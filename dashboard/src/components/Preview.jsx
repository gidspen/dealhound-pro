import { useEffect } from 'preact/hooks';
import { view, previewOpen, currentDeal, dealsForCurrentScan, currentScan, starredDealIds, activeThreads, deals } from '../lib/state.js';
import { switchThread, loadUserData, toggleStar } from '../lib/api.js';
import { fmtPrice, tierFromStrategy, tierLabel, riskClass, parseBreakdown } from '../lib/utils.js';

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

  return (
    <>
      <div class="preview-header">
        <span>{scanDeals.length} Deals</span>
        <button class="preview-close" onClick={() => { previewOpen.value = false; }}>×</button>
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

  return (
    <>
      <div class="preview-header">
        <span>Deal Detail</span>
        <button class="preview-close" onClick={() => { previewOpen.value = false; }}>×</button>
      </div>
      <div class="preview-body">
        <div class="deal-detail">
          <div class="deal-detail-top">
            <div>
              <div class="deal-detail-title">{deal.title || 'Unnamed'}</div>
              <div class="deal-detail-location">{deal.location || ''}</div>
            </div>
            <div style="display:flex;align-items:center;gap:6px;">
              <button class="preview-star" onClick={() => toggleStar(deal.id)} style="font-size:1.1rem;">
                {isStarred ? '★' : '☆'}
              </button>
              <span class={`deal-tier-badge tier-${tier}`}>{tierLabel(tier)}</span>
            </div>
          </div>

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

          {strategy.summary && (
            <div class="deal-detail-assessment">
              <div class="deal-detail-assessment-label">Agent Assessment</div>
              <p>{strategy.summary}</p>
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
  const shouldShow = (view.value === 'scan' && dealsForCurrentScan.value.length > 0) || view.value === 'deal';

  useEffect(() => {
    if (shouldShow && !previewOpen.value) {
      previewOpen.value = true;
    } else if (!shouldShow && previewOpen.value) {
      previewOpen.value = false;
    }
  }, [shouldShow]);

  if (!previewOpen.value) {
    return <div id="preview-panel" class="preview-collapsed" />;
  }

  return (
    <div id="preview-panel" class="preview-open">
      {view.value === 'scan' && <ScanDealList />}
      {view.value === 'deal' && <DealDetail />}
    </div>
  );
}
