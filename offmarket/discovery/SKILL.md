# Off-Market Discovery Skill

A self-improving skill for finding off-market property listings (RV parks, boutique hotels, campgrounds, self-storage, glamping, inns) across a dynamic pool of broker sites and niche marketplaces.

This file is the skill's instructions — agent-editable markdown. When you (the agent) encounter a new case worth permanently absorbing, edit this file, add tests, and commit. Treat it like code.

---

## Mental model

**The source pool moves.** Brokers come and go. New niche marketplaces launch. A buy box for "RV parks in TX" pulls in a different set of sources than "boutique hotels in Hill Country." Static catalogs rot — that's why this skill discovers sources dynamically per buy box, every run.

**A "source" is anywhere multiple matching for-sale properties (or one relevant property) can be extracted in a single scrape.** Three kinds:
- `broker` — a brokerage's category/listings page (e.g. BusinessBroker.net hotels)
- `marketplace` — a vertical aggregator (e.g. RVParkStore.com)
- `single-listing` — a tiny regional broker with one matching property

**Two scraping paths:**
- **Pinned (cached fast paths)** — hand-coded scrapers in `scrapers/` for high-volume known winners. Cheap and fast.
- **Generic LLM extraction** — Claude reads arbitrary HTML and returns Listings. Handles everything else. Costs ~$0.03–$0.10 per source per run.

---

## Per-run pipeline

```
buy_box.json
     │
     ▼
[1] load memory  ───  offmarket/discovery/memory/{bbid}.json
     │                   ├── active known sources (yielded recently)
     │                   └── demoted sources  (3+ consecutive zero runs)
     ▼
[2] pinned scrapers (skip with --skip-pinned)
     │   → scrapers/rvparkstore.py, businessbroker.py, nicheinvestments.py, …
     ▼
[3] dynamic source discovery (skip with --skip-discovery)
     │   → source_discovery.discover_sources(buy_box, seed_known=memory+pinned)
     │   → at least --min-sources (default 15) candidates from web search + Claude
     ▼
[4] re-check active known sources from memory not covered above
     ▼
[5] for each new/known source URL:
     │     html = base.get(url)
     │     listings = extract_generic.extract_listings(html, url, asset_types)
     │
     ▼
[6] buy-box filter (filter.py)
     │   gates: asset_type, geo.states, geo.regions, price band, size band
     ▼
[7] persist:
       ├── local JSON (data/discovered_listings.json)
       ├── source_memory updated (yield counts, auto-demotion)
       └── Supabase (unless --no-persist)
```

---

## CLI

```bash
python3 -m offmarket.discovery.run --buy-box data/buy_box_rv_parks_tx.json
python3 -m offmarket.discovery.run --buy-box buy_box.json --min-sources 20
python3 -m offmarket.discovery.run --buy-box buy_box.json --skip-discovery   # pinned only
python3 -m offmarket.discovery.run --buy-box buy_box.json --skip-pinned      # discovery only
python3 -m offmarket.discovery.run --buy-box buy_box.json --no-persist       # skip Supabase
```

Required env: `ANTHROPIC_API_KEY` (for discovery + generic extraction). Optional: `SUPABASE_PAT` + `SUPABASE_URL` for persistence.

---

## When to modify this skill

You (the agent) have explicit permission to evolve the skill in these ways. **Every modification must pass `tests/` before commit.**

### Promote: add a cached scraper

If a source consistently yields ≥10 listings via generic extraction for **3+ consecutive runs**, write a dedicated scraper module in `scrapers/`. Why: cheaper, faster, more reliable than re-paying for LLM extraction.

How:
1. Inspect the HTML once (`curl`, save to `tests/fixtures/<source>.html`)
2. Write `scrapers/<source>.py` with a `scrape(states=None, ...) -> list[Listing]` function following the pattern in [`scrapers/businessbroker.py`](scrapers/businessbroker.py)
3. Add a dispatch case in [`run.py::_run_pinned_scraper`](run.py)
4. Add the source to `sources.py::SOURCE_CATALOG` with `status="active"`
5. Run `pytest offmarket/discovery/tests/test_new_scraper_smoke.py` — must pass before commit

### Demote: source memory handles this automatically

`source_memory.record_run_result()` auto-demotes a source after `ZERO_YIELD_DEMOTE_THRESHOLD` (default 3) consecutive zero-yield runs. A successful yield reactivates a demoted source. **Don't manually demote unless you see a hard signal** (404, ToS change, subscription wall).

### Update expected churn thresholds

`tests/fixtures/expected_churn.json` defines how many new sources `discover_sources` must surface per run per asset class. If a class's threshold is too aggressive (test flakes) or too lax (we miss new brokers), edit the JSON and commit. Always note the calibration data in the commit message.

### Refine prompts

`extract_generic.SYSTEM_PROMPT` and `source_discovery.SYSTEM_PROMPT` are tuned to current broker HTML patterns. If you see extraction failing on a new pattern (e.g. a marketplace renders prices in a non-standard format), refine the prompt and add a fixture-based regression test for the new pattern.

---

## Governance: tests (run before any commit)

```bash
pytest offmarket/discovery/tests/ -v
```

| Test | What it locks down |
|------|--------------------|
| [`test_buy_box_filter.py`](tests/test_buy_box_filter.py) | Filter logic — pure unit test, always runs |
| [`test_new_scraper_smoke.py`](tests/test_new_scraper_smoke.py) | Every scraper module imports + `scrape()` returns a list |
| [`test_extract_generic.py`](tests/test_extract_generic.py) | Generic extractor returns ≥10 listings from a real HTML fixture (live, ~$0.05) |
| [`test_min_sources.py`](tests/test_min_sources.py) | `discover_sources` returns ≥15 valid candidates including ≥1 marketplace (live) |
| [`test_novel_sources.py`](tests/test_novel_sources.py) | Two runs of `discover_sources` surface ≥N new sources (N from expected_churn.json by asset class) (live) |
| [`test_yield.py`](tests/test_yield.py) | End-to-end pipeline yields ≥30 matched listings for a known buy box (live, ~$1) |

Live tests skip cleanly when `ANTHROPIC_API_KEY` is unset.

---

## Data shapes

### Listing ([`base.py`](base.py))

```python
@dataclass
class Listing:
    source: str           # e.g. "rvparkstore" or "businessbroker_net"
    url: str
    title: str
    location: str         # "City, ST" or street address
    asking_price: int | None   # dollars; None = "Call for Price" / undisclosed
    asset_type: str       # rv_park | campground | boutique_hotel | glamping | self_storage | inn
    size_metric: str | None    # "39 Lots", "84 acres", "120 units"
    description: str | None
    posted_date: str | None
    broker_name: str | None
    broker_phone: str | None
    broker_email: str | None
    scraped_at: str       # ISO datetime
```

### Buy box

```json
{
  "asset_types": ["rv_park", "campground"],
  "geo": {"states": ["TX"], "regions": ["Hill Country"]},
  "price_min": 500000, "price_max": 5000000,
  "size_min": 10, "size_max": 300,
  "include_undisclosed_price": true
}
```

### SourceRecord ([`source_memory.py`](source_memory.py))

Persistent per-buy-box state: yield history, churn signals, demotion status. Files at `memory/{bbid}.json` (gitignored — per-machine working state).

---

## Where things live

```
offmarket/discovery/
├── SKILL.md                 # this file
├── run.py                   # CLI orchestrator
├── base.py                  # Listing dataclass, HTTP helpers
├── filter.py                # buy-box hard gates
├── sources.py               # pinned/cached scraper catalog
├── source_discovery.py      # dynamic discovery (Claude + web_search)
├── source_memory.py         # per-buy-box yield/demotion state
├── extract_generic.py       # generic LLM HTML → Listing[] extractor
├── loader.py                # Supabase persistence (PAT auth)
├── scrapers/                # cached fast paths
│   ├── rvparkstore.py
│   ├── nicheinvestments.py  # selfstorages + mobilehomeparkstore (same HTML)
│   ├── businessbroker.py
│   ├── bizquest.py          # residential IP only
│   ├── bedandbreakfast.py
│   ├── murphybusiness.py
│   ├── sunbelt.py
│   ├── tworld.py
│   ├── landwatch.py
│   └── texashotelbrokerage.py
├── memory/                  # per-machine, gitignored
│   └── {bbid}.json
└── tests/
    ├── test_buy_box_filter.py
    ├── test_new_scraper_smoke.py
    ├── test_extract_generic.py
    ├── test_min_sources.py
    ├── test_novel_sources.py
    ├── test_yield.py
    └── fixtures/
        ├── expected_churn.json
        └── *.html
```
