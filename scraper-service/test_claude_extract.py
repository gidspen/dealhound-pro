import pytest
import json
from pathlib import Path
from claude_extract import extract_listings_from_page_text

FIXTURES = Path(__file__).parent.parent / "tests" / "fixtures"


@pytest.mark.asyncio
async def test_extracts_listings_from_landsearch():
    page_text = (FIXTURES / "landsearch-sample.txt").read_text()
    listings = await extract_listings_from_page_text(
        page_text=page_text,
        source_url="https://www.landsearch.com/properties/resort/texas",
        source_name="landsearch",
    )
    assert len(listings) >= 5, f"Expected at least 5 listings, got {len(listings)}"
    first = listings[0]
    assert "title" in first
    assert "url" in first
    assert "source" in first
    assert first["source"] == "landsearch"


@pytest.mark.asyncio
async def test_extracts_listings_from_bizbuysell():
    page_text = (FIXTURES / "bizbuysell-sample.txt").read_text()
    listings = await extract_listings_from_page_text(
        page_text=page_text,
        source_url="https://www.bizbuysell.com/texas/campgrounds-and-rv-parks-for-sale/",
        source_name="bizbuysell",
    )
    assert len(listings) >= 1, f"Expected at least 1 listing, got {len(listings)}"
    first = listings[0]
    assert "title" in first
    assert "price" in first or first.get("price") is None
    assert "url" in first


@pytest.mark.asyncio
async def test_returns_empty_for_non_listing_page():
    listings = await extract_listings_from_page_text(
        page_text="Welcome to our blog! Here are 10 tips for buying property...",
        source_url="https://example.com/blog",
        source_name="example",
    )
    assert listings == []


@pytest.mark.asyncio
async def test_all_fields_present():
    """Every listing must have all schema fields (can be null but must exist)."""
    page_text = (FIXTURES / "landsearch-sample.txt").read_text()
    listings = await extract_listings_from_page_text(
        page_text=page_text,
        source_url="https://www.landsearch.com/properties/resort/texas",
        source_name="landsearch",
    )
    required_keys = {
        "title", "price", "price_raw", "location", "url",
        "acreage", "rooms_keys", "revenue_hint", "dom_hint",
        "condition_hint", "description", "property_type", "source",
    }
    for listing in listings:
        missing = required_keys - set(listing.keys())
        assert not missing, f"Missing keys: {missing} in listing: {listing.get('title')}"
