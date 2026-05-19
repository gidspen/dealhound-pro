"""
Scraper — NicheInvestments sister sites (SelfStorages.com, MobileHomeParkStore.com)

Same NicheInvestments LLC platform as RVParkStore.com — identical HTML structure:
  div.item > div.item-info > a.item-title, div.item-price, div.item-location

SelfStorages.com: /self-storages-for-sale/{state}/all
MobileHomeParkStore.com: /mobile-home-parks-for-sale/{state}/all

Both confirmed via footer link from rvparkstore.com.
"""
from __future__ import annotations

import logging
import re
import time
from datetime import datetime, timezone
from typing import Optional

from bs4 import BeautifulSoup

from offmarket.discovery.base import Listing, get, parse_price, POLITENESS_SEC
from offmarket.discovery.scrapers.rvparkstore import STATE_SLUGS

logger = logging.getLogger(__name__)


def _scrape_site(
    base_url: str,
    url_path_template: str,  # e.g. "/mobile-home-parks-for-sale/{slug}/all"
    source_id: str,
    asset_type: str,
    states: Optional[list[str]] = None,
    max_pages_per_state: int = 10,
) -> list[Listing]:
    # If template has no {slug}, scrape once as a national URL
    if "{slug}" not in url_path_template:
        return _scrape_state(base_url, url_path_template, source_id, asset_type, "national", "", max_pages_per_state)

    if states is None:
        states = list(STATE_SLUGS.keys())

    results: list[Listing] = []
    for state in states:
        slug = STATE_SLUGS.get(state.upper())
        if not slug:
            continue
        results.extend(
            _scrape_state(base_url, url_path_template, source_id, asset_type, state.upper(), slug, max_pages_per_state)
        )
    return results


def _scrape_state(base_url, path_tpl, source_id, asset_type, state, slug, max_pages):
    listings: list[Listing] = []
    for page in range(1, max_pages + 1):
        base_path = path_tpl.format(slug=slug) if "{slug}" in path_tpl else path_tpl
        url = f"{base_url}{base_path}" if page == 1 else f"{base_url}{base_path}/page/{page}"

        time.sleep(POLITENESS_SEC)
        html = get(url)
        if not html:
            break

        soup = BeautifulSoup(html, "html.parser")
        cards = soup.select("div.item")
        if not cards:
            break

        for card in cards:
            listing = _parse_card(card, base_url, source_id, asset_type, state)
            if listing:
                listings.append(listing)

        logger.info("%s %s page %d: %d cards", source_id, state, page, len(cards))
        if not soup.select_one("a[href*='/page/']"):
            break

    return listings


def _parse_card(card, base_url, source_id, asset_type, state) -> Optional[Listing]:
    now = datetime.now(timezone.utc).isoformat()

    title_el = card.select_one("a.item-title")
    if not title_el:
        return None
    title = title_el.get_text(strip=True)
    href = title_el.get("href", "")
    url = href if href.startswith("http") else base_url + href

    price_el = card.select_one("div.item-price")
    price_text = price_el.get_text(strip=True) if price_el else ""
    asking_price = parse_price(price_text)

    loc_el = card.select_one("div.item-location")
    location = state
    if loc_el:
        city = loc_el.select_one("span[itemprop='addressLocality']")
        region = loc_el.select_one("span[itemprop='addressRegion']")
        if city and region:
            location = f"{city.get_text(strip=True)}, {region.get_text(strip=True)}"
        else:
            location = loc_el.get_text(strip=True) or state

    detail_el = card.select_one("div.item-details-i")
    size_metric = None
    if detail_el:
        text = detail_el.get_text(" ", strip=True)
        m = re.match(r"(\d+\s*\w+)", text)
        if m:
            size_metric = m.group(1).strip()

    return Listing(
        source=source_id,
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


def scrape_selfstorages(states: Optional[list[str]] = None) -> list[Listing]:
    # Only 3 total US listings; site uses /usa not state slugs
    return _scrape_site(
        base_url="https://www.selfstorages.com",
        url_path_template="/self-storages-for-sale/usa",
        source_id="selfstorages",
        asset_type="self_storage",
        states=None,   # state param not used — always national
    )


def scrape_mobilehomeparks(states: Optional[list[str]] = None) -> list[Listing]:
    return _scrape_site(
        base_url="https://www.mobilehomeparkstore.com",
        url_path_template="/mobile-home-parks-for-sale/{slug}/all",
        source_id="mobilehomeparkstore",
        asset_type="rv_park",
        states=states,
    )
