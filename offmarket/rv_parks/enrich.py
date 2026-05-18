"""Per-park enrichment — populates the motivation + conversion signals.

For each spine row:
  - CAD lookup by address (Dallas + Bexar use existing scrapers; others
    best-effort via cad_registry fallback paths)
  - Tax delinquency check (county-by-county; deferred to v1.1)
  - Probate / obituary cross-match by owner name (deferred to v1.1)
  - Operational signals (website WHOIS, Google reviews recency) — deferred to v1.1
  - Highway proximity from OpenStreetMap (deferred; using is-in-Texas-grid proxy)

For the POC we attach illustrative mock signals so the scoring engine
demonstrates end-to-end. The mock pattern reflects the real distribution
we'd expect to see — most parks have weak signals, a few have stacked
strong signals.

Replace `mock_motivation_signals` with real CAD/probate/tax pulls in v1.1.
"""
from __future__ import annotations

import hashlib
from typing import Optional

from offmarket.rv_parks.score import MotivationSignals, ConversionSignals
from offmarket.rv_parks.spine import RVParkSpineRow


# ---------------------------------------------------------------------------
# Conversion signals — derive from spine + computed fields. Mostly real.
# ---------------------------------------------------------------------------

def conversion_signals(row: RVParkSpineRow,
                       acreage_lookup: Optional[float] = None,
                       glamping_comp_rate: float = 200.0) -> ConversionSignals:
    """Most conversion signals derive directly from spine fields."""

    # Highway proximity: approximate using whether the park is within 5mi of
    # a major TX interstate. For POC we use a simple bounding-box heuristic;
    # production uses OpenStreetMap nearest-highway query.
    near_highway = _approx_near_highway(row.lat, row.lon)

    # Operational decay: deferred to real WHOIS/Google reviews enrichment.
    # For POC, mock as True for ~30% of parks (matches expected real rate
    # for established but under-managed independents).
    decay = _stable_pseudo_random(row.name + "decay", threshold=0.30)

    # Existing utilities: assume True for any park with > 10 pads (they
    # all have at least basic hookups). Production: verify per parcel.
    has_utils = (row.pad_count or 0) > 10

    # Acreage: for POC, derive from pad count where lookup unavailable
    # (rule of thumb: 0.25-0.5 acres per pad including common areas).
    if acreage_lookup is None and row.pad_count:
        acreage_lookup = round(row.pad_count * 0.4, 1)

    # Nightly rate proxy: for POC, mock conservatively. Production: scrape.
    nightly_rate = _stable_pseudo_random(row.name + "rate",
                                         min_v=35, max_v=85)

    return ConversionSignals(
        acreage=acreage_lookup,
        pad_count=row.pad_count,
        independent_not_chain=not row.is_chain,
        highway_distance_mi=3.0 if near_highway else 22.0,
        nightly_rate_usd=nightly_rate,
        glamping_comp_rate_usd=glamping_comp_rate,
        operational_decay=decay,
        has_existing_utilities=has_utils,
        lat=row.lat,
        lon=row.lon,
    )


# ---------------------------------------------------------------------------
# Motivation signals — MOCKED for POC. Real implementation pulls from:
#   - DCAD/BCAD scraper (length of ownership, OV65, owner mailing addr)
#   - County tax assessor delinquent rolls
#   - County clerk deed records (lis pendens, inherited deed)
#   - County probate court records
#   - TX Comptroller (LLC forfeited)
# ---------------------------------------------------------------------------

def _apply_demo_override(row: RVParkSpineRow, sig: MotivationSignals) -> MotivationSignals:
    """Apply a demo override if one exists for this park name."""
    try:
        from offmarket.rv_parks.sample_spine import DEMO_MOTIVATION_OVERRIDES
    except ImportError:
        return sig
    override = DEMO_MOTIVATION_OVERRIDES.get(row.name)
    if override:
        for k, v in override.items():
            setattr(sig, k, v)
    return sig


def mock_motivation_signals(row: RVParkSpineRow) -> MotivationSignals:
    """Illustrative mock signals based on a deterministic hash of the park name.

    In production every park has CAD-derived baseline signals (years_held,
    ov65, owner mailing address). The mock reflects that: years_held is
    always populated, and additional life-event / financial-pressure
    signals stack proportionally to the bucket.

    Distribution:
      ~13% HOT (strong stack: probate / obit / tax delinquent / inherited)
      ~27% STRONG (OV65 + long hold + secondary signal)
      ~45% WATCH (baseline CAD signals only)
      ~15% near-discard (short hold, in-state, no exemption)

    Replace with real enrichment in v1.1.
    """
    h = int(hashlib.md5(row.name.encode()).hexdigest(), 16)
    bucket = h % 100

    # Baseline CAD signals — present for nearly every parcel
    years_held = 8 + (h // 100) % 35              # 8–42 years
    ov65 = (h // 1000) % 100 < 38                 # ~38% have OV65 (matches TX age dist for long-hold land)
    out_of_state = (h // 10000) % 100 < 28        # ~28% absentee
    trust = (h // 100000) % 100 < 12              # ~12% trust-held

    sig = MotivationSignals(
        years_held=years_held,
        ov65_exemption=ov65,
        out_of_state_owner=out_of_state,
        trust_ownership=trust,
    )

    if bucket < 13:
        # HOT — strong life-event or financial-pressure stack
        sig.probate_filing_24mo = bucket < 7
        sig.obituary_match = bucket < 4
        sig.inherited_deed_36mo = bucket < 9
        sig.tax_delinquent_2yr_plus = bucket < 6
        sig.llc_forfeited = bucket < 5
        sig.years_held = max(years_held, 28)
        sig.ov65_exemption = True
    elif bucket < 40:
        # STRONG — moderate stack
        sig.tax_delinquent_1yr = bucket % 4 == 0
        sig.code_violation_24mo = bucket % 5 == 0
        sig.divorce_filing_24mo = bucket % 6 == 0
        sig.years_held = max(years_held, 18)
    # bucket 40-100: just the baseline CAD signals (varies WATCH vs near-discard
    # based on whether ov65/long-hold/out-of-state coincide)

    return _apply_demo_override(row, sig)


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _approx_near_highway(lat: Optional[float], lon: Optional[float]) -> bool:
    """Crude bounding-box check for proximity to a major TX interstate.

    Real implementation: OpenStreetMap nearest-highway query (free, headless).
    """
    if lat is None or lon is None:
        return False
    # I-10 corridor (rough longitude bounds run E-W across TX, lat ~29.5-30.5)
    if 29.0 <= lat <= 30.8:
        return True
    # I-35 corridor (rough lat bounds run N-S, lon ~-97.7 to -97.0)
    if -97.7 <= lon <= -97.0:
        return True
    # I-20 corridor (lat ~32.5)
    if 32.0 <= lat <= 33.0:
        return True
    return False


def _stable_pseudo_random(seed: str, threshold: float = None,
                          min_v: int = None, max_v: int = None):
    """Deterministic per-park value, replaces a real-data lookup for POC."""
    h = int(hashlib.md5(seed.encode()).hexdigest(), 16)
    if threshold is not None:
        return (h % 100) < (threshold * 100)
    if min_v is not None and max_v is not None:
        span = max_v - min_v
        return min_v + (h % (span + 1))
    return h
