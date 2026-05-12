# Buy Box Persistence — Implementation Spec

_May 2026 — MVP_

> Companion to [`PRODUCT_SPEC.md`](../PRODUCT_SPEC.md) §1 and [`PRODUCT_THESIS.md`](../PRODUCT_THESIS.md) §5.
> This doc defines the schema, state model, edit behavior, and worker integration for persistent buy boxes.

---

## What this is

A named, persistent investment strategy that the worker monitors on a schedule. Right now buy boxes live inside `deal_searches` rows — ephemeral, one-per-scan, with no identity of their own. This makes active-count tier enforcement impossible and gives users no way to say "monitor this strategy every day."

After this ships: a buy box is a first-class object with a name, a status, and a history. Scans run against it automatically. When the user edits it, old results stay clean and separate from new results.

---

## The edit problem

This is the core design constraint. If a user changes their buy box from "glamping in Colorado, $500K–$1M" to "boutique hotel in Florida, $2M–$5M", their dashboard should not mix deals from both searches. Old results must remain accessible but must not be confused with new ones.

**Solution: version stamping.** Every time criteria changes, the buy box gets a new version number. Every scan records the version it ran against. The dashboard defaults to showing results from the current version only. Old-version results are accessible via "Previous criteria" but don't pollute the active feed.

This gives users full freedom to edit — no friction, no hard resets — while keeping the results surface clean.

---

## Schema

### New table: `buy_boxes`

```sql
CREATE TABLE buy_boxes (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_email          TEXT NOT NULL REFERENCES users(email) ON DELETE CASCADE,
  name                TEXT NOT NULL DEFAULT 'Buy Box',        -- user-named or auto-assigned
  criteria            JSONB NOT NULL,                         -- the buy box spec (markets, price, type, etc.)
  status              TEXT NOT NULL DEFAULT 'draft'           -- 'active' | 'draft' | 'archived'
                      CHECK (status IN ('active', 'draft', 'archived')),
  version             INTEGER NOT NULL DEFAULT 1,             -- increments on criteria change
  criteria_updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),     -- when criteria last changed
  last_scanned_at     TIMESTAMPTZ,                            -- when worker last ran a scan for this box
  created_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Enforce tier active-count limit at DB level
-- (App layer also enforces this, but DB constraint is the safety net)
-- Note: Can't enforce a parameterized limit purely in DB without a trigger.
-- App-layer enforcement is primary; see "Active count enforcement" below.

CREATE INDEX idx_buy_boxes_user_email  ON buy_boxes (user_email);
CREATE INDEX idx_buy_boxes_status      ON buy_boxes (user_email, status);
```

### Changes to `deal_searches`

```sql
ALTER TABLE deal_searches
  ADD COLUMN IF NOT EXISTS buy_box_id      UUID REFERENCES buy_boxes(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS buy_box_version INTEGER;  -- version of criteria used for this scan

CREATE INDEX idx_deal_searches_buy_box ON deal_searches (buy_box_id, buy_box_version);
```

**Backward compatibility:** existing `deal_searches` rows have `buy_box_id = NULL` and `buy_box_version = NULL`. These continue to show in the dashboard as before. New scans always carry both fields.

---

## Buy box states

```
draft ──activate──▶ active ──pause──▶ draft
                       │
                       └──archive──▶ archived
```

| State      | Scans run? | Editable? | Counts against tier limit? |
|------------|------------|-----------|---------------------------|
| `active`   | Yes        | Yes       | Yes                       |
| `draft`    | No         | Yes       | No                        |
| `archived` | No         | No        | No                        |

**Activating** a buy box beyond the tier limit returns a 409 with upgrade CTA — never silently fails.

**Archiving** is a soft delete. The buy box and its associated deals remain accessible in history. No destructive deletes.

---

## Edit behavior and versioning

When the user saves changes to a buy box's criteria:

1. Increment `version` on the `buy_boxes` row
2. Update `criteria` with the new spec
3. Update `criteria_updated_at` to now
4. Do NOT touch existing `deal_searches` rows — they retain their old `buy_box_version` stamp
5. Next scan by the worker picks up the new criteria and writes a `deal_searches` row with the incremented version

**What the user sees:**

- Dashboard defaults to: deals from `deal_searches` rows where `buy_box_version = buy_boxes.version` (current version)
- A "Previous criteria" section or toggle reveals older-version deals, grouped by version with a date label ("Criteria before May 12")
- The version bump is invisible to the user — they just see "current results" vs "previous results"

**What counts as a criteria change** (version bump):
- Any field in `criteria` that affects which listings are returned: markets, asset types, price range, acreage floor, revenue requirement, hard exclusions
- Renaming the buy box does NOT bump the version (cosmetic change)

**No "start fresh" forced wipe.** Users keep all history. The version model handles separation. If a user explicitly wants a clean slate they can archive the old box and create a new one.

---

## Active count enforcement

**Where it lives:** app layer in `api/scan-start.js` and the new buy box save/activate endpoints.

```js
// On activate (status transition draft → active):
const { count } = await supabase
  .from('buy_boxes')
  .select('id', { count: 'exact', head: true })
  .eq('user_email', email)
  .eq('status', 'active');

const limit = TIER_ACTIVE_BOX_LIMITS[user.subscription_tier];

if (count >= limit) {
  return res.status(409).json({
    error: `You're using ${count} of ${limit} active monitors. Pause one or upgrade to add another.`,
    reason: 'active_box_limit',
    checkoutUrl: '/api/create-checkout',
  });
}
```

```js
const TIER_ACTIVE_BOX_LIMITS = {
  founding:  3,
  hunter:    3,
  investor:  8,
  operator:  Infinity,
};
```

**Edits to active buy boxes are never blocked.** Only the activation of a new active box is gated. A user on a 3-box plan with 3 active boxes can edit all 3 freely — they just can't add a 4th without pausing one.

---

## Worker integration

The worker's current model: a human-triggered scan creates a `scrape_jobs` row and the worker picks it up.

With persistent buy boxes, the worker gains a **scheduler loop** alongside the existing job queue:

```
Every 60 seconds, the worker:
  1. Reads all buy_boxes WHERE status = 'active'
  2. For each, checks last_scanned_at vs the tier's scan interval:
       founding/hunter → 24 hours
       investor        → 1 hour
       operator        → 15 minutes (continuous approximation)
  3. If overdue: inserts a scrape_jobs row referencing buy_box_id + buy_box_version
  4. Updates buy_boxes.last_scanned_at = now()
  5. Worker's existing job loop picks up the scrape_job and runs the scan as usual
```

The scan result writes a `deal_searches` row with:
- `buy_box_id` = the buy box that triggered it
- `buy_box_version` = current version of that buy box at scan time
- `buy_box` = criteria snapshot (already present — keeps deal_searches self-contained)

**Scan frequency enforcement:** the scheduler reads `users.subscription_tier` per buy box owner before inserting the job. If a user downgrades, scans automatically slow down on the next scheduler tick.

---

## Incremental scan optimization

Running a full scrape daily across all sources for every active buy box is expensive ($0.50–$2.00/run). The worker should use an incremental model:

- **Daily (founding/hunter):** check for listings added or updated since `last_scanned_at`. Score only new listings. Full re-score weekly (every 7th daily run) to catch price changes on existing survivors.
- **Hourly (investor):** delta check only — new listings since last hour. Full re-score daily.
- **Continuous (operator):** delta check on every tick. Full re-score weekly.

Implementation: each source scraper compares incoming listing URLs against `deals.url` to skip already-scored listings. New listings get scored; existing ones skip the Claude scoring step unless it's a re-score cycle.

User-facing framing stays simple: "Your agent scans daily." The incremental optimization is invisible.

---

## API endpoints needed

| Method | Path | What it does |
|--------|------|-------------|
| `POST` | `/api/buy-box` | Create new buy box (draft by default) |
| `PATCH` | `/api/buy-box/:id` | Update criteria or name (bumps version if criteria changed) |
| `POST` | `/api/buy-box/:id/activate` | Set status → active (enforces tier limit) |
| `POST` | `/api/buy-box/:id/pause` | Set status → draft |
| `POST` | `/api/buy-box/:id/archive` | Set status → archived |
| `GET` | `/api/buy-boxes` | List all buy boxes for authenticated user |

The existing chat → `save_buy_box` tool call becomes a `POST /api/buy-box` (creates draft) followed by `POST /api/buy-box/:id/activate` once the user confirms. If they're at their tier limit, the activate call returns the 409 and the chat surfaces the upgrade CTA.

---

## UI framing

**Active monitor count pill** (dashboard header):
> "2 of 3 active monitors"
> [Manage] → opens buy box list

**Buy box list view:**
- Each row: name, market summary, status pill (Active / Draft / Archived), last scan time, deal count (current version)
- Active rows: pause button
- Draft rows: activate button (grayed out + upgrade prompt if at limit)
- All rows: edit button (opens criteria chat or inline form)

**Results page — version change indicator:**
When the current version > 1, show a subtle banner:
> "Showing results from current criteria (updated May 12). [View previous results]"

**Upgrade CTA copy** (at active limit):
> "You're using 3 of 3 active monitors. Pause one or upgrade to Hunter for more."

---

## Out of MVP scope

- Buy box templates / sharing
- Duplicate buy box
- Multi-user / team buy boxes
- Buy box performance analytics (which box surfaces the most HOT deals)
- A/B testing two criteria variations
- Automatic buy box suggestions from scan history

---

## Decisions (locked 2026-05-11)

1. **Auto-naming:** AI-generated from criteria. The agent names the buy box based on the key criteria it captured — e.g., "Colorado Glamping $500K–$1M" or "Southeast Boutique Hotels, Value-Add." Editable by the user at any time. Reinforces the agent voice; avoids generic "Buy Box 1" framing.

2. **Free scan → buy box:** Free scan completion automatically creates a `buy_boxes` row (draft status) for the submitting email, with the scan's criteria as the initial criteria. If the user pays, the buy box activates — no prompt, no friction. If they never pay, the draft persists and becomes the starting point if they ever sign up. Do not ask permission; just save it.

3. **Existing user migration:** No prompt. The only active user pre-launch is `monsees.dave@gmail.com`. On deploy, a one-time migration script reads their most recent `deal_searches` row, creates a `buy_boxes` row from that criteria (status = `active`), and backfills `buy_box_id` on their existing `deal_searches` rows. Automated, silent, no UI change needed.
