# find-deals v2 — Deep Discovery + Universal Extractor

**Status:** Draft, awaiting Gideon approval
**Date:** 2026-05-09
**Owner:** Gideon (product) / Autonomous agent (build)
**Skill location:** `~/skills/find-deals/`
**Branch convention:** `feat/find-deals-v2-discovery`

---

## 1. Goal

Make Deal Hound's source coverage broad enough that paid users see deals they could not have found on their own. Today the skill reliably pulls listings from ~4 sites (LandSearch, Campground Connection, NAI OHB, a couple of WebFetch sources). Target state: **50+ verified sources per buy box on first run**, with the long tail of small broker websites included. Source list grows by appending URLs, not by writing new scrapers.

**The promise to the user:** "We searched 50+ sites you've never heard of and ranked the deals against your strategy."

## 2. Non-Goals

Explicitly out of scope for this spec:

- **Email alerts ingestion.** Tracked separately. Don't bundle.
- **Local model (Ollama) execution.** Optimization for later, only if measured token cost becomes a bottleneck.
- **Site-specific Python scrapers.** When a site shows up repeatedly and the universal extractor is slow on it, _then_ it earns a dedicated scraper. Not in this round.
- **Cracking BizBuySell / LoopNet / LandWatch (Akamai).** Already established as uncrackable via free options. Skip and move on.
- **Apify wiring.** Sat through a day of evaluation; no good actors for the sites that matter. Not in this round.
- **The scoring/ranking pipeline (Phase 3).** This spec only touches discovery + extraction. The existing `apply-buybox.md` and `scorer.py` stay as-is.

## 3. Current State (Reality Check)

**Working:**

- `discover-sites.md` — runs 6–10 WebSearch queries, classifies into Bucket A (sites) and Bucket B (individual listings), price-range probes via Playwright MCP. Output: `discovered-sites.json`.
- `scrape-site.md` Phase 2A — Python scrapers for `landsearch` (✅ 239 TX listings) and `campground-connection` (✅ ~72).
- `scrape-site.md` Phase 2B — ad-hoc Playwright MCP agentic flow for everything else.
- Sophie / worker pipeline that invokes `claude -p "/find-deals full"` with a `DEALHOUND_SEARCH_ID` env var.

**Broken / Underpowered:**

- **Discovery is shallow.** 6–10 queries → ~10–15 candidate sites → ~4–5 actually verified. Not enough fan-out for the long tail.
- **Universal extraction is informal.** Phase 2B is freeform instructions to Claude on how to drive Playwright MCP. Each invocation re-derives extraction logic from scratch. No reusable pattern-detection. No confidence scoring. No structured fallback when extraction returns garbage.
- **No rank-position telemetry.** When a source produces a HOT deal, we have no way to know _where in discovery_ that source was found (rank #3? rank #47?). Without that data we can't tell where the value tail dies off.
- **Source registry doesn't track value.** `discovered-sites.json` records `signal_quality` but not "this site has produced 3 STRONG deals across 5 scrapes" — so we can't promote/demote sources based on actual yield.
- **Discovery is hardcoded-hospitality-flavored.** `discover-sites.md` Step 2 query patterns are generic enough, but the existing site registry skews to hospitality. Buy boxes for multifamily, retail, industrial, mobile home parks, marinas, etc., produce thinner results.

## 4. Locked Decisions

| #      | Decision                                                                                                                                                                      | Rationale                                                                                                                                 |
| ------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| **D1** | **DOM-based extraction**, not vision-based                                                                                                                                    | Cheaper and faster. Acceptable failure mode is "skip site," not "extract wrong data."                                                     |
| **D2** | **Universal extractor for all sites in v2.** Site-specific scrapers come later, only for sources that show up repeatedly _and_ the universal extractor is slow/unreliable on. | Avoid the 50-scrapers maintenance treadmill. Source list = config, not codebase.                                                          |
| **D3** | **50 sources target on first run** for any buy box, regardless of vertical                                                                                                    | Forcing function. Below 50, we have not earned the "deals you couldn't find" promise.                                                     |
| **D4** | **Rank-position telemetry on every discovered source.** Track which query found it and at what result position. Track yield (deals scored ≥ MATCH) per source over time.      | Lets us measure where the value tail dies. Lets us prune dead sources after N empty scrapes.                                              |
| **D5** | **No must-have site list from Gideon.** All 50 generated dynamically from buy box.                                                                                            | Buy boxes are diverse (hospitality, multifamily, retail, industrial). A hardcoded list breaks the moment a non-hospitality user signs up. |
| **D6** | **Email alerts stays separate.** This spec ships zero email infrastructure.                                                                                                   | Bounded scope. Email alerts is its own sprint per memory note.                                                                            |
| **D7** | **Universal extractor lives inside the existing find-deals skill.** Do not reinvent the skill — extend `discover-sites.md` and `scrape-site.md` Phase 2B.                     | Per memory: "find-deals skill IS the product core. Don't reinvent it worse."                                                              |

**Resolved questions (Gideon, 2026-05-09):**

- **R1:** Chrome extension at `$HOME/.dealhound-chrome-profile` is **not actively bypassing anti-bot** — it's a warm cookie jar (persistent profile accumulates trust signals across runs). Codebase reference if needed: `/Users/gideonspencer/incredible-ai-extension`. The universal extractor uses the persistent profile as today; no special integration required.
- **R2:** Per-source listing cap = **200**. Configurable per source if a high-yield site warrants more in a later round.
- **R3:** Non-hospitality test buy box = **industrial** (Phase 1.7 acceptance). Agent should construct a reasonable industrial buy box (warehouses, light manufacturing, flex space, distribution centers) at typical Deal Hound price band ($300k–$3M) and use it for the multi-vertical test gate.

## 5. Architecture

### 5.1 Two-layer change

```
┌─────────────────────────────────────────────────────────────┐
│  LAYER 1: DEEP DISCOVERY                                     │
│  Input:  buy_box                                             │
│  Output: 50+ verified sources in discovered-sites.json       │
│          with rank-position metadata                         │
│                                                              │
│  Replaces: discover-sites.md Step 2 (query generation)       │
│            and Step 4 (verification)                         │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│  LAYER 2: UNIVERSAL EXTRACTOR                                │
│  Input:  url, page_type, listing_schema, buy_box             │
│  Output: raw-listings-[slug].json conforming to existing     │
│          schema in scrape-site.md                            │
│                                                              │
│  Replaces: scrape-site.md Phase 2B (formalizes the ad-hoc    │
│            agentic flow into a structured, reusable          │
│            extraction routine)                               │
└─────────────────────────────────────────────────────────────┘
```

Phase 2A (Python scrapers for landsearch + campground-connection) stays. Phase 3 (scoring) stays. Sophie/worker stays.

### 5.2 Layer 1 — Deep Discovery

**Algorithm:**

1. **Parse buy box** — extract:
   - Property type tokens (e.g., "micro resort", "glamping", "boutique hotel" — or "multifamily", "self-storage", "auto repair")
   - Strategy tokens (from `strategy_notes`)
   - Geography tokens (states, metros, regions)
   - Price band ($min–$max)

2. **Build query matrix.** For each `(type_token × geo_token × marketplace_pattern)` triple, compose one query. Marketplace patterns:
   - `"[type]" for sale [geo] broker`
   - `"[type]" listings [geo] marketplace`
   - `best site to buy [type] [geo]`
   - `[type] for sale by owner [geo]`
   - `[type] auction [geo]`
   - `[type] specialist broker [geo]`
   - `niche [type] listings [geo]`
   - `boutique [type] for sale [geo]` _(when applicable)_

   Query budget: **40–80 queries per discovery run** (vs. today's 6–10). De-duplicated. Issue concurrently in batches of 5–10 to keep latency reasonable.

3. **Collect results with rank metadata.** For every URL returned, store:

   ```json
   {
     "url": "...",
     "found_via_query": "glamping for sale Hill Country broker",
     "rank_in_results": 12,
     "search_engine": "WebSearch"
   }
   ```

4. **Domain-deduplicate + classify.** Group URLs by domain. Each domain gets classified Bucket A (multi-listing site, 2+ listings detected) or Bucket B (single listing). Existing classifier logic in `discover-sites.md` Step 3 keeps working; just feed it a much bigger input set.

5. **Verify top N Bucket A sites.** Price-range probe via Playwright MCP. Cap verification at top **60 candidate domains** (slight overshoot to land 50 verified after some fail).

6. **Persist to `discovered-sites.json`.** Each site row gains:

   ```json
   {
     "name": "Some Niche Broker",
     "url": "...",
     "discovery_metadata": {
       "found_via_query": "...",
       "rank_in_results": 34,
       "discovered_at": "2026-05-09",
       "buy_box_hash": "abc123..."
     },
     "performance_metadata": {
       "scrapes": 0,
       "listings_returned_total": 0,
       "deals_scored_match_or_better": 0,
       "deals_scored_strong_or_hot": 0,
       "last_scrape_at": null,
       "last_scrape_status": null,
       "consecutive_empty_scrapes": 0
     },
     ...existing fields (signal_quality, verified, etc.)
   }
   ```

7. **Print discovery summary** including a histogram of rank-position vs. signal quality so we can eyeball where the long tail lives.

### 5.3 Layer 2 — Universal Extractor

A structured routine the agent calls per site. Lives as a new file: `universal-extract.md` (alongside `scrape-site.md`).

**Function signature (conceptual):**

```
extract_listings(
  url: str,
  page_type: "listing_index" | "individual_listing",
  buy_box: BuyBox,
  cap: int = 200
) -> {
  listings: [...],
  extraction_confidence: 0.0-1.0,
  pages_visited: int,
  blocked: bool,
  notes: str
}
```

**Algorithm (Claude + Playwright MCP):**

1. **Navigate + warm load.**

   ```
   browser_navigate(url)
   browser_wait_for(time=2)
   browser_snapshot()  # accessibility tree
   ```

2. **Detect listing structure.** Walk the snapshot looking for:
   - Repeated sibling DOM patterns (5+ siblings with same role/class structure)
   - Anchor-tag clusters where `href` paths share a common prefix (e.g., `/listing/`, `/property/`, `/p/`)
   - Price-pattern density (`$X`, `$X,XXX`, `$X.XM`) within tight DOM neighborhoods
   - Listing-card class names (heuristic: contains `listing`, `card`, `property`, `result`, `tile`)

   If 0 candidate clusters → fall back to `browser_evaluate` with a generic listing-extractor JS function (CSS selector heuristics + microdata/JSON-LD detection).

   If still 0 → mark `extraction_confidence: 0.0`, return empty listings, set `notes: "no listing pattern detected"`. Do not error.

3. **Apply site filters when discoverable.** From the snapshot, find filter inputs (price min/max, type, location). If found and the buy box has the corresponding constraint, apply via `browser_select_option` / `browser_type` / `browser_fill_form`. Wait + re-snapshot. (Existing logic in `scrape-site.md` Phase 2B Step 2 — formalize into the routine.)

4. **Extract per cluster.** For each candidate listing cluster, extract the existing schema (title, price, location, url, address, acreage, rooms_keys, revenue_hint, dom_hint, condition_hint, description, source_url). **Description is required and must not be truncated** — visit the detail page if the index card only shows a snippet (cap detail visits at 30 per site, same as today).

5. **Paginate.** Detect "next page" / "load more" via accessibility tree text. Click via `ref`. Wait + re-snapshot. Repeat until cap reached or no next button.

6. **Score extraction confidence.** Heuristic:
   - 1.0 — every listing has title + price + url + location + non-empty description
   - 0.7 — title + url + (price OR location) on every listing
   - 0.4 — partial extraction; some fields missing on >25% of listings
   - 0.0 — no listings extracted

7. **Save** to `raw-listings-[slug].json` in existing format. Add two new fields:

   ```json
   {
     ...existing...,
     "extraction": {
       "method": "universal_dom",
       "confidence": 0.7,
       "pages_visited": 4,
       "extractor_version": "v2"
     }
   }
   ```

8. **Update `discovered-sites.json`** — increment `performance_metadata.scrapes`, set `last_scrape_at`, set `last_scrape_status`, increment `consecutive_empty_scrapes` if zero listings.

### 5.4 Telemetry — Rank Position vs. Yield

Add `scripts/find-deals-source-yield.py` (read-only analysis):

```
For each source in discovered-sites.json:
  yield_rate = deals_scored_match_or_better / max(scrapes, 1)
  hot_rate   = deals_scored_strong_or_hot / max(scrapes, 1)

Histogram:
  rank 1–10:    avg yield_rate, avg hot_rate
  rank 11–25:   avg yield_rate, avg hot_rate
  rank 26–50:   avg yield_rate, avg hot_rate
  rank 51+:     avg yield_rate, avg hot_rate
```

Print to terminal. This is the data Gideon asked for: _"track what number down the list each was, then we can see how far down the tail is valuable."_ Run it manually after the first 5–10 scans accumulate; cron'd reporting is out of scope.

## 6. Implementation Phases

Each phase is shippable independently. Phase 1 unblocks the 50-source target. Phase 2 ships the structured extractor. Phase 3 wires telemetry.

### Phase 1 — Deep Discovery (target: 50+ sources)

- [ ] **1.1** Refactor `discover-sites.md` Step 2 to generate the query matrix (40–80 queries from buy box × marketplace patterns).
- [ ] **1.2** Add rank-position capture to Step 3 (URL classifier).
- [ ] **1.3** Extend `discovered-sites.json` schema with `discovery_metadata` and `performance_metadata` blocks (with backward-compat shim for existing rows: missing fields default to zero/null).
- [ ] **1.4** Bump verification cap to top 60 candidate domains.
- [ ] **1.5** Update Step 7 summary to print rank-vs-signal histogram.
- [ ] **1.6** **Test gate:** run `/find-deals discover` against the existing hospitality buy box. Acceptance: ≥50 verified Bucket A sites in `discovered-sites.json`, every row has populated `discovery_metadata`.
- [ ] **1.7** **Test gate:** run `/find-deals discover` against a non-hospitality buy box (Gideon to provide one — multifamily or retail). Acceptance: ≥30 verified sources (lower bar — non-hospitality has thinner long tail). Surfaces the multi-vertical robustness of the query matrix.

### Phase 2 — Universal Extractor

- [ ] **2.1** Create `~/skills/find-deals/universal-extract.md` with the full routine in §5.3.
- [ ] **2.2** Update `scrape-site.md` Phase 2B to delegate to `universal-extract.md` (Phase 2B becomes a thin wrapper that loops over HIGH/MEDIUM signal sites and calls the universal extractor).
- [ ] **2.3** Add the `extraction` block to `raw-listings-[slug].json` outputs.
- [ ] **2.4** Add `consecutive_empty_scrapes`-based auto-demote logic: 3 consecutive empty scrapes → downgrade `signal_quality` one tier; 5 consecutive → mark `verified: false`. Captured in `apply-buybox.md` post-run hook or in the extractor itself.
- [ ] **2.5** **Test gate:** run universal extractor against a known-good site (NAI OHB). Acceptance: returns same listings as current Phase 2B flow, with `extraction.confidence ≥ 0.7`.
- [ ] **2.6** **Test gate:** run universal extractor against a randomly-sampled new site from the Phase 1 discovery output that no human has hand-tuned for. Acceptance: returns ≥1 listing OR `blocked: true` OR `extraction.confidence: 0.0` with clean `notes`. (Goal: no crashes, graceful failure.)

### Phase 3 — Telemetry + Loop Closure

- [ ] **3.1** Wire `apply-buybox.md` Step 3 (persist) to update `discovered-sites.json` `performance_metadata` blocks: increment `deals_scored_match_or_better` and `deals_scored_strong_or_hot` per source.
- [ ] **3.2** Build `scripts/find-deals-source-yield.py` per §5.4.
- [ ] **3.3** **Test gate:** run a full `/find-deals full` end-to-end. Acceptance: scored deals land in Supabase, `discovered-sites.json` performance metadata reflects the run, source-yield script produces a non-empty histogram.

## 7. Acceptance Criteria (the "is it done" checklist)

- [ ] `/find-deals discover` returns ≥50 verified Bucket A sources for the default hospitality buy box.
- [ ] `/find-deals discover` returns ≥30 verified Bucket A sources for at least one non-hospitality buy box.
- [ ] `discovered-sites.json` row schema includes `discovery_metadata` (with `found_via_query` and `rank_in_results`) on every new row.
- [ ] `~/skills/find-deals/universal-extract.md` exists and is referenced from `scrape-site.md` Phase 2B.
- [ ] A full `/find-deals full` run succeeds on a buy box where ≥80% of HIGH-signal sites came from the Phase 1 discovery (i.e., not hand-curated).
- [ ] No crashes or unhandled exceptions when the extractor hits a blocked site, a JS-heavy site, or a site with no detectable listing pattern. Graceful degradation only.
- [ ] Source-yield histogram script runs and prints rank-vs-yield breakdown.
- [ ] All existing tests in `~/skills/find-deals/tests/` still pass.
- [ ] No regression in the two known-working Python scrapers (landsearch, campground-connection).

## 8. Risks + Mitigations

| Risk                                                              | Likelihood | Mitigation                                                                                                                                                                                                                                |
| ----------------------------------------------------------------- | ---------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Search engines rate-limit at 40–80 queries/run                    | Medium     | Throttle to 5–10 concurrent; add 1–2s jitter; if WebSearch caps hit, fall back to staggered runs.                                                                                                                                         |
| Universal extractor returns garbage on weird DOM                  | High       | Confidence scoring + graceful fallback. Bad data flagged, not silently merged. The `extraction.confidence` field surfaces this in `raw-listings-*.json`.                                                                                  |
| 50 sources × 200 listings = 10K listings to score → token blowout | Medium     | Existing scoring pipeline already hard-filters before LLM scoring. Phase 1 hard filter (`pipeline.py`) will drop 70–90% before scoring. Re-measure after first full run; if still expensive, add per-source caps to the discovery output. |
| Discovery for non-hospitality verticals returns mostly junk       | Medium     | The 30-source test gate in Phase 1.7 forces us to confront this before declaring done. If it fails, expand the marketplace-pattern list rather than hardcoding category-specific lists.                                                   |
| Anti-bot defenses block too many sites                            | Low–Medium | Acceptable — 50 sources discovered, even if 10 get blocked, leaves 40. Mark blocked sites in registry; revisit them later via different methods (residential proxy, browser extension). Out of scope for this round.                      |

## 9. Agent Execution Notes

The autonomous agent executing this spec should:

1. **Read these files first, in order:**
   - This spec (you're in it)
   - `~/skills/find-deals/SKILL.md`
   - `~/skills/find-deals/discover-sites.md`
   - `~/skills/find-deals/scrape-site.md`
   - `~/skills/find-deals/apply-buybox.md`
   - `~/skills/find-deals/buy-box.md`
   - `~/skills/find-deals/discovered-sites.json` (current state)

2. **Branch:** `feat/find-deals-v2-discovery` off main. Open one PR per phase.

3. **Test runs use the worker pipeline.** Do not invoke the skill in the same Claude Code session you're editing it from — use `claude -p "/find-deals discover"` (separate process, fresh context, exercises the actual skill code path Sophie uses in production).

4. **Source env vars before any test run:** `source ~/.zshrc`. ANTHROPIC_API_KEY, SUPABASE_DEALS_URL, SUPABASE_DEALS_ANON_KEY all required.

5. **Persist incrementally.** Per existing skill convention — never write only at end-of-run. The `discovered-sites.json` updates and `raw-listings-*.json` writes already follow this; preserve it.

6. **Backward compatibility for `discovered-sites.json`.** The existing file has no `discovery_metadata` or `performance_metadata` on its rows. The reader code must treat missing fields as zeros/nulls. The next discovery run will fully populate them.

7. **Stop and ask Gideon if:**
   - A Phase test gate fails twice with different fixes attempted.
   - The 50-source target is consistently unreachable (max ~30) after the query matrix is fully built — implies the architecture needs revisiting.
   - Token cost per `/find-deals full` run exceeds $20 — implies we need an Ollama-for-discovery side trip.

8. **All open questions resolved** in §4 (R1–R3). Do not ask Gideon to re-answer; proceed.

---

**End of spec.** When Gideon approves: hand to autonomous agent, branch off main, ship Phase 1 first.
