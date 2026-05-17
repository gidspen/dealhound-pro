// tests/integration/worker-fallback-pipeline.test.js
//
// Regression guard for the Phase 3 (pipeline.py persist) skip bug.
//
// History (2026-05-16): PR #67 added bail-out logging to the scraper's
// enrich_with_descriptions so cold worker profiles don't hang for 90 min on
// Crexi's Cloudflare challenge. The bail-out lines —
//   "[crexi] N consecutive failures — bailing"
//   "[crexi] wall-time cap hit (240s >= 240s) — bailing..."
// — look like failures in raw text but the scraper still exits 0 with rows
// persisted to raw-listings-*.json. The orchestrating Claude inside the PTY
// sometimes misread them as failures and skipped Step 4a (pipeline.py),
// leaving 0 rows in the deals table for scans that actually succeeded.
//
// `maybeFallbackPipeline` is the deterministic safety net: after the PTY
// returns, if fresh raw-listings-*.json files exist AND the deals table has
// 0 rows for this search_id, spawn pipeline.py directly to persist them.
//
// These tests run fully offline. The function takes injected fs / spawn /
// skillDir deps so the tests don't need vi.mock for node built-ins.

import { describe, it, expect, vi, beforeEach } from 'vitest';
import { EventEmitter } from 'node:events';
import path from 'node:path';

// worker.js eagerly constructs a Supabase client at module load. The tests
// don't use the worker-scope client (they pass their own mocked one into
// maybeFallbackPipeline), but we still need real-looking strings to satisfy
// createClient's URL validation. Set BEFORE the worker import below.
process.env.SUPABASE_URL = process.env.SUPABASE_URL || 'https://fixture.supabase.co';
process.env.SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_KEY || 'fixture-service-key';

const { maybeFallbackPipeline } = await import('../../worker/worker.js');

const FAKE_SKILL_DIR = '/tmp/fake-skill-dir';
const FAKE_PIPELINE_PY = path.join(FAKE_SKILL_DIR, 'pipeline.py');

function makeJob(overrides = {}) {
  return {
    id: 'job-uuid-fallback',
    search_id: 'search-uuid-fallback',
    buy_box: { locations: ['TX'], price_max: 1_000_000 },
    ...overrides,
  };
}

function makeSupabaseMock({ dealCount = 0 } = {}) {
  return {
    from: vi.fn(() => ({
      select: vi.fn(() => ({
        eq: vi.fn(() => Promise.resolve({ count: dealCount })),
      })),
    })),
  };
}

// Fake spawn: returns an EventEmitter that immediately fires 'close' (or
// 'error' if errorMsg is set) so the await inside maybeFallbackPipeline
// resolves without launching a real subprocess.
function makeSpawnFake({ exitCode = 0, errorMsg = null } = {}) {
  return vi.fn(() => {
    const proc = new EventEmitter();
    proc.stdout = new EventEmitter();
    proc.stderr = new EventEmitter();
    setImmediate(() => {
      if (errorMsg) {
        proc.emit('error', new Error(errorMsg));
      } else {
        proc.emit('close', exitCode);
      }
    });
    return proc;
  });
}

// Fake fs: configurable view of the disk. Default mock represents the
// "happy path bug scenario": pipeline.py present, two fresh raw-listings
// files written ~30s ago. Individual tests override per-test.
function makeFsFake({
  pipelineExists = true,
  rawFiles = ['raw-listings-crexi.json', 'raw-listings-landsearch.json'],
  ageMs = 30_000,
} = {}) {
  return {
    existsSync: vi.fn((p) => p === FAKE_PIPELINE_PY && pipelineExists),
    readdirSync: vi.fn(() => rawFiles),
    statSync: vi.fn(() => ({ mtimeMs: Date.now() - ageMs })),
  };
}

let deps;
beforeEach(() => {
  deps = {
    skillDir: FAKE_SKILL_DIR,
    fs: makeFsFake(),
    spawn: makeSpawnFake(),
  };
});

describe('maybeFallbackPipeline — preconditions for skip (no fallback fires)', () => {
  it('skips when pipeline.py does not exist on disk', async () => {
    deps.fs = makeFsFake({ pipelineExists: false });
    const sb = makeSupabaseMock({ dealCount: 0 });

    await maybeFallbackPipeline(makeJob(), {}, sb, deps);

    expect(deps.spawn).not.toHaveBeenCalled();
  });

  it('skips when job has no search_id (anonymous/daily jobs)', async () => {
    const sb = makeSupabaseMock();
    await maybeFallbackPipeline(makeJob({ search_id: null }), {}, sb, deps);
    expect(deps.spawn).not.toHaveBeenCalled();
  });

  it('skips when no raw-listings-*.json files exist', async () => {
    deps.fs = makeFsFake({ rawFiles: [] });
    const sb = makeSupabaseMock();
    await maybeFallbackPipeline(makeJob(), {}, sb, deps);
    expect(deps.spawn).not.toHaveBeenCalled();
  });

  it('skips when raw-listings files exist but are stale (>2h old)', async () => {
    deps.fs = makeFsFake({ ageMs: 3 * 60 * 60 * 1000 });
    const sb = makeSupabaseMock();
    await maybeFallbackPipeline(makeJob(), {}, sb, deps);
    expect(deps.spawn).not.toHaveBeenCalled();
  });

  it('skips when deals table already has rows for the search_id', async () => {
    const sb = makeSupabaseMock({ dealCount: 42 });
    await maybeFallbackPipeline(makeJob(), {}, sb, deps);
    expect(deps.spawn).not.toHaveBeenCalled();
  });

  it('skips non-raw-listings files in the skill dir', async () => {
    // Skill dir has lots of artifacts — only raw-listings-*.json should count.
    deps.fs = makeFsFake({
      rawFiles: ['scored-inline.json', 'survivors-for-scoring.json', 'pipeline.py'],
    });
    const sb = makeSupabaseMock({ dealCount: 0 });
    await maybeFallbackPipeline(makeJob(), {}, sb, deps);
    expect(deps.spawn).not.toHaveBeenCalled();
  });
});

describe('maybeFallbackPipeline — fires the fallback', () => {
  it('spawns python3 pipeline.py with the correct args when conditions match', async () => {
    // Bug scenario: scraper wrote files this run, orchestrator skipped persist.
    const sb = makeSupabaseMock({ dealCount: 0 });
    const env = { DEALHOUND_SEARCH_ID: 'search-uuid-fallback', SUPABASE_DEALS_URL: 'x' };

    await maybeFallbackPipeline(makeJob(), env, sb, deps);

    expect(deps.spawn).toHaveBeenCalledTimes(1);
    const [cmd, args, opts] = deps.spawn.mock.calls[0];
    expect(cmd).toBe('python3');
    expect(args).toEqual([FAKE_PIPELINE_PY]);
    expect(opts.cwd).toBe(FAKE_SKILL_DIR);
    // Exact env pass-through, including DEALHOUND_SEARCH_ID so pipeline.py
    // tags inserted rows with the right search.
    expect(opts.env).toBe(env);
  });

  it('queries the deals table filtered by search_id', async () => {
    const sb = makeSupabaseMock({ dealCount: 0 });

    await maybeFallbackPipeline(makeJob({ search_id: 'specific-search-id' }), {}, sb, deps);

    expect(sb.from).toHaveBeenCalledWith('deals');
    const selectChain = sb.from.mock.results[0].value;
    expect(selectChain.select).toHaveBeenCalledWith('*', { count: 'exact', head: true });
    const eqChain = selectChain.select.mock.results[0].value;
    expect(eqChain.eq).toHaveBeenCalledWith('search_id', 'specific-search-id');
  });

  it('fires when only one raw-listings file is present (e.g. only LandSearch worked)', async () => {
    deps.fs = makeFsFake({ rawFiles: ['raw-listings-landsearch.json'] });
    const sb = makeSupabaseMock({ dealCount: 0 });

    await maybeFallbackPipeline(makeJob(), {}, sb, deps);

    expect(deps.spawn).toHaveBeenCalledTimes(1);
  });

  it('resolves cleanly even when pipeline.py exits non-zero (best-effort)', async () => {
    deps.spawn = makeSpawnFake({ exitCode: 1 });
    const sb = makeSupabaseMock({ dealCount: 0 });

    // Should not throw — fallback is best-effort. Scan still completes; the
    // silent-zero guard catches the missing deals.
    await expect(maybeFallbackPipeline(makeJob(), {}, sb, deps)).resolves.toBeUndefined();
    expect(deps.spawn).toHaveBeenCalledTimes(1);
  });

  it('resolves cleanly when spawn itself errors (e.g. python3 missing)', async () => {
    deps.spawn = makeSpawnFake({ errorMsg: 'ENOENT: python3 not found' });
    const sb = makeSupabaseMock({ dealCount: 0 });

    await expect(maybeFallbackPipeline(makeJob(), {}, sb, deps)).resolves.toBeUndefined();
    expect(deps.spawn).toHaveBeenCalledTimes(1);
  });

  it('tolerates statSync throwing on a single file without aborting (cluster-wide bail)', async () => {
    deps.fs = {
      existsSync: vi.fn(() => true),
      readdirSync: vi.fn(() => ['raw-listings-good.json', 'raw-listings-broken.json']),
      statSync: vi.fn((p) => {
        if (p.includes('broken')) throw new Error('EACCES');
        return { mtimeMs: Date.now() };
      }),
    };
    const sb = makeSupabaseMock({ dealCount: 0 });

    // At least one fresh file remains after the broken one is filtered out —
    // the fallback should still fire.
    await maybeFallbackPipeline(makeJob(), {}, sb, deps);
    expect(deps.spawn).toHaveBeenCalledTimes(1);
  });
});
