---
name: property-research-orchestrator
description: >
  End-to-end property research workflow. Given a property address and a
  recipient email, logs into CoStar, pulls the report and screenshots, emails
  the recipient with a brief summary, archives everything to Gideon's
  property-data knowledge base, and updates the relevant market brief so
  intel compounds over time. This is the top-level skill that chains
  costar-login → costar-property-report → email-research-report →
  archive-property-docs → update-market-brief. Use this skill whenever
  Gideon says "pull a CoStar report on [address] and send it to [recipient]",
  "research the property at [address] for [name]", "do a property pull for
  [recipient] on [address]", "run the full CoStar workflow on [address]", or
  any variation of the full pipeline. If Gideon only asks for one piece
  (e.g. just the login, just an archive lookup, just a market intel
  update), delegate to the specific sub-skill instead.
---

# Property Research Orchestrator

You're running Gideon's full property research pipeline:

```
costar-login → costar-property-report → email-research-report →
archive-property-docs → update-market-brief
```

Each step has its own dedicated skill. Your job is to sequence them, pass
data between them, and recover gracefully if any step fails.

## Inputs

- `address` — full property address (required)
- `recipient_email` — who to send to (required)
- `recipient_name` — for greeting (optional)
- `notes` — extra context for the email body (optional)

If any required input is missing, ask Gideon for it before starting.

## Pre-flight check

Before doing anything else, run `archive-property-docs` in **lookup mode**
on the address. If we already have a recent pull (within the last 30 days):

> "We already pulled CoStar on this property on {date}. Want me to (a) just
> resend the existing report to {recipient}, (b) re-pull fresh, or (c) skip?"

This avoids unnecessary CoStar usage and surfaces existing intel.

## Step 1 — Log into CoStar

Invoke `costar-login`. If it returns `session_status: "failed"`, stop and
tell Gideon what went wrong. Don't try to continue without an authenticated
session.

## Step 2 — Pull the property report

Invoke `costar-property-report` with `address`. Capture:
- `slug`
- `report_path`
- `screenshot_paths`
- `summary_bullets` (the bullet list)

If the address isn't found or has multiple matches, follow the sub-skill's
edge-case handling — ask Gideon, don't guess.

## Step 3 — Email the recipient

Invoke `email-research-report` with:
- `report_type: "property"`
- `recipient_email`, `recipient_name`
- `subject_object: address`
- `report_path`, `screenshot_paths`
- `summary_bullets`
- `notes` (if provided)

Capture `thread_url` and `email_status`. If `email_status` is `"failed"`,
**still continue** to archive — losing the brain entry because email
bounced is worse than a failed email. Flag the failure in the final report.

## Step 4 — Archive into the knowledge base

Invoke `archive-property-docs` with:
- `address`, `slug`
- `report_path`, `screenshot_paths`
- `summary_bullets`
- `recipient_email`, `thread_url`

Capture:
- `archive_path` — folder under `property-data/properties/{slug}/`
- `brief_path` — the structured brief.md
- `meta_path` — meta.json
- `market_slug` — the market this property belongs to
- `is_revision` — true if it was a re-pull

## Step 5 — Update the market brief (THE COMPOUND STEP)

Invoke `update-market-brief` with:
- `source_type: "property-pull"`
- `market_slug` (from Step 4)
- `property_slug` (the property's slug)
- `property_meta` — read meta.json from `meta_path` and pass the parsed dict
- `summary_bullets` — same as Step 2

This is what makes Gideon's intel compound. Every pull makes the market
brief sharper.

Capture `is_new_market` (true if this is the first property in this market)
and `data_points_total`.

## Final report to Gideon

After all steps, send a single summary message:

```
✅ {address}

📄 Report pulled — {N} screenshots + PDF
✉️  Emailed to {recipient_email} ({email_status})
📁 Archived to property-data/properties/{slug}/
🧠 Market brief updated: {market_slug} (now {N} data points on file{, market created if new})

Quick read on the property:
- {bullet 1}
- {bullet 2}
- ...

{any flags or warnings}
```

## Failure recovery

- **Login fails** → stop. Don't try to continue.
- **Report fails** → stop, but tell Gideon what we got (e.g., "logged in
  OK but couldn't find the address").
- **Email fails** → continue to archive AND market update. The brain still
  benefits even if the email bounced. Flag the email failure at the end.
- **Archive fails** → tell Gideon. Skip Step 5 (no archive = nothing to
  feed the market brief from). Leave artifacts in their working dir and
  give him the paths.
- **Market update fails** → not fatal. The property is archived, the
  email sent. Tell Gideon the market brief didn't update so he can run
  `update-market-brief` manually later.

## Notes

This skill is the public interface. Most of the time Gideon will trigger
this and not the sub-skills directly. Keep this skill thin: its only job
is sequencing and data hand-off. All real logic lives in the sub-skills.
