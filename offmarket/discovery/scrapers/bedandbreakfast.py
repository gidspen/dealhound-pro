"""
Scraper — BedAndBreakfast.com "For Sale" section

Dedicated B&B/inn marketplace. Has a public "For Sale" section listing
inns, small hotels, and B&Bs seeking new owners. Owner-listed + broker-listed.

Browse URL: https://www.bedandbreakfast.com/for-sale/
Optional state filter: https://www.bedandbreakfast.com/for-sale/?state=TX

HTML structure (training data):
  div.property-listing or div.listing-card
    h2 a or h3 a         → title + href
    span.price or .asking → price
    span.location         → city, state
    div.description       → snippet
    span.rooms or .units  → room count (size metric)
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

BASE = "https://www.bedandbreakfast.com"
BROWSE_URL = f"{BASE}/for-sale/"


def scrape(states: Optional[list[str]] = None, max_pages: int = 10) -> list[Listing]:
    results: list[Listing] = []
    if states:
        for state in states:
            results.extend(_scrape_pages(state.upper(), max_pages))
    else:
        results.extend(_scrape_pages(None, max_pages))
    return results


def _scrape_pages(state: Optional[str], max_pages: int) -> list[Listing]:
    listings: list[Listing] = []
    for page in range(1, max_pages + 1):
        url = BROWSE_URL
        if state:
            url += f"?state={state}"
        if page > 1:
            sep = "&" if state else "?"
            url += f"{sep}page={page}"

        time.sleep(POLITENESS_SEC)
        html = get(url)
        if not html:
            logger.warning("bedandbreakfast: no response for %s", url)
            break

        soup = BeautifulSoup(html, "html.parser")
        cards = _find_cards(soup)
        if not cards:
            break

        for card in cards:
            listing = _parse_card(card)
            if listing:
                listings.append(listing)

        logger.info("bedandbreakfast /%s page %d: %d listings", state or "all", page, len(cards))

        if not _has_next(soup, page):
            break

    return listings


def _find_cards(soup: BeautifulSoup):
    for sel in [
        "div.property-listing",
        "div.listing-card",
        "div[class*='listing']",
        "article.property",
        "div.property-card",
        "li.listing",
    ]:
        cards = soup.select(sel)
        if cards:
            return cards
    return []


def _parse_card(card) -> Optional[Listing]:
    now = datetime.now(timezone.utc).isoformat()

    title_el = (
        card.select_one("h2 a")
        or card.select_one("h3 a")
        or card.select_one("a[class*='title']")
        or card.select_one("a[href*='/bed-and-breakfast/']")
        or card.select_one("a[href*='/inn/']")
    )
    if not title_el:
        return None

    title = title_el.get_text(strip=True)
    href = title_el.get("href", "")
    url = href if href.startswith("http") else BASE + href

    price_el = (
        card.select_one("span.price")
        or card.select_one("span.asking")
        or card.select_one("[class*='price']")
    )
    price_text = price_el.get_text(strip=True) if price_el else ""
    asking_price = parse_price(price_text)

    loc_el = card.select_one("span.location") or card.select_one("[class*='location']")
    location = loc_el.get_text(strip=True) if loc_el else ""

    # Room count as size metric
    rooms_el = card.select_one("span.rooms") or card.select_one("[class*='rooms']")
    size_metric = rooms_el.get_text(strip=True) if rooms_el else None
    if size_metric:
        size_metric = re.sub(r"\s+", " ", size_metric)

    desc_el = card.select_one("div.description") or card.select_one("p")
    description = desc_el.get_text(strip=True)[:400] if desc_el else None

    return Listing(
        source="bedandbreakfast",
        url=url,
        title=title,
        location=location,
        asking_price=asking_price,
        asset_type="inn",
        size_metric=size_metric,
        description=description,
        posted_date=None,
        broker_name=None,
        broker_phone=None,
        broker_email=None,
        scraped_at=now,
    )


def _has_next(soup, page):
    return bool(soup.select_one(f"a[href*='page={page + 1}']") or soup.select_one("a.next-page"))
