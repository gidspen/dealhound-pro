"""Score all 86 pool service companies and write targets JSON+CSV.

Canonical scoring (per SCORING_INSTRUCTIONS.md + pool-service vertical config):
- Hard gates first
- Layer 1 (0.30): owner age band + tenure modifier
- Layer 2 (0.25): sellability — recurring weekly route 60-80%
- Layer 3 (0.30): coasting tells (pre-2018 site, no portal, no SMS, phone-only,
  aging fleet, owner-tech, flat reviews, no FB w/ service photos, no modern pool route SW)
- Layer 4 (0.15): hot consolidator + TX metro nudges:
  Houston +5 / DFW +3 / Austin +3 / Hill Country +3 / SA 0 / Rural -5
- Final tiers per canonical
"""

from __future__ import annotations

import csv
import json
import re
from pathlib import Path
from typing import Any

DATA_DIR = Path("/Users/gideonspencer/dealhound-pro/.claude/worktrees/laughing-yonath-843b53/offmarket/data")
B1 = DATA_DIR / "pool_service_enrich_batch_1.json"
B2 = DATA_DIR / "pool_service_enrich_batch_2.json"
OUT_JSON = DATA_DIR / "pool_service_targets.json"
OUT_CSV = DATA_DIR / "pool_service_targets.csv"

SCORE_RUN_ID = "86a837ec-2608-42b4-a576-5c030010dada"
VERTICAL = "pool_service"
NAICS = "561790"

# County → metro classification (per vertical config sub-market nudges)
HOUSTON_COUNTIES = {"Harris", "Fort Bend", "Montgomery", "Galveston", "Brazoria", "Liberty", "Waller", "Chambers"}
DFW_COUNTIES = {"Dallas", "Tarrant", "Collin", "Denton", "Rockwall", "Kaufman", "Ellis", "Johnson", "Parker", "Hood"}
AUSTIN_COUNTIES = {"Travis", "Williamson", "Hays", "Bastrop", "Caldwell"}
SAN_ANTONIO_COUNTIES = {"Bexar", "Comal", "Guadalupe", "Wilson", "Atascosa", "Medina", "Kendall"}
HILL_COUNTRY_COUNTIES = {"Comal", "Hays", "Burnet", "Blanco", "Llano", "Kendall", "Gillespie", "Kerr"}
COASTAL_COUNTIES = {"Nueces", "San Patricio", "Aransas", "Cameron", "Kleberg", "Refugio"}

# Known PE-rolled / disqualifying acquirers (per prompt + config)
EXCLUSIONS = {
    "Prime Pool Service": "PE-acquired Nov 2023 by Pool Troopers/SPS PoolCare consolidator",
    "Wade In The Water Pool Services LLC": "Recent ownership change Oct 2024 (Jeff Alloway is the BUYER, not seller)",
    "Gohlke Custom Pools, Inc.": "Top-50 national (PoolPro #7/#17), ~100 employees, 3rd-gen succession completed",
    "Hill Country Pools, Inc.": "3rd-gen handoff completed 2016 to young owner Forest Hill James (age 32)",
    "Miracle Pool Service, Inc.": "Intra-family father-son succession already executing internally",
    "Cooper Custom Pools": "Father-son in-house succession",
}


# ------------------------------ helpers ------------------------------

def _is_excluded(name: str) -> tuple[bool, str | None]:
    for excluded_name, reason in EXCLUSIONS.items():
        if excluded_name.lower() in (name or "").lower() or (name or "").lower() in excluded_name.lower():
            return True, reason
    return False, None


def _classify_market(city: str | None, county: str | None) -> tuple[int, str]:
    """Return (sub_market_nudge_points, label)."""
    county = (county or "").strip().replace(" County", "")
    city = (city or "").strip()

    # Hill Country first (overlaps SA/Austin)
    if county in HILL_COUNTRY_COUNTIES:
        # If also SA suburb (New Braunfels = Comal), Hill Country wins +3
        if city.lower() in {"new braunfels"} and county == "Comal":
            return 3, "Hill Country (Comal) — lake/pool homes nudge"
        return 3, f"Hill Country ({county}) — lake/pool homes nudge"
    if county in HOUSTON_COUNTIES:
        return 5, f"Houston metro ({county}) — pool capital nudge"
    if county in DFW_COUNTIES:
        return 3, f"DFW metro ({county})"
    if county in AUSTIN_COUNTIES:
        return 3, f"Austin metro ({county})"
    if county in SAN_ANTONIO_COUNTIES:
        return 0, f"San Antonio metro ({county})"
    if county in COASTAL_COUNTIES:
        return 0, f"Coastal TX ({county})"
    # Rural fallback
    return -5, f"Rural / non-metro ({county or 'unknown'})"


def _l4_score(metro_nudge: int) -> int:
    """Pool service is HOT consolidator vertical. Base 75 for hot vertical, apply nudge."""
    # Hot vertical × top-3 TX metro × premium → 85-95
    # Hot vertical × major TX metro → 75-85
    # Hot vertical × secondary → 65-78
    # Hot vertical × exurban/rural → 50-68
    if metro_nudge >= 5:
        base = 88  # Houston pool capital
    elif metro_nudge >= 3:
        base = 80  # DFW/Austin/Hill Country
    elif metro_nudge == 0:
        base = 70  # SA / Coastal
    else:
        base = 55  # rural
    return max(50, min(95, base))


def _l1_score(age: int | None, tenure: int | None, owner_known: bool) -> tuple[int, str]:
    """Owner natural-exit timing per canonical bands."""
    parts: list[str] = []
    if age is None:
        # No age estimate — weak proxy only. Use tenure as crude floor.
        if tenure and tenure >= 25:
            base = 50
            parts.append(f"No owner age; using {tenure}-yr tenure proxy → mid-band")
        elif tenure and tenure >= 15:
            base = 35
            parts.append(f"No owner age; only {tenure}-yr tenure as weak proxy")
        else:
            base = 22
            parts.append("No owner age + weak/no tenure → low band")
        if not owner_known:
            base -= 5
            parts.append("owner name undisclosed (-5)")
        return max(10, min(35, base)), "; ".join(parts)

    if age >= 68:
        base = 92
        parts.append(f"Age ~{age} (68+, peak natural-exit window) → 88-100 band")
    elif age >= 63:
        base = 82
        parts.append(f"Age ~{age} (63-67) → 75-90 band")
    elif age >= 58:
        base = 66
        parts.append(f"Age ~{age} (58-62) → 55-78 band")
    elif age >= 53:
        base = 46
        parts.append(f"Age ~{age} (53-57) → 35-58 band")
    else:
        base = 22
        parts.append(f"Age ~{age} (<53) → 10-35 band")

    # tenure modifier
    if tenure:
        if tenure >= 25:
            base += 4
            parts.append(f"+4 long tenure ({tenure} yrs personally running)")
        elif tenure < 10:
            base -= 6
            parts.append(f"-6 short tenure ({tenure} yrs)")

    return max(10, min(100, base)), "; ".join(parts)


def _l2_score(b: dict[str, Any], years: int | None, trucks: int | None, accounts: int | None) -> tuple[int, str]:
    """Sellability: weekly recurring route + size."""
    # If <5 yrs → ≤35 hard gate (handled separately)
    if years is not None and years < 5:
        return 30, f"<5 yrs ({years}) — hard-gate cap at 35"

    # Estimate fleet/account proxy from text if not direct
    parts: list[str] = []

    # Truck-band logic
    if trucks is not None and trucks >= 6:
        base = 84
        parts.append(f"{trucks} trucks → 6-15 multi-truck band (75-88)")
    elif trucks is not None and trucks >= 3:
        base = 76
        parts.append(f"{trucks} trucks → 3-5 truck mid-market band (70-82)")
    elif trucks is not None:
        base = 68
        parts.append(f"{trucks} trucks → solo 1-2 truck band (65-75)")
    elif accounts is not None and accounts >= 400:
        base = 84
        parts.append(f"{accounts} weekly accounts → multi-truck scale (75-88)")
    elif accounts is not None and accounts >= 200:
        base = 75
        parts.append(f"{accounts} weekly accounts → 3-5 truck implied (70-82)")
    elif accounts is not None:
        base = 67
        parts.append(f"{accounts} weekly accounts → solo route band (65-75)")
    else:
        # No size data — use years_in_business proxy
        if years is not None and years >= 25:
            base = 68
            parts.append(f"Long {years}-yr tenure → presumed solid recurring route (65-75 default)")
        elif years is not None and years >= 10:
            base = 60
            parts.append(f"{years}-yr tenure → mid-band recurring (55-72)")
        else:
            base = 50
            parts.append("No size data + short/unknown tenure → conservative mid-50s")

    # service mix nudge: residential weekly = ideal recurring
    sm = (b.get("service_mix") or "").lower()
    if sm == "residential":
        base += 3
        parts.append("+3 residential weekly route = gold-standard recurring")
    elif sm == "mixed":
        base += 1
        parts.append("+1 mixed res/commercial")

    # IPSSA member nudge (clean professional operator)
    if b.get("ipssa_member"):
        base += 3
        parts.append("+3 IPSSA member (clean professional operator)")

    # TPCL low-number license (early licensee, professional)
    tpcl = b.get("tpcl_license") or ""
    if tpcl and re.search(r"\d", tpcl):
        m = re.search(r"(\d{2,5})", tpcl)
        if m and int(m.group(1)) < 1000:
            base += 2
            parts.append(f"+2 early TPCL license ({tpcl})")

    return max(20, min(95, base)), "; ".join(parts)


def _l3_score(b: dict[str, Any]) -> tuple[int, str]:
    """Coasting tells per canonical."""
    parts: list[str] = []

    # Count coasting tells (batch 1 schema)
    tells = b.get("coasting_tells") or []
    n_tells = len(tells)

    # For batch 2 (signals), count positive Layer-3 signals
    signals = b.get("signals") or []
    pos_l3 = [s for s in signals if s.get("layer") == 3 and s.get("direction") == "positive"]
    neg_l3 = [s for s in signals if s.get("layer") == 3 and s.get("direction") == "negative"]
    # Also include Layer-1 positive signals like undisclosed owner as coasting
    pos_l1 = [s for s in signals if s.get("layer") == 1 and s.get("direction") == "positive"]

    n_pos_signals = len(pos_l3) + len([s for s in pos_l1 if "undisclosed" in (s.get("signal_key") or "") or "old" in (s.get("signal_key") or "")])

    n_total = max(n_tells, n_pos_signals)

    if n_total >= 4:
        base = 82
        parts.append(f"{n_total} coasting tells (4+ threshold → 80-100 band)")
    elif n_total >= 2:
        base = 65
        parts.append(f"{n_total} coasting tells (2-3 → 55-80 band)")
    elif n_total == 1:
        base = 42
        parts.append("1 coasting tell (30-55 band)")
    else:
        base = 20
        parts.append("No coasting tells captured (10-30 band)")

    # Penalize modern tech signals (anti-coasting)
    modern = b.get("modern_tech_signals") or []
    n_modern = len(modern)
    strong_modern_terms = {"customer portal", "app", "online booking", "instant quote", "online quote", "sms", "field routes", "pool office manager", "pool service manager", "automation", "video documentation"}
    strong_modern_hits = 0
    for s in modern:
        if any(t in (s or "").lower() for t in strong_modern_terms):
            strong_modern_hits += 1
    # Plus negative L3 signals from batch 2 (negative = anti-coasting evidence)
    neg_modern_hits = len(neg_l3)
    total_modern = strong_modern_hits + neg_modern_hits
    if total_modern >= 3:
        base -= 18
        parts.append(f"-18 heavy modernization ({total_modern} strong modern signals)")
    elif total_modern == 2:
        base -= 10
        parts.append(f"-10 moderate modernization ({total_modern} modern signals)")
    elif total_modern == 1:
        base -= 4
        parts.append("-4 light modernization (1 modern signal)")

    # Successor cap: if successor_present, downgrade L3
    succ = b.get("successor_indicators") or {}
    if succ.get("family_successor_present") or succ.get("second_gen_present"):
        base -= 8
        parts.append("-8 family/2nd-gen successor present (succession path identified)")

    return max(10, min(100, base)), "; ".join(parts)


def _confidence(b: dict[str, Any], age_known: bool, owner_known: bool, age_source: str | None) -> str:
    """Confidence per data completeness + owner-ID + age source quality."""
    dc = b.get("data_completeness") or 0
    has_owner = owner_known
    has_age = age_known
    age_source = age_source or ""
    strong_age = any(t in age_source.lower() for t in ["homestead", "ov65", "deed", "court", "obituary", "linkedin"]) if age_source else False

    if dc >= 0.65 and has_owner and has_age and strong_age:
        return "high"
    if dc >= 0.55 and has_owner and has_age:
        return "medium"
    if dc >= 0.45 and (has_owner or has_age):
        return "medium"
    return "low"


# ------------------------------ main scoring ------------------------------

def score_business(b: dict[str, Any]) -> dict[str, Any]:
    """Score one enriched record. Returns target dict matching canonical schema."""

    name = b.get("legal_name") or b.get("dba_name") or "unknown"
    city = b.get("city")
    county = b.get("county")
    state = b.get("state") or "TX"
    zip_ = b.get("zip")
    website = b.get("website")
    phone = b.get("phone")

    owner_name = b.get("owner_name")
    owner_age = b.get("owner_age_estimate")
    owner_age_source = b.get("owner_age_source")
    owner_tenure = b.get("owner_tenure_years")
    years = b.get("years_in_business")
    year_est = b.get("year_established")
    entity_status = b.get("entity_status") or "Active (presumed)"
    distressed = bool(b.get("is_distressed"))
    distress_reasons = b.get("distress_reasons") or []
    emp_est = b.get("employee_count_estimate")

    # Batch 1 extras
    trucks = b.get("estimated_truck_count")
    accounts = b.get("weekly_account_count")

    # Data completeness
    dc = b.get("data_completeness")
    if dc is None:
        # Derive
        known = sum(1 for v in [owner_name, owner_age, owner_tenure, years, year_est, trucks, accounts, website] if v)
        dc = round(known / 8.0, 2)

    # Data sources
    ds = b.get("data_sources") or []
    ds_urls: list[str] = []
    for s in ds:
        if isinstance(s, dict):
            u = s.get("url") or s.get("source")
            if u:
                ds_urls.append(u)
        elif isinstance(s, str):
            ds_urls.append(s)
    # Add any data_sources_added from batch 2
    for s in (b.get("data_sources_added") or []):
        if isinstance(s, dict):
            u = s.get("url") or s.get("source")
            if u and u not in ds_urls:
                ds_urls.append(u)
        elif isinstance(s, str) and s not in ds_urls:
            ds_urls.append(s)

    target: dict[str, Any] = {
        "legal_name": name,
        "city": city,
        "county": county,
        "state": state,
        "zip": zip_,
        "vertical": VERTICAL,
        "naics_code": NAICS,
        "website": website,
        "phone": phone,
        "license_number": b.get("license_number") or b.get("tpcl_license"),
        "license_holder_name": b.get("license_holder_name"),
        "license_issue_date": None,
        "owner_name": owner_name,
        "owner_age_estimate": owner_age,
        "owner_age_source": owner_age_source,
        "owner_tenure_years": owner_tenure,
        "years_in_business": years,
        "year_established": year_est,
        "employee_count_estimate": emp_est,
        "entity_status": entity_status,
        "is_distressed": distressed,
        "distress_reasons": distress_reasons,
        "data_sources": ds_urls,
        "score_run_id": SCORE_RUN_ID,
    }

    # ===== HARD GATES =====
    hard_gate_reason: str | None = None
    cap_tier: str | None = None
    cap_score: int | None = None

    # G0: exclusions (PE / completed succession)
    is_excl, excl_reason = _is_excluded(name)
    if is_excl:
        target.update(
            layer1_base_rate=15,
            layer1_comment=f"EXCLUDED: {excl_reason}",
            layer2_sellability=25,
            layer2_comment="EXCLUDED",
            layer3_behavioral_trigger=15,
            layer3_comment="EXCLUDED",
            layer4_market_pull=50,
            layer4_comment="EXCLUDED",
            final_score=20,
            final_tier="D_pass",
            final_comment=f"DROP — {excl_reason}. Not an off-market candidate.",
            value_add_thesis="N/A — excluded from outreach list.",
            confidence="high",
            data_completeness=dc,
            deep_dive_pending=False,
            hard_gate_reason=excl_reason,
        )
        return target

    # G1: cannot verify business is real → not applicable here (all came through spine)
    # G2: distressed → D_pass cap 25
    if distressed:
        cap_tier = "D_pass"
        cap_score = 25
        hard_gate_reason = f"distressed: {', '.join(distress_reasons) if distress_reasons else 'flagged'}"

    # G3: years < 5 → cap 35, max C_watch
    if years is not None and years < 5:
        cap_score = min(cap_score or 35, 35)
        cap_tier = cap_tier or "C_watch"
        hard_gate_reason = hard_gate_reason or f"years_in_business={years} <5 (cap 35, max C_watch)"

    # ===== LAYER SCORES =====
    age_known = owner_age is not None
    owner_known = owner_name is not None and "undisclosed" not in (owner_name or "").lower() and "(surname undisclosed" not in (owner_name or "").lower()

    l1, l1c = _l1_score(owner_age, owner_tenure or years, owner_known)
    l2, l2c = _l2_score(b, years, trucks, accounts)
    l3, l3c = _l3_score(b)

    metro_nudge, metro_label = _classify_market(city, county)
    l4_base = _l4_score(metro_nudge)
    l4 = max(40, min(95, l4_base))
    l4c = f"{metro_label}; pool service = HOT consolidator (Patriot Pool, ePoolPro, Pool Troopers/SPS PoolCare, USA Pool); SBA 7(a) financeable; ETA appetite rising."

    final = round(0.30 * l1 + 0.25 * l2 + 0.30 * l3 + 0.15 * l4)
    if cap_score is not None:
        final = min(final, cap_score)

    # ===== TIERS =====
    confidence = _confidence(b, age_known, owner_known, owner_age_source)

    # Determine tier
    if cap_tier == "D_pass":
        tier = "D_pass"
    elif cap_tier == "C_watch":
        tier = "C_watch" if final < 60 else "C_watch"  # forced cap
    elif final >= 78 and l1 >= 70 and l3 >= 65 and not distressed and confidence != "low":
        tier = "A_acquire_self"
    elif final >= 60:
        tier = "B_forward"
    elif final >= 45:
        tier = "C_watch"
    else:
        tier = "D_pass"

    # G4: confidence < medium AND would otherwise be A → cap at B_forward
    if tier == "A_acquire_self" and confidence == "low":
        tier = "B_forward"
        l4c += " | A→B cap: low confidence."

    # G5: successor not verified for A/B → cap at C
    # If "sole listed provider" implied by owner name undisclosed but tier A/B, require live-fetch evidence
    succ = b.get("successor_indicators") or {}
    succ_verified_via = (succ.get("verified_via") or "").lower()
    has_live_fetch_evidence = ("live-fetch" in succ_verified_via) or any("live-fetch" in (s.get("source") or "").lower() or "live_website_fetch" in (s.get("source") or "").lower() for s in (b.get("signals") or []))

    if tier in ("A_acquire_self", "B_forward") and not has_live_fetch_evidence and not succ_verified_via:
        tier = "C_watch"
        l3c += " | Successor check NOT verified via live-fetch → capped at C."

    # G6: A-tier deep-dive not completed → cap at B_forward (orchestrator handles)
    deep_dive_pending = False
    if tier == "A_acquire_self":
        deep_dive_pending = True
        # Per canonical: mark deep_dive_pending=true if final >=78; orchestrator handles
        # We keep tier=A_acquire_self but with deep_dive_pending flag

    # Successor present → strong demote for natural-exit (Manning son-succession, Fox Holbrook, Sun Valley 2nd gen)
    if (succ.get("family_successor_present") or succ.get("second_gen_present")) and tier == "A_acquire_self":
        tier = "B_forward"
        deep_dive_pending = False
        l1c += " | DEMOTE A→B: family/2nd-gen successor present in operations."

    # ===== Synthesis =====
    final_parts: list[str] = []
    final_parts.append(f"Score {final} ({tier}) | L1={l1} L2={l2} L3={l3} L4={l4} | Confidence={confidence} (dc={dc})")
    if hard_gate_reason:
        final_parts.append(f"Hard gate: {hard_gate_reason}.")
    if tier == "A_acquire_self":
        final_parts.append("A-tier candidate by score + gates. Deep-dive pending: confirm owner identity via Comptroller + age via CAD homestead OV65 / property deed, verify recurring-route % and no-successor.")
    elif tier == "B_forward":
        final_parts.append("Forward-quality candidate for ETA/search-fund community. Recurring weekly route, owner in retirement window OR coasting signals strong.")
    elif tier == "C_watch":
        final_parts.append("Watch — re-check in 12-24 months. Either too young, weak coasting evidence, or pending verification.")
    else:
        final_parts.append("Pass — fails core gates.")

    # Value-add thesis
    if tier in ("A_acquire_self", "B_forward"):
        v_parts = []
        v_parts.append("AI/ops levers: digital service reports (photo + chemical readings via app), automated weekly SMS service-day reminders, online customer portal, switch to FieldRoutes / Pool Office Manager (route density + autopay).")
        if trucks and trucks >= 6:
            v_parts.append(f"At {trucks} trucks ({accounts or '450+'} weekly accounts), platform-scale roll-up target for Patriot/ePoolPro/SPS PoolCare — 5-7x EBITDA exit.")
        elif accounts and accounts >= 200:
            v_parts.append(f"At ~{accounts} weekly accounts, prime SBA 7(a) ETA target — 3-5x SDE.")
        else:
            v_parts.append("Solo-route SBA 7(a) target — 3-4x SDE, 18-24 mo EBITDA uplift from 18% → 25%+ via route-density + autopay + tech app.")
        value_add = " ".join(v_parts)
    else:
        value_add = "N/A unless evidence improves."

    target.update(
        layer1_base_rate=l1,
        layer1_comment=l1c + (f" Source: {owner_age_source}" if owner_age_source else ""),
        layer2_sellability=l2,
        layer2_comment=l2c,
        layer3_behavioral_trigger=l3,
        layer3_comment=l3c,
        layer4_market_pull=l4,
        layer4_comment=l4c,
        final_score=final,
        final_tier=tier,
        final_comment=" ".join(final_parts),
        value_add_thesis=value_add,
        confidence=confidence,
        data_completeness=dc,
        deep_dive_pending=deep_dive_pending,
        hard_gate_reason=hard_gate_reason,
    )
    return target


def main() -> None:
    with open(B1) as f:
        batch1 = json.load(f)
    with open(B2) as f:
        batch2 = json.load(f)

    all_in = list(batch1) + list(batch2)
    print(f"Loaded {len(batch1)} + {len(batch2)} = {len(all_in)} pool service businesses")

    # Score incrementally and persist
    targets: list[dict[str, Any]] = []
    for i, biz in enumerate(all_in):
        scored = score_business(biz)
        targets.append(scored)
        # Persist incrementally every 20
        if (i + 1) % 20 == 0:
            with open(OUT_JSON, "w") as f:
                json.dump(targets, f, indent=2, default=str)
            print(f"  persisted {i+1}/{len(all_in)}")

    # Sort: A > B > C > D, then by final_score desc
    tier_order = {"A_acquire_self": 0, "B_forward": 1, "C_watch": 2, "D_pass": 3}
    targets.sort(key=lambda t: (tier_order.get(t["final_tier"], 9), -t["final_score"]))

    with open(OUT_JSON, "w") as f:
        json.dump(targets, f, indent=2, default=str)
    print(f"\nWrote {OUT_JSON} ({len(targets)} records)")

    # CSV (flattened)
    csv_columns = [
        "legal_name", "city", "county", "state", "zip", "vertical", "naics_code",
        "website", "phone", "license_number", "license_holder_name",
        "owner_name", "owner_age_estimate", "owner_age_source", "owner_tenure_years",
        "years_in_business", "year_established", "employee_count_estimate",
        "entity_status", "is_distressed",
        "score_run_id",
        "layer1_base_rate", "layer1_comment",
        "layer2_sellability", "layer2_comment",
        "layer3_behavioral_trigger", "layer3_comment",
        "layer4_market_pull", "layer4_comment",
        "final_score", "final_tier", "final_comment", "value_add_thesis",
        "confidence", "data_completeness", "deep_dive_pending", "hard_gate_reason",
        "data_sources",
    ]
    with open(OUT_CSV, "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(csv_columns)
        for t in targets:
            row = []
            for c in csv_columns:
                v = t.get(c)
                if isinstance(v, list):
                    v = " | ".join(str(x) for x in v)
                row.append(v if v is not None else "")
            w.writerow(row)
    print(f"Wrote {OUT_CSV} ({len(targets)} rows)")

    # Summary
    from collections import Counter
    tier_counts = Counter(t["final_tier"] for t in targets)
    print("\nTier counts:")
    for k in ["A_acquire_self", "B_forward", "C_watch", "D_pass"]:
        print(f"  {k}: {tier_counts.get(k, 0)}")

    # Top by tier
    print("\nTop A_acquire_self:")
    for t in [t for t in targets if t["final_tier"] == "A_acquire_self"][:10]:
        print(f"  {t['final_score']:3d} | {t['legal_name'][:42]:42s} | {t['city']:18s} | {(t['owner_name'] or 'unknown')[:35]}")
    print("\nTop B_forward:")
    for t in [t for t in targets if t["final_tier"] == "B_forward"][:15]:
        print(f"  {t['final_score']:3d} | {t['legal_name'][:42]:42s} | {t['city']:18s} | {(t['owner_name'] or 'unknown')[:35]}")


if __name__ == "__main__":
    main()
