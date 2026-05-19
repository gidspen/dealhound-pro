"""
CLI runner — off-market discovery pipeline (skillpack v2).

Pipeline per run:
  1. Load buy box + per-buy-box source memory
  2. Run pinned scrapers (cached fast paths for known winners — rvparkstore, etc.)
  3. Run dynamic source discovery (Claude + web_search) → new candidates
  4. Re-check active known sources from memory (not already covered above)
  5. For each new/known source: fetch HTML → generic LLM extractor → Listings
  6. Apply buy-box filter
  7. Persist (local JSON + optional Supabase) + update memory

Usage:
  python3 -m offmarket.discovery.run --buy-box data/buy_box_rv_parks_tx.json
  python3 -m offmarket.discovery.run --buy-box buy_box.json --no-persist
  python3 -m offmarket.discovery.run --buy-box buy_box.json --skip-discovery   # pinned only
  python3 -m offmarket.discovery.run --buy-box buy_box.json --min-sources 20

Options:
  --buy-box PATH        Buy-box JSON (required)
  --output PATH         Output JSON (default: data/discovered_listings.json)
  --sources SRC...      Limit pinned scrapers to these IDs
  --states ST...        Override states list
  --min-sources N       Minimum dynamic candidates to seek (default: 15)
  --skip-discovery      Run only pinned scrapers, skip dynamic discovery
  --skip-pinned         Run only dynamic discovery, skip pinned scrapers
  --dry-run             Skip Supabase write (local JSON still written)
  --no-persist          Skip Supabase entirely
  --verbose             Debug logging
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
from urllib.parse import urlparse

from offmarket.discovery.base import Listing, get
from offmarket.discovery.filter import load_buy_box, filter_listings
from offmarket.discovery.sources import sources_for_buy_box
from offmarket.discovery import loader
from offmarket.discovery.source_memory import (
    buy_box_id,
    load_memory,
    upsert_source,
    record_run_result,
)

logger = logging.getLogger(__name__)


def build_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(description="Off-market hospitality discovery pipeline")
    p.add_argument("--buy-box", required=True, metavar="PATH")
    p.add_argument("--output", default="data/discovered_listings.json", metavar="PATH")
    p.add_argument("--sources", nargs="*", metavar="SRC")
    p.add_argument("--states", nargs="*", metavar="ST")
    p.add_argument("--min-sources", type=int, default=15)
    p.add_argument("--skip-discovery", action="store_true")
    p.add_argument("--skip-pinned", action="store_true")
    p.add_argument("--dry-run", action="store_true")
    p.add_argument("--no-persist", action="store_true")
    p.add_argument("--verbose", action="store_true")
    return p


def run(args=None):
    ns = build_parser().parse_args(args)
    logging.basicConfig(
        level=logging.DEBUG if ns.verbose else logging.INFO,
        format="%(asctime)s %(levelname)s %(name)s — %(message)s",
    )

    buy_box = load_buy_box(ns.buy_box)
    bbid = buy_box_id(buy_box)
    asset_types = buy_box.get("asset_types", [])
    states_override = ns.states or (buy_box.get("geo") or {}).get("states")

    logger.info("Buy-box id=%s asset_types=%s states=%s", bbid, asset_types, states_override or "all")

    memory = load_memory(bbid)
    active_memory = [r for r in memory if r.status != "demoted"]
    logger.info("Memory: %d records, %d active", len(memory), len(active_memory))

    all_raw: list[Listing] = []
    source_stats: dict[str, dict] = {}

    # ── 1. Pinned scrapers (cached fast paths) ────────────────────────────────
    pinned_sources = sources_for_buy_box(asset_types)
    if ns.sources:
        pinned_sources = [s for s in pinned_sources if s["id"] in ns.sources]

    if not ns.skip_pinned:
        for source in pinned_sources:
            sid = source["id"]
            logger.info("▶ Pinned: %s (%s risk)", source["name"], source["anti_bot_risk"])
            t0 = time.time()
            try:
                listings = _run_pinned_scraper(sid, asset_types, states_override)
            except Exception as exc:
                logger.error("✗ %s failed: %s", sid, exc)
                listings = []
            elapsed = time.time() - t0
            all_raw.extend(listings)
            source_stats[sid] = {
                "raw": len(listings),
                "elapsed_s": round(elapsed, 1),
                "status": "ok" if listings else "empty",
                "kind": "pinned",
                "url": source.get("base_url", ""),
            }
            logger.info("  → %d listings in %.1fs", len(listings), elapsed)
            upsert_source(
                bbid,
                source.get("base_url", sid),
                name=source["name"],
                kind="broker",
                asset_types=source["asset_types"],
                notes=f"pinned scraper: {sid}",
            )
            record_run_result(bbid, source.get("base_url", sid), len(listings))
            _save(all_raw, ns.output, buy_box, source_stats, partial=True)

    # ── 2. Dynamic source discovery ──────────────────────────────────────────
    candidates = []
    if not ns.skip_discovery:
        try:
            from offmarket.discovery.source_discovery import discover_sources
            seed_known = (
                [s.get("base_url", "") for s in pinned_sources if s.get("base_url")]
                + [r.url for r in memory]
            )
            logger.info("▶ Discovering new sources (min=%d) ...", ns.min_sources)
            candidates = discover_sources(
                buy_box, min_count=ns.min_sources, seed_known=seed_known
            )
            logger.info("  → %d new candidates", len(candidates))
        except Exception as exc:
            logger.error("Discovery failed: %s", exc)
            candidates = []

    # ── 3. Re-check active memory sources not already covered ────────────────
    pinned_urls = {s.get("base_url", "") for s in pinned_sources}
    candidate_urls = {c.url for c in candidates}
    revisit = [
        r for r in active_memory
        if r.url and r.url not in pinned_urls and r.url not in candidate_urls
    ]
    logger.info("Revisit %d previously-active sources from memory", len(revisit))

    # ── 4. Generic extraction (Claude reads HTML → Listings) ────────────────
    extract_targets = []  # (url, name, kind, asset_types, source_id)
    for c in candidates:
        extract_targets.append((c.url, c.name, c.kind, c.asset_types, _slug(c.url)))
    for r in revisit:
        extract_targets.append((r.url, r.name, r.kind, r.asset_types, _slug(r.url)))

    if extract_targets:
        from offmarket.discovery.extract_generic import extract_listings

    for url, name, kind, src_asset_types, sid in extract_targets:
        logger.info("▶ Generic extract: %s [%s]", url, kind)
        t0 = time.time()
        try:
            html = get(url)
            if html:
                listings = extract_listings(html, url, asset_types)
            else:
                listings = []
        except Exception as exc:
            logger.error("✗ Extract failed for %s: %s", url, exc)
            listings = []
        elapsed = time.time() - t0
        all_raw.extend(listings)
        source_stats[sid] = {
            "raw": len(listings),
            "elapsed_s": round(elapsed, 1),
            "status": "ok" if listings else "empty",
            "kind": kind,
            "url": url,
        }
        logger.info("  → %d listings in %.1fs", len(listings), elapsed)
        upsert_source(
            bbid, url, name=name, kind=kind, asset_types=src_asset_types
        )
        record_run_result(bbid, url, len(listings))
        _save(all_raw, ns.output, buy_box, source_stats, partial=True)

    # ── 5. Buy-box filter ────────────────────────────────────────────────────
    matched = filter_listings(all_raw, buy_box)
    logger.info(
        "Discovery complete: %d raw → %d matched (sources attempted: %d)",
        len(all_raw),
        len(matched),
        len(source_stats),
    )

    _save(matched, ns.output, buy_box, source_stats, partial=False)

    # ── 6. Supabase persistence ──────────────────────────────────────────────
    if not ns.dry_run and not ns.no_persist:
        result = loader.upsert(matched)
        logger.info("Supabase: %s", result)
    else:
        logger.info("Supabase persistence skipped (--dry-run or --no-persist)")

    _print_summary(matched, source_stats, ns.output, bbid)
    return matched


# ── pinned scraper dispatch (existing static catalog) ────────────────────────

def _run_pinned_scraper(source_id: str, asset_types: list[str], states: list[str] | None) -> list[Listing]:
    """Dispatch to a hand-coded scraper module."""
    if source_id == "rvparkstore":
        from offmarket.discovery.scrapers.rvparkstore import scrape
        return scrape(states=states)
    elif source_id == "selfstorages":
        from offmarket.discovery.scrapers.nicheinvestments import scrape_selfstorages
        return scrape_selfstorages(states=states)
    elif source_id == "mobilehomeparkstore":
        from offmarket.discovery.scrapers.nicheinvestments import scrape_mobilehomeparks
        return scrape_mobilehomeparks(states=states)
    elif source_id == "businessbroker_campground":
        from offmarket.discovery.scrapers.businessbroker import scrape
        return scrape(keyword_key="campground", states=states, source_id="businessbroker_campground")
    elif source_id == "businessbroker_hotel":
        from offmarket.discovery.scrapers.businessbroker import scrape
        return scrape(keyword_key="hotel", states=states, source_id="businessbroker_hotel")
    elif source_id == "businessbroker_storage":
        from offmarket.discovery.scrapers.businessbroker import scrape
        return scrape(keyword_key="storage", states=states, source_id="businessbroker_storage")
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
    elif source_id == "bedandbreakfast":
        from offmarket.discovery.scrapers.bedandbreakfast import scrape
        return scrape(states=states)
    elif source_id == "murphybusiness":
        from offmarket.discovery.scrapers.murphybusiness import scrape
        industries = _industries_for(asset_types)
        out: list[Listing] = []
        for ind in industries:
            out.extend(scrape(industry=ind, states=states))
        return out
    elif source_id == "sunbelt":
        from offmarket.discovery.scrapers.sunbelt import scrape
        industries = _industries_for(asset_types)
        out: list[Listing] = []
        for ind in industries:
            out.extend(scrape(industry=ind, states=states))
        return out
    elif source_id == "tworld":
        from offmarket.discovery.scrapers.tworld import scrape
        out: list[Listing] = []
        for cat in ("campground", "hotel"):
            if _needs(cat, asset_types):
                out.extend(scrape(category=cat, states=states))
        return out
    elif source_id == "landwatch_campground":
        from offmarket.discovery.scrapers.landwatch import scrape
        return scrape(states=states)
    elif source_id == "texashotelbrokerage":
        from offmarket.discovery.scrapers.texashotelbrokerage import scrape
        return scrape()
    else:
        logger.warning("No pinned scraper for source_id=%s", source_id)
        return []


def _needs(category: str, asset_types: list[str]) -> bool:
    mapping = {
        "campground": {"rv_park", "campground", "glamping"},
        "hotel": {"boutique_hotel", "inn"},
        "storage": {"self_storage"},
    }
    return bool(set(asset_types) & mapping.get(category, set()))


def _industries_for(asset_types: list[str]) -> list[str]:
    out = []
    if _needs("campground", asset_types):
        out.append("campground")
    if _needs("hotel", asset_types):
        out.append("hotel")
    if _needs("storage", asset_types):
        out.append("storage")
    return out or ["campground"]


# ── output helpers ───────────────────────────────────────────────────────────

def _slug(url: str) -> str:
    netloc = urlparse(url).netloc.replace("www.", "")
    return netloc.replace(".", "_") or url


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


def _print_summary(listings: list[Listing], stats: dict, output_path: str, bbid: str):
    print(f"\n{'='*60}")
    print(f"Off-Market Discovery — {datetime.now().strftime('%Y-%m-%d %H:%M')}")
    print(f"Buy-box id: {bbid}")
    print(f"{'='*60}")
    print(f"Sources attempted: {len(stats)}")
    print(f"Total matched listings: {len(listings)}")
    print()
    print("Source breakdown:")
    for sid, s in stats.items():
        icon = "✓" if s["status"] == "ok" else "✗"
        kind = s.get("kind", "?")[:11]
        print(f"  {icon} {sid:32s} {kind:12s} {s['raw']:4d} raw  ({s['elapsed_s']:.1f}s)")
    print()
    print("Top listings (most recent):")
    for l in listings[:10]:
        price = f"${l.asking_price:,}" if l.asking_price else "undisclosed"
        print(f"  [{l.source}] {l.title[:50]:<50} {price:>15}  {l.location[:30]}")
    print()
    print(f"Output: {output_path}")
    print(f"{'='*60}\n")


if __name__ == "__main__":
    run()
