# Deal Hound — End-to-End User Flow Specification

**Version:** 1.1 (2026-05-10)
**Purpose:** Single source of truth for pre-launch Playwright e2e tests, manual QA, and subagent-orchestrated test runs. Living doc — update when flows change.
**Companion:** [LAUNCH_STRATEGY.md](../LAUNCH_STRATEGY.md), [PRODUCT_SPEC.md](../PRODUCT_SPEC.md).

> Each flow below is a **testable contract**. If the code drifts from this doc, either the code is wrong or the doc is wrong — fix one. Don't let them disagree silently.

## Changelog

- **1.1 (2026-05-10):** Removed Flow J (public scan report viral loop — product decision to retire). Locked Flow E with Option A: cap free users from day 1; no "beta unlimited" period; Founding $49/mo lifetime with token cap; top-up for overflow.
- **1.0 (2026-05-10):** Initial mapping of A–L from current code.

---

## Locked Launch Policy (read before editing flows)

1. **No "beta unlimited."** Token cost is real from day 1. Free scan submission = exactly 1 scan per email (the lead-magnet scan), then paywall.
2. **Founding Member:** $49/mo, **price locked for life**, **all current + future skills always included**, capped at 10 agent runs/month.
3. **Cap enforcement is mandatory.** A super-user must NOT be able to exceed their tier's monthly run cap or per-skill COGS cap. The worker is the last line of defense (per-skill $1.50 hard kill).
4. **Top-up SKU exists** — $25 one-time = +5 runs. (Note: see Flow I for a known handler bug to fix before launch.)
5. **No public scan viewer.** All delivered scans are accessed via the email magic link → dashboard. The `/scan/:id` public report is being retired; magic link is the only path.
6. **Sign-in is email-only** for now. Anyone with the user's email can open their dashboard. Disclose on the gate or upgrade to magic-link-only sign-in before scaling beyond Founding Members.

---

## 0. System Map

### 0.1 Surfaces (what users actually touch)

| #   | Surface                                               | URL                                                                         | File                                                             | Auth required                |
| --- | ----------------------------------------------------- | --------------------------------------------------------------------------- | ---------------------------------------------------------------- | ---------------------------- |
| 1   | Marketing home / pricing                              | `/`                                                                         | [index.html](../index.html)                                      | No                           |
| 2   | Free async scanner                                    | `/free-scan`                                                                | [free-scan/index.html](../free-scan/index.html)                  | No (email-gated for results) |
| 3   | ~~Public scan report~~ **DEPRECATED** — being retired | `/scan/:id`                                                                 | [scan/index.html](../scan/index.html)                            | (was: No)                    |
| 4   | Magic-link landing                                    | `/api/magic-link?token=...` → 302 → `/dashboard?email=&scan_id=&from=magic` | [api/\_lib/magic-link-route.js](../api/_lib/magic-link-route.js) | HMAC token                   |
| 5   | Dashboard (chat + deals)                              | `/dashboard`                                                                | [dashboard/src/app.jsx](../dashboard/src/app.jsx)                | Email-only "soft auth"       |
| 6   | Standalone chat (legacy)                              | `/chat`                                                                     | [chat/index.html](../chat/index.html)                            | Email-gated                  |
| 7   | Stripe checkout                                       | `checkout.stripe.com/...`                                                   | [api/create-checkout.js](../api/create-checkout.js)              | No                           |

### 0.2 API contract

| Endpoint                                     | Method     | Purpose                                              | Called from                       |
| -------------------------------------------- | ---------- | ---------------------------------------------------- | --------------------------------- |
| `/api/health`                                | GET        | Liveness                                             | Smoke tests, internal             |
| `/api/free-scan-start`                       | POST       | Public free scan kickoff                             | `/free-scan` form                 |
| `/api/scan-start`                            | POST       | Authenticated scan kickoff (paywall-gated)           | Dashboard chat after buy-box save |
| `/api/scan-progress?id=`                     | GET        | Poll scan status                                     | Dashboard scan view, `/scan/:id`  |
| `/api/scan-report?id=`                       | GET        | Public report data                                   | `/scan/:id`                       |
| `/api/scan-report?_action=magic-link&token=` | GET        | Verify token, redirect to dashboard                  | Email CTA                         |
| `/api/chat`                                  | POST (SSE) | Streaming buy-box conversation                       | Dashboard chat, `/chat`           |
| `/api/conversation`                          | GET/POST   | Load/manage chat threads                             | Dashboard chat                    |
| `/api/user-data?email=`                      | GET        | Bootstrap dashboard state (scans, deals, agent name) | Dashboard on login                |
| `/api/deal-actions`                          | POST       | Star / view / archive a deal                         | Dashboard deal cards              |
| `/api/deal-chat`                             | POST (SSE) | Per-deal Q&A                                         | Dashboard deal preview            |
| `/api/create-checkout`                       | POST       | Stripe session for tier or top-up                    | Homepage pricing buttons          |
| `/api/stripe-webhook`                        | POST       | Sync subscription state                              | Stripe                            |

### 0.3 Auth model (read this carefully — it's not what you'd expect)

- **There is no password.** Auth is email-only.
- `localStorage.dh_email` = the active session. If present, dashboard auto-loads with that email.
- The Settings panel "Sign out" button just clears localStorage and reloads.
- Magic links from email use HMAC-signed tokens (24h TTL, see [api/\_lib/magic-link.js](../api/_lib/magic-link.js)). On click → 302 to `/dashboard?email=X&scan_id=Y&from=magic` → app sets `localStorage.dh_email = email`, strips query params, routes to scan view.
- **Anyone who knows your email can open your dashboard.** This is intentional (bridge-product launch), but we MUST flag it to users before launch and harden later.
- Server-side paywall check (`api/_lib/paywall.js`) is the real gate. If `users.subscription_tier == null` → `/api/scan-start` returns 402 paywall response. **Free public scans bypass this** by going through `/api/free-scan-start`.

### 0.4 Worker / async pipeline (out-of-process)

```
POST /api/free-scan-start (or /api/scan-start)
  → INSERT into deal_searches (status='pending')
  → INSERT into scrape_jobs (status='pending')

worker.js (PM2 on Mac Pro, polls every 60s)
  → spawn `claude -p "/find-deals full"` with buy box
  → skill writes scan_progress events as it goes
  → skill writes deals to Supabase
  → on complete: worker calls sendFreeScanCompleteEmail() with magic link
  → updates deal_searches.status = 'complete'
```

### 0.5 Personas (test fixtures)

| Persona               | Description                                        | Initial DB state                                                        |
| --------------------- | -------------------------------------------------- | ----------------------------------------------------------------------- |
| **P1 Anon**           | Brand-new visitor, no email known                  | none                                                                    |
| **P2 FreeSubmitted**  | Submitted free scan, scan still running            | `users` row, `deal_searches` row status=pending, no `subscription_tier` |
| **P2b FreeDelivered** | Free scan complete, email sent, hasn't clicked yet | `deal_searches.status=complete`, deals exist, `agent_name` assigned     |
| **P3 FreeClaimed**    | Clicked magic link, in dashboard, no subscription  | localStorage.dh_email set, `subscription_tier` still null               |
| **P4 Founding**       | Paid $49 founding member                           | `subscription_tier='founding'`, `agent_runs_used=0`                     |
| **P5 Investor**       | Paid $249 tier                                     | `subscription_tier='investor'`                                          |
| **P6 OverCap**        | Paid user who hit run cap                          | `agent_runs_used >= TIER_LIMITS[tier]`                                  |
| **P7 Cancelled**      | Cancelled subscription                             | `subscription_tier=null`, `stripe_subscription_id=null`                 |

---

## Flow A — Anonymous Visitor → Free Scan Submission

**Goal:** Kick off an async scan without creating an account.
**Persona enters as:** P1 Anon
**Persona exits as:** P2 FreeSubmitted
**Entry URL:** `/` or direct `/free-scan`

### Steps

| #   | User action                                              | URL/State              | Network                                                                                   | Expected                                                                                                               | Assertion                                                     |
| --- | -------------------------------------------------------- | ---------------------- | ----------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------- | -------------------------------------------- |
| A1  | Lands on homepage                                        | `/`                    | —                                                                                         | Hero "Your AI deal team" + tier cards visible                                                                          | `text=Your AI deal team` AND 4 tier cards present             |
| A2  | Clicks "Run a Free Scan" CTA (line 1033)                 | navigation             | —                                                                                         | Routes to `/free-scan`                                                                                                 | URL = `/free-scan`, form visible                              |
| A3  | Fills form: assetType, market, priceMin, priceMax, email | `/free-scan`           | —                                                                                         | All fields accept input; no submit until required filled                                                               | `[name=assetType]`, `[name=market]`, `[name=email]` populated |
| A4  | Submits                                                  | `/free-scan`           | `POST /api/free-scan-start` body `{assetType, market, priceMin, priceMax, email, _hp:""}` | 200 `{ok:true, searchId, agentName}`                                                                                   | Confirmation panel renders within 3s                          |
| A5  | Sees confirmation                                        | `/free-scan` (in-page) | —                                                                                         | "Your AI deal hunter is searching now. Expect your report in your inbox within 60 minutes." Shows assigned agent name. | `text~/searching now                                          | in your inbox/i` visible; agent name visible |

### Acceptance criteria

- A `users` row exists for the submitted email after A4.
- A `deal_searches` row exists with `status='pending'` and the buy-box parameters.
- A `scrape_jobs` row exists for the worker to pick up.
- The form does NOT redirect away from `/free-scan` — confirmation is in-page.
- The honeypot field `website` is **not** visible (CSS-hidden, `aria-hidden="true"`).

### Failure modes to test

| Mode                   | Trigger                                | Expected behavior                                                                                        |
| ---------------------- | -------------------------------------- | -------------------------------------------------------------------------------------------------------- |
| Bot submission         | Honeypot `website` field filled        | 200 fake-success or silent drop (no DB row)                                                              |
| Rate limit (same IP)   | 2nd submission within 24h from same IP | 429 with friendly message                                                                                |
| Invalid email format   | `email=foo`                            | Browser HTML5 validation OR server 400                                                                   |
| Missing required field | Omit `assetType`                       | Inline error "Please select an asset type."                                                              |
| Worker offline         | Submit but worker not running          | Row inserted, scan stays pending; user still sees confirmation (timeout caught by separate alert system) |

### Playwright assertions

```
await page.goto('/free-scan');
await page.selectOption('[name=assetType]', 'Micro Resort');
await page.fill('[name=market]', 'Blue Ridge Mountains, NC');
await page.fill('[name=priceMin]', '500000');
await page.fill('[name=priceMax]', '2500000');
await page.fill('[name=email]', testEmail);
const reqPromise = page.waitForRequest(r => r.url().includes('/api/free-scan-start') && r.method()==='POST');
await page.click('button[type=submit]');
const req = await reqPromise;
expect(JSON.parse(req.postData()).email).toBe(testEmail);
await expect(page.locator('text=/searching now|in your inbox/i')).toBeVisible();
```

---

## Flow B — Worker Runs Scan → Email Delivered

**Goal:** Async worker completes the scan and sends the magic-link email.
**Persona enters as:** P2 FreeSubmitted
**Persona exits as:** P2b FreeDelivered
**Entry URL:** none (out-of-process)

### Steps

| #   | Actor            | Action                                                                                           | Effect                                                                        | Assertion                                                              |
| --- | ---------------- | ------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------- | ---------------------------------------------------------------------- |
| B1  | Worker (PM2)     | Polls `scrape_jobs` every 60s, picks up pending row                                              | `scrape_jobs.status='running'`, `scan_progress` row "Searching marketplaces…" | `scan_progress` row exists with phase 'searching'                      |
| B2  | find-deals skill | Scrapes Crexi/LandSearch/LandWatch via Apify (or local fallback)                                 | `listings` upserts                                                            | row count > 0 in `listings` for this run                               |
| B3  | find-deals skill | Scores listings (Haiku coarse → Sonnet deep)                                                     | `scored_listings` rows; top deals copied into `deals` table                   | `deals` rows exist with `score_breakdown`                              |
| B4  | Worker           | On complete: signs magic-link token (24h), calls `sendFreeScanCompleteEmail`                     | Resend API delivers email                                                     | `deal_searches.status='complete'`                                      |
| B5  | Email arrives    | Subject `"Hey! I found some deals 👀"`, From `{agentName} from Deal Hound <hello@dealhound.pro>` | —                                                                             | Visible in test inbox; HTML contains magic-link button + plaintext URL |

### Acceptance criteria

- Email subject matches **exactly**: `Hey! I found some deals 👀`
- Email "From" is `{agentName} from Deal Hound <hello@dealhound.pro>` (agentName persisted in `users.agent_name`)
- HTML body includes: greeting, listings count, deal count, top deal one-liner (or zero-deal variant copy), CTA button "Open my dashboard →", expiry note "This link expires in 24 hours."
- Magic link points to `/api/magic-link?token=...` and verifies via HMAC.
- If `dealCount === 0`: copy says "I burned through {N} listings and nothing cleared the bar today…" and CTA still appears.

### Failure modes to test

| Mode                         | Setup                    | Expected                                                                                                                         |
| ---------------------------- | ------------------------ | -------------------------------------------------------------------------------------------------------------------------------- |
| Skill timeout / cost cap hit | Force COGS > $1.50       | Worker writes `deal_searches.status='failed'`, `error_reason` set; no email sent (or sent with apology copy — TBD before launch) |
| Resend API down              | `RESEND_API_KEY` missing | Function returns gracefully, logs warning, scan still marked complete; **no silent retry**                                       |
| Worker crash mid-run         | Kill worker process      | `scrape_jobs.status='running'` rows go stale; admin recovery script needed                                                       |
| Zero deals found             | Buy box too narrow       | `deals` rows = 0; email sent with zero-deal variant; magic link still works                                                      |

### Playwright/test approach

This flow is **infrastructure-level** — Playwright can't drive the worker. Test as:

1. Insert `scrape_jobs` row directly in test DB.
2. Mock or run real worker against test DB.
3. Poll `deal_searches.status` until `'complete'` or 5-min timeout.
4. Verify Resend received correct payload (use Resend test mode + their delivery log API).
5. Reconstruct magic link from token signing function and assert it verifies.

Test file: `tests/integration/free-scan-pipeline.test.js` (new).

---

## Flow C — Magic Link → First Dashboard Claim

**Goal:** New user clicks email CTA, lands in dashboard authenticated, sees their scan results.
**Persona enters as:** P2b FreeDelivered
**Persona exits as:** P3 FreeClaimed
**Entry URL:** `https://dealhound.pro/api/magic-link?token={signed_token}`

### Steps

| #   | User action                                 | URL/State                      | Network                                         | Expected                                                                           | Assertion                                                      |
| --- | ------------------------------------------- | ------------------------------ | ----------------------------------------------- | ---------------------------------------------------------------------------------- | -------------------------------------------------------------- |
| C1  | Clicks "Open my dashboard →" in email       | `/api/magic-link?token=...`    | GET                                             | 302 → `/dashboard?email=X&scan_id=Y&from=magic`                                    | redirect status 302; `Location` header parses                  |
| C2  | Browser follows redirect                    | `/dashboard?...&from=magic`    | GET dashboard html                              | App boots, magic-link branch in [app.jsx:120](../dashboard/src/app.jsx) fires      | `localStorage.dh_email` set to magic email                     |
| C3  | App calls `/api/user-data?email=X`          | dashboard SPA                  | GET                                             | 200 `{agent_name, scans:[…], deals:[…], …}`                                        | response includes the scan_id from magic link                  |
| C4  | App switches to scan view (line 134)        | `/dashboard` (params stripped) | `/api/conversation`, `/api/scan-progress`, etc. | Scan thread opens, deals appear in Sidebar grouped by tier (HOT/STRONG/WATCH/PASS) | URL is `/dashboard` (no query); top deal opens in Preview pane |
| C5  | User sees Preview with top deal AI analysis | `/dashboard`                   | `GET /api/deal-actions?_route=files` etc.       | Deal card visible with score breakdown                                             | text matches deal title from DB; tier badge visible            |

### Acceptance criteria

- After C2, `window.location.search` is empty (params stripped via `history.replaceState`).
- After C2, `localStorage.dh_email === magicEmail`.
- After C4, the active scan (`activeThreadId`) === `magicScanId`.
- The dashboard does NOT show the EmailGate component.
- A page refresh keeps the user logged in (auto-load from localStorage).

### Failure modes to test

| Mode                                  | Setup                                                 | Expected                                                                                           |
| ------------------------------------- | ----------------------------------------------------- | -------------------------------------------------------------------------------------------------- |
| Expired token                         | Set token `expires_at` in past                        | `/api/magic-link` returns 401 or redirects to `/dashboard` with no email; EmailGate shown          |
| Tampered signature                    | Modify last char of token                             | HMAC verify fails, 401                                                                             |
| Wrong scan_id (not theirs)            | Sign valid token but scan_id belongs to another email | Loads dashboard, but `routeAfterLoad` falls through (scan not found in their data); no leakage     |
| `/api/user-data` 5xx after magic-link | Stub error                                            | App clears localStorage, falls back to EmailGate (per [app.jsx:142-146](../dashboard/src/app.jsx)) |
| Click magic link twice                | —                                                     | Both work within 24h (token is stateless), then both fail after expiry                             |

### Playwright assertions

```
const token = signMagicLink({email: testEmail, scanId: testScanId});
await page.goto(`/api/magic-link?token=${token}`);
await page.waitForURL(/\/dashboard$/);
expect(await page.evaluate(() => localStorage.getItem('dh_email'))).toBe(testEmail);
await expect(page.locator('text=/HOT|STRONG/i')).toBeVisible({timeout: 10000});
```

---

## Flow D — Returning User → Email-Gate Sign-in

**Goal:** A user who already exists comes back later (email expired, cleared cookies, new device) and signs in via the email gate.
**Persona enters as:** any persona, no `dh_email` in localStorage
**Persona exits as:** same persona, authenticated

### Steps

| #   | User action                           | URL/State    | Network                                  | Expected                                                                                                                      | Assertion                                          |
| --- | ------------------------------------- | ------------ | ---------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------- |
| D1  | Visits `/dashboard` directly          | `/dashboard` | GET dashboard html                       | EmailGate renders: "Your deal hunting command center."                                                                        | `text=command center` visible; email input visible |
| D2  | Types email, clicks "Open Dashboard"  | `/dashboard` | `POST` no — `GET /api/user-data?email=X` | 200 user payload                                                                                                              | localStorage.dh_email set                          |
| D3  | App routes per `routeAfterLoad` rules | `/dashboard` | follow-up calls                          | • Has deals → deal view + top deal in Preview<br>• Has scans no deals → scan view<br>• No scans → onboarding (Quinn greeting) | Correct view rendered per persona                  |

### Acceptance criteria

- EmailGate is the **only** thing visible until login completes.
- On API failure, error message "Could not load your dashboard. Check your connection and try again." renders inline AND localStorage is NOT set (so retry works cleanly).
- Three routing paths above are mutually exclusive — exactly one fires.

### Failure modes to test

| Mode                                  | Setup                                  | Expected                                                                                                         |
| ------------------------------------- | -------------------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| Empty email submit                    | —                                      | HTML5 required prevents; no network call                                                                         |
| Email never seen by system            | Brand-new email                        | `/api/user-data` auto-creates user row + assigns agent name; routes to onboarding                                |
| Network timeout                       | Throttle or 503 stub                   | Inline error renders; localStorage NOT polluted; user can retry                                                  |
| Stale localStorage but DB row deleted | localStorage has email, DB has nothing | `/api/user-data` 404 → app clears localStorage, falls to EmailGate (per [app.jsx:160](../dashboard/src/app.jsx)) |

---

## Flow E — Free User → Attempts New Scan → Hits Paywall → Sees Upgrade Modal

**Goal:** A claimed free-scan user (P3) tries to start a NEW scan from inside the dashboard, is paywall-blocked, and sees a modal that explains the cap and offers Founding Member upgrade.
**Persona enters as:** P3 FreeClaimed
**Persona exits as:** still P3 (sees modal) OR P4 Founding (after upgrade flow)

**Locked policy (Option A, 2026-05-10):**

- The free scan is a one-shot lead magnet. It costs us money and is capped per email per IP per day.
- Any subsequent scan attempt requires a paid tier.
- The dashboard MUST surface an upgrade modal — not silently fail or show a 402 toast.

### Steps

| #   | User action                                | URL/State    | Network                                              | Expected                                                                                                                                                                                                      | Assertion                                                             |
| --- | ------------------------------------------ | ------------ | ---------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------- |
| E1  | Already in dashboard, opens chat           | `/dashboard` | —                                                    | Chat thread visible, "+ New" button or chat input                                                                                                                                                             | new-thread affordance visible                                         |
| E2  | Has conversational buy-box flow with Quinn | `/dashboard` | `POST /api/chat` (SSE)                               | Streamed responses, eventually `buy_box_saved` SSE event with `searchId`                                                                                                                                      | conversation reaches save event                                       |
| E3  | App auto-fires scan-start                  | `/dashboard` | `POST /api/scan-start` body `{searchId}`             | **402** `{error:'paywall', tier:null, runs_used, runs_limit:0}`                                                                                                                                               | response status 402                                                   |
| E4  | Dashboard surfaces upgrade modal           | `/dashboard` | —                                                    | Modal: "You've used your free scan. To run more, become a Founding Member — $49/mo, lifetime price guarantee, all current and future agents." Two CTAs: "Become a Founding Member · $49/mo" / "See all plans" | modal visible, founding CTA visible                                   |
| E5  | Clicks "Become a Founding Member"          | `/dashboard` | `POST /api/create-checkout {tier:'founding', email}` | 200 `{url:'https://checkout.stripe.com/...'}`                                                                                                                                                                 | redirect to Stripe → continues into Flow F                            |
| E6  | Dismisses modal                            | `/dashboard` | —                                                    | Returns to dashboard. The unsaved buy-box conversation is preserved as a draft scan (status='paywalled' or similar) so they can return to it post-upgrade.                                                    | draft visible in sidebar; chat input shows "Upgrade to run this scan" |

### Acceptance criteria (post-fix)

- Settings copy ([Settings.jsx:48](../dashboard/src/components/Settings.jsx)) is updated to reflect real account state (NOT "Beta access — unlimited"). Recommended: "Plan: Free · 0 of 1 free scan remaining" or for paid users "Plan: Founding Member · 7 of 10 runs used · resets May 31."
- The upgrade modal does NOT appear preemptively — only after the 402 response from `/api/scan-start`.
- If founding spots are full (`count(*) WHERE tier='founding' >= 50`), the modal swaps "Founding $49" for "Hunter $79" and explains the founding cap closed.
- If the launch window is past (14 days from first founding signup), founding tier is removed from all upgrade surfaces.
- Free scan IP rate limit (1/day) and email rate limit (1/email forever) are enforced at `/api/free-scan-start` — a free user cannot get more free scans by clicking "Run a Free Scan" again.

### Known issues to fix BEFORE this flow can pass

| #   | Issue                                | File                                                                                    | Action                                                                                     |
| --- | ------------------------------------ | --------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------ |
| 1   | Settings copy lies about plan state  | [dashboard/src/components/Settings.jsx:48-49](../dashboard/src/components/Settings.jsx) | Replace static "Beta access" copy with live runs-counter + plan-name from `/api/user-data` |
| 2   | No in-app upgrade modal exists       | dashboard/src/components/ (new file)                                                    | Build `UpgradeModal.jsx`; trigger on 402 from scan-start                                   |
| 3   | Free scan rate limit not verified    | [api/free-scan-start.js](../api/free-scan-start.js)                                     | Confirm IP+email throttle is in place; add test                                            |
| 4   | "Draft scan" preservation on paywall | [api/scan-start.js](../api/scan-start.js) + dashboard chat                              | Decide: persist the buy-box for post-upgrade resume, or discard and reprompt               |

### Failure modes

| Mode                                            | Setup                     | Expected                                                                                                                                                  |
| ----------------------------------------------- | ------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------- |
| User clicks Founding when 50/50 full            | DB count=50 founding subs | Server returns 409 `{error:'founding_full'}`; modal swaps to Hunter $79 with explanation                                                                  |
| User clicks Founding past 14-day window         | Window expired            | Server returns 410 `{error:'founding_window_closed'}`; modal swaps to Hunter                                                                              |
| User retries scan-start after upgrade completes | DB tier updated           | 200; scan begins; runs counter increments to 1                                                                                                            |
| Webhook lag (paid but DB still null)            | Race                      | Frontend retries `/api/user-data` once after `?checkout=success`; if still null after 5s, polls Stripe directly via `/api/checkout-verify` (TBD endpoint) |

---

## Flow F — Free User → Stripe Upgrade → Returns to Dashboard

**Goal:** P3 user goes through Stripe and lands back in dashboard as a paying member.
**Persona enters as:** P3 FreeClaimed
**Persona exits as:** P4 Founding (or P5 Investor depending on tier)

### Steps

| #   | User action                                                    | URL/State                                   | Network                                           | Expected                                                                                                                                      | Assertion                                                       |
| --- | -------------------------------------------------------------- | ------------------------------------------- | ------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------- |
| F1  | From `/` homepage OR (future) in-app modal, clicks tier button | `/`                                         | `POST /api/create-checkout {tier, email}`         | 200 `{url:'https://checkout.stripe.com/...'}`                                                                                                 | response has Stripe URL                                         |
| F2  | Redirected to Stripe checkout                                  | `checkout.stripe.com`                       | (Stripe-hosted)                                   | Stripe checkout shows correct price + product                                                                                                 | Stripe page reachable                                           |
| F3  | Completes payment with test card                               | `checkout.stripe.com`                       | Stripe webhook fires `checkout.session.completed` | `/api/stripe-webhook` upserts `users` with `subscription_tier`, resets `agent_runs_used=0`, sets `agent_runs_reset_at` to first-of-next-month | DB row updated                                                  |
| F4  | Stripe redirects back                                          | `/dashboard?checkout=success&tier=founding` | dashboard SPA boots                               | App shows success toast/banner (TBD); user can now start scans                                                                                | toast visible; subsequent `/api/scan-start` returns 200 not 402 |
| F5  | User cancels at Stripe                                         | `checkout.stripe.com` cancel                | redirect to `/dashboard?checkout=cancelled`       | App shows neutral "no charge" message                                                                                                         | URL param parsed; no DB write                                   |

### Acceptance criteria

- Founding tier ONLY appears as option if `count(*) FROM users WHERE subscription_tier='founding' < 50` AND launch window not expired.
- Webhook is idempotent — replaying the same `checkout.session.completed` event does not double-grant runs.
- After F3, `users.stripe_customer_id` and `users.stripe_subscription_id` are set.

### Failure modes to test

| Mode                                              | Setup                                   | Expected                                                                                                                                                                                           |
| ------------------------------------------------- | --------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Stripe webhook arrives before user redirects back | —                                       | DB updated first; on F4 dashboard reflects paid status immediately                                                                                                                                 |
| Webhook never arrives (Stripe outage)             | Disable webhook                         | User redirected to dashboard with `checkout=success` but DB still says null tier; **need a fallback** — recommend secondary check on `/api/user-data` that polls Stripe API by `stripe_session_id` |
| User pays for Founding after cap hit              | Race condition: 50 paid, 51st in-flight | Server-side check in `/api/create-checkout` rejects with `{error:'founding_full'}`; existing webhook code handles correctly via constraint                                                         |
| Different email at Stripe vs dashboard            | User changes email at checkout          | Webhook upserts by `email` from Stripe — could create duplicate user. **Test this and lock down** before launch                                                                                    |

---

## Flow G — Paid User → Conversational Scan via Chat

**Goal:** A paying user runs a scan by talking to Quinn (the in-app chat agent).
**Persona enters as:** P4/P5 (any paid tier with runs left)
**Persona exits as:** same persona, +1 agent_runs_used

### Steps

| #   | User action                                             | URL/State    | Network                                                           | Expected                                                                                | Assertion                      |
| --- | ------------------------------------------------------- | ------------ | ----------------------------------------------------------------- | --------------------------------------------------------------------------------------- | ------------------------------ |
| G1  | Opens dashboard                                         | `/dashboard` | `/api/user-data`                                                  | If P4/P5 has prior data → routed per `routeAfterLoad`; else onboarding                  | view rendered                  |
| G2  | Clicks "+ New" or starts chat in onboarding             | `/dashboard` | —                                                                 | Empty chat, Quinn greeting                                                              | text contains greeting         |
| G3  | Types criteria ("Find me micro resorts in TN under 2M") | `/dashboard` | `POST /api/chat` (SSE)                                            | Quinn streams clarifying questions                                                      | SSE chunks received            |
| G4  | Confirms buy box                                        | `/dashboard` | `POST /api/chat` continues                                        | Server emits SSE events: `text` chunks → `conversation_id` → `buy_box_saved {searchId}` | `buy_box_saved` event observed |
| G5  | App auto-fires scan                                     | `/dashboard` | `POST /api/scan-start {searchId}`                                 | 200 `{ok:true}`; `agent_runs_used` incremented                                          | DB `users.agent_runs_used` +1  |
| G6  | Scan view opens with progress                           | `/dashboard` | `GET /api/scan-progress?id=X` (poll every 2-5s)                   | Steps stream in: "Searching marketplaces…" → "Scoring 1,247 listings…" → "Complete"     | progress bar advances          |
| G7  | Deals appear as scoring completes                       | `/dashboard` | next `/api/user-data` or `/api/scan-progress` includes deal_count | Sidebar populates HOT/STRONG/WATCH/PASS groups                                          | tier groups have items         |
| G8  | User clicks a deal                                      | `/dashboard` | switches activeThreadId to deal                                   | Preview pane shows full deal card + AI analysis + per-deal chat input                   | deal title visible             |

### Acceptance criteria

- `users.agent_runs_used` increments by exactly 1 per scan kickoff (idempotent — duplicate POSTs to `/api/scan-start` for same `searchId` do NOT double-increment).
- Worker COGS cap ($1.50/scan) enforced; if hit, scan ends with partial deals + `error_reason='cost_cap_hit'`.
- SSE stream from `/api/chat` always emits `conversation_id` event before any subsequent message in a thread (so client can group).

### Failure modes to test

| Mode                         | Setup                      | Expected                                                                                                  |
| ---------------------------- | -------------------------- | --------------------------------------------------------------------------------------------------------- |
| User cancels mid-chat        | Close tab during streaming | Conversation row exists with partial messages; resumable on next visit                                    |
| Worker offline               | Stop PM2                   | Scan stays `pending`; dashboard polling shows "Still searching…" indefinitely; need timeout + alert (TBD) |
| Buy box too narrow → 0 deals | Submit `priceMax=1000`     | Scan completes with 0 deals; dashboard shows zero-state with "Loosen filters" suggestion                  |
| Quinn loops (LLM error)      | Force chat error           | Inline error in chat thread; thread saved with error marker; user can restart                             |

---

## Flow H — Paid User → Re-runs / Multiple Buy Boxes

**Goal:** A returning paid user runs additional scans across visits.
**Persona enters as:** P4/P5 with one prior scan
**Persona exits as:** same persona, multiple scans, history visible

### Steps

| #   | User action                            | URL/State    | Network                                           | Expected                                                                           | Assertion                        |
| --- | -------------------------------------- | ------------ | ------------------------------------------------- | ---------------------------------------------------------------------------------- | -------------------------------- |
| H1  | Returns next day, opens `/dashboard`   | `/dashboard` | `/api/user-data`                                  | Auto-loaded via localStorage; routed to deal view (top deal from most recent scan) | top deal in Preview              |
| H2  | Sidebar shows past scans + deals       | `/dashboard` | —                                                 | Sidebar lists all `scans` + grouped deals                                          | scan count matches DB            |
| H3  | Clicks "+ New scan"                    | `/dashboard` | —                                                 | Empty chat for new buy box                                                         | new conversation_id eventually   |
| H4  | Repeats Flow G with different criteria | `/dashboard` | `/api/chat` → `/api/scan-start`                   | New `deal_searches` row, new `agent_runs_used+=1`                                  | DB has 2 searches for this user  |
| H5  | Switches between scans via sidebar     | `/dashboard` | `/api/conversation`                               | Each scan thread preserves its chat + deal grouping                                | switching is <500ms              |
| H6  | Stars a deal in scan A                 | `/dashboard` | `POST /api/deal-actions {action:'star', deal_id}` | 200; star icon filled                                                              | DB `user_deal_stars` upserted    |
| H7  | Archives a deal                        | `/dashboard` | `POST /api/deal-actions {action:'archive'}`       | Deal removed from active list                                                      | DB `user_deal_archives` upserted |

### Acceptance criteria

- Stars and archives are per-user (P5's stars do not appear for P4 looking at the same pooled deal).
- The "agent runs used" counter is visible somewhere in the UI (TBD location — Settings is the natural place, currently empty on this).
- Multiple scans for the same user are isolated — `/api/conversation` does NOT bleed messages across `conversation_id`s.

### Failure modes to test

| Mode                                          | Setup                               | Expected                                                                 |
| --------------------------------------------- | ----------------------------------- | ------------------------------------------------------------------------ |
| Two paid users see the same pooled deal       | Both ran scans hitting same listing | Each user's stars/views/archives are isolated                            |
| Concurrent scan kickoffs (double-click "Run") | Click button twice fast             | Only one `agent_runs_used+=1`; second call returns 409 conflict or no-op |
| User signs out mid-scan                       | Click sign-out while scan running   | Scan continues server-side; on re-login, dashboard shows scan complete   |

---

## Flow I — Paid User → Hits Run Cap → Top-up SKU

**Goal:** A paid user exhausts monthly runs and either tops up or waits.
**Persona enters as:** P6 OverCap
**Persona exits as:** same persona OR P6+5runs after top-up

### Steps

| #   | User action                          | URL/State                                | Network                                             | Expected                                                                                                                | Assertion    |
| --- | ------------------------------------ | ---------------------------------------- | --------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------- | ------------ |
| I1  | Tries to start a scan                | `/dashboard`                             | `POST /api/scan-start`                              | 402 `{error:'cap_hit', tier, runs_used, runs_limit}`                                                                    | status 402   |
| I2  | Dashboard shows top-up modal         | `/dashboard`                             | —                                                   | Modal: "You've used your monthly compute. Top up 5 runs for $25, or wait until next month." Two CTAs: "Top up" / "Wait" | text visible |
| I3  | Clicks "Top up"                      | `/dashboard`                             | `POST /api/create-checkout {tier:'topup', email}`   | 200 Stripe URL                                                                                                          | redirect     |
| I4  | Stripe one-time charge $25           | `checkout.stripe.com`                    | webhook `checkout.session.completed` mode=`payment` | Webhook adds 5 to a `bonus_runs` field (TBD schema) OR decrements `agent_runs_used` by 5                                | DB updated   |
| I5  | Returns to dashboard, can scan again | `/dashboard?checkout=success&tier=topup` | `/api/scan-start` retries                           | 200                                                                                                                     | scan begins  |

### Known gap

Top-up SKU exists in `/api/create-checkout` (`tier:'topup'` → $25 one-time) but the **webhook handler doesn't have a documented branch for `mode='payment'` granting bonus runs**. Verify before testing — this may need to be implemented.

### Failure modes to test

| Mode                                   | Setup                | Expected                                                                                    |
| -------------------------------------- | -------------------- | ------------------------------------------------------------------------------------------- |
| Per-skill COGS cap mid-scan            | Force expensive scan | Worker terminates, returns partial; counts as 1 run; "run capped — refine criteria" message |
| `agent_runs_reset_at` passes mid-month | Manipulate timestamp | Next scan attempt resets `agent_runs_used=0` and proceeds                                   |

---

## Flow J — ~~Public Scan Report~~ **REMOVED 2026-05-10**

The `/scan/:id` public viewer is being retired. Magic link in the email routes directly to `/dashboard?email=X&scan_id=Y&from=magic` (Flow C) — that is now the **only** path to a delivered scan. The viral-loop strategy in [LAUNCH_STRATEGY.md §6](../LAUNCH_STRATEGY.md) is being revisited; if/when a new sharing surface is designed, it gets its own flow here.

**Cleanup TODO (separate task):**

- Remove `/scan/:id` rewrite from [vercel.json](../vercel.json)
- Remove [scan/index.html](../scan/index.html)
- Remove `/api/scan-report?id=` (the report-data endpoint) — keep only the `?_action=magic-link` route, which lives in the same file
- Update [LAUNCH_STRATEGY.md §6 Virality](../LAUNCH_STRATEGY.md) to reflect the new direction

---

## Flow K — Stripe Webhook Sync (background)

**Goal:** Out-of-band Stripe events (cancel, subscription update, payment failure) reflect in DB.

### Cases

| Event                                         | Webhook handler behavior                            | Test setup                | Assertion                                      |
| --------------------------------------------- | --------------------------------------------------- | ------------------------- | ---------------------------------------------- |
| `customer.subscription.deleted`               | Clear `subscription_tier`, `stripe_subscription_id` | Cancel sub via Stripe CLI | DB row reflects null tier                      |
| `invoice.payment_failed`                      | (TBD: dunning email? Grace period?)                 | Trigger via Stripe CLI    | Document expected behavior before launch       |
| `checkout.session.completed` (subscription)   | Upsert tier, reset run counter                      | Complete test checkout    | `agent_runs_used=0`, `agent_runs_reset_at` set |
| `checkout.session.completed` (payment, topup) | Grant bonus runs                                    | Complete top-up checkout  | DB reflects bonus runs (TBD schema)            |
| Replay of any event                           | Idempotent                                          | Re-fire same event        | No double-counting                             |

### Failure modes

- Webhook signature invalid → 400, no DB write
- Webhook for unknown email → create user row OR reject? (Decide before launch)
- Webhook for already-cancelled sub → no-op

---

## Flow L — Sign-out and Re-entry

| #   | User action                  | URL/State    | Effect                                                                           |
| --- | ---------------------------- | ------------ | -------------------------------------------------------------------------------- |
| L1  | In dashboard, opens Settings | `/dashboard` | Settings panel slides over                                                       |
| L2  | Clicks "Sign out"            | `/dashboard` | `localStorage.removeItem('dh_email')` + `removeItem('dh_notif_digest')` + reload |
| L3  | Page reloads                 | `/dashboard` | EmailGate renders (no localStorage)                                              |
| L4  | Re-enters email              | `/dashboard` | Resumes Flow D                                                                   |

### Assertions

- After L2, localStorage has no `dh_*` keys.
- No server call is made on sign-out (purely local).
- Page reload does NOT auto-sign-in.

---

## 11. Cross-Flow Edge Cases

| #   | Case                                                                  | Test                                                                                    |
| --- | --------------------------------------------------------------------- | --------------------------------------------------------------------------------------- |
| 1   | Two browser tabs open with different `dh_email` localStorage          | Last write wins per tab; data isolation by email                                        |
| 2   | User changes email mid-session (manual localStorage edit)             | App reloads, shows new user's data; no leakage                                          |
| 3   | Scan completes WHILE user is in dashboard                             | Polling picks up `status='complete'`; deals appear; no refresh needed                   |
| 4   | Free scan email ends up in spam                                       | Not testable in CI; manual deliverability check (Mail Tester, Glock Apps) before launch |
| 5   | User opens `/dashboard` while their only scan is still pending        | Routed to scan view (not onboarding); progress indicator visible                        |
| 6   | DB row for `users.subscription_tier` set externally to invalid string | `/api/scan-start` paywall returns "tier_unknown" 500 — must be graceful                 |
| 7   | Concurrent free-scan submissions for same email                       | First inserts user; second hits rate limit OR enqueues separate scan (decide)           |

---

## 12. Test Orchestration Plan

When we move to Playwright + subagent-driven testing, the orchestration map:

### 12.1 Test files to create

| Flow  | Test file                                         | Type                                           |
| ----- | ------------------------------------------------- | ---------------------------------------------- |
| A     | `tests/e2e/free-scan-submit.spec.ts`              | Playwright                                     |
| B     | `tests/integration/free-scan-pipeline.test.js`    | Vitest + worker harness                        |
| C     | `tests/e2e/magic-link-claim.spec.ts`              | Playwright + token signer                      |
| D     | `tests/e2e/email-gate-signin.spec.ts`             | Playwright                                     |
| E     | `tests/e2e/free-user-paywall.spec.ts`             | Playwright (depends on upgrade-modal ship)     |
| F     | `tests/e2e/stripe-upgrade.spec.ts`                | Playwright + Stripe test mode                  |
| G     | `tests/e2e/conversational-scan.spec.ts`           | Playwright (long-running, mark @slow)          |
| H     | `tests/e2e/multi-scan-history.spec.ts`            | Playwright                                     |
| I     | `tests/e2e/run-cap-topup.spec.ts`                 | Playwright (depends on top-up handler bug fix) |
| ~~J~~ | ~~public-report-viral~~ — flow removed 2026-05-10 | —                                              |
| K     | `tests/integration/stripe-webhook.test.js`        | Vitest + Stripe CLI                            |
| L     | `tests/e2e/signout-reentry.spec.ts`               | Playwright                                     |

### 12.2 Subagent parallelization (for `/subagent-driven-development`)

**Independent (run in parallel):**

- Group P1: A, D, L (no cross-dependencies, frontend-only)
- Group P2: K (webhook), B (worker pipeline) — backend-only

**Sequential dependencies:**

- A → B → C (each builds on prior state)
- D → E → F → G → H → I (paid-user journey, sequential persona evolution)

**Recommended swarm:**

- Agent #1: Frontend (A, D, L) — single browser, sequential
- Agent #2: Pipeline + auth (B, C) — needs worker + token signer
- Agent #3: Payments (E, F, K, I) — needs Stripe test mode setup
- Agent #4: Paid journey (G, H) — long-running, real worker

Each agent owns its own test fixtures + DB cleanup. Shared helpers in `tests/helpers/`:

- `personas.js` — DB seed for each persona state
- `magic-link-signer.js` — wrap `signMagicLink` for tests
- `stripe-fixtures.js` — test customer/subscription factories
- `worker-poll.js` — wait for `deal_searches.status='complete'` with timeout

### 12.3 Pre-flight checklist (must be GREEN before subagents launch)

**Code changes required:**

1. ⬜ **Settings.jsx truthful copy** — replace "Beta access — Unlimited" with live runs counter from `/api/user-data`
2. ⬜ **UpgradeModal component** — built and wired to fire on 402 from `/api/scan-start`
3. ⬜ **Top-up webhook bug fix** — [api/stripe-webhook.js:85-100](../api/stripe-webhook.js) currently INCREMENTS `agent_runs_used` by 5 on top-up, which makes the user MORE blocked, not less. Should grant 5 to a `bonus_runs` field (new column) and the paywall check becomes `used >= (limit + bonus_runs)`. See Flow I.
4. ⬜ **Free-scan rate limit** — confirm IP+email throttle in [api/free-scan-start.js](../api/free-scan-start.js)
5. ⬜ **(Optional) Remove `/scan/:id`** — vercel.json + scan/index.html + scan-report endpoint

**Infra / credentials required:** 6. ⬜ Playwright installed (`npm i -D @playwright/test playwright`); test script in package.json 7. ⬜ `worker.js` running on Mac Pro (`pm2 status`) 8. ⬜ Apify wired (or local Crexi/LandSearch/LandWatch fallback works) 9. ⬜ Stripe test-mode keys in `.env.test` + test customer + test products for all 4 tiers + topup 10. ⬜ Resend domain verification confirmed (`hello@dealhound.pro` actually delivers — DKIM/SPF/DMARC set) 11. ⬜ Resend test mode token for delivery-log API access in CI 12. ⬜ Test Supabase branch (or test schema) with isolated `users`, `deal_searches`, `scrape_jobs`, etc. 13. ⬜ Worker can be pointed at test DB via env var (verify `SUPABASE_URL` is per-env)

**Test infra to scaffold:** 14. ⬜ `tests/helpers/personas.js` 15. ⬜ `tests/helpers/magic-link-signer.js` 16. ⬜ `tests/helpers/stripe-fixtures.js` 17. ⬜ `tests/helpers/worker-poll.js` 18. ⬜ `playwright.config.ts` with baseURL pointing at preview deployment

### 12.4 Definition of "ready to launch"

All flows A–I, K, L pass on green. (Flow J retired.) Specifically:

- A: 100% pass, sub-3s confirmation
- B: ≥90% scans deliver email within 10 min in CI test mode
- C: 100% pass, magic-link round-trip ≤5s
- D: 100% pass on all 3 routing branches
- E: 100% pass with upgrade modal firing on 402
- F: 100% pass, webhook idempotent under replay
- G: 100% pass, scan completes ≤10 min
- H: 100% pass, isolation verified
- I: 100% pass with top-up correctly granting headroom (after handler bug fix)
- K: 100% pass on all event types
- L: 100% pass

---

## 13. Open Questions / Decide Before Test Build

| #   | Question                                       | Status                                                                                                                                                        |
| --- | ---------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1   | ~~Paywall copy contradiction~~                 | ✅ **Resolved 2026-05-10** — Option A locked. Cap from day 1, no beta-unlimited. See Locked Launch Policy.                                                    |
| 2   | Top-up webhook bug                             | 🔴 **Open** — handler increments `agent_runs_used` instead of granting headroom. Needs schema (`bonus_runs` column) + paywall check update + handler rewrite. |
| 3   | ~~Pending scan visited via `/scan/:id`~~       | ✅ **Obviated** — public `/scan/:id` removed.                                                                                                                 |
| 4   | Worker timeout / scan failure email            | 🟡 **Open** — do we email "scan failed" or stay silent? UX call.                                                                                              |
| 5   | Different email at Stripe vs dashboard         | 🟡 **Open** — reject, merge, or warn?                                                                                                                         |
| 6   | Daily digest email                             | 🟡 **Open** — Settings has toggle but is the cron wired?                                                                                                      |
| 7   | Auth-by-email-only security disclosure         | 🟡 **Open** — one-line note on EmailGate, OR upgrade to magic-link-only.                                                                                      |
| 8   | `hello@dealhound.pro` Resend verification      | 🟡 **Open** — confirm DKIM/SPF/DMARC set + at least one real successful delivery to Gmail/Outlook before testing.                                             |
| 9   | "Draft scan" preservation on paywall (Flow E6) | 🟡 **Open** — persist user's unsaved buy box for resume after upgrade, or discard?                                                                            |
