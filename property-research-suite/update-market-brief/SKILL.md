---
name: update-market-brief
description: >
  Updates Gideon's rolling market brief in the property-data knowledge base
  whenever new market intel comes in — whether from a per-property pull,
  a direct CoStar market report, a podcast guest comment, a broker call,
  or a member share. Appends to the market's data-points.md ledger and
  re-derives the synthesis in brief.md so future questions about that
  market draw on everything we've ever learned. Called by both
  property-research-orchestrator (after archive-property-docs) and
  market-research-orchestrator (after archive-market-report). Can also be
  invoked standalone when Gideon says "log this for the {market} brain",
  "add this to our market intel", "update the market brief with {fact}",
  or when a podcast guest, broker, or member drops a useful market data
  point worth capturing. Also use in lookup mode for "what do we know
  about {market}", "summarize our intel on {market}", "what comps do we
  have in {market}".
---

# Update Market Brief

You're maintaining Gideon's compounding market memory. Three things feed
this skill:

1. **Property pulls** — every property archived in `properties/` triggers
   a contribution to the relevant market brief.
2. **Direct market reports** — every market-level CoStar report archived
   in `markets/{slug}/reports/` triggers a fuller contribution with
   structured key metrics.
3. **Free-text intel** — anything else worth capturing (podcast guest
   comment, broker call, member share, news article).

Your job is to take the input, append to the ledger, and re-synthesize the
brief. The ledger is append-only history; the brief is a living synthesis.

## Knowledge base path

```
/Users/gideonspencer/dealhound-pro/property-data/markets/{market-slug}/
├── brief.md           ← the rolling synthesis you maintain
└── data-points.md     ← append-only ledger of contributions
```

Schema for `brief.md`:
`/Users/gideonspencer/dealhound-pro/property-data/_schema-market-brief.md`

## Inputs (three modes)

### Mode A — Called from property-research-orchestrator

- `source_type: "property-pull"`
- `market_slug` — e.g. `austin-tx`
- `property_slug` — the property contributing data
- `property_meta` — meta.json contents from the property folder
- `summary_bullets` — bullets from the CoStar property pull

### Mode B — Called from market-research-orchestrator

- `source_type: "direct-market-report"`
- `market_slug`
- `source_info` — the payload from `archive-market-report`:
  - `report_file` — filename of the archived PDF
  - `filter_scope` — e.g. "boutique hotels only"
  - `pulled_at`, `pulled_by`
  - `emailed_to`, `thread_url`
- `summary_bullets`
- `key_metrics` — structured numeric data (avg $/key, cap rates, etc.)

### Mode C — Standalone (free-text contribution)

- `source_type: "podcast" | "broker-call" | "member-share" | "news" | "other"`
- `market_slug`
- `data_point` — free-text observation
- `source` — who said it, where (with URL if available)

## Step 1 — Resolve the market folder

If `markets/{market-slug}/` doesn't exist:
1. Create it with `reports/`, `screenshots/`, plus `brief.md`,
   `data-points.md`, `notes.md` files.
2. Initialize `brief.md` with the canonical schema (read
   `_schema-market-brief.md` and fill in whatever's known).
3. Initialize `data-points.md` with just a header.
4. Append a new row to `markets/_index.md`.
5. Tell Gideon: "Created a new market folder for {market name} — first
   time we've added intel on this market."

## Step 2 — Append to data-points.md

This file is **append-only**. Never edit prior entries.

Format (adapt fields to mode):

```markdown
## {YYYY-MM-DD} — {short title}

**Source type:** {property-pull | direct-market-report | podcast | broker-call | member-share | news | other}
**Source link:** {relative path to property folder, or path to the market report PDF, or external URL, or "n/a"}
**Contributed by:** {Sophia | Gideon | etc.}

{The actual data — could be a transaction comp, an observation, a price
trend, a broker quote, whatever. Use bullets for structured data.}

---
```

**Mode A (property pull) example:**
```markdown
## 2026-04-26 — 1234 Main St, Austin TX (boutique hotel pull)

**Source type:** property-pull
**Source link:** [../../properties/1234-main-st-austin-tx-78701/](../../properties/1234-main-st-austin-tx-78701/)
**Contributed by:** Sophia

- Asking $4.2M, 24 keys, 12,500 sqft
- $/key: $175,000  ·  $/sqft: $336
- Last sale 2017 at $2.8M
- Built 1998, renovated 2019
- Independent flag, currently owner-operated

---
```

**Mode B (direct market report) example:**
```markdown
## 2026-04-26 — Austin boutique hotels — direct CoStar market report

**Source type:** direct-market-report
**Source link:** [./reports/market-report-austin-tx-2026-04-26.pdf](./reports/market-report-austin-tx-2026-04-26.pdf)
**Filter scope:** boutique hotels only
**Contributed by:** Sophia

- Avg $/key: $165,000 (median across 18 transactions, last 12 months)
- Avg $/sqft: $320
- Median cap rate: 7.2%
- Trend direction: compressing (cap rates down 80bps YoY)
- 18 transactions in TTM, vs 11 in prior year — volume up 64%

---
```

**Mode C (free-text) example:**
```markdown
## 2026-04-26 — Broker comment on Austin hospitality demand

**Source type:** broker-call
**Source link:** n/a
**Contributed by:** Gideon (via call with John Smith @ JLL)

- Broker reports that downtown Austin is seeing pricing pressure as
  remote-first tech employers reduce footprint, but east-side boutique
  product is holding strong with leisure demand.
- Expects more distressed deals in late 2026 from groups that overpaid
  in 2021-2022.

---
```

## Step 3 — Re-derive the brief

Read all of `data-points.md` and update affected sections of `brief.md`:

1. **Top metadata** — bump `Last Updated`, increment `Data Points On File`.
   If this came from a property pull, update `Properties Researched`. If
   it came from a direct market report, update `Direct Market Reports`.
2. **Market Snapshot** — 2-4 sentence opening. Refresh if the new data
   shifts the picture.
3. **Property Types We Track Here** — count entries by type.
4. **Recent Comps (Last 12 Months)** — re-build from transaction-class
   data points dated within the last 12 months. Sort newest first. For
   property-pull entries, link to the property folder. For
   direct-market-report entries, link to the report PDF.
5. **Pricing Trends** — recompute $/key, $/sqft, cap rate ranges and
   medians from the comps. For Mode B (direct reports), the `key_metrics`
   payload may already give you ranges and medians at the market level —
   prefer those over computing from comps when available, since they're
   more authoritative.
6. **Key Players** — add new brokers, operators, lenders mentioned.
7. **Demand Drivers** — add anything new the source surfaced.
8. **Observations & Trends** — append the new observation, attribute the
   source.
9. **Risks / Headwinds** — add any flagged in the new data.
10. **Open Questions** — leave existing, add new if surfaced.
11. **Source Reports** — for Mode B, append the new market report to the
    table.

The brief is a synthesis. Each section should reference the ledger entries
that drove the conclusions — `(from: 2026-04-26 broker-call entry)` or
similar inline citations are good.

## Step 4 — Update markets/_index.md

Update the row for this market with new counts and `Last Updated` date.

## Output

Return to the caller:
- `market_path` — absolute path to the market folder
- `brief_path` — absolute path to the updated brief
- `is_new_market` — true if folder was just created
- `data_points_total` — running count after this update
- `properties_researched_total` — running count
- `direct_market_reports_total` — running count

---

## Lookup mode

If Gideon asks "what do we know about {market}", "summarize our intel on
{market}", or similar:

1. Slugify the market name.
2. Read `markets/{market-slug}/brief.md` and report the synthesis.
3. If he wants more depth, read `data-points.md` for the raw history.
4. If asked specifically about market reports we've pulled, list the
   contents of `markets/{market-slug}/reports/`.
5. If the market doesn't exist yet, tell him "no intel on file for that
   market yet."

## Why this skill exists

Without it, every CoStar pull (property or market) would be a one-shot.
With it, year three of operating means the Austin market brief contains
50+ comps from property pulls + 12 direct market reports + assorted broker
comments + member contributions — and it's all synthesized, sourced, and
queryable. That's the whole point of treating this like a brain.
