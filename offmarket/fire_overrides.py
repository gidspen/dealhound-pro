#!/usr/bin/env python3
"""Apply orchestrator manual overrides to fire_targets.json after rule-based scoring.

These reflect Opus judgment on rows where sub-agent qualitative evidence
warrants tier promotion or demotion beyond what the rule-based scorer caught.
"""
import json
import csv

DATA = "/Users/gideonspencer/dealhound-pro/.claude/worktrees/fervent-kilby-9ed36a/offmarket/data"

with open(f"{DATA}/fire_targets.json") as f:
    rows = json.load(f)

# Index by legal_name
by_name = {r["legal_name"]: r for r in rows}


def update(name, **kwargs):
    if name in by_name:
        r = by_name[name]
        for k, v in kwargs.items():
            r[k] = v
        return True
    return False


# === DEMOTIONS ===

# Eagle Fire Extinguisher — Wright family BOUGHT from Massey in spring 2024 = succession completed = NOT exit-window
update(
    "Eagle Fire Extinguisher Company",
    final_tier="D_pass",
    final_score=22,
    hard_gate_reason="succession_completed: Wright family bought from Massey family spring 2024 — current owners are recent buyers in build-equity mode, not exit mode",
    final_comment="GATE: succession_completed (Brandon + Christina Wright bought from Massey family spring 2024). Recent-buyer profile = NOT exit-window candidate. D_pass.",
    value_add_thesis="N/A — recent ownership transition, current owners in equity-build phase.",
)

# === PROMOTIONS C → B ===

# Richardson Fire Equipment — Mark + Kathy Thomas, 38 yrs, sub-agent confirmed kids NOT in biz
# Strong qualitative succession-gap signal, multi-trade, Dallas County. Promote to B pending OV65.
update(
    "Richardson Fire Equipment",
    final_tier="B_forward",
    final_score=68,
    layer1_base_rate=72,
    layer1_comment="Mark Thomas (Founder/Owner/GM), age UNKNOWN but 38-yr business tenure as founder-operator suggests 60+; wife Kathy also active. Sub-agent batch 3 confirmed via website read that two grown children are NOT in the business — clean succession-gap. Needs HCAD homestead + OV65 lookup to confirm age via CAD direct (blocked this session).",
    layer3_behavioral_trigger=68,
    layer3_comment="3+ coasting tells: (1) two grown children explicitly NOT in business (succession gap, sub-agent batch 3 live-fetch); (2) ~6-person team for 38-yr multi-trade shop (Dallas multi-trade should scale larger); (3) ACR+ECR+HCR full license stack with no second-RME visible. Successor-check confirmed via direct team-page read. Live-fetch evidence captured.",
    final_comment="Mark + Kathy Thomas, ~60+, founded Richardson Fire Equipment 1988, multi-trade ACR/ECR/HCR; two grown kids NOT in the business per direct team-page read — classic succession-gap. Building presumed owned (Dallas Co — needs DCAD confirmation). 38 yrs in Dallas County; Pye-Barker / Impact Fire / Encore all actively bolting Dallas multi-trade. Tier B: forward to ETA community + flag for direct outreach if CAD confirms owner age >65.",
    value_add_thesis="Multi-trade shop in Dallas with full license stack (ACR/ECR/HCR) and a 38-yr family book of customers — modernization play: digital inspection reports via Inspect Point, customer portal, RMR upsell on existing fire-alarm install base, route optimization. EBITDA arbitrage realistic from estimated 15-18% (manual ops) to 22-25% in 18-24 months under modern field-service software + RMR push.",
    confidence="medium",
)

# Lone Star Fire Extinguisher Co. — Deborah Brantley sole owner-operator 33 yrs, family route business
update(
    "Lone Star Fire Extinguisher Co.",
    final_tier="B_forward",
    final_score=64,
    layer1_base_rate=68,
    layer1_comment="Deborah Brantley, 33-yr owner-operator since 1992; spouse Robin in ops; age UNKNOWN but 33-yr solo tenure as principal suggests 60+. No visible 2nd-gen successor on website or LinkedIn. Sub-agent batch 2 enrichment captured. Needs DCAD homestead + OV65 lookup for direct age confirmation.",
    layer3_behavioral_trigger=66,
    layer3_comment="Pure route-based extinguisher/recharge business — sub-trade L3 coasting tells: no online portal, no SMS scheduling, phone-only intake, no recent capex/fleet refresh visible. Sub-agent batch 2 found 'Yelp confirms route business' — minimal digital footprint = strong sub-trade coasting signal.",
    final_comment="Deborah Brantley, ~60+, runs Lone Star Fire Extinguisher in Mesquite (Dallas Co) since 1992; spouse Robin in ops; no 2nd-gen successor visible. Pure route-based extinguisher recharge — quintessential coasting solo-owner profile. Dallas County extinguisher-sub-trade is less consolidated than multi-trade but Pye-Barker has been bolt-on acquiring extinguisher routes specifically. Tier B: forward to ETA community + flag for direct outreach if DCAD confirms age 65+.",
    value_add_thesis="Route extinguisher businesses scale on density + recurring billing software. AI-powered route optimization + customer-portal modernization (Inspect Point, ServiceTrade) + RMR-style monthly billing on extinguisher service contracts could move EBITDA from estimated 15-18% to 22-28%. Cleanest M&A exit path: roll into a multi-trade Dallas platform or sell to Pye-Barker bolt-on team.",
    confidence="medium",
)

# === ALSO ADD value_add_thesis for the existing B-tier candidates ===

update(
    "Fire Safe Protection Services",
    value_add_thesis="Multi-trade Houston shop with healthcare-system anchor accounts + diversified license stack (alarms, sprinklers, hood, BDA/ERRC, nurse call, monitoring). Modernization levers: monitoring-RMR growth (current mix unclear, likely <30% — push toward 50%+); digital inspection reports for healthcare clients; rep+CSM expansion. McKinney exit-glide path with second-tier leadership team retention = clean 18-24 mo EBITDA path from estimated 18-20% to 24-27%. Strong Pye-Barker / Impact Fire bolt-on target post-modernization.",
)

update(
    "Lone Star Fire & First Aid",
    value_add_thesis="Solo San Antonio extinguisher route business — Anthony Sherwood ~39 yrs in. Sparse digital footprint = ripe for AI-front-desk + customer portal + RMR-style annual-billing modernization. Smaller deal ($500K-$800K rev band) makes this a high-ROIC search-fund target; alternatively, bolt-on to a Bexar Co multi-trade platform for cross-sell. 18-24 mo EBITDA improvement from estimated 15% to 22% via modern routing + retention plays.",
)

update(
    "Industrial Fire TX",
    value_add_thesis="81-yr Houston multi-trade with HCR kitchen-hood + ACR + extinguisher trifecta and trademark 'Serving Texas Since 1945' — institutional brand equity. Owner not publicly named (Phase 5 deep-dive priority: SOS filing + Comptroller). Reduced office hours (M-F 8:00-3:30) = classic owner-pullback signal. Modernization levers: digital inspection reports, healthcare/restaurant cross-sell, online quote capture. Conservative 18-24 mo EBITDA path 16% → 22%. Strong fit for Houston-PE-platform bolt-on.",
)

update(
    "Frontline Fire Protection, INC.",
    value_add_thesis="Nick Bartow, 30-yr Dallas multi-trade. Mid-size shop with regional Dallas-Fort Worth footprint. Modernization play: BuildOps / ServiceTrade adoption, customer portal, RMR billing on existing alarm-monitoring book. EBITDA improvement 17% → 22% over 18-24 mo. Owner age confirmation needed for direct A-tier promotion.",
)

update(
    "Cowboy Fire Equipment LLC",
    value_add_thesis="Larry + Diane Kindricks, second-generation route extinguisher business in Waxahachie (Ellis Co, DFW exurb) — 57-yr family business since 1969. Hotmail.com primary email = strong digital-staleness coasting tell. Pure-route economics with deep institutional customer relationships in DFW south corridor. Modernization: routing software, customer portal, RMR billing. Smaller deal ($400K-$700K rev band) fits search-fund or as Dallas-platform bolt-on. 18-24 mo EBITDA path 14% → 21%.",
)

update(
    "American Fire Systems, Inc.",
    value_add_thesis="Houston multi-trade with David Stone + Cody Huff leadership; 24 yrs. Mid-size shop with established Harris Co commercial book. Modernization play: monitoring-RMR push, digital inspection reports, BuildOps adoption. Owner-age and successor verification needed for tier promotion. EBITDA improvement 17% → 22% potential over 18-24 mo. Houston Pye-Barker / Impact Fire bolt-on candidate post-modernization.",
)

# Now write back
with open(f"{DATA}/fire_targets.json", "w") as f:
    json.dump(list(by_name.values()), f, indent=2, default=str)

# Re-emit CSV with overrides
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
rows_out = list(by_name.values())
rows_out.sort(key=lambda r: ({"A_acquire_self":0,"B_forward":1,"C_watch":2,"D_pass":3}[r["final_tier"]], -r["final_score"]))
with open(f"{DATA}/fire_targets.csv", "w", newline="") as f:
    w = csv.writer(f)
    w.writerow(CSV_HEADER)
    for r in rows_out:
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

# Report new tier counts
from collections import Counter
counts = Counter(r["final_tier"] for r in rows_out)
print(f"After overrides: {dict(counts)}")
print()
print("B_forward candidates (ranked):")
for r in [x for x in rows_out if x["final_tier"]=="B_forward"]:
    print(f"  {r['final_score']:3d} | {r['legal_name'][:50]:50s} {r['city']:15s} {r['county']:10s} conf={r['confidence']}")
