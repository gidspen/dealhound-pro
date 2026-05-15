## Intent

Fixes the root cause of "0 DEALS / Scan failed" on all worker scan runs. The PTY fallback
completion detector in `pty-runner.js` was calibrated at 50KB, which Claude Code's ANSI
spinner animation fills in ~30 seconds — before any scraper or pipeline code runs. This
caused every scan to exit prematurely (zero listings), which triggered the zero-row guard
in `worker.js` and set every job to `status='error'`. Raising the threshold to 500KB
requires real multi-phase pipeline output, making the fallback safe to use.

## Files changed

- `worker/pty-runner.js` — raised `rawBuffer.length` fallback threshold from `50_000` to
  `500_000` and updated the comment to document the ANSI spinner calibration rationale

## Confirmation

No files outside the intended scope were modified.
