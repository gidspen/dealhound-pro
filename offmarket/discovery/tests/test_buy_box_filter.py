"""Pure-logic tests for the buy-box filter."""
from __future__ import annotations

from datetime import datetime, timezone

import pytest

from offmarket.discovery.base import Listing
from offmarket.discovery.filter import filter_listings


def _make(
    *,
    title: str,
    asset_type: str = "rv_park",
    location: str = "Austin, TX",
    asking_price: int | None = 1_500_000,
    size_metric: str | None = "50 Lots",
    scraped_at: str | None = None,
) -> Listing:
    return Listing(
        source="test",
        url=f"https://example.com/{title.replace(' ', '-').lower()}",
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
        scraped_at=scraped_at or datetime.now(timezone.utc).isoformat(),
    )


BUY_BOX = {
    "asset_types": ["rv_park"],
    "geo": {"states": ["TX"]},
    "price_min": 500_000,
    "price_max": 5_000_000,
    "size_min": 10,
    "size_max": 300,
    "include_undisclosed_price": True,
}


@pytest.fixture
def listings() -> list[Listing]:
    return [
        # --- 3 matching ---
        _make(title="Match A", location="Austin, TX", asking_price=1_200_000, size_metric="50 Lots"),
        _make(title="Match B", location="Hill Country, TX", asking_price=900_000, size_metric="80 Lots"),
        _make(title="Match C", location="Houston, TX", asking_price=2_500_000, size_metric="120 Lots"),
        # --- wrong asset type ---
        _make(title="Wrong Asset", asset_type="self_storage", location="Dallas, TX",
              asking_price=1_500_000, size_metric="60 Units"),
        # --- wrong state ---
        _make(title="Wrong State", location="Los Angeles, CA",
              asking_price=1_500_000, size_metric="50 Lots"),
        # --- below price min ---
        _make(title="Too Cheap", location="Austin, TX",
              asking_price=100_000, size_metric="50 Lots"),
        # --- above price max ---
        _make(title="Too Pricey", location="Austin, TX",
              asking_price=10_000_000, size_metric="50 Lots"),
        # --- size below min ---
        _make(title="Too Small", location="Austin, TX",
              asking_price=1_500_000, size_metric="3 Lots"),
        # --- size above max ---
        _make(title="Too Big", location="Austin, TX",
              asking_price=1_500_000, size_metric="500 Lots"),
        # --- undisclosed price ---
        _make(title="Call For Price", location="San Antonio, TX",
              asking_price=None, size_metric="40 Lots"),
    ]


def test_filter_includes_undisclosed_when_flag_true(listings):
    result = filter_listings(listings, BUY_BOX)
    titles = sorted(l.title for l in result)
    assert titles == sorted(["Match A", "Match B", "Match C", "Call For Price"])
    assert len(result) == 4


def test_filter_excludes_undisclosed_when_flag_false(listings):
    bb = {**BUY_BOX, "include_undisclosed_price": False}
    result = filter_listings(listings, bb)
    titles = sorted(l.title for l in result)
    assert titles == sorted(["Match A", "Match B", "Match C"])
    assert len(result) == 3
