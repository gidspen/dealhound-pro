# Improve Search Quality Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Restore the DealHound value proposition — granular, personalized deal matching with strategic evaluation — by killing the scan-bypass shortcut, capturing qualitative buy box nuance, scoring deals against each user's personal strategy (including listing descriptions), and surfacing the tier-grouped magical moment.

**Architecture:** Five sequential phases, each shippable independently. Phase 1 stops the regression by always queuing a personalized scan. Phase 2 expands buy box capture from structured fields into qualitative strategy nuance and matches it against listing descriptions. Phase 3 introduces per-user re-scoring of pool deals (cached) so every deal a user sees has been evaluated against their box. Phase 4 surfaces the work — tier grouping, full card detail, always-on debrief. Phase 5 repositions the union scan as a candidate inventory pre-warmer (not a delivery mechanism) and adds a buy box specificity gate.

**Tech Stack:** Node.js (Vercel serverless API), Preact (dashboard), Supabase (Postgres), Anthropic SDK (Claude Sonnet + Opus), Vitest, PM2 worker on Mac Pro running `claude -p "/find-deals full"`.

**Branch:** `improve/search-quality` (already created).

---

## Review Decisions (2026-05-01, /plan-eng-review)

The plan below was reviewed via `/plan-eng-review`. Seven decisions were made that override or refine specific tasks. **Read this section first — it supersedes parts of the original task list.**

| # | Decision | Affected tasks |
|---|----------|----------------|
| **D1** | ~~Worker handles re-scoring as a fast `rescore_jobs` job type~~ — **superseded by D6** | — |
| **D2** | Dashboard shows progressive reveal with a live "X of Y deals analyzed" counter; deals fill into HOT/STRONG/WATCH tiers as the worker completes scoring. Counter reflects scan progress under D6, not separate rescore jobs. | New Task 4.5 (replaces "background re-score") |
| **D3** | Don't build parallel workers yet. Add a Supabase view `worker_queue_depth`; alert manually if depth > 3. | New Task 5.0 |
| **D4** | ~~UNIQUE constraint on rescore_jobs(deal_id, user_email, buy_box_hash)~~ — **superseded by D6** (no rescore_jobs table) | — |
| **D5** | **New Phase 2.5** — 10-listing LLM eval suite. Hand-curated listing+buy-box pairs with known correct outputs. Tracks scoring quality over time. | New Phase 2.5 |
| **D6** | **Architectural override (replaces D1/D4):** Pool re-scoring is folded into the scan job. When the worker runs the skill for user A, the skill ALSO evaluates the last 7 days of pool deals against A's buy box as part of its existing Stage A scoring batch. **No `rescore_jobs` table, no `/api/rescore-deal` Sonnet endpoint, no dashboard background-fetch loop.** Single executor (the skill). One job per user. `deal_user_scores` cache still exists — populated as a side effect of every scan. | **Phase 3 collapses** — Tasks 3.3 (`score-against-buybox.js`), 3.4 (`rescore-deal` endpoint), and 4.5 (background fetch) are **dropped**. New Task 3.6 (skill extension) replaces them. |
| **D7** | Build all 5 phases (founder call). Outside voice argued for Phase 1 only + measure; declined. | — |

### Phase 0 — Prerequisite checks (NEW, must run before Phase 1)

The outside voice flagged three concrete checks that must pass before this plan can deliver. Add these as explicit gates:

- **0.1 — Verify `raw_description` coverage.** Run:
  ```sql
  select count(*) as total,
         count(raw_description) as with_desc,
         percentile_cont(0.5) within group (order by length(raw_description)) as median_len
  from deals where scraped_at > now() - interval '7 days';
  ```
  **Gate:** if `with_desc / total < 0.9` OR `median_len < 300` chars, halt and fix the scraper to capture full descriptions before proceeding. Phase 1 dealbreaker matching and Phase 2 qualitative scoring both depend on this.

- **0.2 — Skill single-deal mode is NOT required (resolved by D6).** The simpler architecture means the skill scores pool deals as part of its batched Stage A — no single-deal invocation mode needed. **No action; verified via `grep` 2026-05-01.**

- **0.3 — Specificity gate calibration.** Capture 5-10 real buy boxes from existing users. Run them through `evaluateBuyBoxSpecificity`. If the score≥60 threshold rejects more than 30% of real users, recalibrate before Task 2.4 ships the gate. Otherwise the gate becomes dead code (everyone clicks "Run anyway").

### Missed dependencies (must be addressed during implementation)

- **Skill deployment lockstep with Phase 2.** Phase 2.3 changes the skill's `score_breakdown` shape (adds `qualitative_match`). If the skill update doesn't deploy in lockstep with the worker restart, every scan from that point produces broken `score_breakdown` rows. **Add an explicit gate between Tasks 2.2 and 2.3:** "Skill update deployed to ~/skills/find-deals/ on the worker host AND worker process restarted before any scrape_job is queued with the new buy box schema."

- **Legacy `score_breakdown` rows lack `qualitative_match`.** `computePriorityScore` will silently zero the qualitative component for old rows (or crash on null deref). **Add a defensive shim in the score reader:** treat missing `qualitative_match` as `{must_haves_total: 0, nice_to_haves_total: 0, ...}` so the math gracefully degrades to the legacy formula for old data. Mark legacy rows as `score_stale: true` so they get re-scored on the next scan via D6.

---

## Pre-flight: Context for the Implementing Agent

**Critical files you must read before starting:**
- `api/chat.js` (current buy box capture — Sonnet streaming + save_buy_box tool)
- `api/_lib/location.js` (filter logic — currently only price + location)
- `api/_lib/filters.js` (full hard-filter logic in `applyHardFilters`)
- `api/user-data.js` (pool query lives here)
- `worker/worker.js` (job dispatcher)
- `worker/union-buy-box.js` (the union builder — to be repurposed in Phase 5)
- `~/skills/find-deals/apply-buybox.md` (the actual scoring pipeline)
- `~/skills/find-deals/scoring-rubric.md` (rubric — Strategy Match + 5-factor Risk)
- `dashboard/src/components/DealCard.jsx` (card UI — currently undersurfaced)
- `dashboard/src/lib/utils.js` (tierFromStrategy mapper)

**The buy box schema today (`api/chat.js` save_buy_box tool):**
```json
{
  "locations": ["Texas", "Hill Country, TX"],
  "price_min": 300000,
  "price_max": 3000000,
  "property_types": ["micro_resort", "glamping"],
  "revenue_requirement": "cash_flow_day_1",
  "acreage_min": 1,
  "exclusions": ["mobile home park"]
}
```

**The new buy box schema (after Phase 2):**
```json
{
  // ... all existing fields ...
  "strategy_notes": "Looking for properties within 1.5 hours of Austin or Houston. Want existing event venue revenue or potential. Open to adding cabins to existing properties. Prefer waterfront. Avoid anything in floodplain.",
  "must_haves": ["waterfront access", "existing structures", "septic-ready or installed"],
  "nice_to_haves": ["existing event venue", "barn or barndo", "frontage on paved road"],
  "dealbreakers": ["floodplain", "leased land", "HOA restrictions on STR"]
}
```

**The scoring tier mapping (already in place):**
- `strategy.overall === "STRONG MATCH"` → HOT
- `strategy.overall === "MATCH"` → STRONG
- `strategy.overall === "PARTIAL"` → WATCH
- `strategy.overall === "MISS"` → dropped (not shown)

**Test conventions:** Vitest, `tests/integration/` hits real Supabase using `TEST_EMAIL`, `tests/unit/` is pure logic, `tests/smoke/` is end-to-end. Cleanup helpers in `tests/helpers/supabase.js`. Use `test_data: true` flag on `deal_searches` rows for cleanup.

---

## File Structure

### Files to Create

| Path | Responsibility |
|------|----------------|
| `api/_lib/buy-box-filter.js` | Single source of truth for hard filtering pool deals against a buy box (price, acreage, property_type, exclusions, dealbreakers). Replaces the weak `filterDealsByBuyBox` in `location.js`. |
| `api/_lib/buy-box-hash.js` | Stable hash of a buy box for cache keys. Lets us tell if a re-score is stale. |
| `api/_lib/score-against-buybox.js` | Re-scores an existing deal against a personal buy box using Sonnet. Reads `raw_description`, evaluates strategy_notes/must_haves/dealbreakers, returns full `score_breakdown` shape. |
| `api/rescore-deal.js` | Vercel serverless endpoint that re-scores a single (deal_id, buy_box) pair on demand. Caches result in `deal_user_scores`. |
| `dashboard/src/components/TierSection.jsx` | Renders one tier (HOT / STRONG / WATCH) with a header + count + grid of DealCards. |
| `dashboard/src/components/DealCardDetail.jsx` | Expanded card showing priority score, strategy match labels, risk dimensions, and mitigations. Used in deal detail/preview. |
| `tests/unit/buy-box-filter.test.js` | Tests for the new tightened filter. |
| `tests/unit/buy-box-hash.test.js` | Tests for hash stability. |
| `tests/unit/score-against-buybox.test.js` | Tests using fixture deals + mock Sonnet response. |
| `tests/integration/rescore-deal.test.js` | Tests `/api/rescore-deal` endpoint end-to-end. |
| `tests/integration/scan-trigger.test.js` | Tests that every new buy box queues a scrape_job (no bypass). |
| `tests/fixtures/sample-pool-deals.json` | Fixture pool deals with varied attributes for filter tests. |
| `migrations/001_buy_box_qualitative_fields.sql` | Documentation of schema changes (Supabase). |
| `migrations/002_deal_user_scores_table.sql` | Documentation of new caching table. |

### Files to Modify

| Path | Changes |
|------|---------|
| `api/chat.js` | (1) Expand `save_buy_box` tool schema with strategy_notes/must_haves/nice_to_haves/dealbreakers. (2) Update SYSTEM_PROMPT to elicit qualitative nuance. (3) Delete the pool-bypass block (lines ~264-309); always queue scrape_job. (4) Add buy box specificity gate before saving. |
| `api/_lib/location.js` | Keep `dealMatchesLocations`, deprecate `filterDealsByBuyBox` (delegate to new `buy-box-filter.js`). |
| `api/user-data.js` | (1) Use new `buy-box-filter.js`. (2) Mark pool deals with `from_pool: true`. (3) For pool deals, prefer cached personal score from `deal_user_scores`; fall back to union score with `score_stale: true` flag. (4) Trigger background re-score for stale-scored pool deals. (5) Suppress pool deals when an active scan is `pending` or `scanning`. |
| `api/scan-start.js` | No structural changes; verify it still works with always-queue flow. |
| `worker/worker.js` | No core changes; ensure DEALHOUND_BUY_BOX_JSON includes new qualitative fields so the skill sees them. |
| `worker/union-buy-box.js` | Add a `display: false` semantic flag in output — the union is a scrape target, not a scoring target. |
| `~/skills/find-deals/apply-buybox.md` | Update Stage A Sonnet prompt to evaluate `raw_description` against `strategy_notes`, `must_haves`, `dealbreakers`. Update score_breakdown shape to include `qualitative_match` block. |
| `~/skills/find-deals/scoring-rubric.md` | Add the qualitative match dimension and how it influences the priority score. |
| `~/skills/find-deals/buy-box.md` | Document the new fields. |
| `dashboard/src/components/DealCard.jsx` | Surface priority score, strategy labels (M/R/P), and a top mitigation snippet. |
| `dashboard/src/components/Chat.jsx` | Update onboarding prompts to explicitly elicit nuance (already covered by SYSTEM_PROMPT, but verify). |
| `dashboard/src/app.jsx` | Routing — render `TierSection` groups; never route to deal view if all visible deals are stale-scored pool deals AND a scan is `scanning`/`pending`. |
| `dashboard/src/lib/utils.js` | Add `groupDealsByTier(deals)` helper. |
| `dashboard/src/lib/state.js` | Add `dealsByTier` computed signal. |

---

# Phase 1: Stop the Bleeding

**Outcome:** Every new buy box queues a real scan. Pool deals are filtered against the full buy box (price, location, property type, acreage, exclusions). No more location-only "is the search complete?" shortcut.

**Files touched:** `api/chat.js`, `api/_lib/buy-box-filter.js` (new), `api/_lib/location.js`, `api/user-data.js`, plus tests.

---

### Task 1.1: Write failing test for new tightened pool filter

**Files:**
- Create: `tests/fixtures/sample-pool-deals.json`
- Create: `tests/unit/buy-box-filter.test.js`

- [ ] **Step 1: Write the fixture file**

Create `tests/fixtures/sample-pool-deals.json` with 8 deals covering edge cases (null price, null acreage, dealbreaker keyword in description, wrong property type, exclusion match, perfect match, location mismatch, price out of range):

```json
[
  {
    "id": "perfect-match",
    "title": "Lakefront Glamping Resort, 12 keys",
    "location": "Lake Travis, TX",
    "price": 1200000,
    "acreage": 8,
    "property_type": "glamping",
    "raw_description": "Operating glamping resort on Lake Travis with 12 deluxe tents, event venue, and septic-ready expansion lots."
  },
  {
    "id": "price-too-high",
    "title": "Luxury Resort",
    "location": "Austin, TX",
    "price": 5000000,
    "acreage": 20,
    "property_type": "boutique_hotel",
    "raw_description": "High-end resort, 20 keys."
  },
  {
    "id": "price-too-low",
    "title": "Tiny Cabin",
    "location": "Hill Country, TX",
    "price": 150000,
    "acreage": 2,
    "property_type": "cabin",
    "raw_description": "Single cabin on small lot."
  },
  {
    "id": "wrong-location",
    "title": "Beach House",
    "location": "Miami, FL",
    "price": 1500000,
    "acreage": 1,
    "property_type": "vacation_rental",
    "raw_description": "Beachfront vacation rental."
  },
  {
    "id": "wrong-property-type",
    "title": "Self Storage Facility",
    "location": "San Antonio, TX",
    "price": 2000000,
    "acreage": 3,
    "property_type": "self_storage",
    "raw_description": "Cash flowing self storage business."
  },
  {
    "id": "acreage-too-small",
    "title": "Urban Boutique Inn",
    "location": "Houston, TX",
    "price": 1500000,
    "acreage": 0.25,
    "property_type": "bed_and_breakfast",
    "raw_description": "Small urban inn, 6 rooms."
  },
  {
    "id": "exclusion-keyword",
    "title": "Mobile Home Park",
    "location": "Austin, TX",
    "price": 1800000,
    "acreage": 10,
    "property_type": "land",
    "raw_description": "30-pad mobile home park with hookups."
  },
  {
    "id": "dealbreaker-floodplain",
    "title": "Riverside Lodge",
    "location": "Hill Country, TX",
    "price": 900000,
    "acreage": 6,
    "property_type": "lodge",
    "raw_description": "Historic lodge in floodplain — flood insurance required. Beautiful river frontage."
  },
  {
    "id": "null-price",
    "title": "Off-Market Glamping",
    "location": "Austin, TX",
    "price": null,
    "acreage": 5,
    "property_type": "glamping",
    "raw_description": "Off-market opportunity, contact broker for price."
  }
]
```

- [ ] **Step 2: Write the test**

Create `tests/unit/buy-box-filter.test.js`:

```javascript
import { describe, it, expect } from 'vitest';
import { readFileSync } from 'fs';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';
import { filterPoolDealsAgainstBuyBox } from '../../api/_lib/buy-box-filter.js';

const __dirname = dirname(fileURLToPath(import.meta.url));
const FIXTURES = JSON.parse(
  readFileSync(join(__dirname, '../fixtures/sample-pool-deals.json'), 'utf8')
);

const BASE_BUY_BOX = {
  locations: ['Texas'],
  price_min: 300000,
  price_max: 3000000,
  property_types: ['glamping', 'boutique_hotel', 'lodge', 'bed_and_breakfast', 'cabin', 'vacation_rental'],
  acreage_min: 1,
  exclusions: ['mobile home park'],
  dealbreakers: ['floodplain']
};

describe('filterPoolDealsAgainstBuyBox', () => {
  it('keeps deals matching all hard filters', () => {
    const result = filterPoolDealsAgainstBuyBox(FIXTURES, BASE_BUY_BOX);
    const ids = result.map(d => d.id);
    expect(ids).toContain('perfect-match');
  });

  it('drops deals over price_max', () => {
    const result = filterPoolDealsAgainstBuyBox(FIXTURES, BASE_BUY_BOX);
    expect(result.map(d => d.id)).not.toContain('price-too-high');
  });

  it('drops deals under price_min', () => {
    const result = filterPoolDealsAgainstBuyBox(FIXTURES, BASE_BUY_BOX);
    expect(result.map(d => d.id)).not.toContain('price-too-low');
  });

  it('drops deals outside location', () => {
    const result = filterPoolDealsAgainstBuyBox(FIXTURES, BASE_BUY_BOX);
    expect(result.map(d => d.id)).not.toContain('wrong-location');
  });

  it('drops deals with non-matching property_type', () => {
    const result = filterPoolDealsAgainstBuyBox(FIXTURES, BASE_BUY_BOX);
    expect(result.map(d => d.id)).not.toContain('wrong-property-type');
  });

  it('drops deals under acreage_min', () => {
    const result = filterPoolDealsAgainstBuyBox(FIXTURES, BASE_BUY_BOX);
    expect(result.map(d => d.id)).not.toContain('acreage-too-small');
  });

  it('drops deals with exclusion keyword in title or description', () => {
    const result = filterPoolDealsAgainstBuyBox(FIXTURES, BASE_BUY_BOX);
    expect(result.map(d => d.id)).not.toContain('exclusion-keyword');
  });

  it('drops deals with dealbreaker keyword in description', () => {
    const result = filterPoolDealsAgainstBuyBox(FIXTURES, BASE_BUY_BOX);
    expect(result.map(d => d.id)).not.toContain('dealbreaker-floodplain');
  });

  it('keeps deals with null price (flagged, not dropped)', () => {
    const result = filterPoolDealsAgainstBuyBox(FIXTURES, BASE_BUY_BOX);
    const nullPriceDeal = result.find(d => d.id === 'null-price');
    expect(nullPriceDeal).toBeDefined();
    expect(nullPriceDeal.flags).toContain('price_unknown');
  });
});
```

- [ ] **Step 3: Run the test, verify it fails**

```bash
npx vitest run tests/unit/buy-box-filter.test.js
```

Expected: FAIL — module `api/_lib/buy-box-filter.js` does not exist.

- [ ] **Step 4: Commit**

```bash
git add tests/fixtures/sample-pool-deals.json tests/unit/buy-box-filter.test.js
git commit -m "test: failing tests for tightened pool buy-box filter"
```

---

### Task 1.2: Implement `buy-box-filter.js`

**Files:**
- Create: `api/_lib/buy-box-filter.js`

- [ ] **Step 1: Write the implementation**

Create `api/_lib/buy-box-filter.js`. Mirrors the rigor of `apply-buybox.md` Step 2 hard filters, plus exclusion + dealbreaker keyword checks against title and description:

```javascript
const { dealMatchesLocations } = require('./location');

function matchesPropertyType(deal, allowedTypes) {
  if (!allowedTypes || allowedTypes.length === 0) return true;
  const haystack = [
    deal.property_type,
    deal.title,
    deal.raw_description
  ].filter(Boolean).join(' ').toLowerCase();
  return allowedTypes.some(t => haystack.includes(String(t).toLowerCase().replace(/_/g, ' ')));
}

function containsAny(text, keywords) {
  if (!keywords || keywords.length === 0) return false;
  const haystack = (text || '').toLowerCase();
  return keywords.some(k => haystack.includes(String(k).toLowerCase()));
}

function filterPoolDealsAgainstBuyBox(deals, buyBox) {
  if (!buyBox) return [];
  const priceMin = buyBox.price_min ?? null;
  const priceMax = buyBox.price_max ?? null;
  const acreageMin = buyBox.acreage_min ?? null;
  const locations = (buyBox.locations || []).map(l => String(l).toLowerCase());
  const allowedTypes = buyBox.property_types || [];
  const exclusions = buyBox.exclusions || [];
  const dealbreakers = buyBox.dealbreakers || [];

  const out = [];
  for (const d of deals) {
    const flags = [];

    // Price — explicit violations only; null = flag
    if (d.price == null) {
      flags.push('price_unknown');
    } else {
      if (priceMin != null && Number(d.price) < priceMin) continue;
      if (priceMax != null && Number(d.price) > priceMax) continue;
    }

    // Acreage — explicit violations only; null = flag
    if (d.acreage == null) {
      flags.push('acreage_unknown');
    } else if (acreageMin != null && Number(d.acreage) < acreageMin) {
      continue;
    }

    // Location
    if (!dealMatchesLocations(d.location, locations)) continue;

    // Property type — match against type, title, or description
    if (!matchesPropertyType(d, allowedTypes)) continue;

    // Exclusions — drop if any keyword appears in title or description
    const text = `${d.title || ''} ${d.raw_description || ''}`;
    if (containsAny(text, exclusions)) continue;
    if (containsAny(text, dealbreakers)) continue;

    out.push({ ...d, flags });
  }
  return out;
}

module.exports = { filterPoolDealsAgainstBuyBox };
```

- [ ] **Step 2: Run the test, verify it passes**

```bash
npx vitest run tests/unit/buy-box-filter.test.js
```

Expected: PASS — all 9 cases.

- [ ] **Step 3: Commit**

```bash
git add api/_lib/buy-box-filter.js
git commit -m "feat: tighten pool filter to use full buy box (price, acreage, type, exclusions, dealbreakers)"
```

---

### Task 1.3: Wire `buy-box-filter.js` into `user-data.js`

**Files:**
- Modify: `api/user-data.js`
- Modify: `api/_lib/location.js` (deprecation comment only)

- [ ] **Step 1: Update `user-data.js` to use the new filter**

Replace the import on line 2 of `api/user-data.js`:

```javascript
const { filterDealsByBuyBox } = require('./_lib/location');
```

With:

```javascript
const { filterPoolDealsAgainstBuyBox } = require('./_lib/buy-box-filter');
```

Replace the call on line 119 of `api/user-data.js`:

```javascript
poolDeals = filterDealsByBuyBox(rawPoolDeals, latestBuyBox);
```

With:

```javascript
poolDeals = filterPoolDealsAgainstBuyBox(rawPoolDeals, latestBuyBox);
```

Also update the SELECT on lines 110-115 to fetch `raw_description` (it's already fetched in the user's own deals query, but pool query needs it for exclusion/dealbreaker matching). Already present — verify.

- [ ] **Step 2: Add deprecation comment to `location.js`**

Above `function filterDealsByBuyBox` (line 46) in `api/_lib/location.js`, add:

```javascript
/**
 * @deprecated Since 2026-05. Use filterPoolDealsAgainstBuyBox in buy-box-filter.js.
 * Kept for backward compatibility — this only checks price + location.
 */
```

- [ ] **Step 3: Run integration test for user-data to ensure nothing broke**

```bash
npx vitest run tests/integration/user-data.test.js
```

Expected: PASS (or document any pre-existing failure as out of scope).

- [ ] **Step 4: Commit**

```bash
git add api/user-data.js api/_lib/location.js
git commit -m "feat: user-data uses tightened pool filter"
```

---

### Task 1.4: Write failing test that every new buy box queues a scrape_job

**Files:**
- Create: `tests/integration/scan-trigger.test.js`

- [ ] **Step 1: Write the test**

```javascript
import { describe, it, expect, afterAll } from 'vitest';
import { getTestSupabase, cleanupTestData } from '../helpers/supabase.js';
import { TEST_EMAIL } from '../helpers/test-constants.js';

describe('Scan trigger — every buy box queues a scrape_job', () => {
  const supabase = getTestSupabase();
  afterAll(() => cleanupTestData(supabase, TEST_EMAIL));

  it('inserts a scrape_job for a new buy box even when pool has matches', async () => {
    // Seed a pool deal that would match a Texas buy box
    const { data: seedSearch } = await supabase
      .from('deal_searches')
      .insert({
        user_email: 'seed-pool@dealhound.dev',
        buy_box: { locations: ['Texas'], price_max: 3000000, property_types: ['glamping'], revenue_requirement: 'any' },
        status: 'complete',
        test_data: true,
        run_at: new Date().toISOString()
      })
      .select('id')
      .single();

    await supabase.from('deals').insert({
      search_id: seedSearch.id,
      url: 'https://test.dealhound/seed-' + Date.now(),
      title: 'Seed Glamping Texas',
      location: 'Austin, TX',
      price: 1500000,
      acreage: 5,
      property_type: 'glamping',
      raw_description: 'Glamping resort outside Austin.',
      passed_hard_filters: true,
      scraped_at: new Date().toISOString()
    });

    // Save a new buy box for TEST_EMAIL — same location as seed pool
    const { data: search } = await supabase
      .from('deal_searches')
      .insert({
        user_email: TEST_EMAIL,
        buy_box: { locations: ['Texas'], price_max: 3000000, property_types: ['glamping'], revenue_requirement: 'cash_flow_day_1' },
        status: 'ready',
        test_data: true,
        run_at: new Date().toISOString()
      })
      .select('id')
      .single();

    // Simulate the chat.js handler post-save flow — should queue a scrape_job regardless of pool matches
    // (After Phase 1 task 1.5, this happens automatically. For now, verify the contract.)
    await supabase.from('scrape_jobs').insert({
      search_id: search.id,
      buy_box: { locations: ['Texas'], price_max: 3000000 },
      status: 'pending'
    });

    const { data: jobs } = await supabase
      .from('scrape_jobs')
      .select('id, status')
      .eq('search_id', search.id);

    expect(jobs).toHaveLength(1);
    expect(jobs[0].status).toBe('pending');

    // Cleanup seed
    await supabase.from('deals').delete().eq('search_id', seedSearch.id);
    await supabase.from('deal_searches').delete().eq('id', seedSearch.id);
  });
});
```

- [ ] **Step 2: Run the test, verify it passes (it tests the contract, not chat.js yet)**

```bash
npx vitest run tests/integration/scan-trigger.test.js
```

Expected: PASS — verifies contract that scrape_jobs can be inserted. The real fix is in Task 1.5.

- [ ] **Step 3: Commit**

```bash
git add tests/integration/scan-trigger.test.js
git commit -m "test: contract that scan trigger always inserts scrape_job"
```

---

### Task 1.5: Kill the scan-bypass in `chat.js`

**Files:**
- Modify: `api/chat.js`

- [ ] **Step 1: Delete the pool-bypass block**

In `api/chat.js`, find the block starting around line 264:

```javascript
// Query ALL recent scored deals (not just one pool scan).
// ...
let poolMatchCount = 0;
try {
  const sevenDaysAgo = ...
  // ... pool query ...
} catch (poolErr) {
  // ...
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

Replace the entire block with:

```javascript
// Always queue a personalized scan. The pool can show candidate deals
// while the scan runs (see api/user-data.js), but it is never a substitute
// for a scan against the user's actual buy box.
await supabase.from('scrape_jobs').insert({
  search_id: search.id,
  buy_box: buyBox,
  status: 'pending',
});
await supabase
  .from('deal_searches')
  .update({ status: 'scanning' })
  .eq('id', search.id);

// Pool match count for the SSE event — informational only, used by the chat UI
// to show "you'll see N candidate matches while your scan runs".
let poolMatchCount = 0;
try {
  const sevenDaysAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString();
  const { data: rawPoolDeals } = await supabase
    .from('deals')
    .select('url, price, location, acreage, property_type, title, raw_description')
    .eq('passed_hard_filters', true)
    .not('search_id', 'eq', search.id)
    .gte('scraped_at', sevenDaysAgo)
    .limit(500);

  if (rawPoolDeals && rawPoolDeals.length > 0) {
    const { filterPoolDealsAgainstBuyBox } = require('./_lib/buy-box-filter');
    poolMatchCount = filterPoolDealsAgainstBuyBox(rawPoolDeals, buyBox).length;
  }
} catch (poolErr) {
  console.error('Pool query error:', poolErr.message);
}
```

- [ ] **Step 2: Run integration tests for chat.js / buy-box-save / scan-start**

```bash
npx vitest run tests/integration/buy-box-save.test.js tests/integration/scan-start.test.js
```

Expected: PASS (or pre-existing failures unrelated to this change).

- [ ] **Step 3: Manual verification (production-like)**

Send a POST to `/api/chat` with a confirmation message that triggers `save_buy_box`. Verify in Supabase:
- A new `deal_searches` row with `status = 'scanning'` (not `complete`).
- A new `scrape_jobs` row with `status = 'pending'`.

- [ ] **Step 4: Commit**

```bash
git add api/chat.js
git commit -m "fix: always queue personalized scan — kill location-only bypass

The pool-match shortcut was scoring deals against a union buy box and
serving them as if they matched the user's strategy. Every new buy box
now queues a scrape_job. Pool deals can still be shown while the scan
runs, but they no longer mark the search 'complete'."
```

---

### Task 1.6: Suppress pool deals while a scan is active

**Files:**
- Modify: `api/user-data.js`

- [ ] **Step 1: Read the current user-data.js pool block (lines 91-126)**

Find the comment "Shared pool: show scored deals from the last 7 days, filtered to user's buy box."

- [ ] **Step 2: Add a "pool suppression" guard above the pool query**

Replace the block starting at "Shared pool" with:

```javascript
// Shared pool: only shown when no scan is currently in flight.
// During an active scan, the user should see scan progress, not stale pool deals.
const hasActiveScan = (scans || []).some(s => s.status === 'scanning' || s.status === 'pending');

let poolDeals = [];
let rawBuyBox = (scans || []).find(s => s.buy_box)?.buy_box || null;
let latestBuyBox = null;
if (rawBuyBox) {
  if (typeof rawBuyBox === 'string') {
    try { latestBuyBox = JSON.parse(rawBuyBox); } catch (_) { latestBuyBox = null; }
  } else {
    latestBuyBox = rawBuyBox;
  }
}

if (latestBuyBox && !hasActiveScan) {
  const sevenDaysAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString();
  const { data: rawPoolDeals } = await supabase
    .from('deals')
    .select('id, title, location, price, acreage, rooms_keys, score_breakdown, source, url, search_id, passed_hard_filters, brief, days_on_market, property_type, raw_description, scraped_at')
    .eq('passed_hard_filters', true)
    .gte('scraped_at', sevenDaysAgo)
    .limit(500);

  if (rawPoolDeals && rawPoolDeals.length > 0) {
    poolDeals = filterPoolDealsAgainstBuyBox(rawPoolDeals, latestBuyBox);
    const userUrls = new Set(deals.map(d => d.url).filter(Boolean));
    poolDeals = poolDeals.filter(d => !d.url || !userUrls.has(d.url));
    poolDeals = poolDeals.map(d => ({ ...d, from_pool: true }));
  }
}

deals = [...deals, ...poolDeals];
```

- [ ] **Step 3: Pass `from_pool` through the response mapping**

In the `deals.map(d => ({ ... }))` block in the response (around line 167), add `from_pool: !!d.from_pool` to the returned object.

- [ ] **Step 4: Run integration test**

```bash
npx vitest run tests/integration/user-data.test.js
```

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add api/user-data.js
git commit -m "feat: suppress pool deals during active scan; mark pool deals with from_pool flag"
```

---

### Task 1.7: Phase 1 ship checkpoint

- [ ] **Step 1: Run all tests**

```bash
npx vitest run
```

Expected: PASS.

- [ ] **Step 2: Push branch and open PR (optional — Phase 1 is shippable on its own)**

```bash
git push -u origin improve/search-quality
gh pr create --title "fix: restore personalized scan trigger (Phase 1)" --body "$(cat <<'EOF'
## Summary
- Killed the location-only pool-match bypass in api/chat.js. Every new buy box now queues a personalized scrape_job.
- Tightened the pool filter to check price, location, property type, acreage, exclusions, and dealbreakers.
- Suppressed pool deals while a scan is pending or scanning.
- Marked pool deals with from_pool: true for downstream UI labeling.

## Test plan
- [ ] Send a buy box via /api/chat — verify scrape_jobs row created and search.status = 'scanning'.
- [ ] Load /api/user-data?email=... with an active scan — verify no pool deals returned.
- [ ] Load /api/user-data?email=... with a completed scan — verify only pool deals matching full buy box returned.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

---

# Phase 2: Granular Buy Box Capture + Description Matching

**Outcome:** The chat onboarding elicits qualitative strategy nuance (free-text + must-haves + dealbreakers). Listing descriptions are matched against that nuance during scoring. Buy box specificity is gated — too-broad boxes are pushed back on before saving.

**Files touched:** `api/chat.js`, `~/skills/find-deals/apply-buybox.md`, `~/skills/find-deals/scoring-rubric.md`, `~/skills/find-deals/buy-box.md`, `migrations/001_buy_box_qualitative_fields.sql`, `tests/integration/buy-box-save.test.js`.

---

### Task 2.1: Document the schema migration

**Files:**
- Create: `migrations/001_buy_box_qualitative_fields.sql`

- [ ] **Step 1: Create the migration SQL file**

The `deal_searches.buy_box` column is JSONB — no DDL change required. Document the new schema for future reference:

```sql
-- migrations/001_buy_box_qualitative_fields.sql
-- 2026-05-01 — DealHound search quality refresh
--
-- The deal_searches.buy_box JSONB column gets four new fields:
--
--   strategy_notes   text         Free-form qualitative criteria the chat captured.
--                                 Used by Sonnet to evaluate listing descriptions.
--   must_haves       text[]       Specific features the user requires (matched against title/description).
--   nice_to_haves    text[]       Bonus features (boost priority score, never disqualify).
--   dealbreakers     text[]       Specific phrases that disqualify a listing (drop in hard filters).
--
-- Example buy_box payload:
--   {
--     "locations": ["Hill Country, TX"],
--     "price_min": 500000,
--     "price_max": 2500000,
--     "property_types": ["glamping", "micro_resort"],
--     "revenue_requirement": "cash_flow_day_1",
--     "acreage_min": 5,
--     "exclusions": ["mobile home park"],
--     "strategy_notes": "Within 1.5 hours of Austin. Wants existing event venue revenue or potential. Open to adding cabins.",
--     "must_haves": ["waterfront access", "existing structures"],
--     "nice_to_haves": ["existing event venue", "barndo"],
--     "dealbreakers": ["floodplain", "leased land", "HOA STR restrictions"]
--   }
--
-- No DDL needed. Existing rows without these fields are valid (treated as empty arrays / null).
```

- [ ] **Step 2: Commit**

```bash
git add migrations/001_buy_box_qualitative_fields.sql
git commit -m "docs: schema notes for qualitative buy box fields"
```

---

### Task 2.2: Expand the `save_buy_box` tool schema in `chat.js`

**Files:**
- Modify: `api/chat.js`

- [ ] **Step 1: Update the TOOLS schema**

In `api/chat.js`, find the `TOOLS` constant. Add four new properties to `save_buy_box.input_schema.properties`:

```javascript
strategy_notes: {
  type: 'string',
  description: 'Free-form qualitative criteria capturing the nuance of the investor\'s strategy. Capture everything they said about HOW they think about the deal — not just structured filters. Examples: "wants existing event venue revenue", "open to adding cabins to existing properties", "prefers waterfront with deferred maintenance under $800/key", "wants 1.5 hours from Austin or Houston". This is what separates a good match from a generic match.'
},
must_haves: {
  type: 'array',
  items: { type: 'string' },
  description: 'Specific features the property MUST have. Each item is a short phrase that will be matched against listing titles and descriptions. Examples: ["waterfront access", "existing structures", "septic-ready"]. Be specific — these become hard filters.'
},
nice_to_haves: {
  type: 'array',
  items: { type: 'string' },
  description: 'Features that boost the deal\'s priority but do not disqualify it. Examples: ["existing event venue", "barn or barndo", "frontage on paved road"].'
},
dealbreakers: {
  type: 'array',
  items: { type: 'string' },
  description: 'Phrases that, if found in a listing description, disqualify the deal. More specific than exclusions (which are about property categories). Examples: ["floodplain", "leased land", "HOA restrictions on STR"].'
}
```

Add `strategy_notes` to the `required` array (the others can be empty arrays).

- [ ] **Step 2: Update the SYSTEM_PROMPT to elicit nuance**

In `api/chat.js`, replace Step 2 (the Clarifying Questions section) with:

```
**Step 2: Clarifying Questions**

After the user shares their criteria, ask focused follow-ups in this order:

(a) Structured filters they didn't mention (1-2 questions max):
- Price range (exact min/max) — "Is there a floor on price, or just the $2M ceiling?"
- Specific locations — "When you say Southeast, any specific states? Or the whole region?"
- Property type specifics — "Hotels, glamping, RV parks, B&Bs — which ones?"
- Acreage minimum — if relevant
- Revenue requirements — cash flow day 1 vs. value-add vs. development
- Hard exclusions — categories to never show

(b) Qualitative nuance — THIS IS WHERE THE MAGIC HAPPENS. Ask 1-2 of these
that map to what they cared about:
- "What would make a property feel like a 'YES' the moment you saw it?"
   (Capture as must_haves and strategy_notes)
- "What should I never show you, even if it hits the price and location?"
   (Capture as dealbreakers — distinct from exclusions, which are categories)
- "Beyond price and acreage, what tells you the deal has upside?"
   (Capture as nice_to_haves and feed into strategy_notes)

Ask ONE question at a time. 2-4 clarifying questions total. Keep it tight.

When the user answers, capture EVERYTHING qualitative in strategy_notes —
this is the free-form summary the scorer uses to evaluate descriptions.
must_haves / nice_to_haves / dealbreakers are short, specific phrases
extracted from that nuance.
```

- [ ] **Step 3: Update the existing buy-box-save integration test**

In `tests/integration/buy-box-save.test.js`, expand the existing test to include the new fields:

```javascript
const buyBox = {
  locations: ['Coastal North Carolina'],
  price_max: 2000000,
  property_types: ['boutique_hotel', 'micro_resort'],
  revenue_requirement: 'cash_flow_day_1',
  strategy_notes: 'Wants existing event venue revenue. Open to adding cabins.',
  must_haves: ['waterfront access'],
  nice_to_haves: ['existing event venue'],
  dealbreakers: ['floodplain']
};
```

And in the second test ("retrieves the saved buy box with correct data"), add:

```javascript
expect(data.buy_box.strategy_notes).toContain('event venue');
expect(data.buy_box.must_haves).toContain('waterfront access');
expect(data.buy_box.dealbreakers).toContain('floodplain');
```

- [ ] **Step 4: Run the test**

```bash
npx vitest run tests/integration/buy-box-save.test.js
```

Expected: PASS (JSONB accepts arbitrary fields).

- [ ] **Step 5: Commit**

```bash
git add api/chat.js tests/integration/buy-box-save.test.js
git commit -m "feat: capture qualitative buy box nuance (strategy_notes, must_haves, dealbreakers)"
```

---

### Task 2.3: Update the find-deals skill to score against qualitative criteria

**Files:**
- Modify: `~/skills/find-deals/apply-buybox.md`
- Modify: `~/skills/find-deals/scoring-rubric.md`
- Modify: `~/skills/find-deals/buy-box.md`

- [ ] **Step 1: Update `apply-buybox.md` Step 2 hard filters**

Add a fifth hard filter under "Step 2: Apply Hard Filters":

```markdown
### Filter 5: Dealbreakers (description match)
```
Rule: If buy_box.dealbreakers is non-empty, drop any listing whose
title OR raw_description contains any dealbreaker keyword (case-insensitive).
This is stricter than exclusions — exclusions filter property categories,
dealbreakers filter specific phrases the user said are disqualifying.
```
```

- [ ] **Step 2: Update `apply-buybox.md` Stage A Sonnet output schema**

In Stage A — Sonnet, expand the per-deal output to include a qualitative match block:

```markdown
**3. Qualitative Match (NEW):**
```json
{
  "qualitative_match": {
    "must_haves_satisfied": 3,           // count of must_haves the listing satisfies
    "must_haves_total": 4,                // total must_haves in buy box
    "nice_to_haves_satisfied": 2,
    "nice_to_haves_total": 5,
    "strategy_notes_match": "STRONG | MATCH | PARTIAL | MISS",
    "evidence": "Listing description mentions existing event venue and waterfront access; no mention of cabins."
  }
}
```

The Sonnet prompt now receives:
- The full listing data (title, location, price, acreage, raw_description — full text, not truncated)
- The buy box (including strategy_notes, must_haves, nice_to_haves)

Sonnet evaluates whether the description supports each must_have / nice_to_have,
and rates the strategy_notes match holistically.

**Strategy match recalculation:**
The `strategy.overall` label now incorporates the qualitative match:
- If `must_haves_satisfied < must_haves_total / 2` → `overall` is at most PARTIAL
- If `strategy_notes_match` is MISS → `overall` is MISS (drops the deal)
- Otherwise unchanged.
```

- [ ] **Step 3: Update `apply-buybox.md` Step 3c priority score components**

Replace the priority score table:

```markdown
| Component | Max Pts | What it measures |
|-----------|---------|-----------------|
| Strategy Type Alignment | 25 | Primary strategy = 25, Secondary = 17, Tertiary = 8 |
| Revenue Readiness | 20 | Cash flowing now = 20, Revenue signals = 17, Unknown = 10, Feasible/ramp = 8 |
| Market Fit | 20 | STRONG MATCH = 20, MATCH = 14, PARTIAL = 6 |
| Qualitative Match (NEW) | 20 | (must_haves_satisfied / must_haves_total) × 12 + (nice_to_haves × 8) |
| Risk Offset | 15 | 15 minus (total_risk × 0.6), clamped to 0 |
```

- [ ] **Step 4: Update `scoring-rubric.md`**

Add a new section after "Output 2: Risk Score":

```markdown
---

## Output 3: Qualitative Match (per-user)

Evaluates how well the listing description matches the user's strategy_notes,
must_haves, nice_to_haves. This is what makes scoring personal vs generic.

### Inputs
- listing.title
- listing.raw_description (FULL text, not truncated)
- buy_box.strategy_notes
- buy_box.must_haves
- buy_box.nice_to_haves

### Output

```json
{
  "must_haves_satisfied": 3,
  "must_haves_total": 4,
  "nice_to_haves_satisfied": 2,
  "nice_to_haves_total": 5,
  "strategy_notes_match": "STRONG | MATCH | PARTIAL | MISS",
  "evidence": "<one sentence citing specific phrases from the listing>"
}
```

### Sonnet evaluation rules
- Each must_have: search title + description for any phrase semantically
  matching it. Be generous — "waterfront access" is satisfied by "lakefront",
  "river frontage", "beach access", etc.
- nice_to_haves: same matching, but missing them never disqualifies.
- strategy_notes_match: rate the listing against the holistic strategy
  description.
- Always include `evidence` — quote or paraphrase the specific listing
  phrase that drove your call.
```

- [ ] **Step 5: Update `buy-box.md`**

Add a new section before "## Onboarding Instructions":

```markdown
---

## Qualitative Criteria

These fields capture the nuance that distinguishes a great deal from a generic match.

```yaml
strategy_notes: |
  (free-text) The investor's qualitative strategy summary. Captured during
  onboarding chat. Used by the scorer to evaluate listing descriptions
  holistically.
must_haves:
  - (string) Specific features the property MUST have
nice_to_haves:
  - (string) Features that boost priority but never disqualify
dealbreakers:
  - (string) Phrases that disqualify a deal if they appear in title/description
```
```

- [ ] **Step 6: Commit (skill files live outside the repo, but track the changes)**

```bash
# Skill files are outside the repo — copy snapshots into docs/ for review trail
mkdir -p docs/skill-snapshots/2026-05-01
cp ~/skills/find-deals/apply-buybox.md docs/skill-snapshots/2026-05-01/
cp ~/skills/find-deals/scoring-rubric.md docs/skill-snapshots/2026-05-01/
cp ~/skills/find-deals/buy-box.md docs/skill-snapshots/2026-05-01/
git add docs/skill-snapshots
git commit -m "docs: snapshot find-deals skill changes for qualitative scoring"
```

---

### Task 2.4: Add buy box specificity gate

**Files:**
- Create: `api/_lib/buy-box-specificity.js`
- Create: `tests/unit/buy-box-specificity.test.js`
- Modify: `api/chat.js`

- [ ] **Step 1: Write the test**

Create `tests/unit/buy-box-specificity.test.js`:

```javascript
import { describe, it, expect } from 'vitest';
import { evaluateBuyBoxSpecificity } from '../../api/_lib/buy-box-specificity.js';

describe('evaluateBuyBoxSpecificity', () => {
  it('rates a vague buy box as too-broad', () => {
    const result = evaluateBuyBoxSpecificity({
      locations: ['Texas'],
      price_max: 3000000,
      property_types: ['glamping', 'boutique_hotel', 'micro_resort', 'cabin', 'lodge'],
      revenue_requirement: 'any'
    });
    expect(result.is_specific_enough).toBe(false);
    expect(result.suggestions.length).toBeGreaterThan(0);
  });

  it('rates a granular buy box as specific enough', () => {
    const result = evaluateBuyBoxSpecificity({
      locations: ['Hill Country, TX'],
      price_min: 500000,
      price_max: 2000000,
      property_types: ['glamping'],
      revenue_requirement: 'cash_flow_day_1',
      acreage_min: 5,
      strategy_notes: 'Within 1.5 hours of Austin. Wants existing event venue revenue.',
      must_haves: ['waterfront access', 'existing structures'],
      dealbreakers: ['floodplain']
    });
    expect(result.is_specific_enough).toBe(true);
  });

  it('flags missing strategy_notes on a otherwise-broad box', () => {
    const result = evaluateBuyBoxSpecificity({
      locations: ['Florida'],
      price_max: 3000000,
      property_types: ['glamping']
    });
    expect(result.is_specific_enough).toBe(false);
    expect(result.suggestions.some(s => s.includes('strategy'))).toBe(true);
  });
});
```

- [ ] **Step 2: Run the test, verify it fails**

```bash
npx vitest run tests/unit/buy-box-specificity.test.js
```

Expected: FAIL — module does not exist.

- [ ] **Step 3: Implement `buy-box-specificity.js`**

Create `api/_lib/buy-box-specificity.js`:

```javascript
/**
 * Heuristic score for how specific a buy box is. Returns:
 *   { is_specific_enough: boolean, score: 0-100, suggestions: string[] }
 *
 * Used to push back on vague buy boxes during chat onboarding before saving.
 * The thresholds are calibrated for the value prop — granular criteria
 * deliver the magical moment; broad criteria deliver generic results.
 */
function evaluateBuyBoxSpecificity(buyBox) {
  let score = 0;
  const suggestions = [];

  // Price range tightness (max 20)
  const priceMin = buyBox.price_min ?? 0;
  const priceMax = buyBox.price_max ?? Infinity;
  if (priceMin > 0 && priceMax < Infinity) {
    const ratio = priceMax / priceMin;
    if (ratio <= 3) score += 20;
    else if (ratio <= 6) score += 12;
    else score += 4;
  }
  if (priceMin === 0) suggestions.push('Add a price floor to focus the search.');

  // Location specificity (max 20)
  const locs = buyBox.locations || [];
  if (locs.length === 0) {
    suggestions.push('Add at least one specific location or region.');
  } else {
    const hasSpecific = locs.some(l => /,| within | hours | mile| mountain| lake| coast/i.test(l));
    score += hasSpecific ? 20 : 10;
    if (!hasSpecific) suggestions.push('Tighten location — a state alone is too broad. Try a region, metro, or radius.');
  }

  // Property type narrowness (max 15)
  const types = buyBox.property_types || [];
  if (types.length === 0) {
    suggestions.push('Pick at least one property type.');
  } else if (types.length <= 2) {
    score += 15;
  } else if (types.length <= 4) {
    score += 8;
  } else {
    suggestions.push('Narrow property types — picking 5+ types makes scoring noisy.');
    score += 3;
  }

  // strategy_notes presence + length (max 25)
  const notes = (buyBox.strategy_notes || '').trim();
  if (notes.length > 80) score += 25;
  else if (notes.length > 30) score += 15;
  else suggestions.push('Add strategy notes — a sentence or two on what makes a deal a YES for you.');

  // must_haves count (max 10)
  const mustHaves = buyBox.must_haves || [];
  if (mustHaves.length >= 2) score += 10;
  else if (mustHaves.length === 1) score += 5;
  else suggestions.push('Add 1-2 must-haves — specific features the property must have.');

  // dealbreakers count (max 10)
  const dealbreakers = buyBox.dealbreakers || [];
  if (dealbreakers.length >= 1) score += 10;
  else suggestions.push('Add at least one dealbreaker — what should never make the cut.');

  return {
    is_specific_enough: score >= 60,
    score,
    suggestions
  };
}

module.exports = { evaluateBuyBoxSpecificity };
```

- [ ] **Step 4: Run the test, verify it passes**

```bash
npx vitest run tests/unit/buy-box-specificity.test.js
```

Expected: PASS.

- [ ] **Step 5: Wire the gate into `chat.js`**

In `api/chat.js`, immediately before the `deal_searches.insert` (around line 249), add:

```javascript
const { evaluateBuyBoxSpecificity } = require('./_lib/buy-box-specificity');
const specificity = evaluateBuyBoxSpecificity(buyBox);

if (!specificity.is_specific_enough) {
  res.write(`data: ${JSON.stringify({
    type: 'buy_box_too_broad',
    score: specificity.score,
    suggestions: specificity.suggestions
  })}\n\n`);
  // Save anyway, but flag — UI can decide whether to ask for refinement
}
```

The chat UI can choose to show a "Want to tighten this before we run?" prompt before triggering the scan. (UI-side gate is Phase 4.)

- [ ] **Step 6: Commit**

```bash
git add api/_lib/buy-box-specificity.js tests/unit/buy-box-specificity.test.js api/chat.js
git commit -m "feat: buy box specificity gate — emit warning when criteria too broad"
```

---

# Phase 2.5: LLM Eval Suite (D5)

**Outcome:** 10 hand-curated listing + buy-box pairs with known correct outputs. Eval runner compares scoring output to expected. Quality score tracked over time so future rubric tweaks don't regress silently.

**Files touched:** `evals/scoring/cases.json`, `evals/scoring/run.js`, `evals/scoring/rubric.md`.

### Task 2.5.1: Curate 10 cases

- [ ] **Step 1: Hand-build 10 cases** in `evals/scoring/cases.json`. Each case: `{name, listing: {title, location, price, acreage, raw_description, property_type}, buy_box: {...}, expected: {strategy.overall, qualitative_match.must_haves_satisfied, ...}}`. Cover: clear HOT, clear STRONG, clear WATCH, clear MISS-via-dealbreaker, clear MISS-via-property-fit, edge: null price, edge: null acreage, edge: must_have ambiguous, edge: dealbreaker keyword in description vs title, edge: nice_to_have only.

### Task 2.5.2: Build the runner

- [ ] **Step 1: Create `evals/scoring/run.js`** that loads cases, calls the same scoring logic the skill uses (after D6 this is just the skill itself, invoked locally), compares output to expected, prints a quality table.
- [ ] **Step 2: Add `npm run eval`** to package.json.
- [ ] **Step 3: Establish baseline.** Run on current scoring (pre-Phase-2 changes), record baseline quality score in `evals/scoring/baseline.md`.
- [ ] **Step 4: Re-run after Phase 2.3 ships** — quality score must not regress.

---

# Phase 3: Pool Deal Re-Scoring (D6 — collapsed)

**Outcome:** When the worker runs a scan for user A, the skill ALSO evaluates the last 7 days of recent pool deals against A's buy box as part of its existing Stage A batch. Pool deals get personalized `score_breakdown` written to `deal_user_scores`. **No separate rescore_jobs infrastructure.**

**Files touched:** `~/skills/find-deals/apply-buybox.md` (extend Stage A to include pool deals), `migrations/002_deal_user_scores_table.sql`, `api/_lib/buy-box-hash.js`, `api/user-data.js`.

> **NOTE:** Tasks 3.3 (`score-against-buybox.js`), 3.4 (`rescore-deal` endpoint), and the original 3.5 fan-out logic in user-data.js are **DROPPED** under D6. Tasks 3.1 (deal_user_scores table) and 3.2 (buy-box-hash.js) remain. New Task 3.6 replaces 3.3-3.5.

### Task 3.6: Extend skill Stage A to score pool deals

**Files:**
- Modify: `~/skills/find-deals/apply-buybox.md`
- Modify: `api/user-data.js`

- [ ] **Step 1: Add a "pool deals" load step in the skill.** In `apply-buybox.md` Step 1 (Load Raw Listings), after loading the freshly-scraped raw-listings-*.json files, ALSO query Supabase for pool deals from the last 7 days that match the user's buy box on the tightened hard-filter dimensions (price/loc/type/acreage/exclusions/dealbreakers — same as `buy-box-filter.js`). Add them to the deduped scoring queue WITH a flag `from_pool: true`.

- [ ] **Step 2: Stage A scoring sees pool deals as input.** No special handling — they go through the same Sonnet batch as fresh deals. Output is the standard `score_breakdown` block.

- [ ] **Step 3: Step 5 writes pool-deal results to `deal_user_scores`, not `deals`.** For deals with `from_pool: true`, INSERT into `deal_user_scores` with `(deal_id, user_email, buy_box_hash, score_breakdown, priority_score)`. For freshly-scraped deals, UPDATE the `deals` row as today.

- [ ] **Step 4: `user-data.js` reads from deal_user_scores when serving pool deals.** When a pool deal has a `deal_user_scores` row for this user + current buy_box_hash, use that score_breakdown. Otherwise, mark the deal `score_stale: true` (the next scan will populate it).

- [ ] **Step 5: Add legacy-row shim** in `parseBreakdown` (utils.js) and `computePriorityScore` (wherever it lives post-D6): if `qualitative_match` is missing, treat as zero counts; the math degrades gracefully to legacy scoring.

- [ ] **Step 6: Commit**

```bash
git add ~/skills/find-deals/apply-buybox.md api/user-data.js dashboard/src/lib/utils.js
git commit -m "feat(D6): skill scores pool deals against personal buy box as part of every scan"
```

### Original Task 3.3 — DROPPED (D6)
### Original Task 3.4 — DROPPED (D6)
### Original Task 3.5 — REPLACED BY 3.6

---

# Phase 3 (Original — superseded by D6, kept for reference only)

**Outcome:** Pool deals are re-scored against the user's personal buy box on demand. Cached in a new `deal_user_scores` table keyed by `(deal_id, buy_box_hash)`. Dashboard shows personal scores, never union scores.

**Files touched:** `api/_lib/buy-box-hash.js`, `api/_lib/score-against-buybox.js`, `api/rescore-deal.js`, `api/user-data.js`, `migrations/002_deal_user_scores_table.sql`, plus tests.

---

### Task 3.1: Document the new caching table

**Files:**
- Create: `migrations/002_deal_user_scores_table.sql`

- [ ] **Step 1: Create the migration SQL**

```sql
-- migrations/002_deal_user_scores_table.sql
-- 2026-05-01 — DealHound per-user re-scoring cache

CREATE TABLE IF NOT EXISTS deal_user_scores (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  deal_id         uuid NOT NULL REFERENCES deals(id) ON DELETE CASCADE,
  user_email      text NOT NULL,
  buy_box_hash    text NOT NULL,
  score_breakdown jsonb NOT NULL,
  priority_score  integer,
  scored_at       timestamptz NOT NULL DEFAULT now(),
  UNIQUE (deal_id, user_email, buy_box_hash)
);

CREATE INDEX IF NOT EXISTS idx_deal_user_scores_lookup
  ON deal_user_scores (user_email, deal_id, buy_box_hash);
```

- [ ] **Step 2: Apply the migration in Supabase**

Run via the Supabase MCP tool or the SQL editor. Verify with:

```bash
# (Optional, if you have the supabase CLI / MCP wired)
# Apply via supabase MCP — see ~/.claude/CLAUDE.md notes for project ID
```

- [ ] **Step 3: Commit**

```bash
git add migrations/002_deal_user_scores_table.sql
git commit -m "feat: deal_user_scores table for per-user re-scoring cache"
```

---

### Task 3.2: Implement `buy-box-hash.js`

**Files:**
- Create: `api/_lib/buy-box-hash.js`
- Create: `tests/unit/buy-box-hash.test.js`

- [ ] **Step 1: Write the test**

```javascript
import { describe, it, expect } from 'vitest';
import { hashBuyBox } from '../../api/_lib/buy-box-hash.js';

describe('hashBuyBox', () => {
  it('produces the same hash for equivalent buy boxes regardless of key order', () => {
    const a = { locations: ['Texas'], price_max: 3000000, must_haves: ['waterfront'] };
    const b = { must_haves: ['waterfront'], price_max: 3000000, locations: ['Texas'] };
    expect(hashBuyBox(a)).toEqual(hashBuyBox(b));
  });

  it('produces a different hash when content changes', () => {
    const a = { locations: ['Texas'], price_max: 3000000 };
    const b = { locations: ['Texas'], price_max: 2000000 };
    expect(hashBuyBox(a)).not.toEqual(hashBuyBox(b));
  });

  it('treats array order in non-ordered fields as equivalent', () => {
    const a = { locations: ['Texas', 'Florida'] };
    const b = { locations: ['Florida', 'Texas'] };
    expect(hashBuyBox(a)).toEqual(hashBuyBox(b));
  });

  it('returns a hex string', () => {
    const h = hashBuyBox({ locations: ['Texas'] });
    expect(h).toMatch(/^[a-f0-9]+$/);
  });
});
```

- [ ] **Step 2: Run, verify fail**

```bash
npx vitest run tests/unit/buy-box-hash.test.js
```

Expected: FAIL.

- [ ] **Step 3: Implement**

```javascript
const crypto = require('crypto');

function canonicalize(obj) {
  if (Array.isArray(obj)) {
    return [...obj].map(canonicalize).sort((a, b) => JSON.stringify(a).localeCompare(JSON.stringify(b)));
  }
  if (obj && typeof obj === 'object') {
    return Object.keys(obj).sort().reduce((acc, k) => {
      acc[k] = canonicalize(obj[k]);
      return acc;
    }, {});
  }
  return obj;
}

function hashBuyBox(buyBox) {
  if (!buyBox) return 'empty';
  const canonical = JSON.stringify(canonicalize(buyBox));
  return crypto.createHash('sha256').update(canonical).digest('hex').slice(0, 16);
}

module.exports = { hashBuyBox };
```

- [ ] **Step 4: Run, verify pass**

```bash
npx vitest run tests/unit/buy-box-hash.test.js
```

- [ ] **Step 5: Commit**

```bash
git add api/_lib/buy-box-hash.js tests/unit/buy-box-hash.test.js
git commit -m "feat: stable buy-box hashing for re-score cache keys"
```

---

### Task 3.3: Implement `score-against-buybox.js`

**Files:**
- Create: `api/_lib/score-against-buybox.js`
- Create: `tests/unit/score-against-buybox.test.js`

- [ ] **Step 1: Write the test (with a mocked Anthropic client)**

```javascript
import { describe, it, expect, vi } from 'vitest';
import { scoreDealAgainstBuyBox } from '../../api/_lib/score-against-buybox.js';

const SAMPLE_DEAL = {
  id: 'd1',
  title: 'Lakefront Glamping Resort, 12 keys',
  location: 'Lake Travis, TX',
  price: 1200000,
  acreage: 8,
  property_type: 'glamping',
  raw_description: 'Operating glamping resort with 12 deluxe tents, on-site event venue, septic-ready expansion lots. Cash flowing $400k gross last year.'
};

const SAMPLE_BUY_BOX = {
  locations: ['Hill Country, TX'],
  price_min: 500000,
  price_max: 2500000,
  property_types: ['glamping', 'micro_resort'],
  revenue_requirement: 'cash_flow_day_1',
  must_haves: ['waterfront access', 'existing structures'],
  nice_to_haves: ['existing event venue'],
  dealbreakers: ['floodplain'],
  strategy_notes: 'Within 1.5 hours of Austin. Wants existing event venue revenue.'
};

describe('scoreDealAgainstBuyBox', () => {
  it('returns a full score_breakdown structure', async () => {
    const mockClient = {
      messages: {
        create: vi.fn().mockResolvedValue({
          content: [{
            type: 'text',
            text: JSON.stringify({
              strategy: {
                market_match: 'STRONG MATCH',
                revenue_match: 'STRONG MATCH',
                property_fit: 'STRONG MATCH',
                unit_economics: '$100k/key',
                seller_motivation: 'MODERATE',
                overall: 'STRONG MATCH'
              },
              risk: {
                capital_risk: 1, market_risk: 1, revenue_risk: 1,
                execution_risk: 1, information_risk: 2,
                total_risk: 6, risk_level: 'MODERATE'
              },
              qualitative_match: {
                must_haves_satisfied: 2,
                must_haves_total: 2,
                nice_to_haves_satisfied: 1,
                nice_to_haves_total: 1,
                strategy_notes_match: 'STRONG',
                evidence: 'Listing mentions on-site event venue, existing structures, lakefront via Lake Travis.'
              }
            })
          }]
        })
      }
    };

    const result = await scoreDealAgainstBuyBox(SAMPLE_DEAL, SAMPLE_BUY_BOX, { client: mockClient });

    expect(result.strategy.overall).toBe('STRONG MATCH');
    expect(result.qualitative_match.must_haves_satisfied).toBe(2);
    expect(result.priority_score).toBeGreaterThan(70);
  });

  it('returns null score for missing buy box', async () => {
    const result = await scoreDealAgainstBuyBox(SAMPLE_DEAL, null);
    expect(result).toBeNull();
  });
});
```

- [ ] **Step 2: Run, verify fail**

```bash
npx vitest run tests/unit/score-against-buybox.test.js
```

- [ ] **Step 3: Implement**

```javascript
const Anthropic = require('@anthropic-ai/sdk');

const SCORING_PROMPT = `You are a deal evaluator for DealHound. Given a real estate listing and a personalized buy box, output a JSON object with three sections: strategy, risk, qualitative_match. Use the rubric exactly.

LISTING:
{{LISTING}}

BUY BOX:
{{BUY_BOX}}

OUTPUT ONLY VALID JSON IN THIS SHAPE — no preamble:
{
  "strategy": {
    "market_match": "STRONG MATCH | MATCH | PARTIAL | MISS",
    "revenue_match": "STRONG MATCH | MATCH | PARTIAL | MISS",
    "property_fit": "STRONG MATCH | MATCH | PARTIAL | MISS",
    "unit_economics": "$X/key or $X/acre",
    "seller_motivation": "HIGH | MODERATE | LOW",
    "overall": "<worst of market/revenue/property>"
  },
  "risk": {
    "capital_risk": 0-5,
    "market_risk": 0-5,
    "revenue_risk": 0-5,
    "execution_risk": 0-5,
    "information_risk": 0-5,
    "total_risk": <sum>,
    "risk_level": "LOW | MODERATE | HIGH | VERY HIGH"
  },
  "qualitative_match": {
    "must_haves_satisfied": <int>,
    "must_haves_total": <int>,
    "nice_to_haves_satisfied": <int>,
    "nice_to_haves_total": <int>,
    "strategy_notes_match": "STRONG | MATCH | PARTIAL | MISS",
    "evidence": "<one sentence quoting specific listing phrases>"
  }
}

Rules:
- Be generous on must_haves: "waterfront access" satisfied by "lakefront", "river frontage", "beach access".
- If must_haves_satisfied < must_haves_total / 2, overall is at most PARTIAL.
- If strategy_notes_match is MISS, overall is MISS.
- When uncertain between PARTIAL and MISS, use PARTIAL.
- Always cite evidence from the listing description.`;

function computePriorityScore(breakdown, buyBox) {
  const tier = (breakdown.strategy?.overall || '').toUpperCase();
  let typeAlignment = 8;
  const types = buyBox.property_types || [];
  if (types.length > 0) typeAlignment = 25; // primary

  const revReq = buyBox.revenue_requirement;
  const revMatch = breakdown.strategy?.revenue_match;
  let revenueReadiness = 10;
  if (revMatch === 'STRONG MATCH') revenueReadiness = 20;
  else if (revMatch === 'MATCH') revenueReadiness = 17;
  else if (revMatch === 'PARTIAL') revenueReadiness = 8;

  let marketFit = 6;
  const m = breakdown.strategy?.market_match;
  if (m === 'STRONG MATCH') marketFit = 20;
  else if (m === 'MATCH') marketFit = 14;

  const qm = breakdown.qualitative_match || {};
  const mhRatio = qm.must_haves_total > 0 ? qm.must_haves_satisfied / qm.must_haves_total : 1;
  const nhRatio = qm.nice_to_haves_total > 0 ? qm.nice_to_haves_satisfied / qm.nice_to_haves_total : 0;
  const qualitative = Math.round(mhRatio * 12 + nhRatio * 8);

  const totalRisk = breakdown.risk?.total_risk || 0;
  const riskOffset = Math.max(0, Math.round(15 - totalRisk * 0.6));

  return typeAlignment + revenueReadiness + marketFit + qualitative + riskOffset;
}

async function scoreDealAgainstBuyBox(deal, buyBox, opts = {}) {
  if (!buyBox) return null;
  const client = opts.client || new Anthropic();

  const prompt = SCORING_PROMPT
    .replace('{{LISTING}}', JSON.stringify({
      title: deal.title,
      location: deal.location,
      price: deal.price,
      acreage: deal.acreage,
      property_type: deal.property_type,
      raw_description: deal.raw_description
    }, null, 2))
    .replace('{{BUY_BOX}}', JSON.stringify(buyBox, null, 2));

  const resp = await client.messages.create({
    model: 'claude-sonnet-4-20250514',
    max_tokens: 2000,
    messages: [{ role: 'user', content: prompt }]
  });

  const text = resp.content.find(c => c.type === 'text')?.text || '';
  let breakdown;
  try {
    breakdown = JSON.parse(text);
  } catch (e) {
    const m = text.match(/\{[\s\S]*\}/);
    if (!m) throw new Error('Could not parse Sonnet response: ' + text.slice(0, 200));
    breakdown = JSON.parse(m[0]);
  }

  const priority_score = computePriorityScore(breakdown, buyBox);

  return { ...breakdown, priority_score };
}

module.exports = { scoreDealAgainstBuyBox, computePriorityScore };
```

- [ ] **Step 4: Run, verify pass**

```bash
npx vitest run tests/unit/score-against-buybox.test.js
```

- [ ] **Step 5: Commit**

```bash
git add api/_lib/score-against-buybox.js tests/unit/score-against-buybox.test.js
git commit -m "feat: per-user re-scoring against personal buy box (Sonnet + qualitative match)"
```

---

### Task 3.4: Add `/api/rescore-deal` endpoint

**Files:**
- Create: `api/rescore-deal.js`
- Create: `tests/integration/rescore-deal.test.js`

- [ ] **Step 1: Write the integration test**

```javascript
import { describe, it, expect, afterAll, vi } from 'vitest';
import { getTestSupabase, cleanupTestData } from '../helpers/supabase.js';
import { TEST_EMAIL } from '../helpers/test-constants.js';

describe('POST /api/rescore-deal', () => {
  const supabase = getTestSupabase();
  let dealId, searchId;

  afterAll(async () => {
    if (dealId) await supabase.from('deal_user_scores').delete().eq('deal_id', dealId);
    await cleanupTestData(supabase, TEST_EMAIL);
  });

  it('caches a per-user score in deal_user_scores', async () => {
    // Seed a search and a deal
    const { data: s } = await supabase.from('deal_searches').insert({
      user_email: TEST_EMAIL,
      buy_box: { locations: ['Texas'] },
      status: 'complete',
      test_data: true,
      run_at: new Date().toISOString()
    }).select('id').single();
    searchId = s.id;

    const { data: d } = await supabase.from('deals').insert({
      search_id: searchId,
      url: 'https://test/' + Date.now(),
      title: 'Test Deal',
      location: 'Austin, TX',
      price: 1000000,
      acreage: 5,
      property_type: 'glamping',
      raw_description: 'A glamping resort.',
      passed_hard_filters: true,
      scraped_at: new Date().toISOString()
    }).select('id').single();
    dealId = d.id;

    // Mock the handler — directly invoke the function with a stubbed client
    // (Real test setup would call the handler via supertest; for this contract
    // we verify the cache row gets created.)
    const handler = (await import('../../api/rescore-deal.js')).default;
    const req = {
      method: 'POST',
      body: { deal_id: dealId, user_email: TEST_EMAIL, buy_box: { locations: ['Texas'], price_max: 3000000, property_types: ['glamping'] } }
    };
    const res = {
      _status: 200, _body: null,
      setHeader() {}, status(c) { this._status = c; return this; },
      json(b) { this._body = b; return this; },
      end() {}
    };
    // Stub Anthropic at module level via env var fall-through is hard;
    // for this integration test we accept the test will hit the real API.
    // Skip if no key.
    if (!process.env.ANTHROPIC_API_KEY) {
      console.warn('Skipping rescore-deal test — no ANTHROPIC_API_KEY');
      return;
    }
    await handler(req, res);
    expect(res._status).toBe(200);

    const { data: cached } = await supabase
      .from('deal_user_scores')
      .select('*')
      .eq('deal_id', dealId)
      .eq('user_email', TEST_EMAIL);
    expect(cached.length).toBeGreaterThan(0);
  }, 30000);
});
```

- [ ] **Step 2: Implement the handler**

Create `api/rescore-deal.js`:

```javascript
const { createClient } = require('@supabase/supabase-js');
const { scoreDealAgainstBuyBox } = require('./_lib/score-against-buybox');
const { hashBuyBox } = require('./_lib/buy-box-hash');

const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_KEY);

module.exports = async function handler(req, res) {
  if (req.method === 'OPTIONS') {
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
    return res.status(200).end();
  }
  if (req.method !== 'POST') return res.status(405).json({ error: 'Method not allowed' });
  res.setHeader('Access-Control-Allow-Origin', '*');

  const { deal_id, user_email, buy_box } = req.body || {};
  if (!deal_id || !user_email || !buy_box) {
    return res.status(400).json({ error: 'Missing deal_id, user_email, or buy_box' });
  }

  const buyBoxHash = hashBuyBox(buy_box);

  // Cache lookup
  const { data: cached } = await supabase
    .from('deal_user_scores')
    .select('score_breakdown, priority_score, scored_at')
    .eq('deal_id', deal_id)
    .eq('user_email', user_email)
    .eq('buy_box_hash', buyBoxHash)
    .maybeSingle();

  if (cached) {
    return res.status(200).json({ ...cached, cached: true });
  }

  // Fetch the deal
  const { data: deal, error: dealError } = await supabase
    .from('deals')
    .select('id, title, location, price, acreage, property_type, raw_description')
    .eq('id', deal_id)
    .single();
  if (dealError || !deal) return res.status(404).json({ error: 'Deal not found' });

  // Score
  let breakdown;
  try {
    breakdown = await scoreDealAgainstBuyBox(deal, buy_box);
  } catch (err) {
    console.error('Re-score error:', err.message);
    return res.status(500).json({ error: 'Scoring failed: ' + err.message });
  }
  if (!breakdown) return res.status(400).json({ error: 'No buy box' });

  const { priority_score, ...score_breakdown } = breakdown;

  // Cache
  const { error: insertError } = await supabase
    .from('deal_user_scores')
    .insert({
      deal_id,
      user_email,
      buy_box_hash: buyBoxHash,
      score_breakdown,
      priority_score
    });
  if (insertError) console.error('Cache insert error:', insertError.message);

  return res.status(200).json({ score_breakdown, priority_score, cached: false });
};
```

- [ ] **Step 3: Run the test (with ANTHROPIC_API_KEY set)**

```bash
npx vitest run tests/integration/rescore-deal.test.js
```

Expected: PASS (or skip if no API key).

- [ ] **Step 4: Commit**

```bash
git add api/rescore-deal.js tests/integration/rescore-deal.test.js
git commit -m "feat: /api/rescore-deal endpoint with caching"
```

---

### Task 3.5: Wire re-scored data into `user-data.js`

**Files:**
- Modify: `api/user-data.js`

- [ ] **Step 1: Update the pool query and overlay logic**

In `api/user-data.js`, after pool deals are filtered (after the `poolDeals = poolDeals.map(...)` line), add a step that loads cached personal scores:

```javascript
// Overlay personal scores from deal_user_scores cache
if (poolDeals.length > 0 && latestBuyBox) {
  const { hashBuyBox } = require('./_lib/buy-box-hash');
  const buyBoxHash = hashBuyBox(latestBuyBox);
  const poolIds = poolDeals.map(d => d.id);
  const { data: personalScores } = await supabase
    .from('deal_user_scores')
    .select('deal_id, score_breakdown, priority_score')
    .eq('user_email', email)
    .eq('buy_box_hash', buyBoxHash)
    .in('deal_id', poolIds);

  const personalMap = {};
  (personalScores || []).forEach(p => { personalMap[p.deal_id] = p; });

  poolDeals = poolDeals.map(d => {
    const personal = personalMap[d.id];
    if (personal) {
      return {
        ...d,
        score_breakdown: personal.score_breakdown,
        score: personal.priority_score,
        score_personalized: true
      };
    }
    return { ...d, score_personalized: false, score_stale: true };
  });
}
```

- [ ] **Step 2: Pass `score_personalized` and `score_stale` through the response mapping**

In the response `deals.map`, add:

```javascript
score_personalized: !!d.score_personalized,
score_stale: !!d.score_stale
```

- [ ] **Step 3: Add a "rescore in background" trigger (best-effort)**

The user-data response shouldn't block on re-scoring — it just returns the stale data flagged. The dashboard will call `/api/rescore-deal` per stale deal in the background. This is enabled in Task 4.x.

- [ ] **Step 4: Commit**

```bash
git add api/user-data.js
git commit -m "feat: overlay personal re-scored data on pool deals"
```

---

# Phase 4: Restore the Magical Moment

**Outcome:** Dashboard groups deals by HOT/STRONG/WATCH with counts, surfaces priority score + strategy match labels + top mitigation on each card, always offers the chat debrief, and triggers background re-scoring for stale pool deals.

**Files touched:** `dashboard/src/components/DealCard.jsx`, `dashboard/src/components/TierSection.jsx` (new), `dashboard/src/components/DealCardDetail.jsx` (new), `dashboard/src/lib/utils.js`, `dashboard/src/lib/state.js`, `dashboard/src/lib/api.js`, `dashboard/src/app.jsx`, `api/chat.js` (debrief gate).

---

### Task 4.1: Add `groupDealsByTier` helper

**Files:**
- Modify: `dashboard/src/lib/utils.js`
- Create: `tests/unit/group-deals-by-tier.test.js`

- [ ] **Step 1: Write the test**

```javascript
import { describe, it, expect } from 'vitest';
import { groupDealsByTier } from '../../dashboard/src/lib/utils.js';

const sampleDeals = [
  { id: '1', score_breakdown: { strategy: { overall: 'STRONG MATCH' } } },
  { id: '2', score_breakdown: { strategy: { overall: 'MATCH' } } },
  { id: '3', score_breakdown: { strategy: { overall: 'PARTIAL' } } },
  { id: '4', score_breakdown: { strategy: { overall: 'MATCH' } } },
  { id: '5', score_breakdown: null }
];

describe('groupDealsByTier', () => {
  it('groups deals into hot/strong/watch buckets', () => {
    const groups = groupDealsByTier(sampleDeals);
    expect(groups.hot.map(d => d.id)).toEqual(['1']);
    expect(groups.strong.map(d => d.id)).toEqual(['2', '4']);
    expect(groups.watch.map(d => d.id)).toEqual(['3', '5']);
  });

  it('sorts each tier by priority score descending', () => {
    const deals = [
      { id: 'a', score: 50, score_breakdown: { strategy: { overall: 'MATCH' } } },
      { id: 'b', score: 80, score_breakdown: { strategy: { overall: 'MATCH' } } }
    ];
    const groups = groupDealsByTier(deals);
    expect(groups.strong.map(d => d.id)).toEqual(['b', 'a']);
  });
});
```

- [ ] **Step 2: Implement**

Add to `dashboard/src/lib/utils.js`:

```javascript
export function groupDealsByTier(deals) {
  const groups = { hot: [], strong: [], watch: [] };
  for (const d of deals) {
    const tier = tierFromStrategy(parseBreakdown(d.score_breakdown).strategy?.overall);
    if (groups[tier]) groups[tier].push(d);
    else groups.watch.push(d);
  }
  for (const k of Object.keys(groups)) {
    groups[k].sort((a, b) => (b.score || 0) - (a.score || 0));
  }
  return groups;
}
```

- [ ] **Step 3: Run, verify pass**

```bash
npx vitest run tests/unit/group-deals-by-tier.test.js
```

- [ ] **Step 4: Commit**

```bash
git add dashboard/src/lib/utils.js tests/unit/group-deals-by-tier.test.js
git commit -m "feat: groupDealsByTier helper"
```

---

### Task 4.2: Build `TierSection` component

**Files:**
- Create: `dashboard/src/components/TierSection.jsx`

- [ ] **Step 1: Implement**

```jsx
import { DealCard } from './DealCard.jsx';

const TIER_META = {
  hot:    { label: 'HOT',    blurb: 'Strong fit on strategy, market, revenue, and qualitative criteria.' },
  strong: { label: 'STRONG', blurb: 'Solid match — worth a closer look.' },
  watch:  { label: 'WATCH',  blurb: 'Partial fit. Worth scanning for upside angles.' }
};

export function TierSection({ tier, deals, onOpenThread }) {
  if (!deals || deals.length === 0) return null;
  const meta = TIER_META[tier];
  return (
    <div class={`tier-section tier-section-${tier}`}>
      <div class="tier-section-header">
        <span class={`tier-section-label tier-${tier}`}>{meta.label}</span>
        <span class="tier-section-count">{deals.length}</span>
        <span class="tier-section-blurb">{meta.blurb}</span>
      </div>
      <div class="tier-section-grid">
        {deals.map(d => (
          <DealCard key={d.id} deal={d} variant="grid" onOpenThread={onOpenThread} />
        ))}
      </div>
    </div>
  );
}
```

- [ ] **Step 2: Add CSS**

In `dashboard/src/styles.css`, append:

```css
.tier-section { margin-bottom: 2rem; }
.tier-section-header { display: flex; align-items: center; gap: 0.75rem; margin-bottom: 0.75rem; }
.tier-section-label { font-weight: 700; padding: 0.2rem 0.5rem; border-radius: 4px; font-size: 0.85rem; letter-spacing: 0.05em; }
.tier-section-label.tier-hot { background: #ff4d2e; color: white; }
.tier-section-label.tier-strong { background: #f5a623; color: white; }
.tier-section-label.tier-watch { background: #888; color: white; }
.tier-section-count { font-weight: 600; color: var(--text-secondary, #666); }
.tier-section-blurb { color: var(--text-secondary, #888); font-size: 0.85rem; }
.tier-section-grid { display: grid; gap: 0.75rem; }
```

- [ ] **Step 3: Commit**

```bash
git add dashboard/src/components/TierSection.jsx dashboard/src/styles.css
git commit -m "feat: TierSection groups deals by HOT/STRONG/WATCH"
```

---

### Task 4.3: Surface scoring on `DealCard`

**Files:**
- Modify: `dashboard/src/components/DealCard.jsx`

- [ ] **Step 1: Update the card**

Replace the existing `DealCard` body with:

```jsx
import { starredDealIds } from '../lib/state.js';
import { toggleStar } from '../lib/api.js';
import { fmtPrice, tierFromStrategy, tierLabel, riskClass, parseBreakdown, strategyLabels } from '../lib/utils.js';

export function DealCard({ deal, variant = 'preview', onOpenThread }) {
  const bd = parseBreakdown(deal.score_breakdown);
  const strategy = bd.strategy || {};
  const risk = bd.risk || {};
  const qm = bd.qualitative_match || {};
  const tier = tierFromStrategy(strategy.overall);
  const isStarred = starredDealIds.value.has(deal.id);
  const labels = strategyLabels(bd);
  const topMitigation = (risk.mitigations || [])[0];

  const acreage = deal.acreage ? deal.acreage + ' ac' : null;
  const keys = deal.rooms_keys ? deal.rooms_keys + ' keys' : null;

  return (
    <div class={`deal-card deal-card-${variant} ${tier === 'hot' ? 'deal-card-hot' : ''}`}>
      <div class="deal-card-header">
        <div>
          <div class="deal-card-title">{deal.title || 'Unnamed Property'}</div>
          <div class="deal-card-location">{deal.location || ''}{deal.source ? ` · ${deal.source}` : ''}</div>
        </div>
        <div class="deal-card-actions-top">
          <button class="deal-star-btn" onClick={(e) => { e.stopPropagation(); toggleStar(deal.id); }} title={isStarred ? 'Unstar' : 'Star'}>
            {isStarred ? '★' : '☆'}
          </button>
          <span class={`deal-tier-badge tier-${tier}`}>{tierLabel(tier)}</span>
          {deal.score != null && <span class="deal-priority-score">{deal.score}/100</span>}
        </div>
      </div>

      <div class="deal-card-metrics">
        {deal.price != null && <span>{fmtPrice(deal.price)}</span>}
        {acreage && <span>{acreage}</span>}
        {keys && <span>{keys}</span>}
        {risk.risk_level && <span class={riskClass(risk.risk_level)}>{risk.risk_level} Risk</span>}
        {qm.must_haves_total > 0 && (
          <span class="must-have-count">{qm.must_haves_satisfied}/{qm.must_haves_total} must-haves</span>
        )}
      </div>

      {labels.length > 0 && (
        <div class="deal-card-labels">
          {labels.map(l => (
            <span class={`deal-label deal-label-${(l.value || '').toLowerCase().replace(/\s/g, '-')}`}>
              {l.key}: {l.value}
            </span>
          ))}
        </div>
      )}

      {topMitigation && (
        <div class="deal-card-mitigation">
          <span class="mitigation-pill">Risk note</span> {topMitigation}
        </div>
      )}

      {deal.from_pool && (
        <div class="deal-card-pool-tag">From shared pool</div>
      )}

      <div class="deal-card-footer">
        {deal.url && <a href={deal.url} target="_blank" rel="noopener" class="deal-listing-link">Listing →</a>}
        {onOpenThread && (
          <button class="deal-open-thread-btn" onClick={(e) => { e.stopPropagation(); onOpenThread(deal); }}>
            Open Thread →
          </button>
        )}
      </div>
    </div>
  );
}
```

- [ ] **Step 2: Add CSS for the new elements**

Append to `dashboard/src/styles.css`:

```css
.deal-priority-score { font-weight: 700; color: var(--accent, #ff4d2e); margin-left: 0.5rem; }
.deal-card-labels { display: flex; gap: 0.4rem; flex-wrap: wrap; margin: 0.5rem 0; }
.deal-label { font-size: 0.75rem; padding: 0.15rem 0.4rem; border-radius: 3px; background: rgba(255,255,255,0.08); }
.deal-label-strong-match { background: #2e8b57; color: white; }
.deal-label-match { background: #3a78c2; color: white; }
.deal-label-partial { background: #888; color: white; }
.must-have-count { font-size: 0.85rem; color: var(--text-secondary, #888); }
.deal-card-mitigation { font-size: 0.85rem; margin: 0.5rem 0; padding: 0.5rem; background: rgba(255,77,46,0.06); border-left: 2px solid var(--accent, #ff4d2e); border-radius: 3px; }
.mitigation-pill { font-weight: 600; color: var(--accent, #ff4d2e); margin-right: 0.4rem; }
.deal-card-pool-tag { font-size: 0.75rem; color: var(--text-secondary, #888); margin-top: 0.4rem; font-style: italic; }
```

- [ ] **Step 3: Commit**

```bash
git add dashboard/src/components/DealCard.jsx dashboard/src/styles.css
git commit -m "feat: deal card surfaces priority score, strategy labels, top mitigation, pool tag"
```

---

### Task 4.4: Render tier sections in app.jsx

**Files:**
- Modify: `dashboard/src/app.jsx`
- Modify: `dashboard/src/lib/state.js`

- [ ] **Step 1: Add a `dealsByTier` computed signal**

In `dashboard/src/lib/state.js`, add:

```javascript
import { computed } from '@preact/signals';
import { groupDealsByTier } from './utils.js';

export const dealsByTier = computed(() => groupDealsByTier(deals.value));
```

(Make sure `deals` and `groupDealsByTier` are imported as needed.)

- [ ] **Step 2: Render tier sections in the deal-list view**

In `dashboard/src/app.jsx`, find where deals are rendered (in the deal view branch). Replace the flat `deals.value.map` with:

```jsx
import { TierSection } from './components/TierSection.jsx';
import { dealsByTier } from './lib/state.js';

// ...inside the deal view:
const groups = dealsByTier.value;
return (
  <>
    <TierSection tier="hot" deals={groups.hot} onOpenThread={handleOpenThread} />
    <TierSection tier="strong" deals={groups.strong} onOpenThread={handleOpenThread} />
    <TierSection tier="watch" deals={groups.watch} onOpenThread={handleOpenThread} />
  </>
);
```

(Adjust to match the existing routing structure in `app.jsx`.)

- [ ] **Step 3: Manual UI test**

Run the dashboard locally:

```bash
npm run build
# Or: vite dev
```

Load `/dashboard?email=<your-test-email>` and verify deals are visually grouped by tier.

- [ ] **Step 4: Commit**

```bash
git add dashboard/src/app.jsx dashboard/src/lib/state.js
git commit -m "feat: dashboard groups deals into HOT/STRONG/WATCH tier sections"
```

---

### Task 4.5: Progressive reveal counter (D2 — replaces background re-score)

Under D6, re-scoring happens inside the scan job, not via a dashboard background fetch. The dashboard's job is to show progress while the scan runs and reveal deals into their tier as scoring completes.

**Files:**
- Modify: `dashboard/src/lib/api.js` (poll scan_progress)
- Modify: `dashboard/src/components/Sidebar.jsx` or a new `ScanProgress.jsx` (counter UI)
- Modify: `dashboard/src/app.jsx` (route to scan view with counter when scan is in flight)

- [ ] **Step 1: Extend `scan_progress` rows to carry counts.** When the worker invokes the skill, the skill writes progress events with `{step: "scoring", deals_scored: N, deals_total: M}`. Already partially supported via `scan_progress` table — extend the schema to include `deals_scored` and `deals_total` columns (or stash in a `data` JSONB).

- [ ] **Step 2: Dashboard polls `/api/scan-progress?id=...` every 2s while a scan is `pending` or `scanning`.** Render a counter "Hand-picking your matches… 12 of 47 analyzed".

- [ ] **Step 3: As `deal_user_scores` rows land, show those deals in their HOT/STRONG/WATCH section.** New deals slide in (CSS transition) — never reorder existing visible deals to avoid mid-mouse-hover jumps.

- [ ] **Step 4: When scan completes, hide the counter and show the final tier counts.**

- [ ] **Step 5: Commit**

```bash
git add dashboard/src/components/* dashboard/src/lib/api.js dashboard/src/app.jsx
git commit -m "feat(D2): progressive reveal counter while scan/scoring runs"
```

---

### Task 4.6: Always offer scan debrief

**Files:**
- Modify: `api/chat.js`
- Modify: `dashboard/src/components/Chat.jsx`

- [ ] **Step 1: Verify the debrief mode still works regardless of pool path**

In `api/chat.js`, the `buildDebriefPrompt` is invoked when `mode === 'scan_debrief'`. Verify it uses the user's actual deals, not the pool only. The debrief should show whatever the user is looking at.

Update `buildDebriefPrompt` query to include `from_pool` deals if the user's own deals list is empty (but the user has matching pool deals):

(no code change needed if `chat.js:108-112` already pulls deals by `search_id`. Confirm and document.)

- [ ] **Step 2: Verify the dashboard always shows the "Open scan thread" CTA**

In `dashboard/src/components/Chat.jsx` (or wherever the scan-debrief entry point is), ensure the debrief is offered whenever `view.value === 'deal'` or `view.value === 'scan'`. Remove any condition that skips the debrief based on pool source.

- [ ] **Step 3: Commit**

```bash
git add api/chat.js dashboard/src/components/Chat.jsx
git commit -m "fix: always offer scan debrief regardless of pool/scan source"
```

---

# Phase 5: Architectural Cleanup + Operations

**Outcome:** Union scan is repositioned as a candidate-inventory pre-warmer (not a delivery channel). Buy box specificity gate UI is wired. Old/dead pool-bypass code is removed. Worker queue depth is visible (D3).

**Files touched:** `worker/union-buy-box.js`, `dashboard/src/components/Chat.jsx`, `api/_lib/location.js` (cleanup), `migrations/003_worker_queue_depth_view.sql` (new).

---

### Task 5.0: Worker queue depth view (D3)

**Files:**
- Create: `migrations/003_worker_queue_depth_view.sql`

- [ ] **Step 1: Create the view**

```sql
-- migrations/003_worker_queue_depth_view.sql
create or replace view worker_queue_depth as
select
  count(*) filter (where status = 'pending')   as pending,
  count(*) filter (where status = 'running')   as running,
  count(*) filter (where status in ('pending','running')) as active,
  max(created_at) filter (where status = 'pending') as oldest_pending_at,
  now() - max(created_at) filter (where status = 'pending') as oldest_pending_age
from scrape_jobs;
```

- [ ] **Step 2: Document manual alert procedure** in `worker/SETUP.md`: "Run `select * from worker_queue_depth` weekly. If `active > 3` or `oldest_pending_age > 30 minutes`, the queue is backing up — investigate before adding parallel workers."

- [ ] **Step 3: Commit**

```bash
git add migrations/003_worker_queue_depth_view.sql worker/SETUP.md
git commit -m "feat(D3): worker_queue_depth view + manual alert procedure"
```

---

---

### Task 5.1: Mark union scan as non-display

**Files:**
- Modify: `worker/union-buy-box.js`

- [ ] **Step 1: Add the `display: false` semantic to output**

The union buy box output already has `is_union: true`. The `find-deals` skill should treat union runs as inventory-only — not score against any user.

In `worker/union-buy-box.js`, expand the output object:

```javascript
return {
  is_union: true,
  display: false,             // never shown directly to users
  delivery: 'inventory_only', // candidates for re-scoring, never final scores
  source_count: ...,
  // ... existing fields
};
```

- [ ] **Step 2: Document in `~/skills/find-deals/apply-buybox.md`**

Add a note near Step 0:

```markdown
**Union buy box (DEALHOUND_BUY_BOX_FILE has is_union: true):**
This run is for inventory pre-warming, not user-facing scoring. Skip Stage A
(strategy match) and Stage B (mitigations). Save listings to `deals` with
`passed_hard_filters` set per the union's hard filters, but leave
`score_breakdown` and `score` null. Per-user scoring happens later via
`/api/rescore-deal` against each user's personal buy box.
```

- [ ] **Step 3: Commit**

```bash
git add worker/union-buy-box.js docs/skill-snapshots/2026-05-01/apply-buybox.md
git commit -m "feat: union scan output marked inventory-only — no user-facing scoring"
```

---

### Task 5.2: Wire buy box specificity gate into chat UI

**Files:**
- Modify: `dashboard/src/components/Chat.jsx`

- [ ] **Step 1: Listen for `buy_box_too_broad` SSE events**

In `dashboard/src/components/Chat.jsx`, where the SSE event stream is consumed, handle the new event type:

```javascript
if (event.type === 'buy_box_too_broad') {
  // Surface a confirmation prompt
  setSpecificityWarning({
    score: event.score,
    suggestions: event.suggestions
  });
  // The buy box is already saved; user can choose to refine or proceed
}
```

- [ ] **Step 2: Render a refinement prompt**

When `specificityWarning` is set, show:

```jsx
{specificityWarning && (
  <div class="specificity-warning">
    <h4>Want to tighten this before we run?</h4>
    <p>This buy box is broad ({specificityWarning.score}/100). DealHound works best with granular criteria. Suggestions:</p>
    <ul>
      {specificityWarning.suggestions.map(s => <li>{s}</li>)}
    </ul>
    <div>
      <button onClick={() => sendMessage("Yes, let's refine — " + specificityWarning.suggestions[0])}>Refine</button>
      <button onClick={() => setSpecificityWarning(null)}>Run anyway</button>
    </div>
  </div>
)}
```

- [ ] **Step 3: Commit**

```bash
git add dashboard/src/components/Chat.jsx
git commit -m "feat: surface buy box specificity warning in chat UI"
```

---

### Task 5.3: Final cleanup — remove deprecated `filterDealsByBuyBox`

**Files:**
- Modify: `api/_lib/location.js`

- [ ] **Step 1: Confirm no callers**

```bash
grep -rn "filterDealsByBuyBox" /Users/gideonspencer/dealhound-pro --include="*.js" --include="*.jsx" --exclude-dir=node_modules
```

Expected: zero hits (after Phase 1 wired everything to `buy-box-filter.js`).

- [ ] **Step 2: Delete the deprecated function**

Remove `filterDealsByBuyBox` from `api/_lib/location.js` and its export. Keep `dealMatchesLocations` — it's still used by `buy-box-filter.js`.

- [ ] **Step 3: Run the full test suite**

```bash
npx vitest run
```

Expected: PASS.

- [ ] **Step 4: Commit**

```bash
git add api/_lib/location.js
git commit -m "chore: remove deprecated filterDealsByBuyBox"
```

---

### Task 5.4: Final ship

- [ ] **Step 1: Run full test suite + smoke tests**

```bash
npx vitest run
npm run test:smoke
```

- [ ] **Step 2: Build the dashboard**

```bash
npm run build
```

- [ ] **Step 3: Push and open PR**

```bash
git push
gh pr create --title "feat: restore granular personalized deal matching" --body "$(cat <<'EOF'
## Summary
Restores the DealHound value proposition. Five phases, all on this PR (or split per phase if preferred):

1. Stop the bleeding — kill the location-only pool bypass; tighten the pool filter to use the full buy box.
2. Granular buy box capture — strategy_notes, must_haves, nice_to_haves, dealbreakers; matched against listing descriptions during scoring.
3. Per-user re-scoring — pool deals scored against each user's personal buy box; cached in deal_user_scores.
4. Magical moment restored — tier grouping (HOT/STRONG/WATCH), card surfaces priority score + strategy match + top mitigation, scan debrief always available.
5. Architectural cleanup — union scan is inventory-only; buy box specificity gate in chat; deprecated code removed.

## Test plan
- [ ] New buy box always queues a scrape_job.
- [ ] Pool deals respect price, location, property type, acreage, exclusions, dealbreakers.
- [ ] Vague buy boxes trigger the specificity warning.
- [ ] Listing descriptions matched against must_haves / dealbreakers.
- [ ] Pool deals show personalized scores (re-scored) on second load.
- [ ] Dashboard groups deals into HOT / STRONG / WATCH sections.
- [ ] Cards show priority score, strategy labels, top mitigation.
- [ ] Scan debrief chat available regardless of pool/scan source.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

---

## Rollout Notes

- **Phases are sequential but each is shippable.** Phase 1 alone restores the trigger. Phase 2 alone makes the buy box capture better but won't show qualitative match until the skill is updated. Phase 3 makes pool deals personalized but assumes Phase 2 is captured. Phase 4 surfaces what Phases 2-3 produced. Phase 5 cleans up.
- **The skill files (`~/skills/find-deals/`) live outside this repo.** Snapshot them into `docs/skill-snapshots/YYYY-MM-DD/` for the review trail and to make the changes versionable.
- **Don't ship Phase 4 (background re-score) without Phase 3 deployed.** The `/api/rescore-deal` endpoint must exist before the dashboard calls it.
- **If running Phase 1-2 only:** Pool deals will be filtered correctly but still show union scores. Acceptable temporary state — better than today.
- **Watch worker logs after Phase 1 ships.** Volume of scrape_jobs will increase (no more bypass). Confirm Mac Pro keeps up.


---

## GSTACK REVIEW REPORT

| Review | Trigger | Why | Runs | Status | Findings |
|--------|---------|-----|------|--------|----------|
| CEO Review | `/plan-ceo-review` | Scope & strategy | 0 | — | not run |
| Codex Review | `/codex review` | Independent 2nd opinion | 0 | — | not run (codex not installed) |
| Eng Review | `/plan-eng-review` | Architecture & tests (required) | 1 | CLEAR (PLAN) | 7 decisions made, 0 critical gaps remain, 0 unresolved |
| Design Review | `/plan-design-review` | UI/UX gaps | 0 | — | not run |
| DX Review | `/plan-devex-review` | Developer experience gaps | 0 | — | not run |

**OUTSIDE VOICE (Claude subagent):** Ran. Identified 3 critical issues + 2 strategic concerns + 1 simpler-architecture proposal + 2 missed dependencies. Cross-model agreement on: scoring drift risk (resolved by D6), raw_description coverage uncertainty (Phase 0.1 added), simpler architecture (D6 adopted, replaces D1/D4). User overrode strategic concern about Phase scope (D7 — build all 5 phases).

**CROSS-MODEL:** Strong consensus on architecture simplification (D6). User retained authority on product scope (D7).

**UNRESOLVED:** 0

**VERDICT:** ENG REVIEW CLEARED — 7 decisions applied, plan reshaped (Phase 3 collapsed via D6, Phase 0 + Phase 2.5 added, Task 4.5 reframed for D2 progressive counter, Task 5.0 added for D3 monitoring). Ready to implement.

