"""
Scraper — LandWatch.com (recreational / campground land)

LandWatch lists campground/RV park/retreat properties alongside raw land.
Filtering by "Recreation" type surfaces relevant inventory.

TX recreational land: /texas-land-for-sale/type-recreation/
National campground search: /land-for-sale/?search=campground

HTML structure (training data — LandWatch uses React but initial HTML includes
listing data in a JSON blob under window.__INITIAL_STATE__ or similar):
  div.card-listing or div.property-card
    a.card-title or h2 a    → title + href
    span.price              → price
    span.location           → location
    ul.property-details li  → acreage, type

Medium bot risk — may need residential IP. Falls back gracefully.
"""
from __future__ import annotations

import json
import logging
import re
import time
from datetime import datetime, timezone
from typing import Optional

from bs4 import BeautifulSoup

from offmarket.discovery.base import Listing, get, parse_price, POLITENESS_SEC

logger = logging.getLogger(__name__)

BASE = "https://www.landwatch.com"


def scrape(states: Optional[list[str]] = None, max_pages: int = 5) -> list[Listing]:
    results: list[Listing] = []

    if states:
        for state in states:
            results.extend(_scrape_state(state.upper(), max_pages))
    else:
        # Default to national campground search
        results.extend(_scrape_url(
            f"{BASE}/land-for-sale/?search=campground+rv+park",
            "campground",
            max_pages,
        ))

    return results


def _scrape_state(state: str, max_pages: int) -> list[Listing]:
    slug = state.lower()
    url = f"{BASE}/{slug}-land-for-sale/type-recreation/"
    return _scrape_url(url, "campground", max_pages, state)


def _scrape_url(base_url: str, asset_type: str, max_pages: int, state: str = "") -> list[Listing]:
    listings: list[Listing] = []
    for page in range(1, max_pages + 1):
        url = base_url if page == 1 else f"{base_url}?page={page}"

        time.sleep(POLITENESS_SEC)
        html = get(url)
        if not html:
            logger.warning("landwatch: no response for %s (page %d)", url, page)
            break

        # Try JSON state blob first (React SSR)
        json_listings = _extract_json_listings(html, asset_type)
        if json_listings:
            listings.extend(json_listings)
            logger.info("landwatch %s page %d: %d from JSON blob", state or "all", page, len(json_listings))
        else:
            # Fall back to HTML parsing
            soup = BeautifulSoup(html, "html.parser")
            cards = _find_cards(soup)
            if not cards:
                break
            for card in cards:
                listing = _parse_card(card, asset_type)
                if listing:
                    listings.append(listing)
            logger.info("landwatch %s page %d: %d from HTML", state or "all", page, len(cards))

        if not _has_next(html, page):
            break

    return listings


def _extract_json_listings(html: str, asset_type: str) -> list[Listing]:
    """Attempt to pull listing data from React/Next.js SSR JSON blob."""
    now = datetime.now(timezone.utc).isoformat()
    listings = []

    # Look for __NEXT_DATA__ or similar patterns
    patterns = [
        r'window\.__INITIAL_STATE__\s*=\s*({.+?});\s*</script>',
        r'<script id="__NEXT_DATA__"[^>]*>({.+?})</script>',
        r'"listings"\s*:\s*(\[.+?\])',
    ]
    for pat in patterns:
        m = re.search(pat, html, re.DOTALL)
        if not m:
            continue
        try:
            data = json.loads(m.group(1))
        except (json.JSONDecodeError, IndexError):
            continue

        # Try to extract a list of property objects from the blob
        props = _dig_listings(data)
        for prop in props[:50]:
            listing = _json_to_listing(prop, asset_type, now)
            if listing:
                listings.append(listing)
        if listings:
            return listings

    return []


def _dig_listings(obj, depth=0):
    """Recursively search for a list of dicts with 'price' or 'title' keys."""
    if depth > 5:
        return []
    if isinstance(obj, list) and obj and isinstance(obj[0], dict):
        if any(k in obj[0] for k in ("price", "title", "name", "acres")):
            return obj
    if isinstance(obj, dict):
        for v in obj.values():
            result = _dig_listings(v, depth + 1)
            if result:
                return result
    return []


def _json_to_listing(prop: dict, asset_type: str, now: str) -> Optional[Listing]:
    title = prop.get("title") or prop.get("name") or prop.get("label", "")
    if not title:
        return None

    url_path = prop.get("url") or prop.get("href") or prop.get("link", "")
    url = url_path if url_path.startswith("http") else BASE + url_path

    price_raw = prop.get("price") or prop.get("askingPrice") or prop.get("listPrice")
    asking_price = parse_price(str(price_raw)) if price_raw else None

    location = prop.get("location") or prop.get("city") or prop.get("state") or ""
    if isinstance(location, dict):
        location = f"{location.get('city', '')}, {location.get('state', '')}".strip(", ")

    acres = prop.get("acres") or prop.get("acreage")
    size_metric = f"{acres} acres" if acres else None

    return Listing(
        source="landwatch",
        url=url,
        title=str(title),
        location=str(location),
        asking_price=asking_price,
        asset_type=asset_type,
        size_metric=size_metric,
        description=prop.get("description", "")[:400] if prop.get("description") else None,
        posted_date=str(prop.get("listedDate", "")) or None,
        broker_name=None,
        broker_phone=None,
        broker_email=None,
        scraped_at=now,
    )


def _find_cards(soup: BeautifulSoup):
    for sel in [
        "div.card-listing",
        "div.property-card",
        "div[class*='listing']",
        "article.property",
        "li.property",
    ]:
        cards = soup.select(sel)
        if cards:
            return cards
    return []


def _parse_card(card, asset_type: str) -> Optional[Listing]:
    now = datetime.now(timezone.utc).isoformat()

    title_el = card.select_one("a.card-title") or card.select_one("h2 a") or card.select_one("h3 a")
    if not title_el:
        return None

    title = title_el.get_text(strip=True)
    href = title_el.get("href", "")
    url = href if href.startswith("http") else BASE + href

    price_el = card.select_one("span.price") or card.select_one("[class*='price']")
    asking_price = parse_price(price_el.get_text(strip=True)) if price_el else None

    loc_el = card.select_one("span.location") or card.select_one("[class*='location']")
    location = loc_el.get_text(strip=True) if loc_el else ""

    # Acreage
    acres_el = card.select_one("[class*='acres']")
    size_metric = acres_el.get_text(strip=True) if acres_el else None

    return Listing(
        source="landwatch",
        url=url,
        title=title,
        location=location,
        asking_price=asking_price,
        asset_type=asset_type,
        size_metric=size_metric,
        description=None,
        posted_date=None,
        broker_name=None,
        broker_phone=None,
        broker_email=None,
        scraped_at=now,
    )


def _has_next(html: str, page: int) -> bool:
    return bool(re.search(rf'["\']page={page + 1}["\']|page/{page + 1}', html))
