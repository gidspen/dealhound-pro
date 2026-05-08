import { useEffect, useState, useRef } from 'preact/hooks';
import { view, previewOpen, previewWidth, currentDeal, dealsForCurrentScan, currentScan, scans, starredDealIds, activeThreads, deals, activeThreadId, scanInProgress, email } from '../lib/state.js';
import { switchThread, loadUserData, toggleStar } from '../lib/api.js';
import { fmtPrice, tierFromStrategy, tierLabel, riskClass, parseBreakdown, fmtDaysOnMarket, riskDimensions, strategyLabels } from '../lib/utils.js';

function CompactDealRow({ deal, onOpen }) {
  const bd = parseBreakdown(deal.score_breakdown);
  // Pass the full breakdown + score so tierFromStrategy can use .tier or score-based fallback
  // when older `strategy.overall` is missing (e.g. pipelines that wrote a flat tier field).
  // score_breakdown stores the score as priority_score; deal.score is a fallback for any future column.
  const tier = tierFromStrategy({ ...bd, score: bd.priority_score ?? deal.score });
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

  const grouped = { hot: [], strong: [], watch: [], pass: [] };
  unstarred.forEach(deal => {
    const bd = parseBreakdown(deal.score_breakdown);
    const tier = tierFromStrategy({ ...bd, score: bd.priority_score ?? deal.score });
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
  grouped.pass.sort(sortByRecency);

  return (
    <>
      <div class="preview-header">
        <span>{scanInProgress.value && scanDeals.length === 0 ? 'Scanning…' : `${scanDeals.length} Deals`}</span>
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

        {/* PASS */}
        {grouped.pass.length > 0 && (
          <>
            <div class="preview-group-hdr preview-group-watch">Pass · {grouped.pass.length}</div>
            {grouped.pass.map(deal => <CompactDealRow key={deal.id} deal={deal} onOpen={openThread} />)}
          </>
        )}

        {scanDeals.length === 0 && (
          <div class="preview-empty">
            {scanInProgress.value
              ? 'Deals will appear here as they\'re scored.'
              : 'No deals in this scan.'}
          </div>
        )}
      </div>
    </>
  );
}

const ALLOWED_EXTENSIONS = '.pdf,.xlsx,.xls,.csv,.doc,.docx';

function fmtFileSize(bytes) {
  if (!bytes) return '';
  if (bytes < 1024) return `${bytes}B`;
  if (bytes < 1048576) return `${(bytes / 1024).toFixed(0)}KB`;
  return `${(bytes / 1048576).toFixed(1)}MB`;
}

function fileIcon(mimeType) {
  if (!mimeType) return '📄';
  if (mimeType.includes('pdf')) return '📕';
  if (mimeType.includes('excel') || mimeType.includes('spreadsheet') || mimeType.includes('csv')) return '📊';
  if (mimeType.includes('word') || mimeType.includes('wordprocessing')) return '📝';
  return '📄';
}

function DealDocuments({ dealId }) {
  const [files, setFiles] = useState([]);
  const [uploading, setUploading] = useState(false);
  const [dragOver, setDragOver] = useState(false);
  const [error, setError] = useState(null);
  const inputRef = useRef(null);
  const userEmail = email.value;

  useEffect(() => {
    if (!dealId || !userEmail) return;
    fetch(`/api/deal-files?deal_id=${dealId}&email=${encodeURIComponent(userEmail)}`)
      .then(r => r.json())
      .then(data => setFiles(data.files || []))
      .catch(() => {});
  }, [dealId]);

  const showError = (msg) => {
    setError(msg);
    setTimeout(() => setError(null), 6000);
  };

  const upload = async (file) => {
    if (uploading) return;
    setUploading(true);
    setError(null);
    try {
      const base64 = await new Promise((resolve, reject) => {
        const reader = new FileReader();
        reader.onload = () => resolve(reader.result.split(',')[1]);
        reader.onerror = reject;
        reader.readAsDataURL(file);
      });

      const res = await fetch('/api/deal-files', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          deal_id: dealId,
          email: userEmail,
          file_name: file.name,
          file_type: file.type || null,
          file_data_base64: base64,
        }),
      });

      const data = await res.json();
      if (!res.ok) throw new Error(data.error || 'Upload failed');
      setFiles(prev => [data.file, ...prev]);
    } catch (err) {
      showError(err.message);
    } finally {
      setUploading(false);
    }
  };

  const removeFile = async (id) => {
    try {
      const res = await fetch(`/api/deal-files?id=${id}&email=${encodeURIComponent(userEmail)}`, {
        method: 'DELETE',
      });
      if (!res.ok) throw new Error('Delete failed');
      setFiles(prev => prev.filter(f => f.id !== id));
    } catch {
      showError('Delete failed. Try again.');
    }
  };

  const onDrop = (e) => {
    e.preventDefault();
    setDragOver(false);
    const file = e.dataTransfer.files[0];
    if (file) upload(file);
  };

  return (
    <div class="deal-docs">
      <div class="deal-detail-section-label">Documents</div>
      <div
        class={`deal-docs-zone${dragOver ? ' deal-docs-zone-active' : ''}${uploading ? ' deal-docs-zone-uploading' : ''}`}
        onDrop={onDrop}
        onDragOver={(e) => { e.preventDefault(); setDragOver(true); }}
        onDragLeave={() => setDragOver(false)}
        onClick={() => !uploading && inputRef.current?.click()}
      >
        <input
          ref={inputRef}
          type="file"
          style="display:none"
          accept={ALLOWED_EXTENSIONS}
          onChange={(e) => { if (e.target.files[0]) upload(e.target.files[0]); e.target.value = ''; }}
        />
        <span class="deal-docs-zone-text">
          {uploading ? 'Uploading…' : <><span class="deal-docs-upload-icon">↑</span> Drop or click to add</>}
        </span>
      </div>
      {error && <div class="deal-docs-error">{error}</div>}
      {files.length > 0 && (
        <div class="deal-docs-list">
          {files.map(f => (
            <div key={f.id} class="deal-docs-file">
              <span class="deal-docs-file-icon">{fileIcon(f.file_type)}</span>
              <div class="deal-docs-file-meta">
                <div class="deal-docs-file-name" title={f.file_name}>{f.file_name}</div>
                <div class="deal-docs-file-size">{fmtFileSize(f.file_size_bytes)}</div>
              </div>
              <button class="deal-docs-delete" onClick={() => removeFile(f.id)} title="Remove file">×</button>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

function DealDetail() {
  const deal = currentDeal.value;
  if (!deal) return null;

  const bd = parseBreakdown(deal.score_breakdown);
  const strategy = bd.strategy || {};
  const risk = bd.risk || {};
  const tier = tierFromStrategy({ ...bd, score: bd.priority_score ?? deal.score });
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

          <DealDocuments dealId={deal.id} />

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
  const hasContent = view.value === 'scan' || view.value === 'deal';

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
