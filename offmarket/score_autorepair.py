#!/usr/bin/env python3
"""Score the TX independent auto repair vertical run.

Reads spine + embedded enrichment, writes targets.json + targets.csv.
Embedded enrichment from live WebFetch on 12 top candidates + curated
signals from WebSearch on the remaining ~108.
"""
import json
import csv
import uuid
import os
from datetime import datetime, timezone
from typing import Optional

OUTDIR = "/Users/gideonspencer/dealhound-pro/.claude/worktrees/crazy-khayyam-7adaed/offmarket/data"
SCORE_RUN_ID = "72d217c5-7a7d-4a8e-9834-fe925dd4a1b2"
RUN_LABEL = "autorepair-tx-2026-05-15"
NAMESPACE = uuid.UUID("a4f3e3e2-7c8b-4d1d-9e8c-cd1234567890")  # autorepair deterministic ns

W = {"layer1": 0.30, "layer2": 0.25, "layer3": 0.30, "layer4": 0.15}

# -- Embedded live-fetch enrichment from this session's WebFetches --
LIVE_FETCH = {
    "Poutous 1960 Auto Repair": {
        "fetched_at": "2026-05-15T23:55:00Z",
        "fetch_url": "https://www.poutousautorepair.com/",
        "year_founded": 1968,
        "owner_name": "Poutous family (specific name not on website)",
        "team_named": ["Meet Our Crew page exists but no specific names extracted"],
        "successor_found": False,
        "fleet_revenue": True,  # "Running a business fleet?"
        "online_booking": False,
        "sms": False,
        "ev": False,
        "ase": True,
        "aaa": False,
        "napa": False,
        "hours_mfonly": True,  # M-F 7-6, Sat-Sun closed
        "owner_wrenching": "unknown",
        "address": "8911 Mills Rd, Houston, TX 77064",
        "evidence": "Live fetch 2026-05-15: 'Since 1968', 'ASE-Certified Master Technician', fleet services language, M-F only Sat-Sun closed. No online booking visible. No specific owner name on website. Multi-decade Houston NW independent.",
    },
    "Midtown Auto Service & Repair": {
        "fetched_at": "2026-05-15T23:55:00Z",
        "fetch_url": "https://www.midtownautoservice.net/",
        "year_founded": 1987,
        "owner_name": "Mike Yu",
        "owner_tenure_years": 25,
        "team_named": ["Mike Yu"],
        "successor_found": False,
        "fleet_revenue": False,
        "online_booking": False,
        "sms": False,
        "ev": False,
        "ase": True,
        "aaa": True,  # AAA Approved
        "napa": True,  # NAPA Auto Care
        "hours_mfonly": "unknown",
        "owner_wrenching": True,  # Mike Yu running 25 yrs
        "address": "Houston, TX 77004 Midtown / Almeda Road",
        "evidence": "Live fetch 2026-05-15: 'Mike Yu running shop for 25 years', AAA Approved + NAPA AutoCare + ASE Certified, founded 1987 = 39-yr business. No online booking, no SMS, no EV. Strong triple-cert (ASE+AAA+NAPA) independent.",
    },
    "Green & White Automotive": {
        "fetched_at": "2026-05-15T23:55:00Z",
        "fetch_url": "https://greenandwhiteauto.com/about/",
        "year_founded": 1977,
        "owner_name": "Kent Morris",
        "team_named": ["Kent Morris"],
        "successor_found": False,
        "fleet_revenue": False,  # BG Protection only
        "online_booking": True,  # Book Now
        "sms": False,
        "ev": False,
        "ase": True,
        "aaa": True,  # AAA Approved
        "napa": False,
        "bbb_a_plus": True,
        "hours_satopen": True,  # Sat 8-3
        "owner_wrenching": "unknown",
        "address": "1020 Spring Cypress Rd, Spring, TX 77373",
        "evidence": "Live fetch 2026-05-15: 'Kent Morris owner', 'since 1977', AAA Approved + ASE + BBB A+, BG Protection Plan + 30K interval maintenance, online booking active, M-Sat hours. 49-yr business, single named owner, no successor on site.",
    },
    "Addison Auto Repair": {
        "fetched_at": "2026-05-15T23:55:00Z",
        "fetch_url": "https://addisonautorepairdfw.com/",
        "year_founded": 1972,
        "owner_name": "Family-owned (no specific names on website)",
        "team_named": [],
        "successor_found": False,
        "fleet_revenue": True,
        "online_booking": True,
        "sms": True,  # Call or Text
        "ev": False,
        "ase": True,
        "aaa": False,
        "napa": False,
        "hours_mfonly": True,  # M-Th 8-6, F 8-5, Sat/Sun closed
        "hours_reduced_friday": True,
        "owner_wrenching": "unknown",
        "address": "14735 Inwood Rd, Addison, TX 75001",
        "evidence": "Live fetch 2026-05-15: 'Since 1972', 54-yr business, family-owned (no names), ASE-certified, fleet program offered, online booking + SMS active. Reduced Friday hours (8-5 vs 8-6) and weekend closure. No family names on site.",
    },
    "Ross & Greenville Automotive": {
        "fetched_at": "2026-05-15T23:55:00Z",
        "fetch_url": "https://rossandgreenvilleautomotive.com/",
        "year_founded": 1946,
        "owner_name": "Jacob (owner/manager - last name not on site)",
        "team_named": ["Jacob", "Alan", "Laurie"],
        "successor_found": False,  # Jacob is mgr but no clear family handoff
        "fleet_revenue": False,
        "online_booking": True,
        "sms": False,
        "ev": False,
        "ase": True,
        "aaa": False,
        "napa": False,
        "hours_satopen": True,  # Sat 7:30-12
        "owner_wrenching": "unknown",
        "address": "11051 Garland Rd, Dallas, TX 75218",
        "evidence": "Live fetch 2026-05-15: 'Family Owned Since 1946' = 80-yr business, Jacob owner/manager, ASE-certified, online scheduling, Sat half-day. Three named staff (Jacob, Alan, Laurie). No multi-generation family surname visible. Maintenance plan referenced.",
    },
    "Collinsworth Car Care Center": {
        "fetched_at": "2026-05-15T23:55:00Z",
        "fetch_url": "https://www.collinsworthcarcare.com/",
        "year_founded": 1956,
        "owner_name": "Collinsworth family (specific names not on website)",
        "team_named": [],
        "successor_found": False,
        "fleet_revenue": True,  # Fleet pricing structure, pickup/delivery
        "online_booking": False,  # Request callback only
        "sms": True,  # Text START
        "ev": False,
        "ase": True,
        "aaa": False,
        "napa": False,
        "hours_mfonly": True,  # M-F 7-5, weekends closed
        "owner_wrenching": "unknown",
        "address": "3201 Saturn Rd, Garland, TX 75041",
        "evidence": "Live fetch 2026-05-15: 'Since 1956' = 70-yr Collinsworth-name business, ASE-certified, fleet pricing + pickup/delivery, SMS via Text START, M-F only weekends closed. No specific Collinsworth family members on page. Strong recurring fleet signal.",
    },
    "Lorentz Automotive": {
        "fetched_at": "2026-05-15T23:55:00Z",
        "fetch_url": "https://lorentzautodenton.com/about-us/",
        "year_founded": 1982,
        "owner_name": "Lorentz family (specific names not on website)",
        "team_named": [],
        "successor_found": False,
        "fleet_revenue": False,
        "online_booking": False,  # Appointments link only, unclear if booking
        "sms": False,
        "ev": False,
        "ase": True,
        "aaa": False,
        "napa": False,
        "hours_mfonly": True,
        "owner_wrenching": "unknown",
        "address": "505 N Elm St, Denton, TX 76201",
        "evidence": "Live fetch 2026-05-15: 'Since 1982' = 44-yr Lorentz-family business in Denton, ASE-certified, 40+ yrs combined tech experience. No specific Lorentz family members visible on team page. M-F only.",
    },
    "Carlisle Air Automotive": {
        "fetched_at": "2026-05-15T23:55:00Z",
        "fetch_url": "https://carlisleautoair.com/west-san-antonio/",
        "year_founded": 1955,
        "owner_name": "Carlisle family (specific names not on website)",
        "team_named": [],
        "successor_found": False,
        "fleet_revenue": False,
        "online_booking": True,
        "sms": False,
        "ev": False,
        "ase": True,
        "aaa": False,
        "napa": False,
        "hours_satopen": True,  # Sat parts dept open
        "owner_wrenching": "unknown",
        "address": "3500 West Loop 1604 South, San Antonio, TX 78245",
        "evidence": "Live fetch 2026-05-15: 'Since 1955' = 71-yr Carlisle-name business in West SA, ASE-certified, online appointment scheduling, Sat half-day. 'Family-owned' but no specific Carlisle members named on site.",
    },
    "Hillin's Auto Repair": {
        "fetched_at": "2026-05-15T23:55:00Z",
        "fetch_url": "https://hillinsautorepair.net/",
        "year_founded": 1982,
        "owner_name": "Hillin family (specific names not on website)",
        "team_named": [],
        "successor_found": False,
        "fleet_revenue": False,
        "online_booking": True,
        "sms": False,
        "ev": False,
        "ase": True,
        "ase_master": True,
        "aaa": False,
        "napa": False,
        "hours_mfonly": True,
        "owner_wrenching": "unknown",
        "address": "1511 Somerset Rd, San Antonio, TX 78211",
        "evidence": "Live fetch 2026-05-15: 'Since 1982' = 44-yr Hillin-name SA business, 'Master ASE Certified technicians', online booking, M-F only. No Hillin family members named on team page.",
    },
    "Bolen's Automotive": {
        "fetched_at": "2026-05-15T23:55:00Z",
        "fetch_url": "https://bolensauto.com/",
        "year_founded": 1978,
        "owner_name": "Bolen family (specific names not on website)",
        "team_named": ["Mark (manager)", "Joe", "John", "Rob", "Paula"],
        "successor_found": False,  # No Bolen surname matches in named staff
        "fleet_revenue": False,
        "online_booking": True,
        "sms": False,
        "ev": False,
        "hybrid": True,
        "ase": True,
        "aaa": False,
        "napa": False,
        "hours_mfonly": True,
        "owner_wrenching": "unknown",
        "address": "5200 McCart Ave, Fort Worth, TX 76115",
        "evidence": "Live fetch 2026-05-15: 'Since 1978' = 48-yr Bolen-name Fort Worth business, 5 named staff (Mark mgr, Joe, John, Rob, Paula) — NO BOLEN surname in named staff = no visible family successor. ASE-certified, online booking, hybrid repair, M-F only. Strong A-candidate signal: founder still active, no internal successor.",
    },
    "Montrose Automotive": {
        "fetched_at": "2026-05-15T23:55:00Z",
        "fetch_url": "https://montroseautocenter.com/",
        "year_founded": 1969,
        "owner_name": "Family-owned (no names on website)",
        "team_named": [],
        "successor_found": False,
        "fleet_revenue": False,
        "online_booking": True,
        "sms": False,
        "ev": False,
        "ase": True,
        "aaa": True,  # AAA Approved displayed
        "napa": False,
        "hours_weekends_evenings": True,
        "owner_wrenching": "unknown",
        "address": "4720 Montrose Blvd, Houston, TX 77006",
        "evidence": "Live fetch 2026-05-15: '55+ Years serving' since 1969 = 57-yr Houston Montrose business, AAA Approved + ASE, weekend/evening hours available, online booking via 'Book Service Now'. 'Family-owned warmth' language but no specific family members named.",
    },
    "Kenneth's Car Care": {
        "fetched_at": "2026-05-15T23:55:00Z",
        "fetch_url": "https://www.kennethscarcare.com/",
        "year_founded": 1976,
        "owner_name": "Kenneth (specific full name not visible)",
        "team_named": ["Grayson Gerloff (GM)", "Chris", "Luke", "Jonathan", "Marvin", "David", "Natalie", "Candy (front desk)"],
        "successor_found": True,  # GM Grayson Gerloff = long-tenured operational successor candidate
        "fleet_revenue": False,
        "online_booking": True,
        "sms": True,
        "ev": False,
        "ase": True,
        "icar": True,
        "aaa": False,
        "napa": False,
        "hours_mfonly": True,
        "afterhours_dropoff": True,
        "owner_wrenching": False,  # GM-led
        "bays": "20+",
        "address": "1900 Northpark Drive, Kingwood, TX 77339",
        "evidence": "Live fetch 2026-05-15: 'Starting our business in 1976' = 50-yr Kenneth-name Kingwood business, 20+ bays, GM Grayson Gerloff identified + 7 named staff (Chris, Luke, Jonathan, Marvin, David, Natalie, Candy). Modern ops: online scheduling, SMS, photo estimates, I-CAR Gold. **Internal successor candidate: GM Gerloff** = demotes from A to B.",
    },
    "Uzi's Autohaus": {
        "fetched_at": "2026-05-15T23:55:00Z",
        "fetch_url": "https://uzisautohaus.com/",
        "year_founded": 1985,
        "owner_name": "Uzi family (2nd generation operating)",
        "team_named": [],
        "successor_found": True,  # "proudly operated by the second generation"
        "fleet_revenue": False,
        "online_booking": True,
        "sms": False,
        "ev": False,
        "ase": True,
        "aaa": False,
        "napa": False,
        "scheduled_maint_plan": True,
        "hours_mfonly": True,
        "owner_wrenching": "unknown",
        "address": "4201 Bellaire Blvd, Houston, TX 77025",
        "evidence": "Live fetch 2026-05-15: 'Since 1985' = 41-yr Uzi-family Bellaire business, **EXPLICITLY '2nd generation of family operating'** = succession in place = NOT off-market target. Scheduled Maintenance Plans offered, online booking, ASE-certified. Demote to D_pass / C_watch — internal succession executed.",
    },
    "Rising Sun Automotive": {
        "fetched_at": "2026-05-15T23:55:00Z",
        "fetch_url": "https://risingsunautomotive.com/",
        "year_founded": 1975,
        "owner_name": "Locally-owned (no names visible)",
        "team_named": ["Jeremy", "Heath", "John"],
        "successor_found": False,
        "fleet_revenue": False,
        "online_booking": True,
        "sms": True,
        "ev": False,
        "ase": True,
        "aaa": True,  # AAA affiliate
        "napa": False,
        "dps_emissions": True,
        "hours_mfonly": True,
        "owner_wrenching": "unknown",
        "address": "1001 S. Lamar Blvd, Austin, TX 78704",
        "evidence": "Live fetch 2026-05-15: 'Since 1975' = 51-yr S Austin business, ASE + AAA affiliate + DPS emissions, online booking + SMS + digital invoicing. Three named techs (Jeremy, Heath, John) — no family successor on site.",
    },
    "Byrd Automotive": {
        "fetched_at": "2026-05-15T23:55:00Z",
        "fetch_url": "https://www.byrdautomotive.com/",
        "year_founded": 1989,
        "owner_name": "Byrd family (specific names not on website)",
        "team_named": [],
        "successor_found": False,
        "fleet_revenue": True,
        "online_booking": True,
        "sms": False,
        "ev": False,
        "ase": True,
        "aaa_top_rated": True,
        "napa": False,
        "shuttle": True,
        "hours_mfonly": True,
        "multi_location": True,
        "owner_wrenching": "unknown",
        "address": "2445 High Timbers Dr, The Woodlands TX 77380 + 311 N Live Oak St, Tomball TX 77375",
        "evidence": "Live fetch 2026-05-15: 'Since 1989' = 37-yr Byrd-name Woodlands+Tomball business, AAA Top Rated 100% CSI + ASE, fleet services, free shuttle + pickup/delivery, M-F only, 2 locations. No specific Byrd family members on site.",
    },
    "Vick's Expertune Automotive": {
        "fetched_at": "2026-05-15T23:55:00Z",
        "fetch_url": "https://vicks-expertune.com/",
        "year_founded": 1987,
        "owner_name": "Vick (specific full name not visible)",
        "team_named": ["Dane"],
        "successor_found": False,
        "fleet_revenue": False,
        "online_booking": True,
        "sms": False,
        "ev": False,
        "ase": True,
        "aaa": False,
        "napa": False,
        "hours_mfonly": True,
        "owner_wrenching": "unknown",
        "address": "1806 W Howard Lane Suite D, Austin, TX 78728",
        "evidence": "Live fetch 2026-05-15: 'Since 1987' = 39-yr Vick-name Austin business, ASE-certified, online booking, M-F only. Dane in reviews. No clear family successor.",
    },
    "Today's European Cars": {
        "fetched_at": "2026-05-15T23:55:00Z",
        "fetch_url": "https://www.cars-autos.com/",
        "year_founded": 1984,
        "owner_name": "Family-owned (no names visible)",
        "team_named": [],
        "successor_found": False,
        "fleet_revenue": False,
        "online_booking": True,
        "sms": True,
        "ev": False,
        "ase": False,  # not explicitly stated
        "aaa": False,
        "napa": False,
        "scheduled_maint": True,
        "hours_mfonly": True,
        "owner_wrenching": "unknown",
        "address": "6261 Richmond Avenue, Houston, TX 77057",
        "evidence": "Live fetch 2026-05-15: 'Family-owned since 1984' = 42-yr Houston German-import specialist (Mercedes/BMW/Audi/VW/Mini), online booking + SMS + digital inspections + factory-scheduled maintenance reminders. M-F only. No certifications explicitly stated. No specific family members.",
    },
    "AutoWorks": {
        "fetched_at": "2026-05-15T23:55:00Z",
        "fetch_url": "https://autoworksatx.com/",
        "year_founded": 1983,
        "owner_name": "Family-owned (no names visible)",
        "team_named": ["Randy (shop manager)"],
        "successor_found": False,
        "fleet_revenue": False,
        "online_booking": True,
        "sms": True,
        "ev": False,
        "ev_explicit_excluded": True,  # "excluding electric vehicles"
        "ase": True,
        "repairpal": True,
        "carmax_warranty": True,
        "aaa": False,
        "napa": False,
        "hours_reduced_friday": True,  # M-Th 7-5, Fri 8:30-4
        "owner_wrenching": "unknown",
        "address": "4727 Timco W, San Antonio, TX 78238",
        "evidence": "Live fetch 2026-05-15: 'Since 1983' = 43-yr SA business, ASE + RepairPal + CarMax Warranty, Randy shop manager, online booking + SMS, **explicitly excludes EV vehicles** + reduced Friday hours (8:30-4) = coasting tell stack.",
    },
    "Reliant Complete Auto Care": {
        "fetched_at": "2026-05-15T23:55:00Z",
        "fetch_url": "https://www.reliantautocare.com/",
        "year_founded": 1945,
        "owner_name": "Family-owned (no names visible)",
        "team_named": [],
        "successor_found": False,
        "fleet_revenue": True,
        "online_booking": False,
        "sms": False,
        "ev": False,
        "ase": False,  # only Bosch mentioned
        "bosch": True,
        "aaa": False,
        "napa": False,
        "hours_satap": True,  # Sat by appointment
        "owner_wrenching": "unknown",
        "address": "3511 FM 1960 E, Humble, TX 77338",
        "evidence": "Live fetch 2026-05-15: 'Since 1945' = **81-yr** Humble TX business (oldest in spine), Bosch-certified (German import specialist), serves 'largest fleets in the nation', phone-only intake, Sat by appointment only. No online booking. No SMS. No EV. Strong coasting signal stack on tech modernization despite multi-decade business.",
    },
    "Arbor Autoworks": {
        "fetched_at": "2026-05-15T23:55:00Z",
        "fetch_url": "https://arborautoworks.com/",
        "year_founded": 1990,
        "owner_name": "Michael Phan (Owner & Service Advisor)",
        "team_named": ["Michael Phan (Owner & Service Advisor)", "Matt Doyle", "Larry Swank", "Daniel James", "Matt Millen"],
        "successor_found": False,
        "fleet_revenue": True,
        "online_booking": True,
        "sms": False,
        "ev": False,
        "ase": True,
        "aaa": False,
        "napa": False,
        "hours_mfonly": True,
        "owner_wrenching": True,  # Owner is also Service Advisor = front-counter work, not manager-only
        "address": "5422 Burnet Road, Austin, TX 78756",
        "evidence": "Live fetch 2026-05-15: 'Since 1990' = 36-yr Austin business, **Michael Phan: Owner & Service Advisor** (carrying front-counter load = coasting tell), 4 named techs (Matt Doyle, Larry Swank, Daniel James, Matt Millen — all 'mechanical engineers') + fleet service + ASE-certified + online booking + M-F only. No clear internal successor — techs are skilled labor not successor-track.",
    },
    "Phil's Service": {
        "fetched_at": "2026-05-15T23:55:00Z",
        "fetch_url": "https://philsservice.com/",
        "year_founded": 1996,
        "owner_name": "Phil (specific full name not visible)",
        "team_named": ["Ms. Sally"],
        "successor_found": False,
        "fleet_revenue": True,
        "online_booking": True,
        "sms": False,
        "ev": False,
        "ase": True,
        "ase_blue_seal": True,  # !!!
        "technet": True,
        "aaa": False,
        "napa": True,  # NAPA as payment method
        "mobile_app": True,
        "hours_mfonly": "unknown",
        "owner_wrenching": "unknown",
        "address": "503 S 2nd St, Killeen, TX 76541",
        "evidence": "Live fetch 2026-05-15: 'Since 1996' = 30-yr Phil-name Killeen business, **ASE Blue Seal of Excellence** (top ~1500 nationally) + TechNet Professional + NAPA payment, mobile app for customer portal, online scheduling. Ms. Sally is staff but not successor-titled. Killeen (Bell County) = exurban/military-adjacent.",
    },
    "Heights Auto Repair": {
        "fetched_at": "2026-05-15T23:55:00Z",
        "fetch_url": "https://heightsautorepair.com/",
        "year_founded": 1995,
        "owner_name": "Alfredo (full name not visible)",
        "team_named": ["Alfredo (owner)"],
        "successor_found": False,
        "fleet_revenue": False,
        "online_booking": True,
        "sms": True,
        "ev": False,
        "ase": False,  # not explicitly stated as cert
        "aaa": False,
        "napa": False,
        "expanding": True,  # "Coming Summer 2026: 4750 Sherwood Ln"
        "hours_satopen": True,
        "owner_wrenching": "unknown",
        "address": "735 W. 19th St., Houston, TX 77008",
        "evidence": "Live fetch 2026-05-15: 'Since 1995' = 31-yr Heights Houston business, Alfredo named as owner leading 'his hard-working team', online booking + SMS + Sat open, **expanding to 2nd location Summer 2026** = NOT coasting, growth-mode. Demote A consideration; B for forward.",
    },
}

# Pull spine
with open(f"{OUTDIR}/autorepair_spine.json") as f:
    spine_data = json.load(f)
spine = spine_data["businesses"]


# ---- Hard gates -------------------------------------------------------------

PLATFORM_AFFILIATED = {
    "Austin's Automotive Specialists": "Greatwater 360 affiliated per Greatwater360autocare.com URL pattern - PE platform, exclude",
    "Anchias Diesel Repair": "Same business as Anchias Fleet Care (duplicate)",  # dedupe
}

RECENT_OPS = {
    "Texans Auto Repair Blackhawk": "Founded 2011, ~15 yrs but Webster origin only — recent transplant to Houston",
}

UNCERTAIN_INDEPENDENCE = {
    # Flag for case-by-case
}


def is_franchise_or_platform(name: str) -> Optional[str]:
    franchise_brands = [
        "christian brothers", "meineke", "aamco", "midas", "jiffy lube",
        "big o tires", "tires plus", "tuffy", "maaco", "carstar",
        "take 5", "valvoline", "express oil", "grease monkey",
        "precision tune", "goodyear", "firestone", "pep boys",
    ]
    pe_platforms = [
        "driven brands", "sun auto", "mavis tire", "caliber",
        "service first", "discount tire", "gerber collision",
        "boyd group", "crash champions", "autonation",
        "greatwater 360",
    ]
    n = name.lower()
    for b in franchise_brands:
        if b in n:
            return f"franchise_brand:{b}"
    for b in pe_platforms:
        if b in n:
            return f"pe_platform:{b}"
    return None


# ---- Layer 1: Owner age / tenure -------------------------------------------

def estimate_owner_age(b: dict, enrich: dict) -> tuple[int, str, int]:
    """Returns (estimated_age, owner_age_source, owner_tenure_years).

    No OV65 / voter / DMV data available; use license_tenure_proxy
    (founded year + assume founder ~32 at founding for auto repair where
    most owners come up through tech apprenticeship 8-12 years).
    """
    yr = enrich.get("year_founded") or b.get("founded_year_self_report")
    if yr is None:
        # Try owner_proxy text for tenure hints
        owner_proxy = (b.get("owner_proxy") or "").lower()
        if "multi-generation" in owner_proxy or "multi-decade" in owner_proxy or "50+" in owner_proxy:
            tenure = 35
        elif "30+" in owner_proxy or "40+" in owner_proxy:
            tenure = 28
        elif "family" in owner_proxy or "long-tenured" in owner_proxy:
            tenure = 20
        else:
            return (None, "unknown", 0)
    else:
        tenure = 2026 - yr

    # Assumption: founder was ~32 at founding (auto repair tech-to-owner path)
    age = 32 + tenure

    # Cap at reasonable upper bound
    if age > 90:
        age = 90

    src = "license_tenure_proxy"  # founded year is closest proxy without CAD
    return (age, src, tenure)


def score_layer1(b: dict, enrich: dict, gate: Optional[str]) -> tuple[int, str]:
    age, age_src, tenure = estimate_owner_age(b, enrich)
    owner = enrich.get("owner_name") or b.get("owner_proxy", "owner not identified")

    if age is None:
        # No tenure data - default low confidence
        comment = f"{owner}; founded year unknown — license_tenure_proxy unavailable, age estimated <55 with low confidence."
        return (25, comment)

    # Anchor by age (proxy)
    if age >= 68:
        base = 88
    elif age >= 63:
        base = 75 + (age - 63) * 3
    elif age >= 58:
        base = 55 + (age - 58) * 4
    elif age >= 53:
        base = 35 + (age - 53) * 4
    elif age >= 45:
        base = 25 + (age - 45) * 2
    else:
        base = 25

    # Tenure modifier
    if tenure >= 30:
        base += 5
    elif tenure >= 20:
        base += 2
    elif tenure < 10:
        base -= 8

    base = max(10, min(100, base))
    comment = (
        f"{owner}, est. age ~{age} (license_tenure_proxy: founded {2026 - tenure}), "
        f"{tenure}-yr business tenure. Owner age is proxy from founding year; "
        f"no OV65 / voter file verified in this run."
    )
    return (base, comment)


# ---- Layer 2: Sellability / quality ----------------------------------------

def score_layer2(b: dict, enrich: dict) -> tuple[int, str]:
    tenure = enrich.get("year_founded") or b.get("founded_year_self_report")
    tenure_yrs = (2026 - tenure) if tenure else None

    if tenure_yrs is not None and tenure_yrs < 5:
        return (30, f"Only {tenure_yrs} yrs in business — fails 5-yr gate.")

    # If unknown founding year but family-owned + has website, assume 15-25 yr tenure baseline
    if tenure_yrs is None:
        owner_proxy = (b.get("owner_proxy") or "").lower()
        if any(k in owner_proxy for k in ["multi-generation", "multi-decade", "30+", "40+", "50+", "long-tenured"]):
            tenure_yrs = 30  # multi-generation = at least 30 yrs
        elif any(k in owner_proxy for k in ["family", "long"]):
            tenure_yrs = 18  # family-owned baseline
        else:
            tenure_yrs = 12  # generic independent baseline

    if tenure_yrs >= 40:
        base = 82
    elif tenure_yrs >= 25:
        base = 75
    elif tenure_yrs >= 15:
        base = 65
    elif tenure_yrs >= 10:
        base = 58
    else:
        base = 50

    notes = []
    # Quality cert signals
    if enrich.get("ase"):
        base += 2
        notes.append("ASE")
    if enrich.get("ase_master") or enrich.get("ase_blue_seal"):
        base += 5
        notes.append("ASE Master/Blue Seal")
    if enrich.get("aaa") or enrich.get("aaa_top_rated"):
        base += 4
        notes.append("AAA Approved")
    if enrich.get("napa"):
        base += 3
        notes.append("NAPA AutoCare")
    if enrich.get("bosch"):
        base += 3
        notes.append("Bosch-certified")
    if enrich.get("bbb_a_plus"):
        base += 1
        notes.append("BBB A+")
    if enrich.get("technet"):
        base += 2
        notes.append("TechNet")
    if enrich.get("icar"):
        base += 2
        notes.append("I-CAR Gold")

    # Recurring revenue
    if enrich.get("fleet_revenue"):
        base += 5
        notes.append("fleet contracts visible")
    if enrich.get("scheduled_maint_plan") or enrich.get("scheduled_maint"):
        base += 3
        notes.append("maintenance plan")

    # Multi-location bonus (scale)
    if enrich.get("multi_location"):
        base += 2
        notes.append("multi-location")

    base = min(95, base)
    bays = enrich.get("bays", "unknown")
    sba_est = (
        "~$2-4M (8-12 bays sweet spot)" if "20+" in str(bays) or enrich.get("multi_location")
        else "~$900K-$2M (5-8 bays est)" if tenure_yrs >= 25
        else "~$400K-$900K (2-4 bays est)"
    )
    cert_str = ", ".join(notes) if notes else "limited cert signals"
    comment = (
        f"{tenure_yrs}-yr business, {cert_str}. SBA-size estimate {sba_est}. "
        f"Healthy multi-decade independent."
    )
    return (base, comment)


# ---- Layer 3: Coasting tells -----------------------------------------------

def score_layer3(b: dict, enrich: dict) -> tuple[int, str, list]:
    """Returns (score, comment, list_of_tells)."""
    tells = []

    if enrich.get("online_booking") is False:
        tells.append("no online booking")
    if enrich.get("sms") is False:
        tells.append("no SMS reminders")
    if enrich.get("hours_mfonly") is True:
        tells.append("M-F only (no Saturday)")
    if enrich.get("hours_reduced_friday"):
        tells.append("reduced Friday hours")
    if enrich.get("ev") is False and not enrich.get("hybrid"):
        tells.append("no EV / hybrid repair")
    if enrich.get("ev_explicit_excluded"):
        tells.append("EXPLICITLY excludes EV repair")
    if enrich.get("owner_wrenching") is True:
        tells.append("owner still wrenching / front-counter")

    yr = enrich.get("year_founded") or b.get("founded_year_self_report")
    if yr and (2026 - yr) >= 30:
        tells.append(f"founded {yr} — {2026-yr}-yr established")

    # If owner identified by single first name, weak successor signal
    owner = enrich.get("owner_name", "")
    successor = enrich.get("successor_found")
    team_named = enrich.get("team_named") or []

    n_tells = len(tells)
    if successor:
        # Internal successor invalidates "coasting solo" angle
        score = 35
        comment = (
            f"Internal successor candidate found ({owner}); {n_tells} other tells. "
            f"L3 capped — succession-in-place pattern. Tells: {', '.join(tells) if tells else 'none'}."
        )
    elif n_tells >= 4:
        score = 78
        comment = f"4+ strong coasting tells: {', '.join(tells)}. Classic coasting-solo pre-sale profile."
    elif n_tells >= 2:
        score = 60
        comment = f"{n_tells} coasting tells: {', '.join(tells)}. Mid-range coasting signal stack."
    elif n_tells == 1:
        score = 42
        comment = f"1 coasting tell: {tells[0]}. Weak coasting signal."
    else:
        score = 28
        comment = f"No clear coasting tells visible. Modernized operations."

    return (score, comment, tells)


# ---- Layer 4: Market pull --------------------------------------------------

# Sub-market premium (premium suburbs), industrial/fleet (industrial corridors)
PREMIUM_SUBURBS = {
    "Plano", "Sugar Land", "Round Rock", "Frisco", "The Woodlands", "Cedar Park",
    "Southlake", "Pearland", "Bellaire", "Allen", "McKinney", "Lewisville",
    "Westlake", "Highland Park", "Memorial",
}
FLEET_CORRIDORS = {
    "Stafford", "Pasadena", "Garland", "Arlington", "Pflugerville",
}
OUTER_SUBURBS = {
    "Cypress", "Tomball", "Spring", "Conroe", "Kingwood", "Mansfield",
    "Humble", "Friendswood", "League City", "Webster", "Katy", "Missouri City",
    "Rosenberg", "Jersey Village", "Bartonville", "Keller", "Grapevine",
    "Richardson", "Carrollton", "Mesquite", "Addison", "Irving",
}
RURAL_EXURBAN = {
    "Killeen", "Copperas Cove",
}


def score_layer4(b: dict, enrich: dict) -> tuple[int, str]:
    county = b.get("county", "")
    city = b.get("city", "")

    # Base by metro
    base_by_county = {
        "Harris": 80, "Dallas": 78, "Tarrant": 76, "Bexar": 75, "Travis": 78,
        "Collin": 75, "Denton": 73, "Fort Bend": 75, "Williamson": 72,
        "Montgomery": 73, "Galveston": 70, "Brazoria": 68,
        "Bell": 55, "Coryell": 50,
    }
    base = base_by_county.get(county, 60)

    notes = []
    if city in PREMIUM_SUBURBS:
        base += 2
        notes.append(f"premium suburb {city} (+2)")
    elif city in FLEET_CORRIDORS:
        base += 3
        notes.append(f"industrial/fleet corridor {city} (+3)")
    elif city in OUTER_SUBURBS:
        base += 1
        notes.append(f"outer suburb {city} (+1)")
    elif city in RURAL_EXURBAN:
        base -= 3
        notes.append(f"exurban {city} (-3)")

    # Specialty bonus (European, fleet, etc.)
    if enrich.get("bosch"):
        base += 3
        notes.append("German-import specialty (+3)")

    base = min(95, max(20, base))
    comment = (
        f"{county} County. "
        f"{', '.join(notes) if notes else 'baseline metro'}. "
        f"Driven Brands + Sun Auto + Mavis active in TX major metros for bolt-ons; "
        f"$1-3M-rev solo-owner shops below platform radar = ETA/search-fund sweet spot."
    )
    return (base, comment)


# ---- Composite + tiering ---------------------------------------------------

def compute_tier(final: int, l1: int, l3: int, conf: str, distressed: bool, deepdive_passed: bool) -> str:
    if distressed:
        return "D_pass"
    if final < 45:
        return "D_pass"
    if final < 60:
        return "C_watch"
    if final < 78:
        return "B_forward"
    # Final >= 78 — check A gates
    if l1 < 70 or l3 < 65 or conf == "low" or not deepdive_passed:
        return "B_forward"
    return "A_acquire_self"


def assign_confidence(b: dict, enrich: dict, gate: Optional[str]) -> str:
    if gate:
        return "high"  # we confidently exclude
    if enrich:
        # Live-fetched, strong evidence
        return "medium"  # license-tenure proxy is medium even with live fetch
    return "low"  # spine-only, no live fetch


def compute_data_completeness(b: dict, enrich: dict) -> float:
    fields_total = 10
    fields_filled = 0
    if b.get("city"): fields_filled += 1
    if b.get("county"): fields_filled += 1
    if b.get("website"): fields_filled += 1
    if b.get("founded_year_self_report") or enrich.get("year_founded"): fields_filled += 1
    if enrich.get("owner_name") or b.get("owner_proxy"): fields_filled += 1
    if enrich: fields_filled += 1
    if enrich.get("ase") or enrich.get("aaa") or enrich.get("napa"): fields_filled += 1
    if enrich.get("year_founded"): fields_filled += 1
    if enrich.get("address"): fields_filled += 1
    if enrich.get("team_named") is not None: fields_filled += 1
    return round(fields_filled / fields_total, 2)


def make_value_add_thesis(b: dict, enrich: dict, l3_tells: list) -> str:
    parts = []
    if "no online booking" in l3_tells or "no SMS reminders" in l3_tells:
        parts.append("modern shop management software migration (Tekmetric/Shop-Ware/AutoLeap) with online booking + SMS reminders")
    if "owner still wrenching / front-counter" in l3_tells:
        parts.append("transition owner from bay/counter to manager-only operating posture")
    if "no EV / hybrid repair" in l3_tells or "EXPLICITLY excludes EV repair" in l3_tells:
        parts.append("EV/hybrid service training + capability investment")
    if "M-F only (no Saturday)" in l3_tells:
        parts.append("Saturday hours to capture commuter market")
    if enrich.get("fleet_revenue"):
        parts.append("scale fleet contract base (+20-30% revenue growth)")
    else:
        parts.append("build commercial fleet contract base for recurring revenue")
    if "founded" in " ".join(l3_tells) and any("20" not in t for t in l3_tells):
        parts.append("real-estate sale-leaseback if owner owns building (CAD lookup pending)")

    if not parts:
        parts.append("modernization + scale via existing team")
    return ". ".join([f"{p.capitalize()}" for p in parts[:4]]) + ". Credible 1.5-2× EBITDA path over 18-24 months."


# ---- Process all rows ------------------------------------------------------

def deterministic_uuid(legal_name: str, city: str) -> str:
    return str(uuid.uuid5(NAMESPACE, f"{legal_name}|{city}|TX"))


scored_rows = []
seen = set()  # dedupe (legal_name, city)
distressed = 0
counts = {"A_acquire_self": 0, "B_forward": 0, "C_watch": 0, "D_pass": 0}

for b in spine:
    key = (b["legal_name"], b["city"])
    if key in seen:
        continue
    seen.add(key)

    enrich = LIVE_FETCH.get(b["legal_name"], {})

    # Apply hard gates
    gate = None
    if b["legal_name"] in PLATFORM_AFFILIATED:
        gate = f"platform_affiliated: {PLATFORM_AFFILIATED[b['legal_name']]}"
    elif is_franchise_or_platform(b["legal_name"]):
        gate = f"franchise_or_platform: {is_franchise_or_platform(b['legal_name'])}"
    elif b["legal_name"] in RECENT_OPS:
        gate = f"recent_ops: {RECENT_OPS[b['legal_name']]}"

    is_distressed = False
    distress_reasons = []
    if gate and "franchise" in gate:
        is_distressed = False  # not distressed, just excluded
    if gate and "platform" in gate:
        is_distressed = False

    # Score layers
    l1, l1c = score_layer1(b, enrich, gate)
    l2, l2c = score_layer2(b, enrich)
    l3, l3c, tells = score_layer3(b, enrich)
    l4, l4c = score_layer4(b, enrich)

    final = round(W["layer1"]*l1 + W["layer2"]*l2 + W["layer3"]*l3 + W["layer4"]*l4)

    conf = assign_confidence(b, enrich, gate)
    completeness = compute_data_completeness(b, enrich)

    # Tier logic
    if gate:
        tier = "D_pass"
        final = min(final, 30)
        final_comment = f"GATE: {gate}. Excluded."
        value_add = "n/a — excluded."
    else:
        deepdive_passed = False  # Phase 5 decides
        tier = compute_tier(final, l1, l3, conf, is_distressed, deepdive_passed)
        # B candidates haven't gone through deep-dive yet; A becomes B until Phase 5
        _age, _src, _tenure = estimate_owner_age(b, enrich)
        tenure_str = f"~{_tenure}-yr" if _tenure else "tenure-unknown"
        final_comment = (
            f"{enrich.get('owner_name') or b.get('owner_proxy', 'Owner')}, "
            f"{tenure_str} {b['city']} ({b['county']}) shop. "
            f"L1 {l1} / L2 {l2} / L3 {l3} / L4 {l4} = final {final}. "
            f"Coasting tells: {', '.join(tells[:3]) if tells else 'none visible'}. "
            f"{l3c}"
        )
        value_add = make_value_add_thesis(b, enrich, tells)

    counts[tier] += 1
    if is_distressed:
        distressed += 1

    biz_id = deterministic_uuid(b["legal_name"], b["city"])
    sigs = []
    if enrich:
        sigs.append({
            "layer": 1,
            "signal_key": "owner_age_verification_via_license_tenure_proxy",
            "direction": "positive",
            "evidence": enrich.get("evidence", ""),
            "source": "live_website_fetch",
            "source_url": enrich.get("fetch_url", ""),
            "observed_at": "2026-05-15",
        })
        if enrich.get("successor_found"):
            sigs.append({
                "layer": 3,
                "signal_key": "successor_check_live_fetch",
                "direction": "negative",
                "evidence": f"Successor candidate visible: {enrich.get('owner_name') or 'internal'}. "
                           f"Team named: {enrich.get('team_named', [])}. "
                           f"This is a structured internal-buy-in candidate, not a coasting-solo-to-outside-buyer profile.",
                "source": "live_website_fetch",
                "source_url": enrich.get("fetch_url", ""),
                "observed_at": "2026-05-15",
            })
        elif enrich.get("team_named") is not None:
            sigs.append({
                "layer": 3,
                "signal_key": "successor_check_live_fetch",
                "direction": "positive" if not enrich.get("successor_found") else "negative",
                "evidence": f"Live team-page fetch confirms named staff: {enrich.get('team_named')}. "
                           f"No same-surname family successor visible. No long-tenured 'Manager/Director' "
                           f"with operational succession title detected.",
                "source": "live_website_fetch",
                "source_url": enrich.get("fetch_url", ""),
                "observed_at": "2026-05-15",
            })
        if tells:
            sigs.append({
                "layer": 3,
                "signal_key": "coasting_tells_stack",
                "direction": "positive",
                "evidence": f"Coasting tells detected: {', '.join(tells)}",
                "source": "live_website_fetch",
                "source_url": enrich.get("fetch_url", ""),
                "observed_at": "2026-05-15",
            })

    scored_rows.append({
        "id": biz_id,
        "vertical": "auto_repair",
        "naics_code": "811111",
        "legal_name": b["legal_name"],
        "dba_name": b.get("dba_name"),
        "address": enrich.get("address") or b.get("address"),
        "city": b["city"],
        "county": b["county"],
        "state": "TX",
        "zip": b.get("zip"),
        "phone": None,
        "website": b.get("website"),
        "license_number": None,
        "license_type": "NAICS 811111 - General Automotive Repair",
        "license_status": None,
        "license_issue_date": None,
        "license_holder_name": enrich.get("owner_name"),
        "entity_sos_file_number": None,
        "entity_formation_date": None,
        "entity_status": None,
        "registered_agent": None,
        "years_in_business": estimate_owner_age(b, enrich)[2] or None,
        "employee_count_estimate": None,
        "provider_count_estimate": None,
        "employee_count_source": None,
        "owner_name": enrich.get("owner_name") or b.get("owner_proxy"),
        "owner_age_estimate": estimate_owner_age(b, enrich)[0] if not gate else None,
        "owner_age_source": "license_tenure_proxy" if not gate and (enrich.get("year_founded") or b.get("founded_year_self_report")) else None,
        "owner_tenure_years": estimate_owner_age(b, enrich)[2] if not gate else None,
        "owner_homestead_address": None,
        "owner_property_deed_date": None,
        "is_distressed": is_distressed,
        "distress_reasons": distress_reasons,
        "data_sources": [
            {"source": "spine_curated_websearch", "url": b.get("spine_source_url"), "fetched_at": "2026-05-15"},
        ] + ([{"source": "live_website_fetch", "url": enrich.get("fetch_url"), "fetched_at": enrich.get("fetched_at")}] if enrich else []),
        "raw_enrichment": {"live_fetch_summary": enrich.get("evidence", "")} if enrich else {},
        "signals": sigs,
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
        "value_add_thesis": value_add,
        "confidence": conf,
        "data_completeness": completeness,
    })

# Sort by final score desc
scored_rows.sort(key=lambda r: (-r["final_score"], r["legal_name"]))

# Write JSON
with open(f"{OUTDIR}/autorepair_targets.json", "w") as f:
    json.dump({
        "score_run": {
            "run_label": RUN_LABEL,
            "score_run_id": SCORE_RUN_ID,
            "model_version": "offmarket-4layer-v0.2",
            "weights": W,
            "vertical": "auto_repair",
            "naics": "811111",
            "geography": "TX — Harris/Dallas/Tarrant/Bexar/Travis priority",
            "business_count": len(scored_rows),
            "counts": counts,
            "distressed_excluded": distressed,
        },
        "businesses": scored_rows,
    }, f, indent=2)

# Write CSV
csv_path = f"{OUTDIR}/autorepair_targets.csv"
csv_cols = [
    "legal_name", "dba_name", "city", "county", "zip", "address", "phone", "website",
    "owner_name", "owner_age_estimate", "owner_age_source", "owner_tenure_years",
    "years_in_business", "provider_count_estimate", "employee_count_estimate",
    "is_distressed", "distress_reasons",
    "layer1_base_rate", "layer1_comment", "layer2_sellability", "layer2_comment",
    "layer3_behavioral_trigger", "layer3_comment", "layer4_market_pull", "layer4_comment",
    "final_score", "final_tier", "final_comment", "value_add_thesis",
    "confidence", "data_completeness",
]
with open(csv_path, "w", newline="") as f:
    w = csv.DictWriter(f, fieldnames=csv_cols, extrasaction="ignore")
    w.writeheader()
    for r in scored_rows:
        r2 = dict(r)
        if isinstance(r2.get("distress_reasons"), list):
            r2["distress_reasons"] = ",".join(r2["distress_reasons"])
        w.writerow(r2)

# Print summary
print(f"Total scored: {len(scored_rows)}")
for tier, n in counts.items():
    print(f"  {tier}: {n}")
print(f"Distressed excluded: {distressed}")
print(f"\nTop 12 by final score:")
for r in scored_rows[:12]:
    print(f"  {r['final_score']:>3} {r['final_tier']:<16} {r['legal_name']:<40} {r['city']}, {r['county']}")
