-- Migration: one-time backfill — create buy_boxes row for monsees.dave@gmail.com
-- Date:      2026-05-12
-- Reason:    Decision locked 2026-05-11 (see docs/buy-box-persistence-spec.md §Decisions):
--            "The only active user pre-launch is monsees.dave@gmail.com. On deploy,
--            a one-time migration script reads their most recent deal_searches row,
--            creates a buy_boxes row from that criteria (status = active), and
--            backfills buy_box_id on their existing deal_searches rows."
--            This script implements that migration manually and safely.
--
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- !!  ONE-TIME MANUAL MIGRATION — DO NOT EXECUTE AUTOMATICALLY.             !!
-- !!  Review and apply manually after PR merge.                             !!
-- !!  Verify the DRY RUN output below before running the BEGIN/COMMIT block. !!
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
--
-- Idempotent: The INSERT uses WHERE NOT EXISTS — re-running inserts nothing
--             if the buy_boxes row already exists for this user. The UPDATE
--             targets only rows WHERE buy_box_id IS NULL, so re-running after
--             a partial application is safe.
--
-- Rollback:
--   UPDATE public.deal_searches
--     SET buy_box_id = NULL, buy_box_version = NULL
--     WHERE user_email = 'monsees.dave@gmail.com';
--
--   DELETE FROM public.buy_boxes
--     WHERE user_email = 'monsees.dave@gmail.com'
--       AND name = 'Migrated Buy Box';

-- ---------------------------------------------------------------------------
-- DRY RUN: run these SELECT statements first to verify what will be touched.
-- Do NOT include these in the BEGIN/COMMIT block — they are read-only checks.
-- ---------------------------------------------------------------------------

-- DRY RUN: most recent deal_searches row that will seed the buy_boxes criteria
SELECT
  id,
  user_email,
  buy_box,
  run_at
FROM public.deal_searches
WHERE user_email = 'monsees.dave@gmail.com'
ORDER BY run_at DESC NULLS LAST
LIMIT 1;

-- DRY RUN: count of deal_searches rows that will be backfilled with buy_box_id
SELECT COUNT(*) AS rows_to_backfill
FROM public.deal_searches
WHERE user_email = 'monsees.dave@gmail.com'
  AND buy_box_id IS NULL;

-- ---------------------------------------------------------------------------
-- ACTUAL MIGRATION — review DRY RUN output before executing this block
-- ---------------------------------------------------------------------------

BEGIN;

  -- Step 1: Insert buy_boxes row for monsees.dave@gmail.com using criteria
  -- from their most recent deal_searches row. WHERE NOT EXISTS makes this
  -- safe to re-run — if the row already exists, this is a no-op.
  INSERT INTO public.buy_boxes (
    user_email,
    name,
    criteria,
    status,
    version,
    criteria_updated_at,
    created_at
  )
  SELECT
    ds.user_email,
    'Migrated Buy Box'    AS name,
    ds.buy_box            AS criteria,
    'active'              AS status,
    1                     AS version,
    COALESCE(ds.run_at, now())  AS criteria_updated_at,
    COALESCE(ds.run_at, now())  AS created_at
  FROM public.deal_searches ds
  WHERE ds.user_email = 'monsees.dave@gmail.com'
    AND ds.buy_box IS NOT NULL
    AND NOT EXISTS (
      SELECT 1
      FROM public.buy_boxes bb
      WHERE bb.user_email = 'monsees.dave@gmail.com'
    )
  ORDER BY ds.run_at DESC NULLS LAST
  LIMIT 1;

  -- Step 2: Backfill buy_box_id on all existing deal_searches rows for this
  -- user. Targets only rows where buy_box_id IS NULL so partial re-runs are
  -- safe. buy_box_version is set to 1 to match the seeded buy_boxes row.
  UPDATE public.deal_searches
  SET
    buy_box_id      = (
      SELECT id
      FROM public.buy_boxes
      WHERE user_email = 'monsees.dave@gmail.com'
      LIMIT 1
    ),
    buy_box_version = 1
  WHERE user_email  = 'monsees.dave@gmail.com'
    AND buy_box_id IS NULL;

COMMIT;
