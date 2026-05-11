# Ship approval — feat/free-first-run

## Intent

Reinstates the free-first-run policy that was reverted in `afccf1c`. Every email gets one free scan (FREE_RUNS=1) before the paywall asks them to subscribe. This is the locked launch strategy — Deal Hound is not paid-only. The earlier revert claimed "main updated the spec," which was wrong: the spec is unchanged, the revert was a misread during the bonus_runs merge.

## Files changed

- **api/\_lib/paywall.js** — Adds `FREE_RUNS` constant. `checkPaywall` now allows no-row users and null-tier users with `agent_runs_used < FREE_RUNS`, returning `free_run: true` and `tier_limit: FREE_RUNS`. Null-tier users past the limit return `reason: 'free_run_used'` (was `'no_subscription'`). `incrementAgentRuns` now upserts a fresh row when none exists so the free-first-run counter persists for next time.
- **tests/integration/paywall.test.js** — Rewrites tests for the new policy: no-row → allowed, null-tier-0 → allowed (free run), null-tier-1 → blocked (free_run_used), operator/founding tier logic unchanged, plus a new `incrementNoRow` test for the upsert path. 8/8 passing against live Supabase.

## Confirmation

No files outside the intended scope were modified.
