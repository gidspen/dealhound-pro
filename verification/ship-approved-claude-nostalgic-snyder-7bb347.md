## Intent

This branch delivers two targeted fixes: (1) sorts debrief deals by `priority_score` so the Deal 1/2/3 numbering in chat responses matches the rank order shown in the UI dashboard, and (2) implements the free-first-run paywall logic so null-tier users get one free scan before being gated.

## Files changed

- `api/chat.js` — adds `parseBreakdown` helper for safe JSON.parse, pre-parses score_breakdown once per deal, sorts by priority_score descending, removes dead null guards
- `api/_lib/paywall.js` — null-tier + 0 runs → allowed (tier_limit: 1); null-tier + ≥1 run → 402 with "free scan" error; adds bonus_runs support from main merge
- `tests/integration/paywall.test.js` — adds required agent_name field to user inserts; improves afterAll error logging

## Confirmation

No files outside the intended scope were modified.
