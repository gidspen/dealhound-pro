# Run B — find-deals v2 Phase 2 Checkpoint (Universal Extractor)

## ORIENT (turns 1–4)

- Read spec §5.3 + §6, RUN_A_FIND_DEALS_V2_CHECKPOINT.md (Phase 1 outcomes), scrape-site.md (file being refactored), discovered-sites.json (current state), SKILL.md (orchestration).
- Confirmed Phase 1 branch `feat/find-deals-v2-discovery` exists and is pushed (Phase 1 PR #1 open against gidspen/find-deals-skill main).
- Branched `feat/find-deals-v2-extractor` off Phase 1 — stack PR pattern.
- Pre-selected test sites: NAI OHB (Gate K, in main registry, no Python scraper) + International Glamping Business (Gate R, NEW from Run A's discovery output, no human hand-tuning).
- Direct work: 5 file reads + 3 git/bash ops.
- Sub-agents: 0.

## PLAN (turn 5)

- Wrote `docs/RUN_B_FIND_DEALS_V2_PLAN.md`. Sections: file change list, universal-extract.md outline (10 steps), DOM detection heuristics in detail (3-signal combo), test sites (Gate K + Gate R rationale), sub-agent spawn plan (2 sonnet sub-agents), risks (5 named).
- Committed plan to worktree branch.
- Sub-agents: 0.

## BUILD (turns 6–9)

- **Sub-agent 1 (Sonnet):** Created `universal-extract.md` (557 lines). Covers all 10 steps: navigate + warm load, 3-signal cluster detection, JSON-LD/CSS heuristic JS fallback (full inline JS bodies), filter application, per-cluster extraction with detail-page visit cap, pagination, confidence scoring (1.0/0.7/0.4/0.0), save with required `extraction` block, `discovered-sites.json` performance_metadata update with auto-demote rules (3 empty → downgrade signal_quality; 5 empty → verified=false), terminal summary print, failure modes table.
- **Sub-agent 2 (Sonnet):** Refactored `scrape-site.md` Phase 2B. Replaced ~150 lines of freeform Playwright MCP playbook with a ~70-line orchestrator. Site selection skips Phase-2A-validated, unverified, blocked. Orders by `signal_quality` desc. Per-site delegation contract (url/page_type/buy_box/cap inputs). Progress events preserved. Failure-handling note. Full Phase 2 Sequence + promotion-to-Python-scraper trigger updated to reference confidence ≥ 0.7 over 3+ runs.
- Auto-demote logic folded into `universal-extract.md` Step 9 (per principle "pick the simpler home") — no separate Python script needed.
- Committed to skill branch as commit `234b871`.
- Direct work: 4 verification reads + 2 git/bash ops.
- Sub-agents: 2.

## VERIFY (turns 10–17)

### Test Gate K — NAI OHB (known-good site) — **PASS**

- Invoked `claude -p` against `/Users/gideonspencer/skills/find-deals/universal-extract.md` with URL `https://www.naiohb.com/listings/`, hospitality buy box, cap=200, 35-turn budget.
- **Result:** 22 listings extracted, confidence 0.7 ✅ (spec gate ≥ 0.7), 23 pages visited (1 index + 22 details), `blocked: false`.
- 2/22 unpriced listings (HTR Black Hills, Deer Point Meadows portfolio) cap confidence at 0.7 — title+url+(price OR location) on every listing satisfies 0.7 tier.
- Notable: extractor agent's Playwright MCP browser was locked by another concurrent test session; the routine fell back to WebFetch HTTP. Full extraction succeeded with all detail-page descriptions. Documented this as a follow-up note for the universal-extract.md failure-modes table.
- Evidence: `verification/run-b-naiohb-extraction.json` (30KB, full listings + extraction block).

### Test Gate R — International Glamping Business (random new site) — **PASS**

- URL: `https://www.glampingbusiness.com/businesses-for-sale/`. Net-new in Run A's Phase 1 discovery output (called out in Run A checkpoint as "net-new vs prior registry"), HIGH-signal, NOT in main `discovered-sites.json`.
- **Result:** 0 listings, `blocked: true`, `confidence: 0.0`, clean non-empty `notes`. ✅ (spec gate: ≥1 listing OR `blocked:true` OR `confidence:0.0` with non-empty notes — no crashes, no unhandled exceptions.)
- **Why graceful failure:** glampingbusiness.com is a UK trade-magazine wrapper that embeds listings via cross-origin iframe from `uk.businessesforsale.com`. The iframe target returns Cloudflare "Performing security verification" challenge (Ray ID 9f95e0178f6fe912). Zero price signals, zero listing-path anchors, zero structured data on the host page itself. The actual listing inventory belongs to a different (Cloudflare-hardened) domain.
- **Bonus actionable finding:** the real inventory lives at `uk.businessesforsale.com/search/camping-and-caravan-parks-and-rv-parks-for-sale`, but it's UK-denominated (GBP, UK locations). Worth a US-buy-box geography-filter note in the registry. Documented for a future PR.
- Evidence: `verification/run-b-random-extraction.json` (1KB, empty listings + extraction block with full notes).

### Regression — Python scrapers (Phase 2A path, untouched) — **PASS**

| Scraper                 | Result                                                                               |
| ----------------------- | ------------------------------------------------------------------------------------ |
| `landsearch`            | 247 unique TX listings (3 pages /resort + /lodge); 120 enriched with descriptions ✅ |
| `campground-connection` | 14 TX listings (Southwest region filter applied to 71 unique URLs) ✅                |

Phase 2A code path was deliberately untouched in this PR. Both scrapers run as before. Confirms no collateral regression from the Phase 2B refactor.

- Direct work: 4 background launches + 1 monitor + 4 result reads + 2 evidence file copies + 1 file revert.
- Sub-agents: 0.

## SHIP (turns 18–19)

- Pushed `feat/find-deals-v2-extractor` to gidspen/find-deals-skill (HEAD `234b871`).
- Reverted `discovered-sites.json` test-side-effect mutation before push (Step 9 wrote performance_metadata during the Gate K test run; the universal-extract.md routine itself is the deliverable — not the test-run side-effect on the registry file).
- Opened **PR #2 (stacked on PR #1):** https://github.com/gidspen/find-deals-skill/pull/2
- PR body: full diff stats, Gate K result (22 listings + 0.7 confidence), Gate R result (graceful blocked:true), regression results (landsearch 247 + campground 14), evidence file paths, follow-up notes (iframe wrapper finding, Playwright concurrency lock note, side-effect on registry file note), explicit base/head + merge-order instructions.
- Direct work: 1 git push + 1 PR create.
- Sub-agents: 0.

## FINAL (this turn)

### What was done

- ✅ `universal-extract.md` shipped (557 lines, all 10 spec §5.3 steps).
- ✅ `scrape-site.md` Phase 2B refactored to delegate (−74 net lines).
- ✅ `extraction` block in `raw-listings-[slug].json` (method, confidence, pages_visited, extractor_version v2, blocked, notes) — required on every output.
- ✅ Auto-demote rules (3 empty → signal_quality downgrade; 5 empty → verified=false) live in universal-extract.md Step 9.
- ✅ Test Gate K **PASS** — NAI OHB, 22 listings, confidence 0.7.
- ✅ Test Gate R **PASS** — glampingbusiness.com, graceful blocked:true degradation.
- ✅ Python scraper regressions **PASS** — landsearch (247) + campground-connection (14).
- ✅ PR #2 opened, stacked on PR #1 — merge order documented in body.

### What was NOT done and why

- ❌ Phase 3 (telemetry loop closure per spec §6 Phase 3) intentionally not started — out of scope for Run B. Will branch off `feat/find-deals-v2-extractor` as `feat/find-deals-v2-telemetry`.
- ❌ Did not add an explicit "Playwright MCP session lock → WebFetch fallback" line item to the universal-extract.md failure-modes table. The fallback worked organically in Gate K (the agent figured it out from the existing failure-mode rows that say "graceful degradation only — never throw"), but a future PR should make this explicit. Not a blocker.
- ❌ Did not act on the glampingbusiness.com iframe-wrapper finding (the actual inventory is at uk.businessesforsale.com which is GBP-denominated). Documented for a future registry-curation PR.

### Anything ambiguous needing human judgment

1. **Should the test-side-effect on `discovered-sites.json` (performance_metadata write) ship as part of the PR?** I reverted it to keep the diff clean — the gate evidence JSON captures that Step 9 fired. But an alternate interpretation says: the test demonstrates the feature works, and shipping the file with realistic perf data is fine. Recommendation: keep the revert. Production runs of the extractor will populate `discovered-sites.json` properly during real `/find-deals scrape` invocations.
2. **Confidence 0.7 vs 1.0 calibration on NAI OHB.** Spec gate is ≥ 0.7 and we hit exactly that. The two unpriced listings (HTR Black Hills, Deer Point Meadows) prevent 1.0. This is correct per the spec, but it suggests the rubric is strict — many real broker sites have a few unpriced or under-contract listings. Consider whether 1.0 should require 95% rather than 100% in a future revision. Not a blocker.
3. **Concurrent Playwright MCP sessions lock each other.** When 4 parallel test invocations ran on this Mac, Gate K hit a Playwright lock and fell back to WebFetch. The fallback worked but isn't documented in the routine. Worth a follow-up doc PR.

### Evidence files

- `verification/run-b-naiohb-extraction.json` — Gate K, 22 listings + extraction block (30KB)
- `verification/run-b-random-extraction.json` — Gate R, blocked + notes (1KB)
- `docs/RUN_B_FIND_DEALS_V2_PLAN.md` — pre-build plan (~100 lines)
- `docs/RUN_B_FIND_DEALS_V2_CHECKPOINT.md` — this file

### Skill repo PR

**https://github.com/gidspen/find-deals-skill/pull/2** (stacked on PR #1 — merge order: #1 → main, then #2 → main).

Skill branch HEAD: `234b8717404c947516e5c9300f7f715063a037e5`.

### Worktree branch

Worktree branch: `claude/sad-visvesvaraya-35b506`. Plan + checkpoint + evidence files committed in this run will land in a single follow-up commit.

### Token budget audit

- Turns used: ~22 of 80 budget (very disciplined).
- Sub-agent spawns: 2 (universal-extract.md creation + scrape-site.md refactor — both Sonnet). Both single-shot, no iteration needed.
- Direct-work items: ~20 (file reads, git ops, background launches, evidence saves, monitor, JSON parses).
- Test runs: 4 in parallel (Gate K + Gate R via `claude -p` subscription path; landsearch + campground via Python). All completed successfully on first try.
- Verdict: discipline held. Opus tokens spent on planning/diagnosis/decision; Sonnet tokens spent on bulk file authoring; subscription tokens spent on test runs. No wasted iterations.
