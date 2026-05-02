import { describe, it, expect, afterAll } from 'vitest';
import { getTestSupabase, cleanupTestData } from '../helpers/supabase.js';
import { TEST_EMAIL } from '../helpers/test-constants.js';
import { triggerScan } from '../../api/_lib/scan-trigger.js';

describe('triggerScan raw_prompt persistence', () => {
  const supabase = getTestSupabase();
  const createdSearchIds = [];

  afterAll(async () => {
    // Clean up scrape_jobs for any search we created
    if (createdSearchIds.length > 0) {
      await supabase.from('scrape_jobs').delete().in('search_id', createdSearchIds);
    }
    await cleanupTestData(supabase, TEST_EMAIL);
  });

  it('preserves raw_prompt through triggerScan into scrape_jobs', async () => {
    const buyBox = {
      raw_prompt: 'luxury micro resort in coastal north carolina, $3m-5m, strong cash flow, oceanfront preferred',
      locations: ['Coastal North Carolina'],
      price_max: 5_000_000,
      property_types: ['micro_resort', 'boutique_hotel'],
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
      .select('buy_box')
      .eq('search_id', search.id)
      .single();

    expect(job).not.toBeNull();
    expect(job.buy_box).not.toBeNull();
    expect(job.buy_box.raw_prompt).toBe('luxury micro resort in coastal north carolina, $3m-5m, strong cash flow, oceanfront preferred');
    expect(job.buy_box.locations).toContain('Coastal North Carolina');
    expect(job.buy_box.price_max).toBe(5_000_000);
    expect(job.buy_box.property_types).toContain('micro_resort');
    expect(job.buy_box.property_types).toContain('boutique_hotel');
    expect(job.buy_box.revenue_requirement).toBe('cash_flow_day_1');
  });
});
