// tests/e2e/helpers/test-email.js
//
// Two test-email generators with an explicit isTestEmail() safety check that
// personas.deleteUser() consults before any DB mutation.
//
//   freshTestEmail(flow)   → e2e-{flow}-{ts}-{rand}@dealhound.dev
//     Default. Use when no real email delivery needs to be observed.
//     The @dealhound.dev domain has no real recipients, so even if a stray
//     send path fires, nothing escapes to a real inbox.
//
//   freshInboxEmail(flow)  → gideon+dh-e2e-{flow}-{ts}-{rand}@stonemontcap.com
//     Use ONLY in flows that must verify a real email actually delivered
//     (Flow B: worker scan → email). Routes to gideon@stonemontcap.com via
//     Gmail +aliasing. Guarded by DEALHOUND_E2E_ALLOW_REAL_INBOX=true so we
//     never accidentally email a real address from a CI run.

const REAL_INBOX_FLAG = 'DEALHOUND_E2E_ALLOW_REAL_INBOX';

export function freshTestEmail(flow = 'misc') {
  const ts = Date.now();
  const rand = Math.random().toString(36).slice(2, 8);
  return `e2e-${flow}-${ts}-${rand}@dealhound.dev`;
}

/**
 * Generate a Gmail-aliased address that routes to gideon@stonemontcap.com.
 * Guarded by an env flag so accidental CI invocations don't email a real inbox.
 *
 * @param {string} flow short tag for log/audit (e.g. 'flow-b')
 * @returns {string} gideon+dh-e2e-{flow}-{ts}-{rand}@stonemontcap.com
 */
export function freshInboxEmail(flow = 'misc') {
  if (process.env[REAL_INBOX_FLAG] !== 'true') {
    throw new Error(
      `freshInboxEmail refused: set ${REAL_INBOX_FLAG}=true to allow ` +
        'tests that deliver to a real inbox (gideon+dh-e2e-*@stonemontcap.com).'
    );
  }
  const ts = Date.now();
  const rand = Math.random().toString(36).slice(2, 8);
  return `gideon+dh-e2e-${flow}-${ts}-${rand}@stonemontcap.com`;
}

/**
 * Safety gate for personas.deleteUser etc. Accepts:
 *   1. @dealhound.dev (never used by real users)
 *   2. gideon+dh-e2e-... or gideon+dh-test-... @stonemontcap.com (Gmail aliases)
 */
export function isTestEmail(email) {
  if (!email) return false;
  return (
    /^e2e-[a-z0-9-]+-\d+-[a-z0-9]+@dealhound\.dev$/.test(email) ||
    /^gideon\+dh-(e2e|test)-[a-z0-9_.-]+@stonemontcap\.com$/i.test(email)
  );
}
