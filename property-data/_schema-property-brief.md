# Schema: Property Brief

Canonical template for `properties/{slug}/brief.md`. Sophia must use these
exact field names so future AI queries can rely on them.

```markdown
# {Full Address}

**Slug:** {slug}
**Market:** {market-slug}  ← maps to markets/{market-slug}/
**Pulled:** {YYYY-MM-DD}
**Last Updated:** {YYYY-MM-DD}
**Source:** CoStar | Broker | Podcast Guest | Member | Other
**Pulled By:** {agent or human name}

## Property Type

{Boutique hotel | Motel | Micro resort | STR portfolio | Mixed-use | Other}

## Key Specs

- **Room count / units:** {N or "n/a"}
- **Total sqft:** {N or "n/a"}
- **Lot size:** {acres or sqft, or "n/a"}
- **Year built:** {YYYY}
- **Last renovated:** {YYYY or "n/a"}
- **Stories:** {N or "n/a"}

## Financials

- **Asking price:** ${N or "not listed"}
- **Last sale:** ${N} on {YYYY-MM-DD}
- **NOI (TTM):** ${N or "not disclosed"}
- **Cap rate:** {X.X% or "not disclosed"}
- **$/key:** ${N or "n/a"}
- **$/sqft:** ${N or "n/a"}
- **Tax assessed value:** ${N}

## Operations

- **Flag / brand:** {Marriott / Hilton / Independent / etc.}
- **Operator:** {who runs it, if known}
- **Occupancy:** {X% or "not disclosed"}
- **ADR:** ${N or "not disclosed"}
- **RevPAR:** ${N or "not disclosed"}

## Location Context

- **Distance to major metro:** {N min from {metro}}
- **Proximity to demand drivers:** {airports, attractions, employers, etc.}
- **Seasonality:** {high | moderate | low}

## Notable Features

Free-form bullets — what makes this property interesting. Architecture,
amenities, water rights, entitlements, redevelopment angle, etc.

## Risks / Flags

- {anything Sophia or Gideon noticed that's a red flag}
- {high seasonality, deferred maintenance, market headwinds, etc.}

## Files

- [CoStar property report](./property-report-{slug}-{YYYY-MM-DD}.pdf)
- [Screenshots](./screenshots/)
- [Email thread]({thread_url}) ← if shared with someone

## History

| Date | Event | Notes |
|------|-------|-------|
| {YYYY-MM-DD} | First pulled | by {agent} |

## Tags

`{property-type}` `{market-slug}` `{price-band}` `{any other tags}`
```

## Rules

1. **Never delete fields** — if data is unknown, write `"n/a"` or
   `"not disclosed"`. The schema must stay consistent across all properties
   for cross-property queries to work.
2. **Numbers without commas** in numeric fields (`4200000` not `4,200,000`)
   so they're parseable. Format with commas in display layer.
3. **Append to History**, don't overwrite. A re-pull adds a new row.
4. **Tags are lowercase, hyphenated** for grep-ability.
