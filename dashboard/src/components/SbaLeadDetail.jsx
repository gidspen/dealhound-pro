import { currentSbaLead, previewOpen } from '../lib/state.js';

function tierColor(tier) {
  switch (tier) {
    case 'HOT': return 'sba-tier-hot';
    case 'STRONG': return 'sba-tier-strong';
    case 'WATCH': return 'sba-tier-watch';
    default: return 'sba-tier-watch';
  }
}

function SignalRow({ signal }) {
  return (
    <div class={`sba-signal-row ${signal.fired ? 'sba-signal-fired' : 'sba-signal-unfired'}`}>
      <div class="sba-signal-header">
        <span class="sba-signal-indicator">{signal.fired ? '+' : '-'}</span>
        <span class="sba-signal-key">{signal.key.replace(/_/g, ' ')}</span>
        <span class="sba-signal-weight">{signal.weight} pts</span>
      </div>
      <div class="sba-signal-evidence">{signal.evidence}</div>
      {signal.source && signal.source !== 'pending' && (
        <div class="sba-signal-source">Source: {signal.source}</div>
      )}
      {signal.source === 'pending' && (
        <div class="sba-signal-source sba-signal-pending">Pending integration</div>
      )}
    </div>
  );
}

export function SbaLeadDetail() {
  const lead = currentSbaLead.value;
  if (!lead) return null;

  const signals = Array.isArray(lead.signals) ? lead.signals : [];
  const firedSignals = signals.filter(s => s.fired);
  const unfiredSignals = signals.filter(s => !s.fired);

  // Group by category
  const categories = {};
  signals.forEach(s => {
    const cat = s.category || 'other';
    if (!categories[cat]) categories[cat] = [];
    categories[cat].push(s);
  });

  const catLabels = {
    owner_age: 'Owner Age Indicators',
    succession_vacuum: 'Succession Risk',
    digital_decay: 'Digital Decay',
    activity_decline: 'Activity Decline',
    no_growth: 'Growth Stagnation'
  };

  return (
    <>
      <div class="preview-header">
        <span>Practice Detail</span>
        <button class="preview-toggle" onClick={() => { previewOpen.value = false; }} title="Collapse panel">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round">
            <path d="M13 17l5-5-5-5" /><path d="M6 17l5-5-5-5" />
          </svg>
        </button>
      </div>
      <div class="preview-body sba-detail-body">
        {/* Tier accent bar */}
        <div class={`deal-detail-accent sba-accent-${lead.retirement_tier.toLowerCase()}`} />

        {/* Header */}
        <div class="sba-detail-top">
          <div>
            <div class="sba-detail-title">{lead.business_name}</div>
            <div class="sba-detail-subtitle">{lead.owner_name || 'Owner unknown'} · {lead.city}, {lead.state}</div>
          </div>
          <span class={`sba-tier-badge-lg ${tierColor(lead.retirement_tier)}`}>
            {lead.retirement_tier}
          </span>
        </div>

        {/* Score section */}
        <div class="sba-detail-score-section">
          <div class="sba-detail-score-number">{lead.retirement_score}</div>
          <div class="sba-detail-score-label">Retirement Score</div>
          <div class="sba-detail-score-bar">
            <div class={`sba-detail-score-fill sba-fill-${lead.retirement_tier.toLowerCase()}`} style={`width: ${lead.retirement_score}%`} />
          </div>
          <div class="sba-detail-score-meta">
            {firedSignals.length} of {signals.length} signals fired · {signals.filter(s => s.source === 'pending').length} pending (LinkedIn)
          </div>
        </div>

        {/* Business info grid */}
        <div class="deal-detail-grid">
          <div class="deal-detail-cell">
            <div class="deal-detail-cell-label">Years in Business</div>
            <div class="deal-detail-cell-value">{lead.years_in_business || '—'}</div>
          </div>
          <div class="deal-detail-cell">
            <div class="deal-detail-cell-label">License Year</div>
            <div class="deal-detail-cell-value">{lead.license_year || '—'}</div>
          </div>
          <div class="deal-detail-cell">
            <div class="deal-detail-cell-label">Phone</div>
            <div class="deal-detail-cell-value">{lead.phone || '—'}</div>
          </div>
          <div class="deal-detail-cell">
            <div class="deal-detail-cell-label">Website</div>
            <div class="deal-detail-cell-value">{lead.website ? <a href={lead.website.startsWith('http') ? lead.website : 'https://' + lead.website} target="_blank" rel="noopener" class="sba-link">{lead.website.replace(/^https?:\/\//, '').split('/')[0]}</a> : '—'}</div>
          </div>
        </div>

        {/* Contact info */}
        {(lead.owner_email || lead.owner_phone) && (
          <div class="sba-detail-contact">
            <div class="deal-detail-section-label">Contact</div>
            {lead.owner_email && <div class="sba-contact-row">Email: {lead.owner_email}</div>}
            {lead.owner_phone && <div class="sba-contact-row">Phone: {lead.owner_phone}</div>}
          </div>
        )}

        {/* Signal stack */}
        <div class="sba-detail-signals">
          <div class="deal-detail-section-label">Signal Stack ({firedSignals.length}/{signals.length})</div>
          {Object.entries(categories).map(([cat, sigs]) => (
            <div key={cat} class="sba-signal-category">
              <div class="sba-signal-cat-label">{catLabels[cat] || cat}</div>
              {sigs.map(s => <SignalRow key={s.key} signal={s} />)}
            </div>
          ))}
        </div>

        {/* Outreach draft */}
        {lead.outreach_body && (
          <div class="sba-detail-outreach">
            <div class="deal-detail-section-label">Drafted Outreach</div>
            {lead.outreach_subject && (
              <div class="sba-outreach-subject">Subject: {lead.outreach_subject}</div>
            )}
            <div class="sba-outreach-body">{lead.outreach_body}</div>
            <button class="sba-copy-btn" onClick={() => {
              navigator.clipboard.writeText(
                `Subject: ${lead.outreach_subject || ''}\n\n${lead.outreach_body}`
              );
            }}>
              Copy to clipboard
            </button>
          </div>
        )}
      </div>
    </>
  );
}
