/**
 * paywall.js — subscription enforcement helpers
 */

const TIER_LIMITS = {
  founding: 10,
  hunter: 10,
  investor: 50,
  operator: Infinity,
};

/**
 * checkPaywall(email, supabase)
 *
 * Returns:
 *   { allowed: false, status: 402, body: { error, checkoutUrl, tier } }
 *   { allowed: true, user: { email, subscription_tier, agent_runs_used }, tier_limit }
 */
async function checkPaywall(email, supabase) {
  const { data: user } = await supabase
    .from('users')
    .select('email, subscription_tier, agent_runs_used')
    .eq('email', email)
    .single();

  // No row or no tier — unsubscribed
  if (!user || user.subscription_tier == null) {
    return {
      allowed: false,
      status: 402,
      body: {
        error:
          "Hey, you'll need a subscription to run a scan. Pick a plan and let's get you hunting.",
        checkoutUrl: '/api/create-checkout',
        tier: null,
      },
    };
  }

  // Subscribed but out of runs
  const limit = TIER_LIMITS[user.subscription_tier];
  if (limit !== undefined && user.agent_runs_used >= limit) {
    return {
      allowed: false,
      status: 402,
      body: {
        error: "Hey, looks like you're out of runs this month — top up here?",
        checkoutUrl: '/api/create-checkout',
        tier: user.subscription_tier,
      },
    };
  }

  return {
    allowed: true,
    user: {
      email: user.email,
      subscription_tier: user.subscription_tier,
      agent_runs_used: user.agent_runs_used,
    },
    tier_limit: limit,
  };
}

/**
 * incrementAgentRuns(email, supabase)
 *
 * Increments agent_runs_used by 1. Tries the RPC first; falls back to a
 * manual read-then-write (same pattern as api/stripe-webhook.js:86-104).
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
      return { ok: true };
    }

    // RPC failed — fall back to manual increment
    console.warn(
      'increment_agent_runs rpc failed, falling back to manual update:',
      rpcError.message
    );

    const { data: user, error: readError } = await supabase
      .from('users')
      .select('agent_runs_used')
      .eq('email', email)
      .single();

    if (readError || !user) {
      return { ok: false, error: readError?.message || 'User not found during fallback increment' };
    }

    const { error: writeError } = await supabase
      .from('users')
      .update({ agent_runs_used: (user.agent_runs_used || 0) + 1 })
      .eq('email', email);

    if (writeError) {
      return { ok: false, error: writeError.message };
    }

    return { ok: true };
  } catch (err) {
    return { ok: false, error: err.message };
  }
}

module.exports = { checkPaywall, incrementAgentRuns };
