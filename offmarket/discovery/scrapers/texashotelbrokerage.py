"""
Scraper — Texas Hotel Brokerage (texashotelbrokerage.com)

TX-specific boutique hotel/hospitality brokerage. Small site, minimal bot defense.
Limited volume (~5-20 listings) but high relevance: Hill Country, Gulf Coast, DFW.

HTML structure (small broker site, likely WordPress):
  div.listing or div.property or article
    h2 a or h3 a           → title + href
    span.price or p.price  → asking price
    span.location or p     → location
    div.details or p       → description
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

BASE = "https://www.texashotelbrokerage.com"


def scrape() -> list[Listing]:
    results: list[Listing] = []

    for path in ["/listings/", "/properties/", "/hotels-for-sale/", "/"]:
        time.sleep(POLITENESS_SEC)
        html = get(BASE + path)
        if not html:
            continue

        soup = BeautifulSoup(html, "html.parser")
        cards = _find_cards(soup)
        if cards:
            for card in cards:
                listing = _parse_card(card)
                if listing:
                    results.append(listing)
            logger.info("texashotelbrokerage %s: %d listings", path, len(cards))
            break

        # Fallback: look for any hotel listing links in the page
        listing_links = _find_listing_links(soup)
        if listing_links:
            for href in listing_links[:20]:
                url = href if href.startswith("http") else BASE + href
                time.sleep(POLITENESS_SEC)
                detail_html = get(url)
                listing = _parse_detail(url, detail_html)
                if listing:
                    results.append(listing)
            if results:
                break

    return results


def _find_cards(soup: BeautifulSoup):
    for sel in [
        "div.listing",
        "div.property",
        "article.listing",
        "div[class*='property']",
        "div[class*='listing']",
        "div.hotel-listing",
    ]:
        cards = soup.select(sel)
        if cards:
            return cards
    return []


def _find_listing_links(soup: BeautifulSoup) -> list[str]:
    """Find any links that look like individual property detail pages."""
    links = []
    seen = set()
    for a in soup.find_all("a", href=True):
        href = a["href"]
        if re.search(r"/(listing|property|hotel|inn)/\d+|/listing-[a-z]", href, re.I):
            if href not in seen:
                seen.add(href)
                links.append(href)
    return links


def _parse_card(card) -> Optional[Listing]:
    now = datetime.now(timezone.utc).isoformat()

    title_el = card.select_one("h2 a") or card.select_one("h3 a") or card.select_one("h4 a")
    if not title_el:
        return None

    title = title_el.get_text(strip=True)
    href = title_el.get("href", "")
    url = href if href.startswith("http") else BASE + href

    price_text = ""
    for el in card.find_all(string=re.compile(r"\$[\d,]+")):
        m = re.search(r"\$[\d,]+", el)
        if m:
            price_text = m.group(0)
            break
    asking_price = parse_price(price_text)

    location = ""
    loc_el = card.select_one("span.location") or card.select_one("p.location")
    if loc_el:
        location = loc_el.get_text(strip=True)
    else:
        for el in card.find_all(string=re.compile(r",\s*TX")):
            m = re.search(r"([A-Za-z\s]+,\s*TX)", el)
            if m:
                location = m.group(1).strip()
                break

    desc_el = card.select_one("div.description") or card.select_one("p")
    description = desc_el.get_text(strip=True)[:400] if desc_el else None

    return Listing(
        source="texashotelbrokerage",
        url=url,
        title=title,
        location=location,
        asking_price=asking_price,
        asset_type="boutique_hotel",
        size_metric=None,
        description=description,
        posted_date=None,
        broker_name="Texas Hotel Brokerage",
        broker_phone=None,
        broker_email=None,
        scraped_at=now,
    )


def _parse_detail(url: str, html: Optional[str]) -> Optional[Listing]:
    """Parse a detail page when no index cards are found."""
    now = datetime.now(timezone.utc).isoformat()
    if not html:
        return None

    soup = BeautifulSoup(html, "html.parser")

    title_el = soup.find("h1")
    title = title_el.get_text(strip=True) if title_el else url.split("/")[-1]

    price_match = re.search(r"\$[\d,]+", html)
    asking_price = parse_price(price_match.group(0)) if price_match else None

    location = ""
    for el in soup.find_all(string=re.compile(r",\s*TX")):
        m = re.search(r"([A-Za-z\s]+,\s*TX)", el)
        if m:
            location = m.group(1).strip()
            break

    desc_el = soup.find("meta", attrs={"name": "description"})
    description = desc_el.get("content", "")[:400] if desc_el else None

    return Listing(
        source="texashotelbrokerage",
        url=url,
        title=title,
        location=location,
        asking_price=asking_price,
        asset_type="boutique_hotel",
        size_metric=None,
        description=description,
        posted_date=None,
        broker_name="Texas Hotel Brokerage",
        broker_phone=None,
        broker_email=None,
        scraped_at=now,
    )
