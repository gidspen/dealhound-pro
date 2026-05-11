// tests/e2e/flow-e-paywall-upgrade-modal.spec.js
//
// Flow E — Free user → tries to scan → hits paywall → sees UpgradeModal
// See docs/USER_FLOWS.md §Flow E for the contract (Option A locked).
//
// This spec verifies the END of Flow E: that the paywall response from
// /api/scan-start (or the SSE 'paywall' event from /api/chat) opens the
// UpgradeModal with the right copy and the Founding CTA POSTs to
// /api/create-checkout. We DO NOT exercise the chat LLM here — we drive
// the modal directly by writing to the upgradeModal signal, then assert
// the user-facing behavior.
//
// Why this approach: the chat path requires a fully-working /api/chat
// (Anthropic + Supabase + Stripe creds), which adds slowness and cost.
// The modal contract is the testable surface. The chat-driven path is
// covered by Flow G with a real worker.

import { test, expect } from '@playwright/test';
import { freshTestEmail } from './helpers/test-email.js';
import { seedUser, deleteUser } from './helpers/personas.js';

test.describe('Flow E — Paywall + UpgradeModal', () => {
  let testEmail;

  test.beforeEach(async () => {
    testEmail = freshTestEmail('flow-e');
    await seedUser({ email: testEmail }); // free user, no tier
  });

  test.afterEach(async () => {
    await deleteUser(testEmail);
  });

  test('E4a: no_subscription reason → Founding pitch + CTAs', async ({ page }) => {
    await page.goto('/dashboard');
    await page.fill('input[type=email]', testEmail);
    await page.click('button:has-text("Open Dashboard")');
    await expect(page.locator('#app-shell')).toBeVisible({ timeout: 10_000 });

    // Trigger the modal as if a paywall SSE event fired
    await page.evaluate(() => {
      // Reach into the module via a tagged window hook — set by app on mount.
      // If no global is exposed, dispatch a synthetic event that lib/api.js wires.
      if (window.__dh_setUpgradeModal) {
        window.__dh_setUpgradeModal({ reason: 'no_subscription', tier: null });
      } else {
        // Fallback: trigger via the buy-box-saved-style custom event hook
        window.dispatchEvent(new CustomEvent('dh-test-open-upgrade', {
          detail: { reason: 'no_subscription', tier: null },
        }));
      }
    });

    // Modal copy assertions
    await expect(page.locator('text=/Become a Founding Member/i')).toBeVisible({ timeout: 5000 });
    await expect(page.locator('text=/\\$49\\/mo/i').first()).toBeVisible();
    await expect(page.locator('text=/lifetime/i').first()).toBeVisible();

    // Primary CTA: Founding $49/mo → POST /api/create-checkout
    const reqPromise = page.waitForRequest(
      (r) => r.url().includes('/api/create-checkout') && r.method() === 'POST'
    );

    // Block the actual Stripe redirect so we don't navigate away
    await page.route('**/api/create-checkout', async (route) => {
      const body = JSON.parse(route.request().postData() || '{}');
      // Echo a mocked Stripe URL back
      await route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify({
          url: `https://checkout.stripe.com/c/pay/cs_test_mock?tier=${body.tier}`,
        }),
      });
    });

    await page.click('button:has-text("Become a Founding Member")');

    const req = await reqPromise;
    const body = JSON.parse(req.postData() || '{}');
    expect(body.tier).toBe('founding');
    expect(body.email).toBe(testEmail);
  });

  test('E4b: out_of_runs reason → top-up pitch + CTA', async ({ page }) => {
    await page.goto('/dashboard');
    await page.fill('input[type=email]', testEmail);
    await page.click('button:has-text("Open Dashboard")');
    await expect(page.locator('#app-shell')).toBeVisible({ timeout: 10_000 });

    await page.evaluate(() => {
      if (window.__dh_setUpgradeModal) {
        window.__dh_setUpgradeModal({
          reason: 'out_of_runs',
          tier: 'founding',
          runs_used: 10,
          runs_limit: 10,
          bonus_runs: 0,
        });
      } else {
        window.dispatchEvent(new CustomEvent('dh-test-open-upgrade', {
          detail: {
            reason: 'out_of_runs',
            tier: 'founding',
            runs_used: 10,
            runs_limit: 10,
          },
        }));
      }
    });

    await expect(page.locator('text=/out of runs/i').first()).toBeVisible({ timeout: 5000 });
    await expect(page.locator('text=/10 \\/ 10/').first()).toBeVisible();

    const reqPromise = page.waitForRequest(
      (r) => r.url().includes('/api/create-checkout') && r.method() === 'POST'
    );
    await page.route('**/api/create-checkout', async (route) => {
      await route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify({ url: 'https://checkout.stripe.com/c/pay/cs_test_topup' }),
      });
    });

    await page.click('button:has-text("Top up 5 runs")');
    const req = await reqPromise;
    const body = JSON.parse(req.postData() || '{}');
    expect(body.tier).toBe('topup');
    expect(body.email).toBe(testEmail);
  });

  test('E-fail: Founding 409 (cap full) → falls back to Hunter', async ({ page }) => {
    await page.goto('/dashboard');
    await page.fill('input[type=email]', testEmail);
    await page.click('button:has-text("Open Dashboard")');
    await expect(page.locator('#app-shell')).toBeVisible({ timeout: 10_000 });

    let callCount = 0;
    await page.route('**/api/create-checkout', async (route) => {
      callCount++;
      const body = JSON.parse(route.request().postData() || '{}');
      if (body.tier === 'founding') {
        await route.fulfill({
          status: 409,
          contentType: 'application/json',
          body: JSON.stringify({ error: 'Founding Member spots are full' }),
        });
      } else if (body.tier === 'hunter') {
        await route.fulfill({
          status: 200,
          contentType: 'application/json',
          body: JSON.stringify({ url: 'https://checkout.stripe.com/c/pay/cs_test_hunter' }),
        });
      }
    });

    await page.evaluate(() => {
      if (window.__dh_setUpgradeModal) {
        window.__dh_setUpgradeModal({ reason: 'no_subscription', tier: null });
      } else {
        window.dispatchEvent(new CustomEvent('dh-test-open-upgrade', {
          detail: { reason: 'no_subscription', tier: null },
        }));
      }
    });

    await expect(page.locator('text=/Become a Founding Member/i')).toBeVisible({ timeout: 5000 });
    await page.click('button:has-text("Become a Founding Member")');

    // 409 → modal shows "Falling back to Hunter…" then auto-retries on Hunter
    await expect(page.locator('text=/Founding|spots are full|Falling back/i').first()).toBeVisible({ timeout: 4000 });

    // Wait for the auto-fallback Hunter call (1.5s setTimeout in component)
    await page.waitForRequest(
      (r) => {
        if (!r.url().includes('/api/create-checkout') || r.method() !== 'POST') return false;
        const body = JSON.parse(r.postData() || '{}');
        return body.tier === 'hunter';
      },
      { timeout: 5000 }
    );

    expect(callCount).toBeGreaterThanOrEqual(2); // founding + hunter
  });
});
