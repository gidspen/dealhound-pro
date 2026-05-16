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
const PROMPT_RE = /(?:^|\n)❯\s/; // ❯ followed by space (real input prompt)

// --dangerously-skip-permissions now shows a confirmation dialog on startup:
//   "By proceeding, you accept all responsibility..."
//   "❯ 1. No, exit   2. Yes, I accept"
// Detect it and auto-select option 2. The ❯ here has no space before the digit.
const BYPASS_DIALOG_RE = /Yes,\s*I\s*accept|accept all responsibility/i;

// settings.json parse error dialog (shown when settings.json has invalid JSON):
//   "Settings Error — /path/to/settings.json — Invalid or malformed JSON"
//   "❯ 1. Exit and fix manually   2. Continue without these settings"
// Navigate down then Enter to select option 2.
const SETTINGS_ERROR_RE = /Invalid or malformed JSON|Settings Error|Exit and fix manually/i;

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
function runFindDealsHeaded({ claudeBin, env, jobId, skill = 'deal scan', timeout = 90 * 60_000 }) {
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

    let rawBuffer = ''; // raw PTY bytes (for COGS / metric regexes)
    let cleanBuffer = ''; // ANSI-stripped (for prompt / completion detection)
    let state = 'INIT'; // INIT → RUNNING → DONE
    let metrics = {};
    let lastPhase = null;
    const phaseTimestamps = {};
    let cappedByCost = false;
    let exitHandled = false;
    let bypassHandled = false; // guard against re-triggering bypass acceptance
    let settingsErrorHandled = false; // guard against re-triggering settings error acceptance

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
        log(
          `[COGS] Run cap hit — $${totalCost.toFixed(4)} >= $${capAmount} for skill "${skill}" — terminating`,
          {
            job: jobId,
          }
        );
        ptyProc.write('exit\r');
      }

      // ── Metric / phase parsing ────────────────────────────────────────────
      const mm = data.match(/DEALHOUND_METRICS:\s*(\{[^\n]+\})/);
      if (mm) {
        try {
          metrics = JSON.parse(mm[1]);
        } catch (_) {}
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
        // Handle --dangerously-skip-permissions acceptance dialog (added in recent
        // Claude Code versions). Shows a menu: "❯ 1. No, exit  2. Yes, I accept"
        // Navigate with down-arrow then Enter. Guard with bypassHandled so the
        // async timeouts don't re-trigger on subsequent onData events.
        if (!bypassHandled && BYPASS_DIALOG_RE.test(cleanBuffer)) {
          bypassHandled = true;
          log('[PTY] Bypass permissions dialog detected — navigating to "Yes, I accept"');
          setTimeout(() => {
            ptyProc.write('\x1b[B'); // down arrow → move to option 2
            setTimeout(() => {
              log('[PTY] Confirming acceptance');
              ptyProc.write('\r'); // Enter → confirm
            }, 300);
          }, 800);
          return;
        }
        // Handle settings.json parse error dialog. Appears after the bypass dialog
        // when settings.json contains invalid JSON. Selects "Continue without these
        // settings" so the PTY reaches the real interactive prompt regardless.
        if (!settingsErrorHandled && SETTINGS_ERROR_RE.test(cleanBuffer)) {
          settingsErrorHandled = true;
          log('[PTY] Settings error dialog detected — selecting "Continue without these settings"');
          setTimeout(() => {
            ptyProc.write('\x1b[B'); // down arrow → move to option 2
            setTimeout(() => {
              log('[PTY] Confirming continue without settings');
              ptyProc.write('\r'); // Enter → confirm
            }, 300);
          }, 500);
          return;
        }

        // Wait for the real interactive prompt (❯ followed by space)
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

        // Fallback: prompt returned after >500 KB of output (skill exited, Claude idle)
        // The 500KB floor prevents false-positives from Claude Code's ANSI spinner
        // animation, which fills ~50KB in ~30s before any scraper or pipeline runs.
        // A real full scan (scraper + pipeline + scoring) produces >>500KB of output.
        // Old threshold (50KB) was incorrectly calibrated — spinner fills it before
        // Phase 2A even starts, killing the session with zero listings every time.
        if (rawBuffer.length > 500_000 && PROMPT_RE.test(cleanBuffer)) {
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
        log(`[COGS] Run ended by cost cap`, {
          job: jobId,
          cogsUsed: `$${costTracker.total.toFixed(4)}`,
        });
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
