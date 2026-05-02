---
name: market-research-orchestrator
description: >
  End-to-end MARKET-level research workflow (parallel to
  property-research-orchestrator, but for whole markets rather than single
  addresses). Given a market specification (e.g. "Austin boutique hotels")
  and a recipient email, logs into CoStar, pulls the market-level report
  and screenshots, emails the recipient with a brief summary, archives the
  raw artifacts to property-data/markets/{slug}/reports/, and updates the
  rolling market brief. Use this skill whenever Gideon says "pull a market
  report on [market] and send it to [recipient]", "research the [market]
  hospitality market for [name]", "do a CoStar market pull on [market]",
  "run the market research workflow on [market]", or any variation of the
  full market-level pipeline. If Gideon mentions a specific property
  address, use property-research-orchestrator instead.
---

# Market Research Orchestrator

You're running Gideon's full **market-level** research pipeline:

```
costar-login → costar-market-report → email-research-report →
archive-market-report → update-market-brief
```

This is the market analog of `property-research-orchestrator`. The
distinction matters: property research targets a single address; market
research targets a whole market or submarket.

## Inputs

- `market` — free-text market specification, e.g. "Austin boutique hotels"
  (required)
- `recipient_email` — who to send to (required)
- `recipient_name` — for greeting (optional)
- `filter_scope` — narrowing filters like "boutique only", "under 50 keys"
  (optional)
- `notes` — extra context for the email body (optional)

If any required input is missing, ask Gideon for it before starting.

## Pre-flight check

Before doing anything else, run `update-market-brief` in **lookup mode**
on the market. If we already have a recent direct market report (within
the last 90 days):

> "We already pulled a market report on {market} on {date}. Want me to
> (a) just resend it to {recipient}, (b) re-pull fresh, or (c) skip?"

Market data ages slower than property data — 90 days is a reasonable
freshness threshold rather than the 30-day window for properties.

## Step 1 — Log into CoStar

Invoke `costar-login`. If it fails, stop and tell Gideon.

## Step 2 — Pull the market report

Invoke `costar-market-report` with `market` and `filter_scope`. Capture:
- `market_slug`
- `market_display_name`
- `report_path`
- `screenshot_paths`
- `summary_bullets` (bullets)
- `key_metrics` (structured data)

## Step 3 — Email the recipient

Invoke `email-research-report` with:
- `report_type: "market"`
- `recipient_email`, `recipient_name`
- `subject_object: market_display_name`
- `report_path`, `screenshot_paths`
- `summary_bullets`
- `notes` (if provided)

Capture `thread_url` and `email_status`. If email fails, continue —
don't lose the brain entry over a bounced email.

## Step 4 — Archive the raw artifacts

Invoke `archive-market-report` with the outputs from Steps 2 and 3.
Capture:
- `market_path` — folder under `property-data/markets/{slug}/`
- `report_path_archived`
- `is_new_market`
- `source_info` (payload for the next step)

## Step 5 — Update the market brief (THE COMPOUND STEP)

Invoke `update-market-brief` with:
- `source_type: "direct-market-report"`
- `market_slug` (from Step 4)
- `source_info` (from Step 4)
- `summary_bullets` (from Step 2)
- `key_metrics` (from Step 2)

Capture `data_points_total` for the final report.

## Final report to Gideon

```
✅ {market_display_name}

📊 Market report pulled — {N} screenshots + PDF
✉️  Emailed to {recipient_email} ({email_status})
📁 Archived to property-data/markets/{market_slug}/reports/
🧠 Market brief updated: now {N} data points on file{, market created if new}

Quick read on the market:
- {bullet 1}
- {bullet 2}
- ...

{any flags or warnings}
```

## Failure recovery

- **Login fails** → stop.
- **Market report fails** (e.g. filter too narrow / too broad) → stop,
  tell Gideon what we got.
- **Email fails** → continue archive + brief update. Flag at the end.
- **Archive fails** → stop. The brain can't ingest data that isn't filed.
- **Brief update fails** → not fatal. Tell Gideon to run
  `update-market-brief` manually later.

## Notes

This skill and `property-research-orchestrator` are the two public
interfaces for CoStar pulls. Sophia picks based on the input: address-shaped
input → property orchestrator. Market name → market orchestrator.

If Gideon asks for "all property pulls and a market report on the same
market" in one go, run them in sequence (property orchestrator first, then
this one). Don't try to merge them into a single workflow — they have
different artifacts and different archive locations.
