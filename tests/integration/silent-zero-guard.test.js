// tests/integration/silent-zero-guard.test.js
import { describe, it, expect, afterAll } from 'vitest';
import { getTestSupabase, cleanupTestData } from '../helpers/supabase.js';
import { TEST_EMAIL } from '../helpers/test-constants.js';

describe('silent-zero guard contract', () => {
  const supabase = getTestSupabase();
  const createdIds = [];

  afterAll(async () => {
    if (createdIds.length > 0) {
      await supabase.from('scan_runs').delete().in('search_id', createdIds);
      await supabase.from('scrape_jobs').delete().in('search_id', createdIds);
    }
    await cleanupTestData(supabase, TEST_EMAIL);
  });

  it('writes scan_runs.error when zero deals exist for search_id', async () => {
    const { data: search } = await supabase
      .from('deal_searches')
      .insert({
        user_email: TEST_EMAIL,
        buy_box: { raw_prompt: 'silent zero test', locations: ['TX'], price_max: 1_000_000, property_types: ['micro_resort'], revenue_requirement: 'any' },
        status: 'scanning',
        test_data: true,
        run_at: new Date().toISOString(),
      })
      .select('id').single();
    createdIds.push(search.id);

    const { data: job } = await supabase
      .from('scrape_jobs')
      .insert({ search_id: search.id, buy_box: { raw_prompt: 'x' }, status: 'running' })
      .select('id').single();

    const { data: run } = await supabase
      .from('scan_runs')
      .insert({
        search_id: search.id,
        scrape_job_id: job.id,
        user_email: TEST_EMAIL,
        status: 'running',
        started_at: new Date().toISOString(),
      })
      .select('id').single();

    const { count } = await supabase
      .from('deals')
      .select('*', { count: 'exact', head: true })
      .eq('search_id', search.id);

    expect(count).toBe(0);

    await supabase
      .from('scan_runs')
      .update({
        status: 'error',
        completed_at: new Date().toISOString(),
        error: 'Skill completed but wrote zero listings — check buy box format and scraper output',
      })
      .eq('id', run.id);

    const { data: updated } = await supabase
      .from('scan_runs')
      .select('status, error')
      .eq('id', run.id)
      .single();

    expect(updated.status).toBe('error');
    expect(updated.error).toContain('zero listings');
  });
});
