"""
Scraper — BusinessBroker.net

Independent business broker directory. CONFIRMED working from cloud.

URLs (verified via Playwright 2026-05-18):
  Campgrounds: /keyword/campground-businesses-for-sale.aspx
  Hotels:      /industry/services-hotel-motel-businesses-for-sale.aspx
  Storage:     /keyword/self-storage-businesses-for-sale.aspx

HTML structure (confirmed):
  div.result-item.listing      → card container
    data-invest                → price as 8-digit padded int (e.g. "01000000" = $1,000,000)
    data-name                  → listing name
    a[href*="/business-for-sale/"] → detail URL
    .listing-location          → "City, ST" text

Pagination: via ?page=2 query param.
"""
from __future__ import annotations

import logging
import time
from datetime import datetime, timezone
from typing import Optional

from bs4 import BeautifulSoup

from offmarket.discovery.base import Listing, get, POLITENESS_SEC

logger = logging.getLogger(__name__)

BASE = "https://www.businessbroker.net"

URLS = {
    "campground": (f"{BASE}/keyword/campground-businesses-for-sale.aspx", "campground"),
    "hotel": (f"{BASE}/industry/services-hotel-motel-businesses-for-sale.aspx", "boutique_hotel"),
    "storage": (f"{BASE}/keyword/self-storage-businesses-for-sale.aspx", "self_storage"),
    "rv_park": (f"{BASE}/keyword/rv-park-businesses-for-sale.aspx", "rv_park"),
}


def scrape(
    keyword_key: str = "campground",
    states: Optional[list[str]] = None,
    max_pages: int = 5,
    source_id: Optional[str] = None,
) -> list[Listing]:
    if keyword_key not in URLS:
        raise ValueError(f"Unknown keyword: {keyword_key}. Use: {list(URLS)}")

    base_url, asset_type = URLS[keyword_key]
    sid = source_id or f"businessbroker_{keyword_key}"
    return _scrape_pages(base_url, asset_type, states, max_pages, sid)


def _scrape_pages(base_url, asset_type, states, max_pages, source_id="businessbroker") -> list[Listing]:
    listings: list[Listing] = []
    for page in range(1, max_pages + 1):
        url = base_url if page == 1 else f"{base_url}?page={page}"

        time.sleep(POLITENESS_SEC)
        html = get(url)
        if not html:
            logger.warning("businessbroker: no response for %s (page %d)", url, page)
            break

        soup = BeautifulSoup(html, "html.parser")
        cards = soup.select("div.result-item.listing")
        if not cards:
            logger.info("businessbroker: no cards on page %d — done", page)
            break

        page_listings = []
        for card in cards:
            listing = _parse_card(card, asset_type, source_id)
            if listing:
                # State filter post-scrape (site doesn't support state query param reliably)
                if states and not any(f", {st}" in listing.location for st in states):
                    continue
                page_listings.append(listing)

        listings.extend(page_listings)
        logger.info("businessbroker '%s' page %d: %d cards, %d kept", asset_type, page, len(cards), len(page_listings))

        if not _has_next(soup, page):
            break

    return listings


def _parse_card(card, asset_type: str, source_id: str = "businessbroker") -> Optional[Listing]:
    now = datetime.now(timezone.utc).isoformat()

    # Name from data attribute
    title = card.get("data-name", "").strip()

    # Link from anchor
    link_el = card.select_one('a[href*="/business-for-sale/"]')
    if not link_el and not title:
        return None
    href = link_el.get("href", "") if link_el else ""
    url = href if href.startswith("http") else BASE + href

    # Price from data-invest (padded integer, e.g. "01000000" → 1000000)
    invest_raw = card.get("data-invest", "").lstrip("0") or "0"
    try:
        asking_price = int(invest_raw) if invest_raw else None
        if asking_price == 0:
            asking_price = None
    except ValueError:
        asking_price = None

    # Location from first div.location (confirmed via requests HTML 2026-05-18)
    loc_els = card.select("div.location")
    location = loc_els[0].get_text(strip=True) if loc_els else ""

    # Description snippet from inner text
    inner_text = card.get_text(" ", strip=True)
    desc_start = inner_text.find(title)
    description = None
    if desc_start >= 0 and len(inner_text) > desc_start + len(title) + 5:
        description = inner_text[desc_start + len(title):desc_start + len(title) + 400].strip()

    return Listing(
        source=source_id,
        url=url,
        title=title or url.split("/")[-1],
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


def _has_next(soup: BeautifulSoup, page: int) -> bool:
    return bool(soup.select_one(f"a[href*='?page={page + 1}']") or soup.select_one("a.next"))
