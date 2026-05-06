'use strict';

/**
 * Diagnostic harness for the worker → claude → supabase contract.
 *
 * Why this exists: searches triggered through the worker produce empty/weak
 * results, but the same /find-deals skill produces good results when run
 * directly in a terminal. Same skill, same code, different output. That means
 * the bug is at the seam — not in the skill. This harness captures both runs
 * forensically so the seam is visible.
 *
 * Modes:
 *   --env-check   Fast. No spawn. Prints the exact args + env diff between
 *                 the current shell and what worker.composeSpawnConfig builds.
 *                 Often reveals the bug instantly (missing var, stripped key,
 *                 wrong cwd, MCP scope drift).
 *
 *   --full-run    Slow (~5–15 min). Creates a fixture deal_search, spawns
 *                 claude EXACTLY like the worker does, tees stdout/stderr to
 *                 logs, then queries supabase for deal_count, sources scraped,
 *                 and scan_progress steps. Writes a JSON report.
 *
 * Comparison protocol:
 *   1. `node worker/diagnose.js --env-check`
 *      Read the diff. If you spot the bug here, stop — fix it, done.
 *
 *   2. `node worker/diagnose.js --full-run`
 *      Note the printed search_id (call it WORKER_ID) and buy-box file path.
 *
 *   3. In another terminal, with no special env, run claude interactively
 *      against the SAME buy box. The script prints the exact command. Note
 *      the search_id you create there (DIRECT_ID).
 *
 *   4. Compare the two reports. We are NOT asserting deal-count equality —
 *      LLMs are fluid. We ARE asserting structural parity:
 *        - sources_scraped should be the same set
 *        - progress_steps should hit the same milestones
 *        - deal_count should be > 0 in BOTH (or 0 in BOTH for an empty market)
 *      Whatever differs structurally between WORKER_ID and DIRECT_ID is
 *      the seam bug.
 */

const path = require('path');
const fs = require('fs');
const os = require('os');
const { spawn } = require('child_process');
const { createClient } = require('@supabase/supabase-js');

const envPath = path.join(__dirname, '../.env.local');
if (fs.existsSync(envPath)) require('dotenv').config({ path: envPath });

const { composeSpawnConfig } = require('./worker.js');

// Small, deterministic-ish buy box. Texas glamping/micro-resort is a market
// we've previously seen produce listings via the skill direct-run, so a
// healthy worker run should also produce >0.
const FIXTURE_BUY_BOX = {
  locations: ['Texas'],
  price_min: 200000,
  price_max: 1500000,
  property_types: ['glamping', 'micro_resort'],
  revenue_requirement: 'value_add_ok',
  acreage_min: 5,
  exclusions: [],
  raw_prompt: 'glamping or micro resort in texas, minimum 5 acres, $200k to $1.5m, value-add okay',
};

const TAG = `diag-${Date.now()}`;
const TEST_EMAIL = `diagnose+${TAG}@dealhound.dev`;

const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_KEY);

function findClaude() {
  const cands = [
    process.env.CLAUDE_BIN,
    '/opt/homebrew/bin/claude',
    '/usr/local/bin/claude',
    `${os.homedir()}/.npm-global/bin/claude`,
  ].filter(Boolean);
  for (const p of cands) {
    try { fs.accessSync(p, fs.constants.X_OK); return p; } catch (_) {}
  }
  return 'claude';
}

function truncate(s, n) {
  return s.length <= n ? s : s.slice(0, n - 1) + '…';
}

function envCheck() {
  const fakeJob = { id: TAG, search_id: TAG, buy_box: FIXTURE_BUY_BOX };
  const buyBoxFile = path.join(os.tmpdir(), `${TAG}-buybox.json`);
  fs.writeFileSync(buyBoxFile, JSON.stringify(FIXTURE_BUY_BOX, null, 2));

  const { args, env } = composeSpawnConfig(fakeJob, process.env, buyBoxFile);

  // Keys most likely to matter for the seam: skill resolution, Anthropic auth,
  // MCP tool availability, supabase writes, buy-box delivery.
  const watch = [
    'PATH', 'HOME', 'PWD', 'SHELL', 'USER',
    'ANTHROPIC_API_KEY', 'CLAUDE_CONFIG_DIR', 'CLAUDE_BIN',
    'XDG_CONFIG_HOME',
    'SUPABASE_URL', 'SUPABASE_SERVICE_KEY',
    'SUPABASE_DEALS_URL', 'SUPABASE_DEALS_ANON_KEY',
    'DEALHOUND_SEARCH_ID', 'DEALHOUND_SCRAPE_JOB_ID',
    'DEALHOUND_BUY_BOX_FILE', 'DEALHOUND_BUY_BOX_JSON',
  ];

  console.log('=== Worker spawn args ===');
  console.log(JSON.stringify(args));
  console.log('\nNote: `-p "/find-deals full"` runs claude in non-interactive mode.');
  console.log('Direct interactive runs differ in MCP tool surface, settings.json scope,');
  console.log('and stdin/stdout shape. This is a likely seam — verify by running both.');

  console.log('\n=== cwd ===');
  console.log('worker process cwd:', process.cwd());
  console.log('claude inherits that cwd unless overridden in spawn opts.');
  console.log('Direct-run cwd is wherever you `cd`d to. Skill file resolution,');
  console.log('relative paths in skills, and project-scoped settings.json all');
  console.log('depend on cwd — confirm both runs use the same one.');

  console.log('\n=== Env diff: shell → worker-spawn ===');
  console.log('!=changed/added  -=stripped from spawn  =unchanged');
  console.log('FLAG  KEY' + ' '.repeat(30) + 'SHELL'.padEnd(22) + 'WORKER-SPAWN');
  console.log('-'.repeat(95));
  for (const k of watch) {
    const a = process.env[k];
    const b = env[k];
    const flag = (a || '') === (b || '') ? ' =' : (b == null ? ' -' : ' !');
    const redact = k.includes('KEY') || k.includes('SECRET');
    const aShort = a == null ? '<unset>' : (redact ? '<set>' : truncate(a, 20));
    const bShort = b == null ? '<unset>' : (redact ? '<set>' : truncate(b, 30));
    console.log(`${flag}    ${k.padEnd(32)}${aShort.padEnd(22)}${bShort}`);
  }

  console.log('\n=== Shell-only keys (present in shell, dropped from spawn) ===');
  const dropped = Object.keys(process.env).filter((k) => !(k in env)).sort();
  console.log(dropped.length ? dropped.join(', ') : '(none)');

  console.log('\n=== Buy box fixture ===');
  console.log('File:', buyBoxFile);
  console.log('Content:', JSON.stringify(FIXTURE_BUY_BOX));

  console.log('\n=== To compare against a direct interactive run ===');
  console.log('1. In a fresh terminal (no PM2 env, your normal shell):');
  console.log(`   export DEALHOUND_BUY_BOX_FILE=${buyBoxFile}`);
  console.log('   export DEALHOUND_SEARCH_ID=<create a new deal_searches row id>');
  console.log('   claude');
  console.log('2. At the prompt: /find-deals full');
  console.log('3. Watch what it does. Compare to --full-run output.');
}

async function fullRun() {
  console.log(`[diag] tag=${TAG}`);

  const { data: search, error } = await supabase
    .from('deal_searches')
    .insert({
      user_email: TEST_EMAIL,
      buy_box: { ...FIXTURE_BUY_BOX, _diag_tag: TAG },
      status: 'ready',
      run_at: new Date().toISOString(),
    })
    .select('id')
    .single();
  if (error) throw new Error(`insert deal_searches failed: ${error.message}`);
  const searchId = search.id;
  console.log(`[diag] created deal_searches.id=${searchId}`);

  const buyBoxFile = path.join(os.tmpdir(), `${TAG}-buybox.json`);
  fs.writeFileSync(buyBoxFile, JSON.stringify(FIXTURE_BUY_BOX, null, 2));
  const job = {
    id: `${TAG}-job`,
    search_id: searchId,
    buy_box: FIXTURE_BUY_BOX,
  };
  const { args, env } = composeSpawnConfig(job, process.env, buyBoxFile);

  const logDir = path.join(__dirname, 'logs');
  fs.mkdirSync(logDir, { recursive: true });
  const stdoutPath = path.join(logDir, `${TAG}-stdout.log`);
  const stderrPath = path.join(logDir, `${TAG}-stderr.log`);
  const stdoutFd = fs.openSync(stdoutPath, 'a');
  const stderrFd = fs.openSync(stderrPath, 'a');

  const claudeBin = findClaude();
  console.log(`[diag] spawning: ${claudeBin} ${args.join(' ')}`);
  console.log(`[diag] stdout → ${stdoutPath}`);
  console.log(`[diag] stderr → ${stderrPath}`);
  console.log(`[diag] cwd    = ${process.cwd()}`);
  console.log(`[diag] buy box file = ${buyBoxFile}`);
  console.log(`[diag] starting at ${new Date().toISOString()} — expect 5–15 min`);

  const startMs = Date.now();
  const proc = spawn(claudeBin, args, { env, stdio: ['ignore', 'pipe', 'pipe'] });
  proc.stdout.on('data', (c) => { process.stdout.write(c); fs.writeSync(stdoutFd, c); });
  proc.stderr.on('data', (c) => { process.stderr.write(c); fs.writeSync(stderrFd, c); });

  const exitCode = await new Promise((resolve, reject) => {
    proc.on('close', resolve);
    proc.on('error', reject);
  });
  const durationMs = Date.now() - startMs;
  fs.closeSync(stdoutFd);
  fs.closeSync(stderrFd);

  // Pull supabase side-effects.
  const { count: dealCount } = await supabase
    .from('deals')
    .select('*', { count: 'exact', head: true })
    .eq('search_id', searchId);

  const { data: progress } = await supabase
    .from('scan_progress')
    .select('step,status,listing_count,message,created_at')
    .eq('search_id', searchId)
    .order('created_at', { ascending: true });

  const sources = new Set();
  for (const p of progress || []) {
    const m = p.step && p.step.match(/^scrape:([^:]+):/);
    if (m) sources.add(m[1]);
  }

  const report = {
    tag: TAG,
    search_id: searchId,
    exit_code: exitCode,
    duration_ms: durationMs,
    duration_human: `${(durationMs / 1000).toFixed(1)}s`,
    deal_count: dealCount || 0,
    sources_scraped: [...sources].sort(),
    progress_steps: (progress || []).map((p) => ({
      step: p.step,
      status: p.status,
      listing_count: p.listing_count,
    })),
    stdout_log: stdoutPath,
    stderr_log: stderrPath,
  };

  const reportPath = path.join(logDir, `${TAG}-report.json`);
  fs.writeFileSync(reportPath, JSON.stringify(report, null, 2));

  console.log('\n=== REPORT ===');
  console.log(JSON.stringify(report, null, 2));
  console.log(`\nSaved: ${reportPath}`);
  console.log('\nNow run /find-deals full directly in a terminal against the same buy box');
  console.log('(see --env-check output for the exact env to set), then diff the two reports.');
}

async function main() {
  const mode = process.argv[2];
  if (mode === '--env-check') {
    envCheck();
  } else if (mode === '--full-run') {
    if (!process.env.SUPABASE_URL || !process.env.SUPABASE_SERVICE_KEY) {
      console.error('FATAL: missing SUPABASE_URL / SUPABASE_SERVICE_KEY');
      process.exit(1);
    }
    await fullRun();
  } else {
    console.log('Usage:');
    console.log('  node worker/diagnose.js --env-check   # fast: args + env + cwd diff');
    console.log('  node worker/diagnose.js --full-run    # slow: spawn + capture + report');
    process.exit(1);
  }
}

main().catch((err) => {
  console.error('FATAL:', err);
  process.exit(1);
});
