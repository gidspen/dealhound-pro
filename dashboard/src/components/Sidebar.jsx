import { batch } from '@preact/signals';
import {
  email, view, activeThreadId, scans, activeThreads,
  settingsOpen, sidebarOpen, sidebarWidth, sidebarTab, unreadFilter,
  starredDealIds, viewedDealIds, archivedDealIds,
  inboxDeals, trackingDeals, newDealCount, previewOpen
} from '../lib/state.js';
import { switchThread, toggleStar, archiveDeal } from '../lib/api.js';
import { tierFromStrategy, tierLabel, fmtPrice, parseBreakdown } from '../lib/utils.js';

// ── DealRow ──────────────────────────────────────────────────────────────────

function DealRow({ deal }) {
  const bd = parseBreakdown(deal.score_breakdown);
  const tier = tierFromStrategy(bd.strategy?.overall);
  const isActive = view.value === 'deal' && activeThreadId.value === deal.id;
  const isViewed = viewedDealIds.value.has(deal.id);
  const isStarred = starredDealIds.value.has(deal.id);
  const inInbox = sidebarTab.value === 'inbox';
  const thread = activeThreads.value.find(t => t.deal_id === deal.id);

  const handleClick = () => {
    batch(() => {
      activeThreadId.value = deal.id;
      view.value = 'deal';
      previewOpen.value = true;
    });
    switchThread(deal.id, 'deal', thread?.conversation_id);
  };

  const handleStar = (e) => {
    e.stopPropagation();
    toggleStar(deal.id);
  };

  const handleArchive = (e) => {
    e.stopPropagation();
    archiveDeal(deal.id);
  };

  return (
    <div class={`sidebar-deal-row ${isActive ? 'active' : ''}`} onClick={handleClick}>
      <div class="sidebar-deal-name">
        {!isViewed && <span class="new-dot" title="New" />}
        <span class="sidebar-deal-title">{deal.title || 'Untitled'}</span>
        <span class={`sidebar-tier tier-${tier}`}>{tierLabel(tier)}</span>
      </div>
      <div class="sidebar-deal-meta">
        <span>{fmtPrice(deal.price)}{deal.location ? ' · ' + deal.location.split(',')[0] : ''}</span>
        <span class="sidebar-deal-actions">
          <button
            class={`sidebar-action-btn ${isStarred ? 'starred' : ''}`}
            onClick={handleStar}
            title={isStarred ? 'Unstar' : 'Star'}
          >
            {isStarred ? '★' : '☆'}
          </button>
          {inInbox && (
            <button
              class="sidebar-action-btn"
              onClick={handleArchive}
              title="Archive"
            >
              ✕
            </button>
          )}
        </span>
      </div>
    </div>
  );
}

// ── GroupedDeals ──────────────────────────────────────────────────────────────

function GroupedDeals({ dealList }) {
  // Group by tier strength
  const grouped = { hot: [], strong: [], watch: [] };
  dealList.forEach(deal => {
    const bd = parseBreakdown(deal.score_breakdown);
    const tier = tierFromStrategy(bd.strategy?.overall);
    if (grouped[tier]) grouped[tier].push(deal);
  });

  const scanMap = new Map();
  scans.value.forEach(s => scanMap.set(s.id, s));

  const sortByRecency = (a, b) => {
    const timeA = scanMap.get(a.search_id)?.run_at ? new Date(scanMap.get(a.search_id).run_at).getTime() : 0;
    const timeB = scanMap.get(b.search_id)?.run_at ? new Date(scanMap.get(b.search_id).run_at).getTime() : 0;
    return timeB - timeA;
  };

  grouped.hot.sort(sortByRecency);
  grouped.strong.sort(sortByRecency);
  grouped.watch.sort(sortByRecency);

  return (
    <>
      {grouped.hot.length > 0 && (
        <>
          <div class="sidebar-section-hdr sidebar-hdr-hot">Hot · {grouped.hot.length}</div>
          {grouped.hot.map(deal => <DealRow key={deal.id} deal={deal} />)}
        </>
      )}
      {grouped.strong.length > 0 && (
        <>
          <div class="sidebar-section-hdr sidebar-hdr-strong">Strong · {grouped.strong.length}</div>
          {grouped.strong.map(deal => <DealRow key={deal.id} deal={deal} />)}
        </>
      )}
      {grouped.watch.length > 0 && (
        <>
          <div class="sidebar-section-hdr sidebar-hdr-watch">Watch · {grouped.watch.length}</div>
          {grouped.watch.map(deal => <DealRow key={deal.id} deal={deal} />)}
        </>
      )}
    </>
  );
}

// ── Sidebar ───────────────────────────────────────────────────────────────────

export function Sidebar() {
  const totalAnalyzed = scans.value.reduce((sum, s) => sum + (s.deal_count || 0), 0);

  const startNewScan = () => {
    view.value = 'onboarding';
    activeThreadId.value = null;
  };

  // ── Collapsed state ────────────────────────────────────────────────────────
  if (!sidebarOpen.value) {
    return (
      <div id="sidebar" class="sidebar-collapsed">
        <button
          class="sidebar-toggle sidebar-toggle-collapsed"
          onClick={() => { sidebarOpen.value = true; }}
          title="Expand sidebar"
        >
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round">
            <path d="M13 17l5-5-5-5" /><path d="M6 17l5-5-5-5" />
          </svg>
        </button>
        <div class="sidebar-collapsed-icon">
          <svg width="13" height="13" viewBox="0 0 16 16" fill="white">
            <path d="M8 0 L9.6 6.4 L16 8 L9.6 9.6 L8 16 L6.4 9.6 L0 8 L6.4 6.4 Z"/>
          </svg>
        </div>
        <div class="sidebar-collapsed-spacer" />
        <button
          class="sidebar-settings-btn"
          onClick={() => { settingsOpen.value = true; }}
          title="Settings"
          style="margin: 0 auto 12px;"
        >
          <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round">
            <circle cx="12" cy="12" r="3" />
            <path d="M19.4 15a1.65 1.65 0 00.33 1.82l.06.06a2 2 0 010 2.83 2 2 0 01-2.83 0l-.06-.06a1.65 1.65 0 00-1.82-.33 1.65 1.65 0 00-1 1.51V21a2 2 0 01-4 0v-.09A1.65 1.65 0 009 19.4a1.65 1.65 0 00-1.82.33l-.06.06a2 2 0 01-2.83-2.83l.06-.06A1.65 1.65 0 004.68 15a1.65 1.65 0 00-1.51-1H3a2 2 0 010-4h.09A1.65 1.65 0 004.6 9a1.65 1.65 0 00-.33-1.82l-.06-.06a2 2 0 012.83-2.83l.06.06A1.65 1.65 0 009 4.68a1.65 1.65 0 001-1.51V3a2 2 0 014 0v.09a1.65 1.65 0 001 1.51 1.65 1.65 0 001.82-.33l.06-.06a2 2 0 012.83 2.83l-.06.06A1.65 1.65 0 0019.4 9a1.65 1.65 0 001.51 1H21a2 2 0 010 4h-.09a1.65 1.65 0 00-1.51 1z" />
          </svg>
        </button>
      </div>
    );
  }

  // ── Expanded state ─────────────────────────────────────────────────────────
  let activeDeals = sidebarTab.value === 'tracking' ? trackingDeals.value : inboxDeals.value;
  if (sidebarTab.value === 'inbox' && unreadFilter.value) {
    activeDeals = activeDeals.filter(d => !viewedDealIds.value.has(d.id));
  }
  const newCount = newDealCount.value;
  const trackCount = trackingDeals.value.length;

  return (
    <div id="sidebar" style={`width: ${sidebarWidth.value}px`}>
      {/* Logo header */}
      <div class="sidebar-logo">
        <div class="sidebar-logo-icon">
          <svg width="13" height="13" viewBox="0 0 16 16" fill="white">
            <path d="M8 0 L9.6 6.4 L16 8 L9.6 9.6 L8 16 L6.4 9.6 L0 8 L6.4 6.4 Z"/>
          </svg>
        </div>
        <span class="sidebar-logo-text">Deal Hound</span>
        <button
          class="sidebar-toggle"
          onClick={() => { sidebarOpen.value = false; }}
          title="Collapse sidebar"
        >
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round">
            <path d="M11 17l-5-5 5-5" /><path d="M18 17l-5-5 5-5" />
          </svg>
        </button>
      </div>

      {/* Inbox / Tracking tabs */}
      <div class="sidebar-tabs">
        <button
          class={`sidebar-tab ${sidebarTab.value === 'inbox' ? 'active' : ''}`}
          onClick={() => { sidebarTab.value = 'inbox'; }}
        >
          Inbox{newCount > 0 ? ` · ${newCount} new` : ''}
        </button>
        <button
          class={`sidebar-tab ${sidebarTab.value === 'tracking' ? 'active' : ''}`}
          onClick={() => { sidebarTab.value = 'tracking'; }}
        >
          ★ Tracking{trackCount > 0 ? ` · ${trackCount}` : ''}
        </button>
      </div>

      {/* Controls: New Scan + Unread filter (inbox only) */}
      <div class="sidebar-controls">
        <button class="sidebar-new-scan" style="flex: 1;" onClick={startNewScan}>
          <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round">
            <line x1="12" y1="5" x2="12" y2="19" /><line x1="5" y1="12" x2="19" y2="12" />
          </svg>
          New Scan
        </button>
        {sidebarTab.value === 'inbox' && (
          <button
            class={`sidebar-filter-btn ${unreadFilter.value ? 'active' : ''}`}
            onClick={() => { unreadFilter.value = !unreadFilter.value; }}
            title={unreadFilter.value ? 'Show all deals' : 'Show unread only'}
          >
            <span class="filter-dot" />
            Unread
          </button>
        )}
      </div>

      {/* Deal list */}
      <div class="sidebar-scroll">
        {totalAnalyzed > 0 && (
          <div class="sidebar-tally">{totalAnalyzed.toLocaleString()} deals analyzed</div>
        )}

        {activeDeals.length > 0
          ? <GroupedDeals dealList={activeDeals} />
          : (
            <div class="sidebar-empty">
              {sidebarTab.value === 'tracking'
                ? 'No starred deals — star a deal to track it'
                : 'No deals yet — run a scan'}
            </div>
          )
        }
      </div>

      {/* Footer */}
      <div class="sidebar-footer">
        <button
          class="sidebar-settings-btn"
          onClick={() => { settingsOpen.value = true; }}
          title="Settings"
        >
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
