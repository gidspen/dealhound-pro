import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import { createClient } from '@supabase/supabase-js';
import { checkPaywall, incrementAgentRuns, FREE_RUNS } from '../../api/_lib/paywall.js';

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_KEY;
const missingEnv = !SUPABASE_URL || !SUPABASE_SERVICE_KEY;

describe.skipIf(missingEnv)('paywall', () => {
  let supabase;
  const ts = Date.now();
  const emails = {
    noRow: `test-paywall-${ts}-0@dealhound.dev`,
    nullTier0Runs: `test-paywall-${ts}-1@dealhound.dev`,
    nullTier1Run: `test-paywall-${ts}-2@dealhound.dev`,
    operatorTier: `test-paywall-${ts}-3@dealhound.dev`,
    foundingBlocked: `test-paywall-${ts}-4@dealhound.dev`,
    foundingAllowed: `test-paywall-${ts}-5@dealhound.dev`,
    incrementTest: `test-paywall-${ts}-6@dealhound.dev`,
    incrementNoRow: `test-paywall-${ts}-7@dealhound.dev`,
  };

  beforeAll(async () => {
    supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);

    // noRow + incrementNoRow are intentionally not seeded — we test the no-row path.
    const rows = [
      {
        email: emails.nullTier0Runs,
        subscription_tier: null,
        agent_runs_used: 0,
        agent_name: 'Scout',
      },
      {
        email: emails.nullTier1Run,
        subscription_tier: null,
        agent_runs_used: 1,
        agent_name: 'Scout',
      },
      {
        email: emails.operatorTier,
        subscription_tier: 'operator',
        agent_runs_used: 999,
        agent_name: 'Scout',
      },
      {
        email: emails.foundingBlocked,
        subscription_tier: 'founding',
        agent_runs_used: 10,
        agent_name: 'Scout',
      },
      {
        email: emails.foundingAllowed,
        subscription_tier: 'founding',
        agent_runs_used: 9,
        agent_name: 'Scout',
      },
      {
        email: emails.incrementTest,
        subscription_tier: null,
        agent_runs_used: 0,
        agent_name: 'Scout',
      },
    ];

    const { error } = await supabase.from('users').insert(rows);
    if (error) throw new Error(`beforeAll insert failed: ${error.message}`);
  });

  afterAll(async () => {
    await supabase.from('users').delete().in('email', Object.values(emails));
  });

  it('no row → allowed (free first run)', async () => {
    const result = await checkPaywall(emails.noRow, supabase);
    expect(result.allowed).toBe(true);
    expect(result.free_run).toBe(true);
    expect(result.tier_limit).toBe(FREE_RUNS);
  });

  it('null tier, 0 runs → allowed (free first run)', async () => {
    const result = await checkPaywall(emails.nullTier0Runs, supabase);
    expect(result.allowed).toBe(true);
    expect(result.free_run).toBe(true);
    expect(result.tier_limit).toBe(FREE_RUNS);
  });

  it('null tier, 1 run → blocked (free run used)', async () => {
    const result = await checkPaywall(emails.nullTier1Run, supabase);
    expect(result.allowed).toBe(false);
    expect(result.status).toBe(402);
    expect(result.body.tier).toBeNull();
    expect(result.body.reason).toBe('free_run_used');
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
    expect(result.body.reason).toBe('out_of_runs');
  });

  it('founding tier, 9 runs → allowed (under tier limit)', async () => {
    const result = await checkPaywall(emails.foundingAllowed, supabase);
    expect(result.allowed).toBe(true);
  });

  it('incrementAgentRuns increments existing row by 1', async () => {
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

  it('incrementAgentRuns upserts a new row when none exists (free-first-run path)', async () => {
    const { ok } = await incrementAgentRuns(emails.incrementNoRow, supabase);
    expect(ok).toBe(true);

    const { data, error } = await supabase
      .from('users')
      .select('agent_runs_used, subscription_tier')
      .eq('email', emails.incrementNoRow)
      .single();

    expect(error).toBeNull();
    expect(data.agent_runs_used).toBe(1);
    expect(data.subscription_tier).toBeNull();
  });
});
