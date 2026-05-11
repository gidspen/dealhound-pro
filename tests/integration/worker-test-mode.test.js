// tests/integration/worker-test-mode.test.js
//
// Locks in the WORKER_TEST_MODE short-circuit contract. When the env flag is
// set, the worker must skip the Claude/Apify spawn entirely and instead insert
// 3 fake deals + mark scan_run/job/search complete. Lets Flow B+C+G e2e tests
// exercise the full pipeline without token spend.
//
// Default OFF: worker behavior must be byte-identical when the flag is unset.

import { describe, it, expect, afterAll, beforeAll, vi } from 'vitest';
import { getTestSupabase, cleanupTestData } from '../helpers/supabase.js';
import { TEST_EMAIL } from '../helpers/test-constants.js';

describe('WORKER_TEST_MODE short-circuit', () => {
  const supabase = getTestSupabase();
  const createdSearchIds = [];
  const createdJobIds = [];

  beforeAll(() => {
    process.env.WORKER_TEST_MODE = 'true';
  });

  afterAll(async () => {
    delete process.env.WORKER_TEST_MODE;
    if (createdJobIds.length > 0) {
      await supabase.from('scan_runs').delete().in('scrape_job_id', createdJobIds);
      await supabase.from('scrape_jobs').delete().in('id', createdJobIds);
    }
    if (createdSearchIds.length > 0) {
      await supabase.from('deals').delete().in('search_id', createdSearchIds);
    }
    await cleanupTestData(supabase, TEST_EMAIL);
  });

  async function seedSearchAndJob() {
    const { data: search } = await supabase
      .from('deal_searches')
      .insert({
        user_email: TEST_EMAIL,
        buy_box: {
          raw_prompt: 'test mode',
          locations: ['TX'],
          price_max: 2_000_000,
          property_types: ['micro_resort'],
          revenue_requirement: 'any',
        },
        status: 'scanning',
        test_data: true,
        run_at: new Date().toISOString(),
      })
      .select('id')
      .single();
    createdSearchIds.push(search.id);

    const { data: job } = await supabase
      .from('scrape_jobs')
      .insert({ search_id: search.id, buy_box: { raw_prompt: 'x' }, status: 'running' })
      .select()
      .single();
    createdJobIds.push(job.id);

    return { searchId: search.id, job };
  }

  it('inserts 3 fake deals for the job search_id', async () => {
    const { runFindDealsTestMode } = await import('../../worker/worker.js');
    const { searchId, job } = await seedSearchAndJob();

    await runFindDealsTestMode(job, supabase);

    const { data: deals, count } = await supabase
      .from('deals')
      .select('title, score_breakdown, source', { count: 'exact' })
      .eq('search_id', searchId);

    expect(count).toBe(3);
    expect(deals.every((d) => d.source === 'test_mode')).toBe(true);

    const tiers = deals.map((d) => d.score_breakdown?.strategy?.overall).sort();
    expect(tiers).toEqual(['MATCH', 'PARTIAL', 'STRONG MATCH']);
  });

  it('marks the scan_run as complete', async () => {
    const { runFindDealsTestMode } = await import('../../worker/worker.js');
    const { searchId, job } = await seedSearchAndJob();

    await runFindDealsTestMode(job, supabase);

    const { data: run } = await supabase
      .from('scan_runs')
      .select('status')
      .eq('scrape_job_id', job.id)
      .single();

    expect(run.status).toBe('complete');
  });

  it('marks the scrape_job as complete', async () => {
    const { runFindDealsTestMode } = await import('../../worker/worker.js');
    const { job } = await seedSearchAndJob();

    await runFindDealsTestMode(job, supabase);

    const { data: updatedJob } = await supabase
      .from('scrape_jobs')
      .select('status')
      .eq('id', job.id)
      .single();

    expect(updatedJob.status).toBe('complete');
  });

  it('updates the deal_searches status to complete', async () => {
    const { runFindDealsTestMode } = await import('../../worker/worker.js');
    const { searchId, job } = await seedSearchAndJob();

    await runFindDealsTestMode(job, supabase);

    const { data: search } = await supabase
      .from('deal_searches')
      .select('status')
      .eq('id', searchId)
      .single();

    expect(search.status).toBe('complete');
  });

  it('does NOT invoke runFindDeals (the real Claude spawn)', async () => {
    const workerModule = await import('../../worker/worker.js');
    const spy = vi.spyOn(workerModule, 'runFindDeals');
    const { job } = await seedSearchAndJob();

    await workerModule.runFindDealsTestMode(job, supabase);

    expect(spy).not.toHaveBeenCalled();
    spy.mockRestore();
  });
});
