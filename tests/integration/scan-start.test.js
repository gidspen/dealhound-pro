import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import { getTestSupabase, cleanupTestData } from '../helpers/supabase.js';
import { TEST_EMAIL } from '../helpers/test-constants.js';

describe('Scan start', () => {
  const supabase = getTestSupabase();
  let searchId;

  beforeAll(async () => {
    const { data } = await supabase
      .from('deal_searches')
      .insert({
        user_email: TEST_EMAIL,
        buy_box: { locations: ['Texas'], price_max: 1500000, property_types: ['boutique_hotel'], revenue_requirement: 'any' },
        status: 'ready',
        test_data: true,
        run_at: new Date().toISOString()
      })
      .select('id')
      .single();

    searchId = data.id;
  });

  afterAll(() => cleanupTestData(supabase, TEST_EMAIL));

  it('transitions a search from ready to scanning', async () => {
    const { error } = await supabase
      .from('deal_searches')
      .update({ status: 'scanning' })
      .eq('id', searchId);

    expect(error).toBeNull();

    const { data } = await supabase
      .from('deal_searches')
      .select('status')
      .eq('id', searchId)
      .single();

    expect(data.status).toBe('scanning');
  });

  it('can insert scan_progress rows', async () => {
    const steps = [
      { search_id: searchId, step: 'init', status: 'complete', message: 'Buy box loaded' },
      { search_id: searchId, step: 'scrape_test', status: 'running', message: 'Scanning test marketplace...' }
    ];

    const { error: insertError } = await supabase.from('scan_progress').insert(steps);
    expect(insertError).toBeNull();

    // Verify rows exist — use count to avoid RLS read issues
    const { count, error: countError } = await supabase
      .from('scan_progress')
      .select('*', { count: 'exact', head: true })
      .eq('search_id', searchId);

    expect(countError).toBeNull();
    expect(count).toBe(2);
  });
});
