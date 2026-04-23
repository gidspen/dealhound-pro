import { starredDealIds } from '../lib/state.js';
import { toggleStar } from '../lib/api.js';
import { fmtPrice, tierFromStrategy, tierLabel, riskClass, parseBreakdown } from '../lib/utils.js';

export function DealCard({ deal, variant = 'preview', onOpenThread }) {
  const bd = parseBreakdown(deal.score_breakdown);
  const strategy = bd.strategy || {};
  const risk = bd.risk || {};
  const tier = tierFromStrategy(strategy.overall);
  const isStarred = starredDealIds.value.has(deal.id);

  const acreage = deal.acreage ? deal.acreage + ' ac' : null;
  const keys = deal.rooms_keys ? deal.rooms_keys + ' keys' : null;

  return (
    <div class={`deal-card deal-card-${variant} ${tier === 'hot' ? 'deal-card-hot' : ''}`}>
      <div class="deal-card-header">
        <div>
          <div class="deal-card-title">{deal.title || 'Unnamed Property'}</div>
          <div class="deal-card-location">{deal.location || ''}{deal.source ? ` · ${deal.source}` : ''}</div>
        </div>
        <div class="deal-card-actions-top">
          <button class="deal-star-btn" onClick={(e) => { e.stopPropagation(); toggleStar(deal.id); }} title={isStarred ? 'Unstar' : 'Star'}>
            {isStarred ? '\u2605' : '\u2606'}
          </button>
          <span class={`deal-tier-badge tier-${tier}`}>{tierLabel(tier)}</span>
        </div>
      </div>

      <div class="deal-card-metrics">
        {deal.price != null && <span>{fmtPrice(deal.price)}</span>}
        {acreage && <span>{acreage}</span>}
        {keys && <span>{keys}</span>}
        {risk.level && <span class={riskClass(risk.level)}>{risk.level} Risk</span>}
      </div>

      {strategy.summary && (
        <div class="deal-card-summary">{strategy.summary}</div>
      )}

      <div class="deal-card-footer">
        {deal.url && <a href={deal.url} target="_blank" rel="noopener" class="deal-listing-link">Listing →</a>}
        {onOpenThread && (
          <button class="deal-open-thread-btn" onClick={(e) => { e.stopPropagation(); onOpenThread(deal); }}>
            Open Thread →
          </button>
        )}
      </div>
    </div>
  );
}
