// tests/integration/free-scan-rate-limit.test.js
//
// Verifies email-level and IP-level rate limiting on /api/free-scan-start.js.
//
// Strategy: free-scan-start.js is a CJS module that calls createClient() at
// module load time. vi.mock doesn't reliably intercept CJS require() across
// multiple test runs. Instead we clear the Node require cache before each test,
// patch require('@supabase/supabase-js') with a test-specific stub by swapping
// Module._load, then require the handler fresh. This gives each test its own
// supabase instance with the right counts.

import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import { createRequire } from 'module';
import { fileURLToPath } from 'url';
import { dirname, resolve } from 'path';
import Module from 'module';

const __dirname = dirname(fileURLToPath(import.meta.url));
const HANDLER_PATH = resolve(__dirname, '../../api/free-scan-start.js');
const SUPABASE_PKG = '@supabase/supabase-js';

// ── Helpers ───────────────────────────────────────────────────────────────────
function mockRes() {
  const res = { statusCode: 200, body: null, headers: {} };
  res.setHeader = (k, v) => { res.headers[k] = v; };
  res.status = (code) => { res.statusCode = code; return res; };
  res.json = (data) => { res.body = data; return res; };
  res.end = () => res;
  res._isMock = true;
  return res;
}

function mockReq({ method = 'POST', body = {}, headers = {} } = {}) {
  return { method, body, headers, socket: { remoteAddress: '0.0.0.0' } };
}

const VALID_BODY = {
  assetType: 'motel',
  market: 'Austin, TX',
  priceMin: 500000,
  priceMax: 2000000,
  email: 'fresh@test.com',
};

// Build a supabase mock client with configurable email/ip counts.
function makeSupabaseMock({ emailCount = 0, ipCount = 0 } = {}) {
  const fromImpl = (table) => ({
    select: (cols, opts) => {
      if (opts && opts.head && opts.count === 'exact') {
        return {
          eq: (col, _val) => {
            if (col === 'email') {
              return Promise.resolve({ count: emailCount, error: null });
            }
            // IP count: .eq('ip', ip).gte('created_at', since)
            return {
              gte: () => Promise.resolve({ count: ipCount, error: null }),
            };
          },
        };
      }
      // .select('id') after .insert — ends with .single()
      return {
        single: () =>
          Promise.resolve({
            data: { id: table === 'deal_searches' ? 'search-uuid-1' : 'fsr-uuid-1' },
            error: null,
          }),
      };
    },

    insert: () => ({
      // .insert().select('id').single() for deal_searches / free_scan_requests
      select: () => ({
        single: () =>
          Promise.resolve({
            data: { id: table === 'deal_searches' ? 'search-uuid-1' : 'fsr-uuid-1' },
            error: null,
          }),
      }),
      // .insert({}) with no .select() for scrape_jobs — must be directly awaitable
      then: (resolve, reject) => Promise.resolve({ error: null }).then(resolve, reject),
    }),

    update: () => ({
      eq: () => Promise.resolve({ error: null }),
    }),

    delete: () => ({
      eq: () => Promise.resolve({ error: null }),
    }),
  });

  return { from: fromImpl };
}

// Load the handler fresh with a patched require, clearing any cached CJS modules.
function loadHandlerWithMock(sbMock) {
  // Resolve the real path of @supabase/supabase-js so we can match it in _load
  const require = createRequire(HANDLER_PATH);
  let supabaseRealPath;
  try {
    supabaseRealPath = require.resolve(SUPABASE_PKG);
  } catch {
    supabaseRealPath = SUPABASE_PKG;
  }

  // Clear the handler and supabase from require cache so they reload fresh.
  delete Module._cache[HANDLER_PATH];
  if (supabaseRealPath && Module._cache[supabaseRealPath]) {
    delete Module._cache[supabaseRealPath];
  }

  // Temporarily patch Module._load to intercept require('@supabase/supabase-js')
  const origLoad = Module._load.bind(Module);
  Module._load = function (request, parent, isMain) {
    if (request === SUPABASE_PKG || (supabaseRealPath && request === supabaseRealPath)) {
      return { createClient: () => sbMock };
    }
    return origLoad(request, parent, isMain);
  };

  // Load the handler (CJS) — picks up the patched require
  const handler = Module._load(HANDLER_PATH, null, false);

  // Restore original _load immediately
  Module._load = origLoad;

  return handler;
}

// ── Tests ─────────────────────────────────────────────────────────────────────

describe('free-scan-start — email rate limit', () => {
  beforeEach(() => {
    process.env.SUPABASE_URL = process.env.SUPABASE_URL || 'http://test';
    process.env.SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_KEY || 'test';
  });

  afterEach(() => {
    // Clear handler from CJS cache to avoid state bleed between tests
    delete Module._cache[HANDLER_PATH];
  });

  it('same email + new IP → 429 with "already used your free scan"', async () => {
    const sbMock = makeSupabaseMock({ emailCount: 1, ipCount: 0 });
    const handler = loadHandlerWithMock(sbMock);

    const req = mockReq({
      body: { ...VALID_BODY, email: 'repeat@test.com' },
      headers: { 'x-forwarded-for': '9.9.9.9' },
    });
    const res = mockRes();

    await handler(req, res);

    expect(res.statusCode).toBe(429);
    expect(res.body.error).toContain('already used your free scan');
  });

  it('fresh email + same IP within 24h → 429 with "One free scan per day per IP"', async () => {
    const sbMock = makeSupabaseMock({ emailCount: 0, ipCount: 1 });
    const handler = loadHandlerWithMock(sbMock);

    const req = mockReq({
      body: { ...VALID_BODY, email: 'newuser@test.com' },
      headers: { 'x-forwarded-for': '1.2.3.4' },
    });
    const res = mockRes();

    await handler(req, res);

    expect(res.statusCode).toBe(429);
    expect(res.body.error).toContain('One free scan per day per IP');
  });

  it('fresh email + new IP → 200 with success=true and scanId', async () => {
    const sbMock = makeSupabaseMock({ emailCount: 0, ipCount: 0 });
    const handler = loadHandlerWithMock(sbMock);

    const req = mockReq({
      body: { ...VALID_BODY, email: 'brandnew@test.com' },
      headers: { 'x-forwarded-for': '5.6.7.8' },
    });
    const res = mockRes();

    await handler(req, res);

    expect(res.body.success).toBe(true);
    expect(res.body.scanId).toBe('search-uuid-1');
  });
});
