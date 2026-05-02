// tests/integration/scan-progress-events.test.js
import { describe, it, expect, afterAll } from 'vitest';
import { getTestSupabase, cleanupTestData } from '../helpers/supabase.js';
import { TEST_EMAIL } from '../helpers/test-constants.js';

describe('scan_progress events', () => {
  const supabase = getTestSupabase();
  const createdIds = [];

  afterAll(async () => {
    if (createdIds.length > 0) {
      await supabase.from('scan_progress').delete().in('search_id', createdIds);
    }
    await cleanupTestData(supabase, TEST_EMAIL);
  });

  it('round-trips the shape the skill writes', async () => {
    const { data: search } = await supabase
      .from('deal_searches')
      .insert({
        user_email: TEST_EMAIL,
        buy_box: { raw_prompt: 'test', locations: ['TX'], price_max: 1_000_000, property_types: ['micro_resort'], revenue_requirement: 'any' },
        status: 'scanning',
        test_data: true,
        run_at: new Date().toISOString(),
      })
      .select('id').single();
    createdIds.push(search.id);

    const events = [
      { search_id: search.id, step: 'discover:start', status: 'running', message: 'Loading sites...' },
      { search_id: search.id, step: 'scrape:landsearch:done', status: 'complete', message: 'LandSearch: 231 listings', listing_count: 231 },
      { search_id: search.id, step: 'apply_buybox:done', status: 'complete', message: '12 candidates passed', listing_count: 12 },
      { search_id: search.id, step: 'complete', status: 'complete', message: 'Done — 7 scored deals', listing_count: 7 },
    ];
    for (const e of events) {
      const { error } = await supabase.from('scan_progress').insert(e);
      expect(error).toBeNull();
    }

    const { data: rows } = await supabase
      .from('scan_progress')
      .select('step, status, message, listing_count')
      .eq('search_id', search.id)
      .order('created_at', { ascending: true });

    expect(rows).toHaveLength(4);
    expect(rows[0].step).toBe('discover:start');
    expect(rows[1].listing_count).toBe(231);
    expect(rows[3].step).toBe('complete');
  });
});
