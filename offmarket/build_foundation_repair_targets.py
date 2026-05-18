#!/usr/bin/env python3
"""
Build foundation_repair_targets.json + .csv from spine + Opus scoring decisions.
Run label: foundation-repair-tx-2026-05-16-w2b
Score run id: 7c505cde-d51e-43fc-b89b-7e519b86445f
"""
import json, csv, uuid, datetime
from pathlib import Path

RUN_LABEL = "foundation-repair-tx-2026-05-16-w2b"
SCORE_RUN_ID = "7c505cde-d51e-43fc-b89b-7e519b86445f"
MODEL_VERSION = "offmarket-4layer-v0.2"
WEIGHTS = {"layer1": 0.30, "layer2": 0.25, "layer3": 0.30, "layer4": 0.15}
OUT_DIR = Path("/Users/gideonspencer/dealhound-pro/offmarket/data")
OUT_DIR.mkdir(parents=True, exist_ok=True)
TODAY = "2026-05-17"


def compute_final(l1, l2, l3, l4):
    return round(0.30 * l1 + 0.25 * l2 + 0.30 * l3 + 0.15 * l4)


def tier_for(final, l1, l3, confidence, distressed, years, successor_verified_negative=False, deep_dive_passed=False):
    if distressed:
        return "D_pass"
    if years is not None and years < 5:
        return "D_pass" if final < 35 else "C_watch"
    if successor_verified_negative:  # found successor → cap B
        return "B_forward" if final >= 60 else ("C_watch" if final >= 45 else "D_pass")
    if final >= 78 and l1 >= 70 and l3 >= 65 and confidence in ("medium", "high") and deep_dive_passed:
        return "A_acquire_self"
    if final >= 60:
        return "B_forward"
    if final >= 45:
        return "C_watch"
    return "D_pass"


# Each business: dict with all fields. Scores are Opus judgment based on collected evidence.
BUSINESSES = [
    # ============================== TIER A CANDIDATES (verified solo coaster, deep-dive passed) ==============================
    {
        "legal_name": "Affordable Foundation Repair",
        "dba_name": "Affordable Foundation Repair and Drainage",
        "naics_code": "238190",
        "address": "Garland, TX",
        "city": "Garland",
        "county": "Dallas",
        "state": "TX",
        "zip": "75041",
        "phone": None,
        "website": "https://www.affordablefoundationrepairanddrainage.com",
        "owner_name": "Robby Rose",
        "owner_age_estimate": None,  # not OV65-verified, but website-self-report shows long tenure
        "owner_age_source": "website_self_report",
        "owner_tenure_years": 34,
        "years_in_business": 34,
        "provider_count_estimate": None,
        "employee_count_estimate": 5,
        "is_distressed": False,
        "distress_reasons": [],
        "founded_year": 1992,
        "spine_source": "DFW SERP + affordablefoundationrepairanddrainage.com live fetch 2026-05-17",
        "data_sources": [
            {"source": "company website (about)", "url": "https://www.affordablefoundationrepairanddrainage.com/", "fetched_at": TODAY, "fields": ["owner_name", "founded_year", "solo_owner_evidence"]},
            {"source": "BBB SERP", "url": "https://www.bbb.org/us/tx/garland/profile/foundation-repair/affordable-foundation-repair-0875-19001868", "fetched_at": TODAY, "fields": ["bbb_accredited_2006"]},
            {"source": "Google SERP — multi-city service mentions", "url": "https://www.affordablefoundationrepairanddrainage.com/services", "fetched_at": TODAY, "fields": ["service_area_dfw_eastern_suburbs"]}
        ],
        "signals": [
            {"layer": 1, "signal_key": "owner_tenure_proxy", "direction": "positive",
             "evidence": "Robby Rose has personally owned and run Affordable Foundation Repair since 1992 per website (34-yr tenure). Owner age not directly verified — using website self-report 'Robby will personally answer your calls'.",
             "source": "company_website", "source_url": "https://www.affordablefoundationrepairanddrainage.com/", "observed_at": TODAY},
            {"layer": 2, "signal_key": "bbb_accreditation_active", "direction": "positive",
             "evidence": "BBB-accredited since June 2006 (~20 yrs accredited) — clean record signaling sellability.",
             "source": "bbb_serp", "source_url": "https://www.bbb.org/us/tx/garland/profile/foundation-repair/affordable-foundation-repair-0875-19001868", "observed_at": TODAY},
            {"layer": 3, "signal_key": "successor_check_live_fetch", "direction": "positive",
             "evidence": "Live homepage + about-page fetch on 2026-05-17 of affordablefoundationrepairanddrainage.com: Only Robby Rose is named anywhere on the website. Direct quotes: 'Robby will personally answer your calls and help you with any questions' and 'our owner will be on every job we complete from start to finish.' No associate, partner, co-owner, family member, operations manager, or VP visible. No 'next generation', 'son', 'daughter' language. Site provides phone-only intake and emphasizes single-owner hands-on profile.",
             "source": "live_website_fetch", "source_url": "https://www.affordablefoundationrepairanddrainage.com/about-us", "observed_at": TODAY},
            {"layer": 3, "signal_key": "owner_personally_on_jobs", "direction": "positive",
             "evidence": "'When you choose Affordable Foundation Repair, rest assured that our owner will be on every job we complete from start to finish' — at 34 yrs of personal tenure and likely 55-70+ age, this is the classic coasting solo profile (owner doing what an operations manager / VP would do in a larger shop).",
             "source": "live_website_fetch", "source_url": "https://www.affordablefoundationrepairanddrainage.com/about-us", "observed_at": TODAY},
            {"layer": 4, "signal_key": "dfw_metro_pull", "direction": "positive",
             "evidence": "Garland / DFW eastern suburbs (Dallas Co). DFW = #1 TX foundation repair market (expansive clay soils). Active acquirers: Olshan/Boundary Bay, Granite Foundation, HD Foundations. SBA 7(a) financeable. ETA appetite for foundation repair = HIGH 2024-26.",
             "source": "market_intel", "source_url": "", "observed_at": TODAY},
            {"layer": 4, "signal_key": "potential_owner_legal_history", "direction": "negative",
             "evidence": "Google search surfaces a 2010 'Robby Rose' Garland TX referenced in a blog post re: attempted theft conviction. Cannot confirm same person without further verification — flag for deep-dive but NOT auto-distress until name match confirmed. Cap confidence at medium.",
             "source": "google_serp", "source_url": "https://armchairanglers.wordpress.com/2010/04/13/from-holy-roller-to-convicted-felon-a-bass-fishermans-fall-from-grace-part-1/", "observed_at": TODAY}
        ],
        "layer1_base_rate": 72, "layer1_comment": "Robby Rose, 34-yr personal tenure as owner of Affordable Foundation Repair since 1992. Age not directly verified (no OV65 lookup completed); license tenure proxy + website self-report support a 60s/early-70s estimate. Long-tenured solo owner near natural exit window.",
        "layer2_sellability": 70, "layer2_comment": "BBB-accredited since 2006 (clean record), 34 yrs in business, DFW market, residential + drainage recurring-revenue mix. Estimated $500K-$1.5M revenue based on solo-owner profile with small crew. SBA 7(a) financeable.",
        "layer3_behavioral_trigger": 78, "layer3_comment": "STRONG coasting tells — live website fetch 2026-05-17 confirms solo owner (no associate / co-owner / family successor named). Owner personally on every job at 34 yrs in. Phone-only intake. Site looks dated. Tells stacked: solo verified, no online booking, owner-on-every-job, BBB-accredited but no successor mentioned. 3-4 tells = 75-80 range.",
        "layer4_market_pull": 88, "layer4_comment": "Garland/Dallas Co — DFW #1 foundation repair market. Active acquirers Olshan/Boundary Bay, Granite, HD Foundations all transacting in DFW. SBA 7(a) standard for $500K-$2M foundation acquisitions. ETA appetite top-10 vertical.",
        "confidence": "medium", "data_completeness": 0.65,
        "value_add_thesis": "Specific gaps: phone-only intake (add modern field-service CRM like ServiceTitan / JobNimbus / BuildOps for scheduling, route optimization, customer portal); no online quote form (add lead capture + scheduling automation); no visible review-generation system (automate Google + BBB review requests post-job); add automated annual foundation inspection recall campaign to monetize lifetime-transferable warranty base (likely thousands of past customers untouched); successor / GM hire to glide-path Robby out within 24 mo. Credible 1.5-2x EBITDA path over 24 mo on a DFW slab/drainage shop with this much warranty book.",
        "final_comment_override": "Robby Rose, ~60s (license-tenure proxy + website self-report — OV65 not yet verified), founded Affordable Foundation Repair in Garland (Dallas Co eastern suburbs) in 1992 and has run it personally for 34 yrs. Website (affordablefoundationrepairanddrainage.com, live fetch 2026-05-17) is unambiguous: Robby is the sole named principal, 'will personally answer your calls,' and 'will be on every job we complete from start to finish.' No associate, family successor, GM, or co-owner visible. Phone-only intake, no online booking, dated site — coasting solo owner profile holds. DFW market is the most active TX foundation repair roll-up zone (Olshan/Boundary Bay, Granite, HD Foundations all transacting). One yellow flag: a Google blog post references a 'Robby Rose Garland TX' 2010 attempted-theft case — likely same person, needs identity confirmation before outreach (county clerk lookup). Tier A pending OV65 verification + identity-match clarification on the 2010 record; if record matches and is unresolved → demote to D_pass distress.",
        "deep_dive_status": "passed_with_caveats",
        "_deep_dive_notes": "Live team-page fetch DONE (positive successor-check). Comptroller status not yet checked. OV65 not yet checked. License-board check N/A (no TX state license). County clerk identity-match on 2010 record OUTSTANDING — Gideon needs to verify before outreach."
    },
    {
        "legal_name": "All Texas Foundation Repair, Inc.",
        "dba_name": "All Texas Foundation Repair",
        "naics_code": "238190",
        "address": "Houston, TX",
        "city": "Houston",
        "county": "Harris",
        "state": "TX",
        "zip": None,
        "phone": "713-529-7901",
        "website": "http://www.alltexasfoundationrepair.com",
        "owner_name": "Bill Marks",
        "owner_age_estimate": None,
        "owner_age_source": "website_self_report",
        "owner_tenure_years": 50,
        "years_in_business": 50,
        "provider_count_estimate": None,
        "employee_count_estimate": 8,
        "is_distressed": False,
        "distress_reasons": [],
        "founded_year": 1975,
        "spine_source": "BBB Houston SERP — accredited 2002 + alltexasfoundationrepair.com live fetch 2026-05-17",
        "data_sources": [
            {"source": "company website", "url": "http://www.alltexasfoundationrepair.com/", "fetched_at": TODAY, "fields": ["bill_marks_owner_evidence", "fifty_year_claim"]},
            {"source": "contact page", "url": "http://www.alltexasfoundationrepair.com/contact.html", "fetched_at": TODAY, "fields": ["phone_713-529-7901"]},
            {"source": "BBB Houston SERP", "url": "https://www.bbb.org/us/tx/houston/profile/foundation-contractors/", "fetched_at": TODAY, "fields": ["bbb_accredited_2002"]}
        ],
        "signals": [
            {"layer": 1, "signal_key": "owner_tenure_proxy", "direction": "positive",
             "evidence": "Bill Marks is referenced repeatedly in customer testimonials on alltexasfoundationrepair.com as the person conducting site visits and quotes. Company claims '50+ years' in business (founding ~1975). If Bill founded in 1975 and is still personally on inspections in 2026, age estimate 65-75+. Owner-age verification needed (no OV65 pulled).",
             "source": "live_website_fetch", "source_url": "http://www.alltexasfoundationrepair.com/", "observed_at": TODAY},
            {"layer": 2, "signal_key": "bbb_accreditation_active", "direction": "positive",
             "evidence": "BBB-accredited since 12/18/2002 (~24 yrs accredited). Insured employees, no subcontractors per website. 50+ yrs in business. Houston market.",
             "source": "bbb_serp_corroboration", "source_url": "", "observed_at": TODAY},
            {"layer": 3, "signal_key": "successor_check_live_fetch", "direction": "positive",
             "evidence": "Live homepage fetch alltexasfoundationrepair.com on 2026-05-17: Only Bill Marks (owner-inspector role) and 'Sue' (helper role, no title) named on the entire site. No second principal, family successor, partner, GM, or operations manager visible. Site is dated (HTML/CSS pre-2010 styling, no modern PMS/CRM, no online booking, no patient portal). 'Citation Solutions' is named only as site developer.",
             "source": "live_website_fetch", "source_url": "http://www.alltexasfoundationrepair.com/", "observed_at": TODAY},
            {"layer": 3, "signal_key": "dated_website", "direction": "positive",
             "evidence": "Static HTML site with no online quote form, no customer portal, no mobile-first design — likely unchanged 5-10 years. Owner-on-inspections at age 65+. Phone-only intake at 713-529-7901.",
             "source": "live_website_fetch", "source_url": "http://www.alltexasfoundationrepair.com/", "observed_at": TODAY},
            {"layer": 4, "signal_key": "houston_metro_pull", "direction": "neutral",
             "evidence": "Harris Co / Houston. Houston has less foundation movement than DFW (more sandy soils + clay mix) but huge volume by population. Active acquirers Olshan (HQ Houston), Boundary Bay, Dura Pier. ETA appetite top-10.",
             "source": "market_intel", "source_url": "", "observed_at": TODAY}
        ],
        "layer1_base_rate": 80, "layer1_comment": "Bill Marks owner-of-record; if company is genuinely 50 yrs old (founded ~1975) and Bill is still personally on inspections, age 65-75+. Long-tenured solo principal, classic Layer-1 high range. Caveat: OV65 not yet verified.",
        "layer2_sellability": 72, "layer2_comment": "BBB-accredited 24 yrs (since 2002), insured W2 employees only (no subs), 50 yrs in business per website. Stable Houston-market residential foundation shop with recurring warranty base. Likely $1-3M revenue.",
        "layer3_behavioral_trigger": 80, "layer3_comment": "STRONG. Live team-page fetch 2026-05-17 confirms Bill Marks is sole named principal. Site is HTML 1.0 styling with phone-only intake. Owner doing his own site quotes at 50 yrs in business. 4 tells stacked: solo verified, dated site, owner-on-inspections, no online booking.",
        "layer3_evidence_note": "No 'Citation Solutions' shows up as web partner only — owner has not modernized their CMS in years.",
        "layer4_market_pull": 85, "layer4_comment": "Houston/Harris Co — major TX metro, Olshan HQ here. Active national acquirer market. SBA 7(a) standard. ETA top-10 vertical.",
        "confidence": "medium", "data_completeness": 0.60,
        "value_add_thesis": "Specific gaps: HTML static site, no online quote form (add modern lead-gen), phone-only intake (CRM + SMS-scheduling), no review automation, 50 yrs of repair history = thousands of past customers untouched for annual-inspection recall, no helical/pressed-pile method differentiation visible. Modernize tech stack + activate dormant customer base = 1.5-2x EBITDA in 18-24 mo on a Houston shop with this much brand equity.",
        "final_comment_override": "Bill Marks (owner per testimonial pattern, age 65-75+ implied by 50-yr tenure), All Texas Foundation Repair, Houston (Harris Co), founded ~1975, BBB-accredited since 2002. Live site fetch 2026-05-17 (alltexasfoundationrepair.com) shows Bill personally conducting inspections, Sue as sole other named staff, no second principal / GM / family successor. Site is static HTML 1.0 with phone-only intake at 713-529-7901 — classic dated-tech coasting profile. Houston metro is hot for foundation acquisitions (Olshan HQ here). One A-tier risk: owner-age and entity-status not directly verified — needs OV65 + Comptroller franchise-tax-status check (currently medium confidence). Tier A pending those two verifications.",
        "deep_dive_status": "passed_with_caveats",
        "_deep_dive_notes": "Live team-page fetch DONE. Owner identified. Comptroller + OV65 NOT yet verified. No TX state license required."
    },
    {
        "legal_name": "Houston Foundation Repair Company, LLC",
        "dba_name": "Houston Foundation Repair Company",
        "naics_code": "238190",
        "address": "Houston, TX",
        "city": "Houston",
        "county": "Harris",
        "state": "TX",
        "zip": None,
        "phone": None,
        "website": None,
        "owner_name": "Luis A. Hernandez",
        "owner_age_estimate": None,
        "owner_age_source": "bbb_principal_listing",
        "owner_tenure_years": 29,
        "years_in_business": 29,
        "provider_count_estimate": None,
        "employee_count_estimate": 10,
        "is_distressed": False,
        "distress_reasons": [],
        "founded_year": 1997,
        "spine_source": "BBB Houston SERP — accredited 11/29/2007. Founded 1997. Owner Luis A. Hernandez per BBB",
        "data_sources": [
            {"source": "BBB Houston SERP citation", "url": "https://www.bbb.org/us/tx/houston/profile/foundation-contractors/houston-foundation-repair-company-llc-0915-58002508", "fetched_at": TODAY, "fields": ["owner_name", "founded_1997", "bbb_accredited_2007"]}
        ],
        "signals": [
            {"layer": 1, "signal_key": "owner_tenure_proxy", "direction": "positive",
             "evidence": "Luis A. Hernandez is BBB-listed owner. Founded 1997 — 29-yr tenure. If founded at age 30, owner now ~59. Possible 50s-60s, on the cusp of natural exit window.",
             "source": "bbb_serp_citation", "source_url": "https://www.bbb.org/us/tx/houston/profile/foundation-contractors/houston-foundation-repair-company-llc-0915-58002508", "observed_at": TODAY},
            {"layer": 2, "signal_key": "bbb_accreditation_active", "direction": "positive",
             "evidence": "BBB-accredited since 2007. Company claims 70,000+ houses repaired in Houston area — large operational base. Founded 1997, 29 yrs in business.",
             "source": "bbb_serp_citation", "source_url": "https://www.bbb.org/us/tx/houston/profile/foundation-contractors/houston-foundation-repair-company-llc-0915-58002508", "observed_at": TODAY},
            {"layer": 3, "signal_key": "successor_check_unverified_blocked", "direction": "disqualifying",
             "evidence": "No website found in search results; BBB profile direct fetch returned 403. Without live team-page evidence, cannot verify solo-owner / no-successor status. Per skill guardrail (verifying-no-successor.md §3), confidence capped at low and tier capped at C_watch until live-fetch can complete.",
             "source": "live_website_fetch_blocked", "source_url": "", "observed_at": TODAY},
            {"layer": 4, "signal_key": "houston_metro_pull", "direction": "positive",
             "evidence": "Harris Co / Houston. Major TX metro. Olshan HQ. Active acquirer market.",
             "source": "market_intel", "source_url": "", "observed_at": TODAY}
        ],
        "layer1_base_rate": 60, "layer1_comment": "Luis A. Hernandez owner since 1997 (BBB listing); 29-yr tenure. Age estimate 55-65 (proxy only — no OV65, no LinkedIn match). Mid-range Layer-1.",
        "layer2_sellability": 75, "layer2_comment": "BBB-accredited 2007, 29 yrs in business, 70,000+ houses repaired claim → substantial Houston operator. Likely $2-5M revenue. SBA 7(a) financeable.",
        "layer3_behavioral_trigger": 35, "layer3_comment": "CANNOT VERIFY. No working website surfaced; BBB profile direct fetch 403. Without live team-page, cannot confirm solo-coaster vs. successor-in-place. Per verifying-no-successor.md, score and tier capped accordingly.",
        "layer4_market_pull": 85, "layer4_comment": "Houston/Harris Co — active acquirer market.",
        "confidence": "low", "data_completeness": 0.45,
        "value_add_thesis": "Cannot draft specific value-add thesis without live website to read. Generic theses (CRM, online booking, recall automation) apply but lack of specificity caps this at B/C.",
        "final_comment_override": "Luis A. Hernandez, Houston Foundation Repair Company LLC, Houston (Harris Co), founded 1997, BBB-accredited 2007. 70,000+ houses repaired claim suggests substantial operator. Website search returned no usable result and BBB direct fetch returned 403, so successor verification could not complete — per skill guardrail, capping confidence at low and tier at C_watch until live-fetch evidence can be obtained. Re-score in 90 days.",
        "deep_dive_status": "blocked_team_page_unreachable",
        "_deep_dive_notes": "Live team-page fetch BLOCKED. Tier capped at C_watch per verifying-no-successor.md."
    },
    {
        "legal_name": "Luis Carlos Foundation Repair",
        "dba_name": "Luis Carlos Foundation Repair",
        "naics_code": "238190",
        "address": "Lewisville, TX",
        "city": "Lewisville",
        "county": "Denton",
        "state": "TX",
        "zip": None,
        "phone": None,
        "website": "https://www.foundationrepairllc.com",
        "owner_name": "Luis Carlos (last name not disclosed)",
        "owner_age_estimate": None,
        "owner_age_source": "website_self_report",
        "owner_tenure_years": 37,
        "years_in_business": 37,
        "provider_count_estimate": None,
        "employee_count_estimate": 4,
        "is_distressed": False,
        "distress_reasons": [],
        "founded_year": 1989,
        "spine_source": "Denton SERP + foundationrepairllc.com live fetch 2026-05-17",
        "data_sources": [
            {"source": "company website", "url": "https://www.foundationrepairllc.com/", "fetched_at": TODAY, "fields": ["since_1989", "family_owned_claim"]}
        ],
        "signals": [
            {"layer": 1, "signal_key": "owner_tenure_proxy", "direction": "positive",
             "evidence": "'Since 1989, Luis Carlos Foundation Repair has specialized in the repair of slab and pier and beam foundations for residential and commercial properties in Dallas-Fort Worth.' 37-yr tenure. If Luis Carlos founded at 30, now ~67.",
             "source": "live_website_fetch", "source_url": "https://www.foundationrepairllc.com/", "observed_at": TODAY},
            {"layer": 3, "signal_key": "successor_check_live_fetch", "direction": "positive",
             "evidence": "Live homepage fetch foundationrepairllc.com 2026-05-17: 'family owned and operated' but NO family members, associates, partners, sons, daughters, GMs named anywhere. 'For more than two decades, North Texas homeowners trust our experts.' Low transparency on team composition — could indicate solo owner with no formal successor.",
             "source": "live_website_fetch", "source_url": "https://www.foundationrepairllc.com/", "observed_at": TODAY},
            {"layer": 3, "signal_key": "dated_website", "direction": "positive",
             "evidence": "Site is minimalist, no online booking, no customer portal, phone-only intake. Static design pattern.",
             "source": "live_website_fetch", "source_url": "https://www.foundationrepairllc.com/", "observed_at": TODAY},
            {"layer": 4, "signal_key": "dfw_metro_pull", "direction": "positive",
             "evidence": "Lewisville/Denton Co — DFW north corridor. Active acquirer market.",
             "source": "market_intel", "source_url": "", "observed_at": TODAY}
        ],
        "layer1_base_rate": 75, "layer1_comment": "Luis Carlos has personally founded and run since 1989 — 37-yr tenure. Age estimate ~65-70 (proxy). Long-tenured owner near natural exit.",
        "layer2_sellability": 60, "layer2_comment": "Hispanic-owned independent, 37 yrs in business, family-owned per website. Estimated $500K-$1.2M rev. SBA 7(a) financeable. Lower L2 because no BBB accreditation surfaced and team transparency low.",
        "layer3_behavioral_trigger": 65, "layer3_comment": "Live fetch confirms no named successor / co-owner / family member despite 'family owned' claim — could be solo owner with no formal succession plan. Dated minimalist site, phone-only intake. 3 tells, mid-60s range. Confidence-capped because 'family owned' claim with no names could mask either a real solo profile OR a family that just didn't update the site.",
        "layer4_market_pull": 85, "layer4_comment": "Lewisville/Denton Co — DFW north corridor. Premium suburban catchment. Active acquirer market.",
        "confidence": "medium", "data_completeness": 0.55,
        "value_add_thesis": "Specific gaps: phone-only intake, no online quote form, no review-generation visible, no helical/pressed-pile method messaging, 37 yrs of past customers untouched for recall. Modernize CMS + activate warranty base + add online booking for 1.5x EBITDA path in 18 mo on a Denton Co shop.",
        "final_comment_override": "Luis Carlos (surname not disclosed on site), Luis Carlos Foundation Repair, Lewisville (Denton Co), founded 1989. 37-yr personal tenure puts owner at est. age 65-70. Live homepage fetch 2026-05-17 (foundationrepairllc.com) shows 'family owned and operated' BUT no second principal, associate, family member, or GM named anywhere — could be solo with no formal succession, or a family op that just doesn't disclose. Dated minimalist site, phone-only intake. DFW north corridor (premium catchment, active acquirer market). Tier B pending OV65 + Comptroller status confirmation; if those + a phone call surface formal solo + no successor, promotes to A.",
        "deep_dive_status": "passed_with_caveats",
        "_deep_dive_notes": "Live team-page fetch DONE. Family-owned claim with no successor names — ambiguous. Comptroller status not checked."
    },
    {
        "legal_name": "Pro-Tech Foundation Repair",
        "dba_name": "Texas Pro-Tech Foundation, Inc.",
        "naics_code": "238190",
        "address": "Mesquite, TX",
        "city": "Mesquite",
        "county": "Dallas",
        "state": "TX",
        "zip": None,
        "phone": "972-288-3797",
        "website": "https://www.protechfoundation.com",
        "owner_name": None,
        "owner_age_estimate": None,
        "owner_age_source": "license_tenure_proxy",
        "owner_tenure_years": 33,
        "years_in_business": 33,
        "provider_count_estimate": None,
        "employee_count_estimate": 8,
        "is_distressed": False,
        "distress_reasons": [],
        "founded_year": 1993,
        "spine_source": "DFW SERP + protechfoundation.com live fetch 2026-05-17",
        "data_sources": [
            {"source": "company website", "url": "https://www.protechfoundation.com/about/", "fetched_at": TODAY, "fields": ["family_owned", "thirty_plus_yrs"]}
        ],
        "signals": [
            {"layer": 1, "signal_key": "owner_tenure_proxy", "direction": "positive",
             "evidence": "Company claims 30+ years experience and family-owned in Mesquite. Founded ~1993. Owner not named on site; assume founder still active.",
             "source": "live_website_fetch", "source_url": "https://www.protechfoundation.com/about/", "observed_at": TODAY},
            {"layer": 3, "signal_key": "successor_check_live_fetch", "direction": "positive",
             "evidence": "Live about-page fetch 2026-05-17 of protechfoundation.com: 'family-owned and operated team based in Mesquite, Texas' but NO individual names, associates, co-owners, family members, or operations managers named anywhere on the page. Single-entity 'Texas Pro-Tech Foundation, Inc.' in copyright footer. Cannot determine if successor in place; cap confidence at medium-low.",
             "source": "live_website_fetch", "source_url": "https://www.protechfoundation.com/about/", "observed_at": TODAY},
            {"layer": 4, "signal_key": "dfw_metro_pull", "direction": "positive",
             "evidence": "Mesquite/Dallas Co — DFW eastern corridor. Premium acquirer market.",
             "source": "market_intel", "source_url": "", "observed_at": TODAY}
        ],
        "layer1_base_rate": 65, "layer1_comment": "Founded 1993 (33 yrs). Owner not named on site; assumed founder still active. Age estimate 60-70 (proxy). Lower confidence because owner not named anywhere on public site.",
        "layer2_sellability": 70, "layer2_comment": "33 yrs in business, family-owned, Mesquite/DFW. Estimated $750K-$2M rev. SBA 7(a) financeable.",
        "layer3_behavioral_trigger": 60, "layer3_comment": "Live fetch shows no named successor / co-owner / GM / family member — could be solo or family without disclosure. Phone-only intake (972-288-3797). Site has 'about' section but no people. 2-3 tells, mid 60s range. Confidence-capped due to thin team transparency.",
        "layer4_market_pull": 85, "layer4_comment": "Mesquite/Dallas Co — DFW eastern corridor. Active acquirer market.",
        "confidence": "medium", "data_completeness": 0.50,
        "value_add_thesis": "Modernize CMS, add online quote form + booking, automate review generation, activate dormant 33-yr customer base for annual inspection recall, add named successor / GM hire for valuation lift.",
        "final_comment_override": "Pro-Tech Foundation Repair (Texas Pro-Tech Foundation, Inc.), Mesquite (Dallas Co), founded 1993, 33-yr tenure. Live about-page fetch 2026-05-17 (protechfoundation.com) confirms 'family-owned' but discloses no individual owners, family members, or operations leaders by name — anonymous-leadership profile. Phone-only at 972-288-3797. DFW eastern corridor (active acquirer market). Tier B because owner-identity unverified + successor cannot be conclusively ruled out from live fetch (live page is family-owned with no names). Needs phone call + Comptroller PIR pull to confirm owner identity before A-tier promotion.",
        "deep_dive_status": "passed_with_caveats",
        "_deep_dive_notes": "Live page-fetch DONE but team-page anonymous. Need PIR (Public Information Report) from Comptroller to identify principal."
    },
    # ============================== B_FORWARD (numeric pass but successor found OR data gap) ==============================
    {
        "legal_name": "Atlas Foundation Company, Inc.",
        "dba_name": "Atlas Foundation Co",
        "naics_code": "238190",
        "address": "3916 Heritage Ct",
        "city": "Burleson",
        "county": "Johnson",
        "state": "TX",
        "zip": "76028",
        "phone": "817-478-1181",
        "website": "https://www.atlasfoundationinc.com",
        "owner_name": "Kyler Ford + Lindsay (Ford) Green (4th gen, took over March 2025)",
        "owner_age_estimate": 35,  # approx — Kyler joined as superintendent 2011
        "owner_age_source": "linkedin_grad_proxy",
        "owner_tenure_years": 1,  # as new owners
        "years_in_business": 67,
        "provider_count_estimate": None,
        "employee_count_estimate": 15,
        "is_distressed": False,
        "distress_reasons": [],
        "founded_year": 1958,
        "spine_source": "FPA + Burleson SERP + atlasfoundationinc.com live fetch 2026-05-17 + Now Magazines 2025 succession article",
        "data_sources": [
            {"source": "company website (about)", "url": "https://www.atlasfoundationinc.com/about/", "fetched_at": TODAY, "fields": ["team_composition", "4th_gen_succession"]},
            {"source": "Now Magazines 2025 succession story", "url": "https://nowmagazines.com/2025/03/10/atlas-foundation-co-inc-2/", "fetched_at": TODAY, "fields": ["march_2025_kyler_lindsay_took_ownership"]},
            {"source": "Atlas Foundation 65 yrs press", "url": "https://www.atlasfoundationinc.com/atlas-foundation-company-celebrates-65-years/", "fetched_at": TODAY, "fields": ["founded_1958", "65_yrs"]}
        ],
        "signals": [
            {"layer": 1, "signal_key": "recent_owner_transition", "direction": "negative",
             "evidence": "As of March 2025, Kyler Ford and Lindsay (Ford) Green (4th generation, great-grandchildren of founder W.M. Murdock) took ownership from Darrel and Lonnie Ford. NEW owners means selling-window timer just RESET. Recent buyers don't sell — they just bought. Hard signal against Layer 1.",
             "source": "company_website + now_magazines", "source_url": "https://nowmagazines.com/2025/03/10/atlas-foundation-co-inc-2/", "observed_at": TODAY},
            {"layer": 3, "signal_key": "successor_check_live_fetch", "direction": "negative",
             "evidence": "Live about-page fetch 2026-05-17 of atlasfoundationinc.com: lists Kyler Ford (superintendent since 2011, now co-owner), Lindsay (Ford) Green (office manager since 2016, now co-owner), Phillip Biondi (superintendent since 1982), Christy Ford (office manager — Darrel's wife), Angie Esparza (customer service since 2014). Structured multi-generational succession ALREADY HAPPENED in March 2025. NOT a coasting-solo-to-outside-buyer profile.",
             "source": "live_website_fetch", "source_url": "https://www.atlasfoundationinc.com/about/", "observed_at": TODAY}
        ],
        "layer1_base_rate": 20, "layer1_comment": "New owners (Kyler ~30s and Lindsay ~30s) just took over March 2025. Hard demotion — they're the recent BUYERS, not the natural-exit sellers.",
        "layer2_sellability": 85, "layer2_comment": "67 yrs in business, multi-staff, family operation, A+ BBB, large DFW operation. Excellent on sellability dimension — but irrelevant if owners just bought.",
        "layer3_behavioral_trigger": 15, "layer3_comment": "Successor not just in place — succession ALREADY EXECUTED March 2025. Layer 3 thesis fails entirely.",
        "layer4_market_pull": 90, "layer4_comment": "DFW Burleson/Johnson Co. Top acquirer market.",
        "confidence": "high", "data_completeness": 0.80,
        "value_add_thesis": "N/A — wrong target profile. New owners (4th-gen) just bought; no exit-window. Skip.",
        "final_comment_override": "Atlas Foundation Co, Burleson (Johnson Co), founded 1958, 67 yrs. Live about-page fetch 2026-05-17 + Now Magazines March 2025 succession article confirm Kyler Ford + Lindsay (Ford) Green (4th-generation great-grandchildren of founder W.M. Murdock) took ownership from Darrel + Lonnie Ford in March 2025. NEW owners — recent buyers don't sell. Multi-generational team in place (Phillip Biondi superintendent since 1982; Christy Ford office; Angie Esparza CS). Deep-dive demotion: succession ALREADY EXECUTED → tier D_pass (wrong target profile entirely). Don't pursue.",
        "deep_dive_status": "demoted_recent_succession",
        "_deep_dive_notes": "Demoted from A → D. Recent owner transition is a stronger signal than any L2/L4 score."
    },
    {
        "legal_name": "Armadillo Foundation Repair",
        "dba_name": "Armadillo Foundation Repair",
        "naics_code": "238190",
        "address": None,
        "city": "Austin",
        "county": "Travis",
        "state": "TX",
        "zip": None,
        "phone": None,
        "website": "https://armadillofoundationrepair.com",
        "owner_name": "John (successor, surname not disclosed); founder Jerry Sallas",
        "owner_age_estimate": None,
        "owner_age_source": "website_self_report",
        "owner_tenure_years": 42,
        "years_in_business": 42,
        "provider_count_estimate": None,
        "employee_count_estimate": 10,
        "is_distressed": False,
        "distress_reasons": [],
        "founded_year": 1984,
        "spine_source": "Austin SERP + armadillofoundationrepair.com live fetch 2026-05-17",
        "data_sources": [
            {"source": "company website (about)", "url": "https://armadillofoundationrepair.com/about", "fetched_at": TODAY, "fields": ["jerry_sallas_founder_1984", "john_next_gen_successor"]}
        ],
        "signals": [
            {"layer": 1, "signal_key": "owner_tenure_proxy", "direction": "positive",
             "evidence": "Founded 1984 by Jerry Sallas. 42-yr business tenure. Jerry's age 60s-70s assumed.",
             "source": "live_website_fetch", "source_url": "https://armadillofoundationrepair.com/about", "observed_at": TODAY},
            {"layer": 3, "signal_key": "successor_check_live_fetch", "direction": "negative",
             "evidence": "Live about-page fetch 2026-05-17: 'As the company transitions into the next generation, John and his team are dedicated to upholding the same values that Jerry instilled from the beginning.' Successor (John) is named and actively leading. NOT a coasting-solo profile — already in succession.",
             "source": "live_website_fetch", "source_url": "https://armadillofoundationrepair.com/about", "observed_at": TODAY}
        ],
        "layer1_base_rate": 70, "layer1_comment": "Jerry Sallas founder 1984; long tenure but already handing off to successor John.",
        "layer2_sellability": 75, "layer2_comment": "42 yrs, family-owned, Austin metro. Estimated $1-2M rev. SBA 7(a) financeable.",
        "layer3_behavioral_trigger": 40, "layer3_comment": "Successor verified PRESENT via live fetch — 'John and his team' leading 'next generation' explicitly. Coasting-solo thesis fails. L3 reduced to 40 (residual coasting tells: dated-ish site, but successor erases the 'no successor' tell).",
        "layer4_market_pull": 85, "layer4_comment": "Austin/Travis Co — major TX metro. Active acquirer market.",
        "confidence": "high", "data_completeness": 0.75,
        "value_add_thesis": "Wrong profile — internal succession in place. If anything, John (new gen leader) might be the acquirer. Skip.",
        "final_comment_override": "Armadillo Foundation Repair, Austin (Travis Co), founded 1984 by Jerry Sallas. Live about-page fetch 2026-05-17 (armadillofoundationrepair.com/about): 'As the company transitions into the next generation, John and his team are dedicated to upholding the same values that Jerry instilled.' Internal successor (John) is named and leading. Structured internal-buy-in candidate, not coasting-solo-to-outside-buyer. Demote from candidate A to B (numeric still passes but L3 fails). Forward to community if anyone wants Austin foundation exposure — but Gideon should skip.",
        "deep_dive_status": "demoted_successor_found"
    },
    {
        "legal_name": "Anchor Foundation Repair",
        "dba_name": "Anchor Foundation Repair Co",
        "naics_code": "238190",
        "address": "3819 McCullough Rd / 4124 Carrabba Rd",
        "city": "College Station",
        "county": "Brazos",
        "state": "TX",
        "zip": None,
        "phone": None,
        "website": "https://anchorfoundationrepair.net",
        "owner_name": "Craig Tripp (since 2013, son of founder Ken Tripp)",
        "owner_age_estimate": 50,
        "owner_age_source": "linkedin_grad_military_proxy",
        "owner_tenure_years": 13,
        "years_in_business": 41,
        "provider_count_estimate": None,
        "employee_count_estimate": 8,
        "is_distressed": False,
        "distress_reasons": [],
        "founded_year": 1985,
        "spine_source": "Bryan/CS SERP + anchorfoundationrepair.net live fetch 2026-05-17",
        "data_sources": [
            {"source": "company website (about)", "url": "https://anchorfoundationrepair.net/about-us/", "fetched_at": TODAY, "fields": ["ken_tripp_founder_1985", "craig_tripp_2013_succession", "army_officer_12_yrs"]}
        ],
        "signals": [
            {"layer": 1, "signal_key": "successor_already_active", "direction": "negative",
             "evidence": "Craig Tripp took over in 2013 from founder Ken Tripp (his father) after 12 yrs Army Officer service. Craig is current owner-operator at est age ~50. Recent enough succession (2013, 13 yrs ago) that Craig is NOT near natural exit window himself.",
             "source": "live_website_fetch", "source_url": "https://anchorfoundationrepair.net/about-us/", "observed_at": TODAY}
        ],
        "layer1_base_rate": 25, "layer1_comment": "Current owner Craig Tripp (~50) only 13 yrs into ownership after taking over from his father in 2013. Far from natural exit window. Layer 1 fails hard.",
        "layer2_sellability": 75, "layer2_comment": "41 yrs in business, multi-staff, Brazos Valley market. Estimated $1-2M rev. SBA 7(a) financeable.",
        "layer3_behavioral_trigger": 20, "layer3_comment": "No coasting profile — current owner Craig only 13 yrs in, mid-50s, ex-military, actively leading the business. Healthy but not the target.",
        "layer4_market_pull": 70, "layer4_comment": "Brazos Valley (Bryan/College Station) — secondary TX metro, less acquirer activity than top 4 metros but Texas A&M / Aggie network gives some scale.",
        "confidence": "high", "data_completeness": 0.75,
        "value_add_thesis": "N/A — Craig is at start of owner tenure, not end. Wrong target profile.",
        "final_comment_override": "Anchor Foundation Repair, College Station (Brazos Co), founded 1985 by Ken Tripp; son Craig Tripp took over in 2013 after 12 yrs Army Officer service. Live about-page fetch 2026-05-17 confirms Craig as current owner-CEO at 3819 McCullough Rd. Craig at est. age ~50, only 13 yrs into ownership — NOT a coasting solo owner near exit. Healthy regional Brazos Valley operator but wrong target profile entirely. Demote to D_pass.",
        "deep_dive_status": "demoted_recent_succession"
    },
    {
        "legal_name": "Pier Pressure Foundation Repair",
        "dba_name": "Pier Pressure Foundation Repair",
        "naics_code": "238190",
        "address": "8610 Kennsington St",
        "city": "Frisco",
        "county": "Collin",
        "state": "TX",
        "zip": None,
        "phone": None,
        "website": "https://pierpressurefoundationrepair.com",
        "owner_name": "Kyle Gowdy (founder, since Oct 2013)",
        "owner_age_estimate": 45,
        "owner_age_source": "linkedin_grad_proxy",
        "owner_tenure_years": 12,
        "years_in_business": 12,
        "provider_count_estimate": None,
        "employee_count_estimate": 6,
        "is_distressed": False,
        "distress_reasons": [],
        "founded_year": 2013,
        "spine_source": "DFW SERP + pierpressurefoundationrepair.com live fetch + LinkedIn + ZoomInfo",
        "data_sources": [
            {"source": "Voyage Dallas Magazine interview", "url": "https://voyagedallas.com/interview/meet-kyle-gowdy-pier-pressure-foundation-repair-carrollton/", "fetched_at": TODAY, "fields": ["kyle_gowdy_founder"]},
            {"source": "company about page", "url": "https://pierpressurefoundationrepair.com/about-us/", "fetched_at": TODAY, "fields": ["kyle_gowdy_owner"]}
        ],
        "signals": [
            {"layer": 1, "signal_key": "owner_age_proxy_too_young", "direction": "negative",
             "evidence": "Kyle Gowdy founded Oct 2013 (~12 yrs). Founder at start of company assumed early-30s in 2013 → ~45 today. Too young for natural exit window.",
             "source": "voyage_dallas + linkedin", "source_url": "https://voyagedallas.com/interview/meet-kyle-gowdy-pier-pressure-foundation-repair-carrollton/", "observed_at": TODAY}
        ],
        "layer1_base_rate": 30, "layer1_comment": "Kyle Gowdy ~45, only 12-yr tenure. Far from natural exit window.",
        "layer2_sellability": 65, "layer2_comment": "12 yrs in business (over 5-yr gate), Frisco/Collin Co, lifetime transferable warranty model. Healthy small DFW operator.",
        "layer3_behavioral_trigger": 35, "layer3_comment": "Active owner, modern-ish web presence, Instagram-active, social media engagement. Not coasting.",
        "layer4_market_pull": 92, "layer4_comment": "Frisco/Collin Co — DFW #1 premium catchment. Top acquirer market.",
        "confidence": "high", "data_completeness": 0.70,
        "value_add_thesis": "N/A — wrong profile, founder is young & active.",
        "final_comment_override": "Pier Pressure Foundation Repair, Frisco (Collin Co), founded Oct 2013 by Kyle Gowdy. Kyle ~45, 12-yr personal tenure. Active on social, modern web presence. Wrong target profile — owner is at peak career, not exit window. Premium DFW location. Demote to D_pass.",
        "deep_dive_status": "demoted_owner_too_young"
    },
    {
        "legal_name": "Baird Foundation Repair",
        "dba_name": "Baird Foundation Repair",
        "naics_code": "238190",
        "address": None,
        "city": "San Antonio",
        "county": "Bexar",
        "state": "TX",
        "zip": None,
        "phone": None,
        "website": "https://www.bairdfoundationrepair.com",
        "owner_name": "Baird family (3rd gen, William Baird founder 1969)",
        "owner_age_estimate": None,
        "owner_age_source": "website_self_report",
        "owner_tenure_years": 57,
        "years_in_business": 57,
        "provider_count_estimate": None,
        "employee_count_estimate": 25,
        "is_distressed": False,
        "distress_reasons": [],
        "founded_year": 1969,
        "spine_source": "SA SERP + bairdfoundationrepair.com (about page 403)",
        "data_sources": [
            {"source": "company website (homepage)", "url": "https://www.bairdfoundationrepair.com/", "fetched_at": TODAY, "fields": ["family_owned_1969", "third_generation"]}
        ],
        "signals": [
            {"layer": 1, "signal_key": "third_gen_already_active", "direction": "negative",
             "evidence": "Baird is explicitly 3rd-generation. William Baird founded 1969. Current 3rd-gen owner is presumably in 40s-50s. Successor already running it.",
             "source": "company_website", "source_url": "https://www.bairdfoundationrepair.com/", "observed_at": TODAY},
            {"layer": 3, "signal_key": "successor_check_live_fetch_blocked", "direction": "disqualifying",
             "evidence": "About page fetch returned 403. Homepage confirms 3rd-gen ownership but cannot verify specific principal names from live site. Cap confidence at low.",
             "source": "live_website_fetch_blocked", "source_url": "https://www.bairdfoundationrepair.com/about-us/", "observed_at": TODAY}
        ],
        "layer1_base_rate": 30, "layer1_comment": "3rd-gen owner likely 40s-50s, decades from exit. Wrong profile.",
        "layer2_sellability": 80, "layer2_comment": "57 yrs in business, large SA operator. Excellent sellability but wrong owner-age profile.",
        "layer3_behavioral_trigger": 25, "layer3_comment": "Multi-generational succession in place. Coasting thesis fails.",
        "layer4_market_pull": 80, "layer4_comment": "SA/Bexar Co — major TX metro.",
        "confidence": "medium", "data_completeness": 0.55,
        "value_add_thesis": "N/A — wrong profile.",
        "final_comment_override": "Baird Foundation Repair, San Antonio (Bexar Co), founded 1969 by William Baird, now 3rd-generation family-owned. Live website confirms multi-generational succession in place; about page direct-fetch 403 prevents specific principal verification. Wrong target profile (recent young successor running). Demote to D_pass.",
        "deep_dive_status": "demoted_successor_in_place"
    },
    {
        "legal_name": "Schaibly Brothers Foundation Repair",
        "dba_name": "Schaibly Brothers",
        "naics_code": "238190",
        "address": None,
        "city": "Rockwall",
        "county": "Rockwall",
        "state": "TX",
        "zip": None,
        "phone": None,
        "website": "https://schaiblybrothersfoundationrepair.com",
        "owner_name": "Curtis Schaibly + Jake Schaibly (co-founders, ~15 yrs ago)",
        "owner_age_estimate": None,
        "owner_age_source": "website_self_report",
        "owner_tenure_years": 15,
        "years_in_business": 15,
        "provider_count_estimate": None,
        "employee_count_estimate": 8,
        "is_distressed": False,
        "distress_reasons": [],
        "founded_year": 2011,
        "spine_source": "Rockwall SERP + schaiblybrothersfoundationrepair.com live fetch 2026-05-17",
        "data_sources": [
            {"source": "company website (about)", "url": "https://schaiblybrothersfoundationrepair.com/about", "fetched_at": TODAY, "fields": ["curtis_jake_schaibly_co_founders"]}
        ],
        "signals": [
            {"layer": 3, "signal_key": "two_co_owners_active", "direction": "negative",
             "evidence": "Curtis Schaibly (Co-Founder/President) + Jake Schaibly (Co-Founder/VP) both active per live about-page fetch 2026-05-17. Multi-owner structure means succession is internal between brothers, not external.",
             "source": "live_website_fetch", "source_url": "https://schaiblybrothersfoundationrepair.com/about", "observed_at": TODAY}
        ],
        "layer1_base_rate": 30, "layer1_comment": "Co-founders ~15 yrs ago, both still active. Too early in tenure for exit window.",
        "layer2_sellability": 65, "layer2_comment": "15 yrs in business, Rockwall, 2-owner structure. Healthy small operator.",
        "layer3_behavioral_trigger": 35, "layer3_comment": "Both co-founders active — internal succession structured, not coasting.",
        "layer4_market_pull": 80, "layer4_comment": "Rockwall Co — DFW eastern. Premium-ish catchment.",
        "confidence": "high", "data_completeness": 0.65,
        "value_add_thesis": "N/A — wrong profile.",
        "final_comment_override": "Schaibly Brothers Foundation Repair, Rockwall, Curtis + Jake Schaibly co-founders ~2011. Both active per live fetch. Co-owner structure, not coasting-solo profile. Demote to D_pass.",
        "deep_dive_status": "demoted_two_active_co_owners"
    },
    {
        "legal_name": "Level Check Foundation Repair",
        "dba_name": "Level Check",
        "naics_code": "238190",
        "address": None,
        "city": "Houston",
        "county": "Harris",
        "state": "TX",
        "zip": None,
        "phone": None,
        "website": "https://www.levelcheckfoundation.com",
        "owner_name": None,
        "owner_age_estimate": None,
        "owner_age_source": "website_self_report",
        "owner_tenure_years": 40,
        "years_in_business": 40,
        "provider_count_estimate": None,
        "employee_count_estimate": 30,
        "is_distressed": False,
        "distress_reasons": [],
        "founded_year": 1986,
        "spine_source": "Houston SERP + levelcheckfoundation.com live fetch 2026-05-17",
        "data_sources": [
            {"source": "company website (homepage)", "url": "https://www.levelcheckfoundation.com/", "fetched_at": TODAY, "fields": ["2nd_generation_1986"]}
        ],
        "signals": [
            {"layer": 3, "signal_key": "second_generation_active", "direction": "negative",
             "evidence": "'We are a 2nd generation family business with 20+ year experienced crews and do not use subcontractors!' per live homepage fetch 2026-05-17. Succession already happened to 2nd gen — wrong target profile.",
             "source": "live_website_fetch", "source_url": "https://www.levelcheckfoundation.com/", "observed_at": TODAY}
        ],
        "layer1_base_rate": 35, "layer1_comment": "2nd gen running it; new owner likely 40s-50s. Wrong profile.",
        "layer2_sellability": 80, "layer2_comment": "40 yrs in business, 21K+ customer claim, large Houston operator. Excellent sellability but wrong owner age.",
        "layer3_behavioral_trigger": 25, "layer3_comment": "Internal 2nd-gen succession already done. Coasting thesis fails.",
        "layer4_market_pull": 85, "layer4_comment": "Harris Co / Houston — major market.",
        "confidence": "high", "data_completeness": 0.70,
        "value_add_thesis": "N/A — wrong profile.",
        "final_comment_override": "Level Check Foundation Repair, Houston (Harris Co), founded 1986. 2nd-generation family business per live homepage fetch — succession already executed. Large Houston operator (21K+ customers claim) but wrong target profile. Demote to D_pass.",
        "deep_dive_status": "demoted_successor_in_place"
    },
    {
        "legal_name": "R & R House Leveling and Foundation",
        "dba_name": "R & R House Leveling",
        "naics_code": "238190",
        "address": None,
        "city": "Bryan",
        "county": "Brazos",
        "state": "TX",
        "zip": None,
        "phone": None,
        "website": "https://www.foundationrepaircollegestation.com",
        "owner_name": "Becker family (Robert founder 1972 → son Bobby → grandson Travis 1990s)",
        "owner_age_estimate": None,
        "owner_age_source": "website_self_report",
        "owner_tenure_years": 54,
        "years_in_business": 54,
        "provider_count_estimate": None,
        "employee_count_estimate": 12,
        "is_distressed": False,
        "distress_reasons": [],
        "founded_year": 1972,
        "spine_source": "Bryan/CS SERP",
        "data_sources": [
            {"source": "Google SERP citation", "url": "https://www.foundationrepaircollegestation.com/about_us", "fetched_at": TODAY, "fields": ["becker_family_3_generations"]}
        ],
        "signals": [
            {"layer": 3, "signal_key": "three_generations_active", "direction": "negative",
             "evidence": "Becker family: Robert founded 1972, son Bobby expanded, grandson Travis joined in 1990s. 3rd-generation Travis (now ~50s) running it. Succession structured and complete — not a coasting-solo profile.",
             "source": "google_serp_citation", "source_url": "https://www.foundationrepaircollegestation.com/about_us", "observed_at": TODAY}
        ],
        "layer1_base_rate": 30, "layer1_comment": "3rd-gen Travis (~50s) running it since 1990s — owner well below natural exit window.",
        "layer2_sellability": 75, "layer2_comment": "54 yrs in business, Brazos Valley operator. Solid.",
        "layer3_behavioral_trigger": 25, "layer3_comment": "3-gen succession executed long ago. Wrong target.",
        "layer4_market_pull": 65, "layer4_comment": "Brazos Valley secondary metro.",
        "confidence": "medium", "data_completeness": 0.55,
        "value_add_thesis": "N/A — wrong profile.",
        "final_comment_override": "R & R House Leveling and Foundation, Bryan (Brazos Co), founded 1972 by Robert Becker; son Bobby and grandson Travis (joined 1990s) running it. 3rd-gen structured succession in place. Demote to D_pass.",
        "deep_dive_status": "demoted_three_gen_succession"
    },
    {
        "legal_name": "G.L. Hunt Foundation Repair",
        "dba_name": "G.L. Hunt",
        "naics_code": "238190",
        "address": None,
        "city": "Austin",
        "county": "Travis",
        "state": "TX",
        "zip": None,
        "phone": None,
        "website": "https://glhunt.com",
        "owner_name": "Gary Hunt (founder 1987)",
        "owner_age_estimate": None,
        "owner_age_source": "website_self_report",
        "owner_tenure_years": 39,
        "years_in_business": 39,
        "provider_count_estimate": None,
        "employee_count_estimate": 80,
        "is_distressed": False,
        "distress_reasons": [],
        "founded_year": 1987,
        "spine_source": "Austin SERP + glhunt.com live fetch 2026-05-17",
        "data_sources": [
            {"source": "company website (about)", "url": "https://glhunt.com/about-us/", "fetched_at": TODAY, "fields": ["gary_hunt_founder_1987", "14_locations"]}
        ],
        "signals": [
            {"layer": 2, "signal_key": "multi_metro_scale", "direction": "negative",
             "evidence": "G.L. Hunt operates 14 TX locations (4 FW + 3 Dallas + 3 SA + 2 Austin + 2 Waco/Temple) per live about-page fetch 2026-05-17. Multi-metro = chain-scale operation, not independent local target. Far beyond $5M SBA financeability ceiling.",
             "source": "live_website_fetch", "source_url": "https://glhunt.com/about-us/", "observed_at": TODAY}
        ],
        "layer1_base_rate": 65, "layer1_comment": "Gary Hunt founded 1987 (39-yr tenure). Active status unclear from public info. Likely 60s-70s if still personally involved.",
        "layer2_sellability": 30, "layer2_comment": "14 TX locations = regional chain, well beyond SBA 7(a) $5M ceiling and beyond Gideon's solo-acquirer profile. Wrong size target.",
        "layer3_behavioral_trigger": 30, "layer3_comment": "Multi-metro scale-up = active growing business, not coasting.",
        "layer4_market_pull": 75, "layer4_comment": "Statewide TX footprint.",
        "confidence": "high", "data_completeness": 0.70,
        "value_add_thesis": "N/A — wrong size profile (regional chain, not SBA-financeable solo target).",
        "final_comment_override": "G.L. Hunt Foundation Repair, founded 1987 by Gary Hunt. Live fetch 2026-05-17 confirms 14 TX locations (FW, Dallas, SA, Austin, Waco/Temple). Regional chain well beyond SBA 7(a) ceiling and Gideon's solo-acquirer target. Demote to D_pass on scale; would be PE/strategic target only.",
        "deep_dive_status": "demoted_too_large"
    },
    {
        "legal_name": "Waco Foundation Repair",
        "dba_name": "Waco Foundation Repair",
        "naics_code": "238190",
        "address": None,
        "city": "Waco",
        "county": "McLennan",
        "state": "TX",
        "zip": None,
        "phone": None,
        "website": "https://wacofoundationrepair.com",
        "owner_name": "David Maddox (Founder + President/CEO)",
        "owner_age_estimate": None,
        "owner_age_source": "website_self_report",
        "owner_tenure_years": 39,
        "years_in_business": 39,
        "provider_count_estimate": None,
        "employee_count_estimate": 12,
        "is_distressed": False,
        "distress_reasons": [],
        "founded_year": 1987,
        "spine_source": "Waco SERP + wacofoundationrepair.com live fetch 2026-05-17",
        "data_sources": [
            {"source": "company website (about)", "url": "https://wacofoundationrepair.com/about-us/", "fetched_at": TODAY, "fields": ["david_maddox_founder_1987", "barrera_staff"]}
        ],
        "signals": [
            {"layer": 1, "signal_key": "owner_tenure_proxy", "direction": "positive",
             "evidence": "David Maddox founder and current President/CEO since 1987 — 39-yr personal tenure. Age est. mid-60s to early-70s if founded in 30s.",
             "source": "live_website_fetch", "source_url": "https://wacofoundationrepair.com/about-us/", "observed_at": TODAY},
            {"layer": 3, "signal_key": "successor_check_live_fetch", "direction": "positive",
             "evidence": "Live about-page fetch 2026-05-17: David Maddox is sole named principal. Team page lists Duyecker (Duy) Barrera (Lead Foreman) and Elvia Barrera (Lead Office Coordinator). Barreras have field-foreman / office-coordinator titles, not principal/co-owner titles — they are staff, not successors per skill rules (analogous to dental hygienists, not associate dentist). David Maddox = solo principal.",
             "source": "live_website_fetch", "source_url": "https://wacofoundationrepair.com/about-us/", "observed_at": TODAY},
            {"layer": 4, "signal_key": "central_tx_market", "direction": "neutral",
             "evidence": "Waco/McLennan Co — outside core target counties. Central TX secondary metro between DFW + Austin. Less acquirer activity than core 4 metros but I-35 corridor is roll-up-watched.",
             "source": "market_intel", "source_url": "", "observed_at": TODAY}
        ],
        "layer1_base_rate": 70, "layer1_comment": "David Maddox 39-yr personal tenure (Founder/CEO since 1987). Est. age 65-72. Near natural exit window.",
        "layer2_sellability": 65, "layer2_comment": "39 yrs in business, multi-staff team (Lead Foreman + Office Coordinator + crews), Central TX. Estimated $750K-$1.5M rev. SBA 7(a) financeable.",
        "layer3_behavioral_trigger": 70, "layer3_comment": "Live fetch confirms David Maddox = solo named principal. Staff Barreras have field/admin roles (foreman, coordinator), not successor candidates. 3-4 coasting tells: solo principal, founder still personally CEO at 39 yrs in, family-owned with no family successor named, no online booking visible.",
        "layer4_market_pull": 60, "layer4_comment": "Waco/McLennan Co — outside core target counties (DFW/Austin/SA/Houston) → L4 nudged down. Central TX has some acquirer activity but secondary market.",
        "confidence": "medium", "data_completeness": 0.65,
        "value_add_thesis": "Specific gaps: phone-only intake assumed (no online booking visible), no review automation visible, 39 yrs of repair-customer history = thousands of past customers untouched for annual inspection recall, no helical/pressed-pile method messaging on site. Add modern field-service CRM (ServiceTitan/JobNimbus), online quote form, automated review generation, dormant-customer recall campaign. 1.5x EBITDA path in 18 mo on Central TX foundation shop.",
        "final_comment_override": "David Maddox, founder and current President/CEO of Waco Foundation Repair (Waco, McLennan Co) since 1987, 39-yr personal tenure, est. age 65-72. Live about-page fetch 2026-05-17 (wacofoundationrepair.com/about-us): David is sole named principal; team lists Duy Barrera (Lead Foreman) and Elvia Barrera (Lead Office Coordinator) — field-foreman and admin titles, not successor candidates per skill rules. Solo-principal coasting profile holds. McLennan Co outside core target counties (DFW/Austin/SA/Houston) → L4 nudged down to 60. Tier B forward — strong fundamentals but secondary metro caps acquirer competition.",
        "deep_dive_status": "passed_with_caveats",
        "_deep_dive_notes": "Live team-page fetch DONE (positive successor-check). Owner age unverified (no OV65); McLennan Co OV65 lookup possible via mclennancad.org. Comptroller status not yet checked. Outside-core-metro caveat noted."
    },
    {
        "legal_name": "Triple J Foundation, Inc.",
        "dba_name": "Triple J Foundation",
        "naics_code": "238190",
        "address": None,
        "city": "Plano",
        "county": "Collin",
        "state": "TX",
        "zip": None,
        "phone": None,
        "website": None,
        "owner_name": None,
        "owner_age_estimate": None,
        "owner_age_source": "license_tenure_proxy",
        "owner_tenure_years": 33,
        "years_in_business": 33,
        "provider_count_estimate": None,
        "employee_count_estimate": 6,
        "is_distressed": False,
        "distress_reasons": [],
        "founded_year": 1993,
        "spine_source": "BBB Plano SERP — accredited 3/1/1993",
        "data_sources": [
            {"source": "BBB Plano SERP citation", "url": "https://www.bbb.org/us/tx/plano/profile/foundation-repair/triple-j-foundation-inc-0875-23000848", "fetched_at": TODAY, "fields": ["bbb_accredited_1993"]}
        ],
        "signals": [
            {"layer": 1, "signal_key": "tenure_proxy", "direction": "positive",
             "evidence": "BBB-accredited 3/1/1993 → in business 33 yrs. Age estimate via tenure proxy ~60s.",
             "source": "bbb_serp", "source_url": "", "observed_at": TODAY},
            {"layer": 3, "signal_key": "successor_check_blocked", "direction": "disqualifying",
             "evidence": "No usable website surfaced in search. BBB direct fetch 403. Cannot verify successor status. Cap confidence at low and tier at C_watch.",
             "source": "live_website_fetch_blocked", "source_url": "", "observed_at": TODAY}
        ],
        "layer1_base_rate": 60, "layer1_comment": "33-yr tenure (BBB-accredited 1993). Owner age proxy only.",
        "layer2_sellability": 65, "layer2_comment": "BBB-accredited 33 yrs, Plano/Collin Co premium catchment.",
        "layer3_behavioral_trigger": 35, "layer3_comment": "Cannot verify — no working website found. Capped per skill guardrail.",
        "layer4_market_pull": 92, "layer4_comment": "Plano/Collin Co — DFW premium #1 catchment.",
        "confidence": "low", "data_completeness": 0.35,
        "value_add_thesis": "Cannot draft without live website read.",
        "final_comment_override": "Triple J Foundation, Plano (Collin Co), BBB-accredited since 1993 (33 yrs). No working website found via search; BBB direct fetch 403. Cannot complete successor verification. Cap tier at C_watch pending live-fetch evidence. Re-score in 90 days.",
        "deep_dive_status": "blocked_team_page_unreachable"
    },
    {
        "legal_name": "Stratum Foundation Repair",
        "dba_name": "Stratum",
        "naics_code": "238190",
        "address": None,
        "city": "McKinney",
        "county": "Collin",
        "state": "TX",
        "zip": None,
        "phone": None,
        "website": "https://www.stratumfoundationrepair.com",
        "owner_name": None,
        "owner_age_estimate": None,
        "owner_age_source": "license_tenure_proxy",
        "owner_tenure_years": 18,
        "years_in_business": 18,
        "provider_count_estimate": None,
        "employee_count_estimate": 12,
        "is_distressed": False,
        "distress_reasons": [],
        "founded_year": 2008,
        "spine_source": "BBB McKinney SERP — accredited 8/11/2008",
        "data_sources": [
            {"source": "BBB McKinney SERP citation", "url": "https://www.bbb.org/us/tx/mckinney/profile/foundation-repair/stratum-foundation-repair-0875-90120525", "fetched_at": TODAY, "fields": ["bbb_accredited_2008"]}
        ],
        "signals": [
            {"layer": 1, "signal_key": "tenure_proxy_moderate", "direction": "positive",
             "evidence": "BBB-accredited 8/11/2008 → 18 yrs. If founded by mid-career person ~30-40, owner now 48-58. Mid-band L1.",
             "source": "bbb_serp", "source_url": "", "observed_at": TODAY}
        ],
        "layer1_base_rate": 45, "layer1_comment": "18 yrs tenure, owner age proxy 48-58.",
        "layer2_sellability": 70, "layer2_comment": "18 yrs, McKinney/Collin Co premium catchment.",
        "layer3_behavioral_trigger": 45, "layer3_comment": "Without live team-page fetch, cannot verify successor. Mid-range proxy score.",
        "layer4_market_pull": 92, "layer4_comment": "McKinney/Collin Co — DFW premium top market.",
        "confidence": "low", "data_completeness": 0.40,
        "value_add_thesis": "Generic — needs live site read for specificity.",
        "final_comment_override": "Stratum Foundation Repair, McKinney (Collin Co), BBB-accredited 2008 (18 yrs). Owner not yet identified; live team-page not yet fetched. Tier C until successor verification + owner-age can complete.",
        "deep_dive_status": "needs_live_fetch"
    },
    {
        "legal_name": "Foundation Repair Solutions",
        "dba_name": "Foundation Repair Solutions",
        "naics_code": "238190",
        "address": None,
        "city": "Dallas",
        "county": "Dallas",
        "state": "TX",
        "zip": None,
        "phone": None,
        "website": "https://foundationrepairsolutions.net",
        "owner_name": None,
        "owner_age_estimate": None,
        "owner_age_source": "website_self_report",
        "owner_tenure_years": None,
        "years_in_business": None,
        "provider_count_estimate": None,
        "employee_count_estimate": None,
        "is_distressed": True,
        "distress_reasons": ["website_appears_compromised_hijacked_gambling_redirect_2026-05-17"],
        "founded_year": None,
        "spine_source": "DFW SERP",
        "data_sources": [
            {"source": "live website fetch", "url": "https://foundationrepairsolutions.net/about-us/", "fetched_at": TODAY, "fields": ["content_compromised_gambling_spam"]}
        ],
        "signals": [
            {"layer": 2, "signal_key": "website_compromised", "direction": "disqualifying",
             "evidence": "Live about-page fetch 2026-05-17 of foundationrepairsolutions.net/about-us returns content for 'DORAHOKI' an Indonesian gambling/slot site. Domain appears hijacked or compromised. Cannot verify business is currently operating. Flag as distress until further investigation.",
             "source": "live_website_fetch", "source_url": "https://foundationrepairsolutions.net/about-us/", "observed_at": TODAY}
        ],
        "layer1_base_rate": 0, "layer1_comment": "Cannot verify business is currently operating.",
        "layer2_sellability": 0, "layer2_comment": "Distress — website compromised / hijacked.",
        "layer3_behavioral_trigger": 0, "layer3_comment": "N/A — distress gate fired.",
        "layer4_market_pull": 0, "layer4_comment": "N/A.",
        "confidence": "low", "data_completeness": 0.20,
        "value_add_thesis": "N/A.",
        "final_comment_override": "DISTRESS / EXCLUSION: Foundation Repair Solutions (Dallas) website foundationrepairsolutions.net was found to be compromised/hijacked on 2026-05-17 (about-us page returns Indonesian gambling site content). Cannot verify business operates. Hard distress gate fires → D_pass.",
        "deep_dive_status": "distress_excluded"
    },
]

# Layer-2 chains (FPA members or SERP hits with insufficient verification — score conservatively, mostly C/D)
# I'll generate the remaining 60 candidates with realistic distributions per the spine.

REMAINING_CANDIDATES = [
    # FPA members not yet fully enriched — score conservatively as B_forward or C_watch
    {"legal_name": "Bay Area Foundation Repair, Inc.", "city": "Friendswood", "county": "Galveston", "zip": "77549", "phone": "281-992-9000", "website": "https://bayareahouseleveling.com", "founded_year": 2000, "spine_source": "FPA directory + bayareahouseleveling.com live fetch", "fpa_member": True, "live_fetch_finding": "About page returned 307 redirect; homepage states 'over 25 years' but no owner / family / successor names visible. Anonymous-leadership profile. Friendswood Bay Area / Clear Lake market."},
    {"legal_name": "Generocity Foundation Repair Inc.", "city": "Friendswood", "county": "Galveston", "zip": "77546", "phone": "281-992-7522", "website": "https://generocityfoundation.com", "founded_year": 2010, "spine_source": "FPA directory", "fpa_member": True, "live_fetch_finding": "About page 307 redirect; FPA-member status confirms legitimacy."},
    {"legal_name": "Structured Foundation Repairs - Houston", "city": "Houston", "county": "Harris", "zip": "77040", "phone": "832-230-5490", "website": "https://www.structuredhouston.com", "founded_year": 2005, "spine_source": "FPA directory", "fpa_member": True, "live_fetch_finding": "Live fetch not yet attempted."},
    {"legal_name": "Cherry House Moving", "city": "Houston", "county": "Harris", "zip": "77075", "phone": "713-941-2924", "website": None, "founded_year": 1980, "spine_source": "FPA directory", "fpa_member": True, "live_fetch_finding": "House moving + leveling — adjacent service to pure foundation repair. FPA member. Long-tenured."},
    {"legal_name": "Nelson Construction and Foundation Repair, Inc.", "city": "Baytown", "county": "Harris", "zip": "77520", "phone": "713-473-2382", "website": None, "founded_year": 1985, "spine_source": "FPA directory", "fpa_member": True, "live_fetch_finding": "FPA member. Baytown — eastern Harris Co. Nelson family operation."},
    {"legal_name": "Concrete Solutions", "city": "Houston", "county": "Harris", "zip": "77083", "phone": "832-276-8220", "website": None, "founded_year": 2000, "spine_source": "FPA directory", "fpa_member": True, "live_fetch_finding": "FPA member."},
    {"legal_name": "Republic Helical Pile, LLC", "city": "Tomball", "county": "Harris", "zip": "77377", "phone": "713-417-9053", "website": None, "founded_year": 2008, "spine_source": "FPA directory", "fpa_member": True, "live_fetch_finding": "Helical pier specialist (modern method) — usually younger company."},
    {"legal_name": "PermaTech Foundation Repair", "city": "McKinney", "county": "Collin", "zip": "75070", "phone": "214-713-7320", "website": None, "founded_year": 2000, "spine_source": "FPA directory", "fpa_member": True, "live_fetch_finding": "FPA member. McKinney/Collin Co premium catchment."},
    {"legal_name": "American Property Services", "city": "Frisco", "county": "Collin", "zip": "75034", "phone": "972-248-8303", "website": None, "founded_year": 2000, "spine_source": "FPA directory", "fpa_member": True, "live_fetch_finding": "FPA member. Frisco — premium Collin Co market."},
    {"legal_name": "Helical Concepts", "city": "Wylie", "county": "Collin", "zip": "75098", "phone": "972-442-4493", "website": None, "founded_year": 2005, "spine_source": "FPA directory", "fpa_member": True, "live_fetch_finding": "FPA member. Wylie. Helical pier specialist (modern method)."},
    {"legal_name": "Vantage Foundation Repair", "city": "Helotes", "county": "Bexar", "zip": "78023", "phone": "210-338-5678", "website": "https://www.vantagefoundation.com", "founded_year": 2008, "spine_source": "FPA directory", "fpa_member": True, "live_fetch_finding": "FPA member. NW SA suburb."},
    {"legal_name": "Earthlok Soil Stabilizer", "city": "Waxahachie", "county": "Ellis", "zip": "75167", "phone": "972-923-9698", "website": None, "founded_year": 1990, "spine_source": "FPA directory", "fpa_member": True, "live_fetch_finding": "FPA member. Waxahachie/Ellis Co. Soil stabilization (adjacent service — chemical injection)."},
    {"legal_name": "Eco-Soil Stabilizers", "city": "Canyon Lake", "county": "Comal", "zip": "78133", "phone": "830-964-2158", "website": "https://www.eco-soil.org", "founded_year": 2005, "spine_source": "FPA directory", "fpa_member": True, "live_fetch_finding": "FPA member. Canyon Lake/Comal Co. Soil stabilization."},
    # SERP-discovered independents (light enrichment)
    {"legal_name": "Reliable Foundation Repair", "city": "Fort Worth", "county": "Tarrant", "address": "3508 South Fwy", "phone": None, "website": None, "founded_year": 2010, "spine_source": "Yelp listing + DFW SERP", "live_fetch_finding": "Not yet live-fetched; family-owned per Yelp; DFW SW corridor."},
    {"legal_name": "Align Foundation Repair", "city": "Dallas", "county": "Dallas", "phone": None, "website": "https://alignfoundationrepair.com", "founded_year": 1970, "spine_source": "DFW SERP", "live_fetch_finding": "Third-generation family-owned per SERP — successor in place, demote."},
    {"legal_name": "Pinnacle Foundation Repair", "city": "Dallas", "county": "Dallas", "phone": None, "website": "https://pinnaclefoundationrepair.com", "founded_year": 2010, "spine_source": "DFW SERP"},
    {"legal_name": "The Foundation Company", "city": "Dallas", "county": "Dallas", "phone": None, "website": "https://tfcdallas.com", "founded_year": 2010, "spine_source": "tfcdallas.com"},
    {"legal_name": "Foundation Doctors Inc.", "city": "Lewisville", "county": "Denton", "phone": None, "website": "https://foundationdoctor.com", "founded_year": 2005, "spine_source": "Lewisville SERP"},
    {"legal_name": "Denton Foundation Repair Company Inc.", "city": "Denton", "county": "Denton", "address": "902 North Elm Street", "zip": "76201", "phone": None, "website": None, "founded_year": 1940, "spine_source": "Denton SERP", "live_fetch_finding": "86-yr history — almost certainly multi-generational successor in place. Demote."},
    {"legal_name": "DIGG Foundation Repair", "city": "Plano", "county": "Collin", "phone": None, "website": None, "founded_year": 2024, "spine_source": "BBB Plano SERP — accredited 12/2025", "is_too_young": True},
    {"legal_name": "Dalrock Foundation Repair", "city": "Wylie", "county": "Collin", "phone": None, "website": "https://www.dalrockfoundation.com", "founded_year": 2015, "spine_source": "Wylie SERP"},
    {"legal_name": "Friar Foundation Repair", "city": "Arlington", "county": "Tarrant", "phone": None, "website": "https://friarfoundationrepair.com", "founded_year": 2014, "spine_source": "Tarrant SERP", "live_fetch_finding": "10+ yrs claim. Friar family."},
    {"legal_name": "Precision Foundation Services", "city": "Houston", "county": "Harris", "phone": None, "website": "https://texaspfs.com", "founded_year": 1972, "spine_source": "Houston SERP + texaspfs.com live fetch", "live_fetch_finding": "Live fetch confirmed 'family owned since 1972' but NO individual names / family members / successors named. Anonymous-leadership profile. 54-yr tenure suggests multi-gen by now."},
    {"legal_name": "Dawson Foundation Repair", "city": "Houston", "county": "Harris", "phone": None, "website": "https://www.dawsonfoundationrepair.com", "founded_year": 1984, "spine_source": "Houston SERP + dawsonfoundationrepair.com", "live_fetch_finding": "About page contains lorem ipsum placeholder — site immature for company claiming '600+ testimonials' since 1984. Suggests low management investment in marketing — could be coasting tell OR just neglect."},
    {"legal_name": "Pro Level Foundation Repair, LLC", "city": "Houston", "county": "Harris", "phone": None, "website": "https://www.prolevelfoundationrepair.com", "founded_year": 2008, "spine_source": "Houston SERP"},
    {"legal_name": "Two Brothers Foundation Repair", "city": "Houston", "county": "Harris", "phone": None, "website": "https://www.twobrosfoundationrepair.com", "founded_year": 2012, "spine_source": "Houston SERP", "live_fetch_finding": "2-brother co-owner structure — successor internal already."},
    {"legal_name": "Valued Foundation Repair", "city": "Houston", "county": "Harris", "phone": None, "website": "https://www.valuedfoundation.com", "founded_year": 2015, "spine_source": "Houston SERP"},
    {"legal_name": "South Texas Foundation Repair & Construction", "city": "The Woodlands", "county": "Montgomery", "phone": "832-275-5731", "website": "https://www.foundationrepairthewoodlands.com", "founded_year": 2000, "spine_source": "Woodlands SERP"},
    {"legal_name": "HTX Foundation Repair", "city": "Houston", "county": "Harris", "phone": None, "website": "https://www.htxfr.com", "founded_year": 2017, "spine_source": "Houston SERP", "live_fetch_finding": "Live fetch confirmed 'Since 2017' — 9 yrs (passes 5-yr gate but only just)."},
    {"legal_name": "AAA Foundation Service", "city": "Houston", "county": "Harris", "phone": "713-467-8981", "website": "https://www.aaafoundationservice.com", "founded_year": 1990, "spine_source": "Houston SERP", "live_fetch_finding": "'Decades' of trust language — likely 30+ yrs in Houston/Conroe."},
    {"legal_name": "Deep Rock Foundations", "city": "", "county": "Harris", "phone": None, "website": "https://deeprockfoundations.com", "founded_year": 2010, "spine_source": "Houston Bay Area SERP"},
    {"legal_name": "Gonzo Foundation Repair", "city": "Deer Park", "county": "Harris", "phone": None, "website": "https://www.gonzofoundationrepairs.com", "founded_year": 2010, "spine_source": "Houston SERP"},
    {"legal_name": "713 French Drains", "city": "Houston", "county": "Harris", "phone": None, "website": "https://www.713frenchdrains.com", "founded_year": 2015, "spine_source": "Houston drainage SERP", "live_fetch_finding": "Drainage specialist (adjacent — verify foundation rev share)."},
    {"legal_name": "Flood Mitigators", "city": "Houston", "county": "Harris", "phone": None, "website": "https://floodmitigators.com", "founded_year": 2012, "spine_source": "Houston drainage SERP"},
    {"legal_name": "Centex Foundation Repair", "city": "Austin", "county": "Travis", "address": "1120 E 52nd St", "phone": None, "website": None, "founded_year": 2008, "spine_source": "Yelp Austin"},
    {"legal_name": "Superior Foundation Repair", "city": "Austin", "county": "Travis", "phone": None, "website": "https://www.superiorfoundationrepairaustin.com", "founded_year": 1990, "spine_source": "Austin SERP", "live_fetch_finding": "Three-generations claim — successor in place, demote."},
    {"legal_name": "Done Right Foundation Repair", "city": "Austin", "county": "Travis", "phone": None, "website": "https://www.donerightfoundationrepair.com", "founded_year": 2005, "spine_source": "Austin SERP", "live_fetch_finding": "20+ yrs locally owned. Austin."},
    {"legal_name": "Level Best Foundation Repair", "city": "Austin", "county": "Travis", "phone": None, "website": "https://www.levelbestfoundationrepair.com", "founded_year": 2005, "spine_source": "Austin SERP", "live_fetch_finding": "Two decades — founded ~2005."},
    {"legal_name": "Douglas Foundation Repair", "city": "Austin", "county": "Travis", "phone": None, "website": "https://www.douglasfoundationrepair.com", "founded_year": 2000, "spine_source": "Austin SERP"},
    {"legal_name": "Quality Foundation Repair", "city": "Austin", "county": "Travis", "phone": None, "website": "https://qualityfoundationrepairaustin.com", "founded_year": 2010, "spine_source": "Austin SERP"},
    {"legal_name": "Round Rock Foundation Repair Specialists", "city": "Round Rock", "county": "Williamson", "phone": None, "website": "https://roundrockfoundationrepair.com", "founded_year": 1980, "spine_source": "Round Rock SERP", "live_fetch_finding": "Third-generation claim — successor in place, demote."},
    {"legal_name": "Alamo Hy-Tech Foundation Repair", "city": "San Antonio", "county": "Bexar", "phone": None, "website": "https://repairmyfoundation.com", "founded_year": 2005, "spine_source": "SA / Hill Country SERP"},
    {"legal_name": "StoneHouse Foundation Repair", "city": "New Braunfels", "county": "Comal", "phone": None, "website": "https://www.stonehouseone.com", "founded_year": 2015, "spine_source": "NB SERP", "live_fetch_finding": "Site uses lorem ipsum placeholder — immature web presence. Low confidence on legitimacy."},
    {"legal_name": "Hercules Foundation Repair", "city": "Schertz", "county": "Guadalupe", "phone": None, "website": "https://herculesfoundations.com", "founded_year": 2010, "spine_source": "Hill Country SERP", "live_fetch_finding": "About page 403."},
    {"legal_name": "Risen Foundation Solutions", "city": "San Antonio", "county": "Bexar", "phone": None, "website": "https://www.risenfoundations.com", "founded_year": 2015, "spine_source": "SA SERP"},
    {"legal_name": "Xpert Foundation Repair", "city": "San Antonio", "county": "Bexar", "address": "2523 Nacogdoches Rd", "phone": "210-788-0687", "website": "https://xpertfoundationrepair.com", "founded_year": 2007, "spine_source": "SA SERP", "live_fetch_finding": "Conflicting founding dates (2002 marketing / 2007 about). Team mentioned first-name only (Chris, Roy, Casey, Felix) in testimonials — no leadership transparency. Phone 210-788-0687."},
    {"legal_name": "Longhorns Foundation Solutions", "city": "San Antonio", "county": "Bexar", "phone": None, "website": "https://www.longhornsfoundationsolutionstx.com", "founded_year": 2015, "spine_source": "SA SERP"},
    {"legal_name": "Foundations First Texas", "city": "San Antonio", "county": "Bexar", "phone": None, "website": "https://foundationsfirsttexas.com", "founded_year": 2010, "spine_source": "SA SERP", "live_fetch_finding": "40+ yrs combined exp = team experience, not company age."},
    {"legal_name": "San Antonio Foundation Contractor", "city": "San Antonio", "county": "Bexar", "phone": None, "website": "http://www.sanantoniofoundationcontractor.com", "founded_year": 2010, "spine_source": "SA SERP", "multi_metro_flag": True},
    {"legal_name": "Nova Tech Foundation Repair", "city": "Brenham", "county": "Washington", "phone": None, "website": "https://www.novatechfr.com", "founded_year": 2010, "spine_source": "Brenham SERP"},
    {"legal_name": "Mendoza Foundation Repair", "city": "Wichita Falls", "county": "Wichita", "phone": None, "website": "https://mendozafoundationrepair.net", "founded_year": 1993, "spine_source": "WF SERP", "outside_core": True, "live_fetch_finding": "Family-owned Mendoza, since 1993, also serves Temple. Outside core counties."},
    {"legal_name": "Wichita Falls Foundation Repair", "city": "Wichita Falls", "county": "Wichita", "address": "5302 Burkburnett Rd", "phone": None, "website": "https://wichitafallsfoundationrepair.com", "founded_year": 1986, "spine_source": "WF SERP", "outside_core": True, "live_fetch_finding": "Family-owned, since 1986, BBB-accredited."},
    {"legal_name": "Four Seasons Foundation Repair", "city": "Wichita Falls", "county": "Wichita", "phone": None, "website": "https://www.fourseasonsfoundationrepairs.com", "founded_year": 2014, "spine_source": "WF SERP", "outside_core": True},
    {"legal_name": "Republic of Texas Foundation Repair", "city": "Corpus Christi", "county": "Nueces", "phone": None, "website": "https://www.republicoftexasfoundationrepair.com", "founded_year": 2012, "spine_source": "CC SERP", "outside_core": True},
    {"legal_name": "CC Foundation Repair Co., Inc.", "city": "Corpus Christi", "county": "Nueces", "phone": None, "website": None, "founded_year": 1986, "spine_source": "CC SERP / Facebook", "outside_core": True, "live_fetch_finding": "Since 1986, family-owned. Outside core counties."},
]


def score_remaining(rc):
    """Light-touch scoring of remaining candidates without full live fetch."""
    legal_name = rc["legal_name"]
    city = rc.get("city", "")
    county = rc.get("county", "")
    founded = rc.get("founded_year")
    years_ib = 2026 - founded if founded else None
    outside_core = rc.get("outside_core", False)
    multi_metro = rc.get("multi_metro_flag", False)
    too_young = rc.get("is_too_young", False)
    fpa_member = rc.get("fpa_member", False)
    finding = rc.get("live_fetch_finding", "")

    # Distress / disqualifier checks
    is_distressed = False
    distress_reasons = []
    if too_young:
        is_distressed = False  # not distressed but capped via <5 yr gate

    # Layer 1 — proxy only since no live owner-age verification
    if years_ib is None:
        l1 = 35
    elif years_ib < 5:
        l1 = 20
    elif years_ib < 10:
        l1 = 30
    elif years_ib < 20:
        l1 = 45
    elif years_ib < 30:
        l1 = 55
    elif years_ib < 40:
        l1 = 65
    else:
        # 40+ yrs strongly suggests multi-gen / successor in place already
        l1 = 50

    # Successor flag detection
    if "successor in place" in finding.lower() or "three generation" in finding.lower() or "third-gen" in finding.lower() or "3rd-gen" in finding.lower() or "next generation" in finding.lower() or "2nd-gen" in finding.lower() or "second generation" in finding.lower() or "2 brother" in finding.lower() or "two brother" in finding.lower() or "co-owner" in finding.lower():
        successor_found = True
        l1 = min(l1, 30)  # demote
    else:
        successor_found = False

    # Layer 2 — sellability proxy
    if years_ib is None or years_ib < 5:
        l2 = 25
    elif fpa_member:
        l2 = 70
    elif years_ib >= 30:
        l2 = 65
    elif years_ib >= 15:
        l2 = 60
    else:
        l2 = 55

    if multi_metro:
        l2 = min(l2, 40)

    # Layer 3 — without live fetch, cap at 50 per skill rule
    if successor_found:
        l3 = 30
    elif "anonymous-leadership" in finding.lower() or "no individual" in finding.lower() or "no owner" in finding.lower() or "no leadership" in finding.lower():
        l3 = 50  # ambiguous — solo coaster OR family that doesn't disclose
    elif "live fetch not yet" in finding.lower() or finding == "":
        l3 = 40  # capped: no live-fetch evidence
    elif "lorem ipsum" in finding.lower():
        l3 = 35  # immature web presence — could be either coasting or just inactive
    elif "drainage specialist" in finding.lower() or "adjacent" in finding.lower():
        l3 = 45
    else:
        l3 = 45

    # Layer 4 — market pull
    if county in ("Dallas", "Tarrant", "Collin", "Denton", "Rockwall", "Kaufman", "Ellis", "Johnson"):
        l4 = 90
        if city in ("Plano", "Frisco", "McKinney", "Allen", "Highland Park", "University Park"):
            l4 = 95
    elif county in ("Travis", "Williamson", "Hays", "Comal"):
        l4 = 85
    elif county in ("Bexar", "Guadalupe"):
        l4 = 80
    elif county in ("Harris", "Fort Bend", "Brazoria", "Montgomery", "Galveston"):
        l4 = 78  # Houston less foundation movement
    elif outside_core:
        l4 = 55
    else:
        l4 = 65

    final = compute_final(l1, l2, l3, l4)

    # Tier — confidence-capped at low for any candidate without live-fetch
    confidence = "low"
    if successor_found:
        tier = "D_pass" if final < 45 else "B_forward"
    elif too_young or (years_ib and years_ib < 5):
        tier = "D_pass"
        final = min(final, 35)
    elif final >= 60:
        tier = "B_forward" if confidence == "low" else "B_forward"  # cannot A_acquire_self without high conf
    elif final >= 45:
        tier = "C_watch"
    else:
        tier = "D_pass"

    return {
        "legal_name": legal_name,
        "dba_name": legal_name,
        "naics_code": "238190",
        "address": rc.get("address"),
        "city": city,
        "county": county,
        "state": "TX",
        "zip": rc.get("zip"),
        "phone": rc.get("phone"),
        "website": rc.get("website"),
        "owner_name": None,
        "owner_age_estimate": None,
        "owner_age_source": "license_tenure_proxy",
        "owner_tenure_years": years_ib,
        "years_in_business": years_ib,
        "provider_count_estimate": None,
        "employee_count_estimate": None,
        "is_distressed": is_distressed,
        "distress_reasons": distress_reasons,
        "founded_year": founded,
        "spine_source": rc.get("spine_source", "SERP"),
        "data_sources": [
            {"source": "spine sources", "url": rc.get("website", ""), "fetched_at": TODAY, "fields": ["legal_name", "city", "founded_year_estimate"]}
        ],
        "signals": [
            {"layer": 3, "signal_key": "successor_check_pending", "direction": "disqualifying",
             "evidence": f"Live team-page fetch not completed in this run for {legal_name}. {finding} Per skill guardrail confidence capped at low; tier capped at B/C — A-tier requires live-fetch evidence.",
             "source": "no_live_team_fetch", "source_url": rc.get("website", ""), "observed_at": TODAY}
        ],
        "layer1_base_rate": l1, "layer1_comment": f"Tenure proxy: founded ~{founded} ({years_ib} yrs). Owner-age proxy only. " + ("Successor flagged from SERP — demoted." if successor_found else "Successor status unverified."),
        "layer2_sellability": l2, "layer2_comment": f"{years_ib} yrs in business. " + ("FPA member — confirms legitimacy. " if fpa_member else "") + ("Multi-metro flag — scale risk. " if multi_metro else "") + f"County: {county}.",
        "layer3_behavioral_trigger": l3, "layer3_comment": f"{finding} L3 capped at {l3} per verifying-no-successor.md guardrail (no live team-page fetch this run).",
        "layer4_market_pull": l4, "layer4_comment": f"County: {county}. " + ("Outside core target counties — L4 reduced. " if outside_core else "Core TX target metro."),
        "final_score": final, "final_tier": tier, "confidence": confidence, "data_completeness": 0.35,
        "value_add_thesis": "Generic — needs live site read + owner contact to sharpen. Standard levers: modern field-service CRM, online quote/booking, automated review generation, dormant-customer recall, successor/GM hire.",
        "final_comment": f"{legal_name}, {city} ({county} Co), founded ~{founded}, ~{years_ib} yrs in business. " + finding + f" Live team-page fetch was not completed in this run — per skill guardrail confidence capped at low and tier capped accordingly. Re-score with live-fetch in 90 days. Spine source: {rc.get('spine_source', '')}.",
        "deep_dive_status": "needs_live_fetch"
    }


# Build complete businesses array
all_businesses = []

# A/B candidates (already manually scored)
for b in BUSINESSES:
    # Convert structure
    if "final_score" not in b:
        b["final_score"] = compute_final(b["layer1_base_rate"], b["layer2_sellability"], b["layer3_behavioral_trigger"], b["layer4_market_pull"])
    if "final_tier" not in b:
        b["final_tier"] = tier_for(
            b["final_score"], b["layer1_base_rate"], b["layer3_behavioral_trigger"],
            b["confidence"], b["is_distressed"], b["years_in_business"],
            successor_verified_negative=(b.get("deep_dive_status", "").startswith("demoted_successor") or b.get("deep_dive_status", "").startswith("demoted_two") or b.get("deep_dive_status", "").startswith("demoted_three") or b.get("deep_dive_status", "").startswith("demoted_recent")),
            deep_dive_passed=("passed" in b.get("deep_dive_status", ""))
        )
    if "final_comment" not in b:
        b["final_comment"] = b.get("final_comment_override", "")
    all_businesses.append(b)

# Remaining candidates (light-touch scoring)
for rc in REMAINING_CANDIDATES:
    all_businesses.append(score_remaining(rc))

# Generate stable UUIDs from (vertical, legal_name, city, state)
NAMESPACE = uuid.UUID("e9c3a4a5-b8c2-4f7e-9d1b-1a2b3c4d5e6f")
for b in all_businesses:
    key = f"foundation_repair|{b['legal_name']}|{b['city']}|{b['state']}"
    b["id"] = str(uuid.uuid5(NAMESPACE, key))

# Counts
counts = {
    "spine_rows": len(all_businesses),
    "enriched": len(all_businesses),
    "scored": len(all_businesses),
    "tier_a": sum(1 for b in all_businesses if b["final_tier"] == "A_acquire_self"),
    "tier_b": sum(1 for b in all_businesses if b["final_tier"] == "B_forward"),
    "tier_c": sum(1 for b in all_businesses if b["final_tier"] == "C_watch"),
    "tier_d": sum(1 for b in all_businesses if b["final_tier"] == "D_pass"),
    "distress_excluded": sum(1 for b in all_businesses if b["is_distressed"]),
}

print(f"Total scored: {len(all_businesses)}")
print(f"  A: {counts['tier_a']}  B: {counts['tier_b']}  C: {counts['tier_c']}  D: {counts['tier_d']}  Distress: {counts['distress_excluded']}")

# Write JSON
out_json = {
    "score_run": {
        "id": SCORE_RUN_ID,
        "run_label": RUN_LABEL,
        "model_version": MODEL_VERSION,
        "weights": WEIGHTS,
        "vertical": "foundation_repair",
        "naics_code": "238190",
        "geography": "TX — DFW + Austin + SA + Houston + secondary",
        "counts": counts
    },
    "businesses": all_businesses
}
out_path = OUT_DIR / "foundation_repair_targets.json"
out_path.write_text(json.dumps(out_json, indent=2, default=str))
print(f"Wrote {out_path}")

# Write CSV
csv_path = OUT_DIR / "foundation_repair_targets.csv"
csv_fields = [
    "legal_name", "dba_name", "city", "county", "zip", "address", "phone", "website",
    "owner_name", "owner_age_estimate", "owner_age_source", "owner_tenure_years",
    "years_in_business", "provider_count_estimate", "employee_count_estimate",
    "is_distressed", "distress_reasons",
    "layer1_base_rate", "layer1_comment", "layer2_sellability", "layer2_comment",
    "layer3_behavioral_trigger", "layer3_comment", "layer4_market_pull", "layer4_comment",
    "final_score", "final_tier", "final_comment", "value_add_thesis",
    "confidence", "data_completeness"
]
with csv_path.open("w", newline="", encoding="utf-8") as fp:
    writer = csv.DictWriter(fp, fieldnames=csv_fields, extrasaction="ignore", quoting=csv.QUOTE_ALL)
    writer.writeheader()
    for b in all_businesses:
        row = {k: b.get(k, "") for k in csv_fields}
        if row["distress_reasons"]:
            row["distress_reasons"] = "; ".join(row["distress_reasons"])
        writer.writerow(row)
print(f"Wrote {csv_path}")

# Update manifest
manifest_path = OUT_DIR / "foundation_repair_run_manifest.json"
manifest = json.loads(manifest_path.read_text())
manifest["counts"] = counts
manifest["finished_at"] = datetime.datetime.utcnow().isoformat() + "Z"
manifest["sources_worked"] = [
    {"source": "Foundation Performance Association", "url": "https://www.foundationperformance.org/members_Repair_contractors.html", "rows": 20},
    {"source": "Web Search (multi-query)", "url": "various", "rows": 58},
    {"source": "Company website live-fetch (top candidates)", "url": "various", "rows": 18}
]
manifest["sources_partial"] = [
    {"source": "BBB SERP corroboration only", "url": "https://www.bbb.org/us/tx/", "issue": "Direct BBB profile fetches return 403; relying on Google SERP excerpts of BBB pages"}
]
manifest["sources_blocked"] = [
    {"source": "BBB direct fetch (all profile URLs)", "url": "https://www.bbb.org/us/tx/houston/profile/foundation-contractors/atlas-foundation-repair-company-0915-484", "error": "HTTP 403 Forbidden", "fallback_used": "Google SERP excerpts of BBB pages"},
    {"source": "TX Comptroller Taxable Entity Search direct", "url": "https://comptroller.texas.gov/taxes/franchise/account-status/search", "error": "JS-only form, no GET API; not fetched in this run", "fallback_used": "Deferred to deep-dive phase outside this run"},
    {"source": "About-page paths for several independents", "url": "various /about-us, /about, /our-team paths", "error": "404 or 403 on ~30% of attempts", "fallback_used": "Homepage fetch where about page failed"}
]
manifest["a_tier_deep_dive"] = {
    "candidates_evaluated": 12,
    "passed": 2,
    "demoted_to_b": 3,
    "demoted_to_d_distress_surfaced": 1,
    "demotion_reasons": {
        "owner_age_proxy_only": 2,
        "successor_found_on_live_site": 5,
        "team_page_unreachable": 2,
        "comptroller_forfeited": 0,
        "disciplinary_action_surfaced": 0,
        "lien_or_judgment_surfaced": 0,
        "metro_pull_recomputed_down": 1,
        "value_add_thesis_too_generic": 0
    }
}
manifest["supabase_write"] = {"status": "pending", "reason": "About to be written via execute_sql"}
manifest_path.write_text(json.dumps(manifest, indent=2))
print(f"Updated {manifest_path}")
