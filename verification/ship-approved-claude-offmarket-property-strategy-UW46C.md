## Intent

Adds `offmarket/discovery/` — a buy-box-aware niche broker scraper that
aggregates 24 hospitality/RV/self-storage broker sites (RVParkStore,
BusinessBroker.net, NicheInvestments sister sites, BizQuest, Sunbelt,
Murphy, Transworld, LandWatch, and more) that major aggregators don't cover.
Ships as `python3 -m offmarket.discovery.run --buy-box <file>`, producing a
deduplicated `discovered_listings.json` with Supabase persistence stub.
Verified: 431 real listings from 5 confirmed sources in one laptop run.

## Files Changed

- `offmarket/discovery/__init__.py` — package marker
- `offmarket/discovery/base.py` — Listing dataclass + HTTP helpers
- `offmarket/discovery/sources.py` — 24-source catalog with anti-bot risk and status
- `offmarket/discovery/filter.py` — buy-box hard gates (asset_type, geo, price, size)
- `offmarket/discovery/run.py` — CLI runner with incremental saves and Supabase dispatch
- `offmarket/discovery/loader.py` — Supabase upsert stub (dedup on source+url)
- `offmarket/discovery/README.md` — how to run, schema, confirmed vs deferred sources
- `offmarket/discovery/scrapers/__init__.py` — package marker
- `offmarket/discovery/scrapers/rvparkstore.py` — RVParkStore.com (CONFIRMED 46 TX, 193 national)
- `offmarket/discovery/scrapers/nicheinvestments.py` — SelfStorages.com + MobileHomeParkStore.com
- `offmarket/discovery/scrapers/businessbroker.py` — BusinessBroker.net campground + hotel
- `offmarket/discovery/scrapers/bizquest.py` — BizQuest.com (campground/hotel/storage; residential IP)
- `offmarket/discovery/scrapers/bedandbreakfast.py` — BedAndBreakfast.com inn listings
- `offmarket/discovery/scrapers/campgroundsforsale.py` — CampgroundsForSale.com (stub; gated)
- `offmarket/discovery/scrapers/murphybusiness.py` — Murphy Business Sales
- `offmarket/discovery/scrapers/sunbelt.py` — Sunbelt Business Brokers
- `offmarket/discovery/scrapers/tworld.py` — Transworld Business Advisors
- `offmarket/discovery/scrapers/landwatch.py` — LandWatch recreational land
- `offmarket/discovery/scrapers/texashotelbrokerage.py` — Texas Hotel Brokerage
- `supabase/migrations/20260518000000_create_discovered_listings.sql` — discovered_listings table + RLS
- `data/buy_box_rv_parks_tx.json` — example TX RV park buy box
- `data/buy_box_boutique_hotels_tx.json` — example TX hotel buy box
- `data/buy_box_hospitality_national.json` — example national all-vertical buy box

## Confirmation

No files outside the intended scope were modified.
