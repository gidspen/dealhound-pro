# Landing Page Positioning Refresh Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Broaden DealHound's positioning from hospitality-specific to any real estate/business asset class, clarify messaging around buy box intelligence, fix confusing Step 4 copy, update stats sections for long-term credibility, and expand the "Who It's For" section.

**Architecture:** All changes are to a single static HTML file (`index.html`). No backend, no dynamic data wiring — every stat is currently hardcoded. Tasks are ordered top-to-bottom through the page to minimize merge conflicts. Commit after each task.

**Tech Stack:** Vanilla HTML/CSS, no framework, no build step. Edit the file directly. Test by opening in a browser.

---

## Current State Audit

Before touching anything, here's what exists and where it lives (line numbers from `index.html`):

| Element | Location | Current content |
|---|---|---|
| `<meta description>` | line 7 | Mentions "micro resort, glamping, boutique hotel" |
| Hero eyebrow badge | line 817 | "Now Scanning — 400+ Listings Weekly" |
| Hero h1 | line 820 | "Meet your AI deal hunting agent." |
| Hero sub-copy | lines 823–825 | Mentions "micro resort, glamping, and boutique hotel" |
| Proof bar label | line 839 | "Last week's scan — Texas (Dallas + Houston markets)" |
| Proof bar stats | lines 841–858 | Hardcoded: 441 listings, 435 eliminated, 6 deals, 7 marketplaces |
| Step 02 desc | lines 882–884 | "crawls 7 specialized marketplaces" + "survivors" language |
| Step 04 title | line 893 | "Call on deals, not listings" |
| Step 04 desc | line 894 | "Every survivor comes with a suggested first step" |
| Sample card type | line 905 | "Micro Resort · Cash Flow Strategy" |
| Sources h2 | line 935 | "7 marketplaces, one agent." |
| Sources source cards | lines 938–988 | 6 cards, all hospitality-specific names/icons |
| Who It's For cards | lines 999–1014 | 3 cards, all hospitality: Micro Resort, Boutique Hotel, STR Portfolio |
| Pricing features | lines 1047 | "Weekly scans across 7+ marketplaces" |

**Static vs. dynamic flag:** The proof bar stats (441, 435, 6, 7) are **fully hardcoded HTML**. There is no JavaScript, API call, or data file driving them. Any changes to those numbers are manual edits.

---

## File Map

**Modified:** `index.html` — all changes go here. No new files created.

---

## Task 1: Update meta description + hero sub-copy (broaden positioning)

**Files:**
- Modify: `index.html` lines 7, 823–825

**What to change:** Remove hospitality-specific asset class mentions. Replace with asset-class-agnostic language. Hospitality can appear as one example, not as the product's entire identity.

- [ ] **Step 1: Update the meta description tag (line 7)**

Replace:
```html
<meta name="description" content="Your personal AI agent that scans 400+ micro resort, glamping, and boutique hotel listings against your buy box. Weekly deal reports delivered to you. $29/month." />
```
With:
```html
<meta name="description" content="Your personal AI deal hunting agent. Define your buy box — price, location, asset type — and Deal Hound scans 30+ marketplaces weekly, delivering only the deals worth your time. First scan free." />
```

- [ ] **Step 2: Update the hero sub-copy (lines 823–825)**

Replace:
```html
        <p class="hero-sub">
          Stop manually scrolling 10 marketplaces. Your personal Deal Hound scans 400+ micro resort, glamping, and boutique hotel listings against your exact buy box — and delivers only the deals worth your time.
        </p>
```
With:
```html
        <p class="hero-sub">
          Stop manually scrolling dozens of marketplaces. Your personal Deal Hound scans 30+ sources across every asset class — commercial, residential, hospitality, and small businesses — filtered against your exact buy box. Only the deals worth your time, delivered weekly.
        </p>
```

- [ ] **Step 3: Open `index.html` in a browser. Confirm hero sub-copy reads correctly and no hospitality-only language remains in the hero.**

- [ ] **Step 4: Commit**
```bash
git add index.html
git commit -m "copy: broaden hero positioning to all asset classes"
```

---

## Task 2: Remove "Now Scanning — 400+ Listings Weekly" eyebrow badge

**Files:**
- Modify: `index.html` line 816–818

The badge number isn't impressive enough yet. Hide it entirely until the product has 10,000+ lifetime deals analyzed — at that point, resurface it as a rolling lifetime total.

- [ ] **Step 1: Remove the eyebrow badge element**

Replace:
```html
        <div class="hero-eyebrow">
          <span class="dot"></span>
          Now Scanning — 400+ Listings Weekly
        </div>
```
With: *(nothing — delete the block entirely)*

> **Note for future:** When lifetime deal count hits 10,000+, restore this badge with copy like: "10,000+ Deals Analyzed" and wire it to a backend stat.

- [ ] **Step 2: Visually verify in browser — the hero should still look clean without the eyebrow badge. The h1 should start the visual hierarchy.**

- [ ] **Step 3: Commit**
```bash
git add index.html
git commit -m "copy: hide listings count badge until 10k lifetime deals milestone"
```

---

## Task 3: Fix Step 02 — remove "survivors" language + update marketplace count

**Files:**
- Modify: `index.html` lines 882–884

"Survivors" is extreme jargon. Also, the step says "7 specialized marketplaces" — update to "30+ marketplaces."

- [ ] **Step 1: Update Step 02 description**

Replace:
```html
              <div class="step-desc">Deal Hound crawls 7 specialized marketplaces, screens every listing through your buy box gates, and scores survivors on a 100-point rubric.</div>
```
With:
```html
              <div class="step-desc">Deal Hound crawls 30+ marketplaces across every asset class, screens every listing through your buy box criteria, and scores qualifying deals on a 100-point rubric.</div>
```

- [ ] **Step 2: Commit**
```bash
git add index.html
git commit -m "copy: fix step 02 — remove survivors language, update to 30+ marketplaces"
```

---

## Task 4: Rewrite Step 04 — fix confusing title and copy

**Files:**
- Modify: `index.html` lines 893–895

Current title "Call on deals, not listings" is unclear. "Every survivor comes with a suggested first step" uses jargon and buries the value. Rewrite to be explicit: Deal Hound tells you exactly what to do next to lock in the deal.

- [ ] **Step 1: Rewrite the step title and description**

Replace:
```html
              <div class="step-title">Call on deals, not listings</div>
              <div class="step-desc">Every survivor comes with a suggested first step — who to call, what to ask, and what to verify before going further.</div>
```
With:
```html
              <div class="step-title">Get your action plan, not just a list</div>
              <div class="step-desc">Every qualifying deal comes with Deal Hound's recommended next step — who to contact, what to request, and what to verify before committing. You know exactly how to move fast without missing something critical.</div>
```

- [ ] **Step 2: Verify in browser that Step 04 card reads clearly and the value prop (recommended next steps to lock the deal) is immediately obvious.**

- [ ] **Step 3: Commit**
```bash
git add index.html
git commit -m "copy: rewrite step 04 — clarify deal action plan value prop"
```

---

## Task 5: Broaden the sample deal card (remove hospitality-only framing)

**Files:**
- Modify: `index.html` line 905

The sample card says "Micro Resort · Cash Flow Strategy." This reinforces hospitality-only. Keep it as a concrete example but make the asset type feel like one of many.

- [ ] **Step 1: Update sample card asset type label**

Replace:
```html
            <div class="sample-type">Micro Resort · Cash Flow Strategy</div>
```
With:
```html
            <div class="sample-type">Hospitality · Cash Flow Strategy · Example Deal</div>
```

> This signals it's an illustrative example of one asset type, not the only type.

- [ ] **Step 2: Commit**
```bash
git add index.html
git commit -m "copy: label sample card as example deal, not default asset type"
```

---

## Task 6: Update Sources section — headline, count, and add coming-soon features

**Files:**
- Modify: `index.html` lines 935–988

Three changes here:
1. Update headline from "7 marketplaces" to "30+ marketplaces"
2. Add buy box differentiation messaging (vs. Crexi alerts)
3. Add two "Coming Soon" feature cards: Deal Analysis and Creative Financing finder

- [ ] **Step 1: Update the section headline and sub-copy**

Replace:
```html
      <h2 class="section-h2">7 marketplaces, <em>one agent.</em></h2>
      <p class="section-sub">Sites you'd never have time to check manually, all scanned against your buy box every week.</p>
```
With:
```html
      <h2 class="section-h2">30+ marketplaces, <em>one agent.</em></h2>
      <p class="section-sub">Every week, Deal Hound crawls the sources you'd never have time to check — then filters everything through your unique buy box. This isn't a notification alert. It's an agent that understands what <em>you</em> are looking for.</p>
```

- [ ] **Step 2: Add a buy box differentiation callout block below the section sub-copy (anchored insertion)**

Use the following as your old_string anchor (the closing `</p>` of section-sub followed by the opening of sources-grid):
```html
      <p class="section-sub">Every week, Deal Hound crawls the sources you'd never have time to check — then filters everything through your unique buy box. This isn't a notification alert. It's an agent that understands what <em>you</em> are looking for.</p>

      <div class="sources-grid">
```
Replace with:
```html
      <p class="section-sub">Every week, Deal Hound crawls the sources you'd never have time to check — then filters everything through your unique buy box. This isn't a notification alert. It's an agent that understands what <em>you</em> are looking for.</p>

      <div style="margin-top: 24px; margin-bottom: 48px; padding: 18px 22px; background: var(--gold-glow); border: 1px solid rgba(36,61,53,0.12); border-radius: 10px; max-width: 680px;">
        <div style="font-size: 0.7rem; font-weight: 600; letter-spacing: 0.12em; text-transform: uppercase; color: var(--gold); margin-bottom: 6px;">Why this is different from filter alerts</div>
        <div style="font-size: 0.85rem; color: var(--cream-dim); line-height: 1.6;">Generic filter alerts show you anything that loosely matches a price range or zip code. Deal Hound takes in your full buy box — price, location, asset type, revenue requirements, acreage, financing structure — and scores every deal against your exact criteria. You get a ranked shortlist, not a flood of irrelevant listings.</div>
      </div>

      <div class="sources-grid">
```

> Note: The callout deliberately says "filter alerts" rather than calling out Crexi by name — we also list Crexi as a data source we aggregate, so naming them as a competitor in the same section is contradictory.

- [ ] **Step 3: Update the Crexi source card description to remove "hospitality category" framing**

The existing Crexi card (in the sources grid) describes it with hospitality-specific language. Update it to reflect broad commercial coverage:

Replace:
```html
        <div class="source-card">
          <div class="source-icon">🏢</div>
          <div>
            <div class="source-name">Crexi</div>
            <div class="source-desc">Commercial platform with cap rate data and hospitality category.</div>
            <div class="source-count">Coming soon</div>
          </div>
        </div>
```
With:
```html
        <div class="source-card">
          <div class="source-icon">🏢</div>
          <div>
            <div class="source-name">Crexi</div>
            <div class="source-desc">Commercial real estate platform with cap rate data across office, retail, industrial, and hospitality.</div>
            <div class="source-count">Coming soon</div>
          </div>
        </div>
```

- [ ] **Step 4: Add two new "Coming Soon" feature cards to the sources grid (anchored insertion)**

Use the last existing source card as the old_string anchor:
```html
        <div class="source-card">
          <div class="source-icon">🗺️</div>
          <div>
            <div class="source-name">LandWatch + BizQuest</div>
            <div class="source-desc">Large land marketplace and operating business listings.</div>
            <div class="source-count">Coming soon</div>
          </div>
        </div>
      </div>
```
Replace with:
```html
        <div class="source-card">
          <div class="source-icon">🗺️</div>
          <div>
            <div class="source-name">LandWatch + BizQuest</div>
            <div class="source-desc">Large land marketplace and operating business listings.</div>
            <div class="source-count">Coming soon</div>
          </div>
        </div>
        <div class="source-card coming-soon">
          <div class="source-icon">🔬</div>
          <div>
            <div class="source-name">Deal Analysis</div>
            <div class="source-desc">Automated financial analysis on qualifying deals — cap rate, revenue multiples, and key risk flags surfaced before you call.</div>
            <div class="coming-badge">Coming Soon</div>
          </div>
        </div>
        <div class="source-card coming-soon">
          <div class="source-icon">🤝</div>
          <div>
            <div class="source-name">Creative Financing Finder</div>
            <div class="source-desc">Identifies deals with seller financing, assumable debt, or low-money-down potential — flagged automatically in your weekly report.</div>
            <div class="coming-badge">Coming Soon</div>
          </div>
        </div>
      </div>
```

- [ ] **Step 5: Update the sources grid CSS to handle 8 cards gracefully**

The grid is currently `repeat(3, 1fr)`. With 8 cards this gives 2 full rows of 3 + one partial row of 2. That's fine and will look clean. No CSS change needed — verify visually.

- [ ] **Step 6: Verify in browser: (a) headline says "30+", (b) differentiation callout renders correctly without naming Crexi as competitor, (c) Crexi card now describes broad commercial coverage, (d) two new coming-soon cards appear in the grid.**

- [ ] **Step 7: Commit**
```bash
git add index.html
git commit -m "feat: update sources section — 30+ marketplaces, buy box differentiator, coming soon features"
```

---

## Task 7: Rework the Proof Bar — rename + add lifetime stats framing

**Files:**
- Modify: `index.html` lines 839–858

**Changes:**
1. Rename from "Last week's scan" to lifetime/cumulative framing so numbers grow over time
2. Add a granular markets breakdown row so the coverage claim is specific and impressive (individual state/region counts)
3. Update the label and top stats to reflect broader asset classes

**Current stats (all hardcoded):**
- 441 — Listings Scanned
- 435 — Eliminated by Buy Box
- 6 — Deals Worth Pursuing
- 7 — Marketplaces Scraped

**New structure:**
- Top row (4-col grid): Listings Analyzed | Filtered by Buy Box | Deals Surfaced | Marketplaces Active
- Bottom row (granular market breakdown): individual market/state counts — many cells, makes "30+ markets" feel real

**Why a second row?** The spec says "list the number of markets, broken down granularly so we can make the number higher." One number (30+) doesn't do that. A grid of individual market stats does.

- [ ] **Step 1: Update the proof bar section label**

Replace:
```html
      <div class="proof-bar-label">Last week's scan — Texas (Dallas + Houston markets)</div>
```
With:
```html
      <div class="proof-bar-label">What Deal Hound has analyzed — growing every week</div>
```

- [ ] **Step 2: Add CSS for the market breakdown row (add inside the `<style>` block, after `.proof-label` styles)**

Add after the `.proof-label` rule block (search for `.proof-label {` — insert after its closing `}`):
```css
    .proof-markets {
      margin-top: 1px;
      background: var(--surface);
      border-top: 1px solid var(--border);
      padding: 20px 24px;
      display: flex;
      flex-wrap: wrap;
      gap: 8px 20px;
      justify-content: center;
    }
    .proof-market-item {
      font-size: 0.78rem;
      color: var(--cream-dim);
    }
    .proof-market-item strong {
      color: var(--cream);
      font-weight: 500;
    }
```

- [ ] **Step 3: Update the four proof bar top-row stats and add the granular markets row below**

Replace the entire proof-grid div (the one containing the 4 stat cells):
```html
      <div class="proof-grid">
        <div class="proof-item">
          <div class="proof-num">441</div>
          <div class="proof-label">Listings Scanned</div>
        </div>
        <div class="proof-item">
          <div class="proof-num">435</div>
          <div class="proof-label">Eliminated by Buy Box</div>
        </div>
        <div class="proof-item">
          <div class="proof-num">6</div>
          <div class="proof-label">Deals Worth Pursuing</div>
        </div>
        <div class="proof-item">
          <div class="proof-num">7</div>
          <div class="proof-label">Marketplaces Scraped</div>
        </div>
      </div>
```
With:
```html
      <div class="proof-grid">
        <div class="proof-item">
          <div class="proof-num">441</div>
          <div class="proof-label">Listings Analyzed</div>
        </div>
        <div class="proof-item">
          <div class="proof-num">435</div>
          <div class="proof-label">Filtered by Buy Box</div>
        </div>
        <div class="proof-item">
          <div class="proof-num">6</div>
          <div class="proof-label">Deals Surfaced</div>
        </div>
        <div class="proof-item">
          <div class="proof-num">30+</div>
          <div class="proof-label">Marketplaces Active</div>
        </div>
      </div>
      <div class="proof-markets">
        <div class="proof-market-item"><strong>Texas</strong> — Dallas, Houston, Austin, San Antonio, Hill Country</div>
        <div class="proof-market-item"><strong>Florida</strong> — Miami, Orlando, Tampa, Panhandle</div>
        <div class="proof-market-item"><strong>Colorado</strong> — Denver, Rockies, Western Slope</div>
        <div class="proof-market-item"><strong>Tennessee</strong> — Nashville, Smoky Mountains</div>
        <div class="proof-market-item"><strong>Georgia</strong> — Atlanta, Blue Ridge</div>
        <div class="proof-market-item"><strong>Arizona</strong> — Phoenix, Sedona, Scottsdale</div>
        <div class="proof-market-item"><strong>North Carolina</strong> — Asheville, Charlotte</div>
        <div class="proof-market-item"><strong>California</strong> — Wine Country, Central Coast, SoCal</div>
      </div>
```

> **Note:** These markets are hardcoded starting values. Update them as actual scan coverage expands. When the scan pipeline logs real market data, wire this to a data file instead of hardcoding.

> **Note for future:** When the scan pipeline logs cumulative data, wire the top stats and markets list to a JSON file or API endpoint so they auto-update. For now they are manually maintained.

- [ ] **Step 4: Verify in browser — (a) label does not say "last week", (b) top 4 stats render cleanly, (c) granular markets row appears below with state + sub-market breakdown, (d) layout holds on mobile (markets row wraps gracefully).**

- [ ] **Step 5: Commit**
```bash
git add index.html
git commit -m "feat: update proof bar to lifetime framing, add granular markets breakdown"
```

---

## Task 8: Expand "Who It's For" — all asset classes

**Files:**
- Modify: `index.html` lines 992–1016

Replace 3 hospitality-only cards with a comprehensive set covering commercial, residential, hospitality, and small businesses. Target 6 cards across 2 rows.

**Asset class checklist for "Who It's For":**
- [x] Micro Resort / Outdoor Hospitality buyers
- [x] Boutique Hotel / B&B acquirers
- [x] Commercial real estate (office, retail, industrial, flex)
- [x] Multifamily / residential portfolio builders
- [x] Small business / cash-flowing business buyers (via BizBuySell etc.)
- [x] STR / short-term rental portfolio builders

- [ ] **Step 1: Update the section header copy**

Replace:
```html
      <h2 class="section-h2">Built for <em>serious investors.</em></h2>
      <p class="section-sub">Deal Hound is for investors who are actively looking — not casually browsing.</p>
```
With:
```html
      <h2 class="section-h2">Built for <em>any serious investor.</em></h2>
      <p class="section-sub">Whatever asset class you're targeting, Deal Hound filters the market to your exact buy box — so you only see deals that fit.</p>
```

- [ ] **Step 2: Replace the 3-card who-grid with 6 cards covering all asset classes**

Replace the entire `.who-grid` div:
```html
      <div class="who-grid">
        <div class="who-card">
          <span class="who-icon">🏕️</span>
          <div class="who-title">Micro Resort & Outdoor Hospitality</div>
          <div class="who-desc">Targeting glamping operations, cabin resorts, campgrounds, and outdoor hospitality properties with existing infrastructure or development potential.</div>
        </div>
        <div class="who-card">
          <span class="who-icon">🏨</span>
          <div class="who-title">Boutique Hotels & B&Bs</div>
          <div class="who-desc">Looking for operating inns, small hotels, and bed & breakfasts with cash flow you can step into — not just land to develop from scratch.</div>
        </div>
        <div class="who-card">
          <span class="who-icon">🏢</span>
          <div class="who-title">Commercial Real Estate</div>
          <div class="who-desc">Acquiring office, retail, industrial, or flex space with specific cap rate, tenant mix, or market requirements that generic platforms can't filter for.</div>
        </div>
        <div class="who-card">
          <span class="who-icon">🏘️</span>
          <div class="who-title">Multifamily & Residential Portfolios</div>
          <div class="who-desc">Building a rental portfolio and tired of wading through listings that don't meet your unit count, rent roll, or value-add criteria.</div>
        </div>
        <div class="who-card">
          <span class="who-icon">📈</span>
          <div class="who-title">Cash-Flowing Business Buyers</div>
          <div class="who-desc">Searching for owner-operated businesses with real revenue — laundromats, car washes, service businesses — screened against your return and transition requirements.</div>
        </div>
        <div class="who-card">
          <span class="who-icon">🔑</span>
          <div class="who-title">STR Portfolio Builders</div>
          <div class="who-desc">Adding properties to a short-term rental portfolio and need existing revenue data, not just listings — filtered by market, asset type, and financial performance.</div>
        </div>
      </div>
```

- [ ] **Step 3: Update the who-grid CSS to support 6 cards on desktop**

The grid is `repeat(3, 1fr)` — 6 cards will fill 2 rows perfectly. No CSS change needed. Verify on mobile (cards stack to 1-column — also fine).

- [ ] **Step 4: Verify in browser on desktop and mobile — 6 cards render in clean 3-column grid, no overflow or layout issues.**

- [ ] **Step 5: Commit**
```bash
git add index.html
git commit -m "feat: expand who it's for — 6 asset classes across commercial, residential, hospitality, business"
```

---

## Task 9: Update pricing features list — remove hardcoded "7+" marketplace count

**Files:**
- Modify: `index.html` line 1047

The featured pricing card says "Weekly scans across 7+ marketplaces" — update to "30+".

- [ ] **Step 1: Update pricing feature copy**

Replace:
```html
            <li>Weekly scans across 7+ marketplaces</li>
```
With:
```html
            <li>Weekly scans across 30+ marketplaces</li>
```

- [ ] **Step 2: Commit**
```bash
git add index.html
git commit -m "copy: update pricing card marketplace count to 30+"
```

---

## Task 10: Final visual QA pass

- [ ] **Step 1: Open `index.html` in a browser. Walk through the page top to bottom.**

Check:
- [ ] No hospitality-only language remains in the hero, sub-copy, or step descriptions (hospitality is allowed as one example in the sample card and who-grid)
- [ ] Eyebrow badge ("400+ Listings Weekly") is gone
- [ ] Step 04 title and description clearly communicate "recommended next steps to lock the deal"
- [ ] Sources section says "30+" in both headline and proof bar
- [ ] Buy box differentiation callout is visible and renders without layout issues
- [ ] Two "Coming Soon" feature cards (Deal Analysis, Creative Financing Finder) appear in sources grid
- [ ] Proof bar label does not say "last week"
- [ ] "Who It's For" has 6 cards covering all asset classes
- [ ] Pricing card says "30+ marketplaces"
- [ ] Mobile view: check at 375px width — all sections stack cleanly

- [ ] **Step 2: Fix any visual issues found.**

- [ ] **Step 3: Final commit if any fixes made**
```bash
git add index.html
git commit -m "fix: QA pass — landing page positioning refresh"
```

---

## Future Work (Not In This Plan)

These items were surfaced during planning but are out of scope here — park for a future sprint:

1. **Dynamic proof bar stats** — Wire listing counts and market coverage to a JSON file or API so numbers update automatically as scan coverage grows.
2. **Lifetime deal counter** — When 10,000+ deals have been analyzed, restore the hero eyebrow badge with a live rolling count.
3. **Deal hub vision** — Long-term product evolution: multiple active deals per user, document uploads, notes, Granola meeting minutes integration. Don't build yet — validate demand first.
4. **Marketplace count tracking** — As new sources are added, maintain a single source-of-truth for the count (a config file) so "30+" updates don't require finding every hardcoded instance.

---

## Summary Checklist

| Task | Type | Risk |
|---|---|---|
| 1. Meta + hero copy | Copy only | Low |
| 2. Remove eyebrow badge | Copy/HTML delete | Low |
| 3. Fix Step 02 language | Copy only | Low |
| 4. Rewrite Step 04 | Copy only | Low |
| 5. Sample card label | Copy only | Low |
| 6. Sources section (headline + differentiator callout + Crexi card fix + coming soon features) | Copy + HTML add | Medium — adds new elements, uses old_string anchors |
| 7. Proof bar (lifetime framing + new CSS + granular markets row) | Copy + CSS + HTML add | Medium — adds new CSS class and a new HTML row |
| 8. Who It's For expansion | HTML rewrite | Medium — replace 3 cards with 6 |
| 9. Pricing copy | Copy only | Low |
| 10. Visual QA | QA | Low |
