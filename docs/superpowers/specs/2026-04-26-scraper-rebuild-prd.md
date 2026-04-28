# DealHound Pro -- Scraper Rebuild PRD

**Product:** DealHound Pro
**Version:** MVP v2 (Mac Scraper Pivot)
**Date:** 2026-04-26 (architecture pivoted 2026-04-27)
**Status:** Active

---

## Architecture History

**Original approach (2026-04-26):** Railway-hosted Playwright container with ScraperAPI residential proxy. Claude Sonnet extracted listings from page text. Separate Vercel functions handled filtering, scoring, and Supabase writes.

**Why it failed:** After a full day of debugging, the Railway approach produced worse results than the existing /find-deals skill. Three of four sites were blocked (SSL cert errors, IP blocking, proxy timeouts). ScraperAPI credits exhausted mid-run. The entire scraper-service was a degraded clone of a skill that already worked.

**Current approach (2026-04-27):** Run the /find-deals skill directly from Gideon's Mac via Sophie (persistent Node.js agent). No containers, no proxies, no Docker. Real browser on a residential IP. The skill already handles discovery, scraping, filtering, scoring, and Supabase writes.

**Implementation plan:** `plans/2026-04-27-mac-scraper-pivot.md`

---

## Current Architecture

```
User clicks "Scan" in dashboard
        |
        v
Vercel scan-start.js
  - Creates deal_searches row (status: scanning)
  - Writes scrape_jobs row (status: pending)
  - Returns immediately
        |
        v
Sophie (Mac, polling every 60s)
  - Picks up pending job
  - Sets DEALHOUND_SEARCH_ID env var
  - Spawns: claude -p "/find-deals full -- [buy box overrides]"
  - Writes heartbeat progress rows every 5 min
        |
        v
/find-deals skill (Claude Code on Mac)
  - Phase 1: WebSearch discovers marketplace sites
  - Phase 2A: Playwright scraper (LandSearch -- fast, free)
  - Phase 2B: gstack Chrome browser (blocked sites -- BizBuySell, Crexi, LandWatch)
  - Phase 3: Sonnet classifies + rates, Opus writes mitigations, arithmetic scores
  - Writes scored deals to Supabase deals table (linked to DEALHOUND_SEARCH_ID)
        |
        v
Sophie marks job complete
  - Updates scrape_jobs.status = complete
  - Updates deal_searches.status = complete
  - Writes final scan_progress row
        |
        v
Dashboard polls scan_progress, shows results from deals table
```

### Daily Scan (no user trigger needed)

```
Sophie cron (6am CT daily)
  - Invokes /find-deals full with default buy-box.md
  - Skill creates its own deal_searches row (user_email: gideon@...)
  - Scored deals written to Supabase
  - Sophie sends WhatsApp summary to Gideon
```

### Key Integration Points

| Component | Supabase table | Who writes | Who reads |
|-----------|---------------|------------|-----------|
| Scan request | `deal_searches` | Vercel (scan-start.js) | Skill (via DEALHOUND_SEARCH_ID), dashboard |
| Job queue | `scrape_jobs` | Vercel (scan-start.js) | Sophie (polling loop) |
| Progress | `scan_progress` | Sophie (heartbeats), Vercel (init) | Dashboard (scan-progress.js) |
| Raw listings | `raw_listings` | Not used in new arch (skill scores inline) | -- |
| Scored deals | `deals` | Skill (apply-buybox.md) | Dashboard (user-data.js) |

### search_id Bridging

The dashboard creates a `deal_searches` row with the user's email and buy box. The skill normally creates its own search record in Step 0 of `apply-buybox.md`. For on-demand scans, Sophie passes `DEALHOUND_SEARCH_ID` as an env var to the `claude` CLI. The skill checks for this env var and skips the INSERT, using the existing search_id instead. This links the skill's scored deals to the dashboard's search record deterministically.

### What Runs Where

| System | Runs on | Purpose |
|--------|---------|---------|
| Dashboard + API | Vercel | User-facing app, scan triggers, progress polling |
| Sophie | Mac (persistent Node.js) | Cron scheduling, job queue polling, skill invocation |
| /find-deals skill | Mac (Claude Code CLI) | Discovery, scraping, filtering, scoring, Supabase writes |
| Supabase | Cloud (hosted) | Persistence for all scan data |

### What Was Removed

| Component | Replaced by |
|-----------|-------------|
| `scraper-service/` (Railway) | /find-deals skill on Mac |
| ScraperAPI proxy | Mac residential IP + real browser |
| `api/_lib/scrape.js` | Sophie job queue |
| `api/scan-continue.js` (webhook) | Sophie polling loop |
| `api/scan-pipeline.js` | Sophie + skill |
| `api/_lib/process-listings.js` | Skill's apply-buybox.md |
| `api/_lib/discover.js` | Skill's Phase 1 |
| `api/_lib/score.js` | Skill's Phase 3 |
| `api/_lib/filters.js` | Skill's hard filters |

---

## Problem Statement

DealHound's scan pipeline finds fewer deals and lower-quality results than running the /find-deals skill manually. Three of four marketplace sites are blocked by bot detection. Listings with missing data (null acreage, null price) are silently dropped. The same property listed on multiple sites is scored three times. Mitigations are generic rather than deal-specific. Users get a worse experience from the product than the founder gets running a CLI skill.

## Desired Outcome

A user triggers a scan, waits 30-60 minutes, and receives a ranked list of investment-grade property deals -- sourced from 4+ marketplaces plus web discovery -- with specific, actionable risk analysis for each. The quality matches what the /find-deals skill produces locally, because it IS the /find-deals skill. The system runs reliably, handles missing data gracefully, and scales to 100 users at $5/user without architecture changes.

## What MVP Is NOT

- Not per-user agents running in containers (Phase 3)
- Not a mobile app
- Not real-time deal alerts or push notifications
- Not off-market deal sourcing or broker integrations
- Not document analysis (OMs, T12s)
- Not price range probing on discovered sites (post-MVP optimization)
- Not support for international markets
- Not shared pool fan-out to multiple users (deferred -- daily scan is Gideon-only initially)

---

## Epic 1: Universal Scraper -- Skill Runs All Sites

### User Story
As an investor using DealHound, I want the scan to find listings from BizBuySell, LandWatch, Crexi, and LandSearch (plus any newly discovered sites), so that I'm not missing deals just because a website changed its layout or blocks automated scrapers.

### How It Works Now
The /find-deals skill handles this end-to-end:
- Phase 2A: Playwright scraper for LandSearch (fast, free, ~239 TX listings)
- Phase 2B: gstack Chrome browser for blocked sites (BizBuySell, Crexi, LandWatch)
- Phase 1 discovers new sites via WebSearch and adds them to the scrape queue

No proxies, no Docker, no Railway. Real browser on a residential IP.

### Acceptance Criteria

| # | Criterion | How to verify |
|---|-----------|---------------|
| 1.1 | Scan returns listings from all 4 marketplace sites: BizBuySell, LandWatch, Crexi, LandSearch | Run `/find-deals full`. Check `deals` table in Supabase -- listings from all 4 sources present. |
| 1.2 | Each listing has all schema fields present (fields can be null but must exist) | Query `deals` table for the scan. Verify schema fields exist on each row. |
| 1.3 | Extraction works on dynamically discovered sites (from web search) | Check `discovered-sites.json` after a run. New sites should appear and be scraped. |
| 1.4 | No site returns a 403 or bot block that kills the entire scan | Check skill output. Individual site failures are logged and skipped, other sites still return results. |
| 1.5 | Listing count matches or exceeds previous skill runs | Compare deal count against prior `scored-deals-*.json` files in `~/incredibleai-pro/deal-hound/data/`. |

### Definition of Done
- All 4 sites return listings in a production scan triggered from the dashboard
- Sophie successfully invokes the skill and deals appear in Supabase linked to the correct search_id
- Skill output quality matches running `/find-deals` manually

### Depends On
Plan Tasks 1-5, 7

---

## Epic 2: Conservative Filtering -- Never Drop a Deal on Missing Data

### User Story
As an investor, I want to see all potentially matching deals even when listing data is incomplete, so that I don't miss a great opportunity just because the listing didn't show acreage or price.

### How It Works Now
The skill's `apply-buybox.md` Step 1 already implements this:
- Null price = pass with flag (not dropped)
- Null acreage = pass with flag (not dropped)
- Only explicit violations (price > max, matches exclusion keyword) cause drops

### Acceptance Criteria

| # | Criterion | How to verify |
|---|-----------|---------------|
| 2.1 | A listing with null price is scored and appears in results | After a scan, check `deals` table for rows with `price IS NULL`. They should exist with scores. |
| 2.2 | A listing with null acreage is scored and appears in results | After a scan, check `deals` table for rows with `acreage IS NULL`. They should exist with scores. |
| 2.3 | A listing with price above max is rejected | Check for deals with miss_reason mentioning price. |
| 2.4 | Exclusion keywords still work | Listings with "mobile home" in title should not appear as scored deals. |

### Definition of Done
- Zero listings dropped due to missing data in a production scan
- Verified by comparing deal count to raw listing count

### Depends On
Already implemented in skill. Verified during E2E test (Task 8).

---

## Epic 3: Cross-Source Deduplication -- One Deal, One Card

### User Story
As an investor, I want each property to appear once in my results even if it's listed on multiple sites, so that my results aren't cluttered with duplicates and my scoring resources aren't wasted.

### How It Works Now
The skill's `apply-buybox.md` includes dedup logic:
- Tier 1: Normalized address match (definitive dupe)
- Tier 2: Price within 5% + same city + 2+ shared title words (probable dupe)
- Tier 3: Price within 5% + same city only (flagged, both kept)

### Acceptance Criteria

| # | Criterion | How to verify |
|---|-----------|---------------|
| 3.1 | Cross-source duplicates are merged | Check `deals` table for `also_listed_on` values. Merged deals should show other source URLs. |
| 3.2 | The kept listing is the one with more data | For merged deals, verify the kept row has more non-null fields. |
| 3.3 | Possible duplicates are flagged but both kept | Check for deals with `possible_duplicate = true`. |

### Definition of Done
- A scan with overlapping sources shows merged results
- No obvious duplicate properties in the dashboard

### Depends On
Already implemented in skill. Verified during E2E test (Task 8).

---

## Epic 4: Scoring Quality -- Opus Mitigations + False-Negative Protection

### User Story
As an investor, I want risk mitigations that reference my specific deal's data (not generic advice), and I don't want good deals dropped because the AI was uncertain.

### How It Works Now
The skill's `apply-buybox.md` + `scoring-rubric.md`:
- Sonnet classifies and rates all survivors (batch size 25)
- False-negative rule: uncertain between PARTIAL and MISS = always PARTIAL
- Opus writes mitigations only for risk factors rated 3+ (specific, data-driven)
- Priority score (0-100) = type alignment (30) + revenue readiness (25) + market fit (25) + risk offset (20)

### Acceptance Criteria

| # | Criterion | How to verify |
|---|-----------|---------------|
| 4.1 | Mitigations reference specific listing data | Spot-check 5 deals with risk >= 3. Each mitigation cites price, location, acreage, or condition data. |
| 4.2 | Borderline deals are scored PARTIAL, not MISS | Compare MISS count to prior runs. Should be equal or fewer. |
| 4.3 | Priority scores use the correct arithmetic | Check `score_breakdown` in Supabase. Verify weights match rubric. |

### Definition of Done
- Mitigations quality matches running `/find-deals` manually (spot-check 5 deals)
- No regressions from prior skill runs

### Depends On
Already implemented in skill. Verified during E2E test (Task 8).

---

## Epic 5: Pipeline Reliability -- Job Queue + Heartbeats

### User Story
As an investor, I want my scan to complete reliably even when it takes 30-60 minutes, and I want to see clear progress updates -- not a hung spinner or cryptic error.

### How It Works Now
- Vercel writes a `scrape_jobs` row and returns immediately (no timeout risk)
- Sophie picks up jobs within 60 seconds
- Heartbeat progress rows are written every 5 minutes during the skill run
- Stale scan detection timeout is 120 minutes (not 5 minutes)
- If Sophie is offline, jobs queue up and get picked up when she restarts
- If the skill fails, Sophie writes an error to `scan_progress` and `deal_searches`

### Acceptance Criteria

| # | Criterion | How to verify |
|---|-----------|---------------|
| 5.1 | A full scan completes without any Vercel function timeout | Trigger a scan from the dashboard. No 504 errors in Vercel logs. |
| 5.2 | Progress feed shows updates during the 30-60 min scan | Watch the dashboard during a scan. Heartbeat messages appear every 5 min. |
| 5.3 | If Sophie is offline, the user sees "Waiting for deal scanner..." not an error | Kill Sophie. Trigger a scan. Dashboard shows queued status. Restart Sophie -- job gets picked up. |
| 5.4 | If the skill fails, the user sees a clear error message | Force a skill failure (e.g., invalid API key). Dashboard shows error in progress feed. |
| 5.5 | Jobs are idempotent -- picking up the same job twice doesn't duplicate deals | Verify optimistic locking on job claim (`.eq('status', 'pending')`). |

### Definition of Done
- End-to-end scan completes from dashboard trigger to scored deals appearing
- Progress feed shows heartbeat updates during the scan
- Failure modes tested: Sophie offline, skill error, stale detection

### Depends On
Plan Tasks 1, 4, 5, 7.5

---

## Epic 6: Daily Scan -- Deals Arrive Without Asking

### User Story
As an investor, I want to open my dashboard and see new deals that my agent found overnight, without having to trigger a scan manually every day.

### How It Works Now
Sophie's cron fires at 6am CT daily and invokes `/find-deals full` with the default buy box. The skill creates its own `deal_searches` row and writes scored deals to Supabase.

**Current limitation:** Daily scan results use `user_email: "gideon@incrediblehospitalityco.com"`. Other users don't see these results unless we add a shared pool query path to the dashboard. This is deferred until there are paying users.

### Acceptance Criteria (MVP -- Gideon only)

| # | Criterion | How to verify |
|---|-----------|---------------|
| 6.1 | Sophie's daily cron fires at 6am CT and invokes the skill | Check Sophie logs. Supabase shows a new `deal_searches` row each morning. |
| 6.2 | Scored deals from the daily scan appear in Gideon's dashboard | Open dashboard, verify new deals from today's scan are visible. |
| 6.3 | Sophie sends a WhatsApp summary after the daily scan completes | Check WhatsApp for a deal scan summary message. |

### Deferred (post-MVP, when paying users exist)

| # | Criterion | When |
|---|-----------|------|
| 6.4 | Other users see deals from the shared daily scan matching their buy box | After 5+ paying users |
| 6.5 | Locations are deduplicated across users (one scrape per unique location set) | After 5+ paying users |
| 6.6 | Cost scales with locations, not users | After 5+ paying users |

### Definition of Done (MVP)
- Daily cron fires and produces scored deals in Supabase
- Gideon sees daily scan results in dashboard
- WhatsApp summary delivered

### Depends On
Plan Tasks 2, 4

---

## Non-Functional Requirements

### Reliability
- Scan completion rate >= 95% (measured over 30 days of daily scans)
- Graceful degradation: if one site is blocked or down, other sites still return results
- Job queue: if Sophie is offline, jobs queue up and execute when she restarts

### Performance
- Full scan (4 sites, 1 state) completes in 30-60 minutes (skill runtime)
- Dashboard loads results in under 3 seconds after scan completes
- Heartbeat progress rows appear every 5 minutes during scan

### Cost
- Total infrastructure cost at 100 users: < $300/month
- Breakdown: Claude API ~$250 (Sonnet extraction + classification, Opus mitigations), Supabase $25, Vercel free tier
- No ScraperAPI cost. No Railway cost. Mac runs on existing hardware.
- Cost scales with locations scraped and deals scored, not with user count

### Scalability
- Architecture supports ~50 users without structural changes (Mac single-threaded, one scan at a time)
- Beyond 50 users: migrate skill to Agent SDK containers (Phase 3) or add parallel Mac instances
- Shared pool model (deferred) means adding a user doesn't add a scrape

### Security
- Anthropic API key in `~/.zshrc` on Mac, never in code or logs
- Supabase keys in `~/.zshrc` on Mac and Vercel env vars, never in code or logs
- Sophie's Express server is localhost-only (Twilio webhook via ngrok/tunnel)
- Mac must be powered on for scans to run (acknowledged tradeoff vs cloud)

---

## Success Metrics

| Metric | Target | How to measure |
|--------|--------|----------------|
| Sites returning listings | 4/4 (100%) | Check `deals` table per scan -- all 4 sources present |
| Listings found per scan | >= 50 (across all sites for Texas) | Count rows in `deals` per scan |
| Scoring false-negative rate | < 5% (deals incorrectly dropped as MISS) | Compare 20 MISS-scored deals against manual review |
| Mitigation specificity | 100% reference listing data | Spot-check 10 mitigations -- all must cite a specific data point |
| Scan completion rate | >= 95% | Track scan status over 30 days |
| Quality parity with skill | Deal output matches `/find-deals` manual run | Side-by-side comparison of 10 deals |
| User-reported "found a deal I wouldn't have found" | >= 1 in first 10 users | Ask during onboarding follow-up |

---

## Out of Scope (Explicitly Deferred)

| Item | Why deferred | When to revisit |
|------|-------------|----------------|
| Shared pool fan-out to multiple users | Need paying users first | After 5 paying users |
| Price range probing on discovered sites | Optimization, not needed for MVP | After 30 days of daily scans |
| Per-user agent containers (Agent SDK) | Phase 3, needs PMF first | After 50 paying users |
| Push notifications / email digest | Valuable but not core | After daily scan stable for 2 weeks |
| Off-market deals / broker integrations | Different data source | After on-market scraping is reliable |
| Mobile app | Web dashboard works on mobile browsers | After 100 users request it |
| Multi-state parallel scraping | Single-threaded works for MVP | When daily scan takes > 60 minutes |
| 24/7 availability (Mac must be on) | Acceptable for MVP scale | When paying users need guaranteed uptime |
