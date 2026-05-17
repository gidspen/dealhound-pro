"""Score CNC machine shops (NAICS 332710) per canonical 4-layer model.

Input: offmarket/data/cnc_machine_shop_enrich_batch_{1,2,3}.json
Output: offmarket/data/cnc_machine_shop_targets.json + .csv
"""
from __future__ import annotations

import csv
import json
import os
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DATA = ROOT / "data"

SCORE_RUN_ID = "becddbcf-bcef-4bb1-80b9-95fed0635545"
VERTICAL = "cnc_machine_shop"
NAICS = "332710"

# Exclusions per orchestrator brief
EXCLUDE_NAMES = {
    "Owens Machine and Tool Company",  # PE-acquired May 2024 (Precision Aerospace Holdings)
    "Icon Machine Company",  # PE-acquired Aug 2022 (Precision Aerospace Holdings)
    "Neo Industries Corporation",  # 2019 ownership transition, new owners only 7yr in
    "B&R Productions — San Antonio service branch",  # duplicate of New Waverly
    "C & M Machining LP — Sugar Land branch",  # duplicate of Navasota
    "Rigid Concepts LLC",  # 2015 founding, growth-mode (anti-fit)
    "JIREH CNC Machining",  # 2021 founding, growth-mode
    "Jireh Precision Machining",  # Houston Jireh, young growth-mode
    "Texas Machining & Sales, Inc.",  # NC HQ, not TX-independent
    "Texas Contract Manufacturing Group (TCMG)",  # multi-subsidiary group
    "Mitchell Crane",  # primary biz is cranes, CNC is secondary division
    "A & A Machine & Fabrication LLC",  # >$30M ceiling — international (Beijing rep office)
    "Conroe Machine",  # >$30M ceiling — 65K sqft, full API Q1 + AS9100 + ITAR stack
    "Alloy CNC Inc",  # >$30M ceiling — 80K sqft Conroe facility
    "Snoe Inc., Machining and Welding",  # >$30M ceiling — 63K sqft, 53 CNC, JCP/DDTC defense
    "Automatic Products Corporation (APC)",  # >$30M ceiling — 118K sqft, PMPA leader
    "Mann Made Industries / G01 Enterprises Inc.",  # primary biz is aluminum extrusion (out of scope)
}

# Pre-curated scoring decisions per record (one per business surviving the gates).
# Notes follow the canonical methodology:
# L1 (0.30): owner age band + tenure modifier
# L2 (0.25): real, healthy, SBA-financeable
# L3 (0.30): coasting tells (vertical adj: aerospace cert is anti-coast; legacy CAD/MANUAL is coast)
# L4 (0.15): Houston/DFW +5; Austin +5; SA +3; East TX 0; Rural -3. AS9100 +10 / ISO +5 / ITAR +5 / API +5.
# Confidence: high (≥0.85 data_completeness), medium (0.65-0.84), low (<0.65)
SCORES: list[dict] = [
    # === BATCH 1 ===
    {
        "legal_name": "Reliable Machinists Corporation",
        "l1": 90, "l1_c": "Founder Chung Nguyen ~70 (FMC 1976 → RMC 1981, 45-yr tenure). 68+ band + tenure-modifier +3.",
        "l2": 70, "l2_c": "Stable oilfield API 6A/17D specialty 45-yr book, ~18 employees. SBA-financeable solo profile.",
        "l3": 75, "l3_c": "8 strong tells: mid-2000s site no copyright, no equipment brands, JobBoss legacy ERP, generic CAM, no hiring page, no socials, pure-oilfield niche, phone-only intake.",
        "l4": 78, "l4_c": "Houston metro (Harris) +5 oil-and-gas pull; ISO/AS9100/ITAR absent but API 6A/17D present (+5 = 83 base, adjusted).",
        "tier_override": None, "confidence": "medium", "data_completeness": 0.7,
        "thesis": "Acquire 45-yr Houston oilfield API specialist Chung Nguyen book. Modernize ERP (off JobBoss), add CMM/SPC, layer ISO 9001 → land aerospace/medical sub-mix → 1.5-2x EBITDA in 3yrs.",
        "deep_dive_pending": True,
    },
    {
        "legal_name": "MIC-ALL Machining, Inc.",
        "l1": 35, "l1_c": "Owner age not confirmed; Leslie Little proxy ~50s. Without verified age, weak-proxy band.",
        "l2": 58, "l2_c": "Small rural shop ~8 employees, modern Okuma/ENSHU. ISO 'compliant' but not certified — limits SBA aerospace/defense premium.",
        "l3": 60, "l3_c": "7 tells: no founding year, ISO compliance (not certified), rural FM-389 Burton, mid-2010s site, no CAM software, no 5-axis/fiber laser, partner-team only.",
        "l4": 55, "l4_c": "Rural Washington county (-3) between Houston/Austin. No certifications for market premium.",
        "tier_override": None, "confidence": "low", "data_completeness": 0.55,
        "thesis": "Bolt-on rural-TX small shop with modern Okuma/ENSHU fleet. Long path to ETA value — needs full ownership verification before pursuing.",
        "deep_dive_pending": False,
    },
    {
        "legal_name": "MSM Machine Works",
        "l1": 25, "l1_c": "Owner not named, founding not disclosed, only 'decades of experience' tell. Weak proxy band.",
        "l2": 45, "l2_c": "Generic mixed-vertical job shop ~12 employees, no certifications, eastside Houston Hershe St. Hard to qualify SBA-grade.",
        "l3": 60, "l3_c": "8 tells: owner unnamed, no founding year, no equipment, no CAM, no certs, no social, generic 6-vertical pitch, modern 2024 site.",
        "l4": 70, "l4_c": "Houston metro (Harris) +5 base. No certs for premium uplift.",
        "tier_override": None, "confidence": "low", "data_completeness": 0.5,
        "thesis": "Eastside Houston job-shop wildcard. Needs phone/in-person discovery for any acquirer interest.",
        "deep_dive_pending": False,
    },
    {
        "legal_name": "Midway Machine & Instrument Company",
        "l1": 78, "l1_c": "Owner ~65 (1982 founding proxy). 63-67 band, +3 for 44-yr personal tenure.",
        "l2": 80, "l2_c": "AS9100D + ISO 9001:2015, DMG MORI fleet, 25K sqft aerospace/biomedical mid-size — solid SBA-financeable.",
        "l3": 45, "l3_c": "6 tells (mixed): mid-2010s site, ambiguous founding year — but hiring page open + DMG MORI investment + AS9100 active = growth-mode, not coasting.",
        "l4": 88, "l4_c": "Houston metro +5 + AS9100 +10 + ISO 9001 +5 = +20 from base 70.",
        "tier_override": None, "confidence": "medium", "data_completeness": 0.7,
        "thesis": "South Houston aerospace/biomedical mid-size with recent DMG MORI investment. Owner age 65 plausible exit but growth-mode posture — closer to B-tier than classic coast.",
        "deep_dive_pending": False,
    },
    {
        "legal_name": "U.C. Precision, Inc.",
        "l1": 25, "l1_c": "Owner age unknown; founding year not stated. Weak proxy band.",
        "l2": 65, "l2_c": "Recently ISO 9001:2015 certified (Nov 2024) — actively maturing, ~10 employees, Doosan/Mori Seiki fleet.",
        "l3": 30, "l3_c": "6 tells but anti-coast pattern: recent cert + 2025 copyright + 'small but nimble' + 4-day turnaround = competitive, not coasting.",
        "l4": 80, "l4_c": "NW Houston (Harris) +5 + ISO 9001 +5 = 80 base.",
        "tier_override": None, "confidence": "low", "data_completeness": 0.5,
        "thesis": "NW Houston nimble competitor with fresh ISO. Not classic coast — skip unless ownership intel surfaces age signal.",
        "deep_dive_pending": False,
    },
    {
        "legal_name": "RBR Machine",
        "l1": 25, "l1_c": "Owner not named, founding year not stated. Weak proxy band.",
        "l2": 80, "l2_c": "ISO 9001 + AS9100D + ISO 13485 (medical) + ITAR + CAGE/DUNS-registered + 165\" milling capacity = high-end aerospace/medical, ~25 employees.",
        "l3": 35, "l3_c": "6 tells but anti-coast: cert-stack + large-capacity investment + active socials = modern posture not coasting.",
        "l4": 92, "l4_c": "Houston (Harris) +5 + AS9100 +10 + ISO 9001 +5 + ITAR +5 = high stack.",
        "tier_override": None, "confidence": "low", "data_completeness": 0.55,
        "thesis": "High-end Houston aerospace/medical multi-cert shop. Not a coasting target — too modern. Skip unless owner age signal surfaces.",
        "deep_dive_pending": False,
    },
    {
        "legal_name": "S.T.B. Machine Works",
        "l1": 82, "l1_c": "Founder ~67 (1980 → 46-yr personal tenure proxy). 63-67 band, tenure modifier +5.",
        "l2": 72, "l2_c": "ISO 9001 + Mazak/HURCO/Haas fleet, 11K sqft on 1.3 acres (likely owned), 46-yr oilfield-aerospace book. Solid SBA-financeable.",
        "l3": 78, "l3_c": "STRONG: site copyright frozen at 2016-2017 (9yr stale), social links non-functional placeholders, no AS9100/ITAR, owner-unnamed, land-rich Acres Homes location, no equipment refresh visible.",
        "l4": 80, "l4_c": "Houston metro (Harris) +5 + ISO 9001 +5 = 80 (no AS9100/ITAR uplift).",
        "tier_override": None, "confidence": "medium", "data_completeness": 0.7,
        "thesis": "STB Acres Homes Houston — 46-yr founder, frozen-since-2017 site + land-rich + Mazak fleet = textbook coast. Modernize digital ops + add AS9100 to monetize oilfield/subsea/aerospace cross-sell.",
        "deep_dive_pending": True,
    },
    {
        "legal_name": "Cutting Source Precision, Inc.",
        "l1": 30, "l1_c": "Founder not named (woman-owned, founded 2000); age unknown. Weak proxy band.",
        "l2": 70, "l2_c": "ISO 9001 + ISO/TS 29001:2010 (oilfield spec) + ASME NQA-1 (nuclear) + 26-yr tenure. Niche cert posture, ~15 employees.",
        "l3": 45, "l3_c": "4 tells (mixed): GoDaddy site copyright frozen 2021 + hiring open. Active certs maintained = mid-coast signal not classic.",
        "l4": 80, "l4_c": "NW Houston (Harris) +5 + ISO 9001 +5 + nuclear NQA-1 cert premium = 80.",
        "tier_override": None, "confidence": "low", "data_completeness": 0.55,
        "thesis": "Woman-owned Houston nuclear/oilfield-niche shop with stale site but active hiring. Interesting cert combo but owner age unknown — skip unless intel surfaces.",
        "deep_dive_pending": False,
    },
    {
        "legal_name": "Turbine Component Repair Inc.",
        "l1": 30, "l1_c": "Owner unnamed, founding year missing. Logo dated 2015 suggests ~10yr+ but no firm anchor.",
        "l2": 65, "l2_c": "ISO 9001:2015 (ABS #54215), turbine-specialty niche, 78\" diameter capacity. ~15 employees. Modest SBA-financeable.",
        "l3": 60, "l3_c": "7 tells: owner unnamed, founding unstated, 2015 logo, mid-2010s site, inner-loop Pinemont older industrial corridor, generic socials only.",
        "l4": 80, "l4_c": "Houston (Harris) +5 + ISO 9001 +5 = 80 base.",
        "tier_override": None, "confidence": "low", "data_completeness": 0.55,
        "thesis": "Houston inner-loop turbine-specialty niche. Phone/LinkedIn enrichment required before acquisition workup.",
        "deep_dive_pending": False,
    },
    {
        "legal_name": "Ed's Precision Manufacturing, LLC",
        "l1": 85, "l1_c": "Owner ~68 ('Ed' eponymous + 39-yr tenure proxy). 68+ band, tenure modifier +3.",
        "l2": 75, "l2_c": "ISO 9001 + ITAR + CAGE/CMMC Level-1 + EJCP cert + 39-yr aerospace/medical/oilfield mix, ~18 employees. SBA-financeable.",
        "l3": 80, "l3_c": "STRONG: eponymous 'Ed's' = single-founder succession risk + no equipment brands + no CAM software + no socials + no successor + government-registered (CAGE).",
        "l4": 85, "l4_c": "Houston (Harris) +5 + ISO +5 + ITAR +5 = 85.",
        "tier_override": None, "confidence": "medium", "data_completeness": 0.7,
        "thesis": "Ed's Precision — classic eponymous-founder coast: ITAR + 39-yr book + no successor + no marketing investment. Acquire, name-detach to broader brand, modernize digital ops + ISO upgrade.",
        "deep_dive_pending": True,
    },
    {
        "legal_name": "H&W Manufacturing",
        "l1": 90, "l1_c": "Owner pair likely ~70 (1978 founding, 48-yr tenure proxy, 'H&W' = founder initials). 68+ band, tenure +5.",
        "l2": 72, "l2_c": "Family-owned 48-yr Swiss-screw/EDM/auto-screw specialist, owns 34K sqft (built 2009), ~22 employees. SBA-financeable solo profile.",
        "l3": 80, "l3_c": "STRONG: 8 tells — H&W initials only (founder pair), no owner named, no certs, no equipment brands, no CAM software, modest FB/LinkedIn, building owned, 48yr family-owned language.",
        "l4": 75, "l4_c": "Spring (N Harris, Houston metro) +5 = 75 base. No cert uplift.",
        "tier_override": None, "confidence": "medium", "data_completeness": 0.65,
        "thesis": "H&W Spring — 48-yr Swiss-screw specialist, founder pair (H+W) ~70, owns building, zero cert overhead. Modernize Swiss capacity for medical/aerospace + add AS9100 to unlock premium book.",
        "deep_dive_pending": True,
    },
    {
        "legal_name": "Rockwell Precision",
        "l1": 82, "l1_c": "Owner ~65 (1979 founding, 47-yr tenure proxy; Dan Cotrino contact). 63-67 band, tenure +5.",
        "l2": 70, "l2_c": "ISO 9001 + 47-yr 'family-owned legacy' + ~20 employees + oilfield/construction diversified. SBA-financeable.",
        "l3": 70, "l3_c": "8 tells: no owner named explicitly (only contact), single ISO cert, no equipment brands, no CAM, modest socials, career page open (mild anti-coast), modern responsive site.",
        "l4": 80, "l4_c": "NW Houston FM 1960/249 corridor (Harris) +5 + ISO +5 = 80.",
        "tier_override": None, "confidence": "medium", "data_completeness": 0.65,
        "thesis": "Rockwell NW Houston — 47-yr family legacy, single ISO cert, diversified book. Verify Dan Cotrino age + successor status; classic coast if 65+. Modernize quoting + add AS9100 for aerospace pull.",
        "deep_dive_pending": True,
    },
    {
        "legal_name": "ABCD Precision, Inc.",
        "l1": 40, "l1_c": "Founder ~55 (2012 founding); only 14yr tenure — too young for retirement-exit band.",
        "l2": 55, "l2_c": "ISO 9001:2015 + CAGE Code + 14-yr O&G shop, ~8 employees. Site neglect mild distress signal.",
        "l3": 55, "l3_c": "6 tells: gallery frozen Dec 2018, Joomla mid-2010s tech, possible SEO injection, no successor; founding 2012 limits 'coasting' framework.",
        "l4": 80, "l4_c": "NW Houston (Harris) +5 + ISO +5 = 80.",
        "tier_override": "C_watch", "confidence": "low", "data_completeness": 0.5,
        "thesis": "ABCD Precision — too young for classic coast. Watch only.",
        "deep_dive_pending": False,
    },
    {
        "legal_name": "EDM of Texas Manufacturing",
        "l1": 28, "l1_c": "Owner age unknown; 31-yr tenure but no founder anchor. Weak proxy band.",
        "l2": 65, "l2_c": "EDM specialist niche, FDA/GMP/3-A standards, 24/7 ops, multi-state book TX/MI/IL/CA. ~10 employees. SBA-financeable.",
        "l3": 35, "l3_c": "6 tells (mixed): suite-only address rented (not owned), modern site, 24/7 ops, multi-state reach — competitive posture not classic coast.",
        "l4": 80, "l4_c": "N Houston (Harris) +5 = 80 base (no certs).",
        "tier_override": None, "confidence": "low", "data_completeness": 0.5,
        "thesis": "EDM Texas — 31-yr competitive EDM specialist, suite-rented, multi-state. Not a coasting acquisition target; skip.",
        "deep_dive_pending": False,
    },
    {
        "legal_name": "Centerline Manufacturing, LTD.",
        "l1": 35, "l1_c": "Owner unnamed, founded 2005 (21yr). LTD entity = partnership. Weak proxy band.",
        "l2": 78, "l2_c": "AS9100D + ISO 9001:2015 + ITAR + NDIA member, ~18 employees, 21-yr aerospace/defense/medical book. SBA-financeable.",
        "l3": 45, "l3_c": "6 tells (mixed): owner unnamed, LTD entity = partnership, NW Houston FM 529 corridor — but cert-rich + 'Single-Source American' marketing = active posture.",
        "l4": 92, "l4_c": "Houston (Harris) +5 + AS9100 +10 + ISO +5 + ITAR +5 = 92.",
        "tier_override": None, "confidence": "low", "data_completeness": 0.55,
        "thesis": "Centerline — 21-yr cert-stack aerospace partnership. Too young for classic coast; need partner-age intel before pursuing.",
        "deep_dive_pending": False,
    },
    # Index 15 = A & A Machine & Fabrication LLC → EXCLUDED (>$30M international)
    {
        "legal_name": "EMD",
        "l1": 30, "l1_c": "Owner unnamed, only '30+ years' tell. Weak proxy band.",
        "l2": 62, "l2_c": "ISO 9001:2015 single cert, mold/tooling + CNC + wire EDM heritage niche, ~15 employees. SBA-financeable but tooling segment declining.",
        "l3": 70, "l3_c": "7 tells: owner unnamed, no founding year, IG-only social, no equipment, no CAM, single ISO cert, mold-tooling heritage (declining segment).",
        "l4": 80, "l4_c": "NW Houston (Harris) +5 + ISO +5 = 80.",
        "tier_override": None, "confidence": "low", "data_completeness": 0.55,
        "thesis": "EMD Houston NW — mold-tooling-heritage 30yr coast signal but no owner anchor. Phone enrichment needed.",
        "deep_dive_pending": False,
    },
    # Index 17 = Conroe Machine → EXCLUDED (>$30M)
    # Index 18 = Alloy CNC → EXCLUDED (>$30M)
    {
        "legal_name": "TXSwiss",
        "l1": 25, "l1_c": "Owner unnamed, ~20yr tenure (founded ~2005). Weak proxy band.",
        "l2": 70, "l2_c": "ISO 9001:2015 + CAGE + 13-axis Swiss-screw specialist, ~20 employees. Niche SBA-financeable.",
        "l3": 30, "l3_c": "6 tells but anti-coast: active hiring + modern site + 13-axis high-end equipment = competitive, not coasting.",
        "l4": 80, "l4_c": "Conroe (Montgomery, Houston metro) +5 + ISO +5 = 80.",
        "tier_override": None, "confidence": "low", "data_completeness": 0.5,
        "thesis": "TXSwiss — modern Swiss-screw specialist in active growth. Not coast — skip.",
        "deep_dive_pending": False,
    },
    {
        "legal_name": "B&R Productions",
        "l1": 60, "l1_c": "Owner unnamed (B&R = two-owner initials); 32-yr tenure. Mid-band proxy.",
        "l2": 75, "l2_c": "ISO 9001 + API 6A + 25+ CNC machines + 20K parts/month + 35 employees + diversified aerospace/defense/oilfield book. SBA-financeable.",
        "l3": 75, "l3_c": "8 tells: B&R initials suggest partner pair, OLDER-GEN equipment fleet (Monarch/Bridgeport/Clausing/Fadal/Warner Swasey 1980s-90s), Korean import lower-tier, single ISO (no AS9100 cert), no socials, rural New Waverly.",
        "l4": 75, "l4_c": "New Waverly rural (Walker, Conroe-Huntsville corridor) -3 + ISO +5 + API +5 = 75.",
        "tier_override": None, "confidence": "medium", "data_completeness": 0.65,
        "thesis": "B&R New Waverly — 32-yr partner-pair (B+R) running aging Monarch/Bridgeport/Fadal fleet with single ISO. Upgrade equipment + add AS9100 to unlock aerospace book + 1.5x EBITDA.",
        "deep_dive_pending": True,
    },
    {
        "legal_name": "United Machine Works",
        "l1": 92, "l1_c": "Owner ~72 (1972 founding, 54-yr tenure proxy, likely 2nd-gen now). 68+ band, tenure +5.",
        "l2": 75, "l2_c": "ISO 9001 + 7-service stack (welding+CNC+coatings+fab) + oil&gas/renewable/power-gen + ~30 employees. SBA-financeable multi-service plant.",
        "l3": 70, "l3_c": "6 tells: 54-yr founder-likely-retired/deceased, single ISO cert, no equipment brands, modest FB/LinkedIn, old-school multi-service plant model, spine tenure correction.",
        "l4": 72, "l4_c": "New Waverly rural (Walker, between Conroe + Huntsville) -3 + ISO +5 = 72.",
        "tier_override": None, "confidence": "medium", "data_completeness": 0.55,
        "thesis": "UMW New Waverly — 54-yr multi-service old-school plant, 2nd-gen now likely 70s. Acquire, modernize CNC scope, monetize welding/coatings cross-sell within Houston-Huntsville energy corridor.",
        "deep_dive_pending": True,
    },
    {
        "legal_name": "C & M Machining LP",
        "l1": 75, "l1_c": "Owner ~60 (C+M initials = partner pair, 30-yr tenure). 58-62 band, tenure +5.",
        "l2": 70, "l2_c": "ISO 9001 + 34K sqft + 25 employees + family-owned 30yr oilfield/research/energy book. SBA-financeable.",
        "l3": 78, "l3_c": "8 tells: C+M two-owner family/partner, MANUAL MILLS in equipment list (old-school), engine lathes (Weilers), single ISO, no socials, last review Aug 2023, rural Navasota, deduplicated Sugar Land branch.",
        "l4": 72, "l4_c": "Navasota rural (Grimes, between Bryan-Houston) -3 + ISO +5 = 72.",
        "tier_override": None, "confidence": "medium", "data_completeness": 0.65,
        "thesis": "C&M Navasota — 30-yr family partner-pair, manual+CNC hybrid, single ISO, rural Houston-Bryan corridor. Modernize equipment + add AS9100 to capture aerospace overflow from Bryan/College Station semicon expansion.",
        "deep_dive_pending": True,
    },
    {
        "legal_name": "Snoe Inc., Machining and Welding",
        # Kept noted in exclude list as size; if we want to score for completeness, place as C-watch with size flag
        # Actually flagged exclude (revenue likely $25-45M). Remove from output.
    },
    # Index 24 = Mitchell Crane → EXCLUDED
    {
        "legal_name": "Precision Enterprise, Inc.",
        "l1": 92, "l1_c": "Owner ~72 (1967 founding, 59-yr tenure proxy, 2nd-3rd gen). 68+ band, tenure +5.",
        "l2": 62, "l2_c": "No certifications, 12-employee 12K sqft pump-repair/papermill/petrochem book, owns building. SBA-financeable but declining oilfield-pump-repair segment.",
        "l3": 92, "l3_c": "11 tells (top-of-cohort): 59-yr tenure, DeltaCAD legacy software, MANUAL machining in service mix, declining pump-repair niche, no certs, no socials, long-tenure named staff (James Fryer + John), 12K sqft modest facility, rural East TX Woodville.",
        "l4": 55, "l4_c": "Woodville rural East TX (Tyler county) -3, no cert uplift. Pure rural penalty.",
        "tier_override": None, "confidence": "medium", "data_completeness": 0.7,
        "thesis": "Precision Enterprise Woodville — TOP-OF-COHORT 59-yr coast: DeltaCAD legacy + manual mix + no certs + rural East TX. Acquire, modernize CAM (move off DeltaCAD), diversify out of declining pump-repair → 2x EBITDA path.",
        "deep_dive_pending": True,
    },
    {
        "legal_name": "Lewis Engineering Co.",
        "l1": 92, "l1_c": "Owner ~70 (1961 founding, 65-yr tenure proxy, 2nd-3rd gen). 68+ band, tenure +5.",
        "l2": 85, "l2_c": "ISO 9001 + ITAR + PRI Programs Accredited + 'guided bombs/munitions' defense work + ~35 employees + 65-yr family book. SBA-financeable; defense ITAR moat.",
        "l3": 50, "l3_c": "6 tells (mixed): 65-yr tenure + family-owned 1961 — but active FB/LinkedIn/YouTube + modern responsive (©2026) site = active posture not coast.",
        "l4": 80, "l4_c": "Marshall East TX (Harrison) 0 + ISO +5 + ITAR +5 = 80 (defense ITAR moat offsets East TX 0).",
        "tier_override": None, "confidence": "medium", "data_completeness": 0.6,
        "thesis": "Lewis Marshall — 65-yr defense/ITAR family book with munitions niche. Modern posture (active socials, ©2026 site) means closer to B-tier than classic coast; investigate succession plan + retention before pursuit.",
        "deep_dive_pending": True,
    },
    # Index 27 = C & M Sugar Land branch → EXCLUDED (duplicate)
    {
        "legal_name": "Bates Machine & Mfg., Inc.",
        "l1": 85, "l1_c": "Co-owners Paul Bates + Mary Kaye Wilson ~65 (2nd gen, children of Earl Bates Jr. d.2019). 63-67 band, +5 for combined 51-yr family tenure.",
        "l2": 75, "l2_c": "51-yr family book, diversified 11-industry mix (aerospace/medical/O&G/automotive/defense/ag/construction/renewables), ~12 employees. No certs but multi-vertical = recession-resistant. SBA-financeable.",
        "l3": 85, "l3_c": "8 tells: founder Earl Bates Jr. d.2019 transition implicit, sibling-co-owner setup, brochure site no online quoting, phone-first intake, NO CAD/CAM disclosed, NO certs (no ISO/AS9100/ITAR — anti-PE-rollup), rural Farmersville off-PE-radar, '3-generation' soft-sell language.",
        "l4": 80, "l4_c": "Farmersville rural Collin (NE McKinney DFW exurban) +5 DFW pull adjusted -3 rural = 75 + 5 family-coast premium = 80.",
        "tier_override": None, "confidence": "medium", "data_completeness": 0.78,
        "thesis": "Bates — sibling-coowner aligned exit setup, 6yr post-founder transition window, rural off-PE Farmersville, anti-PE-cert posture. Acquire on sibling-divergence catalyst, add ISO + online quoting + modern CAM for 2x EBITDA path.",
        "deep_dive_pending": True,
    },
    # === BATCH 2 ===
    # Bates already scored above (index 28+29 are same company, batch 2 has fresher data)
    {
        "legal_name": "Starke Machine Co.",
        "l1": 82, "l1_c": "Owner ~65 (1980 founding, 46-yr tenure, Dwayne Burgamy LinkedIn). 63-67 band, +5 tenure.",
        "l2": 78, "l2_c": "AS9100 + ISO 9001 aerospace-defense ITAR-registered, 20K sqft (since 1996), ~65 employees ($10M ZoomInfo). SBA-financeable.",
        "l3": 65, "l3_c": "6 tells: owner kept off site (privacy), founder-garage origin Warfield St 1980, 30-yr same facility (settled), brochure About generic 'state-of-art' language, single FW location, AS9100 credentialed but no growth-mode socials.",
        "l4": 85, "l4_c": "Fort Worth (Tarrant, DFW) +5 + AS9100 +10 + ISO +5 = 85.",
        "tier_override": None, "confidence": "medium", "data_completeness": 0.72,
        "thesis": "Starke FW — 46-yr closely-held aerospace/defense AS9100 shop, founder ~65, no growth marketing. Acquire on retirement trigger, modernize digital + aerospace marketing pull from Lockheed/Bell-adjacent DFW.",
        "deep_dive_pending": True,
    },
    {
        "legal_name": "Halsey Manufacturing",
        "l1": 95, "l1_c": "Don Halsey ~72 (UNT grad + 47-yr founding 1979). 68+ band, +5 tenure (founder still active CEO past retirement age).",
        "l2": 75, "l2_c": "Marquee client list (Samsung, Lockheed Martin, Peterbilt) + diversified 10-vertical mix, ~25 employees, HAAS/Ganesh/Hitachi value-tier fleet + Trotec laser side-hustle. No certs but solid SBA-financeable.",
        "l3": 80, "l3_c": "8 tells: founder past retirement age still CEO, brochure site no online quoting, value-tier equipment (no flagship Mazak/DMG), Trotec laser side-hustle (non-CNC growth), NO certs despite aerospace clients, FB-only social, static brand, no successor.",
        "l4": 90, "l4_c": "Denton (Denton county, DFW) +5 = 75. No cert uplift but Lockheed/Samsung client list = premium pull adjusted up.",
        "tier_override": None, "confidence": "medium", "data_completeness": 0.8,
        "thesis": "Halsey Denton — 47-yr Don Halsey ~72 with Lockheed/Samsung/Peterbilt book + zero ISO/AS9100 cert overhead. Acquire on age-driven exit, layer ISO + AS9100 in year-1 = unlock cert-premium SOW from existing client base.",
        "deep_dive_pending": True,
    },
    {
        "legal_name": "Continental Manufacturing",
        "l1": 50, "l1_c": "Judd Stretcher (3rd gen, ~55) heads parent Continental NH3 Products. 53-57 band, modest tenure.",
        "l2": 55, "l2_c": "Captive shop for parent NH3 ag-equipment business, ASME pressure-fitting certs, no ISO 9001/AS9100, ~35 employees. Carve-out complexity reduces SBA-financeability.",
        "l3": 60, "l3_c": "7 tells: 72-yr tenure but captive-customer structure, ASME-only (no ISO/AS9100), 'state-of-art' generic language, no specific equipment, LinkedIn-only social, Dallas inner-loop owned facility.",
        "l4": 65, "l4_c": "Dallas (DFW) +5 = 65 base. Captive-shop carve-out penalty applied.",
        "tier_override": "C_watch", "confidence": "medium", "data_completeness": 0.7,
        "thesis": "Continental Mfg — division of NH3 ag-equipment parent, carve-out required. Skip unless parent signals divestiture.",
        "deep_dive_pending": False,
    },
    {
        "legal_name": "Dallas Precision Machining (DPM)",
        "l1": 30, "l1_c": "Sister-co of Pacific Sensor LLC (William Ritter VP). Owner unnamed, age unknown. Weak proxy band.",
        "l2": 65, "l2_c": "ISO 9001:2015 + AS9100D + ITAR + Mazak INTEGREX + 16K sqft Carrollton, ~20 employees. Sister-company structure complicates SBA.",
        "l3": 45, "l3_c": "5 tells (mixed): two-machine garage origin small + sister-co ownership complexity + 16K Carrollton single location + Mazak/Haas/Leadwell mix + full aerospace cert stack — but no growth marketing.",
        "l4": 92, "l4_c": "Carrollton (Dallas, DFW) +5 + AS9100 +10 + ISO +5 + ITAR +5 = 92.",
        "tier_override": "C_watch", "confidence": "low", "data_completeness": 0.5,
        "thesis": "DPM Carrollton — sister-co of Pacific Sensor, would need combined-deal carve-out. C-watch pending Pacific Sensor ownership investigation.",
        "deep_dive_pending": False,
    },
    {
        "legal_name": "Cameron Machine Shop, Inc.",
        "l1": 60, "l1_c": "Christi Cameron (3rd gen President since 2007) ~55. 53-57 band + 19-yr personal tenure +3.",
        "l2": 78, "l2_c": "NTMA + NFIB + woman-owned, 25K sqft same Richardson facility since 1971, 12 machines, ~25 employees, general-industrial diversified book. No ISO/AS9100. SBA-financeable.",
        "l3": 75, "l3_c": "7 tells: contact-form-only no phone (phone-shy), same building 55 years, slow tech adoption (first CNC 1980/first CMM 1993), NTMA+NFIB+woman-owned but no ISO/AS9100, no 4th-gen successor, solo decision-maker, settled 19-yr rhythm.",
        "l4": 85, "l4_c": "Richardson (Dallas, DFW) +5 = 85. No cert uplift but building-owned real-estate.",
        "tier_override": None, "confidence": "medium", "data_completeness": 0.85,
        "thesis": "Cameron Richardson — 3rd-gen Christi Cameron sole-decision-maker, no 4th-gen named, building owned 55yr. Acquire on 12-36mo exit window, layer ISO/AS9100, monetize Richardson real estate.",
        "deep_dive_pending": True,
    },
    {
        "legal_name": "Manda Machine Company, Inc.",
        "l1": 80, "l1_c": "Andy Ellard + Todd Ellard (3rd-gen brothers, ~60) approaching succession-decision pressure. 58-62 band +5 sibling-tenure.",
        "l2": 85, "l2_c": "76-yr tenure + AS9100D (2023) + ISO 9001 (2008) + Dallas inner-loop building owned since 1950 + ~30 employees + precision metal/assembly book. SBA-financeable + AS9100 cert premium.",
        "l3": 78, "l3_c": "7 tells: 76-yr tenure (oldest in cohort), sibling-co-owners (Andy+Todd ~60), slow tech adoption (ISO not until 2008 = 58yrs after founding, AS9100D until 2023), no equipment brands disclosed, limited social posting, phone-first, no 4th-gen public.",
        "l4": 92, "l4_c": "Dallas (DFW) +5 + AS9100 +10 + ISO +5 = 92.",
        "tier_override": None, "confidence": "high", "data_completeness": 0.85,
        "thesis": "Manda — oldest in cohort (76yr), Ellard sibling-coowners approaching 60 + fresh AS9100D 2023 (sale-prep tell) + no 4th-gen + Dallas inner-loop owned real estate. Acquire on sibling-alignment exit, monetize cert + real estate.",
        "deep_dive_pending": True,
    },
    # Index 36 = APC Garland → EXCLUDED (>$30M)
    # Index 37 = TCMG → EXCLUDED (multi-subsidiary group)
    {
        "legal_name": "Austin Precision Machining and Manufacturing (APMM)",
        "l1": 40, "l1_c": "Tensay Johnson (founder, mid-career ~50, 19yr tenure). Below retirement-cohort.",
        "l2": 60, "l2_c": "Solo principal, no certs, automation/auto/aerospace/medical/electronics/semicon Austin-corridor book. SBA-financeable but mid-stage.",
        "l3": 55, "l3_c": "7 tells: mobile+office phone solo-operator, no successor, brochure no online quoting, no certs, founder-led mission language, single-DM posture, 19yr mid-career stage.",
        "l4": 80, "l4_c": "Pflugerville (Travis, Austin semicon corridor) +5 = 80. No cert uplift.",
        "tier_override": "C_watch", "confidence": "medium", "data_completeness": 0.7,
        "thesis": "APMM — Tensay Johnson too young for retirement exit. Watch for 5-10yr horizon.",
        "deep_dive_pending": False,
    },
    {
        "legal_name": "Waggoner Manufacturing Inc.",
        "l1": 40, "l1_c": "Danton Waggoner (3rd gen, ~48) after Pat Waggoner founded 1979. 47-yr family tenure but current operator below 53.",
        "l2": 70, "l2_c": "3-gen family + aerospace/energy/maritime/government/military/semicon diversified + ~30 employees + L.G. Electronics origin honored brand. No certs but solid SBA-financeable.",
        "l3": 55, "l3_c": "6 tells: 3rd-gen succession executed, founder-tribute renaming legacy-preservation not growth, no ISO/AS9100, FB/YouTube/LinkedIn limited content, brochure site, founder-tribute static brand.",
        "l4": 80, "l4_c": "Round Rock (Williamson, Austin) +5 = 80. No cert uplift.",
        "tier_override": "C_watch", "confidence": "medium", "data_completeness": 0.7,
        "thesis": "Waggoner — 3rd-gen Danton at 48 = 5-10yr exit horizon. Watch for 4th-gen development or sibling-coowner trigger.",
        "deep_dive_pending": False,
    },
    {
        "legal_name": "American Valmark, Inc.",
        "l1": 40, "l1_c": "Rachel Prevost (President, ~48). Below retirement-cohort.",
        "l2": 70, "l2_c": "21-yr ITAR-registered aerospace/semicon/biotech/medical mix, ~15 employees, modern multi-process (CNC + finishing + laser + waterjet). SBA-financeable.",
        "l3": 50, "l3_c": "7 tells (mixed): Spicewood rural Hazy Hills driveway address, ITAR-only (no ISO/AS9100), solo principal, single phone line, FB/LinkedIn-only social.",
        "l4": 80, "l4_c": "Spicewood (Travis, Austin metro exurban) +5 -3 rural = 82 + ITAR +5 = 80-87. Use 80.",
        "tier_override": "C_watch", "confidence": "medium", "data_completeness": 0.7,
        "thesis": "American Valmark — Rachel Prevost ~48 below retirement-cohort. Strong semicon/biotech customer book. Watch for 5-10yr horizon.",
        "deep_dive_pending": False,
    },
    {
        "legal_name": "A.R. Machining, Inc.",
        "l1": 78, "l1_c": "Anthony Dobias (founding-gen, ~60) + Matthew Dobias (2nd-gen) + siblings. 58-62 band +5 47-yr family tenure.",
        "l2": 72, "l2_c": "ISO + ITAR (no AS9100) + 47-yr aerospace/medical/military/semicon/O&G book + ~20 employees + Samsung/Tesla semicon adjacency. SBA-financeable.",
        "l3": 65, "l3_c": "7 tells: 3 location moves (Manor → Hutto → Pflugerville → Hutto 2004 = NOT classic coast), multi-sibling 2nd-gen family-only labor, Hutto rural east of Round Rock, ISO+ITAR but no AS9100, no CAD-CAM brands, no public employee count.",
        "l4": 85, "l4_c": "Hutto (Williamson, Austin semicon corridor) +5 + ISO +5 + ITAR +5 = 85.",
        "tier_override": None, "confidence": "medium", "data_completeness": 0.7,
        "thesis": "A.R. Hutto — Anthony Dobias ~60 + multi-sibling 2nd-gen + Samsung/Tesla semicon adjacency. Acquire on sibling-coordination exit catalyst, layer AS9100 to unlock aerospace pull.",
        "deep_dive_pending": True,
    },
    {
        "legal_name": "JB Machine LLC",
        "l1": 45, "l1_c": "'Jarid' (last name undisclosed) ~50. Below retirement-cohort but tenure +3.",
        "l2": 60, "l2_c": "Solo-owner 26-yr SA general industrial book, ~8 employees, no certs, gov capability statement (unsuccessful federal cred build). SBA-financeable.",
        "l3": 75, "l3_c": "7 tells: owner first-name only ('Jarid'), no certs, phone not on accessed page (extreme low marketing), gov cap statement w/o cert success, 26-yr w/ limited online presence (classic coast), founder-tracked metrics, solo single-DM.",
        "l4": 73, "l4_c": "San Antonio (Bexar) +3 SA defense corridor. No cert uplift.",
        "tier_override": None, "confidence": "medium", "data_completeness": 0.65,
        "thesis": "JB Machine SA — 26-yr Jarid solo-owner, minimal marketing, SA defense corridor. Acquire on age-trigger (~50 + 26yr fatigue), build out ISO + federal cert stack.",
        "deep_dive_pending": True,
    },
    {
        "legal_name": "Camargo Custom (Camargo's Custom Machine & Welding, Inc.)",
        "l1": 60, "l1_c": "Eduardo + Maria Camargo (spouse co-owners ~55) + multi-family-employee setup. 53-57 band +3 family-tenure.",
        "l2": 65, "l2_c": "20-yr vintage-equipment-restoration niche + family-employee labor + BBB-listed + ~10 employees. SBA-financeable solo-niche.",
        "l3": 70, "l3_c": "7 tells: 'over 100yr combined' marketing = aging team, no ISO/AS9100/defense creds, family-employee model (Eduardo+Maria+Agustin+Eduardo Adrian+Agustin Jr), single Converse location, woman+family-owned dual designation, vintage-restoration sticky niche.",
        "l4": 75, "l4_c": "Converse (Bexar, east SA) +3 SA = 73 + niche premium = 75.",
        "tier_override": None, "confidence": "medium", "data_completeness": 0.7,
        "thesis": "Camargo Converse SA — spouse co-owners ~55 + 20yr vintage-equipment-restoration niche (sticky customer base) + family-employee setup. Acquire on spouse-retirement trigger, monetize niche moat with PE/strategic acquirer.",
        "deep_dive_pending": True,
    },
    # Index 45 = Owens Machine → EXCLUDED (PE-acquired)
    {
        "legal_name": "Maximum Industries, Inc.",
        "l1": 70, "l1_c": "Owner unnamed ~60 (30-yr tenure proxy). 58-62 band +3.",
        "l2": 78, "l2_c": "AS9100 + ISO 9001:2023 + 30-yr aerospace/general-industrial + 44K sqft climate-controlled + ~45 employees + multi-process (CNC + waterjet + laser). SBA-financeable. PE-attractive.",
        "l3": 50, "l3_c": "7 tells (mixed): owner unnamed (privacy), 44K sqft scale-up, current 2023 ISO cert (active), multi-process job-shop generalist, phone-first hiring page open (growth not coast), weak/no social. Anti-coast pattern.",
        "l4": 92, "l4_c": "Irving (Dallas, DFW) +5 + AS9100 +10 + ISO +5 = 92.",
        "tier_override": None, "confidence": "medium", "data_completeness": 0.7,
        "thesis": "Maximum Industries Irving — 30-yr AS9100 cert-stack, 44K sqft, hiring + active growth. Closer to B-tier (PE-attractive but not coasting). Investigate owner-age + 5-yr horizon.",
        "deep_dive_pending": True,
    },
    # Index 47 = Rigid Concepts → EXCLUDED (2015 growth-mode)
    {
        "legal_name": "FTC Industries, Inc.",
        "l1": 72, "l1_c": "Rick Flores (CEO, ~60) + 29-yr tenure. 58-62 band +3.",
        "l2": 78, "l2_c": "ISO 9000 (older standard, no AS9100) + 29-yr aerospace/O&G/medical/military/auto + 43K sqft climate-controlled + ~50 employees + 20-hr daily M-F utilization. SBA-financeable mid-scale.",
        "l3": 50, "l3_c": "7 tells (mixed): 29-yr Rick Flores email public (single-DM accessibility), older ISO 9000 (no AS9100), multi-state branding (Dallas/FW/Laredo/Corpus = growth-oriented), 20hr/day high-utilization NOT coasting.",
        "l4": 85, "l4_c": "Arlington (Tarrant, DFW) +5 + ISO +5 = 85.",
        "tier_override": None, "confidence": "medium", "data_completeness": 0.7,
        "thesis": "FTC Industries Arlington — Rick Flores ~60 + 20hr/day high-utilization growth-mode (not coast). Closer to B-tier. Watch for transition triggers, modernize ISO to 9001:2015 + add AS9100.",
        "deep_dive_pending": True,
    },
    {
        "legal_name": "Garland Service Company (GSC)",
        "l1": 30, "l1_c": "Owner unnamed, founding 'for decades' undisclosed. Weak proxy band.",
        "l2": 75, "l2_c": "ISO 9001:2015 + AS9100D + ITAR + DFARS/FARS + 'for decades' tenure + ~35 employees + 3-division (PCBA tooling + custom tooling + aerospace precision). SBA-financeable.",
        "l3": 35, "l3_c": "6 tells but anti-coast: QMS upgrade 2008 (process-driven), HEAVY cert stack (AS9100D + ITAR + DFARS + FARS), active CNC machinist recruitment + Dallas College partnership (workforce investing), YouTube/LinkedIn/SAP Ariba modern B2B = growth-investing.",
        "l4": 92, "l4_c": "Garland (Dallas, DFW) +5 + AS9100 +10 + ISO +5 + ITAR +5 = 92.",
        "tier_override": "C_watch", "confidence": "low", "data_completeness": 0.55,
        "thesis": "GSC Garland — process-driven aerospace/PCBA tooling + workforce-investing growth posture. Anti-coast. Skip.",
        "deep_dive_pending": False,
    },
    # Index 50 = Icon Machine → EXCLUDED (PE-acquired)
    {
        "legal_name": "Mills Machine Shop Operating Services, Inc.",
        "l1": 80, "l1_c": "Eddie + Linda Mills (spouse co-owners ~62; Eddie machining since 1982). 58-62 band +5 32-yr tenure.",
        "l2": 72, "l2_c": "NTMA + NFIB (no ISO/AS9100) + 32-yr general CNC + 9 machines (HAAS/Hwacheon/Leadwell/HE&M value-tier) + ~12 employees + tight-tolerance niche. SBA-financeable solo-niche.",
        "l3": 90, "l3_c": "9 tells (STRONG): husband-wife co-owners ~62, value-tier production fleet (no Mazak/DMG flagship), no ISO/AS9100 in 32yr, legacy 2000s Yahoo Local/Yelp/Angie's directory presence, founder-led brand fragility (Eddie+Linda quoted in marketing), labor pressure (CNC operator recruiting), Ponder rural Denton county off-PE-radar, no successor named, owners ~60s.",
        "l4": 80, "l4_c": "Ponder rural Denton (DFW exurban) +5 DFW -3 rural = 77. No cert uplift but value-tier fleet appropriate scale.",
        "tier_override": None, "confidence": "high", "data_completeness": 0.88,
        "thesis": "Mills Ponder — textbook spouse-co-owner ~62 + 32-yr value-tier fleet + zero cert overhead + rural off-PE Denton + no successor. Acquire on retirement trigger, layer ISO + online quoting + AS9100 to capture DFW aerospace overflow.",
        "deep_dive_pending": True,
    },
    # Index 52 = Neo Industries → EXCLUDED (2019 transition)
    {
        "legal_name": "Precision Machining Company, LLC",
        "l1": 55, "l1_c": "3rd-gen family-owned (owner ~50, names withheld). 53-57 band, family tenure modifier.",
        "l2": 65, "l2_c": "Swiss-capable niche + 3-gen FW family + ~15 employees + Enon Ave secondary corridor. No certs. SBA-financeable.",
        "l3": 78, "l3_c": "8 tells: 3rd-gen succession in place, founder + founding year both withheld (privacy/closely-held), FB handle 'Chipslinger0' casual-personal not corporate, Swiss-capable niche, no ISO/AS9100, S Fort Worth secondary corridor (not Lockheed-Bell core).",
        "l4": 85, "l4_c": "Fort Worth (Tarrant, DFW) +5 = 85. No cert uplift.",
        "tier_override": None, "confidence": "medium", "data_completeness": 0.65,
        "thesis": "PMC FW — 3rd-gen privacy-posture Swiss-niche shop, owner ~50 mid-career. Watch for 5-10yr horizon; SOS lookup to capture founder identity.",
        "deep_dive_pending": False,
    },
    {
        "legal_name": "Transtar CNC Machine, LLC",
        "l1": 30, "l1_c": "'Group of partners with 50+ yrs combined' — names withheld. Weak proxy band.",
        "l2": 70, "l2_c": "AS9100D + ISO 9001 + aviation/O&G/auto + reverse-eng + prototyping + ~12 employees + 7-day-week service. SBA-financeable but partner-structure complexity.",
        "l3": 60, "l3_c": "8 tells (mixed): address inconsistency Mansfield vs Arlington (relocation/branding), 7-day-week high service commitment NOT coasting, AS9100D + ISO 9001 aerospace-credentialed, partner-structure names withheld, multi-owner succession complexity, reverse-eng sticky moat.",
        "l4": 92, "l4_c": "Arlington (Tarrant, DFW) +5 + AS9100 +10 + ISO +5 = 92.",
        "tier_override": None, "confidence": "low", "data_completeness": 0.55,
        "thesis": "Transtar Arlington — partnership AS9100D + reverse-eng niche, 7-day high-service active. Investigate partner-age + multi-owner exit alignment.",
        "deep_dive_pending": False,
    },
    {
        "legal_name": "JY's Extreme Machine LLC",
        "l1": 50, "l1_c": "Jason Yeates (founder, ~50) + 21-yr tenure. 53-57 lower band +3 tenure.",
        "l2": 55, "l2_c": "Small 4K sqft job shop (~$2-3M revenue) + 5 employees + no certs + tight-tolerance niche (Inconel exotics) + Hurco origin. SBA-financeable small-bolt-on.",
        "l3": 88, "l3_c": "10 tells (STRONG): 4K sqft tiny, solo owner-operator Jason Yeates 21yr, single-machine Hurco origin, no certs, tight-tolerance ±0.0001\" craftsmanship-focused, generational-decline concern in marketing copy = succession signal, founder-led brand fragility.",
        "l4": 75, "l4_c": "Burleson (Johnson, S DFW) +5 = 75. No cert uplift but small scale.",
        "tier_override": None, "confidence": "high", "data_completeness": 0.8,
        "thesis": "JY's Burleson — Jason Yeates ~50 + 21-yr solo-owner + explicit succession-concern in marketing = signaling exit-ready. Small bolt-on for solo-acquirer; not PE-scale.",
        "deep_dive_pending": True,
    },
    # === BATCH 3 ===
    # Skip excluded: Texas Machining & Sales (NC HQ)
    {
        "legal_name": "Saga Machine Co.",
        "l1": 25, "l1_c": "Owner not named, founding year not disclosed. Weak proxy band.",
        "l2": 65, "l2_c": "AS9100 + ITAR defense/aerospace + NTMA + ~10 employees. SBA-financeable.",
        "l3": 30, "l3_c": "Limited tells — page does not disclose founder/family. Anti-coast: AS9100+ITAR + active modern posture.",
        "l4": 90, "l4_c": "Denton (Denton county, DFW) +5 + AS9100 +10 + ITAR +5 = 90.",
        "tier_override": "C_watch", "confidence": "low", "data_completeness": 0.5,
        "thesis": "Saga Denton — AS9100+ITAR DFW defense shop. Needs SOS pull for owner identity before A-tier consideration.",
        "deep_dive_pending": False,
    },
    {
        "legal_name": "OEM Machining",
        "l1": 25, "l1_c": "Owner not named, founding year missing. Weak proxy band.",
        "l2": 60, "l2_c": "ISO 9001:2015 + ~8 employees + Galveston coast general production. SBA-financeable small.",
        "l3": 40, "l3_c": "1 tell: no public owner identity. Insufficient data for coasting signal.",
        "l4": 78, "l4_c": "League City (Galveston, Houston metro) +5 + ISO +5 = 78.",
        "tier_override": "C_watch", "confidence": "low", "data_completeness": 0.5,
        "thesis": "OEM Machining League City — needs Comptroller/SOS pull for ownership intel.",
        "deep_dive_pending": False,
    },
    {
        "legal_name": "KALCO Machine & Manufacturing",
        "l1": 65, "l1_c": "Owner ~55 (1998 founding, 28-yr tenure proxy). 53-57 band +3.",
        "l2": 78, "l2_c": "AS9100 + ISO 9001 + 130K sqft + ~80 employees + oilfield/aerospace mix. SBA-financeable but SIZE FLAG (possibly >$30M).",
        "l3": 40, "l3_c": "Limited tells, no public coasting signal. Anti-coast: AS9100 + multi-industry credentialed.",
        "l4": 78, "l4_c": "Wichita Falls (Wichita county, secondary TX metro) 0 + AS9100 +10 + ISO +5 = 78. North TX secondary metro.",
        "tier_override": "C_watch", "confidence": "low", "data_completeness": 0.55,
        "thesis": "KALCO Wichita Falls — 28-yr AS9100 shop, 130K sqft suggests possibly >$30M ceiling. Watch with revenue verification.",
        "deep_dive_pending": False,
    },
    {
        "legal_name": "Gulf Coast Repair & Machine Shop, Inc.",
        "l1": 78, "l1_c": "Owner ~62 (1989 founding, 37-yr tenure proxy). 58-62 band +5 tenure.",
        "l2": 65, "l2_c": "37-yr oilfield + 20 acres Corpus Christi land + ~25 employees + no certs (no ISO/AS9100). Significant real estate + legacy customer base. SBA-financeable.",
        "l3": 78, "l3_c": "3 explicit tells but high-signal: no certifications listed (built on relationships not credentials), no public owner identity, garage-start narrative (no modern capability emphasis), 20-acre Corpus Christi real estate, 37-yr legacy customer base.",
        "l4": 70, "l4_c": "Corpus Christi (Nueces, Gulf Coast oilfield) 0 + no cert uplift but 20-acre real estate premium = 70.",
        "tier_override": None, "confidence": "medium", "data_completeness": 0.65,
        "thesis": "Gulf Coast Repair Corpus — 37-yr owner ~62 + 20-acre real estate + no cert overhead. Acquire on age-trigger, monetize Corpus Christi land + layer ISO for offshore O&G recovery wave.",
        "deep_dive_pending": True,
    },
    {
        "legal_name": "Tool Tech Machining & Sheet Metal",
        "l1": 30, "l1_c": "Owner unnamed, founding not disclosed. Weak proxy band.",
        "l2": 60, "l2_c": "~20 employees + petrochem/marine specialty + Golden Triangle corridor + no certs. SBA-financeable small.",
        "l3": 60, "l3_c": "4 tells: no certifications, no public owner, no founding year, Golden Triangle (409) area code mature petrochem corridor.",
        "l4": 65, "l4_c": "Beaumont (Jefferson, Golden Triangle East TX petrochem) 0 = 65 base.",
        "tier_override": None, "confidence": "low", "data_completeness": 0.5,
        "thesis": "Tool Tech Beaumont — Golden Triangle petrochem shop, needs SOS+Comptroller pull for ownership intel.",
        "deep_dive_pending": False,
    },
    {
        "legal_name": "H&H Precision Machining, Inc.",
        "l1": 75, "l1_c": "Phillip Holt (founder, ~60) + 26-yr tenure. 58-62 band +3.",
        "l2": 65, "l2_c": "26-yr auto/aerospace + family-successor reference + ~15 employees + no certs (limits aerospace primacy). SBA-financeable.",
        "l3": 65, "l3_c": "2 tells but high-signal: no ISO/AS9100 (limits aerospace primes), 'family successors' explicit reference no named transition, founder-led brand, modest scale.",
        "l4": 78, "l4_c": "Decatur (Wise, DFW exurban) +5 DFW = 78. No cert uplift.",
        "tier_override": None, "confidence": "medium", "data_completeness": 0.6,
        "thesis": "H&H Decatur — Phillip Holt ~60 + 26-yr auto/aerospace + explicit family-successor reference. Acquire on succession-trigger, add ISO/AS9100 to capture DFW aerospace overflow.",
        "deep_dive_pending": True,
    },
    {
        "legal_name": "Central Texas Machining, LP",
        "l1": 80, "l1_c": "Rick + Paul Sacket (3rd-gen brothers, ~63) + 26-yr business tenure but 1989 plastics origin. 58-62 band +5 multi-gen.",
        "l2": 60, "l2_c": "3-gen family + oilfield/hydraulic-cylinder niche + ~10 machinists + no certs + no phone on site. SBA-financeable small-niche.",
        "l3": 75, "l3_c": "3 tells but high-signal: no address on website, no certifications, no phone on site (extreme low-visibility = textbook coast), 3rd-gen family ownership explicit, hydraulic-cylinder + O&G niche moat, traceable plastics origin 1989.",
        "l4": 65, "l4_c": "Unknown city (rural-implied no address) 0 + no cert uplift = 65.",
        "tier_override": None, "confidence": "medium", "data_completeness": 0.6,
        "thesis": "Central Texas Machining — 3rd-gen Sacket brothers ~63 + hydraulic-cylinder + O&G niche + zero web visibility. Acquire on sibling-aligned exit catalyst; needs address SOS pull.",
        "deep_dive_pending": True,
    },
    {
        "legal_name": "Custom Components & Assemblies, Inc.",
        "l1": 75, "l1_c": "Owner unnamed ~60 (31-yr tenure proxy). 58-62 band +3.",
        "l2": 70, "l2_c": "ISO 9001:2015 + 31-yr Houston job shop + ~25 employees + multi-vertical (O&G + aerospace + medical). SBA-financeable.",
        "l3": 55, "l3_c": "2 tells (mid-signal): no public owner identity on About page, no AS9100 despite aerospace customer claim. Otherwise active.",
        "l4": 80, "l4_c": "Houston (Harris) +5 + ISO +5 = 80.",
        "tier_override": None, "confidence": "medium", "data_completeness": 0.65,
        "thesis": "CCA Houston — 31-yr ISO-cert diversified job shop, owner ~60. Acquire on age-trigger, layer AS9100 to unlock aerospace premium.",
        "deep_dive_pending": True,
    },
    {
        "legal_name": "ALPA Precision L.L.P",
        "l1": 85, "l1_c": "Owner ~68 (1981 founding, 45-yr tenure proxy). 68+ band +5 tenure.",
        "l2": 65, "l2_c": "L.L.P. partnership + 45-yr Houston O&G exotic-alloy (Inconel/Titanium/MP35N) niche + ~20 employees + no certs (relationship-built). SBA-financeable.",
        "l3": 80, "l3_c": "4 tells: no certifications, no public owner identity, L.L.P. older partnership structure (suggests pre-90s founding ownership), single-vertical Houston O&G reliance.",
        "l4": 78, "l4_c": "Houston (Harris) +5 + niche exotic-alloy premium = 78 (no formal cert uplift).",
        "tier_override": None, "confidence": "medium", "data_completeness": 0.55,
        "thesis": "ALPA Houston — 45-yr L.L.P. partnership ~68 + exotic-alloy O&G niche moat. Acquire on age-trigger as Houston O&G recovery wave compounds value; SOS pull for L.L.P. partner identities.",
        "deep_dive_pending": True,
    },
    {
        "legal_name": "Metal Machining Technology",
        "l1": 50, "l1_c": "Owner ~55 (2008 founding, founder 35+yr career proxy). 53-57 lower band.",
        "l2": 55, "l2_c": "Small ~6 employees + 18-yr Houston general job shop + weekend services + no certs + sub-tenant Belgold St. SBA-financeable lifestyle business.",
        "l3": 55, "l3_c": "4 tells: weekend services (owner-operator), co-located complex sub-tenant (not facility owner), no certs, no employee count.",
        "l4": 75, "l4_c": "Houston (Harris) +5 = 75. No cert uplift, sub-tenant scale.",
        "tier_override": None, "confidence": "low", "data_completeness": 0.55,
        "thesis": "MMT Houston — small lifestyle-biz Houston job shop, owner ~55. Bolt-on candidate for solo acquirer; not PE scale.",
        "deep_dive_pending": False,
    },
    {
        "legal_name": "Pearland Precision",
        "l1": 45, "l1_c": "'Chad' (last name undisclosed) ~55 + 30+yr machinist career. 53-57 lower band.",
        "l2": 50, "l2_c": "Tiny ~5 employees + CNC-turning niche + chad@ direct email + no certs + sub-tenant refining corridor. SBA-financeable tiny.",
        "l3": 65, "l3_c": "3 tells: no certifications, owner email visible chad@ (owner-operator), small shop sub-tenant scale.",
        "l4": 73, "l4_c": "Pearland (Brazoria, Houston metro) +5 = 73. No cert uplift, small scale.",
        "tier_override": None, "confidence": "low", "data_completeness": 0.5,
        "thesis": "Pearland Precision — Chad owner-machines 30+yr career, tiny CNC-turning niche. Lifestyle-buy bolt-on; needs SOS for full owner ID.",
        "deep_dive_pending": False,
    },
    {
        "legal_name": "Osborn Technical Services",
        "l1": 85, "l1_c": "Vernon Osborn (founder, ~67-72 pioneer framing + 50yr combined experience). 68+ band +3.",
        "l2": 65, "l2_c": "24-yr gear-shaping + crane-component niche + Fellows Spur Gear Shapers + Morrison Internal Key Cutter (specialty legacy equip) + ~18 employees + no certs. SBA-financeable defensible niche.",
        "l3": 75, "l3_c": "4 tells: Vernon Osborn 'pioneer' framing, legacy gear-shaping equipment (Fellows/Morrison), no AS9100/ISO, industrial estate Decker Industrial Circle, 50yr combined experience framing founder-driven legacy not modernization.",
        "l4": 75, "l4_c": "Pinehurst (Montgomery, Houston metro N) +5 = 75. No cert uplift but niche moat premium.",
        "tier_override": None, "confidence": "medium", "data_completeness": 0.65,
        "thesis": "Osborn Pinehurst — Vernon Osborn ~67 + gear-shaping/crane-component defensible niche + no certs. Acquire on retirement-trigger, monetize Fellows/Morrison specialty equipment moat in Houston-N corridor.",
        "deep_dive_pending": True,
    },
    {
        "legal_name": "Leverage Mechanical Services",
        "l1": 25, "l1_c": "Owner unnamed, founding not disclosed. Weak proxy band.",
        "l2": 50, "l2_c": "Field-machining + valve-repair (industrial services not pure CNC) + ~25 employees + no certs. SCOPE FLAG. SBA-financeable but borderline-scope.",
        "l3": 50, "l3_c": "3 tells: specialty mechanical/field-machining heritage (service-bias not pure CNC), no certs, no founding year.",
        "l4": 70, "l4_c": "Baytown (Harris, Houston petrochem) +5 = 70.",
        "tier_override": "C_watch", "confidence": "low", "data_completeness": 0.4,
        "thesis": "Leverage Baytown — field-machining/valve-repair is closer to industrial services than pure CNC. Scope review required; skip.",
        "deep_dive_pending": False,
    },
    {
        "legal_name": "Ultimate Precision Tech",
        "l1": 30, "l1_c": "Long Tao (CEO since 2019, ~45). Below retirement-cohort.",
        "l2": 60, "l2_c": "Young 7-yr Houston tight-tolerance multi-vertical + ~10 employees + no certs. SBA-financeable but young.",
        "l3": 40, "l3_c": "2 tells: young firm (2019, not coasting), no address on accessed page.",
        "l4": 75, "l4_c": "Houston (Harris) +5 = 75. No cert uplift.",
        "tier_override": "C_watch", "confidence": "low", "data_completeness": 0.5,
        "thesis": "UPT Houston — too young (7yr, Long Tao ~45) for classic coast. Skip.",
        "deep_dive_pending": False,
    },
    {
        "legal_name": "Maddox Metal Works, Inc.",
        "l1": 75, "l1_c": "Sam Maddox (founder, current ownership unknown) + 74-yr multi-gen tenure. 68+ band assuming 3rd-gen Maddox owners ~60+, +5 tenure.",
        "l2": 55, "l2_c": "74-yr legacy + ~50 employees + N TX commercial gearing capacity + no certs + TLS cert expired (operational neglect distress signal). SIZE FLAG (40K sqft + commercial gearing could push >$30M).",
        "l3": 80, "l3_c": "4 tells: TLS cert expired (operational neglect), no AS9100/ISO despite aerospace customer claim, founded 1952 = multi-gen operating without modernization, largest commercial gearing capacity N TX (legacy positioning).",
        "l4": 80, "l4_c": "Dallas (DFW) +5 + commercial-gearing niche premium = 80.",
        "tier_override": None, "confidence": "low", "data_completeness": 0.55,
        "thesis": "Maddox Dallas — 74-yr Maddox family legacy + commercial gearing niche moat + operational neglect (TLS expired). Acquire on distress-signal trigger; size verification needed (could be too big).",
        "deep_dive_pending": True,
    },
    {
        "legal_name": "New Braunfels Machine, Inc.",
        "l1": 25, "l1_c": "Owner not surfaced, founding not disclosed. Weak proxy band.",
        "l2": 45, "l2_c": "Website timeout (distress) + ~10 employees + no certs + N SA metro. Distress signal limits SBA-financeability.",
        "l3": 60, "l3_c": "4 tells: website times out (distress), no certs, no founding year, no phone published.",
        "l4": 68, "l4_c": "New Braunfels (Comal, N SA metro) +3 SA = 68.",
        "tier_override": "C_watch", "confidence": "low", "data_completeness": 0.35,
        "thesis": "NBM New Braunfels — distress flag (website down). SOS + Comptroller pull required before acquisition consideration.",
        "deep_dive_pending": False,
    },
    {
        "legal_name": "Wakeland Engineering PLLC",
        "l1": 20, "l1_c": "No public footprint beyond NTMA membership. Weak proxy band.",
        "l2": 40, "l2_c": "PLLC suffix = sole-prop/small partnership + ~5 employees + no website + no certs. SBA-financeable tiny.",
        "l3": 55, "l3_c": "3 tells: no website surfaced, PLLC suffix small-partnership, NTMA-only public footprint.",
        "l4": 60, "l4_c": "Unknown city = neutral 60 base.",
        "tier_override": "C_watch", "confidence": "low", "data_completeness": 0.3,
        "thesis": "Wakeland — needs SOS pull for PLLC registered owner identity. Skip until further intel.",
        "deep_dive_pending": False,
    },
    {
        "legal_name": "Bryli, Inc.",
        "l1": 50, "l1_c": "Owner ~55 (2001 founding, 25-yr tenure proxy). 53-57 lower band.",
        "l2": 70, "l2_c": "ISO 9001 + AS9100 dual-cert DFW contract mfg + ~25 employees + tooling/mold + 25-yr tenure. SBA-financeable.",
        "l3": 45, "l3_c": "2 tells: address/phone not surfaced from public pages, no public owner identity. Anti-coast: AS9100+ISO active.",
        "l4": 90, "l4_c": "Unknown city DFW-implied (LinkedIn) +5 + AS9100 +10 + ISO +5 = 90.",
        "tier_override": "C_watch", "confidence": "low", "data_completeness": 0.4,
        "thesis": "Bryli DFW — 25-yr AS9100+ISO dual-cert contract mfg, owner ~55 below retirement. Watch + SOS pull for ownership.",
        "deep_dive_pending": False,
    },
    {
        "legal_name": "Texas Machined Components, Inc.",
        "l1": 20, "l1_c": "No public footprint beyond NTMA. Weak proxy band.",
        "l2": 40, "l2_c": "NTMA-only + no website + no certs surfaced. Insufficient SBA workup data.",
        "l3": 55, "l3_c": "2 tells: no public website, NTMA-only.",
        "l4": 60, "l4_c": "Unknown city, neutral 60.",
        "tier_override": "C_watch", "confidence": "low", "data_completeness": 0.3,
        "thesis": "TMC — NTMA-only public footprint. SOS pull required.",
        "deep_dive_pending": False,
    },
    # Index 78 = Mann Made / G01 → EXCLUDED (aluminum extrusion, out-of-scope)
    {
        "legal_name": "C & C Machining LLC",
        "l1": 20, "l1_c": "No public footprint beyond NTMA. Weak proxy band.",
        "l2": 40, "l2_c": "NTMA-only Fort Worth quick-turn + no website + no certs. Insufficient SBA workup.",
        "l3": 55, "l3_c": "2 tells: no public website, NTMA-only.",
        "l4": 70, "l4_c": "Fort Worth (Tarrant, DFW) +5 = 70.",
        "tier_override": "C_watch", "confidence": "low", "data_completeness": 0.3,
        "thesis": "C&C FW — NTMA-only public footprint. SOS pull required.",
        "deep_dive_pending": False,
    },
    {
        "legal_name": "LSC Precision, Inc.",
        "l1": 30, "l1_c": "No public owner anchor; rural Krum Denton county + Facebook-only suggests owner-operator. Weak proxy band.",
        "l2": 45, "l2_c": "FB-only web + ~5 employees + no certs + tiny rural Krum + NTMA. SBA-financeable tiny.",
        "l3": 75, "l3_c": "3 tells but high-signal: no proper website (FB-only), rural Krum small Denton county town, NTMA-only modern signal — textbook coast.",
        "l4": 67, "l4_c": "Krum rural Denton (DFW exurban) +5 DFW -3 rural = 67.",
        "tier_override": "C_watch", "confidence": "low", "data_completeness": 0.35,
        "thesis": "LSC Krum — rural FB-only owner-operator, coast signal present but ownership intel missing. SOS pull required.",
        "deep_dive_pending": False,
    },
    {
        "legal_name": "Expert Tool & Machine, Inc.",
        "l1": 20, "l1_c": "No public footprint, NTMA-only. Weak proxy band.",
        "l2": 40, "l2_c": "etmusa.com not fetched + http (no https) outdated + no certs + NTMA-only. Insufficient SBA workup.",
        "l3": 55, "l3_c": "3 tells: http (not https) outdated, address/phone not surfaced, NTMA-only.",
        "l4": 60, "l4_c": "Unknown city, neutral 60.",
        "tier_override": "C_watch", "confidence": "low", "data_completeness": 0.3,
        "thesis": "Expert Tool — http(not https) signal + NTMA-only. SOS pull required.",
        "deep_dive_pending": False,
    },
    {
        "legal_name": "Meyer Enterprises",
        "l1": 85, "l1_c": "Owner ~67 (Angelfire web platform implies pre-2005 owner, DBA + NTMA). 63-67 band +3.",
        "l2": 50, "l2_c": "Tiny ~3 employees + turning/milling/welding + no certs + Angelfire-frozen web + NTMA. SBA-financeable lifestyle small.",
        "l3": 85, "l3_c": "4 tells (STRONG): ANGELFIRE web platform (pre-2005, frozen ~15-20yr — classic 'frozen in time' signal), FB secondary, very small owner-operated, NTMA-only modern signal.",
        "l4": 70, "l4_c": "Denton (DFW) +5 = 70. No cert uplift but tiny scale.",
        "tier_override": None, "confidence": "low", "data_completeness": 0.45,
        "thesis": "Meyer Denton — ~67 owner-operator + Angelfire-frozen pre-2005 web + tiny scale = textbook about-to-close. SOS lookup for owner identity, opportunistic lifestyle-buy.",
        "deep_dive_pending": True,
    },
    {
        "legal_name": "Westfield Machine, Inc.",
        "l1": 88, "l1_c": "Owner ~68 (1982 founding, 44-yr family tenure proxy). 68+ band +3.",
        "l2": 85, "l2_c": "ISO 9001:2015 + API Q1 + AS9100D + Doosan/Okuma/Toyoda/Acra/Johnford modern multi-brand fleet + ~30 employees + gas turbine + O&G niche. SBA-financeable + cert-stack.",
        "l3": 60, "l3_c": "2 tells: owner-direct customer model 'people who have vested interest', founder still in customer-facing role. Otherwise modern cert posture.",
        "l4": 95, "l4_c": "Houston (Harris) +5 + AS9100 +10 + ISO +5 + API Q1 +5 = 95.",
        "tier_override": None, "confidence": "medium", "data_completeness": 0.75,
        "thesis": "Westfield Houston — 44-yr ~68 family owner + full AS9100+ISO+API Q1 cert stack + gas turbine niche + modern equipment fleet. Acquire on age-trigger, monetize Houston O&G recovery + add aerospace cross-sell.",
        "deep_dive_pending": True,
    },
    {
        "legal_name": "C & F Tool & Die Co.",
        "l1": 82, "l1_c": "Steve Collier + Robert Collier (brothers ~65, garage start 1986). 63-67 band +5 tenure.",
        "l2": 88, "l2_c": "AS9100D + ISO 9001:2015 + ITAR DDTC + 5-axis CNC + CMM + ~30 employees + aerospace/defense/semicon/biomed mix + NW SA 20K sqft. SBA-financeable + heavy cert moat.",
        "l3": 60, "l3_c": "1 tell + multi-gen: no public successor on About page (Steve+Robert remain face). Otherwise high-cert active posture.",
        "l4": 93, "l4_c": "San Antonio (Bexar) +3 SA + AS9100 +10 + ISO +5 + ITAR +5 = 93.",
        "tier_override": None, "confidence": "medium", "data_completeness": 0.8,
        "thesis": "C&F Tool & Die SA — Collier brothers ~65 + AS9100+ISO+ITAR cert moat + 5-axis modern equipment + diversified aerospace/defense/semicon/biomed book. Acquire on brother-aligned exit catalyst, monetize ITAR/AS9100 defense premium.",
        "deep_dive_pending": True,
    },
    {
        "legal_name": "Anthony Machine",
        "l1": 92, "l1_c": "80-yr tenure (1946) multi-gen Anthony family (3rd-4th gen). 68+ band +5 tenure.",
        "l2": 85, "l2_c": "ISO 9001 + AS9100 + ASME + SAMA + SME + TACA + ~35 employees + inner-SA legacy real estate owned + gearbox/industrial repair/aerospace mix + 80-yr book. SBA-financeable + cert-stack + real-estate.",
        "l3": 65, "l3_c": "2 tells: DS Anthony brand testimonials but no clear successor, inner-SA W Laurel legacy real estate. Otherwise high-cert active posture.",
        "l4": 88, "l4_c": "San Antonio (Bexar) +3 SA + AS9100 +10 + ISO +5 = 88.",
        "tier_override": None, "confidence": "medium", "data_completeness": 0.7,
        "thesis": "Anthony Machine SA — 80-yr (oldest in batch) multi-gen + AS9100+ISO+ASME + inner-SA real estate owned + gearbox/industrial-repair niche. Acquire on multi-gen succession catalyst, monetize SA real estate + cert moat.",
        "deep_dive_pending": True,
    },
    {
        "legal_name": "Texas Toolmakers, Inc.",
        "l1": 90, "l1_c": "Owner ~72 (1977 founding, 49-yr tenure proxy). 68+ band +5 tenure.",
        "l2": 65, "l2_c": "Privately-owned 49-yr + ~40 employees + tool-die/CNC/mold/sheet metal/injection mold + aerospace+semi customer claims + NO public certs + TX license #19391 (older). SBA-financeable diversified.",
        "l3": 78, "l3_c": "2 tells but high-signal: no public certs despite aerospace+semi customer claims (could be coasting on relationships), TX license #19391 older tenure, privately-owned 49-yr, no successor named, diverse multi-discipline book.",
        "l4": 73, "l4_c": "San Antonio (Bexar) +3 SA. No cert uplift but multi-discipline premium = 73.",
        "tier_override": None, "confidence": "medium", "data_completeness": 0.6,
        "thesis": "Texas Toolmakers SA — 49-yr privately-owned ~72 + multi-discipline (tool & die + CNC + mold + sheet metal + injection mold). Acquire on age-trigger, layer ISO/AS9100 to capture aerospace/semi premium on existing customer base.",
        "deep_dive_pending": True,
    },
    {
        "legal_name": "FERPA Precision Machine, Inc.",
        "l1": 85, "l1_c": "Antonio Patino (founder, ~68) + 36-yr tenure. 68+ band +3.",
        "l2": 82, "l2_c": "ISO 9001 + AS9100 + 36-yr Houston Greenspoint + ~25 employees + thermoplastic/metal seals + refinery/oilfield + aerospace/space + modern 5-axis. SBA-financeable + cert-stack + Hispanic-owned (SBA 7(a) favorable).",
        "l3": 50, "l3_c": "Limited tells but founder-led brand + no successor named — modern cert-stack offsets coast signal.",
        "l4": 92, "l4_c": "Houston Greenspoint (Harris) +5 + AS9100 +10 + ISO +5 = 92.",
        "tier_override": None, "confidence": "medium", "data_completeness": 0.7,
        "thesis": "FERPA Houston — Antonio Patino ~68 + 36-yr AS9100+ISO + thermoplastic/seals niche + Houston Greenspoint. Acquire on age-trigger; SBA 7(a) favorable for Hispanic-owned succession; monetize aerospace/space cross-sell.",
        "deep_dive_pending": True,
    },
    {
        "legal_name": "Roden's All-Star Machine & Manufacturing Incorporated",
        "l1": 70, "l1_c": "Tommy Roden (~78 founder) + three sons in business — built-in succession lowers exit pressure. 68+ band BUT multi-gen pipeline reduces urgency, net 70.",
        "l2": 85, "l2_c": "ISO 9001 + AS9100D + ~65 employees + 40K+ sqft + 17 CNC lathes + 16 CNC mills + 5 EDMs + aerospace/auto/telecom/food/banking/resource-extraction diversified book. SBA-financeable + cert-stack.",
        "l3": 50, "l3_c": "2 tells: founder retains 'face of company' role despite age, original Bridgeport mill + lathe from 2000 still on equipment list. Otherwise modern cert posture + 3-son succession pipeline.",
        "l4": 92, "l4_c": "Fort Worth (Tarrant, DFW) +5 + AS9100 +10 + ISO +5 = 92.",
        "tier_override": None, "confidence": "medium", "data_completeness": 0.85,
        "thesis": "Roden's All-Star FW — Tommy Roden ~78 + 3 sons already in business (built-in succession reduces near-term exit urgency). DEMOTED to B-tier: more likely recap/partial-buyout than clean exit. Sons may be interested if Tommy aligned. Monetize AS9100 + 40K sqft DFW position.",
        "deep_dive_pending": True,
    },
    {
        "legal_name": "Knox Machine Co Inc.",
        "l1": 80, "l1_c": "61-yr family tenure (1965), owner-likely 2nd-3rd gen ~60-70. 68+ band +5 tenure.",
        "l2": 55, "l2_c": "61-yr family-owned + S Fort Worth building owned + ~15 employees + no website + no certs + mfg.com listing only. SBA-financeable but very low visibility.",
        "l3": 92, "l3_c": "5 tells (TOP coast signal): NO PUBLIC WEBSITE, 61-yr tenure under one name (legacy operating model), no certifications, no phone publicly listed, S Fort Worth industrial corridor legacy real estate owned. Textbook frozen-pre-2010 ops style.",
        "l4": 70, "l4_c": "Fort Worth (Tarrant, DFW) +5 = 70. No cert uplift but building real-estate.",
        "tier_override": None, "confidence": "low", "data_completeness": 0.45,
        "thesis": "Knox FW — 61-yr family + NO WEBSITE + NO CERTS + S Fort Worth building owned = textbook about-to-sell-or-close coast. SOS + Comptroller priority lookup; classic ETA/lifestyle-buy bolt-on.",
        "deep_dive_pending": True,
    },
]


def load_enriched() -> list[dict]:
    rows: list[dict] = []
    for n in [1, 2, 3]:
        with open(DATA / f"cnc_machine_shop_enrich_batch_{n}.json") as f:
            d = json.load(f)
        for r in d:
            if not isinstance(r, dict):
                continue
            if r.get("_meta"):
                continue
            if not r.get("legal_name"):
                continue
            rows.append(r)
    return rows


def lookup(records: list[dict], name: str) -> dict | None:
    # Prefer the most recent (highest-data-completeness) duplicate when present
    matches = [r for r in records if r.get("legal_name") == name]
    if not matches:
        return None
    matches.sort(key=lambda r: r.get("data_completeness") or 0.0, reverse=True)
    return matches[0]


def make_data_sources(rec: dict) -> list[dict]:
    ds = rec.get("data_sources") or []
    out: list[dict] = []
    for s in ds:
        if isinstance(s, dict):
            out.append({"url": s.get("url"), "fetched_at": s.get("fetched_at") or "2026-05-16T20:30:00Z"})
        else:
            # string source — wrap
            out.append({"url": str(s), "fetched_at": "2026-05-16T20:30:00Z"})
    if not out:
        out.append({"url": rec.get("website") or "n/a", "fetched_at": "2026-05-16T20:30:00Z"})
    return out


def derive_tier(final: int, l1: int, l3: int, confidence: str, deep_dive_pending: bool, is_distressed: bool, years: int | None, override: str | None) -> str:
    if override:
        return override
    if is_distressed:
        return "D_pass"
    if years is not None and years < 5:
        return "D_pass"
    # A-gate: final >=78 AND L1 >=70 AND L3 >=65 AND confidence >=medium
    if final >= 78 and l1 >= 70 and l3 >= 65 and confidence in ("medium", "high"):
        # Per canonical: deep_dive_pending=true caps at B_forward
        if deep_dive_pending:
            return "B_forward"
        return "A_acquire_self"
    if final >= 60:
        return "B_forward"
    if final >= 45:
        return "C_watch"
    return "D_pass"


def build_targets() -> list[dict]:
    records = load_enriched()
    scored: list[dict] = []

    for score in SCORES:
        name = score["legal_name"]
        if name in EXCLUDE_NAMES:
            continue
        rec = lookup(records, name)
        if rec is None:
            print(f"WARN: could not find enrichment for {name}")
            continue

        l1 = score["l1"]
        l2 = score["l2"]
        l3 = score["l3"]
        l4 = score["l4"]
        final = round(0.30 * l1 + 0.25 * l2 + 0.30 * l3 + 0.15 * l4)

        confidence = score.get("confidence", "low")
        is_distressed = bool(rec.get("is_distressed"))
        years = rec.get("years_in_business")
        deep_dive_pending = score.get("deep_dive_pending", False)
        tier = derive_tier(final, l1, l3, confidence, deep_dive_pending, is_distressed, years, score.get("tier_override"))

        final_comment = (
            f"Score {final} ({tier}) | L1={l1} L2={l2} L3={l3} L4={l4} | "
            f"Confidence={confidence} | data_completeness={score.get('data_completeness', rec.get('data_completeness', 0.6))}."
        )

        target = {
            "legal_name": name,
            "city": rec.get("city"),
            "county": rec.get("county"),
            "state": rec.get("state", "TX"),
            "vertical": VERTICAL,
            "naics_code": NAICS,
            "website": rec.get("website"),
            "owner_name": rec.get("owner_name"),
            "owner_age_estimate": rec.get("owner_age_estimate"),
            "owner_age_source": rec.get("owner_age_source"),
            "owner_tenure_years": rec.get("years_in_business"),
            "years_in_business": rec.get("years_in_business"),
            "year_established": rec.get("year_established"),
            "entity_status": rec.get("entity_status") or "Active",
            "is_distressed": is_distressed,
            "score_run_id": SCORE_RUN_ID,
            "layer1_base_rate": l1,
            "layer1_comment": score["l1_c"],
            "layer2_sellability": l2,
            "layer2_comment": score["l2_c"],
            "layer3_behavioral_trigger": l3,
            "layer3_comment": score["l3_c"],
            "layer4_market_pull": l4,
            "layer4_comment": score["l4_c"],
            "final_score": final,
            "final_tier": tier,
            "final_comment": final_comment,
            "value_add_thesis": score["thesis"],
            "confidence": confidence,
            "data_completeness": score.get("data_completeness", rec.get("data_completeness", 0.6)),
            "deep_dive_pending": deep_dive_pending,
            "data_sources": make_data_sources(rec),
        }
        scored.append(target)

        # Persist incrementally to JSON (atomic-ish)
        tmp_path = DATA / "cnc_machine_shop_targets.json.tmp"
        with open(tmp_path, "w") as f:
            json.dump(scored, f, indent=2)
        os.replace(tmp_path, DATA / "cnc_machine_shop_targets.json")

    return scored


CSV_COLUMNS = [
    "legal_name", "city", "county", "state", "vertical", "naics_code", "website",
    "owner_name", "owner_age_estimate", "owner_age_source", "owner_tenure_years",
    "years_in_business", "year_established", "entity_status", "is_distressed",
    "score_run_id", "layer1_base_rate", "layer1_comment", "layer2_sellability",
    "layer2_comment", "layer3_behavioral_trigger", "layer3_comment",
    "layer4_market_pull", "layer4_comment", "final_score", "final_tier",
    "final_comment", "value_add_thesis", "confidence", "data_completeness",
    "deep_dive_pending", "data_sources",
]


def write_csv(targets: list[dict]) -> None:
    rows: list[dict] = []
    for t in targets:
        row = {k: t.get(k) for k in CSV_COLUMNS}
        # Flatten data_sources urls pipe-joined
        ds = t.get("data_sources") or []
        urls = []
        for d in ds:
            if isinstance(d, dict):
                u = d.get("url")
                if u:
                    urls.append(u)
        row["data_sources"] = " | ".join(urls)
        rows.append(row)
    out = DATA / "cnc_machine_shop_targets.csv"
    with open(out, "w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=CSV_COLUMNS)
        w.writeheader()
        for r in rows:
            w.writerow(r)


def main() -> None:
    targets = build_targets()
    write_csv(targets)
    # summary
    tier_counts: dict[str, int] = {}
    for t in targets:
        tier_counts[t["final_tier"]] = tier_counts.get(t["final_tier"], 0) + 1
    print("Total scored:", len(targets))
    print("Tier counts:", tier_counts)
    print("Top by final_score:")
    for t in sorted(targets, key=lambda r: r["final_score"], reverse=True)[:15]:
        print(f"  {t['final_score']:3} {t['final_tier']:14} {t['legal_name'][:50]:50} | {t['city'][:14] if t['city'] else '?':14}")


if __name__ == "__main__":
    main()
