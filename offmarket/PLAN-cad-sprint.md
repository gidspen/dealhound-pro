# PLAN — Texas CAD Scraper Sprint + Cross-Vertical Comptroller Wiring

**Scope:** Ship HCAD/DCAD/BCAD scrapers + wire Comptroller auto-enrichment across pest/dental/fire-life-safety + move enrichment cache from `/tmp` to persistent `offmarket/cache/`.

**Mirrors:** `scrape_comptroller.py` (working pattern).
**Refines:** `scrape_dcad.py` (existing stub).
**Builds:** HCAD + BCAD from scratch.
**Playbook source:** `REPORT-pest-tx-2026-Q2-v2.md` §7.

## 1. Architecture — narrow shared helper, YES

Build `offmarket/scrapers/cad_common.py`. Abstracts only what truly recurs across all 3 portals + Comptroller:

- `cache_path(portal: str, tpcl: str) -> Path` — single source of truth for cache file location.
- `load_cached(portal, tpcl, fresh_until_map=None) -> dict | None` — returns parsed JSON if per-field freshness OK, else None.
- `write_cached(portal, tpcl, payload: dict) -> None` — atomic write (tmpfile + os.replace).
- `log_factory(portal: str) -> Callable[[str], None]` — timestamped stdout + per-portal log file in `offmarket/cache/logs/`.
- `load_targets(vertical: str, county_filter: list[str] | None = None) -> list[dict]` — single loader reading `offmarket/data/{vertical}_targets.json`. Handles vertical-specific keying (TPCL for pest, NPI for dental).
- `name_variants(legal_name, owner_name) -> list[tuple[str, str|None]]` — ports the existing `name_to_last_first` logic from `scrape_dcad.py`.
- `extract_exemptions(text: str) -> dict` — single regex pack for OV65 / homestead / disabled / deed_date / year_built / appraised_value. Ports JS regex blob from `scrape_dcad.py`.
- `summary(results: dict, log) -> None` — count statuses, print histogram.

**What does NOT abstract:** portal navigation, form selectors, anti-bot warmup, result-row parsing. Each portal's UI is too different — abstracting these creates leaky polymorphism.

**Justification:** cache + log + target-loading would be triplicated. Exemption regex would be triplicated. Name variants are 30 lines that already exist once. >100 LOC saved with zero coupling cost. Going wider (abstract `BaseCADScraper`) buys nothing.

## 2. File layout

```
offmarket/scrapers/cad_common.py          # cache, log, name variants, exemption regex, target loader
offmarket/scrapers/scrape_hcad.py         # Harris — search.hcad.org, XHR-first recon then HTTP or Playwright
offmarket/scrapers/scrape_dcad.py         # Dallas — refined from existing stub
offmarket/scrapers/scrape_bcad.py         # Bexar — Cloudflare warmup, TrueAutomation classic
offmarket/scrapers/scrape_comptroller.py  # MODIFY: --vertical flag; cache to offmarket/cache/comptroller/
offmarket/scrapers/enrich_phase6.py       # Phase-6 hook — single entry point any orchestrator calls
offmarket/cache/comptroller/{tpcl}.json   # one file per business, atomic write
offmarket/cache/{h,d,b}cad/{tpcl}.json    # same, per portal
offmarket/cache/logs/{portal}.log         # per-portal append-only log
offmarket/scrapers/tests/fixtures/        # recorded HTML/JSON per portal
offmarket/scrapers/tests/test_*.py        # one fixture-driven smoke test per scraper
```

`offmarket/cache/` added to `.gitignore`.

## 3. Phase-6 integration hook

```python
# offmarket/scrapers/enrich_phase6.py

def enrich(vertical: str, *, run_comptroller=True, run_cad=True,
           county_overrides: dict[str,str]|None=None,
           force_refresh: bool=False) -> dict[str, dict]:
    """Returns {tpcl: merged_enrichment_dict}.
    Reads offmarket/data/{vertical}_targets.json. Splits by county.
    Comptroller: single ThreadPoolExecutor pass over all businesses.
    CAD: dispatches by county → hcad/dcad/bcad → writes per-business cache files.
    Returns one dict keyed by tpcl with merged comptroller + cad fields."""
```

Any vertical orchestrator (pest, dental, fire/life-safety) calls `enrich("dental")`. Cache-first; only hits network for missing/stale entries. **One hook, one signature, three callers.**

CLI: `python -m offmarket.scrapers.enrich_phase6 --vertical dental --no-cad` for Comptroller-only quick runs.

## 4. Persistent cache — file-per-business JSON

**Schema:**

```json
{
  "tpcl": "...",
  "fetched_at": "ISO8601",
  "portal": "hcad|dcad|bcad|comptroller",
  "status": "...",
  "raw_term": "...",
  "owner_match": {...},
  "exemptions": {"ov65": true, "homestead": true, "disabled": false},
  "deed_date": "YYYY-MM-DD",
  "appraised_value": 123456,
  "fresh_until": {"ov65": "2026-08-12", "deed_date": "2027-05-14", "appraised_value": "2027-05-14"},
  "errors": []
}
```

**Cache key:** `(portal, tpcl)`. For verticals without TPCL (dental → NPI), keying is hidden inside `load_targets`. Cache is portal+entity, not vertical-scoped, so dental and pest businesses sharing an address don't pay the lookup tax twice.

**TTL — field-typed, not portal-wide:**

- `ov65`, `homestead`, `disabled`: 90 days (catches the toggle within a quarter of when it happens).
- `deed_date`, `appraised_value`, `year_built`: 365 days (annual appraisal cycle).
- Comptroller `status`: 30 days (forfeiture cascades quickly).

`load_cached` checks per-field freshness; partial cache hits trigger only the stale-field refetch.

**Atomic write:** write to `{tpcl}.json.tmp`, then `os.replace`. Survives mid-run crashes.

**Why not SQLite:** zero new deps, easy to grep/inspect, trivial to delete a single bad record. Revisit if cache grows past ~10K entries.

## 5. Concurrency + rate-limit

**Two distinct worker pools, never shared:**

| Portal      | Engine                                                         | Workers                                | Justification                                                                                         |
| ----------- | -------------------------------------------------------------- | -------------------------------------- | ----------------------------------------------------------------------------------------------------- |
| Comptroller | `urllib` + `ThreadPoolExecutor`                                | **8**                                  | Proven in `scrape_comptroller.py`. ~6s for 60 businesses. Pure JSON API.                              |
| HCAD        | XHR recon first → `urllib`+ThreadPool if open, else Playwright | **4** HTTP / **2** Playwright fallback | §7: no anti-bot. React SPA likely has reachable JSON XHR.                                             |
| DCAD        | Playwright (sync)                                              | **2**                                  | ASP.NET viewstate is per-session. Two browser contexts max.                                           |
| BCAD        | Playwright (sync)                                              | **1**                                  | Cloudflare challenge per session. Parallelism = more challenges. Serial with reused context is safer. |

**Per-portal politeness:** 500ms between requests in HCAD, 1s in DCAD, 2s in BCAD.

**Each pool runs in its own subprocess** when called from `enrich_phase6.py`. Sub-processes communicate via the cache directory only.

## 6. Test strategy

- **Fixtures:** `offmarket/scrapers/tests/fixtures/{portal}/`. One `search_results.html` + one `detail.html` per portal. Captured via `--save-fixture` flag.
- **Default mode:** fixture-driven. Tests load HTML from disk, hand it to pure `_parse_results()` / `_parse_detail()` functions, assert exemption fields. **No network in CI.**
- **Live mode:** `python -m unittest test_hcad --live`. Hits real portals with one known-good owner. Used to refresh fixtures.
- **Refresh cadence:** quarterly + on reported failures.

Each scraper splits `search_owner(page, term)` → `(html, _parse_results(html))`. The parse function is pure and unit-testable.

## 7. Implementation order

**HCAD first.** Reasoning: §7 says "no anti-bot observed" and it's a React SPA — likely fetches JSON over XHR. If we can sniff the XHR endpoint, HCAD becomes a Comptroller-style HTTP scraper.

**Agent H's first 10 minutes are XHR reconnaissance only:**

1. Open Chrome devtools, capture XHR on a manual owner search.
2. If XHR is open (no Auth0, no CSRF) → HTTP path, 4 workers.
3. If XHR is auth-walled → Playwright path, 2 workers. **Both paths pre-documented in the brief.**

Sequence:

1. `cad_common.py` — pure helpers, no portal deps. **(serial prep)**
2. `scrape_hcad.py` — XHR recon, then implementation. **(parallel)**
3. `scrape_dcad.py` — refine existing stub. **(parallel)**
4. `scrape_bcad.py` — Cloudflare warmup + detail-page click flow. **(parallel)**
5. `enrich_phase6.py` orchestration wrapper + Comptroller modification. **(serial finalize)**
6. Tests last — fixtures captured from live runs of steps 2–4.

## 8. Risk register

| #   | Risk                                                           | Likelihood | Fallback                                                                                                                                                         |
| --- | -------------------------------------------------------------- | ---------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1   | HCAD XHR auth-walled → HTTP-first fails                        | M          | Pre-documented Playwright fallback. Cost: ~10 min vs ~2 min runtime.                                                                                             |
| 2   | DCAD viewstate cookie expires mid-batch                        | M          | Re-warm homepage every 20 requests.                                                                                                                              |
| 3   | BCAD Cloudflare upgrades to CAPTCHA                            | L–M        | Detect challenge HTML; mark `bcad_status: "cloudflare_blocked"`; cache survives, resume later.                                                                   |
| 4   | Sole-prop owner lives outside business county (Fincannon case) | H          | **Cross-county fallback shipped in v1.** Each scraper accepts `fallback_counties`. After primary returns no match, retry against adjacent CADs (4 attempts max). |
| 5   | Portal HTML structure changes                                  | M          | Fixture tests fail loudly. Refresh via `--save-fixture`.                                                                                                         |

**Cross-county fallback lists:**

- HCAD primary: Harris. Fallbacks: Fort Bend, Montgomery, Brazoria.
- DCAD primary: Dallas. Fallbacks: Collin, Denton, Tarrant, Rockwall.
- BCAD primary: Bexar. Fallbacks: Comal, Guadalupe.

## 9. Parallelization map

**Phase A — serial prep (1 Sonnet agent, ~10 min):**

- Create `cad_common.py`, `offmarket/cache/` directory tree, update `.gitignore`. Every downstream agent imports from `cad_common`.

**Phase B — parallel implementation (3 Sonnet agents, fully concurrent):**

- **Agent H:** `scrape_hcad.py` + `tests/test_hcad.py` + fixtures + cross-county fallback (Fort Bend, Montgomery, Brazoria).
- **Agent D:** `scrape_dcad.py` refinement + `tests/test_dcad.py` + fixtures + cross-county fallback (Collin, Denton, Tarrant, Rockwall).
- **Agent B:** `scrape_bcad.py` + `tests/test_bcad.py` + fixtures + cross-county fallback (Comal, Guadalupe).

Each agent owns disjoint files. Each reads `cad_common` read-only. Each writes its own portal cache directory. **Zero conflict potential.**

**Phase C — serial finalize (1 Sonnet agent, ~20 min):**

- Modify `scrape_comptroller.py` (add `--vertical`, switch to `offmarket/cache/comptroller/`).
- Create `enrich_phase6.py` dispatching all 4 scrapers.
- Create `test_enrich_phase6.py` integration smoke test.

**Phase D — independent review (1 Opus agent, ~10 min):**

- Adversarial review of all changes vs this plan. Surface any gaps before merge.

**Total: 5 Sonnet agent-calls + 1 Opus review.**

**Realistic wall-time:** ~90 min if Phase B agents truly concurrent.

## 10. Sonnet briefs — self-contained

Each parallel agent gets:

1. Absolute path to the file it writes.
2. Function signatures from §1.
3. Selectors from §7 of REPORT v2 (quoted).
4. The cache-write idiom from `cad_common.write_cached`.
5. The Comptroller scraper as style reference.
6. Cross-county fallback list (vertical-specific).

No agent needs to read another agent's output to make decisions.

---

## Self-critique (eng review) — incorporated into plan above

Three weakest decisions in the first draft + the fixes that are now in the plan:

1. **"HCAD HTTP-first" was hope, not engineering.**
   - _Fix:_ Agent H's first 10 minutes are XHR reconnaissance. Decision tree documented in brief. Playwright fallback ready, not researched at runtime.

2. **Uniform 90-day TTL masks OV65 toggle events.**
   - _Fix:_ Field-typed TTLs. OV65/homestead/disabled = 90d. Deed/value/year_built = 365d. Comptroller status = 30d. `fresh_until` map in cache entry.

3. **"Cross-county fallback in Phase 2" reships the exact gap §7 identified (Fincannon case).**
   - _Fix:_ Cross-county fallback shipped in v1. Each scraper accepts `fallback_counties` list. ~1 hour added to each parallel agent.

---

## Critical files for implementation reference

- `offmarket/scrapers/scrape_comptroller.py` — style reference
- `offmarket/scrapers/scrape_dcad.py` — existing stub to refine
- `offmarket/data/pest-control_targets.json` — target schema
- `offmarket/REPORT-pest-tx-2026-Q2-v2.md` — §7 playbook source
- `offmarket/scrapers/cad_common.py` — created in Phase A, imported by all
