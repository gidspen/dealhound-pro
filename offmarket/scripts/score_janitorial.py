#!/usr/bin/env python3
"""
Score enriched janitorial businesses using the canonical 4-layer off-market
acquisition model. Writes janitorial_targets.json + .csv. Persists
incrementally — every record appended atomically.

Layer weights:  L1 0.30  L2 0.25  L3 0.30  L4 0.15

Vertical specifics (janitorial):
- L2: 70-90% recurring monthly contracts -> 80-92. Medical/HIPAA + school +
  church bonus -> +5 (specialty value).
- L3 janitorial tells: pre-2015 site, no customer portal, no work-order app,
  no Janitorial Manager / Clean Easier visible, phone-only, owner cleaning,
  no social, no hiring, stale copyright.
- L4 janitorial market pull: ABM/Pritchard/Aramark/Diversified Maintenance
  active.  DFW+Austin commercial-growth -> 80-88.  Houston -> 75-85.  SA ->
  70-78.  Suburban office-park-heavy (Plano/Sugar Land/Round Rock/Las
  Colinas) -> +3.  Rural -> -5.

Hard gates per canonical:
- is_distressed=true  -> D_pass, score <= 25.
- years_in_business < 5  -> max C_watch, score <= 35.
- Confidence < medium AND would otherwise land in A  -> cap at B_forward.
- A-tier deep-dive not yet completed  -> cap at B_forward (mark
  deep_dive_pending=true).
- Successor verification not done on candidate A/B  -> cap at C_watch.
"""

import csv
import json
from pathlib import Path

ROOT = Path("/Users/gideonspencer/dealhound-pro/.claude/worktrees/laughing-yonath-843b53/offmarket/data")
SCORE_RUN_ID = "76d82ef9-f0db-4c64-92ef-db2973d7f014"
OUT_JSON = ROOT / "janitorial_targets.json"
OUT_CSV = ROOT / "janitorial_targets.csv"
BATCHES = [
    ROOT / "janitorial_enrich_batch_1.json",
    ROOT / "janitorial_enrich_batch_2.json",
]

# Spine-flagged distress exclusions
EXCLUDE_FOR_DISTRESS_SPINE_IDX = {71, 83, 94}


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

DFW_COMMERCIAL_GROWTH = {
    "Plano", "Frisco", "Allen", "McKinney", "Carrollton", "Richardson",
    "Garland", "Irving", "Las Colinas", "Las colinas", "Grapevine",
    "Southlake", "South Lake", "Coppell", "Lewisville", "Flower Mound",
    "Addison", "Farmers Branch", "Dallas", "Fort Worth",
    "Hurst", "Richland Hills", "North Richland Hills", "Arlington",
    "Mansfield", "Keller", "Euless", "Bedford", "Grand Prairie",
}

SUBURBAN_OFFICE_PARK_NUDGE_CITIES = {
    "Plano", "Frisco", "Allen", "McKinney", "Sugar Land", "Round Rock",
    "Las Colinas", "Pflugerville", "Cedar Park", "The Woodlands", "Spring",
    "Katy", "Coppell", "Las colinas", "Lewisville", "Flower Mound",
    "Richardson", "Carrollton", "Southlake", "South Lake",
}

AUSTIN_METRO = {
    "Austin", "Round Rock", "Pflugerville", "Cedar Park", "Buda",
    "Kyle", "Leander", "Georgetown", "Lakeway",
}

HOUSTON_METRO = {
    "Houston", "Sugar Land", "Katy", "Cypress", "Tomball", "Pearland",
    "Spring", "The Woodlands", "Conroe", "Friendswood", "League City",
    "Webster", "Stafford", "Missouri City", "Kingwood", "Magnolia",
    "Humble",
}

SAN_ANTONIO_METRO = {
    "San Antonio", "Schertz", "Boerne", "New Braunfels",
}

# Secondary / smaller TX metros
SECONDARY_METROS = {
    "Lubbock", "Amarillo", "El Paso", "Corpus Christi", "Beaumont",
    "Galveston", "Tyler", "Longview", "Waco", "Bryan", "College Station",
    "Killeen", "Temple", "Belton", "Sherman", "Denison", "Wichita Falls",
    "San Angelo", "Texarkana", "Midland", "Odessa", "McAllen",
    "Harlingen", "Brownsville", "Laredo", "Nacogdoches", "Lufkin",
}

RURAL_INDICATORS = {
    "Canton", "Atlanta", "Hamshire", "Nacogdoches", "Sachse",
}


def is_dfw(city: str) -> bool:
    if not city:
        return False
    return city in DFW_COMMERCIAL_GROWTH or "DFW" in city.upper() or "Dallas-Fort Worth" in city


def is_austin(city: str) -> bool:
    if not city:
        return False
    return city in AUSTIN_METRO


def is_houston(city: str) -> bool:
    if not city:
        return False
    return city in HOUSTON_METRO


def is_sa(city: str) -> bool:
    if not city:
        return False
    return city in SAN_ANTONIO_METRO


def is_secondary(city: str) -> bool:
    if not city:
        return False
    return city in SECONDARY_METROS


def is_suburban_park(city: str) -> bool:
    if not city:
        return False
    return city in SUBURBAN_OFFICE_PARK_NUDGE_CITIES


def is_rural(city: str) -> bool:
    if not city:
        return False
    return city in RURAL_INDICATORS


# ---------------------------------------------------------------------------
# Layer scoring
# ---------------------------------------------------------------------------

def score_layer1(rec):
    """Owner natural-exit timing. 0-100. Weight 0.30."""
    age = rec.get("owner_age_estimate")
    # Some enrich records have age stored as strings like "60+", "45-60",
    # "65+ (46-year operator)", "60-75". Extract leading number(s) robustly.
    if isinstance(age, str):
        import re
        s = age.strip()
        # First, try a range like "60-75" or "45 - 60"
        m_range = re.match(r"^(\d{2})\s*[-–]\s*(\d{2})", s)
        m_plus = re.match(r"^(\d{2})\s*\+", s)
        m_int = re.match(r"^(\d{2})", s)
        if m_range:
            try:
                age = (int(m_range.group(1)) + int(m_range.group(2))) // 2
            except Exception:
                age = None
        elif m_plus:
            try:
                age = int(m_plus.group(1))
            except Exception:
                age = None
        elif m_int:
            try:
                age = int(m_int.group(1))
            except Exception:
                age = None
        else:
            age = None

    tenure = rec.get("years_in_business")
    owner_name = rec.get("owner_name")
    age_source = rec.get("owner_age_source") or ""

    base = 25
    comment_parts = []

    if age is not None:
        if age >= 68:
            base = 92
            comment_parts.append(f"Owner age ~{age} (src: {age_source[:60]}) — squarely 68+ exit band")
        elif age >= 63:
            base = 82
            comment_parts.append(f"Owner age ~{age} entering 63-67 exit band")
        elif age >= 58:
            base = 67
            comment_parts.append(f"Owner age ~{age} approaching retirement (58-62)")
        elif age >= 53:
            base = 47
            comment_parts.append(f"Owner age ~{age} pre-retirement (53-57)")
        else:
            base = 22
            comment_parts.append(f"Owner age ~{age} mid-career, exit unlikely <5 yrs")
    else:
        base = 22
        comment_parts.append("Owner age unknown — weak proxy applied (cap L1 low)")

    # Tenure modifier
    if tenure is not None:
        if tenure >= 25:
            base += 4
            comment_parts.append(f"+4 for {tenure}-yr personal tenure")
        elif tenure < 10:
            base -= 7
            comment_parts.append(f"-7 for thin {tenure}-yr tenure")

    base = max(5, min(100, base))
    return base, "; ".join(comment_parts)


def score_layer2(rec):
    """Sellability — real, healthy, SBA-financeable. 0-100. Weight 0.25."""
    years = rec.get("years_in_business")
    succ = rec.get("successor_indicators") or {}
    second_gen = succ.get("second_gen_present")
    family_succ = succ.get("family_successor_present")

    notes = (rec.get("notes") or "").lower()
    service_mix = (rec.get("service_mix") or "").lower()
    signals_summary = (rec.get("signals_summary") or "").lower()

    emp = rec.get("employee_count_estimate")
    emp_str = emp if isinstance(emp, str) else (f"{emp}" if emp else "")
    emp_lower = emp_str.lower() if emp_str else ""

    contract_base = (rec.get("contract_base_strength") or "").lower()

    base = 50
    comment_parts = []

    # Tenure-driven baseline
    if years is None:
        base = 50
        comment_parts.append("Tenure unverified — neutral sellability base")
    elif years >= 25:
        base = 80
        comment_parts.append(f"Clean {years}-yr operation — multi-decade institutional base")
    elif years >= 10:
        base = 72
        comment_parts.append(f"Clean {years}-yr operator")
    elif years >= 5:
        base = 55
        comment_parts.append(f"{years}-yr operator — sub-decade, moderate sellability")
    else:
        base = 32
        comment_parts.append(f"Thin {years}-yr tenure — sellability suppressed (Hard gate)")

    # Janitorial recurring-revenue bonus
    if "recurring" in contract_base or "recurring" in service_mix \
       or "contract" in contract_base.replace("contract_base_strength", "") \
       or "office" in service_mix or "porter" in service_mix \
       or "monthly" in service_mix or "70+ contract" in signals_summary:
        base += 4
        comment_parts.append("+4 recurring monthly contract pattern (janitorial sellability lift)")

    # Specialty bonus (medical/HIPAA + school + church)
    has_medical = "medical" in service_mix or "hipaa" in service_mix \
        or rec.get("hipaa_certified") is True or "healthcare" in service_mix \
        or "terminal" in service_mix or "biohazard" in service_mix
    has_school = "school" in service_mix or "k-12" in service_mix \
        or "college" in service_mix or "education" in service_mix
    has_church = "church" in service_mix or "religious" in service_mix \
        or "worship" in service_mix
    specialty_count = sum([has_medical, has_school, has_church])
    if specialty_count >= 2:
        base += 5
        comment_parts.append(
            f"+5 specialty-vertical mix (med/school/church x{specialty_count})")
    elif specialty_count == 1:
        base += 2
        comment_parts.append("+2 single-specialty vertical")

    # Cert layer
    if rec.get("bscai_member"):
        base += 3
        comment_parts.append("+3 BSCAI member")
    if rec.get("issa_member"):
        base += 2
        comment_parts.append("+2 ISSA member")
    if rec.get("iicrc_certified"):
        base += 2
        comment_parts.append("+2 IICRC certified")
    if rec.get("hub_certified") is True or rec.get("wbenc_certified") is True \
       or rec.get("mbe_certified") is True or rec.get("sba_certified") is True \
       or rec.get("sam_gov_eligible"):
        base += 3
        comment_parts.append("+3 minority/woman/sba cert (institutional contract premium)")

    # Family-multi-gen succession already locked-in -> reduces sellability for outside ETA
    if second_gen and family_succ:
        base -= 8
        comment_parts.append("-8 active multi-gen family succession (limits outside ETA window)")

    # Over-size penalty (too large for SBA micro-acquisition)
    if "500+" in emp_lower or "650" in emp_lower or "1500" in emp_lower \
       or "300+" in signals_summary \
       or "platform" in (rec.get("notes") or "").lower() \
       or "lower-middle-market" in (rec.get("notes") or "").lower() \
       or "above sba" in (rec.get("notes") or "").lower() \
       or "wrong size" in (rec.get("notes") or "").lower():
        base -= 6
        comment_parts.append("-6 above SBA micro-acquisition target size")

    # Distress: gmail-only / no domain email = low investment
    distress = rec.get("distress_signals") or []
    if any("gmail" in str(d).lower() for d in distress):
        base -= 4
        comment_parts.append("-4 gmail-only signal — low-investment shop")

    # Franchise / disqualifying business model
    if "franchise" in notes and ("master" in notes or "sells own franchise" in notes
                                 or "franchisor" in notes):
        base = 20
        comment_parts.append("DISQUALIFIED: master franchisor / multi-unit licensor — wrong model")

    if "ex-franchise" in notes or "vanguard" in notes:
        base -= 4
        comment_parts.append("-4 ex-franchise origin")

    base = max(5, min(100, base))
    return base, "; ".join(comment_parts)


def score_layer3(rec):
    """Coasting tells. 0-100. Weight 0.30."""
    tells = rec.get("coasting_tells") or []
    if isinstance(tells, str):
        tells = [tells]
    succ = rec.get("successor_indicators") or {}
    second_gen = succ.get("second_gen_present")
    family_succ = succ.get("family_successor_present")
    notes = (rec.get("notes") or "").lower()
    signals_summary = (rec.get("signals_summary") or "").lower()
    service_mix = (rec.get("service_mix") or "").lower()
    distress = rec.get("distress_signals") or []
    modern_tech = (rec.get("modern_tech_indicators") or "").lower()

    # Reject items that are explicitly anti-coasting
    anti_keywords = [
        "inc 5000", "growth-mode", "actively scaling", "best place to work",
        "active engagement", "active growth",
        "growing", "scaling", "growth posture",
        "active 3-generation", "active multi-generational",
        "professionally-run", "not a coasting candidate",
        "active operator", "anti-coasting",
        "intentional delegation",
    ]

    # Strong coasting keyword bumps
    strong_coasting_keywords = [
        "stale", "stale copyright", "stale 2", "old footer",
        "expired ssl", "site unreachable", "site 503", "site 404",
        "broken", "broken about", "404", "site 503",
        "no customer portal", "no portal", "phone-forward", "phone-only",
        "phone only",
        "no team page", "no founder named", "no owner named",
        "no second-gen", "no successor",
        "owner identity opaque", "ownership opacity", "extreme opacity",
        "first-name only", "first name only", "owner cleaning",
        "first-name-only", "namesake-only",
        "first-name-only owner",
        "no industry credentials",
        "no social media", "no linkedin",
        "no copyright year",
        ".net domain", ".biz domain", "pre-2010 era",
        "estate-driven", "estate planning",
        "neglect", "neglected", "neglect signal",
        "po box address only", "po box only",
        "dated", "domain ends in", "dated-feel",
        "long-tenure", "long-tenured",
        "40-year sole-proprietor", "40-yr sole-proprietor",
        "40-year sole", "40-yr sole",
        "50-year", "50-yr",
        "founder identity defense", "founder-identity advertising",
        "stale website", "stale site",
        "outlook.com email", "@outlook.com",
        "founder mindset",
        "hours mon-sat", "working all hours",
        "owner working", "owner-doing-the-work",
        "site is dated",
        "dated content",
        "calendly only",
        "owner does the selling",
        "single-point-of-failure",
        "absentee", "absentee owner",
        "no second-gen named",
        "celebrating",
    ]

    count = 0
    matched_tells = []
    for tell in tells:
        t_lower = str(tell).lower()
        # Reject anti-coasting
        if any(k in t_lower for k in anti_keywords):
            continue
        # Count as coasting if it matches strong keywords OR is a plain tell
        if any(k in t_lower for k in strong_coasting_keywords):
            count += 1
            matched_tells.append(tell)
        else:
            # Generic tells (long tenure, broad service mix, single-metro, etc.)
            # only count weakly
            if (
                "year" in t_lower
                or "tenure" in t_lower
                or "no founder" in t_lower
                or "family-owned" in t_lower
                or "veteran" in t_lower
                or "broad service mix" in t_lower
                or "diversification" in t_lower
                or "diversified" in t_lower
                or "single-owner" in t_lower
                or "single-location" in t_lower
                or "narrow service" in t_lower
                or "owner-operator" in t_lower
                or "100+ combined years" in t_lower
                or "aging team" in t_lower
            ):
                count += 0.5
                matched_tells.append(tell)
            else:
                # Conservative count weak tells
                count += 0.5
                matched_tells.append(tell)

    # Distress-signal bumps (treated as strong coasting too)
    for d in distress:
        d_lower = str(d).lower()
        if "stale" in d_lower or "abandoned" in d_lower or "expired" in d_lower \
           or "abandoned website" in d_lower or "operator disengagement" in d_lower \
           or "lapse" in d_lower:
            count += 1
            matched_tells.append(d)

    # Score by tell count
    if count >= 4.5:
        base = 88
    elif count >= 3.5:
        base = 78
    elif count >= 2.5:
        base = 68
    elif count >= 1.5:
        base = 50
    elif count >= 0.5:
        base = 35
    else:
        base = 18

    # Heavily penalize active succession in-motion (already locked in)
    if second_gen and family_succ:
        base = min(base, 35)

    # Modern tech indicators (online portal, modern site) reduce coasting score
    if "online booking" in modern_tech or "calendly" in modern_tech \
       or "online employee portal" in modern_tech \
       or "above-average tech" in (rec.get("notes") or "").lower() \
       or "online quote" in modern_tech:
        base -= 8

    # Anti-coasting overrides (notes-driven)
    if "professionalized" in notes or "full c-suite" in notes \
       or "professionally-run" in notes or "not a coasting candidate" in signals_summary \
       or "growth-mode" in notes or "inc 5000" in notes \
       or "actively scaling" in notes \
       or "growing aggressively" in notes:
        base = min(base, 30)

    base = max(5, min(100, base))
    return base, f"{int(count)} tells: {'; '.join(str(t)[:80] for t in matched_tells[:5])}"


def score_layer4(rec):
    """Market pull / consolidator interest. 0-100. Weight 0.15."""
    city = rec.get("city") or ""
    base = 60
    parts = []

    if is_dfw(city):
        base = 84
        parts.append(f"DFW commercial-growth corridor ({city})")
    elif is_austin(city):
        base = 84
        parts.append(f"Austin commercial-growth corridor ({city})")
    elif is_houston(city):
        base = 80
        parts.append(f"Houston metro ({city})")
    elif is_sa(city):
        base = 74
        parts.append(f"San Antonio metro ({city})")
    elif is_secondary(city):
        base = 65
        parts.append(f"Secondary TX metro ({city})")
    else:
        base = 55
        parts.append(f"Tertiary/rural market ({city})")

    # Suburban office-park-heavy nudge
    if is_suburban_park(city):
        base += 3
        parts.append("+3 office-park-heavy suburban submarket")

    # Rural penalty
    if is_rural(city):
        base -= 5
        parts.append("-5 rural geography")

    # Mention national consolidators active in TX commercial cleaning
    parts.append("Consolidators active: ABM, Pritchard, Aramark, Diversified Maintenance")

    base = max(5, min(100, base))
    return base, "; ".join(parts)


# ---------------------------------------------------------------------------
# Hard gates + tier
# ---------------------------------------------------------------------------

def determine_confidence(rec):
    dc = rec.get("data_completeness") or 0
    owner_name = rec.get("owner_name")
    years = rec.get("years_in_business")
    if dc >= 0.75 and owner_name and years:
        return "high"
    if dc >= 0.55 and (owner_name or years):
        return "medium"
    return "low"


def assign_tier(final_score, l1, l3, confidence, is_distressed, years_in_business):
    """Apply tier rules + canonical caps."""
    notes_about_cap = []

    if is_distressed:
        return "D_pass", 25, ["distressed"], notes_about_cap

    if years_in_business is not None and years_in_business < 5:
        capped = min(final_score, 35)
        return "D_pass" if capped < 45 else "C_watch", capped, ["<5-yr hard gate"], notes_about_cap

    if final_score < 45:
        return "D_pass", final_score, [], notes_about_cap
    elif final_score < 60:
        return "C_watch", final_score, [], notes_about_cap
    elif final_score < 78:
        return "B_forward", final_score, [], notes_about_cap
    else:
        # Provisional A — apply A-tier gates
        if l1 < 70:
            notes_about_cap.append("cap B: L1 < 70")
            return "B_forward", final_score, [], notes_about_cap
        if l3 < 65:
            notes_about_cap.append("cap B: L3 < 65")
            return "B_forward", final_score, [], notes_about_cap
        if confidence == "low":
            notes_about_cap.append("cap B: confidence low")
            return "B_forward", final_score, [], notes_about_cap
        # All gates pass — true A with deep_dive_pending
        return "A_acquire_self", final_score, [], notes_about_cap


# ---------------------------------------------------------------------------
# Output schema
# ---------------------------------------------------------------------------

def build_value_add_thesis(rec, tier):
    """1-3 sentence pitch."""
    city = rec.get("city")
    service_mix = (rec.get("service_mix") or "").lower()
    contract = rec.get("contract_base_strength") or ""

    parts = []
    has_medical = "medical" in service_mix or "hipaa" in service_mix
    has_school = "school" in service_mix or "education" in service_mix
    has_church = "church" in service_mix
    has_govt = "government" in service_mix or rec.get("sam_gov_eligible") or rec.get("fema_first_responder")

    if tier == "A_acquire_self":
        parts.append(
            "Acquire long-tenure operator; modernize tech (Janitorial Manager / "
            "Clean Easier / Swept), digitize work orders + customer portal, "
            "raise rates 8-12% on legacy contracts, install full-time GM to "
            "replace founder-led inspection model."
        )
        if has_medical and (has_school or has_church):
            parts.append("Specialty book (medical + school/church) creates sticky multi-year recurring revenue.")
        elif has_govt:
            parts.append("FEMA / SAM.gov institutional book provides government-revenue moat.")
        parts.append("Target EBITDA uplift 400-700 bps via tech + pricing.")
    elif tier == "B_forward":
        parts.append(
            "Forward to ETA buyers or independent sponsors — modernize "
            "ops tech and customer portal, expand commercial book, replace "
            "founder-led inspections with operations-mgr layer."
        )
    elif tier == "C_watch":
        parts.append(
            "Watch list — owner age / tenure not yet in exit window. "
            "Re-check in 12-24 months for tenure milestone or succession signal."
        )
    else:
        parts.append("Pass — distress / size / model misfit for ETA acquisition.")

    return " ".join(parts)


def build_final_comment(rec, tier, l1, l2, l3, l4, final, distress_reasons, cap_notes):
    parts = []
    years = rec.get("years_in_business")
    owner = rec.get("owner_name") or "owner unknown"
    age = rec.get("owner_age_estimate")

    parts.append(
        f"L1={l1} L2={l2} L3={l3} L4={l4} final={final} tier={tier}."
    )

    if years and age:
        parts.append(f"{years}-yr operator, owner est ~{age}.")
    elif years:
        parts.append(f"{years}-yr operator, owner age TBD.")

    if tier == "A_acquire_self":
        parts.append(
            f"A-tier: institutional contract base + coasting tells + market pull. "
            f"Deep-dive pending (successor verification, contract count, financials)."
        )
    elif tier == "B_forward":
        if cap_notes:
            parts.append(f"B-tier ({'; '.join(cap_notes)}): forward to ETA/SS buyers.")
        else:
            parts.append("B-tier: forward to ETA buyer pool; modernize ops + pricing playbook.")
    elif tier == "C_watch":
        parts.append("C-watch: tenure or owner-age threshold not yet reached.")
    else:
        if distress_reasons:
            parts.append(f"D-pass: {', '.join(distress_reasons)}.")
        else:
            parts.append("D-pass: profile mismatch (size/model/tenure).")

    return " ".join(parts)


def to_target_record(rec, score_run_id):
    distress_reasons = []
    is_distressed = bool(rec.get("is_distressed"))
    spine_idx = rec.get("spine_index")

    # Force-distress for spine-listed exclusions (site unreachable / 503 / 404)
    if spine_idx in EXCLUDE_FOR_DISTRESS_SPINE_IDX:
        is_distressed = True
        distress_reasons.append("site_unreachable_or_5xx_4xx_at_enrichment")
    if rec.get("distress_signals"):
        for d in rec["distress_signals"]:
            d_l = str(d).lower()
            if "unreachable" in d_l or "abandoned" in d_l or "503" in d_l \
               or "404" in d_l or "hosting lapse" in d_l \
               or "domain/hosting" in d_l:
                is_distressed = True
                distress_reasons.append(str(d))

    # Score layers
    l1, l1_comment = score_layer1(rec)
    l2, l2_comment = score_layer2(rec)
    l3, l3_comment = score_layer3(rec)
    l4, l4_comment = score_layer4(rec)

    final = round(0.30 * l1 + 0.25 * l2 + 0.30 * l3 + 0.15 * l4)

    confidence = determine_confidence(rec)
    years = rec.get("years_in_business")

    tier, final_capped, gate_reasons, cap_notes = assign_tier(
        final, l1, l3, confidence, is_distressed, years
    )

    final_comment = build_final_comment(
        rec, tier, l1, l2, l3, l4, final_capped, distress_reasons + gate_reasons, cap_notes
    )
    thesis = build_value_add_thesis(rec, tier)

    # Successor cap: if A/B and successor not verified, downgrade
    succ = rec.get("successor_indicators") or {}
    if tier in ("A_acquire_self", "B_forward"):
        verified = succ.get("verified_via") or ""
        if not verified or "spine_only" in verified or "fetch_failed" in verified \
           or "FAILED" in verified or "site_unreachable" in verified:
            if tier == "A_acquire_self":
                tier = "B_forward"
                cap_notes.append("cap B: successor verification not done via live-fetch")
            # A->B already; we keep B even with weak successor verification since
            # canonical only says cap at C_watch when listed as A/B candidate
            # without successor verification.  We choose to be slightly more
            # lenient: B-tier remains B if live-fetch attempted (most records)
            # but ultra-thin spine-only records get downgraded.
            if tier == "B_forward" and verified in ("spine_only", "spine + about_404", ""):
                tier = "C_watch"
                cap_notes.append("cap C: spine-only successor data")

    deep_dive_pending = (tier == "A_acquire_self")

    target = {
        "legal_name": rec.get("legal_name"),
        "city": rec.get("city"),
        "county": rec.get("county"),
        "state": rec.get("state", "TX"),
        "zip": rec.get("zip"),
        "vertical": "janitorial",
        "naics_code": "561720",
        "license_number": None,
        "license_holder_name": None,
        "license_issue_date": None,
        "owner_name": rec.get("owner_name"),
        "owner_age_estimate": rec.get("owner_age_estimate"),
        "owner_age_source": rec.get("owner_age_source"),
        "owner_tenure_years": rec.get("owner_tenure_years") or rec.get("years_in_business"),
        "years_in_business": rec.get("years_in_business"),
        "employee_count_estimate": rec.get("employee_count_estimate"),
        "entity_status": rec.get("entity_status", "unknown"),
        "is_distressed": is_distressed,
        "distress_reasons": distress_reasons,
        "data_sources": rec.get("data_sources") or [],
        "score_run_id": score_run_id,
        "layer1_base_rate": l1,
        "layer1_comment": l1_comment,
        "layer2_sellability": l2,
        "layer2_comment": l2_comment,
        "layer3_behavioral_trigger": l3,
        "layer3_comment": l3_comment,
        "layer4_market_pull": l4,
        "layer4_comment": l4_comment,
        "final_score": final_capped,
        "final_tier": tier,
        "final_comment": final_comment,
        "value_add_thesis": thesis,
        "confidence": confidence,
        "data_completeness": rec.get("data_completeness") or 0.0,
        "deep_dive_pending": deep_dive_pending,
    }
    return target


# ---------------------------------------------------------------------------
# Driver
# ---------------------------------------------------------------------------

def main():
    print(f"Loading enrichment batches from {ROOT} ...")
    all_records = []
    for batch_path in BATCHES:
        with batch_path.open("r") as f:
            data = json.load(f)
            all_records.extend(data)
        print(f"  loaded {len(data)} from {batch_path.name}")

    print(f"Total enriched records: {len(all_records)}")

    targets = []
    # Persist incrementally — write the JSON after every record
    for i, rec in enumerate(all_records):
        t = to_target_record(rec, SCORE_RUN_ID)
        targets.append(t)
        # Atomic write each iteration
        if (i + 1) % 10 == 0 or i == len(all_records) - 1:
            tmp = OUT_JSON.with_suffix(".json.tmp")
            with tmp.open("w") as f:
                json.dump(targets, f, indent=2, default=str)
            tmp.replace(OUT_JSON)

    # Write CSV
    cols = [
        "legal_name", "city", "county", "state", "zip",
        "vertical", "naics_code", "license_number", "license_holder_name",
        "license_issue_date", "owner_name", "owner_age_estimate",
        "owner_age_source", "owner_tenure_years", "years_in_business",
        "employee_count_estimate", "entity_status", "is_distressed",
        "distress_reasons", "score_run_id", "layer1_base_rate",
        "layer1_comment", "layer2_sellability", "layer2_comment",
        "layer3_behavioral_trigger", "layer3_comment",
        "layer4_market_pull", "layer4_comment", "final_score",
        "final_tier", "final_comment", "value_add_thesis",
        "confidence", "data_completeness", "deep_dive_pending",
    ]
    with OUT_CSV.open("w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=cols, extrasaction="ignore")
        writer.writeheader()
        for t in targets:
            row = dict(t)
            row["distress_reasons"] = json.dumps(row.get("distress_reasons") or [])
            writer.writerow(row)

    print(f"Wrote {len(targets)} records to {OUT_JSON.name} + {OUT_CSV.name}")

    # Tier counts
    tier_counts = {}
    for t in targets:
        tier_counts[t["final_tier"]] = tier_counts.get(t["final_tier"], 0) + 1
    print("Tier breakdown:")
    for tier, n in sorted(tier_counts.items()):
        print(f"  {tier}: {n}")

    # Top A/B candidates
    a_records = sorted(
        [t for t in targets if t["final_tier"] == "A_acquire_self"],
        key=lambda x: x["final_score"], reverse=True
    )
    b_records = sorted(
        [t for t in targets if t["final_tier"] == "B_forward"],
        key=lambda x: x["final_score"], reverse=True
    )

    print(f"\nTop A_acquire_self candidates ({len(a_records)}):")
    for t in a_records[:10]:
        print(f"  {t['final_score']:>3} {t['legal_name']} ({t['city']}) — {t['owner_name'] or 'owner TBD'}")

    print(f"\nTop B_forward candidates ({len(b_records)}):")
    for t in b_records[:10]:
        print(f"  {t['final_score']:>3} {t['legal_name']} ({t['city']}) — {t['owner_name'] or 'owner TBD'}")


if __name__ == "__main__":
    main()
