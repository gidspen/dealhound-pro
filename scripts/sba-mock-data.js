'use strict';

/**
 * sba-mock-data.js
 *
 * Seeds Supabase with the 20 mock TX dental practice leads from
 * tests/fixtures/sba-mock-leads.json.
 *
 * Usage:
 *   node scripts/sba-mock-data.js --user-id <uuid>
 *
 * Falls back to results/sba-mock-output.json if Supabase insert fails.
 */

const path = require('path');
const fs = require('fs');

// ---------------------------------------------------------------------------
// Parse args
// ---------------------------------------------------------------------------
const args = process.argv.slice(2);
const userIdIdx = args.indexOf('--user-id');
if (userIdIdx === -1 || !args[userIdIdx + 1]) {
  console.error('Usage: node scripts/sba-mock-data.js --user-id <uuid>');
  process.exit(1);
}
const USER_ID = args[userIdIdx + 1];

// ---------------------------------------------------------------------------
// Load fixture
// ---------------------------------------------------------------------------
const FIXTURE_PATH = path.resolve(
  __dirname,
  '../tests/fixtures/sba-mock-leads.json',
);

if (!fs.existsSync(FIXTURE_PATH)) {
  console.error(`Fixture not found: ${FIXTURE_PATH}`);
  process.exit(1);
}

const leads = JSON.parse(fs.readFileSync(FIXTURE_PATH, 'utf-8'));

// ---------------------------------------------------------------------------
// Supabase client (optional — only initialised when env vars are present)
// ---------------------------------------------------------------------------
function buildSupabaseClient() {
  const url = process.env.SUPABASE_URL || process.env.VITE_SUPABASE_URL;
  const key =
    process.env.SUPABASE_SERVICE_ROLE_KEY ||
    process.env.SUPABASE_ANON_KEY ||
    process.env.VITE_SUPABASE_ANON_KEY;

  if (!url || !key) {
    return null;
  }

  try {
    const { createClient } = require('@supabase/supabase-js');
    return createClient(url, key);
  } catch (err) {
    console.warn('Could not initialise Supabase client:', err.message);
    return null;
  }
}

// ---------------------------------------------------------------------------
// Fallback: write to results/sba-mock-output.json
// ---------------------------------------------------------------------------
function writeFallback(scanId, enrichedLeads, reason) {
  const resultsDir = path.resolve(__dirname, '../results');
  if (!fs.existsSync(resultsDir)) {
    fs.mkdirSync(resultsDir, { recursive: true });
  }

  const outPath = path.join(resultsDir, 'sba-mock-output.json');
  const output = {
    fallback_reason: reason,
    scan: {
      id: scanId,
      user_id: USER_ID,
      vertical: 'dental',
      state: 'TX',
      target_lead_count: enrichedLeads.length,
      status: 'complete',
      deal_count: enrichedLeads.filter((l) =>
        ['HOT', 'STRONG'].includes(l.retirement_tier),
      ).length,
      created_at: new Date().toISOString(),
    },
    leads: enrichedLeads,
  };

  fs.writeFileSync(outPath, JSON.stringify(output, null, 2), 'utf-8');
  console.log(`Fallback written to: ${outPath}`);
}

// ---------------------------------------------------------------------------
// Summary helper
// ---------------------------------------------------------------------------
function logSummary(enrichedLeads) {
  const counts = { HOT: 0, STRONG: 0, WATCH: 0, DISCARD: 0 };
  for (const lead of enrichedLeads) {
    counts[lead.retirement_tier] = (counts[lead.retirement_tier] || 0) + 1;
  }
  console.log(
    `Inserted ${enrichedLeads.length} leads ` +
      `(${counts.HOT} HOT, ${counts.STRONG} STRONG, ${counts.WATCH} WATCH, ${counts.DISCARD} DISCARD)`,
  );
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------
async function main() {
  const scanId = `scan-mock-${Date.now()}`;
  const now = new Date().toISOString();

  // Attach scan_id and user_id to each lead
  const enrichedLeads = leads.map((lead) => ({
    ...lead,
    scan_id: scanId,
    user_id: USER_ID,
  }));

  const supabase = buildSupabaseClient();

  if (!supabase) {
    console.warn(
      'No Supabase credentials found (SUPABASE_URL / SUPABASE_SERVICE_ROLE_KEY). ' +
        'Writing to fallback file.',
    );
    writeFallback(scanId, enrichedLeads, 'no_credentials');
    logSummary(enrichedLeads);
    return;
  }

  // ------------------------------------------------------------------
  // 1. Create sba_scans row
  // ------------------------------------------------------------------
  const scanRow = {
    id: scanId,
    user_id: USER_ID,
    vertical: 'dental',
    state: 'TX',
    target_lead_count: enrichedLeads.length,
    status: 'complete',
    deal_count: enrichedLeads.filter((l) =>
      ['HOT', 'STRONG'].includes(l.retirement_tier),
    ).length,
    created_at: now,
    updated_at: now,
  };

  const { error: scanError } = await supabase
    .from('sba_scans')
    .insert(scanRow);

  if (scanError) {
    const reason = `sba_scans insert failed: ${scanError.message} (code: ${scanError.code})`;
    console.error(reason);
    console.warn('Falling back to local JSON output.');
    writeFallback(scanId, enrichedLeads, reason);
    logSummary(enrichedLeads);
    return;
  }

  console.log(`Created sba_scans row: ${scanId}`);

  // ------------------------------------------------------------------
  // 2. Insert leads in batches of 10 to avoid payload limits
  // ------------------------------------------------------------------
  const BATCH_SIZE = 10;
  let insertedCount = 0;

  for (let i = 0; i < enrichedLeads.length; i += BATCH_SIZE) {
    const batch = enrichedLeads.slice(i, i + BATCH_SIZE);

    const { error: leadsError } = await supabase
      .from('sba_leads')
      .insert(batch);

    if (leadsError) {
      const reason = `sba_leads insert failed at batch ${Math.floor(i / BATCH_SIZE) + 1}: ${leadsError.message} (code: ${leadsError.code})`;
      console.error(reason);
      console.warn(
        `Inserted ${insertedCount} leads before failure. Falling back to local JSON.`,
      );
      writeFallback(scanId, enrichedLeads, reason);
      logSummary(enrichedLeads);
      return;
    }

    insertedCount += batch.length;
    console.log(
      `  Batch ${Math.floor(i / BATCH_SIZE) + 1}: inserted ${batch.length} leads (${insertedCount}/${enrichedLeads.length} total)`,
    );
  }

  // ------------------------------------------------------------------
  // 3. Summary
  // ------------------------------------------------------------------
  logSummary(enrichedLeads);
}

main().catch((err) => {
  console.error('Unexpected error:', err);
  process.exit(1);
});
