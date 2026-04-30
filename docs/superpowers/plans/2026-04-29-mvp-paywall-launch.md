# Deal Hound MVP Paywall Launch Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship Stripe-backed paywall, scan metering, and DB-backed settings — turning Deal Hound from a free demo into a chargeable MVP.

**Architecture:** Add `subscription_*` and `free_scans_used` columns to the existing `users` table (no new tables — the relation is 1:1). Three new API routes wrap Stripe Checkout, Customer Portal, and a webhook receiver. The buy-box save handler in `api/chat.js` becomes the single server-side gate: it checks `users.free_scans_used >= 1 AND subscription_status != 'active'` and returns a paywall payload instead of inserting `deal_searches`. Frontend gets a subscription-aware `New Scan` button, a paywall message in chat, and a real Settings billing section that links to Stripe Customer Portal.

**Tech Stack:** Node.js (CommonJS) on Vercel serverless, Stripe Node SDK (`stripe` npm), `@supabase/supabase-js`, Preact + signals, vitest, Supabase Auth (magic link), PostHog (analytics). Stripe is in test mode through this plan; flipping to live mode is part of the wake-up checklist.

---

## SPEC AMENDMENTS — Post-CEO-Review (2026-04-30)

This plan was originally drafted with a simple "1 free scan = paywall" model. After Gideon clarified the spec, the model evolved significantly. This amendment block captures all changes from the post-write spec session and the CEO review. Implementer must apply ALL of these on top of the original phase definitions below.

### A1. Metering model: HOT/STRONG threshold, not simple counter

The plan's original `free_scans_used INTEGER` column and "1 scan free, then paywall" logic is REPLACED with:

- New column: `has_qualifying_free_scan BOOLEAN DEFAULT FALSE` on `users` table
- A scan "qualifies" when its results contain ≥1 HOT MATCH OR ≥10 STRONG MATCH deals (read from `deals.score_breakdown.strategy.overall`)
- Free user can keep scanning until they get a qualifying scan; agent suggests buy-box loosening between attempts
- Once qualifying, `has_qualifying_free_scan = true`. Next scan attempt → paywall.

**Where computed:** at gate time in `api/chat.js`, query the user's deals across all their scans. If any deal has `score_breakdown.strategy.overall = 'HOT MATCH'` OR they have ≥10 deals with `'STRONG MATCH'`, set `has_qualifying_free_scan` true (write-through cache). Active subscribers bypass the check.

**Agent flow change:** when a scan completes below threshold, agent's debrief message includes a specific buy-box loosening suggestion (e.g. "Your acreage minimum of 50 might be too tight — try 25 to see more candidates"). System prompt update in `api/chat.js` `buildDebriefPrompt()`.

### A2. Pricing structure

- Stripe Price: $97/mo monthly recurring (rack rate)
- Stripe Coupon: `FOUNDER` (or similar) — 50% off forever, applied via promo code at Checkout
- Effective price for early users: $48.50/mo (close enough to $49)
- Both prices: 1 buy box (overwrite-on-save), daily pool refresh against their buy box, $6/mo chat token budget
- Stripe Checkout: `allow_promotion_codes: true` (already in original plan ✓)
- Wake-up checklist must include: create the FOUNDER coupon in Stripe Dashboard

### A3. Token budget tracking

Free user: $1.50/mo. Paid user: $6.00/mo. Both expressed in cents in DB.

New columns on `users`:
- `chat_tokens_used_cents INTEGER DEFAULT 0`
- `chat_tokens_reset_at TIMESTAMPTZ DEFAULT now()`

Per-message accounting in `api/deal-chat.js` and `api/chat.js`:
- Before request: lazy-reset (if `reset_at + 30 days < now()`, set `tokens_used_cents = 0` and `reset_at = now()`)
- Calculate budget remaining: `(subscription_tier === 'pro' ? 600 : 150) - tokens_used_cents`
- If remaining ≤ 0: write SSE event `{type: 'token_exhausted', renew_at: <ISO date>}`. Do NOT call Anthropic.
- After response: compute cost cents from `usage.input_tokens × $3/M + usage.output_tokens × $15/M` (Sonnet pricing). Add to `chat_tokens_used_cents`.

UI: when `token_exhausted` event arrives, render "Your free chat allotment renews on [date]" message in chat. Do NOT show dollar amount. Show only the renewal date.

### A4. Magic-link auth (Supabase Auth)

- Replace `localStorage.dh_email = X` with `supabase.auth.signInWithOtp({ email })`
- New page: `/auth/callback.html` — handles redirect from email link, calls `supabase.auth.getSession()`, persists JWT, redirects to `/dashboard`
- All API endpoints must read JWT from `Authorization: Bearer <token>` header and verify against Supabase. Email comes from JWT, not body/query.
- Cherry-pick #2 (resend flow): on email gate, after first send, show "Email sent. Didn't get it? Resend" with 60-second client-side throttle.
- Callback page error handling: `?error=expired_token` or `?error=invalid_token` → render "Link expired. Send a new one?" CTA back to email gate.

**JWT migration boundary (Section 1+3 finding):** ALL existing endpoints must be updated to read user identity from JWT, not from body/query email. List: `chat.js`, `deal-chat.js`, `user-data.js`, `scan-start.js`, `scan-progress.js`, `star-deal.js`, `view-deal.js`, `archive-deal.js`, `conversation.js`, `archive-deal.js`. New endpoints (`stripe-*`, `user-settings`, `auth/callback`) get JWT from day one.

Add helper `api/_lib/auth.js`:
```javascript
async function getUserFromRequest(req) {
  const authHeader = req.headers.authorization || '';
  const token = authHeader.replace('Bearer ', '');
  if (!token) throw new Error('Missing auth token');
  const { data: { user }, error } = await supabase.auth.getUser(token);
  if (error || !user) throw new Error('Invalid token');
  return user; // user.email is canonical
}
```

Test required: each endpoint rejects requests without valid JWT (401).

### A5. Cancel-but-active subscription state (Section 2 finding)

`canScan` logic must include canceled-but-period-end-in-future as active. Update `api/_lib/user.js`:

```javascript
const ACTIVE_STATUSES = new Set(['active', 'trialing']);
function isSubscriptionActive(user) {
  if (ACTIVE_STATUSES.has(user.subscription_status)) return true;
  if (user.subscription_status === 'canceled' &&
      user.subscription_current_period_end &&
      new Date(user.subscription_current_period_end) > new Date()) return true;
  return false;
}
```

### A6. user-settings authorization (Section 3 finding)

`/api/user-settings` PATCH must enforce `JWT.email === target email`. With A4, since email comes from JWT only (not body), this is automatic. Add explicit test.

### A7. return_url validation (Section 3 finding)

In `stripe-checkout.js` and `stripe-portal.js`, validate `return_url` against allowlist:
- Must start with `https://dealhound.pro/`, OR
- Must equal `req.headers.origin` AND origin must be in allowlist

Reject otherwise (open redirect risk).

### A8. Webhook idempotency (Cherry-pick #4)

New table:
```sql
CREATE TABLE stripe_events (
  id TEXT PRIMARY KEY,            -- Stripe event ID
  type TEXT NOT NULL,
  processed_at TIMESTAMPTZ DEFAULT now()
);
CREATE INDEX stripe_events_processed_at_idx ON stripe_events(processed_at);
```

In `stripe-webhook.js`, after signature verification, before processing:
```javascript
const { error } = await supabase
  .from('stripe_events')
  .insert({ id: event.id, type: event.type });
if (error?.code === '23505') { // unique violation = duplicate
  return res.status(200).json({ received: true, deduped: true });
}
// else proceed
```

**Test required:** webhook handler called twice with same event_id processes only once.

### A9. PostHog conversion analytics (Cherry-pick #1)

Add `posthog-js` to dashboard dependencies. Initialize in `dashboard/src/main.jsx`. Capture events:
- `signup_started` — email gate submit
- `signup_completed` — magic link clicked, callback succeeded
- `buy_box_started` — onboarding view loaded
- `buy_box_saved` — save_buy_box tool fired
- `scan_started` — deal_search status → scanning
- `scan_completed` — deal_search status → complete (with `qualifying: bool`)
- `paywall_shown` — `paywall` SSE event received
- `checkout_clicked` — Upgrade button click
- `checkout_completed` — return from Stripe with `?checkout=success`
- `subscription_canceled` — webhook customer.subscription.deleted
- `chat_tokens_exhausted` — token_exhausted SSE event received

PostHog project key in `VITE_POSTHOG_KEY` env var (Vite env, prefixed). Wake-up checklist: Gideon creates PostHog account (free tier), gets project key, adds to Vercel env.

### A10. Usage indicator in Settings (Cherry-pick #3)

In `Settings.jsx` Billing section, add:
- Free tier: "This month: 3 scans, 47% of chat allotment used"
- Paid tier: "Unlimited scans · Chat allotment: 18% used"

Backend already returns the data via A3. Frontend just renders bar. Reset countdown shown only when within 7 days of reset.

### A11. Mac-worker observability (Section 8 finding)

Add `api/admin/health.js` endpoint:
- GET only, no auth (intentional — used by Gideon's manual checks; could add IP allowlist later)
- Returns: `{ stale_scans_30min: N, stale_scans_2hr: M, last_scrape_completed_at: ISO }`
- N>0 means worker may be hung; M>0 means definitely hung

Wake-up checklist: Gideon adds a daily reminder to curl this endpoint.

### A12. Feature flag for paywall (Section 9 recommendation)

Add `ENABLE_PAYWALL` env var to Vercel (string `'true'` or unset). In `api/chat.js` gate:
```javascript
if (process.env.ENABLE_PAYWALL === 'true' && !subState.canScan) { /* paywall */ }
```

Default off. First deploy ships paywall code but doesn't enforce it. After smoke test, flip on.

### A13. Landing page sign-up flow (Section 11 / spec)

Verify `/index.html` "Get started" / "Sign up" CTAs:
- Currently route to `/dashboard` which triggers email gate
- After A4, dashboard email gate triggers magic-link send
- Confirm landing copy ("First scan free") aligns with new HOT/STRONG threshold framing
- If copy says "1 free scan" specifically, soften to "Try it free — adjust until your agent finds matches"

### A14. Chat.js refactor (Section 1 smell)

Extract gate + token logic from `api/chat.js` into `api/_lib/scan-gate.js`:
```javascript
async function checkScanGate(supabase, email) {
  // Returns { allowed: bool, reason: string|null, hasQualifying: bool }
}
async function checkTokenBudget(supabase, email) {
  // Returns { allowed: bool, remaining_cents: int, reset_at: ISO }
}
```

Keeps `chat.js` focused on streaming + tool dispatch.

### A15. Updated wake-up checklist additions

In addition to the original 12 items:
- [ ] Create Stripe coupon `FOUNDER` (50% off forever) in Stripe Dashboard → Products → Coupons
- [ ] Sign up for PostHog (free tier), create project, copy project API key, add as `VITE_POSTHOG_KEY` Vercel env var
- [ ] Configure Supabase Auth: enable Email provider → Magic Link. Default email templates work. (Settings → Authentication → Providers → Email)
- [ ] Set Supabase Auth Site URL to `https://dealhound.pro` and add `https://dealhound.pro/auth/callback` to Redirect URLs allowlist
- [ ] Copy Supabase JWT secret from Supabase Dashboard → Settings → API → "JWT Secret" → add as `SUPABASE_JWT_SECRET` Vercel env var (required by A17 local JWT verification)
- [ ] Generate a random string for `ADMIN_HEALTH_KEY` Vercel env var (required by A19 — `openssl rand -hex 32`)
- [ ] Set `ENABLE_PAYWALL=false` initially in Vercel env vars; flip to `true` after smoke test
- [ ] Run all tests with all env vars set (`npm test`) — financial-critical tests will be skipIf-skipped without keys

---

## SPEC AMENDMENTS — Post-Eng-Review (2026-04-30)

The CEO review locked the strategy and scope. The eng review then audited the implementation plan and surfaced 7 issues. Three were strategic (user-decided); four were tactical (autonomous fix). All landed as the amendments below.

### A16. Pre-debit token tracking (replaces A3's post-record pattern)

**Problem:** A3 records token cost AFTER stream completes. If user disconnects mid-stream, Anthropic still bills us, but we don't bill the user. Margin leak ~5-10% at scale.

**Solution:** pre-debit + refund pattern.

Modify the chat flow in `api/chat.js` and `api/deal-chat.js`:

```javascript
// Step 1: Pre-debit estimate BEFORE calling Anthropic
const estimateCents = estimateMessageCost(messages, MAX_TOKENS);
const budget = await getTokenBudget(supabase, email);
if (budget.remaining_cents < estimateCents) {
  res.write(`data: ${JSON.stringify({ type: 'token_exhausted', renew_at: budget.reset_at })}\n\n`);
  return res.end();
}
await debitTokens(supabase, email, estimateCents);

// Step 2: Stream from Anthropic
let actualUsage = null;
try {
  const stream = await client.messages.stream({...});
  for await (const event of stream) { /* existing */ }
  const final = await stream.finalMessage();
  actualUsage = final.usage; // { input_tokens, output_tokens }
} catch (err) {
  // On error, refund the entire pre-debit
  await refundTokens(supabase, email, estimateCents);
  throw err;
}

// Step 3: Settle — compute actual cost, refund difference
if (actualUsage) {
  const actualCents = computeActualCost(actualUsage); // raw float, no rounding
  const delta = estimateCents - actualCents;
  if (delta > 0) await refundTokens(supabase, email, delta);
  else if (delta < 0) await debitTokens(supabase, email, -delta); // overshoot edge case
}
```

Helper functions in `api/_lib/token.js`:

```javascript
function estimateMessageCost(messages, maxOutputTokens) {
  // Rough char→token: 4 chars per token, then apply Sonnet pricing
  const inputChars = JSON.stringify(messages).length;
  const inputTokens = Math.ceil(inputChars / 4);
  // Pre-debit assumes max output (over-estimate is OK; we refund)
  const cost = (inputTokens * 3 + maxOutputTokens * 15) / 10000; // raw cents (float)
  return Math.ceil(cost); // round UP only at the pre-debit boundary
}

function computeActualCost(usage) {
  // Returns raw float cents — DO NOT ceil here (A20 fix)
  return (usage.input_tokens * 3 + usage.output_tokens * 15) / 10000;
}

async function debitTokens(supabase, email, cents) {
  // Atomic increment via RPC if available, else read-modify-write
  const { data } = await supabase.rpc('increment_token_usage', { p_email: email, p_cents: cents });
  return data;
}

async function refundTokens(supabase, email, cents) {
  return debitTokens(supabase, email, -cents);
}
```

Add a Postgres RPC for atomic increment:

```sql
CREATE OR REPLACE FUNCTION increment_token_usage(p_email TEXT, p_cents NUMERIC)
RETURNS NUMERIC AS $$
DECLARE new_used NUMERIC;
BEGIN
  UPDATE users
  SET chat_tokens_used_cents = GREATEST(0, chat_tokens_used_cents + p_cents)
  WHERE email = p_email
  RETURNING chat_tokens_used_cents INTO new_used;
  RETURN new_used;
END;
$$ LANGUAGE plpgsql;
```

This eliminates the margin leak. Pre-debit conservatively (assume max_tokens output), then settle on actual usage.

### A17. Local JWT verification via jose lib (replaces A4's network-call pattern)

**Problem:** `supabase.auth.getUser(token)` makes a Supabase Auth network call on every API request. 50-100ms latency per call. At 100 active users, this is the slowest hop in the app.

**Solution:** verify JWT signature locally with the `jose` library using Supabase's JWT secret. Network call only at `/auth/callback` to bind email on first login.

Update `api/_lib/auth.js`:

```javascript
const { jwtVerify } = require('jose');
const { createClient } = require('@supabase/supabase-js');

const JWT_SECRET = new TextEncoder().encode(process.env.SUPABASE_JWT_SECRET);

async function getUserFromRequest(req) {
  const authHeader = req.headers.authorization || '';
  const token = authHeader.replace('Bearer ', '');
  if (!token) throw new Error('Missing auth token');

  try {
    const { payload } = await jwtVerify(token, JWT_SECRET, { algorithms: ['HS256'] });
    if (!payload.email || !payload.sub) throw new Error('Token missing email/sub');
    return { id: payload.sub, email: payload.email };
  } catch (err) {
    throw new Error('Invalid token: ' + err.message);
  }
}

// Used only at /auth/callback to bind a fresh user to the DB
async function bindUserFromSession(supabase, accessToken) {
  const { data: { user }, error } = await supabase.auth.getUser(accessToken);
  if (error || !user) throw new Error('Invalid session');
  return user;
}

module.exports = { getUserFromRequest, bindUserFromSession };
```

Add `jose` to `package.json` dependencies (`npm install jose`).

Wake-up: Gideon adds `SUPABASE_JWT_SECRET` env var (in Supabase Dashboard → Settings → API → "JWT Secret"). Already in updated checklist (A15).

### A18. Auth callback as Preact route, not standalone HTML (replaces Phase 8 Task 22)

**Problem:** Plan's Phase 8 Task 22 creates `dashboard/auth-callback.html` as a separate static page. Round-trip through static page breaks Preact SPA continuity and adds a flash of unstyled content.

**Solution:** Add `view: 'auth-callback'` to the Preact router state. Detect the route by URL pattern (`window.location.pathname === '/auth/callback'`), parse the URL fragment via Supabase's `auth.getSession()`, then route to dashboard.

Update `dashboard/src/app.jsx`:

```jsx
import { supabase } from './lib/supabase.js';

function AuthCallback() {
  useEffect(() => {
    (async () => {
      const url = new URL(window.location.href);
      const error = url.searchParams.get('error') || url.hash.includes('error=') ? 'expired_token' : null;
      if (error) {
        window.location.replace('/dashboard?auth_error=' + error);
        return;
      }
      const { data, error: sessionError } = await supabase.auth.getSession();
      if (sessionError || !data.session) {
        window.location.replace('/dashboard?auth_error=invalid_token');
        return;
      }
      // Persist email for compat + identify in PostHog
      localStorage.setItem('dh_email', data.session.user.email);
      window.location.replace('/dashboard');
    })();
  }, []);
  return <div class="auth-callback-loading">Signing you in…</div>;
}

// In App():
if (window.location.pathname === '/auth/callback') {
  return <AuthCallback />;
}
```

Update `vercel.json`:

```json
{ "source": "/auth/callback", "destination": "/dashboard-dist/index.html" }
```

Routes the callback path to the SPA, which handles the rest.

In `EmailGate`, handle `?auth_error=` query params from app.jsx by reading on mount and showing an inline message.

### A19. Admin health endpoint auth via shared key (replaces A11's "no auth")

**Problem:** A11 said "no auth (intentional)" on `/api/admin/health`. Public endpoint that returns operational intel (stale scan counts, last scrape time). Low value to attackers but free reconnaissance.

**Solution:** Require `?key=` query param matching `ADMIN_HEALTH_KEY` env var. Reject 401 otherwise.

Update `api/admin/health.js`:

```javascript
module.exports = async function handler(req, res) {
  if (req.method !== 'GET') return res.status(405).json({});
  const expected = process.env.ADMIN_HEALTH_KEY;
  if (!expected) return res.status(500).json({ error: 'ADMIN_HEALTH_KEY not configured' });
  if (req.query.key !== expected) return res.status(401).json({ error: 'Unauthorized' });
  // ... rest of A11 implementation
};
```

Wake-up: Gideon generates a random key (`openssl rand -hex 32`), adds as `ADMIN_HEALTH_KEY` Vercel env var, curls with `?key=...`. Already in updated checklist (A15).

### A20. Token cost rounding fix (replaces A3's per-call Math.ceil)

**Problem:** A3 formula `Math.ceil(...)` per-call over-charges users by ~30% averaged over many small messages. A 2.25-cent message becomes 3 cents in DB. Free user with $1.50 budget exhausts ~25% faster than designed.

**Solution:** Track raw cents as `NUMERIC(10,4)` in DB (not `INTEGER`). Sum unrounded values. Round only when displayed to user as a percentage or when comparing against budget.

Migration update — change column type:

```sql
ALTER TABLE users
  ALTER COLUMN chat_tokens_used_cents TYPE NUMERIC(10,4) USING chat_tokens_used_cents::NUMERIC(10,4);
```

Helper update — `computeActualCost` returns raw float (already shown in A16). Budget check compares raw values: `if (used_cents >= budget_cents) blocked`. No per-call rounding.

### A21. Phase ordering — extract scan-gate.js BEFORE writing gate logic

**Problem:** Plan's Phase 4 Task 8 writes the scan gate logic inline in `api/chat.js`. Then A14 says extract it to `api/_lib/scan-gate.js`. Implementer would write it twice.

**Solution:** Reorder. Tasks should run in this sequence:

1. (NEW Task 8a, runs FIRST) Create `api/_lib/scan-gate.js` with `checkScanGate(supabase, email)` and `checkTokenBudget(supabase, email)` function signatures.
2. (Original Task 8) In `api/chat.js`, call the extracted helpers — don't inline the logic.

Treat A14 as completed by Task 8a. Skip the "later refactor" step entirely.

### A22. Critical test coverage additions (Boil the Lake)

Eng review identified 14 critical gaps in test coverage. All added to scope. New test files:

**Unit tests (api/_lib/):**
- `tests/unit/scan-gate.test.js` (NEW): HOT/STRONG threshold counting
  - 0 HOT + 0 STRONG → not qualifying, allowed
  - 1 HOT + 0 STRONG → qualifying
  - 0 HOT + 9 STRONG → not qualifying, allowed (edge: one short)
  - 0 HOT + 10 STRONG → qualifying
  - Active subscription bypass
- `tests/unit/token-budget.test.js` (per A3, expanded): lazy reset, exhaustion, paid budget, **cost calc accuracy** (test that 2.25-cent messages don't over-charge), pre-debit + refund flow
- `tests/unit/auth.test.js` (NEW): missing token → throw, invalid signature → throw, valid token → returns email, expired token → throw
- `tests/unit/subscription-active.test.js` (NEW): active, trialing, canceled+future-period-end, canceled+past-period-end, past_due

**Integration tests (api/):**
- `tests/integration/return-url-validation.test.js` (NEW): stripe-checkout and stripe-portal reject malicious return_urls (not on allowlist), accept valid ones
- `tests/integration/webhook-handlers.test.js` (NEW): each event type — created, updated, deleted, checkout.session.completed, invoice.payment_failed — produces correct DB state changes
- `tests/integration/token-tracking.test.js` (NEW): pre-debit happens before stream, refund happens on completion, refund happens on error, disconnect mid-stream still leaves user debited
- `tests/integration/admin-health-auth.test.js` (NEW): missing key → 401, wrong key → 401, correct key → 200

**E2E tests (deferred — no E2E framework yet):**
- First-time magic-link signup flow [→TODO]
- Free user qualifying scan → paywall on next attempt [→TODO]
- Free user non-qualifying → agent suggests loosening → retry loop [→TODO]
- Paid user cancels in Customer Portal → retains access until period_end [→TODO]
- FOUNDER coupon at checkout [→TODO]

E2E framework setup (Playwright) is its own project, deferring to a follow-up sprint per Gideon's "1 buy box, 1 scan/day" MVP scope. The unit + integration tests cover the financial/security critical paths.

**Total new test count:** 8 new test files, ~50 new test cases. Adds ~2 hrs CC time to plan.

---

## Autonomous Decisions Made (no Gideon input needed)

These are decisions I made tonight without waking Gideon, with rationale. He can override any of these in the morning.

1. **Subscription state lives on the `users` table** as columns, not a new `subscriptions` table. Reason: 1:1 relationship, simpler query path, no joins in the hot path.
2. **One free scan per user, ever** (not per month). Reason: Gideon stated "first scan free" — interpreted strictly. Easier to relax later than to tighten.
3. **The pool-match path counts as a scan.** A `save_buy_box` tool call is what increments `free_scans_used`, regardless of whether it triggered an actual scrape or matched the pool. Reason: from the user's perspective, they ran a scan and got results. Otherwise users could cycle buy boxes against the pool indefinitely.
4. **Paywall gate fires at `save_buy_box`, not at "New Scan" click.** Server-side gate is canonical. The frontend ALSO shows a lock on "New Scan" pre-emptively, but the server gate is the source of truth.
5. **Customer Portal handles cancel/upgrade/payment-method/invoice history.** No custom cancel UI. Reason: Stripe-hosted is compliance-clean and saves hours.
6. **Webhook events listened to:** `checkout.session.completed`, `customer.subscription.created`, `customer.subscription.updated`, `customer.subscription.deleted`, `invoice.payment_failed`. Reason: covers the full activation/cancellation/dunning lifecycle.
7. **Daily digest preference stored as `users.digest_enabled` boolean.** No per-time-of-day, no per-frequency for MVP — matches what Settings.jsx already shows.
8. **Frontend `dh_email` localStorage stays as-is.** No magic-link auth. Gideon explicitly accepted this for MVP.
9. **Tests added for financial-critical paths only:** webhook signature verification, scan-gate logic. Frontend changes get a smoke check via `vite build`.
10. **No code in the worker (Mac heartbeat agent).** Out of scope per Gideon.

---

## Wake-Up Checklist for Gideon

When Gideon wakes up, here's exactly what he must do **outside the codebase** to make this go live. Code is shipped; configuration is on him.

### Stripe Dashboard (https://dashboard.stripe.com)

- [ ] **1. Create or confirm Stripe account.** Switch the Dashboard to **Test mode** for initial testing.
- [ ] **2. Create the product.** Products → Add product → Name: "Deal Hound Pro" → Pricing: $29.00 USD recurring monthly. Save. Copy the **Price ID** (looks like `price_1ABC...`).
- [ ] **3. Configure Customer Portal.** Settings → Billing → Customer portal:
   - Allow customers to: cancel subscriptions, update payment method, view invoice history
   - Cancellation behavior: cancel at end of period (recommended)
   - Save changes.
- [ ] **4. Add webhook endpoint.** Developers → Webhooks → Add endpoint:
   - Endpoint URL: `https://dealhound.pro/api/stripe-webhook`
   - Events to listen for: `checkout.session.completed`, `customer.subscription.created`, `customer.subscription.updated`, `customer.subscription.deleted`, `invoice.payment_failed`
   - After saving, click "Reveal" next to "Signing secret" and copy it (`whsec_...`).
- [ ] **5. Copy your API keys.** Developers → API keys:
   - `STRIPE_SECRET_KEY` = "Secret key" (`sk_test_...`)
   - `STRIPE_PUBLISHABLE_KEY` = "Publishable key" (`pk_test_...`)

### Vercel Dashboard (https://vercel.com)

- [ ] **6. Add four env vars** to the `dealhound-pro` project (Settings → Environment Variables). Add to **all environments** (Production, Preview, Development):
   - `STRIPE_SECRET_KEY` = `sk_test_...`
   - `STRIPE_PUBLISHABLE_KEY` = `pk_test_...`
   - `STRIPE_PRICE_ID` = `price_...`
   - `STRIPE_WEBHOOK_SECRET` = `whsec_...`

### Local `.env` (so local tests pass)

- [ ] **7. Append the same four vars** to `/Users/gideonspencer/dealhound-pro/.env`.

### Deploy + Verify

- [ ] **8. Re-run tests with Stripe env vars set:** the `tests/integration/stripe-webhook.test.js` "happy path" suite is `skipIf`-skipped without Stripe env vars. After adding the four env vars to `.env`, run `npm test` and confirm those tests now run and pass.
- [ ] **9. Merge `mvp-launch-paywall` to `main`** (or open a PR and merge from the GitHub UI). Vercel auto-deploys main.
- [ ] **10. Smoke test:** Open dealhound.pro in an incognito window, sign in with a fresh email, run a scan, then click "New Scan" again — paywall should appear. Click "Upgrade" → Stripe Checkout → use test card `4242 4242 4242 4242`. Subscription should activate; New Scan should unlock.
- [ ] **11. Verify webhook signature handling on real Vercel:** Tail logs (`vercel logs --follow` or the Vercel dashboard) and confirm webhook events return 200, not 400. A 400 in production almost always means the raw body handling needs a tweak (see Risks table in the plan).
- [ ] **12. (Optional) Switch Stripe to Live mode.** Repeat Stripe steps 2–5 in Live mode, swap the four env vars in Vercel to the `live` versions, and redeploy.

---

## File Structure

### New files

| File | Responsibility |
|---|---|
| `api/_lib/stripe.js` | Lazy-loaded Stripe client + helpers (`getStripe()`, `getOrCreateCustomer(email)`) |
| `api/_lib/user.js` | User read/write helpers — `getUserSubscriptionState(email)`, `incrementFreeScansUsed(email)`, `setDigestEnabled(email, enabled)` |
| `api/stripe-checkout.js` | POST → creates a Checkout Session for the $29/mo subscription, returns the redirect URL |
| `api/stripe-portal.js` | POST → creates a Customer Portal session, returns the redirect URL |
| `api/stripe-webhook.js` | POST → verifies signature, processes Stripe events, updates `users` table |
| `api/user-settings.js` | GET → returns subscription state + digest preference; PATCH → updates `digest_enabled` |
| `tests/integration/scan-gate.test.js` | Tests that `users.free_scans_used >= 1 AND subscription_status != 'active'` blocks new searches |
| `tests/integration/stripe-webhook.test.js` | Tests webhook signature verification rejection + state mutations on valid events |
| `tests/unit/user-helpers.test.js` | Unit tests for `getUserSubscriptionState` and `incrementFreeScansUsed` |
| `migrations/2026-04-29-add-subscription-columns.sql` | The DDL — checked into source control as a record, even though I run it via Supabase MCP |

### Modified files

| File | What changes |
|---|---|
| `package.json` | Add `"stripe": "^17.5.0"` to `dependencies` |
| `api/chat.js` | Inside `save_buy_box` tool handler: call `getUserSubscriptionState(email)` first; if blocked, write a `paywall` SSE event and skip the `deal_searches` insert. On success, increment `free_scans_used`. |
| `api/user-data.js` | Include `subscription_status`, `free_scans_used`, `digest_enabled` in response payload |
| `dashboard/src/lib/state.js` | Add `subscriptionStatus`, `freeScansUsed`, `digestEnabled`, `paywallOpen` signals |
| `dashboard/src/lib/api.js` | `loadUserData` reads new fields; new `openCheckout()` and `openPortal()` helpers; SSE handler routes `paywall` event type |
| `dashboard/src/components/Settings.jsx` | Replace `alert(...)` with real "Upgrade" button → `openCheckout()`; add "Manage subscription" button when active → `openPortal()`; digest toggle PATCHes `/api/user-settings` |
| `dashboard/src/components/Sidebar.jsx` | "New Scan" button shows lock state when blocked; clicking it opens paywall |
| `dashboard/src/components/Chat.jsx` | Listens for `paywall` SSE event and renders inline upgrade message with CTA button |
| `dashboard/src/styles.css` | Add styles for `.paywall-msg`, `.btn-upgrade`, `.sidebar-new-scan.locked`, `.settings-cancel-btn`, `.settings-manage-btn` |
| `vercel.json` | Add `stripe-checkout`, `stripe-portal`, `stripe-webhook`, `user-settings` to `functions` map |

---

## Phase 0: Branch Setup

### Task 0: Confirm working branch

The agent that wrote this plan already ran `git checkout -b mvp-launch-paywall` before invoking the writing-plans skill. The implementing agent should:

- [ ] **Step 1: Verify branch**

```bash
git branch --show-current
```

Expected: `mvp-launch-paywall`. If the output is `main` or anything else, run `git checkout -b mvp-launch-paywall` (or `git checkout mvp-launch-paywall` if it already exists).

- [ ] **Step 2: Confirm clean baseline**

```bash
git status -s
```

Pre-existing untracked files (`property-data/`, `property-research-suite/`, etc.) are fine — they were untracked before this plan began.

---

## Phase 1: Database + Dependencies

### Task 1: Verify users table schema, write migration

**Files:**
- Create: `migrations/2026-04-29-add-subscription-columns.sql`

- [ ] **Step 1: Inspect current users table** via the Supabase MCP `list_tables` tool, scoped to the public schema. Confirm columns currently are at minimum `email` (PK) and `agent_name`. Note any others for the migration to avoid clashes.

- [ ] **Step 1b: Create migrations dir if needed**

```bash
mkdir -p migrations
```

- [ ] **Step 2: Write the migration SQL** to `migrations/2026-04-29-add-subscription-columns.sql`:

```sql
-- Add subscription + metering + preferences columns to users table.
-- All columns are nullable / defaulted so existing rows continue to work.

ALTER TABLE users
  ADD COLUMN IF NOT EXISTS stripe_customer_id TEXT,
  ADD COLUMN IF NOT EXISTS stripe_subscription_id TEXT,
  ADD COLUMN IF NOT EXISTS subscription_status TEXT DEFAULT 'inactive',
  ADD COLUMN IF NOT EXISTS subscription_current_period_end TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS free_scans_used INTEGER NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS digest_enabled BOOLEAN NOT NULL DEFAULT TRUE;

-- Index on stripe_customer_id for the webhook reverse-lookup path
CREATE INDEX IF NOT EXISTS users_stripe_customer_id_idx
  ON users (stripe_customer_id)
  WHERE stripe_customer_id IS NOT NULL;
```

- [ ] **Step 3: Apply the migration** via Supabase MCP `apply_migration` tool with name `add_subscription_columns_2026_04_29` and the SQL above.

- [ ] **Step 4: Verify the columns exist** by running this SQL via the Supabase MCP `execute_sql` tool:

```sql
SELECT column_name, data_type, column_default, is_nullable
FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'users'
  AND column_name IN (
    'stripe_customer_id', 'stripe_subscription_id', 'subscription_status',
    'subscription_current_period_end', 'free_scans_used', 'digest_enabled'
  )
ORDER BY column_name;
```

Expected: 6 rows returned. If fewer, re-run the migration.

- [ ] **Step 5: Commit**

```bash
git add migrations/
git commit -m "feat(db): add subscription + metering + digest columns to users"
```

### Task 2: Install Stripe SDK

**Files:**
- Modify: `package.json`

- [ ] **Step 1: Add the dependency** by editing `package.json` to include `"stripe": "^17.5.0"` in `dependencies` (alphabetized — between `@supabase/supabase-js` and `preact`).

- [ ] **Step 2: Install** with `npm install` (no `--save` flag needed since it's already in package.json).

- [ ] **Step 3: Verify** by running `node -e "console.log(require('stripe'))"` — should print the function (not an error).

- [ ] **Step 4: Commit**

```bash
git add package.json package-lock.json
git commit -m "feat(deps): add stripe SDK"
```

---

## Phase 2: Backend Helpers

### Task 3: Stripe client helper

**Files:**
- Create: `api/_lib/stripe.js`

- [ ] **Step 1: Write the helper**

```javascript
// api/_lib/stripe.js
const Stripe = require('stripe');

let _stripe = null;
function getStripe() {
  if (_stripe) return _stripe;
  const key = process.env.STRIPE_SECRET_KEY;
  if (!key) throw new Error('STRIPE_SECRET_KEY not configured');
  _stripe = new Stripe(key, { apiVersion: '2024-12-18.acacia' });
  return _stripe;
}

async function getOrCreateCustomer(supabase, email) {
  const { data: user } = await supabase
    .from('users')
    .select('email, stripe_customer_id')
    .eq('email', email)
    .single();

  if (user?.stripe_customer_id) return user.stripe_customer_id;

  const stripe = getStripe();
  const customer = await stripe.customers.create({ email });

  await supabase
    .from('users')
    .update({ stripe_customer_id: customer.id })
    .eq('email', email);

  return customer.id;
}

module.exports = { getStripe, getOrCreateCustomer };
```

- [ ] **Step 2: Commit**

```bash
git add api/_lib/stripe.js
git commit -m "feat(api): add stripe client + customer helper"
```

### Task 4: User helpers — subscription state + scan metering

**Files:**
- Create: `api/_lib/user.js`
- Test: `tests/unit/user-helpers.test.js`

- [ ] **Step 1: Write the failing test**

```javascript
// tests/unit/user-helpers.test.js
import { describe, it, expect, afterAll, beforeEach } from 'vitest';
import { getTestSupabase } from '../helpers/supabase.js';
import { getUserSubscriptionState, incrementFreeScansUsed } from '../../api/_lib/user.js';

const TEST_EMAIL = 'user-helpers-test@dealhound.dev';

describe('user helpers', () => {
  const supabase = getTestSupabase();

  beforeEach(async () => {
    await supabase.from('users').delete().eq('email', TEST_EMAIL);
    await supabase.from('users').insert({ email: TEST_EMAIL, agent_name: 'Test' });
  });

  afterAll(async () => {
    await supabase.from('users').delete().eq('email', TEST_EMAIL);
  });

  it('reports inactive + 0 free scans for a new user', async () => {
    const state = await getUserSubscriptionState(supabase, TEST_EMAIL);
    expect(state.subscription_status).toBe('inactive');
    expect(state.free_scans_used).toBe(0);
    expect(state.canScan).toBe(true);
  });

  it('blocks scan after free scan used', async () => {
    await incrementFreeScansUsed(supabase, TEST_EMAIL);
    const state = await getUserSubscriptionState(supabase, TEST_EMAIL);
    expect(state.free_scans_used).toBe(1);
    expect(state.canScan).toBe(false);
  });

  it('allows scan when subscription is active even with scans used', async () => {
    await incrementFreeScansUsed(supabase, TEST_EMAIL);
    await supabase.from('users').update({ subscription_status: 'active' }).eq('email', TEST_EMAIL);
    const state = await getUserSubscriptionState(supabase, TEST_EMAIL);
    expect(state.canScan).toBe(true);
  });
});
```

- [ ] **Step 2: Run the test, confirm it fails** with module not found.

```bash
npx vitest run tests/unit/user-helpers.test.js
```

- [ ] **Step 3: Implement `api/_lib/user.js`**

```javascript
// api/_lib/user.js
const ACTIVE_STATUSES = new Set(['active', 'trialing']);
const FREE_SCAN_LIMIT = 1;

async function getUserSubscriptionState(supabase, email) {
  const { data, error } = await supabase
    .from('users')
    .select('email, subscription_status, free_scans_used, stripe_customer_id, digest_enabled, subscription_current_period_end')
    .eq('email', email)
    .single();

  if (error || !data) {
    return {
      subscription_status: 'inactive',
      free_scans_used: 0,
      stripe_customer_id: null,
      digest_enabled: true,
      subscription_current_period_end: null,
      canScan: true
    };
  }

  const isActive = ACTIVE_STATUSES.has(data.subscription_status);
  const canScan = isActive || (data.free_scans_used || 0) < FREE_SCAN_LIMIT;

  return {
    subscription_status: data.subscription_status || 'inactive',
    free_scans_used: data.free_scans_used || 0,
    stripe_customer_id: data.stripe_customer_id || null,
    digest_enabled: data.digest_enabled !== false,
    subscription_current_period_end: data.subscription_current_period_end || null,
    canScan
  };
}

async function incrementFreeScansUsed(supabase, email) {
  const { data: current } = await supabase
    .from('users')
    .select('free_scans_used')
    .eq('email', email)
    .single();

  const next = (current?.free_scans_used || 0) + 1;

  await supabase
    .from('users')
    .update({ free_scans_used: next })
    .eq('email', email);

  return next;
}

async function setDigestEnabled(supabase, email, enabled) {
  await supabase
    .from('users')
    .update({ digest_enabled: !!enabled })
    .eq('email', email);
}

module.exports = {
  getUserSubscriptionState,
  incrementFreeScansUsed,
  setDigestEnabled,
  FREE_SCAN_LIMIT,
  ACTIVE_STATUSES
};
```

- [ ] **Step 4: Run the test, confirm it passes.**

```bash
npx vitest run tests/unit/user-helpers.test.js
```

- [ ] **Step 5: Commit**

```bash
git add api/_lib/user.js tests/unit/user-helpers.test.js
git commit -m "feat(api): user subscription state + free scan metering helpers"
```

---

## Phase 3: Stripe API Endpoints

### Task 5: Checkout session endpoint

**Files:**
- Create: `api/stripe-checkout.js`

- [ ] **Step 1: Write the endpoint**

```javascript
// api/stripe-checkout.js
const { createClient } = require('@supabase/supabase-js');
const { getStripe, getOrCreateCustomer } = require('./_lib/stripe.js');

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_KEY
);

module.exports = async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');

  if (req.method === 'OPTIONS') {
    res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
    return res.status(200).end();
  }

  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const { email, return_url } = req.body || {};
  if (!email) return res.status(400).json({ error: 'Missing email' });

  const priceId = process.env.STRIPE_PRICE_ID;
  if (!priceId) return res.status(500).json({ error: 'STRIPE_PRICE_ID not configured' });

  try {
    const customerId = await getOrCreateCustomer(supabase, email);
    const stripe = getStripe();

    const baseUrl = return_url || (req.headers.origin || 'https://dealhound.pro');

    const session = await stripe.checkout.sessions.create({
      mode: 'subscription',
      customer: customerId,
      line_items: [{ price: priceId, quantity: 1 }],
      success_url: `${baseUrl}/dashboard?checkout=success`,
      cancel_url: `${baseUrl}/dashboard?checkout=cancel`,
      allow_promotion_codes: true,
      subscription_data: {
        metadata: { user_email: email }
      }
    });

    return res.status(200).json({ url: session.url });
  } catch (err) {
    console.error('stripe-checkout error:', err.message);
    return res.status(500).json({ error: err.message });
  }
};
```

- [ ] **Step 2: Commit**

```bash
git add api/stripe-checkout.js
git commit -m "feat(api): stripe checkout session endpoint"
```

### Task 6: Customer portal endpoint

**Files:**
- Create: `api/stripe-portal.js`

- [ ] **Step 1: Write the endpoint**

```javascript
// api/stripe-portal.js
const { createClient } = require('@supabase/supabase-js');
const { getStripe, getOrCreateCustomer } = require('./_lib/stripe.js');

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_KEY
);

module.exports = async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');

  if (req.method === 'OPTIONS') {
    res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
    return res.status(200).end();
  }

  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const { email, return_url } = req.body || {};
  if (!email) return res.status(400).json({ error: 'Missing email' });

  try {
    const customerId = await getOrCreateCustomer(supabase, email);
    const stripe = getStripe();

    const baseUrl = return_url || (req.headers.origin || 'https://dealhound.pro');

    const session = await stripe.billingPortal.sessions.create({
      customer: customerId,
      return_url: `${baseUrl}/dashboard`
    });

    return res.status(200).json({ url: session.url });
  } catch (err) {
    console.error('stripe-portal error:', err.message);
    return res.status(500).json({ error: err.message });
  }
};
```

- [ ] **Step 2: Commit**

```bash
git add api/stripe-portal.js
git commit -m "feat(api): stripe customer portal session endpoint"
```

### Task 7: Webhook receiver

**Files:**
- Create: `api/stripe-webhook.js`
- Test: `tests/integration/stripe-webhook.test.js`

- [ ] **Step 1: Write the failing test** — covers signature rejection + the happy-path subscription update.

```javascript
// tests/integration/stripe-webhook.test.js
import { describe, it, expect, afterAll, beforeEach } from 'vitest';
import Stripe from 'stripe';
import { getTestSupabase } from '../helpers/supabase.js';

const TEST_EMAIL = 'webhook-test@dealhound.dev';
const STRIPE_CUSTOMER_ID = 'cus_test_webhookflow';
const STRIPE_SUB_ID = 'sub_test_webhookflow';

// Skip suite if Stripe keys aren't configured
const HAS_STRIPE = process.env.STRIPE_SECRET_KEY && process.env.STRIPE_WEBHOOK_SECRET;

describe.skipIf(!HAS_STRIPE)('stripe-webhook', () => {
  const supabase = getTestSupabase();

  beforeEach(async () => {
    await supabase.from('users').delete().eq('email', TEST_EMAIL);
    await supabase.from('users').insert({
      email: TEST_EMAIL,
      agent_name: 'Test',
      stripe_customer_id: STRIPE_CUSTOMER_ID
    });
  });

  afterAll(async () => {
    await supabase.from('users').delete().eq('email', TEST_EMAIL);
  });

  it('rejects requests with invalid signature', async () => {
    const handler = require('../../api/stripe-webhook.js');
    const req = {
      method: 'POST',
      headers: { 'stripe-signature': 'invalid' },
      rawBody: Buffer.from('{}')
    };
    const res = mockRes();
    await handler(req, res);
    expect(res.statusCode).toBe(400);
  });

  it('activates user on customer.subscription.created with valid signature', async () => {
    const handler = require('../../api/stripe-webhook.js');
    const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);
    const payload = JSON.stringify({
      id: 'evt_test',
      type: 'customer.subscription.created',
      data: {
        object: {
          id: STRIPE_SUB_ID,
          customer: STRIPE_CUSTOMER_ID,
          status: 'active',
          current_period_end: Math.floor(Date.now() / 1000) + 30 * 86400
        }
      }
    });
    const sig = stripe.webhooks.generateTestHeaderString({
      payload,
      secret: process.env.STRIPE_WEBHOOK_SECRET
    });
    const req = {
      method: 'POST',
      headers: { 'stripe-signature': sig },
      rawBody: Buffer.from(payload)
    };
    const res = mockRes();
    await handler(req, res);
    expect(res.statusCode).toBe(200);

    const { data: user } = await supabase
      .from('users')
      .select('subscription_status, stripe_subscription_id')
      .eq('email', TEST_EMAIL)
      .single();
    expect(user.subscription_status).toBe('active');
    expect(user.stripe_subscription_id).toBe(STRIPE_SUB_ID);
  });
});

function mockRes() {
  const res = {
    statusCode: 200,
    body: null,
    headers: {},
    setHeader(k, v) { this.headers[k] = v; },
    status(code) { this.statusCode = code; return this; },
    json(obj) { this.body = obj; return this; },
    end() { return this; }
  };
  return res;
}
```

- [ ] **Step 2: Run test, confirm failure** (module not found).

```bash
npx vitest run tests/integration/stripe-webhook.test.js
```

- [ ] **Step 3: Implement the webhook handler**

> **IMPORTANT — Vercel raw body handling:** Stripe signature verification requires the EXACT raw bytes Stripe sent. Vercel's Node runtime auto-parses JSON when `Content-Type: application/json`, which mutates the body and breaks signature checks. Two reliable patterns: (a) **export `config.api.bodyParser=false`** to opt out of parsing — this works on Vercel for Node-runtime serverless functions, and `req` becomes a readable stream you collect chunks from. (b) **Use the Stripe-recommended fallback** that handles both pre-parsed and raw cases. We use approach (a). The implementer must verify by checking that `req` IS a stream when this handler runs in Vercel — log `typeof req.on === 'function'` once during smoke testing. If Vercel's behavior has changed, fall back to receiving the body as `req.body` (string when bodyParser is disabled) and `Buffer.from(req.body, 'utf8')`.

```javascript
// api/stripe-webhook.js
const { createClient } = require('@supabase/supabase-js');
const { getStripe } = require('./_lib/stripe.js');

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_KEY
);

// Vercel: opt out of automatic body parsing so the signature check sees raw bytes.
// This config export is read by Vercel's Node runtime at deploy time.
module.exports.config = { api: { bodyParser: false } };

async function readRawBody(req) {
  // Test frameworks may pre-supply rawBody as a Buffer
  if (req.rawBody && Buffer.isBuffer(req.rawBody)) return req.rawBody;

  // If the runtime already parsed the body despite our config (defensive fallback),
  // try to recover. This will only succeed if the body is still the raw string —
  // if it's been JSON.parsed into an object, the signature check will fail and
  // we want it to fail loudly rather than silently re-stringify (which would
  // produce different bytes than Stripe sent).
  if (typeof req.body === 'string') return Buffer.from(req.body, 'utf8');
  if (Buffer.isBuffer(req.body)) return req.body;

  // Standard path: req is a readable stream. Collect chunks.
  const chunks = [];
  for await (const chunk of req) {
    chunks.push(typeof chunk === 'string' ? Buffer.from(chunk) : chunk);
  }
  return Buffer.concat(chunks);
}

async function handleSubscriptionEvent(sub) {
  const customerId = sub.customer;
  const status = sub.status;
  const periodEnd = sub.current_period_end
    ? new Date(sub.current_period_end * 1000).toISOString()
    : null;

  await supabase
    .from('users')
    .update({
      stripe_subscription_id: sub.id,
      subscription_status: status,
      subscription_current_period_end: periodEnd
    })
    .eq('stripe_customer_id', customerId);
}

async function handleCheckoutCompleted(session) {
  // Subscription mode: stripe will fire customer.subscription.created right after.
  // We just attach the customer if not already attached (defensive).
  if (session.mode !== 'subscription') return;
  const customerId = session.customer;
  const email = session.customer_details?.email || session.customer_email;
  if (!customerId || !email) return;

  await supabase
    .from('users')
    .update({ stripe_customer_id: customerId })
    .eq('email', email)
    .is('stripe_customer_id', null);
}

module.exports = async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const secret = process.env.STRIPE_WEBHOOK_SECRET;
  if (!secret) return res.status(500).json({ error: 'STRIPE_WEBHOOK_SECRET not configured' });

  const sig = req.headers['stripe-signature'];
  if (!sig) return res.status(400).json({ error: 'Missing stripe-signature header' });

  let event;
  try {
    const rawBody = await readRawBody(req);
    const stripe = getStripe();
    event = stripe.webhooks.constructEvent(rawBody, sig, secret);
  } catch (err) {
    console.error('stripe-webhook signature error:', err.message);
    return res.status(400).json({ error: `Webhook signature verification failed: ${err.message}` });
  }

  try {
    switch (event.type) {
      case 'customer.subscription.created':
      case 'customer.subscription.updated':
      case 'customer.subscription.deleted':
        await handleSubscriptionEvent(event.data.object);
        break;
      case 'checkout.session.completed':
        await handleCheckoutCompleted(event.data.object);
        break;
      case 'invoice.payment_failed':
        // Stripe will also fire customer.subscription.updated → status=past_due.
        // Logging only here.
        console.log('Invoice payment failed for customer:', event.data.object.customer);
        break;
      default:
        console.log('Unhandled stripe event:', event.type);
    }
    return res.status(200).json({ received: true });
  } catch (err) {
    console.error('stripe-webhook handler error:', err.message);
    return res.status(500).json({ error: err.message });
  }
};
module.exports.handler = module.exports;
```

- [ ] **Step 4: Run test** — should pass for the signature-rejection case at minimum. (The signed-event case requires `STRIPE_SECRET_KEY` and `STRIPE_WEBHOOK_SECRET` to be set; if they're not, the suite is `skipIf`-skipped, which is correct.)

```bash
npx vitest run tests/integration/stripe-webhook.test.js
```

- [ ] **Step 5: Commit**

```bash
git add api/stripe-webhook.js tests/integration/stripe-webhook.test.js
git commit -m "feat(api): stripe webhook receiver with signature verification"
```

---

## Phase 4: Scan Gate + User-Settings Endpoint

### Task 8: Add scan-count gate to chat.js

**Files:**
- Modify: `api/chat.js`
- Test: `tests/integration/scan-gate.test.js`

- [ ] **Step 1: Write the failing test**

```javascript
// tests/integration/scan-gate.test.js
import { describe, it, expect, afterAll, beforeEach } from 'vitest';
import { getTestSupabase } from '../helpers/supabase.js';
import { getUserSubscriptionState } from '../../api/_lib/user.js';

const TEST_EMAIL = 'scan-gate-test@dealhound.dev';

describe('scan gate', () => {
  const supabase = getTestSupabase();

  beforeEach(async () => {
    await supabase.from('deal_searches').delete().eq('user_email', TEST_EMAIL);
    await supabase.from('users').delete().eq('email', TEST_EMAIL);
    await supabase.from('users').insert({ email: TEST_EMAIL, agent_name: 'Test' });
  });

  afterAll(async () => {
    await supabase.from('deal_searches').delete().eq('user_email', TEST_EMAIL);
    await supabase.from('users').delete().eq('email', TEST_EMAIL);
  });

  it('allows first scan for new user', async () => {
    const state = await getUserSubscriptionState(supabase, TEST_EMAIL);
    expect(state.canScan).toBe(true);
  });

  it('blocks second scan after free scan consumed and no subscription', async () => {
    await supabase.from('users').update({ free_scans_used: 1 }).eq('email', TEST_EMAIL);
    const state = await getUserSubscriptionState(supabase, TEST_EMAIL);
    expect(state.canScan).toBe(false);
  });

  it('allows unlimited scans when subscription is active', async () => {
    await supabase.from('users').update({
      free_scans_used: 99,
      subscription_status: 'active'
    }).eq('email', TEST_EMAIL);
    const state = await getUserSubscriptionState(supabase, TEST_EMAIL);
    expect(state.canScan).toBe(true);
  });
});
```

- [ ] **Step 2: Run test, confirm it passes** (this just exercises the helper, which is already implemented). If it fails, fix the helper.

- [ ] **Step 3: Patch `api/chat.js`** — add the gate inside the `save_buy_box` tool handler, before the `deal_searches` insert. Increment `free_scans_used` after the insert succeeds.

The current code (lines 225-348) needs three edits:

   **3a.** At the top of the file, after the supabase require, add:

   ```javascript
   const { getUserSubscriptionState, incrementFreeScansUsed } = require('./_lib/user.js');
   ```

   **3b.** Inside the `content_block_stop` branch where `toolUse.name === 'save_buy_box'` is handled, immediately after parsing `buyBox` (after the `try { buyBox = JSON.parse(toolUse.partial); } catch { ... continue; }` block) and before the `console.log('Saving buy box...`, insert the gate:

   ```javascript
   const subState = await getUserSubscriptionState(supabase, email);
   if (!subState.canScan) {
     res.write(`data: ${JSON.stringify({
       type: 'paywall',
       reason: 'free_scan_used',
       free_scans_used: subState.free_scans_used,
       subscription_status: subState.subscription_status
     })}\n\n`);
     toolUse = null;
     continue; // skip the rest of this block — no DB writes
   }
   ```

   **Note on `continue`:** The existing parse-error branch (~line 234 of the current `chat.js`) already uses `continue;` inside this same `for await (const event of stream)` loop. So `continue` is the established pattern here. If for some reason the implementer is editing a refactored version where `continue` is no longer in a loop, replace with: write the SSE event, set `toolUse = null;`, and wrap the rest of the original block in `else { ... }`.

   **3c.** After the `deal_searches` insert succeeds and the buy_box_saved event is written (right before `toolUse = null;` at the end of the block), add:

   ```javascript
   try {
     await incrementFreeScansUsed(supabase, email);
   } catch (incErr) {
     console.error('Failed to increment free_scans_used:', incErr.message);
   }
   ```

- [ ] **Step 4: Run all tests** to make sure nothing broke.

```bash
npm test
```

- [ ] **Step 5: Commit**

```bash
git add api/chat.js tests/integration/scan-gate.test.js
git commit -m "feat(api): scan-count gate + free scan metering in chat handler"
```

### Task 9: User-settings endpoint

**Files:**
- Create: `api/user-settings.js`

- [ ] **Step 1: Write the endpoint**

```javascript
// api/user-settings.js
const { createClient } = require('@supabase/supabase-js');
const { getUserSubscriptionState, setDigestEnabled } = require('./_lib/user.js');

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_KEY
);

module.exports = async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');

  if (req.method === 'OPTIONS') {
    res.setHeader('Access-Control-Allow-Methods', 'GET, PATCH, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
    return res.status(200).end();
  }

  if (req.method === 'GET') {
    const email = req.query.email;
    if (!email) return res.status(400).json({ error: 'Missing email' });
    try {
      const state = await getUserSubscriptionState(supabase, email);
      return res.status(200).json(state);
    } catch (err) {
      console.error('user-settings GET error:', err.message);
      return res.status(500).json({ error: err.message });
    }
  }

  if (req.method === 'PATCH') {
    const { email, digest_enabled } = req.body || {};
    if (!email) return res.status(400).json({ error: 'Missing email' });
    try {
      if (typeof digest_enabled === 'boolean') {
        await setDigestEnabled(supabase, email, digest_enabled);
      }
      const state = await getUserSubscriptionState(supabase, email);
      return res.status(200).json(state);
    } catch (err) {
      console.error('user-settings PATCH error:', err.message);
      return res.status(500).json({ error: err.message });
    }
  }

  return res.status(405).json({ error: 'Method not allowed' });
};
```

- [ ] **Step 2: Commit**

```bash
git add api/user-settings.js
git commit -m "feat(api): user-settings GET + PATCH for digest preference"
```

### Task 10: Surface subscription state on user-data

**Files:**
- Modify: `api/user-data.js`

- [ ] **Step 1: Add the import** at the top of the file:

```javascript
const { getUserSubscriptionState } = require('./_lib/user.js');
```

- [ ] **Step 2: After `const user = await getOrCreateUser(email);`** (around line 52), fetch subscription state in parallel with the existing scans query:

```javascript
const subStatePromise = getUserSubscriptionState(supabase, email);
```

- [ ] **Step 3: In the final response object** (currently around line 208), merge the new fields. Read the existing return statement first — it currently returns `{ agent_name, scans, deals, active_threads }`. Add the four subscription fields to that object alongside the existing keys, do NOT replace the existing keys. Concretely:

```javascript
const subState = await subStatePromise;

return res.status(200).json({
  agent_name: user.agent_name,
  subscription_status: subState.subscription_status,
  free_scans_used: subState.free_scans_used,
  digest_enabled: subState.digest_enabled,
  can_scan: subState.canScan,
  scans: (scans || []).map(s => ({ /* existing scan-mapping logic */ })),
  deals: deals.map(d => ({ /* existing deal-mapping logic */ })),
  active_threads: (threadConvos || []).map(c => ({ /* existing thread-mapping logic */ }))
});
```

(Keep the existing `scans.map`, `deals.map`, `active_threads.map` bodies as-is — they're already correct.)

- [ ] **Step 4: Run integration tests** to make sure the existing user-data flow still passes.

```bash
npx vitest run tests/integration/user-data.test.js
```

- [ ] **Step 5: Commit**

```bash
git add api/user-data.js
git commit -m "feat(api): include subscription state in user-data response"
```

### Task 11: Update vercel.json

**Files:**
- Modify: `vercel.json`

- [ ] **Step 1: Add the four new functions** to the `functions` map. Webhook needs longer maxDuration; checkout/portal are quick:

```json
"api/stripe-checkout.js": { "maxDuration": 10 },
"api/stripe-portal.js": { "maxDuration": 10 },
"api/stripe-webhook.js": { "maxDuration": 30 },
"api/user-settings.js": { "maxDuration": 5 }
```

- [ ] **Step 2: Commit**

```bash
git add vercel.json
git commit -m "feat(infra): register stripe + user-settings serverless functions"
```

---

## Phase 5: Frontend State + Settings Rebuild

### Task 12: Frontend state additions

**Files:**
- Modify: `dashboard/src/lib/state.js`

- [ ] **Step 1: Add new signals** at the bottom of the imports/declarations (after `archivedDealIds`):

```javascript
export const subscriptionStatus = signal('inactive');
export const freeScansUsed = signal(0);
export const canScan = signal(true);
export const digestEnabled = signal(true);
export const paywallOpen = signal(false);
```

- [ ] **Step 2: Commit**

```bash
git add dashboard/src/lib/state.js
git commit -m "feat(ui): subscription + paywall signals"
```

### Task 13: Frontend api lib — load + checkout + portal + paywall event

**Files:**
- Modify: `dashboard/src/lib/api.js`

- [ ] **Step 1: Update `loadUserData`** to read the new fields.

   **1a. Edit the existing `import { ... } from './state.js'` line at the top of `api.js`** — do NOT add a second import statement. Add `subscriptionStatus`, `freeScansUsed`, `canScan`, `digestEnabled`, `paywallOpen` to the existing destructured import. The current import is:

   ```javascript
   import {
     email, agentName, scans, deals, activeThreads, starredDealIds,
     viewedDealIds, archivedDealIds,
     chatMessages, chatConversationId, chatStreaming,
     cacheGet, cacheSet, activeThreadId
   } from './state.js';
   ```

   Change it to:

   ```javascript
   import {
     email, agentName, scans, deals, activeThreads, starredDealIds,
     viewedDealIds, archivedDealIds,
     chatMessages, chatConversationId, chatStreaming,
     cacheGet, cacheSet, activeThreadId,
     subscriptionStatus, freeScansUsed, canScan, digestEnabled, paywallOpen
   } from './state.js';
   ```

   **1b. Inside `loadUserData`, after `archivedDealIds.value = ...`, append:**

   ```javascript
   subscriptionStatus.value = data.subscription_status || 'inactive';
   freeScansUsed.value = data.free_scans_used || 0;
   canScan.value = data.can_scan !== false;
   digestEnabled.value = data.digest_enabled !== false;
   ```

- [ ] **Step 2: Add three new exports** to `api.js`:

```javascript
export async function openCheckout() {
  const res = await fetch('/api/stripe-checkout', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email: email.value })
  });
  if (!res.ok) {
    const err = await res.json().catch(() => ({}));
    alert('Could not open checkout: ' + (err.error || 'unknown error'));
    return;
  }
  const { url } = await res.json();
  if (url) window.location.href = url;
}

export async function openPortal() {
  const res = await fetch('/api/stripe-portal', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email: email.value })
  });
  if (!res.ok) {
    const err = await res.json().catch(() => ({}));
    alert('Could not open billing portal: ' + (err.error || 'unknown error'));
    return;
  }
  const { url } = await res.json();
  if (url) window.location.href = url;
}

export async function setDigestEnabled(enabled) {
  const res = await fetch('/api/user-settings', {
    method: 'PATCH',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email: email.value, digest_enabled: enabled })
  });
  if (res.ok) {
    const data = await res.json();
    digestEnabled.value = data.digest_enabled !== false;
  }
}
```

- [ ] **Step 3: Handle the `paywall` SSE event** in `sendMessage`. Inside the `for (const line of lines)` loop, after the `event.type === 'buy_box_saved'` branch, add:

```javascript
} else if (event.type === 'paywall') {
  const msgs = [...chatMessages.value];
  msgs.push({
    role: 'assistant',
    content: '__PAYWALL__',
    paywall: true
  });
  chatMessages.value = msgs;
  freeScansUsed.value = event.free_scans_used;
  canScan.value = false;
  window.dispatchEvent(new CustomEvent('paywall-shown'));
}
```

(Make sure `freeScansUsed` and `canScan` are in the imports at the top.)

- [ ] **Step 4: Commit**

```bash
git add dashboard/src/lib/api.js
git commit -m "feat(ui): checkout + portal helpers + paywall SSE handling"
```

### Task 14: Settings rebuild

**Files:**
- Modify: `dashboard/src/components/Settings.jsx`

- [ ] **Step 1: Replace the file contents** with subscription-aware UI.

```jsx
import { useEffect } from 'preact/hooks';
import { settingsOpen, email, subscriptionStatus, digestEnabled, freeScansUsed } from '../lib/state.js';
import { openCheckout, openPortal, setDigestEnabled as setDigestEnabledRemote } from '../lib/api.js';

export function Settings() {
  useEffect(() => {
    if (!settingsOpen.value) return;
    const handler = (e) => { if (e.key === 'Escape') settingsOpen.value = false; };
    window.addEventListener('keydown', handler);
    return () => window.removeEventListener('keydown', handler);
  }, [settingsOpen.value]);

  if (!settingsOpen.value) return null;

  const isActive = subscriptionStatus.value === 'active' || subscriptionStatus.value === 'trialing';
  const isPastDue = subscriptionStatus.value === 'past_due';
  const isCanceled = subscriptionStatus.value === 'canceled';

  const planLabel = isActive ? 'Pro · $29/mo' :
    isPastDue ? 'Pro · payment past due' :
    isCanceled ? 'Free (subscription canceled)' : 'Free';

  const toggleDigest = async (e) => {
    const newVal = e.target.checked;
    digestEnabled.value = newVal;
    await setDigestEnabledRemote(newVal);
  };

  const signOut = () => {
    localStorage.removeItem('dh_email');
    localStorage.removeItem('dh_notif_digest');
    window.location.reload();
  };

  return (
    <div id="settings-overlay" onClick={(e) => { if (e.target.id === 'settings-overlay') settingsOpen.value = false; }}>
      <div class="settings-panel">
        <div class="settings-header">
          <span class="settings-title">Settings</span>
          <button class="settings-close-btn" onClick={() => { settingsOpen.value = false; }}>×</button>
        </div>

        <div class="settings-section">
          <div class="settings-section-title">Billing</div>
          <div class="settings-plan">Current plan: <strong>{planLabel}</strong></div>
          {!isActive && (
            <>
              <div class="settings-plan-meta">
                {freeScansUsed.value === 0 ? 'Your first scan is free.' : 'Your free scan has been used.'}
              </div>
              <button class="settings-upgrade-btn" onClick={openCheckout}>
                Upgrade to Pro — $29/mo
              </button>
            </>
          )}
          {isActive && (
            <button class="settings-manage-btn" onClick={openPortal}>
              Manage subscription →
            </button>
          )}
          {isPastDue && (
            <button class="settings-manage-btn" onClick={openPortal}>
              Update payment method →
            </button>
          )}
        </div>

        <div class="settings-section">
          <div class="settings-section-title">Notifications</div>
          <div class="settings-notif-row">
            <span>Daily digest email</span>
            <label class="toggle">
              <input type="checkbox" checked={digestEnabled.value} onChange={toggleDigest} />
              <span class="toggle-track" />
            </label>
          </div>
        </div>

        <div class="settings-section">
          <div class="settings-section-title">Help</div>
          <a href="mailto:support@dealhound.pro" class="settings-link">Contact Support →</a>
        </div>

        <div class="settings-bottom">
          <button class="settings-signout" onClick={signOut}>Sign out</button>
        </div>
      </div>
    </div>
  );
}
```

- [ ] **Step 2: Commit**

```bash
git add dashboard/src/components/Settings.jsx
git commit -m "feat(ui): real billing section with Stripe checkout + portal"
```

---

## Phase 6: Frontend Gates

### Task 15: Sidebar New Scan gate

**Files:**
- Modify: `dashboard/src/components/Sidebar.jsx`

- [ ] **Step 1: Update import** to pull in `canScan` and `paywallOpen`:

```jsx
import {
  email, view, activeThreadId, scans, activeThreads,
  settingsOpen, sidebarOpen, sidebarWidth, sidebarTab, unreadFilter,
  starredDealIds, viewedDealIds, archivedDealIds,
  inboxDeals, trackingDeals, newDealCount, previewOpen,
  canScan, paywallOpen
} from '../lib/state.js';
```

- [ ] **Step 2: Update `startNewScan`** to gate on `canScan`:

```jsx
const startNewScan = () => {
  if (!canScan.value) {
    paywallOpen.value = true;
    return;
  }
  view.value = 'onboarding';
  activeThreadId.value = null;
};
```

- [ ] **Step 3: Update the New Scan button rendering** so it shows a lock state when blocked. Replace the existing `<button class="sidebar-new-scan">` with:

```jsx
<button
  class={`sidebar-new-scan ${!canScan.value ? 'locked' : ''}`}
  style="flex: 1;"
  onClick={startNewScan}
  title={!canScan.value ? 'Upgrade to run another scan' : 'Start a new scan'}
>
  {canScan.value ? (
    <>
      <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round">
        <line x1="12" y1="5" x2="12" y2="19" /><line x1="5" y1="12" x2="19" y2="12" />
      </svg>
      New Scan
    </>
  ) : (
    <>
      <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round">
        <rect x="3" y="11" width="18" height="11" rx="2" /><path d="M7 11V7a5 5 0 0110 0v4" />
      </svg>
      Upgrade to scan
    </>
  )}
</button>
```

- [ ] **Step 4: Commit**

```bash
git add dashboard/src/components/Sidebar.jsx
git commit -m "feat(ui): lock New Scan button when free scan is used"
```

### Task 16: Chat paywall message + paywall modal trigger

**Files:**
- Modify: `dashboard/src/components/Chat.jsx`
- Modify: `dashboard/src/app.jsx` (mount paywall modal effect)

- [ ] **Step 1: Add a Paywall component** to `Chat.jsx` (near the top, alongside `WatchPlaceholder`):

```jsx
import { openCheckout } from '../lib/api.js';
// ...

function PaywallMessage() {
  return (
    <div class="msg msg-assistant paywall-msg">
      <div class="msg-label"><span class="msg-dot" />Agent</div>
      <div class="msg-body">
        <p><strong>Your first scan is on us.</strong></p>
        <p>To run another scan, get unlimited scans + daily digest emails for $29/mo. Cancel anytime.</p>
        <button class="btn-upgrade" onClick={openCheckout}>Upgrade to Pro — $29/mo</button>
      </div>
    </div>
  );
}
```

- [ ] **Step 2: Render the paywall message** when a chat message has `paywall: true`.

   **Minimum-change patch:** Find the existing `chatMessages.value.map((msg, i) => (...))` block in `Chat.jsx`. Convert it from an arrow expression returning JSX directly to an arrow body with an early return for paywall messages — leave everything else inside the map untouched.

   **Before:**

   ```jsx
   {chatMessages.value.map((msg, i) => (
     <div key={i} class={`msg msg-${msg.role}`}>
       {/* ... existing rendering ... */}
     </div>
   ))}
   ```

   **After:**

   ```jsx
   {chatMessages.value.map((msg, i) => {
     if (msg.paywall) return <PaywallMessage key={i} />;
     return (
       <div key={i} class={`msg msg-${msg.role}`}>
         {/* ... keep existing rendering verbatim — do not modify ... */}
       </div>
     );
   })}
   ```

   The implementer should literally copy-paste the existing JSX block into the `return (...)` of the new arrow body. No other changes to message rendering.

- [ ] **Step 3: Open the paywall (settings panel) when `paywallOpen` flips true** — add an effect in `app.jsx`. Also scroll the Billing section into view and pulse it briefly so the user knows why they landed there.

```jsx
import { settingsOpen, paywallOpen } from './lib/state.js';
// ...
useEffect(() => {
  if (paywallOpen.value) {
    settingsOpen.value = true;
    paywallOpen.value = false;
    // After the panel mounts, focus the upgrade button
    setTimeout(() => {
      const btn = document.querySelector('.settings-upgrade-btn');
      if (btn) {
        btn.scrollIntoView({ behavior: 'smooth', block: 'center' });
        btn.classList.add('pulse');
        setTimeout(() => btn.classList.remove('pulse'), 1200);
      }
    }, 100);
  }
}, [paywallOpen.value]);
```

(Decision: paywall modal IS the Settings panel. Saves building two modals. Add a `.pulse` class in styles.css that briefly highlights the upgrade button so the user knows why they're here.)

- [ ] **Step 4: Commit**

```bash
git add dashboard/src/components/Chat.jsx dashboard/src/app.jsx
git commit -m "feat(ui): paywall message in chat + Settings as paywall surface"
```

### Task 17: Paywall + lock styles

**Files:**
- Modify: `dashboard/src/styles.css`

- [ ] **Step 1: Append paywall + lock styles** at the end of the file:

```css
/* Paywall message in chat */
.paywall-msg .msg-body {
  background: linear-gradient(135deg, var(--gold-glow), var(--gold-dim));
  border-left: 3px solid var(--gold);
  padding: 16px 18px;
  border-radius: 6px;
}
.paywall-msg .msg-body p {
  margin: 0 0 8px;
}
.paywall-msg .msg-body p:last-of-type {
  margin-bottom: 14px;
}
.btn-upgrade {
  background: var(--gold);
  color: white;
  border: 0;
  padding: 10px 18px;
  border-radius: 4px;
  font-family: var(--sans);
  font-weight: 500;
  font-size: 14px;
  cursor: pointer;
}
.btn-upgrade:hover { opacity: 0.9; }

/* Locked New Scan button */
.sidebar-new-scan.locked {
  background: var(--surface2);
  color: var(--cream-dim);
  cursor: pointer;
  border-color: var(--border);
}
.sidebar-new-scan.locked:hover {
  background: var(--gold-glow);
  color: var(--gold);
}

/* Settings: manage subscription */
.settings-manage-btn {
  display: block;
  width: 100%;
  background: transparent;
  color: var(--gold);
  border: 1px solid var(--gold);
  padding: 10px 14px;
  border-radius: 4px;
  font-family: var(--sans);
  font-weight: 500;
  font-size: 13px;
  cursor: pointer;
  margin-top: 8px;
}
.settings-manage-btn:hover {
  background: var(--gold-glow);
}
.settings-plan-meta {
  font-size: 12px;
  color: var(--cream-dim);
  margin: 4px 0 12px;
}

/* Pulse highlight when paywall lands on the Settings panel */
@keyframes pulseGold {
  0%, 100% { box-shadow: 0 0 0 0 rgba(36,61,53,0.0); }
  50% { box-shadow: 0 0 0 6px rgba(36,61,53,0.25); }
}
.settings-upgrade-btn.pulse {
  animation: pulseGold 0.6s ease-in-out 2;
}
```

- [ ] **Step 2: Commit**

```bash
git add dashboard/src/styles.css
git commit -m "feat(ui): paywall + lock + manage-subscription styles"
```

---

## Phase 7: Verify Build, Tests, Final Commit

### Task 18: Build verification

- [ ] **Step 1: Run `npm run build`** — fix any Vite/Preact errors that surface.

```bash
npm run build
```

Expected: build succeeds, output in `dashboard/dist/` (or wherever vite.config.js writes — check that path).

- [ ] **Step 2: Run all tests** — they should all pass (or be `skipIf`-skipped where Stripe env vars aren't present).

```bash
npm test
```

- [ ] **Step 3: Run smoke tests**

```bash
npm run test:smoke
```

- [ ] **Step 4: If anything fails**, fix in-place and add commits. If a test depends on Stripe env vars and Gideon hasn't supplied them yet, the suite's `skipIf` should make it green. If the build dies on a syntax issue, fix it.

### Task 19: Final summary commit + push

- [ ] **Step 1: Create a deployment summary** at `docs/superpowers/plans/2026-04-29-mvp-paywall-launch-completion.md` that lists all commits made on this branch and pastes the wake-up checklist verbatim. (This is the "what's done, what you owe me" doc.)

- [ ] **Step 2: Push the branch**

```bash
git push -u origin mvp-launch-paywall
```

- [ ] **Step 3: Open a PR** with title "feat: MVP paywall — Stripe checkout + scan metering + settings billing" and a body that summarizes the changes and links to this plan + the wake-up checklist.

```bash
gh pr create --title "feat: MVP paywall — Stripe checkout + scan metering + settings billing" --body "$(cat <<'EOF'
## Summary
- Adds Stripe Checkout, Customer Portal, and webhook receiver
- Scan-count gate in api/chat.js: free user gets 1 scan, then sees paywall
- Settings rebuilt: real billing section, DB-backed digest preference
- New columns on users table: stripe_customer_id, stripe_subscription_id, subscription_status, subscription_current_period_end, free_scans_used, digest_enabled

## Wake-up checklist
See [docs/superpowers/plans/2026-04-29-mvp-paywall-launch.md](docs/superpowers/plans/2026-04-29-mvp-paywall-launch.md) — top section. Stripe dashboard setup + 4 env vars in Vercel are required before merging to make this go live.

## Test plan
- [ ] Stripe env vars added to Vercel (test mode is fine)
- [ ] Migration applied (already done by build agent — verify columns exist)
- [ ] Sign in fresh email → run first scan → click New Scan → see paywall
- [ ] Click Upgrade → Stripe Checkout → use 4242 4242 4242 4242 → return → scan unlocked
- [ ] Settings → Manage subscription → Stripe Portal opens → cancel works
- [ ] Daily digest toggle persists across reload

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

- [ ] **Step 4: Final commit if needed** to capture any remaining lint/format fixes from CI.

---

## Phase 8: Magic-Link Auth (Supabase Auth) — A4 amendment

### Task 20: Add Supabase Auth client + helper

**Files:**
- Create: `api/_lib/auth.js`
- Modify: `dashboard/src/lib/supabase.js` (create if missing)

- [ ] **Step 1: Frontend Supabase client** — create `dashboard/src/lib/supabase.js`:

```javascript
import { createClient } from '@supabase/supabase-js';
const url = import.meta.env.VITE_SUPABASE_URL;
const anonKey = import.meta.env.VITE_SUPABASE_ANON_KEY;
export const supabase = createClient(url, anonKey, {
  auth: { persistSession: true, autoRefreshToken: true }
});
```

- [ ] **Step 2: Backend auth helper** — create `api/_lib/auth.js` (see code in A4 of SPEC AMENDMENTS).

- [ ] **Step 3: Wake-up checklist additions** — Gideon adds `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY` to Vercel env vars (separate from the service key already there).

- [ ] **Step 4: Commit**

```bash
git add api/_lib/auth.js dashboard/src/lib/supabase.js
git commit -m "feat(auth): add Supabase Auth client + JWT helper"
```

### Task 21: Magic-link send + email-gate UI

**Files:**
- Modify: `dashboard/src/app.jsx` (EmailGate component)
- Modify: `dashboard/src/styles.css`

- [ ] **Step 1: Replace localStorage with Supabase OTP** in `EmailGate`:

```jsx
const handleSubmit = async (e) => {
  e.preventDefault();
  const val = e.target.elements.email.value.trim();
  if (!val) return;
  setSending(true);
  const { error } = await supabase.auth.signInWithOtp({
    email: val,
    options: { emailRedirectTo: `${window.location.origin}/auth/callback` }
  });
  setSending(false);
  if (error) { setSendError(error.message); return; }
  setEmailSent(val);
};
```

- [ ] **Step 2: Render three states** — initial form, "email sent" with resend button (60s throttle — Cherry-pick #2), error state with retry.

- [ ] **Step 3: Add loading spinner styles** + email-sent confirmation message.

- [ ] **Step 4: Commit**

```bash
git add dashboard/src/app.jsx dashboard/src/styles.css
git commit -m "feat(auth): magic-link send with email-sent + resend UI"
```

### Task 22: Auth callback page

**Files:**
- Create: `dashboard/auth-callback.html` (or route in app.jsx)

- [ ] **Step 1: Create callback page** that reads `#access_token=...` fragment, calls `supabase.auth.getSession()`, and routes:
  - Success → `/dashboard`
  - `?error=expired_token` → "Link expired. Send a new one?" → back to email gate
  - `?error=invalid_token` → "This link is no longer valid." → back to email gate

- [ ] **Step 2: Add route to vercel.json:**

```json
{ "source": "/auth/callback", "destination": "/auth-callback.html" }
```

- [ ] **Step 3: Commit**

```bash
git add dashboard/auth-callback.html vercel.json
git commit -m "feat(auth): magic-link callback with expired-link handling"
```

### Task 23: Migrate ALL API endpoints to JWT auth

**Files:**
- Modify: `api/chat.js`, `api/deal-chat.js`, `api/user-data.js`, `api/scan-start.js`, `api/scan-progress.js`, `api/star-deal.js`, `api/view-deal.js`, `api/archive-deal.js`, `api/conversation.js`, `api/user-settings.js`, `api/stripe-checkout.js`, `api/stripe-portal.js`
- Test: `tests/integration/auth.test.js`

- [ ] **Step 1: Write the failing auth test** that asserts each endpoint returns 401 without a valid Authorization header.

```javascript
// tests/integration/auth.test.js
import { describe, it, expect } from 'vitest';

const ENDPOINTS = [
  { path: '/api/chat', method: 'POST' },
  { path: '/api/deal-chat', method: 'POST' },
  { path: '/api/user-data', method: 'GET' },
  // ...full list
];

describe('all endpoints require JWT', () => {
  for (const ep of ENDPOINTS) {
    it(`${ep.method} ${ep.path} returns 401 without token`, async () => {
      // Test by importing handler directly with mock req/res
    });
  }
});
```

- [ ] **Step 2: For each endpoint, add at the top:**

```javascript
const { getUserFromRequest } = require('./_lib/auth.js');
// ...inside handler, before any logic:
let user;
try { user = await getUserFromRequest(req); }
catch (err) { return res.status(401).json({ error: 'Unauthorized' }); }
const email = user.email; // use this instead of req.body.email or req.query.email
```

- [ ] **Step 3: Frontend api.js** — add Authorization header to every fetch:

```javascript
async function authedFetch(url, opts = {}) {
  const { data: { session } } = await supabase.auth.getSession();
  const headers = { ...(opts.headers || {}), Authorization: `Bearer ${session?.access_token}` };
  return fetch(url, { ...opts, headers });
}
// Replace all fetch() with authedFetch() in api.js
```

- [ ] **Step 4: Run all tests** — every endpoint should now return 401 without auth, 200 with auth.

- [ ] **Step 5: Commit**

```bash
git add api/ dashboard/src/lib/api.js tests/integration/auth.test.js
git commit -m "feat(auth): migrate all API endpoints to JWT-based auth"
```

---

## Phase 9: Token Budget Tracking — A3 amendment

### Task 24: Token budget helpers + DB columns

Already covered in updated migration (Phase 1) and updated user.js helpers (Phase 2 — add `getTokenBudget` and `recordTokenUsage` functions).

- [ ] **Step 1: Add to `api/_lib/user.js`:**

```javascript
const FREE_BUDGET_CENTS = 150;  // $1.50/mo
const PRO_BUDGET_CENTS = 600;   // $6.00/mo
const RESET_INTERVAL_DAYS = 30;

async function getTokenBudget(supabase, email) {
  const { data: user } = await supabase
    .from('users')
    .select('chat_tokens_used_cents, chat_tokens_reset_at, subscription_status, subscription_current_period_end')
    .eq('email', email)
    .single();

  if (!user) return { allowed: true, remaining_cents: FREE_BUDGET_CENTS, reset_at: null };

  const isPaid = isSubscriptionActive(user);
  const budget = isPaid ? PRO_BUDGET_CENTS : FREE_BUDGET_CENTS;

  // Lazy reset
  const resetAt = new Date(user.chat_tokens_reset_at || 0);
  const nextReset = new Date(resetAt.getTime() + RESET_INTERVAL_DAYS * 86400 * 1000);
  let used = user.chat_tokens_used_cents || 0;
  let actualResetAt = user.chat_tokens_reset_at;

  if (nextReset < new Date()) {
    used = 0;
    actualResetAt = new Date().toISOString();
    await supabase
      .from('users')
      .update({ chat_tokens_used_cents: 0, chat_tokens_reset_at: actualResetAt })
      .eq('email', email);
  }

  const remaining = budget - used;
  const renewAt = new Date(new Date(actualResetAt).getTime() + RESET_INTERVAL_DAYS * 86400 * 1000).toISOString();

  return {
    allowed: remaining > 0,
    remaining_cents: remaining,
    budget_cents: budget,
    used_cents: used,
    reset_at: renewAt,
    is_paid: isPaid
  };
}

async function recordTokenUsage(supabase, email, inputTokens, outputTokens) {
  // Sonnet pricing: $3/M input, $15/M output
  const cents = Math.ceil((inputTokens * 3 / 10000) + (outputTokens * 15 / 10000));
  // Use atomic update via RPC or direct increment
  const { data: current } = await supabase
    .from('users')
    .select('chat_tokens_used_cents')
    .eq('email', email)
    .single();
  const next = (current?.chat_tokens_used_cents || 0) + cents;
  await supabase
    .from('users')
    .update({ chat_tokens_used_cents: next })
    .eq('email', email);
  return cents;
}
```

- [ ] **Step 2: Tests** — `tests/unit/token-budget.test.js` with cases for: lazy reset, exhaustion blocks, paid user gets larger budget, increment is atomic.

### Task 25: Wire token budget into chat endpoints

**Files:**
- Modify: `api/chat.js` (deal-chat conversations), `api/deal-chat.js`

- [ ] **Step 1:** Before streaming response, call `getTokenBudget(supabase, email)`. If `!allowed`, write SSE event `{type: 'token_exhausted', renew_at: budget.reset_at}` and `res.end()`.

- [ ] **Step 2:** After Anthropic stream completes, read `usage.input_tokens` and `usage.output_tokens` from the final message, call `recordTokenUsage(supabase, email, inputTokens, outputTokens)`.

- [ ] **Step 3:** Frontend handler (`dashboard/src/lib/api.js`) — handle `token_exhausted` event by appending a chat message with renewal date (no dollar amount).

- [ ] **Step 4: Commit**

```bash
git add api/chat.js api/deal-chat.js api/_lib/user.js dashboard/src/lib/api.js tests/unit/token-budget.test.js
git commit -m "feat(billing): chat token budget with lazy reset + exhaustion UI"
```

---

## Phase 10: PostHog Analytics — A9 / Cherry-pick #1

### Task 26: PostHog client init

**Files:**
- Modify: `package.json` (add `posthog-js` to dashboard deps — or top-level since dashboard shares deps)
- Modify: `dashboard/src/main.jsx`

- [ ] **Step 1: Install `posthog-js`** via `npm install posthog-js`.

- [ ] **Step 2: Initialize in `main.jsx`:**

```jsx
import posthog from 'posthog-js';
const POSTHOG_KEY = import.meta.env.VITE_POSTHOG_KEY;
if (POSTHOG_KEY) {
  posthog.init(POSTHOG_KEY, {
    api_host: 'https://us.i.posthog.com',
    person_profiles: 'identified_only',
    capture_pageview: true
  });
}
export { posthog };
```

- [ ] **Step 3: Identify user on email gate success:**

```jsx
posthog.identify(email);
```

### Task 27: Wire funnel events

**Files:**
- Modify: `dashboard/src/app.jsx` (signup_started, signup_completed)
- Modify: `dashboard/src/components/Chat.jsx` (buy_box_started, buy_box_saved)
- Modify: `dashboard/src/lib/api.js` (paywall_shown, checkout_clicked, checkout_completed, scan_completed, chat_tokens_exhausted)
- Modify: `dashboard/src/components/Settings.jsx` (subscription_canceled visibility)

- [ ] **Step 1:** Capture each event from A9's list at the right trigger point.

- [ ] **Step 2:** For `scan_completed`, include `qualifying: bool` property.

- [ ] **Step 3: Commit**

```bash
git add package.json package-lock.json dashboard/src/
git commit -m "feat(analytics): PostHog funnel events"
```

---

## Phase 11: Webhook Idempotency — A8 / Cherry-pick #4

### Task 28: stripe_events table + dedup logic

**Files:**
- Modify: `migrations/2026-04-29-add-subscription-columns.sql` (add stripe_events table)
- Modify: `api/stripe-webhook.js`
- Test: `tests/integration/webhook-idempotency.test.js`

- [ ] **Step 1: Append to migration SQL:**

```sql
CREATE TABLE IF NOT EXISTS stripe_events (
  id TEXT PRIMARY KEY,
  type TEXT NOT NULL,
  processed_at TIMESTAMPTZ DEFAULT now()
);
CREATE INDEX IF NOT EXISTS stripe_events_processed_at_idx ON stripe_events(processed_at);
```

Re-apply migration via Supabase MCP.

- [ ] **Step 2: Add dedup check** in `stripe-webhook.js` after signature verification, before event-type switch:

```javascript
const { error: dupError } = await supabase
  .from('stripe_events')
  .insert({ id: event.id, type: event.type });
if (dupError && dupError.code === '23505') {
  return res.status(200).json({ received: true, deduped: true });
}
```

- [ ] **Step 3: Write idempotency test** — call handler twice with same event_id, assert second call returns `deduped: true` and DB state changed only once.

- [ ] **Step 4: Commit**

```bash
git add migrations/ api/stripe-webhook.js tests/integration/webhook-idempotency.test.js
git commit -m "feat(billing): stripe webhook idempotency via stripe_events table"
```

---

## Phase 12: Usage Indicator + Resend Magic Link — A10 / Cherry-picks #2 #3

### Task 29: Settings usage indicator

**Files:**
- Modify: `dashboard/src/components/Settings.jsx`
- Modify: `dashboard/src/styles.css`

- [ ] **Step 1: Render usage block** in Billing section:

```jsx
const { used_cents, budget_cents, reset_at } = tokenBudget.value || {};
const pct = budget_cents ? Math.min(100, Math.round((used_cents / budget_cents) * 100)) : 0;
// ...render bar with pct% width, label "Chat allotment used"
// Plus: "Scans this month: N" from a new query that counts deal_searches in current month
```

- [ ] **Step 2: Style the progress bar** in styles.css.

- [ ] **Step 3: Commit**

```bash
git add dashboard/src/components/Settings.jsx dashboard/src/styles.css
git commit -m "feat(ui): Settings usage indicator (chat allotment + monthly scan count)"
```

### Task 30: Resend magic link with throttle

**Files:**
- Modify: `dashboard/src/app.jsx` (EmailGate)

- [ ] **Step 1: Add resend button** to "email sent" state with countdown:

```jsx
const [resendCooldown, setResendCooldown] = useState(0);
useEffect(() => {
  if (resendCooldown <= 0) return;
  const t = setTimeout(() => setResendCooldown(c => c - 1), 1000);
  return () => clearTimeout(t);
}, [resendCooldown]);

const handleResend = async () => {
  if (resendCooldown > 0) return;
  await supabase.auth.signInWithOtp({ email: emailSent, options: {...} });
  setResendCooldown(60);
};

// In render:
<button disabled={resendCooldown > 0} onClick={handleResend}>
  {resendCooldown > 0 ? `Resend in ${resendCooldown}s` : 'Resend email'}
</button>
```

- [ ] **Step 2: Commit**

```bash
git add dashboard/src/app.jsx
git commit -m "feat(auth): resend magic link with 60s client throttle"
```

---

## Phase 13: Mac-Worker Health Endpoint + Feature Flag + Landing Verify

### Task 31: Admin health endpoint — A11

**Files:**
- Create: `api/admin/health.js`

- [ ] **Step 1: Write the endpoint:**

```javascript
// api/admin/health.js
const { createClient } = require('@supabase/supabase-js');
const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_KEY);

module.exports = async function handler(req, res) {
  if (req.method !== 'GET') return res.status(405).json({});
  const now = new Date();
  const t30min = new Date(now.getTime() - 30 * 60 * 1000).toISOString();
  const t2hr = new Date(now.getTime() - 2 * 60 * 60 * 1000).toISOString();

  const { count: stale30 } = await supabase
    .from('deal_searches')
    .select('*', { count: 'exact', head: true })
    .eq('status', 'scanning')
    .lt('run_at', t30min);

  const { count: stale2h } = await supabase
    .from('deal_searches')
    .select('*', { count: 'exact', head: true })
    .eq('status', 'scanning')
    .lt('run_at', t2hr);

  const { data: latestComplete } = await supabase
    .from('deal_searches')
    .select('run_at')
    .eq('status', 'complete')
    .order('run_at', { ascending: false })
    .limit(1)
    .single();

  return res.status(200).json({
    stale_scans_30min: stale30 || 0,
    stale_scans_2hr: stale2h || 0,
    last_scrape_completed_at: latestComplete?.run_at || null,
    health: (stale2h || 0) === 0 ? 'ok' : 'degraded'
  });
};
```

- [ ] **Step 2: Register in vercel.json** + add to wake-up checklist (Gideon curls daily).

- [ ] **Step 3: Commit**

```bash
git add api/admin/health.js vercel.json
git commit -m "feat(ops): admin health endpoint for Mac-worker monitoring"
```

### Task 32: Feature flag + landing page verify — A12 / A13

- [ ] **Step 1: Add `ENABLE_PAYWALL` env check** in scan-gate logic. Default off.

- [ ] **Step 2: Smoke test landing page** — verify "Get started" CTA in `index.html` routes to `/dashboard` and that the email gate works with magic link. Update any "1 free scan" copy to "Try it free — adjust until your agent finds matches."

- [ ] **Step 3: Commit**

```bash
git add api/_lib/scan-gate.js index.html
git commit -m "feat(ops): paywall feature flag + landing copy alignment"
```

---

## Risks & Mitigations

| Risk | Likelihood | Mitigation |
|---|---|---|
| Migration runs but a downstream API can't see the new columns until cache invalidates | Low | Supabase MCP `apply_migration` is synchronous; subsequent queries see the new columns. If we hit an issue, run `select column_name from information_schema.columns where table_name='users'` to confirm. |
| Stripe webhook signature verification fails because Vercel pre-parses the body | Medium | Set `module.exports.config = { api: { bodyParser: false } }` and read raw body via async iterator. Documented in code. |
| Race: user clicks Upgrade, completes checkout, returns, but webhook hasn't fired yet → Settings still shows "Free" | Medium | After return from Stripe, the dashboard reload pulls latest user-data. If the webhook is slow, the user sees stale state for a few seconds. Acceptable for MVP — log it and revisit if support tickets pile up. Could be improved by polling user-settings for 10 seconds after return. |
| User cancels in Customer Portal → webhook fires with `customer.subscription.updated` (cancel_at_period_end=true) → status stays `active` until period end | Expected | This is correct Stripe behavior and matches the Customer Portal config recommended (cancel at period end). User retains access through the paid period. |
| Anyone can hit /api/stripe-checkout with someone else's email and trick a paid customer's session | Low (no real auth) | This was an explicit accepted tradeoff. The blast radius is "spawn a checkout someone won't complete." Worst case: email fishing. Document this in PR description. Real magic-link auth is a follow-up sprint. |
| `incrementFreeScansUsed` failure leaves a row in `deal_searches` but no metering bump → user gets unlimited free scans | Low | We try/catch the increment so it doesn't fail the request, but a Supabase outage during the increment is the gap. Acceptable for MVP. Could be addressed by a `BEFORE INSERT` Postgres trigger that auto-increments — defer. |
| Build fails on Vercel because Stripe env vars are unset and a top-level require evaluates the secret | Low | Stripe client is lazy-loaded inside `getStripe()` — `require('stripe')` succeeds without a key. Endpoints only fail at request-time if keys are missing. |

---

## What I Won't Touch (per scope agreement)

- ~~Mac scraper worker code~~ (out of scope; we add a health-check endpoint only)
- ~~`/find-deals` skill or scrape pipeline architecture~~ (skill is the product core)
- ~~UI redesign of properties list / preview / chat~~ (already works per audit)
- ~~Onboarding flow rework~~ (already works)
- ~~Mastermind hidden invite (gamified)~~ (deferred to P1, after first 10-20 paying users with PostHog data)
- ~~Pool-match logic DRY refactor~~ (logged as TODO; touch when one of the duplicating files needs another change)
- ~~Multi-buy-box premium tier~~ ($97 is the rack rate; effective tier comes later)
- ~~Anthropic 429 retry/backoff~~ (logged as TODO; out of scope for MVP)

Items previously listed here that are NOW IN SCOPE post-CEO-review:
- ✅ Magic-link auth via Supabase Auth (Phase 8) — replaces localStorage email
- ✅ Pricing structure: $97/mo rack, FOUNDER coupon → $49/mo (A2 amendment)
- ✅ Email digest toggle DB-synced (was already in original plan)

---

## Plan Sign-off

This plan was written autonomously while Gideon slept on 2026-04-29. Updated 2026-04-30 after CEO review (SELECTIVE EXPANSION mode) added 4 cherry-picks (PostHog, resend magic-link, usage indicator, webhook idempotency) and integrated the post-write spec clarifications (HOT/STRONG threshold metering, token budgets, magic-link auth, pricing structure, Mac-worker observability, feature flag, landing copy alignment).

Every code task here is something I can complete autonomously. The wake-up checklist captures the configuration boundary: Stripe Dashboard, Supabase Auth config, PostHog signup, and four (now eight) Vercel env vars require Gideon's account access.

If anything in here surprises you in the morning, leave a comment on the PR and I'll iterate.

---

## GSTACK REVIEW REPORT

| Review | Trigger | Why | Runs | Status | Findings |
|--------|---------|-----|------|--------|----------|
| CEO Review | `/plan-ceo-review` | Scope & strategy | 1 | CLEAR (PLAN) | 4 proposals, 4 accepted, 2 deferred (Mastermind hooks) |
| Codex Review | `/codex review` | Independent 2nd opinion | 0 | — | not run |
| Eng Review | `/plan-eng-review` | Architecture & tests (required) | 1 | CLEAR (PLAN) | 7 issues found, 0 critical gaps remaining (3 user-decided + 4 autonomous fixes); 14 critical test gaps closed via A22 |
| Design Review | `/plan-design-review` | UI/UX gaps | 0 | — | not run (recommend before merge — significant UI changes) |
| DX Review | `/plan-devex-review` | Developer experience gaps | 0 | — | not run |

- **UNRESOLVED:** 0
- **VERDICT:** CEO + ENG CLEARED — ready to implement (recommend `/plan-design-review` before merge)

