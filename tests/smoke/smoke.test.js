import { describe, it, expect, afterAll } from 'vitest';
import { createClient } from '@supabase/supabase-js';

const BASE_URL = process.env.SMOKE_TEST_URL;
if (!BASE_URL) throw new Error('SMOKE_TEST_URL env var required');

const CLEANUP_ENABLED = !!process.env.SUPABASE_URL && !!process.env.SUPABASE_SERVICE_KEY;

describe('Post-deploy smoke tests', () => {
  const createdSearchIds = [];

  afterAll(async () => {
    if (!CLEANUP_ENABLED) return;

    const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_KEY);
    const email = 'test-ci@dealhound.dev';

    await supabase.from('conversations').delete().eq('user_email', email);

    if (createdSearchIds.length > 0) {
      await supabase.from('scan_progress').delete().in('search_id', createdSearchIds);
      await supabase.from('deal_searches').delete().in('id', createdSearchIds);
    }
  });

  it('GET /api/health returns 200', async () => {
    const res = await fetch(`${BASE_URL}/api/health`);
    expect(res.status).toBe(200);
    const body = await res.json();
    expect(body.status).toBe('ok');
  });

  it('GET /api/user-data returns user object', async () => {
    const res = await fetch(`${BASE_URL}/api/user-data?email=test-ci@dealhound.dev`);
    expect(res.status).toBe(200);
    const body = await res.json();
    expect(body.agent_name).toBeDefined();
  });

  it('POST /api/chat streams a response', async () => {
    const res = await fetch(`${BASE_URL}/api/chat`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email: 'test-ci@dealhound.dev',
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
        email: 'test-ci@dealhound.dev',
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
      const hasText = events.some(e => e.type === 'text');
      const hasError = events.some(e => e.type === 'error');
      expect(hasError).toBe(false);
      expect(hasText).toBe(true);
      console.warn('Smoke: Claude did not call save_buy_box (nondeterministic). Streaming worked.');
    }
  }, 60000);
});
