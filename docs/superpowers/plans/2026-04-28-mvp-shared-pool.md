# DealHound MVP -- Shared Pool Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** When a new user signs up and defines their buy box, they instantly see scored deals from the daily shared pool that match their criteria. No scan button, no 30-minute wait.

**Architecture:** Sophie's daily cron builds a pool of scored deals in Supabase. When a user defines their buy box via the onboarding chat, the `save_buy_box` tool creates a `deal_searches` record AND queries the existing pool for matching deals. The dashboard shows results immediately. The "scan" concept becomes invisible -- deals are always fresh from this morning's run.

**Tech Stack:** Vercel serverless (Node.js), Supabase (PostgreSQL), Preact dashboard (existing).

---

## What Exists

| Component | Status | Notes |
|-----------|--------|-------|
| Onboarding chat | Working | Claude-powered buy box intake with `save_buy_box` tool in `api/chat.js` |
| `save_buy_box` tool | Working | Creates `deal_searches` record with buy box JSONB |
| Dashboard sidebar | Working | Groups deals by tier (HOT/STRONG/WATCH), star/archive/view |
| Deal chat | Working | Claude analyzes individual deals |
| Scan debrief | Working | Claude summarizes scan results |
| Daily cron | Working | Sophie runs /find-deals at 6am CT, produces ~50 scored deals |
| `user-data.js` | Working | Returns deals by `user_email` + `search_id` |
| `scan-start.js` | Working | Writes to `scrape_jobs` queue (but on-demand scan takes 10-30 min) |

## What's Wrong for MVP

1. **New users see 0 deals until a scan completes.** After onboarding, `scan-start.js` fires, Sophie picks up the job, skill runs 10-30 min. User stares at an empty dashboard.

2. **Deals are siloed by search_id.** `user-data.js` only returns deals from searches owned by the logged-in user. The daily cron's 50 deals are under Gideon's email. A new user can't see them.

3. **Scan button is the wrong UX.** Users don't want to "run a scan." They want to see deals. The scan is an implementation detail.

## What MVP Looks Like

```
User signs up → onboarding chat → defines buy box → "Here are your deals"
                                                       ↓
                                          Instant results from today's pool
                                          filtered by the user's buy box
```

No scan button. No waiting. Deals appear the moment the buy box is confirmed.

Behind the scenes, the daily cron keeps the pool fresh. New locations from new users get added to the next day's cron run.

---

## File Structure

### Modified files

| File | What changes |
|------|-------------|
| `api/chat.js` | `save_buy_box` tool: after saving, query shared pool for matching deals and link them to the user's search |
| `api/user-data.js` | Also return deals from the latest shared pool scan that match the user's buy box |
| `api/scan-start.js` | Remove or repurpose -- on-demand scan becomes optional, not the primary flow |

### New files

None. This is a behavior change in existing files, not new infrastructure.

---

## Task 1: Query Shared Pool After Buy Box Save

When the `save_buy_box` tool fires in `api/chat.js`, it currently creates a `deal_searches` record and triggers `scan-start`. Instead, it should:

1. Create the `deal_searches` record (keep this)
2. Find the most recent daily scan with deals
3. Copy matching deals from that scan to the user's search_id
4. Skip the scan-start call entirely

**Files:**
- Modify: `/Users/gideonspencer/dealhound-pro/api/chat.js`

- [ ] **Step 1: Read the current save_buy_box handler**

In `api/chat.js`, find where `save_buy_box` tool use is handled. It should be after the Claude API call, in the tool_use response handling.

- [ ] **Step 2: Find the tool handling code**

```bash
cd /Users/gideonspencer/dealhound-pro && grep -n "save_buy_box" api/chat.js
```

- [ ] **Step 3: Add shared pool query after buy box save**

After the `deal_searches` INSERT, add this logic:

```javascript
// Find the most recent daily scan that has scored deals.
// The daily cron always creates a deal_searches record (skill Step 0).
// Just grab the most recent one that isn't the user's new record.
const { data: latestPool } = await supabase
  .from('deals')
  .select('search_id')
  .eq('passed_hard_filters', true)
  .not('search_id', 'eq', searchRecord.id)
  .order('scraped_at', { ascending: false })
  .limit(1);

const bestPoolId = latestPool?.[0]?.search_id || null;

if (bestPoolId && bestCount > 0) {
  // Copy matching deals from the pool to this user's search
  const { data: poolDeals } = await supabase
    .from('deals')
    .select('*')
    .eq('search_id', bestPoolId)
    .eq('passed_hard_filters', true);

  // Filter by user's buy box
  const bb = buyBoxData; // from the tool input
  const matching = (poolDeals || []).filter(deal => {
    // Price filter
    if (deal.price && bb.price_max && deal.price > bb.price_max) return false;
    if (deal.price && bb.price_min && deal.price < bb.price_min) return false;
    // Location filter (loose match -- check if deal location contains any buy box location keyword)
    if (bb.locations && bb.locations.length > 0 && deal.location) {
      const dealLoc = deal.location.toLowerCase();
      const locationMatch = bb.locations.some(loc => {
        const locLower = loc.toLowerCase();
        return dealLoc.includes(locLower) || locLower === 'us' || locLower === 'usa' || locLower === 'nationwide';
      });
      if (!locationMatch) return false;
    }
    return true;
  });

  if (matching.length > 0) {
    // Insert copies linked to the user's search_id
    const copies = matching.map(d => ({
      search_id: searchRecord.id,
      source: d.source,
      url: d.url,
      source_url: d.source_url,
      title: d.title,
      price: d.price,
      acreage: d.acreage,
      location: d.location,
      address: d.address,
      property_type: d.property_type,
      rooms_keys: d.rooms_keys,
      score: d.score,
      score_breakdown: d.score_breakdown,
      brief: d.brief,
      raw_description: d.raw_description,
      days_on_market: d.days_on_market,
      passed_hard_filters: true,
      scraped_at: d.scraped_at,
      also_listed_on: d.also_listed_on || [],
      possible_duplicate: d.possible_duplicate || false,
    }));

    // Insert in batches
    for (let i = 0; i < copies.length; i += 50) {
      await supabase.from('deals').insert(copies.slice(i, i + 50));
    }
  }

  // Mark search as complete (deals are ready)
  await supabase
    .from('deal_searches')
    .update({ status: 'complete' })
    .eq('id', searchRecord.id);

  // Return match count so Claude can tell the user
  poolMatchCount = matching.length;
} else {
  poolMatchCount = 0;
}

// Use poolMatchCount in the tool result sent back to Claude:
// "Buy box saved. Found 23 deals from today's scan that match."
// or "Buy box saved. No deals match yet -- results will be ready by tomorrow morning."
```

- [ ] **Step 4: Remove the scan-start trigger from the chat frontend**

In `dashboard/src/components/Chat.jsx`, the `buybox-saved` event handler calls `/api/scan-start`. Remove that fetch call. The buy box save now immediately produces deals.

Find this code (~line 57-65):
```javascript
try {
  await fetch('/api/scan-start', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ search_id })
  });
} catch { /* scan-start may not be fully wired yet */ }
```

Replace with nothing -- just remove the fetch. The `loadUserData()` call right after will pick up the deals that were just copied from the pool.

- [ ] **Step 5: Update the Chat.jsx buybox-saved handler**

The handler should still switch to scan view after saving, but now it shows deals immediately:

```javascript
const handler = async (e) => {
  const { search_id } = e.detail;
  const msgs = [...chatMessages.value];
  msgs.push({ role: 'system', content: 'Buy box saved. Loading your deals...' });
  chatMessages.value = msgs;

  await loadUserData();
  view.value = 'scan';
  await switchThread(search_id, 'scan', null);
};
```

- [ ] **Step 6: Verify syntax**

```bash
cd /Users/gideonspencer/dealhound-pro && node --check api/chat.js && echo "OK"
```

- [ ] **Step 7: Build the dashboard**

```bash
cd /Users/gideonspencer/dealhound-pro/dashboard && npm run build
```

- [ ] **Step 8: Commit**

```bash
git add api/chat.js dashboard/
git commit -m "feat: instant deals from shared pool after buy box save

When a user defines their buy box, query the most recent daily scan
for matching deals and copy them to the user's search. No 30-minute
wait. Deals appear immediately after onboarding."
```

---

## Task 2: Make user-data.js Show Shared Pool Deals

Right now `user-data.js` only returns deals from searches where `user_email` matches the logged-in user. For MVP, it should also check the latest shared pool and return matching deals even if the user hasn't run their own scan.

**Files:**
- Modify: `/Users/gideonspencer/dealhound-pro/api/user-data.js`

- [ ] **Step 1: Read current user-data.js**

Understand the current query flow (already read above -- it queries `deal_searches` by email, then `deals` by search_ids).

- [ ] **Step 2: This is already handled by Task 1**

Task 1 copies matching deals from the shared pool into the user's own `deal_searches` record. `user-data.js` already queries by `user_email` and returns deals from those searches. Since the copied deals are linked to the user's search_id, they show up automatically.

No changes needed to `user-data.js`. Task 1's copy approach means the existing query path works.

- [ ] **Step 3: Verify by checking the query flow**

After Task 1 is implemented, a new user's flow:
1. Onboarding chat -> save_buy_box -> creates deal_searches with user's email
2. save_buy_box also copies matching deals from daily pool into user's search
3. deal_searches.status = 'complete'
4. Dashboard calls user-data.js -> queries deal_searches by email -> finds the record -> queries deals by search_id -> finds the copied deals
5. Deals appear in sidebar

Skip this task -- mark as not needed.

---

## Task 3: (Merged into Task 1)

The `poolMatchCount` variable from Task 1 feeds into the tool result message that Claude receives. When Claude sees "Found 23 deals", it naturally tells the user. No separate task needed.

---

## Task 4: Add User's Locations to Daily Cron Pool

When a new user defines locations the daily cron doesn't cover, those locations should be added to the next day's scan. The daily cron currently uses the hardcoded buy-box.md. It should also check Supabase for all active user locations.

**Files:**
- Modify: `/Users/gideonspencer/sophie/pipelines/daily-scrape.js`

- [ ] **Step 1: Read all active user buy boxes before running the skill**

Before invoking `/find-deals full`, query Supabase for all unique locations across active buy boxes:

```javascript
async function run() {
  console.log('[Sophie] Daily scrape: collecting locations from all users...');

  // Gather all unique locations from user buy boxes
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

  // Pass locations to the skill via prompt override
  const prompt = allLocations.size > 0
    ? `/find-deals full -- in ${locationStr}`
    : '/find-deals full';

  // ... rest of the run() function
```

Note: this uses the natural-language override for the daily cron (acceptable since the daily cron is Gideon's scan, not a user-facing on-demand scan). The on-demand path uses the structured DEALHOUND_BUY_BOX_FILE env var.

- [ ] **Step 2: Commit**

```bash
cd /Users/gideonspencer/sophie
git add pipelines/daily-scrape.js
git commit -m "feat: daily cron covers all user locations, not just default buy box"
```

---

## Task 5: Deploy and Test End-to-End

- [ ] **Step 1: Build dashboard**

```bash
cd /Users/gideonspencer/dealhound-pro/dashboard && npm run build
```

- [ ] **Step 2: Deploy Vercel**

```bash
cd /Users/gideonspencer/dealhound-pro && vercel --prod --yes
```

- [ ] **Step 3: Test the new user flow**

1. Open the dashboard in a browser
2. Enter a NEW email (not gideon@stonemontcap.com)
3. Go through onboarding: define buy box for Texas, micro resorts, $300k-$3M
4. After confirming, deals should appear IMMEDIATELY (from this morning's pool)
5. Verify the chat says "Found X deals" not "Starting your scan"
6. Click on deals in the sidebar, verify deal cards show tier/price/location
7. Click into a deal, verify deal chat works

- [ ] **Step 4: Verify data in Supabase**

```sql
-- New user should have a deal_searches record with status='complete'
SELECT id, user_email, status FROM deal_searches
WHERE user_email = 'NEW_TEST_EMAIL' ORDER BY run_at DESC LIMIT 1;

-- And deals linked to it
SELECT count(*) FROM deals
WHERE search_id = 'SEARCH_ID_FROM_ABOVE' AND passed_hard_filters = true;
```

- [ ] **Step 5: Commit any fixes**

```bash
git add -A
git commit -m "fix: MVP testing fixes"
```

---

## What MVP Does NOT Include

| Item | Why deferred |
|------|-------------|
| On-demand scan button | Daily pool covers MVP; scan button is a future feature for new locations |
| DEALHOUND_BUY_BOX_FILE structured override | Daily cron handles deal sourcing; on-demand per-user scraping is post-MVP |
| Multi-user buy box in daily cron via env var | Task 4 handles location expansion via prompt; structured env var is post-MVP |
| Push notifications / email digest | Users check the dashboard; notifications are post-MVP |
| User auth (passwords, OAuth) | Email gate is sufficient for MVP |
| Payment / billing | Free for initial users |
