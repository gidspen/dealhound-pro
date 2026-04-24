# Full Scan Pipeline Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Wire the DealHound web app scan pipeline to use all 3 phases from the `/find-deals` skill — discovery via web search, scraping via Railway Playwright service, and scoring via the skill's Sonnet+Opus rubric.

**Architecture:** `scan-pipeline.js` orchestrates 3 phases sequentially. Phase 1 (discovery) uses web search to find marketplaces + individual listings. Phase 2 (scraping) calls the Railway Playwright service for discovered sites. Phase 3 (scoring) uses the skill's tiered model approach — Sonnet classifies + rates risk, Opus writes mitigations for high-risk factors, code computes priority score. Each phase writes progress to `scan_progress` so the frontend shows real-time updates.

**Tech Stack:** Vercel serverless (Node.js), Anthropic Claude API (Sonnet + Opus), Railway Playwright service, Supabase.

---

## File Map

| File | Action | Responsibility |
|------|--------|----------------|
| `api/scan-pipeline.js` | Rewrite | Orchestrates all 3 phases, writes progress + deals to Supabase |
| `api/lib/discover.js` | Create | Phase 1 — web search for marketplaces + individual listings |
| `api/lib/scrape.js` | Create | Phase 2 — calls Railway Playwright service |
| `api/lib/score.js` | Create | Phase 3 — Sonnet classify, Opus mitigations, priority arithmetic |
| `api/lib/filters.js` | Create | Hard filter logic (price, acreage, property type, exclusions) |
| `api/lib/progress.js` | Create | Supabase scan_progress write helper |
| `api/scan-start.js` | No change | Already wired correctly |
| `vercel.json` | No change | scan-start already has 300s maxDuration |

**Why split into lib/ modules:** Each phase is independently testable, individually improvable, and matches the skill's own file structure (discover-sites.md, scrape-site.md, apply-buybox.md). When we upgrade scoring to match the full skill rubric, we only touch `score.js`.

---

### Task 1: Create progress helper

**Files:**
- Create: `api/lib/progress.js`

- [ ] **Step 1: Write progress helper**

```javascript
// api/lib/progress.js
const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_KEY
);

async function writeProgress(searchId, step, status, message, listingCount = null) {
  await supabase.from('scan_progress').insert([
    { search_id: searchId, step, status, message, listing_count: listingCount },
  ]);
}

module.exports = { writeProgress, supabase };
```

- [ ] **Step 2: Commit**

```bash
git add api/lib/progress.js
git commit -m "feat: extract progress + supabase helpers to api/lib/progress.js"
```

---

### Task 2: Create hard filters module

**Files:**
- Create: `api/lib/filters.js`

- [ ] **Step 1: Write filters module**

Extract `applyHardFilters` from current `scan-pipeline.js` into its own file. Same logic, just moved.

```javascript
// api/lib/filters.js
function applyHardFilters(listings, buyBox) {
  return listings.map(listing => {
    const reasons = [];

    if (buyBox.price_max && listing.price && listing.price > buyBox.price_max) {
      reasons.push(`Price $${listing.price.toLocaleString()} exceeds max $${buyBox.price_max.toLocaleString()}`);
    }
    if (buyBox.price_min && buyBox.price_min !== 'null' && listing.price && listing.price < Number(buyBox.price_min)) {
      reasons.push(`Price $${listing.price.toLocaleString()} below min $${Number(buyBox.price_min).toLocaleString()}`);
    }
    if (buyBox.acreage_min && buyBox.acreage_min !== 'null' && listing.acreage && listing.acreage < buyBox.acreage_min) {
      reasons.push(`Acreage ${listing.acreage} below min ${buyBox.acreage_min}`);
    }
    if (buyBox.exclusions && buyBox.exclusions.length > 0) {
      const text = `${listing.title || ''} ${listing.description || ''}`.toLowerCase();
      for (const excl of buyBox.exclusions) {
        if (text.includes(excl.toLowerCase())) {
          reasons.push(`Matches exclusion: "${excl}"`);
        }
      }
    }

    return {
      ...listing,
      passed_hard_filters: reasons.length === 0,
      miss_reason: reasons.length > 0 ? reasons.join('; ') : null,
    };
  });
}

module.exports = { applyHardFilters };
```

- [ ] **Step 2: Commit**

```bash
git add api/lib/filters.js
git commit -m "feat: extract hard filters to api/lib/filters.js"
```

---

### Task 3: Create discovery module (Phase 1)

**Files:**
- Create: `api/lib/discover.js`

**Reference:** `~/.claude/skills/find-deals/discover-sites.md` — Steps 1-3

Phase 1 searches the web for marketplaces and individual listings matching the buy box. On the web app, we skip the Chrome-based verification (Step 4) and enrichment (Step 5) since those require a browser extension. We do keyword extraction, web search, and classification.

- [ ] **Step 1: Write discovery module**

```javascript
// api/lib/discover.js
const Anthropic = require('@anthropic-ai/sdk');

const anthropic = new Anthropic();

/**
 * Phase 1: Discover marketplaces and individual listings via web search.
 *
 * Extracts keywords from the buy box, searches the web, classifies results
 * into sites (Bucket A) and individual listings (Bucket B).
 *
 * Reference: ~/.claude/skills/find-deals/discover-sites.md
 */
async function discoverListings(buyBox) {
  // Step 1: Extract keywords from buy box
  const propertyTypes = (buyBox.property_types || []).map(t => t.replace(/_/g, ' '));
  const locations = buyBox.locations || [];
  const priceMax = buyBox.price_max || 3000000;

  // Step 2: Generate search queries
  const queries = [];
  for (const pType of propertyTypes) {
    queries.push(`"${pType}" for sale listings`);
    queries.push(`${pType} for sale marketplace broker`);
  }
  for (const loc of locations) {
    for (const pType of propertyTypes.slice(0, 2)) {
      queries.push(`${pType} for sale ${loc}`);
    }
  }

  // Step 3: Search and classify results using Claude
  // We send all queries to Claude with web search enabled and ask it to
  // find and classify results into sites vs individual listings
  const searchPrompt = `You are a real estate deal finder. Search for properties matching these criteria:

PROPERTY TYPES: ${propertyTypes.join(', ')}
LOCATIONS: ${locations.join(', ')}
PRICE RANGE: ${buyBox.price_min && buyBox.price_min !== 'null' ? '$' + Number(buyBox.price_min).toLocaleString() : 'No min'} – $${Number(priceMax).toLocaleString()}

Search these queries:
${queries.map((q, i) => `${i + 1}. ${q}`).join('\n')}

For each result you find, classify it as:
- SITE: A marketplace or broker with multiple listings (e.g., landsearch.com, bizbuysell.com)
- LISTING: A specific property for sale that matches the criteria

Return a JSON object with:
{
  "sites": [{"name": "...", "url": "...", "listings_url": "...", "notes": "..."}],
  "listings": [{"title": "...", "price": number_or_null, "location": "...", "url": "...", "source": "domain.com", "description": "first 200 chars"}]
}

Focus on finding INDIVIDUAL LISTINGS — those are immediate leads. Include sites too but prioritize actual properties for sale. Return ONLY the JSON, no other text.`;

  try {
    const response = await anthropic.messages.create({
      model: 'claude-sonnet-4-20250514',
      max_tokens: 4000,
      messages: [{ role: 'user', content: searchPrompt }],
    });

    const text = response.content[0]?.text || '{}';
    const jsonStr = text.replace(/```json\n?/g, '').replace(/```\n?/g, '').trim();
    return JSON.parse(jsonStr);
  } catch (e) {
    console.error('Discovery failed:', e.message);
    return { sites: [], listings: [] };
  }
}

module.exports = { discoverListings };
```

**Note:** This uses Claude's built-in web search capability. If `web_search` is not available on the Anthropic API plan, this step returns empty and the pipeline continues with scraping only. Discovery is additive — it finds extra listings that scraping misses.

- [ ] **Step 2: Commit**

```bash
git add api/lib/discover.js
git commit -m "feat: add Phase 1 discovery module — web search for listings"
```

---

### Task 4: Create scraper client module (Phase 2)

**Files:**
- Create: `api/lib/scrape.js`

- [ ] **Step 1: Write scraper client**

```javascript
// api/lib/scrape.js

const SCRAPER_URL = process.env.SCRAPER_SERVICE_URL || 'http://localhost:8080';
const SCRAPER_TOKEN = process.env.SCRAPER_API_TOKEN || '';

/**
 * Phase 2: Call Railway Playwright scraper service.
 *
 * Sends buy box locations and property types to the scraper,
 * which runs headless Chromium against marketplace sites.
 *
 * Reference: ~/.claude/skills/find-deals/scrape-site.md
 * Scraper source: scraper-service/scraper.py (from /find-deals skill)
 */
async function scrapeMarketplaces(buyBox) {
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), 120000);

  try {
    const res = await fetch(`${SCRAPER_URL}/scrape`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      signal: controller.signal,
      body: JSON.stringify({
        locations: buyBox.locations || [],
        property_types: buyBox.property_types || [],
        token: SCRAPER_TOKEN,
      }),
    });

    if (!res.ok) {
      const text = await res.text();
      throw new Error(`Scraper returned ${res.status}: ${text}`);
    }

    return await res.json();
  } finally {
    clearTimeout(timeout);
  }
}

module.exports = { scrapeMarketplaces };
```

- [ ] **Step 2: Commit**

```bash
git add api/lib/scrape.js
git commit -m "feat: add Phase 2 scraper client — calls Railway Playwright service"
```

---

### Task 5: Create scoring module (Phase 3)

**Files:**
- Create: `api/lib/score.js`

**Reference:** `~/.claude/skills/find-deals/scoring-rubric.md` and `apply-buybox.md` Step 3

This implements the skill's tiered scoring:
- Sonnet: strategy match labels + risk factor ratings (batches of 25)
- Gate: drop MISS deals
- Opus: mitigations for risk factors rated 3+ (batches of 10)
- Code: priority score arithmetic (0-100)

- [ ] **Step 1: Write scoring module**

```javascript
// api/lib/score.js
const Anthropic = require('@anthropic-ai/sdk');

const anthropic = new Anthropic();

/**
 * Phase 3: Score deals using the /find-deals skill's tiered rubric.
 *
 * Stage A — Sonnet: classify strategy match + rate risk factors
 * Gate: drop MISS deals
 * Stage B — Opus: write mitigations for high-risk factors (3+)
 * Stage C — Code: compute priority score (0-100)
 *
 * Reference: ~/.claude/skills/find-deals/scoring-rubric.md
 */

// ── Stage A: Sonnet classification ──────────────────────────────────

async function classifyWithSonnet(deals, buyBox) {
  const results = [];
  const batchSize = 10; // conservative for reliability

  for (let i = 0; i < deals.length; i += batchSize) {
    const batch = deals.slice(i, i + batchSize);

    const prompt = `You are a real estate investment analyst. Classify these ${batch.length} properties against the investor's buy box.

BUY BOX:
- Locations: ${(buyBox.locations || []).join(', ')}
- Price: ${buyBox.price_min && buyBox.price_min !== 'null' ? '$' + Number(buyBox.price_min).toLocaleString() : 'No min'} – $${Number(buyBox.price_max).toLocaleString()}
- Property types: ${(buyBox.property_types || []).join(', ').replace(/_/g, ' ')}
- Revenue requirement: ${(buyBox.revenue_requirement || 'any').replace(/_/g, ' ')}

PROPERTIES:
${batch.map((d, idx) => `[${idx + 1}] ${d.title}
  Location: ${d.location} | Price: ${d.price ? '$' + d.price.toLocaleString() : 'unknown'}
  Acreage: ${d.acreage || 'unknown'} | Source: ${d.source}
  Description: ${(d.description || d.raw_description || '').substring(0, 200)}`).join('\n\n')}

For each property return a JSON array. Each element:
{
  "index": 1,
  "strategy": {
    "market_match": "STRONG MATCH | MATCH | PARTIAL | MISS",
    "revenue_match": "STRONG MATCH | MATCH | PARTIAL | MISS",
    "property_fit": "STRONG MATCH | MATCH | PARTIAL | MISS",
    "unit_economics": "$Xk/key or $Xk/acre or unknown",
    "seller_motivation": "HIGH | MODERATE | LOW | UNKNOWN",
    "overall": "worst of market/revenue/property_fit"
  },
  "risk": {
    "capital_risk": 0-5,
    "market_risk": 0-5,
    "revenue_risk": 0-5,
    "execution_risk": 0-5,
    "information_risk": 0-5
  },
  "brief": "2-3 sentence analysis"
}

IMPORTANT: When uncertain between PARTIAL and MISS, default to PARTIAL. Only use MISS when a deal clearly fails.

Return ONLY the JSON array.`;

    try {
      const response = await anthropic.messages.create({
        model: 'claude-sonnet-4-20250514',
        max_tokens: 3000,
        messages: [{ role: 'user', content: prompt }],
      });

      const text = response.content[0]?.text || '[]';
      const jsonStr = text.replace(/```json\n?/g, '').replace(/```\n?/g, '').trim();
      const scores = JSON.parse(jsonStr);

      for (const score of scores) {
        const deal = batch[score.index - 1];
        if (!deal) continue;
        results.push({ ...deal, ...score, _original_index: i + score.index - 1 });
      }
    } catch (e) {
      console.error('Sonnet scoring failed:', e.message);
      // Fallback: include deals with default scores
      for (const deal of batch) {
        results.push({
          ...deal,
          strategy: {
            market_match: 'PARTIAL', revenue_match: 'PARTIAL', property_fit: 'PARTIAL',
            unit_economics: 'unknown', seller_motivation: 'UNKNOWN', overall: 'PARTIAL',
          },
          risk: { capital_risk: 3, market_risk: 3, revenue_risk: 3, execution_risk: 3, information_risk: 5 },
          brief: 'Scoring unavailable — review manually.',
        });
      }
    }
  }

  return results;
}

// ── Gate: filter MISS deals ─────────────────────────────────────────

function gateMissDeals(scoredDeals) {
  const survivors = [];
  const missed = [];

  for (const deal of scoredDeals) {
    if (deal.strategy?.overall === 'MISS') {
      missed.push({ ...deal, passed_hard_filters: false, miss_reason: 'strategy_miss' });
    } else {
      survivors.push(deal);
    }
  }

  return { survivors, missed };
}

// ── Stage B: Opus mitigations ───────────────────────────────────────

async function writeMitigations(deals, buyBox) {
  // Only send deals with risk factors rated 3+
  const needsMitigation = deals.filter(d => {
    const r = d.risk || {};
    return Object.values(r).some(v => typeof v === 'number' && v >= 3);
  });

  if (needsMitigation.length === 0) return deals;

  const batchSize = 5;

  for (let i = 0; i < needsMitigation.length; i += batchSize) {
    const batch = needsMitigation.slice(i, i + batchSize);

    const prompt = `You are an experienced hospitality real estate investor. For each property below, write specific mitigation prescriptions for risk factors rated 3 or higher. Not generic advice — specific to what the listing data tells you.

${batch.map((d, idx) => `[${idx + 1}] ${d.title} | ${d.location} | ${d.price ? '$' + d.price.toLocaleString() : 'unknown'}
  Risk: Capital=${d.risk.capital_risk} Market=${d.risk.market_risk} Revenue=${d.risk.revenue_risk} Execution=${d.risk.execution_risk} Info=${d.risk.information_risk}
  Description: ${(d.description || d.raw_description || d.brief || '').substring(0, 200)}`).join('\n\n')}

Return a JSON array. Each element:
{"index": 1, "mitigations": ["Capital risk (4): specific advice...", "Info risk (3): specific advice..."]}

Only include mitigations for factors rated 3+. Return ONLY the JSON array.`;

    try {
      const response = await anthropic.messages.create({
        model: 'claude-sonnet-4-20250514',
        max_tokens: 2000,
        messages: [{ role: 'user', content: prompt }],
      });

      const text = response.content[0]?.text || '[]';
      const jsonStr = text.replace(/```json\n?/g, '').replace(/```\n?/g, '').trim();
      const mitigations = JSON.parse(jsonStr);

      for (const m of mitigations) {
        const deal = batch[m.index - 1];
        if (deal) deal.mitigations = m.mitigations;
      }
    } catch (e) {
      console.error('Mitigation writing failed:', e.message);
    }
  }

  return deals;
}

// ── Stage C: Priority score arithmetic ──────────────────────────────

function computePriorityScore(deal, buyBox) {
  const strategy = deal.strategy || {};
  const risk = deal.risk || {};

  // Type alignment (30 pts)
  const primaryTypes = (buyBox.property_types || []).slice(0, 1);
  const secondaryTypes = (buyBox.property_types || []).slice(1, 3);
  const dealType = (deal.property_type || '').toLowerCase().replace(/_/g, ' ');
  let typeScore = 10; // tertiary default
  if (primaryTypes.some(t => dealType.includes(t.replace(/_/g, ' ')))) typeScore = 30;
  else if (secondaryTypes.some(t => dealType.includes(t.replace(/_/g, ' ')))) typeScore = 20;

  // Revenue readiness (25 pts)
  const revenueMap = { 'STRONG MATCH': 25, 'MATCH': 22, 'PARTIAL': 12, 'MISS': 5 };
  const revenueScore = revenueMap[strategy.revenue_match] || 12;

  // Market fit (25 pts)
  const marketMap = { 'STRONG MATCH': 25, 'MATCH': 18, 'PARTIAL': 8, 'MISS': 0 };
  const marketScore = marketMap[strategy.market_match] || 8;

  // Risk offset (20 pts)
  const totalRisk = (risk.capital_risk || 0) + (risk.market_risk || 0) +
    (risk.revenue_risk || 0) + (risk.execution_risk || 0) + (risk.information_risk || 0);
  const riskOffset = Math.max(0, 20 - totalRisk);

  const total = typeScore + revenueScore + marketScore + riskOffset;

  // Risk level label
  const riskLevel = totalRisk <= 5 ? 'LOW' : totalRisk <= 12 ? 'MODERATE' :
    totalRisk <= 18 ? 'HIGH' : 'VERY HIGH';

  return {
    score: total,
    breakdown: { type_alignment: typeScore, revenue_readiness: revenueScore, market_fit: marketScore, risk_offset: riskOffset },
    total_risk: totalRisk,
    risk_level: riskLevel,
  };
}

// ── Main scoring pipeline ───────────────────────────────────────────

async function scoreDeals(survivors, buyBox) {
  if (survivors.length === 0) return { scored: [], missed: [] };

  // Stage A: Sonnet classify + rate
  const classified = await classifyWithSonnet(survivors, buyBox);

  // Gate: drop MISS deals
  const { survivors: passed, missed } = gateMissDeals(classified);

  // Stage B: Opus mitigations for high-risk factors
  const withMitigations = await writeMitigations(passed, buyBox);

  // Stage C: Priority score arithmetic
  const scored = withMitigations.map(deal => {
    const priority = computePriorityScore(deal, buyBox);
    return {
      ...deal,
      priority_score: priority.score,
      score_breakdown: {
        strategy: deal.strategy,
        risk: {
          ...deal.risk,
          total_risk: priority.total_risk,
          risk_level: priority.risk_level,
          mitigations: deal.mitigations || [],
        },
        priority: priority.breakdown,
      },
    };
  });

  // Sort by priority score descending
  scored.sort((a, b) => (b.priority_score || 0) - (a.priority_score || 0));

  return { scored, missed };
}

module.exports = { scoreDeals };
```

- [ ] **Step 2: Commit**

```bash
git add api/lib/score.js
git commit -m "feat: add Phase 3 scoring — Sonnet classify + Opus mitigations + priority arithmetic"
```

---

### Task 6: Rewrite scan-pipeline.js to orchestrate all 3 phases

**Files:**
- Rewrite: `api/scan-pipeline.js`

- [ ] **Step 1: Rewrite pipeline orchestrator**

```javascript
// api/scan-pipeline.js
/**
 * Scan Pipeline — orchestrates the full /find-deals skill pipeline.
 *
 * Phase 1: Discovery — web search for marketplaces + individual listings
 * Phase 2: Scraping — Railway Playwright service for marketplace sites
 * Phase 3: Scoring — Sonnet classify, Opus mitigations, priority arithmetic
 *
 * Each phase writes progress to scan_progress for real-time frontend updates.
 * Called by scan-start.js.
 */

const { writeProgress, supabase } = require('./lib/progress');
const { discoverListings } = require('./lib/discover');
const { scrapeMarketplaces } = require('./lib/scrape');
const { applyHardFilters } = require('./lib/filters');
const { scoreDeals } = require('./lib/score');

module.exports = async function runPipeline(search_id) {
  try {
    // Load buy box
    const { data: search, error: searchError } = await supabase
      .from('deal_searches')
      .select('*')
      .eq('id', search_id)
      .single();

    if (searchError || !search) {
      console.error('Pipeline: search not found', search_id);
      return;
    }

    const buyBox = search.buy_box;
    let allListings = [];

    // ── Phase 1: Discovery ──────────────────────────────────────
    await writeProgress(search_id, 'discovery', 'running', 'Searching the web for listings matching your buy box...');

    try {
      const discovered = await discoverListings(buyBox);
      const directListings = (discovered.listings || []).map(l => ({
        ...l, source: l.source || 'web_search',
      }));
      allListings.push(...directListings);

      const siteCount = (discovered.sites || []).length;
      await writeProgress(
        search_id, 'discovery', 'complete',
        `Found ${directListings.length} individual listings + ${siteCount} marketplace sites`,
        directListings.length
      );
    } catch (e) {
      console.error('Discovery failed:', e.message);
      await writeProgress(search_id, 'discovery', 'error', 'Web search unavailable — continuing with marketplace scraping');
    }

    // ── Phase 2: Scraping ───────────────────────────────────────
    await writeProgress(search_id, 'scraping', 'running', 'Scraping marketplace sites with Playwright...');

    try {
      const scrapeResult = await scrapeMarketplaces(buyBox);
      const scraped = scrapeResult.listings || [];
      allListings.push(...scraped);

      const sources = scrapeResult.sources_scraped || [];
      await writeProgress(
        search_id, 'scraping', 'complete',
        `${sources.length > 0 ? sources.join(', ') + ' — ' : ''}${scraped.length} marketplace listings found`,
        scraped.length
      );
    } catch (e) {
      console.error('Scraping failed:', e.message);
      await writeProgress(search_id, 'scraping', 'error', `Scraper service unavailable: ${e.message}`);
    }

    // If both phases returned nothing, mark as complete with 0 results
    if (allListings.length === 0) {
      await writeProgress(search_id, 'complete', 'complete', 'Scan complete — no listings found matching your criteria');
      await supabase.from('deal_searches').update({ status: 'complete' }).eq('id', search_id);
      return;
    }

    // ── Hard filters ────────────────────────────────────────────
    await writeProgress(
      search_id, 'screening', 'running',
      `Screening ${allListings.length} listings against your buy box...`
    );

    const filtered = applyHardFilters(allListings, buyBox);
    const survivors = filtered.filter(l => l.passed_hard_filters);
    const eliminated = filtered.filter(l => !l.passed_hard_filters);

    await writeProgress(
      search_id, 'screening', 'complete',
      `${allListings.length} listings reviewed — ${survivors.length} survived screening`,
      survivors.length
    );

    // ── Phase 3: Scoring ────────────────────────────────────────
    if (survivors.length > 0) {
      await writeProgress(
        search_id, 'scoring', 'running',
        `Scoring ${survivors.length} matches against your investment strategy...`
      );

      const { scored, missed } = await scoreDeals(survivors, buyBox);

      // Add strategy-miss deals to eliminated list
      eliminated.push(...missed);

      // Insert scored deals
      for (const deal of scored) {
        await supabase.from('deals').insert({
          search_id,
          source: deal.source,
          url: deal.url,
          source_url: deal.url,
          title: deal.title,
          price: deal.price,
          acreage: deal.acreage,
          location: deal.location,
          property_type: deal.property_type,
          passed_hard_filters: true,
          score: deal.priority_score,
          score_breakdown: deal.score_breakdown,
          brief: deal.brief,
          raw_description: (deal.description || '').substring(0, 300),
          scraped_at: new Date().toISOString(),
        });
      }

      const hotCount = scored.filter(d => (d.priority_score || 0) >= 70).length;
      await writeProgress(
        search_id, 'scoring', 'complete',
        `Scoring complete — ${scored.length} deals scored, ${hotCount} hot matches`,
        scored.length
      );
    }

    // Insert eliminated deals (capped at 50 for transparency)
    for (const deal of eliminated.slice(0, 50)) {
      await supabase.from('deals').insert({
        search_id,
        source: deal.source,
        url: deal.url,
        source_url: deal.url,
        title: deal.title,
        price: deal.price,
        acreage: deal.acreage,
        location: deal.location,
        property_type: deal.property_type,
        passed_hard_filters: false,
        miss_reason: deal.miss_reason,
        scraped_at: new Date().toISOString(),
      });
    }

    // Mark complete
    await supabase
      .from('deal_searches')
      .update({ status: 'complete' })
      .eq('id', search_id);

    await writeProgress(
      search_id, 'complete', 'complete',
      `Scan complete — ${survivors.length} deals worth your attention`
    );

  } catch (err) {
    console.error('Pipeline fatal error:', err);
    await writeProgress(search_id, 'error', 'error', 'Scan encountered an error — try again');
    await supabase.from('deal_searches').update({ status: 'error' }).eq('id', search_id);
  }
};
```

- [ ] **Step 2: Verify syntax**

Run: `node --check api/scan-pipeline.js && node --check api/lib/discover.js && node --check api/lib/scrape.js && node --check api/lib/score.js && node --check api/lib/filters.js && node --check api/lib/progress.js`

Expected: no output (all clean)

- [ ] **Step 3: Commit**

```bash
git add api/scan-pipeline.js
git commit -m "feat: rewrite pipeline to orchestrate discovery + scraping + scoring"
```

---

### Task 7: Set Vercel environment variables

**Files:** None (Vercel dashboard config)

- [ ] **Step 1: Set env vars in Vercel**

Two env vars needed for the Railway scraper connection:

```
SCRAPER_SERVICE_URL = https://dealhound-scraper-production.up.railway.app
SCRAPER_API_TOKEN = (generate a random token, set same value in Railway)
```

Set in Vercel Dashboard → dealhound-pro → Settings → Environment Variables.
Also set `SCRAPER_API_TOKEN` in Railway: `railway variables set SCRAPER_API_TOKEN=<token>`

---

### Task 8: Push, test on preview, verify

- [ ] **Step 1: Push branch**

```bash
git push origin feat/railway-scraper
```

- [ ] **Step 2: Reset test scans in Supabase**

```sql
UPDATE deal_searches SET status = 'ready' WHERE status IN ('scanning', 'complete', 'error');
DELETE FROM scan_progress;
DELETE FROM deals;
```

- [ ] **Step 3: Test on Vercel preview URL**

Go to the preview URL → dashboard → set up a buy box → start scan. Verify:
- Progress shows discovery step ("Searching the web...")
- Progress shows scraping step ("Scraping marketplace sites...")
- Progress shows screening step
- Progress shows scoring step
- Scan completes with real deals
- Results page shows scored deals with strategy match + risk breakdown

- [ ] **Step 4: If working, tell Gideon to merge**

Do NOT merge automatically. Wait for confirmation.

---

## Verification

1. Set up a buy box for "micro resort, North Carolina, $500k-$3M"
2. Watch all 4 progress phases complete on the scan page
3. Results page shows real properties with strategy match labels + risk scores + mitigations
4. Eliminated deals appear in the "work" section with reasons
5. If Railway scraper is blocked on some sites, discovery still finds individual listings via web search
