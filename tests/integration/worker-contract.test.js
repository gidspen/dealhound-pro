// tests/integration/worker-contract.test.js
//
// Locks in the worker's contract with the find-deals skill. Each test here
// corresponds to a real production bug we hit on 2026-05-02:
//
// - "/find-deals full" arg: switching to "/find-deals for [text]" caused
//   Claude to improvise a flow that skipped Step 1c (Supabase persistence).
//   17min runs producing 0 deals.
//
// - ANTHROPIC_API_KEY stripping: leaving it in the subprocess env caused
//   `claude` CLI to bill the API account instead of falling back to the
//   user's Claude Pro/Max subscription. Burned credits fast.
//
// - SUPABASE_DEALS_* aliasing: the skill expects SUPABASE_DEALS_URL /
//   SUPABASE_DEALS_ANON_KEY. The worker's .env.local uses SUPABASE_URL /
//   SUPABASE_SERVICE_KEY. Without the alias, progress events and deal
//   inserts authenticated against the wrong env and silently no-op'd.
//
// - In-flight guard: setInterval doesn't wait for previous ticks. Without
//   the guard, a second job could spawn while the first was still scoring.
//   2x token spend and LandSearch rate-limit hits.
//
// Don't simplify or remove these tests without understanding which incident
// each one is locking out.

import { describe, it, expect } from 'vitest';
import { composeSpawnConfig, createInFlightGuard } from '../../worker/worker.js';

const FIXTURE_JOB = Object.freeze({
  id: 'job-uuid-abc',
  search_id: 'search-uuid-xyz',
  buy_box: {
    raw_prompt: 'glamping in texas, under $1m, cash flow from day 1',
    locations: ['Texas'],
    price_max: 1_000_000,
    property_types: ['glamping'],
    revenue_requirement: 'cash_flow_day_1',
  },
});

describe('composeSpawnConfig — promptArg contract', () => {
  it('always uses the documented `/find-deals full` subcommand with --dangerously-skip-permissions', () => {
    const { args } = composeSpawnConfig(FIXTURE_JOB, {}, '/tmp/buybox.json');
    expect(args).toEqual(['-p', '/find-deals full', '--dangerously-skip-permissions']);
  });

  it('uses `/find-deals full` even when raw_prompt is present in buy_box', () => {
    // Regression guard: an earlier impl tried `/find-deals for ${rawPrompt}`,
    // which broke persistence. raw_prompt may exist but is NOT a command arg.
    const { args } = composeSpawnConfig(FIXTURE_JOB, {}, '');
    expect(args[1]).toBe('/find-deals full');
    expect(args[1]).not.toContain('for ');
    expect(args[1]).not.toContain(FIXTURE_JOB.buy_box.raw_prompt);
  });
});

describe('composeSpawnConfig — env stripping', () => {
  it('strips ANTHROPIC_API_KEY from the subprocess env', () => {
    const processEnv = {
      ANTHROPIC_API_KEY: 'sk-ant-shouldnt-leak',
      SUPABASE_URL: 'https://example.supabase.co',
      PATH: '/usr/bin',
    };
    const { env } = composeSpawnConfig(FIXTURE_JOB, processEnv, '');
    expect(env.ANTHROPIC_API_KEY).toBeUndefined();
    // But other vars should pass through
    expect(env.PATH).toBe('/usr/bin');
  });
});

describe('composeSpawnConfig — required dealhound vars', () => {
  it('sets DEALHOUND_SEARCH_ID from job.search_id', () => {
    const { env } = composeSpawnConfig(FIXTURE_JOB, {}, '');
    expect(env.DEALHOUND_SEARCH_ID).toBe('search-uuid-xyz');
  });

  it('sets DEALHOUND_SCRAPE_JOB_ID from job.id', () => {
    const { env } = composeSpawnConfig(FIXTURE_JOB, {}, '');
    expect(env.DEALHOUND_SCRAPE_JOB_ID).toBe('job-uuid-abc');
  });

  it('sets DEALHOUND_BUY_BOX_FILE to the provided path', () => {
    const { env } = composeSpawnConfig(FIXTURE_JOB, {}, '/tmp/buybox-123.json');
    expect(env.DEALHOUND_BUY_BOX_FILE).toBe('/tmp/buybox-123.json');
  });

  it('sets DEALHOUND_BUY_BOX_JSON as serialized JSON of the buy box', () => {
    const { env } = composeSpawnConfig(FIXTURE_JOB, {}, '');
    const parsed = JSON.parse(env.DEALHOUND_BUY_BOX_JSON);
    expect(parsed.locations).toEqual(['Texas']);
    expect(parsed.price_max).toBe(1_000_000);
  });

  it('handles a job with no search_id without throwing', () => {
    const job = { id: 'orphan-job', search_id: null, buy_box: {} };
    const { env } = composeSpawnConfig(job, {}, '');
    expect(env.DEALHOUND_SEARCH_ID).toBe('');
  });
});

describe('composeSpawnConfig — SUPABASE_DEALS aliasing', () => {
  it('aliases SUPABASE_URL → SUPABASE_DEALS_URL when latter is unset', () => {
    const processEnv = { SUPABASE_URL: 'https://main.supabase.co' };
    const { env } = composeSpawnConfig(FIXTURE_JOB, processEnv, '');
    expect(env.SUPABASE_DEALS_URL).toBe('https://main.supabase.co');
  });

  it('prefers SUPABASE_DEALS_URL over SUPABASE_URL when both set', () => {
    const processEnv = {
      SUPABASE_URL: 'https://main.supabase.co',
      SUPABASE_DEALS_URL: 'https://deals.supabase.co',
    };
    const { env } = composeSpawnConfig(FIXTURE_JOB, processEnv, '');
    expect(env.SUPABASE_DEALS_URL).toBe('https://deals.supabase.co');
  });

  it('aliases SUPABASE_SERVICE_KEY → SUPABASE_DEALS_ANON_KEY when latter is unset', () => {
    const processEnv = { SUPABASE_SERVICE_KEY: 'service-key-123' };
    const { env } = composeSpawnConfig(FIXTURE_JOB, processEnv, '');
    expect(env.SUPABASE_DEALS_ANON_KEY).toBe('service-key-123');
  });

  it('prefers SUPABASE_DEALS_ANON_KEY over SUPABASE_SERVICE_KEY when both set', () => {
    const processEnv = {
      SUPABASE_SERVICE_KEY: 'service-key',
      SUPABASE_DEALS_ANON_KEY: 'anon-key',
    };
    const { env } = composeSpawnConfig(FIXTURE_JOB, processEnv, '');
    expect(env.SUPABASE_DEALS_ANON_KEY).toBe('anon-key');
  });
});

describe('createInFlightGuard — concurrency cap', () => {
  it('runs the first call', async () => {
    const guard = createInFlightGuard();
    let ran = false;
    const result = await guard.tryRun(async () => { ran = true; });
    expect(ran).toBe(true);
    expect(result).toBe(true);
  });

  it('skips a concurrent second call while the first is still running', async () => {
    const guard = createInFlightGuard();
    const ranOrder = [];

    // Start the first call but don't await it — it'll be in-flight
    const first = guard.tryRun(async () => {
      ranOrder.push('first-start');
      await new Promise((r) => setTimeout(r, 50));
      ranOrder.push('first-end');
    });

    // Try a second call while the first is mid-flight
    const second = await guard.tryRun(async () => {
      ranOrder.push('second-ran');
    });

    await first;

    expect(second).toBe(false); // Second call returned false (skipped)
    expect(ranOrder).toEqual(['first-start', 'first-end']); // Second never ran
  });

  it('allows a new call after the previous one completes', async () => {
    const guard = createInFlightGuard();
    await guard.tryRun(async () => {});
    let secondRan = false;
    const result = await guard.tryRun(async () => { secondRan = true; });
    expect(secondRan).toBe(true);
    expect(result).toBe(true);
  });

  it('releases the lock even if the inner fn throws', async () => {
    const guard = createInFlightGuard();
    await expect(
      guard.tryRun(async () => { throw new Error('boom'); })
    ).rejects.toThrow('boom');

    // Guard should be released — next call should run
    let secondRan = false;
    await guard.tryRun(async () => { secondRan = true; });
    expect(secondRan).toBe(true);
  });
});
