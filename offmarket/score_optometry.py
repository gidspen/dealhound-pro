#!/usr/bin/env python3
"""Score the Optometry vertical run."""
import json, csv
from collections import defaultdict, Counter
W = {"layer1":0.30,"layer2":0.25,"layer3":0.30,"layer4":0.15}
DATA = "/Users/gideonspencer/dealhound-pro/.claude/worktrees/fervent-kilby-9ed36a/offmarket/data"

with open(f"{DATA}/optometry_targets.json") as f:
    rows = json.load(f)

by_key = defaultdict(list)
for r in rows:
    by_key[(r.get("legal_name",""), r.get("city",""))].append(r)
merged = []
for k, g in by_key.items():
    if len(g) == 1:
        merged.append(g[0])
    else:
        base = dict(g[0])
        for o in g[1:]:
            for k2, v in o.items():
                if base.get(k2) in (None,"","unknown") and v not in (None,"","unknown"):
                    base[k2] = v
        merged.append(base)
rows = merged

# Hard-gate dictionaries
SUCCESSION_IN_PLACE = {
    "Walnut Vision": "DeShaw father-son succession in place",
    "Vision Source Kingwood": "Glenn Ellisor = founder of Vision Source cooperative + 3-gen family pipeline (Wade + Erin)",
    "Cedar Park Vision": "Husband-wife co-owners + Dr. Rains internal-successor candidate",
    "Lakeline Vision Source": "Son Eric Hammond OD already in practice = locked family succession",
    "Pak Family Eye Care": "Husband-wife co-owners — internal locked",
    "Klein Eyecare": "Today's Vision franchise + recent associate hire (Moczygemba)",
    "Better Vision TX": "Owner ~43, growth-mode multi-location",
    "Eye Site Texas": "Owner ~50, multi-location, young children — growth mode",
    "Pearland Eye Associates": "Sister practice to Exquisite (same operator) — co-owner pattern",
    "Vision Pro": "5 ODs not solo, owner ~52",
    "Envision Eye Care": "Owner ~52, two-party PLLC (Nguyen & Whyte)",
    "Houston Family Eyecare": "Two-party PLLC (Nguyen & Whyte)",
    "Vision Source Meyer Park": "Steve Lai = 2-location operator + Vision Source administrator",
    "Eye Shop on Memorial": "4 ODs, 2023 relocation — active growth",
    "Exquisite Eye Care": "Multi-OD with sister Pearland location (same operator)",
    "Aspire Vision Care": "Husband-wife co-owners + 4 ODs + Aspire Vision Training Center build mode",
    "Great Hills Eye Care": "4 locations / 7 ODs / 40K patients — platform-rollup target, not micro-acquisition",
    "Austin Vision Center": "Spine flagged STRONG A but enrichment found Dr. Clay Barnett (multi-practice operator with 3 young kids) — current owner mid-career, not founder",
    "Austin Optometry Group": "Spine flagged STRONG A but enrichment found Dr. Wolf is 2nd-gen owner (bought 2009), ~42, KOL/consultant active growth",
    "Bristol Family Eyecare": "Mid-career owner with young kids, 3 locations, just got biz degree 2022",
    "Boerne Vision Center": "Owner has 3 young children, 14 yrs, growth mode",
    "Clear Eye Care": "Regional growth operator, founder age ~41 + multi-location",
    "Modern Spectacle": "Only 2-yr practice",
    "Sonie Vision": "Brand-new private practice launched after 16 yrs corporate optometry — build mode",
    "Cedar Park Eye Care": "Solo Dr. McCarty ~50, too young (8-15 yr horizon)",
    "Eye Capitol": "Owner 38-46, build/growth mode",
    "Ranch Road Vision": "Owner 38-46, build/growth mode",
    "Round Rock Eyes": "Owner 38-46, build/growth mode",
    "Crystal Falls Vision": "Owner 38-46, build/growth mode",
    "Look + See Eye Care": "Owner 38-46, build/growth mode",
    "Lifetime Eyecare Associates": "Multi-location independent",
    "Colony Eye Care Center": "Multi-location LLP",
    "Vision Source Copperfield": "Original founder gone; current senior OD UHCO 2006 + 2022 associate hire — succession already executed",
    "Pro-Optix": "2025 relocation to Upper Kirby — expansion mode",
    "Vision Source Aldine": None,  # Keep — actually a strong solo pick
}
# Don't disqualify Vision Source Aldine
del SUCCESSION_IN_PLACE["Vision Source Aldine"]

OUT_OF_SCOPE_OR_MISCLASS = {
    "Alamo Eye Institute": "Misclassified — Dr. Lynnell Lowry is MD ophthalmologist (GWU SOM 1993), not OD",
    "River Oaks Optical": "Optical-retail boutique with leased OD, not OD-owned practice",
}

TOO_YOUNG_OR_MID_CAREER = {
    "Northwest Animal Hospital": "Different vertical — skip",  # shouldn't match
}

def hard_gate(r):
    name = r.get("legal_name","")
    pac = r.get("platform_affiliation_check","independent")
    if pac in ("retail_chain","platform_subsidiary"):
        return ("D_pass", f"platform_or_retail: {pac}")
    if "MD_not_OD" in pac or name in OUT_OF_SCOPE_OR_MISCLASS:
        return ("D_pass", f"out_of_scope_or_misclassified: {OUT_OF_SCOPE_OR_MISCLASS.get(name, pac)}")
    if r.get("recent_acquisition"):
        return ("D_pass", "recent_acquisition_post_spine")
    if r.get("is_distressed"):
        return ("D_pass", "distressed_hard_gate")
    yrs = r.get("years_in_business") or 0
    if yrs and yrs < 5:
        return ("D_pass", "too_young_under_5_yrs")
    if name in SUCCESSION_IN_PLACE:
        return ("D_pass" if "growth" in SUCCESSION_IN_PLACE[name].lower() or "mid-career" in SUCCESSION_IN_PLACE[name].lower() or "build" in SUCCESSION_IN_PLACE[name].lower() else "C_watch", f"succession_or_growth: {SUCCESSION_IN_PLACE[name]}")
    if "multi_location" in pac:
        return ("C_watch", f"multi_location_indep: {pac}")
    if pac == "uncertain":
        return ("C_watch", "platform_affiliation_uncertain")
    return (None, None)

def score_layer1(r):
    age = r.get("owner_age_estimate")
    age_src = r.get("owner_age_source","unknown")
    yrs = r.get("years_in_business") or 0
    owner = r.get("owner_name") or "owner not identified"
    tenure_mod = 4 if yrs >= 25 else (-6 if yrs < 10 else 0)
    if age is None:
        if yrs >= 30:
            base = 55
        elif yrs >= 20:
            base = 45
        elif yrs >= 15:
            base = 35
        else:
            base = 25
        score = max(10, min(100, base + tenure_mod))
        comment = f"{owner}, age UNKNOWN; {yrs}-yr practice tenure — license-tenure proxy only."
        return (score, comment)
    if age >= 68:
        base = 88 + min(7, age - 68)
    elif age >= 63:
        base = 75 + (age - 63) * 3
    elif age >= 58:
        base = 55 + (age - 58) * 4
    elif age >= 53:
        base = 35 + (age - 53) * 4
    else:
        base = 25
    score = max(10, min(100, base + tenure_mod))
    age_src_label = {"ov65":"OV65","voter_dob":"voter DOB","license_tenure_proxy":"license-tenure proxy","linkedin_grad":"LinkedIn grad","website_self_report":"website self-report"}.get(age_src, age_src)
    comment = f"{owner}, est. age ~{age} ({age_src_label}); {yrs}-yr practice tenure."
    return (score, comment)

def score_layer2(r):
    yrs = r.get("years_in_business") or 0
    od_count = r.get("provider_count_estimate") or 1
    practice_type = r.get("practice_type","unknown")
    optical_attached = r.get("optical_attached", False)
    if yrs < 5:
        return (30, f"Only {yrs} yrs — fails 5-yr gate.")
    if yrs >= 30:
        base = 82
    elif yrs >= 20:
        base = 75
    elif yrs >= 10:
        base = 65
    else:
        base = 55
    if od_count >= 4:
        base -= 3
    if practice_type == "medical_eye_care":
        base += 4
    elif practice_type == "mixed":
        base += 2
    elif practice_type == "refraction_only":
        base -= 4
    if optical_attached == True or optical_attached == "true":
        base += 2
    score = min(95, base)
    comment = f"{yrs}-yr {practice_type} practice; {od_count} OD(s); optical attached={optical_attached}. Annual exam + contact lens recurring revenue."
    return (score, comment)

def score_layer3(r):
    signals = r.get("signals", [])
    tell_keys = set()
    for s in signals:
        k = (s.get("signal_key") or "").lower()
        if any(t in k for t in ["stale","wayback","no_online","no_associate","sole","footer","no_portal","no_booking","review_flat","no_hiring","dated","reduced_hours","no_saturday","no_social","phone_only","old_school"]):
            tell_keys.add(k)
    n = len(tell_keys)
    if n == 0 and len(signals) > 2:
        n = 2
    if n >= 4:
        score = 78
    elif n >= 2:
        score = 60
    elif n == 1:
        score = 42
    else:
        score = 28
    has_successor = any("successor" in (s.get("signal_key") or "").lower() for s in signals)
    comment = f"{n} coasting tell(s). {'Successor-check live-fetch captured.' if has_successor else 'Successor-check live-fetch not completed.'}"
    return (score, comment)

def score_layer4(r):
    county = r.get("county","")
    practice_type = r.get("practice_type","unknown")
    base = {"Harris":83,"Dallas":83,"Tarrant":80,"Travis":80,"Williamson":74,"Bexar":78,"Collin":82,"Denton":78,"Fort Bend":80,"Montgomery":74,"Brazos":68,"Brazoria":72,"Comal":68,"Kendall":66,"Hays":70}.get(county, 65)
    if practice_type == "medical_eye_care":
        base += 4
    elif practice_type == "mixed":
        base += 1
    elif practice_type == "refraction_only":
        base -= 5
    score = min(95, base)
    comment = f"{county} County. MyEyeDr/Acuity/Keplr/AEG less aggressive than DSO consolidation in dental — solo $700K-$1.2M OD-owned practices still under-targeted."
    return (score, comment)

def assign_confidence(r, gate):
    if gate:
        if any(t in gate for t in ["platform","too_young","out_of_scope","misclassified","recent","retail","growth","build"]):
            return "high"
        return "medium"
    age_src = r.get("owner_age_source","unknown")
    owner = r.get("owner_name") or ""
    yrs = r.get("years_in_business") or 0
    if age_src == "ov65":
        return "high"
    if age_src in ("voter_dob","dmv"):
        return "high"
    if age_src in ("license_tenure_proxy","linkedin_grad","linkedin_tenure_proxy") and owner and yrs >= 20:
        return "medium"
    if owner and yrs >= 15:
        return "medium"
    return "low"

def assign_tier(final, L1, L3, conf, cap):
    if cap == "D_pass":
        return "D_pass"
    if cap == "C_watch":
        return "C_watch"
    if final < 45:
        return "D_pass"
    if final < 60:
        return "C_watch"
    if final < 78:
        return "B_forward"
    if L1 < 70 or L3 < 65 or conf == "low":
        return "B_forward"
    return "A_acquire_self"

scored = []
for r in rows:
    cap, gate = hard_gate(r)
    L1, L1c = score_layer1(r)
    L2, L2c = score_layer2(r)
    L3, L3c = score_layer3(r)
    L4, L4c = score_layer4(r)
    if cap == "D_pass":
        final = min(25, round(W["layer1"]*L1 + W["layer2"]*L2 + W["layer3"]*L3 + W["layer4"]*L4))
    else:
        final = round(W["layer1"]*L1 + W["layer2"]*L2 + W["layer3"]*L3 + W["layer4"]*L4)
    conf = assign_confidence(r, gate)
    tier = assign_tier(final, L1, L3, conf, cap)
    fc = []
    if gate: fc.append(f"GATE: {gate}.")
    fc.append(f"L1 {L1}/L2 {L2}/L3 {L3}/L4 {L4} → final {final}, tier {tier} (conf {conf}).")
    r.update({"layer1_base_rate":L1,"layer1_comment":L1c,"layer2_sellability":L2,"layer2_comment":L2c,"layer3_behavioral_trigger":L3,"layer3_comment":L3c,"layer4_market_pull":L4,"layer4_comment":L4c,"final_score":final,"final_tier":tier,"final_comment":" ".join(fc),"value_add_thesis":"","confidence":conf,"hard_gate_reason":gate})
    inputs = sum([bool(r.get("owner_name")), bool(r.get("owner_age_estimate")), bool(r.get("years_in_business")), bool(r.get("license_number")), bool(r.get("website")), bool(r.get("signals")), bool(r.get("entity_status") and r.get("entity_status")!="unknown"), bool(r.get("owner_homestead_address"))])
    r["data_completeness"] = round(inputs/8, 2)
    scored.append(r)

tier_order={"A_acquire_self":0,"B_forward":1,"C_watch":2,"D_pass":3}
scored.sort(key=lambda x:(tier_order.get(x["final_tier"],9), -x["final_score"]))
counts = Counter(r["final_tier"] for r in scored)
print(f"Tier counts: {dict(counts)}")
print()
print("Top B/A:")
for r in scored:
    if r["final_tier"] in ("A_acquire_self","B_forward"):
        print(f"  {r['final_tier']:18s} {r['final_score']:3d} L1={r['layer1_base_rate']} L3={r['layer3_behavioral_trigger']} conf={r['confidence']:6s} | {r.get('legal_name','?')[:45]:45s} ({r.get('city','?')})")

print()
print("D_pass:")
for r in scored:
    if r["final_tier"]=="D_pass":
        print(f"  {r.get('legal_name','?')[:45]:45s} | {r.get('hard_gate_reason','low_data')}")

with open(f"{DATA}/optometry_targets.json","w") as f:
    json.dump(scored, f, indent=2, default=str)

CSV_HEADER = ["legal_name","dba_name","city","county","zip","address","phone","website","owner_name","owner_age_estimate","owner_age_source","owner_tenure_years","years_in_business","provider_count_estimate","employee_count_estimate","is_distressed","distress_reasons","layer1_base_rate","layer1_comment","layer2_sellability","layer2_comment","layer3_behavioral_trigger","layer3_comment","layer4_market_pull","layer4_comment","final_score","final_tier","final_comment","value_add_thesis","confidence","data_completeness","practice_type"]
with open(f"{DATA}/optometry_targets.csv","w",newline="") as f:
    w = csv.writer(f)
    w.writerow(CSV_HEADER)
    for r in scored:
        row = []
        for k in CSV_HEADER:
            v = r.get(k, "")
            if k == "distress_reasons" and not isinstance(v, str):
                v = json.dumps(v)
            row.append(v)
        w.writerow(row)
print(f"\nWrote {DATA}/optometry_targets.json and .csv")
