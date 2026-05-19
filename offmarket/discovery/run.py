"""
CLI runner — off-market discovery pipeline.

Usage:
  python3 -m offmarket.discovery.run --buy-box path/to/buy_box.json
  python3 -m offmarket.discovery.run --buy-box buy_box.json --output data/discovered_listings.json
  python3 -m offmarket.discovery.run --buy-box buy_box.json --sources rvparkstore campgroundsforsale
  python3 -m offmarket.discovery.run --buy-box buy_box.json --dry-run

Options:
  --buy-box PATH    Path to buy_box.json (required)
  --output PATH     Output JSON file (default: data/discovered_listings.json)
  --sources SRC...  Limit to specific source IDs (default: all active matching buy-box)
  --states ST...    Override states list (e.g. TX TN NC)
  --dry-run         Run scrapers but skip Supabase write; still writes local JSON
  --no-persist      Skip Supabase entirely (same as dry-run for persistence)
  --verbose         Debug logging
"""
from __future__ import annotations

import argparse
import json
import logging
import sys
import time
from dataclasses import asdict
from datetime import datetime, timezone
from pathlib import Path

from offmarket.discovery.base import Listing
from offmarket.discovery.filter import load_buy_box, filter_listings
from offmarket.discovery.sources import sources_for_buy_box, SOURCE_BY_ID
from offmarket.discovery import loader

logger = logging.getLogger(__name__)


def build_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(description="Off-market hospitality discovery pipeline")
    p.add_argument("--buy-box", required=True, metavar="PATH", help="Buy-box JSON file")
    p.add_argument("--output", default="data/discovered_listings.json", metavar="PATH")
    p.add_argument("--sources", nargs="*", metavar="SRC", help="Limit to source IDs")
    p.add_argument("--states", nargs="*", metavar="ST", help="Override states list")
    p.add_argument("--dry-run", action="store_true", help="Skip Supabase write")
    p.add_argument("--no-persist", action="store_true", help="Skip Supabase entirely")
    p.add_argument("--verbose", action="store_true")
    return p


def run(args=None):
    p = build_parser()
    ns = p.parse_args(args)

    logging.basicConfig(
        level=logging.DEBUG if ns.verbose else logging.INFO,
        format="%(asctime)s %(levelname)s %(name)s — %(message)s",
    )

    buy_box = load_buy_box(ns.buy_box)
    asset_types = buy_box.get("asset_types", [])
    states_override = ns.states or (buy_box.get("geo") or {}).get("states")

    # Determine which sources to run
    active_sources = sources_for_buy_box(asset_types)
    if ns.sources:
        active_sources = [s for s in active_sources if s["id"] in ns.sources]

    logger.info(
        "Running discovery: %d sources, asset_types=%s, states=%s",
        len(active_sources),
        asset_types,
        states_override or "all",
    )

    all_raw: list[Listing] = []
    source_stats: dict[str, dict] = {}

    for source in active_sources:
        sid = source["id"]
        logger.info("▶ Scraping %s (%s risk) ...", source["name"], source["anti_bot_risk"])
        t0 = time.time()

        try:
            listings = _run_scraper(sid, asset_types, states_override)
        except Exception as exc:
            logger.error("✗ %s failed: %s", sid, exc)
            listings = []

        elapsed = time.time() - t0
        all_raw.extend(listings)
        source_stats[sid] = {
            "raw": len(listings),
            "elapsed_s": round(elapsed, 1),
            "status": "ok" if listings else "empty",
        }
        logger.info("  → %d raw listings in %.1fs", len(listings), elapsed)

        # Incremental save after each source (so kills don't lose data)
        _save(all_raw, ns.output, buy_box, source_stats, partial=True)

    # Final filter
    matched = filter_listings(all_raw, buy_box)
    logger.info(
        "Discovery complete: %d raw → %d matched (buy-box filter)",
        len(all_raw),
        len(matched),
    )

    # Write final output
    _save(matched, ns.output, buy_box, source_stats, partial=False)

    # Supabase persistence
    if not ns.dry_run and not ns.no_persist:
        result = loader.upsert(matched)
        logger.info("Supabase: %s", result)
    else:
        logger.info("Supabase persistence skipped (--dry-run or --no-persist)")

    _print_summary(matched, source_stats, ns.output)
    return matched


def _run_scraper(source_id: str, asset_types: list[str], states: list[str] | None) -> list[Listing]:
    """Dispatch to the right scraper module."""
    # Lazy imports to keep startup fast
    if source_id == "rvparkstore":
        from offmarket.discovery.scrapers.rvparkstore import scrape
        return scrape(states=states)

    elif source_id == "campgroundsforsale":
        from offmarket.discovery.scrapers.campgroundsforsale import scrape
        return scrape()

    elif source_id == "selfstorages":
        from offmarket.discovery.scrapers.nicheinvestments import scrape_selfstorages
        return scrape_selfstorages(states=states)

    elif source_id == "mobilehomeparkstore":
        from offmarket.discovery.scrapers.nicheinvestments import scrape_mobilehomeparks
        return scrape_mobilehomeparks(states=states)

    elif source_id == "bizquest_campground":
        from offmarket.discovery.scrapers.bizquest import scrape
        return scrape(category="campground", states=states)

    elif source_id == "bizquest_hotel":
        from offmarket.discovery.scrapers.bizquest import scrape
        return scrape(category="hotel", states=states)

    elif source_id == "bizquest_storage":
        from offmarket.discovery.scrapers.bizquest import scrape
        return scrape(category="storage", states=states)

    elif source_id == "bizquest_glamping":
        from offmarket.discovery.scrapers.bizquest import scrape
        return scrape(category="campground", states=states)

    elif source_id == "businessbroker_campground":
        from offmarket.discovery.scrapers.businessbroker import scrape
        return scrape(keyword_key="campground", states=states, source_id="businessbroker_campground")

    elif source_id == "businessbroker_hotel":
        from offmarket.discovery.scrapers.businessbroker import scrape
        return scrape(keyword_key="hotel", states=states, source_id="businessbroker_hotel")

    elif source_id == "businessbroker_storage":
        from offmarket.discovery.scrapers.businessbroker import scrape
        return scrape(keyword_key="storage", states=states, source_id="businessbroker_storage")

    elif source_id == "bedandbreakfast":
        from offmarket.discovery.scrapers.bedandbreakfast import scrape
        return scrape(states=states)

    elif source_id == "murphybusiness":
        industries = _asset_types_to_murphy_industries(asset_types)
        from offmarket.discovery.scrapers.murphybusiness import scrape
        results = []
        for ind in industries:
            results.extend(scrape(industry=ind, states=states))
        return results

    elif source_id == "sunbelt":
        industries = _asset_types_to_sunbelt_industries(asset_types)
        from offmarket.discovery.scrapers.sunbelt import scrape
        results = []
        for ind in industries:
            results.extend(scrape(industry=ind, states=states))
        return results

    elif source_id == "tworld":
        categories = [c for c in ("campground", "hotel") if _needs(c, asset_types)]
        from offmarket.discovery.scrapers.tworld import scrape
        results = []
        for cat in categories:
            results.extend(scrape(category=cat, states=states))
        return results

    elif source_id == "landwatch_campground":
        from offmarket.discovery.scrapers.landwatch import scrape
        return scrape(states=states)

    elif source_id == "texashotelbrokerage":
        from offmarket.discovery.scrapers.texashotelbrokerage import scrape
        return scrape()

    else:
        logger.warning("No scraper implemented for source_id=%s — skipping", source_id)
        return []


def _needs(category: str, asset_types: list[str]) -> bool:
    mapping = {
        "campground": {"rv_park", "campground", "glamping"},
        "hotel": {"boutique_hotel", "inn"},
        "storage": {"self_storage"},
    }
    return bool(set(asset_types) & mapping.get(category, set()))


def _asset_types_to_murphy_industries(asset_types):
    result = []
    if _needs("campground", asset_types):
        result.append("campground")
    if _needs("hotel", asset_types):
        result.append("hotel")
    if _needs("storage", asset_types):
        result.append("storage")
    return result or ["campground"]


def _asset_types_to_sunbelt_industries(asset_types):
    return _asset_types_to_murphy_industries(asset_types)


def _save(listings: list[Listing], output_path: str, buy_box: dict, stats: dict, partial: bool):
    Path(output_path).parent.mkdir(parents=True, exist_ok=True)
    payload = {
        "meta": {
            "scraped_at": datetime.now(timezone.utc).isoformat(),
            "partial": partial,
            "buy_box": buy_box,
            "source_stats": stats,
            "total": len(listings),
        },
        "listings": [l.to_dict() for l in listings],
    }
    with open(output_path, "w") as f:
        json.dump(payload, f, indent=2, default=str)


def _print_summary(listings: list[Listing], stats: dict, output_path: str):
    print(f"\n{'='*60}")
    print(f"Off-Market Discovery — {datetime.now().strftime('%Y-%m-%d %H:%M')}")
    print(f"{'='*60}")
    print(f"Total matched: {len(listings)}")
    print()
    print("Source breakdown:")
    for sid, s in stats.items():
        status_icon = "✓" if s["status"] == "ok" else "✗"
        print(f"  {status_icon} {sid:35s} {s['raw']:4d} raw  ({s['elapsed_s']:.1f}s)")
    print()
    print("Top listings (by recency):")
    for l in listings[:10]:
        price = f"${l.asking_price:,}" if l.asking_price else "undisclosed"
        print(f"  [{l.source}] {l.title[:55]:<55} {price:>15}  {l.location}")
    print()
    print(f"Output: {output_path}")
    print(f"{'='*60}\n")


if __name__ == "__main__":
    run()
