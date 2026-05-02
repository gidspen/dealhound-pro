// tests/integration/user-data-isolation.test.js
import { describe, it, expect, afterAll, beforeAll } from 'vitest';
import { getTestSupabase, cleanupTestData } from '../helpers/supabase.js';
import { TEST_EMAIL } from '../helpers/test-constants.js';

const OTHER_EMAIL = 'other-user-isolation@dealhound.dev';

describe('user-data isolation', () => {
  const supabase = getTestSupabase();
  let mySearchId, otherSearchId;

  beforeAll(async () => {
    // Create my search + a deal scored against my buy box
    const { data: mySearch } = await supabase
      .from('deal_searches')
      .insert({
        user_email: TEST_EMAIL,
        buy_box: { locations: ['Austin, TX'], price_max: 2_000_000 },
        status: 'complete',
        test_data: true,
        run_at: new Date().toISOString(),
      })
      .select('id').single();
    mySearchId = mySearch.id;

    await supabase.from('deals').insert({
      search_id: mySearchId,
      url: 'https://example.com/mine-1',
      title: 'My Deal',
      price: 1_500_000,
      location: 'Austin, TX',
      source: 'bizbuysell',
      passed_hard_filters: true,
      scraped_at: new Date().toISOString(),
    });

    // Create another user's search + their deal
    const { data: otherSearch } = await supabase
      .from('deal_searches')
      .insert({
        user_email: OTHER_EMAIL,
        buy_box: { locations: ['Austin, TX'], price_max: 2_000_000 },
        status: 'complete',
        test_data: true,
        run_at: new Date().toISOString(),
      })
      .select('id').single();
    otherSearchId = otherSearch.id;

    await supabase.from('deals').insert({
      search_id: otherSearchId,
      url: 'https://example.com/theirs-1',
      title: 'Other User Deal',
      price: 1_800_000,
      location: 'Austin, TX',
      source: 'bizbuysell',
      passed_hard_filters: true,
      scraped_at: new Date().toISOString(),
    });
  });

  afterAll(async () => {
    await cleanupTestData(supabase, TEST_EMAIL);
    await cleanupTestData(supabase, OTHER_EMAIL);
  });

  it('returns only deals whose search_id belongs to the requesting user', async () => {
    const { data: scans } = await supabase
      .from('deal_searches')
      .select('id')
      .eq('user_email', TEST_EMAIL);
    const scanIds = scans.map(s => s.id);

    const { data: deals } = await supabase
      .from('deals')
      .select('id, title, search_id')
      .in('search_id', scanIds)
      .eq('passed_hard_filters', true);

    const titles = deals.map(d => d.title);
    expect(titles).toContain('My Deal');
    expect(titles).not.toContain('Other User Deal');
  });

  it('does not return system-scraped deals (union scrape) to a user', async () => {
    const { data: systemSearch } = await supabase
      .from('deal_searches')
      .insert({
        user_email: 'system+union@dealhound.dev',
        buy_box: { locations: ['Austin, TX'] },
        status: 'complete',
        test_data: true,
        run_at: new Date().toISOString(),
      })
      .select('id').single();

    await supabase.from('deals').insert({
      search_id: systemSearch.id,
      url: 'https://example.com/union-1',
      title: 'Union Pre-Warm Deal',
      price: 1_200_000,
      location: 'Austin, TX',
      source: 'bizbuysell',
      passed_hard_filters: true,
      scraped_at: new Date().toISOString(),
    });

    const { data: scans } = await supabase
      .from('deal_searches')
      .select('id')
      .eq('user_email', TEST_EMAIL);
    const scanIds = scans.map(s => s.id);

    const { data: deals } = await supabase
      .from('deals')
      .select('id, title, search_id')
      .in('search_id', scanIds)
      .eq('passed_hard_filters', true);

    const titles = deals.map(d => d.title);
    expect(titles).not.toContain('Union Pre-Warm Deal');

    // Cleanup the system search test data
    await supabase.from('deals').delete().eq('search_id', systemSearch.id);
    await supabase.from('deal_searches').delete().eq('id', systemSearch.id);
  });
});
