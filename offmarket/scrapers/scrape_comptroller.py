#!/usr/bin/env python3
"""TX Comptroller Taxable Entity Search via direct JSON API.

API endpoints (discovered via XHR trace):
  GET https://comptroller.texas.gov/data-search/franchise-tax?name=<NAME>
      → {success, data: [{name, taxpayerId, mailingAddressZip}], count}
  GET https://comptroller.texas.gov/data-search/franchise-tax/<taxpayerId>
      → {success, data: {rightToTransactTX, sosRegistrationStatus, ...full record}}

Writes /tmp/pestrun_results/comptroller_results.json keyed by tpcl.
"""
import json
import sys
import urllib.parse
import urllib.request
import ssl
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from datetime import datetime, timezone
from pathlib import Path

TARGETS = Path('/Users/gideonspencer/dealhound-pro/offmarket/data/pest-control_targets.json')
OUT = Path('/tmp/pestrun_results/comptroller_results.json')
LOG = Path('/tmp/pestrun_results/comptroller.log')

API_SEARCH = "https://comptroller.texas.gov/data-search/franchise-tax"
HEADERS = {'User-Agent': 'Mozilla/5.0 (Macintosh) Chrome/120.0.0.0', 'Accept': 'application/json'}
CTX = ssl.create_default_context()

def log(msg):
    ts = datetime.now(timezone.utc).strftime('%H:%M:%S')
    line = f"[{ts}] {msg}"
    print(line, flush=True)
    with open(LOG, 'a') as f:
        f.write(line + '\n')

def get_json(url, retries=2):
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

def normalize(name):
    """Uppercase, strip punctuation, split into words, drop trailing corp suffixes."""
    n = name.upper().replace('.', ' ').replace(',', ' ').replace('-', ' ').replace("'", '').replace('&', ' AND ')
    words = n.split()
    # Drop trailing corp suffixes only (not embedded — fixes 'CONSTRUCTION' → 'NSTRUCTION' bug)
    while words and words[-1] in CORP_SUFFIXES:
        words.pop()
    return ' '.join(words)

def best_match(target_name, candidates, target_city=None, target_zip=None):
    """Return the candidate that best matches target name; prefer zip match if available."""
    target = normalize(target_name)
    target_words = set(target.split())
    best = None
    best_score = -1
    for c in candidates:
        cname = normalize(c.get('name', ''))
        cwords = set(cname.split())
        # word overlap
        overlap = len(target_words & cwords)
        # exact match bonus
        exact_bonus = 10 if cname == target else 0
        # zip bonus
        zip_bonus = 0
        if target_zip and c.get('mailingAddressZip') == target_zip:
            zip_bonus = 5
        score = overlap + exact_bonus + zip_bonus
        if score > best_score:
            best_score = score
            best = c
    return best, best_score

def is_likely_match(target, candidate, allow_subset=True):
    """Check if a candidate name is plausibly the SAME entity as the target.

    Avoids false positives like 'CHARLES HOWARD' matching 'CHARLES HOWARD DESIGN INC'.
    Rule: candidate must contain ALL target name-tokens AND either be ≤3 extra tokens
    OR contain a corporate suffix (INC/LLC/CORP) showing it's incorporated under that name."""
    t = normalize(target)
    c = normalize(candidate)
    t_tokens = t.split()
    c_tokens = c.split()

    # Must contain all target tokens
    for tok in t_tokens:
        if tok not in c_tokens:
            return False

    extras = len(c_tokens) - len(t_tokens)
    if extras <= 1:
        return True

    # If the extras add a corp suffix only, accept
    extra_tokens = [t for t in c_tokens if t not in t_tokens]
    corp_words = {'INC', 'LLC', 'CORP', 'CORPORATION', 'COMPANY', 'LTD', 'LP', 'PC', 'PLLC'}
    if all(e in corp_words for e in extra_tokens):
        return True

    # Otherwise: if "DBA"-style extra words like "DESIGN", "REMODELING" — reject as different business
    return False

def is_sole_proprietor_name(legal_name):
    """Heuristic: is this a person's name vs a corporation?"""
    n = legal_name.upper()
    corp_markers = ['INC', 'LLC', 'CORP', 'CORPORATION', 'COMPANY', 'LTD', 'LP', 'PC', 'PLLC', 'SERVICES', 'SERVICE', 'CONTROL', 'EXTERMINATING', 'PEST']
    return not any(m in n.split() for m in corp_markers)

def words_compatible(target_words, candidate_words):
    """Each target word must match a candidate word by exact OR prefix (≥4 chars) OR shared prefix.

    Examples that should match:
      target 'EXTERM'  ↔  candidate 'EXTERMINATORS'  (target is prefix of candidate)
      target 'MGMT'    ↔  candidate 'MANAGEMENT'      (4-char prefix shared)
      target 'SYSTEM'  with no SYSTEM in candidate    → drop SYSTEM if other words match
    """
    candidate_set = set(candidate_words)
    matched = 0
    for tw in target_words:
        if tw in candidate_set:
            matched += 1
            continue
        # Try prefix match in either direction (need at least 4 char prefix)
        if len(tw) >= 4 and any(cw.startswith(tw[:4]) and (cw.startswith(tw) or tw.startswith(cw[:4])) for cw in candidate_words):
            matched += 1
            continue
    # Allow 1 unmatched word for noise tolerance (e.g., SYSTEM, INC)
    return matched >= len(target_words) - 1 and matched >= 2

def lookup_one(biz):
    """Lookup one business; returns dict.

    Strategy (conservative — avoid false positives):
    - If legal_name has corp markers (INC/LLC): search by legal_name only. Match must be near-exact.
    - If legal_name is a person's name (sole prop): search by business_name (DBA). Match must be near-exact.
    - "Not Found" is fine — sole proprietors usually have no franchise tax entity.
    """
    legal = biz['legal_name']
    business_name = biz.get('business_name_used') or ''
    tpcl = biz['tpcl']
    target_zip = biz.get('zip')

    is_sole = is_sole_proprietor_name(legal)

    result = {
        "legal_name": legal,
        "business_name": business_name,
        "tpcl": tpcl,
        "is_sole_prop_estimated": is_sole,
        "search_attempts": [],
        "fetched_at": datetime.now(timezone.utc).isoformat(),
    }

    # Try queries in order: business_name first if sole prop, else legal_name first.
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
    NOISE_WORDS = {'INC','LLC','CORP','CORPORATION','COMPANY','LTD','LP','PC','PLLC','THE','SERVICES','SERVICE'}

    for q in queries:
        url = f"{API_SEARCH}?name={urllib.parse.quote(q)}"
        r = get_json(url)
        result["search_attempts"].append({"name": q, "count": r.get('count', 0)})
        if r.get('error'):
            result["error"] = r['error']
            result["comptroller_status"] = "Error"
            return result
        these_candidates = r.get('data', [])
        candidates = these_candidates  # keep last set for diagnostics

        target_norm = normalize(q)
        target_words = [w for w in target_norm.split() if w not in NOISE_WORDS]
        if not target_words:
            continue

        for c in these_candidates:
            cnorm = normalize(c.get('name', ''))
            cwords = cnorm.split()
            cwords_no_noise = [w for w in cwords if w not in NOISE_WORDS]
            # Use prefix-tolerant word matching, ignoring noise words on both sides
            if words_compatible(target_words, cwords_no_noise):
                # And reject if candidate has extra non-noise content beyond reasonable variance
                cwords_set = set(cwords_no_noise)
                tw_set = set(target_words)
                extras = cwords_set - tw_set
                # Filter extras using same prefix-match logic — any extra that prefix-matches a target word doesn't count
                real_extras = set()
                for e in extras:
                    if not any(tw.startswith(e[:4]) or e.startswith(tw[:4]) for tw in tw_set if len(tw) >= 4):
                        real_extras.add(e)
                # For sole-prop searches, require ZERO real extras (avoid 'CHARLES HOWARD' matching 'CHARLES HOWARD DESIGN INC')
                # For corp searches, allow 1 real extra (e.g., a regional qualifier)
                max_extras = 0 if is_sole else 1
                if len(real_extras) <= max_extras:
                    near_matches.append(c)

        if near_matches:
            matched_query = q
            break

    result["matched_query"] = matched_query

    if not near_matches:
        result["comptroller_status"] = "Not Found"
        result["entity_name_matched"] = None
        result["candidates_count"] = len(candidates)
        if candidates:
            result["loose_candidates"] = [c.get('name') for c in candidates[:5]]
        result["interpretation"] = (
            "Sole proprietor or unregistered — no franchise tax entity" if is_sole
            else "Corp name not found in Comptroller — possible unregistered, dissolved, or out-of-state"
        )
        return result

    # Pick best match — prefer zip match
    best = near_matches[0]
    for c in near_matches:
        if target_zip and c.get('mailingAddressZip') == target_zip:
            best = c
            break

    result["entity_name_matched"] = best['name']
    result["taxpayer_id"] = best['taxpayerId']
    result["candidates_count"] = len(candidates)
    result["near_matches_count"] = len(near_matches)

    # Step 3: get full detail
    detail_url = f"{API_SEARCH}/{best['taxpayerId']}"
    detail = get_json(detail_url)
    if detail.get('error'):
        result["error"] = detail['error']
        return result

    d = detail.get('data', {})
    result["comptroller_status"] = d.get('rightToTransactTX', 'Unknown')
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


def main():
    OUT.parent.mkdir(parents=True, exist_ok=True)
    LOG.unlink(missing_ok=True)

    with open(TARGETS) as f:
        data = json.load(f)
    businesses = data['businesses']
    log(f"Loaded {len(businesses)} businesses")

    results = {}
    with ThreadPoolExecutor(max_workers=8) as ex:
        futures = {ex.submit(lookup_one, b): b for b in businesses}
        for i, fut in enumerate(as_completed(futures), 1):
            b = futures[fut]
            try:
                r = fut.result()
            except Exception as e:
                r = {"legal_name": b['legal_name'], "tpcl": b['tpcl'],
                     "comptroller_status": "Error", "error": f"{type(e).__name__}: {str(e)[:120]}"}
            results[r['tpcl']] = r
            status = r.get('comptroller_status', '?')
            matched = r.get('entity_name_matched', '') or ''
            log(f"[{i}/{len(businesses)}] {b['legal_name'][:30]:32s} → {status:12s} | {matched[:50]}")

    with open(OUT, 'w') as f:
        json.dump(results, f, indent=2)

    # Summary
    summary = {}
    for r in results.values():
        s = r.get('comptroller_status', '?')
        summary[s] = summary.get(s, 0) + 1
    log(f"\nSUMMARY: {summary}")
    log(f"Wrote {len(results)} results to {OUT}")


if __name__ == '__main__':
    main()
