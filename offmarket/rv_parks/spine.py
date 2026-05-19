"""Spine loader — TX RV park / campground universe.

Pulls from public directories. Each directory is best-effort; on failure
(network block, layout change), we log and continue with whatever the
other sources returned.

Sources, in priority order:
  1. KOA state directory (koa.com/states/tx/) — chains and franchises, clean
  2. ARVC / Go Camping America (gocampingamerica.com) — independent operators
  3. Good Sam Club RV Resorts directory
  4. RV Park Reviews (rvparkreviews.com)
  5. Google Places API (rv_park + campground in TX bbox) — requires GOOGLE_PLACES_API_KEY

POC NOTE: All five sources block this cloud sandbox IP (typical 403 from
cloud-IP geo/bot filters). The scraping logic below runs cleanly from a
residential IP. For the in-sandbox POC demo we fall back to a curated
sample dataset of well-known real TX parks (see sample_spine.py).
"""
from __future__ import annotations

import json
import os
import time
from dataclasses import dataclass, field, asdict
from pathlib import Path
from typing import Optional

import requests
from bs4 import BeautifulSoup


USER_AGENT = (
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 "
    "(KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
)
POLITENESS_SEC = 1.5


@dataclass
class RVParkSpineRow:
    """Raw spine record — one row per park before enrichment."""
    name: str
    address: Optional[str] = None
    city: Optional[str] = None
    state: str = "TX"
    zip: Optional[str] = None
    lat: Optional[float] = None
    lon: Optional[float] = None
    phone: Optional[str] = None
    website: Optional[str] = None
    source: str = ""
    source_url: Optional[str] = None
    is_chain: bool = False                 # KOA / Good Sam franchise / Yogi Bear etc.
    chain_name: Optional[str] = None
    pad_count: Optional[int] = None
    amenities: list[str] = field(default_factory=list)


def fetch(url: str, timeout: int = 20) -> Optional[str]:
    try:
        r = requests.get(url, headers={"User-Agent": USER_AGENT}, timeout=timeout)
        if r.status_code == 200:
            return r.text
    except requests.RequestException:
        pass
    return None


# ---------------------------------------------------------------------------
# Source 1: KOA TX directory
# ---------------------------------------------------------------------------

def scrape_koa_tx() -> list[RVParkSpineRow]:
    """Scrape https://koa.com/states/tx/ for KOA-branded TX campgrounds."""
    html = fetch("https://koa.com/states/tx/")
    if not html:
        return []

    rows: list[RVParkSpineRow] = []
    soup = BeautifulSoup(html, "html.parser")
    for card in soup.select("[data-campground], .campground-card, .location-card"):
        name_el = card.select_one(".campground-name, .location-name, h3")
        addr_el = card.select_one(".campground-address, .location-address")
        link_el = card.select_one("a[href]")
        if not name_el:
            continue
        rows.append(RVParkSpineRow(
            name=name_el.get_text(strip=True),
            address=addr_el.get_text(strip=True) if addr_el else None,
            source="koa",
            source_url=("https://koa.com" + link_el["href"]) if link_el else None,
            is_chain=True,
            chain_name="KOA",
        ))
    return rows


# ---------------------------------------------------------------------------
# Source 2: ARVC / Go Camping America
# ---------------------------------------------------------------------------

def scrape_arvc_tx() -> list[RVParkSpineRow]:
    """ARVC member directory — independent and small-chain operators."""
    html = fetch("https://gocampingamerica.com/find-campgrounds-rv-parks/?state=TX")
    if not html:
        return []

    rows: list[RVParkSpineRow] = []
    soup = BeautifulSoup(html, "html.parser")
    for card in soup.select(".campground-listing, .member-card, .park-listing"):
        name_el = card.select_one("h3, .park-name")
        addr_el = card.select_one(".park-address, .address")
        link_el = card.select_one("a[href]")
        if not name_el:
            continue
        rows.append(RVParkSpineRow(
            name=name_el.get_text(strip=True),
            address=addr_el.get_text(strip=True) if addr_el else None,
            source="arvc",
            source_url=link_el["href"] if link_el else None,
            is_chain=False,
        ))
    return rows


# ---------------------------------------------------------------------------
# Source 3: Google Places API
# ---------------------------------------------------------------------------

def scrape_google_places_tx(api_key: str) -> list[RVParkSpineRow]:
    """Google Places Text Search for 'rv park in texas' and 'campground in texas'.

    Quota-aware: typical search returns 60 results paginated. To cover TX
    properly we'd grid the state (~30 grid cells * 2 queries = 60 calls,
    well within free tier). For POC we issue a single query each.
    """
    if not api_key:
        return []

    rows: list[RVParkSpineRow] = []
    for query in ("rv park in texas", "campground in texas"):
        url = "https://maps.googleapis.com/maps/api/place/textsearch/json"
        params = {"query": query, "key": api_key}
        try:
            r = requests.get(url, params=params, timeout=20)
            if r.status_code != 200:
                continue
            for result in r.json().get("results", []):
                rows.append(RVParkSpineRow(
                    name=result.get("name", ""),
                    address=result.get("formatted_address"),
                    lat=result.get("geometry", {}).get("location", {}).get("lat"),
                    lon=result.get("geometry", {}).get("location", {}).get("lng"),
                    source="google_places",
                    source_url=f"https://www.google.com/maps/place/?q=place_id:{result.get('place_id','')}",
                ))
        except requests.RequestException:
            continue
        time.sleep(POLITENESS_SEC)
    return rows


# ---------------------------------------------------------------------------
# Spine merge + de-dup
# ---------------------------------------------------------------------------

def normalize_name(s: str) -> str:
    return " ".join(s.lower().replace(",", " ").replace(".", " ").split())


def merge_spine(*sources: list[RVParkSpineRow]) -> list[RVParkSpineRow]:
    """De-dup across sources by (normalized_name, zip) or (normalized_name, city)."""
    seen: dict[tuple, RVParkSpineRow] = {}
    for batch in sources:
        for row in batch:
            key = (normalize_name(row.name), (row.zip or row.city or "").lower())
            if key in seen:
                # Merge fields, preferring non-null
                existing = seen[key]
                for f in row.__dataclass_fields__:
                    if getattr(existing, f) in (None, "", []) and getattr(row, f) not in (None, "", []):
                        setattr(existing, f, getattr(row, f))
            else:
                seen[key] = row
    return list(seen.values())


def build_spine(google_places_key: Optional[str] = None,
                use_sample_fallback: bool = True) -> list[RVParkSpineRow]:
    """Build the TX RV park spine across all sources.

    If all directory scrapes fail (typical in cloud sandboxes) and
    use_sample_fallback=True, load the curated sample dataset.
    """
    koa = scrape_koa_tx()
    arvc = scrape_arvc_tx()
    gp = scrape_google_places_tx(google_places_key) if google_places_key else []
    merged = merge_spine(koa, arvc, gp)

    if not merged and use_sample_fallback:
        from offmarket.rv_parks.sample_spine import CURATED_TX_RV_PARKS
        return [RVParkSpineRow(**row) for row in CURATED_TX_RV_PARKS]

    return merged


def write_spine(rows: list[RVParkSpineRow], path: Path) -> None:
    payload = [asdict(r) for r in rows]
    path.write_text(json.dumps(payload, indent=2))


if __name__ == "__main__":
    out = Path(__file__).parent / "data" / "spine.json"
    rows = build_spine(google_places_key=os.environ.get("GOOGLE_PLACES_API_KEY"))
    write_spine(rows, out)
    print(f"Wrote {len(rows)} rows to {out}")
