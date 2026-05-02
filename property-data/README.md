# Property Data — Stonemont Capital Knowledge Base

This is Gideon's compounding memory for property and market intel. Every
CoStar pull (property OR market level), broker conversation, podcast guest
insight, or member-shared data point flows into here so future questions
get answered with the full weight of everything we've ever learned.

Think of it as a brain: structured enough that an AI agent can extract
specific facts, loose enough that humans can read it like notes.

## Two layers, two report types

The knowledge base distinguishes between **property data** (per-address
intel) and **market data** (per-MSA intel). Each layer can hold its own
raw CoStar reports — they are NOT mixed.

```
property-data/
├── properties/                    # PROPERTY layer — per-address
│   ├── _index.md
│   └── {slug}/                    # one folder per property we've researched
└── markets/                       # MARKET layer — per-MSA
    ├── _index.md
    └── {market-slug}/             # one folder per market we operate or watch
```

### How to tell them apart at a glance

| Signal | Property | Market |
|--------|----------|--------|
| **Folder** | `properties/{slug}/` | `markets/{market-slug}/` |
| **Slug format** | full address: `1234-main-st-austin-tx-78701` | city + state: `austin-tx` |
| **Raw report filename** | `property-report-{slug}-{date}.pdf` | `market-report-{slug}-{date}.pdf` |
| **Brief schema** | `_schema-property-brief.md` | `_schema-market-brief.md` |
| **Lookup question** | "what do we know about 1234 Main St?" | "what do we know about Austin?" |

The file prefix (`property-report-` vs `market-report-`) plus the parent
folder make it impossible to mix them up.

---

## Properties layer

Per-address research. Each property folder holds:

```
properties/{slug}/
├── brief.md                                 # structured, AI-readable summary
├── meta.json                                # machine-readable mirror of brief.md
├── property-report-{slug}-{date}.pdf        # raw CoStar property report
├── screenshots/                             # property-page screenshots
│   ├── {slug}-overview.png
│   └── ...
└── notes.md                                 # free-form qualitative notes
```

Schema: `_schema-property-brief.md` — every property uses the same fields,
which is what makes cross-property queries work.

### What feeds this layer

- Property-level CoStar pulls (the most common source)
- Broker emails on a specific property
- Member-shared deals
- Podcast guest mentions of a specific property

### Common queries

- "What do we have on 1234 Main St?"
- "Show me every boutique hotel under $5M with cap rate above 8%"
- "Every property we've researched in the last 90 days"

---

## Markets layer

Per-market intel. Each market folder holds:

```
markets/{market-slug}/
├── brief.md                              # rolling synthesis (auto-updated)
├── data-points.md                        # append-only contribution ledger
├── reports/
│   ├── market-report-{slug}-{date}.pdf   # raw CoStar market reports
│   └── ...
├── screenshots/                          # screenshots from market pulls
│   └── ...
└── notes.md                              # free-form qualitative notes
```

Schema: `_schema-market-brief.md`.

### Two distinct sources fill this layer

1. **Direct market reports** — Sophia pulls a CoStar market-level report
   on, say, "Austin boutique hotels". The raw PDF and screenshots land in
   `markets/austin-tx/reports/` and `markets/austin-tx/screenshots/`. The
   data inside contributes to `brief.md` and `data-points.md`.
2. **Property pull contributions** — every time a property is pulled in
   `properties/`, the `update-market-brief` skill appends a data point to
   the relevant market's `data-points.md` and re-derives the synthesis in
   `brief.md`.

This is why markets compound. Year one feels like overhead. Year three,
the Austin market brief is gold because it's been fed by 30 property pulls
plus 12 direct market reports plus assorted broker comments.

### Common queries

- "What do we know about the Austin hospitality market?"
- "What's the $/key range we're seeing in Palm Springs?"
- "Which markets have we researched the most?"

---

## How to query this brain

**Specific property** → read `properties/{slug}/brief.md`
**Specific market** → read `markets/{market-slug}/brief.md`
**Full market history** → read `markets/{market-slug}/data-points.md`
**Cross-property** → glob `properties/*/meta.json`, filter, summarize
**Did we research X already?** → check existence of `properties/{slug}/`
or `markets/{market-slug}/`

---

## Schemas

- `_schema-property-brief.md` — canonical template for property briefs
- `_schema-market-brief.md` — canonical template for market briefs

Sophia (and any future agent) MUST follow these schemas exactly. Field
names stay consistent so cross-property and cross-market queries work
reliably without parsing ambiguity.

---

## Why this design

1. **Clear separation** — property data and market data live in separate
   trees with clearly different naming conventions. No ambiguity about
   what's what.
2. **Same schema across all entries of a type** — every property brief
   has the same fields, every market brief has the same fields. AI
   queries are reliable.
3. **Markets compound** — every property pull feeds market intel, AND
   direct market reports add their own raw data. The brain gets sharper
   with every pull.
4. **Source-traceable** — every claim in a synthesized brief traces back
   to a dated entry in `data-points.md` or a specific property's brief.
5. **AI-readable AND human-readable** — plain markdown means Gideon can
   read it, agents can parse it, and a future RAG layer can embed it. No
   proprietary format lock-in.
