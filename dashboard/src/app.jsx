import { useEffect } from 'preact/hooks';
import { email, view, scans } from './lib/state.js';
import { loadUserData, switchThread } from './lib/api.js';
import { Sidebar } from './components/Sidebar.jsx';
import { Chat } from './components/Chat.jsx';
import { Preview } from './components/Preview.jsx';
import { Settings } from './components/Settings.jsx';

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
      if (completedScans.length > 0) {
        view.value = 'scan';
        await switchThread(completedScans[0].id, 'scan', completedScans[0].conversation_id);
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
        if (completedScans.length > 0) {
          view.value = 'scan';
          switchThread(completedScans[0].id, 'scan', completedScans[0].conversation_id);
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
      <Chat />
      <Preview />
    </div>
  );
}
