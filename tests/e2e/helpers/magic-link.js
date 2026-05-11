// tests/e2e/helpers/magic-link.js
//
// Wraps api/_lib/magic-link.js so tests can mint signed tokens without
// having to drive the full email pipeline. Used by Flow C (magic-link claim)
// and any flow that needs a logged-in dashboard quickly.

const { signMagicLink } = require('../../../api/_lib/magic-link');

/**
 * mintMagicLinkUrl({ baseUrl, email, scanId, ttlMs? })
 *
 * Returns the full URL the email CTA would point to:
 *   {baseUrl}/api/magic-link?token=...
 */
export function mintMagicLinkUrl({ baseUrl, email, scanId, ttlMs }) {
  const token = signMagicLink({ email, scanId, ttlMs });
  return `${baseUrl}/api/magic-link?token=${encodeURIComponent(token)}`;
}
