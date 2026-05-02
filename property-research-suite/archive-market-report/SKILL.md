---
name: archive-market-report
description: >
  Files raw market report artifacts (PDF, screenshots) into Gideon's
  property-data knowledge base under markets/{market-slug}/reports/ and
  screenshots/. Parallel to archive-property-docs, but for market-level
  reports rather than per-property pulls. Use this skill at the end of a
  market research workflow, or when Gideon says "file this market report",
  "archive the market pull", "save this to the {market} folder". The
  update-market-brief skill runs immediately after to fold the data into
  the rolling synthesis.
---

# Archive Market Report

You're filing the raw artifacts from a market-level CoStar pull into the
markets layer of Gideon's knowledge base. The synthesis step
(`update-market-brief`) runs after this and updates `brief.md` and
`data-points.md` — your job is just to put the raw files where they belong.

## Knowledge base path

```
/Users/gideonspencer/dealhound-pro/property-data/markets/{market-slug}/
├── reports/
│   └── market-report-{market-slug}-{YYYY-MM-DD}.pdf   ← here
└── screenshots/
    └── {market-slug}-{section}.png                     ← here
```

## Inputs

- `market_slug` — e.g. `austin-tx`
- `market_display_name` — e.g. "Austin, TX — Boutique Hotels"
- `report_path` — absolute path to the downloaded PDF
- `screenshot_paths` — list of PNG paths
- `summary_bullets` — bullet list from the capture skill
- `key_metrics` — structured numeric data
- `recipient_email` — if the report was emailed (for cross-link)
- `thread_url` — link to the email thread (if any)
- `filter_scope` — e.g. "boutique hotels only" — captured in the index row

## Step 1 — Ensure the market folder exists

If `markets/{market-slug}/` doesn't exist:
1. Create the folder with `reports/` and `screenshots/` subfolders.
2. Tell Gideon: "First time we've filed market data for {market_display_name} —
   creating the folder."

If it exists but `reports/` or `screenshots/` subfolders don't, create them.

## Step 2 — Move the artifacts

- Move the PDF to `markets/{market-slug}/reports/market-report-{market-slug}-{YYYY-MM-DD}.pdf`
  - If a file with that name already exists (same market, same day), add
    a `-v2`, `-v3` suffix so we don't overwrite.
- Move all screenshots to `markets/{market-slug}/screenshots/`

## Step 3 — Hand off to update-market-brief

Don't write `brief.md` or `data-points.md` yourself — that's
`update-market-brief`'s job and it has the synthesis logic. Your output
to the orchestrator includes everything that skill needs:

- `market_slug`
- `market_path` — absolute path to the market folder
- `report_path_archived` — final filename of the PDF
- `screenshot_paths_archived` — list of final screenshot paths
- `summary_bullets`, `key_metrics` — passed straight through
- `source_info` — for the data-points.md ledger entry:
  ```json
  {
    "type": "direct-market-report",
    "filter_scope": "boutique hotels only",
    "report_file": "market-report-austin-tx-2026-04-26.pdf",
    "pulled_at": "2026-04-26T14:30:00-06:00",
    "pulled_by": "Sophia",
    "emailed_to": "broker@example.com",
    "thread_url": "https://mail.google.com/..."
  }
  ```

## Output

Return to the caller:
- `market_slug`
- `market_path`
- `report_path_archived`
- `screenshot_paths_archived`
- `is_new_market` — true if folder was just created
- `source_info` — payload for `update-market-brief`

## Why this is its own skill

We considered folding it into `update-market-brief`, but separating
"file the raw artifacts" from "synthesize the brief" keeps each skill
atomic and lets Sophia call them independently when needed (e.g. file a
report now, synthesize later when Gideon has time to sanity-check).
