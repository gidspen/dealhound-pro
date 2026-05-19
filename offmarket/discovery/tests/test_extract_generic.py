"""Integration test for extract_generic — costs ~$0.05 per run."""
from __future__ import annotations

import os
from pathlib import Path

import pytest
import requests

from offmarket.discovery.extract_generic import extract_listings

FIXTURE_URL = (
    "https://www.businessbroker.net/industry/"
    "services-hotel-motel-businesses-for-sale.aspx"
)
FIXTURE_DIR = Path(__file__).parent / "fixtures"
FIXTURE_PATH = FIXTURE_DIR / "businessbroker_hotel_sample.html"


def _load_fixture() -> str:
    if not FIXTURE_PATH.exists():
        FIXTURE_DIR.mkdir(parents=True, exist_ok=True)
        headers = {
            "User-Agent": (
                "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
                "AppleWebKit/537.36 (KHTML, like Gecko) "
                "Chrome/124.0.0.0 Safari/537.36"
            ),
            "Accept-Language": "en-US,en;q=0.9",
        }
        resp = requests.get(FIXTURE_URL, headers=headers, timeout=30)
        resp.raise_for_status()
        FIXTURE_PATH.write_text(resp.text, encoding="utf-8")
    return FIXTURE_PATH.read_text(encoding="utf-8")


def test_extract_listings_businessbroker_hotels():
    if not os.environ.get("ANTHROPIC_API_KEY"):
        pytest.skip("ANTHROPIC_API_KEY not set")

    html = _load_fixture()
    result = extract_listings(html, FIXTURE_URL, ["boutique_hotel"])

    assert len(result) >= 10, f"expected >=10 listings, got {len(result)}"
    for listing in result:
        assert listing.title, f"empty title on {listing}"
        assert listing.url and listing.url.startswith("http"), (
            f"bad url on {listing}"
        )
        assert listing.location, f"empty location on {listing}"
        assert listing.asset_type == "boutique_hotel", (
            f"unexpected asset_type {listing.asset_type}"
        )
