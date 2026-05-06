# Deal Hound — Launch Strategy
*Version 1.0 — May 2026*

> Companion to [PRODUCT_SPEC.md](./PRODUCT_SPEC.md). PRODUCT_SPEC defines what we build. This doc defines how we launch, price, and grow it.

---

## TL;DR

- **Positioning shift:** Not a "deal scanner" — an **AI deal team**. Skills expand over time (deal scan → LOI → underwriting → comp analysis → market reports).
- **Pricing metric:** "Agent runs," not scans. Skill-agnostic. Each skill = 1 run, with per-skill COGS caps.
- **Tiers:** Founding ($49 lifetime, first 50) / Hunter ($79) / Investor ⭐ ($249) / Operator ($599).
- **Acquisition model:** Free async public scan tool (no signup, email gated for results). Public shareable report URL = viral loop.
- **Revenue target:** $15K MRR in 3 weeks from warm audience (IG + podcast + Mastermind).

---

## 1. Strategic Context

### Why the web app exists
The web app is a **bridge** to the long-term MCP-first product. Its job:
1. Generate cash to $15K MRR — fast.
2. Build the proprietary deal database that becomes the moat.
3. Acquire and prove out power-user customers who graduate to MCP later.

The MCP and the web app share the same skill layer. **Same product, two surfaces.** Don't architect them as separate products.

### Time horizon
- **Now → 3 weeks:** Launch web app to existing warm audience. Hit $5K MRR floor.
- **3 weeks → 60 days:** Iterate, add 2nd–3rd skills (LOI + underwriting), grow to $15K MRR.
- **60 → 180 days:** MCP version ships as power-user tier. Database becomes searchable/queryable for paying users.

---

## 2. Positioning

### Hero
> **Your AI deal team. Finds deals. Writes LOIs. Underwrites. Replaces 3 hours/day of grunt work.**
>
> Built for boutique hotel, micro resort, and STR investors who want velocity, not another dashboard.

### What we're NOT
- Not a listings aggregator (LoopNet, BizBuySell exist)
- Not a search tool (PropStream exists)
- Not a Claude wrapper (anchor against PropStream/Mashvisor pricing, not Claude $20/mo)

### What we ARE
A vertical AI agent platform that compounds in value with every skill we ship. Customers buy access to a growing team of specialized agents that handle the entire pre-acquisition workflow.

---

## 3. Pricing Structure

### Universal value metric: "Agent Runs"
- 1 deal scan = 1 agent run
- 1 LOI draft = 1 agent run
- 1 underwriting = 1 agent run
- 1 comp analysis = 1 agent run
- 1 market report = 1 agent run

User sees a single, simple count. Tiers gate by run quantity, not feature access. New skills unlock automatically for all paying tiers as we ship them.

### Tiers

| Tier | Price | Agent runs/mo | Saved searches | Skills | Notes |
|---|---|---|---|---|---|
| **Founding Member** | $49/mo lifetime | 10 | 1 | All current + future | First 50 only. 14-day window. |
| **Hunter** | $79/mo | 10 | 1 | All current + future | Standard entry tier (post-founding) |
| **Investor** ⭐ | $249/mo | 50 | 5 | All current + future | Recommended tier — most customers |
| **Operator** | $599/mo | Unlimited* | Unlimited | All current + future | *Per-run COGS cap still applies |

### Founding Member — exact terms
- $49/mo locked in **for life**, never increases as long as subscription stays active
- 10 agent runs/month
- 1 saved search with weekly auto-monitoring
- **Every future skill** automatically unlocks (LOI, underwriting, comps, market reports, etc.)
- "Founding Member" badge on profile + product
- Direct line to founder for feedback during beta
- First 50 only. Window closes after 14 days OR 50 signups, whichever first.

After cap closes: Hunter tier becomes the entry point at $79/mo, no future-skills lifetime guarantee.

---

## 4. Token Economics — Cost Caps

### Per-skill COGS budget (hard kill on overrun)
Each agent run has a maximum compute cost. Worker terminates if exceeded, returns partial result + "run capped — refine criteria for more depth."

| Skill | Max COGS / run |
|---|---|
| Deal scan | $1.50 |
| LOI draft | $0.50 |
| Underwriting | $2.00 |
| Comp analysis | $1.00 |
| Market report | $1.50 |

### Monthly compute ceiling per tier
Separate from agent run count — protects against high-COGS skill abuse (e.g., founder underwrites 50 deals).

| Tier | Run cap | Monthly compute hard cap | Margin at cap |
|---|---|---|---|
| Founding | 10 | $30 | 39% |
| Hunter | 10 | $30 | 62% |
| Investor | 50 | $150 | 40% |
| Operator | "unlimited" (200 soft) | $400 | 33% |

If user hits monthly compute cap before run cap, show:
> "You've used your monthly compute. Top up 5 runs for $25, or wait until next month."

Top-up SKU: 5 additional runs / $25, no compute cap (but per-run COGS still applies).

### Why this works
- Per-skill caps make any single run bounded
- Monthly compute cap defends against skill mix abuse
- Operator margin is the lowest because power users will run heavier skills more often — that's fine, they're paying $599
- Top-up SKU monetizes power users who genuinely need more without forcing them to upgrade

---

## 5. Free Tool Model (Public Async Scanner)

### What it is
A separate, public-facing tool at `dealhound.pro/free-scan`. **Not a freemium account.** Not a free tier of the paid product. A public marketing experience.

### Flow
1. User lands on `/free-scan`
2. Enters criteria (asset type, market, price range, etc.) + email
3. Sees confirmation: "Your AI deal hunter is searching now. Expect your report in your inbox within 60 minutes."
4. Confirmation page shows live progress + below-the-fold: testimonials, what's coming next, $49 Founding Member CTA
5. Async worker runs scan (capped at $1.50 COGS)
6. Email delivered with link to `dealhound.pro/scan/[id]` — beautiful public report
7. Public report page CTA: "Want this on autopilot every week? → Founding Member $49/mo"

### Why async + email is a feature, not a bug
- 60-min wait signals "real AI doing real work" — justifies premium pricing later
- Email gate is gentler than signup but stronger than no-gate — qualified leads only
- Inbox moment of delight beats passive page-watch
- Filters tire-kickers — anyone willing to wait is a real buyer

### Abuse defenses (stack)
- IP rate limit: 1 free scan per IP per day
- Cloudflare Turnstile or hCaptcha on form submission (kills 95%+ of bots)
- Email gate to view full report
- Per-scan $1.50 COGS hard cap (max bleed bounded even if abuse gets through)
- Monitor weekly, block bad IPs/email patterns as needed

Budget $50–100/mo abuse leakage as cost of doing business. ROI is fine if it generates leads worth $5K+ MRR.

---

## 6. Virality & Distribution

### Primary viral mechanic: Public Shareable Report URL
Every scan (free OR paid) produces a public URL at `dealhound.pro/scan/[id]`:
- No login required to view
- Beautifully formatted: deal photos, key numbers, AI analysis, comp matrix
- Branded header with Deal Hound logo
- CTA above and below: "Find your own deals like this — Free scan in 60 min"

Real estate investors share deals constantly (partner threads, deal Slacks, family office emails). Every share = free distribution.

### Phase 1 launch (weeks 1–3): SHIP
1. Public report URL with branded header — ✅ ship in week 1
2. "Share Report" button — copies link to clipboard
3. "Email Report" button — pre-fills mailto with subject + link

### Phase 2 (post first 50 customers): EXPAND
- One-click PDF export with watermark + footer CTA
- Refer-a-partner: refer paying customer = 1 month free
- Twitter/X auto-formatted "deal card" for share
- Public weekly "Best Deals Found" feed (SEO + viral)

**Do not build Phase 2 features pre-launch. They are excuses to delay.**

---

## 7. Beta / Launch Sequence

### Pre-launch (this week)
- [ ] Fix the broken end-to-end scan path (separate thread)
- [ ] Build `/free-scan` page with email gate + async confirmation
- [ ] Build public `/scan/[id]` report page with branded header + share button
- [ ] Implement per-skill COGS caps in worker
- [ ] Implement monthly compute ceiling tracking per account
- [ ] Set up Stripe with 4 tiers + top-up SKU
- [ ] Reposition homepage hero to "AI deal team"

### Launch week (week 2)
- [ ] Announce to Mastermind community first (private soft launch)
- [ ] Founding Member offer: $49/mo lifetime, first 50, 14-day window
- [ ] Email blast to podcast + IG + newsletter list
- [ ] 3 IG posts/week showcasing deals found by the agent
- [ ] 1 podcast episode about the launch with "use my AI agent" CTA

### Growth window (weeks 2–3)
- [ ] Daily IG content: "Deal of the Day" found by agent
- [ ] Public report URL share campaign — pin best deals to top of dealhound.pro
- [ ] DM existing Mastermind members directly with personalized free-scan demos
- [ ] Goal: 30 Founding Members + 5 Investor tier = $4,720 MRR by end of week 3

### Stretch goal: $15K MRR by week 6 with continued audience push

---

## 8. Decision Log

| # | Decision | Approved by Gideon | Date |
|---|---|---|---|
| 1 | Use "agent runs" as universal value metric, not scans | ✅ | 2026-05-06 |
| 2 | Founding Member tier: $49/mo lifetime, first 50, all future skills included, 14-day window | ✅ | 2026-05-06 |
| 3 | Reposition hero from "deal scanner" to "AI deal team" | ✅ | 2026-05-06 |
| 4 | Pricing: $79 / $249 / $599 (Hunter / Investor / Operator) | ✅ | 2026-05-06 |
| 5 | Free public scanner at `/free-scan` — async, email-gated, no account required | ✅ | 2026-05-06 |
| 6 | Per-skill COGS hard caps + monthly compute ceiling per tier | ✅ | 2026-05-06 |
| 7 | Money-back 7 days on paid tiers (replaces free trial) | ✅ implied | 2026-05-06 |
| 8 | Web app is a bridge to MCP, not a separate product | ✅ | 2026-05-06 |

---

## 9. Open Items / Risks

### Blocking
- **Product is broken end-to-end** — being debugged in separate thread. Launch sequence cannot start until a successful scan run is reproducible.

### Watch-list
- **Audience conversion rate unknown.** $15K MRR in 3 weeks assumes 1–3% paid conversion from warm audience of ~3K. If lower, extend timeline don't lower price.
- **Free tool abuse.** Monitor weekly for first 30 days; tighten if leakage exceeds $200/mo.
- **Skill velocity.** "All future skills included" promise to Founding Members only holds if we ship at least 1 new skill / 6 weeks. Slower = perceived value drops.
- **MCP cannibalization risk.** When MCP ships, Founding Members may want to use the MCP version with their lifetime price. Decide before MCP launch: include or charge separately?

### Deferred (not for launch)
- Annual pricing
- Team / multi-user accounts
- Refer-a-partner credits
- Public deal feed for SEO
- API access tier
- White label

---

## 10. Metrics to Track

### Daily (during launch window)
- Free scans started
- Free scans completed (delivered email)
- Free → paid conversion rate
- Founding Member signups (countdown to 50)

### Weekly
- MRR by tier
- Churn (target: <5% monthly)
- Avg agent runs / customer / month
- COGS per customer (margin check)
- Public report URL shares (track via analytics)
- Top-up SKU purchase rate (signal of pricing pressure)

### Pricing health signals (review at 30 days)
- "Too cheap" feedback → raise prices
- Conversion rate >40% → raise prices
- Top-up purchase rate >20% → consider raising Investor tier run count
- Founding Member churn after $49 lifetime → diagnose: skill velocity? quality?
