// tests/integration/cost-guardrails.test.js
//
// Verifies:
//   1. CostTracker accumulates cost from DEALHOUND_TOKENS lines
//   2. CostTracker fires capped=true when cost >= skill cap
//   3. FORCE_COGS_OVERRUN=true causes cap to fire on the first token event
//   4. checkAndReserveMonthlyBudget blocks when monthly cap is hit
//   5. checkAndReserveMonthlyBudget resets on new calendar month
//   6. Top-up runs bypass monthly cap and decrement topup_runs_remaining
//   7. recordComputeUsed calls Supabase rpc
//
// These tests run fully offline — Supabase is stubbed.

import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
import {
  CostTracker,
  CapExceededError,
  checkAndReserveMonthlyBudget,
  recordComputeUsed,
  SKILL_CAPS,
  TIER_MONTHLY_CAPS,
  RUN_CAPPED_MESSAGE,
  INPUT_COST_PER_TOKEN,
  OUTPUT_COST_PER_TOKEN,
} from '../../worker/cost-guardrails.js';

// ── CostTracker unit tests ────────────────────────────────────────────────────

describe('CostTracker — constants', () => {
  it('INPUT_COST_PER_TOKEN is $3/1M', () => {
    expect(INPUT_COST_PER_TOKEN).toBeCloseTo(0.000003);
  });
  it('OUTPUT_COST_PER_TOKEN is $15/1M', () => {
    expect(OUTPUT_COST_PER_TOKEN).toBeCloseTo(0.000015);
  });
  it('deal scan cap is $1.50', () => {
    expect(SKILL_CAPS['deal scan']).toBe(1.5);
  });
  it('loi draft cap is $0.50', () => {
    expect(SKILL_CAPS['loi draft']).toBe(0.5);
  });
  it('underwriting cap is $2.00', () => {
    expect(SKILL_CAPS['underwriting']).toBe(2.0);
  });
  it('comp analysis cap is $1.00', () => {
    expect(SKILL_CAPS['comp analysis']).toBe(1.0);
  });
  it('market report cap is $1.50', () => {
    expect(SKILL_CAPS['market report']).toBe(1.5);
  });
  it('RUN_CAPPED_MESSAGE is correct', () => {
    expect(RUN_CAPPED_MESSAGE).toBe('run capped — refine criteria for more depth');
  });
});

describe('CostTracker — normal token accumulation', () => {
  it('returns capped=false and totalCost=0 when no token lines seen', () => {
    const t = new CostTracker('deal scan');
    const { capped, totalCost } = t.trackTokenLine('some random output');
    expect(capped).toBe(false);
    expect(totalCost).toBe(0);
  });

  it('accumulates cost from a valid DEALHOUND_TOKENS line', () => {
    const t = new CostTracker('deal scan');
    // 100k input tokens + 10k output tokens
    // Cost = 100000 * 0.000003 + 10000 * 0.000015 = 0.30 + 0.15 = $0.45
    const line = 'DEALHOUND_TOKENS: {"input_tokens":100000,"output_tokens":10000}';
    const { capped, totalCost } = t.trackTokenLine(line);
    expect(capped).toBe(false);
    expect(totalCost).toBeCloseTo(0.45, 4);
  });

  it('does not fire capped before exceeding the cap', () => {
    const t = new CostTracker('deal scan'); // cap = $1.50
    // Each event = $0.45 — need > $1.50 / $0.45 = 3.33 events
    const line = 'DEALHOUND_TOKENS: {"input_tokens":100000,"output_tokens":10000}';
    t.trackTokenLine(line); // $0.45
    t.trackTokenLine(line); // $0.90
    const { capped } = t.trackTokenLine(line); // $1.35 — still under cap
    expect(capped).toBe(false);
  });

  it('fires capped=true when accumulated cost >= cap', () => {
    const t = new CostTracker('deal scan'); // cap = $1.50
    const line = 'DEALHOUND_TOKENS: {"input_tokens":100000,"output_tokens":10000}';
    t.trackTokenLine(line); // $0.45
    t.trackTokenLine(line); // $0.90
    t.trackTokenLine(line); // $1.35
    const { capped, totalCost } = t.trackTokenLine(line); // $1.80 >= $1.50 → capped
    expect(capped).toBe(true);
    expect(totalCost).toBeGreaterThanOrEqual(1.5);
  });

  it('stays capped once capped — additional calls return capped=true without extra accumulation', () => {
    const t = new CostTracker('loi draft'); // cap = $0.50
    // 50k input + 40k output = 0.05*3 + 0.04*15 ... actually:
    // 50000 * 0.000003 + 40000 * 0.000015 = 0.15 + 0.60 = $0.75 > $0.50
    const line = 'DEALHOUND_TOKENS: {"input_tokens":50000,"output_tokens":40000}';
    const { capped: first } = t.trackTokenLine(line);
    expect(first).toBe(true);
    const totalAfterCap = t.total;
    const { capped: second } = t.trackTokenLine(line); // should short-circuit
    expect(second).toBe(true);
    expect(t.total).toBe(totalAfterCap); // no further accumulation
  });

  it('handles malformed JSON gracefully — no throw, no accumulation', () => {
    const t = new CostTracker('deal scan');
    const bad = 'DEALHOUND_TOKENS: {not valid json}';
    expect(() => t.trackTokenLine(bad)).not.toThrow();
    expect(t.total).toBe(0);
  });

  it('ignores lines that are not DEALHOUND_TOKENS', () => {
    const t = new CostTracker('deal scan');
    t.trackTokenLine('DEALHOUND_METRICS: {"sites_discovered":5}');
    t.trackTokenLine('DEALHOUND_PHASE: phase2');
    t.trackTokenLine('some random log line');
    expect(t.total).toBe(0);
  });
});

describe('CostTracker — FORCE_COGS_OVERRUN', () => {
  beforeEach(() => {
    process.env.FORCE_COGS_OVERRUN = 'true';
  });
  afterEach(() => {
    delete process.env.FORCE_COGS_OVERRUN;
  });

  it('fires cap on the first DEALHOUND_TOKENS line (overrun=$5)', () => {
    const t = new CostTracker('deal scan'); // cap = $1.50
    // With FORCE_COGS_OVERRUN, first event = $5.00 > $1.50 → immediate cap
    const line = 'DEALHOUND_TOKENS: {"input_tokens":1,"output_tokens":1}';
    const { capped, totalCost } = t.trackTokenLine(line);
    expect(capped).toBe(true);
    expect(totalCost).toBe(5.0);
  });

  it('fires cap for every skill — LOI draft ($0.50 cap)', () => {
    const t = new CostTracker('loi draft');
    const line = 'DEALHOUND_TOKENS: {"input_tokens":100,"output_tokens":100}';
    const { capped } = t.trackTokenLine(line);
    expect(capped).toBe(true);
  });
});

// ── Monthly budget guard tests ────────────────────────────────────────────────

function makeSupabaseMock({ user = null, updateError = null, rpcError = null } = {}) {
  const updateChain = {
    eq: vi.fn().mockReturnThis(),
    then: vi.fn((fn) => (fn ? fn({ error: updateError }) : Promise.resolve())),
  };
  updateChain.then = (fn) => (fn ? fn({ error: updateError }) : Promise.resolve());

  return {
    from: vi.fn(() => ({
      select: vi.fn().mockReturnThis(),
      update: vi.fn(() => updateChain),
      eq: vi.fn().mockReturnThis(),
      single: vi
        .fn()
        .mockResolvedValue({ data: user, error: user ? null : { message: 'not found' } }),
    })),
    rpc: vi.fn().mockResolvedValue({ error: rpcError }),
  };
}

describe('checkAndReserveMonthlyBudget — no user email', () => {
  it('allows anonymous/daily jobs (no email)', async () => {
    const sb = makeSupabaseMock();
    const result = await checkAndReserveMonthlyBudget(null, sb);
    expect(result.allowed).toBe(true);
  });
});

describe('checkAndReserveMonthlyBudget — user not found', () => {
  it('allows when user lookup fails (fail open)', async () => {
    const sb = makeSupabaseMock({ user: null });
    const result = await checkAndReserveMonthlyBudget('ghost@example.com', sb);
    expect(result.allowed).toBe(true);
  });
});

describe('checkAndReserveMonthlyBudget — within cap', () => {
  it('allows when monthly_compute_used is below tier cap', async () => {
    const user = {
      email: 'user@example.com',
      subscription_tier: 'hunter',
      monthly_compute_used: 10.0, // $10 of $30 cap used
      agent_runs_reset_at: new Date().toISOString(),
      topup_runs_remaining: 0,
    };
    const sb = makeSupabaseMock({ user });
    const result = await checkAndReserveMonthlyBudget(user.email, sb);
    expect(result.allowed).toBe(true);
    expect(result.topupUsed).toBeFalsy();
  });

  it('investor tier: allows when used < $150 cap', async () => {
    const user = {
      email: 'investor@example.com',
      subscription_tier: 'investor',
      monthly_compute_used: 100.0, // $100 of $150 cap — should allow
      agent_runs_reset_at: new Date().toISOString(),
      topup_runs_remaining: 0,
    };
    const sb = makeSupabaseMock({ user });
    const result = await checkAndReserveMonthlyBudget(user.email, sb);
    expect(result.allowed).toBe(true);
  });

  it('operator tier: allows when used < $400 cap', async () => {
    const user = {
      email: 'operator@example.com',
      subscription_tier: 'operator',
      monthly_compute_used: 399.99,
      agent_runs_reset_at: new Date().toISOString(),
      topup_runs_remaining: 0,
    };
    const sb = makeSupabaseMock({ user });
    const result = await checkAndReserveMonthlyBudget(user.email, sb);
    expect(result.allowed).toBe(true);
  });
});

describe('checkAndReserveMonthlyBudget — cap hit', () => {
  it('blocks when monthly_compute_used >= tier cap', async () => {
    const user = {
      email: 'user@example.com',
      subscription_tier: 'hunter',
      monthly_compute_used: 30.0, // exactly at $30 cap
      agent_runs_reset_at: new Date().toISOString(),
      topup_runs_remaining: 0,
    };
    const sb = makeSupabaseMock({ user });
    const result = await checkAndReserveMonthlyBudget(user.email, sb);
    expect(result.allowed).toBe(false);
    expect(result.reason).toContain("You've used your monthly compute");
    expect(result.reason).toContain('Top up 5 runs for $25');
  });

  it('investor tier: blocks when used >= $150 cap', async () => {
    const user = {
      email: 'investor@example.com',
      subscription_tier: 'investor',
      monthly_compute_used: 150.0, // at cap — should block, not use $30 hunter fallback
      agent_runs_reset_at: new Date().toISOString(),
      topup_runs_remaining: 0,
    };
    const sb = makeSupabaseMock({ user });
    const result = await checkAndReserveMonthlyBudget(user.email, sb);
    expect(result.allowed).toBe(false);
  });

  it('operator tier: blocks when used >= $400 cap', async () => {
    const user = {
      email: 'operator@example.com',
      subscription_tier: 'operator',
      monthly_compute_used: 400.0,
      agent_runs_reset_at: new Date().toISOString(),
      topup_runs_remaining: 0,
    };
    const sb = makeSupabaseMock({ user });
    const result = await checkAndReserveMonthlyBudget(user.email, sb);
    expect(result.allowed).toBe(false);
  });

  it('uses hunter cap ($30) for unknown subscription_tier values', async () => {
    const user = {
      email: 'user@example.com',
      subscription_tier: 'legacy_plan', // unknown tier — should default to hunter
      monthly_compute_used: 31.0,
      agent_runs_reset_at: new Date().toISOString(),
      topup_runs_remaining: 0,
    };
    const sb = makeSupabaseMock({ user });
    const result = await checkAndReserveMonthlyBudget(user.email, sb);
    expect(result.allowed).toBe(false);
  });
});

describe('checkAndReserveMonthlyBudget — monthly reset', () => {
  it('resets monthly_compute_used when in a new calendar month', async () => {
    // Simulate user whose reset date was last month
    const lastMonth = new Date();
    lastMonth.setUTCMonth(lastMonth.getUTCMonth() - 1);

    const user = {
      email: 'user@example.com',
      subscription_tier: 'hunter',
      monthly_compute_used: 29.99, // near cap, but month rolled over
      agent_runs_reset_at: lastMonth.toISOString(),
      topup_runs_remaining: 0,
    };

    // We need to capture the update call to verify reset is written
    const updateCalls = [];
    const sb = {
      from: vi.fn(() => ({
        select: vi.fn().mockReturnThis(),
        update: vi.fn((data) => {
          updateCalls.push(data);
          return {
            eq: vi.fn().mockReturnThis(),
            then: (fn) => (fn ? fn({}) : Promise.resolve()),
          };
        }),
        eq: vi.fn().mockReturnThis(),
        single: vi.fn().mockResolvedValue({ data: user, error: null }),
      })),
    };

    const result = await checkAndReserveMonthlyBudget(user.email, sb);

    // Should allow — because after reset, used = 0
    expect(result.allowed).toBe(true);

    // Should have written the reset
    const resetUpdate = updateCalls.find(
      (u) => u.monthly_compute_used === 0 && u.agent_runs_reset_at
    );
    expect(resetUpdate).toBeTruthy();
  });
});

describe('checkAndReserveMonthlyBudget — top-up bypass', () => {
  it('allows and decrements topup_runs_remaining when > 0', async () => {
    const user = {
      email: 'user@example.com',
      subscription_tier: 'hunter',
      monthly_compute_used: 30.0, // over cap, but has top-up
      agent_runs_reset_at: new Date().toISOString(),
      topup_runs_remaining: 3,
    };

    const updateCalls = [];
    const sb = {
      from: vi.fn(() => ({
        select: vi.fn().mockReturnThis(),
        update: vi.fn((data) => {
          updateCalls.push(data);
          return {
            eq: vi.fn().mockReturnThis(),
            then: (fn) => (fn ? fn({}) : Promise.resolve()),
          };
        }),
        eq: vi.fn().mockReturnThis(),
        single: vi.fn().mockResolvedValue({ data: user, error: null }),
      })),
    };

    const result = await checkAndReserveMonthlyBudget(user.email, sb);

    expect(result.allowed).toBe(true);
    expect(result.topupUsed).toBe(true);

    // Should have decremented topup_runs_remaining to 2
    const topupUpdate = updateCalls.find((u) => u.topup_runs_remaining === 2);
    expect(topupUpdate).toBeTruthy();
  });
});

describe('checkAndReserveMonthlyBudget — null subscription_tier (cancelled sub)', () => {
  it('falls back to hunter cap when subscription_tier is null', async () => {
    const user = {
      email: 'cancelled@example.com',
      subscription_tier: null, // subscription cancelled — stripe-webhook sets this to null
      monthly_compute_used: 25.0, // under hunter $30 cap → still allowed
      agent_runs_reset_at: new Date().toISOString(),
      topup_runs_remaining: 0,
    };
    const sb = makeSupabaseMock({ user });
    const result = await checkAndReserveMonthlyBudget(user.email, sb);
    // paywall.js blocks this user first (subscription_tier == null), but if
    // cost-guardrails is reached, it should fall back to hunter cap, not throw
    expect(result.allowed).toBe(true);
  });

  it('blocks when subscription_tier is null and used >= hunter fallback cap', async () => {
    const user = {
      email: 'cancelled@example.com',
      subscription_tier: null,
      monthly_compute_used: 30.0,
      agent_runs_reset_at: new Date().toISOString(),
      topup_runs_remaining: 0,
    };
    const sb = makeSupabaseMock({ user });
    const result = await checkAndReserveMonthlyBudget(user.email, sb);
    expect(result.allowed).toBe(false);
  });
});

// ── TIER_MONTHLY_CAPS completeness ────────────────────────────────────────────

describe('TIER_MONTHLY_CAPS', () => {
  it('has all four tiers', () => {
    expect(TIER_MONTHLY_CAPS.founding).toBe(30);
    expect(TIER_MONTHLY_CAPS.hunter).toBe(30);
    expect(TIER_MONTHLY_CAPS.investor).toBe(150);
    expect(TIER_MONTHLY_CAPS.operator).toBe(400);
  });
});

// ── PR-3 DoD: explicit cap-exceeded throws ────────────────────────────────────

describe('CapExceededError — per-skill throw (PR-3 DoD)', () => {
  it('throws CapExceededError when token cost crosses the deal-scan $1.50 cap', () => {
    const t = new CostTracker('deal scan');
    // Each line = $0.45; need 4 lines to cross $1.50
    const line = 'DEALHOUND_TOKENS: {"input_tokens":100000,"output_tokens":10000}';
    t.trackTokenLineOrThrow(line); // $0.45
    t.trackTokenLineOrThrow(line); // $0.90
    t.trackTokenLineOrThrow(line); // $1.35
    expect(() => t.trackTokenLineOrThrow(line)).toThrow(CapExceededError);

    // Verify the error carries the right metadata
    const t2 = new CostTracker('deal scan');
    t2.trackTokenLineOrThrow(line);
    t2.trackTokenLineOrThrow(line);
    t2.trackTokenLineOrThrow(line);
    let caught;
    try {
      t2.trackTokenLineOrThrow(line);
    } catch (e) {
      caught = e;
    }
    expect(caught).toBeInstanceOf(CapExceededError);
    expect(caught.message).toBe('run capped — refine criteria for more depth');
    expect(caught.kind).toBe('per_skill');
    expect(caught.capAmount).toBe(1.5);
    expect(caught.totalCost).toBeGreaterThanOrEqual(1.5);
  });
});

describe('monthly compute ceiling — 402 + top-up copy (PR-3 DoD)', () => {
  it('returns allowed:false with top-up copy when monthly_compute_used >= tier cap', async () => {
    const userEmail = 'capped@example.com';
    // Founding tier cap is $30; simulate user at the cap, with a fresh reset this month
    const now = new Date();
    const user = {
      email: userEmail,
      subscription_tier: 'founding',
      monthly_compute_used: 30,
      agent_runs_reset_at: now.toISOString(),
      topup_runs_remaining: 0,
    };
    const supabase = {
      from: vi.fn(() => ({
        select: vi.fn(() => ({
          eq: vi.fn(() => ({
            single: vi.fn().mockResolvedValue({ data: user, error: null }),
          })),
        })),
        update: vi.fn(() => ({
          eq: vi.fn().mockResolvedValue({ error: null }),
        })),
      })),
      rpc: vi.fn().mockResolvedValue({ error: null }),
    };
    const result = await checkAndReserveMonthlyBudget(userEmail, supabase);
    expect(result.allowed).toBe(false);
    expect(result.reason).toBe(
      "You've used your monthly compute. Top up 5 runs for $25, or wait until next month."
    );
  });

  it('CapExceededError surfaces statusCode 402 when kind is monthly_cap', () => {
    const err = new CapExceededError(
      "You've used your monthly compute. Top up 5 runs for $25, or wait until next month.",
      {
        kind: 'monthly_cap',
        totalCost: 30,
        capAmount: 30,
      }
    );
    expect(err.statusCode).toBe(402);
    expect(err.kind).toBe('monthly_cap');
    expect(err.message).toMatch(/Top up 5 runs for \$25/);
  });
});

describe('recordComputeUsed — increments via mocked DB write (PR-3 DoD)', () => {
  it('calls supabase.rpc(increment_compute_used) with the cost', async () => {
    const userEmail = 'increment@example.com';
    const rpcMock = vi.fn().mockResolvedValue({ error: null });
    const supabase = {
      rpc: rpcMock,
      from: vi.fn(() => ({
        select: vi.fn(() => ({
          eq: vi.fn(() => ({
            single: vi.fn().mockResolvedValue({ data: null, error: null }),
          })),
        })),
        update: vi.fn(() => ({
          eq: vi.fn(() => ({
            then: (resolve) => resolve({ error: null }),
          })),
        })),
      })),
    };
    await recordComputeUsed(userEmail, 0.42, supabase);
    expect(rpcMock).toHaveBeenCalledTimes(1);
    expect(rpcMock).toHaveBeenCalledWith('increment_compute_used', {
      p_email: userEmail,
      p_amount: 0.42,
    });
  });
});
