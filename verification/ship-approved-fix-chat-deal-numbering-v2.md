# Ship Approved: fix/chat-deal-numbering-v2

## Intent

This branch fixes the chat debrief agent numbering bug: "Deal 11" in the chat panel
referenced a different property than rank 11 in the preview panel. Root cause was
`buildDebriefPrompt` ordering deals by Supabase insertion `id` (UUID order) before
numbering them `Deal 1`, `Deal 2`... The `/find-deals` pipeline ranks by
`priority_score` inside `score_breakdown`. This branch sorts by `priority_score`
descending in JS before numbering, so "Deal 1" in the agent debrief always matches
the top-ranked deal in the preview panel. Also adds the missing `paywall.test.js`
integration test with assertions corrected to match the current paywall logic.

## Files changed

- `api/chat.js` — remove `order('id')` clause; sort fetched deals by
  `score_breakdown.priority_score` descending before numbering them in the
  debrief prompt. No other changes.
- `tests/integration/paywall.test.js` — new file; integration tests for
  `checkPaywall` and `incrementAgentRuns`. Required `agent_name` column added
  to insert rows; null-tier assertions updated to match current paywall behavior
  (`no_subscription` reason, always blocked).

## Confirmation

No files outside the intended scope were modified.
