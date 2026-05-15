#!/usr/bin/env python3
"""TX Comptroller Taxable Entity Search via direct JSON API.

API endpoints (discovered via XHR trace):
  GET https://comptroller.texas.gov/data-search/franchise-tax?name=<NAME>
      → {success, data: [{name, taxpayerId, mailingAddressZip}], count}
  GET https://comptroller.texas.gov/data-search/franchise-tax/<taxpayerId>
      → {success, data: {rightToTransactTX, sosRegistrationStatus, ...full record}}

Cache: offmarket/cache/comptroller/{tpcl}.json  (atomic write via cad_common)
  status TTL: 30 days per PLAN §4.
"""
import argparse
import json
import sys
import urllib.parse
import urllib.request
import ssl
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from datetime import datetime, timezone, date, timedelta
from pathlib import Path

# ---------------------------------------------------------------------------
# Resolve repo root so this module is importable without pip install.
# ---------------------------------------------------------------------------
_HERE = Path(__file__).resolve().parent
_REPO_ROOT = _HERE.parent.parent
if str(_REPO_ROOT) not in sys.path:
    sys.path.insert(0, str(_REPO_ROOT))

from offmarket.scrapers.cad_common import (
    cache_path,
    load_cached,
    load_targets,
    log_factory,
    summary,
    write_cached,
)

PORTAL = "comptroller"
API_SEARCH = "https://comptroller.texas.gov/data-search/franchise-tax"
HEADERS = {'User-Agent': 'Mozilla/5.0 (Macintosh) Chrome/120.0.0.0', 'Accept': 'application/json'}
CTX = ssl.create_default_context()

# Field-typed TTL: Comptroller status = 30 days per PLAN §4
_STATUS_TTL_DAYS = 30
# fresh_until_map key used for cache freshness checks
_FRESH_UNTIL_MAP = {"status": "any"}


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _get_json(url: str, retries: int = 2) -> dict:
    for attempt in range(retries + 1):
        try:
            req = urllib.request.Request(url, headers=HEADERS)
            with urllib.request.urlopen(req, timeout=15, context=CTX) as r:
                return json.loads(r.read())
        except Exception as e:
            if attempt < retries:
                time.sleep(1)
                continue
            return {"error": f"{type(e).__name__}: {str(e)[:120]}"}


CORP_SUFFIXES = {'INC', 'INCORPORATED', 'LLC', 'CORP', 'CORPORATION', 'COMPANY', 'CO', 'LTD', 'LP', 'PC', 'PLLC'}


def normalize(name: str) -> str:
    """Uppercase, strip punctuation, split into words, drop trailing corp suffixes."""
    n = name.upper().replace('.', ' ').replace(',', ' ').replace('-', ' ').replace("'", '').replace('&', ' AND ')
    words = n.split()
    # Drop trailing corp suffixes only (not embedded — fixes 'CONSTRUCTION' → 'NSTRUCTION' bug)
    while words and words[-1] in CORP_SUFFIXES:
        words.pop()
    return ' '.join(words)


def best_match(target_name: str, candidates: list, target_city=None, target_zip=None):
    """Return the candidate that best matches target name; prefer zip match if available."""
    target = normalize(target_name)
    target_words = set(target.split())
    best = None
    best_score = -1
    for c in candidates:
        cname = normalize(c.get('name', ''))
        cwords = set(cname.split())
        overlap = len(target_words & cwords)
        exact_bonus = 10 if cname == target else 0
        zip_bonus = 0
        if target_zip and c.get('mailingAddressZip') == target_zip:
            zip_bonus = 5
        score = overlap + exact_bonus + zip_bonus
        if score > best_score:
            best_score = score
            best = c
    return best, best_score


def is_likely_match(target: str, candidate: str, allow_subset: bool = True) -> bool:
    """Check if a candidate name is plausibly the SAME entity as the target.

    Avoids false positives like 'CHARLES HOWARD' matching 'CHARLES HOWARD DESIGN INC'.
    """
    t = normalize(target)
    c = normalize(candidate)
    t_tokens = t.split()
    c_tokens = c.split()

    for tok in t_tokens:
        if tok not in c_tokens:
            return False

    extras = len(c_tokens) - len(t_tokens)
    if extras <= 1:
        return True

    extra_tokens = [tk for tk in c_tokens if tk not in t_tokens]
    corp_words = {'INC', 'LLC', 'CORP', 'CORPORATION', 'COMPANY', 'LTD', 'LP', 'PC', 'PLLC'}
    if all(e in corp_words for e in extra_tokens):
        return True

    return False


def is_sole_proprietor_name(legal_name: str) -> bool:
    """Heuristic: is this a person's name vs a corporation?"""
    n = legal_name.upper()
    corp_markers = ['INC', 'LLC', 'CORP', 'CORPORATION', 'COMPANY', 'LTD', 'LP', 'PC', 'PLLC',
                    'SERVICES', 'SERVICE', 'CONTROL', 'EXTERMINATING', 'PEST']
    return not any(m in n.split() for m in corp_markers)


def words_compatible(target_words: list, candidate_words: list) -> bool:
    """Each target word must match a candidate word by exact OR prefix (≥4 chars) OR shared prefix.

    Allow 1 unmatched word for noise tolerance.
    """
    candidate_set = set(candidate_words)
    matched = 0
    for tw in target_words:
        if tw in candidate_set:
            matched += 1
            continue
        if len(tw) >= 4 and any(cw.startswith(tw[:4]) and (cw.startswith(tw) or tw.startswith(cw[:4])) for cw in candidate_words):
            matched += 1
            continue
    return matched >= len(target_words) - 1 and matched >= 2


# ---------------------------------------------------------------------------
# Pure per-business lookup — importable by tests without I/O side effects.
# Callers are responsible for cache-check and cache-write.
# ---------------------------------------------------------------------------

def _lookup_one(business: dict) -> dict:
    """Look up one business via the TX Comptroller JSON API.

    Takes a target dict (from load_targets); returns a payload dict with the
    standard Comptroller result schema.  NO cache I/O — pure network function.
    Designed to be importable and mockable in tests.

    Required keys in business: tpcl, legal_name.
    Optional: business_name_used, zip.
    """
    legal = business['legal_name']
    business_name = business.get('business_name_used') or ''
    tpcl = business['tpcl']
    target_zip = business.get('zip')

    is_sole = is_sole_proprietor_name(legal)

    today = date.today()
    result = {
        "tpcl": tpcl,
        "portal": PORTAL,
        "legal_name": legal,
        "business_name": business_name,
        "is_sole_prop_estimated": is_sole,
        "search_attempts": [],
        "fetched_at": datetime.now(timezone.utc).isoformat(),
        "fresh_until": {
            "status": (today + timedelta(days=_STATUS_TTL_DAYS)).isoformat(),
        },
        "errors": [],
    }

    queries = []
    if is_sole and business_name:
        queries = [business_name, legal]
    elif business_name and business_name.upper() != legal.upper():
        queries = [legal, business_name]
    else:
        queries = [legal]

    candidates = []
    near_matches = []
    matched_query = None
    NOISE_WORDS = {'INC', 'LLC', 'CORP', 'CORPORATION', 'COMPANY', 'LTD', 'LP', 'PC', 'PLLC', 'THE', 'SERVICES', 'SERVICE'}

    for q in queries:
        url = f"{API_SEARCH}?name={urllib.parse.quote(q)}"
        r = _get_json(url)
        result["search_attempts"].append({"name": q, "count": r.get('count', 0)})
        if r.get('error'):
            result["errors"].append(r['error'])
            result["status"] = "error"
            result["raw_term"] = q
            result["owner_match"] = None
            return result
        these_candidates = r.get('data', [])
        candidates = these_candidates

        target_norm = normalize(q)
        target_words = [w for w in target_norm.split() if w not in NOISE_WORDS]
        if not target_words:
            continue

        for c in these_candidates:
            cnorm = normalize(c.get('name', ''))
            cwords = cnorm.split()
            cwords_no_noise = [w for w in cwords if w not in NOISE_WORDS]
            if words_compatible(target_words, cwords_no_noise):
                cwords_set = set(cwords_no_noise)
                tw_set = set(target_words)
                extras = cwords_set - tw_set
                real_extras = set()
                for e in extras:
                    if not any(tw.startswith(e[:4]) or e.startswith(tw[:4]) for tw in tw_set if len(tw) >= 4):
                        real_extras.add(e)
                max_extras = 0 if is_sole else 1
                if len(real_extras) <= max_extras:
                    near_matches.append(c)

        if near_matches:
            matched_query = q
            break

    result["matched_query"] = matched_query
    result["raw_term"] = matched_query or (queries[0] if queries else None)

    if not near_matches:
        result["status"] = "not_found"
        result["owner_match"] = None
        result["candidates_count"] = len(candidates)
        if candidates:
            result["loose_candidates"] = [c.get('name') for c in candidates[:5]]
        result["interpretation"] = (
            "Sole proprietor or unregistered — no franchise tax entity" if is_sole
            else "Corp name not found in Comptroller — possible unregistered, dissolved, or out-of-state"
        )
        return result

    best = near_matches[0]
    for c in near_matches:
        if target_zip and c.get('mailingAddressZip') == target_zip:
            best = c
            break

    result["owner_match"] = {
        "entity_name": best['name'],
        "taxpayer_id": best['taxpayerId'],
    }
    result["entity_name_matched"] = best['name']
    result["taxpayer_id"] = best['taxpayerId']
    result["candidates_count"] = len(candidates)
    result["near_matches_count"] = len(near_matches)

    # Fetch full detail
    detail_url = f"{API_SEARCH}/{best['taxpayerId']}"
    detail = _get_json(detail_url)
    if detail.get('error'):
        result["errors"].append(detail['error'])
        result["status"] = "detail_error"
        return result

    d = detail.get('data', {})
    result["status"] = d.get('rightToTransactTX', 'unknown')
    result["sos_status"] = d.get('sosRegistrationStatus')
    result["sos_file_number"] = d.get('sosFileNumber')
    result["sos_registration_date"] = d.get('effectiveSosRegistrationDate')
    result["registered_agent_name"] = d.get('registeredAgentName')
    result["registered_agent_street"] = d.get('registeredAgentStreet')
    result["registered_agent_city"] = d.get('registeredAgentCity')
    result["registered_agent_state"] = d.get('registeredAgentState')
    result["registered_agent_zip"] = d.get('registeredAgentZip')
    result["mailing_address_street"] = d.get('mailingAddressStreet')
    result["mailing_address_city"] = d.get('mailingAddressCity')
    result["mailing_address_zip"] = d.get('mailingAddressZip')
    result["state_of_formation"] = d.get('stateOfFormation')
    result["dba_name"] = d.get('dbaName')
    return result


# ---------------------------------------------------------------------------
# Main — with CLI matching the other CAD scraper conventions
# ---------------------------------------------------------------------------

def main() -> None:
    parser = argparse.ArgumentParser(description="TX Comptroller franchise-tax scraper")
    parser.add_argument(
        "--vertical", default="pest-control",
        help="Target vertical (matches offmarket/data/{vertical}_targets.json)"
    )
    parser.add_argument(
        "--limit", type=int, default=None,
        help="Cap number of businesses processed (for testing)"
    )
    parser.add_argument(
        "--force-refresh", action="store_true",
        help="Ignore cache and re-fetch all records"
    )
    parser.add_argument(
        "--save-fixture", metavar="TPCL", default=None,
        help="(Unused for Comptroller — HTTP-only, no HTML fixtures needed)"
    )
    args = parser.parse_args()

    log = log_factory(PORTAL)

    try:
        targets = load_targets(args.vertical)
    except FileNotFoundError as e:
        log(f"ERROR: {e}")
        sys.exit(1)

    if args.limit:
        targets = targets[: args.limit]

    log(f"Loaded {len(targets)} {args.vertical} targets")

    results: dict[str, dict] = {}
    cached_hits = 0
    errors = 0

    def _process_one(biz: dict) -> dict:
        tpcl = biz['tpcl']
        if not args.force_refresh:
            cached = load_cached(PORTAL, tpcl, fresh_until_map=_FRESH_UNTIL_MAP)
            if cached is not None:
                return cached
        try:
            r = _lookup_one(biz)
        except Exception as e:
            r = {
                "tpcl": tpcl,
                "portal": PORTAL,
                "legal_name": biz.get('legal_name', ''),
                "status": "error",
                "errors": [f"{type(e).__name__}: {str(e)[:120]}"],
                "fetched_at": datetime.now(timezone.utc).isoformat(),
                "raw_term": None,
                "owner_match": None,
                "fresh_until": {
                    "status": (date.today() + timedelta(days=_STATUS_TTL_DAYS)).isoformat(),
                },
            }
        write_cached(PORTAL, tpcl, r)
        return r

    with ThreadPoolExecutor(max_workers=8) as ex:
        futures = {ex.submit(_process_one, b): b for b in targets}
        for i, fut in enumerate(as_completed(futures), 1):
            b = futures[fut]
            try:
                r = fut.result()
            except Exception as e:
                r = {
                    "tpcl": b['tpcl'], "portal": PORTAL,
                    "legal_name": b.get('legal_name', ''),
                    "status": "error",
                    "errors": [f"{type(e).__name__}: {str(e)[:120]}"],
                    "fetched_at": datetime.now(timezone.utc).isoformat(),
                    "raw_term": None, "owner_match": None,
                    "fresh_until": {"status": (date.today() + timedelta(days=_STATUS_TTL_DAYS)).isoformat()},
                }
            results[r['tpcl']] = r
            is_hit = r.get('_cache_hit', False)
            if is_hit:
                cached_hits += 1
            status = r.get('status', '?')
            if status == 'error':
                errors += 1
            matched = r.get('entity_name_matched', '') or ''
            log(f"[{i}/{len(targets)}] {b.get('legal_name','')[:30]:32s} → {status:20s} | {matched[:40]}")

    summary(results, log)

    # Write run manifest
    _CACHE_ROOT = Path(__file__).resolve().parent.parent / "cache"
    manifest_dir = _CACHE_ROOT / PORTAL
    manifest_dir.mkdir(parents=True, exist_ok=True)
    today_str = date.today().isoformat()
    manifest_path = manifest_dir / f"_manifest_{args.vertical}_{today_str}.json"
    manifest = {
        "vertical": args.vertical,
        "run_date": datetime.now(timezone.utc).isoformat(),
        "total": len(results),
        "cached_hits": cached_hits,
        "errors": errors,
        "pass": len([r for r in results.values() if r.get("status") not in ("error", "not_found")]),
        "not_found": len([r for r in results.values() if r.get("status") == "not_found"]),
    }
    tmp = manifest_path.with_suffix(".json.tmp")
    with tmp.open("w", encoding="utf-8") as fh:
        json.dump(manifest, fh, indent=2)
    import os
    os.replace(tmp, manifest_path)
    log(f"Manifest written → {manifest_path}")


if __name__ == '__main__':
    main()
