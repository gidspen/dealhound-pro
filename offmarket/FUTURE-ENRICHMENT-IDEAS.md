# Off-Market Acquisition Scorer — Future Enrichment Ideas

**Status:** Backlog. Reviewed at a future date.

**Context:** During the 2026-05-15 multi-vertical run (Fire + Insurance + Vet + Optometry = 254 scored businesses), we identified four high-value enrichment paths and executed on them in this session:

1. ✅ Playwright-driven CAD homestead lookup (executed in this session)
2. ✅ Playwright TX Comptroller driver (executed in this session)
3. ✅ Live successor-check team-page fetch on missing B candidates (executed in this session)
4. ✅ TDI SFMO PIA request drafted as Superhuman draft (ready to send)

The ideas below are the **remaining 15 enrichment options** — categorized by ROI tier — flagged here for future review and decision.

---

## Tier A — Medium-value (improves scoring confidence; not a direct A-tier unlock)

### A1. D&B Hoovers / ZoomInfo subscription
**Why valuable:** Hardens Layer 2 (sellability + SBA-size). Revenue + employee count + HQ-vs-branch structure. Currently we estimate revenue from chair-count / truck-count / employee proxies — D&B gives validated numbers.
**Cost:** D&B ~$300/mo entry tier. ZoomInfo varies (~$15k/yr enterprise). Tradeoff: precise numbers vs. proxy-acceptable for off-market scoring.
**When to revisit:** When 2-3 active acquisition conversations are in motion — pays for itself on size-band validation alone.

### A2. SBA 7(a) public loan data
**Why valuable:** SBA publishes change-of-ownership loan data with borrower legal names. Cross-referencing catches businesses that already traded hands (auto-route to D_pass) AND establishes pricing benchmarks for SBA-comparable deals in your target verticals.
**Cost:** Free (SBA public dataset).
**Implementation:** Build a one-time matcher script: spine_legal_name vs. SBA 7(a) borrower roster. Lightweight.
**When to revisit:** Before next full run — easy automation, high return.

### A3. IRS Form 5500 (retirement plan filings)
**Why valuable:** Public filings, accurate employee count + asset levels per plan year. Great Layer 2 confirmation when D&B is too expensive.
**Cost:** Free (DOL bulk data + EFAST2 search).
**Implementation:** Build a 5500-lookup integration. Match by EIN (we don't have most EINs but the Comptroller's `entity_sos_file_number` cross-walks to EIN via SOS filings).
**When to revisit:** After Comptroller spine integration is solid (post-PIA + post-Playwright).

### A4. Indeed Hiring Lab + historical job-posting data
**Why valuable:** Direct cross-validator for the "no producer hiring in 24 mo" coasting tell. Better than the Google-search proxy we used this run.
**Cost:** Indeed API is paid/restricted; LinkedIn Jobs has historical data via Sales Navigator. Glassdoor is free-ish via scraping.
**Implementation:** Per-vertical job-title list + Playwright crawls of LinkedIn Jobs.
**When to revisit:** When you want to harden Layer 3 (coasting) signals — would shift several C_watch rows to B_forward.

### A5. USPTO trademark filings
**Why valuable:** Strong businesses file trademarks (proxy for institutional brand investment). Coasting ones don't. Free signal.
**Cost:** Free (USPTO TESS / TSDR public search).
**Implementation:** USPTO TSDR has a CSV API. Match by trademark owner-of-record → business legal name. Lightweight.
**When to revisit:** When you want a Layer 2 differentiator for borderline B vs. C candidates.

### A6. Google Maps Street View for fleet + building photos
**Why valuable:** Visual confirmation of staff scale + capex freshness — fire trucks, vet vans, optometry storefronts, insurance office signs. Often reveals "owner owns the building" (real estate-attached deal structure).
**Cost:** Free (manual review) or $0.007/image via Maps API.
**Implementation:** For top 15-30 candidates per run, Street View screenshot the business address. Manual review or LLM image-evaluation pass.
**When to revisit:** Optional polish for top-of-list deep-dive packets to forward to ETA community.

---

## Tier B — M&A intelligence (catches recent deals before public Google does)

### B1. PitchBook / Mergr / PrivSource subscriptions
**Why valuable:** Real-time M&A intelligence — catches platform acquisitions weeks/months before they hit Google. This run found 11+ post-spine platform acquisitions; PitchBook would have caught all of them at spine build time.
**Cost:** PitchBook ~$15-25k/yr. Mergr ~$500-2k/yr. PrivSource ~$5k/yr.
**Implementation:** API integration. Match candidate legal_name against M&A deal database; flag any post-2023 deals as `recent_acquisition=true`.
**When to revisit:** When you've committed to running this scorer quarterly — recurring intelligence subscription pays off across 4+ runs/yr.

### B2. PACER federal civil filings
**Why valuable:** Catches civil litigation that Google news search misses. Helps with the distress hard-gate (Item 5 of A-tier deep-dive).
**Cost:** $0.10/page. PACER account required.
**Implementation:** PACER search by entity legal_name + registered_agent. Build a wrapper.
**When to revisit:** When you find a candidate you want to write an offer for — last-mile due diligence check.

### B3. TX Comptroller franchise-tax accountability page (deeper than entity search)
**Why valuable:** Lists tax-forfeited businesses, often a distress signal beyond basic entity_status. Has historical tax-filing data.
**Cost:** Free (TX Comptroller public).
**Implementation:** Per-candidate Playwright drive on the accountability search URL (different from entity search).
**When to revisit:** During the next Playwright-driver build session — easy add-on.

### B4. Glassdoor / Indeed company reviews
**Why valuable:** Employee sentiment proxy. Coasting practices often have falling Glassdoor ratings (frustrated CSRs, no producer career path, owner not paying for raises).
**Cost:** Free via WebFetch / Playwright (some pages need login for full reviews).
**Implementation:** Per-candidate Glassdoor + Indeed scrape; sentiment trend over 24 mo.
**When to revisit:** Phase 5 deep-dive enrichment polish; not a primary gate.

---

## Tier C — Long-tail / restricted-access

### C1. TX voter file (DOB anchor)
**Why valuable:** Voter DOB is a high-confidence Layer 1 anchor (`owner_age_source = "voter_dob"`).
**Cost:** Restricted-use. Free for political committees / candidates / certain research. Gideon's config explicitly notes this is "internal-only Gideon-research" — needs careful access path.
**Implementation:** Apply for voter file access via Texas Secretary of State (party-affiliation route or PIA). Build voter-DOB-matcher.
**When to revisit:** When you have a sustained acquisition pipeline (5+ active conversations) — the data is sensitive enough that scale justifies the compliance overhead.

### C2. DMV DL DOB
**Why valuable:** Same as voter DOB but more universal coverage.
**Cost:** DPPA-restricted. Federal Driver's Privacy Protection Act restricts non-permitted-use. Gideon's config explicitly notes restricted-use.
**Implementation:** TX DMV requires a "permitted use" affidavit; insurance investigators, attorneys, and certain commercial uses qualify. Likely not a clean fit for off-market research.
**When to revisit:** Probably not. Treat as "unavailable" and rely on OV65 + voter file alternatives.

### C3. LinkedIn Sales Navigator
**Why valuable:** Full profile data, tenure histories, accurate employee counts. Currently we use Google "<name> linkedin" snippets — Sales Navigator gives the full picture.
**Cost:** $80/mo individual; $99/mo Team.
**Implementation:** API + per-candidate enrichment.
**When to revisit:** Worth subscribing once you have 3+ active conversations — pays for itself fast.

### C4. Probate / obituary monitoring services
**Why valuable:** Catches owner deaths that change deal dynamics (estate sale = different motivation + timeline + buyer pool). Sensitive but legitimate research signal.
**Cost:** Specialized services exist (e.g., LegacySuite, Ancestry/Newspapers.com); some are paid.
**Implementation:** Subscribe + cross-reference with owner_name list quarterly.
**When to revisit:** When pipeline is mature; useful but not first-order.

### C5. Industry trade publication archive monitoring
**Why valuable:** Fire Apparatus & Equipment, Insurance Journal, Veterinary Practice News, Optometric Management — these often surface owner-retirement announcements early (3-6 mo before public deal closes).
**Cost:** Some are paid subscriptions; some have free archives.
**Implementation:** Set up Google Alerts on owner_name + practice_name for each top-15 candidate.
**When to revisit:** Free version is easy (Google Alerts); paid version when pipeline is mature.

---

## Tier D — Aspirational / experimental

### D1. AI-driven phone-call vibe check
**Why interesting:** Call the practice as a prospective customer (or a researcher openly), record the experience, evaluate "is this practice tired / understaffed / coasting?". Vapi / Bland.ai / similar voice AI can do this at scale.
**Cost:** Vapi-level voice AI ~$1-5/call; scale-quality call ~$5-20/call.
**Concern:** This crosses into outreach territory per the skill's non-negotiable #6 ("no outreach, no contact"). Would need careful framing — "research call" not "sales call". Probably best skipped.
**When to revisit:** Not soon. Too close to the no-outreach line.

### D2. Synthesized "Mystery Shop" via Yelp / Google reviews
**Why interesting:** New Yelp / Google reviews left by recent customers contain real-time service-quality signals. Coasting practices often have "Dr. X seemed tired" / "wait time too long" / "front desk forgot my appointment" reviews.
**Cost:** Free (review data is public).
**Implementation:** Sentiment-classify the last 20 reviews per candidate. Identify "burnout / understaffing / disorganization" signals.
**When to revisit:** Lightweight follow-on to existing Google review velocity check; would enhance Layer 3 (coasting) scoring.

### D3. Google Business Profile photo analysis
**Why interesting:** GBP photos are often updated quarterly; stale GBP photos (last update > 2 yrs) is a strong coasting tell. Plus capex visibility (new equipment in photos vs. dated).
**Cost:** Free / GBP API.
**Implementation:** Per-candidate GBP photo timeline; LLM-classify "modern" vs. "dated".
**When to revisit:** Easy add-on; defer until other items are cleared.

### D4. WHOIS history + domain age check
**Why interesting:** Domain registration history reveals if the practice was ever a different brand (mid-life rebrand = sometimes a distress signal). Plus old WHOIS records sometimes reveal owner contact info.
**Cost:** Free (WHOIS) / DomainTools paid.
**Implementation:** Per-candidate WHOIS lookup + Wayback Machine deeper crawl.
**When to revisit:** When you want to expand Layer 3 (coasting) signals.

### D5. Cross-vertical owner-network mapping
**Why interesting:** Same owner runs businesses across verticals (e.g., a fire-protection shop owner who also owns a dental practice through investment). Catching cross-vertical ownership reveals "professional investors" who don't fit the "tired owner" thesis.
**Cost:** Free (SOS data joins).
**Implementation:** Cross-vertical SQL query on `registered_agent` + `owner_name` after each run.
**When to revisit:** After 6+ months of running this scorer; data accumulates over time.

---

## Notes for future review

1. **Tier A1 (D&B) and Tier B1 (PitchBook) are the highest-leverage paid options.** Both would pay for themselves quickly if you maintain a steady acquisition pipeline. Revisit when 2-3 active deals are in motion.

2. **Tier A2 (SBA 7(a) public data), A5 (USPTO), B3 (Comptroller accountability), D3 (GBP photo analysis) are all free + easy** — these are the natural next sprints once the Playwright driver is productionized.

3. **Tier C1 (voter file) and C2 (DMV) require explicit compliance posture** — Gideon's CLAUDE.md and the skill's config both flag these as restricted-use. Don't pursue these without clear approval + access plan.

4. **The biggest gap exposed by this run is M&A intelligence freshness** — 11+ candidates in the 256-row spine had been acquired by platforms within the prior 12 months. PitchBook or Mergr would catch these at spine build time, dramatically improving signal quality and saving enrichment time.

5. **Quarterly cadence assumption:** if this scorer runs once per quarter (4 verticals × 60-80 candidates = 240-320 rows/quarter), the per-run cost of paid subscriptions amortizes well. Single-run economics don't justify D&B ~$300/mo. Quarterly economics do.
