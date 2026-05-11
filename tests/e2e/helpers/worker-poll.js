// tests/e2e/helpers/worker-poll.js
//
// Wait for a deal_searches row to flip to a target status. Used by Flow B
// (free-scan pipeline) and Flow G (paid scan) to assert the worker
// actually picked up + completed the job.

import { createClient } from '@supabase/supabase-js';

function getSupabase() {
  const url = process.env.SUPABASE_URL;
  const key = process.env.SUPABASE_SERVICE_KEY;
  if (!url || !key) throw new Error('SUPABASE_URL / SUPABASE_SERVICE_KEY missing');
  return createClient(url, key);
}

/**
 * waitForScanStatus(searchId, targetStatus, { timeoutMs, pollMs })
 *
 *   targetStatus: 'scanning' | 'complete' | 'failed' | array of those
 *   timeoutMs:    default 600_000 (10 min) — scans take real time
 *   pollMs:       default 5_000
 *
 * Returns the deal_searches row when the status matches, throws on timeout.
 */
export async function waitForScanStatus(
  searchId,
  targetStatus,
  { timeoutMs = 600_000, pollMs = 5_000 } = {}
) {
  const targets = Array.isArray(targetStatus) ? targetStatus : [targetStatus];
  const sb = getSupabase();
  const deadline = Date.now() + timeoutMs;

  while (Date.now() < deadline) {
    const { data, error } = await sb
      .from('deal_searches')
      .select('id, status, error_reason, run_at')
      .eq('id', searchId)
      .single();

    if (!error && data && targets.includes(data.status)) return data;

    await new Promise((r) => setTimeout(r, pollMs));
  }

  throw new Error(
    `waitForScanStatus(${searchId}, ${targets.join('|')}): timed out after ${timeoutMs}ms`
  );
}
