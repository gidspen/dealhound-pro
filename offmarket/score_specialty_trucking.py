"""Score specialty trucking enrichment batches → targets JSON + CSV.

4-layer canonical model + trucking-specific overrides:
- L1 (0.30): Owner age band + tenure.
- L2 (0.25): Sellability — fleet 10-50 ideal SBA-financeable. Specialty niche moats.
- L3 (0.30): Coasting tells (pre-2018 site, no portal, no telematics, etc.).
- L4 (0.15): Market pull — Houston (petrochem) +5, Permian +5, Eagle Ford / South TX +3, Panhandle +3.

Hard gates per canonical scoring template + trucking-specific exclusions
(fleet >50 → cap C, fleet <10 → cap C, out-of-state HQ → drop, brokerage → drop,
inactive SAFER → distressed, internal succession in place → cap C).
"""

import csv
import json
import os
from pathlib import Path

DATA_DIR = Path(__file__).parent / "data"
SCORE_RUN_ID = "60142bff-46df-4b25-af71-e986ba07e8b8"
VERTICAL = "specialty_trucking"
NAICS = "484220"

BATCH_PATHS = [
    DATA_DIR / "specialty_trucking_enrich_batch_1.json",
    DATA_DIR / "specialty_trucking_enrich_batch_2.json",
]
OUT_JSON = DATA_DIR / "specialty_trucking_targets.json"
OUT_CSV = DATA_DIR / "specialty_trucking_targets.csv"


# Per-business scoring overrides, keyed by spine_index. This is the analyst layer
# — synthesizing the 4-layer model with the enrichment notes + exclusions from
# the orchestrator brief.
SCORES = {
    # ---- batch 1 ----
    0: {  # Texas Chrome Transport — 15yr, frac sand contraction 200→41 trucks
        "owner_age_estimate": None,
        "owner_age_source": "unverified_no_named_principal",
        "owner_tenure_years": 15,
        "L1": 30, "L1c": "Founder unverified; family-owned language hints at aging cohort but no named principal. 15-yr tenure (Texas Chrome only). Score reflects unverified owner age + sub-25yr tenure band.",
        "L2": 50, "L2c": "Fleet 41 trucks (target band). Frac sand specialty. 74% fleet contraction 2024-2025 (200→41) is either distress or active wind-down — depresses sellability score until verified.",
        "L3": 70, "L3c": "Massive fleet contraction is dominant coasting/distress signal. No telematics platforms named; no online quote portal; phone-forward intake; small-town Atascosa County HQ. 5+ tells.",
        "L4": 75, "L4c": "Eagle Ford frac sand → +3 South TX sub-market nudge, +5 oilfield demand. Atascosa County small-town HQ caps premium.",
        "confidence": "low", "thesis": "Contraction-driven motivated seller IF not distressed. SBA-financeable at current 41-truck scale. Operational lever: telematics + customer mix diversification beyond pure frac sand. Verify Comptroller for entity status + named principal before A-tier promotion.",
    },
    1: {  # Palletized Trucking — 57yr Houston heavy-haul
        "owner_age_estimate": 70,
        "owner_age_source": "career_tenure_proxy_57yr_founding_family",
        "owner_tenure_years": 57,
        "L1": 85, "L1c": "Family-owned since 1969; founder cohort estimated ~70+. 57yr tenure → high natural-exit probability. No named successor yet visible.",
        "L2": 75, "L2c": "Heavy-haul / project cargo / oilfield rig moves. 300+ trailer pool (asset base) + company tractors implied. Niche petrochem corridor customer base = defensible recurring revenue but power-unit count unverified.",
        "L3": 80, "L3c": "57yr generational family ops, Houston Heights pre-1970 industrial corridor address, USDOT not on landing page, no online quote portal, phone-forward 713-225 exchange. 5+ tells.",
        "L4": 90, "L4c": "Houston (petrochem hauling) +5 nudge. Inner-loop Ship Channel proximity, project cargo demand evergreen.",
        "confidence": "medium", "thesis": "Multi-generational Houston heavy-hauler with defensible Ship Channel / oilfield niche. Lever: operational systemization (TMS, route optimization, dispatch software). SBA-financeable if power-unit count lands 10-50. Successor verification required before A-tier — verify via Comptroller + LinkedIn dig.",
    },
    2: {  # Basse Truck Line — 97yr SA border hazmat
        "owner_age_estimate": None,
        "owner_age_source": "unverified_likely_3rd_4th_generation",
        "owner_tenure_years": 97,
        "L1": 70, "L1c": "97yr tenure under Basse family — likely 3rd/4th generation operator now. Without named principal, age band uncertain but multi-generational succession question is the dominant signal.",
        "L2": 78, "L2c": "Pre-1950 ICC authority (MC-011603). Hazmat + border-region niche = defensible moat. SA/Del Rio/Laredo/Eagle Pass footprint. Power-unit count unverified.",
        "L3": 75, "L3c": "Mid-2000s SEO domain format, East Side SA pre-1980 industrial corridor, family-owned 97yr, hazmat generalist legacy carrier. Verified low MC# is a coasting/legacy signal. 5 tells.",
        "L4": 85, "L4c": "SA + South TX border corridor. Cross-border + hazmat = high barrier. Not Houston/Permian top-3 but secondary metro w/ niche moat.",
        "confidence": "medium", "thesis": "Texas trucking heritage carrier (97yr, MC# under 12K). Generational inflection-point candidate. Lever: hazmat-pricing tightening + cross-border digitization. SBA-financeable only if power-unit count is 10-50 — verify SAFER first.",
    },
    3: {  # McLo HotShot — 13yr Permian
        "owner_age_estimate": None,
        "owner_age_source": "unverified",
        "owner_tenure_years": 13,
        "L1": 25, "L1c": "13yr tenure below 25yr A-tier band. No owner age or named principal verified.",
        "L2": 35, "L2c": "Hot shot owner-operator format. No USDOT or fleet count. Below SBA-financeable threshold likely.",
        "L3": 30, "L3c": "Single-basin Permian focus; otherwise low coasting tells visible. 13yr tenure too short for classic coasting profile.",
        "L4": 78, "L4c": "Permian (oil services) +5 nudge. Odessa HQ.",
        "confidence": "low", "thesis": "C-tier — too young + insufficient data + owner-operator scale unsuitable for SBA. Defer until tenure + fleet expand.",
    },
    4: {  # Hotshot Texas (Joe Burns) — 52yr solo
        "owner_age_estimate": 75,
        "owner_age_source": "founder_named_1974_plus_minimum_23yr_at_founding",
        "owner_tenure_years": 52,
        "L1": 92, "L1c": "Joe Burns named founder, ~75 yrs. 52yr solo-owner tenure → top of natural-exit band. No named successor.",
        "L2": 55, "L2c": "Solo-owner hot shot + forklift delivery format. Fleet size unverified — owner-operator scale likely. NAICS edge case (LTL + hot shot).",
        "L3": 80, "L3c": ".net domain (older vintage), Humble NE Houston pre-2000 yard, named after founder solo-owner legacy brand, forklift-delivery niche pre-2000, phone-forward, no telematics. 5+ tells.",
        "L4": 88, "L4c": "Houston metro +5 (petrochem-adjacent). LTL + forklift delivery niche has regional pull.",
        "confidence": "low", "thesis": "Classic solo-founder aging-out profile. Forklift-delivery niche has acquisition value to local 3PLs. Lever: dispatch systemization + customer concentration risk audit. Fleet size verification required — likely below SBA threshold but could be roll-up tuck-in. Cap at B until fleet + identity verified.",
    },
    5: {  # Earth Haulers — 49yr DFW aggregate
        "owner_age_estimate": None,
        "owner_age_source": "unverified_no_named_principal",
        "owner_tenure_years": 49,
        "L1": 60, "L1c": "49yr tenure suggests founder is aging out. Owner identity unverified — age band uncertain.",
        "L2": 60, "L2c": "DFW aggregate hauler. Fleet size unverified. Stable construction-demand vertical.",
        "L3": 55, "L3c": "49yr tenure, family-ownership unstated but implied, no platform affiliation, 817-540 mid-Cities exchange. 3 tells but owner identity opacity drags.",
        "L4": 75, "L4c": "DFW metro (ordinary aggregate corridor) — 0 sub-market nudge but stable demand.",
        "confidence": "low", "thesis": "DFW aggregate hauling = stable demand. 49yr tenure attractive but owner identity verification gap caps tier. C-watch pending Comptroller + fleet size lookup.",
    },
    6: {  # Panhandle Express — 102 trucks (SIZE EXCLUDE)
        "owner_age_estimate": None,
        "owner_age_source": "unverified",
        "owner_tenure_years": 19,
        "L1": 25, "L1c": "19yr tenure below A-tier band; no named owner.",
        "L2": 20, "L2c": "102 power units EXCEEDS 50-truck SBA cap. Hard exclude for size band.",
        "L3": 30, "L3c": "Modern scale operator (102 units) at Panhandle ag hub. No strong coasting signals.",
        "L4": 70, "L4c": "Panhandle (cattle/grain) +3.",
        "confidence": "low", "thesis": "EXCLUDE — fleet >50 trucks exceeds SBA/independent-sponsor band. Cross-vertical visibility only.",
    },
    7: {  # Plains Transportation (Gripp) — 53yr Panhandle reefer
        "owner_age_estimate": 80,
        "owner_age_source": "founder_named_dick_gripp_1968_min_25yr_at_founding",
        "owner_tenure_years": 53,
        "L1": 90, "L1c": "Founder Dick Gripp named; if still living ~80+. 53yr family tenure. Likely 2nd-gen operator now.",
        "L2": 70, "L2c": "Refrigerated food-grade niche (USDA stable). TXTA + Truckload Carriers Assoc + SmartWay member. Fleet size unverified.",
        "L3": 75, "L3c": "53yr tenure, Gripp family progression, pivot cattle→reefer, Amarillo pre-2000 dairy corridor HQ, 806-372 old exchange. 4 tells; modern industry memberships pull back slightly.",
        "L4": 80, "L4c": "Panhandle (cattle/grain/dairy) +3 nudge. Plainview/Hereford/Friona milk belt = defensible regional moat.",
        "confidence": "medium", "thesis": "Family dairy/meat refrigerated carrier in Panhandle dairy belt. Lever: cold-chain telematics + USDA compliance tooling. Generational inflection candidate. Successor verification (current Gripp principal) required.",
    },
    8: {  # Reliant Field Services — 15yr Eagle Ford crude
        "owner_age_estimate": None,
        "owner_age_source": "unverified",
        "owner_tenure_years": 15,
        "L1": 30, "L1c": "15yr tenure below A-tier; owner unverified. Corporate HQ posture suggests professional management not solo-founder.",
        "L2": 60, "L2c": "42 power units + 47 trailers (perfect size band). Eagle Ford + Permian crude/condensate/LPG. Asset-based dual-basin = defensible.",
        "L3": 35, "L3c": "Class A office address (Fountain View Drive Suite 420) is professional corporate format, not solo-yard. 15yr tenure too young for coasting. 1 tell.",
        "L4": 85, "L4c": "Houston HQ + dual-basin Eagle Ford / Permian = Houston +5 nudge & Permian +5 collateral.",
        "confidence": "low", "thesis": "B-tier dual-basin crude hauler. Corporate office format suggests possible PE-backed structure — verify ownership before any outreach. If founder-owned, fleet+specialty profile is acquirable.",
    },
    9: {  # Hondo Resources — 3yr ACTIVE BUYER (EXCLUDE)
        "owner_age_estimate": 35,
        "owner_age_source": "founder_named_2023_likely_young_founder",
        "owner_tenure_years": 3,
        "L1": 10, "L1c": "Brayden Woods CEO, ~35. 3yr tenure. Aspirational generational language, not retroactive.",
        "L2": 25, "L2c": "Active acquirer (acquired Hyflow Water Solutions Dec 2025). Roll-up posture. 10 trucks below SBA band.",
        "L3": 10, "L3c": "Active M&A buyer — does NOT match coasting/aging-out thesis.",
        "L4": 70, "L4c": "Permian water transfer demand strong but not relevant here.",
        "confidence": "high", "thesis": "EXCLUDE — Hondo Resources is an active acquirer / competitor in Permian water space. Hard gate fail (years_in_business <5 → cap 35; D_pass for buyer profile).",
        "force_tier": "D_pass",
        "is_distressed": False,
    },
    10: {  # Big Star — OK HQ + 200+ trucks (EXCLUDE)
        "owner_age_estimate": 65,
        "owner_age_source": "founder_named_1999_min_38yr_at_founding",
        "owner_tenure_years": 27,
        "L1": 70, "L1c": "Link Clifton named founder ~65. 27yr tenure.",
        "L2": 15, "L2c": "200+ trucks far exceeds SBA 50-truck cap. OK HQ — out of TX jurisdiction.",
        "L3": 20, "L3c": "No strong coasting tells listed.",
        "L4": 60, "L4c": "OK + TX dual-state. Eagle Ford + Permian via TX division.",
        "confidence": "high", "thesis": "EXCLUDE — out-of-TX HQ (Oklahoma City) + 200+ trucks beyond SBA cap.",
        "force_tier": "D_pass",
    },
    11: {  # Tim Ables — 100+ trucks (SIZE EXCLUDE)
        "owner_age_estimate": 70,
        "owner_age_source": "founder_named_1988_min_30yr_at_founding",
        "owner_tenure_years": 38,
        "L1": 85, "L1c": "Tim Ables ~70, named founder, 38yr tenure. Strong aging-out profile.",
        "L2": 20, "L2c": "100+ trucks EXCEEDS 50-truck SBA cap. Frac sand cyclical exposure.",
        "L3": 80, "L3c": "Floridawebcompany.com hosted (low tech), bootstrap growth, East TX Kilgore HQ, named founder legacy brand, 903-986 rural exchange. 5 tells.",
        "L4": 78, "L4c": "East TX oil patch heritage. Frac sand demand cyclical.",
        "confidence": "medium", "thesis": "Strong coasting profile but fleet >50 exceeds SBA cap. Cross-vertical visibility only.",
        "force_tier": "D_pass",
    },
    12: {  # The Glover Company — Ozona Mike Glover heavy haul
        "owner_age_estimate": None,
        "owner_age_source": "founder_named_no_founding_year",
        "owner_tenure_years": None,
        "L1": 50, "L1c": "Mike Glover named principal. Founding year not disclosed. Solo-owner small-town profile suggests aging cohort but age unverified.",
        "L2": 50, "L2c": "Permian + Concho Valley heavy haul (winch trucks, floats, dropdecks). Fleet + USDOT unverified.",
        "L3": 65, "L3c": "Owner Mike Glover named (solo-owner profile), Ozona TX small West TX town, 325-392 rural exchange, founding year not stated on website. 4 tells.",
        "L4": 80, "L4c": "Permian (oil services) +5 nudge. Small Concho Valley town.",
        "confidence": "low", "thesis": "Solo-owner small-town Permian heavy-haul. Strong coasting signals but insufficient data. C-watch pending Comptroller + USDOT lookup.",
    },
    13: {  # GM Oilfield & Trucking — insufficient data
        "owner_age_estimate": None,
        "owner_age_source": "unverified",
        "owner_tenure_years": None,
        "L1": 30, "L1c": "Owner identity + founding year unverified.",
        "L2": 40, "L2c": "Permian vacuum + pump/kill + hot oilers niche. Fleet unverified.",
        "L3": 35, "L3c": "Family-ownership not stated; founding year not stated. 2 tells.",
        "L4": 78, "L4c": "Permian +5 nudge.",
        "confidence": "low", "thesis": "Insufficient data — needs USDOT + ownership + founding year + fleet size. C-watch.",
    },
    14: {  # Diamond Pump and Transport — insufficient data
        "owner_age_estimate": None,
        "owner_age_source": "unverified",
        "owner_tenure_years": None,
        "L1": 30, "L1c": "'Locally owned and operated' but no named principal or age.",
        "L2": 45, "L2c": "Permian acid pumping + tank cleaning + hot oil + water hauling. Niche specialty. Fleet unverified.",
        "L3": 40, "L3c": "Locally-owned framing, Permian-only service, specialty mix, 432-203 Odessa exchange. 3 tells.",
        "L4": 78, "L4c": "Permian +5 nudge. Odessa epicenter.",
        "confidence": "low", "thesis": "Insufficient data — Permian specialty pump/transport with defensible niche. Needs Comptroller + fleet lookup. C-watch.",
    },
    15: {  # Tiki Trucking — 20yr Austin aggregate
        "owner_age_estimate": None,
        "owner_age_source": "unverified",
        "owner_tenure_years": 20,
        "L1": 50, "L1c": "20yr tenure borderline. Family generational language implies 2nd-gen discussion but owner age unverified.",
        "L2": 60, "L2c": "Austin metro aggregate + pneumatic dry bulk (cement, fly ash). High-demand market. Fleet unverified.",
        "L3": 50, "L3c": "Generational succession language, family-owned 2006, Austin metro aggregate, pneumatic dry-bulk specialty. 3 tells.",
        "L4": 85, "L4c": "Austin DFW-equivalent metro. Pneumatic dry-bulk niche has barriers. Strong Central TX construction pull.",
        "confidence": "low", "thesis": "Austin aggregate + pneumatic dry-bulk has strong market pull. Borderline tenure caps tier. Verify owner age + fleet size for tier upgrade.",
    },
    16: {  # Redbird Trucking — 14yr modernized (DROP)
        "owner_age_estimate": None,
        "owner_age_source": "unverified",
        "owner_tenure_years": 14,
        "L1": 25, "L1c": "14yr tenure below A-tier. Owner unverified.",
        "L2": 55, "L2c": "Pneumatic dry-bulk (cement, fly ash, lime). DBE certified. Late-model fleet.",
        "L3": 20, "L3c": "Modernized fleet + in-house maintenance = active investment, not coasting.",
        "L4": 80, "L4c": "Central TX (Austin) pneumatic niche.",
        "confidence": "low", "thesis": "Modernized active operator, not coasting. C-watch.",
    },
    17: {  # Dee King Trucking — 34yr Amarillo cattle (Tyson)
        "owner_age_estimate": 62,
        "owner_age_source": "founder_named_1992_likely_late_50s_early_60s",
        "owner_tenure_years": 34,
        "L1": 78, "L1c": "Dee King named founder, family-owned 34yr. Owner cohort estimated ~60+. Strong aging-out window.",
        "L2": 60, "L2c": "Cattle/livestock niche (USDA-cycle stable). Tyson Foods customer concentration = both moat & risk. Fleet unverified.",
        "L3": 70, "L3c": "Founder name in business name, 34yr tenure, family-owned, hybrid company drivers + owner-ops, Tyson Foods concentration, 806-670 Amarillo exchange. 5 tells.",
        "L4": 80, "L4c": "Panhandle cattle hub +3 nudge. Tyson dependency caps premium.",
        "confidence": "medium", "thesis": "Family livestock hauler with Tyson Foods anchor customer. Lever: customer-mix diversification beyond single processor + cattle-yard telematics. Verify Dee King current age + fleet size + 2nd-gen presence.",
    },
    18: {  # Texas Premier (Premier Tank Truck) — 23yr Eagle Ford fluid
        "owner_age_estimate": None,
        "owner_age_source": "unverified",
        "owner_tenure_years": 23,
        "L1": 50, "L1c": "23yr family tenure borderline. Owner identity unverified.",
        "L2": 55, "L2c": "Eagle Ford + Barnett frac fluid + drilling mud + production water. Dual-basin. Fleet unverified.",
        "L3": 55, "L3c": "23yr family-owned, inner-loop Houston HQ, 713-524 older Houston exchange, dual-basin exposure. 4 tells.",
        "L4": 85, "L4c": "Houston HQ +5 (petrochem corridor). Dual-basin Eagle Ford / Barnett exposure.",
        "confidence": "low", "thesis": "Houston-headquartered Eagle Ford/Barnett fluid hauler. Borderline tenure, fleet/identity unverified. B-watch.",
    },
    19: {  # Luckey Truck — 6 trucks below SBA threshold
        "owner_age_estimate": None,
        "owner_age_source": "unverified",
        "owner_tenure_years": 44,
        "L1": 70, "L1c": "44yr Luckey family tenure; specific principal unverified.",
        "L2": 25, "L2c": "6 power units — BELOW 10-truck SBA threshold. Vertically integrated with feedlot — trucking ancillary.",
        "L3": 60, "L3c": "44yr tenure, feedlot integration, owner-op scale. 3 tells but tiny fleet limits.",
        "L4": 70, "L4c": "South TX feedlot integration.",
        "confidence": "low", "thesis": "Fleet too small for standalone SBA; trucking is feedlot ancillary. DROP unless bundled with feedlot.",
        "force_tier": "D_pass",
    },
    20: {  # JPI Trucking — Houston aggregate, ~10-15yr
        "owner_age_estimate": None,
        "owner_age_source": "unverified",
        "owner_tenure_years": None,
        "L1": 30, "L1c": "'Over a decade' suggests ~10-15yr tenure. Family-owned but owner unverified.",
        "L2": 45, "L2c": "Houston metro aggregate (select fill, sand, crushed concrete). HUB-certified. Fleet unverified.",
        "L3": 40, "L3c": "Family-owned, HUB-certified, North Houston industrial corridor, 832-740 newer cell exchange. 3 tells.",
        "L4": 85, "L4c": "Houston metro +5 nudge.",
        "confidence": "low", "thesis": "Insufficient data — likely below A-tier tenure. C-watch pending founding year + owner verification.",
    },
    21: {  # Mission Petroleum Carriers — 61yr crude
        "owner_age_estimate": None,
        "owner_age_source": "unverified",
        "owner_tenure_years": 61,
        "L1": 75, "L1c": "61yr tenure A-tier deep heritage. Privately owned — owner identity unverified.",
        "L2": 65, "L2c": "Crude + petroleum transport. SA + Houston bi-city ops. Long employee tenure signal. Fleet unverified.",
        "L3": 65, "L3c": "61yr tenure, privately owned, bi-city SA + Houston, long employee tenure, mipe.com short legacy domain. 4 tells.",
        "L4": 88, "L4c": "Houston phone exchange + SA HQ = +5 Houston nudge with SA collateral.",
        "confidence": "low", "thesis": "Deep-heritage crude carrier. Ownership identity is gate — could be PE-owned or family. Verify Comptroller + LinkedIn for principal. B-watch pending ownership verification.",
    },
    22: {  # Indeca Crude Xpress — 98 trucks (SIZE EXCLUDE)
        "owner_age_estimate": None,
        "owner_age_source": "unverified",
        "owner_tenure_years": None,
        "L1": 30, "L1c": "Owner identity unverified.",
        "L2": 20, "L2c": "98 power units EXCEEDS SBA 50-cap.",
        "L3": 25, "L3c": "Strong Shell Goal Zero customer relationship signal but no classic coasting tells.",
        "L4": 78, "L4c": "Permian crude +5 nudge.",
        "confidence": "low", "thesis": "EXCLUDE — fleet >50 trucks exceeds SBA cap.",
        "force_tier": "D_pass",
    },
    23: {  # PennCo Transport — 22yr 15-truck DFW crude
        "owner_age_estimate": None,
        "owner_age_source": "unverified",
        "owner_tenure_years": 22,
        "L1": 50, "L1c": "22yr family tenure borderline. Owner identity unverified.",
        "L2": 70, "L2c": "15 power units RIGHT in target band. Long employee retention. ISN + Veriforce safety members. TX crude/condensate hauling.",
        "L3": 60, "L3c": "22yr family-owned, long employee retention, ISN/Veriforce posture, Saginaw NW FW industrial site, 817-439 exchange. 4 tells.",
        "L4": 78, "L4c": "DFW metro 0 nudge but Saginaw is FW exurban industrial — stable demand.",
        "confidence": "low", "thesis": "Right-sized 15-truck family crude hauler with stable workforce + safety posture. Lever: customer-mix expansion + dispatch software. Tier upgradeable if founder age confirms succession band.",
    },
    24: {  # Texas Hot Oilers — 44yr Eagle Ford hot oil
        "owner_age_estimate": None,
        "owner_age_source": "unverified",
        "owner_tenure_years": 44,
        "L1": 75, "L1c": "44yr family tenure. Owner identity unverified but multi-decade family op implies 2nd-gen present.",
        "L2": 78, "L2c": "28 power units (perfect band). Hot oil + frac water heater niche (Eagle Ford / Austin Chalk specialty). Multi-yard rural TX footprint. Intrastate hazmat.",
        "L3": 78, "L3c": "44yr family-owned 1982, 28 power units, hot oil units niche, multi-yard Giddings/Madisonville/Caldwell/Tilden, intrastate hazmat, 979-542 Brazos/Lee exchange. 6 tells.",
        "L4": 85, "L4c": "Eagle Ford / Austin Chalk corridor. Hot oil intrastate hazmat = high barrier. +3 South TX nudge.",
        "confidence": "medium", "thesis": "Strong A-tier candidate. Eagle Ford hot oil niche with multi-yard infrastructure + 28-truck SBA-financeable scale + 44yr family tenure. Lever: telematics + cross-basin expansion (Permian hot oil demand). Successor + named principal verification required for A-tier — currently cap at B due to owner identity gap.",
    },
    25: {  # Western Dairy Transport — MO HQ (EXCLUDE)
        "owner_age_estimate": None,
        "owner_age_source": "founder_family_named",
        "owner_tenure_years": 59,
        "L1": 40, "L1c": "Honeycutt founder family — out-of-state HQ (Cabool MO) caps any age premium.",
        "L2": 20, "L2c": "Out-of-state corporate HQ. TX terminal is operational outpost only.",
        "L3": 30, "L3c": "Not applicable — out-of-state ownership profile.",
        "L4": 50, "L4c": "TX terminal in Erath dairy belt but corporate HQ Cabool MO.",
        "confidence": "high", "thesis": "EXCLUDE — Cabool MO corporate HQ disqualifies from TX-domiciled filter.",
        "force_tier": "D_pass",
    },
    26: {  # Winburn Milk — 59yr C.D. Ballard ~75 (TOP A-TIER)
        "owner_age_estimate": 75,
        "owner_age_source": "ballard_acquired_1980s_likely_30s_plus_45yrs",
        "owner_tenure_years": 45,
        "L1": 95, "L1c": "C.D. Ballard President ~75. 45yr family ownership (acquired 1980s; business founded 1967). 2nd-gen daughters Tammy Ballard Acker + Terri Monday active.",
        "L2": 82, "L2c": "29 power units (perfect band). Refrigerated milk niche (USDA-regulated, defensible). USDOT 109646 pre-1970 ICC authority. Sulphur Springs Hopkins County dairy belt.",
        "L3": 92, "L3c": "No public website — phone-only customer intake (huge coasting tell), USDOT 109646 pre-1970 ICC, named founder C.D. Ballard ~75, 2nd-gen succession path verified, 903-885 NE TX rural exchange, 59yr tenure. 6 strong tells.",
        "L4": 80, "L4c": "Hopkins County dairy belt + Erath County operations. Panhandle/dairy +3 collateral. Refrigerated USDA niche = high regional pull.",
        "confidence": "medium", "thesis": "TOP A-TIER. Multi-generational refrigerated milk carrier with named founder, named 2nd-gen successors, perfect SBA fleet size, USDA-regulated niche, no website = old-school. Lever: digital customer portal + cold-chain telematics + carve-out from broader Ballard Enterprises (Hopkins + Erath entities). Internal succession may be path of least resistance for family, but inflection point timing suggests external sale window. Deep-dive required — cap deep_dive_pending=true.",
        "deep_dive_pending": True,
    },
    27: {  # Houston Refrigerated Logistics — 3PL primary (NAICS DROP)
        "owner_age_estimate": None,
        "owner_age_source": "founder_named_2013",
        "owner_tenure_years": 13,
        "L1": 25, "L1c": "13yr tenure below A-tier; founders Dennis & Julie Carroll named.",
        "L2": 35, "L2c": "3PL/warehousing primary, trucking secondary. NAICS likely 484+493.",
        "L3": 30, "L3c": "13yr tenure, founders named, family-owned 2013. 2 tells.",
        "L4": 80, "L4c": "Houston metro.",
        "confidence": "low", "thesis": "NAICS mismatch — primarily 3PL/warehouse not specialty trucking. DROP from current vertical.",
        "force_tier": "D_pass",
    },
    28: {  # JA Harris Trucking — 22yr Ship Channel heavy-haul
        "owner_age_estimate": 60,
        "owner_age_source": "founder_named_2004_likely_late_30s_plus_22yr",
        "owner_tenure_years": 22,
        "L1": 60, "L1c": "Jaime A. Harris + Rogelio Gonzalez founders. Joe Harris (2nd-gen son or brother) joined 2005. Founder cohort ~60. 22yr tenure borderline.",
        "L2": 72, "L2c": "15-30 power unit fleet (SAFER 15 / website 30 discrepancy). Heavy-haul + Ship Channel oilfield + petrochem niche. Specialized trailer mix (flatbeds, RGN, gooseneck).",
        "L3": 65, "L3c": "22yr family-led, named founders, verified 2nd-gen Joe Harris joined 2005, Ship Channel concentration, fleet count discrepancy SAFER vs website, 713-672 older Houston exchange. 5 tells.",
        "L4": 90, "L4c": "Houston Ship Channel petrochem corridor +5 nudge.",
        "confidence": "medium", "thesis": "B+ tier. Ship Channel heavy-haul / petrochem family op with verified 2nd-gen successor. Lever: TMS adoption + customer-mix diversification beyond Ship Channel concentration. Internal succession likely in place — may not be motivated seller; verify Joe Harris age + ambitions.",
    },
    29: {  # Dunagin Transport — 120 trucks (SIZE EXCLUDE)
        "owner_age_estimate": None,
        "owner_age_source": "unverified",
        "owner_tenure_years": 45,
        "L1": 75, "L1c": "45yr Dunagin family tenure. Owner unverified.",
        "L2": 20, "L2c": "120 power units EXCEEDS SBA 50-cap.",
        "L3": 50, "L3c": "Family-owned 40+ years, small West TX town. 2 tells but scale undercuts coasting profile.",
        "L4": 78, "L4c": "Big Country + Permian fluid hauling.",
        "confidence": "medium", "thesis": "EXCLUDE — fleet >50 exceeds SBA cap.",
        "force_tier": "D_pass",
    },
    30: {  # Ahrens Brothers — 48yr LPG/asphalt (STRONG A)
        "owner_age_estimate": 72,
        "owner_age_source": "founder_brothers_1978_likely_70s",
        "owner_tenure_years": 48,
        "L1": 88, "L1c": "Ahrens Brothers founder cohort likely 70s now after 48yr tenure. No named successor publicly identified.",
        "L2": 80, "L2c": "19 power units + 22 LPG tank trailers + 6 asphalt trailers (perfect SBA band). LPG + asphalt oil hazmat niche (high barrier to entry).",
        "L3": 80, "L3c": "48yr 'Brothers' founder cohort, Brenham small-town Washington County, niche LPG + asphalt hazmat trailers, 979-836 Brazos Valley exchange. 4 strong tells.",
        "L4": 80, "L4c": "Brenham TX between Houston and Austin — Central TX corridor. LPG + asphalt regional demand stable. +0 sub-market but defensible niche.",
        "confidence": "medium", "thesis": "STRONG A-tier candidate. Aging Ahrens Brothers founder cohort, perfect SBA fleet size (19 trucks), LPG + asphalt hazmat niche with high barriers. Lever: dispatch + telematics + cross-state LPG opportunity. Deep-dive required for principal identity + 2nd-gen status — cap deep_dive_pending=true.",
        "deep_dive_pending": True,
    },
    31: {  # HD5 Transport — 15yr NGL (B/C)
        "owner_age_estimate": None,
        "owner_age_source": "unverified",
        "owner_tenure_years": 15,
        "L1": 30, "L1c": "15yr tenure below A-tier. Owner unverified.",
        "L2": 60, "L2c": "15 power units (perfect band). NGL/Y-grade/raw mix/propane specialty (midstream chemicals).",
        "L3": 40, "L3c": "'Family-orientated' culture, 15yr tenure, NGL midstream niche. 2 tells.",
        "L4": 80, "L4c": "Central TX + San Angelo midstream. Hot vertical 0 nudge.",
        "confidence": "low", "thesis": "Right-size NGL specialty carrier but 15yr tenure caps. C-watch pending owner verification.",
    },
    32: {  # Pulido Transport — 31yr Joe Pulido ~65 (STRONG A)
        "owner_age_estimate": 65,
        "owner_age_source": "founder_named_1995_former_driver_likely_35_at_founding",
        "owner_tenure_years": 31,
        "L1": 85, "L1c": "Joe Pulido named founder ~65 (former truck driver who started carrier at ~35). 31yr solo-founder tenure. Aging-out window open.",
        "L2": 82, "L2c": "29 power units (perfect band). Chemical / lubricants / waxes specialty. Houston + Beaumont petrochem corridor terminals. Asset-based.",
        "L3": 82, "L3c": "Named founder Joe Pulido former-driver narrative, 31yr solo tenure, asset-based, Houston + Beaumont terminals, 832-243 newer cell exchange. 5 tells.",
        "L4": 92, "L4c": "Houston + Beaumont petrochem corridor +5 nudge. Lubricants / waxes / chemicals defensible niche.",
        "confidence": "medium", "thesis": "STRONG A-tier candidate. Classic solo-founder former-driver narrative, perfect SBA fleet size, Houston/Beaumont petrochem corridor, chemical specialty. Lever: TMS + customer expansion beyond lubricants + potential rollout to Galveston/Corpus terminals. Deep-dive required for successor verification (any Pulido children active?) — cap deep_dive_pending=true.",
        "deep_dive_pending": True,
    },
    33: {  # Forerunner Ag — 20yr Panhandle ag
        "owner_age_estimate": None,
        "owner_age_source": "associated_principal_named",
        "owner_tenure_years": 20,
        "L1": 50, "L1c": "James Barrett associated principal. ~20yr tenure borderline. Age unverified.",
        "L2": 68, "L2c": "27 power units (perfect band). Diversified ag (livestock + grain + feed + hay + dry bulk) — Panhandle.",
        "L3": 55, "L3c": "20yr Panhandle ag, James Barrett associated, no platform affiliation, diversified ag mix, 806-346 Hereford exchange. 4 tells.",
        "L4": 78, "L4c": "Panhandle (cattle/grain) +3 nudge. Hereford ag hub.",
        "confidence": "low", "thesis": "Right-size Panhandle ag carrier with diversified commodity mix. Borderline tenure caps tier. Verify James Barrett age + founding year for upgrade.",
    },
    34: {  # Texas Milk Transport — CA-controlled flag (EXCLUDE)
        "owner_age_estimate": None,
        "owner_age_source": "unverified",
        "owner_tenure_years": None,
        "L1": 25, "L1c": "559 (CA) phone area code suggests CA-controlled ownership.",
        "L2": 50, "L2c": "19 power units (perfect band). TX dairy belt operations.",
        "L3": 45, "L3c": "CA phone code flag, 19 units, no website. 3 tells.",
        "L4": 65, "L4c": "Castro County Panhandle dairy belt +3.",
        "confidence": "low", "thesis": "Jurisdiction risk — CA-controlled ownership likely. DROP pending verification.",
        "force_tier": "D_pass",
    },
    35: {  # Texas Oilfield Transportation — Mt Enterprise no website (insufficient)
        "owner_age_estimate": None,
        "owner_age_source": "unverified",
        "owner_tenure_years": None,
        "L1": 35, "L1c": "Owner unverified; founding year not disclosed.",
        "L2": 55, "L2c": "20 power units + 4 employee drivers (heavily owner-op dependent). Mt Enterprise East TX. Diverse cargo (lumber + oilfield + water well).",
        "L3": 60, "L3c": "No website, phone-only, owner-op dependent, 903-822 East TX rural, generalist cargo mix. 4 tells.",
        "L4": 70, "L4c": "East TX oil patch.",
        "confidence": "low", "thesis": "Classic coasting signals (no website, 20-truck, East TX rural) but insufficient data on owner. C-watch pending Comptroller + cold-call.",
    },
    # ---- batch 2 ----
    36: {  # REX Oilfield Services — 19yr Midland
        "owner_age_estimate": None,
        "owner_age_source": "no_disclosure_no_website",
        "owner_tenure_years": 19,
        "L1": 50, "L1c": "19yr tenure borderline. No website + no named principal → owner identity gap.",
        "L2": 70, "L2c": "49 power units (top of target band), 30 drivers. Pure Permian oilfield niche.",
        "L3": 75, "L3c": "No website (strong tell), LP entity structure (older partnership pattern), pure oilfield no diversification, 49 trucks no modernization signals, no driver app, no team page. 6 tells.",
        "L4": 85, "L4c": "Permian (oil services) +5 nudge. Midland epicenter.",
        "confidence": "low", "thesis": "Strong coasting + size profile but owner identity totally opaque. Comptroller lookup needed for named principal before A/B upgrade. C-watch.",
    },
    37: {  # West Texas Frac Sand Logistics — no founding year
        "owner_age_estimate": None,
        "owner_age_source": "no_disclosure_on_website",
        "owner_tenure_years": None,
        "L1": 35, "L1c": "Founding year + owner not disclosed.",
        "L2": 55, "L2c": "40 power units (perfect band). Pure frac sand (cyclical, oil-price exposed). Permian + SE NM.",
        "L3": 55, "L3c": "Founding year not disclosed, owner not disclosed, no team page, phone-first intake, pure frac sand cycle exposure. 5 tells.",
        "L4": 80, "L4c": "Permian frac sand +5 nudge. Odessa epicenter.",
        "confidence": "low", "thesis": "Right-size frac sand specialist but ownership opacity caps. Frac sand cyclicality is sellability risk. C-watch pending Comptroller.",
    },
    38: {  # Black Rhino Energy Services — ~6yr (fails 5yr soft)
        "owner_age_estimate": None,
        "owner_age_source": "linkedin_president_listing",
        "owner_tenure_years": None,
        "L1": 20, "L1c": "USDOT issued ~2020 → <6yr operation.",
        "L2": 35, "L2c": "14 power units below sweet spot. Frac sand cyclical exposure.",
        "L3": 25, "L3c": "Generic Inc entity recent formation, USDOT post-2020, small fleet. 3 tells.",
        "L4": 78, "L4c": "Permian deep (Gaines County Seminole) +5 nudge.",
        "confidence": "low", "thesis": "Too young for sellability profile. Cesar Carreon President but ~6yr tenure fails 5-yr soft gate barely. DEPRIORITIZE.",
    },
    39: {  # Viper Specialized Services — Midland heavy equipment opaque
        "owner_age_estimate": None,
        "owner_age_source": "70_plus_years_industry_experience_proxy_no_named_owner",
        "owner_tenure_years": None,
        "L1": 45, "L1c": "'70+ years industry experience' claim but USDOT registered ~2018-2019 → legacy buyout/restart pattern. Owner identity opaque.",
        "L2": 65, "L2c": "30 power units (perfect band). Crane + heavy haul + dirt + oilfield construction multi-trade.",
        "L3": 55, "L3c": "Owner opaque, USDOT post-2018 but 70yr industry claim (buyout/restart), family-owned no team page, multi-trade pre-specialization, no client portal. 5 tells.",
        "L4": 85, "L4c": "Midland-Odessa-Pecos-Hobbs Permian footprint +5 nudge.",
        "confidence": "low", "thesis": "Permian heavy equipment + crane specialty with opaque ownership. 70yr industry experience claim worth surfacing — if legacy operator under restart, could be A-tier. Needs Comptroller deep-dive.",
    },
    40: {  # Capitol Land & Livestock — Jim Schwertner ~49 (EXCLUDE)
        "owner_age_estimate": 49,
        "owner_age_source": "texas_monthly_jan_2022_age_45",
        "owner_tenure_years": None,
        "L1": 15, "L1c": "Jim Schwertner ~49 — far too young for succession band. 3rd-gen grandson Jimmy already in pipeline.",
        "L2": 30, "L2c": "50 trucks + 150 people + 225 auctions/week — beyond SBA scale. Active growth posture.",
        "L3": 10, "L3c": "Active growth, NBAA plane membership = high-net-worth maintenance not exit-mode.",
        "L4": 78, "L4c": "Schwertner TX (Williamson County) Central TX corridor.",
        "confidence": "high", "thesis": "EXCLUDE — Schwertner family is 3-gen dynasty (Eugene → Jim ~49 → Jimmy grandson). Not for sale. Internal succession path locked.",
        "force_tier": "D_pass",
    },
    41: {  # Ag Land & Cattle — 9 trucks below band
        "owner_age_estimate": None,
        "owner_age_source": "no_disclosure_no_website",
        "owner_tenure_years": None,
        "L1": 30, "L1c": "Owner unverified.",
        "L2": 30, "L2c": "9 power units BELOW 10-truck SBA threshold.",
        "L3": 55, "L3c": "No website, dual-authority oilfield + livestock generalist, Hereford rural. 3 tells.",
        "L4": 75, "L4c": "Hereford 'Beef Capital' +3 Panhandle nudge.",
        "confidence": "low", "thesis": "Below SBA fleet threshold + identity opaque. Roll-up tuck-in at best. C-watch.",
    },
    42: {  # Texas Tank Trucks — 33yr Breckenridge NO website (STRONG)
        "owner_age_estimate": 63,
        "owner_age_source": "33_yr_tenure_proxy_assume_~30_at_founding",
        "owner_tenure_years": 33,
        "L1": 80, "L1c": "33yr tenure. Owner estimated ~63 if founder still operating. Strong aging-out band.",
        "L2": 68, "L2c": "36 power units (perfect band), 30 drivers. Saltwater/freshwater hauling. Intrastate non-hazmat limits revenue ceiling. Stephens County declining oilfield region.",
        "L3": 88, "L3c": "NO website (huge tell), Excite.com 1990s-era email contact (blondierogers@excite.com), phone-only intake, 33yr operation, Stephens County declining oilfield region, owner identity not disclosed. 6 STRONG tells.",
        "L4": 70, "L4c": "West Central TX (Stephens County) Breckenridge — declining oilfield region; Big Country secondary metro -5 from Permian nudge but stable demand for established operator.",
        "confidence": "low", "thesis": "STRONG A-tier candidate by coasting signals. Owner verification gap caps confidence — owner identity must be confirmed via Comptroller before A-tier promotion. Lever: digital customer portal + telematics + customer-mix expansion. Deep-dive required.",
        "deep_dive_pending": True,
    },
    43: {  # W.M. Dewey & Son — 131yr but modernized + scale (EXCLUDE)
        "owner_age_estimate": None,
        "owner_age_source": "1950s_acquisition_proxy_3rd_gen_now_in_30s-50s",
        "owner_tenure_years": None,
        "L1": 55, "L1c": "McDowell family 2nd+3rd gen since mid-1950s. 3rd-gen may be 30s-50s — not classic succession band.",
        "L2": 35, "L2c": "40 company tractors + 110 flatbeds + owner-ops — exceeds SBA scale. Better PE/strategic buyer fit.",
        "L3": 20, "L3c": "Online quote portal + inventory system = MODERN. Copyright 2026, LinkedIn footer, active site. Not coasting.",
        "L4": 88, "L4c": "Houston petrochem corridor +5. 131yr heritage. OCTG niche.",
        "confidence": "medium", "thesis": "Texas trucking legend (131yr) but modernized scale exceeds SBA acquisition. Better PE/strategic fit. DEPRIORITIZE for current run.",
        "force_tier": "D_pass",
    },
    44: {  # Kimrad Transport — Brad + Kimila Pohlmeier ~60 (B watch)
        "owner_age_estimate": 60,
        "owner_age_source": "2003_founding_plus_career_proxy_likely_50s_at_founding",
        "owner_tenure_years": 23,
        "L1": 60, "L1c": "Brad + Kimila Pohlmeier husband-wife founders ~60. 23yr tenure. No visible 2nd-gen successor.",
        "L2": 72, "L2c": "Multi-commodity tanker (asphalt + crude + ammonia + dairy + dry bulk). Amarillo Panhandle hub. TXTA + WIT + SmartWay + ATTA memberships = engaged but not coasting. Fleet size undisclosed.",
        "L3": 50, "L3c": "23yr family co-founder husband-wife, Panhandle hub, online training portal (modern), time-off form online, multi-commodity tanker. 3 tells; modernization pulls back.",
        "L4": 80, "L4c": "Panhandle multi-commodity +3 nudge.",
        "confidence": "medium", "thesis": "B-tier succession watch. Husband-wife founder cohort ~60 with no visible 2nd-gen. Active industry posture limits coasting signals. Lever: customer + region expansion + 2nd-gen vacuum opportunity. Successor verification critical.",
    },
    45: {  # Cole Distributing — fuel wholesaler NAICS flag
        "owner_age_estimate": None,
        "owner_age_source": "no_named_owner_only_cole_family_generic",
        "owner_tenure_years": None,
        "L1": 35, "L1c": "Cole family generic — no specific principal or age.",
        "L2": 45, "L2c": "25 vehicles (within band). NAICS likely 424720 (petroleum wholesale) not 484220 (trucking) — caps revenue mix attribution.",
        "L3": 50, "L3c": "Owner first name not disclosed, founding year not disclosed, family-owned messaging without team page, multi-state TX/OK/LA complexity, no portal. 4 tells.",
        "L4": 70, "L4c": "Palestine East TX. Multi-state fuel distribution.",
        "confidence": "low", "thesis": "NAICS classification risk — fuel wholesale may dominate revenue. C-watch pending NAICS + owner verification.",
    },
    46: {  # QW Transport — Rick Golman ~72 + family succession (EXCLUDE)
        "owner_age_estimate": 72,
        "owner_age_source": "ut_austin_1976_grad",
        "owner_tenure_years": 21,
        "L1": 80, "L1c": "Rick Golman ~72 — perfect succession band age.",
        "L2": 75, "L2c": "50 truck drivers, 1000+ c-stores, multi-decade industry. NAICS overlap with fuel wholesale.",
        "L3": 50, "L3c": "Rick ~72, 40+yrs management, 50 truck drivers, family rhetoric, TFFA member. 3 tells but family succession dampens.",
        "L4": 80, "L4c": "Dallas DFW metro.",
        "confidence": "high", "thesis": "EXCLUDE — Two sons + son-in-law all named operating partners. Internal succession path already structured. Not a likely external sale unless intelligence surfaces family dissatisfaction.",
        "force_tier": "D_pass",
    },
    47: {  # Petroleum Express Inc — Houston Ship Channel, opaque owner
        "owner_age_estimate": None,
        "owner_age_source": "30_plus_years_in_petroleum_industry_proxy",
        "owner_tenure_years": None,
        "L1": 50, "L1c": "'Over 30 years experience' but founding year + owner unverified.",
        "L2": 68, "L2c": "21 power units (perfect band). Houston Ship Channel liquids/gases hauler. Hazmat-certified + on-site maintenance = old-school asset-based. TFFA member.",
        "L3": 65, "L3c": "30+yr industry no founding year, owner opaque, hazmat-certified, on-site maintenance, phone-first, TFFA member. 5 tells.",
        "L4": 92, "L4c": "Houston Ship Channel petrochem +5 nudge.",
        "confidence": "low", "thesis": "Promising Houston Ship Channel liquids hauler but owner identity gap is the dominant blocker. Lever: TMS + customer expansion. Comptroller + LinkedIn dig required for A/B upgrade. C-watch.",
    },
    48: {  # Galaxy Freight Services — 56yr Houston multi-modal
        "owner_age_estimate": 60,
        "owner_age_source": "2nd_gen_of_1970_founding_father_was_founder",
        "owner_tenure_years": None,
        "L1": 70, "L1c": "2nd-gen confirmed; 3rd-gen ambiguous. 56yr operation. Founder cohort retired or passed; 2nd-gen ~60s.",
        "L2": 50, "L2c": "Multi-modal (truck + air + ocean) — NAICS conflict risk (488510 freight forwarding vs 484220). Fleet undisclosed.",
        "L3": 65, "L3c": "56yr op, owner identity opaque, 2nd-gen referenced, two addresses Greengrass + Greens Rd (transitioning HQ?), 24/7/365 messaging, phone-first. 5 tells.",
        "L4": 85, "L4c": "Houston metro +5 nudge.",
        "confidence": "low", "thesis": "NAICS classification flag — freight forwarding may dominate (488510). If asset-based trucking is dominant revenue, B-tier candidate. Comptroller + customer-list audit required.",
    },
    49: {  # Zamco Trucking — Luis Zamora ~73 + 46yr (STRONG A)
        "owner_age_estimate": 73,
        "owner_age_source": "1980_founding_assume_~27_at_founding",
        "owner_tenure_years": 46,
        "L1": 92, "L1c": "Luis C. Zamora ~73, founder of record after 46yr tenure. Alma Zamora Office Manager (likely wife or daughter — family successor).",
        "L2": 60, "L2c": "Owner-operator mix limits asset base from buyer view. DBE/MBE/SBE/HUB cert package = sticky TxDOT revenue moat. Fleet undisclosed but mixed owned + owner-op.",
        "L3": 92, "L3c": "Copyright 2016 (10-yr SITE STALE — STRONG tell), Wix.com hosting (bottom-tier CMS), 46yr tenure, founder Luis Zamora still listed, Alma as Office Manager family successor, owner-op fleet mix, TxDOT cert moat, no employee count, phone-first. 7+ tells.",
        "L4": 82, "L4c": "San Antonio aggregate + Eagle Ford + I-35 corridor +3 South TX nudge. SA secondary metro.",
        "confidence": "medium", "thesis": "STRONG A-tier candidate. Founder ~73, 46yr tenure, site frozen at 2016, family successor (Alma) visible, DBE/MBE TxDOT cert moat. Lever: asset-base build-out from owner-op model (could be a sleeper for a sponsor with capital) + I-35 / Eagle Ford expansion. Deep-dive required for fleet ownership economics + Alma's role.",
        "deep_dive_pending": True,
    },
    50: {  # Sisu Energy — 7yr owner-op brokerage (EXCLUDE)
        "owner_age_estimate": None,
        "owner_age_source": "ut_arlington_mba_proxy_unknown_grad_year",
        "owner_tenure_years": 7,
        "L1": 20, "L1c": "7yr operation, founder Jim Grundy actively building brand (podcasts, SiriusXM).",
        "L2": 20, "L2c": "100% owner-operator model = NO asset base for SBA buyer needing rolling stock collateral.",
        "L3": 10, "L3c": "Growth posture, $100M+ revenue without owned assets, founder active brand-building. Not coasting.",
        "L4": 80, "L4c": "Multi-basin frac sand (STX/NTX/WTX/SETX/PA/OH).",
        "confidence": "high", "thesis": "EXCLUDE — owner-op model (no fleet) + young growth-mode founder. Unsuitable for asset-based SBA acquisition.",
        "force_tier": "D_pass",
    },
    51: {  # Rios Trucking — 38yr Brazos Valley aggregate
        "owner_age_estimate": 65,
        "owner_age_source": "38_yr_tenure_proxy_assume_~27_at_founding",
        "owner_tenure_years": 38,
        "L1": 78, "L1c": "Rios family 38yr operation. Owner estimated ~65 if founder still active.",
        "L2": 55, "L2c": "7 SAFER power units vs 20+ website claim (mostly trailers/leased — asset base ambiguous). Below 10-truck SBA threshold per SAFER reading. HUB/DBE cert moat.",
        "L3": 80, "L3c": "38yr family op, Gmail contact riostruckingco@gmail.com (NOT company domain — major coasting tell), no copyright year, no team page, HUB/DBE TxDOT cert moat, USDOT 2005 registration vs 1988 founding (informal early years). 5 strong tells.",
        "L4": 78, "L4c": "Brazos Valley (Bryan-Hearne) +3 partial South TX / Central TX.",
        "confidence": "low", "thesis": "Strong coasting signal cluster but SAFER fleet below SBA threshold. If 20+ owned equipment claim verifies, upgrades to B-tier. Owner verification + asset-base audit required.",
    },
    52: {  # Asphalt Transport Inc — 159 trucks (SIZE EXCLUDE)
        "owner_age_estimate": None,
        "owner_age_source": "no_named_owner",
        "owner_tenure_years": None,
        "L1": 40, "L1c": "Owner identity opaque; VP Sales Bradley Burgess is public face.",
        "L2": 15, "L2c": "159 power units FAR EXCEEDS SBA 50-cap.",
        "L3": 30, "L3c": "29yr op, multi-state TX/OK/AR/TN footprint, specialty products division. 2 tells but scale undercuts.",
        "L4": 88, "L4c": "Houston Ship Channel + multi-state footprint +5 nudge.",
        "confidence": "low", "thesis": "EXCLUDE — fleet >50 trucks far exceeds SBA cap.",
        "force_tier": "D_pass",
    },
    53: {  # Loomis Trucking — 5 trucks + co-owner deceased (distressed but too small)
        "owner_age_estimate": 68,
        "owner_age_source": "1989_bbb_record_assume_~30_at_founding",
        "owner_tenure_years": 33,
        "L1": 80, "L1c": "Judy Loomis ~68 widowed 2023 (co-founder Terry Loomis deceased). 33yr tenure. Maximum natural-exit + distress pressure.",
        "L2": 20, "L2c": "5 vehicles (pickups + 1 semi). FAR below 10-truck SBA threshold.",
        "L3": 90, "L3c": "Co-founder deceased 2023, Judy runs dispatch FROM HOME, Loomisdoublet@gmail.com (not co domain), micro-fleet, no employee count, no team page, no copyright, no portal, no careers, 33yr op. 8+ strong tells but offset by micro-scale.",
        "L4": 80, "L4c": "Houston metro +5 nudge.",
        "confidence": "medium", "thesis": "STRONG distressed-seller signal (widowed, running dispatch from home, micro-fleet) BUT fleet too small for SBA. Roll-up tuck-in at best — flag for cross-vertical visibility / acqui-hire. Distress reason: co-owner deceased 2023.",
        "is_distressed": True,
        "distress_reasons": ["co_owner_terry_loomis_deceased_2023"],
        "force_tier": "D_pass",
    },
    54: {  # Atascosa Materials — 27 trucks NO website (STRONG B)
        "owner_age_estimate": None,
        "owner_age_source": "directory_contact_only_no_age",
        "owner_tenure_years": None,
        "L1": 50, "L1c": "Mike McCauley directory contact only. Founding year not disclosed but Blue Book listing since 2012 → 14+ yrs op.",
        "L2": 70, "L2c": "27 trucks + 25 drivers (perfect band). Pleasanton Eagle Ford corridor aggregate + ag + heavy haul.",
        "L3": 75, "L3c": "NO WEBSITE (strong tell), phone-only intake, Blue Book since 2012 (~14yr), Eagle Ford / Pleasanton booming corridor, owner identity opaque, mixed aggregate + ag + heavy haul pre-specialization, no online portal / team / copyright. 6 tells.",
        "L4": 82, "L4c": "Eagle Ford / South TX +3 nudge. Atascosa County Pleasanton corridor active.",
        "confidence": "low", "thesis": "Strong coasting signal cluster + sweet-spot fleet size. Owner verification via Comptroller + cold-call required for A/B promotion. C-watch.",
    },
    55: {  # Hearn Trucking — Jack Hearn Jr ~67, 39yr, 55 trucks (STRONG A but 5 above cap)
        "owner_age_estimate": 67,
        "owner_age_source": "started_one_truck_1987_assume_~28_at_founding",
        "owner_tenure_years": 39,
        "L1": 88, "L1c": "Jack Hearn Jr. ~67, 3rd-gen trucker (family tradition), 39yr personal tenure. Classic succession band. No named 4th-gen successor.",
        "L2": 72, "L2c": "55 power units (5 above 50-cap — marginal). Multi-service fleet (livestock + reefer + dry bulk + flatbed + step deck). Oil & Gas Awards 2013 'Trucking Company of the Year' = sellable accolade.",
        "L3": 78, "L3c": "Jack Hearn Jr. ~67 founder, 3rd-gen family tradition, 39yr personal tenure, started 1 truck grew to 55 (founder reinvestment), multi-service generalist fleet, no 4th-gen successor named, WordPress site age unclear. 6 tells.",
        "L4": 82, "L4c": "Weatherford (DFW exurban) — 0 metro nudge but hot exurban sub-market. Oil & Gas Awards 2013 = midcontinent reach.",
        "confidence": "medium", "thesis": "STRONG candidate at marginal scale (55 trucks = 5 above 50-cap). Lever: divest 5 trucks to land in target band OR independent-sponsor with $5-8M deal can stretch. Multi-service fleet provides cross-vertical exposure. Deep-dive for 4th-gen succession status critical.",
        "deep_dive_pending": True,
    },
    56: {  # Oden Transport — 6 trucks + BJ Oden ~40s (below threshold)
        "owner_age_estimate": None,
        "owner_age_source": "18_yr_industry_proxy_unknown_start_age",
        "owner_tenure_years": None,
        "L1": 30, "L1c": "BJ Oden ~40s-50s per 18yr industry proxy. Not in classic succession band.",
        "L2": 30, "L2c": "6 power units BELOW SBA threshold.",
        "L3": 45, "L3c": "6 trucks, 18yr industry proxy, BJ Oden Odessa residence vs Wilson HQ split, phone-first, generalist mix. 3 tells.",
        "L4": 78, "L4c": "Lubbock-south + Permian +5 partial.",
        "confidence": "low", "thesis": "Below SBA threshold + owner too young. DEPRIORITIZE.",
        "force_tier": "D_pass",
    },
    57: {  # Lubbock Cotton Growers — cooperative (EXCLUDE)
        "owner_age_estimate": None,
        "owner_age_source": "cooperative_entity_not_individual_owned",
        "owner_tenure_years": None,
        "L1": 15, "L1c": "Cooperative entity — not individually owned.",
        "L2": 15, "L2c": "Member-owned co-op, not acquirable as private business.",
        "L3": 15, "L3c": "Co-op governance, active growth (new gin), 6 trucks captive arm.",
        "L4": 70, "L4c": "Lubbock cotton belt.",
        "confidence": "high", "thesis": "EXCLUDE — member-owned cooperative gin trucking arm. Not acquirable.",
        "force_tier": "D_pass",
        "is_distressed": True,
        "distress_reasons": ["cooperative_entity_not_acquirable_as_private_business"],
    },
    58: {  # Petroleum Express duplicate of #47 (DROP)
        "owner_age_estimate": None,
        "owner_age_source": "duplicate_of_spine_index_47",
        "owner_tenure_years": None,
        "L1": 0, "L1c": "Duplicate.",
        "L2": 0, "L2c": "Duplicate.",
        "L3": 0, "L3c": "Duplicate.",
        "L4": 0, "L4c": "Duplicate.",
        "confidence": "high", "thesis": "DUPLICATE of spine_index 47 (same USDOT 1922866). Drop in dedup.",
        "force_tier": "D_pass",
        "is_distressed": True,
        "distress_reasons": ["duplicate_of_spine_index_47"],
        "drop": True,
    },
    59: {  # Fred Garrison Oil / Allstar Fuel — Gary Garrison ~65 3rd-gen, 51 trucks (B)
        "owner_age_estimate": 65,
        "owner_age_source": "3rd_gen_of_1948_founding_proxy",
        "owner_tenure_years": None,
        "L1": 70, "L1c": "Gary Garrison ~65 (3rd-gen of 1948 founding). 78yr op. 4th-gen successor not visible.",
        "L2": 65, "L2c": "51 power units (1 above 50-cap). Diversified fuel distribution (gas + diesel + propane + aviation + marine + lubricants). Multi-brand partnerships. NAICS overlap (424720 wholesale).",
        "L3": 40, "L3c": "78yr op, 3rd-gen Gary Garrison active CEO, GPS-dispatched fleet (MODERN), multi-office expansion (Plainview/FW/Permian/Graham), TFFA member, 4th-gen successor not visible. 3 tells — modernization pulls back.",
        "L4": 80, "L4c": "Panhandle Plainview + multi-office +3 nudge.",
        "confidence": "medium", "thesis": "B-tier watch. 4th-gen succession gap with Gary in classic age band, but modernized operating posture suggests engaged operator not coasting. NAICS overlap with fuel wholesale (424720) complicates trucking carve-out. Deep-dive for 4th-gen status + revenue mix required.",
    },
    60: {  # Southeast Texas Timber — 2 trucks micro (DROP)
        "owner_age_estimate": None,
        "owner_age_source": "29_yr_tenure_no_age_disclosure",
        "owner_tenure_years": 29,
        "L1": 50, "L1c": "Todd R Mayo President since 1997. Could be 50s-60s.",
        "L2": 20, "L2c": "2 power units (micro-operator). Hardin County declining timber region.",
        "L3": 60, "L3c": "2 trucks, NO website, 29yr op, single principal, phone-only, declining East TX timber. 4 tells but micro-scale.",
        "L4": 60, "L4c": "Hardin County East TX timber declining.",
        "confidence": "low", "thesis": "Below SBA scale (2 trucks). Roll-up tuck-in only. DROP.",
        "force_tier": "D_pass",
    },
    61: {  # Petroleum Transport Inc — SAFER INACTIVE (DISTRESSED)
        "owner_age_estimate": None,
        "owner_age_source": "ultra_low_USDOT_proxy_pre-1980_likely",
        "owner_tenure_years": None,
        "L1": 20, "L1c": "SAFER inactive flag — cannot verify operating.",
        "L2": 15, "L2c": "INACTIVE SAFER. Hard gate fail: cannot verify business operating.",
        "L3": 30, "L3c": "USDOT 227383 pre-1980, no website, 19 trucks 7 drivers (unusual ratio), phone-only, owner opaque. 4 tells but distress dominates.",
        "L4": 60, "L4c": "Lubbock fuel hauling.",
        "confidence": "high", "thesis": "DISTRESSED — SAFER inactive flag. Hard gate fail.",
        "force_tier": "D_pass",
        "is_distressed": True,
        "distress_reasons": ["safer_record_marked_inactive_per_spine"],
    },
    62: {  # Coastal Plains Trucking — 15yr Lufkin/Eagle Ford crude
        "owner_age_estimate": None,
        "owner_age_source": "no_named_owner_on_website",
        "owner_tenure_years": 15,
        "L1": 35, "L1c": "15yr op, owner identity opaque.",
        "L2": 65, "L2c": "Started 10 trucks May 2011 — current fleet undisclosed but grown. Multi-commodity crude + cryogenics + CNG + water + diesel + jet fuel. Eagle Ford + Permian + Delaware multi-basin.",
        "L3": 30, "L3c": "Modern driver portal at cptportal.net, multi-commodity active growth, multi-basin service. 2 tells — modernization dominates.",
        "L4": 85, "L4c": "Lufkin HQ + multi-basin Eagle Ford / Permian / Delaware +5 nudge.",
        "confidence": "low", "thesis": "Active growth + modernization posture. Owner identity opacity caps. C-watch.",
    },
    63: {  # Meridian Trucking — self-described 'newer' (EXCLUDE)
        "owner_age_estimate": None,
        "owner_age_source": "newer_company_proxy_younger_ownership",
        "owner_tenure_years": None,
        "L1": 15, "L1c": "Self-described 'fresh face / newer company'.",
        "L2": 35, "L2c": "Permian generalist multi-trailer fleet. Owner identity opaque.",
        "L3": 20, "L3c": "Active careers page, named non-owner team. 2 tells — active growth.",
        "L4": 80, "L4c": "Permian Midland-born +5 nudge.",
        "confidence": "medium", "thesis": "DEPRIORITIZE — explicit 'newer company' framing fails sellability gate.",
        "force_tier": "D_pass",
    },
    64: {  # Iron Wheel Energy — Benjamin Kail serial entrepreneur (EXCLUDE)
        "owner_age_estimate": None,
        "owner_age_source": "career_proxy_2011_PMK_start",
        "owner_tenure_years": 6,
        "L1": 20, "L1c": "Benjamin Kail (~40s) serial trucking entrepreneur restarted 2020 after exiting TegraExcel.",
        "L2": 30, "L2c": "Only 6yr operation, fails 5-yr soft gate barely. Prior co TegraExcel peaked 150 trucks 2018 — Kail is scale builder, not coaster.",
        "L3": 15, "L3c": "Active growth mode, family-owned with brother Martin involved, building toward strategic exit. 1 tell offset by active build.",
        "L4": 80, "L4c": "Permian-only.",
        "confidence": "high", "thesis": "EXCLUDE — serial scale-builder actively building toward strategic exit, not natural succession. Recent founding (6yr) fails sellability gate.",
        "force_tier": "D_pass",
    },
    65: {  # Texas Trucking Group — about-page 404 (EXCLUDE)
        "owner_age_estimate": None,
        "owner_age_source": "no_disclosure",
        "owner_tenure_years": None,
        "L1": 0, "L1c": "Cannot verify business is real/operating.",
        "L2": 0, "L2c": "USDOT not disclosed, phone not on site, address not on site, about-page 404. Hard gate fail.",
        "L3": 0, "L3c": "Verification failure across all signals.",
        "L4": 0, "L4c": "N/A.",
        "confidence": "high", "thesis": "DROP — Hard gate fail: cannot verify business is real. Possibly broker shell.",
        "force_tier": "D_pass",
        "is_distressed": True,
        "distress_reasons": ["usdot_not_disclosed_public_about_404_unverified_entity"],
        "drop": True,
    },
    66: {  # Twisted Nail — Hunter Kosar ~40 brokerage (EXCLUDE)
        "owner_age_estimate": 40,
        "owner_age_source": "baylor_grad_proxy_~30_at_founding",
        "owner_tenure_years": 12,
        "L1": 15, "L1c": "Hunter Kosar ~40 — TOO YOUNG for succession band.",
        "L2": 15, "L2c": "100% owner-op brokerage (no asset base). Not acquirable as fleet-asset target.",
        "L3": 15, "L3c": "Active growth (1M+ tons messaging), Baylor commercial relationships, copyright 2026. 1 tell but active build.",
        "L4": 82, "L4c": "Central TX (Austin/Waco/SA) aggregate corridor.",
        "confidence": "high", "thesis": "EXCLUDE — brokerage with no fleet assets + young founder active growth.",
        "force_tier": "D_pass",
    },
    67: {  # U.S. Sand & Gravel — Raitz ~42 active growth (EXCLUDE)
        "owner_age_estimate": 42,
        "owner_age_source": "tarleton_grad_2015_founding_proxy_~30_at_founding",
        "owner_tenure_years": 11,
        "L1": 15, "L1c": "Casey + Celeste Raitz Tarleton grads ~42 — too young.",
        "L2": 30, "L2c": "Active scale-up 7x growth/yr. 100+ employees. Multiple pits + rental + concrete sister businesses.",
        "L3": 10, "L3c": "Active growth, ribbon cuttings, diversifying. Not coasting.",
        "L4": 78, "L4c": "Stephenville TX dairy + DFW corridor.",
        "confidence": "high", "thesis": "EXCLUDE — Raitz family active scale-up, multiple growing sister businesses. Wrong life-stage.",
        "force_tier": "D_pass",
    },
    68: {  # Nichols Transportation — 31yr East TX, owner opaque
        "owner_age_estimate": 60,
        "owner_age_source": "31_yr_tenure_proxy_~30_at_founding",
        "owner_tenure_years": 31,
        "L1": 65, "L1c": "Nichols family 31yr op. Founder cohort estimated ~60.",
        "L2": 55, "L2c": "Heavy haul + RGN East TX (Kilgore/Longview/Tyler/Henderson). Mining + energy + construction + logging multi-trade. Fleet undisclosed.",
        "L3": 60, "L3c": "31yr op, owner identity Nichols family but principal opaque, no team page, no founder bio, multi-trade East TX, Facebook only social. 4 tells.",
        "L4": 78, "L4c": "East TX (Kilgore oil-tied) +3 partial.",
        "confidence": "low", "thesis": "Promising 31yr family op but owner identity gap. Comptroller required for B/A tier. C-watch.",
    },
    69: {  # Texas Panhandle Logistics — 8yr woman-owned (C-watch)
        "owner_age_estimate": None,
        "owner_age_source": "no_disclosure_email_proxy_only",
        "owner_tenure_years": 8,
        "L1": 25, "L1c": "8yr tenure barely passes 5yr soft gate. Owner first name opaque.",
        "L2": 50, "L2c": "Reefer (perishables + dairy + flowers + pharma) + general freight. Texas Panhandle dairy belt. Sister biz 'Weather Seal Insulation' suggests holding-co.",
        "L3": 30, "L3c": "Woman-owned + family-owned, sister biz shared branding, dairy belt regional specialization, pharma/produce cold-chain. 3 tells but limited tenure.",
        "L4": 75, "L4c": "Panhandle dairy +3 nudge.",
        "confidence": "low", "thesis": "Recent founding limits succession profile. C-watch.",
    },
    70: {  # Diamond B Energy Services — 129 trucks (SIZE EXCLUDE)
        "owner_age_estimate": None,
        "owner_age_source": "13_yr_operation_BBB_no_age_disclosure",
        "owner_tenure_years": 13,
        "L1": 30, "L1c": "Ben Burkholder active CEO. 13yr op.",
        "L2": 15, "L2c": "129 power units FAR EXCEEDS SBA 50-cap. $50-100M revenue.",
        "L3": 25, "L3c": "Sister Salty Dawg, active recruiting, multi-state. 2 tells but scale undercuts.",
        "L4": 80, "L4c": "Lubbock + TX/OK/LA/NM.",
        "confidence": "medium", "thesis": "EXCLUDE — fleet >50 + $50-100M revenue far exceeds SBA cap. PE/strategic buyer fit only.",
        "force_tier": "D_pass",
    },
}


def load_enrichment():
    records = []
    for p in BATCH_PATHS:
        with open(p) as f:
            records.extend(json.load(f))
    return records


def score_record(rec):
    idx = rec["spine_index"]
    cfg = SCORES.get(idx)
    if cfg is None:
        # safety net — shouldn't happen
        cfg = {
            "owner_age_estimate": None, "owner_age_source": "unverified", "owner_tenure_years": None,
            "L1": 30, "L1c": "Insufficient data.",
            "L2": 30, "L2c": "Insufficient data.",
            "L3": 30, "L3c": "Insufficient data.",
            "L4": 30, "L4c": "Insufficient data.",
            "confidence": "low", "thesis": "Insufficient enrichment data — needs additional verification.",
        }

    if cfg.get("drop"):
        return None  # signal to skip output entirely

    L1, L2, L3, L4 = cfg["L1"], cfg["L2"], cfg["L3"], cfg["L4"]
    raw_final = 0.30 * L1 + 0.25 * L2 + 0.30 * L3 + 0.15 * L4
    final = int(round(raw_final))

    # Hard gates
    is_distressed = cfg.get("is_distressed", rec.get("is_distressed", False))
    distress_reasons = cfg.get("distress_reasons", rec.get("distress_reasons", []) or [])
    years = rec.get("years_in_business")
    confidence = cfg.get("confidence", "low")
    deep_dive_pending = cfg.get("deep_dive_pending", False)
    force_tier = cfg.get("force_tier")

    if is_distressed:
        final = min(final, 25)
    if years is not None and years < 5:
        final = min(final, 35)

    # Tier assignment
    if force_tier:
        tier = force_tier
        if force_tier == "D_pass" and not is_distressed and final >= 45:
            # Force tier without distress — clamp final to reflect tier
            final = min(final, 44)
    else:
        if final >= 78:
            tier = "A_acquire_self"
        elif final >= 60:
            tier = "B_forward"
        elif final >= 45:
            tier = "C_watch"
        else:
            tier = "D_pass"

    # A-tier guard rails
    if tier == "A_acquire_self":
        if confidence == "low":
            tier = "B_forward"
        if L1 < 70 or L3 < 65:
            tier = "B_forward"
        if is_distressed:
            tier = "D_pass"

    # Canonical: mark deep_dive_pending=true for any final >= 78 (orchestrator
    # handles deep-dive verification post-scoring).
    if final >= 78 and not is_distressed:
        deep_dive_pending = True

    # Distress + <5yr distillation
    if is_distressed:
        tier = "D_pass"
    if years is not None and years < 5:
        if tier == "A_acquire_self":
            tier = "C_watch"
        elif tier == "B_forward":
            tier = "C_watch"

    # Fleet size effective gate (trucking-specific):
    # 10-50 trucks = SBA-financeable sweet spot.
    # 51-60 = "just above cap" — cap at B_forward (orchestrator's framing).
    # >60 = hard SBA exclude → D_pass.
    # <10 = too small for SBA → C_watch.
    fleet = rec.get("fleet_size") or rec.get("fleet_size_estimate")
    if fleet is not None:
        if fleet > 60 and tier not in ("D_pass",):
            tier = "D_pass"
        elif 51 <= fleet <= 60 and tier == "A_acquire_self":
            tier = "B_forward"
        elif fleet < 10 and tier in ("A_acquire_self", "B_forward"):
            tier = "C_watch"

    layer1_comment = cfg["L1c"]
    layer2_comment = cfg["L2c"]
    layer3_comment = cfg["L3c"]
    layer4_comment = cfg["L4c"]

    final_comment = (
        f"L1 {L1}/L2 {L2}/L3 {L3}/L4 {L4} → {final}. {cfg.get('thesis', '')}"
    )
    if deep_dive_pending:
        final_comment += " Deep-dive pending."

    return {
        "legal_name": rec.get("legal_name"),
        "dba_name": rec.get("dba_name"),
        "city": rec.get("city"),
        "county": rec.get("county"),
        "state": rec.get("state", "TX"),
        "zip": rec.get("zip"),
        "vertical": VERTICAL,
        "naics_code": NAICS,
        "license_number": rec.get("fmcsa_dot_number"),
        "license_holder_name": None,
        "license_issue_date": None,
        "owner_name": rec.get("owner_name"),
        "owner_age_estimate": cfg.get("owner_age_estimate"),
        "owner_age_source": cfg.get("owner_age_source"),
        "owner_tenure_years": cfg.get("owner_tenure_years"),
        "years_in_business": rec.get("years_in_business"),
        "year_established": rec.get("year_established") or rec.get("founded_year"),
        "employee_count_estimate": rec.get("driver_count"),
        "fleet_size": rec.get("fleet_size") or rec.get("fleet_size_estimate"),
        "specialty": rec.get("specialty"),
        "fmcsa_dot_number": rec.get("fmcsa_dot_number"),
        "mc_number": rec.get("mc_number"),
        "entity_status": rec.get("entity_status"),
        "is_distressed": is_distressed,
        "distress_reasons": distress_reasons,
        "website": rec.get("website"),
        "phone": rec.get("phone"),
        "data_sources": rec.get("data_sources", []),
        "score_run_id": SCORE_RUN_ID,
        "layer1_base_rate": L1,
        "layer1_comment": layer1_comment,
        "layer2_sellability": L2,
        "layer2_comment": layer2_comment,
        "layer3_behavioral_trigger": L3,
        "layer3_comment": layer3_comment,
        "layer4_market_pull": L4,
        "layer4_comment": layer4_comment,
        "final_score": final,
        "final_tier": tier,
        "final_comment": final_comment,
        "value_add_thesis": cfg.get("thesis", ""),
        "confidence": confidence,
        "data_completeness": rec.get("data_completeness"),
        "deep_dive_pending": deep_dive_pending,
    }


def write_outputs(scored):
    # JSON full
    with open(OUT_JSON, "w") as f:
        json.dump(scored, f, indent=2)
    # CSV flat
    fields = [
        "legal_name", "city", "county", "state", "zip", "vertical", "naics_code",
        "owner_name", "owner_age_estimate", "owner_age_source", "owner_tenure_years",
        "years_in_business", "year_established", "fleet_size", "employee_count_estimate",
        "specialty", "fmcsa_dot_number", "mc_number", "entity_status",
        "is_distressed", "distress_reasons", "website", "phone",
        "score_run_id", "layer1_base_rate", "layer2_sellability",
        "layer3_behavioral_trigger", "layer4_market_pull",
        "final_score", "final_tier", "confidence", "data_completeness", "deep_dive_pending",
    ]
    with open(OUT_CSV, "w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=fields)
        w.writeheader()
        for s in scored:
            row = {k: s.get(k) for k in fields}
            if isinstance(row["distress_reasons"], list):
                row["distress_reasons"] = "; ".join(row["distress_reasons"])
            w.writerow(row)


def main():
    recs = load_enrichment()
    scored = []
    for r in recs:
        result = score_record(r)
        if result is None:
            continue  # dropped
        scored.append(result)
        # Persist incrementally
        with open(OUT_JSON, "w") as f:
            json.dump(scored, f, indent=2)
    write_outputs(scored)
    # Summary
    tiers = {"A_acquire_self": 0, "B_forward": 0, "C_watch": 0, "D_pass": 0}
    for s in scored:
        tiers[s["final_tier"]] += 1
    print(f"Scored {len(scored)} businesses. Tier counts: {tiers}")
    # Top by tier
    for tier in ("A_acquire_self", "B_forward", "C_watch"):
        rows = sorted(
            [s for s in scored if s["final_tier"] == tier],
            key=lambda x: -x["final_score"],
        )[:5]
        if rows:
            print(f"\nTop {tier}:")
            for r in rows:
                print(
                    f"  {r['final_score']} | {r['legal_name']} ({r['city']}, {r['state']}) — fleet={r.get('fleet_size')} yrs={r.get('years_in_business')} conf={r['confidence']}"
                )


if __name__ == "__main__":
    main()
