# Deal Hound SBA — Product Requirements Document
*Off-market small business acquisition lead generation*
*Version 1.0 — May 2026*

---

## 1. Executive Summary

Deal Hound SBA is an autonomous AI agent that surfaces small business owners who have a **high probability of selling soon** — before they ever list their business publicly. The agent ingests public data signals (business age, owner age proxies, succession indicators, digital decay), scores each business on retirement probability, and outputs a ranked list of off-market leads with owner contact info and pre-drafted outreach already written.

The end user is the small business broker, searcher (ETA), or strategic acquirer who needs targeted off-market deal flow that no one else is seeing.

**Tagline:** *"The deals that aren't on the market yet."*

This is a sub-product of the Deal Hound brand, surfaced at **dealhound.pro/sba**, leveraging the existing scoring infrastructure with a separate landing page and a different data pipeline.

---

## 2. The Opportunity

**The Silver Tsunami is real and underaddressed.** Roughly 10,000 baby boomers retire every day in the U.S., and they own a disproportionate share of American small businesses. The vast majority have:
- No succession plan
- No associate or junior partner lined up
- No exit strategy
- No clue what their business is worth

When they finally do sell, most deals happen off-market through brokers and personal relationships. Public listing sites (BizBuySell, Flippa, BizQuest) capture only a fraction of actual transactions.

**The competitive gap:** Existing tools surface businesses that are already listed. There is no widely available tool that proactively identifies pre-sale businesses using public data signals. Brokers source these manually through cold calling, networking, and farming.

**The wedge:** A small business broker who closes one $1M dental practice acquisition earns ~$80–100K in commission. Even one closed deal sourced through this tool delivers 100x ROI on a SaaS subscription. The math works at almost any reasonable price point.

---

## 3. Target Users

### Primary
**Small business brokers** (members of IBBA — International Business Brokers Association — and independent brokers). ~3,000+ in the U.S. They live and die by deal flow. They currently source manually and pay for crude lead lists.

### Secondary
**Searchers / ETA buyers** (entrepreneurs through acquisition). Growing category — Stanford, HBS, and Texas all run ETA programs producing hundreds of searchers per year actively looking for businesses to buy. They have capital but not deal flow.

### Tertiary
**Strategic acquirers / consolidators** (DSOs in dental, MSOs in medical, HVAC roll-ups, etc.). They have target lists but limited research bandwidth.

---

## 4. Core Hypothesis

The probability that a small business owner is willing to sell within 12 months can be estimated with reasonable accuracy by stacking publicly available signals across five categories:

1. **Owner Age Indicators** (proxy for natural retirement timing)
2. **Succession Vacuum** (no one in the org chart to take over)
3. **Digital Decay** (owner has stopped investing in growth)
4. **Activity Decline** (the business is plateauing or shrinking)
5. **No Growth Signals** (no expansion, hiring, or reinvestment)

When 4+ of these are present in stack, the owner is statistically far more likely to be receptive to an acquisition conversation than the general business population.

---

## 5. Probability of Sale — Scoring Model

Every business is scored on a **0–100 retirement probability scale**, computed from weighted signals.

### 5.1 Signal Weights

| Category | Signal | Weight | Source |
|---|---|---|---|
| **Owner Age** | Professional license issued 25+ years ago | 15 | State licensing board |
| **Owner Age** | Business registered 25+ years ago | 10 | Secretary of State |
| **Owner Age** | Owner LinkedIn graduation year (proxy: 1985 or earlier) | 10 | LinkedIn |
| **Succession Vacuum** | Solo practitioner / single owner-operator | 15 | Website, licensing data |
| **Succession Vacuum** | No associate or junior partner listed anywhere | 10 | Website, Google, LinkedIn |
| **Succession Vacuum** | No family member in the business (different last name on staff) | 5 | Website, public records |
| **Digital Decay** | Website last updated 3+ years ago | 8 | WHOIS, Wayback Machine |
| **Digital Decay** | Outdated website tech (no SSL, no mobile, pre-2018 design) | 4 | Site analysis |
| **Digital Decay** | No social media or last post 12+ months ago | 5 | Facebook, Instagram, X |
| **Activity Decline** | Review velocity declining (last 6mo vs prior 6mo) | 8 | Google Maps, Yelp |
| **Activity Decline** | Most recent review > 60 days ago | 5 | Google Maps, Yelp |
| **No Growth** | Zero job postings in last 12 months | 3 | Indeed, LinkedIn, Glassdoor |
| **No Growth** | Same staff count for 5+ years | 2 | Wayback, LinkedIn |

**Total possible: 100**

### 5.2 Tier Thresholds

Mirrors the existing Deal Hound HOT/STRONG/WATCH schema:

| Tier | Score | Meaning | Action |
|---|---|---|---|
| **HOT** | 80–100 | Multiple high-weight signals. Owner likely actively considering exit. | Outreach immediately. Highest broker priority. |
| **STRONG** | 60–79 | Real signals stacked. Worth a personalized cold approach. | Outreach this week with retirement framing. |
| **WATCH** | 40–59 | Some signals present. Not urgent but worth tracking. | Add to nurture sequence. Re-score in 90 days. |
| **Below 40** | 0–39 | Insufficient signal. | Discard from results. |

### 5.3 Risk Level (Separate from Tier)

Like the parent Deal Hound product, **risk is a separate dimension from match strength**. A HOT tier doesn't mean "buy it." It means "high probability the owner will engage." Risk on the deal itself (revenue concentration, regulatory exposure, etc.) is a separate analysis that happens after outreach lands.

---

## 6. Data Sources

### 6.1 Primary Sources (Signal Generation)

| Source | What we get | Vertical scope | Access method |
|---|---|---|---|
| **State Professional Licensing Boards** | License issue year, license type, status | Dental, medical, vet, CPA, legal | Public web (state-by-state) |
| **Secretary of State (per state)** | Business registration date, registered agent, owner name | All verticals | Public web |
| **Google Maps / Places** | Business name, address, phone, website, review count, review recency, hours | All verticals | Places API |
| **WHOIS** | Domain registration date, last update | All with websites | Public WHOIS |
| **Wayback Machine** | Website change history, design recency | All with websites | API |
| **Yelp** | Review velocity, business age on platform | All consumer-facing | Public web |
| **LinkedIn** | Owner profile, employee count, hiring activity, graduation year | All verticals | Manual / careful |
| **Indeed / Glassdoor** | Job posting history | All verticals | Public web |
| **Facebook / Instagram** | Last post date, engagement trend | All consumer-facing | Public web |

### 6.2 Enrichment Sources (Owner Contact)

| Source | Purpose |
|---|---|
| **Hunter.io** | Pattern-based email discovery |
| **Apollo / RocketReach** | Owner email + phone enrichment |
| **Practice website "About" pages** | Direct email, phone, owner photo |
| **State licensing board** | Owner full name, sometimes address |

### 6.3 Vertical Priorities (Build Order)

1. **Dental practices** — best first vertical. Cleanest licensing data, active acquirer market (DSOs), $500K–$3M deal sizes, SBA-loanable, mostly off-market.
2. **HVAC / Plumbing / Electrical** — owner-operators, strong cash flow, high broker demand.
3. **Veterinary practices** — same dental profile, consolidator-driven market.
4. **CPA / accounting firms** — sticky recurring revenue, aging owner base.
5. **Family medicine** — high opportunity but complicated by corporate practice of medicine laws (state-by-state legal complexity).

---

## 7. Geographic Strategy

Start with **Texas** for the MVP. Reasons:
- Public data accessibility is strong
- Texas State Board of Dental Examiners has a public license lookup
- Texas Secretary of State business search is public
- Business-friendly state = more transactions and a larger broker community
- Existing Deal Hound user base is concentrated in Texas / Sun Belt

Expand state-by-state after MVP validates signal quality.

---

## 8. Product Surface

### 8.1 Landing Page — `dealhound.pro/sba`

Separate visual identity from the main Deal Hound product, but shared brand voice.

**Hero:**
> *"The dental practices that aren't on the market yet."*
>
> Find off-market acquisition targets before any other broker sees them.

**Above-the-fold elements:**
- One-line value prop
- Live counter ("X off-market leads scored this week")
- Sample lead card (anonymized)
- Single CTA: "See live leads in your state →"

**Below the fold:**
- How it works (3 steps: choose vertical → choose state → get scored leads with outreach)
- Sample lead breakdown (show the signal stack on one HOT lead so the methodology is visible)
- Pricing
- Logos / testimonials (eventually)

### 8.2 Buy Box — Conversational

Same chat-based intake pattern as the parent Deal Hound product. Agent asks:
- Vertical (dental, HVAC, vet, CPA, etc.)
- Geography (state, optionally specific cities/counties)
- Deal size preference (revenue range estimate)
- Target lead count per week (default: 20)
- Outreach style preferences (warmer/softer vs. direct)

Confirms in plain English. Saves to user profile. Editable anytime.

### 8.3 Results Dashboard

Two sections, mirroring parent product:

**Section A — The Work** (shown collapsed)
- Total businesses screened this week
- Source breakdown (X from licensing data, Y from Google Maps, etc.)
- Elimination reasons (too young, no signals, already sold, etc.)

**Section B — Top Leads** (prominent, sorted HOT → STRONG → WATCH)

Each lead card shows:
- **Business identity:** name, city, address, phone, website
- **Owner identity:** name, estimated age, LinkedIn (if found), email, phone
- **Retirement score** (0–100) and tier badge (HOT / STRONG / WATCH)
- **Signal stack:** which signals fired and contributed (e.g. "License issued 1989 · Solo practitioner · Website last updated 2019 · Reviews declining")
- **Years in business**
- **Suggested outreach angle** (1 sentence)
- **Pre-drafted email** (subject + body, ready to copy/send)
- **Action buttons:** Copy email · Mark contacted · Add to CRM · Snooze

### 8.4 Lead Detail Q&A

Same pattern as parent product. Click into any lead → conversation panel preloaded with that lead's context.

User can ask:
- "Why was this scored HOT?"
- "What other practices does this owner have?"
- "Draft me a follow-up email for after I send the first one"
- "What's a fair offer range for this practice?"

### 8.5 Weekly Digest Email

Subject: *"5 new HOT off-market leads — [Vertical] [State]"*

Body:
- Stats: businesses screened, signal hits, top-tier count
- Top 3 lead cards inline
- CTA → results dashboard

Sent only when there are new HIGH or STRONG leads. No spam.

### 8.6 CSV Export

Every lead set is exportable as CSV for users who push leads into HubSpot, Salesforce, or their preferred CRM.

---

## 9. Output Schema (Per Lead)

```
{
  business_name: string
  vertical: string                    # "dental" | "hvac" | etc.
  address: string
  city: string
  state: string
  zip: string
  phone: string
  website: string
  
  owner_name: string
  owner_estimated_age: number | null
  owner_email: string | null
  owner_phone: string | null
  owner_linkedin: string | null
  
  years_in_business: number
  license_year: number | null
  
  retirement_score: number             # 0–100
  retirement_tier: "HOT" | "STRONG" | "WATCH"
  
  signals: [
    {
      category: string                 # "owner_age" | "succession_vacuum" | etc.
      signal: string                   # "license_issued_25y_ago"
      weight: number
      evidence: string                 # human-readable proof
      source: string                   # "Texas State Board of Dental Examiners"
      source_url: string
    }
  ]
  
  outreach_angle: string               # one-sentence suggestion
  outreach_subject: string
  outreach_body: string
  
  scored_at: timestamp
  last_refreshed: timestamp
  status: "new" | "contacted" | "responded" | "rejected" | "in_progress"
}
```

---

## 10. Auth, Pricing & Conversion

### Auth
Email + magic link. No password. No credit card to start. Same pattern as parent Deal Hound.

### Free tier
First 5 leads free. Unlimited Q&A on those leads.

### Paid
**$199/month** — 50 fresh leads/week per vertical+state combo, full enrichment, weekly digest, CSV export, unlimited Q&A.

**$499/month** — Unlimited verticals + states, 200+ leads/week, priority enrichment, daily digest available.

Pricing rationale: A single broker who closes one deal pays for ~40 years of subscription. The price is set to feel cheap relative to deal value, not relative to other SaaS tools.

### Conversion trigger
Free user sees their 5 leads → wants more states or more verticals → paywall fires with the value math: *"One closed deal = $80K commission. This is $199/month."*

---

## 11. Success Metrics

### Product health
- **Lead quality:** % of HOT leads where owner picks up the phone or replies to email (target: >15% reply rate)
- **Score calibration:** % of HOT-tier owners who confirm they're considering selling (target: >25% within 90 days)
- **Source coverage:** number of verticals × states fully indexed (target by month 3: 5 verticals × 10 states = 50 markets)
- **Lead freshness:** % of leads re-scored in last 30 days (target: 100%)

### Business health
- **Closed deals attributed:** brokers reporting closed acquisitions sourced from the platform (target: 1 per quarter in first 6 months, 5+ per quarter by month 12)
- **MRR**
- **Logo retention:** % of paid users who stay 6+ months (target: >70%)
- **CAC payback:** months to recoup CAC (target: <3)

### Quality control flags
- **Stale data rate:** any signal sourced from data >90 days old gets flagged
- **False HOT rate:** when manual review of top leads shows the signals are actually wrong (target: <10%)

---

## 12. URL & Brand Architecture

**Decision: build under the Deal Hound brand at `dealhound.pro/sba`.**

Reasons:
- Brand equity — Deal Hound already signals "AI-powered deal sourcing" and existing users will see the connection immediately
- Single login, single Stripe customer, single Supabase backend
- Cross-sell — Deal Hound users buying hospitality businesses are the same demographic interested in acquiring service businesses
- Lower marketing surface area to maintain

**The /sba path is the entry point.** Different visual landing page, different positioning, different pricing — but all the infrastructure underneath is shared with the parent product. Auth, billing, data layer, results dashboard pattern, AI conversation engine all reused.

**Why "/sba"?** Because the SBA 7(a) loan is the dominant financing mechanism for these acquisitions. Brokers, searchers, and acquirers all speak SBA. The URL signals "this is for the people who do SBA-financed business acquisitions" — instantly recognizable to the target audience.

**Future:** if it scales independently, lift it to `dealhoundsba.com` or rebrand. For now, leverage Deal Hound traffic and trust.

---

## 13. MVP Scope

### IN SCOPE for MVP

- **One vertical:** dental practices
- **One state:** Texas
- **Buy box:** vertical + state + city/region filter + target lead count
- **Lead pipeline:** scrape → score → enrich → draft outreach → persist
- **Output:** ranked leads in dashboard at `/sba/results` + JSON/CSV export
- **Pre-drafted outreach** with retirement framing
- **Weekly digest email**
- **Magic link auth**
- **Stripe paywall** (after free 5 leads)
- **Lead detail Q&A chat**

### NOT IN MVP

- Outreach sending (user copies and sends from their own email — deliverability is its own product)
- CRM integrations (Salesforce, HubSpot)
- Multi-state per user (one state per buy box at MVP)
- Mobile app
- Acquirer matching (connecting buyers to sellers — that's a marketplace, different product)
- Valuation calculator (separate skill, future)
- Phone outreach via voice agent (future, regulatory complexity)
- Deal financing intros (future partnership opportunity)

---

## 14. Outreach Tone Guidelines

The drafted email is the most sensitive output of this product. Get it wrong and the broker looks predatory. Get it right and they get a meeting.

**Framing rules:**

1. **Lead with respect for what they built.** Reference the years in business, location, longevity. Show you noticed.
2. **Frame around succession, not sale.** Words to use: *next chapter, legacy, transition planning, succession, what comes next*. Words to avoid: *sell, exit, liquidate, retire*.
3. **Be specific, not generic.** Reference at least one actual fact about their business (city, longevity, specialty).
4. **Soft ask.** End with a low-commitment offer: a 15-minute conversation, a no-obligation valuation, a simple "if this isn't the right time, I understand."
5. **Identify yourself clearly.** Owner's name, broker name, phone number. No anonymous outreach.
6. **One paragraph max.** Long emails get archived.

**Sample (for calibration):**

> Subject: A thought on what comes next for [Practice Name]
>
> Dr. [LastName] —
>
> I noticed [Practice Name] has been serving [City] families for over 30 years. That kind of practice doesn't happen by accident, and I imagine you've thought about what the next chapter looks like.
>
> I work with [number] dentists in Texas thinking through succession — sometimes that means a transition to an associate, sometimes a sale to a DSO, sometimes something in between. No two paths look the same.
>
> If you'd ever like a no-strings 15-minute conversation about what your practice could be worth and what your options are, I'd be glad to help you think it through. If now isn't the right time, I understand completely.
>
> [Broker name]
> [Phone]

---

## 15. Open Questions (For Future Resolution)

1. **Data freshness frequency.** Daily? Weekly? Cost vs value tradeoff for re-scoring already-found leads.
2. **Owner email accuracy SLA.** What's the acceptable bounce rate? When does enrichment cost outweigh value?
3. **Lead exclusivity.** Should two brokers be able to see the same lead? Or is exclusivity per-paid-user a paid feature?
4. **Direct outreach via the platform.** Long-term — should we send the emails ourselves (deliverability + tracking) or stay user-copy?
5. **Voice outreach.** AI-driven phone outreach for HOT leads is technically possible. Regulatory and ethical complexity is high.
6. **Anti-abuse / ethical guardrails.** How do we prevent harassment of small business owners? Should owners be able to opt out of being scored?

---

## 16. The North Star

Six months in, a small business broker logs in on Monday morning, sees 8 new HOT leads with full profiles and drafted emails, sends 5 of them in 20 minutes, gets 2 replies by Friday, and books a meeting. Three months later he closes one of them and earns $90K in commission. He never looks at another lead source again.

That's the product.

---

*End of spec.*
