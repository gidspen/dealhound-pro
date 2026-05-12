import { useEffect, useState } from 'preact/hooks';
import { batch } from '@preact/signals';
import {
  email,
  view,
  scans,
  deals,
  activeThreadId,
  sidebarOpen,
  sidebarWidth,
  previewOpen,
  previewWidth,
  upgradeModal,
  plan,
} from './lib/state.js';
import { loadUserData, switchThread } from './lib/api.js';
import { Sidebar } from './components/Sidebar.jsx';
import { Chat } from './components/Chat.jsx';
import { Preview } from './components/Preview.jsx';
import { Settings } from './components/Settings.jsx';
import { UpgradeModal } from './components/UpgradeModal.jsx';

function ResizeHandle({ edge, widthSignal, minW, maxW }) {
  const onPointerDown = (e) => {
    e.preventDefault();
    const startX = e.clientX;
    const startW = widthSignal.value;
    const dir = edge === 'left' ? -1 : 1;

    document.getElementById('app-shell').classList.add('resizing');

    const onMove = (e) => {
      const delta = (e.clientX - startX) * dir;
      widthSignal.value = Math.min(maxW, Math.max(minW, startW + delta));
    };
    const onUp = () => {
      document.removeEventListener('pointermove', onMove);
      document.removeEventListener('pointerup', onUp);
      document.body.style.cursor = '';
      document.body.style.userSelect = '';
      document.getElementById('app-shell').classList.remove('resizing');
    };

    document.body.style.cursor = 'col-resize';
    document.body.style.userSelect = 'none';
    document.addEventListener('pointermove', onMove);
    document.addEventListener('pointerup', onUp);
  };

  return <div class={`resize-handle resize-${edge}`} onPointerDown={onPointerDown} />;
}

// ── Shared routing logic after loadUserData resolves ──────────────────────────
// Rules:
//   1. Has deals (own or pool)  → deal view with top deal
//   2. Has scans but no deals   → scan view (user has buy box, results pending)
//   3. No scans at all          → onboarding (genuinely new user)
async function routeAfterLoad() {
  console.log('[DH] route: deals=%d scans=%d', deals.value.length, scans.value.length);

  // PostHog: identify + dashboard_loaded
  if (window.posthog && email.value) {
    window.posthog.identify(email.value);
    window.posthog.capture('dashboard_loaded', {
      tier: plan.value?.tier || 'free',
      has_scans: (scans.value?.length || 0) > 0,
    });
  }

  if (deals.value.length > 0) {
    const topDeal = deals.value[0];
    console.log('[DH] → deal view', topDeal.id);
    batch(() => {
      activeThreadId.value = topDeal.id;
      view.value = 'deal';
      previewOpen.value = true;
    });
    await switchThread(topDeal.id, 'deal', null);
  } else if (scans.value.length > 0) {
    // User already has a buy box — show scan view rather than restarting onboarding.
    // Prefer a completed scan with deals; fall back to most recent scan.
    const withDeals = scans.value.find((s) => s.deal_count > 0);
    const scan = withDeals || scans.value[0];
    console.log('[DH] → scan view', scan.id, scan.status);
    view.value = 'scan';
    await switchThread(scan.id, 'scan', scan.conversation_id);
  } else {
    // Truly new user: no buy box yet
    console.log('[DH] → onboarding (no scans)');
    view.value = 'onboarding';
  }
}

function EmailGate() {
  const [loading, setLoading] = useState(false);
  const [loadError, setLoadError] = useState(null);

  const handleSubmit = async (e) => {
    e.preventDefault();
    const val = e.target.elements.email.value.trim();
    if (!val) return;

    setLoading(true);
    setLoadError(null);
    email.value = val;
    localStorage.setItem('dh_email', val);

    try {
      await loadUserData();
      await routeAfterLoad();
    } catch (err) {
      console.error('[DH] loadUserData error:', err);
      setLoadError('Could not load your dashboard. Check your connection and try again.');
      setLoading(false);
      // Don't route anywhere — stay on the gate so the user can retry
    }
  };

  return (
    <div class="email-gate">
      <h1>
        Your <em>deal hunting</em>
        <br />
        command center.
      </h1>
      <p>Enter your email to access your buy boxes, scan results, and top deals.</p>
      <form class="gate-form" onSubmit={handleSubmit}>
        <input
          type="email"
          name="email"
          placeholder="your@email.com"
          required
          autocomplete="email"
          autofocus
          disabled={loading}
        />
        <button type="submit" class="btn-primary" disabled={loading}>
          {loading ? 'Loading…' : 'Open Dashboard'}
        </button>
      </form>
      {loadError && <p class="gate-error">{loadError}</p>}
    </div>
  );
}

export function App() {
  // Test-only hook: lets Playwright/devs open the UpgradeModal directly.
  // No-op risk in production (just sets a signal — gated by being dispatched
  // intentionally). Wired here so it's available even before sign-in.
  useEffect(() => {
    if (typeof window === 'undefined') return;
    window.__dh_setUpgradeModal = (payload) => {
      upgradeModal.value = payload;
    };
    const handler = (e) => {
      upgradeModal.value = e.detail;
    };
    window.addEventListener('dh-test-open-upgrade', handler);
    return () => window.removeEventListener('dh-test-open-upgrade', handler);
  }, []);

  useEffect(() => {
    // ── Magic-link handler (runs before localStorage check) ──────────────────
    const params = new URLSearchParams(window.location.search);
    const fromMagic = params.get('from') === 'magic';
    const magicEmail = params.get('email');
    const magicScanId = params.get('scan_id');

    if (fromMagic && magicEmail) {
      email.value = magicEmail;
      localStorage.setItem('dh_email', magicEmail);

      // Strip magic-link params so a refresh doesn't replay this flow.
      window.history.replaceState({}, '', window.location.pathname);

      console.log('[DH] magic-link sign-in:', magicEmail, 'scan_id:', magicScanId);

      (async () => {
        try {
          await loadUserData();
          if (magicScanId) {
            const scan = scans.value.find((s) => s.id === magicScanId);
            if (scan) {
              batch(() => {
                activeThreadId.value = magicScanId;
                view.value = 'scan';
              });
              await switchThread(magicScanId, 'scan', scan.conversation_id);
              return; // skip routeAfterLoad — we have a specific target
            }
          }
          await routeAfterLoad();
        } catch (err) {
          console.error('[DH] magic-link load error:', err);
          // Fall through to email-gate by clearing email so the gate renders
          localStorage.removeItem('dh_email');
          email.value = null;
        }
      })();
      return;
    }

    // ── Existing localStorage auto-sign-in (unchanged) ───────────────────────
    const stored = localStorage.getItem('dh_email');
    if (stored) {
      email.value = stored;
      loadUserData()
        .then(() => routeAfterLoad())
        .catch((err) => {
          // API failed on auto-load — clear stale email so user lands on the gate
          // rather than a blank screen or, worse, Quinn's onboarding greeting.
          console.error('[DH] auto-load failed:', err);
          localStorage.removeItem('dh_email');
          email.value = null;
        });
    }
  }, []);

  if (!email.value) {
    return <EmailGate />;
  }

  return (
    <div id="app-shell">
      <Settings />
      <UpgradeModal />
      <Sidebar />
      {sidebarOpen.value && (
        <ResizeHandle edge="right" widthSignal={sidebarWidth} minW={180} maxW={480} />
      )}
      <Chat />
      {previewOpen.value && (
        <ResizeHandle edge="left" widthSignal={previewWidth} minW={280} maxW={600} />
      )}
      <Preview />
    </div>
  );
}
