# Ship Approval — claude/scorer-model-fixes-5findings (5 model-improvement findings from May 2026 deep-dive)

## Intent

Implements the 5 model-improvement findings surfaced by the Playwright A-tier deep-dive in PR #65 (already merged to main). Every finding now has dedicated code, helper modules, and tests. The skill documentation patches are written to `offmarket/SKILL_DOC_PATCHES.md` rather than applied directly because the `offmarket-acquisition-scorer` skill is in active use by another thread — the user can apply the doc patches when that other thread finishes.

The PR is additive under `offmarket/`. No application source code changes outside that directory. No schema or runtime config changes. Existing scraper APIs are backward compatible (the `extract_exemptions()` return-dict gains new fields but existing fields are unchanged; `_merge_results()` gains an optional `targets_by_ckey` parameter with a None default).

Test results: **236/236 passing.** New tests: 8 Bexar OV65 proxy, 17 cad_registry, 24 scoring_rules, 10 PIR parser, 3 enrich_phase6 wiring.

## Files changed

### Extended scraper helpers (Findings 1, 3)

- `offmarket/scrapers/cad_common.py` — extended `extract_exemptions()` with Bexar OTHER + tax-savings OV65 proxy (Whitaker pattern, $6K+ threshold) and DCAD Tax Ceiling line proxy (Animal Hospital of Valley Ranch pattern). New return fields: `ov65_inferred`, `ov65_inference_source`, `tax_savings_amount`, `tax_ceiling`, `ov65_any`. Backward compatible — existing `ov65` boolean unchanged.
- `offmarket/scrapers/scrape_comptroller.py` — adds `parse_pir_html()` + `fetch_pir()` to extract the Public Information Report officer list (directors/managers/principals + addresses) from the HTML account-status page. The JSON API only exposes the registered agent; the PIR officer list lives on `comptroller.texas.gov/taxes/franchise/account-status/search/{taxpayerId}`. `_lookup_one()` now fetches and caches both.

### New modules (Findings 2, 4, 5)

- `offmarket/scrapers/cad_registry.py` — declarative CAD bimodal classification. Every TX CAD county tagged `works | blocked_spa | blocked_by_law | untested` with ordered alternative-path strategies for blocked counties (county-clerk deed records → voter file → license-tenure proxy with low-confidence cap). 309 lines, exhaustive registry.
- `offmarket/scoring_rules.py` — new module encoding Findings 4 + 5. `verify_owner_name()` cross-checks JSON owner_name against PIR officers + registered agent (handles four mismatch kinds: not_found_in_pir, non_control_role_only, registered_agent_match_but_pir_different_family, no_pir_data). `detect_succession_completed()` detects four signals (multi-officer different addresses, founder absent from team page, non-family Chief of Staff, recent-grad associate hiring). `apply_verification_gates()` is the combined entry point that returns recommended tier/confidence caps for downstream scoring.

### Wiring

- `offmarket/scrapers/enrich_phase6.py` — `_merge_results()` extended with optional `targets_by_ckey` parameter. When provided, every merged record gets `verification_gates` (from scoring_rules) and `cad_status_advisory` (from cad_registry) attached. `enrich()` builds the `targets_by_ckey` map naturally so production runs get the new advisories automatically.

### Documentation (deferred)

- `offmarket/SKILL_DOC_PATCHES.md` — six doc patches to apply to the live skill markdown (`scoring-model.md`, `verifying-no-successor.md`, `data-sources-and-compliance.md`, `pipeline.md`, `a-tier-deep-dive.md`) once the other thread using the skill finishes. Patches describe the new Layer-1 OV65 inference sources, new hard gates 7+8, new verifying-no-successor patterns, CAD bimodality, enrich-pipeline verification-gate step, and A-tier deep-dive PIR officer cross-check.

### Tests (all passing, 236/236)

- `offmarket/scrapers/tests/test_cad_common.py` — 8 new tests for Bexar OV65 proxy + DCAD Tax Ceiling + backward-compat guards.
- `offmarket/scrapers/tests/test_cad_registry.py` — 17 new tests for status classification + alt-path priority + registry-shape invariants.
- `offmarket/scrapers/tests/test_comptroller.py` — 10 new tests for the PIR HTML parser (Whitaker fixture, year detection, officer-row filtering, HTML entity decoding).
- `offmarket/scrapers/tests/test_enrich_phase6.py` — 3 new tests confirming `verification_gates` + `cad_status_advisory` attach correctly for owner-mismatch + blocked-CAD cases.
- `offmarket/tests/test_scoring_rules.py` — 24 new tests covering verify_owner_name (Whitaker/Fire-Safe/Perdue patterns), detect_succession_completed (Bellaire/Whitaker/Colleyville patterns), and apply_verification_gates combined-gate output.

## Confirmation

No files outside the intended scope were modified. All changes are additive under `offmarket/`. Zero changes to application source code outside that directory (`app/`, `worker/`, `api/`, `dashboard/`, `lib/`, etc.). Zero schema or runtime config changes. Pre-existing offmarket scraper APIs remain backward compatible — only new return fields added, no removals or renames. The skill markdown files at `/Users/gideonspencer/.claude/skills/offmarket-acquisition-scorer/` were NOT modified per user's explicit "the skill is actively being used in another thread" instruction; patches are queued in `SKILL_DOC_PATCHES.md` for manual application when safe. No `--no-verify` used. No force-push. Branch is `claude/scorer-model-fixes-5findings`, not main.
