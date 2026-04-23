import { useEffect } from 'preact/hooks';
import { settingsOpen, email } from '../lib/state.js';

export function Settings() {
  // Close on Escape key
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
          <div class="settings-section-title">Help</div>
          <a href="mailto:support@dealhound.pro" class="settings-link">Contact Support →</a>
          <a href="https://dealhound.pro" target="_blank" class="settings-link">Documentation →</a>
        </div>

        <div class="settings-section">
          <div class="settings-section-title">Billing</div>
          <div class="settings-plan">Current plan: <strong>Free</strong></div>
          <button class="settings-upgrade-btn" onClick={() => alert('Upgrade coming soon! Email support@dealhound.pro for early access.')}>
            Upgrade to Pro — $29/mo
          </button>
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
