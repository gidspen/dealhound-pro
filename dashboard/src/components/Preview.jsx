import { useEffect } from 'preact/hooks';
import { view, previewOpen, previewWidth, currentDeal, dealsForCurrentScan, currentScan, scans, starredDealIds, activeThreads, deals, activeThreadId } from '../lib/state.js';
import { switchThread, loadUserData, toggleStar } from '../lib/api.js';
import { fmtPrice, tierFromStrategy, tierLabel, riskClass, parseBreakdown, fmtDaysOnMarket, riskDimensions, strategyLabels } from '../lib/utils.js';

function CompactDealRow({ deal, onOpen }) {
  const bd = parseBreakdown(deal.score_breakdown);
  const tier = tierFromStrategy(bd.strategy?.overall);
  const isStarred = starredDealIds.value.has(deal.id);

  return (
    <div class="preview-deal-row" onClick={() => onOpen(deal)}>
      <button class="preview-star" onClick={(e) => { e.stopPropagation(); toggleStar(deal.id); }}>
        {isStarred ? '★' : '☆'}
      </button>
      <div class="preview-deal-info">
        <div class="preview-deal-name">{deal.title || 'Untitled'}</div>
        <div class="preview-deal-meta">
          {fmtPrice(deal.price)}
          {deal.acreage ? ` · ${deal.acreage} ac` : ''}
          {deal.location ? ` · ${deal.location.split(',')[0]}` : ''}
        </div>
      </div>
      <span class={`preview-tier tier-${tier}`}>{tierLabel(tier)}</span>
    </div>
  );
}

function ScanDealList() {
  const scan = currentScan.value;
  const scanDeals = dealsForCurrentScan.value;

  const openThread = async (deal) => {
    view.value = 'deal';
    await switchThread(deal.id, 'deal', null);
    await loadUserData();
  };

  // Group by starred first, then by tier
  const starred = scanDeals.filter(d => starredDealIds.value.has(d.id));
  const unstarred = scanDeals.filter(d => !starredDealIds.value.has(d.id));

  const grouped = { hot: [], strong: [], watch: [] };
  unstarred.forEach(deal => {
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
      <div class="preview-header">
        <span>{scanDeals.length} Deals</span>
        <button class="preview-toggle" onClick={() => { previewOpen.value = false; }} title="Collapse panel">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M13 17l5-5-5-5" /><path d="M6 17l5-5-5-5" /></svg>
        </button>
      </div>
      <div class="preview-body">
        {/* Starred / Favorites */}
        {starred.length > 0 && (
          <>
            <div class="preview-group-hdr preview-group-starred">★ Saved · {starred.length}</div>
            {starred.map(deal => <CompactDealRow key={deal.id} deal={deal} onOpen={openThread} />)}
          </>
        )}

        {/* HOT */}
        {grouped.hot.length > 0 && (
          <>
            <div class="preview-group-hdr preview-group-hot">Hot · {grouped.hot.length}</div>
            {grouped.hot.map(deal => <CompactDealRow key={deal.id} deal={deal} onOpen={openThread} />)}
          </>
        )}

        {/* STRONG */}
        {grouped.strong.length > 0 && (
          <>
            <div class="preview-group-hdr preview-group-strong">Strong · {grouped.strong.length}</div>
            {grouped.strong.map(deal => <CompactDealRow key={deal.id} deal={deal} onOpen={openThread} />)}
          </>
        )}

        {/* WATCH */}
        {grouped.watch.length > 0 && (
          <>
            <div class="preview-group-hdr preview-group-watch">Watch · {grouped.watch.length}</div>
            {grouped.watch.map(deal => <CompactDealRow key={deal.id} deal={deal} onOpen={openThread} />)}
          </>
        )}

        {scanDeals.length === 0 && (
          <div class="preview-empty">No deals in this scan.</div>
        )}
      </div>
    </>
  );
}

function DealDetail() {
  const deal = currentDeal.value;
  if (!deal) return null;

  const bd = parseBreakdown(deal.score_breakdown);
  const strategy = bd.strategy || {};
  const risk = bd.risk || {};
  const tier = tierFromStrategy(strategy.overall);
  const isStarred = starredDealIds.value.has(deal.id);
  const risks = riskDimensions(bd);
  const stratLabels = strategyLabels(bd);
  const dom = fmtDaysOnMarket(deal.days_on_market);

  return (
    <>
      <div class="preview-header">
        <span>Deal Detail</span>
        <button class="preview-toggle" onClick={() => { previewOpen.value = false; }} title="Collapse panel">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M13 17l5-5-5-5" /><path d="M6 17l5-5-5-5" /></svg>
        </button>
      </div>
      <div class="preview-body">
        <div class={`deal-detail deal-detail-tier-${tier}`}>
          {/* Tier accent bar */}
          <div class={`deal-detail-accent accent-${tier}`} />

          <div class="deal-detail-top">
            <div>
              <div class="deal-detail-title">{deal.title || 'Unnamed'}</div>
              <div class="deal-detail-location">{deal.location || ''}</div>
            </div>
            <div style="display:flex;align-items:center;gap:6px;">
              <button class="preview-star" onClick={() => toggleStar(deal.id)} style="font-size:1.1rem;">
                {isStarred ? '★' : '☆'}
              </button>
              <span class={`deal-tier-badge-lg tier-${tier}`}>{tierLabel(tier)}</span>
            </div>
          </div>

          {/* Badges row */}
          <div class="deal-detail-badges">
            {deal.property_type && <span class="detail-badge">{deal.property_type.replace(/_/g, ' ')}</span>}
            {deal.source && <span class="detail-badge">{deal.source}</span>}
            {dom && <span class="detail-badge">{dom} on market</span>}
          </div>

          {/* Metrics grid */}
          <div class="deal-detail-grid">
            <div class="deal-detail-cell">
              <div class="deal-detail-cell-label">Price</div>
              <div class="deal-detail-cell-value">{fmtPrice(deal.price)}</div>
            </div>
            <div class="deal-detail-cell">
              <div class="deal-detail-cell-label">Acreage</div>
              <div class="deal-detail-cell-value">{deal.acreage ? deal.acreage + ' ac' : '—'}</div>
            </div>
            <div class="deal-detail-cell">
              <div class="deal-detail-cell-label">Keys</div>
              <div class="deal-detail-cell-value">{deal.rooms_keys || '—'}</div>
            </div>
            <div class="deal-detail-cell">
              <div class="deal-detail-cell-label">Risk</div>
              <div class={`deal-detail-cell-value ${riskClass(risk.level)}`}>{risk.level || '—'}</div>
            </div>
          </div>

          {/* Strategy match pills */}
          {stratLabels.length > 0 && (
            <div class="deal-detail-strategy">
              <div class="deal-detail-section-label">Strategy Match</div>
              <div class="deal-detail-pills">
                {stratLabels.map(s => (
                  <span key={s.key} class={`strategy-pill strategy-${String(s.value).toLowerCase().replace(/\s+/g, '-')}`}>
                    {s.key}: {s.value}
                  </span>
                ))}
              </div>
            </div>
          )}

          {/* Risk dimensions */}
          {risks.length > 0 && (
            <div class="deal-detail-risks">
              <div class="deal-detail-section-label">Risk Breakdown</div>
              {risks.map(r => (
                <div key={r.key} class="risk-bar-row">
                  <span class="risk-bar-label">{r.key}</span>
                  <div class="risk-bar-track">
                    <div
                      class={`risk-bar-fill ${r.value <= 2 ? 'risk-bar-low' : r.value <= 3 ? 'risk-bar-mid' : 'risk-bar-high'}`}
                      style={`width: ${(r.value / r.max) * 100}%`}
                    />
                  </div>
                  <span class="risk-bar-val">{r.value}/{r.max}</span>
                </div>
              ))}
            </div>
          )}

          {/* Agent assessment / brief */}
          {(strategy.summary || deal.brief) && (
            <div class={`deal-detail-assessment assessment-${tier}`}>
              <div class="deal-detail-section-label">Agent Assessment</div>
              <p>{deal.brief || strategy.summary}</p>
            </div>
          )}

          {/* Description excerpt */}
          {deal.raw_description && (
            <div class="deal-detail-description">
              <div class="deal-detail-section-label">Listing Description</div>
              <p class="deal-detail-desc-text">{deal.raw_description}</p>
            </div>
          )}

          {deal.url && (
            <a href={deal.url} target="_blank" rel="noopener" class="deal-detail-listing-link">View Original Listing →</a>
          )}
        </div>
      </div>
    </>
  );
}

export function Preview() {
  // Subscribe to currentDeal so Preview re-renders when it changes
  const deal = currentDeal.value;
  const hasContent = (view.value === 'scan' && dealsForCurrentScan.value.length > 0) || view.value === 'deal';

  // Auto-open when switching to a view that has preview content
  useEffect(() => {
    if (hasContent && !previewOpen.value) {
      previewOpen.value = true;
    } else if (!hasContent && previewOpen.value) {
      previewOpen.value = false;
    }
  }, [hasContent]);

  // Collapsed state — show a thin strip with expand button
  if (!previewOpen.value) {
    if (!hasContent) return null;
    return (
      <div id="preview-panel" class="preview-collapsed-strip">
        <button class="preview-toggle preview-toggle-collapsed" onClick={() => { previewOpen.value = true; }} title="Expand panel">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M11 17l-5-5 5-5" /><path d="M18 17l-5-5 5-5" /></svg>
        </button>
      </div>
    );
  }

  return (
    <div id="preview-panel" class="preview-open" style={`width: ${previewWidth.value}px`}>
      {view.value === 'scan' && <ScanDealList />}
      {view.value === 'deal' && <DealDetail />}
    </div>
  );
}
