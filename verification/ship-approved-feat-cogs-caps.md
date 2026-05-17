# Ship approval: feat/cogs-caps

## Intent

Add an explicit `CapExceededError` exception class and a `trackTokenLineOrThrow()` method to the existing cost guardrails so call sites that prefer exception-based flow can use it. The substance of PR 3's spec (5 per-skill caps, 4 tier monthly ceilings, top-up copy, RPC increment) was already implemented in `worker/cost-guardrails.js`; this PR adds the new error class plus 3 tests asserting the DoD's behavior. Also folds in the Phase 0 vitest `--env-file=.env` fix so this branch's integration tests stay green on a clean shell.

## Files changed

- `worker/cost-guardrails.js` — adds `CapExceededError` class (with `kind` / `totalCost` / `capAmount` / `statusCode` fields, `statusCode` defaults to 402 for `monthly_cap` kind, 500 for `per_skill`), adds `CostTracker.trackTokenLineOrThrow()` method that throws `CapExceededError` when cap fires (delegates to existing flag-based `trackTokenLine`), adds `CapExceededError` to the module exports. Existing flag-based behavior is untouched — the worker keeps the current contract.
- `tests/integration/cost-guardrails.test.js` — appends 3 new describe blocks: (1) verifies `trackTokenLineOrThrow` throws on the 4th deal-scan token line with correct `kind` / `capAmount` / `totalCost` metadata, (2) verifies `checkAndReserveMonthlyBudget` returns `{allowed:false}` with the exact top-up copy when at cap and that a `monthly_cap` `CapExceededError` carries `statusCode: 402`, (3) verifies `recordComputeUsed` calls `supabase.rpc('increment_compute_used', { p_email, p_amount })`.
- `package.json` — same Phase 0 fix as PR #54 / #55: test script switched to `node --env-file=.env node_modules/.bin/vitest run tests/integration` so `npm test` runs green on a clean shell.

## Confirmation

No files outside the intended scope were modified.
