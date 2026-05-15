#!/usr/bin/env python3
"""DCAD owner search → OV65 + homestead + deed date for Dallas County businesses.

Strategy: ASP.NET form at https://www.dallascad.org/SearchOwner.aspx
After visiting homepage for viewstate cookies, POST owner name → results grid →
click top match → detail page has exemptions and deed history.

Viewstate cookies expire; re-warm homepage every 20 requests (PLAN §8 risk #2).

On no match in Dallas, emits cross_county_followup list for Collin/Denton/Tarrant/
Rockwall. Those counties each need their own scraper — this file does NOT query them.
"""
import argparse
import sys
import time
from datetime import datetime, timezone, date, timedelta
from pathlib import Path
from typing import Optional

# ---------------------------------------------------------------------------
# Resolve repo root so this script is importable both as a module and as a
# top-level runnable (python scrape_dcad.py) without installing the package.
# ---------------------------------------------------------------------------
_HERE = Path(__file__).resolve().parent
_REPO_ROOT = _HERE.parent.parent
if str(_REPO_ROOT) not in sys.path:
    sys.path.insert(0, str(_REPO_ROOT))

from playwright.sync_api import sync_playwright, TimeoutError as PWTimeout

from offmarket.scrapers.cad_common import (
    cache_key,
    entity_key,
    extract_exemptions,
    load_cached,
    log_factory,
    load_targets,
    name_variants,
    summary,
    write_cached,
)

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

PORTAL = "dcad"
SEARCH_URL = "https://www.dallascad.org/SearchOwner.aspx"
HOME_URL = "https://www.dallascad.org/"
POLITENESS_SEC = 1.0
VIEWSTATE_REFRESH_EVERY = 20
CROSS_COUNTY_COUNTIES = ["Collin", "Denton", "Tarrant", "Rockwall"]


def _cross_county_followup(reason: str = "no_match_in_primary") -> dict:
    return {"counties": CROSS_COUNTY_COUNTIES, "reason": reason}

# TTL for field-typed cache freshness (matches PLAN §4)
_FRESH_UNTIL_MAP = {
    "ov65": "any",
    "deed_date": "any",
}


# ---------------------------------------------------------------------------
# Pure parse functions (no network, fully unit-testable)
# ---------------------------------------------------------------------------

def _parse_results(html: str) -> list[dict]:
    """Parse DCAD owner-search results page HTML → list of row dicts.

    Each dict has: account_no, owner_name, situs_address, detail_link.

    Scoping strategy: DCAD renders the results grid in a table whose ID
    contains "GridView" or whose class/id contains "SearchResults".  We
    look for that specifically.  If the targeted table is absent we fall
    back to the largest data-bearing table (> 2 columns, > 1 data row) to
    stay robust against minor HTML changes.  Navigation / sidebar tables
    typically have ≤2 columns and/or contain no anchor tags pointing to
    /AcctDetailRes.aspx or /AcctDetailBPP.aspx.

    Returns [] when no results (no-match page OR parse failure).
    """
    from html.parser import HTMLParser

    class _TableParser(HTMLParser):
        def __init__(self):
            super().__init__()
            self.in_target = False
            self.depth = 0         # nesting depth *inside* the target table
            self.tables = []       # list of {"rows": [[{"text": str, "href": str|None}]]}
            self._cur_table = None
            self._cur_row = None
            self._cur_cell = None
            self._cell_text = []
            self._cell_href = None
            self._table_stack = []  # track nesting
            self._in_cell = False

        def handle_starttag(self, tag, attrs):
            attrs_d = dict(attrs)
            if tag == "table":
                t = {"rows": [], "id": attrs_d.get("id", ""), "class": attrs_d.get("class", "")}
                self._table_stack.append(t)
                self._cur_table = t
                self._cur_row = None
            elif tag == "tr" and self._cur_table is not None:
                self._cur_row = []
                self._cur_table["rows"].append(self._cur_row)
            elif tag in ("td", "th") and self._cur_row is not None:
                self._cur_cell = {"text": "", "href": None}
                self._cur_row.append(self._cur_cell)
                self._cell_text = []
                self._cell_href = None
                self._in_cell = True
            elif tag == "a" and self._in_cell:
                href = attrs_d.get("href", "")
                if href:
                    self._cell_href = href

        def handle_endtag(self, tag):
            if tag == "table":
                if self._table_stack:
                    finished = self._table_stack.pop()
                    self.tables.append(finished)
                    self._cur_table = self._table_stack[-1] if self._table_stack else None
            elif tag in ("td", "th"):
                if self._cur_cell is not None:
                    self._cur_cell["text"] = " ".join(self._cell_text).strip()
                    if self._cell_href:
                        self._cur_cell["href"] = self._cell_href
                    self._cur_cell = None
                    self._cell_text = []
                    self._cell_href = None
                self._in_cell = False

        def handle_data(self, data):
            if self._in_cell:
                stripped = data.strip()
                if stripped:
                    self._cell_text.append(stripped)

    parser = _TableParser()
    try:
        parser.feed(html)
    except Exception:
        return []

    # Step 1: prefer tables explicitly named for results (GridView / SearchResults)
    RESULT_ID_HINTS = ("gridview", "searchresult", "tblresult", "results", "grid")
    candidate_table = None
    for t in parser.tables:
        tid = (t.get("id", "") + " " + t.get("class", "")).lower()
        if any(hint in tid for hint in RESULT_ID_HINTS):
            data_rows = [r for r in t["rows"] if len(r) >= 3]
            if data_rows:
                candidate_table = t
                break

    # Step 2: fallback — largest table with ≥3 data columns and anchor links
    if candidate_table is None:
        def _score(t):
            # only count rows with ≥3 cells; prefer tables with anchor links
            data_rows = [r for r in t["rows"] if len(r) >= 3]
            anchors = sum(1 for r in data_rows for c in r if c.get("href"))
            return (len(data_rows), anchors)

        tables_scored = sorted(parser.tables, key=_score, reverse=True)
        for t in tables_scored:
            data_rows = [r for r in t["rows"] if len(r) >= 3]
            anchors = sum(1 for r in data_rows for c in r if c.get("href"))
            if data_rows and anchors:
                candidate_table = t
                break

    if candidate_table is None:
        return []

    all_rows = candidate_table["rows"]
    if len(all_rows) < 2:
        return []

    # Skip header row(s) — DCAD header cells contain "Account", "Owner", "Address"
    # Find the first row that looks like data (has a digit or a link in it)
    start_idx = 0
    for i, row in enumerate(all_rows):
        row_text = " ".join(c["text"] for c in row)
        has_digit = any(ch.isdigit() for ch in row_text)
        has_link = any(c.get("href") for c in row)
        if has_digit or has_link:
            start_idx = i
            break
    else:
        return []

    data_rows = all_rows[start_idx:]
    results = []
    for row in data_rows:
        texts = [c["text"] for c in row]
        hrefs = [c.get("href") for c in row if c.get("href")]
        # Skip rows that are obviously navigation or empty
        row_text = " ".join(texts).strip()
        if not row_text or len(row_text) < 5:
            continue
        # Skip rows where first cell doesn't look like an account number
        # DCAD account numbers are numeric strings (8–17 digits)
        first_text = texts[0].strip() if texts else ""
        if not any(ch.isdigit() for ch in first_text):
            continue

        detail_link = None
        for href in hrefs:
            if href and ("AcctDetail" in href or "AcctId" in href or "account" in href.lower()):
                detail_link = href
                break
        if not detail_link and hrefs:
            detail_link = hrefs[0]

        results.append({
            "account_no": first_text,
            "owner_name": texts[1].strip() if len(texts) > 1 else "",
            "situs_address": texts[2].strip() if len(texts) > 2 else "",
            "detail_link": detail_link,
            "raw_cells": texts,
        })

    return results


def _parse_detail_text(text: str) -> dict:
    """Parse DCAD property detail page innerText → exemption dict.

    Delegates actual regex work to cad_common.extract_exemptions.
    Returns the cad_common dict plus a 'page_text_sample' for debugging.
    """
    result = extract_exemptions(text)
    result["page_text_sample"] = text[:800] if text else ""
    return result


def _make_no_match_result(biz: dict, vertical: str, searches: list) -> dict:
    """Build a standardised no-match result dict with cross-county fallback."""
    return {
        "entity_id": entity_key(biz, vertical),
        "cache_key": cache_key(biz, vertical),
        "tpcl": biz.get("tpcl"),
        "license_number": biz.get("license_number"),
        "legal_name": biz.get("legal_name", ""),
        "owner_name": biz.get("owner_name") or biz.get("legal_name", ""),
        "portal": PORTAL,
        "vertical": vertical,
        "status": "no_match",
        "searches": searches,
        "cross_county_followup": _cross_county_followup(),
        "fetched_at": datetime.now(timezone.utc).isoformat(),
    }


# ---------------------------------------------------------------------------
# Network helpers (Playwright)
# ---------------------------------------------------------------------------

def _warm_viewstate(page) -> None:
    """Visit DCAD homepage to obtain fresh ASP.NET viewstate cookies."""
    try:
        page.goto(HOME_URL, wait_until="domcontentloaded", timeout=20_000)
        time.sleep(0.5)
    except Exception:
        pass  # best-effort; main search will error if cookies are truly missing


def _search_owner(page, search_term: str) -> tuple[list[dict], Optional[str]]:
    """Fill and submit the DCAD owner-search form; return (rows, error|None).

    Navigates to SearchOwner.aspx, fills txtOwnerName, clicks cmdSubmit, and
    hands the resulting HTML to the pure _parse_results() function.
    """
    try:
        page.goto(SEARCH_URL, wait_until="domcontentloaded", timeout=25_000)
        page.fill('input[name="txtOwnerName"]', search_term)
        page.click('input[name="cmdSubmit"]')
        page.wait_for_load_state("domcontentloaded", timeout=20_000)
        time.sleep(POLITENESS_SEC)
    except PWTimeout:
        return [], "timeout_on_search"
    except Exception as e:
        return [], f"err_{type(e).__name__}_{str(e)[:60]}"

    try:
        html = page.content()
        rows = _parse_results(html)
        return rows, None
    except Exception as e:
        return [], f"parse_err_{type(e).__name__}"


def _fetch_detail(page, link_url: str) -> tuple[Optional[dict], Optional[str]]:
    """Visit a DCAD property detail page; return (_parse_detail_text result, error|None)."""
    try:
        page.goto(link_url, wait_until="domcontentloaded", timeout=25_000)
        time.sleep(POLITENESS_SEC)
        text = page.evaluate("() => document.body.innerText")
        return _parse_detail_text(text), None
    except PWTimeout:
        return None, "timeout_on_detail"
    except Exception as e:
        return None, f"detail_err_{type(e).__name__}_{str(e)[:60]}"


# ---------------------------------------------------------------------------
# Per-business orchestration
# ---------------------------------------------------------------------------

def _lookup_one(page, biz: dict, request_counter: list[int],
                vertical: str = "pest-control", force_refresh: bool = False) -> dict:
    """Look up one business; return enrichment dict. Mutates request_counter[0].

    Tries every name variant from cad_common.name_variants in sequence.
    Refreshes viewstate every VIEWSTATE_REFRESH_EVERY requests.
    """
    eid = entity_key(biz, vertical)
    ckey = cache_key(biz, vertical)
    legal = biz.get("legal_name", "")
    owner = biz.get("owner_name") or legal

    # --- Cache-first ---
    if not force_refresh:
        cached = load_cached(PORTAL, ckey, fresh_until_map=_FRESH_UNTIL_MAP)
        if cached is not None:
            return {**cached, "_cache_hit": True}

    searches = []
    rows: list[dict] = []
    matched_term: Optional[str] = None

    variants = name_variants(legal, owner)
    if not variants:
        # Absolute fallback: try the raw legal name as-is
        variants = [(legal, None)]

    for last_or_full, first in variants:
        # Viewstate refresh guard
        if request_counter[0] > 0 and request_counter[0] % VIEWSTATE_REFRESH_EVERY == 0:
            _warm_viewstate(page)

        # Build the search term DCAD expects: "LASTNAME FIRSTNAME" or just name
        term = f"{last_or_full} {first}".strip() if first else last_or_full
        these_rows, err = _search_owner(page, term)
        request_counter[0] += 1
        searches.append({
            "term": term,
            "rows": len(these_rows),
            "err": err,
        })
        if these_rows:
            rows = these_rows
            matched_term = term
            break

    if not rows:
        result = _make_no_match_result(biz, vertical, searches)
        write_cached(PORTAL, ckey, result)
        return result

    # --- Pick best row ---
    # Prefer rows where the last word of owner name appears in the row text
    target_last = (owner.split()[-1] if owner else "").upper()
    best = rows[0]
    for r in rows[:30]:
        row_text = " ".join(r.get("raw_cells", [])).upper()
        if target_last and target_last in row_text:
            best = r
            break

    result: dict = {
        "entity_id": eid,
        "cache_key": ckey,
        "tpcl": biz.get("tpcl"),
        "license_number": biz.get("license_number"),
        "legal_name": legal,
        "owner_name": owner,
        "portal": PORTAL,
        "vertical": vertical,
        "status": "search_matched",
        "matched_term": matched_term,
        "rows_count": len(rows),
        "account_no": best.get("account_no"),
        "situs_address": best.get("situs_address"),
        "detail_link": best.get("detail_link"),
        "searches": searches,
        "fetched_at": datetime.now(timezone.utc).isoformat(),
    }

    # --- Fetch detail page ---
    detail_link = best.get("detail_link")
    if detail_link:
        if request_counter[0] > 0 and request_counter[0] % VIEWSTATE_REFRESH_EVERY == 0:
            _warm_viewstate(page)
        detail, err = _fetch_detail(page, detail_link)
        request_counter[0] += 1
        if detail:
            # Field-typed TTLs per PLAN §4
            today = date.today()
            result.update({
                "status": "detail_fetched",
                "exemptions": {
                    "ov65": detail.get("ov65", False),
                    "homestead": detail.get("homestead", False),
                    "disabled": detail.get("disabled", False),
                },
                "deed_date": detail.get("deed_date"),
                "appraised_value": detail.get("appraised_value"),
                "year_built": detail.get("year_built"),
                "page_text_sample": detail.get("page_text_sample"),
                "fresh_until": {
                    "ov65": (today + timedelta(days=90)).isoformat(),
                    "homestead": (today + timedelta(days=90)).isoformat(),
                    "disabled": (today + timedelta(days=90)).isoformat(),
                    "deed_date": (today + timedelta(days=365)).isoformat(),
                    "appraised_value": (today + timedelta(days=365)).isoformat(),
                },
            })
        else:
            result["detail_error"] = err

    write_cached(PORTAL, ckey, result)
    return result


# ---------------------------------------------------------------------------
# Fixture capture helper
# ---------------------------------------------------------------------------

def _save_fixture(eid: str, vertical: str = "pest-control") -> None:
    """Capture live search + detail HTML to fixtures dir for a given entity_id."""
    targets = load_targets(vertical, county_filter=["Dallas"])
    biz = next((b for b in targets if entity_key(b, vertical) == eid), None)
    if not biz:
        print(f"entity_id {eid!r} not found in {vertical} targets")
        return

    legal = biz.get("legal_name", "")
    owner = biz.get("owner_name") or legal
    variants = name_variants(legal, owner)
    if not variants:
        variants = [(legal, None)]

    fixtures_dir = Path(__file__).parent / "tests" / "fixtures" / "dcad"
    fixtures_dir.mkdir(parents=True, exist_ok=True)

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        ctx = browser.new_context(
            user_agent="Mozilla/5.0 (Macintosh) Chrome/120.0.0.0",
            viewport={"width": 1280, "height": 800},
        )
        page = ctx.new_page()
        _warm_viewstate(page)

        for last_or_full, first in variants:
            term = f"{last_or_full} {first}".strip() if first else last_or_full
            page.goto(SEARCH_URL, wait_until="domcontentloaded", timeout=25_000)
            page.fill('input[name="txtOwnerName"]', term)
            page.click('input[name="cmdSubmit"]')
            page.wait_for_load_state("domcontentloaded", timeout=20_000)
            time.sleep(POLITENESS_SEC)
            html = page.content()
            rows = _parse_results(html)
            if rows:
                out = fixtures_dir / "search_results_sample.html"
                out.write_text(html, encoding="utf-8")
                print(f"Saved search fixture → {out}")
                detail_link = rows[0].get("detail_link")
                if detail_link:
                    page.goto(detail_link, wait_until="domcontentloaded", timeout=25_000)
                    time.sleep(POLITENESS_SEC)
                    detail_html = page.content()
                    out2 = fixtures_dir / "detail_sample.html"
                    out2.write_text(detail_html, encoding="utf-8")
                    print(f"Saved detail fixture → {out2}")
                break
            else:
                out = fixtures_dir / "one_no_match.html"
                out.write_text(html, encoding="utf-8")
                print(f"Saved no-match fixture → {out}")

        browser.close()


# ---------------------------------------------------------------------------
# main()
# ---------------------------------------------------------------------------

def main() -> None:
    parser = argparse.ArgumentParser(description="DCAD owner-search scraper")
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
        "--save-fixture", metavar="TPCL",
        help="Capture live HTML fixtures for the given TPCL and exit"
    )
    args = parser.parse_args()

    log = log_factory(PORTAL)

    if args.save_fixture:
        _save_fixture(args.save_fixture, vertical=args.vertical)
        return

    # Load Dallas-county targets
    try:
        targets = load_targets(args.vertical, county_filter=["Dallas"])
    except FileNotFoundError as e:
        log(f"ERROR: {e}")
        sys.exit(1)

    if args.limit:
        targets = targets[: args.limit]

    log(f"Processing {len(targets)} Dallas County {args.vertical} businesses")

    results: dict[str, dict] = {}
    request_counter = [0]  # mutable int in a list for pass-by-ref into _lookup_one

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        # PLAN §5: 2 browser contexts max for DCAD
        ctx = browser.new_context(
            user_agent="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
                       "AppleWebKit/537.36 (KHTML, like Gecko) "
                       "Chrome/120.0.0.0 Safari/537.36",
            viewport={"width": 1280, "height": 800},
        )
        page = ctx.new_page()

        # Warm up homepage for viewstate cookies
        log("Warming viewstate cookies…")
        _warm_viewstate(page)

        for i, biz in enumerate(targets, 1):
            try:
                eid = entity_key(biz, args.vertical)
                ckey = cache_key(biz, args.vertical)
            except KeyError:
                eid = f"unknown_{i}"
                ckey = f"{args.vertical}__{eid}"
            try:
                r = _lookup_one(page, biz, request_counter,
                                vertical=args.vertical,
                                force_refresh=args.force_refresh)
            except Exception as e:
                r = {
                    "entity_id": eid,
                    "cache_key": ckey,
                    "tpcl": biz.get("tpcl"),
                    "license_number": biz.get("license_number"),
                    "legal_name": biz.get("legal_name", ""),
                    "portal": PORTAL,
                    "vertical": args.vertical,
                    "status": "error",
                    "error": f"{type(e).__name__}: {str(e)[:120]}",
                    "fetched_at": datetime.now(timezone.utc).isoformat(),
                }

            results[eid] = r
            status = r.get("status", "?")
            exemptions = r.get("exemptions", {})
            ov65 = exemptions.get("ov65", r.get("cad_ov65", "?"))
            hs = exemptions.get("homestead", r.get("cad_homestead", "?"))
            log(
                f"[{i}/{len(targets)}] {biz.get('legal_name','')[:30]:32s} "
                f"→ {status:20s} OV65={ov65} HS={hs}"
            )

        browser.close()

    summary(results, log)
    log(f"Done. {len(results)} results written to cache.")


if __name__ == "__main__":
    main()
