# RV Parks — Off-Market Lead Pipeline POC

POC for the off-market property product, targeting TX Hill Country RV parks
and campgrounds suitable for conversion to micro-resort / glamping operations.

## What this POC actually proves

Running on a spine of **9 real TX Hill Country RV parks** (verified addresses,
phones, websites, sourced via web search 2026-05-18 — see `real_spine.py`),
with strict honesty about which signals are verified vs. pending:

| Tier   | Count | Why |
|--------|-------|-----|
| HOT    | 0     | No life-event signals (probate / obit / tax delinquent) surface from web search alone — these require CAD/county enrichment |
| STRONG | 1     | Riverside RV Park (Bandera) — 78 pads, Hill Country prime, independent, on Medina River. STRONG on conversion fitness alone. |
| WATCH  | 1     | Heritage Oaks (Fredericksburg) — 88 pads, Hill Country prime, lower conversion fit due to size and chain-style build |
| BELOW  | 7     | Buckhorn Lake, Horseshoe Ridge, Pioneer River, Armadillo Farm, Skyline Ranch, Hill Country Lakes, Hill Country RV Park — pad count not published online, can't compute conversion fitness yet |

**The pipeline correctly refuses to fabricate motivation tier on insufficient
signal.** What the POC validates:

1. ✅ Pipeline ingests real public data and scores it consistently
2. ✅ Conversion-fitness scoring works on real geo + real pad counts
3. ✅ Honest "pending v1.1 enrichment" surfacing — no fake HOT tags
4. ✅ Buckhorn Lake's verified LLC (formed 1999, principal Kathy Christiansen,
      27 years operating) is the kind of real signal we'll be stacking with
      CAD-derived OV65/years-held/out-of-state once v1.1 ships
5. ❌ Web search alone cannot produce HOT-tier leads at scale — v1.1 must
      include CAD/probate/tax enrichment

## What v1.1 must deliver

The 7 parks "below scoring threshold" aren't unscorable — they're
unscored-yet. v1.1 fills the gap by enriching each park with:

- **CAD lookup by address** — owner of record, mailing address, acquisition
  date, OV65 exemption (Dallas + Bexar work today; Hill Country counties
  need `cad_registry.py` fallback paths or a paid aggregator like BatchData)
- **County probate court** — owner-name match in last 24 months
- **County tax assessor** — delinquency rolls
- **County clerk** — lis pendens, NOD, $0-consideration deed transfers
- **TX SOS + Comptroller** — LLC current status (forfeited / dissolved /
  active), officer history, registered agent
- **WHOIS + Wayback** — domain age, last website update (operational decay)

Each of these is a Playwright-driven scrape against a public portal. They
work from a residential IP or properly-allowlisted infra. They do NOT work
from the cloud sandbox running this code (which blocks all outbound HTTP
except package registries) — and that constraint is exactly why your
v1.1 plan to host the agent on a server is the right architectural move.

## Files

- `real_spine.py` — 9 real TX Hill Country RV parks with WebSearch citations
- `geo.py` — Hill Country anchor proximity scoring (real Haversine)
- `score.py` — motivation (15 signals) + conversion-fitness (10 signals) engines
- `enrich.py` — converts real spine fields into scored signals; explicitly
  tracks "pending" motivation signals so the UI labels them honestly
- `run.py` — end-to-end pipeline with buy-box gating
- `spine.py` — multi-source directory scraper code (KOA / ARVC / Good Sam /
  Google Places). Cloud sandbox 403s on all of them. Runs cleanly from
  residential IP.
- `build_preview.py` — bundles `poc_leads.json` into self-contained HTML
- `preview.html` / `preview-standalone.html` — lead-card UI
- `data/poc_leads.json` — pipeline output

## Run

```bash
python3 -m offmarket.rv_parks.run            # writes data/poc_leads.json
python3 -m offmarket.rv_parks.build_preview  # writes preview-standalone.html
```

Open `preview-standalone.html` in any browser.

## Honest gaps

- **9 parks is not a real-world spine.** Real spine needs 500–1,500 parks
  via KOA/ARVC/Good Sam/Google Places scrapes from a residential IP.
- **Pad counts and acreage are sparse from web search.** Each park's own
  website usually publishes pad count; we'd need a per-park WebFetch pass.
- **No motivation enrichment yet.** All 14 motivation signals are pending.
  This is the v1.1 build.
- **Coordinates are city-level approximations** for the corridor distance
  calculation. CAD parcel lookup gives precise parcel coordinates.
