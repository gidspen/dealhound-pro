-- Migration: add bonus_runs to users for top-up SKU
-- Date:      2026-05-10
-- Reason:    The top-up webhook handler was incrementing agent_runs_used by 5,
--            which made paying users MORE blocked, not less. Bonus runs are now
--            tracked in a separate column. Paywall check becomes:
--                user.agent_runs_used >= (TIER_LIMITS[tier] + bonus_runs)
--            Bonus runs persist across the monthly reset until consumed.
--
-- Idempotent: ADD COLUMN IF NOT EXISTS — safe to re-run.

ALTER TABLE users
  ADD COLUMN IF NOT EXISTS bonus_runs INTEGER NOT NULL DEFAULT 0;

-- Optional: replace the increment_agent_runs RPC with a bonus_runs version.
-- The webhook handler also has a manual fallback so the RPC is not strictly required.
CREATE OR REPLACE FUNCTION increment_bonus_runs(p_email TEXT, p_amount INTEGER)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE users
  SET bonus_runs = COALESCE(bonus_runs, 0) + p_amount
  WHERE email = p_email;
END;
$$;
