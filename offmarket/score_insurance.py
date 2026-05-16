#!/usr/bin/env python3
"""Score the Insurance vertical run."""
import json, csv
from collections import defaultdict, Counter
from datetime import datetime, timezone

W = {"layer1": 0.30, "layer2": 0.25, "layer3": 0.30, "layer4": 0.15}
DATA = "/Users/gideonspencer/dealhound-pro/.claude/worktrees/fervent-kilby-9ed36a/offmarket/data"

with open(f"{DATA}/insurance_targets.json") as f:
    rows = json.load(f)

# Dedupe (none expected for insurance per inspection)
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
                if base.get(k2) in (None, "", "unknown") and v not in (None, "", "unknown"):
                    base[k2] = v
        merged.append(base)
rows = merged

# Hard-gate dictionaries
SUCCESSION_IN_PLACE = {
    "Pasadena Insurance Agency, Inc.": "3rd-gen Karkowsky brothers actively operating — succession path locked",
    "Dean & Draper Insurance Agency": "Bob → Kyle Dean succession executed — multi-partner structure",
    "Gibb Agency Insurance Services": "Gilbert → Susana Gibb father-daughter succession executed",
    "Independent Insurance Center": "Sales family multi-gen: Wade + Blake + sons Jake (2018) + Conner (2021)",
    "David Ison & Sons Insurance Agency": "Multi-gen: David founder → Stephen CEO + Mark VP + Jake 3rd gen",
    "David Ison Insurance": "Multi-gen: David founder → Stephen CEO + Mark VP + Jake 3rd gen",
    "Britton & Britton Insurance": "Bob Britton → Riley Britton succession executed",
    "Bosworth Special Risk": "Cambridge Bosworth in training as 2nd gen",
    "Dreiss Insurance Agency": "Denton Dreiss in training as 2nd gen",
    "Central Insurance Agency": "Active Raper brothers succession (Scott Raper b. 1962 + Tyler Raper 2nd gen)",
    "Greater Austin Insurance Agency": "Bob + Jeff Husk active father-son partnership",
    "Threlkeld & Company Insurance Agency": "Dustin Glover (President, ~40-42) clear heir-apparent to Todd Threlkeld",
    "Insurance Over Texas": "Succession just completed — Dale Jackson → Martha Juarez",
    "Champion Commercial Insurance": "Just merged with Wood-Wilson April 2023",
}

TOO_LARGE = {
    "Texas Insurance Agency (TIA)": "700+ employees, 40+ locations — aggregator/platform-scale",
    "Watkins Insurance Group": "165 emp / $93M rev / 50-state — too large + active CEO succession",
    "Kevin Lee Company": "14-state operation — likely above off-market acquirer-self threshold",
    "Rock Insurance": "Self-described 'one of TX's largest' — above target",
    "Allen Thomas Group": "Akron OH HQ multi-state — Houston is regional branch",
}

ACQUIRER_ROLE = {
    "Texan Insurance": "Active acquirer — 5 acquisitions 2020-2025, dedicated M&A landing page",
}

PLATFORM_OR_CAPTIVE = {
    "Lawhorn & Moore Insurance Brokers": "Goosehead Insurance franchise",
    "TWFG Insurance Services (The Woodlands HQ; Tomball branch)": "TWFG franchise model",
    "Chande Agency": "GEICO Local Agent program (captive)",
    "Schuder Insurance Agency": "Crystal Schuder also Farmers captive agent — dual appointment",
}

TOO_YOUNG = {
    "Schuder Insurance Agency": "Only 7 yrs",  # also captive — double-disqualified
    "Salgado Insurance Agency": "Only 13-15 yrs",
    "Texan's Choice (Roger Haines)": "Only 14-yr agency tenure",
}

NOT_SELLING = {
    "Brooks Cannon Insurance Agency": "Founder career started 2000, mid-40s",
    "Alliance Insurance Agency (Frisco)": "Growth mode — expanding into AZ",
    "Tom Shallue Insurance Agency": "Mid-career owner, not exit-mode",
    "Brent Hagen Insurance Agency": "Mid-career owner",
    "Josh Smith Insurance Agency": "Mid-career owner",
    "Joe Race Insurance Agency": "Mid-career owner",
}

def hard_gate(r):
    pac = r.get("platform_affiliation_check", "independent")
    name = r.get("legal_name", "")
    if "platform_subsidiary" in pac or "captive" in pac:
        return ("D_pass", f"platform_or_captive: {pac}")
    if name in PLATFORM_OR_CAPTIVE:
        return ("D_pass", f"platform_or_captive: {PLATFORM_OR_CAPTIVE[name]}")
    if r.get("is_distressed"):
        return ("D_pass", "distressed_hard_gate")
    yrs = r.get("years_in_business") or 0
    if yrs and yrs < 5:
        return ("D_pass", "too_young_under_5_yrs")
    if name in TOO_YOUNG:
        return ("D_pass", f"too_young: {TOO_YOUNG[name]}")
    if name in TOO_LARGE:
        return ("D_pass", f"too_large: {TOO_LARGE[name]}")
    if name in ACQUIRER_ROLE:
        return ("D_pass", f"acquirer_role: {ACQUIRER_ROLE[name]}")
    if name in NOT_SELLING:
        return ("D_pass", f"not_selling_mid_career: {NOT_SELLING[name]}")
    if name in SUCCESSION_IN_PLACE:
        return ("C_watch", f"successor_in_place: {SUCCESSION_IN_PLACE[name]}")
    if r.get("recent_acquisition"):
        return ("D_pass", "recent_acquisition_post_spine")
    if pac == "uncertain":
        return ("C_watch", "platform_affiliation_uncertain")
    if "internal_succession" in pac or "3rd_generation" in pac or "recent_succession" in pac or "recent_merger" in pac:
        return ("C_watch", f"succession_signal: {pac}")
    if "aggressive_acquirer" in pac:
        return ("D_pass", f"acquirer_role: {pac}")
    if "large" in pac.lower() or "out_of_state" in pac:
        return ("D_pass", f"too_large_or_oos: {pac}")
    if "partnership" in pac.lower():
        return ("C_watch", f"partnership_internal_succession_signal")
    return (None, None)

def score_layer1(r):
    age = r.get("owner_age_estimate")
    age_src = r.get("owner_age_source", "unknown")
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
        comment = f"{owner}, age UNKNOWN; {yrs}-yr agency tenure — license-tenure proxy only, no CAD/OV65 this pass."
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
    age_src_label = {"ov65":"OV65 verified","voter_dob":"voter DOB","dmv":"DMV","license_tenure_proxy":"license-tenure proxy","linkedin_grad":"LinkedIn grad","website_self_report":"website self-report","public_records_dob":"public records DOB"}.get(age_src, age_src)
    comment = f"{owner}, est. age ~{age} ({age_src_label}); {yrs}-yr agency tenure."
    return (score, comment)

def score_layer2(r):
    yrs = r.get("years_in_business") or 0
    lines = r.get("lines_of_business", "unknown")
    producer = r.get("producer_count_estimate") or 1
    carriers = r.get("carriers_visible") or []
    has_carriers = len(carriers) >= 3
    if yrs < 5:
        return (30, f"Only {yrs} yrs in business — fails 5-yr gate.")
    if yrs >= 30:
        base = 84
    elif yrs >= 20:
        base = 78
    elif yrs >= 10:
        base = 68
    else:
        base = 58
    if lines in ("commercial_only","mixed"):
        base += 4  # commercial-lines books retain better
    elif lines == "personal_only":
        base -= 4
    if has_carriers:
        base += 3
    score = min(95, base)
    comment = f"{yrs}-yr {lines} agency; {len(carriers)} carriers visible. Renewal-commission recurring revenue is the L2 ceiling for insurance."
    return (score, comment)

def score_layer3(r):
    signals = r.get("signals", [])
    tell_keys = set()
    for s in signals:
        k = (s.get("signal_key") or "").lower()
        if any(t in k for t in ["stale","wayback","no_online","no_associate","sole_producer","footer_year","no_portal","no_booking","review_flat","no_hiring","dated","no_social","phone_only","no_quote","single_producer"]):
            tell_keys.add(k)
    n = len(tell_keys)
    if n == 0 and len(signals) > 2:
        n = 2  # fall back to general signal count
    if n >= 4:
        score = 78
    elif n >= 2:
        score = 60
    elif n == 1:
        score = 42
    else:
        score = 28
    has_successor_check = any("successor" in (s.get("signal_key") or "").lower() for s in signals)
    comment = f"{n} coasting tell(s). {'Successor-check live-fetch captured.' if has_successor_check else 'Successor-check live-fetch not completed — caps confidence at low/medium.'}"
    return (score, comment)

def score_layer4(r):
    county = r.get("county", "")
    lines = r.get("lines_of_business", "unknown")
    base = {
        "Harris":85,"Dallas":85,"Tarrant":85,"Travis":83,"Williamson":78,
        "Bexar":80,"Collin":82,"Denton":80,"Fort Bend":80,"Montgomery":78,
        "Comal":72,"Kendall":68,"Smith":65,
    }.get(county, 65)
    if lines in ("commercial_only","mixed"):
        base += 4
    elif lines == "personal_only":
        base -= 3
    score = min(95, base)
    comment = f"{county} County — insurance brokerage is the most M&A-active vertical (700+ deals/yr nationally). Higginbotham + Hub + Acrisure + AssuredPartners + Inszone all bolt-on active in TX metros."
    return (score, comment)

def assign_confidence(r, gate):
    if gate:
        if any(t in gate for t in ["platform","captive","too_young","too_large","acquirer","not_selling"]):
            return "high"
        return "medium"
    age_src = r.get("owner_age_source", "unknown")
    yrs = r.get("years_in_business") or 0
    owner = r.get("owner_name") or ""
    if age_src == "ov65":
        return "high"
    if age_src == "public_records_dob":
        return "high"
    if age_src in ("voter_dob","dmv","obituary_match"):
        return "high"
    if age_src == "license_tenure_proxy" and owner and yrs >= 25:
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
    r["layer1_base_rate"]=L1; r["layer1_comment"]=L1c
    r["layer2_sellability"]=L2; r["layer2_comment"]=L2c
    r["layer3_behavioral_trigger"]=L3; r["layer3_comment"]=L3c
    r["layer4_market_pull"]=L4; r["layer4_comment"]=L4c
    r["final_score"]=final; r["final_tier"]=tier; r["final_comment"]=" ".join(fc)
    r["value_add_thesis"] = ""
    r["confidence"]=conf
    inputs = sum([bool(r.get("owner_name")), bool(r.get("owner_age_estimate")), bool(r.get("years_in_business")), bool(r.get("license_number")), bool(r.get("website")), bool(r.get("signals")), bool(r.get("entity_status") and r.get("entity_status")!="unknown"), bool(r.get("owner_homestead_address"))])
    r["data_completeness"]=round(inputs/8,2)
    r["hard_gate_reason"]=gate
    scored.append(r)

tier_order = {"A_acquire_self":0,"B_forward":1,"C_watch":2,"D_pass":3}
scored.sort(key=lambda x:(tier_order.get(x["final_tier"],9), -x["final_score"]))
counts = Counter(r["final_tier"] for r in scored)
print(f"Tier counts: {dict(counts)}")
print()
print("Top B/A:")
for r in scored:
    if r["final_tier"] in ("A_acquire_self","B_forward"):
        print(f"  {r['final_tier']:18s} {r['final_score']:3d} L1={r['layer1_base_rate']} L3={r['layer3_behavioral_trigger']} conf={r['confidence']:6s} | {r.get('legal_name','?')[:45]} ({r.get('city','?')})")
print()
print("D_pass reasons summary:")
for r in scored:
    if r["final_tier"]=="D_pass":
        print(f"  {r.get('legal_name','?')[:45]:45s} | {r.get('hard_gate_reason','low_data')}")

with open(f"{DATA}/insurance_targets.json","w") as f:
    json.dump(scored, f, indent=2, default=str)

CSV_HEADER = ["legal_name","dba_name","city","county","zip","address","phone","website","owner_name","owner_age_estimate","owner_age_source","owner_tenure_years","years_in_business","provider_count_estimate","employee_count_estimate","is_distressed","distress_reasons","layer1_base_rate","layer1_comment","layer2_sellability","layer2_comment","layer3_behavioral_trigger","layer3_comment","layer4_market_pull","layer4_comment","final_score","final_tier","final_comment","value_add_thesis","confidence","data_completeness","lines_of_business"]
with open(f"{DATA}/insurance_targets.csv","w",newline="") as f:
    w = csv.writer(f)
    w.writerow(CSV_HEADER)
    for r in scored:
        w.writerow([r.get(k,"") if k != "is_distressed" else r.get(k,False) for k in CSV_HEADER if k != "provider_count_estimate"] + [r.get("producer_count_estimate","")])

print(f"\nWrote {DATA}/insurance_targets.json and .csv")
