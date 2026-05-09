import { batch } from '@preact/signals';
import { view, activeSbaLeadId, previewOpen } from '../lib/state.js';

function tierColor(tier) {
  switch (tier) {
    case 'HOT': return 'sba-tier-hot';
    case 'STRONG': return 'sba-tier-strong';
    case 'WATCH': return 'sba-tier-watch';
    default: return 'sba-tier-watch';
  }
}

function firedSignalCount(signals) {
  if (!Array.isArray(signals)) return 0;
  return signals.filter(s => s.fired).length;
}

export function SbaLeadCard({ lead }) {
  const isActive = activeSbaLeadId.value === lead.id;

  const handleClick = () => {
    batch(() => {
      activeSbaLeadId.value = lead.id;
      view.value = 'sba-lead';
      previewOpen.value = true;
    });
  };

  return (
    <div class={`sba-lead-card ${isActive ? 'sba-lead-card-active' : ''}`} onClick={handleClick}>
      <div class="sba-lead-card-top">
        <div class="sba-lead-card-name">{lead.business_name}</div>
        <span class={`sba-tier-badge ${tierColor(lead.retirement_tier)}`}>
          {lead.retirement_tier}
        </span>
      </div>
      <div class="sba-lead-card-meta">
        <span>{lead.owner_name || 'Unknown owner'}</span>
        <span class="sba-lead-card-dot">·</span>
        <span>{lead.city}, {lead.state}</span>
      </div>
      <div class="sba-lead-card-score">
        <div class="sba-score-bar">
          <div class="sba-score-fill" style={`width: ${lead.retirement_score}%`} />
        </div>
        <span class="sba-score-label">{lead.retirement_score}/100</span>
        <span class="sba-signal-count">{firedSignalCount(lead.signals)} signals</span>
      </div>
    </div>
  );
}
