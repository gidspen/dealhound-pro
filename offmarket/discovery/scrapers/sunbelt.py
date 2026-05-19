"""
Scraper — Sunbelt Business Brokers (sunbeltnetwork.com)

Largest US business broker. HIGH bot risk — 403 confirmed from cloud IPs.
Include with explicit fallback logging; scraper runs but logs failures gracefully.

Search URL: https://www.sunbeltnetwork.com/businesses-for-sale/
Category filter via search form: /businesses-for-sale/?type={type}&state={state}

Listing cards (training data):
  div.listing-card or div.result-card
    h3 a                → title + href
    span.price          → price
    span.location       → location
    p.description       → snippet
"""
from __future__ import annotations

import logging
import re
import time
from datetime import datetime, timezone
from typing import Optional
from urllib.parse import urlencode

from bs4 import BeautifulSoup

from offmarket.discovery.base import Listing, get, parse_price, POLITENESS_SEC

logger = logging.getLogger(__name__)

BASE = "https://www.sunbeltnetwork.com"

TYPES = {
    "campground": ("campground", "campground"),
    "hotel": ("hotel", "boutique_hotel"),
    "storage": ("self-storage", "self_storage"),
}


def scrape(
    industry: str = "campground",
    states: Optional[list[str]] = None,
    max_pages: int = 5,
) -> list[Listing]:
    if industry not in TYPES:
        raise ValueError(f"Unknown industry: {industry}")

    type_slug, asset_type = TYPES[industry]
    results: list[Listing] = []

    if states:
        for state in states:
            results.extend(_scrape_pages(type_slug, asset_type, state.upper(), max_pages))
    else:
        results.extend(_scrape_pages(type_slug, asset_type, None, max_pages))

    return results


def _scrape_pages(type_slug, asset_type, state, max_pages):
    listings: list[Listing] = []
    for page in range(1, max_pages + 1):
        params: dict = {"type": type_slug}
        if state:
            params["state"] = state
        if page > 1:
            params["page"] = page

        url = f"{BASE}/businesses-for-sale/?{urlencode(params)}"
        time.sleep(POLITENESS_SEC)
        html = get(url)
        if not html:
            logger.warning(
                "sunbelt: HTTP failure for %s — likely bot block. "
                "Run from residential IP for results.", url
            )
            break

        soup = BeautifulSoup(html, "html.parser")
        cards = _find_cards(soup)
        if not cards:
            logger.info("sunbelt: no cards found on %s (page %d)", url, page)
            break

        for card in cards:
            listing = _parse_card(card, asset_type)
            if listing:
                listings.append(listing)

        logger.info("sunbelt '%s'/%s page %d: %d listings", type_slug, state or "all", page, len(cards))
        if not _has_next(soup, page):
            break

    return listings


def _find_cards(soup: BeautifulSoup):
    for sel in [
        "div.listing-card",
        "div.result-card",
        "div[class*='listing']",
        "article.listing",
        "li.listing-item",
    ]:
        cards = soup.select(sel)
        if cards:
            return cards
    return []


def _parse_card(card, asset_type: str) -> Optional[Listing]:
    now = datetime.now(timezone.utc).isoformat()

    title_el = card.select_one("h3 a") or card.select_one("h2 a") or card.select_one("a")
    if not title_el:
        return None

    title = title_el.get_text(strip=True)
    href = title_el.get("href", "")
    url = href if href.startswith("http") else BASE + href

    price_el = card.select_one("span.price") or card.select_one("[class*='price']")
    asking_price = parse_price(price_el.get_text(strip=True)) if price_el else None

    loc_el = card.select_one("span.location") or card.select_one("[class*='location']")
    location = loc_el.get_text(strip=True) if loc_el else ""

    desc_el = card.select_one("p.description") or card.select_one("p")
    description = desc_el.get_text(strip=True)[:400] if desc_el else None

    return Listing(
        source="sunbelt",
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


def _has_next(soup, page):
    return bool(soup.select_one(f"a[href*='page={page + 1}']") or soup.select_one("a.next"))
