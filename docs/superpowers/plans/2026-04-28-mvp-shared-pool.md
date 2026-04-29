# DealHound MVP -- Shared Pool Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** When a new user signs up and defines their buy box, they instantly see scored deals from the daily shared pool that match their criteria. If the pool is empty, an on-demand scan fires automatically. The user never knows a pool exists. It feels like their personal agent found the deals.

**Architecture:** Sophie's daily cron builds a pool of scored deals in Supabase. `user-data.js` queries the pool filtered by the user's buy box (shared pool query, not copy). `chat.js` tells Claude the exact deal count at onboarding. If 0 matches, falls back to on-demand scan via `scrape_jobs` queue. URL dedup prevents day-over-day duplicate listings.

**Tech Stack:** Vercel serverless (Node.js), Supabase (PostgreSQL), Preact dashboard (existing).

---

## Key Decisions (from eng review)

- **Shared pool query, not copy.** `user-data.js` queries the pool at read time instead of copying deals into each user's search_id. Avoids linear row growth (50 deals x 100 users = 5,000 redundant rows).
- **URL dedup.** Day-over-day duplicates filtered by URL in `user-data.js`. Cross-source dedup within a day already handled by the skill's three-tier dedup.
- **Exact count with dedup in chat.js.** Run the same dedup logic when counting pool matches so Claude's "Found 23 deals" matches exactly what the sidebar shows.
- **Invisible fallback.** If pool is empty, auto-trigger on-demand scan. User sees "I'm scanning the market for you now" not "No pool available."
- **Agent framing.** User never knows a shared pool exists. It feels like their personal agent found the deals.

---

## Data Flow

```
User defines buy box
        |
        v
chat.js save_buy_box handler
  ├── Save deal_searches record
  ├── Query pool for matching deals (price + location filter)
  ├── Apply URL dedup (same logic as user-data.js)
  ├── Count > 0?
  │   ├── YES: Tell Claude "Found N deals" → mark status='complete'
  │   └── NO:  Write scrape_jobs row → tell Claude "Scanning now, ~20 min"
  └── Return to Claude for response
        |
        v
Dashboard loads → user-data.js
  ├── Fetch user's own deals (by user_email + search_id)
  ├── Fetch pool deals (latest scored deals, filtered by user's buy box)
  ├── URL dedup pool against user's own
  └── Return combined set → sidebar shows deals
```

---

## Task 1: Add Shared Pool Query to user-data.js

`user-data.js` currently returns deals only from searches owned by the logged-in user. Add a pool query that also returns deals from the latest daily scan, filtered by the user's buy box.

**Files:**
- Modify: `/Users/gideonspencer/dealhound-pro/api/user-data.js`

- [ ] **Step 1: Read user-data.js and locate the deals query**

The current flow (lines 55-88): query `deal_searches` by email → get search_ids → query `deals` by search_ids.

- [ ] **Step 2: Add pool query after the existing deals query**

After `deals` are fetched (line 88), add:

```javascript
// Shared pool: also show deals from the latest daily scan matching user's buy box
let poolDeals = [];
const latestBuyBox = (scans || []).find(s => s.buy_box)?.buy_box;

if (latestBuyBox) {
  // Find the most recent pool scan (any search_id with scored deals, not owned by this user)
  const { data: poolCandidates } = await supabase
    .from('deals')
    .select('search_id')
    .eq('passed_hard_filters', true)
    .not('search_id', 'in', `(${scanIds.map(id => `"${id}"`).join(',')})`)
    .order('scraped_at', { ascending: false })
    .limit(1);

  const poolSearchId = poolCandidates?.[0]?.search_id;

  if (poolSearchId) {
    const { data: rawPoolDeals } = await supabase
      .from('deals')
      .select('id, title, location, price, acreage, rooms_keys, score_breakdown, source, url, search_id, passed_hard_filters, brief, days_on_market, property_type, raw_description')
      .eq('search_id', poolSearchId)
      .eq('passed_hard_filters', true);

    // Filter by user's buy box
    const priceMax = latestBuyBox.price_max;
    const priceMin = latestBuyBox.price_min;
    const locations = (latestBuyBox.locations || []).map(l => l.toLowerCase());

    poolDeals = (rawPoolDeals || []).filter(d => {
      if (d.price && priceMax && Number(d.price) > priceMax) return false;
      if (d.price && priceMin && Number(d.price) < priceMin) return false;
      if (locations.length > 0 && d.location) {
        const dealLoc = d.location.toLowerCase();
        const locMatch = locations.some(loc =>
          dealLoc.includes(loc) || loc === 'us' || loc === 'usa' || loc === 'nationwide'
        );
        if (!locMatch) return false;
      }
      return true;
    });

    // URL dedup: remove pool deals that already appear in user's own deals
    const userUrls = new Set(deals.map(d => d.url).filter(Boolean));
    poolDeals = poolDeals.filter(d => !d.url || !userUrls.has(d.url));
  }
}

// Merge: user's own deals first, then pool deals
deals = [...deals, ...poolDeals];
```

- [ ] **Step 3: Update the star/view/archive logic to handle pool deals**

The existing code (lines 91-122) builds `starredIds`, `viewedIds`, `archivedIds` from the user's deal IDs. Pool deal IDs won't be in these sets (user hasn't interacted with them yet). This is correct behavior -- pool deals show as unviewed/unstarred by default.

No change needed. The existing code handles this naturally.

- [ ] **Step 4: Verify syntax**

```bash
cd /Users/gideonspencer/dealhound-pro && node --check api/user-data.js && echo "OK"
```

- [ ] **Step 5: Commit**

```bash
git add api/user-data.js
git commit -m "feat: user-data.js queries shared pool deals filtered by buy box

Adds pool query: finds latest daily scan with scored deals, filters
by user's buy box (price + location), dedupes by URL against user's
own deals. Users see pool deals alongside their own."
```

---

## Task 2: Add Pool Count + Fallback to chat.js save_buy_box

After saving the buy box, query the pool for a count of matching deals. If matches exist, tell Claude the count. If no matches, trigger an on-demand scan.

**Files:**
- Modify: `/Users/gideonspencer/dealhound-pro/api/chat.js`

- [ ] **Step 1: Read chat.js and locate the save_buy_box handler**

Lines 225-263. After the `deal_searches` INSERT succeeds (line 254), add pool logic.

- [ ] **Step 2: Add pool count query and fallback**

After `search` is created (line 249) and before the SSE event is sent (line 255), add:

```javascript
// Query shared pool for matching deals
let poolMatchCount = 0;

// Find latest pool scan
const { data: poolCandidates } = await supabase
  .from('deals')
  .select('search_id')
  .eq('passed_hard_filters', true)
  .order('scraped_at', { ascending: false })
  .limit(1);

const poolSearchId = poolCandidates?.[0]?.search_id;

if (poolSearchId) {
  const { data: rawPoolDeals } = await supabase
    .from('deals')
    .select('url, price, location')
    .eq('search_id', poolSearchId)
    .eq('passed_hard_filters', true);

  const priceMax = buyBox.price_max;
  const priceMin = buyBox.price_min;
  const locations = (buyBox.locations || []).map(l => l.toLowerCase());

  const matching = (rawPoolDeals || []).filter(d => {
    if (d.price && priceMax && Number(d.price) > priceMax) return false;
    if (d.price && priceMin && Number(d.price) < priceMin) return false;
    if (locations.length > 0 && d.location) {
      const dealLoc = d.location.toLowerCase();
      const locMatch = locations.some(loc =>
        dealLoc.includes(loc) || loc === 'us' || loc === 'usa' || loc === 'nationwide'
      );
      if (!locMatch) return false;
    }
    return true;
  });

  poolMatchCount = matching.length;
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
```

- [ ] **Step 3: Update the tool result message**

Change the SSE event to include the pool match count so Claude knows what to say:

```javascript
res.write(`data: ${JSON.stringify({
  type: 'buy_box_saved',
  search_id: search.id,
  buy_box: buyBox,
  pool_match_count: poolMatchCount,
})}\n\n`);
```

Also send a follow-up tool_result to Claude so it can respond appropriately. After the tool handling block, add a second Claude call with the tool result:

```javascript
// Continue the conversation with tool result
const toolResultContent = poolMatchCount > 0
  ? `Buy box saved successfully. Found ${poolMatchCount} deals from today's market scan that match the investor's criteria. They can see them in their dashboard now. Present 2-3 of the strongest matches and ask which one they want to explore first.`
  : `Buy box saved successfully. No deals from today's scan match these exact criteria yet. I've started a fresh scan that will find deals in about 20 minutes. The investor will see results appear in their dashboard shortly.`;
```

- [ ] **Step 4: Remove scan-start trigger from Chat.jsx**

In `dashboard/src/components/Chat.jsx`, find the `buybox-saved` event handler (~line 53-73). Remove the `scan-start` fetch (lines 59-65). Change the system message:

```javascript
const handler = async (e) => {
  const { search_id, pool_match_count } = e.detail;
  const msgs = [...chatMessages.value];

  if (pool_match_count > 0) {
    msgs.push({ role: 'system', content: 'Buy box saved. Loading your deals...' });
  } else {
    msgs.push({ role: 'system', content: 'Buy box saved. Your agent is scanning the market...' });
  }
  chatMessages.value = msgs;

  await loadUserData();
  view.value = 'scan';
  await switchThread(search_id, 'scan', null);
};
```

- [ ] **Step 5: Verify syntax**

```bash
cd /Users/gideonspencer/dealhound-pro && node --check api/chat.js && echo "chat OK"
```

- [ ] **Step 6: Build dashboard**

```bash
cd /Users/gideonspencer/dealhound-pro/dashboard && npm run build
```

- [ ] **Step 7: Commit**

```bash
git add api/chat.js dashboard/
git commit -m "feat: instant pool deals + on-demand fallback after buy box save

Pool has deals: tell Claude the count, mark complete, user sees deals.
Pool empty: auto-trigger on-demand scan, user sees 'scanning for you.'
User never knows a pool exists -- feels like a personal agent."
```

---

## Task 3: Daily Cron Location Expansion

The daily cron currently uses the default buy-box.md locations. It should also cover all user locations from Supabase.

**Files:**
- Modify: `/Users/gideonspencer/sophie/pipelines/daily-scrape.js`

- [ ] **Step 1: Add Supabase location query before skill invocation**

At the top of `run()`, before calling `runClaude`, query all user buy boxes:

```javascript
async function run() {
  console.log('[Sophie] Daily scrape: collecting locations from all users...');

  const { createClient } = require('@supabase/supabase-js');
  const sb = createClient(
    process.env.SUPABASE_DEALS_URL || process.env.SUPABASE_URL,
    process.env.SUPABASE_DEALS_ANON_KEY || process.env.SUPABASE_SERVICE_KEY
  );

  const { data: searches } = await sb
    .from('deal_searches')
    .select('buy_box')
    .not('buy_box', 'is', null);

  const allLocations = new Set();
  for (const s of (searches || [])) {
    const locs = s.buy_box?.locations || [];
    locs.forEach(l => allLocations.add(l));
  }

  const locationStr = [...allLocations].join(', ') || 'Texas';
  console.log(`[Sophie] Daily scrape locations: ${locationStr}`);
  memory.appendToDailyNote(`Daily scrape pipeline: starting /find-deals full for ${locationStr}`);

  const prompt = allLocations.size > 0
    ? `/find-deals full -- in ${locationStr}`
    : '/find-deals full';

  const startTime = Date.now();

  try {
    const { output } = await runClaude(prompt);
    // ... rest unchanged
```

- [ ] **Step 2: Commit**

```bash
cd /Users/gideonspencer/sophie
git add pipelines/daily-scrape.js
git commit -m "feat: daily cron covers all user locations from Supabase"
```

---

## Task 4: URL Dedup Unit Test

Test that pool deals are correctly deduped against user's own deals by URL.

**Files:**
- Create: `/Users/gideonspencer/dealhound-pro/tests/unit/pool-dedup.test.js`

- [ ] **Step 1: Write the test**

```javascript
import { describe, it, expect } from 'vitest';

// Extract the dedup logic into a testable function
function dedupPoolDeals(userDeals, poolDeals) {
  const userUrls = new Set(userDeals.map(d => d.url).filter(Boolean));
  return poolDeals.filter(d => !d.url || !userUrls.has(d.url));
}

describe('pool deal dedup', () => {
  it('removes pool deals with URLs matching user deals', () => {
    const userDeals = [
      { id: '1', url: 'https://rvparkstore.com/listing/123', title: 'RV Park A' },
      { id: '2', url: 'https://campground-marketplace.com/456', title: 'Camp B' },
    ];
    const poolDeals = [
      { id: '3', url: 'https://rvparkstore.com/listing/123', title: 'RV Park A' }, // dupe
      { id: '4', url: 'https://rvparkstore.com/listing/789', title: 'RV Park C' }, // unique
      { id: '5', url: 'https://campground-marketplace.com/456', title: 'Camp B' }, // dupe
    ];

    const result = dedupPoolDeals(userDeals, poolDeals);
    expect(result).toHaveLength(1);
    expect(result[0].id).toBe('4');
  });

  it('keeps pool deals with null URLs', () => {
    const userDeals = [{ id: '1', url: 'https://example.com/1' }];
    const poolDeals = [{ id: '2', url: null, title: 'No URL Deal' }];

    const result = dedupPoolDeals(userDeals, poolDeals);
    expect(result).toHaveLength(1);
  });

  it('returns all pool deals when user has no deals', () => {
    const poolDeals = [
      { id: '1', url: 'https://example.com/1' },
      { id: '2', url: 'https://example.com/2' },
    ];

    const result = dedupPoolDeals([], poolDeals);
    expect(result).toHaveLength(2);
  });

  it('handles day-over-day duplicates (same URL different days)', () => {
    // Monday pool deal already in user's deals from a previous scan
    const userDeals = [
      { id: '1', url: 'https://rvparkstore.com/listing/123', title: 'Park A (Monday)' },
    ];
    // Tuesday pool has same listing
    const poolDeals = [
      { id: '2', url: 'https://rvparkstore.com/listing/123', title: 'Park A (Tuesday)' },
      { id: '3', url: 'https://rvparkstore.com/listing/456', title: 'Park B (new)' },
    ];

    const result = dedupPoolDeals(userDeals, poolDeals);
    expect(result).toHaveLength(1);
    expect(result[0].title).toBe('Park B (new)');
  });
});
```

- [ ] **Step 2: Run test**

```bash
cd /Users/gideonspencer/dealhound-pro && npx vitest run tests/unit/pool-dedup.test.js
```

Expected: All 4 tests pass.

- [ ] **Step 3: Commit**

```bash
git add tests/unit/pool-dedup.test.js
git commit -m "test: URL dedup for shared pool deals across daily scans"
```

---

## Task 5: Deploy and E2E Test

- [ ] **Step 1: Build dashboard**

```bash
cd /Users/gideonspencer/dealhound-pro/dashboard && npm run build
```

- [ ] **Step 2: Deploy Vercel**

```bash
cd /Users/gideonspencer/dealhound-pro && vercel --prod --yes
```

- [ ] **Step 3: Test new user flow (pool has deals)**

1. Open dashboard in browser
2. Enter a NEW email (not gideon@stonemontcap.com)
3. Go through onboarding: define buy box for Texas, micro resorts, $300k-$3M
4. After confirming, Claude should say "Found X deals" (instant, from pool)
5. Deals should appear in sidebar grouped by tier
6. Click a deal -- deal chat should work

- [ ] **Step 4: Test empty pool fallback**

1. Enter another new email
2. Define buy box for a location NOT in the pool (e.g., "Alaska")
3. Claude should say "I'm scanning the market for you now"
4. Check `scrape_jobs` table -- a pending row should appear
5. Sophie should pick it up within 60s

- [ ] **Step 5: Commit any fixes**

```bash
git add -A
git commit -m "fix: MVP E2E testing fixes"
```

---

## What MVP Does NOT Include

| Item | Why deferred |
|------|-------------|
| Buy box edit/update flow | V1 users define once, iterate in future |
| Location normalization | Free-text matching is good enough for MVP markets |
| Daily cron location cap | <10 users, <10 locations, not a problem yet |
| Cross-pool-vs-user dedup beyond URL | Cross-source dedup within a day handled by skill |
| Push notifications / email digest | Users check the dashboard |
| User auth (passwords, OAuth) | Email gate is sufficient |
| Payment / billing | Free for initial users |

## GSTACK REVIEW REPORT

| Review | Trigger | Why | Runs | Status | Findings |
|--------|---------|-----|------|--------|----------|
| CEO Review | `/plan-ceo-review` | Scope & strategy | 0 | -- | -- |
| Codex Review | `/codex review` | Independent 2nd opinion | 0 | -- | -- |
| Eng Review | `/plan-eng-review` | Architecture & tests (required) | 1 | CLEAR (PLAN) | 7 issues, 0 critical gaps |
| Design Review | `/plan-design-review` | UI/UX gaps | 0 | -- | -- |
| DX Review | `/plan-devex-review` | Developer experience gaps | 0 | -- | -- |

- **OUTSIDE VOICE:** Claude subagent found 8 issues. 2 addressed (#3 count mismatch, #6 empty pool fallback). Rest deferred as post-MVP.
- **UNRESOLVED:** 0
- **VERDICT:** ENG CLEARED -- ready to implement
