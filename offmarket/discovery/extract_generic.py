"""
Generic Listing extractor — uses Claude to extract property listings from
arbitrary HTML.

This is the dynamic-source workhorse for the off-market discovery pipeline.
Hand-coded scrapers handle the ~5 known broker sites; this module handles
everything else: long-tail brokers, marketplaces, and one-off niche directories
discovered per buy box.
"""
from __future__ import annotations

import json
import logging
import os
from datetime import datetime, timezone
from typing import Optional
from urllib.parse import urljoin, urlparse

from bs4 import BeautifulSoup

from offmarket.discovery.base import Listing

logger = logging.getLogger(__name__)

MODEL = "claude-sonnet-4-6"
MAX_HTML_CHARS = 50_000  # ~50K char budget for prompt body (contract target)
ALLOWED_ASSET_TYPES = {
    "rv_park",
    "campground",
    "boutique_hotel",
    "glamping",
    "self_storage",
    "inn",
}

# Lazy client construction so import succeeds even without anthropic installed.
_client = None


def _get_client():
    global _client
    if _client is None:
        from anthropic import Anthropic  # noqa: WPS433
        _client = Anthropic()
    return _client


_LISTING_HINTS = (
    "result-item",
    "listing-item",
    "listing-card",
    "property-card",
    "search-result",
    "businessForSale",
    "business-for-sale",
)


def _preprocess_html(html: str) -> str:
    """Extract <body>, drop chrome/noise, collapse whitespace, then truncate
    to ~MAX_HTML_CHARS.

    Additionally, strip image src/srcset, inline base64 data URIs, and
    class/style attribute soup — these eat the budget without helping
    Claude read the markup.
    """
    import re

    soup = BeautifulSoup(html, "html.parser")
    body = soup.body or soup
    for tag in body.find_all(
        ["script", "style", "noscript", "svg", "header", "nav", "footer", "iframe", "link", "meta", "picture", "source"]
    ):
        tag.decompose()
    # Strip noisy attrs from every element — Claude doesn't need image URLs,
    # CSS classes, inline styles, or lazyload data to extract listing info.
    NOISY_ATTRS = {"src", "srcset", "data-src", "data-srcset", "style", "class",
                   "loading", "width", "height", "alt", "title", "id"}
    for tag in body.find_all(True):
        for attr in list(tag.attrs):
            if attr in NOISY_ATTRS:
                del tag.attrs[attr]
        if tag.name == "img":
            tag.decompose()

    text = str(body)
    # Collapse runs of whitespace — saves tokens without hurting Claude's
    # ability to read the markup.
    text = re.sub(r"\s+", " ", text)

    if len(text) <= MAX_HTML_CHARS:
        return text

    # Find the earliest hint of a listing region; slide the window there.
    start = 0
    for hint in _LISTING_HINTS:
        idx = text.find(hint)
        if idx > 0:
            start = max(0, idx - 500)
            break

    return text[start : start + MAX_HTML_CHARS]


def _source_id_from_url(source_url: str) -> str:
    netloc = urlparse(source_url).netloc or source_url
    return netloc.replace("www.", "").replace(".", "_")


def _resolve_url(raw_url: str, source_url: str) -> str:
    if not raw_url:
        return ""
    if raw_url.startswith("http://") or raw_url.startswith("https://"):
        return raw_url
    return urljoin(source_url, raw_url)


TOOL_SCHEMA = {
    "name": "record_listings",
    "description": (
        "Record an array of property/business-for-sale listings extracted from "
        "the supplied HTML. Only include items that are clearly an active "
        "for-sale listing on this page."
    ),
    "input_schema": {
        "type": "object",
        "properties": {
            "listings": {
                "type": "array",
                "items": {
                    "type": "object",
                    "properties": {
                        "title": {
                            "type": "string",
                            "description": "Listing headline / business name.",
                        },
                        "url": {
                            "type": "string",
                            "description": (
                                "Detail page URL. Relative URLs will be "
                                "resolved against the source URL."
                            ),
                        },
                        "location": {
                            "type": "string",
                            "description": "City, ST or region as shown on the card.",
                        },
                        "asking_price": {
                            "type": ["integer", "null"],
                            "description": (
                                "Asking price in whole US dollars. Null if "
                                "'Call for Price', 'Inquire', '$0', or "
                                "otherwise undisclosed."
                            ),
                        },
                        "asset_type": {
                            "type": "string",
                            "enum": sorted(ALLOWED_ASSET_TYPES),
                            "description": "One of the allowed asset categories.",
                        },
                        "size_metric": {
                            "type": ["string", "null"],
                            "description": "e.g. '39 lots', '84 acres', '120 units'.",
                        },
                        "description": {
                            "type": ["string", "null"],
                            "description": "Short blurb/snippet for the listing.",
                        },
                    },
                    "required": ["title", "url", "location", "asset_type"],
                },
            }
        },
        "required": ["listings"],
    },
}


def _build_system_prompt(asset_types: list[str], source_url: str) -> str:
    return (
        "You are extracting property/business-for-sale listings from a broker "
        "site or marketplace HTML page. Return only items where multiple "
        "matching properties are clearly for sale (not blog mentions, not "
        "'recently sold').\n\n"
        "For asking_price: if the text says 'Call for Price' or 'Inquire' or "
        "'$0' or similar, return null. If a dollar amount, return it as an "
        "integer (no commas/symbols).\n\n"
        f"Resolve relative URLs against `{source_url}`.\n\n"
        f"Drop any listing whose asset_type isn't in {asset_types}.\n\n"
        "Allowed asset_type values and how to map liberally:\n"
        "- boutique_hotel: hotels, motels, lodges, resorts, cabins-with-rooms, "
        "hospitality platforms, any small/mid lodging property with rooms.\n"
        "- inn: bed-and-breakfasts, inns, historic inns.\n"
        "- rv_park: RV park, RV resort, mobile home park with RV pads.\n"
        "- campground: campground, primitive campsites, KOA-style.\n"
        "- glamping: glamping, yurts, safari tents, tiny home / cabin / "
        "tiny-house lodging communities used as short-term lodging.\n"
        "- self_storage: self-storage facility, mini-storage.\n\n"
        "IMPORTANT: if the caller's requested asset_types does not include a "
        "perfect match for a listing, but the listing is still a physical "
        "lodging/hospitality/storage property, map it to the closest requested "
        "asset_type. For example, if only `boutique_hotel` is requested and "
        "you see an inn, B&B, lodge, motel, cabins, or small lodging "
        "community, return it as `boutique_hotel`.\n\n"
        "Exclude pure service businesses (property management firms, "
        "vacation rental management contracts, franchise opportunities "
        "without real estate, interior design services)."
    )


def extract_listings(
    html: str,
    source_url: str,
    asset_types: list[str],
) -> list[Listing]:
    """Use Claude to extract Listings from arbitrary HTML.

    asset_types: filter — only return listings whose asset_type is in this list.
                 Allowed values: rv_park, campground, boutique_hotel, glamping,
                 self_storage, inn
    source_url:  stored as listing source AND passed to Claude as context for
                 URL resolution.

    Returns [] if HTML is not a listing page or extraction fails.
    """
    if not html or not source_url:
        return []

    filter_set = {a for a in asset_types if a in ALLOWED_ASSET_TYPES}
    if not filter_set:
        logger.warning("extract_generic: no valid asset_types in %s", asset_types)
        return []

    try:
        cleaned_html = _preprocess_html(html)
    except Exception as exc:  # noqa: BLE001
        logger.warning("extract_generic: HTML preprocess failed: %s", exc)
        return []

    system_prompt = _build_system_prompt(sorted(filter_set), source_url)
    user_msg = (
        f"Source URL: {source_url}\n\n"
        f"Extract all for-sale listings from the HTML below whose asset_type "
        f"is one of {sorted(filter_set)}. Call the `record_listings` tool.\n\n"
        "----- HTML -----\n"
        f"{cleaned_html}"
    )

    try:
        client = _get_client()
        response = client.messages.create(
            model=MODEL,
            max_tokens=8192,
            system=system_prompt,
            tools=[TOOL_SCHEMA],
            tool_choice={"type": "tool", "name": "record_listings"},
            messages=[{"role": "user", "content": user_msg}],
        )
    except Exception as exc:  # noqa: BLE001
        logger.warning("extract_generic: Claude call failed for %s: %s", source_url, exc)
        return []

    # Log token usage
    try:
        usage = getattr(response, "usage", None)
        if usage is not None:
            logger.info(
                "extract_generic tokens: input=%s output=%s url=%s",
                getattr(usage, "input_tokens", "?"),
                getattr(usage, "output_tokens", "?"),
                source_url,
            )
    except Exception:  # noqa: BLE001
        pass

    # Pull tool_use block
    tool_input = None
    for block in getattr(response, "content", []) or []:
        if getattr(block, "type", None) == "tool_use" and getattr(block, "name", None) == "record_listings":
            tool_input = block.input
            break

    if not tool_input:
        logger.warning("extract_generic: no tool_use block in response for %s", source_url)
        return []

    if isinstance(tool_input, str):
        try:
            tool_input = json.loads(tool_input)
        except json.JSONDecodeError:
            logger.warning("extract_generic: tool_input not valid JSON for %s", source_url)
            return []

    raw_items = tool_input.get("listings", []) if isinstance(tool_input, dict) else []
    if not isinstance(raw_items, list):
        return []

    source_id = _source_id_from_url(source_url)
    now = datetime.now(timezone.utc).isoformat()
    out: list[Listing] = []

    for item in raw_items:
        if not isinstance(item, dict):
            continue
        asset_type = item.get("asset_type")
        if asset_type not in filter_set:
            continue  # defensive filter
        title = (item.get("title") or "").strip()
        raw_url = (item.get("url") or "").strip()
        location = (item.get("location") or "").strip()
        if not title or not raw_url:
            continue
        resolved_url = _resolve_url(raw_url, source_url)
        asking_price = item.get("asking_price")
        if isinstance(asking_price, str):
            # be lenient — strip $ and commas
            cleaned = asking_price.replace("$", "").replace(",", "").strip()
            try:
                asking_price = int(float(cleaned)) if cleaned else None
            except ValueError:
                asking_price = None
        if asking_price == 0:
            asking_price = None

        out.append(
            Listing(
                source=source_id,
                url=resolved_url,
                title=title,
                location=location,
                asking_price=asking_price,
                asset_type=asset_type,
                size_metric=item.get("size_metric"),
                description=item.get("description"),
                posted_date=None,
                broker_name=None,
                broker_phone=None,
                broker_email=None,
                scraped_at=now,
            )
        )

    logger.info("extract_generic: %d listings from %s", len(out), source_url)
    return out


__all__ = ["extract_listings"]
