"""Geographic helpers for conversion-fitness scoring.

Hill Country tourism corridor proximity is a strong signal for the
RV-park-to-micro-resort conversion thesis — that's where the glamping
nightly-rate premium exists and where buyer demand is concentrated.

No external deps; uses Haversine for distance.
"""
from __future__ import annotations

import math
from dataclasses import dataclass


# Hill Country tourism anchors — the cities that drive premium nightly rates
# for glamping/micro-resort operations. Distance to nearest anchor is the
# strongest single conversion-fitness signal.
HILL_COUNTRY_ANCHORS = {
    "Wimberley":       (29.9974, -98.0986),
    "Fredericksburg":  (30.2752, -98.8720),
    "Dripping Springs":(30.1902, -98.0867),
    "Bandera":         (29.7266, -98.9933),
    "Boerne":          (29.7944, -98.7320),
    "Kerrville":       (30.0474, -99.1403),
    "Marble Falls":    (30.5783, -98.2733),
    "Blanco":          (30.0991, -98.4253),
    "Comfort":         (29.9694, -98.9061),
    "Johnson City":    (30.2766, -98.4117),
}

# Secondary tourism corridors — Gulf Coast and East TX. Lower premium than
# Hill Country but still viable conversion zones.
SECONDARY_ANCHORS = {
    "Port Aransas":    (27.8336, -97.0611),
    "Rockport":        (28.0206, -97.0544),
    "Galveston":       (29.3013, -94.7977),
    "Caddo Lake":      (32.7188, -94.1722),
    "Tyler":           (32.3513, -95.3011),
    "Big Bend (Terlingua)": (29.3208, -103.6166),
}


@dataclass
class GeoPoint:
    lat: float
    lon: float


def haversine_miles(a: GeoPoint, b: GeoPoint) -> float:
    """Great-circle distance in miles between two lat/lon points."""
    R_MI = 3958.7613
    lat1, lat2 = math.radians(a.lat), math.radians(b.lat)
    dlat = lat2 - lat1
    dlon = math.radians(b.lon - a.lon)
    h = math.sin(dlat / 2) ** 2 + math.cos(lat1) * math.cos(lat2) * math.sin(dlon / 2) ** 2
    return 2 * R_MI * math.asin(math.sqrt(h))


def nearest_hill_country_anchor(lat: float, lon: float) -> tuple[str, float]:
    """Return (anchor_name, distance_miles) for the nearest Hill Country anchor."""
    here = GeoPoint(lat, lon)
    best_name, best_dist = "", float("inf")
    for name, (alat, alon) in HILL_COUNTRY_ANCHORS.items():
        d = haversine_miles(here, GeoPoint(alat, alon))
        if d < best_dist:
            best_name, best_dist = name, d
    return best_name, best_dist


def nearest_secondary_anchor(lat: float, lon: float) -> tuple[str, float]:
    """Return (anchor_name, distance_miles) for the nearest secondary corridor."""
    here = GeoPoint(lat, lon)
    best_name, best_dist = "", float("inf")
    for name, (alat, alon) in SECONDARY_ANCHORS.items():
        d = haversine_miles(here, GeoPoint(alat, alon))
        if d < best_dist:
            best_name, best_dist = name, d
    return best_name, best_dist


def tourism_corridor_fit(lat: float, lon: float) -> dict:
    """Combined corridor proximity assessment.

    Returns nearest Hill Country anchor + distance, nearest secondary
    anchor + distance, and a 0-15 conversion-fitness score.

    Score curve:
      <30 mi from Hill Country anchor   → 15 (prime conversion zone)
      30-60 mi from Hill Country anchor → 10
      60-100 mi from Hill Country       → 6
      <30 mi from secondary anchor      → 8
      30-60 mi from secondary           → 5
      otherwise                         → 0-2
    """
    hc_name, hc_dist = nearest_hill_country_anchor(lat, lon)
    sec_name, sec_dist = nearest_secondary_anchor(lat, lon)

    if hc_dist < 30:
        score, zone = 15, "hill_country_prime"
        primary_name, primary_dist = hc_name, hc_dist
    elif hc_dist < 60:
        score, zone = 10, "hill_country_secondary"
        primary_name, primary_dist = hc_name, hc_dist
    elif hc_dist < 100:
        score, zone = 6, "hill_country_fringe"
        primary_name, primary_dist = hc_name, hc_dist
    elif sec_dist < 30:
        score, zone = 8, "gulf_or_east_tx_prime"
        primary_name, primary_dist = sec_name, sec_dist
    elif sec_dist < 60:
        score, zone = 5, "gulf_or_east_tx_secondary"
        primary_name, primary_dist = sec_name, sec_dist
    else:
        score, zone = 2, "rural"
        primary_name, primary_dist = (hc_name, hc_dist) if hc_dist < sec_dist else (sec_name, sec_dist)

    return {
        "primary_anchor": primary_name,
        "primary_distance_mi": round(primary_dist, 1),
        "hill_country_anchor": hc_name,
        "hill_country_distance_mi": round(hc_dist, 1),
        "secondary_anchor": sec_name,
        "secondary_distance_mi": round(sec_dist, 1),
        "corridor_score": score,
        "corridor_zone": zone,
    }
