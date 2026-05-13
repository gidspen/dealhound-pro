// tests/integration/worker-scheduler.test.js
//
// Integration tests for the buy-box scheduler. The scheduler is imported and
// called directly — NO worker process is started, NO Claude is spawned.
//
// WORKER_TEST_MODE=true is set globally so the existing processPendingJobs()
// picker won't execute real scans if it ever runs in the same process.

process.env.WORKER_TEST_MODE = 'true';

import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import { getTestSupabase } from '../helpers/supabase.js';
import { runBuyBoxScheduler } from '../../worker/buy-box-scheduler.js';

const supabase = getTestSupabase();

// ── Test email namespacing ─────────────────────────────────────────────────────
// Each test run gets unique emails so parallel CI runs don't collide.
const ts = Date.now();
const makeEmail = (suffix) => `scheduler-test-${suffix}-${ts}@dealhound.dev`;

// Track every row created so afterAll can clean up completely.
const createdUserEmails = [];
const createdBuyBoxIds = [];
const createdSearchIds = [];

// ── Helpers ───────────────────────────────────────────────────────────────────

async function createUser(email, tier = 'founding') {
  const { data, error } = await supabase
    .from('users')
    .upsert({ email, subscription_tier: tier, agent_name: 'TestAgent' }, { onConflict: 'email' })
    .select('email')
    .single();
  if (error) throw new Error(`createUser failed: ${error.message}`);
  createdUserEmails.push(email);
  return data;
}

async function createBuyBox(email, { lastScannedAt = undefined, status = 'active' } = {}) {
  const payload = {
    user_email: email,
    name: 'Test Box',
    criteria: {
      markets: ['Austin TX'],
      price_max: 1_500_000,
      property_types: ['micro_resort'],
    },
    status,
    version: 1,
  };
  if (lastScannedAt !== undefined) {
    payload.last_scanned_at = lastScannedAt;
  }

  const { data, error } = await supabase
    .from('buy_boxes')
    .insert(payload)
    .select('id, version, criteria, last_scanned_at')
    .single();
  if (error) throw new Error(`createBuyBox failed: ${error.message}`);
  createdBuyBoxIds.push(data.id);
  return data;
}

async function getSearchesForBox(buyBoxId) {
  const { data } = await supabase
    .from('deal_searches')
    .select('id, buy_box_id, buy_box_version, buy_box, status')
    .eq('buy_box_id', buyBoxId);
  if (data) createdSearchIds.push(...data.map((s) => s.id));
  return data || [];
}

async function getScrapeJobsForSearches(searchIds) {
  if (!searchIds.length) return [];
  const { data } = await supabase
    .from('scrape_jobs')
    .select('id, search_id, status, trigger')
    .in('search_id', searchIds);
  return data || [];
}

async function getBuyBox(id) {
  const { data } = await supabase
    .from('buy_boxes')
    .select('id, last_scanned_at')
    .eq('id', id)
    .single();
  return data;
}

// ── Cleanup ───────────────────────────────────────────────────────────────────

afterAll(async () => {
  // Scrape jobs → deal_searches → buy_boxes → users (in dependency order)
  if (createdSearchIds.length > 0) {
    await supabase.from('scrape_jobs').delete().in('search_id', createdSearchIds);
    await supabase.from('deals').delete().in('search_id', createdSearchIds);
    await supabase.from('scan_progress').delete().in('search_id', createdSearchIds);
    await supabase.from('deal_searches').delete().in('id', createdSearchIds);
  }
  if (createdBuyBoxIds.length > 0) {
    await supabase.from('buy_boxes').delete().in('id', createdBuyBoxIds);
  }
  if (createdUserEmails.length > 0) {
    await supabase.from('users').delete().in('email', createdUserEmails);
  }
});

// ── Tests ─────────────────────────────────────────────────────────────────────

describe('buy-box scheduler', () => {
  // ── Test 1: schedules when interval exceeded ──────────────────────────────
  it('inserts scrape_job when interval exceeded (founding tier, 25h ago)', async () => {
    const email = makeEmail('founding-overdue');
    await createUser(email, 'founding');

    const twentyFiveHoursAgo = new Date(Date.now() - 25 * 60 * 60 * 1000).toISOString();
    const box = await createBuyBox(email, { lastScannedAt: twentyFiveHoursAgo });

    const summary = await runBuyBoxScheduler(supabase, { testData: true });
    expect(summary.scheduled).toBeGreaterThanOrEqual(1);

    // deal_searches row
    const searches = await getSearchesForBox(box.id);
    expect(searches.length).toBe(1);

    const search = searches[0];
    expect(search.buy_box_id).toBe(box.id);
    expect(search.buy_box_version).toBe(box.version);
    expect(search.buy_box).toMatchObject(box.criteria);

    // scrape_jobs row referencing the new search
    const jobs = await getScrapeJobsForSearches([search.id]);
    expect(jobs.length).toBe(1);
    expect(jobs[0].search_id).toBe(search.id);
    expect(jobs[0].status).toBe('pending');

    // last_scanned_at updated
    const refreshed = await getBuyBox(box.id);
    const updatedAt = new Date(refreshed.last_scanned_at);
    expect(Date.now() - updatedAt.getTime()).toBeLessThan(10_000); // within 10s of now
  });

  // ── Test 2: skips when within interval ───────────────────────────────────
  it('skips when within interval (founding tier, 1h ago)', async () => {
    const email = makeEmail('founding-recent');
    await createUser(email, 'founding');

    const oneHourAgo = new Date(Date.now() - 1 * 60 * 60 * 1000).toISOString();
    const box = await createBuyBox(email, { lastScannedAt: oneHourAgo });

    const before = await getSearchesForBox(box.id);
    await runBuyBoxScheduler(supabase, { testData: true });
    const after = await getSearchesForBox(box.id);

    // No new searches created for this box
    expect(after.length).toBe(before.length);
  });

  // ── Test 3: schedules never-scanned buy box ───────────────────────────────
  it('schedules a never-scanned buy_box (last_scanned_at = NULL)', async () => {
    const email = makeEmail('never-scanned');
    await createUser(email, 'founding');

    // No lastScannedAt — leaves column NULL
    const box = await createBuyBox(email);
    expect(box.last_scanned_at).toBeNull();

    const summary = await runBuyBoxScheduler(supabase, { testData: true });
    expect(summary.scheduled).toBeGreaterThanOrEqual(1);

    const searches = await getSearchesForBox(box.id);
    expect(searches.length).toBe(1);

    const jobs = await getScrapeJobsForSearches([searches[0].id]);
    expect(jobs.length).toBe(1);
  });

  // ── Test 4: skips draft and archived buy boxes ────────────────────────────
  it('skips draft and archived buy_boxes', async () => {
    const email = makeEmail('non-active');
    await createUser(email, 'founding');

    const draft = await createBuyBox(email, { status: 'draft' });
    const archived = await createBuyBox(email, { status: 'archived' });

    await runBuyBoxScheduler(supabase, { testData: true });

    const draftSearches = await getSearchesForBox(draft.id);
    const archivedSearches = await getSearchesForBox(archived.id);

    expect(draftSearches.length).toBe(0);
    expect(archivedSearches.length).toBe(0);
  });

  // ── Test 5: respects tier interval (investor = 1h) ────────────────────────
  describe('tier interval enforcement (investor = 1h)', () => {
    it('schedules investor-tier box that is 65 minutes overdue', async () => {
      const email = makeEmail('investor-overdue');
      await createUser(email, 'investor');

      const sixtyFiveMinAgo = new Date(Date.now() - 65 * 60 * 1000).toISOString();
      const box = await createBuyBox(email, { lastScannedAt: sixtyFiveMinAgo });

      await runBuyBoxScheduler(supabase, { testData: true });

      const searches = await getSearchesForBox(box.id);
      expect(searches.length).toBe(1);
    });

    it('does NOT schedule investor-tier box scanned 30 minutes ago', async () => {
      const email = makeEmail('investor-recent');
      await createUser(email, 'investor');

      const thirtyMinAgo = new Date(Date.now() - 30 * 60 * 1000).toISOString();
      const box = await createBuyBox(email, { lastScannedAt: thirtyMinAgo });

      await runBuyBoxScheduler(supabase, { testData: true });

      const searches = await getSearchesForBox(box.id);
      expect(searches.length).toBe(0);
    });
  });
});
