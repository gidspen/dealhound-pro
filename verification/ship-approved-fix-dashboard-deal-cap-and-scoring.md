## Intent

Fixes two bugs causing "50 deals analyzed" and all deals showing as WATCH on the dashboard,
even when 196+ deals passed hard filters.

Bug 1 — deal fetch cap: `api/user-data.js` had `.limit(50)` on the deals query, silently
truncating any scan with more than 50 results. Raised to 500.

Bug 2 — inaccurate deal counts: `dealCountMap` was derived from the 50 fetched rows, so
scans with >50 deals showed wrong counts in the sidebar tally and per-scan count. Replaced
with a lightweight `search_id`-only count query that runs before the display fetch and is
accurate regardless of the display limit.

The all-WATCH issue is a scoring artifact (no `score_breakdown` on the current deals), not
a code bug — that requires running the scoring pipeline separately.

## Files changed

- `api/user-data.js` — add lightweight count query; raise display limit from 50 to 500;
  remove stale derived-count block

### worker/worker.js — `maybeFallbackScore` helper + wiring in headed run path

Adds a post-PTY scorer.py safety net. After every headed PTY run, checks if
`scored-inline.json` was written (Step 4b ran) but no deals have `score_breakdown`
(Step 4c — scorer.py — was interrupted). If so, runs `scorer.py --persist-only`
directly from the worker process. No AI calls; pure Supabase persistence of
already-computed scores. Best-effort: scorer failure doesn't fail the scan.

## Confirmation

No files outside the intended scope were modified.
