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

## Confirmation

No files outside the intended scope were modified.
