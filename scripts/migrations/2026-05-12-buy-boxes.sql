-- Migration: create buy_boxes table and wire deal_searches foreign key
-- Date:      2026-05-12
-- Reason:    Buy boxes are being promoted to first-class objects (see
--            docs/buy-box-persistence-spec.md). Previously, a buy box
--            lived inside a single deal_searches row — ephemeral, one-per-scan,
--            no identity of its own. This migration:
--              1. Creates the buy_boxes table with status/versioning columns
--                 so the worker can monitor named strategies on a schedule.
--              2. Adds buy_box_id + buy_box_version to deal_searches so every
--                 scan result can be traced back to the exact criteria version
--                 that produced it.
--            Existing deal_searches rows are unaffected: buy_box_id and
--            buy_box_version remain NULL and the dashboard treats them as
--            legacy results (backward-compatible).
--
-- Idempotent: CREATE TABLE IF NOT EXISTS, CREATE INDEX IF NOT EXISTS, and
--             ADD COLUMN IF NOT EXISTS are all no-ops when the object already
--             exists. Safe to re-run.
--
-- RLS note:  ENABLE ROW LEVEL SECURITY with no policies restricts table
--            access to service_role only — consistent with the Phase-1 pattern
--            established in 2026-05-11-rls-lockdown-phase1.sql. All server
--            endpoints use SUPABASE_SERVICE_KEY (bypasses RLS), so no explicit
--            policy is needed.
--
-- Rollback:
--   DROP INDEX IF EXISTS public.idx_deal_searches_buy_box;
--   ALTER TABLE public.deal_searches DROP COLUMN IF EXISTS buy_box_version;
--   ALTER TABLE public.deal_searches DROP COLUMN IF EXISTS buy_box_id;
--   DROP INDEX IF EXISTS public.idx_buy_boxes_status;
--   DROP INDEX IF EXISTS public.idx_buy_boxes_user_email;
--   DROP TABLE IF EXISTS public.buy_boxes;

-- ---------------------------------------------------------------------------
-- 1. buy_boxes table
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.buy_boxes (
  id                  uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_email          text        NOT NULL REFERENCES public.users(email) ON DELETE CASCADE,
  name                text        NOT NULL DEFAULT 'Buy Box',
  criteria            jsonb       NOT NULL,
  status              text        NOT NULL DEFAULT 'draft'
                                  CHECK (status IN ('active', 'draft', 'archived')),
  version             integer     NOT NULL DEFAULT 1,
  criteria_updated_at timestamptz NOT NULL DEFAULT now(),
  last_scanned_at     timestamptz,
  created_at          timestamptz NOT NULL DEFAULT now()
);

-- ---------------------------------------------------------------------------
-- 2. Indexes on buy_boxes
-- ---------------------------------------------------------------------------

CREATE INDEX IF NOT EXISTS idx_buy_boxes_user_email
  ON public.buy_boxes (user_email);

-- Composite index supports the scheduler loop: filter active boxes per user
CREATE INDEX IF NOT EXISTS idx_buy_boxes_status
  ON public.buy_boxes (user_email, status);

-- ---------------------------------------------------------------------------
-- 3. Wire deal_searches → buy_boxes
-- ---------------------------------------------------------------------------

ALTER TABLE public.deal_searches
  ADD COLUMN IF NOT EXISTS buy_box_id      uuid    REFERENCES public.buy_boxes(id) ON DELETE SET NULL;

ALTER TABLE public.deal_searches
  ADD COLUMN IF NOT EXISTS buy_box_version integer;

-- Supports dashboard query: WHERE buy_box_id = ? AND buy_box_version = ?
CREATE INDEX IF NOT EXISTS idx_deal_searches_buy_box
  ON public.deal_searches (buy_box_id, buy_box_version);

-- ---------------------------------------------------------------------------
-- 4. Row-level security (service_role bypass — no explicit policies needed)
-- ---------------------------------------------------------------------------

ALTER TABLE public.buy_boxes ENABLE ROW LEVEL SECURITY;
