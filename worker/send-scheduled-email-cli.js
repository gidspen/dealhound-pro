#!/usr/bin/env node
// Tiny CLI wrapper so the find-deals skill (running in a Claude Code session)
// can fire scheduled-scan completion emails via Bash.
//
// Usage:
//   node send-scheduled-email-cli.js --to <email> --agent <name> --deals <count>
//
// Calls sendScheduledScanCompleteEmail (separate template + copy from
// the free-scan email — "Your Deal Hound scan is ready" vs free-scan).
//
// Exit codes:
//   0 — sent successfully, OR skipped (no RESEND_API_KEY) — batch should continue
//   1 — hard failure (bad args, send error)

'use strict';

require('dotenv').config({ path: require('path').join(__dirname, '..', '.env') });
const { sendScheduledScanCompleteEmail } = require('./email-sender');

function parseArgs() {
  const args = {};
  const argv = process.argv.slice(2);
  for (let i = 0; i < argv.length; i += 2) {
    const key = argv[i].replace(/^--/, '');
    args[key] = argv[i + 1];
  }
  return args;
}

async function main() {
  const args = parseArgs();

  if (!args.to || !args.agent || args.deals == null) {
    console.error('[email-cli] Missing required args: --to <email> --agent <name> --deals <count>');
    process.exit(1);
  }

  const dealCount = parseInt(args.deals, 10);
  if (Number.isNaN(dealCount)) {
    console.error(`[email-cli] --deals must be an integer, got: ${args.deals}`);
    process.exit(1);
  }

  const result = await sendScheduledScanCompleteEmail({
    to: args.to,
    agentName: args.agent,
    dealCount,
    dashboardUrl: 'https://dealhound.pro/dashboard',
  });

  if (result.ok) {
    console.log(`[email-cli] sent to ${args.to} (messageId: ${result.messageId || 'unknown'})`);
    process.exit(0);
  } else if (result.skipped) {
    // No RESEND_API_KEY — skip gracefully so the batch doesn't error
    console.warn(`[email-cli] skipped for ${args.to}: ${result.reason}`);
    process.exit(0);
  } else {
    const msg = result.error?.message || result.reason || 'unknown error';
    console.error(`[email-cli] send failed for ${args.to}: ${msg}`);
    process.exit(1);
  }
}

main().catch((err) => {
  console.error('[email-cli] crashed:', err);
  process.exit(1);
});
