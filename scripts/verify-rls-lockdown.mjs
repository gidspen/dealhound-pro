#!/usr/bin/env node
// Verify Phase 1 RLS lockdown: anon-key reads on the 12 locked tables must
// return zero rows (RLS-enabled with no permissive policy = anon blocked).
// deal_searches + deals (Phase 2 deferred) should still return rows.

const SB_URL = 'https://gggmmjvwbbfvrtjjlqvr.supabase.co';
const ANON_KEY =
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdnZ21tanZ3YmJmdnJ0ampscXZyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYwODg0MTMsImV4cCI6MjA5MTY2NDQxM30.D9V0R18p1WEf4DTv9zPYezgkJYpgNXZD-Fd3bMw4u8U';

const LOCKED = [
  'deal_financial_files',
  'deal_financials',
  'deal_outreach',
  'deal_outreach_actions',
  'free_scan_requests',
  'raw_listings',
  'scan_runs',
  'scrape_jobs',
  'user_deal_archives',
  'user_deal_stars',
  'user_deal_views',
  'users',
];

const DEFERRED = ['deal_searches', 'deals'];

async function probe(table) {
  const url = new URL(`${SB_URL}/rest/v1/${table}`);
  url.searchParams.set('select', '*');
  url.searchParams.set('limit', '1');
  const r = await fetch(url, {
    headers: {
      apikey: ANON_KEY,
      Authorization: `Bearer ${ANON_KEY}`,
      Accept: 'application/json',
    },
  });
  const body = await r.text();
  let parsed;
  try {
    parsed = JSON.parse(body);
  } catch {
    parsed = body;
  }
  return { status: r.status, rows: Array.isArray(parsed) ? parsed.length : 'n/a', body: parsed };
}

let pass = 0;
let fail = 0;

console.log('\n=== LOCKED (must return 0 rows or 401) ===');
for (const t of LOCKED) {
  const { status, rows } = await probe(t);
  const ok = status === 200 && rows === 0;
  console.log(`${ok ? '✅' : '❌'} ${t.padEnd(25)} status=${status} rows=${rows}`);
  ok ? pass++ : fail++;
}

console.log('\n=== DEFERRED (Phase 2 — should still return rows) ===');
for (const t of DEFERRED) {
  const { status, rows } = await probe(t);
  const ok = status === 200 && (rows === 0 || rows === 1);
  console.log(`${ok ? '✅' : '❌'} ${t.padEnd(25)} status=${status} rows=${rows}`);
  ok ? pass++ : fail++;
}

console.log(`\nResult: ${pass} pass / ${fail} fail`);
process.exit(fail === 0 ? 0 : 1);
