# Ship Approval — claude/admiring-bardeen-ea9ece (Phase 3 persist-skip fallback)

## Intent

Fix the open follow-up flagged in PR #67's verification doc (`verification/ship-approved-worker-hang-fix.md` lines 23–25): the orchestrating Claude inside the worker PTY sometimes misreads scraper bail-out lines as a failed scrape and skips Step 4a (`pipeline.py` persist). Result: raw-listings-\*.json files exist on disk (200+ listings) but zero rows land in the deals table. PR #67 introduced the bail-out lines (`"N consecutive failures — bailing"`, `"wall-time cap hit (240s >= 240s) — bailing..."`) as the fix for the 90-minute Crexi enrichment hang — they are normal output on cold worker profiles, not errors, and the scraper still exits 0 with listings saved.

The fix adds `maybeFallbackPipeline` to `worker/worker.js` as a deterministic safety net mirroring the existing `maybeFallbackScore` pattern. After the PTY returns, if any `raw-listings-*.json` was written this run AND the deals table has 0 rows for the search_id, spawn `python3 pipeline.py` directly with the worker's env. Wired in BEFORE the scorer fallback so the pipeline → scoring order is preserved. Users get raw filtered listings persisted even when inline scoring is skipped; the dashboard already renders unscored deals gracefully. The fallback does not re-attempt scoring (that requires Claude). Best-effort: non-zero pipeline exit or spawn errors are logged and swallowed so the scan still completes and the silent-zero guard fires for visibility.

The function takes dependency-injection seams (`fs`, `spawn`, `skillDir`) so the regression test runs fully offline with fakes — no `vi.mock` of node built-ins. 12 unit tests cover all six skip preconditions (pipeline.py missing, no search_id, no raw files, stale files >2h, deals already exist, non-matching filenames) and six trigger paths (happy path, exact spawn args, supabase query shape, single-source scrape, non-zero exit best-effort, spawn-error best-effort, partial statSync failure tolerance). All 12 pass in 7 ms. Full local run including worker-contract and cost-guardrails suites: 65/65 green.

## Files changed

- `worker/worker.js` — Adds `maybeFallbackPipeline` (95 LOC) above `maybeFallbackScore`, wires it into the headed-mode `runFn` before the scorer fallback, exports it from `module.exports` so the test can import it.
- `tests/integration/worker-fallback-pipeline.test.js` — NEW. 12 vitest cases for the fallback's skip and trigger logic, fully offline via DI fakes. Sets `SUPABASE_URL` / `SUPABASE_SERVICE_KEY` to fixture strings before importing `worker.js` so the module-load Supabase client construction doesn't error.

## Confirmation

No files outside the intended scope were modified. The diff is two files: one source change adding a new function plus a single call site, and one new test file. Zero changes to schema, migrations, env vars, build config, dashboard, API, or skill files. The skill at `~/.claude/skills/find-deals/pipeline.py` is invoked but not modified — the fallback uses the same script the orchestrating Claude would have used at Step 4a. No `--no-verify` used. No force-push. Branch is `claude/admiring-bardeen-ea9ece`, not main.
