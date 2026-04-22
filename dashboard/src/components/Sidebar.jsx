import { email, agentName, view, activeThreadId, scans, activeDeals, activeThreads, settingsOpen } from '../lib/state.js';
import { switchThread } from '../lib/api.js';
import { tierFromStrategy, tierLabel, fmtPrice, parseBreakdown } from '../lib/utils.js';

function SidebarDealRow({ deal }) {
  const bd = parseBreakdown(deal.score_breakdown);
  const tier = tierFromStrategy(bd.strategy?.overall);
  const isActive = view.value === 'deal' && activeThreadId.value === deal.id;
  const thread = activeThreads.value.find(t => t.deal_id === deal.id);

  const handleClick = () => {
    view.value = 'deal';
    switchThread(deal.id, 'deal', thread?.conversation_id);
  };

  return (
    <div class={`sidebar-deal-row ${isActive ? 'active' : ''}`} onClick={handleClick}>
      <div class="sidebar-deal-name">
        <span>{deal.title || 'Untitled'}</span>
        <span class={`sidebar-tier tier-${tier}`}>{tierLabel(tier)}</span>
      </div>
      <div class="sidebar-deal-meta">{fmtPrice(deal.price)} · {deal.location?.split(',')[0] || ''}</div>
    </div>
  );
}

function SidebarScanRow({ scan }) {
  const isActive = view.value === 'scan' && activeThreadId.value === scan.id;
  const date = scan.run_at ? new Date(scan.run_at).toLocaleDateString('en-US', { month: 'short', day: 'numeric' }) : '';

  const handleClick = () => {
    view.value = 'scan';
    switchThread(scan.id, 'scan', scan.conversation_id);
  };

  return (
    <div class={`sidebar-scan-row ${isActive ? 'active' : ''}`} onClick={handleClick}>
      <div class="sidebar-scan-name">{date} Scan</div>
      <div class="sidebar-scan-meta">{scan.deal_count || 0} deals</div>
    </div>
  );
}

export function Sidebar() {
  const activeDealsList = activeDeals.value;
  const completedScans = scans.value.filter(s => s.status === 'complete');

  const startNewScan = () => {
    view.value = 'onboarding';
    activeThreadId.value = null;
  };

  return (
    <div id="sidebar">
      <div class="sidebar-logo">
        <div class="sidebar-logo-icon">
          <svg width="13" height="13" viewBox="0 0 16 16" fill="white"><path d="M8 0 L9.6 6.4 L16 8 L9.6 9.6 L8 16 L6.4 9.6 L0 8 L6.4 6.4 Z"/></svg>
        </div>
        <span class="sidebar-logo-text">Deal Hound</span>
      </div>

      <div class="sidebar-scroll">
        <div class="sidebar-section-pad">
          <button class="sidebar-new-scan" onClick={startNewScan}>
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round">
              <line x1="12" y1="5" x2="12" y2="19" /><line x1="5" y1="12" x2="19" y2="12" />
            </svg>
            New Scan
          </button>
        </div>

        <div class="sidebar-section-hdr">Active Deals</div>
        {activeDealsList.length === 0 ? (
          <div class="sidebar-empty">None yet</div>
        ) : (
          activeDealsList.map(deal => <SidebarDealRow key={deal.id} deal={deal} />)
        )}

        <div class="sidebar-divider" />

        <div class="sidebar-section-hdr">Scans</div>
        {completedScans.length === 0 ? (
          <div class="sidebar-empty">No scans yet</div>
        ) : (
          completedScans.map(scan => <SidebarScanRow key={scan.id} scan={scan} />)
        )}

        <div class="sidebar-divider" />

        <div class="sidebar-scan-row" onClick={startNewScan}>
          <div class="sidebar-scan-name">Buy Box Setup</div>
          <div class="sidebar-scan-meta">Edit criteria</div>
        </div>
      </div>

      <div class="sidebar-footer">
        <button class="sidebar-settings-btn" onClick={() => { settingsOpen.value = true; }} title="Settings">
          <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round">
            <circle cx="12" cy="12" r="3" />
            <path d="M19.4 15a1.65 1.65 0 00.33 1.82l.06.06a2 2 0 010 2.83 2 2 0 01-2.83 0l-.06-.06a1.65 1.65 0 00-1.82-.33 1.65 1.65 0 00-1 1.51V21a2 2 0 01-4 0v-.09A1.65 1.65 0 009 19.4a1.65 1.65 0 00-1.82.33l-.06.06a2 2 0 01-2.83-2.83l.06-.06A1.65 1.65 0 004.68 15a1.65 1.65 0 00-1.51-1H3a2 2 0 010-4h.09A1.65 1.65 0 004.6 9a1.65 1.65 0 00-.33-1.82l-.06-.06a2 2 0 012.83-2.83l.06.06A1.65 1.65 0 009 4.68a1.65 1.65 0 001-1.51V3a2 2 0 014 0v.09a1.65 1.65 0 001 1.51 1.65 1.65 0 001.82-.33l.06-.06a2 2 0 012.83 2.83l-.06.06A1.65 1.65 0 0019.4 9a1.65 1.65 0 001.51 1H21a2 2 0 010 4h-.09a1.65 1.65 0 00-1.51 1z" />
          </svg>
        </button>
        <span class="sidebar-email">{email.value}</span>
      </div>
    </div>
  );
}
