# Ship Approval — feat/buy-box-persistence

## Intent
Promote buy boxes from an ephemeral JSONB field on `deal_searches` to a first-class
persistent object with identity, status (active/draft/archived), and version
stamping. This makes the active-monitor tier limit enforceable, gives the worker
a scheduler loop that scans each active box on the tier's cadence, lets users edit
criteria without polluting the active feed (results stay separated by version),
and ensures every scan result traces back to the exact criteria version that
produced it. Per spec `docs/buy-box-persistence-spec.md`.

## Files changed

### Schema
- `scripts/migrations/2026-05-12-buy-boxes.sql` — creates `buy_boxes` table
  (id, user_email FK→users.email, name, criteria jsonb, status check
  active/draft/archived, version, criteria_updated_at, last_scanned_at,
  created_at) plus `deal_searches.buy_box_id` and `deal_searches.buy_box_version`
  columns. Indexes on user_email, (user_email,status), (buy_box_id,buy_box_version).
  RLS enabled (service-role bypass — Phase-1 pattern). Idempotent. Applied to
  Supabase project gggmmjvwbbfvrtjjlqvr via apply_migration MCP.
- `scripts/migrations/2026-05-12-monsees-dave-buy-box-backfill.sql` — one-time
  manual backfill for the single pre-launch user (`monsees.dave@gmail.com`).
  Includes dry-run SELECTs and idempotent INSERT/UPDATE. **Not executed
  automatically** — must be applied by a human after PR merge.

### Tier constants
- `api/_lib/buy-box-limits.js` — `TIER_ACTIVE_BOX_LIMITS` (founding 3, hunter 3,
  investor 8, operator Infinity) and `TIER_SCAN_INTERVAL_MS` (24h/24h/1h/15min).
  Single source of truth used by the activate endpoint, the chat saver, the
  stripe webhook auto-activator, and the worker scheduler.

### CRUD API
- `api/buy-box.js` — POST creates draft, PATCH updates (bumps version on
  criteria change via JSON.stringify equality; rename alone does not bump),
  POST `?_action=activate|pause|archive&id=...` performs state transitions.
  Activate enforces TIER_ACTIVE_BOX_LIMITS and returns 409 with upgrade CTA
  when at cap. Ownership verified by email.
- `api/buy-boxes.js` — GET lists for the authenticated email.
- `vercel.json` — rewrites for `/api/buy-box/:id`, `/api/buy-box/:id/activate`,
  `/api/buy-box/:id/pause`, `/api/buy-box/:id/archive`; function maxDuration
  entries for both new files.

### Free scan auto-save
- `api/free-scan-start.js` — upserts users row, inserts a draft buy_boxes row
  for every submitter, stamps buy_box_id + buy_box_version=1 on the
  deal_searches row. Uses shared `deriveBuyBoxName` helper.
- `api/stripe-webhook.js` — on `checkout.session.completed`, auto-activates
  the customer's draft buy_boxes up to `TIER_ACTIVE_BOX_LIMITS[new_tier]`
  (Infinity special-cased for operator). Silent — no UI prompt.

### Chat wiring
- `api/_lib/save-buy-box.js` — extracted upsert: finds the user's active
  buy_box, bumps version when criteria differ (via JSON.stringify), no-op
  when identical, inserts new active row if none exists.
- `api/_lib/buy-box-name.js` — shared `deriveBuyBoxName(criteria)` helper.
- `api/chat.js` — `save_buy_box` tool now calls saveBuyBox and stamps
  buy_box_id/buy_box_version on the deal_searches row; SSE event payload
  includes both fields.

### Worker scheduler
- `worker/buy-box-scheduler.js` — `runBuyBoxScheduler(supabase, options)`.
  Selects active buy_boxes, batches user-tier lookups, computes overdue via
  `TIER_SCAN_INTERVAL_MS`, inserts a deal_searches row (criteria snapshot,
  buy_box_id, buy_box_version) and a scrape_jobs row, updates
  `buy_boxes.last_scanned_at`. Returns `{ scheduled, skipped }`.
- `worker/worker.js` — calls scheduler at startup and on every 60s guard
  tick. processPendingJobs already short-circuits when WORKER_TEST_MODE=true,
  so tests exercise only DB writes — no real scans.

### Lint config
- `eslint.config.js` — added the three new `api/_lib/*.js` files to the CJS
  file-list so eslint accepts `require`/`module.exports`.

### Tests (all new, all passing — 130/130 across 21 files)
- `tests/integration/buy-box-crud.test.js` — 8 tests (create, version bump
  on criteria change, no bump on rename, activate under/over limit, pause,
  archive, list isolation)
- `tests/integration/free-scan-buy-box.test.js` — 3 tests (free-scan draft
  creation, checkout activation, tier-limit during activation)
- `tests/integration/chat-buy-box.test.js` — 3 tests (first save creates
  active, idempotent re-save, criteria change bumps version)
- `tests/integration/worker-scheduler.test.js` — 6 tests (overdue schedules,
  within-interval skips, NULL last_scanned_at schedules, draft/archived
  skip, tier interval respect)
- `tests/integration/free-scan-rate-limit.test.js` — single-line mock fix
  (added `upsert()` to the supabase mock; the new users upsert in
  free-scan-start broke the existing mock)

### Spec
- `docs/buy-box-persistence-spec.md` — already on branch from the prior
  spec commit. No further changes.

## Confirmation
No files outside the intended scope were modified. The hard limits from the
orchestrator prompt were honored: nothing outside `/Users/gideonspencer/dealhound-pro`
was touched; no files deleted; `api/_lib/paywall.js` untouched; the Dave
backfill script was written but **not** executed against production; no real
scans were triggered (WORKER_TEST_MODE=true gates the worker); no production
deploys; branch is `feat/buy-box-persistence`, not main; no `--no-verify` was
used.
