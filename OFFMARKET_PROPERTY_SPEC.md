# Deal Hound Off-Market Properties — Product Requirements Document
*Off-market hospitality property acquisition lead generation*
*Version 0.1 — May 2026*

---

## 1. Executive Summary

Deal Hound Off-Market is an autonomous AI agent that surfaces **property owners with a high probability of selling within 12 months** — before the property is ever listed on LandSearch, Crexi, BizBuySell, or any marketplace. The agent ingests public records (county appraisal districts, secretary of state, probate, tax rolls, code enforcement) plus operational signals (booking activity, review decay, website rot, social silence) and stacks them into a single 0–100 motivation score per parcel.

Output: a ranked list of off-market hospitality properties (micro resorts, glamping sites, boutique hotels, B&Bs, campgrounds, RV parks) that match the user's buy box, with owner contact pre-enriched and pre-drafted outreach attached.

**Tagline:** *"The properties that aren't on the market yet."*

This is the third pillar of the Deal Hound brand, surfaced at **dealhound.pro/offmarket**, sitting alongside the on-market hospitality product (`/`) and the SBA off-market product (`/sba`).

---

## 2. Strategic Premise: Why Off-Market Wins for Real Estate Too

We have run the same experiment twice:

| Approach | Status | Friction |
|---|---|---|
| **On-market scraping** (LandSearch, Crexi, BizBuySell, etc.) | Working but painful | Cloudflare, JS-rendered SPAs, IP bans, captchas, ToS exposure, brittle selectors. Every source is a separate maintenance burden. |
| **Off-market signal stacking** (SBA play — dental, vet, fire, insurance) | Working and pleasant | Public records are designed to be public. No anti-bot. No ToS conflict. Signals stack cleanly. |

The SBA run on 254 businesses across 6 verticals produced a clean ranked list with high-confidence retirement signals, and it took less infrastructure effort than maintaining a single on-market scraper.

**The thesis is that the same asymmetry holds for real estate, with one crucial advantage:** the off-market property data set already includes the parcel, owner, ownership history, and tax status as a single public record at the County Appraisal District — much cleaner than the multi-source assembly required for businesses. We already have the CAD scrapers built (Dallas, Bexar working; six more counties registered in `offmarket/scrapers/cad_registry.py`).

The conclusion is to invert the priority. On-market becomes a coverage tile. Off-market becomes the differentiator and the moat.

---

## 3. Target Users

### Primary
**Hospitality investors and operators** — micro-resort developers, glamping operators, boutique hotel investors, RV-park acquirers, B&B buyers. They are the same Deal Hound personas who are currently using the on-market product but starving for inventory because the good stuff sells off-market.

### Secondary
**Searchers (ETA) targeting hospitality** — same demographic as the SBA secondary, but seeking single-property hospitality businesses instead of service businesses.

### Tertiary
**Hospitality consolidators / portfolio operators** — groups assembling regional glamping or boutique hotel portfolios (Under Canvas competitors, Sunday Adventures roll-ups, AutoCamp peers).

---

## 4. Core Hypothesis

The probability that a hospitality property owner is willing to sell within 12 months can be estimated by stacking public signals across six categories:

1. **Owner Age / Life-Stage** — proxy for natural retirement timing
2. **Length of Ownership** — long-held assets correlate with eventual liquidity events
3. **Succession Vacuum** — no operational successor, no heirs in the business, out-of-state owner
4. **Operational Decay** — bookings declining, reviews stale, website rotting, social silent
5. **Financial Pressure** — tax delinquency, liens, code violations, mortgage age
6. **Life Events** — probate filings, divorce filings, LLC dissolution, registered-agent changes

When 4+ of these are present for a single parcel, the owner is statistically far more likely to engage on an unsolicited acquisition offer than the general property-owning population.

This is the same scoring discipline as the SBA product, retargeted at parcels.

---

## 5. Probability-of-Sale Scoring Model

Every matched parcel is scored 0–100.

### 5.1 Signal Weights

| Category | Signal | Weight | Source |
|---|---|---|---|
| **Owner Age** | Homestead OV65 exemption present (owner ≥ 65) | 12 | CAD exemption codes (where exposed — DCAD yes, HCAD masks) |
| **Owner Age** | Voter-file DOB places owner age ≥ 65 | 12 | TX voter file (restricted-use; same access caveat as SBA C1) |
| **Owner Age** | LinkedIn / public record graduation year ≤ 1985 | 6 | LinkedIn, web search |
| **Length of Ownership** | Owned 15+ years | 8 | CAD deed/acquisition date |
| **Length of Ownership** | Owned 25+ years | +5 (stacks) | CAD deed/acquisition date |
| **Succession Vacuum** | Owner address is out-of-state (absentee) | 8 | CAD owner address |
| **Succession Vacuum** | Title held by single individual (no LLC, no co-owner) | 6 | CAD title record |
| **Succession Vacuum** | LLC owner with no apparent heir/manager on filings | 5 | TX SOS officers list |
| **Operational Decay** | Property website last updated 2+ years ago | 6 | WHOIS, Wayback |
| **Operational Decay** | Most recent Google/TripAdvisor review > 90 days old | 6 | Google Places, TripAdvisor scrape |
| **Operational Decay** | Review velocity declining 50%+ YoY | 6 | Google Places history |
| **Operational Decay** | Listed on Airbnb/VRBO/Hipcamp but availability calendar mostly blocked | 5 | Listing scrape |
| **Operational Decay** | Last social post > 12 months ago (FB/IG primary handle) | 4 | Social scrape |
| **Financial Pressure** | Property tax delinquent in current or prior year | 10 | County tax assessor delinquent rolls |
| **Financial Pressure** | Code violation in last 24 months | 5 | City/county code enforcement |
| **Financial Pressure** | Mortgage 20+ years old (likely free-and-clear) | 4 | County deed records |
| **Financial Pressure** | Active lien or judgment on parcel | 6 | County clerk records |
| **Life Events** | Probate filing matching owner name in last 24 months | 10 | County probate court |
| **Life Events** | Divorce filing matching owner name in last 24 months | 6 | County district court |
| **Life Events** | LLC dissolution or "forfeited existence" status | 6 | TX SOS / Comptroller |

**Total possible: 100+** (capped at 100; multi-signal stacks above 100 still rank by raw sum to break HOT-tier ties).

### 5.2 Tier Thresholds

Mirrors the existing HOT / STRONG / WATCH schema across all Deal Hound products.

| Tier | Score | Meaning | Action |
|---|---|---|---|
| **HOT** | 80–100 | Multiple high-weight signals stacked. Owner likely already considering exit. | Mail / call this week. |
| **STRONG** | 60–79 | Real signal stack but motivation less acute. | Mailer sequence + 60-day follow-up. |
| **WATCH** | 40–59 | Partial signal. Worth tracking. | Drip nurture; re-score quarterly. |
| **Below 40** | 0–39 | Insufficient signal. | Discard. |

### 5.3 Risk Level (Separate from Tier)

Same convention as parent product. Tier = "how likely is the owner to engage." Risk = property/operational risk (deferred maintenance, location, regulatory exposure). They are reported as independent dimensions on the lead card.

### 5.4 Buy-Box Hard Gates (applied before scoring)

A parcel only enters the scoring pool if it satisfies the user's buy-box hard filters:

- **Geography** — state, counties, optional radius from a target city
- **Property type / use code** — CAD land-use codes filtered to hospitality-relevant classes (campground, hotel/motel, B&B, recreational, agricultural-with-improvements, etc.)
- **Acreage** — minimum / maximum
- **Assessed value range** — proxy for price (with multiplier band for under-assessment in tourism markets)
- **Existing improvements** — at least N structures, or vacant-land OK for development-strategy buyers

The hard gate is non-negotiable. Signals only fire after a parcel passes the gate.

---

## 6. Data Sources

### 6.1 Parcel + Owner (Spine)

| Source | What we get | Coverage | Access |
|---|---|---|---|
| **County Appraisal Districts (CAD)** | Parcel, owner name, owner address, acquisition date, land use code, improvements, assessed value, homestead/OV65 exemptions | TX (existing scrapers); other states via parallel build | Public; partial Playwright |
| **County Tax Assessor delinquent rolls** | Current/historic delinquencies | All TX counties (varies in exposure) | Public CSV / portal |
| **County Clerk deed records** | Mortgage age, lien history, ownership chain | TX statewide (county portals) | Public |
| **County Probate Court** | Probate filings by name | County-by-county | Public; some require Playwright |
| **County District Court** | Divorce filings by name | County-by-county | Public; some require Playwright |
| **TX Secretary of State** | LLC officers, registered agents, formation date, status | Statewide | Public web |
| **TX Comptroller** | Franchise tax status, forfeitures | Statewide | Public (existing Playwright driver) |
| **TX Voter File** | DOB anchor for owner age | Statewide | Restricted-use; same SBA C1 access path |

### 6.2 Operational Signals (only for parcels with operating hospitality businesses)

| Source | What we get | Access |
|---|---|---|
| **Google Places / Maps** | Reviews, review recency, photos, hours | Places API |
| **TripAdvisor** | Reviews, ranking trend | Public web (rate-limited) |
| **Airbnb / VRBO / Hipcamp / Glamping Hub / Tentrr** | Listing existence, availability, last review | Public web |
| **AirDNA / STR Insights** *(optional paid)* | Booking revenue trend | Paid API |
| **WHOIS + Wayback** | Domain age, last redesign | Public |
| **Facebook / Instagram** | Last post, follower trend | Public web |
| **Indeed / Google Jobs** | Staff hiring activity (housekeeping, front desk, ops manager) | Public web |

### 6.3 Owner Contact Enrichment (last-mile)

| Source | Purpose |
|---|---|
| **BatchSkipTracing / TruePeopleSearch** | Owner phone, email, mailing address |
| **Hunter.io / Apollo** | Pattern-based email when entity = LLC with website |
| **Property's own website** | Direct contact |
| **CAD owner mailing address** | Direct mail fallback (always present) |

---

## 7. Reuse of Existing Infrastructure

This is not a from-scratch build. The off-market property pipeline reuses substantial machinery already in the repo:

- **CAD scrapers** (`offmarket/scrapers/scrape_dcad.py`, `scrape_bcad.py`, `cad_registry.py`) — already classify each county as `works`, `blocked_spa`, or `blocked_by_law` and define alternative paths. Real-estate use just adds new query patterns (search by use-code + acreage, not by owner name).
- **TX Comptroller driver** (`scrape_comptroller.py`) — reused for LLC status checks on entity-titled parcels.
- **Scoring rules engine** (`offmarket/scoring_rules.py`) — extend to accept a `property_signals` category; the layered HOT/STRONG/WATCH machinery is unchanged.
- **Outreach drafting** (existing SBA pre-draft pattern) — same Claude prompt scaffold, swap the angle from "retirement" to "off-market acquisition interest."
- **Buy-box persistence + chat intake** (parent Deal Hound product) — reuse verbatim; only the buy-box schema gains property-specific fields.
- **Dashboard / results UI** (parent Deal Hound + SBA) — `/offmarket/results` follows the same two-section pattern (The Work + Top Leads).
- **Auth, billing, digest email** — fully shared.

Net new code is roughly: probate scraper, tax-delinquent-roll loader, deed scraper, operational-signals collectors, property-specific scoring weights, property buy-box schema, `/offmarket` landing page.

---

## 8. Buy Box → Lead Pipeline Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│  1. Buy box (conversational intake — reused from parent)         │
│     • geography (state, counties, radius)                         │
│     • property type (hospitality sub-types)                       │
│     • acreage min/max                                             │
│     • assessed-value band                                         │
│     • development vs. operating preference                        │
└────────────────────────┬─────────────────────────────────────────┘
                         │
┌────────────────────────▼─────────────────────────────────────────┐
│  2. Parcel spine build                                            │
│     • Pull CAD parcels matching hard gates                        │
│     • Resolve owner identity (individual / LLC)                   │
│     • Resolve LLC officers via SOS for entity-titled parcels      │
└────────────────────────┬─────────────────────────────────────────┘
                         │
┌────────────────────────▼─────────────────────────────────────────┐
│  3. Signal enrichment (parallel where possible)                   │
│     • Tax delinquency check                                       │
│     • Deed / mortgage / lien lookup                               │
│     • Probate + divorce court searches by owner name              │
│     • LLC status (Comptroller)                                    │
│     • OV65 exemption flag                                         │
│     • Voter file age anchor (where access exists)                 │
│     • Operational signals (if parcel has detectable hospitality   │
│       business: website, reviews, social, listing platforms)      │
└────────────────────────┬─────────────────────────────────────────┘
                         │
┌────────────────────────▼─────────────────────────────────────────┐
│  4. Scoring (0–100, tiered HOT / STRONG / WATCH)                  │
└────────────────────────┬─────────────────────────────────────────┘
                         │
┌────────────────────────▼─────────────────────────────────────────┐
│  5. Owner contact enrichment for HOT + STRONG only                │
│     • Skip trace for phone / email                                │
│     • CAD mailing address as direct-mail fallback                 │
└────────────────────────┬─────────────────────────────────────────┘
                         │
┌────────────────────────▼─────────────────────────────────────────┐
│  6. Pre-drafted outreach                                          │
│     • Letter (postal, primary channel for off-market)             │
│     • Email (where address discovered)                            │
│     • Call script                                                 │
└────────────────────────┬─────────────────────────────────────────┘
                         │
┌────────────────────────▼─────────────────────────────────────────┐
│  7. Persist + surface                                             │
│     • Supabase: off_market_leads table                            │
│     • JSON + CSV fallback (per CLAUDE.md)                         │
│     • Results dashboard at /offmarket/results                     │
│     • Weekly digest email                                         │
└──────────────────────────────────────────────────────────────────┘
```

Incremental refresh: re-pull signals weekly for HOT/STRONG, monthly for WATCH; re-score on each refresh and surface tier changes ("This lead moved from STRONG to HOT — owner just filed for probate").

---

## 9. Output Schema (Per Lead)

```
{
  parcel_id: string                       # CAD parcel identifier
  county: string
  state: string
  address: string
  legal_description: string
  acreage: number
  land_use_code: string
  improvements: [ { type, year_built, sqft } ]
  assessed_value: number
  estimated_market_value: number          # CAD AV + multiplier band

  owner_name: string
  owner_type: "individual" | "llc" | "trust" | "estate"
  owner_mailing_address: string
  owner_in_state: boolean
  owner_estimated_age: number | null
  acquisition_date: date
  years_held: number

  owner_email: string | null
  owner_phone: string | null
  owner_linkedin: string | null

  # If parcel has an operating hospitality business
  business: {
    name: string | null
    type: string | null              # "glamping" | "boutique_hotel" | "b&b" | ...
    website: string | null
    last_review_date: date | null
    review_count_12mo: number | null
    listing_platforms: string[]
  } | null

  motivation_score: number               # 0–100
  motivation_tier: "HOT" | "STRONG" | "WATCH"
  risk_level: "LOW" | "MODERATE" | "HIGH" | "VERY_HIGH"

  signals: [
    {
      category: string
      signal: string
      weight: number
      evidence: string
      source: string
      source_url: string
    }
  ]

  outreach_angle: string
  outreach_letter_subject: string
  outreach_letter_body: string
  outreach_email_subject: string | null
  outreach_email_body: string | null
  outreach_call_script: string | null

  scored_at: timestamp
  last_refreshed: timestamp
  status: "new" | "contacted" | "responded" | "rejected" | "in_progress"
}
```

---

## 10. Geographic Strategy

**MVP: Texas, four counties** — Dallas, Bexar, Travis (Austin metro for glamping), Hays (Austin exurbs / Wimberley, prime micro-resort country).

Rationale:
- Dallas + Bexar CAD scrapers already work.
- Travis + Hays cover the highest-density glamping / boutique-hotel cluster in Texas; Hays is on the CAD blocked-SPA list so the orchestrator will need to fall back via the registry's `alt_paths` (parcel search via TX Comptroller or third-party aggregator).
- Existing user base concentrated in Texas / Sun Belt.

Expansion after MVP validates: Colorado (mountain glamping), Tennessee (Smokies), North Carolina (Asheville), Arizona (Sedona) — pick states with strong public-records exposure and existing tourism-driven STR markets.

---

## 11. Vertical / Asset-Type Priorities

| Priority | Asset type | Why it's first |
|---|---|---|
| 1 | **Glamping sites + micro-resorts** | Highest signal density (operating businesses with web presence + reviews + listings), highest user demand, smallest deal sizes (better SBA fit) |
| 2 | **B&Bs and boutique inns** | Strong owner-age skew (silver tsunami), aging website tech, declining reviews are visible signals |
| 3 | **Campgrounds + RV parks** | Bigger acreage, often family-held 30+ years, generational succession problem |
| 4 | **Independent boutique hotels (<25 keys)** | Same demographic as B&B but bigger ticket; broker market is thin |
| 5 | **Raw land suitable for development** | No operational signals available; lean entirely on owner-age + length-of-ownership + financial pressure |

---

## 12. Surface

### 12.1 Landing — `dealhound.pro/offmarket`

Hero: *"The hospitality properties that aren't on the market yet."*

Above the fold:
- One-line value prop
- Live counter ("X off-market parcels scored this week")
- Sample anonymized lead card showing the signal stack
- CTA: "See leads matching my buy box →"

### 12.2 Buy-Box Intake — Conversational

Same chat pattern. Adds property-specific fields (acreage, use-code preferences, development vs. operating). Confirms in plain English. Editable anytime.

### 12.3 Results Dashboard

Two-section pattern, identical to parent + SBA:

**Section A — The Work** (collapsed)
- Parcels screened, source breakdown, hard-gate eliminations.

**Section B — Top Leads** (prominent)
- HOT / STRONG / WATCH ranked.
- Each card: parcel identity, owner identity, motivation score + signal stack, risk badge, suggested outreach angle, pre-drafted letter/email/call-script, action buttons (mark contacted / snooze / add to CRM).

### 12.4 Lead Q&A Chat

Identical pattern. Pre-loaded with parcel + owner + signal context. User can ask:
- "Why was this scored HOT?"
- "What's the comp set for this parcel?"
- "Draft me a follow-up if I don't hear back in 30 days."
- "What's a fair offer range based on the assessed value and operating signals?"

### 12.5 Weekly Digest

Subject: *"3 new HOT off-market properties — [Region]"* — only when new HOT/STRONG appear.

### 12.6 Export

CSV + JSON. CSV is the primary format for users pushing into direct-mail providers (Click2Mail, LobApi) or CRMs.

---

## 13. Auth, Pricing, Conversion

Auth: magic link, shared with parent.

Free tier: first 5 leads free (mirrors SBA).

Paid:
- **$299/month** — 50 fresh leads/week in one state, full enrichment, weekly digest, CSV export, unlimited Q&A.
- **$799/month** — Multi-state, 200+ leads/week, daily digest, direct-mail integration assist.

Pricing rationale: one closed hospitality acquisition typically yields $50K–250K+ in equity creation or commission. The price is set cheap relative to deal value.

Conversion trigger: same as SBA — free user hits the 5-lead cap or wants a second state.

---

## 14. Success Metrics

**Product health**
- Lead quality: % of HOT leads where outreach gets a reply (target: >8% letter reply, >15% phone connect)
- Score calibration: % of HOT owners who confirm they're considering selling (target: >20% within 90 days)
- Coverage: number of (asset-type × county) tiles fully indexed (target by month 3: 5 asset types × 4 counties = 20 tiles)
- Freshness: % of leads re-scored in last 30 days (target: 100%)

**Business health**
- Closed deals attributed (target: 1 per quarter first 6 months, 5+ per quarter by month 12)
- MRR, retention, CAC payback (same as SBA targets)

**Quality flags**
- Stale data rate (any signal sourced > 90 days flagged)
- False HOT rate (manual review of top leads — target <10%)

---

## 15. MVP Scope

### IN SCOPE for MVP
- **One state:** Texas
- **Four counties:** Dallas, Bexar, Travis, Hays (Hays via fallback path per CAD registry)
- **One asset type at launch:** glamping / micro-resort (use codes filtered to recreational + agricultural-with-improvements + small-acreage hospitality)
- **Pipeline:** CAD spine → SOS/LLC resolution → tax-delinquent + deed + probate + Comptroller enrichment → operational signals (where business detected) → score → enrich contact → pre-draft outreach → persist
- **Output:** dashboard at `/offmarket/results` + CSV/JSON export
- **Pre-drafted letter** (primary) + email (when found)
- **Weekly digest**
- **Auth, paywall, lead Q&A chat** — all reused

### OUT OF SCOPE for MVP
- Direct-mail send-on-behalf-of (Click2Mail integration is post-MVP)
- CRM push (post-MVP)
- Multi-state per user (one state per buy box at MVP, same as SBA)
- Live phone-dial integration
- Map-based UI (use list view first, add map view in v2)
- AirDNA / paid booking-data integration (gate to v2 — Google reviews proxy is good enough at MVP)

---

## 16. Build Order

1. **Property buy-box schema + chat intake extension** — add fields (acreage, use-code, dev-vs-operating) to existing buy-box flow.
2. **Parcel spine loader** — extend CAD scrapers from owner-name search to use-code + acreage filter; produce per-county parcel sets.
3. **LLC resolution** — for entity-owned parcels, route through existing TX SOS officer lookup.
4. **Tax-delinquent roll loader** — county-by-county, four counties at MVP.
5. **Deed / mortgage / lien scraper** — county clerk portals; reuse Playwright pattern from existing CAD work.
6. **Probate + divorce court scraper** — per-county district/probate court portals.
7. **Operational signals collectors** — Google Places, WHOIS/Wayback, social, Hipcamp/Airbnb/Glamping Hub listing matchers (parcel → listing fuzzy match by name + lat/long).
8. **Scoring extension** — add `property_signals` category to `offmarket/scoring_rules.py` with weights from §5.1.
9. **Owner contact enrichment** — wrap BatchSkipTracing API; CAD mailing address always present as fallback.
10. **Outreach pre-draft prompts** — Claude prompts for letter / email / call script; off-market hospitality angle.
11. **Persistence** — Supabase `off_market_leads` table + JSON fallback per CLAUDE.md.
12. **Results dashboard** — `/offmarket/results`, reuse two-section pattern.
13. **Weekly digest email** — reuse digest infra.
14. **Landing page** — `/offmarket` hero + sample card.
15. **Paywall trigger** — 5-lead free cap.

Estimated total LOE for MVP: 3–5 weeks of focused work, heavily dependent on county-portal scraper variance. The CAD-registry pattern from the existing offmarket suite means each blocked county already has a documented fallback path rather than blocking the build.

---

## 17. Risks and Open Questions

1. **Voter-file access** — same restricted-use issue flagged in SBA C1. Age is high-value but the file is access-controlled. MVP can ship without it (OV65 exemption + length-of-ownership + LinkedIn proxy carry most of the owner-age signal); voter file is a v2 upgrade once an access path is secured.
2. **Operational-signal coverage for raw-land plays** — pure land deals lack web/review signals. Score relies entirely on owner-age + financial-pressure + life-event signals. Acceptable but tier distribution will skew differently. Surface this in the buy-box flow ("dev plays score lower on average because we have fewer signals").
3. **Skip-tracing cost** — BatchSkipTracing is ~$0.20–0.50/lookup. Only run on HOT + STRONG (filtered post-scoring) to keep unit economics positive.
4. **Outreach compliance** — direct-mail to property owners is well-established and low-risk. Cold-email and cold-call have CAN-SPAM and TCPA implications; route those through user's own channel (we pre-draft, user sends).
5. **Cross-state expansion variance** — Texas public-records exposure is unusually good. CA, NY, FL each have very different probate/court portal patterns. Build state-by-state, not state-agnostic from day one.
6. **Listing collision** — what if a property we surface as HOT lists publicly the same week? That is a positive signal of model calibration; surface it in the UI ("Your HOT lead from 6 weeks ago just listed for $X — your offer is the anchor").

---

## 18. Relationship to Existing Products

| Product | Surface | Inventory source | Status |
|---|---|---|---|
| **Deal Hound (parent)** | `dealhound.pro/` | On-market hospitality marketplaces | Live, painful to maintain |
| **Deal Hound SBA** | `dealhound.pro/sba` | Off-market small business signals | Live (dental + 5 other verticals scored) |
| **Deal Hound Off-Market Properties** | `dealhound.pro/offmarket` | Off-market property signals | *This spec* |

These are three lenses on the same investment thesis. A single user buy box could surface deals across all three lanes in a unified results view ("9 on-market listings, 14 off-market property leads, 6 off-market operator leads") — that unification is a v2 goal once the off-market lane is producing leads at parity.

---

## 19. Decision Asks

Before building, lock in:

1. **State scope at MVP** — confirming TX-only, 4 counties.
2. **Asset type at MVP** — confirming glamping/micro-resort first.
3. **Voter-file inclusion** — defer to v2, ship MVP without it.
4. **Skip-tracing budget** — confirm BatchSkipTracing as default provider and HOT+STRONG-only filter.
5. **Outreach channel** — confirm direct mail primary, email secondary, no agent-side sending at MVP.
6. **Pricing** — confirm $299 / $799 tiers vs. matching SBA $199 / $499 (hospitality property leads have higher closed-deal value, so higher price is defensible — but want signal from user research before locking).
