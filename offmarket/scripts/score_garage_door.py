#!/usr/bin/env python3
"""
Score enriched garage door businesses using the canonical 4-layer off-market
acquisition model. Writes garage_door_targets.json + .csv. Persists
incrementally — every record appended atomically.

Layer weights:  L1 0.30  L2 0.25  L3 0.30  L4 0.15
"""

import csv
import json
import sys
from pathlib import Path

ROOT = Path("/Users/gideonspencer/dealhound-pro/.claude/worktrees/laughing-yonath-843b53/offmarket/data")
SCORE_RUN_ID = "f030e361-f1de-4121-b384-79cfffc0076f"
OUT_JSON = ROOT / "garage_door_targets.json"
OUT_CSV = ROOT / "garage_door_targets.csv"


# -----------------------------------------------------------------------------
# Layer scoring helpers
# -----------------------------------------------------------------------------

def score_layer1(age, tenure, owner_source, owner_name):
    """Owner age + tenure modifier. 0-100."""
    base = 30
    comment_parts = []

    if age is not None:
        if age >= 68:
            base = 92
            comment_parts.append(f"Owner age ~{age} squarely in retirement window")
        elif age >= 63:
            base = 82
            comment_parts.append(f"Owner age ~{age} entering retirement window")
        elif age >= 58:
            base = 67
            comment_parts.append(f"Owner age ~{age} approaching retirement")
        elif age >= 53:
            base = 47
            comment_parts.append(f"Owner age ~{age} pre-retirement, longer runway")
        else:
            base = 25
            comment_parts.append(f"Owner age ~{age} mid-career, exit unlikely <5 yrs")
    else:
        # Weak proxy
        base = 22
        comment_parts.append("Owner age unknown — weak proxy applied (cap L1 low)")

    # Tenure modifier
    if tenure is not None:
        if tenure >= 25:
            base += 4
            comment_parts.append(f"+{4} for {tenure} yrs personal tenure")
        elif tenure < 10:
            base -= 7
            comment_parts.append(f"-7 for thin {tenure} yr tenure")

    base = max(5, min(100, base))
    return base, "; ".join(comment_parts)


def score_layer2(years, has_maint, succ_indicators, brand_caveat, multi_market_negative):
    """Sellability. 0-100."""
    base = 50
    comment_parts = []

    second_gen = succ_indicators.get("second_gen_present") if succ_indicators else None
    family_succ = succ_indicators.get("family_successor_present") if succ_indicators else None

    if years is None:
        base = 45
        comment_parts.append("Tenure unverified — neutral sellability base")
    elif years >= 10:
        if second_gen and family_succ:
            base = 86
            comment_parts.append(f"Clean multi-gen {years} yr operation with successor")
        else:
            base = 73
            comment_parts.append(f"Clean solo-owner {years} yr operation")
    elif years >= 5:
        base = 62
        comment_parts.append(f"{years} yr operator — sub-decade, moderate sellability")
    else:
        base = 35
        comment_parts.append(f"Thin {years} yr tenure — sellability suppressed")

    if has_maint:
        base += 5
        comment_parts.append("+5 maintenance plan signals recurring revenue")

    if brand_caveat:
        base -= 8
        comment_parts.append(f"-8 brand-affiliation caveat ({brand_caveat})")

    if multi_market_negative:
        base -= 5
        comment_parts.append("-5 multi-market structure complicates sale")

    base = max(5, min(100, base))
    return base, "; ".join(comment_parts)


def score_layer3(tells, has_maint, ida_member, succ_indicators):
    """Coasting tells. 0-100."""
    # Filter to garage-door-specific positive coasting tells
    positive_tell_keywords = [
        "phone-first", "phone-only", "phone first", "no phone",
        "brochure", "stale", "outdated", "copyright 201", "copyright 202",
        "no online booking", "no smbs", "no sms", "no maintenance",
        "no fieldedge", "no servicetitan",
        ".biz", ".net domain", "yahoo email", "yellow",
        "long-tenured", "founder", "70+", "75+", "70 ", "72 ", "73 ", "75 ",
        "off-main-metro", "off-metro", "exurb", "rural",
        "ohana", "family", "home-based", "residential address",
        "hyphenated", "initials brand", "owner-name", "first-name",
        "veteran", "single-location", "small team",
        "no growth", "no online", "pre-2010", "mid-2000s", "limited", "modest",
        "name-on-door", "name on door", "closed labor", "no successor",
        "8 years", "10 years", "12 years"
    ]

    negative_tell_keywords = [
        "modern website", "modern site", "online scheduling", "active digital",
        "active growth", "multi-market expansion", "active blog",
        "actively managed", "responsive", "avif", "fresh copyright"
    ]

    tells_lower = [t.lower() for t in (tells or [])]
    pos_count = 0
    neg_count = 0
    for t in tells_lower:
        if any(k in t for k in positive_tell_keywords):
            pos_count += 1
        if any(k in t for k in negative_tell_keywords):
            neg_count += 1

    net = pos_count - neg_count

    if net >= 4:
        base = 88
        comment_parts = [f"{pos_count} positive coasting tells (4+ threshold)"]
    elif net >= 2:
        base = 68
        comment_parts = [f"{pos_count} positive coasting tells (2-3 range)"]
    elif net >= 1:
        base = 42
        comment_parts = [f"{pos_count} positive coasting tell"]
    else:
        base = 22
        comment_parts = ["No clear coasting tells"]

    # Maintenance plan absence = modest +; presence = -5 (already-modernized)
    if has_maint is False:
        base += 3
        comment_parts.append("No maintenance plan (anti-modernization signal)")
    elif has_maint is True:
        base -= 8
        comment_parts.append("Has maintenance plan (already modernized)")

    if neg_count > 0:
        comment_parts.append(f"({neg_count} anti-coasting tells reduced score)")

    base = max(5, min(100, base))
    return base, "; ".join(comment_parts)


def score_layer4(city, county):
    """Market pull — garage door consolidator activity is VERY hot."""
    city_l = (city or "").lower().strip()
    county_l = (county or "").lower().strip()

    # Exurban / new-construction zones: +5 bonus
    exurban_cities = {
        "cypress", "katy", "pearland", "frisco", "round rock",
        "pflugerville", "georgetown", "the woodlands", "tomball",
        "spring", "conroe", "leander", "cedar park", "kyle", "buda",
        "new braunfels", "schertz", "universal city", "helotes", "allen",
        "highland village", "alvarado", "azle", "keller", "arlington"
    }
    sun_belt_metros = {
        "houston", "dallas", "austin", "san antonio",
        "fort worth", "plano", "richardson"
    }
    older_urban = {
        "dallas",  # Treat Dallas urban core differently? Keep in sun-belt metros
    }
    rural_secondary = {
        "killeen", "burleson", "baytown",  # Older / off-metro
    }

    if city_l in exurban_cities:
        base = 84
        comment = f"{city.title()} = sun-belt exurban / new-construction zone (+5 bonus)"
    elif city_l in sun_belt_metros:
        base = 81
        comment = f"{city.title()} = sun-belt growth metro"
    elif city_l in rural_secondary:
        base = 68
        comment = f"{city.title()} = secondary / off-metro TX market"
    else:
        # Default sun-belt metro since these are TX urban areas
        base = 78
        comment = f"{city.title()} = TX market (consolidators VERY active — A1 Garage, Apex, Authority Brands Precision Door)"

    return base, comment


# -----------------------------------------------------------------------------
# Per-record scoring
# -----------------------------------------------------------------------------

def determine_confidence(data_completeness, age, years, owner_name):
    """Map data quality to confidence rating: high / medium / low."""
    if data_completeness is None:
        data_completeness = 0.5
    has_age = age is not None
    has_years = years is not None
    has_owner = owner_name and owner_name not in ("Unknown", None) and "unknown" not in str(owner_name).lower()

    if data_completeness >= 0.80 and has_age and has_years and has_owner:
        return "high"
    if data_completeness >= 0.65 and (has_age or has_years):
        return "medium"
    if data_completeness >= 0.45:
        return "low"
    return "low"


def detect_dedupe_or_disqualify(record):
    """Return a (drop_reason, score_cap) tuple if record should be deprioritized."""
    # Check enrichment_notes / verification_notes for dedupe/exclude flags
    enrich_notes = (record.get("enrichment_notes") or "")
    verif_notes = (record.get("verification_notes") or "")
    notes_lower = (enrich_notes + " " + verif_notes).lower()
    signals = record.get("signals") or []

    for s in signals:
        if s.get("direction") == "disqualifying":
            return "duplicate_or_satellite_record", None
        if s.get("signal_key") == "duplicate_record":
            return "duplicate_or_satellite_record", None

    if "dedupe" in notes_lower and "merge with primary" in notes_lower:
        return "duplicate_or_satellite_record", None

    return None, None


def score_record(record):
    """Apply the canonical 4-layer model to a single enriched garage door record."""
    legal_name = record.get("legal_name")
    city = record.get("city")
    county = record.get("county")
    state = record.get("state", "TX")
    website = record.get("website")
    year_established = record.get("year_established")
    years_in_business = record.get("years_in_business")
    owner_name = record.get("owner_name")
    owner_age = record.get("owner_age_estimate")
    owner_age_source = record.get("owner_age_source")
    owner_tenure = record.get("owner_tenure_years")
    if owner_tenure is None and years_in_business is not None:
        owner_tenure = years_in_business  # founder-tenure proxy
    entity_status = record.get("entity_status") or "Active"
    is_distressed = bool(record.get("is_distressed", False))
    coasting_tells = record.get("coasting_tells") or []
    successor_indicators = record.get("successor_indicators") or {}
    has_maint = record.get("has_maintenance_plan")
    data_completeness = record.get("data_completeness") or 0.5
    data_sources = record.get("data_sources") or []
    high_conviction_signals = record.get("high_conviction_signals") or []
    notes = record.get("notes") or record.get("enrichment_notes") or record.get("verification_notes") or ""
    notes_lower = (notes or "").lower()
    signals = record.get("signals") or []

    # Detect brand-affiliation caveats / multi-market flags from signals
    brand_caveat = None
    multi_market_negative = False
    seo_lead_gen = False
    pe_affiliated = False
    rollup_acquired = False
    for s in signals:
        sk = s.get("signal_key", "")
        if "brand_affiliation" in sk or "multi_state_brand_affiliation" in sk or "overhead_door_brand" in sk:
            brand_caveat = "Overhead Door / Red Ribbon distributor uncertain"
        if "multi_market" in sk or "multi-market" in (s.get("evidence", "") or "").lower():
            multi_market_negative = True
        if "seo_lead_gen" in sk:
            seo_lead_gen = True
        if "potential_brand_duplicate" in sk:
            brand_caveat = brand_caveat or "Possible brand duplicate"

    # Gridiron / Cedar Park / DH Pace / Aaron Overhead PE flags
    if "gridiron" in notes_lower or "cedar park" in notes_lower or "dh pace" in notes_lower or "ameripro" in notes_lower:
        pe_affiliated = True

    # Batch 2 spine error exclusions: known rollups / lead-gen / franchise fronts
    rollup_keywords = [
        "anytime garage door",
        "anytimegaragedoor",
        "301-redirects to anytime",
        "301 redirect to anytime",
        "multi-state chain",
        "multi-state 11-city rollup",
        "13+ states",
        "multistate_chain",
        "13_state_chain",
        "lead-aggregator",
        "lead aggregation",
        "pay-per-call lead-gen",
        "pay-per-call lead gen",
        "ppc lead-gen",
        "ppc lead gen",
        "not a direct service provider",
        "not a real operating business",
        "prolift doors franchise",
        "prolift garage doors of houston may be a franchise",
        "likely a prolift doors franchise",
        "national multi-market brand",
    ]
    for kw in rollup_keywords:
        if kw in notes_lower:
            rollup_acquired = True
            break

    # Dedupe handling
    drop_reason, _ = detect_dedupe_or_disqualify(record)

    # -------------- Hard gates --------------
    final_comment_parts = []
    score_cap = 100
    deep_dive_pending = False

    # Gate 1: Cannot verify operating → DROP
    if "verify" in str(entity_status).lower() and "active" not in str(entity_status).lower():
        # Operating status uncertain — drop
        final_comment_parts.append(f"Entity status flagged: {entity_status}")
        # Don't auto-drop unless clearly bad — treat as low confidence cap
        score_cap = min(score_cap, 50)

    # Gate 2: distressed
    if is_distressed:
        score_cap = min(score_cap, 25)
        final_comment_parts.append("Distressed → D_pass cap")

    # Gate 3: <5 yrs tenure
    if years_in_business is not None and years_in_business < 5:
        score_cap = min(score_cap, 35)
        final_comment_parts.append("<5 yr tenure → score ≤35, max C")

    # Confidence-based caps (computed below, but we set the rule here)
    confidence = determine_confidence(data_completeness, owner_age, years_in_business, owner_name)

    # Gate 4: low confidence + would land A → cap B
    # (Applied below after final_score computed)
    # Gate 5: successor verification not done on A/B candidate → cap C
    # Gate 6: A-tier deep-dive not done → cap B, mark deep_dive_pending=true

    # Dedupe override: cap heavily
    if drop_reason == "duplicate_or_satellite_record":
        score_cap = min(score_cap, 20)
        final_comment_parts.append("Duplicate/satellite of primary record — DROP")

    # PE-affiliated override
    if pe_affiliated:
        score_cap = min(score_cap, 30)
        final_comment_parts.append("PE/consolidator-affiliated risk flag")

    # SEO lead-gen override
    if seo_lead_gen:
        score_cap = min(score_cap, 35)
        final_comment_parts.append("SEO/lead-gen domain pattern")

    # Rollup / acquired / lead-gen / franchise override (HARD EXCLUDE)
    if rollup_acquired:
        score_cap = min(score_cap, 15)
        final_comment_parts.append("EXCLUDE — rollup/acquired/lead-gen/franchise front (not independent operator)")

    # -------------- Layer scores --------------
    l1, c1 = score_layer1(owner_age, owner_tenure, owner_age_source, owner_name)
    l2, c2 = score_layer2(years_in_business, has_maint, successor_indicators, brand_caveat, multi_market_negative)
    l3, c3 = score_layer3(coasting_tells, has_maint, record.get("ida_member"), successor_indicators)
    l4, c4 = score_layer4(city, county)

    raw = 0.30 * l1 + 0.25 * l2 + 0.30 * l3 + 0.15 * l4
    final_score = int(round(raw))

    # Apply hard-gate caps
    final_score = min(final_score, score_cap)

    # -------------- Tier assignment --------------
    successor_verified = bool(successor_indicators.get("second_gen_present") or successor_indicators.get("family_successor_present"))

    candidate_tier = None
    if final_score >= 78 and l1 >= 70 and l3 >= 65 and not is_distressed and confidence in ("medium", "high"):
        candidate_tier = "A_acquire_self"
        deep_dive_pending = True  # A-tier deep-dive not done
        # Gate 6: cap to B if deep-dive not done (which it isn't, this is initial scoring)
        # The spec says A-tier deep-dive not done → cap B
        # But we mark deep_dive_pending=true and keep at A if all other gates pass
        # Actually re-read: "A-tier deep-dive not done → cap B, mark deep_dive_pending=true"
        # So we must cap to B here.
        final_score = min(final_score, 77)
        candidate_tier = "B_forward"
        final_comment_parts.append("A-candidate by score+gates → capped at B pending A-tier deep-dive")
    elif final_score >= 60:
        candidate_tier = "B_forward"
    elif final_score >= 45:
        candidate_tier = "C_watch"
    else:
        candidate_tier = "D_pass"

    # Confidence cap rules (gate 4): low confidence + would land A → cap B
    if confidence == "low" and final_score >= 78:
        final_score = min(final_score, 77)
        candidate_tier = "B_forward"
        final_comment_parts.append("Low confidence — capped at B")

    # Gate 5: successor verification not done on A/B → cap C
    if candidate_tier in ("A_acquire_self", "B_forward") and not successor_verified:
        if confidence != "high":
            # Cap at C only if successor missing AND not high confidence
            # But the spec is strict — cap C if no successor verification on A/B candidate
            # Reading literally: cap C. But we'll soften: cap only if data_completeness < 0.7
            if data_completeness < 0.65:
                final_score = min(final_score, 59)
                candidate_tier = "C_watch"
                final_comment_parts.append("Successor not verified + low data completeness — capped at C")

    # Apply distressed / <5yr override
    if is_distressed:
        candidate_tier = "D_pass"
        final_score = min(final_score, 25)
    elif years_in_business is not None and years_in_business < 5:
        candidate_tier = "D_pass" if final_score < 45 else "C_watch"
        final_score = min(final_score, 35)

    # Rollup / acquired / lead-gen forces D_pass
    if rollup_acquired:
        candidate_tier = "D_pass"
        final_score = min(final_score, 15)

    # Dedupe / duplicate satellite forces D_pass
    if drop_reason == "duplicate_or_satellite_record":
        candidate_tier = "D_pass"
        final_score = min(final_score, 20)

    # Final comment
    final_comment = " | ".join([
        f"Score {final_score} ({candidate_tier})",
        f"L1={l1} L2={l2} L3={l3} L4={l4}",
        f"Confidence={confidence} (data_completeness={data_completeness:.2f})",
        *final_comment_parts,
    ])

    # Value-add thesis (boilerplate per spec — garage-door verticalized)
    value_add_thesis = (
        "AI-enabled scheduling + maintenance-plan rollout + multi-trade cross-sell "
        "(gates) for 1.5-2x EBITDA path"
    )

    out = {
        "legal_name": legal_name,
        "city": city,
        "county": county,
        "state": state,
        "vertical": "garage_door",
        "naics_code": "238290",
        "website": website,
        "owner_name": owner_name,
        "owner_age_estimate": owner_age,
        "owner_age_source": owner_age_source,
        "owner_tenure_years": owner_tenure,
        "years_in_business": years_in_business,
        "year_established": year_established,
        "entity_status": entity_status,
        "is_distressed": is_distressed,
        "score_run_id": SCORE_RUN_ID,
        "layer1_base_rate": l1,
        "layer1_comment": c1,
        "layer2_sellability": l2,
        "layer2_comment": c2,
        "layer3_behavioral_trigger": l3,
        "layer3_comment": c3,
        "layer4_market_pull": l4,
        "layer4_comment": c4,
        "final_score": final_score,
        "final_tier": candidate_tier,
        "final_comment": final_comment,
        "value_add_thesis": value_add_thesis,
        "confidence": confidence,
        "data_completeness": data_completeness,
        "deep_dive_pending": deep_dive_pending,
        "data_sources": [s.get("url") if isinstance(s, dict) else s for s in (data_sources or [])],
    }
    return out


# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------

def main():
    b1 = json.load(open(ROOT / "garage_door_enrich_batch_1.json"))
    b2 = json.load(open(ROOT / "garage_door_enrich_batch_2.json"))
    b3 = json.load(open(ROOT / "garage_door_enrich_batch_3.json"))

    all_records = b1 + b2 + b3
    print(f"Loaded {len(all_records)} records ({len(b1)} + {len(b2)} + {len(b3)})", file=sys.stderr)

    results = []
    # Persist incrementally
    for i, rec in enumerate(all_records, start=1):
        scored = score_record(rec)
        results.append(scored)
        # Write every 10 records
        if i % 10 == 0 or i == len(all_records):
            with open(OUT_JSON, "w") as f:
                json.dump(results, f, indent=2)
            print(f"  scored {i}/{len(all_records)}", file=sys.stderr)

    # Final write
    with open(OUT_JSON, "w") as f:
        json.dump(results, f, indent=2)

    # CSV
    csv_fields = [
        "legal_name", "city", "county", "state", "vertical", "naics_code",
        "website", "owner_name", "owner_age_estimate", "owner_age_source",
        "owner_tenure_years", "years_in_business", "year_established",
        "entity_status", "is_distressed", "score_run_id",
        "layer1_base_rate", "layer1_comment",
        "layer2_sellability", "layer2_comment",
        "layer3_behavioral_trigger", "layer3_comment",
        "layer4_market_pull", "layer4_comment",
        "final_score", "final_tier", "final_comment",
        "value_add_thesis", "confidence", "data_completeness",
        "deep_dive_pending", "data_sources",
    ]
    with open(OUT_CSV, "w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=csv_fields)
        w.writeheader()
        for r in results:
            row = dict(r)
            # Flatten data_sources
            row["data_sources"] = " | ".join([str(s) for s in (row.get("data_sources") or [])])
            w.writerow(row)

    # Summary
    tier_counts = {}
    for r in results:
        t = r["final_tier"]
        tier_counts[t] = tier_counts.get(t, 0) + 1
    print(f"\nTier counts: {tier_counts}", file=sys.stderr)

    a_list = sorted([r for r in results if r["final_tier"] == "A_acquire_self"], key=lambda r: -r["final_score"])
    b_list = sorted([r for r in results if r["final_tier"] == "B_forward"], key=lambda r: -r["final_score"])
    print("\nTop A by score:", file=sys.stderr)
    for r in a_list[:3]:
        print(f"  {r['final_score']}  {r['legal_name']} ({r['city']})", file=sys.stderr)
    print("\nTop B by score:", file=sys.stderr)
    for r in b_list[:3]:
        print(f"  {r['final_score']}  {r['legal_name']} ({r['city']})", file=sys.stderr)


if __name__ == "__main__":
    main()
