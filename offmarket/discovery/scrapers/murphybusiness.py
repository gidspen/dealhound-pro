"""
Scraper — Murphy Business Sales (murphybusiness.com)

Large national franchise broker network. Has campground, hotel, and storage
categories. Medium bot risk — 403 from cloud IPs, residential works.

Browse URL: https://www.murphybusiness.com/businesses-for-sale/
Category filter: ?industry=Campgrounds+%26+RV+Parks
State filter: ?state=TX

Listing cards (training data):
  div.listing-card or div.business-listing
    h3 a or h2 a              → title + href
    span.listing-price         → price
    span.listing-location      → city, state
    p.listing-description      → snippet
    span.listing-industry      → category
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

BASE = "https://www.murphybusiness.com"
BROWSE = f"{BASE}/businesses-for-sale/"

INDUSTRIES = {
    "campground": ("Campgrounds & RV Parks", "campground"),
    "hotel": ("Hotels & Motels", "boutique_hotel"),
    "storage": ("Self-Storage", "self_storage"),
}


def scrape(
    industry: str = "campground",
    states: Optional[list[str]] = None,
    max_pages: int = 5,
) -> list[Listing]:
    if industry not in INDUSTRIES:
        raise ValueError(f"Unknown industry: {industry}")

    industry_label, asset_type = INDUSTRIES[industry]
    results: list[Listing] = []

    if states:
        for state in states:
            results.extend(_scrape_pages(industry_label, asset_type, state.upper(), max_pages))
    else:
        results.extend(_scrape_pages(industry_label, asset_type, None, max_pages))

    return results


def _scrape_pages(industry_label, asset_type, state, max_pages):
    listings: list[Listing] = []
    for page in range(1, max_pages + 1):
        params: dict = {"industry": industry_label}
        if state:
            params["state"] = state
        if page > 1:
            params["page"] = page

        url = f"{BROWSE}?{urlencode(params)}"
        time.sleep(POLITENESS_SEC)
        html = get(url)
        if not html:
            logger.warning("murphybusiness: no response for %s", url)
            break

        soup = BeautifulSoup(html, "html.parser")
        cards = _find_cards(soup)
        if not cards:
            break

        for card in cards:
            listing = _parse_card(card, asset_type)
            if listing:
                listings.append(listing)

        logger.info("murphybusiness '%s'/%s page %d: %d listings", industry_label, state or "all", page, len(cards))
        if not _has_next(soup, page):
            break

    return listings


def _find_cards(soup: BeautifulSoup):
    for sel in [
        "div.listing-card",
        "div.business-listing",
        "div[class*='listing']",
        "article.listing",
        "li.listing",
    ]:
        cards = soup.select(sel)
        if cards:
            return cards
    return []


def _parse_card(card, asset_type: str) -> Optional[Listing]:
    now = datetime.now(timezone.utc).isoformat()

    title_el = card.select_one("h3 a") or card.select_one("h2 a") or card.select_one("a.listing-title")
    if not title_el:
        return None

    title = title_el.get_text(strip=True)
    href = title_el.get("href", "")
    url = href if href.startswith("http") else BASE + href

    price_el = card.select_one("span.listing-price") or card.select_one("[class*='price']")
    asking_price = parse_price(price_el.get_text(strip=True)) if price_el else None

    loc_el = card.select_one("span.listing-location") or card.select_one("[class*='location']")
    location = loc_el.get_text(strip=True) if loc_el else ""

    desc_el = card.select_one("p.listing-description") or card.select_one("p")
    description = desc_el.get_text(strip=True)[:400] if desc_el else None

    return Listing(
        source="murphybusiness",
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
