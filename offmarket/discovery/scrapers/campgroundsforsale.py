"""
Scraper — CampgroundsForSale.com

CONFIRMED from cloud (landing page content verified 2026-05-18).

Browse page: https://www.campgroundsforsale.com/buy-campground
Listing detail: https://www.campgroundsforsale.com/properties/{id}

The browse page lists available properties with size metrics (N sites, X acres)
but not price (price is on the detail page). We scrape the browse index for
URLs/titles, then optionally fetch detail pages for price.

HTML structure (from WebFetch 2026-05-18):
- Each listing links to /properties/{id}
- Detail page has price, description, contact
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

BASE = "https://www.campgroundsforsale.com"
BROWSE_URL = f"{BASE}/buy-campground"


def scrape(fetch_details: bool = True, max_listings: int = 100) -> list[Listing]:
    """
    Scrape campground listings.

    Args:
        fetch_details: if True, fetch each listing's detail page for price.
        max_listings: cap to avoid very long runs.
    """
    html = get(BROWSE_URL)
    if not html:
        logger.warning("campgroundsforsale: failed to fetch browse page")
        return []

    soup = BeautifulSoup(html, "html.parser")
    listing_links = _extract_listing_links(soup)
    logger.info("campgroundsforsale: found %d listing links", len(listing_links))

    results: list[Listing] = []
    for href in listing_links[:max_listings]:
        url = href if href.startswith("http") else BASE + href

        if fetch_details:
            time.sleep(POLITENESS_SEC)
            detail_html = get(url)
            listing = _parse_detail(url, detail_html)
        else:
            listing = Listing(
                source="campgroundsforsale",
                url=url,
                title=_slug_to_title(href),
                location="",
                asking_price=None,
                asset_type="campground",
                size_metric=None,
                description=None,
                posted_date=None,
                broker_name=None,
                broker_phone=None,
                broker_email=None,
                scraped_at=datetime.now(timezone.utc).isoformat(),
            )

        if listing:
            results.append(listing)

    return results


def _extract_listing_links(soup: BeautifulSoup) -> list[str]:
    """Pull all /properties/{id} hrefs from the browse page."""
    links = []
    seen = set()
    for a in soup.find_all("a", href=True):
        href = a["href"]
        if re.match(r"^/?properties/\d+", href) and href not in seen:
            seen.add(href)
            links.append(href)
    return links


def _parse_detail(url: str, html: Optional[str]) -> Optional[Listing]:
    now = datetime.now(timezone.utc).isoformat()
    if not html:
        logger.warning("campgroundsforsale: empty detail page %s", url)
        return Listing(
            source="campgroundsforsale",
            url=url,
            title=url.split("/")[-1],
            location="",
            asking_price=None,
            asset_type="campground",
            size_metric=None,
            description=None,
            posted_date=None,
            broker_name=None,
            broker_phone=None,
            broker_email=None,
            scraped_at=now,
        )

    soup = BeautifulSoup(html, "html.parser")

    # Title — h1 or og:title
    title_el = soup.find("h1")
    og_title = soup.find("meta", property="og:title")
    title = (
        title_el.get_text(strip=True) if title_el
        else (og_title.get("content", "") if og_title else "Unknown")
    )

    # Price — look for $ amounts in the page
    price_text = ""
    for el in soup.find_all(string=re.compile(r"\$[\d,]+")):
        m = re.search(r"\$[\d,]+", el)
        if m:
            price_text = m.group(0)
            break
    asking_price = parse_price(price_text)

    # Location — look for state/city patterns
    location = ""
    for el in soup.find_all(string=re.compile(r", [A-Z]{2}(\s|$)")):
        m = re.search(r"([A-Za-z\s]+,\s*[A-Z]{2})", el)
        if m:
            location = m.group(1).strip()
            break

    # Size metric — "N sites" or "N acres"
    size_metric = None
    for el in soup.find_all(string=re.compile(r"\d+\s*(sites?|acres?|lots?|pads?)", re.I)):
        m = re.search(r"(\d+\s*(?:sites?|acres?|lots?|pads?))", el, re.I)
        if m:
            size_metric = m.group(1).strip()
            break

    # Description — first non-empty paragraph or meta description
    desc_el = soup.find("meta", attrs={"name": "description"})
    description = desc_el.get("content", "") if desc_el else None

    # Broker info — look for phone patterns
    phone_match = re.search(r"(\(?\d{3}\)?[\s\-]\d{3}[\s\-]\d{4})", html or "")
    broker_phone = phone_match.group(1) if phone_match else None

    return Listing(
        source="campgroundsforsale",
        url=url,
        title=title,
        location=location,
        asking_price=asking_price,
        asset_type="campground",
        size_metric=size_metric,
        description=description,
        posted_date=None,
        broker_name=None,
        broker_phone=broker_phone,
        broker_email=None,
        scraped_at=now,
    )


def _slug_to_title(href: str) -> str:
    """Convert /properties/42 → 'Property 42' as fallback title."""
    m = re.search(r"/(\d+)$", href)
    return f"Property {m.group(1)}" if m else href
