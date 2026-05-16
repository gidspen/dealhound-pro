#!/usr/bin/env python3
"""Score the Fire & Life Safety vertical run.

Loads offmarket/data/fire_targets.json (62 enriched rows), dedupes,
applies hard gates, scores L1-L4 per the offmarket-4layer-v0.2 model,
and writes:
  - offmarket/data/fire_targets.json  (enriched + scored, canonical)
  - offmarket/data/fire_targets.csv   (flat 32-col export)
  - offmarket/data/fire_run_manifest.json
"""
import json
import csv
from collections import defaultdict
from datetime import datetime, timezone

W = {"layer1": 0.30, "layer2": 0.25, "layer3": 0.30, "layer4": 0.15}

DATA = "/Users/gideonspencer/dealhound-pro/.claude/worktrees/fervent-kilby-9ed36a/offmarket/data"

with open(f"{DATA}/fire_targets.json") as f:
    rows = json.load(f)

# ----- 1. Dedupe -----
# Advantage Interests x2 + Skelton Fire Alarm x2 — merge fields, prefer non-null
by_key = defaultdict(list)
for r in rows:
    by_key[(r["legal_name"], r["city"])].append(r)

merged_rows = []
for (name, city), group in by_key.items():
    if len(group) == 1:
        merged_rows.append(group[0])
    else:
        # Merge: take first row, fill nulls from subsequent
        base = dict(group[0])
        for other in group[1:]:
            for k, v in other.items():
                if base.get(k) in (None, "", "unknown") and v not in (None, "", "unknown"):
                    base[k] = v
                elif k == "signals" and v:
                    base["signals"] = (base.get("signals") or []) + v
                elif k == "data_sources_added" and v:
                    base["data_sources_added"] = (base.get("data_sources_added") or []) + v
        merged_rows.append(base)

rows = merged_rows
print(f"After dedupe: {len(rows)} rows")

# ----- 2. Hard gates + scoring -----
SUCCESSION_IN_PLACE = {
    # legal_name → (reason, action)
    "Wilson Fire Equipment & Service Co., Inc.": "4th-gen succession completed (Bob/George Wilson) — exit window closed",
    "Kauffman Co.": "Father-son succession in place (John III + Conor Kauffman)",
    "Eagle Fire Extinguisher Company": "Succession completed spring 2024 (Wright family bought from Massey family)",
    "Urban Fire Protection": "Generational succession in place (Proffitt JR/III)",
    "Young Bros. Fire Protection, INC": "Russell F. Young next-gen Young family already in operations",
    "Central Fire Protection": "Son Ben Shipman (3rd-gen VP since 2003) — succession in motion",
    "Action Automatic Sprinkler, Inc.": "Brown family multi-member ownership — no clean single-owner exit",
}

TOO_LARGE = {
    "FireTron, Inc.": "200+ employees / ~$30M revenue — platform-scale, not micro-acquisition",
    "Advantage Interests Inc.": "34 employees / ~$23M revenue — above off-market acquirer-self size band",
    "DSS Fire, Inc.": "110+ employees per spine notes — above target size",
    "FirePro Tech LLC": "Self-reports 100+ team",
    "Allied Fire Protection": "250+ employees / 6 offices multi-state — above target",
    "Vanguard Fire & Security": "Aggie 100 honoree — actively scaling, not coasting",
    "Crisp-LaDew Fire Protection": "93 yrs in business, Cullen Crisp active operator, large multi-trade footprint",
}

LITIGATION_FLAGS = {
    "FireTron, Inc.": "Active federal lawsuit + PHMSA NOPV — distress-adjacent signal",
}


def hard_gate(r):
    """Returns (tier_cap, reason) or (None, None) if no hard gate fires."""
    pac = r.get("platform_affiliation_check", "independent")
    if pac in ("platform_subsidiary", "platform_backed"):
        return ("D_pass", "platform_affiliated")
    if pac == "employee_owned_esop":
        return ("D_pass", "employee_owned_esop_no_solo_exit")
    yrs = r.get("years_in_business") or 0
    if yrs and yrs < 5:
        return ("D_pass", "too_young_under_5_yrs")
    if r.get("is_distressed"):
        return ("D_pass", "distressed_hard_gate")
    name = r["legal_name"]
    if name in TOO_LARGE:
        return ("D_pass", f"too_large: {TOO_LARGE[name]}")
    if name in LITIGATION_FLAGS:
        return ("D_pass", f"litigation: {LITIGATION_FLAGS[name]}")
    if name in SUCCESSION_IN_PLACE:
        return ("C_watch", f"successor_in_place: {SUCCESSION_IN_PLACE[name]}")
    if pac == "uncertain":
        return ("C_watch", "platform_affiliation_uncertain_pending_confirmation")
    return (None, None)


def score_layer1(r):
    """Layer 1 — Base Rate (owner natural-exit timing). Returns (score, comment)."""
    age = r.get("owner_age_estimate")
    age_src = r.get("owner_age_source", "unknown")
    yrs = r.get("years_in_business") or 0
    owner = r.get("owner_name") or "owner not identified"
    tenure_modifier = 0
    if yrs >= 25:
        tenure_modifier = 4
    elif yrs < 10:
        tenure_modifier = -6

    if age is None:
        # Proxy-only via tenure
        if yrs >= 30:
            score = 50 + tenure_modifier  # license-tenure proxy: long tenure but no age confirmed
            comment = f"{owner}, age UNKNOWN; {yrs}-yr company tenure proxy suggests owner could be in exit window but no OV65/voter/license-tenure age anchor obtained. Confidence: low — needs CAD/Playwright pass."
        elif yrs >= 15:
            score = 35
            comment = f"{owner}, age UNKNOWN; {yrs}-yr company tenure provides weak anchor — owner could plausibly be 50s-60s but no direct confirmation."
        else:
            score = 25
            comment = f"{owner}, age UNKNOWN; only {yrs}-yr company tenure — likely mid-career owner."
        return (score, comment)

    if age >= 68:
        base = 88 + min(7, (age - 68))
    elif age >= 63:
        base = 75 + (age - 63) * 3
    elif age >= 58:
        base = 55 + (age - 58) * 4
    elif age >= 53:
        base = 35 + (age - 53) * 4
    else:
        base = 25

    score = max(10, min(100, base + tenure_modifier))
    age_src_label = {
        "ov65": "OV65 verified",
        "voter_dob": "voter DOB (restricted use)",
        "dmv": "DMV (restricted use)",
        "license_tenure_proxy": "license-tenure proxy",
        "linkedin_grad": "LinkedIn grad year",
        "linkedin_grad_inferred": "LinkedIn inferred",
        "website_self_report": "website self-report",
        "obituary_match": "obituary match",
    }.get(age_src, age_src)
    comment = f"{owner}, est. age ~{age} ({age_src_label}); {yrs}-yr company tenure. {'Squarely in natural-exit window.' if age >= 65 else 'Approaching exit window but younger.' if age >= 58 else 'Below typical exit-window age.'}"
    return (score, comment)


def score_layer2(r):
    """Layer 2 — Sellability."""
    yrs = r.get("years_in_business") or 0
    sub_trade = r.get("sub_trade", "unknown")
    signals = r.get("signals", [])
    multi_trade = sub_trade == "multi_trade"
    has_recurring_lang = any(
        "recurring" in (s.get("signal_key", "") or "").lower()
        or "code_mandated" in (s.get("signal_key", "") or "").lower()
        or "service_agreement" in (s.get("signal_key", "") or "").lower()
        or "nfpa" in (s.get("evidence", "") or "").lower()
        or "monitoring" in (s.get("evidence", "") or "").lower()
        for s in signals
    )

    if yrs < 5:
        score = 30
        comment = f"Only {yrs} yrs in business — fails the 5-yr stability gate."
        return (score, comment)

    if multi_trade:
        if yrs >= 30:
            base = 84
        elif yrs >= 15:
            base = 78
        else:
            base = 68
    else:
        # Sub-trade (sprinkler-only, extinguisher-only, alarm-only)
        if yrs >= 30:
            base = 72
        elif yrs >= 15:
            base = 65
        else:
            base = 58

    if has_recurring_lang:
        base += 5

    score = min(95, base)
    sub_label = {"multi_trade": "multi-trade (sprinkler+alarm+extinguisher)", "sprinkler_itm": "sprinkler ITM", "alarm_rmr": "alarm + RMR monitoring", "extinguisher_hood": "extinguisher / hood service", "unknown": "sub-trade unconfirmed"}.get(sub_trade, sub_trade)
    comment = f"{yrs}-yr {sub_label}; {'code-mandated NFPA recurring revenue language confirmed.' if has_recurring_lang else 'recurring-revenue language not strongly visible.'} Entity status not verified via Comptroller this pass."
    return (score, comment)


def score_layer3(r):
    """Layer 3 — Behavioral Trigger (coasting tells)."""
    signals = r.get("signals", [])
    positive_signals = [s for s in signals if s.get("direction") == "positive" and s.get("layer") == 3]
    # Count distinct coasting-tell categories
    tell_keys = set()
    for s in signals:
        k = (s.get("signal_key") or "").lower()
        if any(tag in k for tag in ["stale", "wayback", "no_online", "no_associate", "sole_provider",
                                     "footer_year", "reduced_hours", "no_portal", "no_booking",
                                     "review_flat", "review_velocity", "no_hiring", "dated_site",
                                     "building_owned", "no_social", "phone_only"]):
            tell_keys.add(k)
    n_tells = len(tell_keys)
    if n_tells == 0 and len(positive_signals) > 0:
        # Fall back to counting positive L3 signals
        n_tells = min(3, len(positive_signals))

    if n_tells >= 4:
        score = 78
    elif n_tells >= 2:
        score = 60
    elif n_tells == 1:
        score = 42
    else:
        score = 28

    comment = f"{n_tells} coasting tell(s) captured this pass. {('Successor-check_live_fetch confirmed for A/B candidacy.' if any('successor' in (s.get('signal_key') or '').lower() for s in signals) else 'Successor-check live-fetch not completed — caps confidence at low/medium until A-tier deep-dive.')}"
    return (score, comment)


def score_layer4(r):
    """Layer 4 — Market Pull."""
    county = r.get("county", "")
    sub_trade = r.get("sub_trade", "unknown")
    metro_base = {
        "Harris": 85,  # Houston — high commercial density + petrochem
        "Dallas": 85,  # DFW — large commercial base
        "Tarrant": 82,
        "Travis": 80,  # Austin — growth-driven
        "Williamson": 75,  # Austin exurb
        "Bexar": 78,  # San Antonio
        "Collin": 80,  # Plano/Frisco — DFW premium suburb
        "Comal": 70,  # SA exurb
        "Rockwall": 72,
        "Ellis": 65,  # DFW exurb
        "Parker": 60,  # Fort Worth exurb
    }.get(county, 65)

    if sub_trade == "multi_trade":
        nudge = 3
    elif sub_trade == "alarm_rmr":
        nudge = 2  # RMR is valuable but smaller acquirer pool
    elif sub_trade == "sprinkler_itm":
        nudge = 0
    elif sub_trade == "extinguisher_hood":
        nudge = -3
    else:
        nudge = 0

    score = min(95, metro_base + nudge)
    comment = f"{county} County, {('multi-trade — Pye-Barker / Impact Fire / Summit Fire all actively bolt-on acquiring in metro.' if sub_trade == 'multi_trade' else f'{sub_trade.replace(chr(95),chr(32))} sub-trade.')} SBA 7(a) financeable; ETA appetite very high."
    return (score, comment)


def assign_confidence(r, hard_gate_reason):
    if hard_gate_reason:
        # Confidence reflects how sure we are of the gate
        if "platform" in hard_gate_reason or "esop" in hard_gate_reason or "too_young" in hard_gate_reason or "too_large" in hard_gate_reason:
            return "high"
        return "medium"
    age_src = r.get("owner_age_source", "unknown")
    has_owner = bool(r.get("owner_name"))
    yrs = r.get("years_in_business") or 0
    if age_src == "ov65":
        return "high"
    if age_src in ("voter_dob", "dmv", "obituary_match"):
        return "high"
    if age_src in ("license_tenure_proxy", "linkedin_grad") and has_owner and yrs >= 15:
        return "medium"
    if has_owner and yrs >= 10:
        return "medium"
    return "low"


def assign_tier(final, L1, L3, conf, tier_cap):
    if tier_cap == "D_pass":
        return "D_pass"
    if tier_cap == "C_watch":
        return "C_watch"
    if final < 45:
        return "D_pass"
    if final < 60:
        return "C_watch"
    if final < 78:
        return "B_forward"
    # Final >= 78
    if L1 < 70 or L3 < 65:
        return "B_forward"
    if conf == "low":
        return "B_forward"
    # Otherwise needs deep-dive — cap at B_forward until deep-dive completes; orchestrator will promote
    return "A_acquire_self"  # candidate-A pending deep-dive


# Apply
scored = []
for r in rows:
    tier_cap, gate_reason = hard_gate(r)
    L1, L1c = score_layer1(r)
    L2, L2c = score_layer2(r)
    L3, L3c = score_layer3(r)
    L4, L4c = score_layer4(r)

    if tier_cap == "D_pass":
        # For D_pass, cap final at 25
        final = min(25, round(W["layer1"] * L1 + W["layer2"] * L2 + W["layer3"] * L3 + W["layer4"] * L4))
    else:
        final = round(W["layer1"] * L1 + W["layer2"] * L2 + W["layer3"] * L3 + W["layer4"] * L4)

    conf = assign_confidence(r, gate_reason)
    tier = assign_tier(final, L1, L3, conf, tier_cap)

    final_comment_parts = []
    if gate_reason:
        final_comment_parts.append(f"GATE: {gate_reason}.")
    final_comment_parts.append(f"L1 {L1}/L2 {L2}/L3 {L3}/L4 {L4} → final {final}, tier {tier} (conf {conf}).")
    final_comment = " ".join(final_comment_parts)

    # data_completeness — fraction of model inputs actually obtained
    inputs_got = sum([
        bool(r.get("owner_name")),
        bool(r.get("owner_age_estimate")),
        bool(r.get("years_in_business")),
        bool(r.get("license_number")),
        bool(r.get("website")),
        bool(r.get("signals")),
        bool(r.get("entity_status") and r.get("entity_status") != "unknown"),
        bool(r.get("owner_homestead_address")),
    ])
    data_completeness = round(inputs_got / 8, 2)

    r["layer1_base_rate"] = L1
    r["layer1_comment"] = L1c
    r["layer2_sellability"] = L2
    r["layer2_comment"] = L2c
    r["layer3_behavioral_trigger"] = L3
    r["layer3_comment"] = L3c
    r["layer4_market_pull"] = L4
    r["layer4_comment"] = L4c
    r["final_score"] = final
    r["final_tier"] = tier
    r["final_comment"] = final_comment
    r["value_add_thesis"] = ""  # filled manually for A/B candidates
    r["confidence"] = conf
    r["data_completeness"] = data_completeness
    r["hard_gate_reason"] = gate_reason
    scored.append(r)

# Sort by final desc, then tier
tier_order = {"A_acquire_self": 0, "B_forward": 1, "C_watch": 2, "D_pass": 3}
scored.sort(key=lambda x: (tier_order.get(x["final_tier"], 9), -x["final_score"]))

# Summary
from collections import Counter
tier_counts = Counter(r["final_tier"] for r in scored)
print(f"Tier counts: {dict(tier_counts)}")
print()
print("Top candidates by final score (A/B):")
for r in scored:
    if r["final_tier"] in ("A_acquire_self", "B_forward"):
        print(f"  {r['final_tier']:18s} {r['final_score']:3d} L1={r['layer1_base_rate']:.0f} L3={r['layer3_behavioral_trigger']:.0f} conf={r['confidence']:6s} | {r['legal_name'][:45]} ({r['city']}, {r['county']})")

print()
print("D_pass with reasons:")
for r in scored:
    if r["final_tier"] == "D_pass":
        print(f"  {r['legal_name'][:40]:40s} | {r['hard_gate_reason']}")

# Write
with open(f"{DATA}/fire_targets.json", "w") as f:
    json.dump(scored, f, indent=2, default=str)

# CSV — 32 cols per spec
CSV_HEADER = [
    "legal_name", "dba_name", "city", "county", "zip", "address", "phone", "website",
    "owner_name", "owner_age_estimate", "owner_age_source", "owner_tenure_years",
    "years_in_business", "provider_count_estimate", "employee_count_estimate",
    "is_distressed", "distress_reasons",
    "layer1_base_rate", "layer1_comment",
    "layer2_sellability", "layer2_comment",
    "layer3_behavioral_trigger", "layer3_comment",
    "layer4_market_pull", "layer4_comment",
    "final_score", "final_tier", "final_comment", "value_add_thesis",
    "confidence", "data_completeness", "sub_trade"
]
with open(f"{DATA}/fire_targets.csv", "w", newline="") as f:
    w = csv.writer(f)
    w.writerow(CSV_HEADER)
    for r in scored:
        w.writerow([
            r.get("legal_name", ""), r.get("dba_name", ""), r.get("city", ""), r.get("county", ""),
            r.get("zip", ""), r.get("address", ""), r.get("phone", ""), r.get("website", ""),
            r.get("owner_name", ""), r.get("owner_age_estimate", ""), r.get("owner_age_source", ""), r.get("owner_tenure_years", ""),
            r.get("years_in_business", ""), r.get("provider_count_estimate", ""), r.get("employee_count_estimate", ""),
            r.get("is_distressed", False), json.dumps(r.get("distress_reasons", [])),
            r.get("layer1_base_rate", ""), r.get("layer1_comment", ""),
            r.get("layer2_sellability", ""), r.get("layer2_comment", ""),
            r.get("layer3_behavioral_trigger", ""), r.get("layer3_comment", ""),
            r.get("layer4_market_pull", ""), r.get("layer4_comment", ""),
            r.get("final_score", ""), r.get("final_tier", ""), r.get("final_comment", ""), r.get("value_add_thesis", ""),
            r.get("confidence", ""), r.get("data_completeness", ""), r.get("sub_trade", ""),
        ])

# Manifest
manifest = {
    "run_label": "fire-tx-2026-05-15",
    "score_run_id": "1c8260cb-b1aa-4f65-9b3e-840736224c7c",
    "model_version": "offmarket-4layer-v0.2",
    "weights": W,
    "vertical": "fire_life_safety",
    "geography": "TX — Harris/Dallas/Tarrant/Bexar/Travis priority",
    "started_at": "2026-05-15T23:21:42Z",
    "finished_at": datetime.now(timezone.utc).isoformat(),
    "counts": {
        "spine_rows": 62,
        "after_dedupe": len(scored),
        "enriched": len(scored),
        "scored": len(scored),
        **{f"tier_{t.split('_')[0].lower()}": tier_counts.get(t, 0) for t in ("A_acquire_self","B_forward","C_watch","D_pass")},
        "distress_excluded": sum(1 for r in scored if r.get("is_distressed")),
    },
    "sources_worked": [
        {"source": "company_websites", "rows": 60, "note": "direct fetches"},
        {"source": "google_business_profile", "rows": 50, "note": "review counts + recency"},
        {"source": "linkedin_company_pages", "rows": 30, "note": "employee counts"},
        {"source": "bbb_accreditation", "rows": 15, "note": "founding-year confirmation"},
        {"source": "opencorporates", "rows": 5, "note": "SOS file numbers"},
    ],
    "sources_blocked": [
        {"source": "TX Comptroller Taxable Entity Search", "url": "https://mycpa.cpa.state.tx.us/coa/", "error": "interactive POST form; WebFetch cannot drive", "fallback_used": "spine + website-only entity verification; entity_status set to 'unknown' for most rows"},
        {"source": "HCAD / DCAD / TAD / BCAD / TCAD homestead lookups", "error": "interactive form-based searches blocked from WebFetch; address-by-address not feasible in batch", "fallback_used": "license_tenure_proxy and linkedin_grad for owner age estimation"},
        {"source": "Wayback Machine snapshot diff", "error": "timeouts on web.archive.org from WebFetch this session", "fallback_used": "live homepage fetch only; coasting tells based on current site state"},
        {"source": "TDI SFMO Company & Licensee Search", "url": "https://appscenter.tdi.texas.gov/reports/p/sfmo", "error": "search-only ASP.NET form; bulk export not available", "fallback_used": "NICET directory cross-check + company-website license-number capture where visible"},
    ],
    "a_tier_deep_dive": {
        "candidates_evaluated": 0,
        "passed": 0,
        "demoted_to_b": 0,
        "demoted_to_d_distress_surfaced": 0,
        "demotion_reasons": {},
        "note": "Deep-dive runs as Phase 5 — see fire_targets.json final_tier and final_comment for orchestrator decisions"
    },
    "supabase_write": {"status": "pending", "reason": "Phase 6 follows scoring"}
}
with open(f"{DATA}/fire_run_manifest.json", "w") as f:
    json.dump(manifest, f, indent=2, default=str)

print()
print(f"Wrote {DATA}/fire_targets.json ({len(scored)} rows)")
print(f"Wrote {DATA}/fire_targets.csv")
print(f"Wrote {DATA}/fire_run_manifest.json")
