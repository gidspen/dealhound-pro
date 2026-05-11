# Supabase RLS Hardening — New-Session Prompt

Copy everything between the `===` markers into a fresh Claude Code session in `dealhound-pro/`.

```
===
Production security task — Deal Hound Supabase (project `incredible-ai-deals`, ref `gggmmjvwbbfvrtjjlqvr`).

## The problem

The Supabase advisory on `mcp__supabase__list_tables` flagged 14 tables in this project with **Row Level Security DISABLED**. That means anyone holding the anon publishable key (which is in the deployed dashboard JS) can read OR write every row in every one of these tables — including users' Stripe customer/subscription IDs and the 83K-row `deals` table that's our entire moat.

This was caught during the launch-prep PR (apps#47) but explicitly NOT auto-fixed: enabling RLS without policies blocks ALL access including the legitimate API. Needs a deliberate session.

## Tables exposed (verify with mcp__supabase__list_tables before acting)

users, deals, deal_searches, scrape_jobs, scan_runs, scan_progress, free_scan_requests, conversations, deal_outreach, deal_outreach_actions, deal_financials, deal_financial_files, raw_listings, user_deal_stars, user_deal_views, user_deal_archives.

(`deal_hound_waitlist` already has RLS enabled — leave it.)

## How the app actually authenticates today (read this carefully)

There is **no Supabase Auth in use**. Read [docs/USER_FLOWS.md §0.3](../USER_FLOWS.md) — auth model is "email-only soft auth": frontend reads `localStorage.dh_email` and passes it as a query param. The backend trusts the email and uses the **service-role key** for all DB operations in `api/*.js` files (see e.g. [api/user-data.js:5-9](../../api/user-data.js)).

So the policy story is simple:
- The dashboard frontend should NOT talk to Supabase directly with the anon key (verify: grep for `createClient` in `dashboard/src/`).
- All DB access goes through `/api/*` Vercel functions using the service-role key.
- Service role bypasses RLS, so enabling RLS does not break the API.
- Anon key access should be rejected for everything (or a tightly-scoped read-only on a future public surface, but per LAUNCH_STRATEGY the public scan viewer was retired in apps#47).

## Plan (proposed — confirm before acting)

1. **Audit anon key usage.** Search the codebase for any Supabase client created with the publishable / anon key. There should be zero in any committed code. If you find one, that's the real bug — fix it first.

2. **For each of the 14 tables, write a single policy** that allows the service_role and rejects everything else:

   ```sql
   ALTER TABLE <table> ENABLE ROW LEVEL SECURITY;
   CREATE POLICY "service_role_all" ON <table>
     FOR ALL TO service_role
     USING (true)
     WITH CHECK (true);
   ```

   (`service_role` is a built-in Postgres role in every Supabase project. Default behavior with RLS enabled and no policies = block all. The policy above explicitly grants the service role full access; anon and authenticated remain blocked.)

3. **Apply via `mcp__supabase__apply_migration`** with name `enable_rls_with_service_role_policy`. Do it as ONE migration so it's atomic — partial failure leaves the DB in a half-locked state.

4. **Smoke test BEFORE walking away:**
   - `npm test` → all 83 integration tests must still pass (they use the service-role key, so should be unaffected).
   - Open dealhound.pro/dashboard with a real account, run a chat → confirm scans/deals load.
   - Hit `/api/health` → 200.
   - If anything breaks: `mcp__supabase__execute_sql` with `ALTER TABLE <table> DISABLE ROW LEVEL SECURITY;` to roll back per-table.

5. **Verify the lockdown:** From a Node REPL, create a Supabase client with the ANON key (not service role) and try to `select * from users limit 1` — should return zero rows or an error, NOT the actual data.

## Edge cases to think through, not skip

- **`free_scan_requests` IP rate-limit query** ([api/free-scan-start.js:60-72](../../api/free-scan-start.js)) — uses service-role, fine.
- **Stripe webhook** ([api/stripe-webhook.js](../../api/stripe-webhook.js)) — uses service-role, fine.
- **Worker** ([worker/worker.js](../../worker/worker.js)) — runs on Mac Pro, uses service-role from env, fine.
- **dashboard-dist** built JS — should not embed any Supabase client at all. Verify.
- **The `find-deals` skill** running inside the worker — uses Python, check if it does direct Supabase access. If so, ensure it's using the service-role key, not anon.

## Out of scope (do NOT do these in this session)

- Don't migrate to Supabase Auth (separate decision; current launch is email-only).
- Don't write per-user policies (`user_deal_stars` could in theory have `auth.email() = user_email` policies, but we're not using auth.email and adding it changes the API contract — defer).
- Don't enable RLS on any table you didn't audit first.

## Definition of done

- `mcp__supabase__list_tables` no longer reports the `rls_disabled` advisory.
- `npm test` passes 83/83.
- Dashboard at dealhound.pro still loads + chat still works for a real user.
- Anon-key Node REPL can't read users/deals (verified).
- Migration SQL committed to `scripts/migrations/2026-MM-DD-rls-service-role-only.sql`.
- One commit, conventional message: `fix(security): enable RLS with service-role-only policies on all user-facing tables`.

When you're done, summarize: which tables locked, smoke-test results, and any anon-key usage you had to remove.
===
```
