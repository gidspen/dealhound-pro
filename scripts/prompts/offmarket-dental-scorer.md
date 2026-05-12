# Autonomous build prompt — Off-Market Dental Acquisition Scorer (spike → skill)

You are an autonomous Opus orchestrator. Your job: **produce a real, evidence-backed, scored list of off-market Texas dental practices** that look like good acquisition targets, write it to a Supabase database and to local files, and write a short report. This is the spike that will *become* the `offmarket-acquisition-scorer` skill — so build it like a one-shot pipeline, but document what a productionized skill would need.

Spawn `model: "sonnet"` sub-agents (`subagent_type: "general-purpose"`) for execution work — web fetches, scraping, per-business enrichment, file writes. Opus tokens for planning, scoring logic, and synthesis only. Before each spawn print one line: `DELEGATING: {task} → sonnet`. Before any work you do directly print: `DOING DIRECTLY: {task} ({why})`.

---

## 0. Who this is for / what changed

The user (Gideon) is building this **for himself** — an internal tool to find healthy, long-tenured, *coasting* small-business owners in Texas who are likely to sell in 1–3 years, so he can either **buy the business himself** (highest-signal ones) or **forward it to the ETA / search-fund / independent-sponsor communities he's part of** (the rest). Not a public product. Not a licensed/brokered product right now and possibly never.

There is an older spec in the repo — `SBA_PRODUCT_SPEC.md` and `docs/SBA_BUILD_DECISIONS.md` — describing a public `dealhound.pro/sba` web product with a flat 13-signal score and owner-age dropped from the schema. **Read them for background only.** This run *supersedes* them on these points:

- Internal personal tool, not a public/licensed product.
- **4-layer composite scoring model** (defined in §3 below), not the flat 13-signal sum. You may map the old 13 signals into the 4 layers as inputs.
- **Owner-age enrichment is in scope** (OV65 homestead exemption, voter-file DOB, DMV, license tenure, LinkedIn grad year). The user has authorized use of the Texas voter file and DMV data *for his own private acquisition research only* — see the compliance note in §5. Do not redistribute these fields; tag every owner-age value with its `owner_age_source` so it's auditable.
- **Distressed businesses are excluded** — hard filter, not a low score. We want healthy, profitable, coasting owners with room for value-add (AI front desk / recall automation / online scheduling / modern PMS / review automation / dynamic pricing). Tax liens, judgments, malpractice suits, forfeited charters, closing notices, going-concern problems → drop the business.
- Output goes to a **new Supabase schema `offmarket`** (already created — see §6) plus local JSON/CSV plus a markdown report.

Vertical for this run: **dental practices** (cleanest licensing data; the user has a broker friend who sells dental practices and can grade the output fast). Pest control is next, not now.

Geography for this run: **Texas, prioritizing Harris County (Houston), Dallas County, and Travis County (Austin)**. If you can pull statewide cheaply, keep statewide rows but make sure the three target counties are fully enriched first.

---

## 1. The deliverable (what "done" means)

1. **Supabase**: rows written to schema `offmarket` in project `gggmmjvwbbfvrtjjlqvr` (see §6 for tables/columns and how to write). One `score_runs` row for this run; `businesses` rows; `business_signals` rows; `business_scores` rows (one per business, linked to this run).
2. **Local files** (always write these even if Supabase write fails):
   - `offmarket/data/dental_targets.json` — full structured records (business + signals + 4-layer scores + comments).
   - `offmarket/data/dental_targets.csv` — flattened, one row per business: identity, key facts, the 4 layer scores, 4 layer comments, final score, tier, final comment, value-add thesis, confidence.
   - `offmarket/data/run_manifest.json` — what sources you actually hit, what was blocked, counts, model version + weights, timestamp.
3. **Report**: `offmarket/REPORT.md` — see §7.

**Target volume for this proof run: 60–150 *real, name-verifiable* Texas dental practices, fully enriched and scored, weighted toward Harris/Dallas/Travis.** Depth > breadth. It is far better to ship 80 practices you've genuinely verified and enriched than 1,000 thin rows. **Never invent a practice, an owner, an address, a license number, or a review stat. Every business must be a real, currently-operating Texas dental practice you can point to a source for. Every signal must have an `evidence` string and, where possible, a `source_url`. If you can't verify it, don't include it.**

---

## 2. Data sources (try in this order; document what works and what's blocked)

The `.gov` domains below have returned HTTP 403 to automated fetchers in this sandbox before. That's a sandbox quirk, not a real block. Try anyway; if blocked, fall back as noted and **record the exact URL + error in `run_manifest.json`** — don't silently skip.

**Practice spine (who exists):**
- TX State Board of Dental Examiners (TSBDE) licensee lists / license search — `tsbde.texas.gov` (look for the bulk "licensee lists" CSVs and the license-verification search). Fields wanted: licensee name, license #, license type, status, **original issue date**, city, county, ZIP, any disciplinary flag, and dental-entity / practice registrations.
- Texas Open Data Portal — `data.texas.gov` (Socrata) — search for TSBDE / dental licensee datasets; the Socrata API (`/resource/<id>.json?$limit=...`) often works when the board's own site doesn't.
- Google Maps / Google Places — for the practice as a *business*: name, address, phone, website, # of reviews, **most-recent-review date**, rating, hours, "owner answers"/photos. Use web search + fetching the Google Maps business page; if you have no Places API key, scrape the public listing.
- Yelp / Healthgrades — secondary review-velocity + tenure-on-platform.

**Entity / ownership:**
- TX Comptroller "Taxable Entity Search" — `comptroller.texas.gov/taxes/franchise/account-status/search.php` — entity legal name, SOS file #, registered agent, officers/managers, franchise-tax status (active vs. forfeited — forfeited = distress flag).
- TX SOSDirect (`sos.state.tx.us`) — formation date, filing history, assumed-name certs (lapsed cert = a mild coasting tell). Paid ($1/search) — only if reachable and only for the highest-priority practices.

**Owner age (best → fallback):**
- County Appraisal District **OV65 homestead exemption** — owner self-declared age 65+. Harris = HCAD (`hcad.org`, "PDATA" bulk downloads), Dallas = DCAD (`dallascad.org`), Travis = TCAD (`traviscad.org`). Also gives owner name, homestead address, **deed/acquisition date** (long homestead tenure ≈ settled owner). This is the single cleanest legal owner-age signal in Texas.
- Texas voter file DOB — authorized by the user for his private use only (see §5). Realistically you may not be able to obtain the bulk file in this sandbox; if not, note it and move on.
- DMV — same: authorized for private use only; almost certainly not obtainable here; note and move on.
- License tenure proxy — TSBDE original issue date: licensed ≥30 yrs → owner very likely 55–65+; ≥25 yrs → likely 50–60; ≥20 → likely 45–55. Always usable; lowest confidence.
- LinkedIn graduation year — dental school grad year + ~26 ≈ age. Manual/light only; likely blocked; nice-to-have.

**Behavioral / "coasting" tells:**
- Wayback Machine (`web.archive.org`) — when was the practice website last meaningfully changed? Design age? Snapshot frequency falling off?
- The practice website itself — SSL? mobile-responsive? online booking? modern PMS / patient portal? copyright year in footer? "Dr. X & Associates" but no associates actually listed? team page stale? a single dentist listed?
- WHOIS — domain registration + last-update dates.
- Facebook / Instagram — last post date.
- Job boards (Indeed/Glassdoor) — any hiring in the last 12 months? (no hiring + aging owner = stronger).
- County deed records — does the owner own the building the practice operates in? (real-estate-heavy exit is common for retiring dentists; also a value lever).

**Distress / disqualifier checks (any hit → exclude the business, with a reason in `distress_reasons`):**
- Comptroller franchise-tax status = forfeited / not in good standing.
- TSBDE disciplinary action against the dentist of record.
- State/federal tax liens, civil judgments, malpractice suits (county clerk / PACER-lite searches you can do for free).
- "Closing", "retiring — practice closed", "no longer accepting patients" notices.
- Reviews collapsing *and* complaints spiking (that's distress, not coasting).

---

## 3. The scoring model — 4 layers, 0–100 each, plus a weighted final

For every practice, produce four sub-scores, each with a 1–3 sentence `_comment` that names the specific evidence behind it (cite the signal/source). Be honest about confidence — if Layer 1 rests only on a license-tenure proxy, say so.

### Layer 1 — Base Rate (owner natural-exit timing)
How close is the owner to a natural sell/retire window, based on age and tenure.
- Inputs: owner age (OV65 ⇒ ≥65; voter DOB; else license-tenure proxy), years the owner has run the practice, entity/practice age, long homestead tenure.
- Rough anchors: owner 68+ → 88–100; 63–67 → 75–90; 58–62 → 55–78; 53–57 → 35–58; <53 or only weak/young proxies → 10–35. Tenure ≥25 yrs nudges up; <10 yrs nudges down. Unknown age with a long license tenure → moderate (≈45–60) with low confidence.

### Layer 2 — Sellability / Quality (is it worth buying & SBA-financeable)
Is this a real, healthy, financeable business — not a distressed scrap, not a fresh startup.
- Inputs: recurring/needs-based revenue (dental hygiene recall = recurring ✓), 5+ years in business, more than one person on staff / has systems (a solo GP is fine for dental but caps slightly vs. a 2–4 provider group), clean license & regulatory record, single established or multi-location, plausible SBA 7(a) size (≈$500k–$5M revenue — estimate from provider/chair count + review volume + footprint), and **not distressed** (also a hard gate per §4).
- Anchors: clean multi-provider 10+ yr recurring-revenue practice of reasonable size → 80–95; clean solo 10+ yr → 65–82; <5 yrs in business → ≤35 (near-disqualifying for this thesis); any disciplinary action → heavy penalty.

### Layer 3 — Behavioral Trigger ("coasting owner" — winding down, *not* distressed)
**This is the differentiating layer.** Healthy business, but the owner has visibly stopped pushing — the classic pre-sale profile.
- Positive tells (stack them): website not meaningfully updated 3+ yrs / outdated tech / no SSL / not mobile; review velocity flat or declining (last 6 mo vs. prior 6 mo) or newest review >60 days old; no new associate/provider in years; zero job postings in 12 mo; owner is the sole listed provider / "& Associates" with no associates; no online booking / no modern PMS / patient portal; reduced or "by appointment only" hours creep; no recent capex / dated equipment photos; owner owns the building; lapsed assumed-name cert or never-updated entity housekeeping; OV65 filed.
- **Distinguish coasting from distress.** Coasting = healthy P&L, disengaged owner. Distress = liens/judgments/suits/forfeiture/closing notices/complaint spikes → those businesses are *excluded* (§4), not scored here.
- Anchors: 4+ strong tells → 80–100; 2–3 → 55–80; exactly 1 → 30–55; none → 10–30.

### Layer 4 — Market Pull (acquirer demand for this vertical × metro)
How hot is the buy-side for this kind of business in this place — drives both "can I flip/roll-up" and "will the community want the referral."
- Inputs: DSO / PE roll-up activity in dental (very high — dental is among the most-consolidated SMB verticals; DSO penetration ~30%+ and climbing; many TX-focused DSOs and PE platforms); comparable-transaction velocity in the specific metro (Houston/Dallas/Austin are all active DSO markets); SBA 7(a) financeability of dental acquisitions (top-tier); appetite of the ETA / search-fund / independent-sponsor community.
- Mostly a vertical+metro constant for TX-dental-in-major-metro (expect ≈80–90), nudged by sub-market and specialty (e.g., a perio/endo/pedo specialty practice vs. a general practice; rural vs. metro). State the comparable activity you're basing it on.

### Final score, gates, tiers
- **Hard gates first:** if `is_distressed` → `D_pass`, `final_score` ≤ 25, comment says why; if <5 yrs in business → cap `final_score` ≤ 35; if you genuinely can't verify the practice is real → drop it entirely.
- **Default weights:** L1 0.30, L2 0.25, L3 0.30, L4 0.15. `final_score = round(0.30·L1 + 0.25·L2 + 0.30·L3 + 0.15·L4)`. Record the weights in `score_runs.weights` and `run_manifest.json` so they can be retuned later.
- **Tiers** (`final_tier`):
  - `A_acquire_self` — `final_score ≥ 78` AND `L1 ≥ 70` AND `L3 ≥ 65` AND not distressed AND confidence ≥ medium. → "Gideon pursues this one directly."
  - `B_forward` — `final_score` 60–77, or ≥78 but lower confidence / smaller / weaker L1 or L3. → "Hand to the buyer community."
  - `C_watch` — `final_score` 45–59. → "Re-score in ~90 days."
  - `D_pass` — `final_score` < 45, or distressed, or too young.
- `final_comment` (3–6 sentences): the through-line — who the owner is and how you know their age, what the business is, the coasting tells, the market context, and the tier call. Example shape: *"Dr. Jane Smith, ~67 (OV65 on her Sugar Land homestead, deed 1994), founded Smith Family Dental in Katy in 1991; 3 hygienists, no associate dentist, building owned by her LLC. Website last refreshed 2020, no online booking, Google reviews down ~40% YoY, newest review 4 months old — healthy practice, disengaged owner. West-Houston dental DSO demand is intense and acquisitions are routinely SBA-financed. Tier A: pursue directly."*
- `value_add_thesis` (1–3 sentences): the AI/ops levers — e.g., *"AI front-desk + recall automation to recover the lapsed-hygiene base, online scheduling, modern PMS migration, automated review generation — a plausible 1.5–2× EBITDA path over 18–24 months."*
- `confidence` (`high`/`medium`/`low`) and `data_completeness` (0–1, fraction of model inputs you actually had).

---

## 4. Distress = exclusion

If any distress/disqualifier check hits (§2), set `is_distressed = true`, fill `distress_reasons`, score it `D_pass` with `final_score ≤ 25`, and move on. Do not spend enrichment effort on distressed businesses beyond confirming the flag. The user explicitly does not want distressed targets right now.

---

## 5. Compliance note (do not skip, do not editorialize beyond this)

- Free public records (licensing boards, Comptroller, SoS, county appraisal/clerk, Wayback, WHOIS, Google/Yelp public pages) — fine to use.
- **Texas voter file** (Election Code restricts use of the voter roll obtained from the SOS to non-commercial / election purposes) and **DMV records** (DPPA restricts permissible uses) — the user has directed that these be used **only for his own private acquisition research, never for marketing, never resold, never redistributed**. If you obtain anything from them, store it only in the `offmarket` schema / local files, tag the field's `owner_age_source` accordingly, and note in `run_manifest.json` that these are restricted-use fields. Do not put them in `REPORT.md` summaries beyond the derived age. Realistically you probably can't obtain the bulk files in this environment — if so, just record that and rely on OV65 + license-tenure proxies.
- Don't contact anyone. Don't send anything. No outreach, no emails, no DMs. Output is a scored list only.
- Only operate inside `/home/user/dealhound-pro/**`. Don't read or print `.env*`. Don't `git push`, don't open PRs, don't commit — the human will handle git. No `rm`, no destructive commands.

---

## 6. Supabase target — schema `offmarket` (already created)

Project ID: `gggmmjvwbbfvrtjjlqvr` (the `incredible-ai-deals` project). Schema: `offmarket`. The Supabase MCP server is available — load its tools with `ToolSearch` (query: `select:mcp__fb5b629a-2ffd-443a-bf8f-2e88e58fd1b9__execute_sql,mcp__fb5b629a-2ffd-443a-bf8f-2e88e58fd1b9__apply_migration,mcp__fb5b629a-2ffd-443a-bf8f-2e88e58fd1b9__list_tables`). Use `execute_sql` for inserts (parameterize via literal SQL with proper escaping; insert in batches). If the MCP tools are not available to you, **skip the DB write, finish the local files + report, and say so loudly in `REPORT.md` and `run_manifest.json`** — the human will load from the local JSON.

Tables (all in schema `offmarket`):

- `score_runs` — insert ONE row at the start: `run_label` (e.g. `"dental-tx-spike-2026-05-12"`), `model_version` (e.g. `"offmarket-dental-4layer-v0.1"`), `weights` (jsonb, e.g. `{"layer1":0.30,"layer2":0.25,"layer3":0.30,"layer4":0.15}`), `vertical` `'dental'`, `geography` (e.g. `"TX — Harris/Dallas/Travis priority"`), `notes`. Capture the returned `id` → `score_run_id`.
- `businesses` — one row per practice. Columns: `vertical`('dental'), `legal_name`, `dba_name`, `naics_code`('621210' for dental offices), `address`, `city`, `county`, `state`('TX'), `zip`, `phone`, `website`, `license_number`, `license_type`, `license_status`, `license_issue_date`(date), `license_holder_name`, `entity_sos_file_number`, `entity_formation_date`(date), `entity_status`, `registered_agent`, `years_in_business`(int), `employee_count_estimate`(int), `provider_count_estimate`(int), `employee_count_source`, `owner_name`, `owner_age_estimate`(int), `owner_age_source`, `owner_tenure_years`(int), `owner_homestead_address`, `owner_property_deed_date`(date), `is_distressed`(bool), `distress_reasons`(jsonb array), `data_sources`(jsonb array of `{source,url,fetched_at,fields}`), `raw_enrichment`(jsonb), `notes`. There's a `unique (vertical, legal_name, city, state)` — upsert on conflict.
- `business_signals` — one row per discrete signal: `business_id`, `layer`(1–4), `signal_key`, `direction`('positive'|'negative'|'disqualifying'), `weight`(numeric, optional), `evidence`(text, required), `source`, `source_url`, `observed_at`(date). Aim for ~3–10 signals per non-distressed business.
- `business_scores` — one row per business for this run: `business_id`, `score_run_id`, `layer1_base_rate`+`layer1_comment`, `layer2_sellability`+`layer2_comment`, `layer3_behavioral_trigger`+`layer3_comment`, `layer4_market_pull`+`layer4_comment`, `final_score`, `final_tier`, `final_comment`, `value_add_thesis`, `confidence`, `data_completeness`. `unique (business_id, score_run_id)`.
- After loading, update `score_runs.business_count`.
- There's a view `offmarket.scored_targets` (businesses ⨝ latest score) — use it to sanity-check.

RLS is enabled on these tables with no policies; the MCP connection uses the service role, so writes work. Don't add policies.

---

## 7. `offmarket/REPORT.md`

Keep it tight and skimmable:
1. **One-paragraph summary** — N practices scored, county breakdown, tier counts (A/B/C/D), how many excluded for distress, headline data-coverage caveat.
2. **Top 15 targets table** — name, city, county, owner (age + how known), years in biz, L1/L2/L3/L4, final, tier, one-line why.
3. **The `A_acquire_self` list** — every Tier-A practice with its full `final_comment` and `value_add_thesis`.
4. **What real data I got vs. what was blocked** — per source: worked / partial / blocked-with-this-error. Be specific (URLs).
5. **Scoring model as run** — the layers, the weights, the gates, the tier thresholds (so the user can retune).
6. **What the productionized skill needs** — the connectors to build (TSBDE bulk CSV / Socrata, Comptroller, HCAD/DCAD/TCAD OV65, Wayback, Google Places, voter/DMV ingestion), the manual-verification checklist (exact column headers per source), refresh cadence, and where the scoring weights should live.
7. **Honest limitations** — sample size, proxy-heavy owner ages, anything you'd want a human to double-check before acting on a lead.

---

## 8. Workflow

1. **Orient** — `cd /home/user/dealhound-pro`; skim `SBA_PRODUCT_SPEC.md` + `docs/SBA_BUILD_DECISIONS.md` (background only); confirm `offmarket/` and `offmarket/data/` exist.
2. **Open the run** — load Supabase MCP tools; insert the `score_runs` row; keep `score_run_id`.
3. **Build the spine** — get a real list of TX dental practices (TSBDE / data.texas.gov / Google), prioritizing Harris/Dallas/Travis. Dedupe. Cap your *fully-enriched* set at ~60–150; you can keep a thin longer list but enrich the priority counties first.
4. **Enrich** — for each priority practice, delegate sonnet sub-agents (batch them — e.g. one sub-agent enriches 5–10 practices) to gather: entity/owner data, owner-age signal, website/Wayback/WHOIS/social staleness, review velocity, hiring, building ownership, distress checks. Persist incrementally — write to `offmarket/data/dental_targets.json` as you go and (optionally) upsert to Supabase in batches, so a crash doesn't lose everything.
5. **Score** — you (Opus) compute the 4 layers + final + tier + comments for each practice from the enriched record. Don't delegate the scoring judgment.
6. **Persist** — upsert all `businesses`, `business_signals`, `business_scores` to Supabase; update `score_runs.business_count`; write the final `dental_targets.json`, `dental_targets.csv`, `run_manifest.json`.
7. **Verify** (see §9) and write `offmarket/REPORT.md`.
8. **Stop** — print a final summary: counts, tier breakdown, where the files are, whether the DB write succeeded, top 5 Tier-A names. Do **not** commit or push.

Token discipline: Opus plans/scores/synthesizes; sonnet does fetches/scrapes/file-writes/DB-writes. If a sub-agent stalls (blocked source, 3+ retries), kill it and route around. Don't grind a blocked source — note it and move on.

---

## 9. Verification (do this before declaring done)

1. `offmarket/data/dental_targets.json` exists, parses, has ≥ 60 real practices, each with: identity fields, ≥1 owner-age signal (even if proxy), ≥3 signals total (unless distressed), all four layer scores in 0–100, all four layer comments non-empty, a final score consistent with the weights, a tier consistent with the thresholds/gates, a `final_comment` and `value_add_thesis`.
2. `dental_targets.csv` opens and row count matches the JSON.
3. At least one practice in each of Tier A, B, and C (proves the model spreads). If everything clusters in one tier, re-examine the model inputs — don't fudge scores to hit the spread, but do sanity-check you're not flat-lining a layer.
4. Spot-check 5 random practices: every `evidence` string is traceable to a real source you actually hit (and a `source_url` where one exists). If you can't trace it, fix or remove the row.
5. No fabricated businesses. No distressed businesses scored above `D_pass`. No business <5 yrs scored above ~35.
6. Supabase: `select count(*) from offmarket.businesses` ≈ JSON count; `select final_tier, count(*) from offmarket.scored_targets group by 1` looks sane. (Or, if MCP unavailable, `run_manifest.json` + `REPORT.md` both clearly say the DB write was skipped and why.)
7. `run_manifest.json` lists every source as worked / partial / blocked-with-error.

If you hit your turn budget before finishing: stop, write whatever you have to the local files, write `REPORT.md` with a `[PARTIAL]` header explaining exactly where you stopped and what's left, and exit clean. A smaller honest result beats a padded one.
