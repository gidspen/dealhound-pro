// dashboard/src/components/ScanProgress.jsx
import { useEffect, useRef, useState } from 'preact/hooks';

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

function relativeTime(iso, nowMs) {
  if (!iso) return '';
  const ts = new Date(iso).getTime();
  const sec = Math.max(0, Math.round((nowMs - ts) / 1000));
  if (sec < 5) return 'just now';
  if (sec < 60) return `${sec}s ago`;
  const min = Math.floor(sec / 60);
  const remSec = sec % 60;
  if (min < 60) return remSec ? `${min}m ${remSec}s ago` : `${min}m ago`;
  const hr = Math.floor(min / 60);
  return `${hr}h ${min % 60}m ago`;
}

export function ScanProgress({ searchId, onStatus }) {
  const [steps, setSteps] = useState([]);
  const [status, setStatus] = useState('scanning');
  const [now, setNow] = useState(Date.now());

  // Keep a fresh ref to onStatus so the polling effect doesn't restart
  // every render the parent re-renders.
  const onStatusRef = useRef(onStatus);
  onStatusRef.current = onStatus;

  // Tick every second so the "12s ago" labels update without re-fetching.
  useEffect(() => {
    const t = setInterval(() => setNow(Date.now()), 1000);
    return () => clearInterval(t);
  }, []);

  useEffect(() => {
    if (!searchId) return;
    let cancelled = false;
    let stoppedAt = null;
    let lastStatus = null;

    async function poll() {
      try {
        const res = await fetch(`${API_BASE}/api/scan-progress?id=${searchId}`);
        if (!res.ok) return;
        const data = await res.json();
        if (cancelled) return;
        setSteps(data.steps || []);
        setStatus(data.status);
        if (onStatusRef.current) onStatusRef.current(data.status);

        // Only fire scan-complete on an actual transition during this session.
        // Without the lastStatus guard we'd re-fire the debrief every time the
        // user lands on an already-completed scan.
        if (data.status === 'complete' && lastStatus && lastStatus !== 'complete' && stoppedAt !== 'complete') {
          stoppedAt = 'complete';
          window.dispatchEvent(new CustomEvent('scan-complete', { detail: { searchId } }));
        } else if (data.status === 'complete' && stoppedAt !== 'complete') {
          stoppedAt = 'complete';
        } else if (data.status === 'error' && stoppedAt !== 'error') {
          stoppedAt = 'error';
        }
        lastStatus = data.status;
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

  const headerText = status === 'error' ? 'Scan failed' : 'Scanning marketplaces...';
  const isEmpty = !steps.length;
  const lastStep = steps[steps.length - 1];

  return (
    <div class="scan-progress">
      <div class="scan-progress__header">
        <span class="scan-progress__header-text">{headerText}</span>
        {!isEmpty && lastStep && (
          <span class="scan-progress__heartbeat">
            updated {relativeTime(lastStep.created_at, now)}
          </span>
        )}
      </div>
      <ul class="scan-progress__steps">
        {isEmpty && (
          <li class="scan-progress__step scan-progress__step--running scan-progress__step--placeholder">
            <span class="scan-progress__label">Warming up the scanner...</span>
          </li>
        )}
        {steps.map((s) => (
          <li key={s.id} class={`scan-progress__step scan-progress__step--${s.status}`}>
            <span class="scan-progress__label">{labelFor(s.step)}</span>
            {s.listing_count != null && (
              <span class="scan-progress__count">{s.listing_count}</span>
            )}
            {s.message && <span class="scan-progress__message">{s.message}</span>}
            <span class="scan-progress__time">{relativeTime(s.created_at, now)}</span>
          </li>
        ))}
      </ul>
    </div>
  );
}
