// api/create-checkout.js
//
// Creates a Stripe Checkout session for the requested tier.
// POST body: { tier: 'founding' | 'hunter' | 'investor' | 'operator' | 'topup', email?: string }
// Returns: { url } — redirect the browser here.
//
// Env vars required:
//   STRIPE_SECRET_KEY        — Stripe secret key
//   SUPABASE_URL             — Supabase project URL
//   SUPABASE_SERVICE_KEY     — Supabase service role key
//   FOUNDING_LAUNCH_DATE     — ISO date string, e.g. "2026-05-06" (14-day window starts here)
//   APP_URL                  — Base URL for success/cancel redirects, e.g. "https://dealhound.pro"

const Stripe = require('stripe');
const { createClient } = require('@supabase/supabase-js');

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_KEY
);

// ---------------------------------------------------------------------------
// Stripe Price IDs — set these as env vars once created in the Stripe dashboard.
// Fall back to the env var; this makes it easy to wire real IDs without a deploy.
// ---------------------------------------------------------------------------
const PRICE_IDS = {
  founding: process.env.STRIPE_PRICE_FOUNDING,   // $49/mo recurring
  hunter:   process.env.STRIPE_PRICE_HUNTER,     // $79/mo recurring
  investor: process.env.STRIPE_PRICE_INVESTOR,   // $249/mo recurring
  operator: process.env.STRIPE_PRICE_OPERATOR,   // $599/mo recurring
  topup:    process.env.STRIPE_PRICE_TOPUP,      // $25 one-time, 5 runs
};

const TIER_LABELS = {
  founding: 'Founding Member — $49/mo',
  hunter:   'Hunter — $79/mo',
  investor: 'Investor — $249/mo',
  operator: 'Operator — $599/mo',
  topup:    'Top-Up — 5 runs for $25',
};

// Founding Member cap constants
const FOUNDING_MAX_SUBSCRIBERS = 50;
const FOUNDING_WINDOW_DAYS = 14;

// ---------------------------------------------------------------------------
// Founding Member eligibility check
// Returns { eligible: true } or { eligible: false, reason: string }
// ---------------------------------------------------------------------------
async function checkFoundingEligibility() {
  // 1. Check 14-day launch window
  const launchDateStr = process.env.FOUNDING_LAUNCH_DATE;
  if (launchDateStr) {
    const launchDate = new Date(launchDateStr);
    const windowClose = new Date(launchDate.getTime() + FOUNDING_WINDOW_DAYS * 24 * 60 * 60 * 1000);
    if (new Date() > windowClose) {
      return { eligible: false, reason: 'Founding Member window has closed (14-day limit reached)' };
    }
  }

  // 2. Check 50-subscriber cap
  const { count, error } = await supabase
    .from('users')
    .select('*', { count: 'exact', head: true })
    .eq('subscription_tier', 'founding');

  if (error) {
    console.error('Founding cap check error:', error);
    // Fail open — let it through; better to over-sell by 1 than block a valid buyer
    // Log for monitoring. In production, tighten this once DB is stable.
  } else if (count >= FOUNDING_MAX_SUBSCRIBERS) {
    return { eligible: false, reason: 'Founding Member spots are full' };
  }

  return { eligible: true };
}

// ---------------------------------------------------------------------------
// Handler
// ---------------------------------------------------------------------------
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

  const { tier, email } = req.body || {};

  if (!tier || !PRICE_IDS[tier]) {
    return res.status(400).json({
      error: 'Invalid or missing tier. Must be one of: founding, hunter, investor, operator, topup',
    });
  }

  const priceId = PRICE_IDS[tier];
  if (!priceId) {
    return res.status(500).json({
      error: `Stripe price ID not configured for tier "${tier}". Set STRIPE_PRICE_${tier.toUpperCase()} env var.`,
    });
  }

  try {
    // Founding Member eligibility gate
    if (tier === 'founding') {
      const eligibility = await checkFoundingEligibility();
      if (!eligibility.eligible) {
        return res.status(409).json({ error: eligibility.reason });
      }
    }

    const baseUrl = process.env.APP_URL || 'https://dealhound.pro';

    // Build session params. Top-up is a one-time payment; all others are subscriptions.
    const isTopup = tier === 'topup';

    const sessionParams = {
      mode: isTopup ? 'payment' : 'subscription',
      line_items: [{ price: priceId, quantity: 1 }],
      success_url: `${baseUrl}/dashboard?checkout=success&tier=${tier}`,
      cancel_url: `${baseUrl}/dashboard?checkout=cancelled`,
      // Collect email if provided (pre-fills the Stripe Checkout form)
      ...(email ? { customer_email: email } : {}),
      // 7-day money-back is enforced via Stripe policy / manual refund — no free trial period.
      // Metadata carries tier so the webhook can read it without a Stripe price lookup.
      metadata: {
        tier,
        product: 'dealhound',
      },
      // Allow promotion codes so we can run discount campaigns later
      allow_promotion_codes: true,
    };

    // Attach subscription metadata for recurring tiers
    if (!isTopup) {
      sessionParams.subscription_data = {
        metadata: { tier, product: 'dealhound' },
      };
    }

    const session = await stripe.checkout.sessions.create(sessionParams);

    return res.status(200).json({ url: session.url });

  } catch (err) {
    console.error('create-checkout error:', err.message);
    return res.status(500).json({ error: 'Failed to create checkout session' });
  }
};

// ---------------------------------------------------------------------------
// Test cases for Founding Member cap logic (unit-testable in isolation)
// ---------------------------------------------------------------------------
//
// CASE 1: Window open, count < 50 → eligible
//   - FOUNDING_LAUNCH_DATE = today, count = 10  → { eligible: true }
//
// CASE 2: Count at 50 → blocked
//   - count = 50                                 → { eligible: false, reason: '...spots are full' }
//
// CASE 3: Count = 49 but window expired → blocked
//   - FOUNDING_LAUNCH_DATE = 15 days ago         → { eligible: false, reason: '...14-day limit reached' }
//
// CASE 4: No FOUNDING_LAUNCH_DATE set → window check skipped, only count matters
//   - count = 30, no launch date                 → { eligible: true }
//
// CASE 5: Count = 50, window also expired → first guard (window) fires first
//   - Whichever check runs first returns 409; both conditions are redundant catch
//
// To run these against a real Supabase:
//   node -e "require('./api/create-checkout').checkFoundingEligibility().then(console.log)"
// (export checkFoundingEligibility if you want to unit-test it; currently it's a closure)
