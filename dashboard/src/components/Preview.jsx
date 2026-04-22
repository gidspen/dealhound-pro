import { useEffect } from 'preact/hooks';
import { view, previewOpen, currentDeal, dealsForCurrentScan, currentScan, activeThreads } from '../lib/state.js';
import { switchThread, loadUserData } from '../lib/api.js';
import { DealCard } from './DealCard.jsx';
import { fmtPrice, tierFromStrategy, tierLabel, riskClass, parseBreakdown } from '../lib/utils.js';

function ScanDealList() {
  const scan = currentScan.value;
  const scanDeals = dealsForCurrentScan.value;

  const openThread = async (deal) => {
    view.value = 'deal';
    await switchThread(deal.id, 'deal', null);
    await loadUserData();
  };

  return (
    <>
      <div class="preview-header">
        <span>{scan ? `${new Date(scan.run_at).toLocaleDateString('en-US', { month: 'short', day: 'numeric' })} Scan · ${scanDeals.length} Deals` : 'Deals'}</span>
        <button class="preview-close" onClick={() => { previewOpen.value = false; }}>×</button>
      </div>
      <div class="preview-body">
        {scanDeals.length === 0 ? (
          <div class="preview-empty">No deals in this scan.</div>
        ) : (
          scanDeals.map(deal => (
            <DealCard key={deal.id} deal={deal} variant="preview" onOpenThread={openThread} />
          ))
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
            <span class={`deal-tier-badge tier-${tier}`}>{tierLabel(tier)}</span>
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
