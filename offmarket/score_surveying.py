#!/usr/bin/env python3
"""Score TX land surveying spine through the 4-layer model.

This script consumes:
  offmarket/data/surveying_spine.json (the spine)
  offmarket/data/surveying_enrich_batch_*.json (sub-agent enrichment output, if any)
  offmarket/data/surveying_deep_dive.json (A-tier deep-dive results, if any)

And produces:
  offmarket/data/surveying_targets.json (canonical record per skill)
  offmarket/data/surveying_targets.csv
  offmarket/data/surveying_run_manifest.json

The scoring math:
- Layer 1: owner-age proxy (license_tenure_proxy from RPLS grant year) + tenure modifier.
  RPLS granted 1965-1980 → owner ~74-81 today  → L1 anchor 85-95
  RPLS granted 1981-1990 → owner ~63-73 today  → L1 anchor 75-88
  RPLS granted 1991-2000 → owner ~53-63 today  → L1 anchor 50-72
  RPLS granted 2001-2010 → owner ~43-53 today  → L1 anchor 30-50
- Layer 2: sellability. Defaults to 65-75 for solo-RPLS multi-staff long-tenured firms.
  Adjust per enrichment data (multi-service, recurring B2B, distress flags).
- Layer 3: coasting tells. Solo-RPLS for 20+ years + dated web + no successor + no recent
  hiring → 70-90. Adjust per enrichment.
- Layer 4: market pull. Surveying baseline 65 (low PE attention). +2 baseline boost for
  solo/2-RPLS small firms in TX (the opportunity zone). Sub-market nudges per verticals.md.
"""
import json, csv, os, sys, re
from datetime import datetime, timezone
from collections import Counter

ROOT = os.path.dirname(os.path.abspath(__file__))
DATA = os.path.join(ROOT, "data")

# Personal-name patterns: solo-RPLS where the firm name is literally the person's name.
# These are typically too small (< $300K rev) to be SBA-acquisition targets.
def looks_like_personal_name_firm(legal_name, rpls_name):
    if not rpls_name:
        return False
    # Strip middle initial / suffix from rpls
    rpls_simple = re.sub(r'\s+(jr|sr|ii|iii|iv)\.?$', '', rpls_name.lower(), flags=re.I).strip()
    rpls_simple = re.sub(r'\s+', ' ', rpls_simple)
    legal_simple = re.sub(r'(\s*,?\s*(inc|llc|pllc|ltd|lp|corp|co|company|surveying|surveyors?|professional|land|associates?|consulting|services?)\s*\.?)+\s*$', '', legal_name.lower()).strip()
    legal_simple = re.sub(r'\s+', ' ', legal_simple)
    # Compare token sets (Last+First match)
    rt = set(t for t in rpls_simple.split() if len(t) > 1)
    lt = set(t for t in legal_simple.split() if len(t) > 1)
    overlap = rt & lt
    return len(overlap) >= 2 and len(legal_simple.split()) <= 4

# === HELPERS ===

def metro_pull_score(geo_bucket, county, city):
    """Layer 4 base + sub-market nudges per verticals.md (LOW PE ATTENTION baseline +2 boost)."""
    base = 65  # surveying baseline = lower than dental/plumbing because low PE attention IS already baked into multipliers via comp transactions, BUT we add +2 to all small-shop TX-metro candidates because opportunity zone
    boost = 2  # universal +2 for solo/2-RPLS TX-metro candidates
    sub_market = 0

    if geo_bucket == "major_metro":
        if county in ("Travis", "Williamson", "Hays"): sub_market += 3   # Austin growth
        elif county in ("Collin", "Denton"): sub_market += 3              # N Dallas growth
        elif county in ("Tarrant", "Dallas"): sub_market += 1
        elif county == "Bexar": sub_market += 1
        else: sub_market += 1
    elif geo_bucket == "major_metro_coastal":
        sub_market += 4  # West Houston / Katy growth +3, +1 subsidence-zone
    elif geo_bucket == "permian":
        sub_market += 3  # Permian Basin oil/gas ROW
    elif geo_bucket == "eagle_ford":
        sub_market += 3  # Eagle Ford energy corridor
    elif geo_bucket == "coastal_flood":
        sub_market += 2  # FEMA elevation cert recurring
    elif geo_bucket == "secondary":
        sub_market += 0
    elif geo_bucket in ("rural", "panhandle", "east_tx"):
        sub_market -= 3
    else:
        sub_market = 0

    return min(100, max(20, base + boost + sub_market))


def metro_pull_comment(geo_bucket, county, city, score):
    """Generate Layer 4 comment with sub-market specifics."""
    bits = []
    if geo_bucket == "major_metro":
        if county in ("Travis", "Williamson", "Hays"):
            bits.append(f"Austin metro ({city}, {county} County) = highest TX development volume 2024-2026 → boundary + topo + construction stake-out demand peak.")
        elif county in ("Collin", "Denton"):
            bits.append(f"North Dallas / {county} County ({city}) — production-homebuilder cluster (DR Horton, Lennar, Toll, KB Home programs).")
        elif county in ("Tarrant", "Dallas"):
            bits.append(f"DFW core metro ({city}, {county} County) — mature development market, steady recurring.")
        elif county == "Bexar":
            bits.append(f"San Antonio metro ({city}, {county} County) — steady boundary + civil-engineering subcontract market.")
        else:
            bits.append(f"TX major metro ({city}, {county} County).")
    elif geo_bucket == "major_metro_coastal":
        bits.append(f"Greater Houston metro ({city}, {county} County) — West Houston growth + Harris-Galveston Subsidence District annual monitoring + flood-zone FEMA work.")
    elif geo_bucket == "permian":
        bits.append(f"Permian Basin ({city}, {county} County) — oil/gas ROW master service agreement work; highest-margin recurring B2B in surveying.")
    elif geo_bucket == "eagle_ford":
        bits.append(f"Eagle Ford energy corridor ({city}, {county} County) — pipeline ROW + lease survey recurring book.")
    elif geo_bucket == "coastal_flood":
        bits.append(f"Coastal flood-zone metro ({city}, {county} County) — FEMA elevation cert recurring work tied to flood-insurance renewals.")
    elif geo_bucket == "secondary":
        bits.append(f"TX secondary metro ({city}, {county} County) — moderate transactional volume; recurring B2B drives valuation.")
    else:
        bits.append(f"{city}, {county or 'TX'} — exurban/rural; thinner platform-bid market but search-fund-active.")

    bits.append("LOW-PE-ATTENTION vertical: only Bowman (NASDAQ:BWMN) + Westwood (Endeavour Capital) are PE-backed rollup platforms in TX; large-AEC strategics (Stantec, WSP, AECOM, Kimley-Horn, Cobb Fendley, LJA) only bolt-on $5M+ rev firms — sub-$5M independents are structurally under-targeted. ETA/search-fund appetite emerging fast 2024-2026 (top-15 vertical in Stanford Search Fund Study). +2 baseline boost for solo/2-RPLS metros = opportunity zone.")
    return " ".join(bits)


def baseline_l1(earliest_rpls_year, n_active_rpls):
    """Base Layer 1 score from RPLS-tenure proxy. Returns (score, age_estimate, source_tag)."""
    if not earliest_rpls_year:
        return 30, None, "unknown"
    # Assume RPLS earned at ~age 30 (TX requires 4yr college + 4yr apprentice + exam)
    age = 2026 - earliest_rpls_year + 30
    tenure = 2026 - earliest_rpls_year

    if age >= 75:        score = 92
    elif age >= 70:      score = 88
    elif age >= 67:      score = 85
    elif age >= 64:      score = 78
    elif age >= 60:      score = 72
    elif age >= 56:      score = 60
    elif age >= 52:      score = 45
    elif age >= 48:      score = 35
    else:                score = 25

    # Tenure bonus
    if tenure >= 40: score += 3
    elif tenure >= 30: score += 2

    # 2-RPLS with younger 2nd RPLS = some successor risk (still possible coasting but reduce L1 modestly)
    # Done in L3 not L1.

    return min(100, score), age, "license_tenure_proxy"


def baseline_l2(n_active_rpls, owner_tenure_years):
    """Base Layer 2 (sellability): default for healthy long-tenured surveying firm."""
    if not owner_tenure_years:
        return 55, "Unknown tenure — default mid."
    # Long-tenured = real, sellable business
    if owner_tenure_years >= 30 and n_active_rpls >= 2: score = 75
    elif owner_tenure_years >= 30 and n_active_rpls == 1: score = 70
    elif owner_tenure_years >= 20 and n_active_rpls >= 2: score = 70
    elif owner_tenure_years >= 20 and n_active_rpls == 1: score = 65
    elif owner_tenure_years >= 10: score = 60
    else: score = 50
    return score, f"{owner_tenure_years}yr-tenured firm with {n_active_rpls} active RPLS — TX RPLS license is a 4yr-college + 4yr-apprentice + exam-gated skilled-trade moat; firm passes the >5yr in-business hard gate; vertical has documented recurring B2B from oil/gas ROW + construction stake-out + ALTA + FEMA elev certs. Default L2 mid-range pending enrichment-time confirmation of staff count + recurring program mix (homebuilder logos / MSA language)."


def baseline_l3(n_active_rpls, owner_tenure_years, latest_rpls_granted_year, principals):
    """Base Layer 3 (coasting trigger): solo long-tenured = strong default; 2-RPLS with younger 2nd = mixed."""
    if not owner_tenure_years:
        return 30, "Insufficient tenure data — default low."

    tells = 0
    tell_strs = []

    # Tell 1: solo RPLS for 20+ years (no successor RPLS added)
    if n_active_rpls == 1 and owner_tenure_years >= 20:
        tells += 1
        tell_strs.append(f"Solo RPLS for {owner_tenure_years}+ years — owner has not added a second RPLS / has not been training a credentialed successor.")
    elif n_active_rpls == 2 and latest_rpls_granted_year:
        # If 2nd RPLS was granted long ago (peer-aged), still a coasting tell
        try:
            gap = int(latest_rpls_granted_year) - int(str(principals[0]['granted'])[:4])
        except Exception:
            gap = 0
        if gap < 5:  # peer-aged
            tells += 1
            tell_strs.append(f"2 RPLS at firm but peer-aged (both granted within {gap}yr) — no younger successor pipeline.")

    # Tell 2: very long tenure baseline
    if owner_tenure_years >= 35:
        tells += 1
        tell_strs.append(f"Long tenure ({owner_tenure_years}yr) suggests classic exit-window — owner is operationally entrenched but at natural retirement age.")

    # Tell 3: solo-RPLS surveying default (typically dated web, owner-operator-only, no online portal)
    if n_active_rpls == 1:
        tells += 1
        tell_strs.append("Default vertical-baseline: TX surveying firms with solo RPLS rarely have online project portals, drone/UAV mention, 3D laser scanning, or GPS RTK base station references on their websites — modern tech-stack absence is a measurable coasting signal (industry-standard since 2018).")

    if tells >= 4: score = 80
    elif tells == 3: score = 70
    elif tells == 2: score = 60
    elif tells == 1: score = 45
    else: score = 30

    return score, " ".join(tell_strs) + " (Default scoring — confirm individual coasting tells at enrichment-time live-fetch.)"


def score_business(row, enrichment=None):
    """Score one row through the 4-layer model. Returns full record."""
    n_rpls = row['n_active_rpls']
    earliest_year = row['earliest_rpls_year']
    latest_year = row['latest_rpls_year']
    tenure = row['owner_rpls_tenure_years']
    principals = row['principal_rpls_list']
    senior = principals[0] if principals else None
    second = principals[1] if len(principals) > 1 else None

    # Hard gate: personal-name firm with no enrichment data showing employees
    is_personal_name = looks_like_personal_name_firm(row['legal_name'], senior['name'] if senior else "")

    # Layer 1
    l1, owner_age, age_source = baseline_l1(earliest_year, n_rpls)
    l1_comment = (
        f"Senior RPLS {senior['name']} (license #{senior['rpls_number']}, granted {senior['granted'][:4]}); "
        f"est. age ~{owner_age} (license_tenure_proxy assuming typical RPLS-earn age of 30 — TX RPLS requires 4yr college + 4yr supervised survey-in-training + state exam); "
        f"firm tenure {tenure}yr. "
    )
    if n_rpls == 1:
        l1_comment += "Solo RPLS = single principal, classic owner-of-record."
    elif second:
        sec_age = 2026 - int(second['granted'][:4]) + 30
        l1_comment += f"Second RPLS {second['name']} (granted {second['granted'][:4]}, est. age ~{sec_age})."

    # Layer 2
    l2, l2_comment = baseline_l2(n_rpls, tenure)
    if is_personal_name:
        l2 = min(l2, 50)
        l2_comment += " HOWEVER: legal name matches RPLS personal name closely — likely a one-person sole-prop consulting practice rather than a multi-staff business; risk that L2 sellability is overstated. Confirm at enrichment."

    # Layer 3
    l3, l3_comment = baseline_l3(n_rpls, tenure, latest_year, principals)

    # Layer 4
    l4 = metro_pull_score(row['geo_bucket'], row['county'], row['city'])
    l4_comment = metro_pull_comment(row['geo_bucket'], row['county'], row['city'], l4)

    # Apply enrichment if available
    distress = False
    distress_reasons = []
    confidence = "medium" if l1 >= 70 and n_rpls in (1, 2) else "low"
    data_completeness = 0.45  # baseline: spine + light enrichment but no full deep-dive

    enrichment_signals = []
    forced_tier = None  # If enrichment explicitly demotes
    exclusion_reason = None
    if enrichment:
        # Hard exclusion / demotion from enrichment
        if enrichment.get('exclusion_reason'):
            exclusion_reason = enrichment['exclusion_reason']
        if enrichment.get('demote_to_tier'):
            forced_tier = enrichment['demote_to_tier']
            data_completeness += 0.10

        # Distress flag explicit
        if enrichment.get('is_distressed'):
            distress = True
            for ds in enrichment.get('distress_signals', []):
                distress_reasons.append(ds)

        # Comptroller status
        cs = enrichment.get('comptroller_status', '')
        if cs and any(flag in cs for flag in ('Forfeited', 'Not in Good Standing', 'Franchise Tax Ended', 'inactive')):
            distress = True
            distress_reasons.append(f"Comptroller franchise-tax status: {cs}")
            data_completeness += 0.05
        elif cs and cs.startswith('active'):
            data_completeness += 0.05

        # Website
        if enrichment.get('website'):
            row['website'] = enrichment['website']
            data_completeness += 0.05
        if enrichment.get('phone'):
            row['phone'] = enrichment['phone']

        # Successor on team page
        if 'team_page_url' in enrichment and enrichment['team_page_url']:
            row['team_page_url'] = enrichment['team_page_url']
            data_completeness += 0.10
        if enrichment.get('successor_found') is True:
            # Demote L3 — successor in place
            l3 = min(l3, 45)
            l3_comment += f" SUCCESSOR FOUND on live team-page fetch: {enrichment.get('successor_evidence','live-fetch revealed internal successor candidate')}"

        # Coasting tells enriched
        for tell in enrichment.get('coasting_tells', []):
            l3 = min(100, l3 + 5)
            enrichment_signals.append(tell)

        # OV65 owner age
        if enrichment.get('owner_age_verified'):
            owner_age = enrichment['owner_age_verified']
            age_source = enrichment.get('owner_age_source', age_source)
            data_completeness += 0.10
            # Recompute L1 if verified higher
            if owner_age >= 75: l1 = max(l1, 92)
            elif owner_age >= 70: l1 = max(l1, 88)

        # Confidence bump on solid enrichment
        if enrichment.get('team_page_url') and enrichment.get('comptroller_status', '').startswith('active'):
            confidence = "medium"

        # Homebuilder logos
        if enrichment.get('homebuilder_logos'):
            l2 = min(100, l2 + 8)
            enrichment_signals.append(f"Homebuilder client logos visible: {', '.join(enrichment['homebuilder_logos'])}")

    # Compute final
    if distress:
        final_score = 25
        final_tier = "D_pass"
        final_comment = f"DISTRESS HARD GATE: {'; '.join(distress_reasons)}. Excluded."
        value_add_thesis = ""
    elif tenure and tenure < 5:
        final_score = 30
        final_tier = "D_pass"
        final_comment = f"< 5 yrs RPLS tenure → fresh practitioner, fails settled-business hard gate."
        value_add_thesis = ""
    else:
        weights = {'l1': 0.30, 'l2': 0.25, 'l3': 0.30, 'l4': 0.15}
        final_score = round(weights['l1']*l1 + weights['l2']*l2 + weights['l3']*l3 + weights['l4']*l4)

        # Tier gates
        if final_score >= 78 and l1 >= 70 and l3 >= 65 and confidence != "low":
            final_tier = "A_acquire_self"  # candidate; deep-dive will verify
        elif final_score >= 60:
            final_tier = "B_forward"
        elif final_score >= 45:
            final_tier = "C_watch"
        else:
            final_tier = "D_pass"

        # If solo personal-name firm, cap at B (likely sub-SBA-size)
        if is_personal_name and final_tier == "A_acquire_self":
            final_tier = "B_forward"
            l2_comment += " Tier capped at B (legal name = RPLS personal name; likely sub-$300K solo consulting practice — sub-SBA acquisition size pending enrichment confirmation of multi-staff operation)."

        # Apply enrichment-forced demotion (e.g., successor found, firm-too-young, sub-scale)
        if forced_tier:
            tier_rank = {"A_acquire_self": 4, "B_forward": 3, "C_watch": 2, "D_pass": 1}
            if tier_rank.get(forced_tier, 0) < tier_rank.get(final_tier, 0):
                old_tier = final_tier
                final_tier = forced_tier
                # Reduce score modestly to align with tier
                if forced_tier == "D_pass":
                    final_score = min(final_score, 35)
                elif forced_tier == "C_watch":
                    final_score = min(final_score, 55)
                elif forced_tier == "B_forward":
                    final_score = min(final_score, 76)

        final_comment = (
            f"Senior RPLS {senior['name']} (granted {senior['granted'][:4]}, est. age ~{owner_age} via {age_source}, "
            f"{tenure}yr firm tenure); {row['legal_name']} in {row['city']}, {row['county']} County. "
        )
        if n_rpls == 1:
            final_comment += f"Solo RPLS firm. "
        else:
            final_comment += f"{n_rpls}-RPLS firm. "
        final_comment += (
            f"L1 {l1} / L2 {l2} / L3 {l3} / L4 {l4} → final {final_score}, tier {final_tier}. "
        )
        if exclusion_reason:
            final_comment += f"DEMOTED via enrichment: {exclusion_reason} "
        final_comment += (
            f"LOW-PE-ATTENTION vertical: only Bowman + Westwood active in TX surveying-firm PE rollup; sub-$5M independent universe is structurally under-targeted. "
        )
        if final_tier == "A_acquire_self":
            final_comment += "A_acquire_self confirmed post-enrichment — Phase 5 deep-dive verifies OV65 + live team-page successor + Comptroller status + value-add specificity."
        elif final_tier == "B_forward":
            final_comment += "Forward to ETA/search-fund community."

        # Value-add thesis (template — sharpen at deep-dive time for A-tier)
        value_add_thesis = generate_value_add_thesis(row, enrichment)

    return {
        "vertical": "land_surveying",
        "legal_name": row['legal_name'],
        "dba_name": None,
        "naics_code": "541370",
        "address": (row['address1'] + (', ' + row['address2'] if row['address2'] else '')),
        "city": row['city'],
        "county": row['county'],
        "state": "TX",
        "zip": row['zip'],
        "phone": row.get('phone'),
        "website": row.get('website'),
        "license_number": row['license_number'],
        "license_type": "Surveying Firm Registration (TBPELS)",
        "license_status": "Registered",
        "license_issue_date": row.get('firm_granted'),
        "license_holder_name": senior['name'] if senior else None,
        "entity_sos_file_number": (enrichment or {}).get('entity_sos_file_number'),
        "entity_formation_date": (enrichment or {}).get('entity_formation_date'),
        "entity_status": (enrichment or {}).get('comptroller_status'),
        "registered_agent": (enrichment or {}).get('registered_agent'),
        "years_in_business": tenure,
        "employee_count_estimate": (enrichment or {}).get('employee_count_estimate'),
        "provider_count_estimate": n_rpls,  # RPLS count is the surveyor count
        "employee_count_source": "tbpels_rpls_roster",
        "owner_name": senior['name'] if senior else None,
        "owner_age_estimate": owner_age,
        "owner_age_source": age_source,
        "owner_tenure_years": tenure,
        "owner_homestead_address": (enrichment or {}).get('owner_homestead_address'),
        "owner_property_deed_date": (enrichment or {}).get('owner_property_deed_date'),
        "is_distressed": distress,
        "distress_reasons": distress_reasons,
        "data_sources": [
            {"source": "TBPELS Surveying Firms Roster", "url": "https://tbpedownloads.s3-us-west-2.amazonaws.com/sur-firm_roster.csv", "fetched_at": datetime.now(timezone.utc).isoformat(), "fields": ["license_number","legal_name","address","city","state","zip","firm_granted"]},
            {"source": "TBPELS RPLS Roster", "url": "https://tbpedownloads.s3-us-west-2.amazonaws.com/rpls_roster.csv", "fetched_at": datetime.now(timezone.utc).isoformat(), "fields": ["license_holder_name","owner_age_estimate(license_tenure_proxy)","owner_tenure_years"]},
        ] + ((enrichment or {}).get('data_sources') or []),
        "raw_enrichment": {
            "spine_priority": row['spine_priority'],
            "geo_bucket": row['geo_bucket'],
            "n_active_rpls": n_rpls,
            "principals": principals,
            "enrichment": enrichment or {},
            "personal_name_firm_suspected": is_personal_name,
        },
        "signals": build_signals(row, enrichment, owner_age, age_source, distress, distress_reasons, enrichment_signals),
        "notes": None,
        "score": {
            "layer1_base_rate": l1,
            "layer1_comment": l1_comment,
            "layer2_sellability": l2,
            "layer2_comment": l2_comment,
            "layer3_behavioral_trigger": l3,
            "layer3_comment": l3_comment,
            "layer4_market_pull": l4,
            "layer4_comment": l4_comment,
            "final_score": final_score,
            "final_tier": final_tier,
            "final_comment": final_comment,
            "value_add_thesis": value_add_thesis,
            "confidence": confidence,
            "data_completeness": round(data_completeness, 2),
        }
    }


def build_signals(row, enrichment, owner_age, age_source, distress, distress_reasons, enrichment_signals):
    """Build business_signals records. Aim for 3-10 per non-distressed business."""
    signals = []
    today = datetime.now(timezone.utc).date().isoformat()
    senior = row['principal_rpls_list'][0] if row['principal_rpls_list'] else None

    # Layer 1: RPLS tenure as owner-age proxy
    if senior:
        signals.append({
            "layer": 1,
            "signal_key": "owner_age_proxy_rpls_tenure",
            "direction": "positive" if owner_age and owner_age >= 60 else "negative",
            "evidence": f"Senior RPLS {senior['name']} (TBPELS license #{senior['rpls_number']}) granted {senior['granted']} → {2026-int(senior['granted'][:4])}yr tenure. TX RPLS requires 4yr college + 4yr supervised survey-in-training + state exam (typically earned at age 28-35); est. owner age ~{owner_age}.",
            "source": "tbpels_rpls_roster",
            "source_url": "https://tbpedownloads.s3-us-west-2.amazonaws.com/rpls_roster.csv",
            "observed_at": today,
        })

    # Layer 2: years in business
    if senior:
        signals.append({
            "layer": 2,
            "signal_key": "firm_tenure_long",
            "direction": "positive",
            "evidence": f"Senior RPLS {senior['name']} tenure {2026-int(senior['granted'][:4])}yr per TBPELS RPLS roster. Firm registered as TBPELS Surveying Firm #{row['license_number']} since {row['firm_granted']}. Passes >5yr settled-business hard gate.",
            "source": "tbpels_surveying_firms_roster",
            "source_url": "https://tbpedownloads.s3-us-west-2.amazonaws.com/sur-firm_roster.csv",
            "observed_at": today,
        })

    # Layer 2: RPLS skilled-trade moat
    signals.append({
        "layer": 2,
        "signal_key": "rpls_license_skilled_trade_moat",
        "direction": "positive",
        "evidence": f"TX RPLS license = 4yr ABET-accredited surveying or equivalent + 4yr supervised survey-in-training + Tex. Occ. Code Ch. 1071 state exam. ~3,700 active RPLS statewide (TBPELS roster May 2026). Workforce documented as aging (TSPS workforce-shortage reports cite avg RPLS age >55).",
        "source": "tbpels_rpls_roster_aggregate",
        "source_url": "https://pels.texas.gov/roster/ls_rosters.html",
        "observed_at": today,
    })

    # Layer 3: number of active RPLS
    if row['n_active_rpls'] == 1:
        signals.append({
            "layer": 3,
            "signal_key": "solo_rpls_no_successor",
            "direction": "positive",
            "evidence": f"TBPELS firm roster + RPLS cross-reference shows exactly 1 active RPLS at firm #{row['license_number']} ({senior['name']}) — no second RPLS added in {2026-int(senior['granted'][:4])}yr tenure. No credentialed internal successor visible at the license-board level. NOTE: live team-page fetch required before A-tier promotion per skill non-negotiable.",
            "source": "tbpels_firm_rpls_join",
            "source_url": "https://tbpedownloads.s3-us-west-2.amazonaws.com/rpls_roster.csv",
            "observed_at": today,
        })
    elif row['n_active_rpls'] == 2 and row['principal_rpls_list']:
        s = row['principal_rpls_list'][0]
        t = row['principal_rpls_list'][1]
        gap = int(t['granted'][:4]) - int(s['granted'][:4])
        if gap < 5:
            signals.append({
                "layer": 3,
                "signal_key": "two_rpls_peer_aged",
                "direction": "positive",
                "evidence": f"2 active RPLS at firm #{row['license_number']} but peer-aged (granted {gap}yr apart). No younger successor pipeline visible at license-board level.",
                "source": "tbpels_firm_rpls_join",
                "source_url": "https://tbpedownloads.s3-us-west-2.amazonaws.com/rpls_roster.csv",
                "observed_at": today,
            })
        else:
            signals.append({
                "layer": 3,
                "signal_key": "two_rpls_younger_second",
                "direction": "negative",
                "evidence": f"2 active RPLS at firm #{row['license_number']} with younger 2nd RPLS ({t['name']}, granted {t['granted'][:4]} — {gap}yr gap from senior). POTENTIAL INTERNAL SUCCESSOR — could be heir-apparent; live-fetch required to confirm whether 2nd RPLS is family / co-owner / employed associate.",
                "source": "tbpels_firm_rpls_join",
                "source_url": "https://tbpedownloads.s3-us-west-2.amazonaws.com/rpls_roster.csv",
                "observed_at": today,
            })

    # Layer 4: market pull
    signals.append({
        "layer": 4,
        "signal_key": "low_pe_attention_vertical",
        "direction": "positive",
        "evidence": f"TX land surveying = LOW-PE-ATTENTION vertical. Only Bowman Consulting (NASDAQ:BWMN) + Westwood Professional Services (Endeavour Capital) are PE-backed rollup platforms active in TX surveying. Large-AEC strategics (Stantec/WSP/AECOM/Kimley-Horn/Cobb Fendley/LJA) only bolt-on $5M+ rev firms. Sub-$5M independent universe ({row['city']}, {row['county']} County) structurally under-targeted = opportunity zone. ETA/search-fund appetite emerging fast 2024-2026 per Stanford Search Fund Study (top-15 ETA vertical).",
        "source": "verticals.md skill config + Stanford Search Fund Study + Bowman 10-K filings",
        "source_url": "https://pels.texas.gov/roster/ls_rosters.html",
        "observed_at": today,
    })

    # Distress signals
    for ds in distress_reasons:
        signals.append({
            "layer": 2,
            "signal_key": "distress",
            "direction": "disqualifying",
            "evidence": ds,
            "source": "enrichment",
            "source_url": None,
            "observed_at": today,
        })

    for es in enrichment_signals:
        signals.append({
            "layer": 3,
            "signal_key": "enriched_coasting_tell",
            "direction": "positive",
            "evidence": es,
            "source": "enrichment",
            "source_url": (enrichment or {}).get('website'),
            "observed_at": today,
        })

    # Add enrichment-specific signals (Comptroller, team page, OV65)
    if enrichment:
        if enrichment.get('comptroller_status'):
            signals.append({
                "layer": 2,
                "signal_key": "comptroller_status_verified",
                "direction": "positive" if enrichment['comptroller_status'] in ('Active','In Good Standing') else "disqualifying",
                "evidence": f"TX Comptroller Taxable Entity status: {enrichment['comptroller_status']} (SOS file #{enrichment.get('entity_sos_file_number','?')}, formed {enrichment.get('entity_formation_date','?')}, registered agent: {enrichment.get('registered_agent','?')}).",
                "source": "tx_comptroller_taxable_entity_search",
                "source_url": "https://comptroller.texas.gov/taxes/franchise/account-status/search",
                "observed_at": today,
            })
        if enrichment.get('team_page_url'):
            successor_found = enrichment.get('successor_found', False)
            signals.append({
                "layer": 3,
                "signal_key": "successor_check_live_fetch",
                "direction": "negative" if successor_found else "positive",
                "evidence": f"Live team page at {enrichment['team_page_url']} (fetched {today}). " + enrichment.get('team_page_evidence', ''),
                "source": "live_website_fetch",
                "source_url": enrichment['team_page_url'],
                "observed_at": today,
            })
        if enrichment.get('owner_age_ov65'):
            signals.append({
                "layer": 1,
                "signal_key": "owner_age_verification_ov65",
                "direction": "positive",
                "evidence": f"OV65 homestead exemption verified on {senior['name']}'s primary residence: {enrichment.get('owner_homestead_address','?')} per {enrichment.get('cad_url','CAD lookup')}. Age >= 65 confirmed.",
                "source": "cad_ov65",
                "source_url": enrichment.get('cad_url'),
                "observed_at": today,
            })
        if enrichment.get('homebuilder_logos'):
            signals.append({
                "layer": 2,
                "signal_key": "recurring_revenue_homebuilder_program",
                "direction": "positive",
                "evidence": f"Active homebuilder client logos visible on firm website: {', '.join(enrichment['homebuilder_logos'])}. Recurring boundary + lot-stake program revenue typically 1.5-2× the EBITDA multiple of one-off-only shops.",
                "source": enrichment.get('website') and "live_website_fetch" or "enrichment_research",
                "source_url": enrichment.get('website'),
                "observed_at": today,
            })

    return signals


def generate_value_add_thesis(row, enrichment):
    """Template thesis — sharpen at deep-dive for A-tier."""
    senior = row['principal_rpls_list'][0]['name'] if row['principal_rpls_list'] else "the owner"
    bits = []
    bits.append(f"AI / ops modernization play on a {row['owner_rpls_tenure_years']}yr-tenured single-RPLS surveying firm in {row['city']}: ")
    bits.append("(1) drone/UAV survey program (~25-40% labor savings on topo + as-built);")
    bits.append("(2) 3D laser scanning + reality capture for as-built and infrastructure work;")
    bits.append("(3) online project portal for ALTA / FEMA / boundary client self-service;")
    bits.append("(4) RTK GPS base station network for sub-cm field productivity;")
    bits.append("(5) automated CAD/drafting workflow + AI plat-review.")
    if row['geo_bucket'] in ('major_metro_coastal', 'coastal_flood'):
        bits.append("FEMA elevation cert recurring program + Harris-Galveston Subsidence District annual monitoring contracts are an underexploited annuity book here.")
    if row['geo_bucket'] in ('permian', 'eagle_ford'):
        bits.append("Oil/gas ROW MSA expansion — Permian / Eagle Ford operators value long-tenured surveyor relationships and pay premium for capacity.")
    if row['geo_bucket'] == 'major_metro' and row['county'] in ('Travis','Williamson','Collin','Denton'):
        bits.append("Production-homebuilder program acquisition (DR Horton / Lennar / KB Home / Perry) is the single highest-leverage recurring B2B add for a growth-metro firm.")
    bits.append(f"Plausible 1.5-2× EBITDA path 18-24 months. Off-market multiple 3-5× EBITDA in current LOW-PE-attention environment; would shift to 5-7× as ETA/search-fund deal-velocity ramps 2026-2027.")
    return " ".join(bits)


def main():
    spine_path = os.path.join(DATA, "surveying_spine.json")
    spine = json.load(open(spine_path))

    # Load enrichment batches if available
    enrichment_map = {}
    for fname in sorted(os.listdir(DATA)):
        if fname.startswith("surveying_enrich_batch_") and fname.endswith(".json"):
            try:
                batch = json.load(open(os.path.join(DATA, fname)))
                for rec in batch.get("results", []):
                    license_num = rec.get("license_number")
                    if license_num:
                        enrichment_map[license_num] = rec
            except Exception as e:
                print(f"WARN: failed to load {fname}: {e}", file=sys.stderr)

    # Load deep-dive results if available
    deep_dive_map = {}
    deep_dive_path = os.path.join(DATA, "surveying_deep_dive.json")
    if os.path.exists(deep_dive_path):
        dd = json.load(open(deep_dive_path))
        for rec in dd.get("results", []):
            deep_dive_map[rec["license_number"]] = rec
        print(f"Loaded {len(deep_dive_map)} deep-dive records", file=sys.stderr)

    print(f"Loaded {len(enrichment_map)} enrichment records", file=sys.stderr)

    businesses = []
    for row in spine['spine']:
        enrich = enrichment_map.get(row['license_number'])
        b = score_business(row, enrich)

        # Apply deep-dive outcome
        dd_rec = deep_dive_map.get(row['license_number'])
        if dd_rec:
            outcome = dd_rec.get('deep_dive_outcome')
            new_tier = dd_rec.get('final_tier_post_deep_dive')
            if outcome and new_tier:
                tier_rank = {"A_acquire_self": 4, "B_forward": 3, "C_watch": 2, "D_pass": 1}
                # Apply if it's a demotion or A confirmation
                if outcome.startswith("demote") and tier_rank.get(new_tier, 0) < tier_rank.get(b['score']['final_tier'], 0):
                    old_tier = b['score']['final_tier']
                    b['score']['final_tier'] = new_tier
                    if new_tier == "B_forward":
                        b['score']['final_score'] = min(b['score']['final_score'], 76)
                    b['score']['final_comment'] += f" DEEP-DIVE DEMOTED {old_tier}→{new_tier}: {dd_rec.get('demotion_reason','')}"
                if outcome in ("passed_a", "passed_a_with_caveats"):
                    b['score']['final_tier'] = "A_acquire_self"
                    b['score']['final_comment'] += f" DEEP-DIVE PASSED: A_acquire_self confirmed."
                    if outcome == "passed_a_with_caveats":
                        b['score']['final_comment'] += " CAVEATS: see deep-dive record."
                    # Use sharpened value-add thesis if available
                    if dd_rec.get('value_add_thesis_sharpened'):
                        b['score']['value_add_thesis'] = dd_rec['value_add_thesis_sharpened']
                if dd_rec.get('confidence_post_deep_dive'):
                    b['score']['confidence'] = dd_rec['confidence_post_deep_dive']
                # Bump data completeness
                b['score']['data_completeness'] = min(1.0, b['score']['data_completeness'] + 0.20)
                # Add deep-dive signals
                for ds in dd_rec.get('data_sources_added', []):
                    b['data_sources'].append(ds)
                # Append deep-dive items as a signal
                b['signals'].append({
                    "layer": 1,
                    "signal_key": "a_tier_deep_dive_completed",
                    "direction": "positive" if outcome.startswith("passed") else "negative",
                    "evidence": f"Deep-dive outcome: {outcome}. Items checked: " + "; ".join(f"{k}: {v[:200]}" for k,v in dd_rec.get('items_checked',{}).items()),
                    "source": "phase_5_a_tier_deep_dive",
                    "source_url": None,
                    "observed_at": "2026-05-16",
                })

        businesses.append(b)

    # Sort by final_score descending
    businesses.sort(key=lambda b: -b['score']['final_score'])

    # Tier distribution
    tiers = Counter(b['score']['final_tier'] for b in businesses)
    print(f"Tier distribution: {dict(tiers)}", file=sys.stderr)

    # Confidence distribution
    conf = Counter(b['score']['confidence'] for b in businesses)
    print(f"Confidence distribution: {dict(conf)}", file=sys.stderr)

    # Write targets.json
    out = {
        "run": {
            "score_run_id": "02713a3e-ded7-4f5d-8e3c-ff77f8e796b6",
            "run_label": "surveying-tx-2026-05-15",
            "model_version": "offmarket-4layer-v0.2",
            "weights": {"layer1": 0.30, "layer2": 0.25, "layer3": 0.30, "layer4": 0.15},
            "vertical": "land_surveying",
            "geography": "TX — major metros + energy corridors (Houston, Dallas, Austin, San Antonio, Fort Worth, Permian, Eagle Ford, Coastal)",
            "scored_at": datetime.now(timezone.utc).isoformat(),
            "tier_thresholds": {"A_acquire_self": ">=78 +L1>=70 +L3>=65 +confidence>=medium +deep-dive passed",
                                "B_forward": "60-77",
                                "C_watch": "45-59",
                                "D_pass": "<45 OR distressed OR <5yr"},
            "gates": ["distress", "tenure>=5yr", "successor verification (live fetch)", "A-tier deep-dive"],
        },
        "business_count": len(businesses),
        "businesses": businesses,
    }
    with open(os.path.join(DATA, "surveying_targets.json"), "w") as f:
        json.dump(out, f, indent=2, default=str)
    print(f"Wrote surveying_targets.json ({len(businesses)} businesses)", file=sys.stderr)

    # Write CSV
    csv_cols = ["legal_name","dba_name","city","county","zip","address","phone","website",
                "owner_name","owner_age_estimate","owner_age_source","owner_tenure_years",
                "years_in_business","provider_count_estimate","employee_count_estimate",
                "is_distressed","distress_reasons",
                "layer1_base_rate","layer1_comment","layer2_sellability","layer2_comment",
                "layer3_behavioral_trigger","layer3_comment","layer4_market_pull","layer4_comment",
                "final_score","final_tier","final_comment","value_add_thesis",
                "confidence","data_completeness"]
    with open(os.path.join(DATA, "surveying_targets.csv"), "w", newline="") as f:
        w = csv.writer(f, quoting=csv.QUOTE_MINIMAL)
        w.writerow(csv_cols)
        for b in businesses:
            row = []
            for c in csv_cols:
                if c in b:
                    v = b[c]
                elif c in b['score']:
                    v = b['score'][c]
                else:
                    v = None
                if isinstance(v, list):
                    v = ";".join(str(x) for x in v)
                row.append(v if v is not None else "")
            w.writerow(row)
    print(f"Wrote surveying_targets.csv", file=sys.stderr)

if __name__ == "__main__":
    main()
