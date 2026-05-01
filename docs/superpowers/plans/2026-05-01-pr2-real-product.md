# PR 2 — Real Product (Magic Link + HOT/STRONG + Tokens)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace PR 1's simple counter and email-in-body auth with the real spec — HOT/STRONG threshold metering, token budget tracking, and magic-link auth with proper JWT verification.

**Branch:** new branch `pr2-real-product` off `main` (after PR 1 is merged).

**Time estimate:** ~4-5 hrs CC + Gideon's Supabase Auth + 2 env var config (~10 min).

**Architecture:** Three subsystems land together because they're interdependent at the chat.js gate layer:

1. **HOT/STRONG threshold metering** — sticky boolean (`has_qualifying_free_scan`) set at scan completion, not at gate time. Replaces the simple `free_scans_used` counter from PR 1.
2. **Token budget tracking** — `$1.50/mo` free, `$6/mo` paid, in `NUMERIC(10,4)` cents (no per-call rounding). Pre-debit estimate before Anthropic, refund unused after. Capped `max_tokens` for free tier so single message can't exhaust budget.
3. **Magic-link auth** — Supabase Auth `signInWithOtp`, local JWT verification via `jose` lib (no Supabase Auth network call per request). Dual-auth fallback during migration: accept JWT OR legacy email-from-body for one release, then enforce JWT-only.

---

## Must-fixes from outside-voice review (baked in)

- **#2 — `has_qualifying_free_scan` is sticky, not recomputed.** Set once at scan completion, never recomputed. Even canceled paid users keep their qualifying flag. (If you want to re-give them the free experience after subscribing once, that's a separate product decision — defer.)
- **#3 — Pre-debit caps `max_tokens` for free tier** at 1500 (paid: 4096). Estimate = inputTokens × 3 + min(maxOutputTokens × 25%, free_budget_remaining × 80%) × 15. Free user can't exhaust budget on a single message.
- **#4 — JWT migration with dual-auth fallback.** Phase 2A adds JWT verification to all endpoints but keeps accepting email-from-body. Phase 2B (after one release in prod) flips to JWT-only.
- **#5 — `dh_email` localStorage purged completely.** All reads go through `supabase.auth.getSession()`. No compat layer.
- **#6 — Supabase Auth rate-limit handling.** EmailGate catches `over_email_send_rate_limit` (429) and shows "Try again in N minutes." Resend has 60s client throttle.

---

## What's in PR 2

- DB migration B: drop `free_scans_used`, add `has_qualifying_free_scan`, `chat_tokens_used_cents` (NUMERIC(10,4)), `chat_tokens_reset_at`. Add `increment_token_usage` RPC.
- Magic-link auth via Supabase Auth + `jose` JWT verification helper.
- All 12+ existing API endpoints migrated to JWT-from-Authorization-header (with dual-auth fallback during this PR).
- Auth callback as Preact route in app.jsx (not standalone HTML).
- HOT/STRONG threshold logic, set at scan completion in worker pipeline (or in scan-progress.js when status flips to complete).
- `api/_lib/scan-gate.js` updated to use the boolean, not the counter.
- Token budget tracking (`api/_lib/token.js`): pre-debit, refund, capped max_tokens, lazy reset.
- Agent buy-box loosening suggestion in `buildDebriefPrompt()` when scan completes below threshold.
- EmailGate UI: send/sent/error/resend states, rate-limit-aware.
- Resend magic-link button with 60s client throttle.
- `dh_email` localStorage removed everywhere.

## What's NOT in PR 2 (deferred to PR 3)

- PostHog analytics events
- Usage indicator in Settings
- Mac-worker email alerting
- Loading spinner UI on email gate
- Post-pay celebration banner
- Lock-pulse animation
- Mobile bottom-sheet for paywall
- a11y additions (aria-live, contrast fixes, touch target verification)

---

## Wake-Up Checklist for Gideon

Before merging PR 2:

### Supabase Dashboard

- [ ] **Enable Email magic link.** Authentication → Providers → Email → enable `Email Magic Link`. Default email templates are fine for MVP.
- [ ] **Set Site URL:** Authentication → URL Configuration → Site URL = `https://dealhound.pro`.
- [ ] **Add Redirect URL:** Authentication → URL Configuration → Redirect URLs → add `https://dealhound.pro/auth/callback` (and `http://localhost:5173/auth/callback` for local dev if needed).
- [ ] **Copy JWT Secret:** Settings → API → "JWT Secret" → copy. (This is different from anon/service keys.)

### Vercel Dashboard

Add to all environments:

- [ ] `SUPABASE_JWT_SECRET` = (the JWT Secret from above)
- [ ] `VITE_SUPABASE_URL` = same as `SUPABASE_URL` but VITE-prefixed for frontend exposure
- [ ] `VITE_SUPABASE_ANON_KEY` = anon key from Supabase → Settings → API (NOT the service key)

### Local `.env`

- [ ] Mirror the same three vars locally.

---

## File Structure

### New files

| File | Responsibility |
|---|---|
| `migrations/2026-05-01-pr2-real-product.sql` | Drop free_scans_used; add has_qualifying_free_scan, chat_tokens_used_cents, chat_tokens_reset_at; create increment_token_usage RPC |
| `api/_lib/auth.js` | `getUserFromRequest(req)` — JWT verify via jose, dual-auth fallback to body email |
| `api/_lib/token.js` | `getTokenBudget`, `estimateMessageCost`, `computeActualCost`, `debitTokens`, `refundTokens` |
| `dashboard/src/lib/supabase.js` | Frontend Supabase client (`auth.signInWithOtp`, etc.) |
| `tests/unit/scan-gate-threshold.test.js` | HOT/STRONG threshold counting; sticky boolean behavior |
| `tests/unit/token-budget.test.js` | Lazy reset, exhaustion, capped max_tokens, pre-debit + refund flow |
| `tests/unit/auth-helper.test.js` | Missing token, invalid sig, valid token, dual-auth fallback |
| `tests/integration/magic-link-rate-limit.test.js` | UI handles `over_email_send_rate_limit` |

### Modified files

| File | What changes |
|---|---|
| `api/_lib/user.js` | Replace `incrementScansUsed` with `setQualifyingScan(email, true)`. Keep `getUserSubscriptionState` but read `has_qualifying_free_scan` not counter |
| `api/_lib/scan-gate.js` | Updated to read `has_qualifying_free_scan` boolean. Remove counter logic |
| `api/chat.js` | Use `getUserFromRequest` (JWT). Pre-debit tokens before Anthropic stream. Refund after. Update buildDebriefPrompt to suggest loosening when scan below threshold |
| `api/deal-chat.js` | Same JWT migration + token tracking pattern |
| `api/scan-progress.js` | When status flips to 'complete', count HOT/STRONG, set `users.has_qualifying_free_scan` if threshold met |
| All other `/api/*.js` (8 files) | Migrate to JWT-from-Authorization (with email-from-body fallback during this PR) |
| `dashboard/src/app.jsx` | Add `/auth/callback` route handling. Remove dh_email reads. Use Supabase session as truth |
| `dashboard/src/components/EmailGate.jsx` (new — extract from app.jsx) | Send/sent/error/resend states. Supabase rate-limit handling |
| `dashboard/src/lib/api.js` | All fetch calls use `authedFetch` helper that adds `Authorization: Bearer <token>` |
| `package.json` | Add `jose` |

---

## Phase 1: Migration + Helpers

### Task 1: Branch + migration B

```bash
git checkout main && git pull
git checkout -b pr2-real-product
```

**File:** `migrations/2026-05-01-pr2-real-product.sql`

```sql
-- PR 2: HOT/STRONG threshold + token budget
-- Drops the simple counter from PR 1, replaces with sticky qualifying flag.
-- Adds token tracking columns and atomic increment RPC.

ALTER TABLE users
  ADD COLUMN IF NOT EXISTS has_qualifying_free_scan BOOLEAN NOT NULL DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS chat_tokens_used_cents NUMERIC(10,4) NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS chat_tokens_reset_at TIMESTAMPTZ NOT NULL DEFAULT now();

-- Backfill: any user with PR 1's free_scans_used >= 1 has effectively a qualifying scan
-- (best-effort; PR 1's counter doesn't actually know if it was qualifying. Treating
-- "they had a scan" as "they qualified" is more conservative — won't unfairly free anyone)
UPDATE users SET has_qualifying_free_scan = TRUE WHERE free_scans_used >= 1;

-- DO NOT drop free_scans_used yet. There's a deploy-ordering window between
-- migration apply and PR 2 code deploy where PR 1 code is still running and
-- writes to free_scans_used. Dropping it now would cause 500s during that window
-- and would break the rollback path (rollback to PR 1 code → column missing).
--
-- Cleanup migration (TODO): after PR 2 has been stable in prod for ~1 week,
-- add a cleanup migration: ALTER TABLE users DROP COLUMN free_scans_used;

-- Atomic increment for token usage (handles concurrent chat messages)
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

Apply via Supabase MCP `apply_migration`. Verify with `execute_sql`. Commit.

### Task 2: Install `jose`

```bash
npm install jose
```

Commit.

### Task 3: `api/_lib/auth.js` with dual-auth fallback (must-fix #4)

```javascript
// api/_lib/auth.js
const { jwtVerify } = require('jose');

const JWT_SECRET = process.env.SUPABASE_JWT_SECRET
  ? new TextEncoder().encode(process.env.SUPABASE_JWT_SECRET)
  : null;

/**
 * Get the authenticated user from the request.
 *
 * DUAL-AUTH FALLBACK (PR 2 only — remove in a follow-up after one prod release):
 *   1. If Authorization: Bearer <jwt> header present → verify locally via jose
 *   2. Else fall back to email in request body/query (legacy)
 *
 * Returns: { id?, email, source: 'jwt' | 'legacy' }
 * Throws: if neither auth method works
 */
async function getUserFromRequest(req) {
  // Try JWT first
  const authHeader = req.headers.authorization || '';
  const token = authHeader.replace('Bearer ', '');
  if (token && JWT_SECRET) {
    try {
      const { payload } = await jwtVerify(token, JWT_SECRET, { algorithms: ['HS256'] });
      if (payload.email) {
        return { id: payload.sub, email: payload.email, source: 'jwt' };
      }
    } catch (err) {
      // Fall through to legacy
      console.warn('JWT verify failed, falling back to legacy:', err.message);
    }
  }

  // Legacy fallback: email in body/query
  const email = req.body?.email || req.query?.email;
  if (email) {
    return { id: null, email, source: 'legacy' };
  }

  throw new Error('Unauthorized: no JWT or email');
}

module.exports = { getUserFromRequest };
```

Tests in `tests/unit/auth-helper.test.js`:
- Missing both → throws
- Valid JWT → returns email + source 'jwt'
- Invalid JWT + email in body → returns email + source 'legacy'
- No JWT + email in body → returns email + source 'legacy'
- Invalid JWT + no email → throws

Commit.

### Task 4: `api/_lib/token.js` — pre-debit + refund (must-fix #3)

```javascript
// api/_lib/token.js
const { isSubscriptionActive } = require('./user.js');

const FREE_BUDGET_CENTS = 150;     // $1.50/mo
const PRO_BUDGET_CENTS = 600;      // $6.00/mo
const RESET_INTERVAL_DAYS = 30;

const FREE_MAX_OUTPUT = 1500;      // cap to prevent single-message budget exhaustion
const PRO_MAX_OUTPUT = 4096;

/**
 * Returns the user's max_tokens cap based on tier.
 */
function getMaxTokens(user) {
  return isSubscriptionActive(user) ? PRO_MAX_OUTPUT : FREE_MAX_OUTPUT;
}

/**
 * Returns budget state, lazily resetting if reset interval has passed.
 */
async function getTokenBudget(supabase, email) {
  const { data: user } = await supabase
    .from('users')
    .select('chat_tokens_used_cents, chat_tokens_reset_at, subscription_status, subscription_current_period_end')
    .eq('email', email)
    .single();

  if (!user) {
    return {
      allowed: true,
      remaining_cents: FREE_BUDGET_CENTS,
      budget_cents: FREE_BUDGET_CENTS,
      used_cents: 0,
      reset_at: null,
      is_paid: false,
      max_output_tokens: FREE_MAX_OUTPUT
    };
  }

  const isPaid = isSubscriptionActive(user);
  const budget = isPaid ? PRO_BUDGET_CENTS : FREE_BUDGET_CENTS;

  // Lazy reset
  const resetAt = new Date(user.chat_tokens_reset_at || 0);
  const nextReset = new Date(resetAt.getTime() + RESET_INTERVAL_DAYS * 86400 * 1000);
  let used = Number(user.chat_tokens_used_cents || 0);
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
    is_paid: isPaid,
    max_output_tokens: isPaid ? PRO_MAX_OUTPUT : FREE_MAX_OUTPUT
  };
}

/**
 * Estimate cost of a chat message, used for pre-debit.
 * Conservative: estimate input + 25% of max output (or remaining budget × 80%, whichever is lower).
 */
function estimateMessageCost(messages, budget) {
  const inputChars = JSON.stringify(messages).length;
  const inputTokens = Math.ceil(inputChars / 4); // rough char→token
  // Conservative output estimate: 25% of max_tokens, but never more than 80% of remaining budget
  const maxOutputBudgetTokens = budget.remaining_cents > 0
    ? Math.floor((budget.remaining_cents * 0.8 * 10000 - inputTokens * 3) / 15)
    : 0;
  const outputEstimate = Math.min(budget.max_output_tokens * 0.25, maxOutputBudgetTokens);
  const cost = (inputTokens * 3 + Math.max(0, outputEstimate) * 15) / 10000;
  return Math.max(0, cost);
}

/**
 * Compute actual cost from Anthropic usage. Returns raw cents (NOT rounded — addresses A20).
 */
function computeActualCost(usage) {
  return (usage.input_tokens * 3 + usage.output_tokens * 15) / 10000;
}

async function debitTokens(supabase, email, cents) {
  const { data, error } = await supabase.rpc('increment_token_usage', { p_email: email, p_cents: cents });
  if (error) throw error;
  return data;
}

async function refundTokens(supabase, email, cents) {
  return debitTokens(supabase, email, -cents);
}

module.exports = {
  FREE_BUDGET_CENTS,
  PRO_BUDGET_CENTS,
  FREE_MAX_OUTPUT,
  PRO_MAX_OUTPUT,
  getMaxTokens,
  getTokenBudget,
  estimateMessageCost,
  computeActualCost,
  debitTokens,
  refundTokens
};
```

Tests in `tests/unit/token-budget.test.js`:
- Lazy reset triggers when reset_at + 30 days < now
- Exhausted budget returns allowed=false
- Paid user gets PRO_BUDGET
- estimateMessageCost caps output by remaining budget × 80%
- computeActualCost returns raw float (not rounded)
- debit/refund are atomic via RPC

Commit.

---

## Phase 2: Replace counter with HOT/STRONG threshold (must-fix #2)

### Task 5: Update `api/_lib/user.js`

Replace `incrementScansUsed` with `setQualifyingScan`:

```javascript
// In api/_lib/user.js

async function setQualifyingScan(supabase, email) {
  await supabase
    .from('users')
    .update({ has_qualifying_free_scan: true })
    .eq('email', email);
}

// Update getUserSubscriptionState to read has_qualifying_free_scan instead of free_scans_used
async function getUserSubscriptionState(supabase, email) {
  // ... select 'has_qualifying_free_scan' instead of 'free_scans_used'
  // ... canScan = active || !user.has_qualifying_free_scan
}

module.exports = { /* ...existing exports... */, setQualifyingScan };
```

(Remove `incrementScansUsed` and `FREE_SCAN_LIMIT` exports — no longer needed.)

### Task 6: Update `api/_lib/scan-gate.js`

```javascript
// scan-gate.js — same shape as PR 1, just reads boolean now
async function checkScanGate(supabase, email, paywallEnabled) {
  const state = await getUserSubscriptionState(supabase, email);
  if (!paywallEnabled) return { allowed: true, reason: null, state };
  if (state.canScan) return { allowed: true, reason: null, state };
  return { allowed: false, reason: 'qualifying_scan_used', state };
}
```

### Task 7: Set `has_qualifying_free_scan` at scan completion

**File:** `api/scan-progress.js` (modify) — when GET response shows status='complete' for the first time AND the deals contain ≥1 HOT or ≥10 STRONG, set the flag.

Better: do this in a dedicated endpoint or in the worker callback. For MVP, piggyback on scan-progress.js since it polls until complete:

```javascript
// In api/scan-progress.js, after the existing "if complete, get deal count" block:

if (search.status === 'complete') {
  // Check threshold and set qualifying flag (idempotent)
  const { data: deals } = await supabase
    .from('deals')
    .select('score_breakdown')
    .eq('search_id', searchId)
    .eq('passed_hard_filters', true);

  if (deals && deals.length > 0) {
    const hotCount = deals.filter(d => {
      const overall = d.score_breakdown?.strategy?.overall;
      return overall === 'HOT MATCH';
    }).length;
    const strongCount = deals.filter(d => {
      const overall = d.score_breakdown?.strategy?.overall;
      return overall === 'STRONG MATCH';
    }).length;

    if (hotCount >= 1 || strongCount >= 10) {
      await supabase
        .from('users')
        .update({ has_qualifying_free_scan: true })
        .eq('email', search.user_email)
        .eq('has_qualifying_free_scan', false); // only flip from false to true (sticky)
    }
  }
}
```

Tests in `tests/unit/scan-gate-threshold.test.js`:
- 0 HOT + 0 STRONG → not qualifying
- 1 HOT → qualifying
- 0 HOT + 9 STRONG → not qualifying
- 0 HOT + 10 STRONG → qualifying
- Once true, stays true (call again with no deals → still true)

### Task 8: Agent buy-box loosening suggestion when scan below threshold

**File:** `api/chat.js` — `buildDebriefPrompt()`

Add to the prompt when deals are returned but threshold not met:

```javascript
// In buildDebriefPrompt:
const hotCount = deals.filter(d => d.score_breakdown?.strategy?.overall === 'HOT MATCH').length;
const strongCount = deals.filter(d => d.score_breakdown?.strategy?.overall === 'STRONG MATCH').length;
const belowThreshold = hotCount < 1 && strongCount < 10;

const loosenInstruction = belowThreshold ? `

IMPORTANT: This scan returned ${deals.length} deals but only ${hotCount} HOT and ${strongCount} STRONG matches — below the threshold for a qualifying first scan.

After your analysis, suggest 2-3 SPECIFIC adjustments to the buy box that would surface more matches. Examples:
- "Your acreage minimum of 50 might be too tight — try 25 to see candidates like X"
- "Hill Country only is restrictive — consider expanding to Hill Country + Piney Woods"
- "Cash-flow-day-1 excludes value-add opportunities — open to include those?"

Tie each suggestion to a specific deal you saw that ALMOST qualified. End with: "Want me to rerun with [specific change]?"
` : '';

// Append loosenInstruction to the existing prompt template
```

Commit.

---

## Phase 3: Token budget wiring

### Task 9: Wire tokens into `api/chat.js` and `api/deal-chat.js`

For both `chat.js` and `deal-chat.js`, before the Anthropic stream:

```javascript
const { getTokenBudget, estimateMessageCost, computeActualCost, debitTokens, refundTokens } = require('./_lib/token.js');

// ... inside handler, after getting email:
const budget = await getTokenBudget(supabase, email);
if (!budget.allowed) {
  res.write(`data: ${JSON.stringify({
    type: 'token_exhausted',
    renew_at: budget.reset_at
  })}\n\n`);
  return res.end();
}

const estimateCents = estimateMessageCost(messages, budget);
await debitTokens(supabase, email, estimateCents);

let actualUsage = null;
let streamErrored = false;
try {
  const stream = await client.messages.stream({
    model: 'claude-sonnet-4-20250514',
    max_tokens: budget.max_output_tokens,
    system: systemPrompt,
    messages: messages.map(m => ({ role: m.role, content: m.content }))
  });

  for await (const event of stream) {
    // ... existing event handling ...
  }

  const final = await stream.finalMessage();
  actualUsage = final.usage;
} catch (err) {
  streamErrored = true;
  await refundTokens(supabase, email, estimateCents);
  throw err;
}

// Settle
if (actualUsage && !streamErrored) {
  const actualCents = computeActualCost(actualUsage);
  const delta = estimateCents - actualCents;
  if (delta > 0) await refundTokens(supabase, email, delta);
  else if (delta < 0) await debitTokens(supabase, email, -delta);
}
```

Frontend: in `dashboard/src/lib/api.js` `sendMessage`, handle the new SSE event:

```javascript
} else if (event.type === 'token_exhausted') {
  const msgs = [...chatMessages.value];
  const renewDate = new Date(event.renew_at).toLocaleDateString();
  msgs.push({
    role: 'assistant',
    content: `Your free chat allotment renews on ${renewDate}. Upgrade to continue chatting now.`
  });
  chatMessages.value = msgs;
}
```

Commit.

---

## Phase 4: Magic-link auth

### Task 10: Frontend Supabase client + EmailGate refactor

**File:** `dashboard/src/lib/supabase.js` (new)

```javascript
import { createClient } from '@supabase/supabase-js';
const url = import.meta.env.VITE_SUPABASE_URL;
const anonKey = import.meta.env.VITE_SUPABASE_ANON_KEY;
export const supabase = createClient(url, anonKey, {
  auth: { persistSession: true, autoRefreshToken: true, detectSessionInUrl: true }
});
```

**File:** `dashboard/src/components/EmailGate.jsx` (new — extract from app.jsx)

```jsx
import { useState } from 'preact/hooks';
import { supabase } from '../lib/supabase.js';

export function EmailGate() {
  const [emailInput, setEmailInput] = useState('');
  const [state, setState] = useState('initial'); // 'initial' | 'sending' | 'sent' | 'error' | 'rate_limited'
  const [errorMsg, setErrorMsg] = useState(null);
  const [resendCooldown, setResendCooldown] = useState(0);

  const sendLink = async (email) => {
    setState('sending');
    setErrorMsg(null);
    const { error } = await supabase.auth.signInWithOtp({
      email,
      options: { emailRedirectTo: `${window.location.origin}/auth/callback` }
    });
    if (error) {
      // Supabase rate-limit codes
      if (error.status === 429 || /rate/i.test(error.message)) {
        setState('rate_limited');
        setErrorMsg('Too many requests. Try again in a few minutes.');
      } else {
        setState('error');
        setErrorMsg(error.message);
      }
      return;
    }
    setState('sent');
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    const val = e.target.elements.email.value.trim();
    if (!val) return;
    setEmailInput(val);
    sendLink(val);
  };

  const handleResend = () => {
    if (resendCooldown > 0) return;
    sendLink(emailInput);
    setResendCooldown(60);
    const interval = setInterval(() => {
      setResendCooldown(c => {
        if (c <= 1) { clearInterval(interval); return 0; }
        return c - 1;
      });
    }, 1000);
  };

  if (state === 'sent') {
    return (
      <div class="email-gate">
        <h1>Check your <em>inbox</em>.</h1>
        <p>We sent a magic link to <strong>{emailInput}</strong>. Click it to sign in.</p>
        <button
          class="btn-resend"
          onClick={handleResend}
          disabled={resendCooldown > 0}
        >
          {resendCooldown > 0 ? `Resend in ${resendCooldown}s` : "Didn't get it? Resend"}
        </button>
      </div>
    );
  }

  if (state === 'rate_limited') {
    return (
      <div class="email-gate">
        <h1>Slow down a moment.</h1>
        <p>{errorMsg}</p>
        <button class="btn-primary" onClick={() => setState('initial')}>Try a different email</button>
      </div>
    );
  }

  return (
    <div class="email-gate">
      <h1>Your <em>deal hunting</em><br />command center.</h1>
      <p>Enter your email and we'll send you a magic link.</p>
      <form class="gate-form" onSubmit={handleSubmit}>
        <input type="email" name="email" placeholder="your@email.com" required autocomplete="email" autofocus disabled={state === 'sending'} />
        <button type="submit" class="btn-primary" disabled={state === 'sending'}>
          {state === 'sending' ? 'Sending…' : 'Send magic link'}
        </button>
      </form>
      {state === 'error' && <p class="email-gate-error">{errorMsg}</p>}
    </div>
  );
}
```

(Loading spinner inside the button is PR 3 polish; PR 2 just disables + changes label.)

### Task 11: Auth callback as Preact route in app.jsx (must-fix #18 from earlier eng review)

In `dashboard/src/app.jsx`, before the existing `App()` body:

```jsx
import { supabase } from './lib/supabase.js';

function AuthCallback() {
  useEffect(() => {
    (async () => {
      const url = new URL(window.location.href);
      const errorParam = url.searchParams.get('error') || (url.hash.includes('error=') ? 'invalid_token' : null);
      if (errorParam) {
        window.location.replace(`/dashboard?auth_error=${errorParam}`);
        return;
      }
      // detectSessionInUrl in supabase client config picks up the access_token from the URL fragment
      const { data, error } = await supabase.auth.getSession();
      if (error || !data.session) {
        window.location.replace('/dashboard?auth_error=invalid_token');
        return;
      }
      // Cleanup the URL fragment
      window.history.replaceState({}, document.title, '/dashboard');
      window.location.reload(); // ensure App.useEffect picks up the session
    })();
  }, []);
  return <div class="auth-callback-loading">Signing you in…</div>;
}

export function App() {
  if (window.location.pathname === '/auth/callback') {
    return <AuthCallback />;
  }
  // ... rest of existing App body
}
```

In `vercel.json`, add:

```json
{ "source": "/auth/callback", "destination": "/dashboard-dist/index.html" }
```

### Task 12: Remove `dh_email` localStorage everywhere (must-fix #5)

- In `app.jsx`: replace `localStorage.getItem('dh_email')` with `await supabase.auth.getSession()`. Set email signal from session.user.email.
- Sign out: `await supabase.auth.signOut()` instead of `localStorage.removeItem('dh_email')`.
- Settings.jsx sign-out button: same.
- Search the entire `dashboard/src/` for any other `dh_email` references — remove all.

```bash
grep -rn "dh_email" /Users/gideonspencer/dealhound-pro/dashboard/src/
```

Verify: `git grep -n "dh_email" dashboard/` returns no results after this task.

### Task 13: All API endpoints use `getUserFromRequest`

Affected: `api/chat.js`, `api/deal-chat.js`, `api/user-data.js`, `api/scan-start.js`, `api/scan-progress.js`, `api/star-deal.js`, `api/view-deal.js`, `api/archive-deal.js`, `api/conversation.js`, `api/user-settings.js`, `api/stripe-checkout.js`, `api/stripe-portal.js`.

For each: at top of handler (after CORS), replace email parsing with:

```javascript
const { getUserFromRequest } = require('./_lib/auth.js');
// ...
let user;
try {
  user = await getUserFromRequest(req);
} catch (err) {
  return res.status(401).json({ error: 'Unauthorized' });
}
const email = user.email;
// ... (the rest of the handler uses `email` as before)
```

The dual-auth fallback in `getUserFromRequest` means existing code that still passes `body.email` continues to work. After PR 2 deploys + verifies in prod, a follow-up PR removes the fallback.

### Task 14: Frontend `authedFetch`

**File:** `dashboard/src/lib/api.js` (modify)

```javascript
import { supabase } from './supabase.js';

async function authedFetch(url, opts = {}) {
  const { data: { session } } = await supabase.auth.getSession();
  const headers = {
    ...(opts.headers || {}),
    'Content-Type': 'application/json',
    ...(session?.access_token ? { Authorization: `Bearer ${session.access_token}` } : {})
  };
  return fetch(url, { ...opts, headers });
}

// Replace all fetch() with authedFetch()
```

(All existing fetch calls become `authedFetch`.)

Commit.

---

## Phase 5: Tests + Ship

### Task 15: Run all tests

```bash
npm test
npm run test:smoke
```

All new tests pass. Existing tests still pass (dual-auth fallback ensures legacy email-from-body tests aren't broken).

### Task 16: Build, push, PR

```bash
npm run build
git push -u origin pr2-real-product
gh pr create --title "feat: PR 2 — magic link + HOT/STRONG threshold + tokens" --body "..."
```

Smoke-test live before flipping any env vars.

---

## Risks & Mitigations

| Risk | Mitigation |
|---|---|
| JWT verification fails on legacy frontend (no Authorization header) | Dual-auth fallback accepts email from body. After one prod release, remove fallback. |
| Pre-debit estimate too high → false exhaustion | Cap output estimate at 80% of remaining budget. Cap max_tokens for free tier at 1500. Tested. |
| Lazy reset race (two concurrent requests both reset) | `RPC increment_token_usage` is atomic. Reset is idempotent (sets to 0; second call sets to 0 again). |
| Migration drops `free_scans_used` while users have it | Backfill `has_qualifying_free_scan = TRUE WHERE free_scans_used >= 1` before drop. PR 1 users keep their qualified state. |
| Magic-link email goes to spam, user gives up | Resend button + Supabase rate-limit handling. PR 3 adds loading spinner UX. |
| Supabase Auth limits hit (4/hr per email, 30/hr per IP) | EmailGate catches 429, shows clear "try again in N min" message. |
| `has_qualifying_free_scan` set during scan-progress.js poll, but user already navigated away | Idempotent UPDATE — only flips false→true. Subsequent polls don't change anything. |

## Definition of Done

- [ ] PR merged to main, all env vars set
- [ ] Migration applied, `users.free_scans_used` column dropped
- [ ] Smoke: new user → magic link → callback → dashboard → run scan → if qualifying, lock state appears; if not, agent suggests loosening
- [ ] Smoke: chat through token budget → token_exhausted message appears with renewal date
- [ ] Smoke: paid user has $6/mo budget, free user has $1.50/mo
- [ ] Smoke: cancel via Customer Portal → access until period_end → then locks
- [ ] No `dh_email` references left in frontend
- [ ] All API endpoints reject unauthenticated requests (no JWT and no body email) with 401
