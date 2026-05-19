"""
Dynamic per-buy-box source discovery using Claude with built-in web_search.

Replaces the static SOURCE_CATALOG in sources.py for the discovery phase:
given a buy box, Claude searches the live web for broker sites, niche
marketplaces, and even single-listing broker pages relevant to that asset
class and geography — then returns structured candidates ready to feed
the scraper pipeline.

A "source" here is anywhere multiple matching for-sale properties (or one
relevant property) can be extracted in a single scrape: large broker
directories, small regional brokers, vertical marketplaces, or one-off
broker pages with a relevant listing.
"""
from __future__ import annotations

import logging
from dataclasses import dataclass, asdict
from typing import Optional

from anthropic import Anthropic

logger = logging.getLogger(__name__)

MODEL = "claude-sonnet-4-6"

ALLOWED_ASSET_TYPES = [
    "rv_park",
    "campground",
    "boutique_hotel",
    "glamping",
    "self_storage",
    "inn",
]

ALLOWED_KINDS = ["broker", "marketplace", "single-listing"]


@dataclass
class CandidateSource:
    url: str
    name: str
    kind: str  # "broker" | "marketplace" | "single-listing"
    asset_types: list[str]
    confidence: float
    notes: str


SYSTEM_PROMPT = """You are a real-estate acquisition source-discovery agent for an off-market
deal pipeline. Your job: given a buy box, find URLs where for-sale property
listings matching the buy box can be scraped.

A "source" is ANY of:
  1. broker site — e.g. a brokerage's category/listings page
  2. small/niche marketplace — e.g. RVParkStore.com, BedAndBreakfast.com
  3. single-listing broker page — a tiny regional broker with one matching
     property currently listed

A source URL must be a page where at least one matching for-sale property
can be extracted in one scrape.

EXCLUDE these absolutely:
  - LoopNet, Crexi, BizBuySell — we have separate scrapers for these
  - Zillow, Realtor.com, Redfin, Trulia — residential only
  - Pure blog posts, news articles, "guide to buying X" pages
  - "Recently sold" or "past transactions" pages with no active inventory
  - Subscription/paywall-gated sites with no public listing preview
  - Aggregator landing pages with no listings (parked domains, 404s)

SEEK a healthy variety:
  - Large broker directories (national reach)
  - Small niche/regional brokers (often one or two relevant listings)
  - Vertical marketplaces specific to the asset class
  - Lesser-known sources — churn matters, novelty matters

WORKFLOW:
  1. Use the web_search tool aggressively (you have up to 8 searches). Search
     by asset class, geography, "for sale" + broker terms, and niche modifiers
     (e.g. "boutique inn for sale Texas", "RV park brokerage", "glamping
     business for sale"). Vary your queries.
  2. For each candidate URL, verify via search that the URL is a real, public
     listings page (not a 404, not a login wall, not a blog post).
  3. When you've gathered enough strong candidates (target 20-30), call the
     record_candidates tool with the final list.

Be RIGOROUS about the URL: it must be the specific page where listings
appear, not just the brokerage homepage (unless the homepage IS the
listings page, which is rare). For each candidate, your confidence should
reflect how sure you are the URL is reachable and shows live listings."""


RECORD_TOOL = {
    "name": "record_candidates",
    "description": (
        "Record the final list of candidate listing sources discovered via "
        "web search. Call this exactly once when you have completed your "
        "research."
    ),
    "input_schema": {
        "type": "object",
        "properties": {
            "candidates": {
                "type": "array",
                "description": (
                    "Discovered candidate sources. Aim for 20-30 high-quality "
                    "entries with variety across broker / marketplace / "
                    "single-listing kinds."
                ),
                "items": {
                    "type": "object",
                    "properties": {
                        "url": {
                            "type": "string",
                            "description": (
                                "Fully-qualified https URL of the listings "
                                "page where properties can be extracted."
                            ),
                        },
                        "name": {
                            "type": "string",
                            "description": "Broker or marketplace name.",
                        },
                        "kind": {
                            "type": "string",
                            "enum": ALLOWED_KINDS,
                        },
                        "asset_types": {
                            "type": "array",
                            "items": {
                                "type": "string",
                                "enum": ALLOWED_ASSET_TYPES,
                            },
                            "description": (
                                "Which buy-box asset types this source "
                                "likely covers."
                            ),
                        },
                        "confidence": {
                            "type": "number",
                            "minimum": 0,
                            "maximum": 1,
                            "description": (
                                "0-1 confidence the URL is reachable and "
                                "shows live listings."
                            ),
                        },
                        "notes": {
                            "type": "string",
                            "description": (
                                "One-line reasoning: why this source matches "
                                "the buy box and what was verified."
                            ),
                        },
                    },
                    "required": [
                        "url",
                        "name",
                        "kind",
                        "asset_types",
                        "confidence",
                        "notes",
                    ],
                },
            }
        },
        "required": ["candidates"],
    },
}

WEB_SEARCH_TOOL = {
    "type": "web_search_20250305",
    "name": "web_search",
    "max_uses": 8,
}


def _build_user_prompt(buy_box: dict, seed_known: list[str]) -> str:
    asset_types = buy_box.get("asset_types") or []
    geo = buy_box.get("geo") or {}
    states = geo.get("states")
    regions = geo.get("regions")
    price_min = buy_box.get("price_min")
    price_max = buy_box.get("price_max")

    geo_line = "Geography: nationwide (US)"
    if states:
        geo_line = f"Geography: states = {', '.join(states)}"
    if regions:
        geo_line += f"; regions = {', '.join(regions)}"

    price_line = "Price band: any"
    if price_min or price_max:
        lo = f"${price_min:,}" if price_min else "any"
        hi = f"${price_max:,}" if price_max else "any"
        price_line = f"Price band: {lo} – {hi}"

    excludes = ""
    if seed_known:
        excludes = (
            "\n\nEXCLUDE these already-known URLs from your results "
            "(we already have them in our catalog — find NEW sources):\n"
            + "\n".join(f"  - {u}" for u in seed_known)
        )

    return f"""Buy box:
- Asset types: {', '.join(asset_types) if asset_types else 'any'}
- {geo_line}
- {price_line}

Find at least 20 candidate sources (broker sites, niche marketplaces, and
single-listing broker pages) where for-sale properties matching this buy
box can be extracted. Use web_search to discover and verify candidates,
then call record_candidates with the final list.{excludes}"""


def _normalize_url(url: str) -> str:
    u = (url or "").strip().lower()
    if u.endswith("/"):
        u = u[:-1]
    return u


def _extract_candidates_from_tool_use(response) -> list[CandidateSource]:
    """Pull a record_candidates tool_use block off a response and parse it."""
    for block in response.content:
        if getattr(block, "type", None) == "tool_use" and block.name == "record_candidates":
            raw = block.input.get("candidates", []) if isinstance(block.input, dict) else []
            return _parse_candidates(raw)
    return []


def _parse_candidates(raw: list[dict]) -> list[CandidateSource]:
    out: list[CandidateSource] = []
    for c in raw:
        try:
            url = (c.get("url") or "").strip()
            if not url.startswith(("http://", "https://")):
                continue
            kind = c.get("kind", "broker")
            if kind not in ALLOWED_KINDS:
                kind = "broker"
            asset_types = [a for a in (c.get("asset_types") or []) if a in ALLOWED_ASSET_TYPES]
            conf_raw = c.get("confidence", 0.5)
            try:
                conf = float(conf_raw)
            except (TypeError, ValueError):
                conf = 0.5
            conf = max(0.0, min(1.0, conf))
            out.append(
                CandidateSource(
                    url=url,
                    name=(c.get("name") or "").strip() or url,
                    kind=kind,
                    asset_types=asset_types,
                    confidence=conf,
                    notes=(c.get("notes") or "").strip(),
                )
            )
        except Exception as e:
            logger.warning("Skipping malformed candidate %r: %s", c, e)
    return out


def _dedupe(candidates: list[CandidateSource]) -> list[CandidateSource]:
    seen: set[str] = set()
    out: list[CandidateSource] = []
    for c in candidates:
        key = _normalize_url(c.url)
        if key in seen:
            continue
        seen.add(key)
        out.append(c)
    return out


def discover_sources(
    buy_box: dict,
    min_count: int = 15,
    seed_known: Optional[list[str]] = None,
) -> list[CandidateSource]:
    """Discover candidate sources for the buy box via web search + LLM classification.

    seed_known: URLs to exclude from results (already known from memory).
    Returns at least min_count candidates if findable; up to ~30.
    """
    seed_known = seed_known or []
    client = Anthropic()

    user_prompt = _build_user_prompt(buy_box, seed_known)
    messages: list[dict] = [{"role": "user", "content": user_prompt}]
    tools = [WEB_SEARCH_TOOL, RECORD_TOOL]

    total_input = 0
    total_output = 0

    # First turn: let Claude search and (ideally) call record_candidates on its own.
    response = client.messages.create(
        model=MODEL,
        max_tokens=4096,
        system=SYSTEM_PROMPT,
        tools=tools,
        messages=messages,
    )

    usage = getattr(response, "usage", None)
    if usage is not None:
        total_input += getattr(usage, "input_tokens", 0) or 0
        total_output += getattr(usage, "output_tokens", 0) or 0

    candidates = _extract_candidates_from_tool_use(response)

    # If Claude didn't call record_candidates yet, force it on a follow-up turn.
    if not candidates:
        logger.info(
            "record_candidates not called on first turn (stop_reason=%s) — forcing.",
            getattr(response, "stop_reason", None),
        )
        messages.append({"role": "assistant", "content": response.content})
        messages.append(
            {
                "role": "user",
                "content": (
                    "You have completed your research. Now call the "
                    "record_candidates tool with your final list of "
                    "discovered sources."
                ),
            }
        )
        try:
            forced = client.messages.create(
                model=MODEL,
                max_tokens=4096,
                system=SYSTEM_PROMPT,
                tools=tools,
                tool_choice={"type": "tool", "name": "record_candidates"},
                messages=messages,
            )
        except Exception as e:
            logger.warning("Forced tool-call turn failed: %s", e)
            forced = None

        if forced is not None:
            usage = getattr(forced, "usage", None)
            if usage is not None:
                total_input += getattr(usage, "input_tokens", 0) or 0
                total_output += getattr(usage, "output_tokens", 0) or 0
            candidates = _extract_candidates_from_tool_use(forced)

    candidates = _dedupe(candidates)

    # Drop anything matching seed_known after normalization (belt-and-suspenders).
    excluded = {_normalize_url(u) for u in seed_known}
    if excluded:
        candidates = [c for c in candidates if _normalize_url(c.url) not in excluded]

    logger.info(
        "discover_sources: returned %d candidates (min_count=%d). "
        "Tokens: input=%d output=%d.",
        len(candidates),
        min_count,
        total_input,
        total_output,
    )
    if len(candidates) < min_count:
        logger.warning(
            "discover_sources: only %d candidates found, below min_count=%d.",
            len(candidates),
            min_count,
        )

    return candidates


__all__ = ["CandidateSource", "discover_sources"]
