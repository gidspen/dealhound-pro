"""Tests for server.py — validates the /scrape endpoint accepts the new
sites array + search_id fields and the /health endpoint works."""

import pytest
from httpx import AsyncClient, ASGITransport
from server import app, ScrapeRequest


@pytest.mark.asyncio
async def test_health_endpoint():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        resp = await client.get("/health")
        assert resp.status_code == 200
        assert resp.json()["status"] == "ok"


def test_scrape_request_accepts_sites_and_search_id():
    """ScrapeRequest model must accept sites array, search_id, and callback_url."""
    req = ScrapeRequest(
        locations=["Texas"],
        property_types=["resort"],
        sites=[
            {"name": "LandSearch", "url": "https://landsearch.com",
             "listings_url": "https://www.landsearch.com/properties/resort/texas"}
        ],
        search_id="test-123",
        callback_url="https://example.com/api/scan-continue",
        token="test",
    )
    assert req.search_id == "test-123"
    assert len(req.sites) == 1
    assert req.callback_url == "https://example.com/api/scan-continue"


@pytest.mark.asyncio
async def test_scrape_accepts_sites_array():
    """Integration test: /scrape endpoint accepts the new payload shape."""
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        resp = await client.post("/scrape", json={
            "locations": ["Texas"],
            "property_types": ["resort"],
            "sites": [
                {"name": "LandSearch", "url": "https://landsearch.com",
                 "listings_url": "https://www.landsearch.com/properties/resort/texas"}
            ],
            "search_id": "test-123",
            "token": "test",
        })
        assert resp.status_code == 200
        data = resp.json()
        assert "listings" in data
        assert "sources_scraped" in data
