import { useEffect } from 'preact/hooks';
import { email, view, scans, sidebarOpen, sidebarWidth, previewOpen, previewWidth } from './lib/state.js';
import { loadUserData, switchThread } from './lib/api.js';
import { Sidebar } from './components/Sidebar.jsx';
import { Chat } from './components/Chat.jsx';
import { Preview } from './components/Preview.jsx';
import { Settings } from './components/Settings.jsx';

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

function EmailGate() {
  const handleSubmit = async (e) => {
    e.preventDefault();
    const val = e.target.elements.email.value.trim();
    if (!val) return;
    email.value = val;
    localStorage.setItem('dh_email', val);

    try {
      await loadUserData();
      const completedScans = scans.value.filter(s => s.status === 'complete');
      // Prefer scan with deals, fall back to newest completed
      const bestScan = completedScans.find(s => s.deal_count > 0) || completedScans[0];
      if (bestScan) {
        view.value = 'scan';
        await switchThread(bestScan.id, 'scan', bestScan.conversation_id);
      } else {
        view.value = 'onboarding';
      }
    } catch {
      view.value = 'onboarding';
    }
  };

  return (
    <div class="email-gate">
      <h1>Your <em>deal hunting</em><br />command center.</h1>
      <p>Enter your email to access your buy boxes, scan results, and top deals.</p>
      <form class="gate-form" onSubmit={handleSubmit}>
        <input type="email" name="email" placeholder="your@email.com" required autocomplete="email" autofocus />
        <button type="submit" class="btn-primary">Open Dashboard</button>
      </form>
    </div>
  );
}

export function App() {
  useEffect(() => {
    const stored = localStorage.getItem('dh_email');
    if (stored) {
      email.value = stored;
      loadUserData().then(() => {
        const completedScans = scans.value.filter(s => s.status === 'complete');
        const bestScan = completedScans.find(s => s.deal_count > 0) || completedScans[0];
        if (bestScan) {
          view.value = 'scan';
          switchThread(bestScan.id, 'scan', bestScan.conversation_id);
        } else {
          view.value = 'onboarding';
        }
      }).catch(() => {
        view.value = 'onboarding';
      });
    }
  }, []);

  if (!email.value) {
    return <EmailGate />;
  }

  return (
    <div id="app-shell">
      <Settings />
      <Sidebar />
      {sidebarOpen.value && <ResizeHandle edge="right" widthSignal={sidebarWidth} minW={180} maxW={480} />}
      <Chat />
      {previewOpen.value && <ResizeHandle edge="left" widthSignal={previewWidth} minW={280} maxW={600} />}
      <Preview />
    </div>
  );
}
