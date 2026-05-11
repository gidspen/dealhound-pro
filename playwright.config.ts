import { defineConfig, devices } from '@playwright/test';

// Override with: E2E_BASE_URL=https://staging.dealhound.pro npm run e2e
// Default assumes `vercel dev` running locally on :3000 (so /api/* routes work).
const BASE_URL = process.env.E2E_BASE_URL || 'http://localhost:3000';

export default defineConfig({
  testDir: './tests/e2e',
  testMatch: '**/*.spec.{js,ts}',
  fullyParallel: false,           // serial: shared DB state, agent ordering
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 1 : 0,
  workers: 1,                      // single worker — DB cleanup races otherwise
  reporter: [
    ['list'],
    ['html', { open: 'never', outputFolder: 'playwright-report' }],
  ],
  use: {
    baseURL: BASE_URL,
    trace: 'retain-on-failure',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
    viewport: { width: 1280, height: 800 },
    actionTimeout: 10_000,
    navigationTimeout: 30_000,
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
    // Mobile viewport — uncomment when we want to verify mobile UX
    // {
    //   name: 'mobile-safari',
    //   use: { ...devices['iPhone 13'] },
    // },
  ],
});
