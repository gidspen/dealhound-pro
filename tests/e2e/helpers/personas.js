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
