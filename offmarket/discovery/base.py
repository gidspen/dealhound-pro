"""Shared types and utilities for off-market discovery scrapers."""
from __future__ import annotations

import logging
import time
from dataclasses import dataclass, field, asdict
from typing import Optional

import requests

logger = logging.getLogger(__name__)

USER_AGENT = (
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 "
    "(KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36"
)
POLITENESS_SEC = 1.5
DEFAULT_TIMEOUT = 25


@dataclass
class Listing:
    source: str
    url: str
    title: str
    location: str
    asking_price: Optional[int]          # None if "Call for Price" / undisclosed
    asset_type: str                       # rv_park | campground | boutique_hotel | glamping | self_storage | inn
    size_metric: Optional[str]            # "39 Lots", "84 acres", "120 units"
    description: Optional[str]
    posted_date: Optional[str]            # ISO date string if available
    broker_name: Optional[str]
    broker_phone: Optional[str]
    broker_email: Optional[str]
    scraped_at: str                       # ISO datetime, always set by scraper

    def to_dict(self) -> dict:
        return asdict(self)


def get(url: str, timeout: int = DEFAULT_TIMEOUT, extra_headers: Optional[dict] = None) -> Optional[str]:
    """GET with residential-friendly headers; returns None on any failure."""
    headers = {"User-Agent": USER_AGENT, "Accept-Language": "en-US,en;q=0.9"}
    if extra_headers:
        headers.update(extra_headers)
    try:
        r = requests.get(url, headers=headers, timeout=timeout)
        if r.status_code == 200:
            return r.text
        logger.warning("HTTP %s fetching %s", r.status_code, url)
    except requests.RequestException as exc:
        logger.warning("Request failed for %s: %s", url, exc)
    return None


def polite_get(url: str, sleep: float = POLITENESS_SEC) -> Optional[str]:
    """GET with politeness delay."""
    time.sleep(sleep)
    return get(url)


def parse_price(text: str) -> Optional[int]:
    """Parse '$1,575,000' → 1575000; 'Call for Price' → None."""
    if not text:
        return None
    cleaned = text.replace("$", "").replace(",", "").strip()
    try:
        return int(float(cleaned))
    except (ValueError, TypeError):
        return None
