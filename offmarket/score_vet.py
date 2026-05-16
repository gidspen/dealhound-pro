#!/usr/bin/env python3
"""Score the Vet vertical run."""
import json, csv
from collections import defaultdict, Counter
W = {"layer1":0.30,"layer2":0.25,"layer3":0.30,"layer4":0.15}
DATA = "/Users/gideonspencer/dealhound-pro/.claude/worktrees/fervent-kilby-9ed36a/offmarket/data"

with open(f"{DATA}/vet_targets.json") as f:
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

SUCCESSION_IN_PLACE = {
    "Tomball Animal Hospital": "2nd-gen Foltin → Bruhn handoff already executed (Dr. Jana Foltin Bruhn + husband Andrew Bruhn running)",
    "Memorial-610 Hospital for Animals": "Pittenger ~56 + 4 DVMs + 3 ABVP — too young + active growth, not coasting",
    "Terrell Heights Veterinary Hospital": "Dr. LaBrie buying in from Dr. Kothmann — succession in motion",
    "Central Texas Animal Hospital": "Neans → Smallwood succession executed ~2019",
    "Animal Hospital of Georgetown": "Breen → Gardial succession executed Jan 2016",
    "Hill Country Animal Hospital": "Founder Peterson 27yrs + 6 DVMs — internal successor likely",
    "Walnut Vision": "DeShaw father-son succession in place",
}

TOO_YOUNG = {
    "Founders Animal Hospital": "Opened June 2025 — < 1 yr tenure",
    "Northwest Animal Hospital": "O'Bannion bought 2018 (8-yr tenure), age ~40",
    "Cy-Fair Animal Hospital": "Founded 2013 by Dr. Aubrey Ross, growth-stage",
    "Abrams Royal Animal Clinic": "Dr. Kyle Smith bought 2018, ~40",
    "Guilbeau Station Animal Hospital": "Independent transition to Dr. Kretzschmar 2025 — 1-yr tenure",
    "Bedford Oaks Family Vet": "Recent ownership transition post-Dr. Rowe; Dr. Manzey joined Feb 2024",
}

TOO_LARGE = {
    "Atascocita Animal Hospital": "6 DVMs — pushes to middle-market",
}

OUT_OF_SCOPE = {
    "Mission Veterinary Hospital": "Spine geo error — Mission TX 78572 (Rio Grande Valley), not Travis/Austin",
}

PLATFORM_OR_PRIOR_TRANSITION = {
    "Spring Creek Animal Hospital": "Acquired Nov 2021 by People, Pets & Vets",
    "North Dallas Veterinary Hospital": "Southern Veterinary Partners affiliated",
    "Country Brook Animal Hospital": "Acquired April 2020 by Innovetive Petcare",
    "South Meadow Animal Clinic": "VetCor acquired Aug 2022",
    "Animal Healthcare Clinic of Southlake": "NVA-owned",
    "Dodd Animal Hospital": "SVP acquired 2019",
    "Babcock Hills Veterinary Hospital, P.C.": "Lakefield Veterinary Group subsidiary",
    "Animal Medical Center of Austin": "Innovetive Petcare subsidiary",
    "Westlake Animal Hospital": "Thrive Pet Healthcare subsidiary (confirmed 301 redirect)",
    "Mansfield Animal Clinic": "Non-DVM owner (Robert Cannon) — suggests prior acquisition",
}

def hard_gate(r):
    name = r.get("legal_name","")
    pac = r.get("platform_affiliation_check","independent")
    if pac == "platform_subsidiary" or pac == "consolidator":
        return ("D_pass", f"platform: {pac}")
    if name in PLATFORM_OR_PRIOR_TRANSITION:
        return ("D_pass", f"platform_or_prior_transition: {PLATFORM_OR_PRIOR_TRANSITION[name]}")
    if r.get("recent_acquisition"):
        return ("D_pass", "recent_acquisition_post_spine")
    if r.get("is_distressed"):
        return ("D_pass", "distressed_hard_gate")
    yrs = r.get("years_in_business") or 0
    if yrs and yrs < 5:
        return ("D_pass", "too_young_under_5_yrs")
    if name in TOO_YOUNG:
        return ("D_pass", f"too_young: {TOO_YOUNG[name]}")
    if name in OUT_OF_SCOPE:
        return ("D_pass", f"out_of_scope: {OUT_OF_SCOPE[name]}")
    if name in TOO_LARGE:
        return ("C_watch", f"too_large_for_solo: {TOO_LARGE[name]}")
    if name in SUCCESSION_IN_PLACE:
        return ("C_watch", f"successor_in_place: {SUCCESSION_IN_PLACE[name]}")
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
        comment = f"{owner}, age UNKNOWN; {yrs}-yr practice tenure proxy only — needs CAD/OV65 verification."
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
    dvm_count = r.get("provider_count_estimate") or 1
    practice_type = r.get("practice_type","unknown")
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
    if dvm_count >= 4:
        base -= 3
    if practice_type == "small_animal":
        base += 3
    elif practice_type == "mixed_animal":
        base += 0
    elif practice_type in ("equine","exotic","specialty"):
        base -= 5
    score = min(95, base)
    comment = f"{yrs}-yr {practice_type} practice; {dvm_count} DVM(s). Vet wellness-plan + preventive-care recurring revenue."
    return (score, comment)

def score_layer3(r):
    signals = r.get("signals", [])
    tell_keys = set()
    for s in signals:
        k = (s.get("signal_key") or "").lower()
        if any(t in k for t in ["stale","wayback","no_online","no_associate","sole","footer","no_portal","no_booking","review_flat","no_hiring","dated","reduced_hours","no_saturday","no_social","phone_only"]):
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
    base = {"Harris":83,"Dallas":82,"Tarrant":80,"Travis":78,"Williamson":74,"Bexar":78,"Collin":80,"Denton":78,"Fort Bend":78,"Montgomery":74,"Comal":68,"Kendall":66,"Hays":72}.get(county, 65)
    if practice_type == "small_animal":
        base += 3
    elif practice_type == "mixed_animal":
        base -= 2
    elif practice_type in ("equine","exotic"):
        base -= 5
    score = min(95, base)
    comment = f"{county} County. Mars/NVA/Innovetive/Lakefield/PetVet active in TX metros, but mostly target $1.5M+ practices — solo-DVM $700K-$1.2M small-animal still under-targeted."
    return (score, comment)

def assign_confidence(r, gate):
    if gate:
        if any(t in gate for t in ["platform","too_young","too_large","out_of_scope","recent"]):
            return "high"
        return "medium"
    age_src = r.get("owner_age_source","unknown")
    owner = r.get("owner_name") or ""
    yrs = r.get("years_in_business") or 0
    if age_src == "ov65":
        return "high"
    if age_src in ("voter_dob","dmv","obituary_match"):
        return "high"
    if age_src in ("license_tenure_proxy","linkedin_grad") and owner and yrs >= 20:
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

with open(f"{DATA}/vet_targets.json","w") as f:
    json.dump(scored, f, indent=2, default=str)

CSV_HEADER = ["legal_name","dba_name","city","county","zip","address","phone","website","owner_name","owner_age_estimate","owner_age_source","owner_tenure_years","years_in_business","provider_count_estimate","employee_count_estimate","is_distressed","distress_reasons","layer1_base_rate","layer1_comment","layer2_sellability","layer2_comment","layer3_behavioral_trigger","layer3_comment","layer4_market_pull","layer4_comment","final_score","final_tier","final_comment","value_add_thesis","confidence","data_completeness","practice_type"]
with open(f"{DATA}/vet_targets.csv","w",newline="") as f:
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
print(f"\nWrote {DATA}/vet_targets.json and .csv")
