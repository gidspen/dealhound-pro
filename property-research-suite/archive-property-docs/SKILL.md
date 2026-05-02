---
name: archive-property-docs
description: >
  Files CoStar property research (report, screenshots, structured brief) into
  Gideon's compounding property knowledge base at /Users/gideonspencer/dealhound-pro/property-data/properties/.
  Writes a schema-conformant brief.md so future AI agents can answer
  cross-property queries reliably. Use this skill at the end of any property
  research workflow, or when Gideon says "archive this property", "save the
  research", "file this in the brain", "put it in property-data". Also use in
  lookup mode when Gideon asks "what do we have on [address]" or "have we
  pulled CoStar on this property before" — that surfaces the existing brief
  without re-pulling.
---

# Archive Property Docs

You're filing the artifacts from a property research pull into Gideon's
knowledge base so they can be referenced later, AND so the data compounds
into the relevant market brief (handled by the `update-market-brief` skill,
which the orchestrator calls right after this one).

## Inputs

- `address` — full property address
- `slug` — property slug (canonical: lowercased + hyphenated address)
- `report_path` — absolute path to the CoStar PDF (from `costar-property-report`)
- `screenshot_paths` — list of PNG paths
- `summary_bullets` — bullet list summary from the capture skill
- `recipient_email` *(optional)* — for the meta.json cross-link
- `thread_url` *(optional)* — email thread URL from `email-research-report`

## Knowledge base root

```
/Users/gideonspencer/dealhound-pro/property-data/
├── properties/{slug}/        ← what you write here
└── markets/{market-slug}/    ← update-market-brief writes here
```

## Property folder structure

```
properties/{slug}/
├── brief.md                                 # structured, AI-readable summary
├── meta.json                                # machine-readable mirror
├── property-report-{slug}-{YYYY-MM-DD}.pdf
├── screenshots/
│   ├── {slug}-overview.png
│   ├── {slug}-comps.png
│   └── ...
└── notes.md                                 # free-form qualitative notes
```

## Step 1 — Slugify the address

Lowercase, replace commas + spaces with hyphens, strip special characters.

`1234 Main St, Austin TX 78701` → `1234-main-st-austin-tx-78701`

## Step 2 — Detect existing folder

If `properties/{slug}/` already exists, this is a re-pull:

- Don't overwrite. Move the new artifacts into a dated subfolder
  `properties/{slug}/{YYYY-MM-DD}/` so the original stays clean.
- **Update** the existing `brief.md` — append a new row to the History
  table, update the `Last Updated` field, refresh any financial fields
  whose values changed.
- Tell Gideon: "Re-pull on this property — preserved the original at
  brief.md, added new pull as a dated revision and updated the brief."

If it's new, create the folder and move on.

## Step 3 — Move artifacts into the folder

Move (not copy) from wherever `costar-property-report` left them:
- The CoStar PDF → `properties/{slug}/property-report-{slug}-{YYYY-MM-DD}.pdf`
- All screenshots → `properties/{slug}/screenshots/`

## Step 4 — Write brief.md using the canonical schema

Read the schema from `/Users/gideonspencer/dealhound-pro/property-data/_schema-property-brief.md`
and use it exactly. Field names must be consistent across every property —
that's what makes the knowledge base queryable.

Pull values from:
- The `summary_bullets` returned by `costar-property-report`
- The CoStar property page (re-read it if needed for fields the summary missed)
- Inputs the orchestrator passed in (recipient, email thread URL, etc.)

For unknown fields, write `"n/a"` or `"not disclosed"` — never delete a
field. The schema must stay consistent.

**Critical:** The `Market` field at the top of the brief must be a
**market slug** that matches a folder under `markets/`. Examples:
- `austin-tx`
- `san-diego-ca`
- `seattle-wa`
- `palm-springs-ca`

Use the city + state two-letter abbreviation, lowercased and hyphenated.
If the market doesn't exist yet under `markets/`, that's fine —
`update-market-brief` will create it. Just make sure the slug you pick
matches the convention.

## Step 5 — Write meta.json

Machine-readable mirror of the brief's key fields:

```json
{
  "address": "1234 Main St, Austin TX 78701",
  "slug": "1234-main-st-austin-tx-78701",
  "market": "austin-tx",
  "property_type": "boutique-hotel",
  "pulled_at": "2026-04-26T14:30:00-06:00",
  "pulled_by": "Sophia",
  "report_file": "property-report-1234-main-st-austin-tx-78701-2026-04-26.pdf",
  "screenshot_files": ["screenshots/1234-main-st-austin-tx-78701-overview.png"],
  "asking_price": 4200000,
  "last_sale_price": 2800000,
  "last_sale_date": "2017-03-15",
  "noi_ttm": null,
  "cap_rate": null,
  "room_count": 24,
  "total_sqft": 12500,
  "year_built": 1998,
  "emailed_to": "broker@example.com",
  "thread_url": "https://mail.google.com/..."
}
```

Numbers as numbers, not strings with commas. Unknown values as `null`.
This file is what scripts will parse for cross-property queries.

## Step 6 — Initialize notes.md

Just a stub — humans and other agents will append qualitative observations
later:

```markdown
# Notes — {address}

_Free-form qualitative notes. The structured data lives in brief.md._

## {YYYY-MM-DD}
- Initial pull. No notes yet.
```

## Step 7 — Update properties/_index.md

Append a row to `property-data/properties/_index.md`:

```
| 2026-04-26 | 1234 Main St, Austin TX 78701 | austin-tx | boutique-hotel | $4.2M | [link](./1234-main-st-austin-tx-78701/) |
```

## Output

Return to the caller:
- `archive_path` — absolute path to the property folder
- `brief_path` — absolute path to brief.md
- `meta_path` — absolute path to meta.json
- `slug` — the property slug
- `market_slug` — the market slug, used by `update-market-brief` next
- `is_revision` — true if this was a re-pull of an existing property

The orchestrator hands `market_slug` and `property_meta` (parsed from meta.json) to `update-market-brief`
to feed the market's rolling intel.

---

## Lookup mode

If Gideon asks "what do we have on {address}" or similar:

1. Slugify the address.
2. Check if `property-data/properties/{slug}/` exists.
3. If yes:
   - Read `brief.md` and report the key facts back to Gideon.
   - Mention the date pulled and whether there are revisions.
   - Offer: "Want me to re-pull for fresh data?"
4. If no:
   - Tell Gideon "no prior pull on this property in the brain."
   - Offer to run the orchestrator (`property-research-orchestrator`).

## Cross-property queries

If Gideon asks something like "show me every property under $5M with cap
rate above 8%" or "all the boutique hotels we've researched in the southwest":

1. Glob `property-data/properties/*/meta.json`.
2. Filter by the criteria.
3. For each match, surface the brief.md key facts.

Because every meta.json uses the same schema, this is fast and reliable.
