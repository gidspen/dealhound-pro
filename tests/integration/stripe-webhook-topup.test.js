// tests/integration/stripe-webhook-topup.test.js
//
// Flow K — Stripe webhook sync (the part that doesn't need Stripe CLI)
// See docs/USER_FLOWS.md §Flow K.
//
// Specifically tests the top-up handler we just rewrote:
//   - tier='topup' should grant +5 BONUS runs (NOT increment agent_runs_used)
//   - paywall.js should then allow N more runs before re-blocking
//
// Hits the real Supabase test DB (incredible-ai-deals project) using the same
// service-role key the rest of the integration suite uses.
//
// Run with:  source .env && npm run test -- stripe-webhook-topup

import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import { createClient } from '@supabase/supabase-js';
import { freshTestEmail } from '../e2e/helpers/test-email.js';
import { seedUser, deleteUser, getUser } from '../e2e/helpers/personas.js';

// We re-implement the handler's top-up branch inline so we don't have to
// stub Stripe signature verification. The branch is tiny — see
// api/stripe-webhook.js handleCheckoutCompleted().
async function applyTopUp(email, supabase) {
  // Try the RPC first (matches production handler logic)
  const { error: rpcError } = await supabase.rpc('increment_bonus_runs', {
    p_email: email,
    p_amount: 5,
  });

  if (rpcError) {
    // Manual fallback (mirrors the catch path in api/stripe-webhook.js)
    const { data: user } = await supabase
      .from('users')
      .select('bonus_runs')
      .eq('email', email)
      .single();
    if (user) {
      await supabase
        .from('users')
        .update({ bonus_runs: (user.bonus_runs || 0) + 5 })
        .eq('email', email);
    }
  }
}

describe('Flow K — Stripe top-up webhook', () => {
  let testEmail;
  let supabase;

  beforeEach(() => {
    testEmail = freshTestEmail('flow-k');
    supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_KEY);
  });

  afterEach(async () => {
    await deleteUser(testEmail);
  });

  it('top-up grants +5 bonus_runs (NOT increment agent_runs_used)', async () => {
    // Seed a user at exactly the cap: founding tier, 10/10 used, 0 bonus
    await seedUser({ email: testEmail, tier: 'founding', runs_used: 10, bonus_runs: 0 });

    const before = await getUser(testEmail);
    expect(before.agent_runs_used).toBe(10);
    expect(before.bonus_runs).toBe(0);

    // Simulate webhook firing for a top-up
    await applyTopUp(testEmail, supabase);

    const after = await getUser(testEmail);
    expect(after.bonus_runs, 'bonus_runs should be +5').toBe(5);
    expect(after.agent_runs_used, 'agent_runs_used should be UNCHANGED').toBe(10);
  });

  it('paywall: capped user with bonus_runs is allowed to scan again', async () => {
    const { checkPaywall } = await import('../../api/_lib/paywall.js');

    // Capped user: 10/10 + 5 bonus → effective limit 15, used 10, so allowed.
    await seedUser({ email: testEmail, tier: 'founding', runs_used: 10, bonus_runs: 5 });

    const result = await checkPaywall(testEmail, supabase);
    expect(result.allowed, 'paywall should allow when bonus headroom exists').toBe(true);
    expect(result.tier_limit).toBe(15);
  });

  it('paywall: bonus runs exhausted re-blocks at the new limit', async () => {
    const { checkPaywall } = await import('../../api/_lib/paywall.js');

    // 15 used, 10 + 5 bonus → at the new effective cap, blocked.
    await seedUser({ email: testEmail, tier: 'founding', runs_used: 15, bonus_runs: 5 });

    const result = await checkPaywall(testEmail, supabase);
    expect(result.allowed, 'paywall should block when bonus also exhausted').toBe(false);
    expect(result.status).toBe(402);
    expect(result.body.reason).toBe('out_of_runs');
    expect(result.body.runs_limit).toBe(15);
  });

  it('paywall: free user with 0 runs is allowed (free first run)', async () => {
    const { checkPaywall, FREE_RUNS } = await import('../../api/_lib/paywall.js');

    await seedUser({ email: testEmail }); // no tier, 0 runs

    const result = await checkPaywall(testEmail, supabase);
    expect(result.allowed).toBe(true);
    expect(result.free_run).toBe(true);
    expect(result.tier_limit).toBe(FREE_RUNS);
  });

  it('paywall: free user past FREE_RUNS is blocked with free_run_used reason', async () => {
    const { checkPaywall, FREE_RUNS } = await import('../../api/_lib/paywall.js');

    await seedUser({ email: testEmail, runs_used: FREE_RUNS }); // no tier, free quota exhausted

    const result = await checkPaywall(testEmail, supabase);
    expect(result.allowed).toBe(false);
    expect(result.status).toBe(402);
    expect(result.body.reason).toBe('free_run_used');
    expect(result.body.tier).toBeNull();
  });

  it('two consecutive top-ups stack to 10 bonus_runs', async () => {
    await seedUser({ email: testEmail, tier: 'hunter', runs_used: 0, bonus_runs: 0 });

    await applyTopUp(testEmail, supabase);
    await applyTopUp(testEmail, supabase);

    const after = await getUser(testEmail);
    expect(after.bonus_runs).toBe(10);
  });
});
