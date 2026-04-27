#!/usr/bin/env python3.12
"""
Deal Finder — Playwright scraper for major listing sites.
Bypasses bot detection by running real headless Chromium.

Usage:
    python3 scraper.py --site bizbuysell --location texas --output raw-listings-bizbuysell.json
    python3 scraper.py --site landwatch --location texas --output raw-listings-landwatch.json
    python3 scraper.py --site all --location texas

Sites supported:
    bizbuysell   — BizBuySell campgrounds + travel businesses
    landwatch    — LandWatch commercial camping land
    landsearch   — LandSearch resort + lodge properties
    crexi        — Crexi RV parks
    all          — Run all sites

Output schema per listing (matches raw-listings-*.json format):
    title, price, price_raw, location, url, acreage, rooms_keys,
    revenue_hint, dom_hint, condition_hint, description, property_type, source
"""

import argparse
import asyncio
import json
import os
import re
import time
import sys
from datetime import datetime
from pathlib import Path
from urllib.parse import urlparse

from playwright.sync_api import sync_playwright, TimeoutError as PlaywrightTimeout
from playwright.async_api import async_playwright

from claude_extract import extract_listings_from_page_text

# ── State lookup ─────────────────────────────────────────────────────────────

STATE_CODES = {
    "alabama": "AL", "alaska": "AK", "arizona": "AZ", "arkansas": "AR",
    "california": "CA", "colorado": "CO", "connecticut": "CT", "delaware": "DE",
    "florida": "FL", "georgia": "GA", "hawaii": "HI", "idaho": "ID",
    "illinois": "IL", "indiana": "IN", "iowa": "IA", "kansas": "KS",
    "kentucky": "KY", "louisiana": "LA", "maine": "ME", "maryland": "MD",
    "massachusetts": "MA", "michigan": "MI", "minnesota": "MN", "mississippi": "MS",
    "missouri": "MO", "montana": "MT", "nebraska": "NE", "nevada": "NV",
    "new hampshire": "NH", "new jersey": "NJ", "new mexico": "NM", "new york": "NY",
    "north carolina": "NC", "north dakota": "ND", "ohio": "OH", "oklahoma": "OK",
    "oregon": "OR", "pennsylvania": "PA", "rhode island": "RI", "south carolina": "SC",
    "south dakota": "SD", "tennessee": "TN", "texas": "TX", "utah": "UT",
    "vermont": "VT", "virginia": "VA", "washington": "WA", "west virginia": "WV",
    "wisconsin": "WI", "wyoming": "WY",
}

def to_state_code(location):
    """Convert full state name to 2-letter code. Pass-through if already a code."""
    loc = location.lower().strip()
    return STATE_CODES.get(loc, location.upper()[:2])

# ── Config ────────────────────────────────────────────────────────────────────

OUTPUT_DIR = Path(__file__).parent
MAX_PAGES = 10          # max pagination pages per site
MAX_LISTINGS = 200      # stop after this many raw listings
DELAY = 1.5             # seconds between page loads (be polite)

HEADERS = {
    "user-agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
                  "AppleWebKit/537.36 (KHTML, like Gecko) "
                  "Chrome/120.0.0.0 Safari/537.36"
}

# ── Helpers ───────────────────────────────────────────────────────────────────

def parse_price(text):
    """Extract integer price from strings like '$1,250,000' or 'Call for Price'."""
    if not text:
        return None
    clean = re.sub(r'[^\d]', '', text)
    return int(clean) if clean else None

def clean(text):
    """Strip whitespace and normalize."""
    if not text:
        return None
    return ' '.join(text.strip().split())

def new_page(browser):
    """Create a new page with realistic headers."""
    ctx = browser.new_context(
        user_agent=HEADERS["user-agent"],
        viewport={"width": 1440, "height": 900},
        locale="en-US",
    )
    page = ctx.new_page()
    page.set_extra_http_headers({"Accept-Language": "en-US,en;q=0.9"})
    return page

def safe_text(el, selector):
    try:
        return clean(el.query_selector(selector).inner_text())
    except:
        return None

def safe_attr(el, selector, attr):
    try:
        return el.query_selector(selector).get_attribute(attr)
    except:
        return None

# ── BizBuySell ────────────────────────────────────────────────────────────────

def scrape_bizbuysell(page, location="texas"):
    """Scrape BizBuySell campgrounds + travel businesses for a given state."""
    listings = []

    urls = [
        f"https://www.bizbuysell.com/{location}/campgrounds-and-rv-parks-for-sale/",
        f"https://www.bizbuysell.com/{location}/travel-businesses-for-sale/",
    ]

    for base_url in urls:
        page_num = 1
        while page_num <= MAX_PAGES and len(listings) < MAX_LISTINGS:
            url = base_url if page_num == 1 else f"{base_url}?page={page_num}"
            print(f"  BizBuySell: {url}")

            try:
                page.goto(url, wait_until="domcontentloaded", timeout=20000)
                page.wait_for_timeout(2000)  # let JS render
            except PlaywrightTimeout:
                print(f"  Timeout on {url}, skipping")
                break

            # Check for bot block
            if "Access Denied" in page.title() or page.url != url:
                print(f"  Blocked or redirected on {url}")
                break

            cards = page.query_selector_all(".resultItem, .listing-card, [data-testid='listing-card']")
            if not cards:
                # Try alternate selectors
                cards = page.query_selector_all("li.result")

            if not cards:
                print(f"  No listing cards found on page {page_num}")
                break

            page_listings = []
            for card in cards:
                try:
                    title = clean(card.query_selector("h3, h2, .title, [class*='title']").inner_text()) if card.query_selector("h3, h2, .title, [class*='title']") else None
                    if not title:
                        continue

                    price_el = card.query_selector("[class*='price'], .price")
                    price_raw = clean(price_el.inner_text()) if price_el else None

                    location_el = card.query_selector("[class*='location'], .location, [class*='city']")
                    loc = clean(location_el.inner_text()) if location_el else None

                    link_el = card.query_selector("a[href]")
                    href = link_el.get_attribute("href") if link_el else None
                    if href and not href.startswith("http"):
                        href = "https://www.bizbuysell.com" + href

                    desc_el = card.query_selector("[class*='description'], [class*='desc'], p")
                    desc = clean(desc_el.inner_text()) if desc_el else None

                    cash_flow_el = card.query_selector("[class*='cash'], [class*='revenue'], [class*='ebitda']")
                    revenue_hint = clean(cash_flow_el.inner_text()) if cash_flow_el else None

                    page_listings.append({
                        "title": title,
                        "price": parse_price(price_raw),
                        "price_raw": price_raw,
                        "location": loc,
                        "address": None,
                        "url": href,
                        "acreage": None,
                        "rooms_keys": None,
                        "revenue_hint": revenue_hint,
                        "dom_hint": None,
                        "condition_hint": None,
                        "description": desc,
                        "property_type": None,
                        "source": "bizbuysell"
                    })
                except Exception as e:
                    continue

            if not page_listings:
                break

            listings.extend(page_listings)
            print(f"  → {len(page_listings)} listings on page {page_num} ({len(listings)} total)")

            # Check for next page
            next_btn = page.query_selector("a[aria-label='Next'], a.next, [class*='next-page']")
            if not next_btn:
                break

            page_num += 1
            time.sleep(DELAY)

    return listings

# ── LandWatch ─────────────────────────────────────────────────────────────────

def scrape_landwatch(page, location="texas"):
    """Scrape LandWatch commercial camping land."""
    listings = []

    urls = [
        f"https://www.landwatch.com/{location}-land-for-sale/commercial-property/camping-activity",
        f"https://www.landwatch.com/{location}-land-for-sale/camping-activity",
    ]

    for base_url in urls:
        page_num = 1
        while page_num <= MAX_PAGES and len(listings) < MAX_LISTINGS:
            url = base_url if page_num == 1 else f"{base_url}?page={page_num}"
            print(f"  LandWatch: {url}")

            try:
                page.goto(url, wait_until="domcontentloaded", timeout=20000)
                page.wait_for_timeout(2500)
            except PlaywrightTimeout:
                print(f"  Timeout on {url}, skipping")
                break

            if "Access Denied" in page.title():
                print(f"  Blocked on {url}")
                break

            cards = page.query_selector_all("[class*='PropertyCard'], [class*='listing-card'], article[class*='property']")

            if not cards:
                print(f"  No cards found on page {page_num}")
                break

            page_listings = []
            for card in cards:
                try:
                    title_el = card.query_selector("h2, h3, [class*='title']")
                    title = clean(title_el.inner_text()) if title_el else None
                    if not title:
                        continue

                    price_el = card.query_selector("[class*='price'], [class*='Price']")
                    price_raw = clean(price_el.inner_text()) if price_el else None

                    loc_el = card.query_selector("[class*='location'], [class*='Location'], [class*='county']")
                    loc = clean(loc_el.inner_text()) if loc_el else None

                    link_el = card.query_selector("a[href]")
                    href = link_el.get_attribute("href") if link_el else None
                    if href and not href.startswith("http"):
                        href = "https://www.landwatch.com" + href

                    # Acreage often in title or separate element
                    acreage = None
                    acreage_match = re.search(r'([\d,\.]+)\s*(?:acres?|ac\.?)', title or '', re.I)
                    if acreage_match:
                        acreage = float(acreage_match.group(1).replace(',', ''))

                    desc_el = card.query_selector("[class*='description'], [class*='desc'], p")
                    desc = clean(desc_el.inner_text()) if desc_el else None

                    page_listings.append({
                        "title": title,
                        "price": parse_price(price_raw),
                        "price_raw": price_raw,
                        "location": loc,
                        "address": None,
                        "url": href,
                        "acreage": acreage,
                        "rooms_keys": None,
                        "revenue_hint": None,
                        "dom_hint": None,
                        "condition_hint": None,
                        "description": desc,
                        "property_type": None,
                        "source": "landwatch"
                    })
                except Exception:
                    continue

            if not page_listings:
                break

            listings.extend(page_listings)
            print(f"  → {len(page_listings)} listings on page {page_num} ({len(listings)} total)")

            next_btn = page.query_selector("a[aria-label='Next'], [class*='next'], [class*='pagination'] a:last-child")
            if not next_btn:
                break

            page_num += 1
            time.sleep(DELAY)

    return listings

# ── LandSearch ────────────────────────────────────────────────────────────────

def scrape_landsearch(page, location="texas"):
    """Scrape LandSearch resort + lodge + cabin properties.

    DOM structure (confirmed):
      article[class*='property']   → card container
      .preview__title              → "$price acreage" concatenated
      .preview__size               → "X acres" (extract acreage from here)
      .preview__subterritory       → county
      .preview__location           → "City, TX zip"
      a.preview-gallery__images    → href to listing detail
    """
    listings = []
    slugs = ["resort", "lodge", "cabin"]

    for slug in slugs:
        url = f"https://www.landsearch.com/{slug}/{location}"
        page_num = 1

        while page_num <= MAX_PAGES and len(listings) < MAX_LISTINGS:
            paginated = url if page_num == 1 else f"{url}/p{page_num}"
            print(f"  LandSearch: {paginated}")

            try:
                page.goto(paginated, wait_until="networkidle", timeout=20000)
            except PlaywrightTimeout:
                print(f"  Timeout, skipping")
                break

            if "Access Denied" in page.title() or "404" in page.title():
                print(f"  Blocked or 404")
                break

            cards = page.query_selector_all("article[class*='property']")
            if not cards:
                print(f"  No cards on page {page_num}")
                break

            page_listings = []
            for card in cards:
                try:
                    # Price is in .preview__title but concatenated with acreage
                    # Extract price by stripping the acreage portion
                    size_el = card.query_selector(".preview__size")
                    size_text = clean(size_el.inner_text()) if size_el else ""

                    title_el = card.query_selector(".preview__title")
                    title_raw = clean(title_el.inner_text()) if title_el else None

                    # Price = title_raw minus the size_text
                    price_raw = title_raw.replace(size_text, "").strip() if (title_raw and size_text) else title_raw

                    # Acreage from size element
                    acreage = None
                    if size_text:
                        m = re.search(r'([\d,\.]+)\s*acres?', size_text, re.I)
                        if m:
                            acreage = float(m.group(1).replace(',', ''))

                    loc_el = card.query_selector(".preview__location")
                    loc = clean(loc_el.inner_text()) if loc_el else None

                    county_el = card.query_selector(".preview__subterritory")
                    county = clean(county_el.inner_text()) if county_el else None

                    full_loc = f"{loc}, {county}" if loc and county else (loc or county)

                    link_el = card.query_selector("a.preview-gallery__images, a[href*='/properties/']")
                    href = link_el.get_attribute("href") if link_el else None
                    if href and not href.startswith("http"):
                        href = "https://www.landsearch.com" + href

                    # Build a title from location + acreage since there's no property name
                    title = f"{acreage} acres — {full_loc}" if acreage and full_loc else full_loc

                    page_listings.append({
                        "title": title,
                        "price": parse_price(price_raw),
                        "price_raw": price_raw,
                        "location": full_loc,
                        "address": None,
                        "url": href,
                        "acreage": acreage,
                        "rooms_keys": None,
                        "revenue_hint": None,
                        "dom_hint": None,
                        "condition_hint": None,
                        "description": None,
                        "property_type": slug,
                        "source": "landsearch"
                    })
                except Exception:
                    continue

            if not page_listings:
                break

            listings.extend(page_listings)
            print(f"  → {len(page_listings)} listings on page {page_num} ({len(listings)} total)")

            next_btn = page.query_selector("a[rel='next'], [class*='pagination'] a:last-child")
            if not next_btn:
                break

            page_num += 1
            time.sleep(DELAY)

    return listings

# ── Crexi ─────────────────────────────────────────────────────────────────────

def scrape_crexi(page, location="texas"):
    """Scrape Crexi RV parks and hospitality listings.
    NOTE: Currently blocked by Cloudflare bot management. Needs residential proxy.
    """
    listings = []
    state = to_state_code(location)

    urls = [
        f"https://www.crexi.com/properties?propertyType=Hospitality&stateCode={state}",
    ]

    for base_url in urls:
        print(f"  Crexi: {base_url}")

        try:
            page.goto(base_url, wait_until="domcontentloaded", timeout=25000)
            page.wait_for_timeout(3000)  # Crexi is heavy JS
        except PlaywrightTimeout:
            print(f"  Timeout, skipping")
            continue

        if "Access Denied" in page.title():
            print(f"  Blocked")
            continue

        # Scroll to load more
        for _ in range(3):
            page.evaluate("window.scrollTo(0, document.body.scrollHeight)")
            page.wait_for_timeout(1000)

        cards = page.query_selector_all("[class*='PropertyCard'], [class*='property-card'], [data-testid*='property']")

        for card in cards:
            try:
                title_el = card.query_selector("h2, h3, [class*='name'], [class*='title']")
                title = clean(title_el.inner_text()) if title_el else None
                if not title:
                    continue

                price_el = card.query_selector("[class*='price'], [class*='Price']")
                price_raw = clean(price_el.inner_text()) if price_el else None

                loc_el = card.query_selector("[class*='location'], [class*='address'], [class*='city']")
                loc = clean(loc_el.inner_text()) if loc_el else None

                link_el = card.query_selector("a[href]")
                href = link_el.get_attribute("href") if link_el else None
                if href and not href.startswith("http"):
                    href = "https://www.crexi.com" + href

                listings.append({
                    "title": title,
                    "price": parse_price(price_raw),
                    "price_raw": price_raw,
                    "location": loc,
                    "address": None,
                    "url": href,
                    "acreage": None,
                    "rooms_keys": None,
                    "revenue_hint": None,
                    "dom_hint": None,
                    "condition_hint": None,
                    "description": None,
                    "property_type": "rv park / campground",
                    "source": "crexi"
                })
            except Exception:
                continue

        print(f"  → {len(listings)} Crexi listings so far")
        time.sleep(DELAY)

    return listings

# ── Async / Universal (ScraperAPI proxy + Claude extraction) ─────────────────

SCRAPER_API_KEY = os.environ.get("SCRAPER_API_KEY", "")
PROXY_SERVER = "http://proxy-server.scraperapi.com:8001"


async def create_browser(use_proxy: bool = True):
    """Launch Playwright Chromium with optional ScraperAPI residential proxy."""
    p = await async_playwright().start()
    launch_args = {
        "headless": True,
        "args": [
            "--disable-blink-features=AutomationControlled",
            "--ignore-certificate-errors",
        ],
    }
    if use_proxy and SCRAPER_API_KEY:
        launch_args["proxy"] = {
            "server": PROXY_SERVER,
            "username": "scraperapi",
            "password": SCRAPER_API_KEY,
        }
    browser = await p.chromium.launch(**launch_args)
    return browser


async def scrape_site_with_claude(
    page,
    site_url: str,
    site_name: str,
    max_pages: int = MAX_PAGES,
    max_listings: int = MAX_LISTINGS,
) -> list[dict]:
    """
    Universal scraper. Playwright fetches the page, Claude extracts listings.
    Works on ANY site — no CSS selectors, no per-site configuration.
    """
    all_listings = []
    current_url = site_url

    for page_num in range(1, max_pages + 1):
        if len(all_listings) >= max_listings:
            break

        try:
            await page.goto(current_url, wait_until="networkidle", timeout=30000)
            await page.wait_for_timeout(2000)
        except Exception as e:
            print(f"[scraper] Failed to load {current_url}: {e}")
            break

        page_text = await page.evaluate("document.body.innerText")

        if not page_text or len(page_text.strip()) < 100:
            print(f"[scraper] Empty page at {current_url}")
            break

        page_listings = await extract_listings_from_page_text(
            page_text=page_text,
            source_url=current_url,
            source_name=site_name,
        )

        if not page_listings:
            print(f"[scraper] No listings found on page {page_num} of {site_name}")
            break

        all_listings.extend(page_listings)
        print(f"[scraper] {site_name} page {page_num}: {len(page_listings)} listings (total: {len(all_listings)})")

        next_url = await _find_next_page(page, current_url)
        if not next_url:
            break

        current_url = next_url
        await asyncio.sleep(DELAY)

    return all_listings[:max_listings]


async def _find_next_page(page, current_url: str) -> str | None:
    """Find the next page URL. Tries common pagination patterns."""
    try:
        next_link = await page.query_selector(
            'a:has-text("Next"), a:has-text("next"), a[aria-label="Next"], '
            'a.next, a.pagination-next, [class*="next"] a'
        )
        if next_link:
            href = await next_link.get_attribute("href")
            if href and href != current_url:
                if href.startswith("/"):
                    parsed = urlparse(current_url)
                    return f"{parsed.scheme}://{parsed.netloc}{href}"
                return href
    except Exception:
        pass
    return None


# ── Main ──────────────────────────────────────────────────────────────────────

SCRAPERS = {
    "bizbuysell": scrape_bizbuysell,
    "landwatch": scrape_landwatch,
    "landsearch": scrape_landsearch,
    "crexi": scrape_crexi,
}

def run(sites, location, output_dir):
    results = {}

    with sync_playwright() as p:
        browser = p.chromium.launch(
            headless=True,
            args=[
                "--no-sandbox",
                "--disable-blink-features=AutomationControlled",
                "--disable-infobars",
            ]
        )

        for site in sites:
            print(f"\n=== Scraping {site.upper()} ===")
            page = new_page(browser)

            try:
                scraper_fn = SCRAPERS[site]
                listings = scraper_fn(page, location)
            except Exception as e:
                print(f"  ERROR on {site}: {e}")
                listings = []
            finally:
                page.context.close()

            # Deduplicate by URL
            seen = set()
            unique = []
            for l in listings:
                key = l.get("url") or l.get("title")
                if key and key not in seen:
                    seen.add(key)
                    unique.append(l)

            results[site] = unique
            print(f"  {site}: {len(unique)} unique listings")

            # Save per-site file
            slug = site.replace(" ", "-")
            out_file = output_dir / f"raw-listings-{slug}.json"
            with open(out_file, "w") as f:
                json.dump({
                    "scraped_at": datetime.now().isoformat(),
                    "location_filter": location,
                    "source": site,
                    "count": len(unique),
                    "listings": unique
                }, f, indent=2)
            print(f"  Saved → {out_file}")

        browser.close()

    return results

def main():
    parser = argparse.ArgumentParser(description="Deal Finder scraper")
    parser.add_argument("--site", default="all", choices=list(SCRAPERS.keys()) + ["all"])
    parser.add_argument("--location", default="texas")
    parser.add_argument("--output-dir", default=str(OUTPUT_DIR))
    args = parser.parse_args()

    sites = list(SCRAPERS.keys()) if args.site == "all" else [args.site]
    output_dir = Path(getattr(args, 'output_dir', str(OUTPUT_DIR)))

    print(f"Sites: {sites}")
    print(f"Location: {args.location}")
    print(f"Output: {OUTPUT_DIR}")

    results = run(sites, args.location, OUTPUT_DIR)

    total = sum(len(v) for v in results.values())
    print(f"\n=== DONE: {total} total listings across {len(sites)} sites ===")
    for site, listings in results.items():
        print(f"  {site}: {len(listings)}")

if __name__ == "__main__":
    main()
