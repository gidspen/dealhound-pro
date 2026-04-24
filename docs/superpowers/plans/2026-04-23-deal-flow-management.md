# Deal Flow Management Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Simplify the deal inbox to a fixed strength-based grouping (hot/strong/watch) with newest deals on top, add an unread filter for inbox, and make both sidebar and preview panels drag-resizable.

**Architecture:** Remove the grouping dropdown and date-grouping code path entirely. Sort deals within each tier by scan `run_at` descending so newest deals surface to the top. Add an `unreadFilter` signal and toggle button visible only on the inbox tab. Implement drag-to-resize on both panel borders using pointer events — no library needed.

**Tech Stack:** Preact + Preact Signals, vanilla CSS, pointer events API

---

## File Map

| File | Action | Responsibility |
|------|--------|----------------|
| `dashboard/src/lib/state.js` | Modify | Remove `sidebarGroupBy` signal, add `unreadFilter` signal |
| `dashboard/src/components/Sidebar.jsx` | Modify | Remove grouping dropdown, add unread filter toggle, sort deals by scan date within tiers |
| `dashboard/src/components/Preview.jsx` | Modify | Apply same sorting within tier groups |
| `dashboard/src/app.jsx` | Modify | Add resize handles, pointer event listeners, width signals for both panels |
| `dashboard/src/styles.css` | Modify | Remove `.sidebar-group-select`, add resize handle styles, update panel width to use signals |

---

### Task 1: Remove grouping signal, add unread filter signal, and update Sidebar import

**Files:**
- Modify: `dashboard/src/lib/state.js:11` (remove `sidebarGroupBy`), add `unreadFilter`
- Modify: `dashboard/src/components/Sidebar.jsx:4` (update import to swap `sidebarGroupBy` for `unreadFilter`)

- [ ] **Step 1: Remove `sidebarGroupBy` and add `unreadFilter`**

In `state.js`, delete line 11:
```javascript
export const sidebarGroupBy = signal('strength');
```

Add in its place:
```javascript
export const unreadFilter = signal(false);
```

- [ ] **Step 2: Update Sidebar.jsx import immediately (prevents broken build)**

In `Sidebar.jsx` line 4, swap `sidebarGroupBy` for `unreadFilter`:
```javascript
// Before
import {
  email, view, activeThreadId, scans, activeThreads,
  settingsOpen, sidebarOpen, sidebarTab, sidebarGroupBy,
  starredDealIds, viewedDealIds, archivedDealIds,
  inboxDeals, trackingDeals, newDealCount, previewOpen
} from '../lib/state.js';

// After
import {
  email, view, activeThreadId, scans, activeThreads,
  settingsOpen, sidebarOpen, sidebarTab, unreadFilter,
  starredDealIds, viewedDealIds, archivedDealIds,
  inboxDeals, trackingDeals, newDealCount, previewOpen
} from '../lib/state.js';
```

- [ ] **Step 3: Verify no other files import `sidebarGroupBy`**

Run: `grep -r "sidebarGroupBy" dashboard/src/`

Expected: No results (state.js export removed, Sidebar.jsx import updated).

- [ ] **Step 4: Commit**

```bash
git add dashboard/src/lib/state.js dashboard/src/components/Sidebar.jsx
git commit -m "refactor: replace sidebarGroupBy with unreadFilter signal"
```

---

### Task 2: Simplify GroupedDeals — remove date grouping, add sort-by-scan-date

**Files:**
- Modify: `dashboard/src/components/Sidebar.jsx:75-145` (GroupedDeals)

Note: Sidebar imports were already updated in Task 1.

- [ ] **Step 1: Replace GroupedDeals with strength-only grouping + scan-date sort**

Replace the entire `GroupedDeals` function (lines 73–145) with:

```javascript
function GroupedDeals({ dealList }) {
  const scanMap = new Map();
  scans.value.forEach(s => scanMap.set(s.id, s));

  // Sort by scan run_at descending (newest first) within each tier
  const sortByRecency = (a, b) => {
    const timeA = scanMap.get(a.search_id)?.run_at ? new Date(scanMap.get(a.search_id).run_at).getTime() : 0;
    const timeB = scanMap.get(b.search_id)?.run_at ? new Date(scanMap.get(b.search_id).run_at).getTime() : 0;
    return timeB - timeA;
  };

  const grouped = { hot: [], strong: [], watch: [] };
  dealList.forEach(deal => {
    const bd = parseBreakdown(deal.score_breakdown);
    const tier = tierFromStrategy(bd.strategy?.overall);
    if (grouped[tier]) grouped[tier].push(deal);
  });

  // Sort each group newest first
  grouped.hot.sort(sortByRecency);
  grouped.strong.sort(sortByRecency);
  grouped.watch.sort(sortByRecency);

  return (
    <>
      {grouped.hot.length > 0 && (
        <>
          <div class="sidebar-section-hdr sidebar-hdr-hot">Hot · {grouped.hot.length}</div>
          {grouped.hot.map(deal => <DealRow key={deal.id} deal={deal} />)}
        </>
      )}
      {grouped.strong.length > 0 && (
        <>
          <div class="sidebar-section-hdr sidebar-hdr-strong">Strong · {grouped.strong.length}</div>
          {grouped.strong.map(deal => <DealRow key={deal.id} deal={deal} />)}
        </>
      )}
      {grouped.watch.length > 0 && (
        <>
          <div class="sidebar-section-hdr sidebar-hdr-watch">Watch · {grouped.watch.length}</div>
          {grouped.watch.map(deal => <DealRow key={deal.id} deal={deal} />)}
        </>
      )}
    </>
  );
}
```

- [ ] **Step 3: Verify the build compiles**

Run: `cd dashboard && npx vite build --mode development 2>&1 | tail -5`
Expected: Build succeeds with no errors.

- [ ] **Step 4: Commit**

```bash
git add dashboard/src/components/Sidebar.jsx
git commit -m "refactor: remove date grouping, sort deals by scan recency within tiers"
```

---

### Task 3: Remove grouping dropdown, add unread filter toggle

**Files:**
- Modify: `dashboard/src/components/Sidebar.jsx:233-249` (controls section)

- [ ] **Step 1: Replace the controls section**

Replace the sidebar controls block (the `<div class="sidebar-controls">` section, roughly lines 234–249) with:

```javascript
{/* Controls: New Scan + Unread filter (inbox only) */}
<div class="sidebar-controls">
  <button class="sidebar-new-scan" style="flex: 1;" onClick={startNewScan}>
    <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round">
      <line x1="12" y1="5" x2="12" y2="19" /><line x1="5" y1="12" x2="19" y2="12" />
    </svg>
    New Scan
  </button>
  {sidebarTab.value === 'inbox' && (
    <button
      class={`sidebar-filter-btn ${unreadFilter.value ? 'active' : ''}`}
      onClick={() => { unreadFilter.value = !unreadFilter.value; }}
      title={unreadFilter.value ? 'Show all deals' : 'Show unread only'}
    >
      <span class="filter-dot" />
      Unread
    </button>
  )}
</div>
```

- [ ] **Step 2: Apply unread filter to the deal list**

In the Sidebar component's expanded state section, update the `activeDeals` line (around line 192):

```javascript
// Before
const activeDeals = sidebarTab.value === 'tracking' ? trackingDeals.value : inboxDeals.value;

// After
let activeDeals = sidebarTab.value === 'tracking' ? trackingDeals.value : inboxDeals.value;
if (sidebarTab.value === 'inbox' && unreadFilter.value) {
  activeDeals = activeDeals.filter(d => !viewedDealIds.value.has(d.id));
}
```

- [ ] **Step 3: Commit**

```bash
git add dashboard/src/components/Sidebar.jsx
git commit -m "feat: replace grouping dropdown with unread filter toggle"
```

---

### Task 4: Add unread filter button styles, remove group select styles

**Files:**
- Modify: `dashboard/src/styles.css`

- [ ] **Step 1: Remove `.sidebar-group-select` styles**

Delete the entire `.sidebar-group-select` and `.sidebar-group-select:focus` blocks (lines 162–171).

- [ ] **Step 2: Add `.sidebar-filter-btn` styles**

Add after the `.sidebar-controls .sidebar-new-scan` rule:

```css
/* Unread filter toggle */
.sidebar-filter-btn {
  display: flex; align-items: center; gap: 5px;
  background: var(--surface); border: 1px solid var(--border);
  border-radius: 6px; padding: 6px 10px; font-family: var(--sans);
  font-size: 0.72rem; font-weight: 500; color: var(--cream-dim);
  cursor: pointer; transition: all 0.15s; white-space: nowrap;
}
.sidebar-filter-btn:hover { border-color: var(--gold); color: var(--gold); }
.sidebar-filter-btn.active {
  background: var(--green-dim); border-color: rgba(26,127,55,0.3);
  color: var(--green);
}
.filter-dot {
  width: 6px; height: 6px; border-radius: 50%;
  background: currentColor; flex-shrink: 0;
}
```

- [ ] **Step 3: Commit**

```bash
git add dashboard/src/styles.css
git commit -m "style: replace group select with unread filter button styles"
```

---

### Task 5: Apply scan-date sorting to Preview panel tier groups

**Files:**
- Modify: `dashboard/src/components/Preview.jsx:29-97` (ScanDealList)

- [ ] **Step 1: Add scan-date sorting to ScanDealList**

In `Preview.jsx`, import `scans` from state (already imported). Inside `ScanDealList`, after the grouping logic (after line 48), add sorting:

```javascript
// After the forEach that populates grouped, add:
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
```

Note: `scans` is already imported on line 2 via `currentScan` dependency — verify `scans` is in the import list. If not, add it.

- [ ] **Step 2: Verify the import includes `scans`**

Check line 2 of Preview.jsx — `scans` is NOT currently imported. Update:
```javascript
import { view, previewOpen, currentDeal, dealsForCurrentScan, currentScan, scans, starredDealIds, activeThreads, deals, activeThreadId } from '../lib/state.js';
```

- [ ] **Step 3: Commit**

```bash
git add dashboard/src/components/Preview.jsx
git commit -m "feat: sort preview deal groups by scan recency"
```

---

### Task 6: Drag-to-resize sidebar panel

**Files:**
- Modify: `dashboard/src/app.jsx` (add resize handle between Sidebar and Chat)
- Modify: `dashboard/src/lib/state.js` (add `sidebarWidth` signal)
- Modify: `dashboard/src/styles.css` (resize handle styles, dynamic sidebar width)

- [ ] **Step 1: Add `sidebarWidth` signal to state.js**

In `state.js`, add:
```javascript
export const sidebarWidth = signal(220);
```

- [ ] **Step 2: Add resize handle component and logic to app.jsx**

Update `app.jsx` imports to include the width signals:
```javascript
import { email, view, scans, sidebarOpen, sidebarWidth } from './lib/state.js';
```

Add a `ResizeHandle` component before `App`:

```javascript
function ResizeHandle({ edge, widthSignal, minW, maxW }) {
  const onPointerDown = (e) => {
    e.preventDefault();
    const startX = e.clientX;
    const startW = widthSignal.value;
    const dir = edge === 'left' ? -1 : 1;

    const onMove = (e) => {
      const delta = (e.clientX - startX) * dir;
      widthSignal.value = Math.min(maxW, Math.max(minW, startW + delta));
    };
    const onUp = () => {
      document.removeEventListener('pointermove', onMove);
      document.removeEventListener('pointerup', onUp);
      document.body.style.cursor = '';
      document.body.style.userSelect = '';
    };

    document.body.style.cursor = 'col-resize';
    document.body.style.userSelect = 'none';
    document.addEventListener('pointermove', onMove);
    document.addEventListener('pointerup', onUp);
  };

  return <div class={`resize-handle resize-${edge}`} onPointerDown={onPointerDown} />;
}
```

- [ ] **Step 3: Wire resize handle into the app shell**

Update the app shell JSX to insert the handle between Sidebar and Chat, and pass width as inline style:

```javascript
return (
  <div id="app-shell">
    <Settings />
    <Sidebar />
    {sidebarOpen.value && <ResizeHandle edge="right" widthSignal={sidebarWidth} minW={180} maxW={480} />}
    <Chat />
    <Preview />
  </div>
);
```

- [ ] **Step 4: Update Sidebar to use dynamic width**

In `Sidebar.jsx`, import `sidebarWidth`:
```javascript
import { ..., sidebarWidth } from '../lib/state.js';
```

In the expanded `<div id="sidebar">` (line 197), add inline style:
```javascript
<div id="sidebar" style={`width: ${sidebarWidth.value}px`}>
```

- [ ] **Step 5: Update CSS — remove fixed `--sidebar-w` usage from `#sidebar`, keep transition for collapse**

In `styles.css`, update `#sidebar` — remove `width: var(--sidebar-w)` but keep the existing `transition: width 0.2s ease`. The collapsed state (`sidebar-collapsed`) keeps `width: 48px`.

Add a class to disable transitions during drag:
```css
#app-shell.resizing #sidebar,
#app-shell.resizing #preview-panel {
  transition: none;
}
```

Update the `ResizeHandle` component to toggle this class during drag:
```javascript
// In onPointerDown, add:
document.getElementById('app-shell').classList.add('resizing');

// In onUp, add:
document.getElementById('app-shell').classList.remove('resizing');
```

- [ ] **Step 6: Add resize handle CSS**

Add to `styles.css`:
```css
/* Resize handles */
.resize-handle {
  width: 6px; cursor: col-resize; flex-shrink: 0;
  position: relative; z-index: 10;
}
.resize-handle::after {
  content: ''; position: absolute;
  top: 0; bottom: 0; left: 2px; width: 2px;
  background: transparent; transition: background 0.15s;
  border-radius: 1px;
}
.resize-handle:hover::after { background: var(--gold); }
.resize-handle:active::after { background: var(--gold); }
```

- [ ] **Step 7: Verify sidebar resizing works**

Run: `cd dashboard && npx vite dev`
Test: Drag the border between sidebar and chat. Sidebar should smoothly resize between 180px and 480px. Collapsed state should still work (48px, no handle).

- [ ] **Step 8: Commit**

```bash
git add dashboard/src/app.jsx dashboard/src/lib/state.js dashboard/src/components/Sidebar.jsx dashboard/src/styles.css
git commit -m "feat: drag-to-resize sidebar panel"
```

---

### Task 7: Drag-to-resize preview panel

**Files:**
- Modify: `dashboard/src/lib/state.js` (add `previewWidth` signal)
- Modify: `dashboard/src/app.jsx` (add resize handle between Chat and Preview)
- Modify: `dashboard/src/components/Preview.jsx` (use dynamic width)
- Modify: `dashboard/src/styles.css` (remove fixed preview width)

- [ ] **Step 1: Add `previewWidth` signal to state.js**

```javascript
export const previewWidth = signal(400);
```

- [ ] **Step 2: Add resize handle for preview in app.jsx**

Update imports to include `previewOpen` and `previewWidth`:
```javascript
import { email, view, scans, sidebarOpen, sidebarWidth, previewOpen, previewWidth } from './lib/state.js';
```

Insert handle between Chat and Preview:
```javascript
return (
  <div id="app-shell">
    <Settings />
    <Sidebar />
    {sidebarOpen.value && <ResizeHandle edge="right" widthSignal={sidebarWidth} minW={180} maxW={480} />}
    <Chat />
    {previewOpen.value && <ResizeHandle edge="left" widthSignal={previewWidth} minW={280} maxW={600} />}
    <Preview />
  </div>
);
```

Note the `edge="left"` — dragging left makes the preview wider (inverted direction).

- [ ] **Step 3: Update Preview to use dynamic width**

In `Preview.jsx`, import `previewWidth`:
```javascript
import { view, previewOpen, previewWidth, currentDeal, dealsForCurrentScan, currentScan, scans, starredDealIds, activeThreads, deals, activeThreadId } from '../lib/state.js';
```

In the open state return (line 250):
```javascript
<div id="preview-panel" class="preview-open" style={`width: ${previewWidth.value}px`}>
```

- [ ] **Step 4: Update CSS — remove fixed preview width, keep transition for collapse**

In `styles.css`, remove `width: var(--preview-w);` from `.preview-open` (width now set by inline style from signal). Keep the existing `transition: width 0.2s ease` on `#preview-panel` — the `#app-shell.resizing` class added in Task 6 already handles disabling transitions during drag.

- [ ] **Step 5: Verify preview resizing works**

Run: `cd dashboard && npx vite dev`
Test: Drag the border between chat and preview. Preview should smoothly resize between 280px and 600px. Collapsed strip (36px) should still work. The resize handle should disappear when preview is collapsed.

- [ ] **Step 6: Commit**

```bash
git add dashboard/src/lib/state.js dashboard/src/app.jsx dashboard/src/components/Preview.jsx dashboard/src/styles.css
git commit -m "feat: drag-to-resize preview panel"
```

---

### Task 8: Final cleanup and integration test

**Files:**
- Modify: `dashboard/src/styles.css` (remove dead CSS vars if unused)

- [ ] **Step 1: Remove unused `--sidebar-w` and `--preview-w` CSS variables if no longer referenced**

Run: `grep -r "sidebar-w\|preview-w" dashboard/src/styles.css`

If only in `:root` definition and nowhere else, remove both lines from `:root`.

- [ ] **Step 2: Search for any remaining `sidebarGroupBy` references**

Run: `grep -r "sidebarGroupBy\|groupBy\|group-select\|sidebar-group" dashboard/src/`

Expected: No results. If any remain, remove them.

- [ ] **Step 3: Full integration test**

Run: `cd dashboard && npx vite dev`

Verify:
1. Inbox tab shows deals grouped by Hot → Strong → Watch, no grouping dropdown
2. Within each group, newest scan deals appear at top
3. Unread filter button appears only on inbox tab
4. Clicking "Unread" filters to only unviewed deals, clicking again shows all
5. Tracking tab shows same strength grouping, no unread filter
6. Sidebar drag-resize works (180px–480px range)
7. Preview drag-resize works (280px–600px range)
8. Both panels still collapse/expand via their toggle buttons
9. Resize handles disappear when panels are collapsed

- [ ] **Step 4: Commit**

```bash
git add -A
git commit -m "chore: remove dead grouping CSS and variables"
```
