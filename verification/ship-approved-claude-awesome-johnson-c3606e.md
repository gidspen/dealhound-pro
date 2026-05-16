# Ship approval — claude/awesome-johnson-c3606e

## Intent

Ship the Texas CAD scraper sprint for the off-market acquisition scorer. Adds HCAD/DCAD/BCAD scrapers, wires Comptroller franchise-tax enrichment cross-vertical (pest / dental / future fire-life-safety) via a single `enrich_phase6.enrich(vertical)` hook, lands the previously-uncommitted pest spike artifacts (Comptroller client, DCAD stub, §7 playbook, target data) as the foundation, and introduces the persistent `offmarket/cache/` directory replacing `/tmp` so each run feeds the closed-loop enrichment cache. Includes the Phase D independent-review fix pass that closed two CRITICAL bugs (HCAD/BCAD missing `--vertical`/`--force-refresh` argparse, `enrich("dental")` KeyError on `tpcl`) plus three HIGH (hardcoded vertical, split `cross_county_followup` schema, BCAD Feb-29 leap-year crash) and eight MEDIUM fixes. 174 tests passing.

## Files changed

- `.gitignore` — gitignore cache contents + Python `__pycache__/` under `offmarket/` (kept `.gitkeep` markers tracked)
- `offmarket/PLAN-cad-sprint.md` — full sprint plan + "Deviations from plan" section documenting HCAD Cloudflare discovery and narrowed cross-county scope
- `offmarket/REPORT-pest-tx-2026-Q2-v2.md` — pest spike report (§7 CAD playbook is the source of truth for portal flows)
- `offmarket/__init__.py`, `offmarket/scrapers/__init__.py`, `offmarket/scrapers/tests/__init__.py` — empty package markers so tests can `python -m unittest` the modules
- `offmarket/cache/{bcad,comptroller,dcad,hcad,logs}/.gitkeep` — tracked directory skeleton; contents gitignored
- `offmarket/data/pest-control_targets.json` — canonical pest target list (60 businesses) read by `load_targets("pest-control")`
- `offmarket/scrapers/cad_common.py` — new shared helpers: cache I/O (atomic write), log factory, target loader, name variants, exemption regex, `entity_key`/`cache_key` for cross-vertical namespacing, `is_cloudflare_challenge` detector
- `offmarket/scrapers/scrape_comptroller.py` — landed from pest spike + refactored to take `--vertical`, write to `offmarket/cache/comptroller/`, use field-typed 30-day TTL, emit run manifest
- `offmarket/scrapers/scrape_hcad.py` — new Playwright scraper for Harris County; recon found Cloudflare on `search.hcad.org` so HTTP path is dead, 2 browser contexts
- `offmarket/scrapers/scrape_dcad.py` — landed from pest spike + refactored: scoped table parser, cache-first, viewstate refresh every 20 reqs, ports inline JS regex to `cad_common.extract_exemptions`
- `offmarket/scrapers/scrape_bcad.py` — new Playwright scraper for Bexar; Cloudflare warmup + 7-marker challenge detector, 1 worker (CF-serial)
- `offmarket/scrapers/enrich_phase6.py` — new Phase-6 hook: `enrich(vertical)` splits targets by county, dispatches scrapers via subprocess (independent crash domains), merges cache files into entity_id-keyed return dict
- `offmarket/scrapers/tests/fixtures/{bcad,dcad,hcad}/*.html` — synthesized fixtures driving the parse-function tests; live verification via each scraper's `--save-fixture` flag required before first real run
- `offmarket/scrapers/tests/test_{bcad,cad_common,comptroller,dcad,enrich_phase6,hcad}.py` — 174 tests covering parse functions, cross-county followup schema, cache roundtrip + freshness + corruption handling, cross-vertical collision prevention, subprocess dispatch logic

## Confirmation

No files outside the intended scope were modified.
