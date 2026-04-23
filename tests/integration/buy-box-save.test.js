import { describe, it, expect, afterAll } from 'vitest';
import { getTestSupabase, cleanupTestData } from '../helpers/supabase.js';
import { TEST_EMAIL } from '../helpers/test-constants.js';

describe('Buy box save', () => {
  const supabase = getTestSupabase();
  let createdId;

  afterAll(() => cleanupTestData(supabase, TEST_EMAIL));

  it('inserts a deal_search with buy box and returns the ID', async () => {
    const buyBox = {
      locations: ['Coastal North Carolina'],
      price_max: 2000000,
      property_types: ['boutique_hotel', 'micro_resort'],
      revenue_requirement: 'cash_flow_day_1'
    };

    const { data, error } = await supabase
      .from('deal_searches')
      .insert({
        user_email: TEST_EMAIL,
        buy_box: buyBox,
        status: 'ready',
        test_data: true,
        run_at: new Date().toISOString()
      })
      .select('id')
      .single();

    expect(error).toBeNull();
    expect(data.id).toBeDefined();
    expect(typeof data.id).toBe('string');
    createdId = data.id;
  });

  it('retrieves the saved buy box with correct data', async () => {
    const { data, error } = await supabase
      .from('deal_searches')
      .select('user_email, buy_box, status, test_data')
      .eq('id', createdId)
      .single();

    expect(error).toBeNull();
    expect(data.user_email).toBe(TEST_EMAIL);
    expect(data.status).toBe('ready');
    expect(data.test_data).toBe(true);
    expect(data.buy_box.locations).toContain('Coastal North Carolina');
    expect(data.buy_box.price_max).toBe(2000000);
  });
});
