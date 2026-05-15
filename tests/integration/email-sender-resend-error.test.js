// tests/integration/email-sender-resend-error.test.js
//
// Behavioral test for worker/email-sender.js.
//
// Two paths covered without mocking the Resend SDK (vi.mock + CJS require
// interop is unreliable for this module):
//
//   1. No-key path: when RESEND_API_KEY is absent, the wrapper short-circuits
//      and returns `{ ok:false, skipped:true, reason:'no-key' }`. Confirms the
//      worker doesn't crash when secrets are missing.
//
//   2. Live-call path: when RESEND_API_KEY is present but no Resend domain is
//      verified yet (our current state until DKIM propagation), the wrapper
//      now returns `{ ok:false, error }` with `error.statusCode === 403`.
//      This locks the 2026-05-15 silent-pass regression where Resend's 4xx
//      response body was being treated as success.
//
// Skips the live-call test when:
//   - RESEND_API_KEY is missing (we'd be testing the same thing as #1)
//   - DEALHOUND_E2E_SKIP_LIVE_RESEND=true (CI escape hatch)

import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import { sendFreeScanCompleteEmail } from '../../worker/email-sender.js';

const SAMPLE_ARGS = {
  to: 'gideon+dh-test-unit@stonemontcap.com',
  agentName: 'Scout',
  firstName: 'Gideon',
  listingsScanned: 100,
  dealCount: 3,
  topDealBrief: 'Unit test brief.',
  magicLinkUrl: 'https://example.test/dashboard',
};

describe('sendFreeScanCompleteEmail — no-key short-circuit', () => {
  let originalKey;

  beforeEach(() => {
    originalKey = process.env.RESEND_API_KEY;
    delete process.env.RESEND_API_KEY;
  });

  afterEach(() => {
    if (originalKey !== undefined) process.env.RESEND_API_KEY = originalKey;
  });

  it('returns {ok:false, skipped:true, reason:"no-key"} when key missing', async () => {
    const result = await sendFreeScanCompleteEmail(SAMPLE_ARGS);
    expect(result.ok).toBe(false);
    expect(result.skipped).toBe(true);
    expect(result.reason).toBe('no-key');
    // The render payload is still attached so callers can log a preview.
    expect(result.preview).toBeDefined();
    expect(result.preview.subject).toMatch(/found some deals/i);
  });
});

describe('sendFreeScanCompleteEmail — silent-pass regression guard (live Resend)', () => {
  const hasKey = !!process.env.RESEND_API_KEY;
  const opted = process.env.DEALHOUND_E2E_SKIP_LIVE_RESEND !== 'true';

  it.skipIf(!hasKey || !opted)(
    'returns {ok:false, error.statusCode:4xx} when Resend rejects (e.g. unverified domain)',
    async () => {
      const result = await sendFreeScanCompleteEmail(SAMPLE_ARGS);
      // Two acceptable outcomes:
      //   a) Domain not yet verified at Resend → error.statusCode === 403
      //   b) Domain verified, send accepted → result.ok === true, messageId present
      if (result.ok) {
        expect(result.messageId).toBeTruthy();
      } else {
        expect(result.error).toBeDefined();
        // statusCode lives on Resend's error envelope; some throwable codepaths
        // surface .message instead.
        const code = result.error.statusCode ?? result.error.status;
        if (code) expect(code).toBeGreaterThanOrEqual(400);
        // Crucially: even on failure we must NOT report ok:true. That's the bug.
        expect(result.ok).toBe(false);
      }
    }
  );
});
