// tests/e2e/helpers/personas.js
//
// DB seed + cleanup helpers for the personas defined in docs/USER_FLOWS.md §0.5.
// Uses Supabase service-role key (loaded from .env). Safe-by-design: only
// touches rows whose email matches isTestEmail() — see test-email.js.

import { createClient } from '@supabase/supabase-js';
import { isTestEmail } from './test-email.js';

function getSupabase() {
  const url = process.env.SUPABASE_URL;
  const key = process.env.SUPABASE_SERVICE_KEY;
  if (!url || !key) {
    throw new Error('SUPABASE_URL / SUPABASE_SERVICE_KEY missing — source .env before running e2e');
  }
  return createClient(url, key);
}

const TIER_DEFAULTS = {
  founding: { runs_used: 0, bonus_runs: 0 },
  hunter: { runs_used: 0, bonus_runs: 0 },
  investor: { runs_used: 0, bonus_runs: 0 },
  operator: { runs_used: 0, bonus_runs: 0 },
};

/**
 * seedUser({ email, tier?, runs_used?, bonus_runs?, agent_name? })
 *
 *   - tier omitted        → free user (no subscription_tier)
 *   - tier 'founding'     → P4 Founding (10/mo)
 *   - tier 'investor'     → P5 Investor (50/mo)
 *   - runs_used override  → e.g. 10 → at-cap, surfaces upgrade modal on next scan
 *   - bonus_runs override → top-up headroom
 */
export async function seedUser({
  email,
  tier = null,
  runs_used = 0,
  bonus_runs = 0,
  agent_name = 'Scout',
}) {
  if (!isTestEmail(email)) {
    throw new Error(`seedUser refused: ${email} is not an e2e- test email`);
  }
  const sb = getSupabase();

  const now = new Date();
  const resetAt = new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth() + 1, 1));

  const payload = {
    email,
    agent_name,
    subscription_tier: tier,
    agent_runs_used: runs_used,
    bonus_runs,
    agent_runs_reset_at: tier ? resetAt.toISOString() : null,
  };

  const { error } = await sb.from('users').upsert(payload, { onConflict: 'email' });
  if (error) throw new Error(`seedUser upsert failed: ${error.message}`);

  return payload;
}

/**
 * deleteUser(email) — wipes user + dependent rows.
 *
 * Order matters because of FKs (deals → search_id, scrape_jobs → search_id, etc.).
 * We blast in dependency order. Skips if not a test email.
 */
export async function deleteUser(email) {
  if (!isTestEmail(email)) {
    console.warn(`deleteUser skipped: ${email} is not an e2e- test email`);
    return;
  }
  const sb = getSupabase();

  // Get search_ids for this user so we can clean dependents
  const { data: searches } = await sb.from('deal_searches').select('id').eq('user_email', email);
  const searchIds = (searches || []).map((s) => s.id);

  if (searchIds.length > 0) {
    await sb.from('scan_progress').delete().in('search_id', searchIds);
    await sb.from('scrape_jobs').delete().in('search_id', searchIds);
    await sb.from('deals').delete().in('search_id', searchIds);
  }

  await sb.from('conversations').delete().eq('user_email', email);
  await sb.from('user_deal_stars').delete().eq('user_email', email);
  await sb.from('user_deal_views').delete().eq('user_email', email);
  await sb.from('user_deal_archives').delete().eq('user_email', email);
  await sb.from('deal_searches').delete().eq('user_email', email);
  await sb.from('users').delete().eq('email', email);
}

/**
 * getUser(email) — returns the user row for assertions.
 */
export async function getUser(email) {
  const sb = getSupabase();
  const { data, error } = await sb.from('users').select('*').eq('email', email).single();
  if (error && error.code !== 'PGRST116') throw error; // PGRST116 = no rows
  return data;
}

/**
 * seedCompletedScan({ email, dealCount? })
 *
 * Inserts a `deal_searches` row with status='complete' plus N fake deals that
 * pass hard filters, so a downstream test can mint a magic link for the user
 * and assert the dashboard claim flow without running the actual worker.
 *
 * Returns: { searchId, dealIds }
 *
 * Safety: refuses non-test emails. Caller should `deleteUser(email)` after.
 */
export async function seedCompletedScan({ email, dealCount = 3 }) {
  if (!isTestEmail(email)) {
    throw new Error(`seedCompletedScan refused: ${email} is not an e2e- test email`);
  }
  const sb = getSupabase();

  // Make sure the user row exists first (FK guard).
  await seedUser({ email });

  const buyBox = {
    asset_type: 'Micro Resort',
    market: 'Blue Ridge Mountains, NC',
    price_min: 500_000,
    price_max: 2_500_000,
  };

  const { data: search, error: searchErr } = await sb
    .from('deal_searches')
    .insert({
      user_email: email,
      buy_box: buyBox,
      status: 'complete',
      test_data: true,
    })
    .select('id')
    .single();
  if (searchErr)
    throw new Error(`seedCompletedScan: deal_searches insert failed: ${searchErr.message}`);

  const searchId = search.id;

  const tiers = ['HOT', 'STRONG', 'WATCH'];
  const dealsPayload = [];
  for (let i = 0; i < dealCount; i++) {
    const tier = tiers[i % tiers.length];
    dealsPayload.push({
      search_id: searchId,
      source: 'test',
      url: `https://example.test/listing/${searchId}/${i}`,
      title: `[E2E] Test Property ${i + 1} — ${tier}`,
      price: 750_000 + i * 100_000,
      acreage: 12 + i,
      rooms_keys: 8 + i,
      location: 'Asheville, NC',
      property_type: 'micro_resort',
      days_on_market: 30 + i * 5,
      passed_hard_filters: true,
      raw_description:
        'Test description for the e2e flow. The dashboard should render this beneath the metrics grid.',
      brief: `One-line agent assessment for test deal ${i + 1}.`,
      score: 80 - i * 5,
      score_breakdown: {
        priority_score: 80 - i * 5,
        strategy: { summary: `Strategy match: ${tier} candidate for the test buy box.` },
        risk: { level: 'MODERATE' },
        tier: tier.toLowerCase(),
      },
      test_data: true,
    });
  }

  const { data: dealsRows, error: dealsErr } = await sb
    .from('deals')
    .insert(dealsPayload)
    .select('id');
  if (dealsErr) throw new Error(`seedCompletedScan: deals insert failed: ${dealsErr.message}`);

  return { searchId, dealIds: (dealsRows || []).map((d) => d.id) };
}

/**
 * seedScanJob({ email, buyBox? })
 *
 * Insert a deal_searches + scrape_jobs row pair so the worker picks it up and
 * runs a real scan + sends the completion email. Bypasses /api/free-scan-start
 * (and therefore its 1-per-IP-per-day rate limit), since Flow A already covers
 * the submit path. Flow B is testing the worker pipeline + email + dashboard.
 *
 * Returns: { searchId }
 *
 * Safety: refuses non-test emails. Caller should deleteUser(email) after.
 */
export async function seedScanJob({ email, buyBox }) {
  if (!isTestEmail(email)) {
    throw new Error(`seedScanJob refused: ${email} is not an e2e- test email`);
  }
  const sb = getSupabase();

  await seedUser({ email });

  const defaultBox = {
    asset_type: 'Micro Resort',
    market: 'Texas',
    price_min: 500_000,
    price_max: 3_000_000,
  };
  const box = buyBox || defaultBox;

  const { data: searchRow, error: searchErr } = await sb
    .from('deal_searches')
    .insert({
      user_email: email,
      buy_box: box,
      status: 'pending',
      test_data: true,
    })
    .select('id')
    .single();
  if (searchErr) throw new Error(`seedScanJob: deal_searches insert failed: ${searchErr.message}`);

  const searchId = searchRow.id;

  const { error: jobErr } = await sb.from('scrape_jobs').insert({
    search_id: searchId,
    buy_box: box,
    status: 'pending',
    source: 'free_scan',
    notify_email: email,
  });
  if (jobErr) {
    await sb.from('deal_searches').delete().eq('id', searchId);
    throw new Error(`seedScanJob: scrape_jobs insert failed: ${jobErr.message}`);
  }

  return { searchId };
}
