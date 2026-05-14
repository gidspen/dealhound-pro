// worker/email-sender.js
//
// Wraps the Resend transactional email API for scan completion emails.
// Never throws — all failures are returned as { ok: false } so the worker
// can continue without interruption.
//
// Exports:
//   sendFreeScanCompleteEmail      — one-time free scan (existing)
//   sendScheduledScanCompleteEmail — recurring scheduled scan (group-scan-runner)
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

// ── Scheduled scan completion email ───────────────────────────────────────────

/**
 * Send a scheduled-scan-complete transactional email via Resend.
 *
 * Used by group-scan-runner.js after a scheduled hourly/daily scan completes
 * for a paid user's buy box. Copy is distinct from the free-scan variant
 * ("Your scheduled Deal Hound scan found X deals" vs "Hey! I found some deals").
 *
 * @param {object}  opts
 * @param {string}  opts.to             — recipient email
 * @param {string}  opts.agentName      — agent first name, e.g. "Scout"
 * @param {number}  opts.dealCount      — deals that cleared hard filters
 * @param {string}  opts.dashboardUrl   — direct dashboard URL (no magic-link expiry)
 *
 * @returns {Promise<
 *   { ok: true,  messageId: string } |
 *   { ok: false, skipped: true,  reason: string } |
 *   { ok: false, error: unknown }
 * >}
 */
async function sendScheduledScanCompleteEmail({ to, agentName, dealCount, dashboardUrl }) {
  const apiKey = process.env.RESEND_API_KEY;

  const subject =
    dealCount > 0
      ? `${agentName} found ${dealCount} deal${dealCount === 1 ? '' : 's'} in your scheduled scan`
      : `${agentName} ran your scheduled scan — nothing cleared the bar today`;

  const from = `${agentName} from Deal Hound <gideon@stonemontcap.com>`;

  const bodyText =
    dealCount > 0
      ? `${agentName} here. Your scheduled Deal Hound scan just finished. I found ${dealCount} listing${dealCount === 1 ? '' : 's'} that match your buy box criteria.\n\nOpen your dashboard to review them:\n\n${dashboardUrl}`
      : `${agentName} here. Your scheduled Deal Hound scan just finished. Nothing cleared the bar this time — the market may be thin on your criteria right now.\n\nPop into the dashboard to adjust your filters or check past results:\n\n${dashboardUrl}`;

  const bodyHtml = `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${escapeHtml(subject)}</title>
</head>
<body style="margin:0;padding:0;background-color:#f5f5f5;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,Helvetica,Arial,sans-serif;">
  <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%" style="background-color:#f5f5f5;">
    <tr>
      <td align="center" style="padding:40px 16px;">
        <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="600" style="max-width:600px;width:100%;background-color:#ffffff;border-radius:8px;overflow:hidden;">
          <tr>
            <td style="padding:32px 40px 24px 40px;border-bottom:1px solid #f0f0f0;">
              <span style="font-size:18px;font-weight:700;color:#111111;letter-spacing:-0.3px;">Deal Hound</span>
            </td>
          </tr>
          <tr>
            <td style="padding:32px 40px 28px 40px;color:#222222;font-size:16px;line-height:1.6;">
              ${
                dealCount > 0
                  ? `<p style="margin:0 0 16px 0;">${escapeHtml(agentName)} here. Your scheduled Deal Hound scan just finished.</p>
                     <p style="margin:0 0 24px 0;">I found <strong>${dealCount} listing${dealCount === 1 ? '' : 's'}</strong> that match your buy box criteria.</p>`
                  : `<p style="margin:0 0 16px 0;">${escapeHtml(agentName)} here. Your scheduled Deal Hound scan just finished.</p>
                     <p style="margin:0 0 24px 0;">Nothing cleared the bar this time — the market may be thin on your criteria right now.</p>`
              }
              <table role="presentation" cellspacing="0" cellpadding="0" border="0">
                <tr>
                  <td style="border-radius:6px;background-color:#111111;">
                    <a href="${dashboardUrl}" style="display:inline-block;padding:14px 28px;font-size:15px;font-weight:600;color:#ffffff;text-decoration:none;border-radius:6px;">
                      Open my dashboard →
                    </a>
                  </td>
                </tr>
              </table>
            </td>
          </tr>
          <tr>
            <td style="padding:20px 40px;background-color:#fafafa;border-top:1px solid #f0f0f0;">
              <p style="margin:0;font-size:12px;color:#aaaaaa;line-height:1.5;">
                You're receiving this because you have an active buy box on
                <a href="https://dealhound.pro" style="color:#aaaaaa;">dealhound.pro</a>.
              </p>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</body>
</html>`;

  if (!apiKey) {
    console.warn(`[email] RESEND_API_KEY missing — skipping scheduled-scan email for ${to}`);
    return { ok: false, skipped: true, reason: 'no-key' };
  }

  let recipient = to;
  if (process.env.DEALHOUND_EMAIL_TEST_MODE === 'true') {
    console.log(`[email] TEST MODE — redirecting scheduled-scan email from ${to} to ${TEST_RECIPIENT}`);
    recipient = TEST_RECIPIENT;
  }

  try {
    const { Resend } = require('resend');
    const resend = new Resend(apiKey);

    const response = await resend.emails.send({
      from,
      to: recipient,
      subject,
      html: bodyHtml,
      text: bodyText,
    });

    const messageId = response?.data?.id ?? null;
    console.log(`[email] scheduled-scan email sent to ${recipient}`, { messageId });
    return { ok: true, messageId };
  } catch (err) {
    console.warn(`[email] scheduled-scan send failed for ${recipient} — ${err.message}`);
    return { ok: false, error: err };
  }
}

// ── HTML escaper (shared with inline template above) ──────────────────────────

function escapeHtml(str) {
  if (!str) return '';
  return String(str)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
}

module.exports = { sendFreeScanCompleteEmail, sendScheduledScanCompleteEmail };
