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
 *
 * Cost guardrails (see cost-guardrails.js for full spec):
 *   FORCE_COGS_OVERRUN=true  — treat every token event as $5 to test cap logic
 */

'use strict';

const { createClient } = require('@supabase/supabase-js');
const { spawn } = require('child_process');
const path = require('path');
const fs = require('fs');
const os = require('os');
const {
  CostTracker,
  checkAndReserveMonthlyBudget,
  recordComputeUsed,
  RUN_CAPPED_MESSAGE,
} = require('./cost-guardrails');

// Load env from ../.env.local (worker/ lives inside dealhound-pro/)
const envPath = process.env.DOTENV_PATH || path.join(__dirname, '../.env.local');
if (fs.existsSync(envPath) && !process.env.SUPABASE_URL) {
  require('dotenv').config({ path: envPath });
}

// ── Config ────────────────────────────────────────────────────────────────────

const POLL_INTERVAL_MS = 60_000;
const SCAN_TIMEOUT_MS = 90 * 60_000; // 90 min hard cap per scan

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

// ── Spawn config (pure function — testable) ──────────────────────────────────

// Compose the args + env passed to `claude` for a given job. Pure: takes the
// caller's processEnv and a job, returns spawn config. Behavior locked in by
// tests/integration/worker-contract.test.js — read that file before changing
// anything here. The promptArg, env stripping, and SUPABASE alias are each
// load-bearing fixes for bugs we hit in production.
function composeSpawnConfig(job, processEnv, buyBoxFilePath) {
  // Strip ANTHROPIC_API_KEY so the spawned `claude` CLI falls back to the
  // local subscription (Claude Pro/Max) instead of billing the API account.
  const { ANTHROPIC_API_KEY: _omit, ...inheritedEnv } = processEnv;
  const env = {
    ...inheritedEnv,
    DEALHOUND_SEARCH_ID: job.search_id || '',
    DEALHOUND_SCRAPE_JOB_ID: job.id,
    DEALHOUND_BUY_BOX_FILE: buyBoxFilePath || '',
    DEALHOUND_BUY_BOX_JSON: JSON.stringify(job.buy_box || {}),
    // The find-deals skill expects SUPABASE_DEALS_URL / SUPABASE_DEALS_ANON_KEY
    // (its naming convention). Alias from our worker-side names so progress
    // events and deal inserts can authenticate. Service key is fine here —
    // the skill needs to bypass RLS to insert deals/progress rows.
    SUPABASE_DEALS_URL: processEnv.SUPABASE_DEALS_URL || processEnv.SUPABASE_URL || '',
    SUPABASE_DEALS_ANON_KEY: processEnv.SUPABASE_DEALS_ANON_KEY || processEnv.SUPABASE_SERVICE_KEY || '',
  };

  // Always invoke the documented `/find-deals full` subcommand. The buy box
  // is loaded by the skill from DEALHOUND_BUY_BOX_FILE. Using a non-standard
  // prompt like `/find-deals for [text]` causes Claude to improvise a flow
  // that skips Step 1c (Supabase persistence) — proven empirically 2026-05-02
  // when raw_prompt-style invocations produced 0 deals.
  //
  // --dangerously-skip-permissions is load-bearing: without it, the spawned
  // claude in -p mode never surfaces MCP browser tools, so the skill's
  // Phase 2B (Playwright scrapes of NAI OHB, RV Park Store, etc.) silently
  // degrades to landsearch-only. Proven empirically 2026-05-05 via
  // worker/diagnose.js. Safe here because the worker runs as a daemon on
  // Gideon's Mac with a fixture supabase-scoped writeset — no shell, no
  // human in the loop, no untrusted prompts.
  const args = ['-p', '/find-deals full', '--dangerously-skip-permissions'];

  return { args, env };
}

// In-flight guard for the polling loop. Caps concurrency at 1 — prevents the
// next setInterval tick from spawning a second `claude` while the first is
// still running. Without this we'd burn 2x tokens and trigger LandSearch
// rate limits. Behavior locked in by tests/integration/worker-contract.test.js.
function createInFlightGuard() {
  let count = 0;
  return {
    async tryRun(fn) {
      if (count > 0) return false;
      count++;
      try { await fn(); return true; }
      finally { count--; }
    },
    inFlight() { return count; },
  };
}

// ── Job execution ─────────────────────────────────────────────────────────────

/**
 * runFindDeals — spawns `claude -p /find-deals full` and tracks cost.
 *
 * Returns { durationMs, metrics, cogsUsed } on clean exit or COGS cap.
 * Rejects on process error or hard timeout.
 *
 * COGS cap path:
 *   - The skill emits DEALHOUND_TOKENS: {"input_tokens":N,"output_tokens":N}
 *   - CostTracker accumulates cost per token event
 *   - When accumulated cost >= skill cap, proc is SIGTERM'd and the promise
 *     resolves (not rejects) with { cappedByCost: true } so the caller can
 *     record a partial result with RUN_CAPPED_MESSAGE rather than an error
 *
 * FORCE_COGS_OVERRUN=true:
 *   - Every token event registers as $5.00 cost
 *   - Cap fires on the first DEALHOUND_TOKENS line
 *   - Use to verify cap logic without a real expensive scan
 */
function runFindDeals(job, skill = 'deal scan') {
  return new Promise((resolve, reject) => {
    const startMs = Date.now();
    let buyBoxFile = null;

    if (job.buy_box) {
      buyBoxFile = writeBuyBoxFile(job.buy_box);
    }

    const { args, env } = composeSpawnConfig(job, process.env, buyBoxFile);

    log(`Spawning claude (${CLAUDE_BIN}) for job ${job.id}`, {
      searchId: job.search_id,
      promptArg: args[1],
      skill,
    });

    let metrics = {};
    let lastPhase = null;
    const phaseTimestamps = {};
    let cappedByCost = false;

    // COGS tracker for this run
    const costTracker = new CostTracker(skill);
    if (process.env.FORCE_COGS_OVERRUN === 'true') {
      log(`[COGS] FORCE_COGS_OVERRUN=true — every token event will register $5.00`);
    }

    const proc = spawn(CLAUDE_BIN, args, {
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

      // Parse phase transitions if the skill emits: DEALHOUND_PHASE: phase1
      const p = text.match(/DEALHOUND_PHASE:\s*(\S+)/);
      if (p) {
        const phase = p[1];
        if (phase !== lastPhase) {
          const elapsedMin = ((Date.now() - startMs) / 60000).toFixed(1);
          log(`[PHASE] ${phase}`, { elapsed: `${elapsedMin}m`, job: job.id });
          phaseTimestamps[phase] = Date.now();
          lastPhase = phase;
        }
      }

      // ── COGS tracking ─────────────────────────────────────────────────────
      // The skill emits: DEALHOUND_TOKENS: {"input_tokens":N,"output_tokens":N}
      // CostTracker parses and accumulates. Kill proc if cap exceeded.
      const { capped, totalCost, capAmount } = costTracker.trackTokenLine(text);
      if (capped && !cappedByCost) {
        cappedByCost = true;
        log(`[COGS] Run cap hit — $${totalCost.toFixed(4)} >= $${capAmount} for skill "${skill}" — terminating`, {
          job: job.id,
        });
        proc.kill('SIGTERM');
      }
    });

    proc.stderr.on('data', (chunk) => process.stderr.write(chunk));

    const timeout = setTimeout(() => {
      log(`WARN: job ${job.id} exceeded ${SCAN_TIMEOUT_MS / 60000}m — killing`);
      proc.kill('SIGTERM');
    }, SCAN_TIMEOUT_MS);

    // Log elapsed time every 5 min so we know where the scan is in long runs.
    const heartbeat = setInterval(() => {
      const elapsedMin = ((Date.now() - startMs) / 60000).toFixed(1);
      log(`[HEARTBEAT] job ${job.id} still running`, {
        elapsed: `${elapsedMin}m`,
        phase: lastPhase || 'unknown',
        cogsAccrued: `$${costTracker.total.toFixed(4)}`,
      });
    }, 5 * 60_000);

    function cleanup(code) {
      clearTimeout(timeout);
      clearInterval(heartbeat);
      if (buyBoxFile && fs.existsSync(buyBoxFile)) fs.unlinkSync(buyBoxFile);
      const durationMs = Date.now() - startMs;
      if (Object.keys(phaseTimestamps).length > 0) {
        const phaseSummary = Object.entries(phaseTimestamps).map(([phase, ts]) => ({
          phase,
          startedAtMin: ((ts - startMs) / 60000).toFixed(1),
        }));
        log(`[TIMING] job ${job.id}`, {
          totalMin: (durationMs / 60000).toFixed(1),
          phases: phaseSummary,
        });
      }
      return durationMs;
    }

    proc.on('close', (code, signal) => {
      const durationMs = cleanup(code);
      const cogsUsed = costTracker.total;

      if (cappedByCost) {
        // Resolve (not reject) — partial result, not a hard failure
        log(`[COGS] Run ended by cost cap`, { job: job.id, cogsUsed: `$${cogsUsed.toFixed(4)}` });
        resolve({ durationMs, metrics, cogsUsed, cappedByCost: true });
        return;
      }

      if (code === 0) {
        resolve({ durationMs, metrics, cogsUsed, cappedByCost: false });
      } else {
        // On macOS, SIGTERM may deliver null code + 'SIGTERM' signal rather than code 143
        const isTimeout = code === 143 || signal === 'SIGTERM';
        const msg = isTimeout
          ? `Scan timed out after ${(durationMs / 60000).toFixed(0)}m`
          : `claude exited with code ${code}`;
        reject(new Error(msg));
      }
    });

    proc.on('error', (err) => {
      cleanup(null);
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

  // ── Resolve user email for budget checks ───────────────────────────────────
  const userEmail = await resolveUserEmail(job.search_id);

  // ── Monthly compute budget check ───────────────────────────────────────────
  // Daily/anonymous jobs (no search_id → no userEmail) always bypass this check.
  const budget = await checkAndReserveMonthlyBudget(userEmail, supabase);
  if (!budget.allowed) {
    log(`[COGS] Monthly compute cap hit for ${userEmail} — rejecting job ${job.id}`);
    const durationMs = Date.now() - startMs;
    await finalizeScanRun(runId, { status: 'error', error: budget.reason, durationMs });
    await finalizeJob(job.id, 'error', budget.reason);
    await updateSearchStatus(job.search_id, 'error');
    // Store the user-facing message so the dashboard can surface it
    await supabase
      .from('deal_searches')
      .update({ last_error: budget.reason })
      .eq('id', job.search_id)
      .then(() => {}); // best-effort
    return;
  }
  if (budget.topupUsed) {
    log(`[COGS] Top-up run used for ${userEmail} — monthly cap bypassed`, { job: job.id });
  }

  try {
    const { durationMs, metrics, cogsUsed, cappedByCost } = await runFindDeals(job);

    // ── Record compute used ──────────────────────────────────────────────────
    // Always record, whether run completed normally or was capped.
    // cogsUsed is 0 if no DEALHOUND_TOKENS lines were emitted (e.g. very fast
    // runs or runs that don't yet emit token data).
    await recordComputeUsed(userEmail, cogsUsed, supabase);
    if (cogsUsed > 0) {
      log(`[COGS] Recorded $${cogsUsed.toFixed(4)} for ${userEmail || 'anon'}`, { job: job.id });
    }

    // ── COGS-capped run ──────────────────────────────────────────────────────
    if (cappedByCost) {
      log(`[COGS] Job ${job.id} returned partial result — capped at skill limit`);
      await finalizeScanRun(runId, {
        status: 'complete',
        durationMs,
        metrics,
        error: RUN_CAPPED_MESSAGE,
      });
      await finalizeJob(job.id, 'complete');
      await updateSearchStatus(job.search_id, 'complete');
      // Store cap message on search so dashboard can surface it
      await supabase
        .from('deal_searches')
        .update({ last_error: RUN_CAPPED_MESSAGE })
        .eq('id', job.search_id)
        .then(() => {});
      log(`Job ${job.id} complete (capped) in ${(durationMs / 1000).toFixed(1)}s`, metrics);
      return;
    }

    // ── Silent-zero guard ────────────────────────────────────────────────────
    // A clean exit with zero inserted rows is a bug, not a "successful" scan.
    // Mark it as error so we see it.
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

  const guard = createInFlightGuard();

  await processPendingJobs();

  setInterval(async () => {
    await guard.tryRun(async () => {
      try { await processPendingJobs(); }
      catch (err) { log('ERROR in poll loop', err.message); }
    });
  }, POLL_INTERVAL_MS);
}

// Only run main() when invoked as a script. Tests can require this module
// without triggering the polling loop.
if (require.main === module) {
  main().catch((err) => { console.error('FATAL:', err); process.exit(1); });
}

module.exports = { composeSpawnConfig, createInFlightGuard, SCAN_TIMEOUT_MS, runFindDeals };
