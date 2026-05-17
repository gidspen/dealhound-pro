#!/usr/bin/env node
/**
 * worker/group-scan-runner.js
 *
 * Single-shot group scan: reads all active buy boxes, runs /find-deals full
 * per overdue user (one Claude subprocess each, headed PTY), then sends
 * Resend notification email per user.
 *
 * ARCHITECTURE DECISION — "full per user" (not "scrape-once, score-per-user")
 * ─────────────────────────────────────────────────────────────────────────────
 * The find-deals skill currently only exposes `/find-deals full` — there is no
 * `/find-deals scrape` (Phase 1–2 only) or `/find-deals score` (Phase 3+ only)
 * subcommand. Splitting scrape from scoring would require modifying the skill
 * to write raw-listing files to a shared location and then accept them as input
 * in a second invocation. That refactor is deferred to a future iteration.
 *
 * For v1, each overdue buy box gets a full `/find-deals full` run with its own
 * criteria. This is correct and safe — it does slightly more scraping than the
 * ideal group-scrape model, but avoids over-engineering before the skill gains
 * the split-phase subcommands. COGS attribution per user is preserved because
 * each claude subprocess is independent. Mark this FUTURE: group-scrape
 * optimization once `/find-deals scrape` + `/find-deals score` exist.
 *
 * SETUP
 * ─────
 * Install LaunchAgent (runs every hour):
 *   cp worker/com.dealhound.group-scan.plist ~/Library/LaunchAgents/
 *   launchctl load ~/Library/LaunchAgents/com.dealhound.group-scan.plist
 *
 * Run manually (one-shot):
 *   node worker/group-scan-runner.js
 *
 * Dry run (no Claude, no DB writes):
 *   DEALHOUND_DRY_RUN=true node worker/group-scan-runner.js
 *
 * Uninstall LaunchAgent:
 *   launchctl unload ~/Library/LaunchAgents/com.dealhound.group-scan.plist
 *
 * NOTES
 * ─────
 * - ANTHROPIC_API_KEY is intentionally stripped from the claude subprocess env
 *   (inherited from worker.js pattern) so it uses Claude Pro subscription.
 * - trigger column on scrape_jobs only accepts 'on_demand' | 'daily' —
 *   do not use 'scheduled'.
 * - Serial execution (not parallel) to avoid overloading Claude and hitting
 *   LandSearch rate limits. Future: limited concurrency with p-limit.
 */

'use strict';

const { createClient } = require('@supabase/supabase-js');
const path = require('path');
const fs = require('fs');
const os = require('os');

// ── Env loading ───────────────────────────────────────────────────────────────
// Try .env first (LaunchAgent sources it via EnvironmentVariables), then
// fall back to .env.local for local dev.
const envPaths = [
  process.env.DOTENV_PATH,
  path.join(__dirname, '../.env'),
  path.join(__dirname, '../.env.local'),
].filter(Boolean);

for (const envPath of envPaths) {
  if (fs.existsSync(envPath) && !process.env.SUPABASE_URL) {
    require('dotenv').config({ path: envPath });
  }
}

// ── Helpers & modules ─────────────────────────────────────────────────────────
const { buildUnionAndPerUser } = require('./union-buy-box');
const { TIER_SCAN_INTERVAL_MS } = require('../api/_lib/buy-box-limits');
const { runFindDealsHeaded } = require('./pty-runner');
const { checkAndReserveMonthlyBudget, recordComputeUsed } = require('./cost-guardrails');
const { sendScheduledScanCompleteEmail } = require('./email-sender');

// ── Config ────────────────────────────────────────────────────────────────────
const DRY_RUN = process.env.DEALHOUND_DRY_RUN === 'true';
const SCAN_TIMEOUT_MS = 90 * 60_000; // 90 min hard cap per scan
const DEFAULT_INTERVAL_MS = 24 * 60 * 60 * 1000; // 24h fallback for unknown tiers
const APP_URL = process.env.APP_URL || 'https://dealhound.pro';

// ── Logging ───────────────────────────────────────────────────────────────────
const LOG_DIR = path.join(__dirname, 'logs');
const LOG_FILE = path.join(LOG_DIR, 'group-scan-runner.log');

if (!fs.existsSync(LOG_DIR)) fs.mkdirSync(LOG_DIR, { recursive: true });

const logStream = fs.createWriteStream(LOG_FILE, { flags: 'a' });

function log(msg, data) {
  const ts = new Date().toISOString();
  const line =
    data !== undefined
      ? `[${ts}] ${msg} ${typeof data === 'object' ? JSON.stringify(data) : data}`
      : `[${ts}] ${msg}`;
  console.log(line);
  logStream.write(line + '\n');
}

// ── Claude binary resolution ──────────────────────────────────────────────────
function findClaude() {
  const candidates = [
    process.env.CLAUDE_BIN,
    '/opt/homebrew/bin/claude',
    '/usr/local/bin/claude',
    `${os.homedir()}/.npm-global/bin/claude`,
    `${os.homedir()}/.local/bin/claude`,
  ].filter(Boolean);
  for (const p of candidates) {
    try {
      fs.accessSync(p, fs.constants.X_OK);
      return p;
    } catch (_) {}
  }
  return 'claude';
}

const CLAUDE_BIN = findClaude();

// ── Supabase client ───────────────────────────────────────────────────────────
function createSupabase() {
  const url = process.env.SUPABASE_URL || process.env.SUPABASE_DEALS_URL;
  const key = process.env.SUPABASE_SERVICE_KEY || process.env.SUPABASE_DEALS_ANON_KEY;
  if (!url || !key) {
    throw new Error('group-scan-runner: SUPABASE_URL and SUPABASE_SERVICE_KEY are required');
  }
  return createClient(url, key);
}

// ── Per-tier overdue detection ────────────────────────────────────────────────
/**
 * Returns the list of buy-box records that are past their scan interval.
 * Fetches user subscription_tier from the users table (same pattern as
 * buy-box-scheduler.js).
 *
 * @param {import('@supabase/supabase-js').SupabaseClient} supabase
 * @param {Array<{ buy_box_id: string, user_email: string, criteria: object }>} perUserBoxes
 * @returns {Promise<Array<{ buy_box_id, user_email, criteria, last_scanned_at }>>}
 */
async function filterOverdueBoxes(supabase, perUserBoxes) {
  // Fetch last_scanned_at for each box (not returned by buildUnionAndPerUser)
  const ids = perUserBoxes.map((b) => b.buy_box_id);
  const { data: boxes, error: boxesError } = await supabase
    .from('buy_boxes')
    .select('id, last_scanned_at')
    .in('id', ids);

  if (boxesError) {
    throw new Error(
      `group-scan-runner: failed to fetch buy_boxes timestamps — ${boxesError.message}`
    );
  }

  const lastScannedById = {};
  for (const b of boxes || []) {
    lastScannedById[b.id] = b.last_scanned_at;
  }

  // Fetch subscription tiers
  const emails = [...new Set(perUserBoxes.map((b) => b.user_email))];
  const { data: users, error: usersError } = await supabase
    .from('users')
    .select('email, subscription_tier')
    .in('email', emails);

  if (usersError) {
    throw new Error(`group-scan-runner: failed to fetch users — ${usersError.message}`);
  }

  const tierByEmail = {};
  for (const u of users || []) {
    tierByEmail[u.email] = (u.subscription_tier || 'hunter').toLowerCase();
  }

  const now = new Date();
  return perUserBoxes.filter((box) => {
    const tier = tierByEmail[box.user_email] || 'hunter';
    const intervalMs = TIER_SCAN_INTERVAL_MS[tier] ?? DEFAULT_INTERVAL_MS;
    const rawTs = lastScannedById[box.buy_box_id];
    const lastScanned = rawTs ? new Date(rawTs) : null;
    const isOverdue = !lastScanned || now - lastScanned >= intervalMs;
    return isOverdue;
  });
}

// ── deal_searches row creation ────────────────────────────────────────────────
/**
 * Inserts a deal_searches row + scrape_jobs row for one overdue buy box.
 * Returns { search_id, scrape_job_id } or throws on failure.
 */
async function createSearchAndJob(supabase, box) {
  const now = new Date().toISOString();

  const { data: search, error: searchError } = await supabase
    .from('deal_searches')
    .insert({
      user_email: box.user_email,
      buy_box: box.criteria,
      buy_box_id: box.buy_box_id,
      status: 'queued',
      run_at: now,
    })
    .select('id')
    .single();

  if (searchError) {
    throw new Error(
      `deal_searches insert failed for box ${box.buy_box_id}: ${searchError.message}`
    );
  }

  const { data: job, error: jobError } = await supabase
    .from('scrape_jobs')
    .insert({
      search_id: search.id,
      buy_box: box.criteria,
      status: 'pending',
      trigger: 'on_demand', // 'scheduled' not in check constraint
    })
    .select('id')
    .single();

  if (jobError) {
    // Best-effort cleanup of orphaned deal_searches row
    await supabase
      .from('deal_searches')
      .delete()
      .eq('id', search.id)
      .then(() => {});
    throw new Error(`scrape_jobs insert failed for box ${box.buy_box_id}: ${jobError.message}`);
  }

  return { search_id: search.id, scrape_job_id: job.id };
}

// ── Buy box temp file ─────────────────────────────────────────────────────────
function writeBuyBoxTmpfile(buyBox) {
  const file = path.join(
    os.tmpdir(),
    `dealhound-group-${Date.now()}-${Math.random().toString(36).slice(2)}.json`
  );
  fs.writeFileSync(file, JSON.stringify(buyBox, null, 2));
  return file;
}

// ── Spawn config (mirrors worker.js composeSpawnConfig) ───────────────────────
function composeSpawnEnv(searchId, scrapeJobId, buyBoxFilePath) {
  // Strip ANTHROPIC_API_KEY — forces Claude to use Pro subscription, not API billing
  const { ANTHROPIC_API_KEY: _omit, ...inheritedEnv } = process.env;
  return {
    ...inheritedEnv,
    DEALHOUND_SEARCH_ID: searchId || '',
    DEALHOUND_SCRAPE_JOB_ID: scrapeJobId || '',
    DEALHOUND_BUY_BOX_FILE: buyBoxFilePath || '',
    // Alias SUPABASE_URL/SERVICE_KEY → SUPABASE_DEALS_* (find-deals skill naming)
    SUPABASE_DEALS_URL: process.env.SUPABASE_DEALS_URL || process.env.SUPABASE_URL || '',
    SUPABASE_DEALS_ANON_KEY:
      process.env.SUPABASE_DEALS_ANON_KEY || process.env.SUPABASE_SERVICE_KEY || '',
  };
}

// ── Post-scan status updates ──────────────────────────────────────────────────
async function finalizeSearch(supabase, searchId, status) {
  await supabase
    .from('deal_searches')
    .update({ status })
    .eq('id', searchId)
    .then(() => {});
}

async function finalizeJob(supabase, jobId, status, errorMsg) {
  await supabase
    .from('scrape_jobs')
    .update({ status, completed_at: new Date().toISOString(), error: errorMsg || null })
    .eq('id', jobId)
    .then(() => {});
}

async function markBuyBoxScanned(supabase, buyBoxId) {
  await supabase
    .from('buy_boxes')
    .update({ last_scanned_at: new Date().toISOString() })
    .eq('id', buyBoxId)
    .then(() => {});
}

// ── Per-user agent name resolution ───────────────────────────────────────────
const AGENT_NAMES = [
  'Scout',
  'Nora',
  'Kit',
  'Stella',
  'Sophie',
  'Quinn',
  'Wren',
  'Ellis',
  'Reid',
  'Sloane',
  'Harper',
  'Hunter',
];

async function resolveAgentName(supabase, userEmail) {
  try {
    const { data } = await supabase
      .from('users')
      .select('agent_name')
      .eq('email', userEmail)
      .single();
    if (data?.agent_name) return data.agent_name;
  } catch (_) {}
  return AGENT_NAMES[Math.floor(Math.random() * AGENT_NAMES.length)];
}

// ── Per-user deal count ───────────────────────────────────────────────────────
async function countDealsForSearch(supabase, searchId) {
  try {
    const { count } = await supabase
      .from('deals')
      .select('*', { count: 'exact', head: true })
      .eq('search_id', searchId)
      .eq('passed_hard_filters', true);
    return count || 0;
  } catch (_) {
    return 0;
  }
}

// ── Main ──────────────────────────────────────────────────────────────────────

async function main() {
  log(`[group-scan] Starting${DRY_RUN ? ' (DRY RUN — no Claude, no DB writes)' : ''}`);

  // ── Validate env ─────────────────────────────────────────────────────────
  const requiredEnv = ['SUPABASE_URL', 'SUPABASE_SERVICE_KEY'];
  const missingEnv = requiredEnv.filter(
    (k) => !process.env[k] && !process.env[k.replace('SUPABASE_URL', 'SUPABASE_DEALS_URL')]
  );
  if (missingEnv.length > 0 && !DRY_RUN) {
    log(`FATAL: missing required env vars: ${missingEnv.join(', ')}`);
    process.exit(1);
  }

  const supabase = DRY_RUN ? null : createSupabase();

  // ── 1. Build union + per-user buy boxes ───────────────────────────────────
  let perUserBoxes = [];

  if (DRY_RUN) {
    log(
      '[group-scan] DRY RUN: skipping Supabase query — would fetch buy_boxes WHERE status=active'
    );
    log('[group-scan] DRY RUN: would build union buy box and per-user criteria list');
    log('[group-scan] DRY RUN: would filter to overdue boxes by tier interval');
    log(
      '[group-scan] DRY RUN: would spawn one `claude --dangerously-skip-permissions` per overdue box'
    );
    log('[group-scan] DRY RUN: would insert deal_searches + scrape_jobs rows per box');
    log('[group-scan] DRY RUN: would send Resend notification email per user');
    log('[group-scan] DRY RUN: would update buy_boxes.last_scanned_at per box');
    log('[group-scan] DRY RUN complete — no side effects');
    return;
  }

  const { unionBuyBox, perUserBoxes: allBoxes } = await buildUnionAndPerUser(supabase);
  log(
    `[group-scan] Found ${allBoxes.length} active buy box(es) across ${new Set(allBoxes.map((b) => b.user_email)).size} user(s)`
  );

  if (allBoxes.length === 0) {
    log('[group-scan] No active buy boxes — nothing to do');
    return;
  }

  // ── 2. Filter to overdue boxes ────────────────────────────────────────────
  perUserBoxes = await filterOverdueBoxes(supabase, allBoxes);
  log(`[group-scan] Overdue: ${perUserBoxes.length} / ${allBoxes.length} box(es)`);

  if (perUserBoxes.length === 0) {
    log('[group-scan] No overdue buy boxes — nothing to do');
    return;
  }

  // Log union buy box summary (for monitoring)
  log('[group-scan] Union buy box', {
    price: `$${(unionBuyBox.price_min / 1000).toFixed(0)}k–$${(unionBuyBox.price_max / 1000).toFixed(0)}k`,
    states: unionBuyBox.states.length > 0 ? unionBuyBox.states.join(', ') : '(any)',
    types: unionBuyBox.property_types.length > 0 ? unionBuyBox.property_types.join(', ') : '(any)',
  });

  // ── 3. Per-user: create rows, run scan, notify ────────────────────────────
  let successCount = 0;
  let errorCount = 0;

  for (const box of perUserBoxes) {
    log(`[group-scan] Processing box ${box.buy_box_id} for ${box.user_email}`);

    // COGS budget check
    const budget = await checkAndReserveMonthlyBudget(box.user_email, supabase);
    if (!budget.allowed) {
      log(`[COGS] Monthly cap hit for ${box.user_email} — skipping`, { reason: budget.reason });
      errorCount++;
      continue;
    }

    // Create deal_searches + scrape_jobs rows
    let searchId, scrapeJobId;
    try {
      const result = await createSearchAndJob(supabase, box);
      searchId = result.search_id;
      scrapeJobId = result.scrape_job_id;
      log(`[group-scan] Created search ${searchId} / job ${scrapeJobId} for ${box.user_email}`);
    } catch (err) {
      log(`ERROR: could not create rows for box ${box.buy_box_id}: ${err.message}`);
      errorCount++;
      continue;
    }

    // Write buy box to tmpfile
    let buyBoxFile = null;
    try {
      buyBoxFile = writeBuyBoxTmpfile(box.criteria);
      const env = composeSpawnEnv(searchId, scrapeJobId, buyBoxFile);

      // Mark job as running
      await supabase
        .from('scrape_jobs')
        .update({ status: 'running', picked_up_at: new Date().toISOString() })
        .eq('id', scrapeJobId)
        .then(() => {});
      await finalizeSearch(supabase, searchId, 'running');

      // ── Spawn headed claude ───────────────────────────────────────────────
      // ARCHITECTURE NOTE: we call /find-deals full per user (not a group-scrape
      // optimization) because the skill has no split-phase subcommands yet.
      // See header comment for the full decision rationale.
      log(`[group-scan] Spawning headed claude for ${box.user_email} (job ${scrapeJobId})`);

      const { durationMs, cogsUsed, cappedByCost } = await runFindDealsHeaded({
        claudeBin: CLAUDE_BIN,
        env,
        jobId: scrapeJobId,
        skill: 'deal scan',
        timeout: SCAN_TIMEOUT_MS,
      });

      // Record compute used (COGS attribution per user)
      await recordComputeUsed(box.user_email, cogsUsed, supabase);
      log(`[COGS] $${cogsUsed.toFixed(4)} for ${box.user_email}`, { job: scrapeJobId });

      // Finalize rows
      const finalStatus = cappedByCost ? 'complete' : 'complete';
      await finalizeJob(supabase, scrapeJobId, finalStatus);
      await finalizeSearch(supabase, searchId, 'complete');
      await markBuyBoxScanned(supabase, box.buy_box_id);

      log(
        `[group-scan] Scan complete for ${box.user_email} in ${(durationMs / 1000).toFixed(1)}s`,
        {
          cappedByCost,
        }
      );

      // ── Send notification email ───────────────────────────────────────────
      const agentName = await resolveAgentName(supabase, box.user_email);
      const dealCount = await countDealsForSearch(supabase, searchId);
      const dashboardUrl = `${APP_URL}/dashboard`;

      const emailResult = await sendScheduledScanCompleteEmail({
        to: box.user_email,
        agentName,
        dealCount,
        dashboardUrl,
      });

      log(`[email] result for ${box.user_email}`, {
        ok: emailResult.ok,
        dealCount,
        messageId: emailResult.messageId || null,
        skipped: emailResult.skipped || false,
      });

      successCount++;
    } catch (err) {
      log(`ERROR: scan failed for ${box.user_email} / job ${scrapeJobId}: ${err.message}`);
      if (scrapeJobId) await finalizeJob(supabase, scrapeJobId, 'error', err.message);
      if (searchId) await finalizeSearch(supabase, searchId, 'error');
      errorCount++;
    } finally {
      if (buyBoxFile && fs.existsSync(buyBoxFile)) {
        try {
          fs.unlinkSync(buyBoxFile);
        } catch (_) {}
      }
    }
  }

  log(`[group-scan] Complete — ${successCount} succeeded, ${errorCount} failed`, {
    total: perUserBoxes.length,
  });
}

main().catch((err) => {
  log(`FATAL: ${err.message}`, { stack: err.stack });
  process.exit(1);
});
