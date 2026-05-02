# Property Research Suite

A modular series of skills for Sophia (or any AI agent) to log into CoStar,
pull research (property-level OR market-level), email recipients, archive
artifacts, and update Gideon's compounding knowledge base — so every pull
makes future answers smarter.

## Two parallel pipelines

The suite handles two distinct CoStar workflows:

```
PROPERTY pipeline                    MARKET pipeline
─────────────────                    ───────────────
Address in →                         Market name in →
costar-login                         costar-login
costar-property-report               costar-market-report
email-research-report (shared)       email-research-report (shared)
archive-property-docs                archive-market-report
update-market-brief (shared)         update-market-brief (shared)

Lands in:                            Lands in:
properties/{slug}/                   markets/{slug}/reports/
+ contributes to                     + contributes to
markets/{slug}/                      markets/{slug}/
```

## The skills (8 in total)

### Shared
1. **costar-login** — log into CoStar with SMS 2FA hand-off via WhatsApp
2. **email-research-report** — send research email with attachments + summary; works for both property and market reports via a `report_type` input
3. **update-market-brief** — append to `markets/{slug}/data-points.md` and re-derive `brief.md`; called by both pipelines plus standalone for free-text intel

### Property pipeline
4. **costar-property-report** — search address, capture screenshots, download report
5. **archive-property-docs** — file artifacts into `properties/{slug}/` with schema-conformant `brief.md`
6. **property-research-orchestrator** — top-level skill for address-driven pulls

### Market pipeline
7. **costar-market-report** — pull a CoStar market-level report, capture screenshots, download PDF
8. **archive-market-report** — file artifacts into `markets/{slug}/reports/`
9. **market-research-orchestrator** — top-level skill for market-driven pulls

(That's six sub-skills + two orchestrators + one shared email skill = nine skill folders total.)

## Where data goes

```
/Users/gideonspencer/dealhound-pro/property-data/
├── README.md                                 # how the brain works
├── _schema-property-brief.md                 # canonical property schema
├── _schema-market-brief.md                   # canonical market schema
├── properties/
│   ├── _index.md
│   └── {slug}/
│       ├── brief.md
│       ├── meta.json
│       ├── property-report-{slug}-{date}.pdf
│       ├── screenshots/
│       └── notes.md
└── markets/
    ├── _index.md
    └── {market-slug}/
        ├── brief.md                          # rolling synthesis
        ├── data-points.md                    # append-only ledger
        ├── reports/
        │   └── market-report-{slug}-{date}.pdf
        ├── screenshots/
        └── notes.md
```

## How Sophia picks the right orchestrator

| Input shape | Orchestrator | Examples |
|-------------|--------------|----------|
| Specific address | `property-research-orchestrator` | "1234 Main St, Austin", "the property at 500 Oak Ln" |
| Market or submarket | `market-research-orchestrator` | "Austin boutique hotels", "Palm Springs hospitality", "the Seattle market" |
| Just login (no pull) | `costar-login` standalone | "log into CoStar" |
| Lookup against the brain | `archive-property-docs` (lookup mode) for properties; `update-market-brief` (lookup mode) for markets | "what do we have on 1234 Main St?", "what do we know about Austin?" |
| Free-text market intel | `update-market-brief` standalone | "log this for the Austin brain: a broker just told me…" |

If Gideon asks for both ("pull every property under contract AND a market
report on Austin"), run them in sequence — don't merge. They write to
different places and have different artifacts.

## Input contracts

### Property orchestrator
- `address` — full property address (required)
- `recipient_email` — who to send to (required)
- `recipient_name` *(optional)*
- `notes` *(optional)*

### Market orchestrator
- `market` — free-text market spec, e.g. "Austin boutique hotels" (required)
- `recipient_email` (required)
- `recipient_name` *(optional)*
- `filter_scope` *(optional)* — narrowing filter
- `notes` *(optional)*

## How Sophia uses these

- **Full property pipeline** → invoke `property-research-orchestrator`
- **Full market pipeline** → invoke `market-research-orchestrator`
- **Just login** → call `costar-login` standalone
- **Property lookup** → ask `archive-property-docs` in lookup mode
- **Market lookup** → ask `update-market-brief` in lookup mode
- **Free-text market contribution** → call `update-market-brief` standalone

## Status

Scaffolded 2026-04-26. Skills carry `<TBD>` markers in places where the
specific CoStar UI details (URLs, selectors, button text, exact navigation
paths) need to be captured during the first manual run. The data
structure, schemas, orchestration logic, and skill descriptions are all
firm.

## Why this design

- **Two parallel pipelines, sharing what makes sense** — login and email
  are shared because they don't care about property vs market; capture and
  archive are split because they handle fundamentally different artifacts.
- **One brain, two sources** — both pipelines feed the same market brief,
  which is what makes the knowledge base compound.
- **Schema-driven** — every property brief and every market brief uses
  consistent fields, so cross-cutting queries work via grep or JSON parse.
- **AI-readable AND human-readable** — plain markdown, no proprietary
  lock-in. Future RAG layer can embed it with no migration.
