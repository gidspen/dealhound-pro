# Skill Is The Product Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Strip the parallel implementations from Deal Hound so the architecture is exactly: user submits buy box → API queues scan → worker runs the `/find-deals` skill → skill writes scored deals to Supabase tagged with `search_id` → dashboard reads only those deals.

**Architecture:** The `/find-deals` skill is the product. Deal Hound's API and dashboard are a thin wrapper. Every scoring, filtering, or matching decision happens **inside the skill**, not in `api/`. The API only does three things: (1) capture buy boxes, (2) queue scans, (3) read scored deals back. No re-scoring. No re-filtering. No "pool overlay." Net effect: the LOC in `api/` goes **down**, and what the user sees on the dashboard is exactly what the skill produced.

**Tech Stack:** Node.js (Vercel API), Supabase (Postgres), Vitest (integration tests against real Supabase via `test_data: true` flag), the `/find-deals` skill (`~/skills/find-deals/`, runs on PM2 worker via `claude -p "/find-deals full"`).

---

## Background — What's Being Deleted And Why

Audit verified this session found **8 layers of regression** across `api/` that re-implement pieces of the skill and produce worse output than the skill itself. Of those, the user has approved deleting these five:

| Bolt-on | File:Line | Behavior to delete |
|---|---|---|
| **Scan-bypass** | `api/chat.js:263-309` | After saving a buy box, code queries the shared pool by location only. If ≥1 match exists, marks search `complete` without scanning. Core regression — users get random pool leftovers instead of their own scan. |
| **Pool overlay** | `api/user-data.js:91-126` | On every dashboard load, queries the last 7 days of pool deals, filters them by buy box (price + location only), and merges into the user's scan results. |
| **Second filter** | `api/_lib/location.js` (entire file) | `filterDealsByBuyBox` and `dealMatchesLocations` re-filter pool deals on price + location. Ignores `property_type`, `acreage_min`, `exclusions`, `revenue_requirement`, qualitative criteria. |
| **Union-as-delivery** | (downstream of pool overlay) | Daily union scrape writes deals scored against a merged superset of all users' criteria. Those scores meant nothing for any individual user; the pool overlay piped them straight to dashboards. |
| **Pool-match count gate** | `api/chat.js:267-290` | The count used to decide whether to bypass the scan. Deleted with the bypass. |

**What stays untouched:**
- `~/skills/find-deals/` (the skill — already excellent per user testing)
- `worker/worker.js` (PM2 polling + `claude -p` spawning)
- `worker/daily-scrape.sh` and `worker/union-buy-box.js` (daily inventory pre-warming — the union scrape keeps running, but its output is never user-facing without per-user re-scoring, which the skill already does)
- `api/scan-start.js`, `api/scan-progress.js` (correct as-is)
- `api/_lib/filters.js` and `tests/integration/filters.test.js` (this is `applyHardFilters`, a different module — not deleted)
- All Phase 0.1 scraper fixes shipped earlier this session (description capture, removed truncations)

---

## File Structure

### New files

| File | Responsibility |
|---|---|
| `api/_lib/scan-trigger.js` | Single source of truth for "given a `search_id` and `buy_box`, queue a scan." Always queues. No bypass. Inserts `scrape_jobs`, updates `deal_searches.status='scanning'`. Used by both `api/chat.js` (after buy box save) and `api/scan-start.js` (currently inlines this). |
| `tests/integration/scan-trigger.test.js` | Confirms `triggerScan()` always inserts a `scrape_jobs` row, never bypasses, regardless of pool state. |
| `tests/integration/user-data-isolation.test.js` | Confirms `/api/user-data` returns ONLY deals whose `search_id` is in the user's `deal_searches` — no cross-user pool leakage. |

### Modified files

| File | Change |
|---|---|
| `api/chat.js:1-3` | Drop `dealMatchesLocations` import (no longer needed). |
| `api/chat.js:263-309` | Replace 47-line bypass block with `await triggerScan(search.id, buyBox, supabase)`. |
| `api/scan-start.js:44-58` | Replace inlined scan-queue logic with `await triggerScan(search_id, search.buy_box, supabase)`. |
| `api/user-data.js:1-2` | Drop `filterDealsByBuyBox` import. |
| `api/user-data.js:91-126` | Delete pool overlay block. Delete the merge into `deals`. |
| `api/user-data.js:128-132` | Drop the now-unused `userUrls` dedup logic (only existed to deduplicate against pool deals). |

### Deleted files

| File | Reason |
|---|---|
| `api/_lib/location.js` | All callers removed in Phases 1 and 2. |
| `tests/unit/pool-dedup.test.js` | Tests dedup logic that no longer exists (pool deals are gone, so there's nothing to dedup against). |

### Untouched (verify imports still resolve)

| File | Verification |
|---|---|
| `api/scan-progress.js` | No location.js import. No change. |
| `api/_lib/filters.js` | Different module (`applyHardFilters`). Used by skill, not by API. No change. |
| `dashboard/src/**` | Reads `/api/user-data` shape — unchanged shape, just different content. |

---

## Phase 1: Kill the scan bypass

**Outcome:** Every buy box save triggers a real scan. The dashboard's "scanning..." spinner shows up every time. No more `complete` status without scanned deals.

### Task 1.1: Create the `scan-trigger.js` helper

**Files:**
- Create: `api/_lib/scan-trigger.js`

- [ ] **Step 1: Write the helper**

```js
// api/_lib/scan-trigger.js
//
// Single source of truth for queuing a scan job. Always queues — no bypass,
// no pool checks, no shortcut. The skill is the only thing that produces
// scored deals for a user, and a scan is the only way to invoke it for a
// given search_id.
//
// Used by:
//   - api/chat.js after a buy box is saved
//   - api/scan-start.js when the dashboard re-triggers a scan

async function triggerScan(searchId, buyBox, supabase) {
  if (!searchId) throw new Error('triggerScan: searchId is required');
  if (!buyBox)   throw new Error('triggerScan: buyBox is required');
  if (!supabase) throw new Error('triggerScan: supabase client is required');

  const { error: jobError } = await supabase.from('scrape_jobs').insert({
    search_id: searchId,
    buy_box: buyBox,
    status: 'pending',
  });
  if (jobError) throw new Error(`triggerScan: scrape_jobs insert failed: ${jobError.message}`);

  const { error: searchError } = await supabase
    .from('deal_searches')
    .update({ status: 'scanning' })
    .eq('id', searchId);
  if (searchError) throw new Error(`triggerScan: deal_searches update failed: ${searchError.message}`);
}

module.exports = { triggerScan };
```

- [ ] **Step 2: Commit**

```bash
git add api/_lib/scan-trigger.js
git commit -m "feat: add scan-trigger helper — single source of truth for queuing scans"
```

---

### Task 1.2: Test that `triggerScan` always queues a scan

**Files:**
- Create: `tests/integration/scan-trigger.test.js`

- [ ] **Step 1: Write the failing test**

```js
// tests/integration/scan-trigger.test.js
import { describe, it, expect, afterAll } from 'vitest';
import { getTestSupabase, cleanupTestData } from '../helpers/supabase.js';
import { TEST_EMAIL } from '../helpers/test-constants.js';
import { triggerScan } from '../../api/_lib/scan-trigger.js';

describe('triggerScan', () => {
  const supabase = getTestSupabase();

  afterAll(() => cleanupTestData(supabase, TEST_EMAIL));

  it('inserts a scrape_jobs row and sets deal_searches.status=scanning', async () => {
    const buyBox = {
      locations: ['Austin, TX'],
      price_max: 2_000_000,
      property_types: ['boutique_hotel'],
      revenue_requirement: 'cash_flow_day_1',
    };

    const { data: search } = await supabase
      .from('deal_searches')
      .insert({
        user_email: TEST_EMAIL,
        buy_box: buyBox,
        status: 'ready',
        test_data: true,
        run_at: new Date().toISOString(),
      })
      .select('id')
      .single();

    await triggerScan(search.id, buyBox, supabase);

    const { data: job } = await supabase
      .from('scrape_jobs')
      .select('search_id, status, buy_box')
      .eq('search_id', search.id)
      .single();

    expect(job).not.toBeNull();
    expect(job.status).toBe('pending');
    expect(job.buy_box.price_max).toBe(2_000_000);

    const { data: updatedSearch } = await supabase
      .from('deal_searches')
      .select('status')
      .eq('id', search.id)
      .single();

    expect(updatedSearch.status).toBe('scanning');
  });

  it('queues a scan even if the pool already has matching deals (no bypass)', async () => {
    // The whole point of this refactor: a populated pool MUST NOT skip the scan.
    const buyBox = {
      locations: ['Austin, TX'],
      price_max: 2_000_000,
      property_types: ['boutique_hotel'],
      revenue_requirement: 'cash_flow_day_1',
    };

    const { data: search } = await supabase
      .from('deal_searches')
      .insert({
        user_email: TEST_EMAIL,
        buy_box: buyBox,
        status: 'ready',
        test_data: true,
        run_at: new Date().toISOString(),
      })
      .select('id')
      .single();

    // triggerScan does not query the pool — it just queues. Verify by checking
    // the job was created regardless of pool state.
    await triggerScan(search.id, buyBox, supabase);

    const { count } = await supabase
      .from('scrape_jobs')
      .select('*', { count: 'exact', head: true })
      .eq('search_id', search.id);

    expect(count).toBe(1);
  });

  it('throws if required args missing', async () => {
    await expect(triggerScan(null, {}, supabase)).rejects.toThrow(/searchId/);
    await expect(triggerScan('x', null, supabase)).rejects.toThrow(/buyBox/);
    await expect(triggerScan('x', {}, null)).rejects.toThrow(/supabase/);
  });
});
```

- [ ] **Step 2: Run test to verify it passes**

Run: `npm test -- tests/integration/scan-trigger.test.js`
Expected: 3 tests PASS.

- [ ] **Step 3: Commit**

```bash
git add tests/integration/scan-trigger.test.js
git commit -m "test: cover scan-trigger always-queues contract"
```

---

### Task 1.3: Replace the bypass block in `api/chat.js`

**Files:**
- Modify: `api/chat.js:1-3` (drop unused import)
- Modify: `api/chat.js:263-309` (replace bypass block)

- [ ] **Step 1: Drop the now-unused location import**

Edit `api/chat.js` — change line 3:

```js
// BEFORE
const { dealMatchesLocations } = require('./_lib/location');

// AFTER (delete the line entirely)
```

- [ ] **Step 2: Add the scan-trigger import**

Edit `api/chat.js` — after line 2 (the supabase import), add:

```js
const { triggerScan } = require('./_lib/scan-trigger');
```

- [ ] **Step 3: Replace the bypass block**

Edit `api/chat.js:263-309` — replace this:

```js
        } else {
          // Query ALL recent scored deals (not just one pool scan).
          // Multiple scans may cover different regions. Grab everything
          // from the last 7 days and filter by the user's buy box.
          let poolMatchCount = 0;
          try {
            const sevenDaysAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString();
            const { data: rawPoolDeals } = await supabase
              .from('deals')
              .select('url, price, location')
              .eq('passed_hard_filters', true)
              .not('search_id', 'eq', search.id)
              .gte('scraped_at', sevenDaysAgo)
              .limit(500);

            if (rawPoolDeals && rawPoolDeals.length > 0) {
              // Pool check uses LOCATION ONLY — no price filter.
              // Price is a refinement for ranking, not a reason to trigger a full scan.
              // A user searching $1M-$3M Texas should see Texas deals even if most
              // pool deals are under $1M. Better to show something than trigger an
              // expensive on-demand scan that may never run.
              const locations = (buyBox.locations || []).map(l => l.toLowerCase());
              const matching = rawPoolDeals.filter(d => dealMatchesLocations(d.location, locations));
              poolMatchCount = matching.length;
            }
          } catch (poolErr) {
            console.error('Pool query error:', poolErr.message);
          }

          if (poolMatchCount > 0) {
            // Deals available from pool -- mark search as complete
            await supabase
              .from('deal_searches')
              .update({ status: 'complete' })
              .eq('id', search.id);
          } else {
            // No pool matches -- trigger on-demand scan
            await supabase.from('scrape_jobs').insert({
              search_id: search.id,
              buy_box: buyBox,
              status: 'pending',
            });
            await supabase
              .from('deal_searches')
              .update({ status: 'scanning' })
              .eq('id', search.id);
          }

          res.write(`data: ${JSON.stringify({
            type: 'buy_box_saved',
            search_id: search.id,
            buy_box: buyBox,
            pool_match_count: poolMatchCount,
          })}\n\n`);
        }
```

with this:

```js
        } else {
          await triggerScan(search.id, buyBox, supabase);

          res.write(`data: ${JSON.stringify({
            type: 'buy_box_saved',
            search_id: search.id,
            buy_box: buyBox,
          })}\n\n`);
        }
```

Net effect: 47 lines deleted, 6 lines added, no pool query, no bypass branch. The `pool_match_count` field disappears from the SSE payload — verify in Step 5 the dashboard doesn't read it.

- [ ] **Step 4: Verify dashboard doesn't depend on `pool_match_count`**

Run: `grep -rn "pool_match_count" dashboard/src/`
Expected: No matches.

If matches exist, surface them — those references must be removed in the same task.

- [ ] **Step 5: Run all integration tests**

Run: `npm test`
Expected: All tests PASS, including the new `scan-trigger.test.js`. The existing `buy-box-save.test.js` should still pass (it tests Supabase directly, not the chat handler).

- [ ] **Step 6: Commit**

```bash
git add api/chat.js
git commit -m "fix: kill scan-bypass — every buy box save triggers a scan"
```

---

### Task 1.4: Refactor `api/scan-start.js` to use the helper

**Files:**
- Modify: `api/scan-start.js:44-58`

This isn't strictly necessary for the bypass fix — `scan-start.js` already always queues. But using the same helper makes "queue a scan" exactly one path in the codebase, which is the entire point of this plan.

- [ ] **Step 1: Add the import**

Edit `api/scan-start.js` after line 2:

```js
const { triggerScan } = require('./_lib/scan-trigger');
```

- [ ] **Step 2: Replace the inlined logic**

Edit `api/scan-start.js:44-58` — replace this:

```js
    await supabase
      .from('deal_searches')
      .update({ status: 'scanning' })
      .eq('id', search_id);

    await supabase.from('scan_progress').insert([
      { search_id, step: 'init', status: 'complete', message: 'Buy box loaded - queuing scan job' },
      { search_id, step: 'queued', status: 'running', message: 'Waiting for deal scanner to pick up your request...' },
    ]);

    await supabase.from('scrape_jobs').insert({
      search_id,
      buy_box: search.buy_box,
      status: 'pending',
    });
```

with this:

```js
    await supabase.from('scan_progress').insert([
      { search_id, step: 'init', status: 'complete', message: 'Buy box loaded - queuing scan job' },
      { search_id, step: 'queued', status: 'running', message: 'Waiting for deal scanner to pick up your request...' },
    ]);

    await triggerScan(search_id, search.buy_box, supabase);
```

Note: `scan_progress` rows are kept here (they're a UX detail for the dashboard polling, not part of the scan-queue contract). `triggerScan` only handles `scrape_jobs` + `deal_searches.status`.

- [ ] **Step 3: Run integration tests**

Run: `npm test -- tests/integration/scan-start.test.js tests/integration/scan-trigger.test.js`
Expected: PASS.

- [ ] **Step 4: Commit**

```bash
git add api/scan-start.js
git commit -m "refactor: scan-start uses triggerScan helper"
```

---

### Phase 1 acceptance check

- [ ] **Verify Phase 1 outcome end-to-end (manual)**

1. `grep -n "pool_match_count\|dealMatchesLocations" api/` → expect zero matches
2. `wc -l api/chat.js` → confirm line count dropped by ~40 vs. before
3. `npm test` → all integration tests PASS

If all three pass, Phase 1 is complete. Dashboard now does a real scan on every buy box save. Pool overlay still exists — that's Phase 2.

---

## Phase 2: Strip the pool overlay from `api/user-data.js`

**Outcome:** The dashboard returns only deals whose `search_id` belongs to the user's own `deal_searches`. No cross-user leakage. No pool-merged results.

### Task 2.1: Test the new isolation contract

**Files:**
- Create: `tests/integration/user-data-isolation.test.js`

- [ ] **Step 1: Write the failing test**

```js
// tests/integration/user-data-isolation.test.js
import { describe, it, expect, afterAll, beforeAll } from 'vitest';
import { getTestSupabase, cleanupTestData } from '../helpers/supabase.js';
import { TEST_EMAIL } from '../helpers/test-constants.js';

const OTHER_EMAIL = 'other-user-isolation@dealhound.dev';

describe('user-data isolation', () => {
  const supabase = getTestSupabase();
  let mySearchId, otherSearchId;

  beforeAll(async () => {
    // Create my search + a deal scored against my buy box
    const { data: mySearch } = await supabase
      .from('deal_searches')
      .insert({
        user_email: TEST_EMAIL,
        buy_box: { locations: ['Austin, TX'], price_max: 2_000_000 },
        status: 'complete',
        test_data: true,
        run_at: new Date().toISOString(),
      })
      .select('id').single();
    mySearchId = mySearch.id;

    await supabase.from('deals').insert({
      search_id: mySearchId,
      url: 'https://example.com/mine-1',
      title: 'My Deal',
      price: 1_500_000,
      location: 'Austin, TX',
      passed_hard_filters: true,
      scraped_at: new Date().toISOString(),
    });

    // Create another user's search + their deal
    const { data: otherSearch } = await supabase
      .from('deal_searches')
      .insert({
        user_email: OTHER_EMAIL,
        buy_box: { locations: ['Austin, TX'], price_max: 2_000_000 },
        status: 'complete',
        test_data: true,
        run_at: new Date().toISOString(),
      })
      .select('id').single();
    otherSearchId = otherSearch.id;

    await supabase.from('deals').insert({
      search_id: otherSearchId,
      url: 'https://example.com/theirs-1',
      title: 'Other User Deal',
      price: 1_800_000,
      location: 'Austin, TX',
      passed_hard_filters: true,
      scraped_at: new Date().toISOString(),
    });
  });

  afterAll(async () => {
    await cleanupTestData(supabase, TEST_EMAIL);
    await cleanupTestData(supabase, OTHER_EMAIL);
  });

  it('returns only deals whose search_id belongs to the requesting user', async () => {
    // Mirror the query that user-data.js performs after Phase 2 changes.
    const { data: scans } = await supabase
      .from('deal_searches')
      .select('id')
      .eq('user_email', TEST_EMAIL);
    const scanIds = scans.map(s => s.id);

    const { data: deals } = await supabase
      .from('deals')
      .select('id, title, search_id')
      .in('search_id', scanIds)
      .eq('passed_hard_filters', true);

    const titles = deals.map(d => d.title);
    expect(titles).toContain('My Deal');
    expect(titles).not.toContain('Other User Deal');
  });
});
```

- [ ] **Step 2: Run the test (should pass with current code, but provides regression cover)**

Run: `npm test -- tests/integration/user-data-isolation.test.js`
Expected: PASS. This test validates the contract independent of `user-data.js` — it confirms Supabase queries for one user's `search_id`s won't return another user's deals. After Phase 2, `user-data.js` will use exactly this query shape.

- [ ] **Step 3: Commit**

```bash
git add tests/integration/user-data-isolation.test.js
git commit -m "test: cover user-data isolation contract"
```

---

### Task 2.2: Delete the pool overlay from `api/user-data.js`

**Files:**
- Modify: `api/user-data.js:1-2` (drop import)
- Modify: `api/user-data.js:91-126` (delete pool overlay)
- Modify: `api/user-data.js:128-132` (drop pool dedup logic)

- [ ] **Step 1: Drop the location import**

Edit `api/user-data.js` — change line 2:

```js
// BEFORE
const { filterDealsByBuyBox } = require('./_lib/location');

// AFTER (delete the line entirely)
```

- [ ] **Step 2: Delete the pool overlay block**

Edit `api/user-data.js:91-126` — delete this entire block:

```js
    // Shared pool: show scored deals from the last 7 days, filtered to user's buy box.
    // Skipped entirely when no buy box is captured — pool can't be filtered without one.
    let poolDeals = [];

    // Parse buy box — handle both JSONB object and accidentally-stringified values
    let rawBuyBox = (scans || []).find(s => s.buy_box)?.buy_box || null;
    let latestBuyBox = null;
    if (rawBuyBox) {
      if (typeof rawBuyBox === 'string') {
        try { latestBuyBox = JSON.parse(rawBuyBox); } catch (_) { latestBuyBox = null; }
      } else {
        latestBuyBox = rawBuyBox;
      }
    }

    // Only query the shared pool when the user has a buy box — without one we
    // have no way to filter the pool to relevant deals.
    if (latestBuyBox) {
      const sevenDaysAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString();
      const { data: rawPoolDeals } = await supabase
        .from('deals')
        .select('id, title, location, price, acreage, rooms_keys, score_breakdown, source, url, search_id, passed_hard_filters, brief, days_on_market, property_type, raw_description')
        .eq('passed_hard_filters', true)
        .gte('scraped_at', sevenDaysAgo)
        .limit(500);

      if (rawPoolDeals && rawPoolDeals.length > 0) {
        // Filter by buy box (price + location), then dedup against user's own deals
        poolDeals = filterDealsByBuyBox(rawPoolDeals, latestBuyBox);
        const userUrls = new Set(deals.map(d => d.url).filter(Boolean));
        poolDeals = poolDeals.filter(d => !d.url || !userUrls.has(d.url));
      }
    }

    // Merge pool deals after user's own deals
    deals = [...deals, ...poolDeals];
```

The block is replaced with **nothing**. `deals` already contains the user's own scan results from the earlier query at lines 80-89.

- [ ] **Step 3: Verify the rest of the file still uses `deals` correctly**

Read `api/user-data.js` end-to-end. The downstream code (`dealIds`, `dealCountMap`, the response JSON) must still operate on the `deals` array exactly as before.

- [ ] **Step 4: Run all integration tests**

Run: `npm test`
Expected: PASS. The new `user-data-isolation.test.js` confirms the contract; existing tests still pass because no public API shape changed.

- [ ] **Step 5: Commit**

```bash
git add api/user-data.js
git commit -m "fix: strip pool overlay — dashboard shows only user's own scan results"
```

---

### Task 2.3: Manual smoke check on the dev server

- [ ] **Step 1: Run the dev server and exercise the dashboard**

Run: `npm run build && vercel dev` (or your local dev command)

In a browser, log in as a user with completed scans. Verify:
1. Dashboard renders deals
2. Every visible deal's `search_id` (visible in Network tab → user-data response) belongs to that user's `deal_searches`
3. No deals appear that the user didn't scan for

If the dashboard is empty for a user with completed scans, the migration is fine — that user genuinely has no deals from their own scans, and was previously seeing pool leftovers. That's expected.

- [ ] **Step 2: Note any UX gaps**

If users with no scan results see a blank dashboard, log this for Phase 5: an empty-state needs a "your scan is running" or "submit a buy box to start" message. Don't fix in this phase.

---

### Phase 2 acceptance check

- [ ] **Verify Phase 2 outcome**

1. `grep -n "filterDealsByBuyBox\|poolDeals\|rawPoolDeals" api/user-data.js` → expect zero matches
2. `npm test` → all PASS
3. Manual smoke: a test user with one completed scan sees deals only from that scan's `search_id`

---

## Phase 3: Delete `api/_lib/location.js`

**Outcome:** The second filter implementation is gone. There is exactly one filter — inside the skill.

### Task 3.1: Confirm zero remaining imports

**Files:**
- Read: all `.js` files in `api/`

- [ ] **Step 1: Search for any lingering imports**

Run: `grep -rn "_lib/location\|filterDealsByBuyBox\|dealMatchesLocations" api/ tests/ dashboard/src/`
Expected: Zero matches (Phases 1 and 2 should have removed them all).

If any matches exist, fix them in this step before deleting the file.

---

### Task 3.2: Delete the file and its unit tests

**Files:**
- Delete: `api/_lib/location.js`
- Delete: `tests/unit/pool-dedup.test.js`

- [ ] **Step 1: Delete `api/_lib/location.js`**

Run: `rm api/_lib/location.js`

- [ ] **Step 2: Delete the obsolete unit test**

`tests/unit/pool-dedup.test.js` tests dedup logic that only existed because pool deals were merged into the user's deals. With pool deals removed, there's nothing to dedup against.

Run: `rm tests/unit/pool-dedup.test.js`

- [ ] **Step 3: Run all tests**

Run: `npm test && npm run test:smoke`
Expected: PASS. No "module not found" errors.

- [ ] **Step 4: Commit**

```bash
git add -A
git commit -m "chore: delete location.js and pool-dedup test — bolt-on layer is gone"
```

---

### Phase 3 acceptance check

- [ ] **Verify Phase 3 outcome**

1. `ls api/_lib/location.js 2>&1` → expect `No such file or directory`
2. `npm test` → all PASS
3. `wc -l api/*.js api/_lib/*.js | tail -1` → confirm total LOC in `api/` is **lower** than at the start of this plan

---

## Phase 4: Confirm union-buy-box.js is inventory-only

**Outcome:** The daily union scrape keeps running for inventory pre-warming, but its output is provably never user-facing without a per-user re-scoring step (which only happens when that user's own scan runs).

This phase is mostly verification — no code should change. If verification reveals a leak, surface it; that's a follow-up plan.

### Task 4.1: Trace the union scrape's data path

**Files:**
- Read: `worker/union-buy-box.js`
- Read: `worker/daily-scrape.sh`
- Read: `worker/worker.js`
- Read: `api/user-data.js` (post-Phase 2 state)

- [ ] **Step 1: Read each file and trace where union-scraped deals end up**

Write down (in your head or scratchpad):
- What `search_id` does the union scrape attach to its deals? (likely a "union" or system-level search_id, not a user's)
- After Phase 2, does any API endpoint return deals whose `search_id` is the union's?

The expected answer: union deals have a non-user `search_id`, and `api/user-data.js` only returns deals where `search_id IN (user's deal_searches.id)`, so union deals are invisible to users — exactly what we want.

- [ ] **Step 2: Run a Supabase MCP query to confirm**

Use the Supabase MCP to query:

```sql
SELECT DISTINCT ds.user_email, COUNT(d.id) AS deal_count
FROM deals d
LEFT JOIN deal_searches ds ON ds.id = d.search_id
GROUP BY ds.user_email
ORDER BY deal_count DESC;
```

Expected output: rows for each real user email with their deal counts, plus possibly one row with `user_email = NULL` (if union scrape attaches to a search_id without a user) or a system email. Either is fine — the user-data API will not return those rows.

- [ ] **Step 3: Document the finding in this plan**

Edit this section to record the actual `search_id`/`user_email` shape of union-scraped deals. This becomes the truth-of-record for future audits.

---

### Task 4.2: Add a regression guard

**Files:**
- Modify: `tests/integration/user-data-isolation.test.js`

- [ ] **Step 1: Extend the existing isolation test**

Add a third test case to the existing `user-data-isolation.test.js`:

```js
  it('does not return system-scraped deals (union scrape) to a user', async () => {
    // Simulate a union-scraped deal: a deal whose search_id is not in this user's deal_searches.
    const { data: systemSearch } = await supabase
      .from('deal_searches')
      .insert({
        user_email: 'system+union@dealhound.dev',
        buy_box: { locations: ['Austin, TX'] },
        status: 'complete',
        test_data: true,
        run_at: new Date().toISOString(),
      })
      .select('id').single();

    await supabase.from('deals').insert({
      search_id: systemSearch.id,
      url: 'https://example.com/union-1',
      title: 'Union Pre-Warm Deal',
      price: 1_200_000,
      location: 'Austin, TX',
      passed_hard_filters: true,
      scraped_at: new Date().toISOString(),
    });

    // Mirror the user-data.js query
    const { data: scans } = await supabase
      .from('deal_searches')
      .select('id')
      .eq('user_email', TEST_EMAIL);
    const scanIds = scans.map(s => s.id);

    const { data: deals } = await supabase
      .from('deals')
      .select('id, title, search_id')
      .in('search_id', scanIds)
      .eq('passed_hard_filters', true);

    const titles = deals.map(d => d.title);
    expect(titles).not.toContain('Union Pre-Warm Deal');

    // Cleanup
    await supabase.from('deals').delete().eq('search_id', systemSearch.id);
    await supabase.from('deal_searches').delete().eq('id', systemSearch.id);
  });
```

- [ ] **Step 2: Run the test**

Run: `npm test -- tests/integration/user-data-isolation.test.js`
Expected: PASS.

- [ ] **Step 3: Commit**

```bash
git add tests/integration/user-data-isolation.test.js
git commit -m "test: regression guard — union-scraped deals never reach a user"
```

---

### Phase 4 acceptance check

- [ ] **Verify Phase 4 outcome**

1. The Supabase query in Task 4.1 Step 2 ran successfully and confirmed union deals are not attached to real user emails
2. `npm test` includes the new regression test and PASSES
3. No code in `api/` was changed — this phase only added a guard

---

## Phase 5: End-to-end verification

**Outcome:** Walk through the full user journey on a deployed environment (preview or production) and confirm the new contract holds: buy box → real scan → personalized deals.

### Task 5.1: Manual end-to-end test

**Files:** None (verification only)

- [ ] **Step 1: Pick a test user email** (e.g., `e2e-test-{date}@dealhound.dev`)

- [ ] **Step 2: Submit a buy box via the chat interface**

Use the dashboard chat to capture a buy box with specific criteria (e.g., "Texas boutique hotels under $2M with revenue").

Verify in the Network tab the `/api/chat` SSE stream emits `{ type: 'buy_box_saved', search_id, buy_box }` — note the absence of `pool_match_count`.

- [ ] **Step 3: Verify a `scrape_jobs` row was inserted**

Use the Supabase MCP:

```sql
SELECT search_id, status, buy_box, created_at
FROM scrape_jobs
WHERE search_id = '<the-search-id-from-step-2>';
```

Expected: One row, `status='pending'`.

- [ ] **Step 4: Verify `deal_searches.status='scanning'`**

```sql
SELECT id, status FROM deal_searches WHERE id = '<the-search-id>';
```

Expected: `status='scanning'`.

- [ ] **Step 5: Wait for the worker to pick up the job**

The PM2 worker polls every 60s. Within ~2 minutes, watch the dashboard scan-progress UI advance through phases (`init`, `queued`, then skill-driven phases like `discover`, `scrape`, `score`).

If the worker doesn't pick up the job, `pm2 logs worker` on the Mac Pro will surface the issue.

- [ ] **Step 6: After scan completes, verify deals were inserted**

```sql
SELECT COUNT(*), MIN(score_breakdown->>'priority_score')
FROM deals
WHERE search_id = '<the-search-id>';
```

Expected: A non-zero count, and `score_breakdown` contains the strategy-match shape (per `~/skills/find-deals/scoring-rubric.md`).

- [ ] **Step 7: Verify the dashboard shows those deals — and only those**

Refresh the dashboard. Open the Network tab and inspect the `/api/user-data` response. Every `deal.search_id` in the response must equal the `search_id` from Step 2 (or another `search_id` belonging to this user).

If any deal has a `search_id` that doesn't belong to this user, Phase 2 wasn't fully effective — surface it.

- [ ] **Step 8: Verify scoring is personalized to this user's buy box**

Open one or two deals and inspect `score_breakdown.qualitative_match` (or whatever the rubric currently emits). The scoring narrative should reference this user's buy box criteria, not a union/superset.

This is the proof that "the skill is the product" works as intended: the skill ran against this user's specific search_id, scored against their specific buy_box, and the dashboard shows the result.

- [ ] **Step 9: Cleanup test data**

```sql
DELETE FROM deals WHERE search_id = '<the-search-id>';
DELETE FROM scan_progress WHERE search_id = '<the-search-id>';
DELETE FROM scrape_jobs WHERE search_id = '<the-search-id>';
DELETE FROM deal_searches WHERE id = '<the-search-id>';
DELETE FROM users WHERE email = 'e2e-test-{date}@dealhound.dev';
```

---

### Task 5.2: Final acceptance check

- [ ] **Verify all goals from the plan**

1. ✅ A user saves a new buy box → an actual scan ALWAYS runs (no bypass)
2. ✅ Dashboard shows ONLY deals scored against that user's buy box (no union-scored, no pool-filtered)
3. ✅ Deleting `api/_lib/location.js` doesn't break anything
4. ✅ Existing tests still pass; new integration tests cover the new contract
5. ✅ Total LOC in `api/` went DOWN

- [ ] **Run the LOC delta**

Compare to the start of the plan:

```bash
git log --stat $(git merge-base HEAD main)..HEAD -- api/ | tail -5
```

Expected: Net negative line count in `api/`. The new `api/_lib/scan-trigger.js` is small (~25 lines); deleted bypass + overlay + location.js is ~120 lines. Net: ~-95 lines.

---

## Out-of-scope (explicitly not done in this plan)

These remain follow-up work, tracked in `docs/superpowers/plans/2026-05-01-improve-search-quality.md`:

- Granular buy box capture (free-text strategy nuance)
- Tier grouping in the dashboard (HOT / STRONG / WATCH)
- Card UI improvements (priority score, mitigation surface)
- Always-on scan debrief
- LLM eval suite
- Worker queue depth view

This plan is **purely about deletion**: removing the bolt-on layers so the skill's output reaches the user unmodified. The above improvements layer cleanly on top of a clean architecture; they would have been built on quicksand otherwise.
