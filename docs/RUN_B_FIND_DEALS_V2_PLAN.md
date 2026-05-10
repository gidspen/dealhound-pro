# Run B — find-deals v2 Phase 2 Plan (Universal Extractor)

**Date:** 2026-05-09
**Branch:** `feat/find-deals-v2-extractor` (stacked on `feat/find-deals-v2-discovery` from Run A — Phase 1 PR #1)
**Goal:** Ship Phase 2 of spec §6 — universal DOM extractor + Phase 2B refactor + auto-demote logic, all gated by two test runs (NAI OHB known-good + random new site).

## File change list

| File                                                                | Change | Why                                                                                       |
| ------------------------------------------------------------------- | ------ | ----------------------------------------------------------------------------------------- |
| `~/skills/find-deals/universal-extract.md`                          | NEW    | Structured extractor routine per spec §5.3 — function signature, algorithm, IO contract.  |
| `~/skills/find-deals/scrape-site.md`                                | MODIFY | Phase 2B refactored: thin loop over HIGH/MEDIUM signal sites that delegates to extractor. |
| `~/skills/find-deals/discovered-sites.json` schema (no edit)        | —      | Already supports `performance_metadata.consecutive_empty_scrapes` from Phase 1.           |
| `verification/run-b-naiohb-extraction.json`                         | NEW    | Test Gate K evidence.                                                                     |
| `verification/run-b-random-extraction.json`                         | NEW    | Test Gate R evidence.                                                                     |
| `docs/RUN_B_FIND_DEALS_V2_PLAN.md`                                  | NEW    | This file.                                                                                |
| `docs/RUN_B_FIND_DEALS_V2_CHECKPOINT.md`                            | NEW    | Final checkpoint.                                                                         |

## universal-extract.md outline

The skill file will have these sections, in order:

1. **Frontmatter + purpose** — what this skill does, when it's invoked (from `scrape-site.md` Phase 2B loop).
2. **Function signature + IO contract** — `extract_listings(url, page_type, buy_box, cap=200) -> {listings, extraction_confidence, pages_visited, blocked, notes}`.
3. **Step 1: Navigate + warm load** — `browser_navigate` + `browser_wait_for(time=2)` + `browser_snapshot`.
4. **Step 2: Detect listing structure** — three pattern detectors (DOM repetition, anchor clusters, price-density), with explicit heuristics (see below).
5. **Step 3: Generic JS extractor fallback** — `browser_evaluate` with CSS-heuristic + microdata/JSON-LD detection function (full JS body provided inline).
6. **Step 4: Apply site filters** — same logic from current Phase 2B Step 2, formalized.
7. **Step 5: Extract per cluster** — full schema fields (title, price, location, url, address, acreage, rooms_keys, revenue_hint, dom_hint, condition_hint, description, source_url). Description must be from detail page if index card only has snippet (cap 30/site).
8. **Step 6: Paginate** — find next/load-more via accessibility tree text, click via `ref`, re-snapshot.
9. **Step 7: Score extraction confidence** — exact heuristic from spec §5.3 step 6 (1.0/0.7/0.4/0.0).
10. **Step 8: Save + update registry** — write `raw-listings-[slug].json` with `extraction` block; increment `discovered-sites.json` `performance_metadata`.
11. **Step 9: Auto-demote** — increment `consecutive_empty_scrapes` if zero listings; downgrade `signal_quality` (high→medium→low) at 3 consecutive empties; mark `verified: false` at 5 consecutive.
12. **Failure modes table** — blocked, no pattern detected, JS-heavy site, CAPTCHA. Each maps to a graceful degradation path.

## DOM pattern detection heuristics (detail)

Detect listing clusters with these three orthogonal signals; success = ≥2 of 3 agree:

**Signal A: Repeated sibling DOM patterns**
- Walk accessibility tree; find any parent node where ≥5 direct children share the same role (`article`, `link`, `listitem`, etc.) and roughly comparable subtree depth.
- Selector heuristics for the JS fallback: `article[class*="listing"]`, `article[class*="property"]`, `div[class*="card"]`, `div[class*="result"]`, `li[class*="listing"]`, `li[class*="property"]`, `[itemtype*="schema.org"]`.

**Signal B: Anchor-tag clusters**
- Find `<a>` tags with `href` paths sharing a common prefix (e.g., 5+ links to `/listing/...`, `/property/...`, `/p/...`, `/business/...`, `/inn/...`).
- Common prefix detected via longest common path segment ≥1 segment, ≥5 occurrences.

**Signal C: Price-pattern density**
- Regex `\$\s?\d{1,3}([,.]?\d{3})*([KkMm])?` (matches `$1,200,000`, `$1.2M`, `$300K`, `$300000`).
- Count matches within tight DOM neighborhoods (parent containing ≥5 prices).

If 0 signals fire → fall back to `browser_evaluate` with generic JS extractor (microdata/JSON-LD first, then CSS heuristics).
If still 0 → return empty listings, confidence 0.0, notes="no listing pattern detected".

## Test sites

**Test Gate K — NAI OHB (known-good site):**
- URL: `https://www.naiohb.com/listings/`
- Why: HIGH-signal specialist broker, currently in registry as Phase 2B candidate (no Python scraper), well-formed listings with 13 active for-sale properties.
- Acceptance: ≥10 listings extracted (matches expected from registry notes), `extraction.confidence ≥ 0.7`, no crashes.

**Test Gate R — International Glamping Business (random new site):**
- URL: `https://www.glampingbusiness.com/businesses-for-sale/`
- Why: Net-new in Run A's Phase 1 discovery output (called out in the checkpoint as "net-new vs prior registry"). HIGH-signal, verified in Run A. NOT in main `discovered-sites.json` (so no human has hand-tuned for it). Clean test for cross-site robustness of universal extractor.
- Acceptance: ≥1 listing extracted OR `blocked: true` OR `confidence: 0.0` with non-empty `notes`. No crashes, no unhandled exceptions.

## Sub-agent spawn plan

| # | Sub-agent task                                              | Why delegate                                                      | Token cost  |
| - | ----------------------------------------------------------- | ----------------------------------------------------------------- | ----------- |
| 1 | Create `universal-extract.md` per spec §5.3 (full skill)    | Largest single file; spec text + algorithm expansion = bulk work. | Sonnet bulk |
| 2 | Refactor `scrape-site.md` Phase 2B to delegate to extractor | Targeted edit on existing file; needs careful diff                | Sonnet      |
| 3 | (Optional) auto-demote logic if separate Python script      | Only if I decide on script path vs in-extractor. Likely in-extractor (simpler).    | —           |

**Total expected sub-agent spawns:** 2 (auto-demote folded into universal-extract.md per principle "pick the simpler home").

## Risks

| Risk | Likelihood | Mitigation |
| --- | --- | --- |
| Confidence scoring produces 0.4 on NAI OHB instead of 0.7 (description requires detail-page visit, may be partially missing on cards) | Medium | Description-from-detail-page logic in Step 5 should bump card-only sites up. If still 0.4, the spec gate is "≥0.7" — would need to iterate. Document and proceed if so. |
| Random site (glampingbusiness.com) has unusual DOM, returns 0 listings | Medium | This is a *valid* outcome per Test Gate R criteria (zero is OK if `notes` field populated). Goal is graceful fail, not extraction success. |
| Playwright MCP launches Chromium and blocks on `--dangerously-skip-permissions` despite flag (we hit this in Run A on Gate I Write step) | Medium | Run via `claude -p` with the flag; if Write to test JSON file is blocked, save log output instead and document. |
| Test Gate K runs over 50-turn budget | Low-Medium | Pre-allocate 30 turns max; if it runs over, log the partial run and bump to 40 in the second attempt. |
| Token cost of running a full extractor pass via `claude -p` exceeds expected | Medium | Subscription path (`claude -p` with `--dangerously-skip-permissions`) charges against subscription, not ANTHROPIC_API_KEY. Verified safe in Run A. |

## Stop conditions

- Test Gate K fails 2x with different fixes → document mismatch, open WIP PR with status flagged
- Sensitive-file Write block again (like Gate I) → save log + alternative evidence, document, proceed
- 70 turns used → write FINAL checkpoint, ship what's there

## Out of scope (don't touch)

- Phase 1 deliverables (`discover-sites.md`, schema) — read-only
- Existing Python scrapers (`scrapers/scraper.py`) — only run as regression tests
- Phase 3 (telemetry loop closure) — separate branch later, stacks on this one
