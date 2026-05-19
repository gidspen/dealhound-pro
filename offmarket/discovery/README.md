# Off-Market Discovery Pipeline

Scrapes 20+ niche broker sites that aggregators (LoopNet, Crexi, BizBuySell) don't cover.
Surfaces listings matching a user's buy box. Source selection is buy-box-aware.

## Quick Start

```bash
# Install deps
pip install requests beautifulsoup4

# Run with example buy box (TX RV parks, $500K–$5M)
python3 -m offmarket.discovery.run \
  --buy-box data/buy_box_rv_parks_tx.json \
  --output data/discovered_listings.json \
  --no-persist

# Run with broader hospitality buy box (national, all verticals)
python3 -m offmarket.discovery.run \
  --buy-box data/buy_box_hospitality_national.json \
  --output data/discovered_listings.json \
  --no-persist
```

## CLI Options

```
python3 -m offmarket.discovery.run --help

  --buy-box PATH    Buy-box JSON (required)
  --output PATH     Output file (default: data/discovered_listings.json)
  --sources SRC...  Limit to specific source IDs
  --states ST...    Override states (e.g. TX TN NC)
  --dry-run         Skip Supabase write, still writes local JSON
  --no-persist      Skip Supabase entirely
  --verbose         Debug logging
```

## Normalized Listing Schema

```json
{
  "source": "rvparkstore",
  "url": "https://www.rvparkstore.com/rv-parks/7035108-...",
  "title": "Lost Buoys RV Resort",
  "location": "1543 Farm To Market Road 1781, Rockport, TX 78382",
  "asking_price": 1575000,
  "asset_type": "rv_park",
  "size_metric": "39 Lots",
  "description": null,
  "posted_date": null,
  "broker_name": null,
  "broker_phone": null,
  "broker_email": null,
  "scraped_at": "2026-05-18T23:42:09.513Z"
}
```

**asset_type values:** `rv_park` | `campground` | `boutique_hotel` | `glamping` | `self_storage` | `inn`

## Buy-Box JSON Format

```json
{
  "asset_types": ["rv_park", "campground"],
  "geo": {
    "states": ["TX", "TN"],
    "regions": ["Hill Country"]
  },
  "price_min": 500000,
  "price_max": 5000000,
  "size_min": 10,
  "size_max": 300,
  "include_undisclosed_price": true
}
```

- `states`: 2-letter codes; `null` = national
- `regions`: substring match on location; `null` = any
- `size_min/max`: applies to numeric part of `size_metric` (lots, acres, units)
- `include_undisclosed_price`: include "Call for Price" listings

## Source Catalog — 24 Sources Documented

See [`sources.py`](sources.py) for full catalog. Summary below.

### ✅ Confirmed Working (from cloud AND residential IP)

| ID | Site | Asset Types | Anti-Bot | Notes |
|----|------|------------|----------|-------|
| `rvparkstore` | RVParkStore.com | rv_park, campground | **low** | 193 national / 46 TX listings |
| `selfstorages` | SelfStorages.com | self_storage | **low** | 3 US listings (sister to RVParkStore) |
| `mobilehomeparkstore` | MobileHomeParkStore.com | rv_park | **low** | 232 national listings (sister site) |
| `businessbroker_campground` | BusinessBroker.net | campground, rv_park | **low** | `/keyword/campground-businesses-for-sale.aspx` |
| `businessbroker_hotel` | BusinessBroker.net | boutique_hotel | **low** | 60+ hotel listings |

### 🔶 Expected to Work from Residential IP (403 from cloud)

| ID | Site | Asset Types | Anti-Bot | Notes |
|----|------|------------|----------|-------|
| `bizquest_campground` | BizQuest.com | campground, rv_park | **medium** | Category ID 67. 403 from cloud |
| `bizquest_hotel` | BizQuest.com | boutique_hotel | **medium** | Category ID 29. 403 from cloud |
| `bizquest_storage` | BizQuest.com | self_storage | **medium** | Category ID 77. 403 from cloud |
| `bizquest_glamping` | BizQuest.com | glamping | **medium** | Keyword search |
| `bedandbreakfast` | BedAndBreakfast.com | inn | **low\*** | 429 from cloud (rate limit). Residential OK |
| `murphybusiness` | MurphyBusiness.com | multi | **medium** | 403 from cloud |
| `sunbelt` | SunbeltNetwork.com | multi | **high** | 403 confirmed. Largest US broker |
| `tworld` | Transworld Business Adv. | campground, hotel | **medium** | Medium bot risk |
| `landwatch_campground` | LandWatch.com | campground, rv_park | **medium** | 403 from cloud; use residential |
| `businessbroker_storage` | BusinessBroker.net | self_storage | **low** | Same site as hotel/campground |
| `texashotelbrokerage` | TexasHotelBrokerage.com | boutique_hotel | **low** | TX-only, low volume, minimal bot defense |

### ❌ Deferred / Not Available

| ID | Site | Reason |
|----|------|--------|
| `campgroundsforsale` | CampgroundsForSale.com | **Subscription-gated** — confirmed 2026-05-18. No public listings |
| `hrec` | HREC Investment Advisors | Advisory firm — not a listing marketplace |
| `mumford` | Mumford Company | SSL cert expired as of 2026-05-18 |
| `glampinghub` | GlampingHub | No public "for sale" marketplace |
| `tentrr` | Tentrr | Operator transitions via relationship only |
| `innrealty` | InnRealty.com | Tracking pixel only — no content |
| `outdoorresorthomes` | OutdoorResortHomes.com | Low volume; defer |

## Run Results (verified 2026-05-18, from cloud IP)

```
Sources run: 5
Total listings matched: 431

  ✓ rvparkstore                          170 raw  (national)
  ✓ mobilehomeparkstore                  232 raw  (national)
  ✓ businessbroker_hotel                  60 raw
  ✓ businessbroker_campground             10 raw
  ✓ selfstorages                           3 raw
```

From residential IP: add bizquest (estimated +50–100 campground/hotel), murphybusiness,
sunbelt, tworld, landwatch, bedandbreakfast.

## Supabase Schema

Migration: [`supabase/migrations/20260518000000_create_discovered_listings.sql`](../../supabase/migrations/20260518000000_create_discovered_listings.sql)

Table: `discovered_listings`  
Dedup key: `(source, url)` — idempotent upserts via `loader.py`

Set environment variables to enable persistence:
```bash
export SUPABASE_URL=https://your-project.supabase.co
export SUPABASE_PAT=your-personal-access-token

python3 -m offmarket.discovery.run --buy-box data/buy_box_rv_parks_tx.json
# (no --no-persist = enables Supabase write)
```

## File Structure

```
offmarket/discovery/
├── README.md           # This file
├── __init__.py
├── base.py             # Listing dataclass + HTTP helpers
├── sources.py          # 24-source catalog
├── filter.py           # Buy-box filter (hard gates + recency sort)
├── run.py              # CLI entry point
├── loader.py           # Supabase persistence (idempotent upsert)
└── scrapers/
    ├── __init__.py
    ├── rvparkstore.py           # RVParkStore.com (CONFIRMED)
    ├── nicheinvestments.py      # SelfStorages.com + MobileHomeParkStore.com
    ├── businessbroker.py        # BusinessBroker.net (CONFIRMED)
    ├── bizquest.py              # BizQuest.com (residential IP)
    ├── bedandbreakfast.py       # BedAndBreakfast.com (residential IP)
    ├── campgroundsforsale.py    # CampgroundsForSale.com (gated — stub)
    ├── murphybusiness.py        # Murphy Business Sales (residential IP)
    ├── sunbelt.py               # Sunbelt Business Brokers (residential IP)
    ├── tworld.py                # Transworld Business Advisors (residential IP)
    ├── landwatch.py             # LandWatch.com (residential IP)
    └── texashotelbrokerage.py   # Texas Hotel Brokerage (low volume)
```

## Extending — Adding a New Source

1. Add entry to `SOURCE_CATALOG` in `sources.py`
2. Write `scrapers/mynewsource.py` returning `list[Listing]`
3. Add dispatch case in `run.py → _run_scraper()`
4. Test: `python3 -c "from offmarket.discovery.scrapers.mynewsource import scrape; print(len(scrape()))"`
