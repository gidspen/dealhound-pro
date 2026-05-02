import { describe, it, expect, afterAll } from 'vitest';
import { getTestSupabase, cleanupTestData } from '../helpers/supabase.js';
import { TEST_EMAIL } from '../helpers/test-constants.js';
import { triggerScan } from '../../api/_lib/scan-trigger.js';

describe('triggerScan', () => {
  const supabase = getTestSupabase();
  const createdSearchIds = [];

  afterAll(async () => {
    // Clean up scrape_jobs for any search we created
    if (createdSearchIds.length > 0) {
      await supabase.from('scrape_jobs').delete().in('search_id', createdSearchIds);
    }
    await cleanupTestData(supabase, TEST_EMAIL);
  });

  it('inserts a scrape_jobs row and sets deal_searches.status=scanning', async () => {
    const buyBox = {
      locations: ['Austin, TX'],
      price_max: 2_000_000,
      property_types: ['boutique_hotel'],
      revenue_requirement: 'cash_flow_day_1',
    };

    const { data: search } = await supabase
      .from('deal_searches')
      .insert({
        user_email: TEST_EMAIL,
        buy_box: buyBox,
        status: 'ready',
        test_data: true,
        run_at: new Date().toISOString(),
      })
      .select('id')
      .single();

    createdSearchIds.push(search.id);

    await triggerScan(search.id, buyBox, supabase);

    const { data: job } = await supabase
      .from('scrape_jobs')
      .select('search_id, status, buy_box')
      .eq('search_id', search.id)
      .single();

    expect(job).not.toBeNull();
    expect(job.status).toBe('pending');
    expect(job.buy_box.price_max).toBe(2_000_000);

    const { data: updatedSearch } = await supabase
      .from('deal_searches')
      .select('status')
      .eq('id', search.id)
      .single();

    expect(updatedSearch.status).toBe('scanning');
  });

  it('queues a scan even if the pool already has matching deals (no bypass)', async () => {
    const buyBox = {
      locations: ['Austin, TX'],
      price_max: 2_000_000,
      property_types: ['boutique_hotel'],
    };

    const { data: search } = await supabase
      .from('deal_searches')
      .insert({
        user_email: TEST_EMAIL,
        buy_box: buyBox,
        status: 'ready',
        test_data: true,
        run_at: new Date().toISOString(),
      })
      .select('id')
      .single();

    createdSearchIds.push(search.id);

    await triggerScan(search.id, buyBox, supabase);

    const { count } = await supabase
      .from('scrape_jobs')
      .select('*', { count: 'exact', head: true })
      .eq('search_id', search.id);

    expect(count).toBe(1);
  });

  it('throws if required args missing', async () => {
    await expect(triggerScan(null, {}, supabase)).rejects.toThrow(/searchId/);
    await expect(triggerScan('x', null, supabase)).rejects.toThrow(/buyBox/);
    await expect(triggerScan('x', {}, null)).rejects.toThrow(/supabase/);
  });
});
