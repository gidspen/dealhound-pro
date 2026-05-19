"""
Scraper — RV Park Store (rvparkstore.com)

CONFIRMED working from cloud and residential IPs.

URL pattern: /rv-parks-for-sale/{state_slug}/all[/page/{n}]
HTML structure (verified via Playwright 2026-05-18):
  div.item
    div.item-image > a[href]
      div.item-price        → price text
    div.item-info
      a.item-title          → listing title + href
      div.item-location     → schema.org address spans
      div.item-details-i    → "N Lots" or similar size metric

Pagination: /page/2, /page/3, ... until no div.item found.
"""
from __future__ import annotations

import logging
import re
import time
from datetime import datetime, timezone
from typing import Optional

from bs4 import BeautifulSoup

from offmarket.discovery.base import Listing, get, parse_price, POLITENESS_SEC

logger = logging.getLogger(__name__)

BASE = "https://www.rvparkstore.com"

STATE_SLUGS = {
    "AL": "alabama", "AK": "alaska", "AZ": "arizona", "AR": "arkansas",
    "CA": "california", "CO": "colorado", "CT": "connecticut", "DE": "delaware",
    "FL": "florida", "GA": "georgia", "HI": "hawaii", "ID": "idaho",
    "IL": "illinois", "IN": "indiana", "IA": "iowa", "KS": "kansas",
    "KY": "kentucky", "LA": "louisiana", "ME": "maine", "MD": "maryland",
    "MA": "massachusetts", "MI": "michigan", "MN": "minnesota", "MS": "mississippi",
    "MO": "missouri", "MT": "montana", "NE": "nebraska", "NV": "nevada",
    "NH": "new-hampshire", "NJ": "new-jersey", "NM": "new-mexico", "NY": "new-york",
    "NC": "north-carolina", "ND": "north-dakota", "OH": "ohio", "OK": "oklahoma",
    "OR": "oregon", "PA": "pennsylvania", "RI": "rhode-island", "SC": "south-carolina",
    "SD": "south-dakota", "TN": "tennessee", "TX": "texas", "UT": "utah",
    "VT": "vermont", "VA": "virginia", "WA": "washington", "WV": "west-virginia",
    "WI": "wisconsin", "WY": "wyoming",
}


def scrape(states: Optional[list[str]] = None, max_pages_per_state: int = 10) -> list[Listing]:
    """
    Scrape RV park listings.

    Args:
        states: list of 2-letter state codes; None = all states.
        max_pages_per_state: safety cap on pagination.
    """
    if states is None:
        states = list(STATE_SLUGS.keys())

    results: list[Listing] = []
    for state in states:
        slug = STATE_SLUGS.get(state.upper())
        if not slug:
            logger.warning("Unknown state code: %s", state)
            continue
        results.extend(_scrape_state(state.upper(), slug, max_pages_per_state))

    return results


def _scrape_state(state: str, slug: str, max_pages: int) -> list[Listing]:
    listings: list[Listing] = []
    for page in range(1, max_pages + 1):
        if page == 1:
            url = f"{BASE}/rv-parks-for-sale/{slug}/all"
        else:
            url = f"{BASE}/rv-parks-for-sale/{slug}/all/page/{page}"

        time.sleep(POLITENESS_SEC)
        html = get(url)
        if not html:
            logger.info("No response for %s page %d — stopping", state, page)
            break

        soup = BeautifulSoup(html, "html.parser")
        cards = soup.select("div.item")
        if not cards:
            break

        for card in cards:
            listing = _parse_card(card, state)
            if listing:
                listings.append(listing)

        logger.info("rvparkstore %s page %d: %d cards", state, page, len(cards))

        # No next page link = last page
        if not soup.select_one("a[href*='/page/']"):
            break

    return listings


def _parse_card(card, state: str) -> Optional[Listing]:
    now = datetime.now(timezone.utc).isoformat()

    # Title + URL
    title_el = card.select_one("a.item-title")
    if not title_el:
        return None
    title = title_el.get_text(strip=True)
    href = title_el.get("href", "")
    url = href if href.startswith("http") else BASE + href

    # Price
    price_el = card.select_one("div.item-price")
    price_text = price_el.get_text(strip=True) if price_el else ""
    asking_price = parse_price(price_text)

    # Location — prefer schema.org spans, fall back to link text
    loc_el = card.select_one("div.item-location")
    location = ""
    if loc_el:
        city = loc_el.select_one("span[itemprop='addressLocality']")
        region = loc_el.select_one("span[itemprop='addressRegion']")
        street = loc_el.select_one("span[itemprop='streetAddress']")
        if city and region:
            location = f"{city.get_text(strip=True)}, {region.get_text(strip=True)}"
            if street:
                location = f"{street.get_text(strip=True)}, {location}"
        else:
            location = loc_el.get_text(strip=True)
    if not location:
        location = state

    # Size metric (e.g. "39 Lots")
    detail_el = card.select_one("div.item-details-i")
    size_metric = None
    if detail_el:
        text = detail_el.get_text(" ", strip=True)
        m = re.match(r"(\d+\s*\w+)", text)
        if m:
            size_metric = m.group(1).strip()

    return Listing(
        source="rvparkstore",
        url=url,
        title=title,
        location=location,
        asking_price=asking_price,
        asset_type="rv_park",
        size_metric=size_metric,
        description=None,
        posted_date=None,
        broker_name=None,
        broker_phone=None,
        broker_email=None,
        scraped_at=now,
    )
