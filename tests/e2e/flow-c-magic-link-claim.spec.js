// tests/e2e/flow-c-magic-link-claim.spec.js
//
// Flow C — Magic Link → First Dashboard Claim
// See docs/USER_FLOWS.md §Flow C for the full contract.
//
// What this spec asserts:
//   1. A signed magic-link token round-trips through the API:
//      GET /api/magic-link?token=... → 302 → /dashboard?email=X&scan_id=Y&from=magic
//   2. The dashboard boots, sets localStorage.dh_email, and strips the query
//      params via history.replaceState.
//   3. The seeded scan and its deals appear in the preview pane.
//
// Pre-conditions:
//   - .env loaded: SUPABASE_URL, SUPABASE_SERVICE_KEY
//   - E2E_BASE_URL set (defaults to localhost:3000 per playwright.config.ts)
//   - The base URL has /api/magic-link wired (production does; vercel dev does too)
//
// This spec does NOT require Resend or the worker — it short-circuits the
// pipeline by seeding a completed scan + deals directly into Supabase.

import { test, expect } from '@playwright/test';
import { freshTestEmail } from './helpers/test-email.js';
import { deleteUser, seedCompletedScan } from './helpers/personas.js';
import { signToken } from './helpers/magic-link.js';

test.describe('Flow C — magic link claims dashboard', () => {
  let testEmail;
  let searchId;
  let dealIds;

  test.beforeEach(async () => {
    testEmail = freshTestEmail('flow-c');
    ({ searchId, dealIds } = await seedCompletedScan({ email: testEmail, dealCount: 3 }));
  });

  test.afterEach(async () => {
    await deleteUser(testEmail);
  });

  test('C1-C5: signed token → 302 → dashboard loads scan + deals', async ({ page, baseURL }) => {
    expect(searchId, 'seedCompletedScan must return a searchId').toBeTruthy();
    expect(dealIds.length, 'seedCompletedScan must produce deals').toBeGreaterThan(0);

    const token = await signToken({ email: testEmail, scanId: searchId });
    const magicUrl = `/api/magic-link?token=${encodeURIComponent(token)}`;

    // C1-C2 — follow the magic link. Playwright follows the 302 automatically;
    // we just need to confirm we landed on /dashboard.
    const respPromise = page.waitForResponse(
      (r) => r.url().includes('/api/magic-link') && r.request().method() === 'GET'
    );
    await page.goto(magicUrl);
    const resp = await respPromise;
    expect(resp.status(), 'magic-link should respond 302').toBe(302);

    // Wait for the dashboard SPA to boot.
    await page.waitForURL(/\/dashboard(\?|$)/, { timeout: 15_000 });

    // C2 — localStorage.dh_email set to the magic-link email.
    const lsEmail = await page.evaluate(() => localStorage.getItem('dh_email'));
    expect(lsEmail, 'dashboard must persist dh_email after magic-link').toBe(testEmail);

    // Query params should be stripped via history.replaceState after the SPA
    // consumes them. Give the app a tick to do that.
    await page.waitForFunction(() => !window.location.search.includes('from=magic'), null, {
      timeout: 5_000,
    });

    // C4-C5 — preview panel should render a seeded deal title.
    // The seeded deals are tagged "[E2E] Test Property N — TIER".
    await expect(page.locator('text=/\\[E2E\\] Test Property/').first()).toBeVisible({
      timeout: 15_000,
    });
  });

  test('C-fail-1: tampered token returns 401', async ({ page }) => {
    const token = await signToken({ email: testEmail, scanId: searchId });
    // Flip the last character of the token; anything but a no-op edit will
    // break the HMAC signature.
    const broken = token.slice(0, -1) + (token.slice(-1) === 'A' ? 'B' : 'A');
    const resp = await page.request.get(`/api/magic-link?token=${encodeURIComponent(broken)}`, {
      maxRedirects: 0,
    });
    expect(resp.status()).toBe(401);
  });

  test('C-fail-2: expired token returns 401', async ({ page }) => {
    // Token signed with negative TTL → already expired.
    const expired = await signToken({ email: testEmail, scanId: searchId, ttlMs: -1000 });
    const resp = await page.request.get(`/api/magic-link?token=${encodeURIComponent(expired)}`, {
      maxRedirects: 0,
    });
    expect(resp.status()).toBe(401);
  });
});
