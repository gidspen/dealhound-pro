# Schema: Market Brief

Canonical template for `markets/{market-slug}/brief.md`. The market brief is
a **rolling synthesis** that gets richer with every property pull or other
data point added to that market. The agent updating it (typically
`update-market-brief`) re-derives sections from the underlying
`data-points.md` ledger.

```markdown
# {Market Name}, {State}

**Slug:** {market-slug}
**Last Updated:** {YYYY-MM-DD}
**Data Points On File:** {N}  ← count from data-points.md
**Properties Researched:** {N}  ← count of properties in this market
**Direct Market Reports:** {N}  ← count of files in reports/

## Market Snapshot

2-4 sentences on what this market looks like right now from our data.
Updated as the data ledger grows.

## Property Types We Track Here

- {Boutique hotels — N properties on file}
- {Motels — N}
- {Micro resorts — N}
- {Other — N}

## Recent Comps (Last 12 Months)

Table of recent transactions we've seen, sourced from our property pulls
or other contributions.

| Date | Address | Type | Price | $/key | Cap Rate | Source |
|------|---------|------|-------|-------|----------|--------|
| {YYYY-MM-DD} | {addr} | {type} | ${N} | ${N} | {X%} | [property](../../properties/{slug}/) |

## Pricing Trends

- **$/key range:** ${low}–${high} (median ${N}) across {N} comps
- **$/sqft range:** ${low}–${high} (median ${N})
- **Cap rate range:** {low%}–{high%} (median {N%})
- **Trend direction:** {compressing | stable | expanding} based on {observation}

Refresh these whenever a new comp is added.

## Key Players

- **Active brokers:** {names + firms we've encountered}
- **Active operators:** {who's running properties here}
- **Lenders seen:** {if mentioned in pulls}

## Demand Drivers

- {airports, employers, attractions, events, demographic trends}
- {what's pulling travelers / capital here}

## Observations & Trends

Running notes on patterns we've noticed. Each observation should reference
where it came from.

- {observation 1} (from: {source})
- {observation 2} (from: {source})

## Risks / Headwinds

- {regulatory issues, oversupply, seasonality, climate, etc.}

## Open Questions

- {things we want to figure out next time we research here}

## Source Reports

Direct market reports we've pulled, newest first.

| Date | Filename | Notes |
|------|----------|-------|
| {YYYY-MM-DD} | [market-report-{slug}-{date}.pdf](./reports/market-report-{slug}-{date}.pdf) | {scope of report — "boutique hotels", "all hospitality", etc.} |

## Tags

`{market-slug}` `{state}` `{region}` `{any other tags}`
```

## Rules

1. **The brief is derived from the ledger.** Never put a fact in the brief
   that doesn't trace back to a data point in `data-points.md`. If you
   want to add an observation without a source, mark it `(opinion)` so
   future readers know.
2. **Update sections, don't append.** The brief is a synthesis — when new
   data comes in, re-summarize the affected sections. The append-only
   record lives in `data-points.md`.
3. **Always update `Last Updated` and the counts** at the top so anyone
   reading knows how fresh and how dense the data is.
4. **Cross-link properties** with relative paths so the brain is navigable
   in any markdown viewer.
