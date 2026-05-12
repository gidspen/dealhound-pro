# Ship approval: fix/email-rate-limit

## Intent

Add a lifetime per-email rate limit (1 free scan per email forever) to `/api/free-scan-start`, sitting in front of the existing per-IP 24h limit. Closes a known abuse vector where the same email plus a new IP yielded a fresh $1.50 scan. Also folds in a Phase 0 fix to the vitest test script so `npm test` loads `.env` automatically via Node's `--env-file` flag — previously the integration suite failed on clean shells because `tests/e2e/helpers/personas.js` requires `SUPABASE_URL` / `SUPABASE_SERVICE_KEY` at module load.

## Files changed

- `api/free-scan-start.js` — adds the email-count Supabase query and the 429 short-circuit immediately before the IP-count guard. Fails open on query error, identical to the IP guard's behavior.
- `package.json` — `test` script now runs `node --env-file=.env node_modules/.bin/vitest run tests/integration` so the integration suite picks up Supabase credentials without a manual `source .env`.
- `tests/integration/free-scan-rate-limit.test.js` — new file. Three cases: same-email + new-IP → 429, fresh-email + same-IP-within-24h → 429 (existing guard preserved), fresh-email + new-IP → 200 happy path. Supabase is mocked via Node's `Module._load` patch (the handler is CJS, so `vi.mock` does not intercept its `require`).

## Confirmation

No files outside the intended scope were modified.
