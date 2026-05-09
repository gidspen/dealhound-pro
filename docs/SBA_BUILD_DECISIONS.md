# Deal Hound SBA — Build Decisions (locked)

**Source of truth for the 3-run autonomous build.** Every fresh agent session reads this file before doing anything. Do not deviate without explicit user approval.

---

## Mission

Ship a working off-market SBA acquisition lead test pilot at `dealhound.pro/sba` so one user (Gideon's buddy) can hit it, generate TX dental practice leads scored 0–100, view drafted outreach, and give feedback. Not a commercial product. Optimize for fast iteration over polish.

**Who this is for:** one test user, no marketing surface needed yet.
**What success looks like:** buddy logs in via magic link → sees SBA buy box → fills it out → gets scored TX dental practices with signal stacks and drafted outreach → can ask follow-up questions per lead → can export CSV.

---

## Locked decisions

| Decision | Value | Reason |
|---|---|---|
| Pricing / paywall | **Cut entirely.** No Stripe, no free-tier gate, no $-anything. | Test pilot, not commercial product. |
| Owner-age field on schema | **Drop.** Implicit in signals. | Single LinkedIn-grad-year proxy too fragile for structured `number`. |
| LinkedIn signals (3 of 13, 25 pts) | **Partial scoring.** Score on whatever fires. Document the gap. | LinkedIn scraping costs money / gets blocked. Pay later via Apollo. |
| Owner enrichment | **Free path only:** scrape practice website contact/about page for email + phone. Email/phone may be `null`. Future: Apollo.io ($79/mo) when paying. | Test pilot doesn't need 100% contact coverage. |
| Lead exclusivity | **Both users see the same lead.** No exclusivity logic. | Pilot has one user; logic adds complexity for no value. |
| Free tier | **No tier logic at all.** Logged-in users see everything. | Ditto. |
| Outreach | **Drafted only, never auto-sent.** User copy/pastes. | Deliverability is its own product. |
| Vertical | **Dental only.** | PRD locked it. Cleanest licensing data. |
| Geography | **Texas only.** | PRD locked it. Public licensing data accessible. |

---

## Route architecture

The Deal Hound dashboard is a **Preact SPA** rooted at `dashboard/` with **state-driven view routing** (no URL router; `view` signal in `dashboard/src/lib/state.js` toggles between `onboarding` / `scan` / `deal`).

**`/sba` integration plan:**

1. **Vercel rewrite** — add `{ "source": "/sba", "destination": "/dashboard-dist/index.html" }` and `{ "source": "/sba/(.*)", "destination": "/dashboard-dist/index.html" }` to `vercel.json`.
2. **Product signal** — add `product` signal to `dashboard/src/lib/state.js`, default `'realestate'`. On app boot, detect URL: if `window.location.pathname.startsWith('/sba')`, set `product.value = 'sba'`.
3. **Conditional rendering** — `Chat.jsx`, `DealCard.jsx`, `Preview.jsx`, `Sidebar.jsx` branch on `product.value` to swap copy, prompts, and card structure.
4. **Shared infrastructure** — magic-link auth, Supabase client, layout shell, resize handles, settings panel: **reuse as-is**.
5. **New API routes** — `api/sba-scan-start.js`, `api/sba-leads.js`, `api/sba-deal-chat.js`. Mirror existing patterns in `api/scan-start.js`, `api/scan-progress.js`, `api/deal-chat.js`.
6. **New Supabase table** — `sba_leads` (schema below).

**Why not a separate top-level `sba/` HTML?** Marketing landing isn't needed for the pilot. Reusing the dashboard SPA = ~80% less code + automatic feature parity (auth, layout, state, chat).

---

## Supabase schema — `sba_leads` table

```sql
create table public.sba_leads (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.users(id) on delete set null,
  scan_id uuid references public.sba_scans(id) on delete cascade,

  -- business identity
  business_name text not null,
  vertical text not null default 'dental',
  address text,
  city text,
  state text not null default 'TX',
  zip text,
  phone text,
  website text,

  -- owner identity (nullable — partial enrichment)
  owner_name text,
  owner_email text,
  owner_phone text,
  owner_linkedin text,

  -- business facts
  years_in_business integer,
  license_year integer,

  -- scoring
  retirement_score integer not null check (retirement_score between 0 and 100),
  retirement_tier text not null check (retirement_tier in ('HOT','STRONG','WATCH','DISCARD')),
  signals jsonb not null default '[]'::jsonb,

  -- outreach
  outreach_angle text,
  outreach_subject text,
  outreach_body text,

  -- lifecycle
  status text not null default 'new' check (status in ('new','contacted','responded','rejected','in_progress','snoozed')),
  scored_at timestamptz not null default now(),
  last_refreshed timestamptz not null default now(),

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index sba_leads_user_id_idx on public.sba_leads(user_id);
create index sba_leads_tier_idx on public.sba_leads(retirement_tier);
create index sba_leads_score_idx on public.sba_leads(retirement_score desc);
```

Companion table `sba_scans` (mirrors existing `scans`):

```sql
create table public.sba_scans (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.users(id) on delete cascade,
  vertical text not null default 'dental',
  state text not null default 'TX',
  city text,
  target_lead_count integer not null default 20,
  status text not null default 'scanning' check (status in ('scanning','complete','error')),
  deal_count integer not null default 0,
  conversation_id uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
```

**Migration goes in `supabase/migrations/` if that dir exists, else `db/migrations/`. Detect on Run A.**

---

## Scoring engine spec

13 signals, weighted sum 0–100. Tier thresholds:

| Tier | Score | UI badge color |
|---|---|---|
| HOT | 80–100 | red |
| STRONG | 60–79 | orange |
| WATCH | 40–59 | yellow |
| DISCARD | <40 | hidden from UI |

**Signal definitions (mirror PRD §5.1):**

```ts
const SIGNALS = [
  { key: 'license_25y',         category: 'owner_age',          weight: 15 },
  { key: 'business_reg_25y',    category: 'owner_age',          weight: 10 },
  { key: 'linkedin_grad_pre85', category: 'owner_age',          weight: 10 },  // LinkedIn — likely null in MVP
  { key: 'solo_practitioner',   category: 'succession_vacuum',  weight: 15 },
  { key: 'no_associate',        category: 'succession_vacuum',  weight: 10 },  // partly LinkedIn — likely null
  { key: 'no_family_in_biz',    category: 'succession_vacuum',  weight: 5 },
  { key: 'website_stale_3y',    category: 'digital_decay',      weight: 8 },
  { key: 'outdated_tech',       category: 'digital_decay',      weight: 4 },
  { key: 'dead_social',         category: 'digital_decay',      weight: 5 },
  { key: 'review_velocity_drop',category: 'activity_decline',   weight: 8 },
  { key: 'last_review_60d',     category: 'activity_decline',   weight: 5 },
  { key: 'no_jobs_12mo',        category: 'no_growth',          weight: 3 },  // LinkedIn/Indeed
  { key: 'flat_staff_5y',       category: 'no_growth',          weight: 2 },  // LinkedIn
];
// total = 100
```

Each signal returns `{ fired: boolean, evidence: string, source: string, source_url: string | null }`.
Score = sum of weights for fired signals.

**LinkedIn-dependent signals (`linkedin_grad_pre85`, `no_associate` in part, `no_jobs_12mo`, `flat_staff_5y`) — for MVP, return `{ fired: false, evidence: 'LinkedIn data not yet integrated', source: 'pending' }` and document the 25-point gap.** Real businesses will score against ~75 points until LinkedIn lands.

Engine location: `api/_lib/sba-scoring.js`. Pure function — takes a hydrated business record, returns `{ score, tier, signals }`.

---

## Outreach generator spec

Server-side function in `api/_lib/sba-outreach.js`:

```ts
generateOutreach(lead) → { subject, body, angle }
```

Calls Anthropic API (`@anthropic-ai/sdk` is already a dep). Use `claude-sonnet-4-6` for cost.

**Tone guardrails baked into the system prompt (PRD §14):**
- Lead with respect for what owner built (reference years, location)
- Frame around succession, NOT sale (`next chapter`, `legacy`, `transition planning` — never `sell`, `exit`, `liquidate`)
- Be specific (reference at least one fact about their practice)
- Soft ask (15-min conversation, no-strings)
- Identify broker clearly
- One paragraph max

System prompt template lives in `api/_lib/sba-outreach.prompt.txt` so it's editable without redeploy.

---

## 3-run plan

Each run is a fresh `claude -p` session. Branches stack so runs don't wait on PR merges.

| Run | Branch (off) | Budget | Scope |
|---|---|---|---|
| **A — Foundation** | `feat/sba-foundation` (off `main`) | **60 turns** | Vercel rewrite, `product` signal, `sba_leads` + `sba_scans` migrations, scoring engine, mock-data dashboard render. **No real scrapers.** Verification: load `/sba`, fill buy box, see 20 mock TX dentists ranked HOT/STRONG/WATCH with signal stacks. |
| **B — Data pipeline** | `feat/sba-data-pipeline` (off `feat/sba-foundation`) | **90 turns** | TX Dental Board scraper, TX SoS scraper, Google Places, WHOIS, Wayback, Yelp. Practice-website contact scraper. Wire to scoring engine, persist to Supabase. **Skip LinkedIn — document the gap.** Verification: run pipeline against 50 real TX dental practices, persist, spot-check 5 records by hand. |
| **C — Buddy polish** | `feat/sba-buddy-polish` (off `feat/sba-data-pipeline`) | **40 turns** | Lead detail Q&A chat (preloaded with lead context), CSV export, status updates (`Mark contacted` / `Snooze`). **Cut: weekly digest, Stripe, paywall, lead exclusivity.** Verification: click into a lead, ask "Why HOT?", get answer; export CSV; mark contacted, see status persist. |

---

## Verification bars (per run)

### Run A
1. `vite` dev server starts on port 5173 without errors
2. Navigate to `/sba` (via Vercel or vite proxy) → SPA loads with SBA-themed buy box
3. Submit buy box (TX, dental, city: any) → 20 mock leads render with HOT/STRONG/WATCH badges
4. Click a lead → see signal stack with evidence + drafted outreach
5. Playwright screenshot saved to `verification/run-a-screenshot.png`
6. PR opened with `gh pr create` linking to screenshot

### Run B
1. Run pipeline command (e.g. `node scripts/sba-pipeline.js --state TX --vertical dental --limit 50`)
2. Pipeline completes without uncaught errors
3. Supabase `sba_leads` table has 50+ rows
4. At least 1 row each at HOT, STRONG, WATCH tiers (proves scoring distribution works)
5. Spot-check: 5 random leads' `signals[].evidence` traceable to source URLs
6. PR opened referencing run output log

### Run C
1. Existing Run B leads still load on `/sba`
2. Click a lead → chat panel opens preloaded with lead context → ask "Why was this scored HOT?" → get answer citing specific signals
3. Click "Export CSV" → file downloads with all visible leads
4. Click "Mark contacted" on a lead → status updates in Supabase + UI
5. PR opened with screenshots

---

## Scope fence (HARD — agent must not cross)

**ALLOWED to read/edit:**
- This repo: `/Users/gideonspencer/dealhound-pro/**`
- Specifically: `dashboard/`, `api/`, `scripts/`, `docs/`, `tests/`, `package.json`, `vite.config.js`, `vercel.json`, `supabase/migrations/`, `db/migrations/` (whichever exists), `eslint.config.js`, `tsconfig.json`

**FORBIDDEN:**
- Any file outside `/Users/gideonspencer/dealhound-pro/**`
- Any `.env*` file (read-only — never edit; never print values)
- Anything in `node_modules/`
- `OVERNIGHT_RUN.md` (historical artifact, not a target)
- `LAUNCH_STRATEGY.md` (different product, do not modify)
- Other branches' work — only operate on the assigned branch

**FORBIDDEN ACTIONS:**
- No `git push --force` to any branch
- No `git reset --hard` past origin/main
- No `--no-verify` on commits or pushes
- No deletes — edit only
- No external API calls except: Anthropic API (Sonnet for outreach drafts), Supabase, Google Places (if key set), public scraping (TX Dental Board, TX SoS, WHOIS, Wayback, Yelp)
- **No emails sent. No Slack messages sent. No Stripe charges. No social posts.** Drafts only.
- No live LinkedIn scraping (skip those signals)
- No paid API calls without explicit env keys present (Apollo, Hunter, RocketReach — none configured)

---

## Environment

| Var | Status | Used by |
|---|---|---|
| `ANTHROPIC_API_KEY` | ✅ Set | Outreach drafts, lead Q&A |
| `SUPABASE_URL` | ✅ Set | All persistence |
| `SUPABASE_SERVICE_KEY` | ✅ Set | Server-side writes |
| `GOOGLE_PLACES_API_KEY` | Check on Run B | Google Places lookup |

If `GOOGLE_PLACES_API_KEY` is missing, Run B falls back to scraping practice websites + Yelp only and documents the gap. Do not block.

---

## Workflow per run

1. **Branch up** — `git checkout {parent}` → `git pull` (if parent is `main`) → `git checkout -b {branch}`
2. **Read this file** (`docs/SBA_BUILD_DECISIONS.md`) and the run's prompt file
3. **Write implementation plan** to `docs/RUN_{X}_PLAN.md`. For Run A only: invoke `/autoplan` against this plan, revise per output, commit revised plan.
4. **Build** — Opus orchestrates, Sonnet sub-agents execute file edits / scrapes / shell commands
5. **Verify** against the run's verification bar (above). Save artifacts to `verification/run-{x}-*.{png,log,txt}`.
6. **Self-review** the diff. If pre-push hook fails (`typecheck && test`), fix root cause. Never `--no-verify`.
7. **Commit + push** the branch.
8. **Open PR** with `gh pr create` — title, body with summary + verification artifacts + test plan checklist for the user.
9. **Write final checkpoint** to `docs/RUN_{X}_CHECKPOINT.md` capturing: what was done, what wasn't and why, turns used, sub-agent spawn count, blockers for the next run.

---

## Failure handling

- **MCP disconnect mid-run** (Playwright especially) — fall back to text-based verification (curl + content check). Don't retry indefinitely.
- **Supabase 400 error on insert/update** (known recurring issue) — investigate schema mismatch immediately, do not defer. Local JSON fallback for pipeline outputs.
- **Pre-push hook fails** — fix root cause (typecheck or test break). Never bypass.
- **Turn budget at 80% with goal incomplete** — stop, write FINAL checkpoint with what's done + what's left, open PR with `[wip]` prefix, exit clean. Do NOT keep grinding past budget.

---

## What "done" looks like for the whole 3-run sequence

Three PRs queued in GitHub, all green, all stacked:
1. `feat/sba-foundation` → `main` (foundation slice with mock data)
2. `feat/sba-data-pipeline` → `feat/sba-foundation` (real TX dental data)
3. `feat/sba-buddy-polish` → `feat/sba-data-pipeline` (Q&A + CSV + status)

User reviews and merges in order. Buddy hits `dealhound.pro/sba` (after Vercel preview deploy from PR or after merge to main) and starts giving feedback.
