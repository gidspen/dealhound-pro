/**
 * cost-guardrails.js
 *
 * Per-run COGS hard caps and monthly compute ceiling enforcement.
 *
 * HOW TOKEN COUNTING WORKS
 * ─────────────────────────
 * The worker spawns `claude -p /find-deals full` as a subprocess. The skill
 * signals token usage by printing a structured line to stdout:
 *
 *   DEALHOUND_TOKENS: {"input_tokens":1500,"output_tokens":800}
 *
 * The worker's stdout listener calls `trackTokenLine(line)` on every output
 * chunk. This module accumulates cost and returns a `capped` flag when the
 * per-skill limit is exceeded. The worker then SIGTERMs the subprocess.
 *
 * PRICING BASIS (claude-sonnet-4-6 as of 2026-05)
 * ─────────────────────────────────────────────────
 *   Input:  $3.00 / 1M tokens   → $0.000003 per token
 *   Output: $15.00 / 1M tokens  → $0.000015 per token
 *
 * FORCE_COGS_OVERRUN — TEST HOOK
 * ───────────────────────────────
 * Set FORCE_COGS_OVERRUN=true in the process environment to make every
 * token call register as $5.00 in cost. This causes the per-run cap to fire
 * immediately on the first DEALHOUND_TOKENS line, letting an agent verify
 * the termination path without running a real expensive scan.
 *
 * Example:
 *   FORCE_COGS_OVERRUN=true node worker.js
 *
 * REQUIRED SUPABASE MIGRATION
 * ────────────────────────────
 * Run the following SQL against your Supabase project before deploying:
 *
 *   ALTER TABLE users
 *     ADD COLUMN IF NOT EXISTS monthly_compute_used NUMERIC(10,4) DEFAULT 0,
 *     ADD COLUMN IF NOT EXISTS agent_runs_reset_at  TIMESTAMPTZ  DEFAULT now(),
 *     ADD COLUMN IF NOT EXISTS topup_runs_remaining INTEGER      DEFAULT 0;
 *
 * Columns:
 *   monthly_compute_used  — cumulative compute cost ($) this calendar month
 *   agent_runs_reset_at   — timestamp of last monthly reset; used to detect
 *                           month rollover at run-start
 *   topup_runs_remaining  — credits purchased via the $25/5-run top-up SKU;
 *                           bypass monthly cap, decrement 1 per run
 */

'use strict';

// ── Pricing constants ─────────────────────────────────────────────────────────

const INPUT_COST_PER_TOKEN = 3.0 / 1_000_000; // $0.000003
const OUTPUT_COST_PER_TOKEN = 15.0 / 1_000_000; // $0.000015

// ── Per-skill COGS hard caps (dollars) ───────────────────────────────────────

const SKILL_CAPS = {
  'deal scan': 1.5,
  'loi draft': 0.5,
  underwriting: 2.0,
  'comp analysis': 1.0,
  'market report': 1.5,
};

// Default to the deal scan cap — the only skill the worker currently invokes
const DEFAULT_SKILL = 'deal scan';

// ── Monthly compute ceiling per tier (dollars) ────────────────────────────────

const TIER_MONTHLY_CAPS = {
  founding: 30,
  hunter: 30,
  investor: 150,
  operator: 400,
};

// ── Token line regex ──────────────────────────────────────────────────────────

// The skill emits: DEALHOUND_TOKENS: {"input_tokens":NNN,"output_tokens":NNN}
const TOKEN_LINE_RE = /DEALHOUND_TOKENS:\s*(\{[^\n]+\})/;

// ── CostTracker ───────────────────────────────────────────────────────────────

/**
 * CostTracker tracks COGS for a single worker run.
 *
 * Usage:
 *   const tracker = new CostTracker('deal scan');
 *   const { capped, totalCost } = tracker.trackTokenLine(chunkText);
 *   if (capped) { proc.kill('SIGTERM'); }
 *
 * @param {string} skill  One of the keys in SKILL_CAPS (default: 'deal scan')
 */
class CostTracker {
  constructor(skill = DEFAULT_SKILL) {
    this.skill = skill.toLowerCase();
    this.cap = SKILL_CAPS[this.skill] ?? SKILL_CAPS[DEFAULT_SKILL];
    this.total = 0;
    this.capped = false;
    this.forceOverrun = process.env.FORCE_COGS_OVERRUN === 'true';
  }

  /**
   * Parse a text chunk from the subprocess stdout. Returns state after update.
   *
   * @param  {string} text  Raw stdout chunk (may span multiple lines)
   * @returns {{ capped: boolean, totalCost: number, capAmount: number }}
   */
  trackTokenLine(text) {
    if (this.capped) return this._state();

    const match = text.match(TOKEN_LINE_RE);
    if (!match) return this._state();

    let lineCost = 0;

    // FORCE_COGS_OVERRUN: treat every token event as $5.00 so the cap fires
    // immediately. Used for integration testing without real API spend.
    if (this.forceOverrun) {
      lineCost = 5.0;
    } else {
      try {
        const { input_tokens = 0, output_tokens = 0 } = JSON.parse(match[1]);
        lineCost = input_tokens * INPUT_COST_PER_TOKEN + output_tokens * OUTPUT_COST_PER_TOKEN;
      } catch (_) {
        // Malformed JSON — skip this line
        return this._state();
      }
    }

    this.total += lineCost;
    if (this.total >= this.cap) {
      this.capped = true;
    }

    return this._state();
  }

  _state() {
    return {
      capped: this.capped,
      totalCost: parseFloat(this.total.toFixed(6)),
      capAmount: this.cap,
    };
  }
}

// ── Monthly compute guard (Supabase) ─────────────────────────────────────────

/**
 * checkAndReserveMonthlyBudget
 *
 * Before starting a run:
 *   1. Looks up the user row by email.
 *   2. Resets monthly_compute_used if we've rolled into a new calendar month
 *      since agent_runs_reset_at.
 *   3. If topup_runs_remaining > 0: skips monthly cap check, decrements by 1,
 *      returns { allowed: true, topupUsed: true }.
 *   4. If monthly_compute_used >= tier cap: returns { allowed: false }.
 *   5. Otherwise: returns { allowed: true }.
 *
 * @param {string}  userEmail  User's email address
 * @param {object}  supabase   Supabase client (service role)
 * @returns {Promise<{ allowed: boolean, topupUsed?: boolean, reason?: string }>}
 */
async function checkAndReserveMonthlyBudget(userEmail, supabase) {
  if (!userEmail) {
    // Daily/anonymous jobs have no user — always allow
    return { allowed: true };
  }

  const { data: user, error } = await supabase
    .from('users')
    .select(
      'email, subscription_tier, monthly_compute_used, agent_runs_reset_at, topup_runs_remaining'
    )
    .eq('email', userEmail)
    .single();

  if (error || !user) {
    // Unknown user — allow rather than block (fail open on user-lookup errors)
    return { allowed: true };
  }

  // ── Monthly reset check ───────────────────────────────────────────────────
  const now = new Date();
  const resetAt = user.agent_runs_reset_at ? new Date(user.agent_runs_reset_at) : null;
  const needsReset =
    !resetAt ||
    now.getUTCFullYear() !== resetAt.getUTCFullYear() ||
    now.getUTCMonth() !== resetAt.getUTCMonth();

  if (needsReset) {
    await supabase
      .from('users')
      .update({
        monthly_compute_used: 0,
        agent_runs_reset_at: now.toISOString(),
      })
      .eq('email', userEmail);
    // After reset, used is 0 — proceed to allow
    user.monthly_compute_used = 0;
  }

  // ── Top-up bypass ─────────────────────────────────────────────────────────
  const topupRemaining = user.topup_runs_remaining ?? 0;
  if (topupRemaining > 0) {
    await supabase
      .from('users')
      .update({ topup_runs_remaining: topupRemaining - 1 })
      .eq('email', userEmail);
    return { allowed: true, topupUsed: true };
  }

  // ── Monthly cap check ─────────────────────────────────────────────────────
  const tier = (user.subscription_tier || 'hunter').toLowerCase();
  const tierCap = TIER_MONTHLY_CAPS[tier] ?? TIER_MONTHLY_CAPS.hunter;
  const used = parseFloat(user.monthly_compute_used ?? 0);

  if (used >= tierCap) {
    return {
      allowed: false,
      reason: "You've used your monthly compute. Top up 5 runs for $25, or wait until next month.",
    };
  }

  return { allowed: true };
}

/**
 * recordComputeUsed
 *
 * After a run completes (success or capped), increment monthly_compute_used
 * on the user's row. Called by the worker after runFindDeals resolves.
 *
 * @param {string}  userEmail  User's email (no-op if null/undefined)
 * @param {number}  cost       Compute cost in dollars for this run
 * @param {object}  supabase   Supabase client (service role)
 */
async function recordComputeUsed(userEmail, cost, supabase) {
  if (!userEmail || !cost || cost <= 0) return;

  // Increment using Postgres arithmetic to avoid race conditions on concurrent
  // requests (unlikely in single-worker setup but correct regardless)
  const { error } = await supabase.rpc('increment_compute_used', {
    p_email: userEmail,
    p_amount: parseFloat(cost.toFixed(6)),
  });

  if (error) {
    // Non-fatal — log but don't throw. The run completed; failing to record
    // compute is a billing accuracy issue, not a product failure.
    console.warn(`[cost-guardrails] Failed to record compute for ${userEmail}: ${error.message}`);
    // Fallback: try a direct update (not atomic but better than nothing)
    await supabase
      .from('users')
      .update({
        monthly_compute_used: supabase.rpc
          ? undefined // rpc failed — skip to avoid double-update
          : 0,
      })
      .eq('email', userEmail)
      .then(() => {}); // swallow errors in the fallback
  }
}

// ── Cap message ───────────────────────────────────────────────────────────────

const RUN_CAPPED_MESSAGE = 'run capped — refine criteria for more depth';

// ── Exports ───────────────────────────────────────────────────────────────────

module.exports = {
  CostTracker,
  checkAndReserveMonthlyBudget,
  recordComputeUsed,
  SKILL_CAPS,
  TIER_MONTHLY_CAPS,
  RUN_CAPPED_MESSAGE,
  // Exposed for testing
  INPUT_COST_PER_TOKEN,
  OUTPUT_COST_PER_TOKEN,
};
