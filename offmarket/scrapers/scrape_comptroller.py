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
import os
import re
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
    cache_key,
    entity_key,
    load_cached,
    load_targets,
    log_factory,
    summary,
    write_cached,
)

PORTAL = "comptroller"
API_SEARCH = "https://comptroller.texas.gov/data-search/franchise-tax"
# PIR officer / director list is only exposed on the HTML account-status page,
# not the JSON API (discovered 2026-05-15 deep-dive — Whitaker Insurance et al).
HTML_ACCOUNT_STATUS = "https://comptroller.texas.gov/taxes/franchise/account-status/search/{taxpayerId}"
HEADERS = {'User-Agent': 'Mozilla/5.0 (Macintosh) Chrome/120.0.0.0', 'Accept': 'application/json'}
HTML_HEADERS = {'User-Agent': 'Mozilla/5.0 (Macintosh) Chrome/120.0.0.0', 'Accept': 'text/html,*/*'}
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


def _get_html(url: str, retries: int = 2) -> str | None:
    """Fetch raw HTML from a Comptroller page. Returns None on persistent failure."""
    for attempt in range(retries + 1):
        try:
            req = urllib.request.Request(url, headers=HTML_HEADERS)
            with urllib.request.urlopen(req, timeout=15, context=CTX) as r:
                body = r.read()
                if isinstance(body, bytes):
                    return body.decode("utf-8", errors="replace")
                return body
        except Exception:
            if attempt < retries:
                time.sleep(1)
                continue
            return None
    return None


# ---------------------------------------------------------------------------
# PIR officer parsing — Finding 1, 2026-05-15 deep-dive
# ---------------------------------------------------------------------------
# The JSON API only returns the registered-agent record. The Public Information
# Report (PIR) officer list — names + titles + addresses of directors/principals —
# lives only on the HTML account-status page. Parsing this gives us Finding 5
# data: cross-check the JSON owner_name against the actual equity-holding officers,
# and Finding 4 data: detect when ≥2 co-Directors live at DIFFERENT residences
# (indicating an internal buyout structure vs single-founder exit).

# Compile once; use re module functions throughout (no BeautifulSoup dep).
_PIR_YEAR_PATTERNS = [
    re.compile(r'Public\s+Information\s+Report\s*\(?\s*(\d{4})\s*\)?', re.I),
    re.compile(r'PIR[^\d]{0,20}(\d{4})', re.I),
]

# Officer rows on the Comptroller account-status page render as:
#   <tr><td>PRESIDENT</td><td>CHESTER D WHITAKER</td><td>8626 TESORO DRIVE STE 310...</td></tr>
# Titles seen in the wild include: PRESIDENT, VICE PRESIDENT, VP, SECRETARY,
# TREASURER, DIRECTOR, MANAGER, MEMBER, PARTNER, OFFICER, AGENT, CEO, COO, CFO.
_OFFICER_TITLE_PATTERN = re.compile(
    r'\b(?:PRESIDENT|VICE\s+PRESIDENT|VP|SECRETARY|TREASURER|DIRECTOR|'
    r'MANAGER|MANAGING\s+MEMBER|MEMBER|PARTNER|MANAGING\s+PARTNER|'
    r'OFFICER|AGENT|CEO|COO|CFO|CHIEF\s+EXECUTIVE\s+OFFICER|'
    r'CHIEF\s+OPERATING\s+OFFICER|CHIEF\s+FINANCIAL\s+OFFICER|'
    r'EXECUTIVE\s+DIRECTOR|GENERAL\s+PARTNER|LIMITED\s+PARTNER|'
    r'TRUSTEE|OWNER|PRINCIPAL)\b',
    re.I,
)

_OFFICER_ROW_PATTERN = re.compile(
    r'<tr[^>]*>\s*'
    r'<t[dh][^>]*>([^<]+)</t[dh]>\s*'
    r'<t[dh][^>]*>([^<]+)</t[dh]>\s*'
    r'<t[dh][^>]*>([^<]+)</t[dh]>\s*'
    r'</tr>',
    re.I | re.S,
)


def _clean_cell(s: str) -> str:
    """Strip HTML entities and whitespace from a cell value."""
    if not s:
        return ""
    s = re.sub(r'&nbsp;', ' ', s)
    s = re.sub(r'&amp;', '&', s)
    s = re.sub(r'&#39;|&apos;', "'", s)
    s = re.sub(r'&quot;', '"', s)
    s = re.sub(r'<[^>]+>', '', s)
    return s.strip()


def parse_pir_html(html: str) -> dict:
    """Parse Comptroller account-status HTML → {pir_year, officers}.

    Returns:
      pir_year       — int | None
      officers       — list of {title, name, address} dicts. Empty if no officers section.

    Pure function — no I/O. Caller passes HTML body; this returns structured data.
    Designed to be testable with HTML fixtures.
    """
    out = {"pir_year": None, "officers": []}
    if not html:
        return out

    # PIR year detection
    for pat in _PIR_YEAR_PATTERNS:
        m = pat.search(html)
        if m:
            try:
                out["pir_year"] = int(m.group(1))
                break
            except (ValueError, IndexError):
                continue

    # Officer rows — naive 3-column <tr> match.
    # Filter to rows where col1 contains a known officer title.
    for m in _OFFICER_ROW_PATTERN.finditer(html):
        c1 = _clean_cell(m.group(1))
        c2 = _clean_cell(m.group(2))
        c3 = _clean_cell(m.group(3))
        if not (c1 and c2):
            continue
        if not _OFFICER_TITLE_PATTERN.search(c1):
            continue
        # Strip extra commas/whitespace from address
        address = re.sub(r'\s+', ' ', c3) if c3 else None
        out["officers"].append({
            "title": c1.upper(),
            "name": c2.upper(),
            "address": address or None,
        })
    return out


def fetch_pir(taxpayer_id: str) -> dict:
    """Fetch + parse PIR officers from the Comptroller HTML page.

    Returns {pir_year, officers, fetch_error}. fetch_error is None on success.
    """
    if not taxpayer_id:
        return {"pir_year": None, "officers": [], "fetch_error": "no_taxpayer_id"}
    url = HTML_ACCOUNT_STATUS.format(taxpayerId=taxpayer_id)
    html = _get_html(url)
    if html is None:
        return {"pir_year": None, "officers": [], "fetch_error": "html_fetch_failed"}
    parsed = parse_pir_html(html)
    parsed["fetch_error"] = None
    parsed["pir_html_url"] = url
    return parsed


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

def _lookup_one(business: dict, vertical: str = "pest-control") -> dict:
    """Look up one business via the TX Comptroller JSON API.

    Takes a target dict (from load_targets); returns a payload dict with the
    standard Comptroller result schema.  NO cache I/O — pure network function.
    Designed to be importable and mockable in tests.
    """
    legal = business['legal_name']
    business_name = business.get('business_name_used') or ''
    eid = entity_key(business, vertical)
    ckey = cache_key(business, vertical)
    target_zip = business.get('zip')

    is_sole = is_sole_proprietor_name(legal)

    today = date.today()
    result = {
        "entity_id": eid,
        "cache_key": ckey,
        "tpcl": business.get('tpcl'),
        "license_number": business.get('license_number'),
        "portal": PORTAL,
        "vertical": vertical,
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

    # PIR officer list — only available on the HTML account-status page.
    # Finding 1 (2026-05-15 deep-dive): registered_agent ≈ owner only ~40% of
    # the time. The PIR officer list is the ground truth on who actually controls
    # the entity (Fire Safe / Burianek case, Perdue / Cloud family case).
    pir = fetch_pir(best['taxpayerId'])
    result["pir_year"] = pir.get("pir_year")
    result["pir_officers"] = pir.get("officers", [])
    result["pir_html_url"] = pir.get("pir_html_url")
    if pir.get("fetch_error"):
        result.setdefault("errors", []).append(f"pir_fetch: {pir['fetch_error']}")
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
        eid = entity_key(biz, args.vertical)
        ckey = cache_key(biz, args.vertical)
        if not args.force_refresh:
            cached = load_cached(PORTAL, ckey, fresh_until_map=_FRESH_UNTIL_MAP)
            if cached is not None:
                return {**cached, "_cache_hit": True}
        try:
            r = _lookup_one(biz, args.vertical)
        except Exception as e:
            r = {
                "entity_id": eid,
                "cache_key": ckey,
                "tpcl": biz.get('tpcl'),
                "license_number": biz.get('license_number'),
                "portal": PORTAL,
                "vertical": args.vertical,
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
        write_cached(PORTAL, ckey, r)
        return r

    with ThreadPoolExecutor(max_workers=8) as ex:
        futures = {ex.submit(_process_one, b): b for b in targets}
        for i, fut in enumerate(as_completed(futures), 1):
            b = futures[fut]
            try:
                r = fut.result()
            except Exception as e:
                r = {
                    "entity_id": entity_key(b, args.vertical),
                    "cache_key": cache_key(b, args.vertical),
                    "tpcl": b.get('tpcl'),
                    "license_number": b.get('license_number'),
                    "portal": PORTAL,
                    "vertical": args.vertical,
                    "legal_name": b.get('legal_name', ''),
                    "status": "error",
                    "errors": [f"{type(e).__name__}: {str(e)[:120]}"],
                    "fetched_at": datetime.now(timezone.utc).isoformat(),
                    "raw_term": None, "owner_match": None,
                    "fresh_until": {"status": (date.today() + timedelta(days=_STATUS_TTL_DAYS)).isoformat()},
                }
            results[r['entity_id']] = r
            if r.get('_cache_hit'):
                cached_hits += 1
            status = r.get('status', '?')
            if status == 'error':
                errors += 1
            matched = r.get('entity_name_matched', '') or ''
            log(f"[{i}/{len(targets)}] {b.get('legal_name','')[:30]:32s} → {status:20s} | {matched[:40]}")

    summary(results, log)

    # Write run manifest via cad_common.write_cached (same atomic-write idiom)
    today_str = date.today().isoformat()
    manifest_key = f"_manifest_{args.vertical}_{today_str}"
    manifest = {
        "vertical": args.vertical,
        "run_date": datetime.now(timezone.utc).isoformat(),
        "total": len(results),
        "cached_hits": cached_hits,
        "errors": errors,
        "pass": len([r for r in results.values() if r.get("status") not in ("error", "not_found")]),
        "not_found": len([r for r in results.values() if r.get("status") == "not_found"]),
    }
    write_cached(PORTAL, manifest_key, manifest)
    log(f"Manifest written → cache/{PORTAL}/{manifest_key}.json")


if __name__ == '__main__':
    main()
