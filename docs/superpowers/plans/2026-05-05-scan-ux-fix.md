# Deal Hound Scan UX Fix — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Deliver the scan experience: user enters dashboard → defines buy box → confirms scan → sees animated progress with live "up to 60 min" warning + dual real-time counter (listings reviewed / deals scored) → scan completes → sidebar auto-populates with no button click required.

**Architecture:** UI-only fix. The backend already writes per-step progress to `scan_progress` (with `listing_count`) via `api/_lib/progress.js`, the dashboard already polls every 3s via `ScanProgress.jsx`, and the chat already auto-refreshes on the `scan-complete` event. The gap is purely in what `ScanProgress.jsx` renders and removing the now-obsolete "View My Results" button from `Chat.jsx`. No DB migrations, no API changes, no worker changes.

**Tech Stack:** Preact + Vite (dashboard), CSS animations, no new dependencies.

---

## Acceptance Criteria (Definition of Done)

All 8 AC must pass on a real scan with a real user account:

1. **AC1** — User lands on dashboard immediately in active chat thread (already works; do not regress)
2. **AC2** — Scan starts only after user agrees in chat (already works; do not regress)
3. **AC3** — "Up to 60 minutes" message appears at scan start, persists throughout
4. **AC4** — Visual movement (animated indicator) — not static text
5. **AC5** — Live dual counter: "X listings reviewed · Y deals scored" updating during scan
6. **AC6** — "View My Results" button never renders
7. **AC7** — Sidebar auto-populates with deals within 5s of scan completion (no click)
8. **AC8** — Chat thread remains visible after deals populate (both panels visible)

---

## File Map

| File | Change | Responsibility |
|------|--------|----------------|
| `dashboard/src/components/Chat.jsx` | Modify | Remove "View My Results" button + `handleViewResults` handler |
| `dashboard/src/components/ScanProgress.jsx` | Modify | Add 60-min banner, animated indicator, aggregate dual counter |
| `dashboard/src/styles.css` | Modify | Add CSS for pulse animation + new layout elements |
| `tests/integration/scan-progress-events.test.js` | Verify | Smoke pass — no regression in progress event contract |

---

## Data Already Available (No Backend Work Needed)

`scan_progress` rows have `step`, `status`, `listing_count`, `message`, `created_at`. The skill emits these step events (from `ScanProgress.jsx:7-22`):

- `scrape:landsearch:done` — `listing_count` = raw listings scraped from LandSearch
- `scrape:naiohb:done`, `scrape:bbteam:done` — same shape per source
- `enrich:done` — `listing_count` = listings after enrichment
- `apply_buybox:done` — `listing_count` = listings that passed buy box filter
- `score:done` — `listing_count` = number of deals scored

**Derivation rules for the dual counter:**
- **Listings reviewed** = max(`listing_count`) across all `scrape:*:done` and `enrich:done` steps (covers in-progress sources too — show running total as sources complete)
- **Deals scored** = `listing_count` of latest `score:*` or `apply_buybox:done` step, defaulting to 0 before scoring starts

---

### Task 1: Remove "View My Results" button and dead handler

**Files:**
- Modify: `dashboard/src/components/Chat.jsx:140-158` (delete `handleViewResults`)
- Modify: `dashboard/src/components/Chat.jsx:203-217` (delete the `scan-cta-bar` block)
- Modify: `dashboard/src/styles.css` (remove `.scan-cta-bar` and `.btn-view-results` rules if present)

- [ ] **Step 1: Read current Chat.jsx and styles.css to confirm exact line ranges**

Run: `grep -n "handleViewResults\|scan-cta-bar\|btn-view-results" dashboard/src/components/Chat.jsx dashboard/src/styles.css`

Expected: Hits at the lines listed above. Confirms `handleViewResults` is only referenced inside the deleted button block (no other callers).

- [ ] **Step 2: Delete the `handleViewResults` function**

Remove the entire block from `Chat.jsx:140-158` including the leading comment.

- [ ] **Step 3: Delete the "View My Results" CTA bar JSX**

Remove the entire `{view.value === 'scan' && ...}` block at `Chat.jsx:203-217` (the `scan-cta-bar` div and its button).

- [ ] **Step 4: Delete `scanStatus` state plumbing if now unused**

Search for remaining uses of `scanStatus` and `setScanStatus` in `Chat.jsx`. The only consumer was the deleted button's `disabled` prop. Remove the `useState` declaration and the `onStatus={setScanStatus}` prop on `<ScanProgress />` at `Chat.jsx:201` (the `onStatus` prop in `ScanProgress.jsx` is optional, so dropping it is safe).

Run: `grep -n "scanStatus\|setScanStatus" dashboard/src/components/Chat.jsx`

Expected: No results.

- [ ] **Step 5: Remove orphaned CSS**

In `dashboard/src/styles.css`, delete the `.scan-cta-bar` and `.btn-view-results` rules.

- [ ] **Step 6: Verify build**

Run: `cd dashboard && npm run build`

Expected: Build succeeds with no warnings about unused imports or undefined symbols.

- [ ] **Step 7: Commit**

```bash
git add dashboard/src/components/Chat.jsx dashboard/src/styles.css
git commit -m "feat(dashboard): remove obsolete View My Results button — sidebar auto-populates"
```

---

### Task 2: Add persistent "up to 60 min" banner to ScanProgress

**Files:**
- Modify: `dashboard/src/components/ScanProgress.jsx:104-132` (header section)
- Modify: `dashboard/src/styles.css` (add `.scan-progress__notice` rule)

- [ ] **Step 1: Add notice text below the header**

In `ScanProgress.jsx`, inside the returned JSX (after the `scan-progress__header` div, before the steps `<ul>`), add:

```jsx
{status !== 'error' && (
  <div class="scan-progress__notice">
    Scans can take up to 60 minutes. You can leave this tab open — the agent will keep working.
  </div>
)}
```

- [ ] **Step 2: Add CSS for the notice**

In `dashboard/src/styles.css`, add (matching the existing scan-progress visual language):

```css
.scan-progress__notice {
  font-size: 13px;
  color: var(--text-muted, #6b6b6b);
  padding: 6px 0 10px;
  border-bottom: 1px solid var(--border-subtle, rgba(0,0,0,0.06));
  margin-bottom: 8px;
}
```

(Adjust variable names if styles.css uses different ones — grep for `--text-muted` first to confirm.)

- [ ] **Step 3: Verify visually**

Run: `cd dashboard && npm run build && cd .. && npm run dev` (or whatever the local serve command is — check `package.json`)

Open the dashboard, trigger a scan, confirm the banner appears below the "Scanning marketplaces..." header and stays visible the whole time.

- [ ] **Step 4: Commit**

```bash
git add dashboard/src/components/ScanProgress.jsx dashboard/src/styles.css
git commit -m "feat(dashboard): persistent 60-min scan duration notice"
```

---

### Task 3: Add animated activity indicator

**Files:**
- Modify: `dashboard/src/components/ScanProgress.jsx:106-113` (header span)
- Modify: `dashboard/src/styles.css` (add `.scan-progress__pulse` keyframes)

- [ ] **Step 1: Add a pulsing dot before the header text**

In `ScanProgress.jsx`, change the header span block to include a pulsing dot (only while status is not error):

```jsx
<div class="scan-progress__header">
  {status !== 'error' && <span class="scan-progress__pulse" aria-hidden="true" />}
  <span class="scan-progress__header-text">{headerText}</span>
  {!isEmpty && lastStep && (
    <span class="scan-progress__heartbeat">
      updated {relativeTime(lastStep.created_at, now)}
    </span>
  )}
</div>
```

- [ ] **Step 2: Add the pulse animation CSS**

In `dashboard/src/styles.css`:

```css
.scan-progress__pulse {
  display: inline-block;
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: #2f7d4a; /* match Stella green; check existing brand var */
  margin-right: 8px;
  vertical-align: middle;
  animation: scan-progress-pulse 1.4s ease-in-out infinite;
}

@keyframes scan-progress-pulse {
  0%, 100% { opacity: 0.35; transform: scale(0.85); }
  50%      { opacity: 1;    transform: scale(1.15); }
}

@media (prefers-reduced-motion: reduce) {
  .scan-progress__pulse { animation: none; opacity: 0.7; }
}
```

(Check existing brand color variables before hardcoding — grep `styles.css` for `#2f7d4a` or `--brand`.)

- [ ] **Step 3: Verify in browser**

Run a scan. Confirm a green dot pulses next to "Scanning marketplaces..." continuously. With OS-level reduced-motion enabled, dot is static.

- [ ] **Step 4: Commit**

```bash
git add dashboard/src/components/ScanProgress.jsx dashboard/src/styles.css
git commit -m "feat(dashboard): animated pulse indicator on scan progress header"
```

---

### Task 4: Add live dual counter ("X listings reviewed · Y deals scored")

**Files:**
- Modify: `dashboard/src/components/ScanProgress.jsx` (derive aggregate counts, render new row)
- Modify: `dashboard/src/styles.css` (add `.scan-progress__counter` rule)

- [ ] **Step 1: Add a derivation helper above the component**

Just below the `STEP_LABELS` object in `ScanProgress.jsx`, add:

```js
function deriveCounts(steps) {
  let reviewed = 0;
  let scored = 0;
  for (const s of steps) {
    if (s.listing_count == null) continue;
    if (s.step.startsWith('scrape:') || s.step.startsWith('enrich:')) {
      // Take the running max — sources may complete out of order, and enrich
      // covers the post-dedup count. Either way reviewed only grows.
      if (s.listing_count > reviewed) reviewed = s.listing_count;
    }
    if (s.step.startsWith('score:') || s.step.startsWith('apply_buybox:')) {
      if (s.listing_count > scored) scored = s.listing_count;
    }
  }
  return { reviewed, scored };
}
```

- [ ] **Step 2: Render the counter row in the JSX**

Inside the component, after `const lastStep = steps[steps.length - 1];`, add:

```js
const { reviewed, scored } = deriveCounts(steps);
```

Then, in the returned JSX, insert (between the notice and the steps `<ul>`):

```jsx
<div class="scan-progress__counter">
  <span class="scan-progress__counter-item">
    <strong>{reviewed.toLocaleString()}</strong> listings reviewed
  </span>
  <span class="scan-progress__counter-sep">·</span>
  <span class="scan-progress__counter-item">
    <strong>{scored.toLocaleString()}</strong> deals scored
  </span>
</div>
```

- [ ] **Step 3: Add CSS**

In `dashboard/src/styles.css`:

```css
.scan-progress__counter {
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 14px;
  padding: 8px 0;
}
.scan-progress__counter-item strong {
  font-weight: 600;
  font-variant-numeric: tabular-nums;
}
.scan-progress__counter-sep {
  color: var(--text-muted, #9b9b9b);
}
```

- [ ] **Step 4: Verify counter updates live during scan**

Run a real scan. Watch the numbers tick up as `scrape:*:done` and `score:done` rows are inserted. Confirm both counters move (reviewed first, then scored).

If the skill never emits `score:done` with a listing_count, fall back: count the rows inserted into `deals` for this `search_id`. (This requires an extra API call — defer unless verification shows scored stays at 0. See Risks below.)

- [ ] **Step 5: Commit**

```bash
git add dashboard/src/components/ScanProgress.jsx dashboard/src/styles.css
git commit -m "feat(dashboard): live dual counter — listings reviewed and deals scored"
```

---

### Task 5: Verify auto-population end-to-end

**Files:**
- Verify only: `dashboard/src/components/Chat.jsx:79-94` (scan-complete listener)
- Verify only: `dashboard/src/components/Sidebar.jsx` (renders from `inboxDeals` signal)
- Verify only: `api/user-data.js`

- [ ] **Step 1: Confirm `scan-complete` event flow**

Run: `grep -n "scan-complete\|loadUserData" dashboard/src/components/Chat.jsx dashboard/src/app.jsx dashboard/src/lib/*.js`

Confirm the chain: `ScanProgress.jsx` dispatches `scan-complete` → `Chat.jsx:79-94` calls `loadUserData()` → `loadUserData()` writes to `inboxDeals` signal → `Sidebar.jsx` renders.

- [ ] **Step 2: Run a real scan to verify**

Walk through dealhound.pro/dashboard:
1. Login
2. Define buy box in chat
3. Confirm scan starts
4. Wait for completion (or trigger a small/cached scan if test fixtures allow)
5. Confirm sidebar shows deals within 5 seconds of `score:done` step appearing
6. Confirm chat thread is still visible alongside the populated sidebar
7. Confirm "View My Results" button is nowhere on screen

- [ ] **Step 3: If sidebar does NOT auto-populate, debug**

Most likely culprit: `loadUserData()` is called but the `view.value` stays on `'scan'`, hiding the sidebar's deal list. Or `inboxDeals` filter is stale. Open browser console, check if `scan-complete` event fires. If it fires but sidebar stays empty, inspect the signal in devtools.

If broken, file findings inline and either:
- Fix the bug if obvious (e.g., missing await, stale signal closure)
- Stop and surface to Gideon with the specific failure mode

- [ ] **Step 4: Run smoke + integration tests**

Run: `npm test -- tests/smoke tests/integration/scan-progress-events.test.js`

Expected: All pass. The contract on `scan_progress` rows hasn't changed, so these should be green.

- [ ] **Step 5: Final commit (if any verification fixes)**

```bash
git add -A
git commit -m "fix(dashboard): <specific fix> for sidebar auto-population"
```

---

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Skill never emits `score:done` with `listing_count` | Verify in Step 4 of Task 4. Fallback: query `/api/user-data` for `deal_count` of active scan, derive `scored` from there. |
| Removing `scanStatus` breaks something else | Step 4 of Task 1 greps for all uses. If hits exist outside the deleted block, address before deleting. |
| Auto-population already broken (pre-existing bug) | Task 5 isolates this. If broken, surface as separate issue rather than masking with new code. |
| CSS variable names differ from assumptions | Each Task says "grep first to confirm" before adding CSS. |

---

## Out of Scope (Explicit)

- Database schema changes
- API endpoint changes
- Worker / find-deals skill changes
- Apify wiring (separate sprint per ship plan)
- Adding sources beyond what skill currently scrapes
- Onboarding flow changes (AC1/AC2 verified, not modified)
