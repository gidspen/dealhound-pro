// api/_lib/magic-link.js
//
// Sign / verify HMAC magic link tokens. Pure module — no I/O.
//
// Token format: base64url(JSON({ e, s, x, sig }))
//   e   — email
//   s   — scan_id (string; may be a free_scan_request UUID or a deal_searches UUID)
//   x   — expires_at (unix ms)
//   sig — base64url HMAC-SHA256 over `${e}|${s}|${x}` using process.env.MAGIC_LINK_SECRET
//         (falls back to SUPABASE_SERVICE_KEY if MAGIC_LINK_SECRET unset)

'use strict';

const crypto = require('crypto');

function getSecret() {
  const secret = process.env.MAGIC_LINK_SECRET || process.env.SUPABASE_SERVICE_KEY;
  if (!secret) {
    throw new Error(
      'magic-link: no secret configured. Set MAGIC_LINK_SECRET or SUPABASE_SERVICE_KEY.'
    );
  }
  return secret;
}

function base64urlEncode(buf) {
  return buf
    .toString('base64')
    .replace(/\+/g, '-')
    .replace(/\//g, '_')
    .replace(/=+$/, '');
}

function base64urlDecode(str) {
  // Pad to a multiple of 4 then restore standard base64 chars
  const padded = str.replace(/-/g, '+').replace(/_/g, '/');
  const padding = (4 - (padded.length % 4)) % 4;
  return Buffer.from(padded + '='.repeat(padding), 'base64');
}

function computeSig(email, scanId, expiresAt, secret) {
  const payload = `${email}|${scanId}|${expiresAt}`;
  const hmac = crypto.createHmac('sha256', secret);
  hmac.update(payload);
  return base64urlEncode(hmac.digest());
}

/**
 * Sign a magic link token.
 * @param {{ email: string, scanId: string, ttlMs?: number }} opts
 * @returns {string} opaque token string safe for URL embedding
 */
function signMagicLink({ email, scanId, ttlMs = 24 * 60 * 60 * 1000 }) {
  if (!email || !scanId) {
    throw new Error('magic-link: email and scanId are required');
  }
  const secret = getSecret();
  const expiresAt = Date.now() + ttlMs;
  const sig = computeSig(email, scanId, expiresAt, secret);
  const payload = JSON.stringify({ e: email, s: scanId, x: expiresAt, sig });
  return base64urlEncode(Buffer.from(payload, 'utf8'));
}

/**
 * Verify a magic link token.
 * @param {string} token
 * @returns {{ ok: true, email: string, scanId: string } | { ok: false, reason: string }}
 */
function verifyMagicLink(token) {
  if (!token || typeof token !== 'string') {
    return { ok: false, reason: 'missing token' };
  }

  let parsed;
  try {
    const json = base64urlDecode(token).toString('utf8');
    parsed = JSON.parse(json);
  } catch {
    return { ok: false, reason: 'malformed token' };
  }

  const { e: email, s: scanId, x: expiresAt, sig } = parsed;

  if (!email || !scanId || !expiresAt || !sig) {
    return { ok: false, reason: 'missing fields' };
  }

  if (typeof expiresAt !== 'number' || expiresAt < Date.now()) {
    return { ok: false, reason: 'token expired' };
  }

  let secret;
  try {
    secret = getSecret();
  } catch (err) {
    return { ok: false, reason: err.message };
  }

  const expected = computeSig(email, scanId, expiresAt, secret);
  const expectedBuf = Buffer.from(expected, 'utf8');
  const actualBuf = Buffer.from(sig, 'utf8');

  // Reject before timingSafeEqual if lengths differ (avoids RangeError)
  if (expectedBuf.length !== actualBuf.length) {
    return { ok: false, reason: 'invalid signature' };
  }

  const valid = crypto.timingSafeEqual(expectedBuf, actualBuf);
  if (!valid) {
    return { ok: false, reason: 'invalid signature' };
  }

  return { ok: true, email, scanId };
}

module.exports = { signMagicLink, verifyMagicLink };
