// dashboard/src/components/ScanProgress.jsx
import { useEffect, useState } from 'preact/hooks';

const API_BASE = '';
const POLL_INTERVAL_MS = 3000;

const STEP_LABELS = {
  'discover:start': 'Loading sites...',
  'scrape:landsearch:start': 'Scraping LandSearch...',
  'scrape:landsearch:done': 'LandSearch',
  'scrape:naiohb:start': 'Checking NAI OHB...',
  'scrape:naiohb:done': 'NAI OHB',
  'scrape:bbteam:start': 'Checking B&B Team...',
  'scrape:bbteam:done': 'B&B Team',
  'enrich:start': 'Reading detail pages...',
  'enrich:done': 'Detail pages',
  'apply_buybox:start': 'Filtering against your buy box...',
  'apply_buybox:done': 'Buy box filter',
  'score:start': 'Scoring deals...',
  'score:done': 'Scoring',
  'complete': 'Done',
};

function labelFor(step) {
  return STEP_LABELS[step] || step;
}

export function ScanProgress({ searchId }) {
  const [steps, setSteps] = useState([]);
  const [status, setStatus] = useState('scanning');

  useEffect(() => {
    if (!searchId) return;
    let cancelled = false;
    let stoppedAt = null;

    async function poll() {
      try {
        const res = await fetch(`${API_BASE}/api/scan-progress?id=${searchId}`);
        if (!res.ok) return;
        const data = await res.json();
        if (cancelled) return;
        setSteps(data.steps || []);
        setStatus(data.status);
        if (data.status === 'complete' && stoppedAt !== 'complete') {
          stoppedAt = 'complete';
          // Tell Chat the scan is done so it can fire the debrief.
          window.dispatchEvent(new CustomEvent('scan-complete', { detail: { searchId } }));
        } else if (data.status === 'error' && stoppedAt !== 'error') {
          stoppedAt = 'error';
        }
      } catch (_) { /* swallow — try again next tick */ }
    }

    poll();
    const interval = setInterval(() => {
      if (stoppedAt) return;
      poll();
    }, POLL_INTERVAL_MS);

    return () => { cancelled = true; clearInterval(interval); };
  }, [searchId]);

  if (!searchId) return null;
  if (status === 'complete') return null;

  return (
    <div class="scan-progress">
      <div class="scan-progress__header">
        {status === 'error' ? 'Scan failed' : 'Scanning marketplaces...'}
      </div>
      {status !== 'error' && (
        <div class="scan-progress__notice">
          Scans can take up to 60 minutes. You can leave this tab open — the agent will keep working.
        </div>
      )}
      <ul class="scan-progress__steps">
        {steps.map((s) => (
          <li key={s.id} class={`scan-progress__step scan-progress__step--${s.status}`}>
            <span class="scan-progress__label">{labelFor(s.step)}</span>
            {s.listing_count != null && (
              <span class="scan-progress__count">{s.listing_count}</span>
            )}
            <span class="scan-progress__message">{s.message}</span>
          </li>
        ))}
      </ul>
    </div>
  );
}
