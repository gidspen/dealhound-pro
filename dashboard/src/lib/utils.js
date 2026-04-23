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
