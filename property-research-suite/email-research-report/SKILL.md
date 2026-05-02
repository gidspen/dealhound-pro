---
name: email-research-report
description: >
  Sends a property OR market research email to a recipient with the CoStar
  report, screenshots, and a short message body. Generalized to handle both
  property pulls and market reports — pass `report_type: "property"` or
  `report_type: "market"` to adjust the subject and body. Designed to run
  after costar-property-report or costar-market-report has produced the
  artifacts. Use this skill when Gideon says "send the report to [name]",
  "email the CoStar pull to [recipient]", "share the property research
  with [recipient]", "send the market report to [recipient]", or as the
  email step in either research workflow.
---

# Email Research Report

You're sending a property OR market research email to a recipient with a
brief, personable message. Gideon's voice is direct and warm — not corporate.

## Inputs

- `report_type` — `"property"` or `"market"` (required, drives subject + body)
- `recipient_email` — who to send to
- `recipient_name` — for greeting (optional; default "there")
- `subject_object` — the address (for property) or market name (for market)
  — used in subject and body
- `report_path` — path to the PDF
- `screenshot_paths` — list of PNG paths
- `summary_bullets` — the bullet summary from the capture skill (used as the body)
- `notes` — extra context Gideon wants in the body (optional)
- `(optional) thread_id` — if continuing an existing thread

## Step 1 — Compose the email

**Subject** depends on `report_type`:

- Property: `CoStar Pull — {subject_object}`
  e.g. `CoStar Pull — 1234 Main St, Austin TX 78701`
- Market: `Market Report — {subject_object}`
  e.g. `Market Report — Austin Boutique Hotels`

**Body template** (same shape, swap the framing):

For `report_type: "property"`:

```
Hey {recipient_name},

Pulled the CoStar on {subject_object} — quick summary below, full report
attached.

{summary_bullets as bullet list}

{notes if any, as a short paragraph}

Let me know if you want me to dig into anything specific.

— Gideon
```

For `report_type: "market"`:

```
Hey {recipient_name},

Pulled the CoStar market report on {subject_object} — quick summary below,
full report attached.

{summary_bullets as bullet list}

{notes if any, as a short paragraph}

Happy to dig into specific submarkets or property types if useful.

— Gideon
```

**Voice rules (apply to both):**
- Direct, warm, conversational.
- No "please find attached" or other corporate filler.
- No em dashes (`—`) or double dashes (`--`) in the body — rewrite the sentence.
- 4-6 sentences max in the body before the bullets.
- Frame everything through the hotel/micro resort lens (avoid STR-specific
  language unless the recipient is in that world).

## Step 2 — Attach files

Attach:
- The report PDF
- All screenshots from `screenshot_paths`

If total attachment size exceeds the email provider's limit
(<TBD — Gmail is 25MB by default>), upload to Drive and link instead.
Note this in the body.

## Step 3 — Send

<TBD — capture during first run:
- Which email tool/connector to use (Gmail MCP? Outlook? Compose-only draft?)
- Whether to send directly or save as draft for Gideon to review
- Default behavior: send draft for review unless Gideon says "just send it">

## Output

Return to the caller:
- `email_status` — `"sent"` | `"drafted"` | `"failed"`
- `thread_url` — link to the email thread (used by the archive step)
- `sent_at` — timestamp

## Edge cases

- **Recipient bounced / invalid email** → stop, tell Gideon, don't retry.
- **Attachments too big** → Drive-link fallback (above).
- **Sensitive recipient** (e.g., a seller's broker) → if the recipient
  looks external rather than internal, default to draft-mode and ask
  Gideon to review before sending.
