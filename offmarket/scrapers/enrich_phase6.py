#!/usr/bin/env python3
"""Phase-6 enrichment hook — single entry point for all orchestrators.

Design decision: subprocess invocation (not in-process function calls).
Rationale per PLAN §5: "Each pool runs in its own subprocess when called from
enrich_phase6.py."  Subprocess gives each scraper an independent crash domain
and its own Python interpreter state.  A Playwright deadlock or memory issue in
one scraper cannot corrupt enrich()'s process.  Parallelism is natural via
subprocess.Popen + wait().  Communication channel is the cache directory only
(no pipes, no return values across process boundaries) — exactly the architecture
the PLAN specifies.

In-process would be simpler, but a crashed Playwright context would kill the
enrich() call and all remaining scrapers.  Subprocess is the right choice here.

Usage (CLI):
  python3 -m offmarket.scrapers.enrich_phase6 --vertical pest-control
  python3 -m offmarket.scrapers.enrich_phase6 --vertical pest-control --no-cad
  python3 -m offmarket.scrapers.enrich_phase6 --vertical dental --force-refresh
"""
import argparse
import json
import subprocess
import sys
from pathlib import Path
from typing import Optional

# ---------------------------------------------------------------------------
# Resolve repo root so this module is importable without pip install.
# ---------------------------------------------------------------------------
_HERE = Path(__file__).resolve().parent
_REPO_ROOT = _HERE.parent.parent
if str(_REPO_ROOT) not in sys.path:
    sys.path.insert(0, str(_REPO_ROOT))

from offmarket.scrapers.cad_common import (
    cache_key,
    entity_key,
    load_targets,
    log_factory,
)

_CACHE_ROOT = Path(__file__).resolve().parent.parent / "cache"
_PORTALS_BY_COUNTY: dict[str, str] = {
    "harris": "hcad",
    "dallas": "dcad",
    "bexar": "bcad",
}
_KNOWN_COUNTIES = set(_PORTALS_BY_COUNTY.keys())

# Module-level registry of scraper modules for subprocess invocation
_SCRAPER_MODULE: dict[str, str] = {
    "comptroller": "offmarket.scrapers.scrape_comptroller",
    "hcad": "offmarket.scrapers.scrape_hcad",
    "dcad": "offmarket.scrapers.scrape_dcad",
    "bcad": "offmarket.scrapers.scrape_bcad",
}


# ---------------------------------------------------------------------------
# Pure helpers — testable without subprocess or network
# ---------------------------------------------------------------------------

def _split_by_county(
    targets: list[dict],
    vertical: str = "pest-control",
    county_overrides: Optional[dict[str, str]] = None,
) -> dict[str, list[dict]]:
    """Split targets into buckets by county.

    Returns a dict with keys: 'harris', 'dallas', 'bexar', 'other'.
    county_overrides: {entity_id: county_name} — force a target into a specific county.
    For backwards compat, also accepts the legacy {tpcl: county} form.
    County matching is case-insensitive.
    """
    buckets: dict[str, list[dict]] = {
        "harris": [],
        "dallas": [],
        "bexar": [],
        "other": [],
    }
    overrides = {k: v.lower() for k, v in (county_overrides or {}).items()}

    for t in targets:
        # Look up override by entity_key OR by tpcl (legacy) — whichever matches
        try:
            eid = entity_key(t, vertical)
        except KeyError:
            eid = None
        legacy_tpcl = t.get("tpcl", "")
        if eid and eid in overrides:
            county = overrides[eid]
        elif legacy_tpcl in overrides:
            county = overrides[legacy_tpcl]
        else:
            county = (t.get("county") or "").strip().lower()

        if county in _KNOWN_COUNTIES:
            buckets[county].append(t)
        else:
            buckets["other"].append(t)

    return buckets


def _merge_results(
    comptroller_cache_dir: Path,
    cad_cache_dirs: dict[str, Path],
    cache_keys: list[str],
) -> dict[str, dict]:
    """Read per-business cache files and merge into a single enrichment dict.

    Returns {cache_key: {"comptroller": {...} | None, "cad": {...} | None,
                         "entity_id": str, "cache_key": str}}.

    cache_keys: list of vertical-namespaced cache keys (from cad_common.cache_key).
    The returned dict's TOP-LEVEL key is the cache_key. Use payload["entity_id"]
    for the human-facing identifier.
    """
    results: dict[str, dict] = {}

    for ckey in cache_keys:
        # Extract entity_id from cache_key (format: "vertical__entity_id")
        eid = ckey.split("__", 1)[1] if "__" in ckey else ckey
        entry: dict = {
            "cache_key": ckey,
            "entity_id": eid,
            "comptroller": None,
            "cad": None,
        }

        # Load Comptroller cache
        cp = comptroller_cache_dir / f"{ckey}.json"
        if cp.exists():
            try:
                with cp.open("r", encoding="utf-8") as fh:
                    entry["comptroller"] = json.load(fh)
            except Exception:
                entry["comptroller"] = {"error": "cache_read_failed", "cache_key": ckey}

        # Load CAD cache (first portal that has a file for this entity)
        for portal_name, cache_dir in cad_cache_dirs.items():
            cp2 = cache_dir / f"{ckey}.json"
            if cp2.exists():
                try:
                    with cp2.open("r", encoding="utf-8") as fh:
                        entry["cad"] = json.load(fh)
                except Exception:
                    entry["cad"] = {"error": "cache_read_failed", "cache_key": ckey, "portal": portal_name}
                break  # first hit wins; an entity lives in one county

        # Surface cross_county_followup from the CAD cache to the top level
        if entry["cad"] and isinstance(entry["cad"], dict) and entry["cad"].get("cross_county_followup"):
            entry["cross_county_followup"] = entry["cad"]["cross_county_followup"]

        results[ckey] = entry

    return results


# ---------------------------------------------------------------------------
# Subprocess invocation
# ---------------------------------------------------------------------------

def _run_scraper(
    module: str,
    args: list[str],
    log,
    label: str,
) -> tuple[bool, Optional[str]]:
    """Run a scraper module as a subprocess.

    Returns (success: bool, error_msg: str | None).
    Non-zero exit is logged and treated as failure; enrich() continues.
    """
    cmd = [sys.executable, "-m", module] + args
    log(f"[{label}] running: {' '.join(cmd)}")
    try:
        proc = subprocess.run(
            cmd,
            capture_output=False,   # let scraper stdout/stderr flow through
            cwd=str(_REPO_ROOT),
        )
        if proc.returncode != 0:
            msg = f"[{label}] subprocess exited with code {proc.returncode}"
            log(msg)
            return False, msg
        log(f"[{label}] completed OK")
        return True, None
    except Exception as e:
        msg = f"[{label}] subprocess launch error: {type(e).__name__}: {str(e)[:120]}"
        log(msg)
        return False, msg


# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

def enrich(
    vertical: str,
    *,
    run_comptroller: bool = True,
    run_cad: bool = True,
    county_overrides: Optional[dict[str, str]] = None,
    force_refresh: bool = False,
) -> dict[str, dict]:
    """Returns {tpcl: merged_enrichment_dict}.

    Reads offmarket/data/{vertical}_targets.json.
    If run_comptroller: invokes scrape_comptroller subprocess over all targets.
    If run_cad: splits targets by county and invokes hcad/dcad/bcad subprocesses.
    Targets in unknown counties get cross_county_followup entries, not scraped.
    county_overrides: {tpcl: county_name} — override a target's county field.
    force_refresh: passed down to each scraper via --force-refresh flag.

    Subprocess design: each scraper runs in its own subprocess (per PLAN §5).
    Scrapers communicate with enrich() via the cache directory only.
    A failing subprocess is logged and skipped — does not abort enrich().
    """
    log = log_factory("enrich_phase6")
    log(f"enrich(): vertical={vertical!r}, run_comptroller={run_comptroller}, run_cad={run_cad}, force_refresh={force_refresh}")

    # Load targets
    try:
        targets = load_targets(vertical)
    except FileNotFoundError as e:
        log(f"ERROR: {e}")
        return {}

    cache_keys = []
    for t in targets:
        try:
            cache_keys.append(cache_key(t, vertical))
        except KeyError as e:
            log(f"SKIP: target with no entity key: {e}")
    log(f"Loaded {len(targets)} targets ({len(cache_keys)} with valid entity keys)")

    # Build common scraper args
    common_args = ["--vertical", vertical]
    if force_refresh:
        common_args.append("--force-refresh")

    # Track per-portal subprocess status for reporting
    portal_status: dict[str, str] = {}

    # -----------------------------------------------------------------------
    # Comptroller pass
    # -----------------------------------------------------------------------
    if run_comptroller:
        ok, err = _run_scraper(
            _SCRAPER_MODULE["comptroller"],
            common_args,
            log,
            label="comptroller",
        )
        portal_status["comptroller"] = "ok" if ok else f"failed: {err}"
    else:
        log("Skipping Comptroller (run_comptroller=False)")
        portal_status["comptroller"] = "skipped"

    # -----------------------------------------------------------------------
    # CAD pass — split by county, dispatch per portal
    # -----------------------------------------------------------------------
    unknown_county_followups: dict[str, dict] = {}

    if run_cad:
        buckets = _split_by_county(targets, vertical=vertical, county_overrides=county_overrides)

        # Warn on unknowns; record cross_county_followup for merge step
        for t in buckets.get("other", []):
            county_val = (t.get("county") or "unknown").strip()
            try:
                ckey = cache_key(t, vertical)
            except KeyError:
                continue
            log(f"WARNING: unknown county {county_val!r} for {ckey} "
                f"({t.get('legal_name', '')[:40]}) — skipping CAD scrape")
            unknown_county_followups[ckey] = {
                "counties": [],
                "reason": "unknown_county_no_cad_scraper",
                "primary_county": county_val,
            }

        # Dispatch Harris → HCAD, Dallas → DCAD, Bexar → BCAD
        for county_key, portal in _PORTALS_BY_COUNTY.items():
            county_targets = buckets.get(county_key, [])
            if not county_targets:
                log(f"No {county_key} targets — skipping {portal}")
                portal_status[portal] = "skipped_no_targets"
                continue

            log(f"{county_key}: {len(county_targets)} targets → {portal}")
            ok, err = _run_scraper(
                _SCRAPER_MODULE[portal],
                common_args,
                log,
                label=portal,
            )
            portal_status[portal] = "ok" if ok else f"failed: {err}"
    else:
        log("Skipping CAD (run_cad=False)")
        for portal in _PORTALS_BY_COUNTY.values():
            portal_status[portal] = "skipped"

    # -----------------------------------------------------------------------
    # Merge cache files into result dict
    # -----------------------------------------------------------------------
    comptroller_cache_dir = _CACHE_ROOT / "comptroller"
    cad_cache_dirs: dict[str, Path] = {
        portal: _CACHE_ROOT / portal
        for portal in _PORTALS_BY_COUNTY.values()
    }

    merged = _merge_results(comptroller_cache_dir, cad_cache_dirs, cache_keys)

    # Inject unknown-county followups (these targets have no CAD scraper, so
    # the merge would otherwise leave them with no cross_county_followup)
    for ckey, followup in unknown_county_followups.items():
        if ckey in merged:
            merged[ckey]["cross_county_followup"] = followup

    # Attach portal_status to each entry (useful for debugging)
    for rec in merged.values():
        rec["_portal_status"] = portal_status

    # Re-key by entity_id (caller's natural identifier) — cache_key namespacing
    # is internal. enrich("dental") returns {license_number: {...}}; enrich("pest-control")
    # returns {tpcl: {...}}.
    by_entity = {rec["entity_id"]: rec for rec in merged.values()}

    log(f"Merge complete. {len(by_entity)} records. Portal status: {portal_status}")
    return by_entity


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def main() -> None:
    parser = argparse.ArgumentParser(
        description="Phase-6 enrichment: Comptroller + CAD for a given vertical"
    )
    parser.add_argument(
        "--vertical", default="pest-control",
        help="Target vertical (matches offmarket/data/{vertical}_targets.json)"
    )
    parser.add_argument(
        "--no-comptroller", action="store_true",
        help="Skip Comptroller scrape"
    )
    parser.add_argument(
        "--no-cad", action="store_true",
        help="Skip all CAD scrapes (HCAD/DCAD/BCAD)"
    )
    parser.add_argument(
        "--force-refresh", action="store_true",
        help="Ignore cache and re-fetch all records in all scrapers"
    )
    args = parser.parse_args()

    results = enrich(
        args.vertical,
        run_comptroller=not args.no_comptroller,
        run_cad=not args.no_cad,
        force_refresh=args.force_refresh,
    )

    # Summary output
    total = len(results)
    has_comptroller = sum(1 for r in results.values() if r.get("comptroller"))
    has_cad = sum(1 for r in results.values() if r.get("cad"))
    cross_f = sum(1 for r in results.values() if r.get("cross_county_followup"))
    print(f"\n=== Phase-6 Summary: {args.vertical} ===")
    print(f"  Total TPCLs : {total}")
    print(f"  Comptroller : {has_comptroller} enriched")
    print(f"  CAD         : {has_cad} enriched")
    print(f"  Cross-county: {cross_f} flagged for follow-up")


if __name__ == "__main__":
    main()
