# PR 1 — Charge People (Stripe Paywall)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a working Stripe paywall on top of the beta product. Free users get one scan, then a paywall. Paid users go through Stripe Checkout (with FOUNDER coupon → $48.50 effective) and can cancel via Customer Portal.

**Branch:** new branch `pr1-charge-people` off `main` (not the old `mvp-launch-paywall` branch — that holds messy iteration history).

**Time estimate:** ~3-4 hrs CC + Gideon's Stripe Dashboard config (~20 min).

**Architecture:** Add subscription columns to existing `users` table. Three new API routes wrap Stripe Checkout, Customer Portal, and webhook receiver. The buy-box save handler in `api/chat.js` becomes the server-side gate — it checks `users.free_scans_used >= 1 AND subscription_status not active` and returns a paywall payload instead of inserting `deal_searches`. **Critical:** scan gate logic lives in `api/_lib/scan-gate.js` from day one (not inlined in chat.js then refactored — see must-fix #7 from eng review). Frontend gets a subscription-aware "New Scan" button, a paywall message in chat, and a real Settings billing section.

**Tech Stack:** Node.js (CommonJS) on Vercel serverless, Stripe Node SDK, `@supabase/supabase-js`, Preact + signals, vitest.

---

## Must-fixes from eng review (baked into this plan)

These were caught by the outside-voice review on the old combined plan. Both are addressed below by structure, not as afterthoughts:

- **#1 Migration correctness** — The original plan had two migrations (one for Stripe, one later for HOT/STRONG threshold + tokens). PR 1 ships ONE complete migration with only the columns PR 1 uses. PR 2 will add ITS migration. No "described in amendment" mismatch.
- **#7 scan-gate extraction first** — `api/_lib/scan-gate.js` is built BEFORE `api/chat.js` calls it. The gate logic never lives inside chat.js, then gets refactored out. It's extracted from the start.

Other must-fixes (#3, #4, #5, #6, #2, #8) apply to PR 2/PR 3 because the code they affect ships in those PRs.

---

## What's in PR 1

- DB migration: 7 new columns on `users` + new `stripe_events` table
- Stripe Checkout endpoint (with FOUNDER coupon support, return_url allowlist)
- Stripe Customer Portal endpoint (with return_url allowlist)
- Stripe webhook receiver (signature verify, raw body, idempotency dedup, cancel-but-active state)
- Simple scan counter gate (`free_scans_used >= 1` blocks; HOT/STRONG threshold is PR 2)
- `api/_lib/scan-gate.js` (extracted from day one)
- `api/_lib/user.js` subscription state helpers (incl. cancel-but-active logic)
- `api/_lib/stripe.js` Stripe client + customer helper
- `api/user-settings.js` GET/PATCH for digest preference
- `api/admin/health.js` basic Mac-worker observability (no email alerts yet — that's PR 3)
- Settings.jsx rebuild (real billing section)
- Sidebar.jsx lock state on "New Scan"
- Chat.jsx inline paywall message
- vercel.json registers new endpoints
- Tests for financial-critical paths

## What's NOT in PR 1 (explicitly deferred)

- HOT/STRONG threshold metering → **PR 2**
- Magic-link auth (Supabase Auth + jose JWT) → **PR 2**
- Token budget tracking → **PR 2**
- Agent buy-box loosening suggestions → **PR 2**
- PostHog analytics → **PR 3**
- Usage indicator in Settings → **PR 3**
- Mac-worker email alerts → **PR 3**
- Loading spinner on email gate, post-pay celebration banner, lock-pulse animation, mobile bottom-sheet, a11y additions → **PR 3**

---

## Wake-Up Checklist for Gideon (Stripe + Vercel config)

PR 1 code is shippable without these, but the paywall won't actually charge until configured. Do these BEFORE flipping `ENABLE_PAYWALL=true`.

### Stripe Dashboard (https://dashboard.stripe.com)

- [ ] **Switch dashboard to Test mode** for initial setup.
- [ ] **Create the product.** Products → Add product → Name: "Deal Hound Pro" → Pricing: $97.00 USD recurring monthly. Save. Copy the **Price ID** (`price_1ABC...`).
- [ ] **Create the FOUNDER coupon.** Products → Coupons → Create coupon. Name: `FOUNDER`. Type: Percent off. Discount: 50%. Duration: Forever. Save. **Copy the auto-generated Coupon ID** (looks like `25_off_forever` or similar string Stripe assigns).
- [ ] **Configure Customer Portal.** Settings → Billing → Customer portal. Allow: cancel subscriptions, update payment method, view invoices. Cancellation: cancel at period end. Save.
- [ ] **Add webhook endpoint.** Developers → Webhooks → Add endpoint. URL: `https://dealhound.pro/api/stripe-webhook`. Events: `checkout.session.completed`, `customer.subscription.created`, `customer.subscription.updated`, `customer.subscription.deleted`, `invoice.payment_failed`. Save. Reveal signing secret, copy (`whsec_...`).
- [ ] **Copy API keys.** Developers → API keys: secret (`sk_test_...`) and publishable (`pk_test_...`).

### Vercel Dashboard

- [ ] Add to all environments (Production + Preview + Development):
  - `STRIPE_SECRET_KEY` = `sk_test_...`
  - `STRIPE_PUBLISHABLE_KEY` = `pk_test_...`
  - `STRIPE_PRICE_ID` = `price_1ABC...`
  - `STRIPE_DEFAULT_COUPON` = (FOUNDER coupon ID from Stripe dashboard) — auto-applies 50% discount at checkout so users see $48.50 without manually entering a code
  - `STRIPE_WEBHOOK_SECRET` = `whsec_...`
  - `ENABLE_PAYWALL` = `false` (flip to `true` after smoke test passes)

### Local `.env`

- [ ] Mirror the same five vars to `/Users/gideonspencer/dealhound-pro/.env` so local tests pass.

---

## File Structure

### New files

| File | Responsibility |
|---|---|
| `api/_lib/stripe.js` | Lazy-load Stripe client; `getOrCreateCustomer(supabase, email)` |
| `api/_lib/user.js` | `getUserSubscriptionState(email)`, `incrementScansUsed(email)`, `setDigestEnabled(email, bool)`, `isSubscriptionActive(user)` (cancel-but-active aware) |
| `api/_lib/scan-gate.js` | `checkScanGate(supabase, email, paywallEnabled)` — returns `{allowed, reason, state}`. Single source of truth for "can this user start a scan" |
| `api/stripe-checkout.js` | POST → returns Checkout Session URL. return_url validated. allow_promotion_codes for FOUNDER |
| `api/stripe-portal.js` | POST → returns Customer Portal URL. return_url validated |
| `api/stripe-webhook.js` | POST → verifies signature, dedups via stripe_events table, handles 5 event types |
| `api/user-settings.js` | GET → subscription state + digest pref. PATCH → digest_enabled |
| `api/admin/health.js` | GET (with `?key=`) → stale_scans counts, last_scrape_completed_at |
| `migrations/2026-04-30-pr1-stripe.sql` | All DDL for PR 1 in one file (NOT split across two migrations) |
| `tests/unit/user-helpers.test.js` | Counter, subscription state, cancel-but-active logic |
| `tests/unit/subscription-active.test.js` | Each subscription_status × period_end combination |
| `tests/integration/scan-gate.test.js` | Counter blocks 2nd scan; active sub bypasses |
| `tests/integration/stripe-webhook.test.js` | Bad signature 400; valid event mutates DB |
| `tests/integration/webhook-idempotency.test.js` | Same event_id twice = processed once |
| `tests/integration/webhook-handlers.test.js` | Each of 5 event types produces correct DB state |
| `tests/integration/return-url-validation.test.js` | checkout + portal reject malicious return_url |
| `tests/integration/admin-health-auth.test.js` | Missing key 401, wrong key 401, correct key 200 |

### Modified files

| File | What changes |
|---|---|
| `package.json` | Add `"stripe": "^17.5.0"` to dependencies |
| `api/chat.js` | Call `checkScanGate` from extracted helper; on gated, write paywall SSE; on success, increment counter |
| `api/user-data.js` | Include `subscription_status`, `free_scans_used`, `digest_enabled`, `can_scan` in response |
| `dashboard/src/lib/state.js` | Add `subscriptionStatus`, `freeScansUsed`, `canScan`, `digestEnabled`, `paywallOpen` signals |
| `dashboard/src/lib/api.js` | `loadUserData` reads new fields. New `openCheckout()`, `openPortal()`, `setDigestEnabled()` helpers. Handle `paywall` SSE event |
| `dashboard/src/components/Settings.jsx` | Replace beta-access copy (PR 0) with real billing section. Free → Upgrade button → checkout. Active → Manage subscription → portal. Past_due → Update payment. Canceled-but-active → "ends on [date]" + Reactivate. Digest toggle DB-synced |
| `dashboard/src/components/Sidebar.jsx` | "New Scan" button shows lock when `canScan = false`. Click → opens Settings panel scrolled to billing |
| `dashboard/src/components/Chat.jsx` | Render inline paywall message when `paywall` SSE event received. Button → openCheckout |
| `dashboard/src/styles.css` | `.paywall-msg`, `.btn-upgrade`, `.sidebar-new-scan.locked`, `.settings-manage-btn`, `.settings-cancel-meta` |
| `vercel.json` | Register 5 new function configs |

---

## Phase 1: Branch + Migration + Dependency

### Task 1: Branch off main

- [ ] Switch to main, pull, branch:

```bash
git checkout main
git pull
git checkout -b pr1-charge-people
git branch --show-current
```

Expected: `pr1-charge-people`. PR 0 must already be merged (or this branch can be off PR 0 if not yet merged).

### Task 2: DB migration (consolidated)

**File:** `migrations/2026-04-30-pr1-stripe.sql`

This is the COMPLETE migration for PR 1. PR 2 will add its own migration for HOT/STRONG threshold + tokens. Do not pre-add columns we don't use yet.

- [ ] **Step 1: Verify current `users` schema** via Supabase MCP `list_tables` (public schema). Confirm columns: `email` (PK), `agent_name`. Anything else? Note for migration.

- [ ] **Step 2: Create migrations dir if needed**

```bash
mkdir -p migrations
```

- [ ] **Step 3: Write the migration SQL** to `migrations/2026-04-30-pr1-stripe.sql`:

```sql
-- PR 1: Stripe paywall + simple scan counter
-- Adds subscription state, scan counter, digest preference, idempotency table.
-- Does NOT add HOT/STRONG threshold columns or token tracking — those are PR 2.

ALTER TABLE users
  ADD COLUMN IF NOT EXISTS stripe_customer_id TEXT,
  ADD COLUMN IF NOT EXISTS stripe_subscription_id TEXT,
  ADD COLUMN IF NOT EXISTS subscription_status TEXT DEFAULT 'inactive',
  ADD COLUMN IF NOT EXISTS subscription_current_period_end TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS subscription_cancel_at_period_end BOOLEAN DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS free_scans_used INTEGER NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS digest_enabled BOOLEAN NOT NULL DEFAULT TRUE;

CREATE INDEX IF NOT EXISTS users_stripe_customer_id_idx
  ON users (stripe_customer_id)
  WHERE stripe_customer_id IS NOT NULL;

CREATE TABLE IF NOT EXISTS stripe_events (
  id TEXT PRIMARY KEY,
  type TEXT NOT NULL,
  processed_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS stripe_events_processed_at_idx
  ON stripe_events (processed_at);
```

- [ ] **Step 4: Apply via Supabase MCP** `apply_migration` tool. Name: `pr1_stripe_2026_04_30`.

- [ ] **Step 5: Verify columns exist** via `execute_sql`:

```sql
SELECT column_name, data_type, column_default, is_nullable
FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'users'
  AND column_name IN (
    'stripe_customer_id', 'stripe_subscription_id', 'subscription_status',
    'subscription_current_period_end', 'subscription_cancel_at_period_end',
    'free_scans_used', 'digest_enabled'
  )
ORDER BY column_name;

SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'stripe_events');
```

Expected: 7 rows + `true`.

- [ ] **Step 6: Commit**

```bash
git add migrations/
git commit -m "feat(db): PR 1 stripe paywall migration (subscription cols + stripe_events)"
```

### Task 3: Install Stripe SDK

- [ ] Edit `package.json` — add `"stripe": "^17.5.0"` to dependencies (alphabetical between `@supabase/supabase-js` and `preact`).
- [ ] `npm install`
- [ ] Verify: `node -e "console.log(require('stripe'))"` should print the function.
- [ ] Commit:

```bash
git add package.json package-lock.json
git commit -m "feat(deps): add stripe SDK for PR 1"
```

---

## Phase 2: Backend Helpers (built BEFORE the routes use them — must-fix #7)

### Task 4: `api/_lib/stripe.js` — Stripe client + customer helper

- [ ] Write the helper:

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

- [ ] Commit.

### Task 5: `api/_lib/user.js` — subscription state + counter

**File:** `api/_lib/user.js`
**Test:** `tests/unit/user-helpers.test.js` and `tests/unit/subscription-active.test.js`

- [ ] **Step 1: Write the failing tests**

```javascript
// tests/unit/subscription-active.test.js
import { describe, it, expect } from 'vitest';
import { isSubscriptionActive } from '../../api/_lib/user.js';

describe('isSubscriptionActive', () => {
  const future = new Date(Date.now() + 7 * 86400 * 1000).toISOString();
  const past = new Date(Date.now() - 86400 * 1000).toISOString();

  it('active is active', () => {
    expect(isSubscriptionActive({ subscription_status: 'active' })).toBe(true);
  });
  it('trialing is active', () => {
    expect(isSubscriptionActive({ subscription_status: 'trialing' })).toBe(true);
  });
  it('inactive is not active', () => {
    expect(isSubscriptionActive({ subscription_status: 'inactive' })).toBe(false);
  });
  it('past_due is not active', () => {
    expect(isSubscriptionActive({ subscription_status: 'past_due' })).toBe(false);
  });
  it('canceled with future period_end IS active (until period_end)', () => {
    expect(isSubscriptionActive({
      subscription_status: 'canceled',
      subscription_current_period_end: future
    })).toBe(true);
  });
  it('canceled with past period_end is NOT active', () => {
    expect(isSubscriptionActive({
      subscription_status: 'canceled',
      subscription_current_period_end: past
    })).toBe(false);
  });
  it('canceled with no period_end is NOT active (defensive)', () => {
    expect(isSubscriptionActive({ subscription_status: 'canceled' })).toBe(false);
  });
});
```

```javascript
// tests/unit/user-helpers.test.js
import { describe, it, expect, afterAll, beforeEach } from 'vitest';
import { getTestSupabase } from '../helpers/supabase.js';
import { getUserSubscriptionState, incrementScansUsed } from '../../api/_lib/user.js';

const TEST_EMAIL = 'pr1-user-helpers@dealhound.dev';

describe('user helpers', () => {
  const supabase = getTestSupabase();

  beforeEach(async () => {
    await supabase.from('users').delete().eq('email', TEST_EMAIL);
    await supabase.from('users').insert({ email: TEST_EMAIL, agent_name: 'Test' });
  });

  afterAll(async () => {
    await supabase.from('users').delete().eq('email', TEST_EMAIL);
  });

  it('new user: 0 scans used, canScan true, status inactive', async () => {
    const state = await getUserSubscriptionState(supabase, TEST_EMAIL);
    expect(state.subscription_status).toBe('inactive');
    expect(state.free_scans_used).toBe(0);
    expect(state.canScan).toBe(true);
  });

  it('after one scan: free_scans_used 1, canScan false', async () => {
    await incrementScansUsed(supabase, TEST_EMAIL);
    const state = await getUserSubscriptionState(supabase, TEST_EMAIL);
    expect(state.free_scans_used).toBe(1);
    expect(state.canScan).toBe(false);
  });

  it('active subscription: canScan true regardless of counter', async () => {
    await incrementScansUsed(supabase, TEST_EMAIL);
    await supabase.from('users').update({ subscription_status: 'active' }).eq('email', TEST_EMAIL);
    const state = await getUserSubscriptionState(supabase, TEST_EMAIL);
    expect(state.canScan).toBe(true);
  });

  it('canceled-but-active: canScan true until period_end', async () => {
    await incrementScansUsed(supabase, TEST_EMAIL);
    const future = new Date(Date.now() + 7 * 86400 * 1000).toISOString();
    await supabase.from('users').update({
      subscription_status: 'canceled',
      subscription_current_period_end: future
    }).eq('email', TEST_EMAIL);
    const state = await getUserSubscriptionState(supabase, TEST_EMAIL);
    expect(state.canScan).toBe(true);
  });
});
```

- [ ] **Step 2: Run tests, confirm they fail** with module not found.

```bash
npx vitest run tests/unit/user-helpers.test.js tests/unit/subscription-active.test.js
```

- [ ] **Step 3: Implement `api/_lib/user.js`**

```javascript
// api/_lib/user.js
const ACTIVE_STATUSES = new Set(['active', 'trialing']);
const FREE_SCAN_LIMIT = 1;

function isSubscriptionActive(user) {
  if (!user) return false;
  if (ACTIVE_STATUSES.has(user.subscription_status)) return true;
  if (user.subscription_status === 'canceled' &&
      user.subscription_current_period_end &&
      new Date(user.subscription_current_period_end) > new Date()) {
    return true;
  }
  return false;
}

async function getUserSubscriptionState(supabase, email) {
  const { data, error } = await supabase
    .from('users')
    .select('email, subscription_status, free_scans_used, stripe_customer_id, digest_enabled, subscription_current_period_end, subscription_cancel_at_period_end')
    .eq('email', email)
    .single();

  if (error || !data) {
    return {
      subscription_status: 'inactive',
      free_scans_used: 0,
      stripe_customer_id: null,
      digest_enabled: true,
      subscription_current_period_end: null,
      subscription_cancel_at_period_end: false,
      canScan: true
    };
  }

  const active = isSubscriptionActive(data);
  const canScan = active || (data.free_scans_used || 0) < FREE_SCAN_LIMIT;

  return {
    subscription_status: data.subscription_status || 'inactive',
    free_scans_used: data.free_scans_used || 0,
    stripe_customer_id: data.stripe_customer_id || null,
    digest_enabled: data.digest_enabled !== false,
    subscription_current_period_end: data.subscription_current_period_end || null,
    subscription_cancel_at_period_end: !!data.subscription_cancel_at_period_end,
    canScan
  };
}

async function incrementScansUsed(supabase, email) {
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
  incrementScansUsed,
  setDigestEnabled,
  isSubscriptionActive,
  FREE_SCAN_LIMIT,
  ACTIVE_STATUSES
};
```

- [ ] **Step 4: Run tests, confirm pass.**

```bash
npx vitest run tests/unit/user-helpers.test.js tests/unit/subscription-active.test.js
```

- [ ] **Step 5: Commit.**

### Task 6: `api/_lib/scan-gate.js` (must-fix #7 — extracted from day one)

**File:** `api/_lib/scan-gate.js`
**Test:** `tests/integration/scan-gate.test.js`

- [ ] **Step 1: Write the failing test.**

```javascript
// tests/integration/scan-gate.test.js
import { describe, it, expect, afterAll, beforeEach } from 'vitest';
import { getTestSupabase } from '../helpers/supabase.js';
import { checkScanGate } from '../../api/_lib/scan-gate.js';

const TEST_EMAIL = 'pr1-scan-gate@dealhound.dev';

describe('checkScanGate', () => {
  const supabase = getTestSupabase();

  beforeEach(async () => {
    await supabase.from('users').delete().eq('email', TEST_EMAIL);
    await supabase.from('users').insert({ email: TEST_EMAIL, agent_name: 'Test' });
  });

  afterAll(async () => {
    await supabase.from('users').delete().eq('email', TEST_EMAIL);
  });

  it('allows new user (paywall on)', async () => {
    const result = await checkScanGate(supabase, TEST_EMAIL, true);
    expect(result.allowed).toBe(true);
  });

  it('blocks user with free_scans_used >= 1 and no subscription (paywall on)', async () => {
    await supabase.from('users').update({ free_scans_used: 1 }).eq('email', TEST_EMAIL);
    const result = await checkScanGate(supabase, TEST_EMAIL, true);
    expect(result.allowed).toBe(false);
    expect(result.reason).toBe('free_scan_used');
  });

  it('allows blocked user when paywall is off (env flag)', async () => {
    await supabase.from('users').update({ free_scans_used: 1 }).eq('email', TEST_EMAIL);
    const result = await checkScanGate(supabase, TEST_EMAIL, false);
    expect(result.allowed).toBe(true);
  });

  it('allows active subscriber even with high counter', async () => {
    await supabase.from('users').update({
      free_scans_used: 99,
      subscription_status: 'active'
    }).eq('email', TEST_EMAIL);
    const result = await checkScanGate(supabase, TEST_EMAIL, true);
    expect(result.allowed).toBe(true);
  });
});
```

- [ ] **Step 2: Run, confirm fail.**

- [ ] **Step 3: Implement.**

```javascript
// api/_lib/scan-gate.js
const { getUserSubscriptionState } = require('./user.js');

/**
 * Single source of truth for "can this user start a scan."
 * Called by api/chat.js before inserting a deal_searches row.
 *
 * Returns:
 *   { allowed: true,  reason: null,                 state: <subState> }
 *   { allowed: false, reason: 'free_scan_used',     state: <subState> }
 *
 * @param paywallEnabled — env var ENABLE_PAYWALL. When false, skip the gate
 *   (paywall code ships disabled; flip on after smoke test).
 */
async function checkScanGate(supabase, email, paywallEnabled) {
  const state = await getUserSubscriptionState(supabase, email);

  if (!paywallEnabled) {
    return { allowed: true, reason: null, state };
  }

  if (state.canScan) {
    return { allowed: true, reason: null, state };
  }

  return {
    allowed: false,
    reason: 'free_scan_used',
    state
  };
}

module.exports = { checkScanGate };
```

- [ ] **Step 4: Run, confirm pass.**

- [ ] **Step 5: Commit.**

---

## Phase 3: Stripe API Endpoints

### Task 7: `api/stripe-checkout.js` — checkout session

**File:** `api/stripe-checkout.js`
**Test:** `tests/integration/return-url-validation.test.js`

- [ ] **Step 1: Write the failing test for return_url validation (cross-cuts checkout + portal).**

```javascript
// tests/integration/return-url-validation.test.js
import { describe, it, expect } from 'vitest';

const HAS_STRIPE = !!process.env.STRIPE_SECRET_KEY && !!process.env.STRIPE_PRICE_ID;

describe.skipIf(!HAS_STRIPE)('return_url validation', () => {
  const ALLOW_ORIGINS = ['https://dealhound.pro', 'http://localhost:3000', 'http://localhost:5173'];
  const BAD = ['https://evil.com', 'javascript:alert(1)', 'http://localhost:9999/redirect?to=evil'];

  for (const goodOrigin of ALLOW_ORIGINS) {
    it(`accepts return_url ${goodOrigin}`, async () => {
      const handler = require('../../api/stripe-checkout.js');
      const req = mockReq('POST', { email: 'allowed@dealhound.dev', return_url: goodOrigin });
      const res = mockRes();
      await handler(req, res);
      expect([200, 500]).toContain(res.statusCode); // 500 only if Stripe API call fails — both indicate validation passed
    });
  }

  for (const bad of BAD) {
    it(`rejects return_url ${bad}`, async () => {
      const handler = require('../../api/stripe-checkout.js');
      const req = mockReq('POST', { email: 'allowed@dealhound.dev', return_url: bad });
      const res = mockRes();
      await handler(req, res);
      expect(res.statusCode).toBe(400);
      expect(res.body.error).toMatch(/return_url/i);
    });
  }
});

function mockReq(method, body) {
  return { method, headers: { origin: 'https://dealhound.pro' }, body };
}
function mockRes() {
  const r = {
    statusCode: 200, body: null, headers: {},
    setHeader(k, v) { this.headers[k] = v; },
    status(c) { this.statusCode = c; return this; },
    json(o) { this.body = o; return this; },
    end() { return this; }
  };
  return r;
}
```

- [ ] **Step 2: Run, confirm fail.**

- [ ] **Step 3: Implement.**

```javascript
// api/stripe-checkout.js
const { createClient } = require('@supabase/supabase-js');
const { getStripe, getOrCreateCustomer } = require('./_lib/stripe.js');

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_KEY
);

const ALLOWED_RETURN_URL_PREFIXES = [
  'https://dealhound.pro',
  'http://localhost:3000',
  'http://localhost:5173',
];

function validateReturnUrl(url, originHeader) {
  if (!url) return null; // null is OK; we'll fall back to origin
  if (typeof url !== 'string') return false;
  // Allow origin header match
  if (originHeader && url === originHeader) {
    return ALLOWED_RETURN_URL_PREFIXES.some(p => originHeader.startsWith(p));
  }
  return ALLOWED_RETURN_URL_PREFIXES.some(p => url.startsWith(p));
}

module.exports = async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  if (req.method === 'OPTIONS') {
    res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
    return res.status(200).end();
  }
  if (req.method !== 'POST') return res.status(405).json({ error: 'Method not allowed' });

  const { email, return_url } = req.body || {};
  if (!email) return res.status(400).json({ error: 'Missing email' });

  if (return_url !== undefined) {
    const ok = validateReturnUrl(return_url, req.headers.origin);
    if (!ok) return res.status(400).json({ error: 'Invalid return_url' });
  }

  const priceId = process.env.STRIPE_PRICE_ID;
  if (!priceId) return res.status(500).json({ error: 'STRIPE_PRICE_ID not configured' });

  try {
    const customerId = await getOrCreateCustomer(supabase, email);
    const stripe = getStripe();
    const baseUrl = return_url || req.headers.origin || 'https://dealhound.pro';

    // Auto-apply the FOUNDER coupon if configured. Avoids the UX bug where
    // paywall says "$48.50/mo" but Checkout shows $97 unless user manually
    // enters the code. Stripe note: when `discounts` is set, `allow_promotion_codes`
    // is ignored — they're mutually exclusive. We default to auto-applied discount;
    // partner-specific codes can be enabled in a follow-up by removing this default.
    const defaultCoupon = process.env.STRIPE_DEFAULT_COUPON;
    const session = await stripe.checkout.sessions.create({
      mode: 'subscription',
      customer: customerId,
      line_items: [{ price: priceId, quantity: 1 }],
      success_url: `${baseUrl}/dashboard?checkout=success`,
      cancel_url: `${baseUrl}/dashboard?checkout=cancel`,
      ...(defaultCoupon
        ? { discounts: [{ coupon: defaultCoupon }] }
        : { allow_promotion_codes: true }),
      subscription_data: { metadata: { user_email: email } }
    });

    return res.status(200).json({ url: session.url });
  } catch (err) {
    console.error('stripe-checkout error:', err.message);
    return res.status(500).json({ error: err.message });
  }
};
```

- [ ] **Step 4: Run, confirm pass (or skipIf-skipped without keys).**

- [ ] **Step 5: Commit.**

### Task 8: `api/stripe-portal.js` — customer portal session

**File:** `api/stripe-portal.js`

- [ ] Implement (mirrors stripe-checkout, returns billingPortal session URL):

```javascript
// api/stripe-portal.js
const { createClient } = require('@supabase/supabase-js');
const { getStripe, getOrCreateCustomer } = require('./_lib/stripe.js');

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_KEY
);

const ALLOWED_RETURN_URL_PREFIXES = [
  'https://dealhound.pro',
  'http://localhost:3000',
  'http://localhost:5173',
];

function validateReturnUrl(url, originHeader) {
  if (!url) return null;
  if (typeof url !== 'string') return false;
  if (originHeader && url === originHeader) {
    return ALLOWED_RETURN_URL_PREFIXES.some(p => originHeader.startsWith(p));
  }
  return ALLOWED_RETURN_URL_PREFIXES.some(p => url.startsWith(p));
}

module.exports = async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  if (req.method === 'OPTIONS') {
    res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
    return res.status(200).end();
  }
  if (req.method !== 'POST') return res.status(405).json({ error: 'Method not allowed' });

  const { email, return_url } = req.body || {};
  if (!email) return res.status(400).json({ error: 'Missing email' });

  if (return_url !== undefined) {
    const ok = validateReturnUrl(return_url, req.headers.origin);
    if (!ok) return res.status(400).json({ error: 'Invalid return_url' });
  }

  try {
    const customerId = await getOrCreateCustomer(supabase, email);
    const stripe = getStripe();
    const baseUrl = return_url || req.headers.origin || 'https://dealhound.pro';

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

- [ ] Add return_url tests for stripe-portal.js to the same `tests/integration/return-url-validation.test.js` file (mirror checkout cases).

- [ ] Commit.

### Task 9: `api/stripe-webhook.js` — receiver with signature, idempotency, all 5 event handlers

**File:** `api/stripe-webhook.js`
**Tests:** `tests/integration/stripe-webhook.test.js`, `tests/integration/webhook-idempotency.test.js`, `tests/integration/webhook-handlers.test.js`

- [ ] **Step 1: Write failing tests** (signature reject, idempotency dedup, each event type).

(See full test specs in: `tests/integration/stripe-webhook.test.js` already drafted in earlier amendment. Plus `webhook-idempotency.test.js` for the dedup case, and `webhook-handlers.test.js` for `customer.subscription.created`, `.updated`, `.deleted`, `checkout.session.completed`, `invoice.payment_failed`.)

For brevity here, the critical assertions:
- Bad signature → 400 (always, regardless of body)
- Same `event.id` posted twice → first call processes, second returns `{received: true, deduped: true}`, DB state changed exactly once
- `customer.subscription.created` with status=active → `users.subscription_status='active'`, `subscription_current_period_end` set
- `customer.subscription.updated` with `cancel_at_period_end=true` → `users.subscription_cancel_at_period_end=true` (status stays 'active' or whatever Stripe sends)
- `customer.subscription.deleted` → `users.subscription_status='canceled'`
- `invoice.payment_failed` → no DB write (just logs); `customer.subscription.updated` will fire with status=`past_due` separately

- [ ] **Step 2: Run, confirm fail.**

- [ ] **Step 3: Implement.**

```javascript
// api/stripe-webhook.js
const { createClient } = require('@supabase/supabase-js');
const { getStripe } = require('./_lib/stripe.js');

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_KEY
);

// Vercel: opt out of automatic body parsing so the signature check sees raw bytes.
module.exports.config = { api: { bodyParser: false } };

async function readRawBody(req) {
  if (req.rawBody && Buffer.isBuffer(req.rawBody)) return req.rawBody;
  if (typeof req.body === 'string') return Buffer.from(req.body, 'utf8');
  if (Buffer.isBuffer(req.body)) return req.body;
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
  const cancelAtPeriodEnd = !!sub.cancel_at_period_end;

  await supabase
    .from('users')
    .update({
      stripe_subscription_id: sub.id,
      subscription_status: status,
      subscription_current_period_end: periodEnd,
      subscription_cancel_at_period_end: cancelAtPeriodEnd
    })
    .eq('stripe_customer_id', customerId);
}

async function handleSubscriptionDeleted(sub) {
  // status flips to 'canceled' on Stripe's side. Mark in DB explicitly.
  await supabase
    .from('users')
    .update({
      subscription_status: 'canceled',
      subscription_cancel_at_period_end: false
    })
    .eq('stripe_customer_id', sub.customer);
}

async function handleCheckoutCompleted(session) {
  if (session.mode !== 'subscription') return;
  const customerId = session.customer;
  const email = session.customer_details?.email || session.customer_email;
  if (!customerId || !email) return;

  // Defensive: bind customer_id to user if not already set.
  await supabase
    .from('users')
    .update({ stripe_customer_id: customerId })
    .eq('email', email)
    .is('stripe_customer_id', null);
}

module.exports = async function handler(req, res) {
  if (req.method !== 'POST') return res.status(405).json({ error: 'Method not allowed' });

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

  // Idempotency dedup
  const { error: dupError } = await supabase
    .from('stripe_events')
    .insert({ id: event.id, type: event.type });
  if (dupError && dupError.code === '23505') {
    return res.status(200).json({ received: true, deduped: true });
  }

  try {
    switch (event.type) {
      case 'customer.subscription.created':
      case 'customer.subscription.updated':
        await handleSubscriptionEvent(event.data.object);
        break;
      case 'customer.subscription.deleted':
        await handleSubscriptionDeleted(event.data.object);
        break;
      case 'checkout.session.completed':
        await handleCheckoutCompleted(event.data.object);
        break;
      case 'invoice.payment_failed':
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
module.exports.config = { api: { bodyParser: false } };
```

- [ ] **Step 4: Run tests.**

- [ ] **Step 5: Commit.**

---

## Phase 4: Wire scan gate into chat.js + user-data + user-settings

### Task 10: Wire `checkScanGate` into `api/chat.js`

**File:** `api/chat.js` (modify)

The gate logic is already extracted in `api/_lib/scan-gate.js` (Task 6). Now `chat.js` just CALLS it. No inline logic.

- [ ] **Step 1: Add import** at the top of `chat.js`:

```javascript
const { checkScanGate } = require('./_lib/scan-gate.js');
const { incrementScansUsed } = require('./_lib/user.js');
```

- [ ] **Step 2: Inside `content_block_stop` branch where `toolUse.name === 'save_buy_box'`**, after parsing `buyBox` (after the existing try/catch on JSON.parse) and before `console.log('Saving buy box...')`, insert:

```javascript
const paywallEnabled = process.env.ENABLE_PAYWALL === 'true';
const gateResult = await checkScanGate(supabase, email, paywallEnabled);

if (!gateResult.allowed) {
  res.write(`data: ${JSON.stringify({
    type: 'paywall',
    reason: gateResult.reason,
    free_scans_used: gateResult.state.free_scans_used,
    subscription_status: gateResult.state.subscription_status
  })}\n\n`);
  toolUse = null;
  continue;
}
```

- [ ] **Step 3: After the `deal_searches` insert succeeds and the `buy_box_saved` event is written**, BEFORE `toolUse = null;` at end of block, add:

```javascript
try {
  await incrementScansUsed(supabase, email);
} catch (incErr) {
  console.error('Failed to increment scans counter:', incErr.message);
  // Non-fatal — the scan still ran. Counter will catch up next time.
}
```

- [ ] **Step 4: Run all integration tests.**

```bash
npm test
```

- [ ] **Step 5: Commit.**

### Task 11: Surface subscription state in `api/user-data.js`

**File:** `api/user-data.js` (modify)

- [ ] **Step 1: Import** `getUserSubscriptionState`:

```javascript
const { getUserSubscriptionState } = require('./_lib/user.js');
```

- [ ] **Step 2: After `const user = await getOrCreateUser(email);`**, fetch state in parallel:

```javascript
const subStatePromise = getUserSubscriptionState(supabase, email);
```

- [ ] **Step 3: Read existing return statement** (currently around line 208 — returns `{ agent_name, scans, deals, active_threads }`). Add subscription fields ALONGSIDE existing keys, do NOT replace them:

```javascript
const subState = await subStatePromise;
return res.status(200).json({
  agent_name: user.agent_name,
  subscription_status: subState.subscription_status,
  free_scans_used: subState.free_scans_used,
  digest_enabled: subState.digest_enabled,
  subscription_current_period_end: subState.subscription_current_period_end,
  subscription_cancel_at_period_end: subState.subscription_cancel_at_period_end,
  can_scan: subState.canScan,
  // ... existing keys (scans, deals, active_threads) untouched
});
```

- [ ] **Step 4: Run** `npx vitest run tests/integration/user-data.test.js`. Existing tests should still pass.

- [ ] **Step 5: Commit.**

### Task 12: `api/user-settings.js` — digest preference endpoint

**File:** `api/user-settings.js`

- [ ] Implement:

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
      return res.status(500).json({ error: err.message });
    }
  }

  return res.status(405).json({ error: 'Method not allowed' });
};
```

- [ ] Commit.

### Task 13: `api/admin/health.js` — basic Mac-worker observability

**File:** `api/admin/health.js`

- [ ] Implement (with `?key=` auth):

```javascript
// api/admin/health.js
const { createClient } = require('@supabase/supabase-js');
const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_KEY);

module.exports = async function handler(req, res) {
  if (req.method !== 'GET') return res.status(405).json({});

  const expected = process.env.ADMIN_HEALTH_KEY;
  if (!expected) return res.status(500).json({ error: 'ADMIN_HEALTH_KEY not configured' });
  if (req.query.key !== expected) return res.status(401).json({ error: 'Unauthorized' });

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

- [ ] Add to wake-up checklist: generate `ADMIN_HEALTH_KEY` (`openssl rand -hex 32`), add to Vercel env. Note: PR 3 adds email alerting on top of this endpoint.

- [ ] Tests in `tests/integration/admin-health-auth.test.js`.

- [ ] Commit.

### Task 14: Update `vercel.json`

- [ ] Add to `functions` map:

```json
"api/stripe-checkout.js": { "maxDuration": 10 },
"api/stripe-portal.js": { "maxDuration": 10 },
"api/stripe-webhook.js": { "maxDuration": 30 },
"api/user-settings.js": { "maxDuration": 5 },
"api/admin/health.js": { "maxDuration": 5 }
```

- [ ] Commit.

---

## Phase 5: Frontend (Settings, Sidebar, Chat, state, api lib)

### Task 15: Frontend state + api lib

**File:** `dashboard/src/lib/state.js`

- [ ] Add signals (after existing signals, near top):

```javascript
export const subscriptionStatus = signal('inactive');
export const freeScansUsed = signal(0);
export const canScan = signal(true);
export const digestEnabled = signal(true);
export const subscriptionPeriodEnd = signal(null);
export const subscriptionCancelAtPeriodEnd = signal(false);
export const paywallOpen = signal(false);
```

**File:** `dashboard/src/lib/api.js`

- [ ] Edit existing import to add new signals:

```javascript
import {
  email, agentName, scans, deals, activeThreads, starredDealIds,
  viewedDealIds, archivedDealIds,
  chatMessages, chatConversationId, chatStreaming,
  cacheGet, cacheSet, activeThreadId,
  subscriptionStatus, freeScansUsed, canScan, digestEnabled,
  subscriptionPeriodEnd, subscriptionCancelAtPeriodEnd, paywallOpen
} from './state.js';
```

- [ ] In `loadUserData`, after existing assignments, append:

```javascript
subscriptionStatus.value = data.subscription_status || 'inactive';
freeScansUsed.value = data.free_scans_used || 0;
canScan.value = data.can_scan !== false;
digestEnabled.value = data.digest_enabled !== false;
subscriptionPeriodEnd.value = data.subscription_current_period_end || null;
subscriptionCancelAtPeriodEnd.value = !!data.subscription_cancel_at_period_end;
```

- [ ] Add three exports:

```javascript
export async function openCheckout() {
  const res = await fetch('/api/stripe-checkout', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email: email.value, return_url: window.location.origin })
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
    body: JSON.stringify({ email: email.value, return_url: window.location.origin })
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

- [ ] In `sendMessage`, inside the SSE event-handling loop, after the `event.type === 'buy_box_saved'` branch, add a `paywall` branch:

```javascript
} else if (event.type === 'paywall') {
  const msgs = [...chatMessages.value];
  msgs.push({ role: 'assistant', content: '__PAYWALL__', paywall: true });
  chatMessages.value = msgs;
  freeScansUsed.value = event.free_scans_used;
  canScan.value = false;
  paywallOpen.value = true;
}
```

- [ ] Commit.

### Task 16: Settings.jsx rebuild

**File:** `dashboard/src/components/Settings.jsx`

Builds on PR 0 (which already replaced the `alert(...)` with beta copy). PR 1 swaps the beta copy for a real billing section with state-aware rendering.

- [ ] Replace the file:

```jsx
import { useEffect } from 'preact/hooks';
import {
  settingsOpen, email, subscriptionStatus, digestEnabled, freeScansUsed,
  subscriptionPeriodEnd, subscriptionCancelAtPeriodEnd
} from '../lib/state.js';
import { openCheckout, openPortal, setDigestEnabled as setDigestEnabledRemote } from '../lib/api.js';

export function Settings() {
  useEffect(() => {
    if (!settingsOpen.value) return;
    const handler = (e) => { if (e.key === 'Escape') settingsOpen.value = false; };
    window.addEventListener('keydown', handler);
    return () => window.removeEventListener('keydown', handler);
  }, [settingsOpen.value]);

  if (!settingsOpen.value) return null;

  const status = subscriptionStatus.value;
  const periodEnd = subscriptionPeriodEnd.value;
  const cancelAtPeriodEnd = subscriptionCancelAtPeriodEnd.value;
  const isActive = status === 'active' || status === 'trialing';
  const isCanceledButActive = status === 'canceled' && periodEnd && new Date(periodEnd) > new Date();
  const isPastDue = status === 'past_due';

  let planLabel = 'Free';
  if (isActive && cancelAtPeriodEnd) planLabel = 'Pro · cancels at period end';
  else if (isActive) planLabel = 'Pro · $48.50/mo';
  else if (isCanceledButActive) planLabel = 'Pro · ends ' + new Date(periodEnd).toLocaleDateString();
  else if (isPastDue) planLabel = 'Pro · payment past due';
  else if (status === 'canceled') planLabel = 'Free (subscription ended)';

  const toggleDigest = async (e) => {
    const newVal = e.target.checked;
    digestEnabled.value = newVal;
    await setDigestEnabledRemote(newVal);
  };

  const signOut = () => {
    localStorage.removeItem('dh_email');
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
          <div class="settings-plan">Plan: <strong>{planLabel}</strong></div>
          {!isActive && !isCanceledButActive && !isPastDue && (
            <>
              <div class="settings-plan-meta">
                {freeScansUsed.value === 0 ? 'Your first scan is free.' : 'Your free scan has been used.'}
              </div>
              <button class="settings-upgrade-btn" onClick={openCheckout}>
                Upgrade to Pro
              </button>
            </>
          )}
          {(isActive || isCanceledButActive) && (
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
          <a
            href={`mailto:gideon@stonemontcap.com?subject=${encodeURIComponent('Deal Hound feedback')}`}
            class="settings-link"
          >
            Send feedback →
          </a>
          <a href="mailto:support@dealhound.pro" class="settings-link">Contact support →</a>
        </div>

        <div class="settings-bottom">
          <button class="settings-signout" onClick={signOut}>Sign out</button>
        </div>
      </div>
    </div>
  );
}
```

- [ ] Commit.

### Task 17: Sidebar.jsx — lock state on New Scan

**File:** `dashboard/src/components/Sidebar.jsx` (modify)

- [ ] Add `canScan, paywallOpen` to existing import from state.js.

- [ ] Update `startNewScan`:

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

- [ ] Replace the New Scan button render with state-aware version:

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

- [ ] Commit.

### Task 18: Chat.jsx — paywall message

**File:** `dashboard/src/components/Chat.jsx` (modify)

- [ ] Import `openCheckout` from `../lib/api.js`.

- [ ] Add a `PaywallMessage` component near `WatchPlaceholder`:

```jsx
function PaywallMessage() {
  return (
    <div class="msg msg-assistant paywall-msg">
      <div class="msg-label"><span class="msg-dot" />Agent</div>
      <div class="msg-body">
        <p><strong>Your first scan is on us.</strong></p>
        <p>To run another scan, get unlimited scans + daily digest emails for $48.50/mo (founder pricing). Cancel anytime.</p>
        <button class="btn-upgrade" onClick={openCheckout}>Upgrade to Pro</button>
      </div>
    </div>
  );
}
```

- [ ] Modify the `chatMessages.value.map` to short-circuit on paywall messages. Find the existing block:

```jsx
{chatMessages.value.map((msg, i) => (
  <div key={i} class={`msg msg-${msg.role}`}>
    {/* ... existing rendering ... */}
  </div>
))}
```

Change to:

```jsx
{chatMessages.value.map((msg, i) => {
  if (msg.paywall) return <PaywallMessage key={i} />;
  return (
    <div key={i} class={`msg msg-${msg.role}`}>
      {/* keep existing JSX verbatim */}
    </div>
  );
})}
```

- [ ] Commit.

### Task 19: Paywall opens Settings panel — app.jsx effect

**File:** `dashboard/src/app.jsx` (modify)

- [ ] Add at top: `import { settingsOpen, paywallOpen } from './lib/state.js';`

- [ ] Inside `App()`, add an effect:

```jsx
useEffect(() => {
  if (paywallOpen.value) {
    settingsOpen.value = true;
    paywallOpen.value = false;
    setTimeout(() => {
      const btn = document.querySelector('.settings-upgrade-btn');
      if (btn) btn.scrollIntoView({ behavior: 'smooth', block: 'center' });
    }, 100);
  }
}, [paywallOpen.value]);
```

(Pulse animation on the upgrade button is PR 3 polish. PR 1 just scrolls.)

- [ ] Commit.

### Task 20: Styles for paywall + lock + manage button

**File:** `dashboard/src/styles.css` (modify)

- [ ] Append:

```css
/* Paywall message in chat */
.paywall-msg .msg-body {
  background: linear-gradient(135deg, var(--gold-glow), var(--gold-dim));
  border-left: 3px solid var(--gold);
  padding: 16px 18px;
  border-radius: 6px;
}
.paywall-msg .msg-body p { margin: 0 0 8px; }
.paywall-msg .msg-body p:last-of-type { margin-bottom: 14px; }

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
```

- [ ] Commit.

---

## Phase 6: Verify, Test, Ship

### Task 21: Build + tests

- [ ] `npm run build` — fix any errors.
- [ ] `npm test` — all tests pass (Stripe-dependent ones skipIf-skipped without env vars; that's fine).
- [ ] `npm run test:smoke`

### Task 22: PR + smoke test

- [ ] Push branch:

```bash
git push -u origin pr1-charge-people
```

- [ ] Open PR with the wake-up checklist embedded:

```bash
gh pr create --title "feat: PR 1 — Stripe paywall + scan metering" --body "$(cat <<'EOF'
## Summary
- Stripe Checkout + Customer Portal + webhook (signature verify, idempotency, return_url allowlist, cancel-but-active)
- Scan-count gate via api/_lib/scan-gate.js (extracted from day one — must-fix #7)
- Settings billing section: real upgrade + manage subscription
- DB migration: 7 columns + stripe_events table
- Feature-flagged via ENABLE_PAYWALL env var (default off)

## Wake-up checklist (Gideon)
See `docs/superpowers/plans/2026-04-30-pr1-charge-people.md` top section. Stripe Dashboard config + 5 env vars needed before flipping ENABLE_PAYWALL=true.

## Test plan
- [ ] Stripe test mode env vars set in Vercel
- [ ] Create FOUNDER coupon (50% off forever) in Stripe Dashboard
- [ ] Webhook endpoint registered, signing secret in env
- [ ] Migration applied, columns verified
- [ ] Smoke: incognito → email gate → first scan free → second scan attempt shows paywall
- [ ] Click Upgrade → Stripe Checkout → 4242... + FOUNDER → return → unlocked
- [ ] Settings → Manage subscription → Stripe Portal → cancel → access until period_end
- [ ] Webhook events fire, DB state updates
- [ ] Flip ENABLE_PAYWALL=true after smoke passes

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

- [ ] After Gideon does Stripe Dashboard config + adds env vars + merges + Vercel deploys, smoke test the live flow.

- [ ] Flip `ENABLE_PAYWALL=true` in Vercel only after smoke test passes.

---

## Risks & Mitigations

| Risk | Mitigation |
|---|---|
| Vercel raw body handling fails (signature 400 in prod) | `bodyParser: false` + multi-fallback `readRawBody`. Verify via Vercel logs after deploy. |
| User completes Checkout, returns before webhook fires → state shows Free | After `?checkout=success`, frontend reloads user-data immediately. May see stale state for ~5s. Acceptable. |
| Cancel during period → user locked out | A5 logic: `isSubscriptionActive` returns true when `canceled` + future `period_end`. Tested. |
| Missing Stripe env vars at deploy | Stripe client lazy-loaded; routes return 500 with clear error rather than crashing. |
| `ENABLE_PAYWALL=false` left on after smoke | Add to wake-up checklist final step: "Flip ENABLE_PAYWALL=true." |
| Mac mini drops worker mid-customer scan | `/api/admin/health` endpoint exists; PR 3 adds email alerting. For MVP customer count, manual curl is acceptable. |

## Definition of Done

- [ ] PR merged to main
- [ ] All env vars + Stripe coupon configured
- [ ] Live site charges a real card (via 4242... in test mode at minimum)
- [ ] Customer Portal cancel flow works end-to-end
- [ ] `ENABLE_PAYWALL=true` flipped in Vercel
- [ ] No regression on PR 0 beta-access experience for users who haven't used their free scan
