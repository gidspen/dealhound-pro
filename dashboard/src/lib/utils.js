export function fmtPrice(n) {
  if (n == null) return '—';
  if (n >= 1000000) return '$' + (n / 1000000).toFixed(1) + 'M';
  if (n >= 1000) return '$' + Math.round(n / 1000) + 'k';
  return '$' + n;
}

export function tierFromStrategy(overall) {
  switch ((overall || '').toUpperCase()) {
    case 'STRONG MATCH': return 'hot';
    case 'MATCH': return 'strong';
    default: return 'watch';
  }
}

export function tierLabel(tier) {
  return { hot: 'HOT', strong: 'STRONG', watch: 'WATCH' }[tier] || 'WATCH';
}

export function riskClass(level) {
  if (!level) return 'risk-moderate';
  switch (level.toUpperCase()) {
    case 'LOW': return 'risk-low';
    case 'MODERATE': return 'risk-moderate';
    case 'HIGH': return 'risk-high';
    case 'VERY HIGH': return 'risk-very-high';
    default: return 'risk-moderate';
  }
}

export function parseBreakdown(raw) {
  if (!raw) return {};
  try { return typeof raw === 'string' ? JSON.parse(raw) : raw; }
  catch { return {}; }
}

export function escHtml(str) {
  const d = document.createElement('div');
  d.textContent = str || '';
  return d.innerHTML;
}

export function fmtDaysOnMarket(days) {
  if (days == null) return null;
  if (days <= 7) return 'New';
  if (days <= 30) return days + 'd';
  if (days <= 365) return Math.round(days / 30) + 'mo';
  return '1y+';
}

export function riskDimensions(breakdown) {
  const risk = breakdown?.risk;
  if (!risk) return [];
  return [
    { key: 'Capital', value: risk.capital, max: 5 },
    { key: 'Market', value: risk.market, max: 5 },
    { key: 'Revenue', value: risk.revenue, max: 5 },
    { key: 'Execution', value: risk.execution, max: 5 },
    { key: 'Info', value: risk.information, max: 5 },
  ].filter(d => d.value != null);
}

export function strategyLabels(breakdown) {
  const s = breakdown?.strategy;
  if (!s) return [];
  return [
    s.market_match && { key: 'Market', value: s.market_match },
    s.revenue_match && { key: 'Revenue', value: s.revenue_match },
    s.property_fit && { key: 'Property', value: s.property_fit },
  ].filter(Boolean);
}
