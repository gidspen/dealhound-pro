// tests/e2e/helpers/test-email.js
//
// Generates collision-free test emails. Uses the dealhound.dev domain
// (matches the smoke test convention in tests/smoke/smoke.test.js)
// so production never accidentally emails a real address.
//
// Pattern: e2e-{flow}-{timestamp}-{random}@dealhound.dev
// The flow tag makes it easy to identify which spec created a row when
// auditing the users table or cleaning up by hand.

export function freshTestEmail(flow = 'misc') {
  const ts = Date.now();
  const rand = Math.random().toString(36).slice(2, 8);
  return `e2e-${flow}-${ts}-${rand}@dealhound.dev`;
}

export function isTestEmail(email) {
  return /^e2e-[a-z0-9-]+-\d+-[a-z0-9]+@dealhound\.dev$/.test(email || '');
}
