# Deal Hound — MVP Product Spec
*Version 1.0 — April 2026*

---

## What it is

An AI agent that hunts hospitality deals across 20+ marketplaces daily, scores them against your specific investment strategy and buy box, and delivers only the ones worth your time — with the reasoning to back it up.

Not a search tool. Not a listing alert. Your own deal analyst that works while you sleep.

---

## Core User Journey

```
Land on site
  → Talk to AI to set up buy box (conversational, not a form)
  → Watch your first scan run in real time
  → See full results: all deals reviewed, top matches surfaced
  → Chat with AI about specific deals or ask why things were filtered
  → Set up daily digest — email shows deal count + top 3 matches
  → Click email → back to site for full deep dive
```

---

## Feature Requirements

### 1. Buy Box Setup — Conversational Onboarding

**How it works:**
- User lands on the site, clicks "Start" or "Set up my agent"
- Enters email (that's it — no password, no credit card)
- Magic link sent → they click → drop into a chat interface
- AI asks questions to build the buy box:
  - Location / target markets
  - Price range (min/max)
  - Property types (micro resort, glamping, boutique hotel, B&B, campground, etc.)
  - Revenue requirement (cash flow day 1, value-add OK, development OK)
  - Acreage minimum
  - Risk tolerance / investment strategy (value-add vs. turnkey)
  - Any hard exclusions

**Agent behavior:**
- Asks clarifying questions to narrow parameters — better input = fewer listings to scrape = faster scans
- Confirms the buy box back in plain English before running: *"Got it. Here's what I'll hunt for: [summary]. Ready to run your first scan?"*
- Saves the buy box to the user's profile
- User can edit buy box anytime via chat: *"Actually, include value-add properties"*

**MVP scope:** Chat UI, AI-driven Q&A, save to Supabase. No form fallback needed.

---

### 2. Scan — Real-Time Progress Display

**How it works:**
- After buy box confirmed, scan kicks off immediately
- User sees a live activity feed (Claude tool-use style):
  ```
  ✓ Searching LandSearch — 238 listings found
  ✓ Searching Campground Marketplace — 71 listings found
  ⟳ Searching NAI Outdoor Hospitality...
    Screening against buy box...
  ✓ 441 listings reviewed — 6 survived initial screening
  ⟳ Scoring survivors...
    Analyzing Cedar Ridge Glamping Resort...
  ```
- Shows forward movement even during waiting periods
- Ends with: "Scan complete — 6 deals worth your attention"

**Technical approach:** Server-sent events (SSE) or polling every 2 seconds against a `scan_progress` table. No WebSockets needed for MVP.

**Progress states to surface:**
- Sources being scraped (with listing counts as they come in)
- Buy box gates being applied (showing eliminations)
- Survivors being scored
- Scan complete + summary

---

### 3. Results — Full List + Top Matches

**Two-section layout:**

**Section A — The Work** (shown first, collapsed by default, expandable)
- All listings reviewed: count by source, elimination reason breakdown
- Table: property name, source, price, why it was eliminated
- Purpose: shows users the agent actually did real work across many sources
- Label: *"441 listings reviewed across 7 marketplaces"*

**Section B — Top Matches** (shown prominently)
- Scored survivors sorted by strategy match tier (HOT → STRONG → WATCH)
- Each card shows:
  - Property name, location, type
  - Price, acreage, keys (where available)
  - Strategy match tier (HOT / STRONG / WATCH) — based on buy box fit, not risk
  - Risk level shown separately (LOW / MODERATE / HIGH / VERY HIGH) — investor decides what's acceptable
  - Score breakdown: what matched, what's uncertain
  - Suggested next step
  - Link to original listing
- "Ask AI about this deal" button on each card → opens conversation

**Sort controls:**
- Default: strategy match (HOT first)
- Option: sort by price, by risk, by acreage
- User preference, not opinionated

---

### 4. AI Conversation — Deal Q&A

**Two entry points:**
1. "Ask about this deal" on any deal card → pre-loads deal context
2. General chat from results page → user can ask anything about the scan

**What the AI can do:**
- Explain why a deal was scored HOT vs STRONG
- Explain why a specific listing was filtered out ("Why wasn't X included?")
- Compare two deals ("Which of these is better for a value-add strategy?")
- Give due diligence checklist for a specific deal
- Answer questions about the market or property type
- Help user refine their buy box based on what they're seeing

**Context loaded into each conversation:**
- User's buy box
- The specific deal (if entering from a card)
- Full scan results for the session

**Conversation tracking:**
- Every conversation stored in Supabase: `conversations` table
- Fields: user_email, deal_id (optional), search_id, messages (jsonb), created_at
- Used for: product improvement, training, user history

---

### 5. Daily Digest — Email Notifications

**Schedule:** Daily (user can configure time)

**Trigger logic:**
- Only send if NEW listings appeared since last digest
- If no new deals: skip send (don't spam)
- If new HOT/STRONG deals: always send

**Email content:**
- Subject: *"3 new deals match your buy box — [Location]"*
- Body:
  - Stats: X listings reviewed, Y survived, Z are strong matches
  - Top 3 deal cards (name, location, match tier, price)
  - CTA: "See all results →" → links to `dealhound.pro/results?email=...`
- Sent via: ConvertKit (already integrated) or Resend for transactional

**⚠️ Decision needed: Daily scan architecture**
Running a full scrape + Claude scoring daily on all sources is expensive (~$0.50–2.00 per run in API costs). Better MVP approach:
- Incremental daily: check for NEW listings only (compare against `last_seen_at`), score only new ones
- Full re-score weekly: re-run scores on all survivors to catch price changes
- This gives "daily freshness" without 7x the cost

User-facing framing stays the same: *"Your agent scans daily."*

---

### 6. Marketplace Coverage

**Current (live):** 7 sources
**Marketing number:** "10+ marketplaces" — achievable with Apify integration for BizBuySell, LandWatch, BizQuest, Crexi (4 more = 11 total)

**⚠️ Flag:** Marketing "20+" before we have 20 creates a trust problem if users check. Better approach: show a live counter of actual marketplaces scanned, updated as we add more. "Currently scanning 11 marketplaces — more added weekly." Transparency + growth story.

**Apify integration** (next sprint after MVP):
- BizBuySell: operating businesses with P&L data — highest value source
- LandWatch: large land marketplace
- BizQuest: operating businesses
- Crexi: commercial, cap rate data

---

### 7. Auth & Account

**Signup:** Email only → magic link. No password. No credit card.

**First run:** Free. Unlimited AI chat on that scan.

**Conversion to paid ($29/mo):**
- Trigger: when user tries to set up daily digest OR requests a second scan
- Message: *"Your first scan is free. Set up daily alerts and unlimited scans for $29/mo."*
- Payment: Stripe, collect at that moment

**User session:** Magic link sets a JWT stored in localStorage. Email is the identity.

---

### 8. Design Principles

- **One thing per screen.** Never make the user choose between competing CTAs.
- **Show the work.** Users need to feel the agent worked hard. The full list of reviewed deals is proof.
- **Agent voice, not dashboard.** The interface speaks. Cards have opinions. "This one's worth a call today."
- **Fast.** Results page loads in under 2 seconds. Scan progress updates feel instant.
- **No jargon.** Cap rate is fine. "DCF-adjusted risk-adjusted yield" is not.
- **Mobile-first.** Investors check email on their phone. Results page must be excellent on mobile.

---

### 9. Marketing Positioning

**Primary message:**
*"Your own AI agent that hunts deals and evaluates them against your criteria."*

**Why it beats listing alerts:**
- Platforms alert when a listing matches their filters (price, type, location)
- Deal Hound scores every deal against your full investment strategy — not just surface criteria
- Result: fewer, smarter leads vs. noise

**Key proof points:**
- X marketplaces scanned (live counter)
- Including smaller/niche marketplaces where competition is lower
- Intelligent scoring, not keyword matching
- Daily scans — fresher than weekly competitor tools

**Tagline options:**
- *"Your deal hunting agent."*
- *"Stop scrolling. Start closing."*
- *"The deals your competitors miss."*

---

## What's NOT in MVP

- Mobile app
- Team/multi-user accounts
- Broker integrations (off-market)
- Auto-scheduling site visits
- Document analysis (OMs, T12s)
- Portfolio tracking
- MLS integration

---

## Build Order

1. **Conversational buy box intake** (chat UI → save buy box)
2. **Real-time scan progress** (SSE/polling progress feed)
3. **Results page v2** (full list + top matches, two sections)
4. **Deal Q&A chat** (AI conversation on individual deals)
5. **Auth** (magic link)
6. **Daily digest email** (incremental scans + ConvertKit/Resend)
7. **Stripe paywall** (triggers on second scan or digest setup)
8. **Apify integration** (unlocks 4 more sources)
