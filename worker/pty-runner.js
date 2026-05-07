'use strict';

/**
 * pty-runner.js — headed Claude runner for Deal Hound worker
 *
 * Replaces `claude -p /find-deals full` (headless) with an interactive PTY
 * spawn to eliminate Step 4b scoring divergence. In interactive mode, Claude
 * uses the same system prompt as Claude Desktop and follows the false-negative
 * protection rule (PARTIAL > MISS when uncertain), producing calibrated risk
 * scores rather than defaulting to total_risk=21 for sparse listings.
 *
 * Proven divergence from 2026-05-06 comparison test:
 *   - Classification agreement: 69% (31% diverge headless vs interactive)
 *   - Risk score agreement: 7% (93% diverge)
 *
 * API mirrors worker.js runFindDeals() exactly:
 *   runFindDealsHeaded(job, options) → Promise<{ durationMs, metrics, cogsUsed, cappedByCost }>
 */

const { CostTracker } = require('./cost-guardrails');

// ── ANSI escape stripper ──────────────────────────────────────────────────────
// Strips color codes, cursor moves, private mode sequences ([?, [>), window
// titles — anything that would confuse pattern matching on the raw PTY stream.
const ANSI_RE = /\x1b\[[\?><]?[0-9;]*[A-Za-z]|\x1b\][^\x07]*(?:\x07|\x1b\\)|\x1b[()][AB012]|\r/g;
const stripAnsi = (s) => s.replace(ANSI_RE, '');

// ── Completion detection ──────────────────────────────────────────────────────
// Claude Code interactive prompt: "❯ " (U+276F heavy right angle quotation mark)
// at the start of a fresh line. We detect this twice:
//   1. INIT → RUNNING: to inject the /find-deals full command
//   2. RUNNING fallback: Claude returned to idle after skill finished
const PROMPT_RE = /(?:^|\n)❯\s/;  // ❯ followed by space

// The find-deals skill always ends with a summary line. Match any of these:
//   "✅ SCAN COMPLETE — 8 HOT | 20 STRONG | 49 WATCH"
//   "8 HOT | 20 STRONG | 49 WATCH"
//   "SCAN COMPLETE"
const COMPLETE_RE = /(?:SCAN COMPLETE|\d+\s+HOT\s*[|│]\s*\d+\s+STRONG\s*[|│]\s*\d+\s+WATCH)/i;

// ── Main export ───────────────────────────────────────────────────────────────

/**
 * runFindDealsHeaded({ claudeBin, env, jobId, skill, timeout })
 *
 * @param {object} opts
 * @param {string}  opts.claudeBin   — absolute path to `claude` binary
 * @param {object}  opts.env         — composed env (from composeSpawnConfig in worker.js)
 * @param {string}  opts.jobId       — scrape_job.id for log context
 * @param {string}  [opts.skill]     — skill label for COGS tracker (default: 'deal scan')
 * @param {number}  [opts.timeout]   — ms before hard kill (default: 90 min)
 *
 * @returns {Promise<{ durationMs: number, metrics: object, cogsUsed: number, cappedByCost: boolean }>}
 */
function runFindDealsHeaded({
  claudeBin,
  env,
  jobId,
  skill = 'deal scan',
  timeout = 90 * 60_000,
}) {
  return new Promise((resolve, reject) => {
    const startMs = Date.now();
    const ts = () => new Date().toISOString();
    const log = (msg, data) => {
      if (data !== undefined) {
        console.log(`[${ts()}] ${msg}`, typeof data === 'object' ? JSON.stringify(data) : data);
      } else {
        console.log(`[${ts()}] ${msg}`);
      }
    };

    let rawBuffer = '';    // raw PTY bytes (for COGS / metric regexes)
    let cleanBuffer = '';  // ANSI-stripped (for prompt / completion detection)
    let state = 'INIT';   // INIT → RUNNING → DONE
    let metrics = {};
    let lastPhase = null;
    const phaseTimestamps = {};
    let cappedByCost = false;
    let exitHandled = false;

    const costTracker = new CostTracker(skill);
    if (process.env.FORCE_COGS_OVERRUN === 'true') {
      log('[COGS] FORCE_COGS_OVERRUN=true — every token event will register $5.00');
    }

    // ── Spawn interactive Claude ──────────────────────────────────────────────
    // No -p flag. PTY allocation makes stdin.isTTY = true, which puts Claude
    // in interactive mode (same system prompt as Claude Desktop).
    // node-pty lazy-loaded here so importing this module (for tests) doesn't
    // require the native binding to be present in root node_modules.
    const pty = require('node-pty');
    const ptyProc = pty.spawn(claudeBin, ['--dangerously-skip-permissions'], {
      name: 'xterm-256color',
      cols: 220, // wide enough to avoid line-wrap confusion in output parsing
      rows: 50,
      cwd: process.env.HOME,
      env,
    });

    log(`[PTY] Spawned headed claude (${claudeBin}) for job ${jobId}`);

    // ── Data handler ──────────────────────────────────────────────────────────
    ptyProc.onData((data) => {
      rawBuffer += data;
      cleanBuffer += stripAnsi(data);
      process.stdout.write(data); // mirror to worker logs verbatim

      // ── COGS tracking ────────────────────────────────────────────────────
      const { capped, totalCost, capAmount } = costTracker.trackTokenLine(data);
      if (capped && !cappedByCost) {
        cappedByCost = true;
        log(`[COGS] Run cap hit — $${totalCost.toFixed(4)} >= $${capAmount} for skill "${skill}" — terminating`, {
          job: jobId,
        });
        ptyProc.write('exit\r');
      }

      // ── Metric / phase parsing ────────────────────────────────────────────
      const mm = data.match(/DEALHOUND_METRICS:\s*(\{[^\n]+\})/);
      if (mm) {
        try { metrics = JSON.parse(mm[1]); } catch (_) {}
      }

      const pp = data.match(/DEALHOUND_PHASE:\s*(\S+)/);
      if (pp) {
        const phase = pp[1];
        if (phase !== lastPhase) {
          const elapsedMin = ((Date.now() - startMs) / 60000).toFixed(1);
          log(`[PHASE] ${phase}`, { elapsed: `${elapsedMin}m`, job: jobId });
          phaseTimestamps[phase] = Date.now();
          lastPhase = phase;
        }
      }

      // ── State machine ─────────────────────────────────────────────────────
      if (state === 'INIT') {
        // Wait for the first interactive prompt
        if (PROMPT_RE.test(cleanBuffer)) {
          state = 'RUNNING';
          log('[PTY] Prompt detected — injecting /find-deals full');
          ptyProc.write('/find-deals full\r');
        }
      } else if (state === 'RUNNING') {
        // Primary: scan summary line
        if (COMPLETE_RE.test(cleanBuffer)) {
          state = 'DONE';
          log('[PTY] Scan complete signal detected — waiting 5s for Supabase writes');
          setTimeout(() => {
            if (!exitHandled) {
              log('[PTY] Sending exit');
              ptyProc.write('exit\r');
            }
          }, 5000);
          return;
        }

        // Fallback: prompt returned after >50 KB of output (skill exited, Claude idle)
        // The 50KB floor prevents triggering on a prompt that appears before the
        // command echo is cleared. 50KB ≈ 1 full landsearch page of output.
        if (rawBuffer.length > 50_000 && PROMPT_RE.test(cleanBuffer)) {
          state = 'DONE';
          log('[PTY] Prompt returned after large output — skill complete', {
            outputKB: (rawBuffer.length / 1024).toFixed(0),
          });
          if (!exitHandled) ptyProc.write('exit\r');
        }
      }
    });

    // ── Timeout ───────────────────────────────────────────────────────────────
    const timeoutHandle = setTimeout(() => {
      if (exitHandled) return;
      exitHandled = true;
      log(`WARN: job ${jobId} exceeded ${timeout / 60000}m — killing PTY`);
      ptyProc.kill('SIGTERM');
      reject(new Error(`Headed scan timed out after ${(timeout / 60000).toFixed(0)}m`));
    }, timeout);

    // ── Heartbeat ─────────────────────────────────────────────────────────────
    const heartbeat = setInterval(() => {
      const elapsedMin = ((Date.now() - startMs) / 60000).toFixed(1);
      log(`[HEARTBEAT] job ${jobId} still running`, {
        elapsed: `${elapsedMin}m`,
        phase: lastPhase || 'unknown',
        cogsAccrued: `$${costTracker.total.toFixed(4)}`,
        state,
        outputKB: (rawBuffer.length / 1024).toFixed(0),
      });
    }, 5 * 60_000);

    // ── Exit handler ──────────────────────────────────────────────────────────
    ptyProc.onExit(({ exitCode }) => {
      if (exitHandled) return;
      exitHandled = true;

      clearTimeout(timeoutHandle);
      clearInterval(heartbeat);

      const durationMs = Date.now() - startMs;

      if (Object.keys(phaseTimestamps).length > 0) {
        const phaseSummary = Object.entries(phaseTimestamps).map(([phase, ts_]) => ({
          phase,
          startedAtMin: ((ts_ - startMs) / 60000).toFixed(1),
        }));
        log(`[TIMING] job ${jobId}`, {
          totalMin: (durationMs / 60000).toFixed(1),
          phases: phaseSummary,
        });
      }

      if (cappedByCost) {
        log(`[COGS] Run ended by cost cap`, { job: jobId, cogsUsed: `$${costTracker.total.toFixed(4)}` });
        resolve({ durationMs, metrics, cogsUsed: costTracker.total, cappedByCost: true });
        return;
      }

      // PTY exits 0 on clean `exit` command. Non-zero = something went wrong.
      if (exitCode === 0 || state === 'DONE') {
        resolve({ durationMs, metrics, cogsUsed: costTracker.total, cappedByCost: false });
      } else {
        reject(new Error(`PTY claude exited with code ${exitCode} (state: ${state})`));
      }
    });
  });
}

module.exports = { runFindDealsHeaded };
