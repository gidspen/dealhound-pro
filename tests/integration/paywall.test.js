import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import { createClient } from '@supabase/supabase-js';
import { checkPaywall, incrementAgentRuns } from '../../api/_lib/paywall.js';

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_KEY;
const missingEnv = !SUPABASE_URL || !SUPABASE_SERVICE_KEY;

describe.skipIf(missingEnv)('paywall', () => {
  let supabase;
  const ts = Date.now();
  const emails = {
    nullTier0Runs:    `test-paywall-${ts}-1@dealhound.dev`,
    nullTier1Run:     `test-paywall-${ts}-2@dealhound.dev`,
    operatorTier:     `test-paywall-${ts}-3@dealhound.dev`,
    foundingBlocked:  `test-paywall-${ts}-4@dealhound.dev`,
    foundingAllowed:  `test-paywall-${ts}-5@dealhound.dev`,
    incrementTest:    `test-paywall-${ts}-6@dealhound.dev`,
  };

  beforeAll(async () => {
    supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);

    const rows = [
      { email: emails.nullTier0Runs,   subscription_tier: null,       agent_runs_used: 0,   agent_name: 'Scout' },
      { email: emails.nullTier1Run,    subscription_tier: null,       agent_runs_used: 1,   agent_name: 'Scout' },
      { email: emails.operatorTier,    subscription_tier: 'operator', agent_runs_used: 999, agent_name: 'Scout' },
      { email: emails.foundingBlocked, subscription_tier: 'founding', agent_runs_used: 10,  agent_name: 'Scout' },
      { email: emails.foundingAllowed, subscription_tier: 'founding', agent_runs_used: 9,   agent_name: 'Scout' },
      { email: emails.incrementTest,   subscription_tier: null,       agent_runs_used: 0,   agent_name: 'Scout' },
    ];

    const { error } = await supabase.from('users').insert(rows);
    if (error) throw new Error(`beforeAll insert failed: ${error.message}`);
  });

  afterAll(async () => {
    const { error } = await supabase
      .from('users')
      .delete()
      .in('email', Object.values(emails));
    if (error) console.error('afterAll cleanup failed — test rows may linger:', error.message);
  });

  it('null tier, 0 runs → allowed (free first run)', async () => {
    const result = await checkPaywall(emails.nullTier0Runs, supabase);
    expect(result.allowed).toBe(true);
    expect(result.tier_limit).toBe(1);
  });

  it('null tier, 1 run → blocked (paywall after free run)', async () => {
    const result = await checkPaywall(emails.nullTier1Run, supabase);
    expect(result.allowed).toBe(false);
    expect(result.status).toBe(402);
    expect(result.body.tier).toBeNull();
    expect(result.body.error).toMatch(/free scan/i);
  });

  it('operator tier, 999 runs → allowed (unlimited)', async () => {
    const result = await checkPaywall(emails.operatorTier, supabase);
    expect(result.allowed).toBe(true);
  });

  it('founding tier, 10 runs → blocked (tier limit hit)', async () => {
    const result = await checkPaywall(emails.foundingBlocked, supabase);
    expect(result.allowed).toBe(false);
    expect(result.status).toBe(402);
    expect(result.body.tier).toBe('founding');
  });

  it('founding tier, 9 runs → allowed (under tier limit)', async () => {
    const result = await checkPaywall(emails.foundingAllowed, supabase);
    expect(result.allowed).toBe(true);
  });

  it('incrementAgentRuns increments by 1', async () => {
    const { ok } = await incrementAgentRuns(emails.incrementTest, supabase);
    expect(ok).toBe(true);

    const { data, error } = await supabase
      .from('users')
      .select('agent_runs_used')
      .eq('email', emails.incrementTest)
      .single();

    expect(error).toBeNull();
    expect(data.agent_runs_used).toBe(1);
  });
});
