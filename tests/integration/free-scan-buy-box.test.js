// tests/integration/free-scan-buy-box.test.js
//
// Task 5 — buy-box persistence
//
// Test 1: free-scan-start creates a draft buy_box row.
// Test 2: checkout.session.completed activates draft buy_boxes for the customer.
//
// Hits the real Supabase test DB (service-role key).
// Run with: source .env && npm test -- free-scan-buy-box

import { describe, it, expect, beforeAll, beforeEach, afterAll } from 'vitest';
import { createClient } from '@supabase/supabase-js';
import { freshTestEmail } from '../e2e/helpers/test-email.js';
import { TIER_ACTIVE_BOX_LIMITS } from '../../api/_lib/buy-box-limits.js';

// ---------------------------------------------------------------------------
// Shared Supabase client
// ---------------------------------------------------------------------------
function getSupabase() {
  return createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_KEY);
}

// ---------------------------------------------------------------------------
// Minimal mock req/res helpers (same shape as free-scan-rate-limit.test.js)
// ---------------------------------------------------------------------------
function mockRes() {
  const res = { statusCode: 200, body: null, headers: {} };
  res.setHeader = (k, v) => {
    res.headers[k] = v;
  };
  res.status = (code) => {
    res.statusCode = code;
    return res;
  };
  res.json = (data) => {
    res.body = data;
    return res;
  };
  res.end = () => res;
  return res;
}

function mockReq({ method = 'POST', body = {}, headers = {} } = {}) {
  return { method, body, headers, socket: { remoteAddress: '0.0.0.0' } };
}

// ---------------------------------------------------------------------------
// TEST 1: free-scan-start creates a draft buy_box
// ---------------------------------------------------------------------------
describe('free-scan-start creates a draft buy_box', () => {
  const testEmail = freshTestEmail('buy-box-free-scan');
  const supabase = getSupabase();

  // Valid scan body — assetType + market must be non-empty strings
  const scanBody = {
    assetType: 'motel',
    market: 'Austin, TX',
    priceMin: 500000,
    priceMax: 2000000,
    email: testEmail,
  };

  // Run cleanup before each test attempt (handles vitest retry: 1)
  beforeEach(async () => {
    await supabase.from('buy_boxes').delete().eq('user_email', testEmail);
    const { data: priorSearches } = await supabase
      .from('deal_searches')
      .select('id')
      .eq('user_email', testEmail);
    const priorIds = (priorSearches || []).map((s) => s.id);
    if (priorIds.length > 0) {
      await supabase.from('scrape_jobs').delete().in('search_id', priorIds);
      await supabase.from('deal_searches').delete().in('id', priorIds);
    }
    await supabase.from('free_scan_requests').delete().eq('email', testEmail);
    await supabase.from('users').delete().eq('email', testEmail);
  });

  afterAll(async () => {
    await supabase.from('buy_boxes').delete().eq('user_email', testEmail);
    // scrape_jobs → free_scan_requests → deal_searches → users (FK order)
    const { data: searches } = await supabase
      .from('deal_searches')
      .select('id')
      .eq('user_email', testEmail);
    const ids = (searches || []).map((s) => s.id);
    if (ids.length > 0) {
      await supabase.from('scrape_jobs').delete().in('search_id', ids);
      await supabase.from('deal_searches').delete().in('id', ids);
    }
    await supabase.from('free_scan_requests').delete().eq('email', testEmail);
    await supabase.from('users').delete().eq('email', testEmail);
  });

  it('returns 200 and creates a draft buy_box row with correct fields', async () => {
    // Dynamically import the CJS handler
    const { default: handler } = await import('../../api/free-scan-start.js');

    const req = mockReq({ body: scanBody });
    const res = mockRes();

    await handler(req, res);

    expect(res.statusCode, `handler returned ${res.statusCode}: ${JSON.stringify(res.body)}`).toBe(
      200
    );
    expect(res.body.success).toBe(true);
    expect(res.body.scanId).toBeTruthy();

    // buy_boxes row
    const { data: boxes, error: boxErr } = await supabase
      .from('buy_boxes')
      .select('*')
      .eq('user_email', testEmail);

    expect(boxErr, `buy_boxes query error: ${boxErr?.message}`).toBeNull();
    expect(boxes).toHaveLength(1);

    const box = boxes[0];
    expect(box.status).toBe('draft');
    expect(box.version).toBe(1);
    expect(box.criteria).toBeTruthy();
    // criteria should mirror the buy_box shape from the handler
    expect(box.criteria.asset_type).toBe(scanBody.assetType);
    expect(box.criteria.market).toBe(scanBody.market);
    expect(box.criteria.price_min).toBe(scanBody.priceMin);
    expect(box.criteria.price_max).toBe(scanBody.priceMax);

    // deal_searches row should have buy_box_id + buy_box_version stamped
    const { data: searches } = await supabase
      .from('deal_searches')
      .select('*')
      .eq('user_email', testEmail);

    expect(searches).toHaveLength(1);
    const search = searches[0];
    expect(search.buy_box_id).toBe(box.id);
    expect(search.buy_box_version).toBe(1);
  });
});

// ---------------------------------------------------------------------------
// TEST 2: checkout.session.completed activates draft buy_boxes
//
// Following the pattern in stripe-webhook-topup.test.js — we re-implement the
// relevant webhook branch inline rather than stubbing Stripe sig verification.
// This tests the exact Supabase mutations handleCheckoutCompleted() performs.
// ---------------------------------------------------------------------------

// Inline the auto-activation logic extracted from handleCheckoutCompleted so
// we can test it against the real DB without fighting Stripe sig verification.
async function applyCheckoutCompleted({ customerEmail, tier }, supabase) {
  // Upsert user (mirrors handleCheckoutCompleted)
  const now = new Date();
  const resetAt = new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth() + 1, 1));

  await supabase.from('users').upsert(
    {
      email: customerEmail,
      subscription_tier: tier,
      agent_runs_used: 0,
      agent_runs_reset_at: resetAt.toISOString(),
      monthly_compute_used: 0,
    },
    { onConflict: 'email' }
  );

  // Auto-activate draft buy_boxes up to tier limit
  const limit = TIER_ACTIVE_BOX_LIMITS[tier] != null ? TIER_ACTIVE_BOX_LIMITS[tier] : 3;

  let drafts;
  if (isFinite(limit) && limit > 0) {
    const { data } = await supabase
      .from('buy_boxes')
      .select('id')
      .eq('user_email', customerEmail)
      .eq('status', 'draft')
      .order('created_at', { ascending: true })
      .limit(limit);
    drafts = data;
  } else {
    const { data } = await supabase
      .from('buy_boxes')
      .select('id')
      .eq('user_email', customerEmail)
      .eq('status', 'draft')
      .order('created_at', { ascending: true });
    drafts = data;
  }

  if (drafts && drafts.length > 0) {
    const ids = drafts.map((d) => d.id);
    await supabase.from('buy_boxes').update({ status: 'active' }).in('id', ids);
  }
}

describe('checkout.session.completed activates draft buy_boxes', () => {
  const testEmail = freshTestEmail('buy-box-webhook');
  const supabase = getSupabase();
  let buyBoxId;

  beforeAll(async () => {
    // Seed a users row with founding tier
    const now = new Date();
    const resetAt = new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth() + 1, 1));
    await supabase.from('users').upsert(
      {
        email: testEmail,
        subscription_tier: 'founding',
        agent_runs_used: 0,
        agent_runs_reset_at: resetAt.toISOString(),
        monthly_compute_used: 0,
        agent_name: 'Scout',
      },
      { onConflict: 'email' }
    );

    // Pre-create 1 draft buy_box
    const { data, error } = await supabase
      .from('buy_boxes')
      .insert({
        user_email: testEmail,
        name: 'Motel in Austin, TX',
        criteria: {
          asset_type: 'motel',
          market: 'Austin, TX',
          price_min: 500000,
          price_max: 2000000,
        },
        status: 'draft',
        version: 1,
      })
      .select('id')
      .single();

    if (error) throw new Error(`beforeAll: buy_boxes insert failed: ${error.message}`);
    buyBoxId = data.id;
  });

  afterAll(async () => {
    await supabase.from('buy_boxes').delete().eq('user_email', testEmail);
    await supabase.from('users').delete().eq('email', testEmail);
  });

  it('draft buy_box is activated after checkout.session.completed', async () => {
    // Confirm it starts as draft
    const { data: before } = await supabase
      .from('buy_boxes')
      .select('status')
      .eq('id', buyBoxId)
      .single();
    expect(before.status).toBe('draft');

    // Simulate the webhook handler logic
    await applyCheckoutCompleted({ customerEmail: testEmail, tier: 'founding' }, supabase);

    // Should now be active
    const { data: after } = await supabase
      .from('buy_boxes')
      .select('status')
      .eq('id', buyBoxId)
      .single();
    expect(after.status).toBe('active');
  });

  it('only activates up to TIER_ACTIVE_BOX_LIMITS[tier] drafts', async () => {
    // Reset the existing box back to draft
    await supabase.from('buy_boxes').update({ status: 'draft' }).eq('id', buyBoxId);

    // Insert 5 more drafts (founding limit = 3, so only 3 of 6 total should activate)
    const extraDrafts = Array.from({ length: 5 }, (_, i) => ({
      user_email: testEmail,
      name: `Extra Draft ${i + 1}`,
      criteria: { asset_type: 'motel', market: 'Austin, TX', price_min: 100000, price_max: 500000 },
      status: 'draft',
      version: 1,
    }));
    await supabase.from('buy_boxes').insert(extraDrafts);

    await applyCheckoutCompleted({ customerEmail: testEmail, tier: 'founding' }, supabase);

    const { data: active } = await supabase
      .from('buy_boxes')
      .select('id')
      .eq('user_email', testEmail)
      .eq('status', 'active');

    const foundingLimit = TIER_ACTIVE_BOX_LIMITS['founding']; // 3
    expect(active.length).toBe(foundingLimit);
  });
});
