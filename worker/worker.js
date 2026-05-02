/**
 * dealhound-worker
 *
 * Polls scrape_jobs every 60s, invokes `claude /find-deals full` for each
 * pending job, and tracks execution in scan_runs.
 *
 * Worker = infrastructure. /find-deals = the agent. Don't conflate them.
 *
 * Env vars loaded automatically from ../.env.local:
 *   SUPABASE_URL           — dealhound-pro Supabase project URL
 *   SUPABASE_SERVICE_KEY   — service role key (needs write access)
 *   ANTHROPIC_API_KEY      — passed through to the claude subprocess
 */

'use strict';

const { createClient } = require('@supabase/supabase-js');
const { spawn } = require('child_process');
const path = require('path');
const fs = require('fs');
const os = require('os');

// Load env from ../.env.local (worker/ lives inside dealhound-pro/)
const envPath = process.env.DOTENV_PATH || path.join(__dirname, '../.env.local');
if (fs.existsSync(envPath) && !process.env.SUPABASE_URL) {
  require('dotenv').config({ path: envPath });
}

// ── Config ────────────────────────────────────────────────────────────────────

const POLL_INTERVAL_MS = 60_000;
const SCAN_TIMEOUT_MS = 30 * 60_000; // 30 min hard cap per scan

// Find claude binary — check common locations across macOS setups
function findClaude() {
  const candidates = [
    process.env.CLAUDE_BIN,
    '/opt/homebrew/bin/claude',
    '/usr/local/bin/claude',
    `${os.homedir()}/.npm-global/bin/claude`,
    `${os.homedir()}/.local/bin/claude`,
  ].filter(Boolean);

  for (const p of candidates) {
    try { fs.accessSync(p, fs.constants.X_OK); return p; } catch (_) {}
  }
  return 'claude'; // fall back to PATH
}

const CLAUDE_BIN = findClaude();

// ── Supabase client ───────────────────────────────────────────────────────────

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_KEY
);

// ── Helpers ───────────────────────────────────────────────────────────────────

function log(msg, data) {
  const ts = new Date().toISOString();
  if (data !== undefined) {
    console.log(`[${ts}] ${msg}`, typeof data === 'object' ? JSON.stringify(data) : data);
  } else {
    console.log(`[${ts}] ${msg}`);
  }
}

async function claimJob(job) {
  const { data, error } = await supabase
    .from('scrape_jobs')
    .update({ status: 'running', picked_up_at: new Date().toISOString() })
    .eq('id', job.id)
    .eq('status', 'pending') // optimistic lock — only claim if still pending
    .select()
    .single();

  if (error || !data) return null;
  return data;
}

async function resolveUserEmail(searchId) {
  if (!searchId) return null;
  const { data } = await supabase
    .from('deal_searches')
    .select('user_email')
    .eq('id', searchId)
    .single();
  return data?.user_email || null;
}

async function createScanRun(job) {
  const userEmail = await resolveUserEmail(job.search_id);
  const { data, error } = await supabase
    .from('scan_runs')
    .insert({
      search_id: job.search_id,
      scrape_job_id: job.id,
      user_email: userEmail,
      trigger: job.trigger || 'on_demand',
      phase: 'full',
      buy_box: job.buy_box,
      status: 'running',
      started_at: new Date().toISOString(),
    })
    .select()
    .single();

  if (error) {
    log('WARN: failed to create scan_run', error.message);
    return null;
  }
  return data;
}

async function finalizeScanRun(runId, { status, error, durationMs, metrics }) {
  if (!runId) return;
  await supabase
    .from('scan_runs')
    .update({
      status,
      error: error || null,
      duration_ms: durationMs,
      completed_at: new Date().toISOString(),
      ...(metrics || {}),
    })
    .eq('id', runId);
}

async function finalizeJob(jobId, status, error) {
  await supabase
    .from('scrape_jobs')
    .update({
      status,
      completed_at: new Date().toISOString(),
      error: error || null,
    })
    .eq('id', jobId);
}

async function updateSearchStatus(searchId, status) {
  if (!searchId) return;
  await supabase
    .from('deal_searches')
    .update({ status })
    .eq('id', searchId);
}

// ── Buy box temp file ─────────────────────────────────────────────────────────

function writeBuyBoxFile(buyBox) {
  const file = path.join(os.tmpdir(), `dealhound-buybox-${Date.now()}.json`);
  fs.writeFileSync(file, JSON.stringify(buyBox, null, 2));
  return file;
}

// ── Job execution ─────────────────────────────────────────────────────────────

function runFindDeals(job) {
  return new Promise((resolve, reject) => {
    const startMs = Date.now();
    let buyBoxFile = null;

    if (job.buy_box) {
      buyBoxFile = writeBuyBoxFile(job.buy_box);
    }

    // Strip ANTHROPIC_API_KEY so the spawned `claude` CLI falls back to the
    // local subscription (Claude Pro/Max) instead of billing the API account.
    // The skill itself doesn't need the key — it only needs the Supabase
    // creds, which we pass through explicitly.
    const { ANTHROPIC_API_KEY: _omit, ...inheritedEnv } = process.env;
    const env = {
      ...inheritedEnv,
      DEALHOUND_SEARCH_ID: job.search_id || '',
      DEALHOUND_SCRAPE_JOB_ID: job.id,
      DEALHOUND_BUY_BOX_FILE: buyBoxFile || '',
      DEALHOUND_BUY_BOX_JSON: JSON.stringify(job.buy_box || {}),
      // The find-deals skill expects SUPABASE_DEALS_URL / SUPABASE_DEALS_ANON_KEY
      // (its naming convention). Alias from our worker-side names so progress
      // events and deal inserts can authenticate. Service key is fine here —
      // the skill needs to bypass RLS to insert deals/progress rows.
      SUPABASE_DEALS_URL: process.env.SUPABASE_DEALS_URL || process.env.SUPABASE_URL || '',
      SUPABASE_DEALS_ANON_KEY: process.env.SUPABASE_DEALS_ANON_KEY || process.env.SUPABASE_SERVICE_KEY || '',
    };

    // Compose the prompt the skill receives. raw_prompt is the truth-of-record
    // for the buy box; the skill's buy-box.md parses it. Fall back to the
    // structured-only invocation if a legacy buy box has no raw_prompt.
    const rawPrompt = (job.buy_box && job.buy_box.raw_prompt) || '';
    const promptArg = rawPrompt
      ? `/find-deals for ${rawPrompt}`
      : '/find-deals full';

    log(`Spawning claude (${CLAUDE_BIN}) for job ${job.id}`, {
      searchId: job.search_id,
      promptArg,
    });

    let metrics = {};
    const proc = spawn(CLAUDE_BIN, ['-p', promptArg], {
      env,
      stdio: ['ignore', 'pipe', 'pipe'],
    });

    proc.stdout.on('data', (chunk) => {
      const text = chunk.toString();
      process.stdout.write(text);
      // Parse structured metrics if the skill emits:
      // DEALHOUND_METRICS: {"sites_discovered":5,"listings_raw":42,"deals_scored":8}
      const m = text.match(/DEALHOUND_METRICS:\s*(\{[^\n]+\})/);
      if (m) { try { metrics = JSON.parse(m[1]); } catch (_) {} }
    });

    proc.stderr.on('data', (chunk) => process.stderr.write(chunk));

    const timeout = setTimeout(() => {
      log(`WARN: job ${job.id} exceeded ${SCAN_TIMEOUT_MS / 60000}m — killing`);
      proc.kill('SIGTERM');
    }, SCAN_TIMEOUT_MS);

    proc.on('close', (code) => {
      clearTimeout(timeout);
      if (buyBoxFile && fs.existsSync(buyBoxFile)) fs.unlinkSync(buyBoxFile);
      const durationMs = Date.now() - startMs;
      if (code === 0) resolve({ durationMs, metrics });
      else reject(new Error(`claude exited with code ${code}`));
    });

    proc.on('error', (err) => {
      clearTimeout(timeout);
      if (buyBoxFile && fs.existsSync(buyBoxFile)) fs.unlinkSync(buyBoxFile);
      reject(err);
    });
  });
}

// ── Core poll loop ────────────────────────────────────────────────────────────

async function processPendingJobs() {
  const { data: jobs, error } = await supabase
    .from('scrape_jobs')
    .select('*')
    .eq('status', 'pending')
    .order('created_at', { ascending: true })
    .limit(1); // one at a time — no parallel token burn

  if (error) { log('ERROR fetching jobs', error.message); return; }
  if (!jobs || jobs.length === 0) return;

  const job = jobs[0];
  log(`Found pending job ${job.id}`, { searchId: job.search_id });

  const claimed = await claimJob(job);
  if (!claimed) { log(`Job ${job.id} already claimed — skipping`); return; }

  const scanRun = await createScanRun(job);
  const runId = scanRun?.id || null;
  const startMs = Date.now();

  try {
    const { durationMs, metrics } = await runFindDeals(job);

    // Silent-zero guard: a clean exit with zero inserted rows is a bug,
    // not a "successful" scan. Mark it as error so we see it.
    let zeroRowError = null;
    if (job.search_id) {
      const { count } = await supabase
        .from('deals')
        .select('*', { count: 'exact', head: true })
        .eq('search_id', job.search_id);
      if (count === 0) {
        zeroRowError = 'Skill completed but wrote zero listings — check buy box format and scraper output';
      }
    }

    if (zeroRowError) {
      log(`WARN: ${zeroRowError}`, { searchId: job.search_id });
      await finalizeScanRun(runId, { status: 'error', durationMs, metrics, error: zeroRowError });
      await finalizeJob(job.id, 'complete');
      await updateSearchStatus(job.search_id, 'error');
    } else {
      await finalizeScanRun(runId, { status: 'complete', durationMs, metrics });
      await finalizeJob(job.id, 'complete');
      await updateSearchStatus(job.search_id, 'complete');
    }
    log(`Job ${job.id} complete in ${(durationMs / 1000).toFixed(1)}s`, metrics);
  } catch (err) {
    const durationMs = Date.now() - startMs;
    log(`ERROR: job ${job.id} failed — ${err.message}`);
    await finalizeScanRun(runId, { status: 'error', error: err.message, durationMs });
    await finalizeJob(job.id, 'error', err.message);
    await updateSearchStatus(job.search_id, 'error');
  }
}

// ── Entry point ───────────────────────────────────────────────────────────────

async function main() {
  const required = ['SUPABASE_URL', 'SUPABASE_SERVICE_KEY'];
  const missing = required.filter((k) => !process.env[k]);
  if (missing.length > 0) {
    console.error(`FATAL: missing env vars: ${missing.join(', ')}`);
    console.error(`Looked for env file at: ${envPath}`);
    process.exit(1);
  }

  log('dealhound-worker started', {
    pollInterval: `${POLL_INTERVAL_MS / 1000}s`,
    claudeBin: CLAUDE_BIN,
    envFile: envPath,
  });

  let inFlight = 0;

  await processPendingJobs();

  setInterval(async () => {
    if (inFlight > 0) return;
    inFlight++;
    try { await processPendingJobs(); }
    catch (err) { log('ERROR in poll loop', err.message); }
    finally { inFlight--; }
  }, POLL_INTERVAL_MS);
}

main().catch((err) => { console.error('FATAL:', err); process.exit(1); });
