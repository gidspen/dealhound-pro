// api/stripe-webhook.js
//
// Handles inbound Stripe webhook events.
// Events handled:
//   checkout.session.completed    → upsert subscription_tier + stripe IDs in users table
//   customer.subscription.deleted → clear subscription_tier (set to null)
//
// Env vars required:
//   STRIPE_SECRET_KEY         — Stripe secret key (for constructing the event)
//   STRIPE_WEBHOOK_SECRET     — Signing secret from Stripe webhook config (whsec_...)
//   SUPABASE_URL              — Supabase project URL
//   SUPABASE_SERVICE_KEY      — Supabase service role key
//
// Vercel note: raw body access requires NO body-parser. Vercel serverless passes
// the raw Buffer via req.body when Content-Type is application/json and the route
// is listed in vercel.json functions block. We read it via getRawBody helper below.

// =============================================================================
// MIGRATION SQL — run these ALTER TABLE statements once against your Supabase DB
// before deploying this webhook. They are idempotent (IF NOT EXISTS / DO NOTHING).
// =============================================================================
//
//   -- Add Stripe subscription columns to users table
//   ALTER TABLE users
//     ADD COLUMN IF NOT EXISTS subscription_tier      TEXT,
//     ADD COLUMN IF NOT EXISTS stripe_customer_id     TEXT,
//     ADD COLUMN IF NOT EXISTS stripe_subscription_id TEXT,
//     ADD COLUMN IF NOT EXISTS agent_runs_used        INTEGER     NOT NULL DEFAULT 0,
//     ADD COLUMN IF NOT EXISTS agent_runs_reset_at    TIMESTAMPTZ,
//     ADD COLUMN IF NOT EXISTS monthly_compute_used   NUMERIC(10,4) NOT NULL DEFAULT 0,
//     ADD COLUMN IF NOT EXISTS bonus_runs             INTEGER     NOT NULL DEFAULT 0;
//
//   -- See scripts/migrations/2026-05-10-bonus-runs.sql for the bonus_runs RPC
//   -- (increment_bonus_runs) that the top-up handler calls.
//
//   -- Index for founding member cap query (count where subscription_tier = 'founding')
//   CREATE INDEX IF NOT EXISTS idx_users_subscription_tier ON users (subscription_tier);
//
//   -- Index for stripe customer lookups in webhook handler
//   CREATE INDEX IF NOT EXISTS idx_users_stripe_customer_id ON users (stripe_customer_id);
//
// =============================================================================

const Stripe = require('stripe');
const { createClient } = require('@supabase/supabase-js');

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);

const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_KEY);

// ---------------------------------------------------------------------------
// getRawBody — reads the raw request buffer so Stripe can verify the signature.
// Vercel does not expose req.rawBody; we have to stream it ourselves.
// ---------------------------------------------------------------------------
function getRawBody(req) {
  return new Promise((resolve, reject) => {
    const chunks = [];
    req.on('data', (chunk) => chunks.push(chunk));
    req.on('end', () => resolve(Buffer.concat(chunks)));
    req.on('error', reject);
  });
}

// ---------------------------------------------------------------------------
// Handle checkout.session.completed
// ---------------------------------------------------------------------------
async function handleCheckoutCompleted(session) {
  const tier = session.metadata?.tier;
  const customerEmail = session.customer_details?.email || session.customer_email;
  const stripeCustomerId = session.customer;

  // For one-time top-up payments there is no subscription object.
  const stripeSubscriptionId = session.subscription || null;

  if (!customerEmail) {
    console.error('checkout.session.completed: no customer email in session', session.id);
    return;
  }

  if (!tier) {
    console.error('checkout.session.completed: no tier metadata in session', session.id);
    return;
  }

  // Top-up: grant 5 BONUS runs (do not touch subscription_tier or agent_runs_used).
  // Bonus runs are added to the effective limit (see api/_lib/paywall.js).
  if (tier === 'topup') {
    const { error } = await supabase.rpc('increment_bonus_runs', {
      p_email: customerEmail,
      p_amount: 5,
    });
    if (error) {
      // rpc may not exist yet — fall back to manual update
      console.warn(
        'increment_bonus_runs rpc failed, falling back to manual update:',
        error.message
      );
      const { data: user } = await supabase
        .from('users')
        .select('bonus_runs')
        .eq('email', customerEmail)
        .single();
      if (user) {
        await supabase
          .from('users')
          .update({ bonus_runs: (user.bonus_runs || 0) + 5 })
          .eq('email', customerEmail);
      }
    }
    console.log(`Top-up: +5 bonus runs for ${customerEmail}`);
    return;
  }

  // Subscription tier — upsert the user record
  const now = new Date();
  // Reset window: first day of next month at midnight UTC
  const resetAt = new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth() + 1, 1));

  const upsertPayload = {
    email: customerEmail,
    subscription_tier: tier,
    stripe_customer_id: stripeCustomerId,
    ...(stripeSubscriptionId ? { stripe_subscription_id: stripeSubscriptionId } : {}),
    agent_runs_used: 0,
    agent_runs_reset_at: resetAt.toISOString(),
    monthly_compute_used: 0,
  };

  const { error } = await supabase.from('users').upsert(upsertPayload, { onConflict: 'email' });

  if (error) {
    console.error('Failed to upsert user after checkout:', error);
    throw error;
  }

  console.log(`Subscription activated: ${customerEmail} → ${tier}`);
}

// ---------------------------------------------------------------------------
// Handle customer.subscription.deleted
// ---------------------------------------------------------------------------
async function handleSubscriptionDeleted(subscription) {
  const stripeCustomerId = subscription.customer;

  const { error } = await supabase
    .from('users')
    .update({
      subscription_tier: null,
      stripe_subscription_id: null,
    })
    .eq('stripe_customer_id', stripeCustomerId);

  if (error) {
    console.error('Failed to clear subscription_tier on deletion:', error);
    throw error;
  }

  console.log(`Subscription cancelled for customer ${stripeCustomerId}`);
}

// ---------------------------------------------------------------------------
// Handler
// ---------------------------------------------------------------------------
module.exports.config = { api: { bodyParser: false } };

module.exports = async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  let rawBody;
  try {
    rawBody = await getRawBody(req);
  } catch (err) {
    console.error('stripe-webhook: failed to read raw body:', err.message);
    return res.status(400).json({ error: 'Could not read request body' });
  }

  const sig = req.headers['stripe-signature'];
  let event;

  try {
    event = stripe.webhooks.constructEvent(rawBody, sig, process.env.STRIPE_WEBHOOK_SECRET);
  } catch (err) {
    console.error('stripe-webhook: signature verification failed:', err.message);
    return res.status(400).json({ error: `Webhook signature verification failed: ${err.message}` });
  }

  try {
    switch (event.type) {
      case 'checkout.session.completed':
        await handleCheckoutCompleted(event.data.object);
        break;

      case 'customer.subscription.deleted':
        await handleSubscriptionDeleted(event.data.object);
        break;

      default:
        // Unhandled event type — acknowledge without acting
        console.log(`stripe-webhook: unhandled event type ${event.type}`);
    }

    return res.status(200).json({ received: true });
  } catch (err) {
    console.error('stripe-webhook: handler error:', err.message);
    // Return 500 so Stripe retries the webhook
    return res.status(500).json({ error: 'Webhook handler failed' });
  }
};
