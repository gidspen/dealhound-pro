"""End-to-end runner for the RV park lead pipeline.

Spine source: real TX Hill Country RV parks pulled via WebSearch
(see real_spine.py). Each park has a verified address + phone +
ownership info where available.

Signals:
  - Conversion fitness — computed from real spine fields + geo
  - Motivation — limited to what's verifiable from web search alone
    (LLC formed year proxy for ownership age). Other motivation signals
    are explicitly tracked as "pending v1.1 local enrichment."

Run from repo root:
  python -m offmarket.rv_parks.run
"""
from __future__ import annotations

import json
import sys
from dataclasses import asdict
from pathlib import Path

# Ensure repo root is importable when run as a script
_REPO_ROOT = Path(__file__).resolve().parent.parent.parent
if str(_REPO_ROOT) not in sys.path:
    sys.path.insert(0, str(_REPO_ROOT))

from offmarket.rv_parks.enrich import (
    conversion_signals_from_real_data,
    motivation_signals_from_real_data,
)
from offmarket.rv_parks.real_spine import TX_HILL_COUNTRY_RV_PARKS_2026_05_18
from offmarket.rv_parks.score import score_lead


DEFAULT_BUY_BOX = {
    "states": ["TX"],
    "asset_types": ["rv_park", "campground"],
    "pad_count_min": 15,
    "pad_count_max": 100,
    "acreage_min": 4,
    "acreage_max": 100,
    "tourism_corridor_required": False,
    "exclude_chains": False,
    "strategy": "rv_park_to_micro_resort_conversion",
}


def passes_buy_box(park: dict, conv_signals, buy_box) -> tuple[bool, list[str]]:
    """Return (passes, list_of_match_summary_strings).

    Unknown fields don't fail the buy box — they're surfaced as
    "needs verification" so users can decide to chase the lead
    or wait for v1.1 CAD enrichment.
    """
    reasons: list[str] = []
    fails: list[str] = []

    state = park.get("state", "")
    if state not in buy_box["states"]:
        fails.append(f"state {state} not in {buy_box['states']}")
    else:
        reasons.append("state TX ✓")

    pad = park.get("pad_count")
    if pad is None:
        reasons.append("pad count: pending verification")
    elif buy_box["pad_count_min"] <= pad <= buy_box["pad_count_max"]:
        reasons.append(f"{pad} pads in target range")
    else:
        fails.append(f"pad count {pad} outside {buy_box['pad_count_min']}-{buy_box['pad_count_max']}")

    acre = conv_signals.acreage
    if acre is None:
        reasons.append("acreage: pending verification")
    elif buy_box["acreage_min"] <= acre <= buy_box["acreage_max"]:
        reasons.append(f"~{acre} acres in target range (est. from pad count)")
    else:
        fails.append(f"acreage {acre} outside {buy_box['acreage_min']}-{buy_box['acreage_max']}")

    if buy_box.get("exclude_chains") and park.get("is_chain"):
        fails.append(f"chain franchise ({park.get('chain_name')})")
    elif not park.get("is_chain"):
        reasons.append("independent operator ✓")

    return (len(fails) == 0, reasons + ([f"× {f}" for f in fails] if fails else []))


def run(out_path: Path, buy_box: dict = None) -> dict:
    buy_box = buy_box or DEFAULT_BUY_BOX

    spine = TX_HILL_COUNTRY_RV_PARKS_2026_05_18
    leads = []
    discarded = []

    for park in spine:
        conv = conversion_signals_from_real_data(park)
        mot, unknown_motivation = motivation_signals_from_real_data(park)

        passes, match_summary = passes_buy_box(park, conv, buy_box)
        scored = score_lead(mot, conv)

        record = {
            "name": park["name"],
            "address": park.get("address"),
            "city": park.get("city"),
            "state": park.get("state"),
            "zip": park.get("zip"),
            "lat": park.get("lat"),
            "lon": park.get("lon"),
            "phone": park.get("phone"),
            "website": park.get("website"),
            "source": park.get("source"),
            "source_urls": park.get("source_urls", []),
            "is_chain": park.get("is_chain"),
            "chain_name": park.get("chain_name"),
            "pad_count": park.get("pad_count"),
            "amenities": park.get("amenities", []),
            "verified_llc_name": park.get("verified_llc_name"),
            "verified_llc_formed_year": park.get("verified_llc_formed_year"),
            "verified_principal_name": park.get("verified_principal_name"),
            "buy_box_match": match_summary,
            "buy_box_passes": passes,
            "pending_motivation_enrichment": unknown_motivation,
            **scored,
        }

        if passes and scored["tier"] != "DISCARD":
            leads.append(record)
        else:
            discarded.append(record)

    # Sort: HOT > STRONG > WATCH; within tier by combined score
    tier_rank = {"HOT": 0, "STRONG": 1, "WATCH": 2, "DISCARD": 3}
    leads.sort(key=lambda r: (
        tier_rank[r["tier"]],
        -(r["motivation_score"] + r["conversion_fitness_score"]),
    ))

    out = {
        "buy_box": buy_box,
        "summary": {
            "spine_total": len(spine),
            "spine_source": "real_web_search_2026_05_18",
            "buy_box_passes": len(leads) + sum(1 for d in discarded if d["buy_box_passes"]),
            "scored_in_pipeline": len(leads),
            "tier_counts": {
                t: sum(1 for r in leads if r["tier"] == t) for t in ("HOT", "STRONG", "WATCH")
            },
            "enrichment_note": (
                "Motivation signals limited to LLC formed year (proxy for ownership "
                "age) from public web search. CAD owner-of-record, probate, tax "
                "delinquency, OV65, out-of-state, and inherited-deed signals require "
                "v1.1 local enrichment from a residential IP or properly allowlisted "
                "environment."
            ),
        },
        "leads": leads,
        "discarded": discarded,
    }
    out_path.write_text(json.dumps(out, indent=2, default=str))
    return out


def print_summary(result: dict) -> None:
    print("=" * 72)
    print("RV PARKS POC — REAL DATA RUN")
    print("=" * 72)
    s = result["summary"]
    print(f"Spine:             {s['spine_total']} real TX parks ({s['spine_source']})")
    print(f"Passed buy box:    {s['buy_box_passes']}")
    print(f"In pipeline:       {s['scored_in_pipeline']}")
    print(f"  HOT:    {s['tier_counts']['HOT']}")
    print(f"  STRONG: {s['tier_counts']['STRONG']}")
    print(f"  WATCH:  {s['tier_counts']['WATCH']}")
    print()
    print("LEADS")
    print("-" * 72)
    for lead in result["leads"]:
        print(f"  [{lead['tier']:6}] {lead['name']} — {lead['city']}, {lead['state']}")
        print(f"          {lead['address']}  · {lead.get('phone','no phone')}")
        print(f"          motivation={lead['motivation_score']} "
              f"conversion={lead['conversion_fitness_score']} "
              f"pads={lead.get('pad_count') or '?'}")
        corridor = lead.get("corridor", {})
        if corridor:
            print(f"          {corridor.get('primary_distance_mi','?')} mi from "
                  f"{corridor.get('primary_anchor','?')} "
                  f"({corridor.get('corridor_zone','?')})")
        if lead.get("verified_llc_formed_year"):
            print(f"          LLC: {lead['verified_llc_name']} formed "
                  f"{lead['verified_llc_formed_year']} ({lead['motivation_signals'][0]['evidence'] if lead['motivation_signals'] else 'baseline'})")
        if lead.get("pending_motivation_enrichment"):
            print(f"          pending v1.1 enrichment: "
                  f"{len(lead['pending_motivation_enrichment'])} motivation signals "
                  f"(CAD/probate/tax)")
        print()


if __name__ == "__main__":
    out_path = Path(__file__).parent / "data" / "poc_leads.json"
    result = run(out_path)
    print_summary(result)
    print(f"Wrote {out_path}")
