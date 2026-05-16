// emails/free-scan-complete.js
//
// Pure render function — no I/O, no network, no side effects.
//
// Export: renderFreeScanCompleteEmail({ agentName, firstName, listingsScanned, dealCount, topDealBrief, magicLinkUrl })
// Returns: { subject, html, text, from }

'use strict';

/**
 * @param {object} opts
 * @param {string}        opts.agentName       — agent's first name, e.g. "Scout"
 * @param {string|null}   opts.firstName       — user's first name, may be empty/null/undefined
 * @param {number|string} opts.listingsScanned — number of listings reviewed
 * @param {number}        opts.dealCount       — deals that cleared the bar
 * @param {string|null}   opts.topDealBrief    — one-line brief on the best deal (may be null)
 * @param {string}        opts.magicLinkUrl    — magic-link URL (expires 24h)
 * @returns {{ subject: string, from: string, html: string, text: string }}
 */
function renderFreeScanCompleteEmail({
  agentName,
  firstName,
  listingsScanned,
  dealCount,
  topDealBrief,
  magicLinkUrl,
}) {
  const subject = 'Hey! I found some deals 👀';
  // Use hello@dealhound.pro — the verified Resend domain. stonemontcap.com
  // isn't verified at Resend (and we don't want it to be — it's Gideon's
  // personal/business domain).
  const from = `${agentName} from Deal Hound <hello@dealhound.pro>`;

  // ── Greeting ─────────────────────────────────────────────────────────────────
  const greeting = firstName && firstName.trim() ? `Hey ${firstName.trim()},` : 'Hey,';

  // ── Body copy ─────────────────────────────────────────────────────────────────
  let bodyLines;

  if (dealCount === 0) {
    // Nothing cleared the bar today
    bodyLines = [
      `I burned through ${listingsScanned} listings and nothing cleared the bar today — your filters are tighter than the market right now. I have ideas on which knobs to loosen. Pop into the dashboard and we'll work through them.`,
    ];
  } else {
    // Deals found
    const dealsLine = `I just finished going through ${listingsScanned} listings across 30+ marketplaces. Found ${dealCount} that match what you're hunting for.`;

    let topDealLine;
    if (topDealBrief && topDealBrief.trim()) {
      topDealLine = `${topDealBrief.trim()} is the one I'd lead with — let me walk you through why.`;
    } else {
      topDealLine = `The top match looks promising — let me walk you through the details in the dashboard.`;
    }

    bodyLines = [dealsLine, '', topDealLine];
  }

  const ctaLine = `Want to dig in together? I'll walk you through them in the dashboard:`;
  const signOff = `— ${agentName}`;

  // ── Plain text ────────────────────────────────────────────────────────────────
  const text = [
    greeting,
    '',
    ...bodyLines,
    '',
    ctaLine,
    '',
    `[ Open my dashboard → ]   ${magicLinkUrl}`,
    '',
    '*(This link expires in 24 hours.)*',
    '',
    signOff,
  ].join('\n');

  // ── HTML ──────────────────────────────────────────────────────────────────────
  const bodyHtml = bodyLines
    .map((line) => (line === '' ? '' : `<p style="margin:0 0 16px 0;">${escapeHtml(line)}</p>`))
    .join('\n');

  const html = `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <title>${escapeHtml(subject)}</title>
</head>
<body style="margin:0;padding:0;background-color:#f5f5f5;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,Helvetica,Arial,sans-serif;">
  <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%" style="background-color:#f5f5f5;">
    <tr>
      <td align="center" style="padding:40px 16px;">
        <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="600" style="max-width:600px;width:100%;background-color:#ffffff;border-radius:8px;overflow:hidden;">

          <!-- Header -->
          <tr>
            <td style="padding:32px 40px 24px 40px;border-bottom:1px solid #f0f0f0;">
              <span style="font-size:18px;font-weight:700;color:#111111;letter-spacing:-0.3px;">Deal Hound</span>
            </td>
          </tr>

          <!-- Body -->
          <tr>
            <td style="padding:32px 40px 16px 40px;color:#222222;font-size:16px;line-height:1.6;">
              <p style="margin:0 0 20px 0;font-size:16px;color:#222222;">${escapeHtml(greeting)}</p>

              ${bodyHtml}

              ${
                dealCount !== 0
                  ? `
              <p style="margin:0 0 28px 0;font-size:16px;color:#222222;">${escapeHtml(ctaLine)}</p>

              <!-- CTA button -->
              <table role="presentation" cellspacing="0" cellpadding="0" border="0">
                <tr>
                  <td style="border-radius:6px;background-color:#111111;">
                    <a href="${magicLinkUrl}"
                       style="display:inline-block;padding:14px 28px;font-size:15px;font-weight:600;color:#ffffff;text-decoration:none;border-radius:6px;letter-spacing:-0.1px;">
                      Open my dashboard →
                    </a>
                  </td>
                </tr>
              </table>

              <p style="margin:24px 0 0 0;font-size:13px;color:#888888;">
                This link expires in 24 hours.
                If the button doesn't work, copy this URL into your browser:<br>
                <a href="${magicLinkUrl}" style="color:#555555;word-break:break-all;">${magicLinkUrl}</a>
              </p>
              `
                  : `
              <!-- CTA button (zero-deal variant) -->
              <table role="presentation" cellspacing="0" cellpadding="0" border="0" style="margin-top:8px;">
                <tr>
                  <td style="border-radius:6px;background-color:#111111;">
                    <a href="${magicLinkUrl}"
                       style="display:inline-block;padding:14px 28px;font-size:15px;font-weight:600;color:#ffffff;text-decoration:none;border-radius:6px;letter-spacing:-0.1px;">
                      Open my dashboard →
                    </a>
                  </td>
                </tr>
              </table>

              <p style="margin:24px 0 0 0;font-size:13px;color:#888888;">
                This link expires in 24 hours.
                If the button doesn't work, copy this URL into your browser:<br>
                <a href="${magicLinkUrl}" style="color:#555555;word-break:break-all;">${magicLinkUrl}</a>
              </p>
              `
              }
            </td>
          </tr>

          <!-- Sign-off -->
          <tr>
            <td style="padding:24px 40px 40px 40px;color:#222222;font-size:16px;line-height:1.6;border-top:1px solid #f0f0f0;">
              <p style="margin:0;color:#222222;">${escapeHtml(signOff)}</p>
            </td>
          </tr>

          <!-- Footer -->
          <tr>
            <td style="padding:20px 40px;background-color:#fafafa;border-top:1px solid #f0f0f0;">
              <p style="margin:0;font-size:12px;color:#aaaaaa;line-height:1.5;">
                You're receiving this because you ran a free scan on
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

  return { subject, from, html, text };
}

// ── Helpers ───────────────────────────────────────────────────────────────────

function escapeHtml(str) {
  if (!str) return '';
  return String(str)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
}

module.exports = { renderFreeScanCompleteEmail };
