/**
 * kit-nurture
 *
 * Post-scan nurture handoff: subscribes a user to a Kit (ConvertKit) tag
 * after free-scan completion so they enter the drip sequence.
 *
 * Supports Kit V4 API with automatic fallback to ConvertKit V3 if V4
 * returns a non-2xx response.
 *
 * Env vars (at least one required for write operations):
 *   KIT_API_KEY    — public API key (used for V4 header auth)
 *   KIT_API_SECRET — secret key    (used for V3 body auth)
 *
 * Never throws — all failures are logged as warnings and returned as
 * { ok: false } so the worker can continue without interruption.
 */

'use strict';

// ── Helpers ───────────────────────────────────────────────────────────────────

function log(msg, data) {
  const ts = new Date().toISOString();
  if (data !== undefined) {
    console.log(`[${ts}] ${msg}`, typeof data === 'object' ? JSON.stringify(data) : data);
  } else {
    console.log(`[${ts}] ${msg}`);
  }
}

// ── Kit V4 ────────────────────────────────────────────────────────────────────

/**
 * Attempt to subscribe via Kit V4 API.
 *
 * @param {string} email
 * @param {string} firstName
 * @param {string} apiKey
 * @returns {{ ok: boolean, subscriber_id?: string|number, status?: number }}
 */
async function subscribeV4(email, firstName, apiKey) {
  const body = { email_address: email };
  if (firstName) body.first_name = firstName;

  const res = await fetch('https://api.kit.com/v4/subscribers', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'X-Kit-Api-Key': apiKey,
    },
    body: JSON.stringify(body),
  });

  if (!res.ok) {
    return { ok: false, status: res.status };
  }

  const json = await res.json();
  // V4 wraps the subscriber under `subscriber`
  const subscriberId = json?.subscriber?.id ?? json?.id ?? null;
  return { ok: true, subscriber_id: subscriberId };
}

// ── Kit V3 (ConvertKit fallback) ──────────────────────────────────────────────

/**
 * Attempt to subscribe via ConvertKit V3 API, tagging by tag name or id.
 *
 * @param {string} email
 * @param {string} firstName
 * @param {string} tag         — tag name or numeric id
 * @param {string} apiSecret
 * @returns {{ ok: boolean, subscriber_id?: string|number, status?: number }}
 */
async function subscribeV3(email, firstName, tag, apiSecret) {
  const encodedTag = encodeURIComponent(tag);
  const url = `https://api.convertkit.com/v3/tags/${encodedTag}/subscribe`;

  const bodyObj = { api_secret: apiSecret, email };
  if (firstName) bodyObj.first_name = firstName;

  const res = await fetch(url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(bodyObj),
  });

  if (!res.ok) {
    return { ok: false, status: res.status };
  }

  const json = await res.json();
  // V3 returns `subscription.subscriber.id`
  const subscriberId = json?.subscription?.subscriber?.id ?? json?.subscriber?.id ?? null;
  return { ok: true, subscriber_id: subscriberId };
}

// ── Public API ────────────────────────────────────────────────────────────────

/**
 * Add a user to Kit nurture after free-scan completion.
 *
 * @param {object} opts
 * @param {string} opts.email       — subscriber email (required)
 * @param {string} opts.tag         — Kit tag name or id to apply
 * @param {string} [opts.firstName] — optional first name for personalisation
 * @returns {Promise<{ ok: boolean, subscriber_id?: string|number, skipped?: boolean, reason?: string, error?: unknown }>}
 */
async function addToKitNurture({ email, tag, firstName = '' }) {
  const apiKey    = process.env.KIT_API_KEY;
  const apiSecret = process.env.KIT_API_SECRET;

  if (!apiKey && !apiSecret) {
    console.warn('[kit] KIT_API_KEY/SECRET missing — skipping nurture handoff for ' + email);
    return { ok: false, skipped: true, reason: 'no-key' };
  }

  try {
    // ── Attempt V4 first (requires KIT_API_KEY) ───────────────────────────────
    if (apiKey) {
      log(`[kit] attempting V4 subscribe for ${email} (tag: ${tag})`);
      const v4Result = await subscribeV4(email, firstName, apiKey);

      if (v4Result.ok) {
        log(`[kit] V4 subscribe succeeded`, { email, subscriber_id: v4Result.subscriber_id });
        return { ok: true, subscriber_id: v4Result.subscriber_id };
      }

      log(`[kit] V4 returned status=${v4Result.status} — falling back to V3`);
    }

    // ── Fall back to V3 (requires KIT_API_SECRET) ─────────────────────────────
    if (apiSecret) {
      log(`[kit] attempting V3 subscribe for ${email} (tag: ${tag})`);
      const v3Result = await subscribeV3(email, firstName, tag, apiSecret);

      if (v3Result.ok) {
        log(`[kit] V3 subscribe succeeded`, { email, subscriber_id: v3Result.subscriber_id });
        return { ok: true, subscriber_id: v3Result.subscriber_id };
      }

      const msg = `[kit] addToKitNurture failed (status=${v3Result.status} message=V3 non-2xx) — continuing without nurture`;
      console.warn(msg);
      return { ok: false, error: { status: v3Result.status } };
    }

    // KIT_API_KEY present but V4 failed and no KIT_API_SECRET for V3
    console.warn(`[kit] addToKitNurture failed (status=V4_fail message=no-api-secret-for-v3-fallback) — continuing without nurture`);
    return { ok: false, error: { reason: 'v4-failed-no-v3-secret' } };

  } catch (err) {
    const status  = err?.status ?? err?.code ?? 'network-error';
    const message = err?.message ?? String(err);
    console.warn(`[kit] addToKitNurture failed (status=${status} message=${message}) — continuing without nurture`);
    return { ok: false, error: err };
  }
}

module.exports = { addToKitNurture };
