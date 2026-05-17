"""
HVAC Commercial scoring — canonical 4-layer scorer.

Reads:
  offmarket/data/hvac_commercial_enrich_batch_1.json
  offmarket/data/hvac_commercial_enrich_batch_2.json

Writes:
  offmarket/data/hvac_commercial_targets.json
  offmarket/data/hvac_commercial_targets.csv

Scoring rules per SCORING_INSTRUCTIONS.md + HVAC-commercial-specific
nudges from the orchestrator prompt:
  L1 (0.30): owner age band + tenure modifier
  L2 (0.25): sellability — clean operation, recurring rev, SBA-sized
  L3 (0.30): coasting tells (commercial-HVAC-specific) +
             BACnet/EMS premium, NEBB/TAB cert nudge, commercial>residential mix
  L4 (0.15): TX-commercial-HVAC sub-market nudges:
             Houston +5 (commercial+petrochem)
             DFW +5 (massive office/warehouse)
             Austin +3 (commercial growth + semicon)
             SA 0 (commercial+military, fine)
             Rural -5
"""

import json
import csv
import os
import sys
from pathlib import Path

ROOT = Path(__file__).parent
DATA = ROOT / "data"
BATCH1 = DATA / "hvac_commercial_enrich_batch_1.json"
BATCH2 = DATA / "hvac_commercial_enrich_batch_2.json"
OUT_JSON = DATA / "hvac_commercial_targets.json"
OUT_CSV = DATA / "hvac_commercial_targets.csv"

SCORE_RUN_ID = "753f9738-f39f-44c0-b37e-13fbfb558b0c"
VERTICAL = "hvac_commercial"
NAICS = "238220"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

HOUSTON_COUNTIES = {"Harris", "Fort Bend", "Montgomery", "Brazoria", "Galveston", "Liberty", "Chambers", "Waller", "Jefferson"}
DFW_COUNTIES = {"Dallas", "Tarrant", "Collin", "Denton", "Rockwall", "Ellis", "Johnson", "Kaufman", "Parker", "Hood"}
AUSTIN_COUNTIES = {"Travis", "Williamson", "Hays", "Bastrop", "Caldwell"}
SA_COUNTIES = {"Bexar", "Guadalupe", "Comal", "Wilson", "Atascosa", "Medina", "Bandera", "Kendall"}

RURAL_MARKERS = {"Tyler", "Beaumont", "Waco", "Conroe", "Aubrey", "Manor", "Weir", "Elgin", "Red Rock", "Liberty Hill",
                 "Manchaca", "Selma", "Schertz", "New Braunfels", "Stafford", "Cypress", "Hutto", "Cedar Park", "Spring",
                 "Pasadena", "Baytown", "Grand Prairie"}


def metro(county, city):
    if county in HOUSTON_COUNTIES:
        return "houston"
    if county in DFW_COUNTIES:
        return "dfw"
    if county in AUSTIN_COUNTIES:
        return "austin"
    if county in SA_COUNTIES:
        return "san_antonio"
    return "secondary"


def l4_market_pull(county, city):
    m = metro(county, city)
    # Hot vertical (HVAC commercial is a hot PE rollup vertical) × metro
    if m == "houston":
        return 88, "Houston metro = hot vertical × top-3 TX metro (commercial+petrochem +5)"
    if m == "dfw":
        return 88, "DFW = hot vertical × top-3 TX metro (massive office/warehouse +5)"
    if m == "austin":
        return 82, "Austin = hot vertical × major TX metro (commercial growth + semicon +3)"
    if m == "san_antonio":
        return 75, "San Antonio = hot vertical × major TX metro (commercial+military, neutral)"
    # secondary / east TX / rural
    if city == "Tyler":
        return 60, "Tyler/East TX = secondary metro; lower PE attention"
    if city == "Beaumont":
        return 62, "Beaumont = secondary metro; petrochem-adjacent industrial pull"
    if city == "Waco":
        return 60, "Waco = secondary central TX metro"
    return 58, f"{city} = secondary/exurban TX market (-5 vs metro)"


def get_owner_age(rec):
    age = rec.get("owner_age_estimate")
    if age is None:
        return None
    try:
        return int(age)
    except (TypeError, ValueError):
        return None


def l1_base_rate(rec):
    """Owner age band + tenure modifier."""
    age = get_owner_age(rec)
    years = rec.get("years_in_business")
    if not age:
        # weak proxy band
        if years and years >= 40:
            return 45, f"Owner age unknown; {years}-yr operator proxies to legacy operator band (10-35 weak proxy floor + tenure nudge)"
        if years and years >= 25:
            return 35, f"Owner age unknown; {years}-yr operator falls in weak-proxy band 10-35"
        return 20, "Owner age unknown and no strong tenure proxy"

    if age >= 68:
        score = 92
        band = "68+ (prime retirement window)"
    elif age >= 63:
        score = 82
        band = "63-67 (entering retirement window)"
    elif age >= 58:
        score = 68
        band = "58-62 (approaching retirement window)"
    elif age >= 53:
        score = 48
        band = "53-57 (mid-career)"
    else:
        score = 22
        band = "<53 (too young for typical 12-36 mo exit)"

    # tenure modifier
    tenure_mod = 0
    if years:
        if years >= 25:
            tenure_mod = 4
        elif years < 10:
            tenure_mod = -6

    score = max(10, min(100, score + tenure_mod))
    mod_note = ""
    if tenure_mod > 0:
        mod_note = f"; +{tenure_mod} tenure mod ({years} yrs)"
    elif tenure_mod < 0:
        mod_note = f"; {tenure_mod} tenure mod (<10 yrs)"

    return score, f"Owner age ~{age} → {band}{mod_note}"


def l2_sellability(rec):
    """Clean operation × recurring revenue × SBA-financeable size."""
    years = rec.get("years_in_business") or 0
    emps = rec.get("employee_count_estimate") or rec.get("estimated_employee_count") or 0
    distress = rec.get("is_distressed", False)

    # mix and sticky revenue signal
    bacnet = rec.get("bacnet_capable") or (rec.get("bacnet_ems_capable") in ("likely", "yes_BAS_mentioned", "yes_core_business", "likely_mission_critical_work_requires_it", "likely_mission_critical_work", "likely_healthcare_+_govt", "likely_MEP_design_capable", "likely_industrial_chillers", "likely_govt_work_demands_it"))
    nebb = rec.get("nebb_tab_certified") in (True, "yes")
    service_mix = (rec.get("service_mix") or "").lower()
    is_commercial_pure = service_mix in ("commercial", "commercial+industrial", "commercial+industrial+institutional", "commercial+industrial+residential", "commercial+institutional", "commercial+industrial+government")
    is_mixed = "residential" in service_mix

    notes = []

    # base buckets per canonical
    if distress:
        return 25, "Distressed signal → capped"

    if years >= 10 and (emps >= 20 or is_commercial_pure):
        # Clean multi-staff long-tenure
        base = 78
        notes.append(f"Clean {years}-yr operation, {emps}-emp est., commercial focus")
    elif years >= 10:
        base = 70
        notes.append(f"Clean {years}-yr solo/mid operation, {emps}-emp est.")
    elif years >= 5:
        base = 60
        notes.append(f"{years}-yr 5-9 multi-staff operation")
    else:
        base = 32
        notes.append(f"{years}-yr operation falls below 5-yr hard gate")

    # SBA size guardrails — penalize ESOP/very large
    if "ESOP" in str(rec.get("owner_name") or "") or "ESOP" in str(rec.get("owner_age_source") or ""):
        base = min(base, 30)
        notes.append("ESOP structure → succession-by-sale unlikely")
    elif emps and emps > 200:
        base = min(base, 65)
        notes.append(f"~{emps} emp = above ideal SBA-sized 10-50 range")
    elif emps and emps > 100:
        # slight penalty for being above the ideal 10-50 band but still investable
        base = min(base, 72)
        notes.append(f"~{emps} emp = above ideal 10-50 ETA range but financeable")

    # premium services nudges
    if bacnet:
        base = min(100, base + 5)
        notes.append("+5 BACnet/EMS commercial automation premium")
    if nebb:
        base = min(100, base + 3)
        notes.append("+3 NEBB/TAB cert engineering depth")

    return base, "; ".join(notes)


def l3_coasting(rec):
    """Coasting tells — count distinct positive HVAC tells, subtract anti-coasting signals."""
    tells = rec.get("coasting_tells") or []
    successor = rec.get("successor_indicators") or {}
    distress = rec.get("distress_signals") or []

    # Positive HVAC commercial tells from the prompt
    pos = 0
    notes = []

    tell_keywords = {
        "pre_2018_site": ["pre_2018_site", "legacy_HTML", "http_only", "http-only", "expired_SSL", "expired ssl", "no_https"],
        "no_online_portal": ["online_quote", "online_portal", "online_customer_portal", "no online portal", "no customer portal", "phone_only", "phone-only", "phone only"],
        "no_fsm_tech": ["servicetitan", "fieldedge", "buildops", "buildertrend", "no_modern_FSM", "no modern FSM", "no_ServiceTitan", "no fsm"],
        "owner_field_tech": ["owner-as-field-tech", "owner_is_field_operations", "owner_field_tech", "owner is field", "owner_dependent"],
        "aging_fleet": ["aging_fleet", "fleet imagery"],
        "no_commercial_testimonials": ["no commercial testimonials", "no commercial-client testimonials"],
        "founder_still_active_after_long_tenure": ["founder_still_active", "founder_still_named", "founder still active", "founder still President"],
        "no_named_owner": ["no_named_owner", "no public owner", "no named owner", "no_public_owner_or_founder_name", "owner identity not disclosed", "owner_identity_opaque", "no public officer", "no_named_owners"],
        "single_market_long_tenure": ["single_market", "no_geographic_expansion", "no growth appetite"],
        "estate_planning_artifact": ["estate_planning_artifact", "two_entity_structure"],
        "old_branding_legacy_name": ["old_branding", "legacy name", "pre_branding_era", "generic_business_name", "pre_PE_era"],
    }

    text = " ".join(map(str, tells)).lower()
    for label, keywords in tell_keywords.items():
        if any(k.lower() in text for k in keywords):
            pos += 1
            notes.append(label)

    # Successor death / co-owner deceased / sibling consolidation = strong tell
    if successor.get("sibling_co_owner_deceased"):
        pos += 1
        notes.append("sibling_co_owner_deceased")
    if successor.get("sibling_consolidation_potential"):
        pos += 1
        notes.append("sibling_consolidation_potential")
    if successor.get("recent_ownership_change"):
        pos = max(0, pos - 3)  # very strong anti-coasting
        notes.append("RECENT_OWNERSHIP_CHANGE (anti-coasting)")

    # Anti-coasting signals
    if "growth_signals" in text or "actively_growing" in text or "premier_dealer" in text or "active multi-state growth" in text:
        pos = max(0, pos - 2)
        notes.append("ACTIVELY_GROWING (anti-coasting)")
    if "too_young" in text or "pre_coasting" in text or "pre-coasting" in text:
        pos = max(0, pos - 2)
        notes.append("PRE_COASTING_YOUNG (anti-coasting)")

    # Convert count to band per canonical
    if pos >= 4:
        score = 86
        band = f"{pos} positive tells (4+ threshold)"
    elif pos >= 2:
        score = 68
        band = f"{pos} tells (2-3 threshold)"
    elif pos == 1:
        score = 42
        band = "1 tell"
    else:
        score = 20
        band = "0 tells"

    # HVAC commercial nudges
    bacnet = rec.get("bacnet_capable") or (rec.get("bacnet_ems_capable") in ("likely", "yes_BAS_mentioned", "yes_core_business", "likely_mission_critical_work_requires_it", "likely_mission_critical_work", "likely_healthcare_+_govt", "likely_MEP_design_capable", "likely_industrial_chillers", "likely_govt_work_demands_it"))
    nebb = rec.get("nebb_tab_certified") in (True, "yes")
    service_mix = (rec.get("service_mix") or "").lower()
    is_commercial_pure = service_mix in ("commercial", "commercial+industrial", "commercial+industrial+institutional", "commercial+industrial+residential", "commercial+institutional", "commercial+industrial+government", "commercial_multifamily", "commercial+plumbing")

    # PM agreement / sticky base
    notes_str = str(rec.get("notes") or "") + " " + str(rec.get("coasting_tells") or "")
    if "PM agreement" in notes_str or "preventive maintenance" in notes_str.lower() or "1000+" in notes_str:
        score = min(100, score + 5)
        notes.append("+5 PM agreement / sticky recurring base")

    # commercial-only vs mixed nudge handled in L2; in L3 use as tiebreaker
    score_label = band + " (" + ", ".join(notes[:6]) + ")"

    return score, score_label


def confidence(rec):
    dc = rec.get("data_completeness")
    if dc is None:
        return "low"
    if dc >= 0.7:
        return "high"
    if dc >= 0.5:
        return "medium"
    return "low"


def final_tier(final_score, l1, l3, distressed, conf, years, recent_buyer):
    if distressed:
        return "D_pass"
    if years is not None and years < 5:
        return "D_pass" if final_score < 35 else "C_watch"
    if recent_buyer:
        return "D_pass"
    if final_score >= 78 and l1 >= 70 and l3 >= 65 and conf in ("medium", "high"):
        # deep_dive_pending gate caps at B
        return "B_forward"
    if final_score >= 60:
        return "B_forward"
    if final_score >= 45:
        return "C_watch"
    return "D_pass"


def value_add_thesis(rec):
    bacnet = rec.get("bacnet_capable") or (rec.get("bacnet_ems_capable") in ("likely", "yes_BAS_mentioned", "yes_core_business", "likely_mission_critical_work_requires_it", "likely_mission_critical_work", "likely_healthcare_+_govt", "likely_MEP_design_capable", "likely_industrial_chillers", "likely_govt_work_demands_it"))
    nebb = rec.get("nebb_tab_certified") in (True, "yes")
    service_mix = (rec.get("service_mix") or "").lower()
    is_pure_commercial = "residential" not in service_mix

    base = "ServiceTitan/BuildOps FSM rollout + PM agreement penetration + commercial new-construction sales modernization"
    if bacnet:
        base += "; BACnet/EMS controls upsell to PM base (recurring premium)"
    if nebb:
        base += "; NEBB/TAB cert leverages design-build margin"
    if not is_pure_commercial:
        base += "; rationalize residential book → commercial-focus margin uplift"
    return base + " — 1.5-2x EBITDA path."


def normalize(rec):
    """Normalize fields between batch 1 and batch 2 enrichment schemas."""
    norm = {
        "spine_index": rec.get("spine_index"),
        "legal_name": rec.get("legal_name"),
        "dba_name": rec.get("dba_name"),
        "city": rec.get("city"),
        "county": rec.get("county"),
        "state": rec.get("state") or "TX",
        "website": rec.get("website"),
        "founded_year": rec.get("founded_year") or rec.get("year_established"),
        "years_in_business": rec.get("years_in_business"),
        "owner_name": rec.get("owner_name"),
        "owner_age_estimate": rec.get("owner_age_estimate"),
        "owner_age_source": rec.get("owner_age_source"),
        "employee_count_estimate": rec.get("employee_count_estimate") or rec.get("estimated_employee_count"),
        "estimated_truck_count": rec.get("estimated_truck_count"),
        "service_mix": rec.get("service_mix"),
        "bacnet_capable": rec.get("bacnet_capable"),
        "bacnet_ems_capable": rec.get("bacnet_ems_capable"),
        "nebb_tab_certified": rec.get("nebb_tab_certified"),
        "ashrae_member": rec.get("ashrae_member"),
        "license_class": rec.get("license_class"),
        "entity_status": rec.get("entity_status"),
        "is_distressed": rec.get("is_distressed", False),
        "distress_signals": rec.get("distress_signals") or [],
        "coasting_tells": rec.get("coasting_tells") or [],
        "successor_indicators": rec.get("successor_indicators") or {},
        "data_sources": rec.get("data_sources") or [],
        "data_completeness": rec.get("data_completeness"),
        "notes": rec.get("notes") or rec.get("is_sellable_target_reason"),
        "disqualification_flag": rec.get("disqualification_flag"),
    }
    return norm


def detect_exclusion(rec):
    """Return string reason if hard-excluded, else None."""
    name = (rec.get("legal_name") or "").lower()
    dq = (rec.get("disqualification_flag") or "").lower()
    notes = (str(rec.get("notes") or "") + " " + str(rec.get("is_sellable_target_reason") or "")).lower()
    owner = (str(rec.get("owner_name") or "")).lower()
    successor = rec.get("successor_indicators") or {}

    # Per the orchestrator prompt + enrichment flags
    if "esop" in owner or "esop" in notes:
        return "ESOP structure — succession-by-sale unlikely"
    if "out_of_state" in dq or "ga_hq" in dq:
        return "Out-of-state HQ — not a TX independent"
    if "bim_consultancy" in dq or "wrong_business_model" in dq:
        return "BIM/VDC consultancy — wrong business model"
    if "pe_owned" in dq or "pe_acquisition" in dq or "se_acquisition" in dq:
        return "Probable PE-owned (acquisition flag)"
    if successor.get("recent_ownership_change") and "2023" in str(notes):
        return "Recent ownership change (2023 buyer) — not an exit candidate"
    if "just transacted" in notes or "recent buyer" in notes:
        return "Recent buyer — not in exit window"
    if "class b" in str(rec.get("license_class") or "").lower() and "light_commercial" in notes:
        return "Class B license — light commercial only, outside thesis"
    if "ike" in name and "light commercial" in notes:
        return "Light-commercial only — outside commercial-pure thesis"
    return None


def is_distressed_calc(rec):
    if rec.get("is_distressed"):
        return True
    signals = rec.get("distress_signals") or []
    text = " ".join(str(s).lower() for s in signals)
    if "expired_ssl" in text or "expired ssl" in text:
        return True
    return False


def score_one(rec):
    rec = normalize(rec)

    # ----- Hard-exclusion / disqualify gate -----
    excl = detect_exclusion(rec)
    distressed = is_distressed_calc(rec)
    years = rec.get("years_in_business")

    # Layer scores
    l1, l1c = l1_base_rate(rec)
    l2, l2c = l2_sellability(rec)
    l3, l3c = l3_coasting(rec)
    l4, l4c = l4_market_pull(rec.get("county"), rec.get("city"))

    final = round(0.30 * l1 + 0.25 * l2 + 0.30 * l3 + 0.15 * l4)

    # Hard gates per canonical
    distress_reasons = []
    if distressed:
        final = min(final, 25)
        distress_reasons.append("Distress signal (expired SSL or flag)")
    if years is not None and years < 5:
        final = min(final, 35)

    recent_buyer = False
    if rec.get("successor_indicators", {}).get("recent_ownership_change"):
        recent_buyer = True
        final = min(final, 30)

    if excl:
        # Hard-exclude → cap at 30 with D_pass
        final = min(final, 30)
        distress_reasons.append(excl)

    conf = confidence(rec)
    # Confidence cap: A-grade needs medium+ confidence
    if final >= 78 and conf == "low":
        final = 73  # forced down into B band

    tier = final_tier(final, l1, l3, distressed or bool(excl), conf, years, recent_buyer)

    deep_dive_pending = (final >= 78 and tier == "B_forward" and not excl and not distressed)

    final_comment = (
        f"Score {final} ({tier}) | L1={l1} L2={l2} L3={l3} L4={l4} "
        f"| Confidence={conf} (data_completeness={rec.get('data_completeness')})"
    )
    if deep_dive_pending:
        final_comment += " | A-candidate by score+gates → capped at B pending A-tier deep-dive"
    if excl:
        final_comment += f" | EXCLUDED: {excl}"
    if distressed:
        final_comment += " | DISTRESSED"

    out = {
        "legal_name": rec.get("legal_name"),
        "city": rec.get("city"),
        "county": rec.get("county"),
        "state": rec.get("state"),
        "vertical": VERTICAL,
        "naics_code": NAICS,
        "website": rec.get("website"),
        "owner_name": rec.get("owner_name"),
        "owner_age_estimate": rec.get("owner_age_estimate"),
        "owner_age_source": rec.get("owner_age_source"),
        "owner_tenure_years": years,
        "years_in_business": years,
        "year_established": rec.get("founded_year"),
        "entity_status": "Active" if (rec.get("entity_status") or "").lower().startswith(("active", "presumed")) else (rec.get("entity_status") or "unknown"),
        "is_distressed": bool(distressed),
        "distress_reasons": distress_reasons,
        "score_run_id": SCORE_RUN_ID,
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
        "final_comment": final_comment,
        "value_add_thesis": value_add_thesis(rec),
        "confidence": conf,
        "data_completeness": rec.get("data_completeness"),
        "deep_dive_pending": deep_dive_pending,
        "data_sources": [s.get("url") if isinstance(s, dict) else s for s in (rec.get("data_sources") or [])],
    }
    return out


def main():
    with open(BATCH1) as f:
        b1 = json.load(f)
    with open(BATCH2) as f:
        b2 = json.load(f)

    # batch 1 has a _meta header item — strip it
    b1_records = [r for r in b1 if "_meta" not in r]
    b2_records = list(b2)

    all_recs = b1_records + b2_records
    print(f"Loaded {len(all_recs)} businesses (batch1={len(b1_records)}, batch2={len(b2_records)})", file=sys.stderr)

    results = []
    for i, rec in enumerate(all_recs):
        try:
            scored = score_one(rec)
            results.append(scored)
            # incremental persist every 20
            if (i + 1) % 20 == 0:
                with open(OUT_JSON, "w") as f:
                    json.dump(results, f, indent=2, default=str)
                print(f"  persisted {i+1}/{len(all_recs)}", file=sys.stderr)
        except Exception as e:
            print(f"ERROR scoring {rec.get('legal_name')!r}: {e}", file=sys.stderr)
            raise

    # final JSON
    with open(OUT_JSON, "w") as f:
        json.dump(results, f, indent=2, default=str)

    # CSV
    columns = [
        "legal_name", "city", "county", "state", "vertical", "naics_code", "website",
        "owner_name", "owner_age_estimate", "owner_age_source", "owner_tenure_years",
        "years_in_business", "year_established", "entity_status", "is_distressed",
        "score_run_id",
        "layer1_base_rate", "layer1_comment",
        "layer2_sellability", "layer2_comment",
        "layer3_behavioral_trigger", "layer3_comment",
        "layer4_market_pull", "layer4_comment",
        "final_score", "final_tier", "final_comment",
        "value_add_thesis", "confidence", "data_completeness", "deep_dive_pending",
        "data_sources",
    ]
    with open(OUT_CSV, "w", newline="") as f:
        writer = csv.writer(f)
        writer.writerow(columns)
        for r in results:
            row = []
            for c in columns:
                v = r.get(c)
                if c == "data_sources" and isinstance(v, list):
                    v = " | ".join(str(x) for x in v if x)
                row.append(v if v is not None else "")
            writer.writerow(row)

    # summary
    by_tier = {"A_acquire_self": 0, "B_forward": 0, "C_watch": 0, "D_pass": 0}
    for r in results:
        by_tier[r["final_tier"]] = by_tier.get(r["final_tier"], 0) + 1

    print(json.dumps({
        "total": len(results),
        "by_tier": by_tier,
        "deep_dive_pending_count": sum(1 for r in results if r["deep_dive_pending"]),
    }, indent=2))

    # top 5 by final_score
    print("\nTop 5 candidates:", file=sys.stderr)
    for r in sorted(results, key=lambda x: -x["final_score"])[:8]:
        print(f"  {r['final_score']} {r['final_tier']:12s} {r['legal_name']}  ({r['city']})", file=sys.stderr)


if __name__ == "__main__":
    main()
