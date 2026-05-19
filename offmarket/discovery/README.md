# Off-Market Discovery Pipeline (v2 — Skillpack)

Dynamic per-buy-box source discovery + generic LLM extraction + memory-driven self-improvement.

**Why v2:** v1 used a static catalog of 24 broker URLs. Broker sites churn, new niche marketplaces appear, and the relevant pool differs per buy box. v2 discovers sources live every run, learns which ones yield, and adds cached fast paths as patterns prove out. See [`SKILL.md`](SKILL.md) for the full skill instructions (agent-editable).

## Quick Start

```bash
# Install deps
pip install requests beautifulsoup4 anthropic

# Required for discovery + extraction
export ANTHROPIC_API_KEY=sk-ant-...

# Run with example buy box (TX RV parks)
python3 -m offmarket.discovery.run \
  --buy-box data/buy_box_rv_parks_tx.json \
  --no-persist

# Broader hospitality buy box (national, all verticals)
python3 -m offmarket.discovery.run \
  --buy-box data/buy_box_hospitality_national.json \
  --no-persist
```

## CLI Options

```
--buy-box PATH         Buy-box JSON (required)
--output PATH          Output file (default: data/discovered_listings.json)
--sources SRC...       Limit pinned scrapers to these IDs
--states ST...         Override states (e.g. TX TN NC)
--min-sources N        Minimum dynamic candidates to seek (default: 15)
--skip-discovery       Run only pinned scrapers
--skip-pinned          Run only dynamic discovery
--dry-run              Skip Supabase write
--no-persist           Skip Supabase entirely
--verbose              Debug logging
```

## How it works

```
buy_box.json
     │
     ▼
[1] load memory  →  per-buy-box source state (yields, demotions)
     ▼
[2] pinned scrapers  →  scrapers/*.py (rvparkstore, businessbroker, …)
     ▼
[3] dynamic discovery  →  Claude + web_search → ≥15 candidate sources
     ▼
[4] revisit active known sources from memory
     ▼
[5] for each source: get(url) → extract_generic.extract_listings()
     ▼
[6] buy-box filter (asset_type, geo, price band, size band)
     ▼
[7] persist (local JSON + Supabase) + update memory
```

## Verified run (2026-05-19)

```
TX RV parks buy box, --skip-pinned (dynamic discovery only):
  Sources attempted: 28
  Total matched: 25
  
  ✓ nstarba_com                   broker         18 raw
  ✓ naiohb_com                    broker         15 raw
  ✓ parksandplaces_com            broker          9 raw
  ✓ thecampgroundconnection_com   marketplace     6 raw
  ✓ thecampgroundmarketplace_com  marketplace     5 raw
  ✓ jtacr_com                     broker          5 raw
  ✓ rvparksforsale_com            broker          3 raw
  ✓ dealstream_com                marketplace     1 raw
  ✗ 20 others (404 / 403 / gated / 0-yield → auto-demote after 3 runs)

Real deals surfaced:
  Fountain Springs RV Development   $1,950,000  Whitewright, TX
  Central Texas RV Park             $3,150,000  Central Texas, TX
  Blue Ridge RV Park                $1,000,000  Blue Ridge, TX
  …plus 22 more
```

With pinned scrapers enabled (rvparkstore, businessbroker_campground), expect total matched to roughly double for TX-specific buy boxes (often 50–100+ listings).

## Normalized Listing Schema

```json
{
  "source": "nstarba_com",
  "url": "https://nstarba.com/listings/...",
  "title": "Seven Lakes RV Resort",
  "location": "Buchanan Dam, TX",
  "asking_price": null,
  "asset_type": "rv_park",
  "size_metric": "120 Lots",
  "description": null,
  "posted_date": null,
  "broker_name": null,
  "broker_phone": null,
  "broker_email": null,
  "scraped_at": "2026-05-19T14:28:51Z"
}
```

`asset_type` values: `rv_park | campground | boutique_hotel | glamping | self_storage | inn`

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

## Tests (governance for self-improvement)

```bash
# Fast, no API key needed
pytest offmarket/discovery/tests/test_buy_box_filter.py offmarket/discovery/tests/test_new_scraper_smoke.py

# Live (requires ANTHROPIC_API_KEY, ~$0.05–$1 each)
pytest offmarket/discovery/tests/test_extract_generic.py
pytest offmarket/discovery/tests/test_min_sources.py
pytest offmarket/discovery/tests/test_novel_sources.py
pytest offmarket/discovery/tests/test_yield.py
```

| Test | Locks down |
|------|-----------|
| `test_buy_box_filter` | Filter logic (pure unit) |
| `test_new_scraper_smoke` | Every scraper imports + `scrape()` returns list |
| `test_extract_generic` | Generic extractor returns ≥10 listings from real HTML fixture |
| `test_min_sources` | `discover_sources` returns ≥15 valid candidates, ≥1 marketplace |
| `test_novel_sources` | Two runs surface ≥N new sources (N per-asset from `expected_churn.json`) |
| `test_yield` | End-to-end ≥30 matched listings for known buy box |

## File Structure

```
offmarket/discovery/
├── SKILL.md                # the skill — agent-editable instructions
├── README.md               # this file
├── run.py                  # CLI orchestrator
├── base.py                 # Listing + HTTP helpers
├── filter.py               # buy-box hard gates
├── sources.py              # pinned/cached scraper catalog
├── source_discovery.py     # Claude + web_search → CandidateSource[]
├── source_memory.py        # per-buy-box yield/demotion state
├── extract_generic.py      # Claude reads HTML → Listing[]
├── loader.py               # Supabase upsert
├── scrapers/               # cached fast paths
└── tests/                  # governance suite + fixtures
```

## Supabase persistence

Migration: [`supabase/migrations/20260518000000_create_discovered_listings.sql`](../../supabase/migrations/20260518000000_create_discovered_listings.sql)

Table: `discovered_listings`. Dedup key: `(source, url)` — idempotent upserts via `loader.py`.

```bash
export SUPABASE_URL=https://your-project.supabase.co
export SUPABASE_PAT=your-personal-access-token

python3 -m offmarket.discovery.run --buy-box data/buy_box_rv_parks_tx.json
# (no --no-persist enables Supabase write)
```
