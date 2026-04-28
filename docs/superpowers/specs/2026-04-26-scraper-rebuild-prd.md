# DealHound Pro — Scraper Rebuild PRD

**Product:** DealHound Pro
**Version:** MVP v2 (Scraper Rebuild)
**Date:** 2026-04-26 (updated 2026-04-27)
**Status:** Draft → **SUPERSEDED by Mac Scraper Pivot**

> **Architecture pivot (2026-04-27):** The Railway+ScraperAPI approach from the original
> plan has been replaced. After a day of debugging Docker SSL certs, proxy IP blocking,
> ScraperAPI credit exhaustion, and networkidle timeouts — all to produce a degraded
> clone of the existing /find-deals skill — we're pivoting to run the skill directly
> from the Mac via Sophie's cron scheduler. See `plans/2026-04-27-mac-scraper-pivot.md`.
>
> **What changed:** Epic 1 (scraping) is now handled by the /find-deals skill on the Mac,
> not a Railway container. Epics 2-4 (filtering, dedup, scoring) are also handled by the
> skill. Epic 5 (reliability) is solved by the job queue architecture. Epic 6 (daily scan)
> is solved by Sophie's cron. The PRD outcomes remain the same — the implementation changed.

---

## Problem Statement

DealHound's scan pipeline finds fewer deals and lower-quality results than running the /find-deals skill manually. Three of four marketplace sites are blocked by bot detection. Listings with missing data (null acreage, null price) are silently dropped. The same property listed on multiple sites is scored three times. Mitigations are generic rather than deal-specific. Users get a worse experience from the product than the founder gets running a CLI skill.

## Desired Outcome

A user triggers a scan, waits 5-10 minutes, and receives a ranked list of investment-grade property deals — sourced from 4+ marketplaces plus web discovery — with specific, actionable risk analysis for each. The quality matches what the /find-deals skill produces locally. The system runs reliably, handles missing data gracefully, and scales to 100 users at $5/user without architecture changes.

## What MVP Is NOT

- Not per-user agents running in containers (Phase 3)
- Not a mobile app
- Not real-time deal alerts or push notifications
- Not off-market deal sourcing or broker integrations
- Not document analysis (OMs, T12s)
- Not price range probing on discovered sites (post-MVP optimization)
- Not support for international markets

---

## Epic 1: Universal Scraper — Claude Reads Pages Instead of CSS Selectors

### User Story
As an investor using DealHound, I want the scan to find listings from BizBuySell, LandWatch, Crexi, and LandSearch (plus any newly discovered sites), so that I'm not missing deals just because a website changed its layout or blocks automated scrapers.

### Why This Matters
Today, 3 of 4 sites return zero results. Users see a scan that claims to search the market but actually only searches one site. This erodes trust immediately.

### Acceptance Criteria

| # | Criterion | How to verify |
|---|-----------|---------------|
| 1.1 | Scan returns listings from all 4 marketplace sites: BizBuySell, LandWatch, Crexi, LandSearch | Trigger a scan with buy box "Texas, micro resorts, $300k-$3M". Check `sources_scraped` in Supabase — all 4 present. |
| 1.2 | Each listing has all schema fields present (fields can be null but must exist): title, price, price_raw, location, url, acreage, rooms_keys, revenue_hint, dom_hint, condition_hint, description, property_type, source | Query `raw_listings` table for the scan. For each row, verify no schema keys are missing (null values are OK). |
| 1.3 | Extraction works on a site the system has never seen before (dynamically discovered via web search) | During discovery, if a new broker site is found, verify it appears in `sources_scraped` and returns listings. Alternatively: feed a saved page from a random real estate broker site through the extraction module and verify it returns structured listings. |
| 1.4 | No site returns a 403, Cloudflare challenge page, or Akamai block | Check Railway logs during scan. No "Access Denied", "Cloudflare", or "blocked" errors for any of the 4 sites. |
| 1.5 | Extraction finds >= the same number of listings as the old CSS selector scraper found on LandSearch (the one site that worked) | Run old scraper and new scraper against LandSearch Texas resorts. New scraper listing count >= old scraper count. |

### Definition of Done
- All 4 sites return listings in a production scan
- Claude extraction module has passing unit tests against saved page fixtures
- ScraperAPI proxy is configured and working on Railway
- No per-site CSS selectors are used for extraction (LandSearch native scraper kept as cost optimization only — Claude extraction is the fallback for all sites)

### Depends On
Plan Tasks 1, 2, 3

---

## Epic 2: Conservative Filtering — Never Drop a Deal on Missing Data

### User Story
As an investor, I want to see all potentially matching deals even when listing data is incomplete, so that I don't miss a great opportunity just because the listing didn't show acreage or price.

### Why This Matters
The current system drops any listing with null acreage when `acreage_min` is set. Many listings on BizBuySell and Crexi don't show acreage. Good deals are silently killed before the user ever sees them.

### Acceptance Criteria

| # | Criterion | How to verify |
|---|-----------|---------------|
| 2.1 | A listing with null price passes the price filter and is flagged `price_unknown` | Submit a listing with `price: null` through `applyHardFilters`. Assert: `passed_hard_filters: true`, `flags` includes `"price_unknown"`. |
| 2.2 | A listing with null acreage passes the acreage filter and is flagged `acreage_unknown` | Submit a listing with `acreage: null` through `applyHardFilters`. Assert: `passed_hard_filters: true`, `flags` includes `"acreage_unknown"`. |
| 2.3 | A listing with price explicitly above max is rejected with a clear reason | Submit a listing with `price: 5000000` (max is $3M). Assert: `passed_hard_filters: false`, `miss_reason` mentions price. |
| 2.4 | Exclusion keywords still work (case-insensitive match on title + description) | Submit a listing with title "Mobile Home Park". Assert: `passed_hard_filters: false`. |
| 2.5 | Flagged listings appear in the dashboard with a visual indicator showing which data is missing | After a scan completes, open the dashboard. Listings with flags should show a badge or note (e.g., "price unknown", "acreage unknown") so the user knows to investigate. |

### Definition of Done
- `applyHardFilters` unit tests pass for all null-data scenarios
- Zero listings dropped due to missing data in a production scan
- Flags visible in the deal detail view in the dashboard

### Depends On
Plan Task 4

---

## Epic 3: Cross-Source Deduplication — One Deal, One Card

### User Story
As an investor, I want each property to appear once in my results even if it's listed on multiple sites, so that my results aren't cluttered with duplicates and my scoring resources aren't wasted.

### Why This Matters
The same lakefront resort appears on BizBuySell, LandWatch, and a broker site. Without dedup, the user sees three cards for the same property, each scored independently. This wastes Claude API budget and makes the product feel sloppy.

### Acceptance Criteria

| # | Criterion | How to verify |
|---|-----------|---------------|
| 3.1 | Two listings with matching normalized street addresses are merged into one (Tier 1: "123 Lake Dr" = "123 Lake Drive") | Feed two listings with address variations through dedup. Assert: one listing returned with `also_listed_on` populated. |
| 3.2 | Two listings with price within 5%, same city/state, and 2+ matching title words are merged (Tier 2) | Feed two listings: "Lakefront Glamping Resort" at $1.2M and "Glamping Resort Lakefront" at $1.23M, both Austin TX. Assert: one listing returned. |
| 3.3 | Two listings with price within 5% and same city but different titles are both kept but flagged as possible duplicates (Tier 3) | Feed two listings with matching price/city but unrelated titles. Assert: both returned, both have `possible_duplicate: true`. |
| 3.4 | The kept listing (on confirmed dupe) is the one with more non-null fields | Feed one listing with acreage and one without, same address. Assert: the one with acreage is kept. |
| 3.5 | A property listed on 2+ sites gets a `also_listed_on` array with the other source URLs | Verify the merged listing has URLs from the dropped duplicate(s). |

### Definition of Done
- Dedup unit tests pass for all three tiers
- A production scan with overlapping sources shows merged results
- No duplicate properties visible in the dashboard

### Depends On
Plan Task 4

---

## Epic 4: Scoring Quality — Opus Mitigations + False-Negative Protection

### User Story
As an investor, I want risk mitigations that reference my specific deal's data (not generic advice), and I don't want good deals dropped because the AI was uncertain.

### Why This Matters
Current mitigations say things like "do more research." The skill produces mitigations like "Information risk (4): 148 leased acres — verify USACE lease terms." That specificity is what makes users trust the product. And the current scoring drops borderline deals that should be kept for review.

### Acceptance Criteria

| # | Criterion | How to verify |
|---|-----------|---------------|
| 4.1 | Mitigations are generated by Claude Opus (not Sonnet) | Check the API call logs or model field in score.js — `writeMitigations` calls `claude-opus-4-20250514`. |
| 4.2 | Every mitigation references specific data from the listing (price, location, acreage, condition, revenue signals) | After a scan, read mitigations for 5 deals with risk factors >= 3. Each mitigation must reference at least one specific data point from the listing. No mitigation should be fully generic (e.g., "do your due diligence"). |
| 4.3 | Mitigations are only generated for risk factors scored 3 or higher | Verify: deals with all risk factors 0-2 have no mitigations. Deals with any factor >= 3 have mitigations only for those factors. |
| 4.4 | The scoring prompt includes false-negative protection language | Read score.js — the Sonnet classification prompt must contain instruction to default to PARTIAL (not MISS) when uncertain. |
| 4.5 | A borderline deal that could be PARTIAL or MISS is scored PARTIAL | This is hard to test deterministically. Compare scoring output for the same 10 listings between old prompt and new prompt. The new prompt should produce equal or fewer MISS classifications. |
| 4.6 | Sonnet classification batch size is 25 (not 10) | Read score.js — batch loop processes 25 deals per API call. |

### Definition of Done
- Opus model used for mitigations in production
- Mitigations quality matches /find-deals skill output (spot-check 5 deals)
- No regressions in existing scoring tests

### Depends On
Plan Task 5

---

## Epic 5: Pipeline Reliability — No Timeouts, Graceful Failures

### User Story
As an investor, I want my scan to complete reliably even when it takes 10+ minutes, and I want to see clear progress updates — not a hung spinner or cryptic error.

### Why This Matters
Vercel serverless functions timeout at 300 seconds. A full scan with Claude extraction across 4+ sites can take 10-15 minutes. The current architecture tries to do everything in one function call — it will timeout. Users see a broken scan with no explanation.

### Acceptance Criteria

| # | Criterion | How to verify |
|---|-----------|---------------|
| 5.1 | A full scan across 4+ sites completes without any Vercel function timeout | Trigger a production scan. Monitor Vercel function logs — no 504 or timeout errors. Scan completes with "done" status in Supabase. |
| 5.2 | Progress feed updates in real-time as each site is scraped | Watch the dashboard during a scan. Progress table should show per-site updates: "Scraping BizBuySell... 23 listings found", "Scraping LandWatch... 45 listings found", etc. |
| 5.3 | If the Railway scraper is offline, the user sees "Scraper service unavailable" — not a hung spinner | Stop the Railway service. Trigger a scan. Verify the progress feed shows an error message within 30 seconds. |
| 5.4 | If ScraperAPI is down or the key is invalid, the scan fails gracefully with a clear error | Use an invalid ScraperAPI key. Trigger a scan. Verify error message in progress feed. |
| 5.5 | The webhook callback is idempotent — if it fires twice, results are not duplicated | Manually POST to `/api/scan-continue` twice with the same `search_id`. Verify deals are not inserted twice in Supabase. |
| 5.6 | Discovery phase returns discovered sites to the scraper (sites are not discarded) | After a scan, check that dynamically discovered sites (from web search) were passed to the scraper and scraped. |

### Definition of Done
- End-to-end scan completes in production (Railway + Vercel + Supabase)
- Progress feed shows per-site updates during scraping
- Failure modes tested: scraper offline, bad proxy key, empty results
- No Vercel timeouts in production logs

### Depends On
Plan Tasks 6, 7, 8

---

## Epic 6: Daily Shared Scan — Deals Arrive Without Asking

### User Story
As an investor, I want to open my dashboard and see new deals that my agent found overnight, without having to trigger a scan manually every day.

### Why This Matters
This is the single biggest step toward the product feeling agentic. The user wakes up, opens the app, and something has been working for them. Today, nothing happens unless they click "scan."

### Acceptance Criteria

| # | Criterion | How to verify |
|---|-----------|---------------|
| 6.1 | A daily cron runs at 6am UTC and scrapes all active user locations | Check Vercel cron logs. The `/api/cron/daily-scan` endpoint fires daily. Supabase shows a new `deal_searches` record with `user_email: 'system@dealhound.pro'` and a merged buy box of all user locations. |
| 6.2 | Locations are deduplicated across users — if 30 users want Texas, Texas is scraped once | Check the merged buy box in the system search record. Each location appears exactly once regardless of how many users specified it. |
| 6.3 | Users see deals from the shared daily scan that match their buy box | User A (Texas, micro resorts, $300k-$2M) and User B (Texas, boutique hotels, $500k-$3M) both see Texas deals from the same scan, filtered by their respective criteria. |
| 6.4 | Shared scan results appear in the user's dashboard alongside their on-demand scan results | Open dashboard. See a section or tab for "Daily Scan" results in addition to any manual scan results. |
| 6.5 | A user who signed up after the daily scan ran can still see results from today's shared pool | New user creates buy box for Texas. Their dashboard shows deals from today's shared scan without triggering a new scrape. |
| 6.6 | The daily scan costs scale with locations, not with users — 100 users with the same 3 locations costs the same as 10 users with those locations | Verify: only one scrape runs per unique location set. Claude API cost is for scoring the shared pool once, not per user. |

### Definition of Done
- Cron endpoint deployed and firing daily
- Users see shared scan results in their dashboard
- Cost verification: daily scan for 3 locations costs the same regardless of user count

### Depends On
Plan Tasks 9, 10

---

## Non-Functional Requirements

### Reliability
- Scan completion rate >= 95% (measured over 30 days of daily scans)
- Graceful degradation: if one site is blocked or down, other sites still return results
- Webhook callback retry: if Vercel is cold-starting and the first callback fails, Railway retries once

### Performance
- Full scan (4 sites, 1 state) completes in under 15 minutes
- Dashboard loads results in under 3 seconds after scan completes
- Progress feed updates within 5 seconds of each site completing

### Cost
- Total infrastructure cost at 100 users: < $500/month ($5/user)
- Breakdown: ScraperAPI ~$100, Railway ~$20, Claude API ~$250, Supabase $25
- Cost scales with locations scraped, not with user count

### Scalability
- Architecture supports 1,000 users without structural changes (increase ScraperAPI plan + Railway compute)
- Claude extraction code is portable to Agent SDK containers (Phase 3 — no rewrite needed)
- Shared pool model means adding a user doesn't add a scrape

### Security
- ScraperAPI key stored in Railway env vars, never in code or logs
- Anthropic API key stored in Railway + Vercel env vars, never in code or logs
- Webhook callback authenticated with shared secret
- Supabase service key used server-side only, never exposed to frontend

---

## Success Metrics

| Metric | Target | How to measure |
|--------|--------|----------------|
| Sites returning listings | 4/4 (100%) | Check `sources_scraped` per scan |
| Listings found per scan | >= 50 (across all sites for Texas) | Count rows in `raw_listings` per scan |
| Scoring false-negative rate | < 5% (deals incorrectly dropped as MISS) | Compare 20 MISS-scored deals against manual review — fewer than 1 should be a real opportunity |
| Mitigation specificity | 100% reference listing data | Spot-check 10 mitigations — all must cite a specific data point |
| Scan completion rate | >= 95% | Track scan status over 30 days |
| User-reported "found a deal I wouldn't have found" | >= 1 in first 10 users | Ask during onboarding follow-up |

---

## Out of Scope (Explicitly Deferred)

| Item | Why deferred | When to revisit |
|------|-------------|----------------|
| Price range probing on discovered sites | Optimization — not needed for MVP if hardcoded sites return results | After 30 days of daily scans, assess which discovered sites are worth probing |
| Per-user agent containers (Agent SDK) | Phase 3 — requires product-market fit first | After 50 paying users |
| Push notifications / email digest | Valuable but not core — users can check the dashboard | After daily scan is stable for 2 weeks |
| Off-market deals / broker integrations | Different data source entirely | After on-market scraping is reliable |
| Mobile app | Web dashboard works on mobile browsers | After 100 users request it |
| Multi-state optimization (parallel scraping) | Single-threaded scraping works for MVP location count | When daily scan takes > 30 minutes |
