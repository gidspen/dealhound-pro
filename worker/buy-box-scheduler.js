/**
 * buy-box-scheduler.js
 *
 * Scheduler function that wakes up on each worker tick, finds overdue active
 * buy boxes, and enqueues deal_searches + scrape_jobs rows for the job queue
 * to execute.
 *
 * This module is intentionally side-effect free (no setInterval, no singleton
 * state). The worker's main loop calls runBuyBoxScheduler() once per tick.
 *
 * Behavior when WORKER_TEST_MODE=true (passed in via options):
 *   - Still queries buy_boxes and inserts deal_searches + scrape_jobs rows
 *     (those writes ARE the test surface).
 *   - The worker's processPendingJobs() loop is separately gated by
 *     WORKER_TEST_MODE so it does not actually spawn Claude.
 */

'use strict';

const { TIER_SCAN_INTERVAL_MS } = require('../api/_lib/buy-box-limits');

const DEFAULT_INTERVAL_MS = 24 * 60 * 60 * 1000; // 24 hours

/**
 * runBuyBoxScheduler
 *
 * 1. Selects all buy_boxes WHERE status = 'active'.
 * 2. Joins users to read subscription_tier (separate query — simpler than join).
 * 3. Computes the scan interval for that user's tier.
 * 4. If last_scanned_at IS NULL or overdue: inserts deal_searches + scrape_jobs,
 *    then updates buy_boxes.last_scanned_at = now().
 *
 * @param {import('@supabase/supabase-js').SupabaseClient} supabase
 * @param {object} [options]
 * @param {boolean} [options.testData]  If true, mark deal_searches rows with
 *                                      test_data = true (useful for cleanup).
 * @returns {Promise<{ scheduled: number, skipped: number }>}
 */
async function runBuyBoxScheduler(supabase, options = {}) {
  const { testData = false } = options;

  // ── 1. Fetch all active buy boxes ─────────────────────────────────────────
  const { data: boxes, error: boxesError } = await supabase
    .from('buy_boxes')
    .select('id, user_email, criteria, version, last_scanned_at')
    .eq('status', 'active');

  if (boxesError) {
    throw new Error(`buy-box-scheduler: failed to fetch buy_boxes — ${boxesError.message}`);
  }

  if (!boxes || boxes.length === 0) {
    return { scheduled: 0, skipped: 0 };
  }

  // ── 2. Batch-fetch user tiers for all distinct emails ─────────────────────
  const emails = [...new Set(boxes.map((b) => b.user_email))];
  const { data: users, error: usersError } = await supabase
    .from('users')
    .select('email, subscription_tier')
    .in('email', emails);

  if (usersError) {
    throw new Error(`buy-box-scheduler: failed to fetch users — ${usersError.message}`);
  }

  const tierByEmail = {};
  for (const u of users || []) {
    tierByEmail[u.email] = (u.subscription_tier || 'hunter').toLowerCase();
  }

  // ── 3. Process each box ───────────────────────────────────────────────────
  const now = new Date();
  let scheduled = 0;
  let skipped = 0;

  for (const box of boxes) {
    const tier = tierByEmail[box.user_email] || 'hunter';
    const intervalMs = TIER_SCAN_INTERVAL_MS[tier] ?? DEFAULT_INTERVAL_MS;

    // Determine if overdue
    const lastScanned = box.last_scanned_at ? new Date(box.last_scanned_at) : null;
    const isOverdue = !lastScanned || now - lastScanned >= intervalMs;

    if (!isOverdue) {
      skipped++;
      continue;
    }

    // ── 4a. Insert deal_searches row ──────────────────────────────────────
    const { data: search, error: searchError } = await supabase
      .from('deal_searches')
      .insert({
        user_email: box.user_email,
        buy_box: box.criteria,        // criteria snapshot — keeps deal_searches self-contained
        buy_box_id: box.id,
        buy_box_version: box.version,
        status: 'queued',
        run_at: now.toISOString(),
        test_data: testData,
      })
      .select('id')
      .single();

    if (searchError) {
      // Log and continue — don't abort the whole scheduler for one bad box
      console.error(
        `[buy-box-scheduler] deal_searches insert failed for box ${box.id}: ${searchError.message}`
      );
      skipped++;
      continue;
    }

    // ── 4b. Insert scrape_jobs row ────────────────────────────────────────
    const { error: jobError } = await supabase.from('scrape_jobs').insert({
      search_id: search.id,
      buy_box: box.criteria,
      status: 'pending',
      trigger: 'on_demand', // 'scheduled' not in check constraint — on_demand is the canonical value
    });

    if (jobError) {
      console.error(
        `[buy-box-scheduler] scrape_jobs insert failed for box ${box.id}: ${jobError.message}`
      );
      // Attempt to clean up the orphaned deal_searches row (best-effort)
      await supabase.from('deal_searches').delete().eq('id', search.id);
      skipped++;
      continue;
    }

    // ── 4c. Update last_scanned_at ────────────────────────────────────────
    await supabase
      .from('buy_boxes')
      .update({ last_scanned_at: now.toISOString() })
      .eq('id', box.id);

    scheduled++;
  }

  return { scheduled, skipped };
}

module.exports = { runBuyBoxScheduler };
