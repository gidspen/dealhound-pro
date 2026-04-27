"""
Deal Hound Scraper Service — thin API wrapper around the Playwright scraper.

POST /scrape
  Body: { "locations": ["Texas"], "property_types": ["micro_resort"],
          "sites": [...], "search_id": "...", "callback_url": "..." }
  Returns: { "listings": [...], "sources_scraped": [...], "total": N }

GET /health
  Returns: { "status": "ok" }
"""

import asyncio
import json
import os
import tempfile
import traceback
from pathlib import Path

import httpx
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

from scraper import SCRAPERS, run, create_browser, scrape_site_with_claude

app = FastAPI(title="Deal Hound Scraper", version="2.0")

# Auth token — set in Railway env vars
API_TOKEN = os.environ.get("SCRAPER_API_TOKEN", "")

# Supabase config (optional — only writes if configured)
SUPABASE_URL = os.environ.get("SUPABASE_URL", "")
SUPABASE_SERVICE_KEY = os.environ.get("SUPABASE_SERVICE_KEY", "")

_supabase_client = None

def _get_supabase():
    """Lazy-init Supabase client."""
    global _supabase_client
    if _supabase_client is None and SUPABASE_URL and SUPABASE_SERVICE_KEY:
        from supabase import create_client
        _supabase_client = create_client(SUPABASE_URL, SUPABASE_SERVICE_KEY)
    return _supabase_client


async def _write_progress(search_id: str, phase: str, status: str, message: str, count: int = 0):
    """Write progress to Supabase scan_progress table if configured."""
    sb = _get_supabase()
    if not sb or not search_id:
        return
    try:
        sb.table("scan_progress").insert({
            "search_id": search_id,
            "step": phase,
            "status": status,
            "message": message,
            "listing_count": count if count else None,
        }).execute()
    except Exception as e:
        print(f"[server] Progress write failed: {e}")


async def _write_raw_listings(search_id: str, listings: list[dict]):
    """Write raw listings to Supabase raw_listings table if configured."""
    sb = _get_supabase()
    if not sb or not search_id or not listings:
        return
    try:
        rows = []
        for l in listings:
            rows.append({
                "search_id": search_id,
                "title": l.get("title"),
                "price": l.get("price"),
                "price_raw": l.get("price_raw"),
                "location": l.get("location"),
                "address": l.get("address"),
                "url": l.get("url"),
                "acreage": l.get("acreage"),
                "rooms_keys": l.get("rooms_keys"),
                "revenue_hint": l.get("revenue_hint"),
                "dom_hint": l.get("dom_hint"),
                "condition_hint": l.get("condition_hint"),
                "description": (l.get("description") or "")[:500] if l.get("description") else None,
                "property_type": l.get("property_type"),
                "source": l.get("source"),
            })
        # Insert in batches of 50
        for i in range(0, len(rows), 50):
            sb.table("raw_listings").insert(rows[i:i+50]).execute()
    except Exception as e:
        print(f"[server] Raw listings write failed ({len(rows)} rows, search_id={search_id}): {e}")


async def _fire_callback(callback_url: str, search_id: str, callback_secret: str = ""):
    """POST search_id to the Vercel webhook when scraping completes."""
    if not callback_url:
        return
    try:
        headers = {}
        if callback_secret:
            headers["X-Webhook-Secret"] = callback_secret
        async with httpx.AsyncClient(timeout=30) as client:
            resp = await client.post(callback_url, json={"search_id": search_id}, headers=headers)
            print(f"[server] Callback to {callback_url}: {resp.status_code}")
    except Exception as e:
        print(f"[server] Callback failed: {e}")

# State name → slug mapping for scraper URLs
STATE_SLUGS = {
    "Alabama": "alabama", "Alaska": "alaska", "Arizona": "arizona",
    "Arkansas": "arkansas", "California": "california", "Colorado": "colorado",
    "Connecticut": "connecticut", "Delaware": "delaware", "Florida": "florida",
    "Georgia": "georgia", "Hawaii": "hawaii", "Idaho": "idaho",
    "Illinois": "illinois", "Indiana": "indiana", "Iowa": "iowa",
    "Kansas": "kansas", "Kentucky": "kentucky", "Louisiana": "louisiana",
    "Maine": "maine", "Maryland": "maryland", "Massachusetts": "massachusetts",
    "Michigan": "michigan", "Minnesota": "minnesota", "Mississippi": "mississippi",
    "Missouri": "missouri", "Montana": "montana", "Nebraska": "nebraska",
    "Nevada": "nevada", "New Hampshire": "new-hampshire", "New Jersey": "new-jersey",
    "New Mexico": "new-mexico", "New York": "new-york",
    "North Carolina": "north-carolina", "North Dakota": "north-dakota",
    "Ohio": "ohio", "Oklahoma": "oklahoma", "Oregon": "oregon",
    "Pennsylvania": "pennsylvania", "Rhode Island": "rhode-island",
    "South Carolina": "south-carolina", "South Dakota": "south-dakota",
    "Tennessee": "tennessee", "Texas": "texas", "Utah": "utah",
    "Vermont": "vermont", "Virginia": "virginia", "Washington": "washington",
    "West Virginia": "west-virginia", "Wisconsin": "wisconsin", "Wyoming": "wyoming",
}

# City/region → state for extracting state from buy box locations
CITY_STATE_MAP = {
    "dallas": "Texas", "houston": "Texas", "austin": "Texas",
    "san antonio": "Texas", "hill country": "Texas", "lake travis": "Texas",
    "wilmington": "North Carolina", "surf city": "North Carolina",
    "outer banks": "North Carolina", "asheville": "North Carolina",
    "charlotte": "North Carolina", "raleigh": "North Carolina",
    "orlando": "Florida", "miami": "Florida", "tampa": "Florida",
    "jacksonville": "Florida", "destin": "Florida", "panama city": "Florida",
    "gatlinburg": "Tennessee", "pigeon forge": "Tennessee", "nashville": "Tennessee",
    "savannah": "Georgia", "atlanta": "Georgia",
    "myrtle beach": "South Carolina", "charleston": "South Carolina",
    "branson": "Missouri", "ozarks": "Missouri",
    "sedona": "Arizona", "scottsdale": "Arizona",
    "big bear": "California", "lake tahoe": "California", "napa": "California",
}


def extract_state(location: str) -> str | None:
    """Extract state name from a location string like 'Wilmington, NC' or 'East Texas near Dallas'."""
    # Check for state abbreviation
    import re
    abbrev_map = {v.upper()[:2] if len(v.split()) == 1 else "".join(w[0] for w in v.split()).upper(): v
                  for v in STATE_SLUGS.keys()}
    # Build proper abbreviation map
    state_abbrevs = {
        "AL": "Alabama", "AK": "Alaska", "AZ": "Arizona", "AR": "Arkansas",
        "CA": "California", "CO": "Colorado", "CT": "Connecticut", "DE": "Delaware",
        "FL": "Florida", "GA": "Georgia", "HI": "Hawaii", "ID": "Idaho",
        "IL": "Illinois", "IN": "Indiana", "IA": "Iowa", "KS": "Kansas",
        "KY": "Kentucky", "LA": "Louisiana", "ME": "Maine", "MD": "Maryland",
        "MA": "Massachusetts", "MI": "Michigan", "MN": "Minnesota", "MS": "Mississippi",
        "MO": "Missouri", "MT": "Montana", "NE": "Nebraska", "NV": "Nevada",
        "NH": "New Hampshire", "NJ": "New Jersey", "NM": "New Mexico", "NY": "New York",
        "NC": "North Carolina", "ND": "North Dakota", "OH": "Ohio", "OK": "Oklahoma",
        "OR": "Oregon", "PA": "Pennsylvania", "RI": "Rhode Island", "SC": "South Carolina",
        "SD": "South Dakota", "TN": "Tennessee", "TX": "Texas", "UT": "Utah",
        "VT": "Vermont", "VA": "Virginia", "WA": "Washington", "WV": "West Virginia",
        "WI": "Wisconsin", "WY": "Wyoming",
    }

    match = re.search(r"\b([A-Z]{2})\b", location)
    if match and match.group(1) in state_abbrevs:
        return state_abbrevs[match.group(1)]

    # Check for full state name
    lower = location.lower()
    for state in STATE_SLUGS:
        if state.lower() in lower:
            return state

    # Check city/region map
    for city, state in CITY_STATE_MAP.items():
        if city in lower:
            return state

    return None


class ScrapeRequest(BaseModel):
    locations: list[str]
    property_types: list[str] = []
    sites: list[dict] = []           # Discovered sites with listings_url
    search_id: str = ""              # For Supabase progress + raw listing writes
    callback_url: str = ""           # Vercel webhook to POST when done
    callback_secret: str = ""        # Sent as X-Webhook-Secret header in callback
    token: str = ""


# Sites that need ScraperAPI proxy (blocked by Cloudflare/Akamai)
PROXY_SITES = {
    "bizbuysell": [
        "https://www.bizbuysell.com/{slug}/campgrounds-and-rv-parks-for-sale/",
        "https://www.bizbuysell.com/{slug}/travel-businesses-for-sale/",
    ],
    "landwatch": [
        "https://www.landwatch.com/{slug}-land-for-sale/commercial-property/camping-activity",
        "https://www.landwatch.com/{slug}-land-for-sale/camping-activity",
    ],
    "crexi": [
        "https://www.crexi.com/properties?propertyType=Hospitality&stateCode={state_code}",
    ],
}


@app.get("/health")
def health():
    return {"status": "ok"}


@app.post("/scrape")
async def scrape(req: ScrapeRequest):
    # Auth check
    if API_TOKEN and req.token != API_TOKEN:
        raise HTTPException(status_code=401, detail="Invalid token")

    # Extract unique states from locations
    states = set()
    for loc in req.locations:
        state = extract_state(loc)
        if state:
            states.add(state)

    if not states:
        return {"listings": [], "sources_scraped": [], "total": 0,
                "error": "Could not extract any states from locations"}

    all_listings = []
    sources_scraped = set()

    # Phase 1: LandSearch via native sync scraper (no proxy needed, saves API cost)
    await _write_progress(req.search_id, "scraping", "running", "Scraping LandSearch (native)...")
    try:
        landsearch_listings = await asyncio.to_thread(
            _run_sync_scraper, "landsearch", states
        )
        if landsearch_listings:
            sources_scraped.add("landsearch")
            all_listings.extend(landsearch_listings)
            await _write_progress(
                req.search_id, "scraping", "running",
                f"LandSearch: {len(landsearch_listings)} listings found",
                len(landsearch_listings),
            )
    except Exception as e:
        print(f"[server] LandSearch sync scraper error: {e}")
        await _write_progress(req.search_id, "scraping", "running",
                              f"LandSearch error: {str(e)[:200]}")

    # Phase 2: Blocked sites via ScraperAPI proxy + Claude extraction
    for site_name, url_templates in PROXY_SITES.items():
        await _write_progress(req.search_id, "scraping", "running",
                              f"Scraping {site_name} (proxy + Claude)...")
        try:
            browser = await create_browser(use_proxy=True)
            page = await browser.new_page()

            site_listings = []
            for state in states:
                slug = STATE_SLUGS.get(state, state.lower().replace(" ", "-"))
                state_code = state[:2].upper()
                # Build proper state code
                from scraper import to_state_code
                state_code = to_state_code(slug)

                for tmpl in url_templates:
                    url = tmpl.format(slug=slug, state_code=state_code)
                    try:
                        listings = await scrape_site_with_claude(
                            page=page, site_url=url, site_name=site_name,
                            max_pages=3,
                        )
                        site_listings.extend(listings)
                    except Exception as e:
                        print(f"[server] {site_name} error on {url}: {e}")

            await browser.close()

            if site_listings:
                sources_scraped.add(site_name)
                all_listings.extend(site_listings)
                await _write_progress(
                    req.search_id, "scraping", "running",
                    f"{site_name}: {len(site_listings)} listings found",
                    len(site_listings),
                )
        except Exception as e:
            print(f"[server] {site_name} scraper error: {e}\n{traceback.format_exc()}")
            await _write_progress(req.search_id, "scraping", "running",
                                  f"{site_name} error: {str(e)[:200]}")

    # Phase 3: Additional discovered sites from the sites array
    for site_info in req.sites:
        listings_url = site_info.get("listings_url", "")
        site_name = site_info.get("name", "discovered").lower().replace(" ", "_")

        if not listings_url:
            continue

        # Skip if we already scraped this site natively
        if site_name in sources_scraped:
            continue

        await _write_progress(req.search_id, "scraping", "running",
                              f"Scraping {site_name} (discovered site)...")
        try:
            browser = await create_browser(use_proxy=True)
            page = await browser.new_page()
            listings = await scrape_site_with_claude(
                page=page, site_url=listings_url, site_name=site_name,
                max_pages=3,
            )
            await browser.close()

            if listings:
                sources_scraped.add(site_name)
                all_listings.extend(listings)
                await _write_progress(
                    req.search_id, "scraping", "running",
                    f"{site_name}: {len(listings)} listings found",
                    len(listings),
                )
        except Exception as e:
            print(f"[server] Discovered site {site_name} error: {e}")
            await _write_progress(req.search_id, "scraping", "running",
                                  f"{site_name} error: {str(e)[:200]}")

    # Write raw listings to Supabase
    await _write_raw_listings(req.search_id, all_listings)
    await _write_progress(
        req.search_id, "scraping", "complete",
        f"Scraping complete — {len(all_listings)} listings from {len(sources_scraped)} sources",
        len(all_listings),
    )

    # Fire callback to Vercel webhook
    await _fire_callback(req.callback_url, req.search_id, req.callback_secret)

    return {
        "listings": all_listings,
        "sources_scraped": list(sources_scraped),
        "total": len(all_listings),
    }


def _run_sync_scraper(site_name: str, states: set) -> list[dict]:
    """Run the sync Playwright scraper for a single site across all states.
    Called via asyncio.to_thread() to avoid blocking the event loop."""
    all_listings = []
    with tempfile.TemporaryDirectory() as tmpdir:
        output_dir = Path(tmpdir)
        for state in states:
            slug = STATE_SLUGS.get(state, state.lower().replace(" ", "-"))
            try:
                results = run([site_name], slug, output_dir)
                for site, listings in results.items():
                    if listings:
                        all_listings.extend(listings)
            except Exception as e:
                print(f"[server] Sync scraper error for {site_name}/{state}: {e}")
    return all_listings
