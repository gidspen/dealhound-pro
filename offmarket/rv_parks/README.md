# RV Parks — Off-Market Lead Pipeline POC

POC for the off-market property product, targeting under-managed TX RV parks
and campgrounds suitable for conversion to micro-resort/glamping operations.

## Status

POC — illustrative scoring on a curated TX sample of 15 real parks.
Pipeline runs end-to-end. Real CAD / probate / tax-roll enrichment ships
in v1.1 (post-validation).

## What's in v1 (this POC)

- **Spine loader** (`spine.py`) — KOA + ARVC + Good Sam + Google Places.
  Cloud sandboxes get 403s from these directories, so the loader falls back
  to a curated sample (`sample_spine.py`) of 15 real TX parks. Locally on
  a residential IP, the live scrapers populate the spine.
- **Scoring engine** (`score.py`) — two independent 0-100 scores per lead:
  - **Motivation score** — probability owner engages (probate, length-held,
    OV65, out-of-state, tax delinquent, LLC forfeited, inherited deed, etc.)
  - **Conversion fitness score** — RV-park-to-micro-resort suitability
    (Hill Country proximity, acreage, pad count, independent vs chain,
    highway access, nightly-rate gap to glamping comps)
- **Geo helpers** (`geo.py`) — Hill Country anchor proximity + secondary
  corridors (Gulf Coast, East TX) for the conversion-thesis fit.
- **Buy-box filter** (`run.py`) — hard gates on state, asset type, pad
  count, acreage, chain inclusion. Match summary is surfaced per lead.
- **Lead card UI** (`preview.html`) — two-score card layout with motivation
  signals, conversion signals, buy-box match, and outreach action stubs.

## What's deferred (v1.1+)

- Live CAD enrichment per park (DCAD + BCAD work; other counties via
  `cad_registry.py` fallback paths). Currently motivation signals are
  mock-illustrated by a deterministic hash with two demo overrides.
- Probate court + obituary scraping per county
- Tax-delinquent rolls per county
- Operational signals (WHOIS, Wayback, Google reviews recency)
- Skip-tracing for phone + email
- Lob direct-mail API integration
- Dashboard route + Supabase persistence
- LLM-drafted personalized outreach per lead

## Running

```bash
# Live spine + enrichment (run from residential IP for unblocked sources)
GOOGLE_PLACES_API_KEY=... python3 -m offmarket.rv_parks.run

# Builds data/poc_leads.json. Then build the standalone preview:
python3 -m offmarket.rv_parks.build_preview

# Open offmarket/rv_parks/preview-standalone.html in a browser.
```

## Output schema (per lead)

```
{
  "name", "address", "city", "state", "zip", "lat", "lon",
  "source",                      # "koa" | "arvc" | "google_places" | "sample"
  "is_chain", "chain_name",
  "pad_count", "amenities",
  "buy_box_match": ["state TX ✓", "32 pads in target range", ...],
  "buy_box_passes": true,
  "motivation_score": 0-100,
  "motivation_signals": [{"key", "weight", "evidence"}, ...],
  "conversion_fitness_score": 0-100,
  "conversion_signals": [{"key", "weight", "evidence"}, ...],
  "corridor": {
    "primary_anchor": "Wimberley",
    "primary_distance_mi": 0.0,
    "corridor_zone": "hill_country_prime",
    ...
  },
  "tier": "HOT" | "STRONG" | "WATCH"
}
```

## File map

- `spine.py` — multi-source TX directory scraper
- `sample_spine.py` — curated 15-park TX sample + demo overrides
- `geo.py` — Hill Country proximity + tourism-corridor scoring
- `score.py` — motivation + conversion-fitness scoring engines
- `enrich.py` — per-park signal enrichment (currently mocked; real CAD/probate in v1.1)
- `run.py` — end-to-end pipeline runner with buy-box gating
- `build_preview.py` — bundles `poc_leads.json` into `preview-standalone.html`
- `preview.html` — lead-card UI template (fetches data/poc_leads.json)
- `preview-standalone.html` — self-contained version (data embedded)
- `data/poc_leads.json` — pipeline output

## Architecture notes

- **Spine inverted from CAD-first to directory-first** because most TX RV
  parks aren't in Dallas/Bexar (the only `works`-tier CADs per
  `cad_registry.py`). Directory-first gives statewide coverage; CAD is
  attempted per-park for enrichment, with `address_only` outreach as
  fallback for blocked counties.
- **Two independent scores** (motivation + conversion fitness) because
  HOT requires both. Surfacing them separately also lets users sort by
  either dimension.
- **Conversion-thesis-specific signals** (Hill Country distance, pad
  count band, independent-not-chain, nightly-rate gap) are the marketing
  wedge — generic property tools rank by motivation only.
