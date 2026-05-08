// worker/email-sender.js
//
// Wraps the Resend transactional email API for free-scan completion emails.
// Never throws — all failures are returned as { ok: false } so the worker
// can continue without interruption.
//
// Env vars:
//   RESEND_API_KEY            — Resend secret key. If missing, email is skipped.
//   DEALHOUND_EMAIL_TEST_MODE — set to 'true' to redirect all sends to the
//                               test address below (protects production data
//                               during E2E runs).

'use strict';

const { renderFreeScanCompleteEmail } = require('../emails/free-scan-complete');

const TEST_RECIPIENT = 'gideon+dh-test@stonemontcap.com';

/**
 * Send a free-scan-complete transactional email via Resend.
 *
 * @param {object}        opts
 * @param {string}        opts.to              — recipient email
 * @param {string}        opts.agentName       — agent first name, e.g. "Scout"
 * @param {string|null}   opts.firstName       — user first name (may be empty)
 * @param {number|string} opts.listingsScanned — listings reviewed count
 * @param {number}        opts.dealCount       — deals that cleared the bar
 * @param {string|null}   opts.topDealBrief    — one-line deal brief (may be null)
 * @param {string}        opts.magicLinkUrl    — magic link URL
 *
 * @returns {Promise<
 *   { ok: true,  messageId: string } |
 *   { ok: false, skipped: true,  reason: string, preview: object } |
 *   { ok: false, error: unknown }
 * >}
 */
async function sendFreeScanCompleteEmail({
  to,
  agentName,
  firstName,
  listingsScanned,
  dealCount,
  topDealBrief,
  magicLinkUrl,
}) {
  const apiKey = process.env.RESEND_API_KEY;

  // ── Render template regardless of whether we send ────────────────────────────
  const rendered = renderFreeScanCompleteEmail({
    agentName,
    firstName,
    listingsScanned,
    dealCount,
    topDealBrief,
    magicLinkUrl,
  });

  // ── No API key — skip gracefully ──────────────────────────────────────────────
  if (!apiKey) {
    console.warn(`[email] RESEND_API_KEY missing — skipping email send for ${to}`);
    return {
      ok: false,
      skipped: true,
      reason: 'no-key',
      preview: {
        from:    rendered.from,
        to,
        subject: rendered.subject,
        text:    rendered.text,
      },
    };
  }

  // ── Test mode: redirect to safe address ──────────────────────────────────────
  let recipient = to;
  if (process.env.DEALHOUND_EMAIL_TEST_MODE === 'true') {
    console.log(`[email] TEST MODE — redirecting send from ${to} to ${TEST_RECIPIENT}`);
    recipient = TEST_RECIPIENT;
  }

  // ── Send via Resend ───────────────────────────────────────────────────────────
  try {
    const { Resend } = require('resend');
    const resend = new Resend(apiKey);

    const response = await resend.emails.send({
      from:    rendered.from,
      to:      recipient,
      subject: rendered.subject,
      html:    rendered.html,
      text:    rendered.text,
    });

    const messageId = response?.data?.id ?? null;
    console.log(`[email] sent to ${recipient}`, { messageId });
    return { ok: true, messageId };

  } catch (err) {
    console.warn(`[email] send failed for ${recipient} — ${err.message}`);
    return { ok: false, error: err };
  }
}

module.exports = { sendFreeScanCompleteEmail };
