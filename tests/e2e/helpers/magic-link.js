// tests/e2e/helpers/magic-link.js
//
// Bridge to the CommonJS signer at api/_lib/magic-link.js. Playwright loads
// .spec.js files as ESM, so top-level `require()` fails. We use dynamic
// import() and return promises.

async function loadSigner() {
  const mod = await import('../../../api/_lib/magic-link.js');
  // CommonJS `module.exports = { signMagicLink, verifyMagicLink }` — Node
  // exposes those as both default-shaped and named exports.
  const sign = mod.signMagicLink || mod.default?.signMagicLink;
  if (typeof sign !== 'function') {
    throw new Error('helpers/magic-link.js: signMagicLink not found in api/_lib/magic-link.js');
  }
  return sign;
}

/**
 * Mint a token via the production signer.
 * @param {{ email: string, scanId: string, ttlMs?: number }} opts
 * @returns {Promise<string>}
 */
export async function signToken({ email, scanId, ttlMs }) {
  const sign = await loadSigner();
  return sign({ email, scanId, ttlMs });
}

/**
 * Return the full URL the email CTA would point to.
 * @param {{ baseUrl: string, email: string, scanId: string, ttlMs?: number }} opts
 * @returns {Promise<string>}
 */
export async function mintMagicLinkUrl({ baseUrl, email, scanId, ttlMs }) {
  const token = await signToken({ email, scanId, ttlMs });
  return `${baseUrl}/api/magic-link?token=${encodeURIComponent(token)}`;
}
