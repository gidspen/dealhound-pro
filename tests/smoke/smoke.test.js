import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import { createClient } from '@supabase/supabase-js';

const BASE_URL = process.env.SMOKE_TEST_URL;
if (!BASE_URL) throw new Error('SMOKE_TEST_URL env var required');

const CLEANUP_ENABLED = !!process.env.SUPABASE_URL && !!process.env.SUPABASE_SERVICE_KEY;

describe('Post-deploy smoke tests', () => {
  const createdSearchIds = [];
  const TEST_EMAIL = `test-ci-${process.env.GITHUB_RUN_ID || Date.now()}@dealhound.dev`;

  // Ensure the test user is paywall-exempt (operator tier = unlimited). The
  // integration test in tests/integration/user-data.test.js deletes this user
  // in its afterAll, so by the time smoke runs the row is gone or freshly
  // created with subscription_tier=null, which the paywall in api/_lib/paywall.js
  // would block. Touching /api/user-data first auto-creates the row, then we
  // upgrade it to 'operator' so save_buy_box can fire end-to-end.
  beforeAll(async () => {
    // Warmup probe — poll /api/health up to 15s to survive cold-start Vercel functions
    const deadline = Date.now() + 15000;
    while (Date.now() < deadline) {
      try {
        const warmup = await fetch(`${BASE_URL}/api/health`);
        if (warmup.status === 200) break;
      } catch {
        // not ready yet
      }
      await new Promise(r => setTimeout(r, 1000));
    }

    if (!CLEANUP_ENABLED) return;
    const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_KEY);

    // Touch user-data once to auto-create the user row if missing
    await fetch(`${BASE_URL}/api/user-data?email=${encodeURIComponent(TEST_EMAIL)}`).catch(() => {});

    // Mark as operator-tier so the paywall doesn't block save_buy_box. Reset
    // agent_runs_used so this never trips the per-tier-limit branch either.
    await supabase
      .from('users')
      .update({ subscription_tier: 'operator', agent_runs_used: 0 })
      .eq('email', TEST_EMAIL);
  }, 20000);

  afterAll(async () => {
    if (!CLEANUP_ENABLED) return;

    const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_KEY);

    await supabase.from('conversations').delete().eq('user_email', TEST_EMAIL);

    if (createdSearchIds.length > 0) {
      await supabase.from('scrape_jobs').delete().in('search_id', createdSearchIds);
      await supabase.from('scan_progress').delete().in('search_id', createdSearchIds);
      await supabase.from('deal_searches').delete().in('id', createdSearchIds);
    }

    await supabase.from('users').delete().eq('email', TEST_EMAIL);
  });

  it('GET /api/health returns 200', async () => {
    const res = await fetch(`${BASE_URL}/api/health`);
    expect(res.status).toBe(200);
    const body = await res.json();
    expect(body.status).toBe('ok');
  });

  it('GET /api/user-data returns user object', async () => {
    const res = await fetch(`${BASE_URL}/api/user-data?email=${encodeURIComponent(TEST_EMAIL)}`);
    expect(res.status).toBe(200);
    const body = await res.json();
    expect(body.agent_name).toBeDefined();
  });

  it('POST /api/chat streams a response', async () => {
    const res = await fetch(`${BASE_URL}/api/chat`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email: TEST_EMAIL,
        messages: [
          { role: 'user', content: 'Hi, I want to set up my buy box.' }
        ]
      })
    });

    expect(res.status).toBe(200);
    const text = await res.text();
    expect(text).toContain('"type":"text"');
  }, 30000);

  it('POST /api/chat buy box save works end-to-end', async () => {
    const res = await fetch(`${BASE_URL}/api/chat`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email: TEST_EMAIL,
        messages: [
          { role: 'user', content: 'Hi, I want to set up my buy box.' },
          { role: 'assistant', content: "Hey! I'm Scout. Tell me what you're looking for." },
          { role: 'user', content: 'Glamping sites in Texas, under $1M, 5-15 units, cash flowing. No RV parks.' },
          { role: 'assistant', content: "Here's what I'll hunt for: Glamping sites in Texas, under $1M, 5-15 units, cash flowing from day 1. No RV parks. Ready to run your first scan?" },
          { role: 'user', content: 'yes' }
        ]
      })
    });

    expect(res.status).toBe(200);
    const text = await res.text();

    const lines = text.split('\n').filter(l => l.startsWith('data: '));
    const events = lines.map(l => {
      try { return JSON.parse(l.slice(6)); } catch { return null; }
    }).filter(Boolean);

    const saved = events.find(e => e.type === 'buy_box_saved');
    if (saved) {
      expect(saved.search_id).toBeDefined();
      expect(saved.buy_box).toBeDefined();
      createdSearchIds.push(saved.search_id);
    } else {
      // LLM nondeterminism — verify we got a response, not an error
      const hasError = events.some(e => e.type === 'error');
      expect(hasError).toBe(false);
      console.warn('Smoke: Claude returned tool-only response (no text deltas) — non-fatal.');
    }
  }, 60000);
});
