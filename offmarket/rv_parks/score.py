"""Scoring engine for RV park / campground off-market leads.

Two independent scores per lead:

1. motivation_score (0-100) — probability owner will engage on an offer.
   Stacks of public-record signals: probate, length-held, OV65, out-of-state
   owner, tax delinquent, LLC forfeited, inherited deed, code violations.

2. conversion_fitness_score (0-100) — how good a candidate this is for the
   RV-park-to-micro-resort conversion thesis. Independent of motivation:
   acreage, pad count, tourism corridor proximity, highway access,
   independent vs chain, nightly rate vs comp market.

A lead is HOT when BOTH scores are high. Surfacing both lets users sort
their pipeline by "owner is motivated AND the property is convertible."
"""
from __future__ import annotations

from dataclasses import dataclass, field, asdict
from typing import Optional

from offmarket.rv_parks.geo import tourism_corridor_fit


# ---------------------------------------------------------------------------
# Motivation signal weights
# ---------------------------------------------------------------------------

MOTIVATION_WEIGHTS = {
    "probate_filing_24mo":         25,
    "obituary_match":              22,
    "lis_pendens_or_nod":          25,
    "tax_delinquent_2yr_plus":     18,
    "tax_delinquent_1yr":          10,
    "ov65_exemption":              10,
    "out_of_state_owner":           8,
    "years_held_25_plus":           8,
    "years_held_15_to_24":          5,
    "inherited_deed_36mo":         12,
    "code_violation_24mo":           6,
    "llc_forfeited":                 8,
    "divorce_filing_24mo":           8,
    "bankruptcy_filing_24mo":      12,
    "trust_ownership":               4,
}


# ---------------------------------------------------------------------------
# Conversion-fitness signal weights
# ---------------------------------------------------------------------------

# Corridor proximity score (0-15) is added from geo.tourism_corridor_fit;
# remaining signals are flag-based with these weights.
CONVERSION_FITNESS_WEIGHTS = {
    "acreage_5_to_50":              15,
    "acreage_50_plus":               8,   # too big = expensive to convert
    "independent_not_chain":        12,
    "pad_count_20_to_80":           15,   # right-size for conversion
    "pad_count_under_20":            8,   # too small, marginal
    "pad_count_80_plus":             4,   # too big, complex
    "highway_access_within_10mi":   10,
    "nightly_rate_below_glamping_comp": 12,
    "operational_decay_signal":     10,   # reviews / website rot
    "has_existing_utilities":        8,   # major capex savings on conversion
}


@dataclass
class MotivationSignals:
    """Raw motivation signals — None = unknown, False = checked-and-absent."""
    probate_filing_24mo: Optional[bool] = None
    obituary_match: Optional[bool] = None
    lis_pendens_or_nod: Optional[bool] = None
    tax_delinquent_2yr_plus: Optional[bool] = None
    tax_delinquent_1yr: Optional[bool] = None
    ov65_exemption: Optional[bool] = None
    out_of_state_owner: Optional[bool] = None
    years_held: Optional[int] = None
    inherited_deed_36mo: Optional[bool] = None
    code_violation_24mo: Optional[bool] = None
    llc_forfeited: Optional[bool] = None
    divorce_filing_24mo: Optional[bool] = None
    bankruptcy_filing_24mo: Optional[bool] = None
    trust_ownership: Optional[bool] = None


@dataclass
class ConversionSignals:
    """Raw conversion-fitness signals."""
    acreage: Optional[float] = None
    pad_count: Optional[int] = None
    independent_not_chain: Optional[bool] = None
    highway_distance_mi: Optional[float] = None
    nightly_rate_usd: Optional[float] = None
    glamping_comp_rate_usd: Optional[float] = None
    operational_decay: Optional[bool] = None
    has_existing_utilities: Optional[bool] = None
    lat: Optional[float] = None
    lon: Optional[float] = None


@dataclass
class ScoredSignal:
    key: str
    weight: int
    evidence: str


def score_motivation(s: MotivationSignals) -> tuple[int, list[ScoredSignal]]:
    """Return (score_0_to_100, list_of_fired_signals)."""
    fired: list[ScoredSignal] = []
    raw = 0

    def fire(key: str, ev: str):
        nonlocal raw
        w = MOTIVATION_WEIGHTS[key]
        raw += w
        fired.append(ScoredSignal(key, w, ev))

    if s.probate_filing_24mo:        fire("probate_filing_24mo", "probate filing within 24 mo")
    if s.obituary_match:             fire("obituary_match", "owner obituary match")
    if s.lis_pendens_or_nod:         fire("lis_pendens_or_nod", "lis pendens or notice of default on file")
    if s.tax_delinquent_2yr_plus:    fire("tax_delinquent_2yr_plus", "property tax delinquent 2+ years")
    elif s.tax_delinquent_1yr:       fire("tax_delinquent_1yr", "property tax delinquent 1 year")
    if s.ov65_exemption:             fire("ov65_exemption", "OV65 homestead exemption present (owner 65+)")
    if s.out_of_state_owner:         fire("out_of_state_owner", "owner mailing address outside TX")
    if s.years_held is not None:
        if s.years_held >= 25:       fire("years_held_25_plus", f"owned {s.years_held} years")
        elif s.years_held >= 15:     fire("years_held_15_to_24", f"owned {s.years_held} years")
    if s.inherited_deed_36mo:        fire("inherited_deed_36mo", "$0-consideration deed transfer in last 36 mo")
    if s.code_violation_24mo:        fire("code_violation_24mo", "code violation in last 24 mo")
    if s.llc_forfeited:              fire("llc_forfeited", "owning LLC forfeited or dissolved")
    if s.divorce_filing_24mo:        fire("divorce_filing_24mo", "divorce filing matching owner in last 24 mo")
    if s.bankruptcy_filing_24mo:     fire("bankruptcy_filing_24mo", "bankruptcy filing matching owner in last 24 mo")
    if s.trust_ownership:            fire("trust_ownership", "property held in trust (estate planning context)")

    return min(raw, 100), fired


def score_conversion(s: ConversionSignals) -> tuple[int, list[ScoredSignal], dict]:
    """Return (score_0_to_100, list_of_fired_signals, corridor_dict)."""
    fired: list[ScoredSignal] = []
    raw = 0

    def fire(key: str, ev: str):
        nonlocal raw
        w = CONVERSION_FITNESS_WEIGHTS[key]
        raw += w
        fired.append(ScoredSignal(key, w, ev))

    if s.acreage is not None:
        if 5 <= s.acreage <= 50:     fire("acreage_5_to_50", f"{s.acreage} acres — right-size for micro-resort")
        elif s.acreage > 50:         fire("acreage_50_plus", f"{s.acreage} acres — large, higher capex")

    if s.pad_count is not None:
        if 20 <= s.pad_count <= 80:  fire("pad_count_20_to_80", f"{s.pad_count} pads — convertible scale")
        elif s.pad_count < 20:       fire("pad_count_under_20", f"{s.pad_count} pads — small, marginal economics")
        else:                        fire("pad_count_80_plus", f"{s.pad_count} pads — complex conversion")

    if s.independent_not_chain:      fire("independent_not_chain", "independent operator (not a chain franchise)")
    if s.highway_distance_mi is not None and s.highway_distance_mi <= 10:
        fire("highway_access_within_10mi", f"{s.highway_distance_mi} mi from highway")
    if (s.nightly_rate_usd is not None and s.glamping_comp_rate_usd is not None
            and s.nightly_rate_usd < s.glamping_comp_rate_usd * 0.4):
        fire("nightly_rate_below_glamping_comp",
             f"${s.nightly_rate_usd}/night vs ${s.glamping_comp_rate_usd} glamping comp — large rate gap")
    if s.operational_decay:          fire("operational_decay_signal", "review/website decay indicators present")
    if s.has_existing_utilities:     fire("has_existing_utilities", "existing utility infrastructure (water/sewer/power hookups)")

    corridor = None
    if s.lat is not None and s.lon is not None:
        corridor = tourism_corridor_fit(s.lat, s.lon)
        raw += corridor["corridor_score"]
        fired.append(ScoredSignal(
            "tourism_corridor",
            corridor["corridor_score"],
            f"{corridor['hill_country_distance_mi']} mi from {corridor['hill_country_anchor']} ({corridor['corridor_zone']})",
        ))

    return min(raw, 100), fired, corridor or {}


def tier(motivation: int, conversion: int) -> str:
    """Combined tier label. Both scores must be strong for HOT."""
    if motivation >= 60 and conversion >= 60:    return "HOT"
    if motivation >= 60 or conversion >= 70:     return "STRONG"
    if motivation >= 40 or conversion >= 50:     return "WATCH"
    return "DISCARD"


def score_lead(motivation: MotivationSignals, conversion: ConversionSignals) -> dict:
    """End-to-end scoring of a single lead."""
    m_score, m_fired = score_motivation(motivation)
    c_score, c_fired, corridor = score_conversion(conversion)
    return {
        "motivation_score": m_score,
        "motivation_signals": [asdict(s) for s in m_fired],
        "conversion_fitness_score": c_score,
        "conversion_signals": [asdict(s) for s in c_fired],
        "corridor": corridor,
        "tier": tier(m_score, c_score),
    }
