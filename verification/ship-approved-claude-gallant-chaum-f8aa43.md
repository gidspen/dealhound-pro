# Ship Approval — claude/gallant-chaum-f8aa43

## Intent

Unblock the target launch-prep outcome ("user submits buy box → receives scan-complete email → clicks magic link → lands in dashboard with scan loaded") by fixing the three things that were preventing it: (1) the worker had `RESEND_API_KEY` missing in `.env.local` so no scan-complete email had been sent in 7 days; (2) `worker/email-sender.js` silently reported `{ok: true}` even when Resend rejected via response body, hiding deliverability failures; (3) Crexi description enrichment was 100% failing because the scraper's generic selectors never matched Crexi's `<crx-asset-description-card>` Angular components and only waited 400 ms post-load. Also adds a real e2e harness (Flow B + Flow C) and an `html_snapshot` column on `deals` so future re-extraction doesn't require re-scraping. All 8 existing/new Playwright e2e tests pass against prod (Flow C × 3, D × 4, L × 1). Flow B is gated behind `DEALHOUND_E2E_ALLOW_REAL_INBOX=true` so it can't fire by accident.

## Files changed

- `worker/email-sender.js` — both `sendFreeScanCompleteEmail` and `sendScheduledScanCompleteEmail` now check `response.error` and return `{ok: false, error}`. Previously the Resend SDK's 4xx response body bypassed the try/catch and silently logged "sent".
- `tests/integration/email-sender-resend-error.test.js` — new vitest covering the no-key short-circuit path and a guarded live silent-pass guard.
- `tests/e2e/helpers/test-email.js` — adds `freshInboxEmail(flow)` for `gideon+dh-e2e-{flow}-{ts}-{rand}@stonemontcap.com` aliases (gated by `DEALHOUND_E2E_ALLOW_REAL_INBOX=true`) and expands `isTestEmail()` to safely accept both legacy `@dealhound.dev` and the new aliases.
- `tests/e2e/helpers/personas.js` — adds `seedCompletedScan({email, dealCount})` which inserts a `deal_searches` row plus N hard-filter-passing fake deals; lets Flow C test the dashboard claim flow without running the actual worker.
- `tests/e2e/helpers/magic-link.js` — rewritten as ESM-safe async wrapper (`signToken`, `mintMagicLinkUrl`). Previous version mixed `require` with `export` which broke under Playwright's ESM loader.
- `tests/e2e/flow-c-magic-link-claim.spec.js` — new spec. Mints a signed magic-link token, drives `/api/magic-link?token=` → 302 → `/dashboard`, asserts `localStorage.dh_email` is set, query params stripped, and seeded deals render. Three tests including tampered-token and expired-token 401 cases.
- `tests/e2e/flow-b-worker-pipeline.spec.js` — new spec. Submits a real free-scan against prod, polls `deal_searches` to `complete`, asserts deals exist, warns if Crexi is missing, and verifies the magic-link round-trip end-to-end. Gated; intentionally not run from `npm run e2e`.
- `package.json` — three new scripts: `e2e:env` (loads `.env`), `e2e:prod` (points at production), `e2e:real` (production + real-inbox flag for Flow B).
- `scripts/migrations/2026-05-15-deals-html-snapshot.sql` — adds `deals.html_snapshot text`. Applied to prod DB.
- `docs/SKILLS_CHANGELOG.md` — tracks scraper-side changes that live at `~/skills/find-deals/` (outside this repo) so reviewers can correlate with product changes. Initial entry documents the Crexi description enrichment + html_snapshot capture.

## Confirmation

No files outside the intended scope were modified.
