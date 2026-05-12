// api/_lib/posthog.js
// Lazy PostHog server client. Safe to require even when env vars are missing
// (capture() becomes a no-op) so tests don't blow up.

const { PostHog } = require('posthog-node');

let client = null;

function getClient() {
  if (client) return client;
  const key = process.env.POSTHOG_API_KEY;
  const host = process.env.POSTHOG_HOST || 'https://us.i.posthog.com';
  if (!key) return null;
  client = new PostHog(key, { host, flushAt: 1, flushInterval: 0 });
  return client;
}

async function capture({ event, distinctId, properties }) {
  const c = getClient();
  if (!c) return;
  try {
    c.capture({ distinctId: distinctId || 'anonymous', event, properties: properties || {} });
    await c.flush();
  } catch (err) {
    console.error('posthog capture failed:', err.message);
  }
}

module.exports = { capture };
