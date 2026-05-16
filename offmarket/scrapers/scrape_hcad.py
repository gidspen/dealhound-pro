#!/usr/bin/env python3
"""HCAD (Harris County) owner search → OV65 + homestead + deed date.

Path chosen: Playwright (sync API), 2 browser contexts.

Recon findings (2026-05-15):
  search.hcad.org → Cloudflare managed challenge (cType:'managed').
  Raw curl returns "Just a moment..." JS challenge page — no HTML content.
  api.hcad.org backend resolves (198.46.75.13) and accepts POST to
  /RealProperty/search, but returns HTTP 401 without a Cloudflare-issued
  session token. The auth token is only obtainable after the JS challenge
  executes in a real browser context.
  XHR-direct (HTTP) path: BLOCKED. Playwright path: required.

Flow per REPORT-pest-tx-2026-Q2-v2.md §7:
  - Navigate search.hcad.org (Cloudflare passes after ~5s in real Chromium)
  - Click #OWNERNAME radio button
  - Fill search input with owner last name
  - Submit form
  - Parse result rows → pick best match → navigate to detail page
  - Extract exemptions via cad_common.extract_exemptions

Cross-county: on no match in Harris, emit cross_county_followup list
  (Fort Bend, Montgomery, Brazoria). Do NOT query those CADs here.
"""
import argparse
import sys
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from datetime import date, datetime, timezone, timedelta
from pathlib import Path

from playwright.sync_api import sync_playwright, TimeoutError as PWTimeout

from offmarket.scrapers.cad_common import (
    cache_key,
    entity_key,
    extract_exemptions,
    is_cloudflare_challenge,
    load_cached,
    load_targets,
    log_factory,
    name_variants,
    summary,
    write_cached,
)

PORTAL = "hcad"
BASE_URL = "https://search.hcad.org"
CROSS_COUNTY_COUNTIES = ["Fort Bend", "Montgomery", "Brazoria"]

# Re-export for tests + symmetry with BCAD
_is_cloudflare_challenge = is_cloudflare_challenge


def _cross_county_followup(reason: str = "no_match_in_primary") -> dict:
    return {"counties": CROSS_COUNTY_COUNTIES, "reason": reason}

FRESH_UNTIL_MAP = {"ov65": "any", "deed_date": "any"}

FIXTURE_DIR = Path(__file__).parent / "tests" / "fixtures" / "hcad"


# ---------------------------------------------------------------------------
# Pure parse functions — no network / Playwright dependency
# ---------------------------------------------------------------------------

def _parse_results(html: str) -> list[dict]:
    """Parse HCAD search results page → list of {account, owner_name, address, detail_url}.

    Handles both the React SPA rendered DOM (result-item li / div structure)
    and a fallback table-row pattern in case the SPA renders differently.
    """
    from html.parser import HTMLParser

    rows: list[dict] = []

    class _Parser(HTMLParser):
        def __init__(self):
            super().__init__()
            self._in_item = False
            self._current: dict = {}
            self._current_class = ""
            self._capture = ""
            self._depth = 0
            self._item_depth = 0

        def handle_starttag(self, tag, attrs):
            attr_dict = dict(attrs)
            cls = attr_dict.get("class", "")
            self._depth += 1
            if tag in ("li", "div") and "result-item" in cls:
                self._in_item = True
                self._current = {
                    "account": attr_dict.get("data-account", ""),
                    "owner_name": "",
                    "address": "",
                    "detail_url": "",
                }
                self._item_depth = self._depth
            if self._in_item:
                if tag == "a":
                    href = attr_dict.get("href", "")
                    if "/Details/" in href or "/detail/" in href.lower():
                        self._current["detail_url"] = href
                if tag == "span":
                    self._current_class = cls
                    self._capture = ""

        def handle_endtag(self, tag):
            if self._in_item and tag == "span" and self._current_class:
                val = self._capture.strip()
                if "account-number" in self._current_class:
                    if not self._current["account"]:
                        self._current["account"] = val
                elif "owner-name" in self._current_class:
                    self._current["owner_name"] = val
                elif "situs-address" in self._current_class:
                    self._current["address"] = val
                self._current_class = ""
                self._capture = ""
            self._depth -= 1
            if self._in_item and self._depth < self._item_depth:
                self._in_item = False
                if self._current.get("account") or self._current.get("owner_name"):
                    rows.append(dict(self._current))
                self._current = {}

        def handle_data(self, data):
            if self._in_item and self._current_class:
                self._capture += data

    _Parser().feed(html)

    # Fallback: table row pattern (in case of non-React rendering)
    if not rows:
        rows = _parse_results_table(html)

    return rows


def _parse_results_table(html: str) -> list[dict]:
    """Fallback: extract rows from a simple <table> result structure."""
    import re
    rows: list[dict] = []
    # Find table rows with account-like content
    tr_pattern = re.compile(r'<tr[^>]*>(.*?)</tr>', re.S | re.I)
    td_pattern = re.compile(r'<td[^>]*>(.*?)</td>', re.S | re.I)
    a_pattern = re.compile(r'<a[^>]+href="([^"]*)"[^>]*>(.*?)</a>', re.S | re.I)
    tag_strip = re.compile(r'<[^>]+>')

    for tr_m in tr_pattern.finditer(html):
        tds = td_pattern.findall(tr_m.group(1))
        if len(tds) < 2:
            continue
        clean = [tag_strip.sub("", td).strip() for td in tds]
        a_m = a_pattern.search(tds[0]) if tds else None
        href = a_m.group(1) if a_m else ""
        # Account is in first cell
        account = clean[0]
        if not any(c.isdigit() for c in account):
            continue  # skip header rows
        rows.append({
            "account": account,
            "owner_name": clean[1] if len(clean) > 1 else "",
            "address": clean[2] if len(clean) > 2 else "",
            "detail_url": href,
        })
    return rows


def _parse_detail(html: str) -> dict:
    """Parse HCAD detail page → exemption dict from cad_common.extract_exemptions.

    Returns the extract_exemptions result dict plus raw owner_name and account
    pulled from the page.
    """
    import re
    tag_strip = re.compile(r'<[^>]+>')
    text = tag_strip.sub(" ", html)
    # Collapse whitespace
    text = re.sub(r'\s+', ' ', text).strip()

    result = extract_exemptions(text)

    # Pull owner name
    owner_m = re.search(r'owner[- ]?name[^>]*>\s*([A-Z][A-Z, \.]+)', html, re.I)
    result["owner_name"] = owner_m.group(1).strip() if owner_m else None

    # Pull account
    acct_m = re.search(r'data-account="(\d+)"', html)
    if not acct_m:
        acct_m = re.search(r'account[:\s]+(\d{10,})', text, re.I)
    result["account"] = acct_m.group(1).strip() if acct_m else None

    return result


# ---------------------------------------------------------------------------
# Browser-based lookup (Playwright)
# ---------------------------------------------------------------------------

def _search_owner(page, term: str, log) -> tuple[str, list[dict]]:
    """Navigate to HCAD, select owner-name mode, submit search. Returns (html, rows)."""
    try:
        page.goto(BASE_URL, wait_until="domcontentloaded", timeout=30000)
        # Cloudflare managed challenge — wait for it to resolve (real Chromium clears it)
        page.wait_for_load_state("networkidle", timeout=20000)
    except PWTimeout:
        log(f"  timeout loading {BASE_URL}")
        return "", []
    except Exception as e:
        log(f"  error loading base: {e}")
        return "", []

    try:
        # Select Owner Name radio
        page.click("#OWNERNAME", timeout=8000)
    except PWTimeout:
        # Try alternate selector patterns the SPA may use
        try:
            page.click("input[value='ownerName'], input[id*='owner'], label:has-text('Owner Name')", timeout=5000)
        except Exception:
            pass

    try:
        # Fill search input
        page.fill("input#searchInput, input[placeholder*='name'], input[type='search']", term, timeout=8000)
        page.keyboard.press("Enter")
        page.wait_for_load_state("networkidle", timeout=15000)
        time.sleep(0.5)  # politeness
    except PWTimeout:
        log(f"  timeout submitting search for '{term}'")
        return "", []
    except Exception as e:
        log(f"  error searching '{term}': {e}")
        return "", []

    html = page.content()
    rows = _parse_results(html)
    return html, rows


def _get_detail(page, detail_url: str, log) -> tuple[str, dict]:
    """Navigate to detail page; returns (html, parsed_dict)."""
    full_url = detail_url if detail_url.startswith("http") else f"{BASE_URL}{detail_url}"
    try:
        page.goto(full_url, wait_until="domcontentloaded", timeout=20000)
        page.wait_for_load_state("networkidle", timeout=15000)
        time.sleep(0.5)
    except PWTimeout:
        log(f"  timeout loading detail {full_url}")
        return "", {}
    except Exception as e:
        log(f"  error loading detail: {e}")
        return "", {}

    html = page.content()
    return html, _parse_detail(html)


def _pick_best_row(rows: list[dict], last: str, first: str | None) -> dict | None:
    """Return row whose owner_name best matches (last, first)."""
    last_up = last.upper()
    first_up = (first or "").upper()
    # Exact last-name match + first-name match
    for r in rows:
        name = r.get("owner_name", "").upper()
        if last_up in name and (not first_up or first_up in name):
            return r
    # Last name only
    for r in rows:
        if last_up in r.get("owner_name", "").upper():
            return r
    return rows[0] if rows else None


def lookup_one(biz: dict, page, log, save_fixture_tpcl: str | None = None,
               vertical: str = "pest-control") -> dict:
    """Look up one business; return enrichment payload dict."""
    eid = entity_key(biz, vertical)
    ckey = cache_key(biz, vertical)
    legal = biz.get("legal_name", "")
    owner = biz.get("owner_name") or legal

    result: dict = {
        "entity_id": eid,
        "cache_key": ckey,
        "tpcl": biz.get("tpcl"),
        "license_number": biz.get("license_number"),
        "portal": PORTAL,
        "vertical": vertical,
        "fetched_at": datetime.now(timezone.utc).isoformat(),
        "raw_term": None,
        "owner_match": None,
        "exemptions": {},
        "deed_date": None,
        "appraised_value": None,
        "year_built": None,
        "status": "pending",
        "errors": [],
    }

    today = date.today()
    result["fresh_until"] = {
        "ov65": (today + timedelta(days=90)).isoformat(),
        "homestead": (today + timedelta(days=90)).isoformat(),
        "disabled": (today + timedelta(days=90)).isoformat(),
        "deed_date": (today + timedelta(days=365)).isoformat(),
        "appraised_value": (today + timedelta(days=365)).isoformat(),
        "year_built": (today + timedelta(days=365)).isoformat(),
    }

    variants = name_variants(legal, owner)
    if not variants:
        result["status"] = "no_variants"
        result["errors"].append("no_name_variants_generated")
        write_cached(PORTAL, ckey, result)
        return result

    matched_rows: list[dict] = []
    matched_last: str = ""
    matched_first: str | None = None

    for last, first in variants:
        term = f"{last}, {first}" if first else last
        log(f"  searching '{term}'")
        html, rows = _search_owner(page, term, log)
        time.sleep(0.5)  # 500ms politeness between requests

        if save_fixture_tpcl and eid == save_fixture_tpcl and html:
            FIXTURE_DIR.mkdir(parents=True, exist_ok=True)
            (FIXTURE_DIR / "search_results_sample.html").write_text(html, encoding="utf-8")
            log(f"  saved search fixture for {eid}")

        if rows:
            matched_rows = rows
            matched_last = last
            matched_first = first
            result["raw_term"] = term
            break

    if not matched_rows:
        result["status"] = "no_match"
        result["cross_county_followup"] = _cross_county_followup()
        log(f"  no match in Harris → flagging cross_county_followup")
        write_cached(PORTAL, ckey, result)
        return result

    best = _pick_best_row(matched_rows, matched_last, matched_first)
    if not best:
        result["status"] = "no_match"
        result["cross_county_followup"] = _cross_county_followup()
        write_cached(PORTAL, ckey, result)
        return result

    result["owner_match"] = {
        "account": best.get("account"),
        "owner_name": best.get("owner_name"),
        "address": best.get("address"),
    }

    detail_url = best.get("detail_url")
    if not detail_url:
        result["status"] = "match_no_detail_link"
        write_cached(PORTAL, ckey, result)
        return result

    detail_html, detail = _get_detail(page, detail_url, log)

    if save_fixture_tpcl and eid == save_fixture_tpcl and detail_html:
        FIXTURE_DIR.mkdir(parents=True, exist_ok=True)
        (FIXTURE_DIR / "detail_sample.html").write_text(detail_html, encoding="utf-8")
        log(f"  saved detail fixture for {eid}")

    if not detail:
        result["status"] = "detail_parse_error"
        result["errors"].append("detail_parse_returned_empty")
        write_cached(PORTAL, ckey, result)
        return result

    result["exemptions"] = {
        "ov65": detail.get("ov65", False),
        "homestead": detail.get("homestead", False),
        "disabled": detail.get("disabled", False),
    }
    result["deed_date"] = detail.get("deed_date")
    result["appraised_value"] = detail.get("appraised_value")
    result["year_built"] = detail.get("year_built")
    result["status"] = "detail_fetched"
    write_cached(PORTAL, ckey, result)
    return result


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(description="HCAD owner search scraper")
    parser.add_argument("--vertical", default="pest-control",
                        help="Target vertical (matches offmarket/data/{vertical}_targets.json)")
    parser.add_argument("--limit", type=int, default=None, help="Process only N businesses")
    parser.add_argument("--force-refresh", action="store_true",
                        help="Ignore cache and re-fetch all records")
    parser.add_argument("--save-fixture", metavar="ENTITY_ID", default=None,
                        help="Save raw HTML fixtures for the given entity_id (TPCL/license)")
    args = parser.parse_args()

    log = log_factory(PORTAL)

    try:
        targets = load_targets(args.vertical, county_filter=["Harris"])
    except FileNotFoundError as e:
        log(f"ERROR: {e}")
        sys.exit(1)

    if args.limit:
        targets = targets[: args.limit]

    log(f"Loaded {len(targets)} Harris County targets for vertical={args.vertical}")

    results: dict[str, dict] = {}

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)

        # 2 browser contexts per PLAN §5
        contexts = [
            browser.new_context(
                user_agent="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
                viewport={"width": 1280, "height": 800},
            )
            for _ in range(2)
        ]
        pages = [ctx.new_page() for ctx in contexts]

        # Warm both contexts through Cloudflare before batching
        for i, pg in enumerate(pages):
            try:
                pg.goto(BASE_URL, wait_until="domcontentloaded", timeout=30000)
                pg.wait_for_load_state("networkidle", timeout=20000)
                log(f"Context {i} warmed up")
            except Exception as e:
                log(f"Context {i} warmup error: {e}")

        # Assign targets round-robin across 2 pages
        page_queues: list[list[dict]] = [[], []]
        for i, biz in enumerate(targets):
            page_queues[i % 2].append(biz)

        def _run_queue(queue: list[dict], pg, page_idx: int) -> list[dict]:
            out = []
            for biz in queue:
                eid = entity_key(biz, args.vertical)
                ckey = cache_key(biz, args.vertical)
                if not args.force_refresh:
                    cached = load_cached(PORTAL, ckey, fresh_until_map=FRESH_UNTIL_MAP)
                    if cached:
                        log(f"[ctx{page_idx}] {biz.get('legal_name','')[:30]:32s} → cache hit")
                        out.append({**cached, "_cache_hit": True})
                        continue
                try:
                    r = lookup_one(biz, pg, log, save_fixture_tpcl=args.save_fixture,
                                   vertical=args.vertical)
                except Exception as e:
                    r = {
                        "entity_id": eid,
                        "cache_key": ckey,
                        "tpcl": biz.get("tpcl"),
                        "license_number": biz.get("license_number"),
                        "portal": PORTAL,
                        "vertical": args.vertical,
                        "status": "error",
                        "errors": [f"{type(e).__name__}: {str(e)[:120]}"],
                        "fetched_at": datetime.now(timezone.utc).isoformat(),
                    }
                    write_cached(PORTAL, ckey, r)
                ov65 = r.get("exemptions", {}).get("ov65", "?")
                hs = r.get("exemptions", {}).get("homestead", "?")
                log(f"[ctx{page_idx}] {biz.get('legal_name','')[:30]:32s} → {r.get('status','?'):22s} OV65={ov65} HS={hs}")
                out.append(r)
            return out

        with ThreadPoolExecutor(max_workers=2) as ex:
            futures = [
                ex.submit(_run_queue, page_queues[i], pages[i], i)
                for i in range(2)
            ]
            all_lists = [f.result() for f in as_completed(futures)]

        for lst in all_lists:
            for r in lst:
                results[r["tpcl"]] = r

        for pg in pages:
            pg.close()
        for ctx in contexts:
            ctx.close()
        browser.close()

    summary(results, log)


if __name__ == "__main__":
    main()
