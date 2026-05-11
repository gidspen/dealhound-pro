import { useEffect } from 'preact/hooks';
import { settingsOpen, email, plan, upgradeModal } from '../lib/state.js';

const TIER_DISPLAY = {
  founding: { label: 'Founding Member',    badge: 'tier-founding' },
  hunter:   { label: 'Hunter',             badge: 'tier-hunter'   },
  investor: { label: 'Investor',           badge: 'tier-investor' },
  operator: { label: 'Operator',           badge: 'tier-operator' },
};

function formatResetDate(iso) {
  if (!iso) return null;
  const d = new Date(iso);
  if (isNaN(d.getTime())) return null;
  return d.toLocaleDateString(undefined, { month: 'short', day: 'numeric' });
}

function PlanSection() {
  const p = plan.value;

  // No subscription yet — pitch upgrade
  if (!p.tier) {
    return (
      <>
        <div class="settings-plan-tier tier-free">Free</div>
        <div class="settings-plan-meta">
          You've used your free scan. Subscribe to keep hunting — every agent skill, capped runs, lifetime price.
        </div>
        <button
          class="settings-upgrade-btn"
          style="margin-top: 12px;"
          onClick={() => {
            settingsOpen.value = false;
            upgradeModal.value = { reason: 'no_subscription', tier: null };
          }}
        >
          See plans →
        </button>
      </>
    );
  }

  const display = TIER_DISPLAY[p.tier] || { label: p.tier, badge: 'tier-free' };
  const used = p.runs_used ?? 0;
  const limit = p.runs_limit;            // null = unlimited
  const bonus = p.bonus_runs || 0;
  const resetLabel = formatResetDate(p.runs_reset_at);
  const overCap = limit !== null && used >= limit;
  const pct = limit !== null && limit > 0 ? Math.min(100, (used / limit) * 100) : 0;

  return (
    <>
      <div class={`settings-plan-tier ${display.badge}`}>{display.label}</div>

      {limit === null ? (
        <div class="settings-runs-text">
          <span>{used} runs this month</span>
          <span>Unlimited</span>
        </div>
      ) : (
        <>
          <div class="settings-runs-bar">
            <div class={`settings-runs-fill${overCap ? ' over' : ''}`} style={`width: ${pct}%`} />
          </div>
          <div class="settings-runs-text">
            <span>{used} of {limit} runs used</span>
            {resetLabel && <span>Resets {resetLabel}</span>}
          </div>
          {bonus > 0 && (
            <div class="settings-runs-text" style="margin-top: 2px;">
              <span class="bonus">Includes {bonus} top-up bonus</span>
            </div>
          )}
        </>
      )}

      {overCap && (
        <button
          class="settings-upgrade-btn"
          style="margin-top: 12px;"
          onClick={() => {
            settingsOpen.value = false;
            upgradeModal.value = {
              reason: 'out_of_runs',
              tier: p.tier,
              runs_used: used,
              runs_limit: limit,
              bonus_runs: bonus,
            };
          }}
        >
          Top up 5 runs · $25
        </button>
      )}
    </>
  );
}

export function Settings() {
  useEffect(() => {
    if (!settingsOpen.value) return;
    const handler = (e) => { if (e.key === 'Escape') settingsOpen.value = false; };
    window.addEventListener('keydown', handler);
    return () => window.removeEventListener('keydown', handler);
  }, [settingsOpen.value]);

  if (!settingsOpen.value) return null;

  const digestOn = localStorage.getItem('dh_notif_digest') !== 'false';

  const toggleDigest = (e) => {
    localStorage.setItem('dh_notif_digest', e.target.checked ? 'true' : 'false');
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
          <div class="settings-section-title">Account</div>
          <div class="settings-plan" style="margin-bottom: 8px;">
            Signed in as <strong>{email.value}</strong>
          </div>
          <PlanSection />
        </div>

        <div class="settings-section">
          <div class="settings-section-title">Help</div>
          <a
            href={`mailto:gideon@stonemontcap.com?subject=${encodeURIComponent('Deal Hound feedback')}&body=${encodeURIComponent('What worked? What didn\'t? What surprised you?\n\n')}`}
            class="settings-link"
          >
            Send feedback →
          </a>
          <a href="mailto:gideon@stonemontcap.com" class="settings-link">Contact support →</a>
        </div>

        <div class="settings-section">
          <div class="settings-section-title">Notifications</div>
          <div class="settings-notif-row">
            <span>Daily digest email</span>
            <label class="toggle">
              <input type="checkbox" checked={digestOn} onChange={toggleDigest} />
              <span class="toggle-track" />
            </label>
          </div>
        </div>

        <div class="settings-bottom">
          <button class="settings-signout" onClick={signOut}>Sign out</button>
        </div>
      </div>
    </div>
  );
}
