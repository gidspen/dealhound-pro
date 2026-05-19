"""
Buy-box filter for discovered listings.

Buy-box JSON schema:
{
  "asset_types": ["rv_park", "campground"],        // required; matches source asset_type
  "geo": {
    "states": ["TX", "TN", "NC"],                  // 2-letter state codes; null = any
    "regions": ["Hill Country", "Smokies"]         // text substring match on location; null = any
  },
  "price_min": 500000,                             // null = no lower bound
  "price_max": 5000000,                            // null = no upper bound (includes "Call for Price")
  "size_min": 10,                                  // min lots/units/sites; null = any
  "size_max": 500,                                 // max lots/units/sites; null = any
  "include_undisclosed_price": true                // include listings with asking_price=None
}
"""
from __future__ import annotations

import json
import re
from pathlib import Path
from typing import Optional

from offmarket.discovery.base import Listing


def load_buy_box(path: str) -> dict:
    with open(path) as f:
        return json.load(f)


def filter_listings(listings: list[Listing], buy_box: dict) -> list[Listing]:
    """
    Apply buy-box hard gates. Returns matched listings sorted by most recently scraped.

    Gates applied in order:
    1. asset_type ∈ buy_box["asset_types"]
    2. geo.states match (if specified)
    3. geo.regions match (if specified)
    4. price band (if specified)
    5. size band (if specified)
    """
    matched = []
    for listing in listings:
        if _passes(listing, buy_box):
            matched.append(listing)

    # Sort by scraped_at descending (most recent first)
    matched.sort(key=lambda x: x.scraped_at, reverse=True)
    return matched


def _passes(listing: Listing, bb: dict) -> bool:
    # 1. Asset type gate
    allowed_types = bb.get("asset_types")
    if allowed_types and listing.asset_type not in allowed_types:
        return False

    # 2. Geo: states
    geo = bb.get("geo") or {}
    states = geo.get("states")
    if states:
        matched_state = any(
            _state_in_location(state, listing.location) for state in states
        )
        if not matched_state:
            return False

    # 3. Geo: regions (substring match)
    regions = geo.get("regions")
    if regions:
        matched_region = any(
            region.lower() in listing.location.lower() for region in regions
        )
        if not matched_region:
            return False

    # 4. Price band
    include_undisclosed = bb.get("include_undisclosed_price", True)
    if listing.asking_price is None:
        if not include_undisclosed:
            return False
    else:
        price_min = bb.get("price_min")
        price_max = bb.get("price_max")
        if price_min is not None and listing.asking_price < price_min:
            return False
        if price_max is not None and listing.asking_price > price_max:
            return False

    # 5. Size band
    size_num = _extract_number(listing.size_metric)
    size_min = bb.get("size_min")
    size_max = bb.get("size_max")
    if size_num is not None:
        if size_min is not None and size_num < size_min:
            return False
        if size_max is not None and size_num > size_max:
            return False

    return True


def _state_in_location(state_code: str, location: str) -> bool:
    """Check if 2-letter state code appears in location string."""
    if not location:
        return False
    # Match ", TX" or " TX " or "Texas" patterns
    abbrev_pat = rf"\b{re.escape(state_code)}\b"
    return bool(re.search(abbrev_pat, location))


def _extract_number(size_metric: Optional[str]) -> Optional[float]:
    """Extract leading number from '39 Lots', '84.2 acres', etc."""
    if not size_metric:
        return None
    m = re.match(r"([\d,\.]+)", size_metric.strip())
    if m:
        try:
            return float(m.group(1).replace(",", ""))
        except ValueError:
            pass
    return None
