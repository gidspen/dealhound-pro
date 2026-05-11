# Ship approval — fix/rls-lockdown

## Intent

Close a real production security hole: the Supabase anon JWT is publicly embedded in `results/index.html`, and every public table in the `gggmmjvwbbfvrtjjlqvr` project had RLS disabled with full DML grants to `anon` + `authenticated`. Any visitor could read or mutate any row in `users`, `deals`, `deal_searches`, etc.

Phase 1 of a two-phase lockdown: enable Postgres Row Level Security on 12 tables with no permissive policy. Service-role bypass keeps every `api/*` and worker path working unchanged. Phase 2 (deferred) locks the remaining 2 tables (`deal_searches`, `deals`) — blocks on migrating `results/index.html` to a service-key API endpoint first.

Also adds `WORKER_TEST_MODE` env var on `worker/worker.js` — when `'true'`, skips the Claude/Apify subprocess and writes 3 fake scored deals + marks the scan complete. Default OFF; zero prod behavior change. Unblocks Flow B/C/G end-to-end tests in CI.

## Files changed (in commit aea17f7)

- `scripts/migrations/2026-05-11-rls-lockdown-phase1.sql` — new. `ENABLE ROW LEVEL SECURITY` on 12 tables. Header documents the scope, why Phase 2 is deferred, and per-table rollback (`DISABLE ROW LEVEL SECURITY`).
- `scripts/verify-rls-lockdown.mjs` — new. Anon-key REPL probe. Reads every locked table with the public anon JWT and asserts `rows=0`; reads the 2 deferred tables and asserts they still return rows. Used to verify Phase 1 post-apply (14/14 pass) and will rerun after Phase 2.
- `worker/worker.js` — added `runFindDealsTestMode(job, supabaseClient)` helper, an env-gated short-circuit in `processPendingJobs` after `claimJob`, and exported the helper. Production code path is byte-identical when `WORKER_TEST_MODE !== 'true'`.
- `tests/integration/worker-test-mode.test.js` — new. 5 vitest cases exercising the test-mode short-circuit: inserts 3 deals, marks scan_run/job/search complete, real `runFindDeals` is not called.
- `docs/USER_FLOWS.md` — §13 item 2 (top-up bug) marked Resolved 2026-05-10; new §14 RLS Lockdown Status documenting Phase 1 / Phase 2 / pre-existing RLS tables; new §15 Worker Test Mode documenting the env var.

## Files changed in this approval commit

- `verification/ship-approved-fix-rls-lockdown.md` — this file.

## Verification before push

- Migration applied via Supabase MCP `apply_migration`. Post-apply `pg_tables.rowsecurity` confirmed `true` on all 12 locked tables, `false` on the 2 deferred.
- `scripts/verify-rls-lockdown.mjs`: 14/14 pass (12 locked return 0 rows under anon JWT; 2 deferred still return rows so `/results/` keeps working).
- `npm test`: 88/88 pass (baseline 83 + 5 new worker-test-mode cases, zero regressions).
- `curl https://dealhound.pro/api/health`: 200 OK.

## Confirmation

No files outside the intended scope were modified. `api/*` endpoints, `results/index.html`, dashboard, chat, free-scan, and the find-deals skill were not touched. Phase 2 work (the `results/` migration and locking the final 2 tables) is documented in `docs/USER_FLOWS.md` §14.2 as a separate follow-up.
