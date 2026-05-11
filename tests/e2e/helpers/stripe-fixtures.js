// tests/e2e/helpers/stripe-fixtures.js
//
// Stripe test-mode utilities. Two modes:
//
//   1. STRIPE_MODE=mock (default for CI) — no real Stripe calls. Use for
//      tests that only need to verify the create-checkout endpoint shape
//      or stub the redirect.
//
//   2. STRIPE_MODE=test — uses STRIPE_TEST_SECRET_KEY to hit Stripe's real
//      test environment. Use for Flow F (full upgrade) and Flow K (webhook).
//
// To make Flow K usable end-to-end you'll need:
//   - STRIPE_TEST_SECRET_KEY set in .env
//   - STRIPE_TEST_WEBHOOK_SECRET set
//   - stripe CLI installed for `stripe listen --forward-to ...`
//   - Test products + prices created in Stripe dashboard, IDs in:
//       STRIPE_PRICE_FOUNDING, STRIPE_PRICE_HUNTER, STRIPE_PRICE_INVESTOR,
//       STRIPE_PRICE_OPERATOR, STRIPE_PRICE_TOPUP
//
// Until those are set, mock mode is the only thing that runs.

const MOCK_CHECKOUT_URL = 'https://checkout.stripe.com/c/pay/cs_test_mock';

export const stripeMode = () => (process.env.STRIPE_TEST_SECRET_KEY ? 'test' : 'mock');

/**
 * mockCreateCheckoutResponse({ tier }) — what the API should return in mock mode.
 * Tests that don't actually want to hit Stripe can intercept the network call
 * and fulfil with this body.
 */
export function mockCreateCheckoutResponse({ tier }) {
  return {
    url: `${MOCK_CHECKOUT_URL}?tier=${tier}`,
  };
}

/**
 * Triggers a checkout.session.completed webhook event against the local
 * stripe listener. Requires:
 *   - stripe CLI installed
 *   - `stripe listen --forward-to localhost:3000/api/stripe-webhook` running
 *
 * Falls back to a no-op if STRIPE_TEST_SECRET_KEY missing.
 */
export async function triggerTestWebhook(eventType, overrides = {}) {
  if (stripeMode() === 'mock') {
    console.warn(`triggerTestWebhook(${eventType}): STRIPE_TEST_SECRET_KEY missing, skipping`);
    return null;
  }
  // TODO: wire stripe CLI invocation when test keys are configured.
  // import { execSync } from 'node:child_process';
  // const args = JSON.stringify({ event: eventType, ...overrides });
  // execSync(`stripe trigger ${eventType} --override ${args}`);
  throw new Error('triggerTestWebhook: not yet implemented — see TODO in stripe-fixtures.js');
}
