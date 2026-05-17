# Ship verification — fix/chat-compute-tracking

## Intent

Wire compute tracking into the chat endpoints (`api/deal-chat.js`, `api/chat.js`) so that `users.monthly_compute_used` increments by the dollar cost of each chat's tokens. Before this change, the Anthropic SDK streamed responses and we never read `usage` — every user's `monthly_compute_used` has been `$0.0000` since launch (confirmed via Supabase query across all 28 users). After this change, `stream.finalMessage().usage` is read after the for-await loop completes, converted to dollars using the cost constants already exported from `worker/cost-guardrails.js`, and written via the existing `recordComputeUsed` helper that the worker uses. Tracking is non-fatal: a failure logs a warning but never breaks the streaming response to the user. Out of scope: the scan worker's `DEALHOUND_TOKENS` parser (separate fix, sized as Fix B in the original triage).

## Files changed

- `api/_lib/chat-compute.js` (new, 29 lines) — exports `costFromUsage(usage)` and `recordChatComputeFromUsage({email, usage, supabase, endpoint})`. Centralizes the cost math + DB write so both endpoints call one helper.
- `api/deal-chat.js` (+14 lines) — adds the require and the post-stream tracking try/catch immediately after the for-await loop and before the conversation save block.
- `api/chat.js` (+14 lines) — same pattern, with `endpoint: 'chat'` label so log lines can be distinguished from `deal-chat`.
- `eslint.config.js` (+1 line) — adds `api/_lib/chat-compute.js` to the explicit CJS-Node files allowlist alongside the existing `api/_lib/*` entries (paywall, scan-trigger, etc.). Required because the flat-config defaults to ESM and would flag `require`/`module` as undefined.
- `tests/integration/chat-compute.test.js` (new, 120 lines) — six integration tests against real Supabase (no SDK mocks, matching the repo's existing test style): cost-math correctness, null-usage no-op, single-call DB write, multi-call accumulation, missing-usage no-op, and non-fatal swallow-on-DB-error.

## Confirmation

No files outside the intended scope were modified. Specifically:
- `worker/` is untouched (Fix B for scan compute is a separate change).
- `api/conversation.js` is untouched (it's a Supabase-only GET endpoint with no Anthropic call — confirmed by reading the full file during planning).
- No DB migrations, no schema changes, no frontend changes.
- No changes to the streaming response shape, headers, or timing — tracking happens AFTER the for-await loop drains, so user-visible response latency is unaffected.

Tests: 6/6 new tests pass; full integration suite 100/100 green (16 files, no regressions in pre-existing tests).
