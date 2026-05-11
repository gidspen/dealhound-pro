import { useState } from 'preact/hooks';
import { upgradeModal, email } from '../lib/state.js';

// Reads `upgradeModal.value` to decide what to render:
//   reason: 'no_subscription' → "Become a Founding Member" sell
//   reason: 'out_of_runs'     → "You're out of runs" top-up sell
//   null                      → render nothing
//
// Closes by setting upgradeModal.value = null.
export function UpgradeModal() {
  const m = upgradeModal.value;
  const [busy, setBusy] = useState(false);
  const [err, setErr] = useState(null);

  if (!m) return null;

  const close = () => {
    if (busy) return;
    upgradeModal.value = null;
  };

  const startCheckout = async (tier) => {
    setBusy(true);
    setErr(null);
    try {
      const res = await fetch('/api/create-checkout', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ tier, email: email.value }),
      });

      if (res.status === 409) {
        // Founding window closed or 50/50 cap reached — fall back to Hunter.
        const body = await res.json().catch(() => ({}));
        setErr((body.error || 'Founding spots are gone — try Hunter at $79/mo.') + ' Falling back to Hunter…');
        // Auto-retry on Hunter after 1.5s so the user reads the message
        setTimeout(() => startCheckout('hunter'), 1500);
        return;
      }

      if (!res.ok) {
        const body = await res.json().catch(() => ({}));
        throw new Error(body.error || `Checkout failed (${res.status})`);
      }

      const { url } = await res.json();
      if (!url) throw new Error('No checkout URL returned');
      window.location.href = url;
    } catch (e) {
      setErr(e.message || 'Could not start checkout. Try again or email gideon@stonemontcap.com.');
      setBusy(false);
    }
  };

  // ── No subscription: pitch Founding Member ────────────────────────────────
  if (m.reason === 'no_subscription') {
    return (
      <div class="upgrade-overlay" onClick={(e) => { if (e.target.classList.contains('upgrade-overlay')) close(); }}>
        <div class="upgrade-modal">
          <button class="upgrade-close" onClick={close} aria-label="Close" disabled={busy}>×</button>

          <div class="upgrade-eyebrow">First 50 only · 14-day window</div>
          <h2 class="upgrade-title">Become a Founding Member</h2>
          <p class="upgrade-lede">
            Your free scan is on the house. To run more, lock in <strong>$49/mo for life</strong> —
            every current and future agent skill, always included.
          </p>

          <ul class="upgrade-bullets">
            <li><strong>10 agent runs / month</strong> — deal scans, LOIs, underwriting, comps</li>
            <li><strong>Lifetime price guarantee</strong> — never increases as long as you stay subscribed</li>
            <li><strong>Every future skill included</strong> — no per-skill upsells, ever</li>
            <li><strong>Direct line to the founder</strong> for feedback during beta</li>
          </ul>

          <button
            class="upgrade-cta-primary"
            onClick={() => startCheckout('founding')}
            disabled={busy}
          >
            {busy ? 'Opening checkout…' : 'Become a Founding Member · $49/mo'}
          </button>

          <button
            class="upgrade-cta-secondary"
            onClick={() => startCheckout('hunter')}
            disabled={busy}
          >
            Skip — go straight to Hunter ($79/mo)
          </button>

          {err && <p class="upgrade-error">{err}</p>}

          <p class="upgrade-fineprint">
            7-day money-back. Capped at 10 runs/month — top up 5 more for $25 any time.
          </p>
        </div>
      </div>
    );
  }

  // ── Out of runs: pitch top-up ─────────────────────────────────────────────
  if (m.reason === 'out_of_runs') {
    const used = m.runs_used ?? '?';
    const limit = m.runs_limit ?? '?';

    return (
      <div class="upgrade-overlay" onClick={(e) => { if (e.target.classList.contains('upgrade-overlay')) close(); }}>
        <div class="upgrade-modal">
          <button class="upgrade-close" onClick={close} aria-label="Close" disabled={busy}>×</button>

          <div class="upgrade-eyebrow">{used} / {limit} runs used this month</div>
          <h2 class="upgrade-title">You're out of runs</h2>
          <p class="upgrade-lede">
            You've used your monthly compute. Top up 5 more runs for $25, or wait until your runs reset next month.
          </p>

          <button
            class="upgrade-cta-primary"
            onClick={() => startCheckout('topup')}
            disabled={busy}
          >
            {busy ? 'Opening checkout…' : 'Top up 5 runs · $25'}
          </button>

          <button
            class="upgrade-cta-secondary"
            onClick={close}
            disabled={busy}
          >
            Wait until next month
          </button>

          {err && <p class="upgrade-error">{err}</p>}

          <p class="upgrade-fineprint">
            One-time charge. Bonus runs roll over until used.
          </p>
        </div>
      </div>
    );
  }

  // Unknown reason — fail gracefully with a generic upgrade nudge
  return (
    <div class="upgrade-overlay" onClick={close}>
      <div class="upgrade-modal">
        <button class="upgrade-close" onClick={close} aria-label="Close">×</button>
        <h2 class="upgrade-title">Upgrade required</h2>
        <p class="upgrade-lede">Pick a plan at <a href="/" target="_blank" rel="noreferrer">dealhound.pro</a> to keep hunting.</p>
      </div>
    </div>
  );
}
