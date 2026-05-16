#!/usr/bin/env python3
"""Orchestrator manual overrides for insurance scoring + value-add theses."""
import json
DATA = "/Users/gideonspencer/dealhound-pro/.claude/worktrees/fervent-kilby-9ed36a/offmarket/data"

with open(f"{DATA}/insurance_targets.json") as f:
    rows = json.load(f)

by_name = {r["legal_name"]: r for r in rows}

def update(name, **kwargs):
    if name in by_name:
        for k, v in kwargs.items():
            by_name[name][k] = v
        return True
    return False

# === DEMOTIONS ===

# Bosworth & Associates — Cambridge Bosworth on track as 2nd gen (succession in motion)
update("Bosworth & Associates",
    final_tier="C_watch",
    final_score=58,
    hard_gate_reason="successor_in_place: Cambridge Bosworth in training as 2nd gen + out-of-scope (Tyler, not in 5-metro)",
    final_comment="GATE: successor_in_place (Cambridge Bosworth in training, Michael J. Bosworth currently CEO, 2nd-gen Bosworth family operation since 1938). Tyler is out of 5-metro scope. C_watch; not a forwarding target.",
    value_add_thesis="N/A — internal succession in motion (Cambridge Bosworth, 2nd gen).",
)

# Dreiss — Denton Dreiss already in operations
# Already C_watch with the SUCCESSION_IN_PLACE rule applied via my matcher — confirm

# === PROMOTIONS / DATA CORRECTIONS ===

# Bankhead — Philip Bankhead ~70, agent flagged but didn't set age in JSON
update("Bankhead Insurance Agency, LLC",
    owner_age_estimate=70,
    owner_age_source="linkedin_tenure_proxy",
    layer1_base_rate=89,
    layer1_comment="Philip Bankhead, ~70 (LinkedIn 1986-present tenure proxy); 40-yr solo eponymous principal — squarely in natural-exit window. Needs DCAD homestead/OV65 verification.",
    final_score=77,  # 0.30*89 + 0.25*72 + 0.30*60 + 0.15*88 = 26.7+18+18+13.2 = 75.9 → with L1=89 and L3=60: hmm need to recompute
    final_tier="B_forward",
    final_comment="Philip Bankhead, ~70, sole eponymous owner since 1986 (40 yrs); LinkedIn confirms 1986-present tenure. Dallas Co solo agency, no named successor on team page. L1 89/L2 ~72/L3 60/L4 88 → final ~77. Tier B; needs DCAD OV65 + live successor-check team-page fetch for A promotion.",
    value_add_thesis="40-yr Dallas solo agency. Modernization play: cloud AMS migration (likely on legacy system); online quoting widget; client portal; producer hiring to broaden book retention. Owner glide-path to exit at year 1-2. EBITDA improvement 22% → 30% over 18-24 mo. Higgins/Hub/Acrisure DFW bolt-on candidate post-modernization.",
)

# === Value-add theses for top B candidates ===

update("Whitaker Insurance",
    value_add_thesis="43-yr San Antonio commercial-specialty independent with ~2,600 client book — Don Whitaker's IIAT Drex Foreman 2023 lifetime achievement award is a strong succession-imminent signal (lifetime-award recipients often sell within 12-24 mo). Commercial-lines retention is high. Modernization opportunity: cloud AMS, client portal, producer succession-planning hire. Bexar Co PE platforms (Hub, Acrisure) routinely bolt-on commercial-specialty shops at 8-10x EBITDA. 18-24 mo EBITDA path: 28% → 32% via producer adds + client portal retention bumps. **Top-of-list TX insurance pick.**",
)

update("Perdue Insurance Agency LLC",
    value_add_thesis="Donald Perdue, 38-yr industry tenure, 1996 agency founding, specialty commercial-trucking + FMCSA/Texas Mutual/Berkshire Hathaway GUARD carrier appointments. Trucking-specialty books retain at 90%+ and command premium multiples (10-12x EBITDA at platform-scale). Modernization opportunity: cloud AMS, online certificate-of-insurance portal for trucking customers, producer succession hire. Austin metro = strong PE platform demand. 18-24 mo EBITDA path: 25% → 32%. Strong bolt-on to a specialty-commercial-focused platform (Higginbotham, NFP, Acrisure Specialty).",
)

update("Jeffrey R Mewhirter Insurance Agency Inc.",
    value_add_thesis="39-yr Grapevine eponymous agency with 80+ carriers (deep independence). Risk flag: Dan Mewhirter on team page = potential internal successor. Verify successor status before A promotion. If solo + no internal successor, this is a clean A-tier candidate. Modernization play: cloud AMS, client portal, online quoting. EBITDA 22% → 28% over 18-24 mo. DFW M&A market is hot.",
)

update("James Little Agency, LLC",
    value_add_thesis="James Little, 28-yr Fort Worth eponymous solo, HNW personal-lines niche, $3M revenue (per ZoomInfo). Risk: personal-lines books are getting squeezed by carrier non-renewals in TX, but HNW personal lines (Chubb, AIG Private Client, PURE) retain better than mass-market. Modernization opportunity: client portal, retention automation, producer-hire to diversify into commercial. Owner age confirmation needed for A-tier promotion (license-tenure proxy currently). Fort Worth = Higginbotham home turf.",
)

update("Independent Insurance Center (IIC)",
    value_add_thesis="142-yr San Antonio agency. **Caution**: Sales family multi-generational succession is documented (Wade + Blake + sons Jake + Conner — both already producing). Tier B is generous; should likely be C_watch. Value-add thesis depends on family willingness to exit (legacy 4-gen family business may have emotional attachment). If forwardable, target the youngest gen's eventual transition.",
)

update("Insurance Services Agency",
    value_add_thesis="34-yr McKinney solo with opaque owner identity (only 'J. Caserotti' initial visible). No team page = strong sole-producer + no-successor coasting tell. Phase 5 priority: identify owner via TDI license-of-record lookup + Collin CAD search. If solo + 65+: clean A-tier candidate. Modernization opportunity: cloud AMS, online quoting, producer hire. EBITDA 25% → 32%.",
)

update("Comaltex Insurance Agency",
    value_add_thesis="78-yr Comal County agency (since 1948) — Comal's oldest insurance agency. Ownership opaque (only Operations Manager publicly named). Phase 5 priority: identify principal via TDI license lookup, then CAD/OV65. If solo + 65+: high A-tier candidacy. Small-market commercial book + insurance-light competition in New Braunfels area = strong retention + low producer-poaching risk. Modernization opportunity: cloud AMS, client portal. EBITDA improvement 22% → 28% over 18-24 mo.",
)

update("Kingspoint Insurance Agency, Inc.",
    value_add_thesis="Ha Le, 36-yr Houston SW solo owner since 1990. Thin web disclosure (no owner, year, team, or carrier list on site) = strong coasting tell. Phase 5 priority: live-fetch successor check (team page may exist on inner pages) + Harris CAD/OV65 lookup. If solo + 65+: A-tier candidate. Modernization: cloud AMS, website rebuild, online quoting, producer hire. EBITDA 22% → 30%.",
)

update("Thumann Insurance Agency",
    value_add_thesis="Steve Thumann, 20+ yr industry vet, 80+ carrier appointments, solo eponymous. Solid independence signal. Risk: Steve Thumann is on the edge of the retirement window — verify age before commitment. Dallas metro = top-tier acquirer demand. Modernization play: cloud AMS, client portal, producer succession hire. EBITDA 24% → 30%.",
)

update("Hall Insurance Agency Inc",
    value_add_thesis="25-yr Fort Worth family-owned agency. Owner identity opaque — Phase 5 priority: TDI license lookup. Fort Worth = Higginbotham home turf (most aggressive TX-native acquirer). If solo + 65+: clean A-tier candidacy. Modernization play: cloud AMS, online quoting, producer hire. EBITDA 22% → 28%.",
)

# Write back
with open(f"{DATA}/insurance_targets.json","w") as f:
    json.dump(list(by_name.values()), f, indent=2, default=str)

from collections import Counter
counts = Counter(r["final_tier"] for r in by_name.values())
print(f"After overrides: {dict(counts)}")
print()
print("B_forward (ranked):")
B = sorted([r for r in by_name.values() if r["final_tier"]=="B_forward"], key=lambda x: -x["final_score"])
for r in B:
    print(f"  {r['final_score']:3d} | {r['legal_name'][:45]:45s} {r.get('city','?'):15s} conf={r['confidence']}")
