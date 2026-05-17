/**
 * paywall.js — subscription enforcement helpers
 */

const TIER_LIMITS = {
  founding: 10,
  hunter: 10,
  investor: 50,
  operator: Infinity,
};

// Free trial: every email gets this many scans before being asked to subscribe.
const FREE_RUNS = 1;

/**
 * checkPaywall(email, supabase)
 *
 * Returns:
 *   { allowed: false, status: 402, body: { error, checkoutUrl, tier, reason } }
 *   { allowed: true, user: { email, subscription_tier, agent_runs_used }, tier_limit, free_run }
 *
 * Policy:
 *   - No row → allowed (FREE_RUNS available, row gets created on increment)
 *   - Null tier + agent_runs_used < FREE_RUNS → allowed (free trial)
 *   - Null tier + agent_runs_used >= FREE_RUNS → blocked (free_run_used)
 *   - Subscribed tier → allowed up to tier limit + bonus_runs
 */
async function checkPaywall(email, supabase) {
  const { data: user } = await supabase
    .from('users')
    .select('email, subscription_tier, agent_runs_used, bonus_runs')
    .eq('email', email)
    .single();

  // No row — brand new user, free first run on us
  if (!user) {
    return {
      allowed: true,
      user: {
        email,
        subscription_tier: null,
        agent_runs_used: 0,
        bonus_runs: 0,
      },
      tier_limit: FREE_RUNS,
      free_run: true,
    };
  }

  // No tier — unsubscribed. Free trial until they hit FREE_RUNS.
  if (user.subscription_tier == null) {
    if ((user.agent_runs_used || 0) < FREE_RUNS) {
      return {
        allowed: true,
        user: {
          email: user.email,
          subscription_tier: null,
          agent_runs_used: user.agent_runs_used || 0,
          bonus_runs: 0,
        },
        tier_limit: FREE_RUNS,
        free_run: true,
      };
    }
    return {
      allowed: false,
      status: 402,
      body: {
        error:
          "That was your free scan — solid work. Pick a plan to keep hunting and we'll line up your next round.",
        reason: 'free_run_used',
        checkoutUrl: '/api/create-checkout',
        tier: null,
        runs_used: user.agent_runs_used || 0,
        runs_limit: FREE_RUNS,
      },
    };
  }

  // Subscribed but out of runs (tier limit + any purchased top-up bonus)
  const tierLimit = TIER_LIMITS[user.subscription_tier];
  const bonus = user.bonus_runs || 0;
  const effectiveLimit = tierLimit === Infinity ? Infinity : tierLimit + bonus;

  if (tierLimit !== undefined && user.agent_runs_used >= effectiveLimit) {
    return {
      allowed: false,
      status: 402,
      body: {
        error: "You're out of runs this month. Top up 5 runs for $25, or wait until next month.",
        reason: 'out_of_runs',
        checkoutUrl: '/api/create-checkout',
        tier: user.subscription_tier,
        runs_used: user.agent_runs_used,
        runs_limit: effectiveLimit,
        bonus_runs: bonus,
      },
    };
  }

  return {
    allowed: true,
    user: {
      email: user.email,
      subscription_tier: user.subscription_tier,
      agent_runs_used: user.agent_runs_used,
      bonus_runs: bonus,
    },
    tier_limit: effectiveLimit,
  };
}

/**
 * incrementAgentRuns(email, supabase)
 *
 * Increments agent_runs_used by 1. Tries the RPC first; falls back to a
 * read-then-write, and finally to an upsert if the user row doesn't exist yet
 * (the free-first-run case: no Stripe webhook has created the row).
 *
 * Returns { ok: boolean, error?: string }. Never throws.
 */
async function incrementAgentRuns(email, supabase) {
  try {
    const { error: rpcError } = await supabase.rpc('increment_agent_runs', {
      p_email: email,
      p_amount: 1,
    });

    if (!rpcError) {
      // RPC succeeded — but it may have been a no-op if no row exists.
      // Verify the row exists; if not, fall through to upsert.
      const { data: check } = await supabase
        .from('users')
        .select('email')
        .eq('email', email)
        .maybeSingle();

      if (check) {
        return { ok: true };
      }
    } else {
      console.warn(
        'increment_agent_runs rpc failed, falling back to manual update:',
        rpcError.message
      );
    }

    // Read existing row (if any) so we can preserve agent_runs_used.
    const { data: user } = await supabase
      .from('users')
      .select('agent_runs_used')
      .eq('email', email)
      .maybeSingle();

    if (user) {
      const { error: writeError } = await supabase
        .from('users')
        .update({ agent_runs_used: (user.agent_runs_used || 0) + 1 })
        .eq('email', email);

      if (writeError) {
        return { ok: false, error: writeError.message };
      }
      return { ok: true };
    }

    // No row yet — first-run user. Upsert so the row exists for next time.
    const { error: upsertError } = await supabase.from('users').upsert(
      {
        email,
        agent_runs_used: 1,
        agent_name: 'Scout',
      },
      { onConflict: 'email' }
    );

    if (upsertError) {
      return { ok: false, error: upsertError.message };
    }

    return { ok: true };
  } catch (err) {
    return { ok: false, error: err.message };
  }
}

module.exports = { checkPaywall, incrementAgentRuns, TIER_LIMITS, FREE_RUNS };
