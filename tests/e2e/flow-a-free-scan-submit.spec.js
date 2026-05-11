// tests/e2e/flow-a-free-scan-submit.spec.js
//
// Flow A — Anonymous Visitor → Free Scan Submission
// See docs/USER_FLOWS.md §Flow A for the full contract.
//
// What this spec asserts:
//   1. The marketing homepage exposes a clear path to /free-scan
//   2. The /free-scan form accepts the documented buy-box fields
//   3. Submitting POSTs to /api/free-scan-start with the right payload
//   4. The user sees a "we're searching" confirmation in-page (no redirect)
//   5. A users row + deal_searches row + scrape_jobs row are created in DB
//
// Failure modes covered:
//   - missing required field → no submit
//   - honeypot field (bot) → silently dropped
//
// Pre-conditions:
//   - .env loaded (SUPABASE_URL, SUPABASE_SERVICE_KEY)
//   - dev server reachable at E2E_BASE_URL (default http://localhost:3000)

import { test, expect } from '@playwright/test';
import { createClient } from '@supabase/supabase-js';
import { freshTestEmail } from './helpers/test-email.js';
import { deleteUser } from './helpers/personas.js';

const sb = () => createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_KEY);

test.describe('Flow A — Free scan submission', () => {
  let testEmail;

  test.beforeEach(() => {
    testEmail = freshTestEmail('flow-a');
  });

  test.afterEach(async () => {
    await deleteUser(testEmail);
  });

  test('A1: homepage exposes "Run a Free Scan" CTA', async ({ page }) => {
    await page.goto('/');
    // Hero positioning per LAUNCH_STRATEGY: "Your AI deal team"
    await expect(page.locator('text=/AI deal team/i').first()).toBeVisible();
    // CTA — link href OR button that routes to /free-scan
    const cta = page.locator('a[href*="/free-scan"], button:has-text("Free Scan")').first();
    await expect(cta).toBeVisible();
  });

  test('A2-A5: full submission → confirmation + DB rows', async ({ page }) => {
    await page.goto('/free-scan');

    // Form fields per free-scan/index.html
    await page.selectOption('[name=assetType]', 'Micro Resort');
    await page.fill('[name=market]', 'Blue Ridge Mountains, NC');
    await page.fill('[name=priceMin]', '500000');
    await page.fill('[name=priceMax]', '2500000');
    await page.fill('[name=email]', testEmail);

    // Watch the request fire
    const reqPromise = page.waitForRequest(
      (r) => r.url().includes('/api/free-scan-start') && r.method() === 'POST'
    );
    const respPromise = page.waitForResponse((r) => r.url().includes('/api/free-scan-start'));

    await page.click('button[type=submit]');

    const req = await reqPromise;
    const body = JSON.parse(req.postData() || '{}');
    expect(body.email).toBe(testEmail);
    expect(body.assetType).toBe('Micro Resort');
    expect(body.market).toBe('Blue Ridge Mountains, NC');
    expect(String(body.priceMin)).toBe('500000');
    expect(String(body.priceMax)).toBe('2500000');
    // Honeypot must be empty (real users never fill it)
    expect(body._hp || body.website || '').toBe('');

    const resp = await respPromise;
    if (resp.status() === 429) {
      // Rate limit hit — this IP already ran a free scan in the last 24h.
      // It IS the right behavior in production; just means we can't repeat the
      // happy-path assertion now. Skip cleanly so the suite stays trustworthy.
      test.skip(
        true,
        'IP rate-limited (429). Re-run from a fresh IP, or wait 24h, or run against vercel dev.'
      );
      return;
    }
    expect(resp.status(), 'expected 2xx from /api/free-scan-start').toBeLessThan(300);

    // Confirmation panel appears in-page (no redirect away)
    await expect(
      page.locator('text=/searching now|in your inbox|hunter|on the case/i').first()
    ).toBeVisible({
      timeout: 10_000,
    });
    expect(page.url()).toContain('/free-scan');

    // DB assertions: user + deal_searches + scrape_jobs rows
    const supabase = sb();
    const { data: user } = await supabase
      .from('users')
      .select('email, agent_name')
      .eq('email', testEmail)
      .single();
    expect(user, 'users row not created').toBeTruthy();
    expect(user.agent_name, 'agent_name not assigned').toBeTruthy();

    const { data: searches } = await supabase
      .from('deal_searches')
      .select('id, status, buy_box')
      .eq('user_email', testEmail);
    expect(searches?.length, 'deal_searches row not created').toBeGreaterThanOrEqual(1);

    const searchIds = searches.map((s) => s.id);
    const { data: jobs } = await supabase
      .from('scrape_jobs')
      .select('search_id, status')
      .in('search_id', searchIds);
    expect(jobs?.length, 'scrape_jobs row not enqueued').toBeGreaterThanOrEqual(1);
  });

  test('A-fail-1: missing assetType blocks submit', async ({ page }) => {
    await page.goto('/free-scan');
    await page.fill('[name=market]', 'Anywhere');
    await page.fill('[name=priceMin]', '100000');
    await page.fill('[name=priceMax]', '500000');
    await page.fill('[name=email]', testEmail);

    let posted = false;
    page.on('request', (r) => {
      if (r.url().includes('/api/free-scan-start') && r.method() === 'POST') posted = true;
    });

    await page.click('button[type=submit]');
    await page.waitForTimeout(800);

    expect(posted, 'request should NOT fire without required assetType').toBe(false);
  });

  test('A-fail-2: honeypot-filled submission gets no DB row', async ({ page }) => {
    await page.goto('/free-scan');
    await page.selectOption('[name=assetType]', 'Boutique Hotel');
    await page.fill('[name=market]', 'Anywhere');
    await page.fill('[name=priceMin]', '100000');
    await page.fill('[name=priceMax]', '500000');
    await page.fill('[name=email]', testEmail);
    // Bots fill the honeypot
    await page.evaluate(() => {
      const el = document.querySelector('input[name=website]');
      if (el) el.value = 'http://bot.example.com';
    });

    await page.click('button[type=submit]');
    await page.waitForTimeout(2000);

    const supabase = sb();
    const { data: user } = await supabase
      .from('users')
      .select('email')
      .eq('email', testEmail)
      .single();
    expect(user, 'honeypot fill should NOT create a user row').toBeNull();
  });
});
