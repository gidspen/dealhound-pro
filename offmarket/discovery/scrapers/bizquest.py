"""
Scraper — BizQuest.com (multiple categories)

403 from cloud IPs; works from residential. Large business broker marketplace
with clean HTML listing pages.

Category IDs (bid param):
  67 = Campground & RV Park
  29 = Hotel & Motel
  77 = Self Storage

URL pattern: /businesses-for-sale/{category-slug}/bid-{N}/
State filter:  /businesses-for-sale/{category-slug}/bid-{N}/state/TX/

Listing cards (training data + IBBA-member pattern cross-check):
  div.listing-result or div.listing-item
    a.listing-title or h3 a  → title + href
    span.asking-price          → price
    span.listing-location      → city, state
    div.listing-description    → description snippet

Pagination: ?page=2, ?page=3 via query param.
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

BASE = "https://www.bizquest.com"

CATEGORIES = {
    "campground": ("campground-rv-park", "67", "campground"),
    "hotel": ("hotel-motel", "29", "boutique_hotel"),
    "storage": ("self-storage", "77", "self_storage"),
}


def scrape(
    category: str = "campground",
    states: Optional[list[str]] = None,
    max_pages: int = 10,
) -> list[Listing]:
    """
    Args:
        category: 'campground', 'hotel', or 'storage'
        states: list of 2-letter state codes; None = national
        max_pages: pagination cap
    """
    if category not in CATEGORIES:
        raise ValueError(f"Unknown category: {category}. Use: {list(CATEGORIES)}")

    slug, bid, asset_type = CATEGORIES[category]
    results: list[Listing] = []

    if states:
        for state in states:
            results.extend(_scrape_pages(slug, bid, asset_type, state.upper(), max_pages))
    else:
        results.extend(_scrape_pages(slug, bid, asset_type, None, max_pages))

    return results


def _scrape_pages(slug, bid, asset_type, state, max_pages) -> list[Listing]:
    listings: list[Listing] = []
    for page in range(1, max_pages + 1):
        if state:
            url = f"{BASE}/businesses-for-sale/{slug}/bid-{bid}/state/{state}/"
        else:
            url = f"{BASE}/businesses-for-sale/{slug}/bid-{bid}/"
        if page > 1:
            url += f"?page={page}"

        time.sleep(POLITENESS_SEC)
        html = get(url)
        if not html:
            logger.warning("bizquest: no response for %s (page %d)", url, page)
            break

        soup = BeautifulSoup(html, "html.parser")
        cards = _find_cards(soup)
        if not cards:
            logger.info("bizquest: no cards on page %d — done", page)
            break

        for card in cards:
            listing = _parse_card(card, asset_type)
            if listing:
                listings.append(listing)

        logger.info("bizquest %s/%s page %d: %d listings", slug, state or "all", page, len(cards))

        # Stop if no next page
        if not _has_next_page(soup, page):
            break

    return listings


def _find_cards(soup: BeautifulSoup):
    """Try multiple selectors for BizQuest listing cards."""
    for selector in [
        "div.listing-result",
        "div.listing-item",
        "div[class*='listing']",
        "article.listing",
        "div.search-result",
    ]:
        cards = soup.select(selector)
        if cards:
            return cards
    # Fallback: find all links pointing to /businesses-for-sale/ detail pages
    return []


def _parse_card(card, asset_type: str) -> Optional[Listing]:
    now = datetime.now(timezone.utc).isoformat()

    # Title + URL
    title_el = (
        card.select_one("a.listing-title")
        or card.select_one("h3 a")
        or card.select_one("h2 a")
        or card.select_one("a[href*='/business-for-sale/']")
    )
    if not title_el:
        return None

    title = title_el.get_text(strip=True)
    href = title_el.get("href", "")
    url = href if href.startswith("http") else BASE + href

    # Price
    price_el = (
        card.select_one("span.asking-price")
        or card.select_one("span.price")
        or card.select_one("[class*='price']")
    )
    price_text = price_el.get_text(strip=True) if price_el else ""
    asking_price = parse_price(price_text)

    # Location
    loc_el = (
        card.select_one("span.listing-location")
        or card.select_one("span.location")
        or card.select_one("[class*='location']")
    )
    location = loc_el.get_text(strip=True) if loc_el else ""

    # Description snippet
    desc_el = card.select_one("div.listing-description") or card.select_one("p.description")
    description = desc_el.get_text(strip=True)[:500] if desc_el else None

    return Listing(
        source="bizquest",
        url=url,
        title=title,
        location=location,
        asking_price=asking_price,
        asset_type=asset_type,
        size_metric=None,
        description=description,
        posted_date=None,
        broker_name=None,
        broker_phone=None,
        broker_email=None,
        scraped_at=now,
    )


def _has_next_page(soup: BeautifulSoup, current_page: int) -> bool:
    next_link = soup.select_one(f"a[href*='?page={current_page + 1}']")
    return next_link is not None
