# Dashboard UX Redesign — Inbox/Tracking + Briefs + Rich Detail

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Transform the Deal Hound dashboard from a static deal list into a Superhuman-style triage inbox with pre-generated deal briefs, viewed/archived state, and a richer detail panel — so users can rapidly work through new deals without waiting for AI responses.

**Architecture:** Two new DB tables (`user_deal_views`, `user_deal_archives`) plus a `brief` column on `deals`. Two new API endpoints (`/api/view-deal`, `/api/archive-deal`). Extended `/api/user-data` returns viewed/archived/brief data. Frontend sidebar rebuilt with Inbox/Tracking tabs and Group By dropdown. Chat panel shows pre-generated briefs instantly instead of auto-triggering AI. Preview panel gets tier-colored accents and expanded data fields.

**Tech Stack:** Preact + @preact/signals, Vercel serverless (Node.js/CommonJS), Supabase PostgreSQL, Anthropic Claude API (claude-sonnet-4-20250514), CSS custom properties.

**Spec:** `docs/superpowers/specs/2026-04-22-dashboard-ux-design.md`

---

## File Map

| Action | Path | Responsibility |
|--------|------|----------------|
| Modify | `dashboard/src/lib/state.js` | Add sidebarTab, sidebarGroupBy, viewedDealIds, archivedDealIds signals + computed values |
| Modify | `dashboard/src/lib/api.js` | Add viewDeal, archiveDeal functions; update loadUserData for new fields |
| Modify | `dashboard/src/lib/utils.js` | Add fmtDaysOnMarket, riskDimensions helper |
| Modify | `dashboard/src/components/Sidebar.jsx` | Complete rewrite — tabs, grouping, archive, new dots |
| Modify | `dashboard/src/components/Chat.jsx` | Show pre-generated briefs; add breakdown button for WATCH |
| Modify | `dashboard/src/components/Preview.jsx` | Richer detail card with tier accents, risk grid, new fields |
| Modify | `dashboard/src/styles.css` | All new styles for tabs, dropdown, dots, tier accents, risk bars |
| Create | `api/view-deal.js` | POST — mark deal as viewed |
| Create | `api/archive-deal.js` | POST — toggle deal archive |
| Modify | `api/user-data.js:77-88,116-143` | Return brief, viewed, archived flags; select new columns |
| Modify | `vercel.json` | Add function configs for new endpoints |

---

## Task 1: Database Migrations

**Files:**
- No code files — Supabase SQL executed via MCP

- [ ] **Step 1: Create `user_deal_views` table**

```sql
CREATE TABLE IF NOT EXISTS user_deal_views (
  user_email TEXT REFERENCES users(email) ON DELETE CASCADE,
  deal_id UUID REFERENCES deals(id) ON DELETE CASCADE,
  viewed_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (user_email, deal_id)
);
```

- [ ] **Step 2: Create `user_deal_archives` table**

```sql
CREATE TABLE IF NOT EXISTS user_deal_archives (
  user_email TEXT REFERENCES users(email) ON DELETE CASCADE,
  deal_id UUID REFERENCES deals(id) ON DELETE CASCADE,
  archived_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (user_email, deal_id)
);
```

- [ ] **Step 3: Add `brief` column to `deals`**

```sql
ALTER TABLE deals ADD COLUMN IF NOT EXISTS brief TEXT;
```

- [ ] **Step 4: Verify all tables exist**

```sql
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'public'
AND table_name IN ('user_deal_views', 'user_deal_archives');

SELECT column_name FROM information_schema.columns
WHERE table_name = 'deals' AND column_name = 'brief';
```

Expected: Both tables returned. `brief` column returned.

---

## Task 2: API — `/api/view-deal.js`

**Files:**
- Create: `api/view-deal.js`

- [ ] **Step 1: Create the endpoint**

```javascript
const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_KEY
);

module.exports = async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');

  if (req.method === 'OPTIONS') {
    res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
    return res.status(200).end();
  }

  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const { email, deal_id } = req.body;

  if (!email || !deal_id) {
    return res.status(400).json({ error: 'Missing email or deal_id' });
  }

  try {
    const { error } = await supabase
      .from('user_deal_views')
      .upsert(
        { user_email: email, deal_id, viewed_at: new Date().toISOString() },
        { onConflict: 'user_email,deal_id' }
      );
    if (error) throw error;

    return res.status(200).json({ ok: true });
  } catch (err) {
    console.error('view-deal error:', err.message);
    return res.status(500).json({ error: 'Failed to mark deal as viewed' });
  }
};
```

- [ ] **Step 2: Commit**

```bash
git add api/view-deal.js
git commit -m "feat: add /api/view-deal endpoint — mark deal as viewed"
```

---

## Task 3: API — `/api/archive-deal.js`

**Files:**
- Create: `api/archive-deal.js`

- [ ] **Step 1: Create the endpoint**

```javascript
const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_KEY
);

module.exports = async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');

  if (req.method === 'OPTIONS') {
    res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
    return res.status(200).end();
  }

  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const { email, deal_id, archived } = req.body;

  if (!email || !deal_id || typeof archived !== 'boolean') {
    return res.status(400).json({ error: 'Missing email, deal_id, or archived (boolean)' });
  }

  try {
    if (archived) {
      const { error } = await supabase
        .from('user_deal_archives')
        .upsert(
          { user_email: email, deal_id, archived_at: new Date().toISOString() },
          { onConflict: 'user_email,deal_id' }
        );
      if (error) throw error;
    } else {
      const { error } = await supabase
        .from('user_deal_archives')
        .delete()
        .eq('user_email', email)
        .eq('deal_id', deal_id);
      if (error) throw error;
    }

    return res.status(200).json({ ok: true });
  } catch (err) {
    console.error('archive-deal error:', err.message);
    return res.status(500).json({ error: 'Failed to update archive status' });
  }
};
```

- [ ] **Step 2: Commit**

```bash
git add api/archive-deal.js
git commit -m "feat: add /api/archive-deal endpoint — toggle deal archive"
```

---

## Task 4: API — Extend `/api/user-data.js`

**Files:**
- Modify: `api/user-data.js:77-88` (deals query — add brief, days_on_market, property_type, raw_description)
- Modify: `api/user-data.js:90-100` (add viewed IDs query)
- Modify: `api/user-data.js:116-143` (add viewed/archived flags to response)

- [ ] **Step 1: Update the deals SELECT to include new fields**

Change line 82 from:
```javascript
        .select('id, title, location, price, acreage, rooms_keys, score_breakdown, source, url, search_id, passed_hard_filters')
```
to:
```javascript
        .select('id, title, location, price, acreage, rooms_keys, score_breakdown, source, url, search_id, passed_hard_filters, brief, days_on_market, property_type, raw_description')
```

- [ ] **Step 2: Add viewed and archived ID queries after the starred query (after line 100)**

Insert after the starred IDs block:

```javascript
    // Viewed status
    let viewedIds = new Set();
    if (dealIds.length > 0) {
      const { data: views } = await supabase
        .from('user_deal_views')
        .select('deal_id')
        .eq('user_email', email)
        .in('deal_id', dealIds);
      viewedIds = new Set((views || []).map(v => v.deal_id));
    }

    // Archived status
    let archivedIds = new Set();
    if (dealIds.length > 0) {
      const { data: archives } = await supabase
        .from('user_deal_archives')
        .select('deal_id')
        .eq('user_email', email)
        .in('deal_id', dealIds);
      archivedIds = new Set((archives || []).map(a => a.deal_id));
    }
```

- [ ] **Step 3: Add new fields to the deals response mapping**

Update the `deals.map` in the response (around line 126) to include new fields:

```javascript
      deals: deals.map(d => ({
        id: d.id,
        title: d.title,
        location: d.location,
        price: d.price,
        acreage: d.acreage,
        rooms_keys: d.rooms_keys,
        score_breakdown: d.score_breakdown,
        source: d.source,
        url: d.url,
        search_id: d.search_id,
        starred: starredIds.has(d.id),
        viewed: viewedIds.has(d.id),
        archived: archivedIds.has(d.id),
        brief: d.brief || null,
        days_on_market: d.days_on_market || null,
        property_type: d.property_type || null,
        raw_description: d.raw_description ? d.raw_description.substring(0, 300) : null
      })),
```

- [ ] **Step 4: Update `vercel.json` with new endpoint configs**

Add to the `functions` object:
```json
    "api/view-deal.js": { "maxDuration": 10 },
    "api/archive-deal.js": { "maxDuration": 10 }
```

- [ ] **Step 5: Commit**

```bash
git add api/user-data.js vercel.json
git commit -m "feat: extend /api/user-data with viewed, archived, brief, and extra deal fields"
```

---

## Task 5: Frontend — State Management

**Files:**
- Modify: `dashboard/src/lib/state.js`

- [ ] **Step 1: Add new signals**

After line 9 (`export const sidebarOpen = signal(true);`), add:

```javascript
export const sidebarTab = signal('inbox');      // 'inbox' | 'tracking'
export const sidebarGroupBy = signal('strength'); // 'strength' | 'date'
export const viewedDealIds = signal(new Set());
export const archivedDealIds = signal(new Set());
```

- [ ] **Step 2: Replace `activeDeals` computed with new computed values**

Replace the `activeDeals` computed (lines 45-48) with:

```javascript
export const inboxDeals = computed(() => {
  return deals.value.filter(d =>
    !archivedDealIds.value.has(d.id) && !starredDealIds.value.has(d.id)
  );
});

export const trackingDeals = computed(() => {
  return deals.value.filter(d => starredDealIds.value.has(d.id));
});

export const newDealCount = computed(() => {
  return inboxDeals.value.filter(d => !viewedDealIds.value.has(d.id)).length;
});
```

- [ ] **Step 3: Commit**

```bash
git add dashboard/src/lib/state.js
git commit -m "feat: add inbox/tracking state signals and computed values"
```

---

## Task 6: Frontend — API Client Updates

**Files:**
- Modify: `dashboard/src/lib/api.js`

- [ ] **Step 1: Update imports from state.js**

Change line 2-5 to:

```javascript
import {
  email, agentName, scans, deals, activeThreads, starredDealIds,
  viewedDealIds, archivedDealIds,
  chatMessages, chatConversationId, chatStreaming,
  cacheGet, cacheSet, activeThreadId
} from './state.js';
```

- [ ] **Step 2: Update loadUserData to populate new signals**

In `loadUserData()` (line 9-19), after `starredDealIds.value = ...` add:

```javascript
  viewedDealIds.value = new Set(data.deals.filter(d => d.viewed).map(d => d.id));
  archivedDealIds.value = new Set(data.deals.filter(d => d.archived).map(d => d.id));
```

- [ ] **Step 3: Add viewDeal function**

Add after `toggleStar`:

```javascript
export async function viewDeal(dealId) {
  if (viewedDealIds.value.has(dealId)) return;

  // Optimistic update
  const updated = new Set(viewedDealIds.value);
  updated.add(dealId);
  viewedDealIds.value = updated;

  try {
    const res = await fetch(`${API_BASE}/api/view-deal`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email: email.value, deal_id: dealId })
    });
    if (!res.ok) throw new Error();
  } catch {
    // Revert on failure
    const reverted = new Set(viewedDealIds.value);
    reverted.delete(dealId);
    viewedDealIds.value = reverted;
  }
}

export async function archiveDeal(dealId) {
  const currentlyArchived = archivedDealIds.value.has(dealId);
  const newArchived = !currentlyArchived;

  // Optimistic update
  const updated = new Set(archivedDealIds.value);
  if (newArchived) updated.add(dealId); else updated.delete(dealId);
  archivedDealIds.value = updated;

  try {
    const res = await fetch(`${API_BASE}/api/archive-deal`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email: email.value, deal_id: dealId, archived: newArchived })
    });
    if (!res.ok) throw new Error();
  } catch {
    // Revert on failure
    const reverted = new Set(archivedDealIds.value);
    if (currentlyArchived) reverted.add(dealId); else reverted.delete(dealId);
    archivedDealIds.value = reverted;
  }
}
```

- [ ] **Step 4: Update switchThread to auto-mark as viewed**

At the top of `switchThread` (line 30), after `activeThreadId.value = threadId;` add:

```javascript
  // Auto-mark deal as viewed when selected
  if (type === 'deal') {
    viewDeal(threadId);
  }
```

- [ ] **Step 5: Commit**

```bash
git add dashboard/src/lib/api.js
git commit -m "feat: add viewDeal, archiveDeal API functions; auto-view on thread switch"
```

---

## Task 7: Frontend — Utility Helpers

**Files:**
- Modify: `dashboard/src/lib/utils.js`

- [ ] **Step 1: Add new helpers at bottom of file**

```javascript
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
```

- [ ] **Step 2: Commit**

```bash
git add dashboard/src/lib/utils.js
git commit -m "feat: add fmtDaysOnMarket, riskDimensions, strategyLabels helpers"
```

---

## Task 8: Frontend — Sidebar Rewrite (Inbox/Tracking Tabs)

**Files:**
- Modify: `dashboard/src/components/Sidebar.jsx`

- [ ] **Step 1: Rewrite the entire component**

Replace the full contents of `dashboard/src/components/Sidebar.jsx` with:

```jsx
import {
  email, view, activeThreadId, scans, deals,
  activeThreads, settingsOpen, sidebarOpen,
  sidebarTab, sidebarGroupBy, starredDealIds,
  viewedDealIds, archivedDealIds,
  inboxDeals, trackingDeals, newDealCount
} from '../lib/state.js';
import { switchThread, toggleStar, archiveDeal } from '../lib/api.js';
import { tierFromStrategy, tierLabel, fmtPrice, parseBreakdown } from '../lib/utils.js';

function DealRow({ deal }) {
  const bd = parseBreakdown(deal.score_breakdown);
  const tier = tierFromStrategy(bd.strategy?.overall);
  const isActive = view.value === 'deal' && activeThreadId.value === deal.id;
  const isViewed = viewedDealIds.value.has(deal.id);
  const isStarred = starredDealIds.value.has(deal.id);
  const thread = activeThreads.value.find(t => t.deal_id === deal.id);

  const handleClick = () => {
    view.value = 'deal';
    switchThread(deal.id, 'deal', thread?.conversation_id);
  };

  return (
    <div class={`sidebar-deal-row ${isActive ? 'active' : ''}`} onClick={handleClick}>
      <div class="sidebar-deal-name">
        {!isViewed && <span class="new-dot" />}
        <span class="sidebar-deal-title">{deal.title || 'Untitled'}</span>
        <span class={`sidebar-tier tier-${tier}`}>{tierLabel(tier)}</span>
      </div>
      <div class="sidebar-deal-meta">
        <span>{fmtPrice(deal.price)}{deal.location ? ` · ${deal.location.split(',')[0]}` : ''}</span>
        <span class="sidebar-deal-actions">
          <button
            class={`sidebar-action-btn ${isStarred ? 'starred' : ''}`}
            onClick={(e) => { e.stopPropagation(); toggleStar(deal.id); }}
            title={isStarred ? 'Untrack' : 'Track'}
          >{isStarred ? '★' : '☆'}</button>
          {sidebarTab.value === 'inbox' && (
            <button
              class="sidebar-action-btn"
              onClick={(e) => { e.stopPropagation(); archiveDeal(deal.id); }}
              title="Archive"
            >✕</button>
          )}
        </span>
      </div>
    </div>
  );
}

function GroupedDeals({ dealList }) {
  const groupBy = sidebarGroupBy.value;

  if (groupBy === 'date') {
    // Group by scan date — newest first
    const byDate = new Map();
    dealList.forEach(deal => {
      const scan = scans.value.find(s => s.id === deal.search_id);
      const dateKey = scan?.run_at ? new Date(scan.run_at).toLocaleDateString('en-US', { month: 'short', day: 'numeric' }) : 'Unknown';
      if (!byDate.has(dateKey)) byDate.set(dateKey, []);
      byDate.get(dateKey).push(deal);
    });

    return (
      <>
        {[...byDate.entries()].map(([date, deals]) => (
          <div key={date}>
            <div class="sidebar-section-hdr">{date}</div>
            {deals.map(d => <DealRow key={d.id} deal={d} />)}
          </div>
        ))}
      </>
    );
  }

  // Default: group by strength
  const grouped = { hot: [], strong: [], watch: [] };
  dealList.forEach(deal => {
    const bd = parseBreakdown(deal.score_breakdown);
    const tier = tierFromStrategy(bd.strategy?.overall);
    if (grouped[tier]) grouped[tier].push(deal);
  });

  return (
    <>
      {grouped.hot.length > 0 && (
        <>
          <div class="sidebar-section-hdr sidebar-hdr-hot">Hot · {grouped.hot.length}</div>
          {grouped.hot.map(d => <DealRow key={d.id} deal={d} />)}
        </>
      )}
      {grouped.strong.length > 0 && (
        <>
          <div class="sidebar-section-hdr sidebar-hdr-strong">Strong · {grouped.strong.length}</div>
          {grouped.strong.map(d => <DealRow key={d.id} deal={d} />)}
        </>
      )}
      {grouped.watch.length > 0 && (
        <>
          <div class="sidebar-section-hdr sidebar-hdr-watch">Watch · {grouped.watch.length}</div>
          {grouped.watch.map(d => <DealRow key={d.id} deal={d} />)}
        </>
      )}
    </>
  );
}

export function Sidebar() {
  const tab = sidebarTab.value;
  const currentDeals = tab === 'tracking' ? trackingDeals.value : inboxDeals.value;
  const totalAnalyzed = scans.value.reduce((sum, s) => sum + (s.deal_count || 0), 0);

  const startNewScan = () => {
    view.value = 'onboarding';
    activeThreadId.value = null;
  };

  if (!sidebarOpen.value) {
    return (
      <div id="sidebar" class="sidebar-collapsed">
        <button class="sidebar-toggle sidebar-toggle-collapsed" onClick={() => { sidebarOpen.value = true; }} title="Expand sidebar">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M13 17l5-5-5-5" /><path d="M6 17l5-5-5-5" /></svg>
        </button>
        <div class="sidebar-collapsed-icon">
          <svg width="13" height="13" viewBox="0 0 16 16" fill="white"><path d="M8 0 L9.6 6.4 L16 8 L9.6 9.6 L8 16 L6.4 9.6 L0 8 L6.4 6.4 Z"/></svg>
        </div>
        <div class="sidebar-collapsed-spacer" />
        <button class="sidebar-settings-btn" onClick={() => { settingsOpen.value = true; }} title="Settings" style="margin: 0 auto 12px;">
          <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round">
            <circle cx="12" cy="12" r="3" />
            <path d="M19.4 15a1.65 1.65 0 00.33 1.82l.06.06a2 2 0 010 2.83 2 2 0 01-2.83 0l-.06-.06a1.65 1.65 0 00-1.82-.33 1.65 1.65 0 00-1 1.51V21a2 2 0 01-4 0v-.09A1.65 1.65 0 009 19.4a1.65 1.65 0 00-1.82.33l-.06.06a2 2 0 01-2.83-2.83l.06-.06A1.65 1.65 0 004.68 15a1.65 1.65 0 00-1.51-1H3a2 2 0 010-4h.09A1.65 1.65 0 004.6 9a1.65 1.65 0 00-.33-1.82l-.06-.06a2 2 0 012.83-2.83l.06.06A1.65 1.65 0 009 4.68a1.65 1.65 0 001-1.51V3a2 2 0 014 0v.09a1.65 1.65 0 001 1.51 1.65 1.65 0 001.82-.33l.06-.06a2 2 0 012.83 2.83l-.06.06A1.65 1.65 0 0019.4 9a1.65 1.65 0 001.51 1H21a2 2 0 010 4h-.09a1.65 1.65 0 00-1.51 1z" />
          </svg>
        </button>
      </div>
    );
  }

  return (
    <div id="sidebar">
      {/* Logo + collapse */}
      <div class="sidebar-logo">
        <div class="sidebar-logo-icon">
          <svg width="13" height="13" viewBox="0 0 16 16" fill="white"><path d="M8 0 L9.6 6.4 L16 8 L9.6 9.6 L8 16 L6.4 9.6 L0 8 L6.4 6.4 Z"/></svg>
        </div>
        <span class="sidebar-logo-text">Deal Hound</span>
        <button class="sidebar-toggle" onClick={() => { sidebarOpen.value = false; }} title="Collapse sidebar">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M11 17l-5-5 5-5" /><path d="M18 17l-5-5 5-5" /></svg>
        </button>
      </div>

      {/* Tabs */}
      <div class="sidebar-tabs">
        <button
          class={`sidebar-tab ${tab === 'inbox' ? 'active' : ''}`}
          onClick={() => { sidebarTab.value = 'inbox'; }}
        >
          Inbox{newDealCount.value > 0 ? ` · ${newDealCount.value} new` : ''}
        </button>
        <button
          class={`sidebar-tab ${tab === 'tracking' ? 'active' : ''}`}
          onClick={() => { sidebarTab.value = 'tracking'; }}
        >
          ★ Tracking · {trackingDeals.value.length}
        </button>
      </div>

      {/* Controls */}
      <div class="sidebar-controls">
        <button class="sidebar-new-scan" onClick={startNewScan}>
          <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round">
            <line x1="12" y1="5" x2="12" y2="19" /><line x1="5" y1="12" x2="19" y2="12" />
          </svg>
          New Scan
        </button>
        <select
          class="sidebar-group-select"
          value={sidebarGroupBy.value}
          onChange={(e) => { sidebarGroupBy.value = e.target.value; }}
        >
          <option value="strength">By Strength</option>
          <option value="date">By Date</option>
        </select>
      </div>

      {/* Deal list */}
      <div class="sidebar-scroll">
        {currentDeals.length === 0 ? (
          <div class="sidebar-empty">
            {tab === 'tracking' ? 'Star deals to track them here' : 'No deals — run a scan'}
          </div>
        ) : (
          <GroupedDeals dealList={currentDeals} />
        )}

        {totalAnalyzed > 0 && (
          <div class="sidebar-tally">{totalAnalyzed.toLocaleString()} deals scanned</div>
        )}
      </div>

      {/* Footer */}
      <div class="sidebar-footer">
        <button class="sidebar-settings-btn" onClick={() => { settingsOpen.value = true; }} title="Settings">
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
```

- [ ] **Step 2: Commit**

```bash
git add dashboard/src/components/Sidebar.jsx
git commit -m "feat: rewrite Sidebar — inbox/tracking tabs, grouping, archive, new dots"
```

---

## Task 9: Frontend — Chat Panel (Pre-Generated Briefs)

**Files:**
- Modify: `dashboard/src/components/Chat.jsx`

- [ ] **Step 1: Rewrite the Chat component**

Replace the full contents of `dashboard/src/components/Chat.jsx` with:

```jsx
import { useRef, useEffect } from 'preact/hooks';
import { view, agentName, chatMessages, chatStreaming, activeThreadId, scans, currentDeal } from '../lib/state.js';
import { sendMessage, loadUserData, switchThread } from '../lib/api.js';
import { parseBreakdown, tierFromStrategy } from '../lib/utils.js';

function TypingIndicator() {
  return (
    <div class="msg msg-assistant">
      <div class="msg-label"><span class="msg-dot" />{agentName.value || 'Agent'}</div>
      <div class="typing"><span /><span /><span /></div>
    </div>
  );
}

function WatchPlaceholder({ deal }) {
  const startBreakdown = () => {
    const scan = scans.value.find(s => s.id === deal.search_id);
    sendMessage('Break down this deal for me.', '/api/deal-chat', { deal, buy_box: scan?.buy_box || {} });
  };

  return (
    <div class="msg msg-assistant">
      <div class="msg-label"><span class="msg-dot" />{agentName.value || 'Agent'}</div>
      <div class="msg-body">
        This deal is on the watch list — I didn't write a full brief for it since it's not a strong match for your buy box. Let me know if you want me to break it down anyway.
      </div>
      <button class="btn-breakdown" onClick={startBreakdown}>Break down this deal</button>
    </div>
  );
}

export function Chat() {
  const msgsRef = useRef(null);
  const inputRef = useRef(null);

  useEffect(() => {
    if (msgsRef.current) {
      msgsRef.current.scrollTop = msgsRef.current.scrollHeight;
    }
  }, [chatMessages.value]);

  // Auto-trigger for onboarding and scan debrief (NOT deal view)
  useEffect(() => {
    if (view.value === 'onboarding' && chatMessages.value.length === 0) {
      sendMessage('Hi, I want to set up my buy box.', '/api/chat', { mode: 'buy_box_intake' });
    } else if (view.value === 'scan' && chatMessages.value.length === 0 && activeThreadId.value) {
      sendMessage('Show me my scan results.', '/api/chat', { mode: 'scan_debrief', search_id: activeThreadId.value });
    }
    // Deal view: do NOT auto-trigger — brief or watch placeholder handles it
  }, [view.value, activeThreadId.value]);

  useEffect(() => {
    const handler = async (e) => {
      const { search_id } = e.detail;
      const msgs = [...chatMessages.value];
      msgs.push({ role: 'system', content: 'Buy box saved. Starting your scan...' });
      chatMessages.value = msgs;

      try {
        await fetch('/api/scan-start', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ search_id })
        });
      } catch { /* scan-start may not be fully wired yet */ }

      await loadUserData();
      view.value = 'scan';
      await switchThread(search_id, 'scan', null);
    };
    window.addEventListener('buybox-saved', handler);
    return () => window.removeEventListener('buybox-saved', handler);
  }, []);

  const handleSend = () => {
    if (chatStreaming.value) return;
    const text = inputRef.current?.value?.trim();
    if (!text) return;
    inputRef.current.value = '';

    if (view.value === 'deal' && currentDeal.value) {
      const scan = scans.value.find(s => s.id === currentDeal.value.search_id);
      sendMessage(text, '/api/deal-chat', { deal: currentDeal.value, buy_box: scan?.buy_box || {} });
    } else {
      const extra = {};
      if (view.value === 'scan' && activeThreadId.value) {
        extra.mode = 'scan_debrief';
        extra.search_id = activeThreadId.value;
      }
      sendMessage(text, '/api/chat', extra);
    }
  };

  const handleKeyDown = (e) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      handleSend();
    }
  };

  // Determine if we should show a pre-generated brief or watch placeholder
  const deal = currentDeal.value;
  const showBrief = view.value === 'deal' && deal && deal.brief && chatMessages.value.length === 0;
  const showWatch = view.value === 'deal' && deal && !deal.brief && chatMessages.value.length === 0;
  const bd = deal ? parseBreakdown(deal.score_breakdown) : {};
  const tier = deal ? tierFromStrategy(bd.strategy?.overall) : 'watch';

  return (
    <div id="chat-panel">
      <div class="chat-messages" ref={msgsRef}>
        <div class="chat-messages-inner">
          {/* Pre-generated brief for HOT/STRONG deals */}
          {showBrief && (
            <div class="msg msg-assistant">
              <div class="msg-label"><span class="msg-dot" />{agentName.value || 'Agent'}</div>
              <div class="msg-body">{deal.brief}</div>
            </div>
          )}

          {/* Watch list placeholder */}
          {showWatch && <WatchPlaceholder deal={deal} />}

          {/* Regular conversation messages */}
          {chatMessages.value.map((msg, i) => (
            <div key={i} class={`msg msg-${msg.role}`}>
              {msg.role === 'assistant' ? (
                <>
                  <div class="msg-label"><span class="msg-dot" />{agentName.value || 'Agent'}</div>
                  <div class="msg-body">{msg.content}</div>
                </>
              ) : msg.role === 'system' ? (
                <div class="msg-system">{msg.content}</div>
              ) : (
                msg.content
              )}
            </div>
          ))}
          {chatStreaming.value && chatMessages.value[chatMessages.value.length - 1]?.role !== 'assistant' && (
            <TypingIndicator />
          )}
        </div>
      </div>

      <div class="chat-input-bar">
        <div class="chat-input-inner">
          <input
            ref={inputRef}
            type="text"
            placeholder={view.value === 'deal' ? 'Ask about this deal...' : 'Talk to your agent...'}
            autocomplete="off"
            onKeyDown={handleKeyDown}
          />
          <button class="btn-send" onClick={handleSend} disabled={chatStreaming.value}>
            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <line x1="22" y1="2" x2="11" y2="13" /><polygon points="22 2 15 22 11 13 2 9 22 2" />
            </svg>
          </button>
        </div>
      </div>
    </div>
  );
}
```

- [ ] **Step 2: Commit**

```bash
git add dashboard/src/components/Chat.jsx
git commit -m "feat: show pre-generated briefs for HOT/STRONG; watch placeholder with breakdown button"
```

---

## Task 10: Frontend — Rich Detail Card (Preview Panel)

**Files:**
- Modify: `dashboard/src/components/Preview.jsx`

- [ ] **Step 1: Update imports**

Replace line 4 with:

```javascript
import { fmtPrice, tierFromStrategy, tierLabel, riskClass, parseBreakdown, fmtDaysOnMarket, riskDimensions, strategyLabels } from '../lib/utils.js';
```

- [ ] **Step 2: Replace the DealDetail component**

Replace the entire `function DealDetail()` (lines 97-161) with:

```jsx
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
                  <span key={s.key} class={`strategy-pill strategy-${s.value.toLowerCase().replace(/\s+/g, '-')}`}>
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
```

- [ ] **Step 3: Commit**

```bash
git add dashboard/src/components/Preview.jsx
git commit -m "feat: rich detail card with tier accents, risk bars, strategy pills, badges"
```

---

## Task 11: Frontend — CSS (New Styles)

**Files:**
- Modify: `dashboard/src/styles.css`

- [ ] **Step 1: Add sidebar tab styles**

Add after the `.sidebar-new-scan:hover` rule:

```css
/* Sidebar tabs */
.sidebar-tabs {
  display: flex; border-bottom: 1px solid var(--border); flex-shrink: 0;
}
.sidebar-tab {
  flex: 1; padding: 10px 8px; text-align: center;
  font-size: 0.72rem; font-weight: 500; letter-spacing: 0.03em;
  color: var(--cream-sub); background: none; border: none;
  cursor: pointer; transition: color 0.12s, box-shadow 0.12s;
  border-bottom: 2px solid transparent;
}
.sidebar-tab:hover { color: var(--cream); }
.sidebar-tab.active {
  color: var(--gold); border-bottom-color: var(--gold); font-weight: 600;
}

/* Sidebar controls row */
.sidebar-controls {
  display: flex; gap: 6px; padding: 8px 12px;
  border-bottom: 1px solid var(--border); flex-shrink: 0;
}
.sidebar-controls .sidebar-new-scan { flex: 1; }
.sidebar-group-select {
  background: var(--surface); border: 1px solid var(--border);
  border-radius: 6px; padding: 6px 8px; font-family: var(--sans);
  font-size: 0.72rem; color: var(--cream-dim); cursor: pointer;
  outline: none; appearance: none;
  background-image: url("data:image/svg+xml,%3Csvg width='10' height='6' viewBox='0 0 10 6' fill='none' xmlns='http://www.w3.org/2000/svg'%3E%3Cpath d='M1 1l4 4 4-4' stroke='%231D1D1B' stroke-width='1.5' stroke-linecap='round'/%3E%3C/svg%3E");
  background-repeat: no-repeat; background-position: right 6px center;
  padding-right: 22px;
}
.sidebar-group-select:focus { border-color: var(--gold); }
```

- [ ] **Step 2: Add new dot and deal action styles**

Add after the `.sidebar-deal-meta` rule:

```css
/* New dot indicator */
.new-dot {
  width: 6px; height: 6px; border-radius: 50%;
  background: var(--green); flex-shrink: 0; margin-right: 6px;
}

/* Deal row title truncation */
.sidebar-deal-title {
  white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
  min-width: 0; flex: 1;
}

/* Deal row inline actions */
.sidebar-deal-actions {
  display: flex; gap: 2px; opacity: 0; transition: opacity 0.12s; flex-shrink: 0;
}
.sidebar-deal-row:hover .sidebar-deal-actions { opacity: 1; }
.sidebar-action-btn {
  background: none; border: none; cursor: pointer;
  font-size: 0.78rem; color: var(--cream-sub); padding: 0 3px;
  transition: color 0.12s; line-height: 1;
}
.sidebar-action-btn:hover { color: var(--gold); }
.sidebar-action-btn.starred { color: var(--amber); }
```

- [ ] **Step 3: Add tier accent bar and large badge styles**

Add after the `.deal-detail` section:

```css
/* Tier accent bar */
.deal-detail-accent {
  height: 3px; border-radius: 3px 3px 0 0; margin: -4px -16px 12px -16px;
}
.accent-hot { background: var(--green); }
.accent-strong { background: var(--gold); }
.accent-watch { background: var(--amber); }

/* Large tier badge */
.deal-tier-badge-lg {
  font-size: 0.68rem; font-weight: 600; letter-spacing: 0.08em;
  text-transform: uppercase; padding: 3px 10px; border-radius: 100px;
}

/* Badges row */
.deal-detail-badges {
  display: flex; gap: 6px; flex-wrap: wrap; margin-bottom: 12px;
}
.detail-badge {
  font-size: 0.65rem; font-weight: 500; letter-spacing: 0.04em;
  text-transform: capitalize; padding: 2px 8px; border-radius: 4px;
  background: var(--surface2); color: var(--cream-dim);
  border: 1px solid var(--border);
}

/* Section labels */
.deal-detail-section-label {
  font-size: 0.62rem; font-weight: 600; letter-spacing: 0.08em;
  text-transform: uppercase; color: var(--cream-sub); margin-bottom: 6px;
}

/* Strategy match pills */
.deal-detail-strategy { margin-bottom: 14px; }
.deal-detail-pills { display: flex; gap: 6px; flex-wrap: wrap; }
.strategy-pill {
  font-size: 0.65rem; font-weight: 500; padding: 2px 8px;
  border-radius: 100px; letter-spacing: 0.03em;
}
.strategy-strong-match { background: var(--green-dim); color: var(--green); border: 1px solid rgba(26,127,55,0.2); }
.strategy-match { background: var(--gold-dim); color: var(--gold); border: 1px solid rgba(36,61,53,0.2); }
.strategy-weak-match { background: var(--amber-dim); color: var(--amber); border: 1px solid rgba(180,83,9,0.2); }
.strategy-no-match { background: var(--red-dim); color: var(--red); border: 1px solid rgba(185,28,28,0.2); }

/* Risk breakdown bars */
.deal-detail-risks { margin-bottom: 14px; }
.risk-bar-row {
  display: flex; align-items: center; gap: 8px; margin-bottom: 4px;
}
.risk-bar-label {
  font-size: 0.65rem; color: var(--cream-sub); width: 56px;
  text-align: right; flex-shrink: 0;
}
.risk-bar-track {
  flex: 1; height: 4px; background: var(--surface2);
  border-radius: 2px; overflow: hidden;
}
.risk-bar-fill {
  height: 100%; border-radius: 2px; transition: width 0.3s ease;
}
.risk-bar-low { background: var(--green); }
.risk-bar-mid { background: var(--amber); }
.risk-bar-high { background: var(--red); }
.risk-bar-val {
  font-size: 0.62rem; color: var(--cream-sub); width: 24px; flex-shrink: 0;
}

/* Agent assessment with tier tint */
.deal-detail-assessment { margin-bottom: 14px; padding: 10px 12px; border-radius: 6px; }
.assessment-hot { background: var(--green-dim); border: 1px solid rgba(26,127,55,0.12); }
.assessment-strong { background: var(--gold-dim); border: 1px solid rgba(36,61,53,0.12); }
.assessment-watch { background: var(--surface2); border: 1px solid var(--border); }
.deal-detail-assessment p {
  font-size: 0.82rem; color: var(--cream-dim); line-height: 1.5;
}

/* Description excerpt */
.deal-detail-description { margin-bottom: 14px; }
.deal-detail-desc-text {
  font-size: 0.78rem; color: var(--cream-sub); line-height: 1.5;
  display: -webkit-box; -webkit-line-clamp: 4; -webkit-box-orient: vertical;
  overflow: hidden;
}

/* Breakdown button for watch deals */
.btn-breakdown {
  display: inline-block; margin-top: 10px;
  background: var(--gold-dim); color: var(--gold);
  border: 1px solid rgba(36,61,53,0.2); border-radius: 6px;
  padding: 8px 16px; font-family: var(--sans);
  font-size: 0.78rem; font-weight: 500; cursor: pointer;
  transition: background 0.15s;
}
.btn-breakdown:hover { background: rgba(36,61,53,0.15); }
```

- [ ] **Step 4: Update deal-detail padding for accent bar**

Change `.deal-detail` padding:

```css
.deal-detail { padding: 4px 16px 0; }
```

- [ ] **Step 5: Commit**

```bash
git add dashboard/src/styles.css
git commit -m "feat: add CSS for tabs, grouping dropdown, new dots, tier accents, risk bars, breakdown button"
```

---

## Task 12: Integration Test

- [ ] **Step 1: Start both servers**

Terminal 1:
```bash
npx vercel dev --listen 3000
```

Terminal 2:
```bash
npx vite
```

- [ ] **Step 2: Test inbox/tracking tabs**

Open `http://localhost:5173`. Log in with `gideon@stonemontcap.com`. Expected: Sidebar shows "Inbox" and "★ Tracking" tabs. Inbox is active by default. Deals listed with new dots for unseen deals.

- [ ] **Step 3: Test grouping dropdown**

Switch "Group by" to "By Date". Expected: deals regroup by scan date. Switch back to "By Strength". Expected: HOT/STRONG/WATCH grouping.

- [ ] **Step 4: Test triage — select a deal**

Click a deal in the inbox. Expected: deal loads in chat + preview. New dot disappears. If deal has a brief, it shows instantly (no streaming). If WATCH deal, shows watch placeholder with breakdown button.

- [ ] **Step 5: Test star → tracking**

Click the star button on a deal. Expected: deal moves to Tracking tab. Switch to Tracking tab to verify.

- [ ] **Step 6: Test archive**

Click the archive button (✕) on a deal in Inbox. Expected: deal disappears from Inbox list.

- [ ] **Step 7: Test rich detail card**

Select a deal. Check preview panel. Expected: tier-colored accent bar at top, badges row (property type, source, DOM), metrics grid, strategy pills, risk bars, agent assessment in tinted card.

- [ ] **Step 8: Test panel collapse/expand**

Collapse sidebar — should show thin strip. Expand back. Collapse preview — should show thin strip with chevron. Expand back.

- [ ] **Step 9: Commit any fixes**

```bash
git add -A
git commit -m "fix: integration test fixes for dashboard UX redesign"
```

---

## Summary

| Task | What It Produces |
|------|-----------------|
| 1 | Database tables (user_deal_views, user_deal_archives, deals.brief) |
| 2 | `/api/view-deal` — mark deal as viewed |
| 3 | `/api/archive-deal` — toggle deal archive |
| 4 | Extended `/api/user-data` — viewed, archived, brief, extra fields |
| 5 | State management — new signals and computed values |
| 6 | API client — viewDeal, archiveDeal, auto-view on select |
| 7 | Utility helpers — DOM formatter, risk dimensions, strategy labels |
| 8 | Sidebar rewrite — inbox/tracking tabs, grouping, archive, new dots |
| 9 | Chat panel — pre-generated briefs, watch placeholder, breakdown button |
| 10 | Preview panel — rich detail card with tier accents, risk bars, badges |
| 11 | CSS — all new styles |
| 12 | Integration test |
