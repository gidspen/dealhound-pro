#!/usr/bin/env python3
"""BCAD owner search → OV65 + homestead + deed date for Bexar County businesses.

Strategy:
  TrueAutomation Classic portal at bexar.trueautomation.com/clientdb/PropertySearch.aspx?cid=110
  Cloudflare sits on bcad.org (the redirect gateway). We warm up there first (10s sleep
  absorbs the 9s JS challenge), then navigate to the TrueAutomation URL directly.

  ONE browser context for all businesses — reusing the session avoids re-triggering
  the Cloudflare challenge per lookup. Per PLAN §5: 1 worker, 2s politeness delay.

  On no match in Bexar: records cross_county_followup = ["Comal", "Guadalupe"].
  Does NOT query those CADs — that is left to the orchestrator.

  On Cloudflare CAPTCHA upgrade: records status = "cloudflare_blocked", breaks loop.
  (PLAN §8 risk #3.)
"""
import argparse
import sys
import time
from datetime import date, datetime, timezone, timedelta
from html.parser import HTMLParser
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

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

PORTAL = "bcad"
BCAD_GATEWAY = "https://www.bcad.org/"
SEARCH_URL = "https://bexar.trueautomation.com/clientdb/PropertySearch.aspx?cid=110"
DETAIL_BASE = "https://bexar.trueautomation.com"

# Field-typed freshness TTLs (days) per PLAN §4
_FRESH_UNTIL_MAP = {
    "ov65": 90,
    "homestead": 90,
    "disabled": 90,
    "deed_date": 365,
    "appraised_value": 365,
    "year_built": 365,
}

CROSS_COUNTY_COUNTIES = ["Comal", "Guadalupe"]
POLITENESS_SLEEP = 2.0  # seconds between requests


def _cross_county_followup(reason: str = "no_match_in_primary") -> dict:
    return {"counties": CROSS_COUNTY_COUNTIES, "reason": reason}


# Re-export shared CF detector for test backwards-compat
_is_cloudflare_challenge = is_cloudflare_challenge


# ---------------------------------------------------------------------------
# Pure parse helpers (unit-testable — no browser dependency)
# ---------------------------------------------------------------------------

class _TableParser(HTMLParser):
    """Minimal HTML table extractor.  Collects all <table> rows as lists of
    (cell_text, href|None) tuples.  Only the first link in each cell is kept."""

    def __init__(self):
        super().__init__()
        self.tables: list[list[list[tuple[str, str | None]]]] = []  # [table][row][cell]
        self._in_table = False
        self._in_row = False
        self._in_cell = False
        self._in_th = False
        self._cur_text: list[str] = []
        self._cur_href: str | None = None
        self._cur_row: list[tuple[str, str | None]] = []
        self._cur_table: list[list[tuple[str, str | None]]] = []

    def handle_starttag(self, tag, attrs):
        attrs_d = dict(attrs)
        if tag == "table":
            self._in_table = True
            self._cur_table = []
        elif tag == "tr" and self._in_table:
            self._in_row = True
            self._cur_row = []
        elif tag in ("td", "th") and self._in_row:
            self._in_cell = True
            self._in_th = tag == "th"
            self._cur_text = []
            self._cur_href = None
        elif tag == "a" and self._in_cell and self._cur_href is None:
            self._cur_href = attrs_d.get("href")

    def handle_endtag(self, tag):
        if tag in ("td", "th") and self._in_cell:
            self._in_cell = False
            self._in_th = False
            self._cur_row.append(("".join(self._cur_text).strip(), self._cur_href))
        elif tag == "tr" and self._in_row:
            self._in_row = False
            if self._cur_row:
                self._cur_table.append(self._cur_row)
        elif tag == "table" and self._in_table:
            self._in_table = False
            if self._cur_table:
                self.tables.append(self._cur_table)

    def handle_data(self, data):
        if self._in_cell:
            self._cur_text.append(data)


def _parse_results(html: str) -> list[dict]:
    """Parse BCAD search results page → list of row dicts.

    Each dict has:
      account   — CAD parcel account number string
      owner     — owner name string
      address   — situs address string
      legal     — legal description string (may be empty)
      detail_href — relative or absolute href to property detail page (may be None)

    Returns [] on parse failure or no results.

    Selector strategy:
      Scan all <table> elements for the one whose first data row has ≥3 columns
      and whose first column contains a link (the account# detail link).
      This is more robust than an id= selector if the portal ever changes its
      element IDs.
    """
    if not html:
        return []

    parser = _TableParser()
    try:
        parser.feed(html)
    except Exception:
        return []

    _HEADER_TEXTS = {"account #", "account#", "account", "acct #", "acct#",
                     "owner name", "owner", "situs address", "address",
                     "legal description", "legal"}

    for table in parser.tables:
        # Require ≥2 rows (at least one header + one data row) and ≥3 columns
        wide_rows = [r for r in table if len(r) >= 3]
        if len(wide_rows) < 2:
            continue

        # Strip pure-header rows (no hrefs anywhere in the row, all text is a
        # known column header label) to find actual data rows.
        data_rows = []
        for row in wide_rows:
            account_text = row[0][0].strip().lower()
            if account_text in _HEADER_TEXTS:
                continue  # skip column-header row
            data_rows.append(row)

        if not data_rows:
            continue

        # Detect results table: at least one data row col-0 must have a href
        # pointing to a property detail page.  Accept hrefs containing "prop_id"
        # or "property" (case-insensitive) as signal.
        has_detail_link = any(
            row[0][1] and (
                "prop_id" in (row[0][1] or "")
                or "property" in (row[0][1] or "").lower()
            )
            for row in data_rows
        )
        if not has_detail_link:
            continue

        rows = []
        for row in data_rows:
            account_text = row[0][0].strip()
            rows.append({
                "account": account_text,
                "owner": row[1][0].strip() if len(row) > 1 else "",
                "address": row[2][0].strip() if len(row) > 2 else "",
                "legal": row[3][0].strip() if len(row) > 3 else "",
                "detail_href": row[0][1],  # href from first cell's <a>
            })
        if rows:
            return rows

    return []


def _parse_detail_text(text: str) -> dict:
    """Parse BCAD property detail page body text → exemption dict.

    Delegates field extraction to cad_common.extract_exemptions() which owns
    the regex pack.  This wrapper adds a thin 'raw_text_sample' field for
    diagnostics and normalises the return shape.

    Returns dict with keys: ov65, homestead, disabled, deed_date,
    appraised_value, year_built, raw_text_sample.
    """
    exemptions = extract_exemptions(text)
    exemptions["raw_text_sample"] = (text or "")[:500]
    return exemptions


# ---------------------------------------------------------------------------
# Browser helpers
# ---------------------------------------------------------------------------

def _resolve_detail_url(href: str) -> str:
    """Resolve a possibly-relative detail href to an absolute URL."""
    if href.startswith("http"):
        return href
    if href.startswith("/"):
        return DETAIL_BASE + href
    return DETAIL_BASE + "/clientdb/" + href


def _warmup_cloudflare(page, log) -> bool:
    """Visit bcad.org gateway to acquire Cloudflare clearance cookie.

    Returns True if warmup succeeded (no interactive challenge detected),
    False if a CAPTCHA challenge was presented.
    """
    log("CF warmup: navigating to bcad.org ...")
    try:
        page.goto(BCAD_GATEWAY, wait_until="domcontentloaded", timeout=30000)
    except PWTimeout:
        log("CF warmup: timeout on bcad.org — continuing anyway")
    except Exception as e:
        log(f"CF warmup: error ({type(e).__name__}: {str(e)[:80]}) — continuing")

    # Sleep past the observed 9s JS challenge with 1s buffer
    log("CF warmup: sleeping 10s for JS challenge ...")
    time.sleep(10)

    # Check whether we landed on an interactive CAPTCHA
    try:
        html = page.content()
    except Exception:
        html = ""
    if _is_cloudflare_challenge(html):
        log("CF warmup: interactive CAPTCHA detected — cannot proceed automatically")
        return False

    log("CF warmup: complete, no interactive challenge")
    return True


def _search_owner(page, last: str, first: str | None, log) -> tuple[list[dict], str | None]:
    """Navigate to BCAD search, fill advanced owner-name form, return parsed rows.

    Returns (rows, error_string|None).
    """
    search_term = f"{last}, {first}" if first else last
    try:
        page.goto(SEARCH_URL, wait_until="domcontentloaded", timeout=20000)
    except PWTimeout:
        return [], "timeout_on_navigate"
    except Exception as e:
        return [], f"nav_err_{type(e).__name__}"

    # Check for unexpected Cloudflare interception after navigation
    try:
        html = page.content()
    except Exception:
        html = ""
    if _is_cloudflare_challenge(html):
        return [], "cloudflare_blocked"

    # Fill the advanced owner-name input
    try:
        # The advanced search panel may need to be activated first.
        # TrueAutomation Classic: the advanced options div id is
        # "propertySearchOptions_advanced"; owner name input is within it.
        # Try to click the "Advanced" tab/link if visible.
        adv_locator = page.locator("#propertySearchOptions_advanced")
        if adv_locator.count() == 0:
            # Try clicking an "Advanced" toggle link/button
            try:
                page.click("text=Advanced", timeout=3000)
                time.sleep(0.5)
            except Exception:
                pass  # may already be open or not needed

        # Owner name input: look for input inside the advanced div, or fall back
        # to any input whose name/id contains "owner" or "name".
        owner_input = None
        for selector in [
            "#propertySearchOptions_advanced input[type='text']",
            "input[name*='owner' i]",
            "input[id*='owner' i]",
            "input[name*='OwnerName' i]",
            "input[id*='OwnerName' i]",
        ]:
            loc = page.locator(selector)
            if loc.count() > 0:
                owner_input = selector
                break

        if owner_input is None:
            return [], "no_owner_input_found"

        page.fill(owner_input, search_term)
        page.keyboard.press("Enter")
        page.wait_for_load_state("domcontentloaded", timeout=15000)
        time.sleep(1)
    except PWTimeout:
        return [], "timeout_on_form"
    except Exception as e:
        return [], f"form_err_{type(e).__name__}"

    try:
        html = page.content()
    except Exception:
        return [], "content_fetch_err"

    if _is_cloudflare_challenge(html):
        return [], "cloudflare_blocked"

    rows = _parse_results(html)
    return rows, None


def _fetch_detail(page, href: str, log) -> tuple[dict | None, str | None]:
    """Navigate to property detail page and extract exemption data."""
    url = _resolve_detail_url(href)
    try:
        page.goto(url, wait_until="domcontentloaded", timeout=20000)
        time.sleep(1)
    except PWTimeout:
        return None, "timeout_on_detail"
    except Exception as e:
        return None, f"detail_nav_err_{type(e).__name__}"

    try:
        html = page.content()
        text = page.inner_text("body")
    except Exception as e:
        return None, f"detail_content_err_{type(e).__name__}"

    if _is_cloudflare_challenge(html):
        return None, "cloudflare_blocked"

    return _parse_detail_text(text), None


# ---------------------------------------------------------------------------
# Per-business lookup
# ---------------------------------------------------------------------------

def _lookup_one(page, biz: dict, log, force_refresh: bool = False,
                vertical: str = "pest-control") -> dict:
    """Look up one Bexar County business; return enrichment dict.

    Cache-first unless force_refresh=True.
    On no Bexar match: emits cross_county_followup dict {counties, reason}.
    """
    eid = entity_key(biz, vertical)
    ckey = cache_key(biz, vertical)
    legal = biz.get("legal_name", "")
    owner = biz.get("owner_name") or legal

    # --- cache check ---
    if not force_refresh:
        cached = load_cached(PORTAL, ckey, fresh_until_map={
            k: "any" for k in _FRESH_UNTIL_MAP
        })
        if cached is not None:
            log(f"  cache hit: {eid}")
            return {**cached, "_cache_hit": True}

    result: dict = {
        "entity_id": eid,
        "cache_key": ckey,
        "tpcl": biz.get("tpcl"),
        "license_number": biz.get("license_number"),
        "portal": PORTAL,
        "vertical": vertical,
        "legal_name": legal,
        "owner_name": owner,
        "fetched_at": datetime.now(timezone.utc).isoformat(),
        "searches": [],
        "errors": [],
    }

    # --- build fresh_until dates (use timedelta uniformly — leap-safe) ---
    today = date.today()
    result["fresh_until"] = {
        field: (today + timedelta(days=days)).isoformat()
        for field, days in _FRESH_UNTIL_MAP.items()
    }

    # --- name variants ---
    variants = name_variants(legal, owner)
    if not variants:
        # Fallback: use last word as surname
        variants = [(owner.split()[-1], None)] if owner.strip() else []

    rows: list[dict] = []
    matched_variant: tuple | None = None
    cloudflare_blocked = False

    for last, first in variants:
        these_rows, err = _search_owner(page, last, first, log)
        result["searches"].append({
            "term": f"{last},{first}" if first else last,
            "rows": len(these_rows),
            "err": err,
        })

        if err == "cloudflare_blocked":
            cloudflare_blocked = True
            break

        if err:
            result["errors"].append(err)
            continue

        if these_rows:
            rows = these_rows
            matched_variant = (last, first)
            break

        time.sleep(POLITENESS_SLEEP)

    if cloudflare_blocked:
        result["status"] = "cloudflare_blocked"
        log(f"  [{eid}] Cloudflare CAPTCHA — stopping run")
        write_cached(PORTAL, ckey, result)
        return result

    if not rows:
        result["status"] = "no_match"
        result["cross_county_followup"] = _cross_county_followup()
        write_cached(PORTAL, ckey, result)
        return result

    result["status"] = "search_matched"
    result["rows_count"] = len(rows)
    result["matched_term"] = f"{matched_variant[0]},{matched_variant[1]}" if matched_variant else None

    # --- pick best row ---
    # Prefer row whose owner text contains the target surname
    target_last = (matched_variant[0] if matched_variant else owner.split()[-1]).upper()
    best = None
    for row in rows[:30]:
        if target_last in row.get("owner", "").upper():
            best = row
            break
    if best is None:
        best = rows[0]

    result["top_row"] = {k: v for k, v in best.items() if k != "detail_href"}
    result["detail_href"] = best.get("detail_href")

    # --- fetch detail ---
    if best.get("detail_href"):
        time.sleep(POLITENESS_SLEEP)
        detail, err = _fetch_detail(page, best["detail_href"], log)
        if err == "cloudflare_blocked":
            result["status"] = "cloudflare_blocked"
            log(f"  [{eid}] Cloudflare CAPTCHA on detail page — stopping run")
            write_cached(PORTAL, ckey, result)
            return result
        if detail:
            result["status"] = "detail_fetched"
            result["exemptions"] = {
                k: detail[k]
                for k in ("ov65", "homestead", "disabled")
            }
            result["deed_date"] = detail.get("deed_date")
            result["appraised_value"] = detail.get("appraised_value")
            result["year_built"] = detail.get("year_built")
        elif err:
            result["errors"].append(err)
    else:
        result["errors"].append("no_detail_href")

    write_cached(PORTAL, ckey, result)
    return result


# ---------------------------------------------------------------------------
# --save-fixture helper
# ---------------------------------------------------------------------------

def _save_fixture(page, eid: str, log, vertical: str = "pest-control") -> None:
    """Navigate BCAD for a single known entity_id and write HTML fixtures to disk."""
    fixture_dir = Path(__file__).parent / "tests" / "fixtures" / "bcad"
    fixture_dir.mkdir(parents=True, exist_ok=True)

    log(f"save-fixture: loading targets for entity_id={eid}")
    targets = load_targets(vertical, county_filter=["bexar"])
    biz = next((b for b in targets if entity_key(b, vertical) == eid), None)
    if biz is None:
        log(f"save-fixture: entity_id {eid} not found in Bexar targets")
        return

    variants = name_variants(biz.get("legal_name"), biz.get("owner_name"))
    if not variants:
        log("save-fixture: no name variants resolved")
        return

    last, first = variants[0]
    rows, err = _search_owner(page, last, first, log)
    if err:
        log(f"save-fixture: search error: {err}")
        return

    search_html = page.content()
    out_search = fixture_dir / "search_results_sample.html"
    out_search.write_text(search_html, encoding="utf-8")
    log(f"save-fixture: wrote {out_search}")

    if rows and rows[0].get("detail_href"):
        url = _resolve_detail_url(rows[0]["detail_href"])
        try:
            page.goto(url, wait_until="domcontentloaded", timeout=20000)
            time.sleep(1)
        except Exception as e:
            log(f"save-fixture: detail nav error: {e}")
            return
        detail_html = page.content()
        out_detail = fixture_dir / "detail_sample.html"
        out_detail.write_text(detail_html, encoding="utf-8")
        log(f"save-fixture: wrote {out_detail}")
    else:
        log("save-fixture: no detail link found in results")


# ---------------------------------------------------------------------------
# main()
# ---------------------------------------------------------------------------

def main() -> None:
    parser = argparse.ArgumentParser(description="BCAD owner search scraper")
    parser.add_argument("--vertical", default="pest-control",
                        help="Target vertical (matches offmarket/data/{vertical}_targets.json)")
    parser.add_argument("--save-fixture", metavar="ENTITY_ID",
                        help="Capture live HTML fixtures for the given entity_id and exit")
    parser.add_argument("--limit", type=int, default=None,
                        help="Process at most N businesses (for debugging)")
    parser.add_argument("--force-refresh", action="store_true",
                        help="Ignore cache; re-fetch all businesses")
    args = parser.parse_args()

    log = log_factory(PORTAL)

    targets = load_targets(args.vertical, county_filter=["bexar"])
    if args.limit:
        targets = targets[: args.limit]
    log(f"Loaded {len(targets)} Bexar County businesses for vertical={args.vertical}")

    results: dict[str, dict] = {}

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        ctx = browser.new_context(
            user_agent="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
                       "AppleWebKit/537.36 (KHTML, like Gecko) "
                       "Chrome/120.0.0.0 Safari/537.36",
            viewport={"width": 1280, "height": 800},
        )
        page = ctx.new_page()

        if args.save_fixture:
            ok = _warmup_cloudflare(page, log)
            if not ok:
                log("Cannot capture fixture — interactive Cloudflare challenge")
                browser.close()
                sys.exit(1)
            _save_fixture(page, args.save_fixture, log, vertical=args.vertical)
            browser.close()
            return

        # --- Cloudflare warmup (ONE context for all lookups per PLAN §5) ---
        ok = _warmup_cloudflare(page, log)
        if not ok:
            log("BCAD run aborted — interactive Cloudflare challenge at warmup")
            browser.close()
            # Write a blocked sentinel for all targets so orchestrator knows
            for biz in targets:
                eid = entity_key(biz, args.vertical)
                ckey = cache_key(biz, args.vertical)
                r = {
                    "entity_id": eid,
                    "cache_key": ckey,
                    "tpcl": biz.get("tpcl"),
                    "license_number": biz.get("license_number"),
                    "portal": PORTAL,
                    "vertical": args.vertical,
                    "status": "cloudflare_blocked",
                    "fetched_at": datetime.now(timezone.utc).isoformat(),
                    "errors": ["interactive_cf_challenge_at_warmup"],
                }
                results[eid] = r
                write_cached(PORTAL, ckey, r)
            summary(results, log)
            return

        # --- Per-business loop ---
        for i, biz in enumerate(targets, 1):
            eid = entity_key(biz, args.vertical)
            ckey = cache_key(biz, args.vertical)
            try:
                r = _lookup_one(page, biz, log, force_refresh=args.force_refresh,
                                vertical=args.vertical)
            except Exception as e:
                r = {
                    "entity_id": eid,
                    "cache_key": ckey,
                    "tpcl": biz.get("tpcl"),
                    "license_number": biz.get("license_number"),
                    "portal": PORTAL,
                    "vertical": args.vertical,
                    "legal_name": biz.get("legal_name", ""),
                    "status": "error",
                    "error": f"{type(e).__name__}: {str(e)[:120]}",
                    "fetched_at": datetime.now(timezone.utc).isoformat(),
                    "errors": [f"{type(e).__name__}: {str(e)[:120]}"],
                }
                write_cached(PORTAL, ckey, r)

            results[eid] = r
            status = r.get("status", "?")
            ov65 = r.get("exemptions", {}).get("ov65", "?")
            hs = r.get("exemptions", {}).get("homestead", "?")
            log(f"[{i}/{len(targets)}] {biz.get('legal_name','')[:30]:32s} "
                f"→ {status:20s} OV65={ov65} HS={hs}")

            # Stop the whole run if CF upgraded to interactive challenge
            if status == "cloudflare_blocked":
                log("Cloudflare CAPTCHA detected mid-run — stopping. "
                    "Remaining businesses not processed.")
                break

            time.sleep(POLITENESS_SLEEP)

        browser.close()

    summary(results, log)
    log(f"BCAD run complete. {len(results)} records written to cache.")


if __name__ == "__main__":
    main()
