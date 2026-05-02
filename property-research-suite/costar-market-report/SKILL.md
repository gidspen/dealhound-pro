---
name: costar-market-report
description: >
  Pulls a CoStar market-level report on a specified market (e.g. "Austin
  boutique hotels", "San Diego hospitality", "Palm Springs micro resorts"),
  captures key screenshots, and downloads the standard market report PDF.
  Assumes an authenticated CoStar session is already open (use the
  costar-login skill first if not). Use this skill whenever Gideon asks for
  "a market report on [market]", "CoStar market data for [market]",
  "research the [market] hotel market", "pull market intel on [market]",
  "what's CoStar showing for [market]", or any variation of pulling
  market-level (not property-specific) intel from CoStar.
---

# CoStar Market Report

You're pulling a CoStar **market-level** report (not a single property —
this covers a market or submarket). Examples:

- "Austin boutique hotels"
- "San Diego hospitality, all classes"
- "Palm Springs micro resorts and STRs"

This skill is the market analog of `costar-property-report`. Output goes
to the markets layer of the knowledge base, not the properties layer.

## Inputs

- `market` — free-text market specification, e.g. "Austin boutique hotels"
  or just "Austin TX"
- `(optional) submarket_or_property_type_filter` — if Gideon wants to
  narrow scope (e.g. "boutique only", "under 50 keys", "all hospitality
  excluding extended stay")

## Step 0 — Resolve the market slug

Before pulling, derive the market slug:

- City + state, lowercased, hyphenated: `austin-tx`, `san-diego-ca`,
  `palm-springs-ca`, `seattle-wa`
- Use this slug for filenames and the archive folder

If the market is a submarket of a larger MSA (e.g. "downtown Austin"),
slug as `austin-tx-downtown` so it nests under the parent market when
sorted.

## Prerequisites

CoStar must be logged in. If you're not sure, run `costar-login` first.

## Step 1 — Navigate to the market view

<TBD — capture during first run:
- Where in CoStar to find market-level analytics (Market Analytics tab?
  Comp Set tool? Report builder?)
- How to specify the geography filter
- How to specify the property type filter
- Whether there's a "Saved Reports" pattern Gideon uses>

## Step 2 — Capture key screenshots

Once on the market view, capture screenshots of:

<TBD — capture during first run. Likely candidates:
- Market overview / summary stats (avg $/key, $/sqft, cap rates, transaction volume)
- Recent transactions list
- Submarket breakdown
- Property type distribution
- Trend charts (12-month, 24-month, 5-year)>

Save each as `screenshots/{market-slug}-{section}.png`.

## Step 3 — Download the market report

<TBD — capture during first run:
- Which export/report button (Market Analytics export? Custom Report?)
- Format (PDF / Excel / both?)
- How long the download takes
- Default filename CoStar gives the file
- Where the file lands>

Rename the downloaded file to
`market-report-{market-slug}-{YYYY-MM-DD}.pdf` and move it to a working
directory the orchestrator can pick up (default
`/Users/gideonspencer/dealhound-pro/property-data/markets/{market-slug}/reports/`).

## Output

Return to the caller:
- `market_slug` — the market slug
- `market_display_name` — e.g. "Austin, TX — Boutique Hotels"
- `report_path` — absolute path to the downloaded PDF
- `screenshot_paths` — list of screenshot paths
- `summary_bullets` — 4-6 bullet points pulled directly from the market view
  (avg $/key, $/sqft, cap rate range, transaction count last 12 months,
  trend direction, notable comps). This becomes the email body and feeds
  the market brief synthesis.
- `key_metrics` — structured numeric values ready for `update-market-brief`
  to ingest:
  ```json
  {
    "avg_price_per_key": 165000,
    "avg_price_per_sqft": 320,
    "median_cap_rate": 0.072,
    "transaction_count_ttm": 18,
    "trend_direction": "compressing",
    "as_of_date": "2026-04-26"
  }
  ```

## Edge cases

- **Market not found / too narrow** → tell Gideon and ask if he wants to
  broaden the filter.
- **Market too broad** (CoStar truncates results) → suggest a submarket
  or property type filter.
- **Report unavailable for this filter** → capture screenshots and the
  market view as a PDF instead, note the limitation in the summary.
