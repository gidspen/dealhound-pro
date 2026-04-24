"""
Deal Hound Scraper Service — thin API wrapper around the Playwright scraper.

POST /scrape
  Body: { "locations": ["Texas"], "property_types": ["micro_resort"] }
  Returns: { "listings": [...], "sources_scraped": [...], "total": N }

GET /health
  Returns: { "status": "ok" }
"""

import json
import os
import tempfile
from pathlib import Path

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

from scraper import SCRAPERS, run

app = FastAPI(title="Deal Hound Scraper", version="1.0")

# Auth token — set in Railway env vars
API_TOKEN = os.environ.get("SCRAPER_API_TOKEN", "")

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
    token: str = ""


@app.get("/health")
def health():
    return {"status": "ok"}


@app.post("/scrape")
def scrape(req: ScrapeRequest):
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

    # Run scrapers for each state
    all_listings = []
    sources_scraped = set()

    # Use all available scrapers
    sites = list(SCRAPERS.keys())

    with tempfile.TemporaryDirectory() as tmpdir:
        output_dir = Path(tmpdir)

        for state in states:
            slug = STATE_SLUGS.get(state, state.lower().replace(" ", "-"))
            try:
                results = run(sites, slug, output_dir)
                for site, listings in results.items():
                    if listings:
                        sources_scraped.add(site)
                        all_listings.extend(listings)
            except Exception as e:
                print(f"Scraper error for {state}: {e}")

    return {
        "listings": all_listings,
        "sources_scraped": list(sources_scraped),
        "total": len(all_listings),
    }
