// tests/integration/scan-trigger-raw-prompt.test.js
import { describe, it, expect, afterAll } from 'vitest';
import { getTestSupabase, cleanupTestData } from '../helpers/supabase.js';
import { TEST_EMAIL } from '../helpers/test-constants.js';
import { triggerScan } from '../../api/_lib/scan-trigger.js';

describe('triggerScan with raw_prompt', () => {
  const supabase = getTestSupabase();
  const createdSearchIds = [];

  afterAll(async () => {
    if (createdSearchIds.length > 0) {
      await supabase.from('scrape_jobs').delete().in('search_id', createdSearchIds);
    }
    await cleanupTestData(supabase, TEST_EMAIL);
  });

  it('persists raw_prompt on the scrape_jobs row', async () => {
    const buyBox = {
      raw_prompt: 'micro resort in east texas, minimum 8 acres, $500k to $3m, must have existing structure, cash flow from day 1',
      locations: ['East Texas'],
      price_min: 500_000,
      price_max: 3_000_000,
      acreage_min: 8,
      property_types: ['micro_resort'],
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

    expect(job.buy_box.raw_prompt).toContain('micro resort');
    expect(job.buy_box.raw_prompt).toContain('east texas');
    expect(job.buy_box.raw_prompt).toContain('$500k');
    expect(job.buy_box.property_types).toEqual(['micro_resort']);
  });
});
