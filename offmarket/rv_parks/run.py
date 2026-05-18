"""End-to-end POC runner.

  1. Build spine (live scrapers if possible, curated sample fallback otherwise)
  2. Enrich each row with motivation + conversion signals
  3. Score
  4. Filter against a buy box
  5. Write ranked lead JSON
  6. Print summary

Run from repo root:
  python -m offmarket.rv_parks.run
"""
from __future__ import annotations

import json
import os
import sys
from dataclasses import asdict
from pathlib import Path

# Ensure repo root is importable when run as a script
_REPO_ROOT = Path(__file__).resolve().parent.parent.parent
if str(_REPO_ROOT) not in sys.path:
    sys.path.insert(0, str(_REPO_ROOT))

from offmarket.rv_parks.enrich import conversion_signals, mock_motivation_signals
from offmarket.rv_parks.score import score_lead
from offmarket.rv_parks.spine import build_spine


# ---------------------------------------------------------------------------
# Buy box — illustrative defaults for the conversion-thesis investor
# ---------------------------------------------------------------------------

DEFAULT_BUY_BOX = {
    "states": ["TX"],
    "asset_types": ["rv_park", "campground"],
    "pad_count_min": 15,
    "pad_count_max": 100,
    "acreage_min": 4,
    "acreage_max": 100,
    "tourism_corridor_required": False,    # if True, only Hill Country leads
    "exclude_chains": False,
    "strategy": "rv_park_to_micro_resort_conversion",
}


def passes_buy_box(spine_row, conv_signals, buy_box) -> tuple[bool, list[str]]:
    """Return (passes, list_of_match_summary_strings)."""
    reasons: list[str] = []
    fails: list[str] = []

    if spine_row.state not in buy_box["states"]:
        fails.append(f"state {spine_row.state} not in {buy_box['states']}")
    else:
        reasons.append(f"state TX ✓")

    if spine_row.pad_count is not None:
        if buy_box["pad_count_min"] <= spine_row.pad_count <= buy_box["pad_count_max"]:
            reasons.append(f"{spine_row.pad_count} pads in target range")
        else:
            fails.append(f"pad count {spine_row.pad_count} outside {buy_box['pad_count_min']}-{buy_box['pad_count_max']}")

    if conv_signals.acreage is not None:
        if buy_box["acreage_min"] <= conv_signals.acreage <= buy_box["acreage_max"]:
            reasons.append(f"~{conv_signals.acreage} acres in target range")
        else:
            fails.append(f"acreage {conv_signals.acreage} outside {buy_box['acreage_min']}-{buy_box['acreage_max']}")

    if buy_box.get("exclude_chains") and spine_row.is_chain:
        fails.append(f"chain franchise ({spine_row.chain_name})")
    elif not spine_row.is_chain:
        reasons.append("independent operator ✓")

    if buy_box.get("tourism_corridor_required"):
        # We check this after scoring since corridor is computed there
        pass

    return (len(fails) == 0, reasons + ([f"× {f}" for f in fails] if fails else []))


def run(out_path: Path, buy_box: dict = None) -> dict:
    buy_box = buy_box or DEFAULT_BUY_BOX

    spine = build_spine(
        google_places_key=os.environ.get("GOOGLE_PLACES_API_KEY"),
        use_sample_fallback=True,
    )

    leads = []
    discarded = []

    for row in spine:
        conv = conversion_signals(row)
        mot = mock_motivation_signals(row)

        passes, match_summary = passes_buy_box(row, conv, buy_box)
        scored = score_lead(mot, conv)

        record = {
            "name": row.name,
            "address": row.address,
            "city": row.city,
            "state": row.state,
            "zip": row.zip,
            "lat": row.lat,
            "lon": row.lon,
            "source": row.source,
            "is_chain": row.is_chain,
            "chain_name": row.chain_name,
            "pad_count": row.pad_count,
            "amenities": row.amenities,
            "buy_box_match": match_summary,
            "buy_box_passes": passes,
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
            "buy_box_passes": len(leads) + sum(1 for d in discarded if d["buy_box_passes"]),
            "scored_in_pipeline": len(leads),
            "tier_counts": {
                t: sum(1 for r in leads if r["tier"] == t) for t in ("HOT", "STRONG", "WATCH")
            },
        },
        "leads": leads,
        "discarded": discarded,
    }
    out_path.write_text(json.dumps(out, indent=2, default=str))
    return out


def print_summary(result: dict) -> None:
    print("=" * 70)
    print("RV PARKS POC — RUN SUMMARY")
    print("=" * 70)
    s = result["summary"]
    print(f"Spine rows:        {s['spine_total']}")
    print(f"Passed buy box:    {s['buy_box_passes']}")
    print(f"In pipeline:       {s['scored_in_pipeline']}")
    print(f"  HOT:    {s['tier_counts']['HOT']}")
    print(f"  STRONG: {s['tier_counts']['STRONG']}")
    print(f"  WATCH:  {s['tier_counts']['WATCH']}")
    print()
    print("TOP 8 LEADS")
    print("-" * 70)
    for lead in result["leads"][:8]:
        print(f"  [{lead['tier']:6}] {lead['name']} — {lead['city']}, {lead['state']}")
        print(f"          motivation={lead['motivation_score']} "
              f"conversion={lead['conversion_fitness_score']} "
              f"pads={lead['pad_count']}")
        corridor = lead.get("corridor", {})
        if corridor:
            print(f"          {corridor.get('primary_distance_mi','?')} mi from "
                  f"{corridor.get('primary_anchor','?')} "
                  f"({corridor.get('corridor_zone','?')})")
        top_sig = [s["evidence"] for s in lead["motivation_signals"][:3]]
        if top_sig:
            print(f"          motivation: {' · '.join(top_sig)}")
        print()


if __name__ == "__main__":
    out_path = Path(__file__).parent / "data" / "poc_leads.json"
    result = run(out_path)
    print_summary(result)
    print(f"Wrote {out_path}")
