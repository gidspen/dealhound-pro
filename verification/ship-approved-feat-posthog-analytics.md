# Ship approval: feat/posthog-analytics

## Intent

Wire 11 PostHog funnel events end-to-end across the marketing site, free-scan form, dashboard app, worker, magic-link handler, and Stripe webhook. Establishes baseline funnel telemetry for the launch funnel (home → free scan → magic link → dashboard → buy box → paywall → upgrade → checkout). Token delivery for client-side analytics chose option (a): inline the public `phc_*` ingestion-only project token directly in the three HTML entrypoints. Server-side uses `posthog-node` via a lazy helper at `api/_lib/posthog.js`. The branch also folds in the same Phase 0 vitest `--env-file=.env` fix used in PR #54 so the integration suite stays green on clean shells.

## Files changed

- `index.html` — PostHog browser snippet in `<head>`; `home_viewed` capture in `<body>`.
- `free-scan/index.html` — PostHog snippet; `free_scan_form_started` on first form focus; `free_scan_submitted` after 200.
- `dashboard/index.html` (vite source) and `dashboard-dist/index.html` (build output) — PostHog snippet loaded before the app bundle so `window.posthog` is ready by the time the app mounts.
- `dashboard/src/app.jsx` — `dashboard_loaded` + `posthog.identify(email)` after `loadUserData()` resolves.
- `dashboard/src/lib/api.js` — `buy_box_saved` and `scan_start_paywalled` inside the SSE event-type branches.
- `dashboard/src/components/UpgradeModal.jsx` — `upgrade_modal_shown` on mount; `checkout_started` before the checkout redirect.
- `worker/worker.js` — `free_scan_email_sent` server-side after Resend send.
- `api/_lib/magic-link-route.js` — `magic_link_clicked` server-side after `verifyMagicLink` success.
- `api/stripe-webhook.js` — `checkout_completed` server-side inside `checkout.session.completed`.
- `api/_lib/posthog.js` — new lazy helper for `posthog-node`. Safe to require when env vars are absent (capture no-ops).
- `package.json` + `package-lock.json` — adds `posthog-node` runtime dep; test script switched to `node --env-file=.env node_modules/.bin/vitest run tests/integration` (same Phase 0 fix as PR #54).

## Confirmation

No files outside the intended scope were modified.
