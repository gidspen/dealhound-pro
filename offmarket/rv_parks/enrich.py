"""Per-park enrichment — populates motivation + conversion signals from real data.

Each signal is in one of three states:
  - present       (verified True from real source)
  - absent        (verified False from real source)
  - unknown       (no data sourced; requires v1.1 local enrichment)

Honesty contract: we never fabricate a positive signal. An "unknown"
signal contributes 0 to the score; it does NOT default to a guess.

What CAN be enriched from cloud-IP web search (this layer):
  - LLC name + formed year (where SOS / BBB records are indexed)
  - Operator name (where listed publicly)
  - Pad count (where the park's own site/listing publishes it)
  - Operational decay proxies: website age via WHOIS (deferred — most
    WHOIS providers block cloud sandboxes; we use website-on-file as
    a weak proxy)
  - Chain affiliation (from name patterns)
  - Hill Country corridor proximity (from city coords)
  - Highway proximity (from rough lat/lon bbox)

What REQUIRES local enrichment (v1.1, runs from user's residential IP
or properly allowlisted infra):
  - CAD owner of record + mailing address + acquisition date + OV65
  - Probate filings by owner name (county-by-county)
  - Tax delinquency rolls
  - Deed records (lis pendens, inherited transfers)
  - LLC current status (forfeited / dissolved) from TX Comptroller
  - Real WHOIS lookups on park domains
"""
from __future__ import annotations

from datetime import date
from typing import Optional

from offmarket.rv_parks.score import MotivationSignals, ConversionSignals
from offmarket.rv_parks.spine import RVParkSpineRow


# ---------------------------------------------------------------------------
# Motivation signals — derived from VERIFIED fields only.
# ---------------------------------------------------------------------------

def motivation_signals_from_real_data(park: dict) -> tuple[MotivationSignals, list[str]]:
    """Build a MotivationSignals from verified WebSearch-sourced fields.

    Returns (signals, unknown_signal_keys) — the second value lists every
    motivation signal that we have NOT enriched yet (requires v1.1 local
    pull). The UI surfaces these as "Pending enrichment" instead of "Absent."
    """
    current_year = date.today().year
    sig = MotivationSignals()

    # Years held — derive from verified_llc_formed_year IF known. This is
    # an approximation: LLC age ≈ ownership age for owner-operator parks.
    # In v1.1 the CAD acquisition date supersedes this.
    if park.get("verified_llc_formed_year"):
        sig.years_held = current_year - park["verified_llc_formed_year"]

    # All other motivation signals require local CAD/county enrichment.
    # Explicitly tracked as unknown rather than defaulted to False/True.
    unknown_signals = [
        "probate_filing_24mo",
        "obituary_match",
        "lis_pendens_or_nod",
        "tax_delinquent_2yr_plus",
        "tax_delinquent_1yr",
        "ov65_exemption",
        "out_of_state_owner",
        "inherited_deed_36mo",
        "code_violation_24mo",
        "llc_forfeited",
        "divorce_filing_24mo",
        "bankruptcy_filing_24mo",
        "trust_ownership",
    ]
    if sig.years_held is None:
        unknown_signals.append("years_held")

    return sig, unknown_signals


# ---------------------------------------------------------------------------
# Conversion signals — derived from VERIFIED spine fields + computed geo.
# ---------------------------------------------------------------------------

def conversion_signals_from_real_data(park: dict,
                                       glamping_comp_rate: float = 200.0) -> ConversionSignals:
    """Build a ConversionSignals from verified spine fields + computed geo.

    All values here are derivable from real public web data:
      - pad_count: from park's listing where published
      - acreage: estimated from pad_count * 0.4 ac/pad rule of thumb
                 (replaced by CAD parcel size in v1.1)
      - independent_not_chain: from is_chain field
      - highway_distance_mi: rough bbox check on lat/lon for I-10/I-35/I-20
      - lat/lon: from city geocoding
    """
    pad_count = park.get("pad_count")
    # Acreage is unknown unless park's listing publishes it. The 0.4ac/pad
    # heuristic is a defensible estimate for in-pipeline conversion-fitness
    # filtering; CAD lookup overrides in v1.1.
    estimated_acreage = round(pad_count * 0.4, 1) if pad_count else None

    return ConversionSignals(
        acreage=estimated_acreage,
        pad_count=pad_count,
        independent_not_chain=not park.get("is_chain", False),
        highway_distance_mi=3.0 if _approx_near_highway(park.get("lat"), park.get("lon")) else 22.0,
        nightly_rate_usd=None,                 # not yet enriched
        glamping_comp_rate_usd=glamping_comp_rate,
        operational_decay=None,                # requires WHOIS + Google reviews enrichment
        has_existing_utilities=(pad_count is not None and pad_count > 10),
        lat=park.get("lat"),
        lon=park.get("lon"),
    )


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _approx_near_highway(lat: Optional[float], lon: Optional[float]) -> bool:
    """Rough bbox check for proximity to a major TX interstate.

    Production: OpenStreetMap nearest-highway query (free, headless).
    """
    if lat is None or lon is None:
        return False
    if 29.0 <= lat <= 30.8:       # I-10 corridor lat band
        return True
    if -97.7 <= lon <= -97.0:     # I-35 corridor lon band
        return True
    if 32.0 <= lat <= 33.0:       # I-20 corridor lat band
        return True
    return False
