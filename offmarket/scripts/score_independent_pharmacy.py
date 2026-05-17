#!/usr/bin/env python3
"""
Score independent pharmacy enrichment batches into the canonical 4-layer
acquisition target schema.

Inputs:
  offmarket/data/independent_pharmacy_enrich_batch_{1,2,3}.json

Outputs:
  offmarket/data/independent_pharmacy_targets.json
  offmarket/data/independent_pharmacy_targets.csv

score_run_id: ffb5045a-257d-44e3-a88e-fd243c69a15b
"""

from __future__ import annotations

import csv
import json
import os
import re
import uuid
from datetime import datetime
from pathlib import Path
from typing import Any

SCORE_RUN_ID = "ffb5045a-257d-44e3-a88e-fd243c69a15b"
DATA_DIR = Path(__file__).resolve().parent.parent / "data"
NOW_ISO = datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ")

VERTICAL = "independent_pharmacy"
NAICS = "446110"

# --- Texas market context (Layer 4) -----------------------------------------
# Rural-elderly / high-Hispanic / RGV / El Paso get +5 per spec.
# Inner-city urban gets -3.
# Compounding specialty: +5.
RURAL_ELDERLY_COUNTIES = {
    # RGV / South TX
    "Hidalgo", "Cameron", "Webb", "Starr", "Willacy", "Jim Hogg",
    "Brooks", "Kenedy", "Zapata", "Duval", "La Salle", "Live Oak",
    # El Paso
    "El Paso",
    # Panhandle / West TX rural
    "Potter", "Randall", "Ector", "Midland",
    # Hill Country / small towns
    "Matagorda", "Wichita", "Navarro", "Comal", "Guadalupe",
    "Denton",  # only Pilot Point-style exurbs
    "Collin",  # only Farmersville-style rural Collin
}
HISPANIC_MAJORITY_METROS = {
    "El Paso", "Laredo", "McAllen", "Brownsville", "Mission",
    "Edinburg", "Mercedes", "Weslaco", "Harlingen",
}
INNER_CITY_URBAN_PEN = {
    # Don't penalize if rural-elderly already applied
    "Houston", "Dallas", "Austin", "Fort Worth",
}


# --- Helpers ----------------------------------------------------------------

def first_present(d: dict, *keys, default=None):
    for k in keys:
        v = d.get(k)
        if v is not None and v != "" and v != []:
            return v
    return default


def safe_int(v: Any, default: int | None = None) -> int | None:
    if v is None:
        return default
    try:
        return int(v)
    except (TypeError, ValueError):
        try:
            return int(float(v))
        except (TypeError, ValueError):
            return default


def clamp(x: float, lo: float, hi: float) -> float:
    return max(lo, min(hi, x))


def list_join(items, sep="; ") -> str:
    return sep.join(str(x) for x in items if x is not None and x != "")


# --- Distress / disqualifier interpretation ---------------------------------

CLOSED_PAT = re.compile(r"\b(closed|closure|dissolved|out of business|permanently closed|stale|removed from spine)\b", re.I)
HOSPITAL_OWNED_PAT = re.compile(r"\b(hospital(-| )?owned|hospital system|FQHC|501c3|Texas Health Resources|methodist|UT Health|HCA)\b", re.I)
PUBLIC_CORP_PAT = re.compile(r"\b(public corp|public company|delaware corporation|publicly traded|public corporate parent)\b", re.I)
PE_OWNED_PAT = re.compile(r"\b(private equity|PE backed|PE-owned|owned by [A-Z][a-zA-Z]+ capital)\b", re.I)
NON_INDEPENDENT_PAT = re.compile(r"\bnon[- ]?independent\b", re.I)
LEASE_DEPENDENT_PAT = re.compile(r"\bin[- ]?store grocery (lease|pharmacy)|grocery lease dependency\b", re.I)
DEA_DISTRESS_PAT = re.compile(r"\b(DEA (suspension|settlement|enforcement|registration revoked)|opioid (settlement|distribution|fine))\b", re.I)
MEDICARE_EXCL_PAT = re.compile(r"\b(LEIE|OIG exclusion|Medicare exclusion|MFCU action)\b", re.I)
RECENT_ACQ_PAT = re.compile(r"\b(recent (ownership|2013) (change|takeover)|ownership transfer (201\d|202\d))\b", re.I)
YOUNG_OWNER_PAT = re.compile(r"\b(young pharmacist|young owner|mid[- ]?career|not exit[- ]?ready|recent founding)\b", re.I)
FAMILY_SUCC_LOCKED_PAT = re.compile(r"\b(family successor in place|active (2nd|second|3rd|third)[- ]?gen|3rd gen|family[- ]?owned legacy|family legacy|not selling)\b", re.I)
WATCH_LIST_PAT = re.compile(r"\b(long[- ]?term watch list|watch list|revisit in 10y|skip for short[- ]?term)\b", re.I)


def detect_distress(row: dict) -> tuple[bool, list[str]]:
    """Return (is_distressed, reasons)."""
    reasons = []

    if row.get("is_distressed") is True:
        reasons.extend(row.get("distress_reasons", []) or ["flagged is_distressed"])

    dq = (row.get("acquisition_disqualifier") or "") + " " + (row.get("enrichment_notes") or "")
    verif = (row.get("verification_notes") or "")
    combo = " ".join([dq, verif])

    es = (row.get("entity_status") or "").lower()
    if "closed" in es or "dissolved" in es:
        reasons.append(f"entity_status={row.get('entity_status')}")

    if CLOSED_PAT.search(combo):
        reasons.append("closed/dissolved per notes")
    if DEA_DISTRESS_PAT.search(combo):
        reasons.append("DEA/opioid distress per notes")
    if MEDICARE_EXCL_PAT.search(combo):
        reasons.append("Medicare/LEIE exclusion per notes")

    # de-dup, preserve order
    seen = set()
    out = []
    for r in reasons:
        if r not in seen:
            seen.add(r)
            out.append(r)
    return (len(out) > 0, out)


def detect_disqualifier_type(row: dict) -> str | None:
    """
    Classify why this row should be dropped (returns reason) or None to keep.
    Order: closed > hospital/non-independent > public corp / PE > recent acq /
    young pharmacy > family successor locked.
    """
    dq = row.get("acquisition_disqualifier") or ""
    notes = (row.get("enrichment_notes") or "") + " " + (row.get("verification_notes") or "")
    full = dq + " " + notes
    full_lo = full.lower()

    if "duplicate" in full_lo:
        return "duplicate_of_other_spine_entry"
    if CLOSED_PAT.search(full):
        return "closed_or_stale"
    if HOSPITAL_OWNED_PAT.search(full) or NON_INDEPENDENT_PAT.search(full):
        return "non_independent_or_hospital_owned"
    if PUBLIC_CORP_PAT.search(full):
        return "public_corp"
    if PE_OWNED_PAT.search(full):
        return "pe_owned"
    if LEASE_DEPENDENT_PAT.search(full):
        return "in_store_grocery_lease_dependent"
    if YOUNG_OWNER_PAT.search(full) or RECENT_ACQ_PAT.search(full):
        return "young_owner_or_recent_acquisition"
    return None


YOUNGER_GEN_PAT = re.compile(
    r"\b(son|daughter|jr\.?|junior|2nd gen|second[- ]?gen|3rd gen|third[- ]?gen|"
    r"third-generation|second-generation|successor pharmd|active pharmd successor|"
    r"pharmd 199[0-9]|pharmd 20[0-2][0-9])\b",
    re.I,
)
SAME_GEN_FAMILY_PAT = re.compile(
    r"\b(brothers?|sisters?|husband[+ ]?(and|&)?[ ]?wife|husband[- ]?wife|"
    r"wife,? rph|founder cohort|3[- ]brother|three[- ]brother|two[- ]brother|"
    r"two[- ]sister|family-operated|family team)\b",
    re.I,
)


def _full_text(row: dict) -> str:
    parts = [
        row.get("acquisition_disqualifier") or "",
        row.get("enrichment_notes") or "",
        row.get("verification_notes") or "",
        row.get("owner_name") or "",
        row.get("owner_age_source") or "",
        " ".join(row.get("coasting_tells") or []),
    ]
    succ = row.get("successor_indicators") or {}
    parts.append(succ.get("verified_via") or "")
    return " ".join(parts)


def is_family_succ_locked(row: dict) -> bool:
    """
    Lock only when there is **explicit, verified evidence** that a YOUNGER
    generation is actively operating the business as owner/successor — i.e.,
    sale-blocked because succession is internal.

    Same-generation family (brothers, husband/wife at peer age) does NOT lock.
    Founder still active with no younger-gen successor does NOT lock.
    """
    full = _full_text(row)
    full_lo = full.lower()

    # 1) Explicit "DISQUALIFY family successor" / "watch list" language always locks
    if WATCH_LIST_PAT.search(full):
        return True

    # 2) Explicit phrases proving younger generation is the active operator
    explicit_lock_phrases = [
        "family successor in place",
        "tightly-held generational",
        "daughter as active successor",
        "son as active successor",
        "active 2nd gen", "active 3rd gen",
        "3rd gen succession active",
        "active third-generation", "active second-generation",
        "daughters running it",
        "son rudy", "rudy davila, jr",
        "active pharmd successor",
        "daughter jeneen", "jeneen schloz",
        "lark swofford", "daughters lark", "daughters lark and codi",
        "greg sansing", "3rd gen sansing",
        "mark newberry, pharmd (3rd gen",
        "jeff carson, rph (ut college of pharmacy 1996",
        "industry-leading innovator, family legacy",
        # disqualifier prose
        "skip for short-term acquisition",
        "long-term watch list",
        "potential family-buyout exit",
    ]
    if any(k in full_lo for k in explicit_lock_phrases):
        return True

    # 3) Explicit acquisition_disqualifier mentioning family successor
    dq = (row.get("acquisition_disqualifier") or "").lower()
    if dq and any(k in dq for k in [
        "family successor", "active 2nd", "active 3rd", "active second",
        "active third", "tightly-held", "family-held", "family-owned multi-location",
        "active 2nd gen pharmd", "active 3rd gen pharmd",
    ]):
        return True

    # 4) Structured successor_indicators with verified_via mentioning younger generation
    succ = row.get("successor_indicators") or {}
    if succ.get("family_successor_present") is True:
        verified_via = (succ.get("verified_via") or "")
        verified_via_lo = verified_via.lower()
        # Younger-gen reference in verified_via with no exempting context
        if YOUNGER_GEN_PAT.search(verified_via):
            # Negation check: if verified_via says "not owner" / "not as owner" /
            # "part-time relief pharmacist, not owner", DO NOT lock
            if any(neg in verified_via_lo for neg in [
                "not owner", "not the owner", "not as owner",
                "not part of ownership", "relief pharmacist",
                "part-time",
            ]):
                return False
            return True
        # If no younger-gen reference but verified_via mentions "brothers" /
        # "husband+wife" / "wife,? rph" — same-gen family — NOT locked
        if SAME_GEN_FAMILY_PAT.search(verified_via):
            return False
        # No clear signal in verified_via but family_successor_present=true.
        # Check the rest of the text for younger-gen.
        if YOUNGER_GEN_PAT.search(full):
            # Negation check on full text
            if any(neg in full_lo for neg in [
                "not owner", "not the owner", "not as owner",
                "relief pharmacist, not owner",
            ]):
                return False
            return True
        # Otherwise: presence of family_successor_present without specific younger-gen
        # evidence — NOT locked (conservative against false positives like KK's where
        # "founder partnership" was treated as successor).
        return False

    # 5) Generic "Xnd gen" / "Xrd gen" language in full text — locked unless
    #    same-gen family or founder-cohort exemption applies
    if any(k in full_lo for k in [
        "2nd gen", "3rd gen", "third-generation", "second-generation",
    ]):
        if SAME_GEN_FAMILY_PAT.search(full):
            return False
        return True
    return False


# --- Confidence / completeness ---------------------------------------------

def infer_confidence(row: dict) -> str:
    """Map to canonical {high, medium, low, unknown}."""
    explicit = (row.get("enrichment_confidence_overall") or "").lower().strip()
    if explicit in ("high", "medium", "low", "unknown"):
        return explicit
    dc = row.get("data_completeness")
    try:
        dc = float(dc) if dc is not None else None
    except Exception:
        dc = None
    if dc is None:
        return "low"
    if dc >= 0.75:
        return "high"
    if dc >= 0.55:
        return "medium"
    if dc >= 0.35:
        return "low"
    return "unknown"


def can_verify(row: dict) -> bool:
    """
    Gate 1: must have at least one of (license, NPI, website, owner_name,
    valid_entity_status, year_established) — i.e., independently verifiable
    that the business exists.
    """
    have = any([
        row.get("license_number"),
        row.get("license_holder_name"),
        row.get("website"),
        row.get("owner_name"),
        row.get("year_established"),
        row.get("phone"),
        (row.get("entity_status") or "").lower() not in ("", "unknown", None),
    ])
    return have


# --- Coasting tells (Layer 3) -----------------------------------------------

PHARMACY_COAST_TELL_KEYWORDS = [
    ("pre-2015 website or none", lambda r: not r.get("website") or "pre-201" in (r.get("verification_notes","")+(r.get("enrichment_notes") or "")+(", ".join(r.get("coasting_tells",[]) or []))).lower()),
    ("no online refill / app", lambda r: r.get("online_refill_observed") is False),
    ("phone-only intake", lambda r: r.get("phone_intake_only_likely") is True),
    ("no vaccine clinic", lambda r: r.get("vaccine_clinic_observed") is False),
    ("no specialty services", lambda r: not r.get("compounding_capability") and not (r.get("services") or [])),
    ("no MTM", lambda r: False),  # rarely observed in this enrichment
    ("storefront photos aged / legacy branding", lambda r: bool([t for t in (r.get("coasting_tells") or []) if "legacy" in t.lower() or "branding" in t.lower()])),
    ("no Rx sync mentioned", lambda r: False),  # not directly observed
    ("modern PIMS absent", lambda r: False),
    ("owner 75+ with no clear successor", lambda r: (safe_int(r.get("owner_age_estimate"), 0) or 0) >= 75 and not (r.get("successor_indicators") or {}).get("family_successor_present")),
    ("30+ yr tenure under same owner", lambda r: (safe_int(r.get("owner_tenure_years"), 0) or 0) >= 30),
    ("single-store solo PIC operation", lambda r: r.get("size_tier") == "single_store_solo" or ((safe_int(r.get("location_count"),1) or 1) == 1 and (safe_int(r.get("pharmacist_count"), 1) or 1) <= 1)),
    ("RxLocal-only microsite (no independent domain)", lambda r: "rxlocal" in (r.get("banner_program") or "").lower() and not r.get("website")),
    ("no public team / about page", lambda r: bool([t for t in (r.get("coasting_tells") or []) if "no public" in t.lower() or "no about" in t.lower() or "no team" in t.lower()]) or (r.get("data_completeness") is not None and float(r.get("data_completeness") or 0) < 0.4)),
]


def count_pharmacy_tells(row: dict) -> tuple[int, list[str]]:
    tells = []
    # Explicit tells from enrichment
    raw_tells = row.get("coasting_tells") or []
    for t in raw_tells:
        tells.append(t)
    # Inferred tells (only count once)
    seen = set(t.lower() for t in tells)
    for name, fn in PHARMACY_COAST_TELL_KEYWORDS:
        try:
            if fn(row) and name.lower() not in seen:
                tells.append(name)
                seen.add(name.lower())
        except Exception:
            pass
    # If no website at all, ensure "no/aged website" tell present
    if not row.get("website") and not any("website" in t.lower() for t in tells):
        tells.append("no independent website")
    return (len(tells), tells)


# --- Layer scoring ----------------------------------------------------------

def score_layer1_owner_age(age: int | None) -> tuple[float, str]:
    if age is None:
        return (45.0, "no owner-age signal; midpoint placeholder")
    if age >= 68:
        s = clamp(88 + (age - 68) * 1.5, 88, 100)
        return (s, f"Owner ~{age} (68+ band, peak succession risk)")
    if age >= 63:
        s = clamp(75 + (age - 63) * 3.0, 75, 90)
        return (s, f"Owner ~{age} (63-67 band, high succession risk)")
    if age >= 58:
        s = clamp(55 + (age - 58) * 4.6, 55, 78)
        return (s, f"Owner ~{age} (58-62 band, moderate succession risk)")
    if age >= 53:
        s = clamp(35 + (age - 53) * 5.75, 35, 58)
        return (s, f"Owner ~{age} (53-57 band, early succession window)")
    s = clamp(10 + (53 - age) * (-1), 10, 35)
    if age < 53:
        s = clamp(10 + (age / 53.0) * 25, 10, 35)
    return (s, f"Owner ~{age} (<53, low succession risk)")


def score_layer2_sellability(row: dict) -> tuple[float, str]:
    """
    Multi-pharmacist 10+ yr Class A → 80-95
    Solo pharmacist 10+ → 65-82
    Compounding/specialty premium → +5
    Banner (GNP / Health Mart) → +3
    """
    loc = safe_int(row.get("location_count"), 1) or 1
    pharm = safe_int(row.get("pharmacist_count"), None)
    if pharm is None:
        pharm = safe_int(row.get("provider_count_estimate"), 1) or 1
    tenure = safe_int(row.get("owner_tenure_years"), None)
    yib = safe_int(row.get("years_in_business"), None)
    eff_tenure = max(tenure or 0, yib or 0)

    license_type = (row.get("license_type") or "").lower()
    is_class_a = "class a" in license_type or "community pharmacy" in license_type or row.get("banner_program")  # most spine entries are Class A by definition

    compounding = bool(row.get("compounding_capability")) and (row.get("compounding_capability") not in ("unknown", None, False))
    services = row.get("services") or []
    services_str = " ".join(s.lower() for s in services if isinstance(s, str))
    has_specialty = compounding or any(s in services_str for s in ["specialty", "ltc", "long-term care", "veterinary", "compounding", "sterile"])

    banner = (row.get("banner_program") or "").lower()
    has_banner = ("good neighbor" in banner) or ("health mart" in banner) or ("gnp" in banner)

    multi_pharm = (pharm or 1) >= 2 or loc >= 2

    if multi_pharm and eff_tenure >= 10 and is_class_a:
        extra = 0
        if eff_tenure >= 10:
            extra += min(8, (eff_tenure - 10) * 0.3)
        if loc >= 2:
            extra += min(6, (loc - 1) * 2.5)
        if pharm and pharm >= 3:
            extra += min(4, (pharm - 2) * 1.0)
        base = clamp(80 + extra, 80, 95)
        comment = f"Multi-pharmacist/multi-loc Class A, {eff_tenure}yr tenure ({loc} loc, {pharm} pharmacist(s))"
    elif eff_tenure >= 10 and is_class_a:
        base = 65 + min(17, (eff_tenure - 10) * 0.6)
        base = clamp(base, 65, 82)
        comment = f"Solo pharmacist 10+yr Class A ({eff_tenure}yr tenure)"
    elif eff_tenure >= 5 and is_class_a:
        base = 45 + (eff_tenure - 5) * 4
        base = clamp(base, 45, 65)
        comment = f"Class A pharmacy ({eff_tenure}yr) — short of 10yr sellability floor"
    else:
        # Either unknown tenure or short tenure
        if eff_tenure and eff_tenure < 5:
            base = 25
            comment = f"<5yr operation ({eff_tenure}yr) — undersized for sellability"
        else:
            base = 50
            comment = "Class A pharmacy, tenure unknown — placeholder midpoint"

    boost_notes = []
    if compounding:
        base += 5
        boost_notes.append("+5 compounding")
    elif has_specialty:
        base += 3
        boost_notes.append("+3 specialty (LTC/veterinary)")
    if has_banner:
        base += 3
        boost_notes.append("+3 banner (GNP/Health Mart)")

    base = clamp(base, 0, 100)
    if boost_notes:
        comment += " | " + ", ".join(boost_notes)
    return (base, comment)


def score_layer3_coasting(row: dict) -> tuple[float, str]:
    n, tells = count_pharmacy_tells(row)
    # Map count to band
    if n >= 4:
        s = clamp(80 + min(20, (n - 4) * 4), 80, 100)
    elif n >= 2:
        s = clamp(55 + (n - 2) * 12, 55, 80)
    elif n == 1:
        s = 42
    else:
        s = 18
    comment = f"{n} coast tell(s): " + (list_join(tells[:6]) if tells else "none observed")
    return (s, comment)


def score_layer4_market(row: dict) -> tuple[float, str]:
    base = 55  # neutral baseline (rising PBM compression industry-wide)
    notes = ["pharmacy PE consolidation rising; PBM compression = motivated sellers (+5 baseline)"]
    base += 5  # baseline market pull for pharmacy vertical

    city = (row.get("city") or "").strip()
    county = (row.get("county") or "").strip()

    if county in RURAL_ELDERLY_COUNTIES:
        base += 5
        notes.append(f"+5 rural-elderly/RGV/El Paso ({county})")
    elif city in HISPANIC_MAJORITY_METROS:
        base += 5
        notes.append(f"+5 Hispanic-majority metro ({city})")
    elif city in INNER_CITY_URBAN_PEN:
        # Inner-city urban penalty (only when not offset by other positive)
        base -= 3
        notes.append(f"-3 inner-city urban ({city})")

    # Compounding specialty premium
    if row.get("compounding_capability") and row.get("compounding_capability") not in ("unknown", None, False):
        base += 5
        notes.append("+5 compounding specialty")

    base = clamp(base, 20, 100)
    return (base, " | ".join(notes))


# --- Tiering ----------------------------------------------------------------

def tier_from_score(score: float, cap: str | None = None) -> str:
    """A: >=85, B: >=70, C: >=55, D: <55. Apply cap if given."""
    if score >= 85:
        t = "A"
    elif score >= 70:
        t = "B"
    elif score >= 55:
        t = "C"
    else:
        t = "D"
    order = ["A", "B", "C", "D"]
    if cap and order.index(t) < order.index(cap):
        t = cap
    return t


# --- Main scoring -----------------------------------------------------------

def score_row(row: dict, batch_idx: int) -> dict:
    legal_name = row.get("legal_name") or "(unknown)"
    dba = row.get("dba_name") or legal_name
    city = row.get("city")
    county = row.get("county")
    state = row.get("state") or "TX"

    spine_idx = row.get("spine_index")
    target_id = f"pharm-{batch_idx}-{spine_idx if spine_idx is not None else legal_name.lower().replace(' ', '-')[:30]}"

    confidence = infer_confidence(row)
    completeness = row.get("data_completeness")
    try:
        completeness = float(completeness) if completeness is not None else None
    except Exception:
        completeness = None

    # Distress detection
    is_dist, dist_reasons = detect_distress(row)

    # Gate 1: can verify?
    verifiable = can_verify(row)
    drop_reason = None
    if not verifiable:
        drop_reason = "cannot_verify_business_exists"

    # Disqualifier classification
    dq_type = detect_disqualifier_type(row)
    if dq_type and dq_type in ("closed_or_stale", "non_independent_or_hospital_owned", "public_corp", "pe_owned", "duplicate_of_other_spine_entry"):
        drop_reason = dq_type
    # Young owner / recent acquisition: drop OR demote to D
    young_dq = (dq_type == "young_owner_or_recent_acquisition")
    grocery_dq = (dq_type == "in_store_grocery_lease_dependent")

    # Years in business gate
    yib = safe_int(row.get("years_in_business"), None)
    short_tenure = yib is not None and yib < 5

    # Family-successor-locked? demote (cap C) but keep on watch list
    family_locked = is_family_succ_locked(row)

    # Layer 1
    age = safe_int(row.get("owner_age_estimate"), None)
    L1, L1c = score_layer1_owner_age(age)

    # Layer 2
    L2, L2c = score_layer2_sellability(row)

    # Layer 3
    L3, L3c = score_layer3_coasting(row)

    # Layer 4
    L4, L4c = score_layer4_market(row)

    raw = 0.30 * L1 + 0.25 * L2 + 0.30 * L3 + 0.15 * L4
    final_score = round(raw)

    # Apply hard gates and caps
    cap = None
    layer_notes_extra = []

    if is_dist:
        # D_pass <=25 (must be max 25)
        final_score = min(final_score, 25)
        cap = "D"
        layer_notes_extra.append("Hard gate: distressed — capped to D_pass<=25")
    if short_tenure:
        final_score = min(final_score, 35)
        cap = "C" if cap != "D" else cap
        layer_notes_extra.append(f"Hard gate: <5yr operation ({yib}yr) — capped to <=35, max C")
    if confidence in ("low", "unknown"):
        # Confidence < medium → if final >= 85 (A), cap to B
        # We implement: cap to B when confidence not >= medium
        if final_score >= 85:
            final_score = min(final_score, 84)
            layer_notes_extra.append("Hard gate: confidence<medium with A-tier raw score — capped to B")
        cap = "B" if cap not in ("C", "D") else cap
    # Successor verification missing on A/B → cap C
    succ = row.get("successor_indicators") or {}
    succ_verified = bool(succ.get("verified_via")) or row.get("license_holder_name")
    raw_tier = tier_from_score(final_score, cap=None)
    if not succ_verified and raw_tier in ("A", "B"):
        final_score = min(final_score, 69)
        cap = "C" if cap not in ("D",) else cap
        layer_notes_extra.append("Hard gate: successor verif missing on A/B candidate — capped to C")

    # Deep-dive not done → cap B + deep_dive_pending=true
    # Treat batch_3 spine-inference-only rows or "deferred_to_downstream" as deep-dive pending.
    deep_dive_pending = False
    if row.get("deferred_to_downstream") or "spine_inference_only" in (row.get("enrichment_method") or ""):
        deep_dive_pending = True
        if final_score >= 85:
            final_score = min(final_score, 84)
            layer_notes_extra.append("Hard gate: deep-dive pending — capped to B")
        cap = "B" if cap not in ("C", "D") else cap

    # Family-successor-locked demotion
    if family_locked:
        final_score = min(final_score, 65)
        cap = "C" if cap not in ("D",) else cap
        layer_notes_extra.append("Family successor in place — demoted (watch-list, not active target)")

    # Lease-dependent → cap C
    if grocery_dq:
        final_score = min(final_score, 60)
        cap = "C" if cap not in ("D",) else cap
        layer_notes_extra.append("In-store grocery lease dependency — capped to C")

    # Young pharmacy / recent ownership → cap D
    if young_dq:
        final_score = min(final_score, 40)
        cap = "D"
        layer_notes_extra.append("Young owner / recent ownership change — not exit-ready, capped to D")

    final_tier = tier_from_score(final_score, cap=cap)

    # If we marked as drop_reason, force D
    if drop_reason:
        final_tier = "D"
        final_score = min(final_score, 20)
        layer_notes_extra.append(f"DROP: {drop_reason}")

    # Compose final comment / thesis
    owner_name = row.get("owner_name")
    age_str = f"~{age}" if age else "age unknown"
    final_comment_bits = []
    if final_tier == "A":
        final_comment_bits.append(f"A-tier: {legal_name} ({city}). Owner {owner_name or 'unknown'} {age_str}, {yib or '?'}yr operation.")
    elif final_tier == "B":
        final_comment_bits.append(f"B-tier: {legal_name} ({city}). Owner {owner_name or 'unknown'} {age_str}, {yib or '?'}yr operation.")
    elif final_tier == "C":
        final_comment_bits.append(f"C-tier: {legal_name} ({city}). " + ", ".join(layer_notes_extra) if layer_notes_extra else f"C-tier: {legal_name} ({city}).")
    else:
        final_comment_bits.append(f"D-tier: {legal_name} ({city}). " + (", ".join(layer_notes_extra) if layer_notes_extra else ""))

    thesis_bits = []
    if final_tier in ("A", "B"):
        thesis_bits.append(
            f"Independent retail pharmacy ({yib or '?'}yr) in {city}, {state}. "
            f"PBM compression + pharmacy PE consolidation = motivated seller pool. "
            f"Value-add: replace owner-PIC with PharmD operator, deploy modern PIMS / online refill / vaccine clinic, "
            f"add Med Sync / MTM, monetize compounding or LTC if existing, roll into multi-store platform."
        )
        if row.get("compounding_capability") and row.get("compounding_capability") not in ("unknown", None, False):
            thesis_bits.append("Compounding capability = enterprise multiple lift.")
        if (row.get("banner_program") or "").lower().find("good neighbor") >= 0 or "health mart" in (row.get("banner_program") or "").lower():
            thesis_bits.append("Banner affiliation (GNP/Health Mart) = professional ops; clean PE roll-up integration.")
    elif final_tier == "C":
        thesis_bits.append("Watch-list. Verify successor status, owner age, and deep-dive verification before active outreach.")
    else:
        thesis_bits.append("Not a current target. See disqualifier / distress reasons.")
    value_add_thesis = " ".join(thesis_bits)

    # Layer comments combined
    layer_comments = {
        "layer1_owner_age": L1c,
        "layer2_sellability": L2c,
        "layer3_coasting": L3c,
        "layer4_market": L4c,
        "score_caps_and_gates": layer_notes_extra,
    }

    final_comment = " | ".join([
        c for c in final_comment_bits if c
    ])
    if layer_notes_extra and final_tier in ("A", "B"):
        final_comment += " | " + "; ".join(layer_notes_extra)

    # Data sources
    sources = row.get("data_sources") or []
    if not isinstance(sources, list):
        sources = []

    # Build output
    out = {
        "target_id": target_id,
        "score_run_id": SCORE_RUN_ID,
        "vertical": VERTICAL,
        "naics_code": NAICS,
        "legal_name": legal_name,
        "dba_name": dba,
        "address": row.get("address"),
        "city": city,
        "county": county,
        "state": state,
        "zip": row.get("zip"),
        "phone": row.get("phone"),
        "website": row.get("website"),
        "license_number": row.get("license_number"),
        "license_type": row.get("license_type"),
        "license_holder_name": row.get("license_holder_name"),
        "banner_program": row.get("banner_program"),
        "owner_name": owner_name,
        "owner_age_estimate": age,
        "owner_age_source": row.get("owner_age_source"),
        "owner_tenure_years": row.get("owner_tenure_years"),
        "years_in_business": yib,
        "entity_status": row.get("entity_status"),
        "is_distressed": is_dist,
        "distress_reasons": dist_reasons,
        "location_count": row.get("location_count"),
        "pharmacist_count": row.get("pharmacist_count") or row.get("provider_count_estimate"),
        "compounding_capability": row.get("compounding_capability"),
        "successor_indicators": row.get("successor_indicators"),
        "layer1_score": round(L1, 1),
        "layer1_comment": L1c,
        "layer2_score": round(L2, 1),
        "layer2_comment": L2c,
        "layer3_score": round(L3, 1),
        "layer3_comment": L3c,
        "layer4_score": round(L4, 1),
        "layer4_comment": L4c,
        "layer_comments": layer_comments,
        "final_score": final_score,
        "final_tier": final_tier,
        "final_comment": final_comment,
        "value_add_thesis": value_add_thesis,
        "confidence": confidence,
        "data_completeness": completeness,
        "deep_dive_pending": deep_dive_pending,
        "drop_reason": drop_reason,
        "disqualifier_type": dq_type,
        "family_successor_locked": family_locked,
        "data_sources": sources,
        "scored_at": NOW_ISO,
        "batch_idx": batch_idx,
        "spine_index": spine_idx,
    }
    return out


def main():
    all_scored = []
    for batch_idx in (1, 2, 3):
        path = DATA_DIR / f"independent_pharmacy_enrich_batch_{batch_idx}.json"
        with open(path) as f:
            rows = json.load(f)
        for r in rows:
            all_scored.append(score_row(r, batch_idx))
        print(f"[batch {batch_idx}] scored {len(rows)} rows")

    # Sort: tier ASC (A first), then final_score DESC
    tier_order = {"A": 0, "B": 1, "C": 2, "D": 3}
    all_scored.sort(key=lambda r: (tier_order.get(r["final_tier"], 9), -r["final_score"]))

    # Write JSON
    json_out = DATA_DIR / "independent_pharmacy_targets.json"
    with open(json_out, "w") as f:
        json.dump(all_scored, f, indent=2, default=str)
    print(f"Wrote {json_out} ({len(all_scored)} rows)")

    # Write CSV (flattened)
    csv_fields = [
        "target_id", "score_run_id", "vertical", "naics_code",
        "legal_name", "dba_name", "address", "city", "county", "state", "zip", "phone", "website",
        "license_number", "license_type", "license_holder_name", "banner_program",
        "owner_name", "owner_age_estimate", "owner_age_source", "owner_tenure_years",
        "years_in_business", "entity_status", "is_distressed", "distress_reasons",
        "location_count", "pharmacist_count", "compounding_capability",
        "layer1_score", "layer1_comment",
        "layer2_score", "layer2_comment",
        "layer3_score", "layer3_comment",
        "layer4_score", "layer4_comment",
        "final_score", "final_tier", "final_comment", "value_add_thesis",
        "confidence", "data_completeness", "deep_dive_pending",
        "drop_reason", "disqualifier_type", "family_successor_locked",
        "scored_at", "batch_idx", "spine_index",
    ]
    csv_out = DATA_DIR / "independent_pharmacy_targets.csv"
    with open(csv_out, "w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=csv_fields, extrasaction="ignore")
        w.writeheader()
        for r in all_scored:
            row = {k: r.get(k) for k in csv_fields}
            # Stringify list / dict fields
            for k, v in list(row.items()):
                if isinstance(v, (list, dict)):
                    row[k] = json.dumps(v, default=str)
            w.writerow(row)
    print(f"Wrote {csv_out}")

    # Summary
    from collections import Counter
    tier_counts = Counter(r["final_tier"] for r in all_scored)
    drop_counts = Counter(r.get("drop_reason") for r in all_scored if r.get("drop_reason"))
    distress_count = sum(1 for r in all_scored if r["is_distressed"])
    deep_dive_count = sum(1 for r in all_scored if r["deep_dive_pending"])
    family_locked_count = sum(1 for r in all_scored if r.get("family_successor_locked"))

    print("\n=== SCORE SUMMARY ===")
    print(f"Total: {len(all_scored)}")
    for t in ("A", "B", "C", "D"):
        print(f"  Tier {t}: {tier_counts.get(t, 0)}")
    print(f"Distressed: {distress_count}")
    print(f"Deep-dive pending: {deep_dive_count}")
    print(f"Family-successor-locked: {family_locked_count}")
    print(f"Drop reasons: {dict(drop_counts)}")

    print("\nTop 25 by final_score (Tier A/B):")
    top = [r for r in all_scored if r["final_tier"] in ("A", "B")][:25]
    for r in top:
        print(f"  [{r['final_tier']}] {r['final_score']}  {r['legal_name']} ({r['city']}) "
              f"age={r.get('owner_age_estimate')} yrs={r.get('years_in_business')} loc={r.get('location_count')} "
              f"conf={r['confidence']} dd_pending={r['deep_dive_pending']}")


if __name__ == "__main__":
    main()
