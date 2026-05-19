"""
Off-market discovery source catalog — 24 sources across 6 verticals.

Each entry documents: name, base URL, asset classes covered, anti-bot risk,
scraper status, and notes on approach/limitations.

anti_bot_risk:
  low    — plain HTML, no Cloudflare/JS challenge; works from any IP
  medium — may block cloud IPs; works from residential IP
  high   — Cloudflare/JS wall; likely blocked even from residential

status:
  active    — scraper implemented and confirmed or expected to work
  deferred  — source identified but scraper not implemented in v1
  inactive  — domain parked, site down, or not a listing site
"""
from __future__ import annotations
from typing import Optional

SOURCE_CATALOG: list[dict] = [

    # ── RV Parks / Campgrounds ──────────────────────────────────────────────

    {
        "id": "rvparkstore",
        "name": "RV Park Store",
        "base_url": "https://www.rvparkstore.com",
        "listing_url_pattern": "https://www.rvparkstore.com/rv-parks-for-sale/{state}/all",
        "asset_types": ["rv_park", "campground"],
        "anti_bot_risk": "low",
        "status": "active",
        "notes": "CONFIRMED from cloud. CSS: div.item, a.item-title, div.item-price. "
                 "Paginated /page/{n}. Sister to SelfStorages.com. "
                 "46 TX listings, 193 national as of 2026-05-18.",
    },
    {
        "id": "campgroundsforsale",
        "name": "Campgrounds for Sale",
        "base_url": "https://www.campgroundsforsale.com",
        "listing_url_pattern": "https://www.campgroundsforsale.com/buy-campground",
        "asset_types": ["campground", "rv_park"],
        "anti_bot_risk": "low",
        "status": "deferred",
        "notes": "CONFIRMED GATED (2026-05-18): /buy-campground requires paid subscription "
                 "to view listings. No public listing URLs accessible. "
                 "Defer until subscription or direct contact strategy.",
    },
    {
        "id": "selfstorages",
        "name": "SelfStorages.com",
        "base_url": "https://www.selfstorages.com",
        "listing_url_pattern": "https://www.selfstorages.com/self-storages-for-sale/{state}/all",
        "asset_types": ["self_storage"],
        "anti_bot_risk": "low",
        "status": "active",
        "notes": "Sister site to RVParkStore.com — identical HTML structure (div.item, "
                 "a.item-title, div.item-price). Confirmed same NicheInvestments platform.",
    },
    {
        "id": "mobilehomeparkstore",
        "name": "Mobile Home Park Store",
        "base_url": "https://www.mobilehomeparkstore.com",
        "listing_url_pattern": "https://www.mobilehomeparkstore.com/mobile-home-parks-for-sale/{state}/all",
        "asset_types": ["rv_park"],  # some overlap with RV parks
        "anti_bot_risk": "low",
        "status": "active",
        "notes": "Sister site to RVParkStore.com — identical HTML. "
                 "Included because park-model RV communities overlap with buy-box.",
    },

    # ── Boutique Hotels / Inns / B&B ───────────────────────────────────────

    {
        "id": "bizquest_hotel",
        "name": "BizQuest — Hotels & Motels",
        "base_url": "https://www.bizquest.com",
        "listing_url_pattern": "https://www.bizquest.com/businesses-for-sale/hotel-motel/bid-29/",
        "asset_types": ["boutique_hotel"],
        "anti_bot_risk": "medium",
        "status": "active",
        "notes": "Large business broker marketplace. 403 from cloud IP; works from "
                 "residential. Category ID 29 = Hotel/Motel. Also: /state/TX/ filter.",
    },
    {
        "id": "bizquest_campground",
        "name": "BizQuest — Campgrounds & RV Parks",
        "base_url": "https://www.bizquest.com",
        "listing_url_pattern": "https://www.bizquest.com/businesses-for-sale/campground-rv-park/bid-67/",
        "asset_types": ["campground", "rv_park", "glamping"],
        "anti_bot_risk": "medium",
        "status": "active",
        "notes": "Category ID 67 = Campground/RV Park. Same site as bizquest_hotel.",
    },
    {
        "id": "bedandbreakfast",
        "name": "BedAndBreakfast.com — Inns For Sale",
        "base_url": "https://www.bedandbreakfast.com",
        "listing_url_pattern": "https://www.bedandbreakfast.com/for-sale/",
        "asset_types": ["inn", "boutique_hotel"],
        "anti_bot_risk": "low",
        "status": "active",
        "notes": "Dedicated B&B/inn marketplace. Has 'For Sale' section with full listings. "
                 "Small operators, often owner-listed. Excellent for boutique-hotel buy box.",
    },
    {
        "id": "businessbroker_hotel",
        "name": "BusinessBroker.net — Hotels",
        "base_url": "https://www.businessbroker.net",
        "listing_url_pattern": "https://www.businessbroker.net/search/?q=hotel&category=Hotels+%26+Motels",
        "asset_types": ["boutique_hotel"],
        "anti_bot_risk": "low",
        "status": "active",
        "notes": "Independent business broker directory. Lower bot defense than BizBuySell. "
                 "Includes smaller regional brokers not on the big platforms.",
    },
    {
        "id": "hrec",
        "name": "HREC Investment Advisors",
        "base_url": "https://hrec.com",
        "listing_url_pattern": "https://hrec.com/properties/for-sale/",
        "asset_types": ["boutique_hotel"],
        "anti_bot_risk": "low",
        "status": "deferred",
        "notes": "Advisory firm — /properties/ shows past appraisal work, NOT active sales. "
                 "Their active listings are via email/relationship. Defer until direct contact.",
    },
    {
        "id": "mumford",
        "name": "Mumford Company",
        "base_url": "https://mumford.com",
        "listing_url_pattern": "https://mumford.com/properties/",
        "asset_types": ["boutique_hotel"],
        "anti_bot_risk": "low",
        "status": "deferred",
        "notes": "Boutique hotel brokerage. SSL cert expired as of 2026-05-18. "
                 "Revisit when cert is renewed. Has real listings when accessible.",
    },

    # ── Glamping ──────────────────────────────────────────────────────────

    {
        "id": "bizquest_glamping",
        "name": "BizQuest — Campgrounds (glamping search)",
        "base_url": "https://www.bizquest.com",
        "listing_url_pattern": "https://www.bizquest.com/businesses-for-sale/?q=glamping",
        "asset_types": ["glamping"],
        "anti_bot_risk": "medium",
        "status": "active",
        "notes": "Keyword search within BizQuest for glamping operators for sale. "
                 "Overlaps with bizquest_campground; filter by keyword post-scrape.",
    },
    {
        "id": "glampinghub",
        "name": "GlampingHub — Operator Listings",
        "base_url": "https://glampinghub.com",
        "listing_url_pattern": "https://glampinghub.com/for-sale/",
        "asset_types": ["glamping"],
        "anti_bot_risk": "high",
        "status": "deferred",
        "notes": "GlampingHub does not have a public 'for sale' marketplace as of 2026. "
                 "Operator transitions happen via direct email/Facebook groups. Defer.",
    },
    {
        "id": "tentrr",
        "name": "Tentrr — Operator Transitions",
        "base_url": "https://tentrr.com",
        "listing_url_pattern": "https://tentrr.com/sell/",
        "asset_types": ["glamping"],
        "anti_bot_risk": "high",
        "status": "deferred",
        "notes": "Tentrr operator transfers are not publicly listed. "
                 "Relationship-based only. Defer to broker-outreach sprint.",
    },

    # ── Self-Storage ─────────────────────────────────────────────────────

    {
        "id": "bizquest_storage",
        "name": "BizQuest — Self-Storage",
        "base_url": "https://www.bizquest.com",
        "listing_url_pattern": "https://www.bizquest.com/businesses-for-sale/self-storage/bid-77/",
        "asset_types": ["self_storage"],
        "anti_bot_risk": "medium",
        "status": "active",
        "notes": "Category ID 77 = Self-Storage. Same BizQuest platform.",
    },
    {
        "id": "businessbroker_storage",
        "name": "BusinessBroker.net — Self-Storage",
        "base_url": "https://www.businessbroker.net",
        "listing_url_pattern": "https://www.businessbroker.net/search/?q=self+storage",
        "asset_types": ["self_storage"],
        "anti_bot_risk": "low",
        "status": "active",
        "notes": "Same platform as businessbroker_hotel; different keyword search.",
    },

    # ── SBA / General Business Brokers ───────────────────────────────────

    {
        "id": "murphybusiness",
        "name": "Murphy Business Sales",
        "base_url": "https://www.murphybusiness.com",
        "listing_url_pattern": "https://www.murphybusiness.com/businesses-for-sale/",
        "asset_types": ["rv_park", "campground", "boutique_hotel", "self_storage"],
        "anti_bot_risk": "medium",
        "status": "active",
        "notes": "Large national franchise broker network. Search by industry. "
                 "Has campground, hotel, storage categories. 403 from cloud, residential OK.",
    },
    {
        "id": "sunbelt",
        "name": "Sunbelt Business Brokers",
        "base_url": "https://www.sunbeltnetwork.com",
        "listing_url_pattern": "https://www.sunbeltnetwork.com/businesses-for-sale/",
        "asset_types": ["rv_park", "campground", "boutique_hotel", "self_storage"],
        "anti_bot_risk": "high",
        "status": "active",
        "notes": "Largest US business broker. Aggressive bot defense (403 confirmed from cloud). "
                 "May work from residential; include with fallback. National footprint.",
    },
    {
        "id": "tworld",
        "name": "Transworld Business Advisors",
        "base_url": "https://www.tworld.com",
        "listing_url_pattern": "https://www.tworld.com/businesses-for-sale/",
        "asset_types": ["rv_park", "campground", "boutique_hotel"],
        "anti_bot_risk": "medium",
        "status": "active",
        "notes": "Large franchise broker. Has campground/hospitality listings. "
                 "Medium bot risk; include with fallback.",
    },
    {
        "id": "businessbroker_campground",
        "name": "BusinessBroker.net — Campgrounds",
        "base_url": "https://www.businessbroker.net",
        "listing_url_pattern": "https://www.businessbroker.net/search/?q=campground+rv+park",
        "asset_types": ["campground", "rv_park"],
        "anti_bot_risk": "low",
        "status": "active",
        "notes": "Keyword search within BusinessBroker.net.",
    },

    # ── Regional / Niche Brokers ─────────────────────────────────────────

    {
        "id": "landwatch_campground",
        "name": "LandWatch — Campground / RV",
        "base_url": "https://www.landwatch.com",
        "listing_url_pattern": "https://www.landwatch.com/texas-land-for-sale/type-recreation",
        "asset_types": ["campground", "rv_park", "glamping"],
        "anti_bot_risk": "medium",
        "status": "active",
        "notes": "LandWatch lists campground/recreational properties for sale. "
                 "TX recreational land filter surfaces RV parks and retreat centers. "
                 "Medium bot risk from cloud; residential should work.",
    },
    {
        "id": "texashotelbrokerage",
        "name": "Texas Hotel Brokerage",
        "base_url": "https://www.texashotelbrokerage.com",
        "listing_url_pattern": "https://www.texashotelbrokerage.com/listings/",
        "asset_types": ["boutique_hotel"],
        "anti_bot_risk": "low",
        "status": "active",
        "notes": "TX-specific boutique hotel brokerage. Small site, minimal bot defense. "
                 "Limited inventory but very relevant (Hill Country, Gulf Coast).",
    },
    {
        "id": "innrealty",
        "name": "Inn Realty / B&B Realty",
        "base_url": "https://www.innrealty.com",
        "listing_url_pattern": "https://www.innrealty.com/properties/",
        "asset_types": ["inn", "boutique_hotel"],
        "anti_bot_risk": "low",
        "status": "deferred",
        "notes": "Niche B&B/inn broker. Limited national inventory. "
                 "Defer in favor of bedandbreakfast.com which has more volume.",
    },
    {
        "id": "outdoorresorthomes",
        "name": "Outdoor Resort Homes & Communities",
        "base_url": "https://www.outdoorresorthomes.com",
        "listing_url_pattern": "https://www.outdoorresorthomes.com/rv-resort-for-sale/",
        "asset_types": ["rv_park", "campground"],
        "anti_bot_risk": "low",
        "status": "deferred",
        "notes": "Niche RV resort community listings. Low volume but very on-target. "
                 "Defer after core scrapers ship.",
    },
]

# Lookup by id
SOURCE_BY_ID = {s["id"]: s for s in SOURCE_CATALOG}

ASSET_TYPES_ALL = [
    "rv_park", "campground", "boutique_hotel", "glamping", "self_storage", "inn"
]


def sources_for_buy_box(asset_types: list[str]) -> list[dict]:
    """Return active sources that cover at least one requested asset type."""
    return [
        s for s in SOURCE_CATALOG
        if s["status"] == "active"
        and any(at in s["asset_types"] for at in asset_types)
    ]
