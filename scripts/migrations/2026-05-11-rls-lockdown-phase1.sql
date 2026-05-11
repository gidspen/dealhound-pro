-- Migration: enable RLS on 12 unprotected tables (Phase 1 of RLS lockdown)
-- Date:      2026-05-11
-- Reason:    These 12 tables had row_security=false, with anon + authenticated
--            granted full DML (SELECT/INSERT/UPDATE/DELETE). Anyone with the
--            project's anon JWT (publicly embedded in /results/index.html) could
--            read or mutate any row. Server endpoints (api/*, worker/) all use
--            SUPABASE_SERVICE_KEY, which bypasses RLS — so enabling RLS without
--            any policy effectively scopes table access to service_role only.
--
-- Out of scope (Phase 2): deal_searches + deals. /results/index.html reads
--            these directly from the browser via anon key. Locking them down
--            here would break every email-CTA link. Phase 2 will migrate the
--            page to a service-key API endpoint, then enable RLS on those two.
--
-- Idempotent: ENABLE ROW LEVEL SECURITY is a no-op when already enabled.
--
-- Rollback:  ALTER TABLE public.<table> DISABLE ROW LEVEL SECURITY;
--            (per-table — see Phase 1 rollback script if needed).

ALTER TABLE public.deal_financial_files  ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.deal_financials       ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.deal_outreach         ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.deal_outreach_actions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.free_scan_requests    ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.raw_listings          ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.scan_runs             ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.scrape_jobs           ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_deal_archives    ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_deal_stars       ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_deal_views       ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.users                 ENABLE ROW LEVEL SECURITY;
