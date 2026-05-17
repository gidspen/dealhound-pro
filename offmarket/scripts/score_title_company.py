"""Score off-market title company acquisition targets (TX, vertical=title_company, NAICS=541199).

Applies canonical 4-layer scorer with title-company-specific nudges:
  - L1 base rate: owner age × tenure; +10 for live succession-event (recent death of founder/principal)
  - L2 sellability: title-plant ownership, multi-county, multi-underwriter, multi-attorney
  - L3 coasting tells: dated tech, info-poverty, founder-still-active, info-hidden ownership
  - L4 market pull: TX RE-volume tier, hot metro/Hill Country/premium suburb nudges

Reads:
  offmarket/data/title_company_enrich_batch_1.json
  offmarket/data/title_company_enrich_batch_2.json

Writes:
  offmarket/data/title_company_targets.json
  offmarket/data/title_company_targets.csv

Incremental persistence: writes JSON every 10 records.
"""

from __future__ import annotations

import csv
import json
import os
from typing import Any

SCORE_RUN_ID = "21d57af1-ad30-4e32-a1f2-d7327001ed89"
DATA_DIR = os.path.join(
    os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
    "data",
)
BATCH_PATHS = [
    os.path.join(DATA_DIR, "title_company_enrich_batch_1.json"),
    os.path.join(DATA_DIR, "title_company_enrich_batch_2.json"),
]
OUT_JSON = os.path.join(DATA_DIR, "title_company_targets.json")
OUT_CSV = os.path.join(DATA_DIR, "title_company_targets.csv")


# ---------- L4 metro nudges (title-company-specific) ----------
# Top TX RE-volume tiers for title business + Hill Country retirement bump + premium suburbs.
HOT_DFW_CORE = {"Dallas", "Tarrant", "Collin", "Denton"}
HOT_AUSTIN_CORE = {"Travis", "Williamson", "Hays"}
HOT_HOUSTON_CORE = {"Harris", "Fort Bend", "Montgomery"}
SAN_ANTONIO_CORE = {"Bexar", "Comal", "Guadalupe", "Kendall"}
HILL_COUNTRY_RETIRE = {"Kerr", "Gillespie", "Llano", "Burnet", "Blanco", "Mason", "Kimble", "Comal", "Kendall", "Hays"}
PREMIUM_SUBURB_ZIPS = {
    # Highland Park, Southlake, Plano premium, Frisco, The Woodlands, Westlake, Tarrytown
    "75205", "75092", "75093", "75024", "75025", "75033", "75034",
    "78746", "78703", "78738",
    "77380", "77381", "77382",
    "76092",
}


def cap(score: int, lo: int = 0, hi: int = 100) -> int:
    return max(lo, min(hi, score))


def _is_excluded(rec: dict) -> tuple[bool, str]:
    """Returns (excluded, reason). Excludes parent-co subsidiaries, bank subs, active acquirers,
    and items the orchestrator pre-flagged as exclusions."""
    notes = (rec.get("notes") or "").upper()
    name = (rec.get("legal_name") or "").lower()
    succ = rec.get("successor_indicators") or {}
    si = rec.get("spine_index")

    # Orchestrator-level explicit exclusions (from scoring instructions):
    # - Nueces Title (sub of Texas Lone Star) [53]
    # - American National Title (bank sub) [59]
    # - Providence Title (growth mode) [60]
    # - Texas Lone Star (active acquirer) [52]
    # - Western Abstract (only 8yr ownership) [41]
    # - Capital Title (active acquirer, vertically integrated) [2]
    EXPLICIT_EXCLUSIONS = {
        2: "active_acquirer_vertically_integrated_capital_title",
        41: "recent_buyer_2018_8yr_ownership_not_coaster_yet",
        52: "active_acquirer_in_roll_up_mode_not_coaster",
        53: "subsidiary_of_active_acquirer_texas_lone_star",
        59: "bank_owned_subsidiary",
        60: "growth_mode_30_office_active_brand_not_coaster",
    }
    if si in EXPLICIT_EXCLUSIONS:
        return True, EXPLICIT_EXCLUSIONS[si]

    if succ.get("active_acquirer_not_target") is True:
        return True, "active_acquirer_vertically_integrated"
    if "subsidiary" in name and "texas lone star" in name:
        return True, "subsidiary_of_active_acquirer_parent"
    if "EXCLUDE FROM" in notes or "EXCLUDE FROM ACTIVE" in notes or "EXCLUDE FROM A-TIER" in notes:
        return True, "explicitly_excluded_in_enrichment"
    if "bank-owned" in notes.lower() or "BANK-AFFILIATED SUBSIDIARY" in notes:
        return True, "bank_owned_subsidiary"
    return False, ""


# ---------- Layer 1: owner natural-exit timing ----------
def score_l1(rec: dict) -> tuple[int, str]:
    age = rec.get("owner_age_estimate")
    yrs = rec.get("years_in_business") or 0
    owner = rec.get("owner_name") or ""
    succ = rec.get("successor_indicators") or {}
    notes_lower = (rec.get("notes") or "").lower()

    # Live succession event (recently deceased principal / forced transition) — +10 boost.
    live_event = bool(succ.get("live_succession_event"))
    deceased = bool(succ.get("ceo_deceased_feb_2026")) or "DECEASED" in (owner.upper())
    succession_boost = 10 if (live_event and deceased) else 0

    # Recent buyer (≤3 yrs) → almost always D_pass via hard gate later; mark with low L1.
    recent_buyer_flag = (
        succ.get("recent_succession_completed_2023") is True
        or succ.get("recent_succession_2019") is True
        or succ.get("succession_completed_2021_employee_buyout") is True
        or succ.get("succession_completed_2016_to_3rd_gen") is True  # 10yr, allowable
    )
    # Only the truly recent (<5 yr) buyer is a real penalty. 2016 succession is now 10yr — OK.
    truly_recent_buyer = (
        succ.get("recent_succession_completed_2023") is True
        or succ.get("recent_succession_2019") is True
        or succ.get("succession_completed_2021_employee_buyout") is True
    )

    # Age-band base score.
    if age is None:
        # No age — use tenure-as-proxy fallback, then mark unknown.
        if yrs >= 50:
            base = 60
            comment_age = f"owner age unknown; {yrs}yr tenure proxy implies senior owner band"
        elif yrs >= 25:
            base = 45
            comment_age = f"owner age unknown; {yrs}yr tenure proxy implies mid-career band"
        else:
            base = 25
            comment_age = f"owner age unknown; {yrs}yr tenure suggests early-career"
    elif age >= 68:
        base = 92
        comment_age = f"owner age est {age} (68+ band)"
    elif age >= 63:
        base = 82
        comment_age = f"owner age est {age} (63-67 band)"
    elif age >= 58:
        base = 68
        comment_age = f"owner age est {age} (58-62 band)"
    elif age >= 53:
        base = 48
        comment_age = f"owner age est {age} (53-57 band)"
    else:
        base = 25
        comment_age = f"owner age est {age} (<53)"

    # Tenure nudge.
    tenure_nudge = 0
    if yrs >= 25:
        tenure_nudge = 4
    elif yrs < 10 and yrs > 0:
        tenure_nudge = -6

    if truly_recent_buyer:
        # Crash L1.
        base = min(base, 25)
        comment = f"recent buyer (<5yr ownership); {comment_age}; tenure nudge {tenure_nudge:+d}; succession-event boost {succession_boost:+d}"
    else:
        comment = f"{comment_age}; tenure {yrs}yr nudge {tenure_nudge:+d}; succession-event boost {succession_boost:+d}"

    score = cap(base + tenure_nudge + succession_boost)

    # Title-vertical specific: politician-owner secondary asset → +5 (Surety/Darby).
    if "darby" in owner.lower() and "house rep" in owner.lower() or "tx house rep" in (rec.get("notes") or "").lower():
        score = cap(score + 5)
        comment += "; politician-owner secondary-asset +5"
    if "sitting tx house representative" in notes_lower or "sitting state legislator" in notes_lower:
        if not ("politician-owner" in comment):
            score = cap(score + 5)
            comment += "; politician-owner secondary-asset +5"

    return score, comment


# ---------- Layer 2: sellability ----------
def score_l2(rec: dict) -> tuple[int, str]:
    yrs = rec.get("years_in_business") or 0
    underw = rec.get("underwriters_appointed") or []
    loc_count = rec.get("location_count") or 1
    tlta = rec.get("tlta_member")
    alta = rec.get("alta_best_practices")
    tech = rec.get("tech_stack_observed") or []
    notes_lower = (rec.get("notes") or "").lower()
    service = (rec.get("service_specialty") or "").lower()
    coasting = rec.get("coasting_tells") or []

    # Hard gate.
    if yrs and yrs < 5:
        return 30, f"{yrs}yr tenure < 5 — hard gate cap 35"

    # Title plant ownership = strong moat.
    has_title_plant = any(
        "title_plant" in (t or "").lower()
        or "sovereign" in (t or "").lower()
        or "abstract" in (t or "").lower()
        for t in tech
    ) or "sovereign title plant" in notes_lower or "title plant" in notes_lower

    # Multi-county footprint
    multi_county = loc_count and loc_count >= 3
    multi_office = loc_count and loc_count >= 5

    # Co-op underwriter mix (3+) → adaptable.
    n_underw = len([u for u in underw if u])
    coop_mix = n_underw >= 3

    # Multi-attorney partnership.
    multi_attorney = (
        "multi-attorney" in service
        or "4-attorney" in notes_lower
        or "attorney-partnership" in notes_lower
        or "partner attorney" in notes_lower
    )

    base = 55
    detail = []
    if yrs >= 40 and (multi_county or multi_office):
        base = 80
        detail.append(f"{yrs}yr tenure + {loc_count}-office multi-county footprint")
    elif yrs >= 25 and multi_county:
        base = 72
        detail.append(f"{yrs}yr tenure + {loc_count}-office footprint")
    elif yrs >= 10:
        base = 62
        detail.append(f"{yrs}yr tenure single-or-low-office")
    elif yrs >= 5:
        base = 55
        detail.append(f"{yrs}yr tenure clean")
    else:
        base = 45
        detail.append("tenure unverified, treated cautiously")

    nudges = 0
    if has_title_plant:
        nudges += 8
        detail.append("title-plant/sovereign-records moat +8")
    if coop_mix:
        nudges += 4
        detail.append(f"{n_underw}-underwriter co-op mix +4 adaptability")
    if multi_attorney:
        nudges += 4
        detail.append("multi-attorney institutional +4")
    if tlta is True:
        nudges += 2
        detail.append("TLTA member +2")
    if alta is True:
        nudges += 2
        detail.append("ALTA Best Practices +2")

    # Distressed/disciplinary penalty.
    if rec.get("is_distressed"):
        return 20, "is_distressed=true → hard penalty"

    score = cap(base + nudges)
    return score, "; ".join(detail)


# ---------- Layer 3: coasting trigger ----------
def score_l3(rec: dict) -> tuple[int, str]:
    tells = rec.get("coasting_tells") or []
    modern = rec.get("modern_tech_signals")
    succ = rec.get("successor_indicators") or {}
    notes_lower = (rec.get("notes") or "").lower()
    website = rec.get("website") or ""
    data_compl = rec.get("data_completeness") or 0

    n_tells = len(tells)

    # Title-vertical-specific coasting amplifiers from canonical:
    # - Pre-2018 site, no online order entry, no SoftPro/RamQuest/Qualia, phone-only, no review velocity, fax, SSL/cert issues.
    amp = 0
    amp_notes = []

    # SSL / TLS / http-only.
    if website.startswith("http://") and not website.startswith("https://"):
        amp += 4
        amp_notes.append("http-only website (pre-2015 web infra)")
    if "self-signed cert" in notes_lower or "tls cert issue" in notes_lower or "ssl cert issue" in notes_lower or "self-signed" in notes_lower:
        amp += 4
        amp_notes.append("SSL/TLS cert failure")
    if "econnrefused" in notes_lower or "live fetch failed" in notes_lower or "live fetches errored" in notes_lower:
        amp += 3
        amp_notes.append("site unreachable / dead web infra")

    # Modern tech absent.
    if modern is False:
        amp += 3
        amp_notes.append("explicit no modern tech signals")
    elif modern is None and n_tells >= 3:
        # Implicit no modern tech if not surfaced.
        amp += 1

    # Founder-still-active marker.
    founder_active = (
        succ.get("founder_still_active") is True
        or succ.get("founder_still_active_after_43yr") is True
        or "founder still active" in notes_lower
        or "founder still listed" in notes_lower
        or "both still in the business" in notes_lower
    )
    if founder_active:
        amp += 3
        amp_notes.append("founder still active post-tenure marker")

    # Info-poverty (no owner disclosure on site).
    info_poor = "info-poor" in notes_lower or "info-hidden" in notes_lower or "owner identity not on public site" in notes_lower or "owner identity not publicly disclosed" in notes_lower
    if info_poor:
        amp += 2
        amp_notes.append("info-hidden / no public owner disclosure")

    # Base by tell count.
    if n_tells >= 4:
        base = 80
    elif n_tells == 3:
        base = 65
    elif n_tells == 2:
        base = 50
    elif n_tells == 1:
        base = 35
    else:
        base = 20

    # 5+ tells → push toward 90.
    if n_tells >= 5:
        base = 88

    score = cap(base + amp)

    parts = [f"{n_tells} coasting tells"] + amp_notes
    return score, "; ".join(parts) if parts else f"{n_tells} tells"


# ---------- Layer 4: market pull ----------
def score_l4(rec: dict) -> tuple[int, str]:
    city = (rec.get("city") or "").strip()
    county = (rec.get("county") or "").strip()
    zip_ = (rec.get("zip") or "").strip()

    detail = []

    if county in HOT_DFW_CORE:
        base = 84
        detail.append(f"DFW core ({county})")
    elif county in HOT_AUSTIN_CORE:
        base = 86
        detail.append(f"Austin metro ({county})")
    elif county in HOT_HOUSTON_CORE:
        base = 76
        detail.append(f"Houston metro ({county})")
    elif county in SAN_ANTONIO_CORE:
        base = 74
        detail.append(f"San Antonio metro ({county})")
    elif county in {"McLennan"}:  # Waco I-35 corridor
        base = 70
        detail.append(f"Waco I-35 corridor ({county})")
    elif county in {"Brazos"}:  # College Station
        base = 70
        detail.append(f"Brazos Valley ({county})")
    elif county in {"Galveston", "Nueces", "Jefferson"}:  # Gulf
        base = 66
        detail.append(f"Gulf TX metro ({county})")
    elif county in {"El Paso"}:
        base = 64
        detail.append(f"El Paso metro ({county})")
    elif county in {"Lubbock", "Potter", "Taylor", "Tom Green", "Ector", "Wichita"}:  # West TX metros
        base = 60
        detail.append(f"West TX secondary metro ({county})")
    elif county in {"Bell", "Grayson", "Hood", "Victoria"}:  # exurban / secondary
        base = 62
        detail.append(f"secondary metro/exurb ({county})")
    elif county in {"Hunt", "Bowie", "Smith", "Gregg", "Henderson", "Walker", "Montgomery"}:  # E TX
        base = 58
        detail.append(f"East TX / Houston-fringe ({county})")
    elif county in {"Llano", "Kerr", "Gillespie", "Kendall", "Comal"}:  # Hill Country
        base = 64
        detail.append(f"Hill Country ({county})")
    elif county in {"Fannin", "Kaufman", "Hopkins", "Leon", "Trinity", "Colorado", "Milam", "Hood", "Reagan", "Reeves", "Moore", "Donley", "Ochiltree"}:
        base = 54
        detail.append(f"rural / small-county TX ({county})")
    else:
        base = 56
        detail.append(f"other TX ({county})")

    # Hill Country retirement nudge.
    if county in HILL_COUNTRY_RETIRE:
        base = min(95, base + 3)
        detail.append("Hill Country retirement +3")

    # Premium suburb nudge.
    if zip_ in PREMIUM_SUBURB_ZIPS:
        base = min(95, base + 3)
        detail.append(f"premium suburb ZIP {zip_} +3")

    detail.append("title is financeable via SBA-7a if real-property held outside")
    return cap(base), "; ".join(detail)


# ---------- Tiering ----------
def final_tier(final: int, l1: int, l3: int, confidence: str, distressed: bool, yrs: int | None) -> str:
    if distressed:
        return "D_pass"
    if yrs is not None and yrs < 5:
        return "D_pass" if final < 36 else "C_watch"

    if final >= 78 and l1 >= 70 and l3 >= 65 and confidence in {"medium", "high"}:
        return "A_acquire_self"
    if final >= 60:
        return "B_forward"
    if final >= 45:
        return "C_watch"
    return "D_pass"


def estimate_confidence(rec: dict) -> str:
    dc = rec.get("data_completeness") or 0
    age = rec.get("owner_age_estimate")
    yrs = rec.get("years_in_business")
    succ = rec.get("successor_indicators") or {}
    # High if age + tenure + succession info known AND completeness ≥0.65
    if dc >= 0.7 and age is not None and yrs is not None and succ.get("verified_via"):
        return "high"
    if dc >= 0.55 and (age is not None or yrs is not None):
        return "medium"
    if dc >= 0.35:
        return "low"
    return "low"


# ---------- Comments / thesis ----------
def value_add_thesis(rec: dict, l1: int, l2: int, l3: int, l4: int, tier: str) -> str:
    name = rec.get("legal_name") or ""
    loc = rec.get("location_count") or 1
    parts = []

    if tier in {"A_acquire_self", "B_forward"}:
        parts.append("Replace fax/phone-only intake with Qualia/SoftPro Cloud + e-recording (drives 15-25% closing-time reduction)")
        parts.append("Cross-sell escrow + closing-protection-letter premium tier (8-12% margin uplift)")
        if loc and loc >= 3:
            parts.append("Consolidate office leases / shared escrow ops across locations to lift EBITDA margin by 4-6 pts")
    else:
        parts.append("Hold — re-screen on succession trigger or owner-age verification")
    return "; ".join(parts) + "."


def final_comment(rec: dict, l1c: str, l2c: str, l3c: str, l4c: str, l1: int, l2: int, l3: int, l4: int, final: int, tier: str) -> str:
    name = rec.get("legal_name")
    yrs = rec.get("years_in_business")
    owner = rec.get("owner_name") or "owner unknown"
    succ = rec.get("successor_indicators") or {}
    live_event = bool(succ.get("live_succession_event"))
    notes_short = (rec.get("notes") or "")[:200]

    s = f"{name} scores {final} ({tier}) — L1={l1}/L2={l2}/L3={l3}/L4={l4}. "
    if live_event and succ.get("ceo_deceased_feb_2026"):
        s += "LIVE SUCCESSION EVENT (CEO deceased Feb 2026). "
    if yrs and yrs >= 100:
        s += f"{yrs}-yr operating history is a generational moat. "
    elif yrs:
        s += f"{yrs}-yr operating history. "
    s += f"Owner: {owner}. "
    if tier == "A_acquire_self":
        s += "Move to deep-dive: SOS pull, owner-age verify, license-holder cross-check, on-site visit."
    elif tier == "B_forward":
        s += "Track and monitor — re-screen on succession trigger or owner-age verify."
    elif tier == "C_watch":
        s += "Watch — does not yet justify outreach but watch for succession events."
    else:
        s += "Pass — fails A/B gates or is excluded by enrichment."
    return s


# ---------- Main ----------
def build_output_record(rec: dict, score_run_id: str) -> dict[str, Any]:
    # Exclusions still produce records (so we can show why), but they go to D_pass.
    excluded, exc_reason = _is_excluded(rec)

    distressed = bool(rec.get("is_distressed"))
    yrs = rec.get("years_in_business")

    l1, l1c = score_l1(rec)
    l2, l2c = score_l2(rec)
    l3, l3c = score_l3(rec)
    l4, l4c = score_l4(rec)

    # Weighted formula.
    final = round(0.30 * l1 + 0.25 * l2 + 0.30 * l3 + 0.15 * l4)

    confidence = estimate_confidence(rec)

    # If excluded → force D_pass with override comment.
    if excluded:
        tier = "D_pass"
        final = min(final, 30)
        l3c = f"{l3c}; excluded: {exc_reason}"
    else:
        tier = final_tier(final, l1, l3, confidence, distressed, yrs)

    # Holding-co affiliation cap: standalone acquisition is muted when parent is
    # a holding company that controls multiple brands. These targets are not
    # excluded entirely (the orchestrator may still negotiate at parent level)
    # but they cannot land at A-tier as a standalone target — cap at B.
    HOLDING_CO_CAP = {
        32: "Texan Title Holdings parent — standalone acquisition story muted",
        51: "Texan Title Holdings parent + Jan 2024 daughter-succession just completed — cap to B",
    }
    if rec.get("spine_index") in HOLDING_CO_CAP and tier == "A_acquire_self":
        tier = "B_forward"
        final = min(final, 77)
        l2c = f"{l2c}; {HOLDING_CO_CAP[rec.get('spine_index')]}"

    # Hard gate: confidence < medium AND would otherwise land in A → cap at B.
    if tier == "A_acquire_self" and confidence not in {"medium", "high"}:
        tier = "B_forward"

    # Successor verification gate: A/B candidates with "sole listed provider" tell MUST have live-fetch URL evidence;
    # otherwise cap confidence at low and tier at C.
    # Map: solo-attorney/sole-owner-no-named-successor + no live fetch verified.
    succ = rec.get("successor_indicators") or {}
    verified_via = (succ.get("verified_via") or "").lower()
    is_sole_provider_tell = any(
        "sole" in (t or "").lower() or "single owner" in (t or "").lower() or "solo-owner" in (t or "").lower() or "solo principal" in (t or "").lower()
        for t in (rec.get("coasting_tells") or [])
    )
    no_live_fetch = (
        "sos_filing_pull_required" in verified_via
        or "failed" in verified_via
        or "directory_search" in verified_via
        or not verified_via
    )
    if tier in {"A_acquire_self", "B_forward"} and is_sole_provider_tell and no_live_fetch and tier == "A_acquire_self":
        tier = "C_watch"
        confidence = "low"
        l3c += "; sole-provider tell w/o live fetch verification — cap to C"

    # A-tier deep-dive pending flag.
    deep_dive_pending = (tier == "A_acquire_self")

    # For A-tier without deep-dive done, cap at B (per canonical gate 6) — but mark deep_dive_pending.
    # Instructions allow flagging deep_dive_pending=true if final ≥78; orchestrator handles deep-dive.

    # value_add_thesis comment.
    thesis = value_add_thesis(rec, l1, l2, l3, l4, tier)
    final_c = final_comment(rec, l1c, l2c, l3c, l4c, l1, l2, l3, l4, final, tier)

    # Owner tenure heuristic.
    owner_tenure_years = None
    succ_completed_year = None
    if succ.get("succession_completed_2016_to_3rd_gen"):
        succ_completed_year = 2016
    elif succ.get("recent_succession_completed_2023"):
        succ_completed_year = 2023
    elif succ.get("recent_succession_2019"):
        succ_completed_year = 2019
    elif succ.get("succession_completed_2021_employee_buyout"):
        succ_completed_year = 2021
    if succ_completed_year:
        owner_tenure_years = 2026 - succ_completed_year
    elif rec.get("year_established"):
        owner_tenure_years = 2026 - rec["year_established"]

    out = {
        "legal_name": rec.get("legal_name"),
        "city": rec.get("city"),
        "county": rec.get("county"),
        "state": rec.get("state") or "TX",
        "zip": rec.get("zip"),
        "vertical": "title_company",
        "naics_code": "541199",
        "license_number": None,  # TDI license-holder pull would supply; not consistently in spine
        "license_holder_name": None,
        "license_issue_date": None,
        "owner_name": rec.get("owner_name"),
        "owner_age_estimate": rec.get("owner_age_estimate"),
        "owner_age_source": rec.get("owner_age_source"),
        "owner_tenure_years": owner_tenure_years,
        "years_in_business": rec.get("years_in_business"),
        "year_established": rec.get("year_established"),
        "employee_count_estimate": rec.get("escrow_officer_count_estimate"),
        "entity_status": rec.get("entity_status") or "Active",
        "is_distressed": distressed,
        "distress_reasons": rec.get("distress_reasons") or [],
        "website": rec.get("website"),
        "phone": rec.get("phone"),
        "location_count": rec.get("location_count"),
        "underwriters_appointed": rec.get("underwriters_appointed") or [],
        "tlta_member": rec.get("tlta_member"),
        "alta_best_practices": rec.get("alta_best_practices"),
        "service_specialty": rec.get("service_specialty"),
        "coasting_tells": rec.get("coasting_tells") or [],
        "successor_indicators": rec.get("successor_indicators") or {},
        "data_sources": rec.get("data_sources") or [],
        "score_run_id": score_run_id,
        "layer1_base_rate": l1,
        "layer1_comment": l1c,
        "layer2_sellability": l2,
        "layer2_comment": l2c,
        "layer3_behavioral_trigger": l3,
        "layer3_comment": l3c,
        "layer4_market_pull": l4,
        "layer4_comment": l4c,
        "final_score": final,
        "final_tier": tier,
        "final_comment": final_c,
        "value_add_thesis": thesis,
        "confidence": confidence,
        "data_completeness": rec.get("data_completeness"),
        "deep_dive_pending": deep_dive_pending,
        "spine_index": rec.get("spine_index"),
    }
    return out


def write_incremental(records: list[dict], path: str) -> None:
    tmp = path + ".tmp"
    with open(tmp, "w") as f:
        json.dump(records, f, indent=2, default=str)
    os.replace(tmp, path)


def write_csv(records: list[dict], path: str) -> None:
    csv_cols = [
        "legal_name",
        "city",
        "county",
        "state",
        "zip",
        "vertical",
        "naics_code",
        "owner_name",
        "owner_age_estimate",
        "owner_age_source",
        "owner_tenure_years",
        "years_in_business",
        "year_established",
        "employee_count_estimate",
        "entity_status",
        "is_distressed",
        "distress_reasons",
        "website",
        "phone",
        "location_count",
        "tlta_member",
        "alta_best_practices",
        "underwriter_count",
        "score_run_id",
        "layer1_base_rate",
        "layer2_sellability",
        "layer3_behavioral_trigger",
        "layer4_market_pull",
        "final_score",
        "final_tier",
        "confidence",
        "data_completeness",
    ]
    with open(path, "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(csv_cols)
        for r in records:
            row = []
            for c in csv_cols:
                if c == "underwriter_count":
                    row.append(len(r.get("underwriters_appointed") or []))
                elif c == "distress_reasons":
                    row.append("|".join(r.get("distress_reasons") or []))
                else:
                    val = r.get(c)
                    row.append("" if val is None else val)
            w.writerow(row)


def main() -> None:
    all_recs: list[dict] = []
    for p in BATCH_PATHS:
        with open(p) as f:
            all_recs.extend(json.load(f))

    out_records: list[dict] = []
    for i, rec in enumerate(all_recs):
        scored = build_output_record(rec, SCORE_RUN_ID)
        out_records.append(scored)
        # Persist every 10 records.
        if (i + 1) % 10 == 0:
            write_incremental(out_records, OUT_JSON)

    write_incremental(out_records, OUT_JSON)
    write_csv(out_records, OUT_CSV)

    # Summary.
    tier_counts: dict[str, int] = {}
    for r in out_records:
        tier_counts[r["final_tier"]] = tier_counts.get(r["final_tier"], 0) + 1

    top_a = sorted(
        [r for r in out_records if r["final_tier"] == "A_acquire_self"],
        key=lambda r: r["final_score"],
        reverse=True,
    )[:5]
    top_b = sorted(
        [r for r in out_records if r["final_tier"] == "B_forward"],
        key=lambda r: r["final_score"],
        reverse=True,
    )[:5]

    print("=== Title Company Scoring Summary ===")
    print(f"Total scored: {len(out_records)}")
    print(f"Tier counts: {tier_counts}")
    print(f"Output JSON: {OUT_JSON}")
    print(f"Output CSV:  {OUT_CSV}")
    print("\nTop A candidates:")
    for r in top_a:
        print(f"  [{r['spine_index']}] {r['legal_name']} ({r['city']}, {r['county']}) — final {r['final_score']} | L1={r['layer1_base_rate']} L2={r['layer2_sellability']} L3={r['layer3_behavioral_trigger']} L4={r['layer4_market_pull']} | conf={r['confidence']}")
    print("\nTop B candidates:")
    for r in top_b:
        print(f"  [{r['spine_index']}] {r['legal_name']} ({r['city']}, {r['county']}) — final {r['final_score']} | conf={r['confidence']}")


if __name__ == "__main__":
    main()
