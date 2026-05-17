# New Vertical Configurations — 2026-05-16 Autonomous Expansion Run

These configurations supplement [verticals.md](/Users/gideonspencer/.claude/skills/offmarket-acquisition-scorer/verticals.md) for verticals NOT yet configured in the skill but added during the 2026-05-16 19-hour autonomous run.

**Selection thesis:** Aging-owner SBA-financeable Texas businesses with recurring revenue and active consolidator pressure → highest probability of finding a buyable business that meets Gideon's thesis. Mix high-PE-attention (hot multiples, exit liquidity) and low-PE-attention (cheap entry multiples, less competition for the buy) verticals.

**Geographic targets (all Wave 1-3 verticals):** Harris, Dallas, Tarrant, Bexar, Travis priority; adjacent counties (Collin, Denton, Williamson, Fort Bend, Galveston, Brazoria, Montgomery, Hays, Comal, Guadalupe, El Paso) acceptable for volume.

---

## WAVE 1

### W1-A. Funeral homes & deathcare services (NAICS 812210)

**Why this vertical:** Highest family-ownership rate of any small-business sector (~90%). Multi-generational with aging founders entering 60s/70s. Strong consolidator pressure (SCI, Carriage Services, Park Lawn, NorthStar). Recurring + needs-based revenue (deaths happen; cremation rate rising = lower-cost transactions but higher volume). SBA 7(a) financeable; established multiples 4-6x SDE for funeral homes, 6-9x EBITDA for cemeteries.

**Spine source:**

- **Primary:** TX Funeral Service Commission (TFSC) Provider Search at `prodengage.tfsc.texas.gov/PublicLicensingService/LicenseSearch` — search by license type "Funeral Establishment" + city/county. Returns establishment-level records (each funeral home is one license).
- **Spine fetch protocol:** Likely interactive search UI; Playwright fallback needed for bulk extraction.
- **Secondary:** TDLR doesn't regulate funeral homes (TFSC is independent). Cross-check Google + Yelp + funeral-industry directory (Funeral Home & Cemetery News, ICCFA member directory).
- **Statutory basis:** Tex. Occ. Code Ch. 651.

**NAICS + filters:**

- NAICS: 812210 (Funeral Homes and Funeral Services).
- **Exclude SCI/Dignity-branded:** SCI brands include Dignity Memorial, Neptune Society, Advantage Funeral. Verify via website footer or "owned by Service Corporation International."
- **Exclude Carriage Services brands.**
- **Exclude Foundation Partners Group brands.**
- **Exclude Park Lawn / NorthStar / Legacy / InvestCare brands.**
- **Include independent family-name funeral homes**, especially same-surname multi-generation (e.g., "Smith Funeral Home, 4th generation").

**Successor candidate definition:**

- Second-generation or third-generation family member on the staff page → STRONG successor (line continues).
- Licensed funeral director listed for 5+ yrs as "Director" or "Manager" → MEDIUM successor.
- Single licensed FD/Embalmer with no successor on team page → NO SUCCESSOR (target).

**Recurring-revenue language (Layer 2):**

- "preneed contracts," "prearrangement plans," "advance planning," "trust-funded preneed."
- "perpetual care fund," "endowment care fund" (cemetery component, increases value).
- "veteran services," "Medicare/Medicaid burial benefits," "funeral pre-arrangement."
- "cremation packages," "memorial society," "burial insurance partnership."
- Healthy mix: 30-40% preneed (recurring written), 50-65% at-need, 10% merchandise + cemetery.

**Coasting tells (Layer 3):**

- Single licensed FD; same-surname owner-operator for 30+ yrs.
- Website built pre-2018, no online obituaries (just listing of names), no online preneed planner.
- Same building since 1980s/1990s; no chapel renovation visible; aging signage.
- Reviews flat or declining; obit-listing not updated within 7 days.
- No cremation-with-memorial / "celebration of life" / pet aftercare additions (industry shift owner missed).
- Family-owned building (CAD ownership = owner LLC).
- No mention of preneed sales force / no preneed counselor on staff.
- Hearse/limo fleet looks aged on Google Maps Street View.

**Active acquirer platforms (Layer 4):**

- **Service Corporation International (SCI/Dignity Memorial):** Public co (NYSE: SCI), 1,500+ TX locations; dominant aggregator. Targets $1.5M-$10M revenue funeral homes.
- **Carriage Services:** Public co (NYSE: CSV), select acquisitions, smaller footprint.
- **Park Lawn Corporation:** Canadian-listed, US-focused growth.
- **NorthStar Memorial Group:** PE-backed (Charlesbank).
- **Foundation Partners Group:** Access Holdings-backed, ~125 locations.
- **InvestCare Partners:** Smaller roll-up.
- **Family Tree Funeral Care:** TX-specific roll-up.
- SBA 7(a) financeable: Yes, very. Funeral homes are top-quartile SBA-financed verticals.
- ETA / search-fund appetite: HIGH (Stanford Search Fund Study lists deathcare as a top-10 vertical).
- Multiples: SDE 4-6x for $300K-$1.5M SDE; EBITDA 6-9x at $1M+ EBITDA; premium for cemetery component.

**SBA-size estimation:**

- 50-100 calls/yr funeral home, 1 FD, no cemetery ≈ $400K-$800K rev.
- 100-250 calls/yr, 2-3 FDs ≈ $800K-$2M rev.
- 250-500 calls/yr ≈ $2M-$4M.
- 500+ calls/yr (large family business) ≈ $4M+.
- EBITDA: 15-25% for funeral home only; 25-40% for combined funeral home + cemetery.
- Pre-need contract base is balance-sheet value (1-1.5x of trust value typically).

**Sub-market nudges (Layer 4):**

- **Major TX metro (Houston, DFW, Austin, SA):** +0 baseline.
- **High-Hispanic-population metros (Houston, SA, Dallas, RGV):** +3 (growing demographic, deathcare is culturally important; family-owned advantage).
- **Hill Country / aging-retiree areas (Hill Country, Burnet, Llano, Comal, Hays):** +5 (boomer death rates).
- **East TX / rural (Tyler, Longview, Lufkin):** +3 (less consolidator competition).
- **Border / RGV (Cameron, Hidalgo):** +3 (cultural moat against SCI rollup).

**Notes:**

- Funeral homes are EMOTIONALLY HARD to value — owners attached to legacy. Successor verification is HARDER because family successors often delay announcing.
- License board (TFSC) discipline = strong distress flag. Cross-check disciplinary actions in `tfsc.texas.gov/disciplinary-actions`.
- Owner age verification via OV65 is RELIABLE here — funeral home owners typically own their building AND live in the area long-term.
- Pet aftercare / pet cremation is an adjacent service some homes offer; not the target but mention is a coasting positive (industry-leading owner).

---

### W1-B. Independent pharmacy (NAICS 446110)

**Why this vertical:** Aging owner-pharmacists with no clear succession. Hot consolidator pressure from chains (CVS, Walgreens, Walmart, Costco, Amazon, Mark Cuban Cost Plus Drugs) eating into volume. PBM (Pharmacy Benefit Manager) pressure squeezing margins — pushes owners to consider exit. Recurring Rx revenue (75-85% of business), needs-based, prescription refill economics built in. SBA 7(a) financeable up to $5M; independent pharmacies trade 3-5x SDE.

**Spine source:**

- **Primary:** TX State Board of Pharmacy License Search at `www.pharmacy.texas.gov/dbsearch/dbsearchpharmacy.asp` — search by city, county. License types: **Class A** (community/retail pharmacy, the target), Class B (nuclear), Class C (institutional/hospital), Class D (clinic), Class E (out-of-state), Class F (freestanding ER). **Target Class A only.**
- **Spine fetch protocol:** Search UI returns HTML table; should be reachable via WebFetch or simple Playwright. If blocked, fall back to PIA request to `info@pharmacy.texas.gov`.
- **Secondary:** Cross-check with NCPDP (National Council for Prescription Drug Programs) provider directory + NPI registry + Surescripts directory.
- **Statutory basis:** Tex. Occ. Code Ch. 551-566.

**NAICS + filters:**

- NAICS: 446110 (Pharmacies and Drug Stores).
- **Exclude chain pharmacies:** CVS, Walgreens, Walmart, HEB, Kroger, Tom Thumb, Target/CVS, Costco, Sam's Club. Identify by national-brand name + registered agent.
- **Exclude hospital outpatient pharmacies** (different reimbursement model).
- **Exclude compounding-only pharmacies** without retail Rx (different valuation).
- **Include:** Family-name independents, multi-location small chains (2-5 stores under one owner = STRONG target), HBA-compounding hybrid retail.

**Successor candidate definition:**

- Second pharmacist (RPh) listed on staff page for 5+ yrs → MEDIUM successor.
- Family-surname pharmacist (son/daughter as PharmD) → STRONG successor (line continues).
- Pharmacist-in-Charge (PIC) different from owner → MEDIUM-WEAK successor (PIC is staff, not owner).
- Solo pharmacist-owner, no other RPh on staff → NO SUCCESSOR (target).

**Recurring-revenue language (Layer 2):**

- "automatic refill," "Rx synchronization," "med sync program," "auto-fill," "free local delivery."
- "compounding services," "hormone replacement therapy (HRT)," "specialty compounding."
- "diabetes care," "MTM (medication therapy management)," "Medicare Part D," "Medicaid pharmacy."
- "vaccine clinic," "immunization services," "flu shots," "COVID/RSV/shingles vaccines."
- "long-term care services," "nursing home Rx," "blister packs," "compliance packaging."
- "specialty pharmacy" (IF documented — high value).
- "Good Neighbor Pharmacy," "Health Mart," "Cardinal Health Leader pharmacy" (independent banner programs — sign of professional ops).
- Healthy mix: 75-85% Rx (recurring), 10-20% OTC/HBA, 5-10% services (vaccines, MTM).

**Coasting tells (Layer 3):**

- Single pharmacist-owner, 50+ yrs old, no associate RPh.
- Website built pre-2015 or no website at all (some Class A pharmacies still phone-only).
- No online refill / no app integration / no text-message refill reminders.
- No specialty services on offer (no diabetes/COPD/HRT clinic, no MTM billing).
- Storefront photos look aged on Google Maps Street View (sometimes still has 1970s/80s signage).
- Same building since 1980s/1990s; owner owns the building.
- Reviews flat; vaccine traffic absent (no COVID/flu vaccine listings on site).
- No e-prescribing software upgrade visible (PioneerRx, McKesson Pharmaserv, Liberty, FrameworkLTC are modern; ComputerRx, RX30 also modern; Cerner RetailRx, older NDCHealth = aging).
- No Medicaid Pharmacy Program enrollment visible (state-by-state — TX = Medicaid managed care).
- Owner is also PIC AND fills Rx daily AND owner — carrying full operational load.

**Active acquirer platforms (Layer 4):**

- **Aggregators / consolidators:**
  - **Cardinal Health (Good Neighbor Pharmacy):** Banner program → some indirect acquisition flow.
  - **AmerisourceBergen (Good Neighbor / Elevate Provider Network):** Same.
  - **McKesson (Health Mart):** Same.
  - **DiplomatCare / OptumRx specialty arms.**
  - **PE platforms:**
    - **HealthCenter Pharmacy** (TX-active).
    - **Family Choice Pharmacy** (TX consolidator).
    - **Pharmacy Development Services (PDS) Network.**
- **Strategic buyers:**
  - **CVS Caremark** acquires independents in specific markets (less now post-2018 chain saturation).
  - **Walgreens** — opportunistic.
  - **Local hospital systems** (CHRISTUS, Memorial Hermann, Methodist, Baylor Scott & White) — buy adjacent pharmacies for 340B program eligibility.
- **SBA 7(a) financeability:** YES, up to $5M. Independent pharmacy is top-quartile SBA-financed.
- **ETA / search-fund appetite:** HIGH (recurring Rx revenue + regulatory moat = ideal searcher profile).
- Multiples: SDE 3-5x for $200K-$800K SDE; EBITDA 5-7x at $500K+ EBITDA; recent PBM compression has pushed multiples down 0.5-1x vs. 2019.

**SBA-size estimation:**

- Solo pharmacist, 1 store, 100-200 Rx/day ≈ $1.5M-$3M rev.
- 1 store, 200-400 Rx/day ≈ $3M-$6M rev.
- 2-store chain ≈ $5M-$10M rev.
- 3+ stores ≈ $7M-$20M rev.
- Gross margin: 18-25% (PBM-compressed; specialty/compounding pharmacies 30-40%).
- EBITDA margin: 6-12% retail; 15-25% with specialty/compounding mix.

**Sub-market nudges (Layer 4):**

- **High-rural-elderly TX (East TX, Hill Country, RGV):** +5 (CVS/Walgreens density lower; demographics favorable).
- **Hispanic-majority metros (RGV, El Paso, SA south side, Houston east):** +3 (cultural pharmacy loyalty, Medicaid mix).
- **Major TX metro suburban:** +0 baseline.
- **Inner-city urban (downtown Houston, Dallas):** -3 (Walgreens / CVS density high, neighborhood evolution = reduced volume).
- **Compounding-heavy specialty:** +5 (premium niche, hot category, recent FDA scrutiny consolidating the market).

**Notes:**

- **PBM/DIR fee compression is the dominant industry headwind** — owners are exhausted by the regulatory and reimbursement environment. This is BOTH a coasting trigger (push factor) AND a Layer 4 negative (depressed multiples). Net is still positive for our thesis (motivated sellers).
- **Owner-age verification via OV65 is RELIABLE** — pharmacy owners typically live in the metro for 20-40 yrs.
- **Distress checks specific:** Look for FDA warning letters, DEA registration suspensions, Medicaid Fraud Control Unit (MFCU) actions, Medicare exclusion list (LEIE) — any of these = D_pass.

---

### W1-C. CPA / Accounting firms (NAICS 541211)

**Why this vertical:** The most aging-owner small business sector. ~40% of CPAs in TX are 55+; AICPA reports 75% of public-practice CPAs plan to retire in the next 15 yrs. Strong recurring tax/audit revenue (60-80% recurring annual). Low consolidator pressure (only ~5% of small CPA firms are platform-affiliated), low PE attention historically but rising — Aprio, Citrin Cooperman, EisnerAmper, Schellman, BDO, RSM, CohnReznick, Wipfli all rolling up regional firms. Strong SBA 7(a) financeability; CPA firms trade 1-1.5x revenue or 4-6x SDE for small shops, 6-8x EBITDA for mid-size.

**Spine source:**

- **Primary:** TX State Board of Public Accountancy (TSBPA) Firm Search at `www.tsbpa.texas.gov/php/exam-fp/find_firm.php` — search by city/county. Returns firm name, license #, address, contact partner, original issue date.
- **Spine fetch protocol:** Simple PHP search form; WebFetch should work. Fall back to Playwright if needed.
- **Secondary:** AICPA member directory, TXCPA chapter directories (Houston CPA, Dallas CPA, Austin CPA, SA CPA chapter sites), Google Maps "accounting" + "[city]."
- **Statutory basis:** Tex. Occ. Code Ch. 901.

**NAICS + filters:**

- NAICS: 541211 (Offices of Certified Public Accountants).
- **Exclude Big 4** (PwC, Deloitte, EY, KPMG) and national firms (BDO, Grant Thornton, RSM, CohnReznick, Crowe, Aprio, Citrin Cooperman, EisnerAmper, Marcum, Schellman, Wipfli, Plante Moran).
- **Exclude tax-prep chains** (H&R Block, Jackson Hewitt, Liberty Tax) — different business model.
- **Include:** Solo CPAs and 2-15 partner regional firms with practice mix of tax + audit + advisory + bookkeeping. Family-name firms are STRONG candidates.

**Successor candidate definition:**

- Second CPA partner on the firm page (not associate; partner-level) → MEDIUM successor.
- Family-surname CPA partner (son/daughter as CPA) → STRONG successor.
- Long-tenured (10+ yr) CPA associate with director/principal title → MEDIUM successor.
- Solo CPA with bookkeeping staff but no second CPA → NO SUCCESSOR (target).
- 2-3 partner firm all 55+ with no younger partner → NO SUCCESSOR (target — group exit).

**Recurring-revenue language (Layer 2):**

- "year-round bookkeeping," "monthly close," "outsourced controller," "outsourced CFO," "fractional CFO," "advisory retainer."
- "annual tax return preparation," "quarterly estimates," "1099 filing," "sales tax filing."
- "annual audit," "review engagement," "compilation," "single audit," "ERISA audit," "401k audit."
- "QuickBooks ProAdvisor," "Xero certified," "Sage certified."
- "payroll services," "Paychex partner," "ADP partner," "Gusto partner."
- "wealth management," "investment advisory," "RIA" (if firm has CPA/PFS — often dual revenue).
- Healthy mix: 40-55% annual tax (recurring), 20-30% audit/review (recurring annual for retainer clients), 15-25% advisory + bookkeeping (highest recurring).

**Coasting tells (Layer 3):**

- Single CPA, 60+ yrs old, no younger CPA in pipeline.
- Practice age 25+ yrs at same address, same client base.
- Website built pre-2015 or templated/generic (CCH SiteBuilder, Thomson SiteWorx default templates from 2010-2012 = coasting tell).
- No online client portal (no SmartVault, Canopy, Liscio, ShareFile portal visible).
- No tax/audit software modernization (CCH Axcess, ProSystem fx — modern; Lacerte, ProSeries, Drake — common; ATX — common; UltraTax — common; if site says "fax your documents" = aging).
- Mostly paper-based workflow (no e-file portal, no DocuSign integration, no e-signature mentioned).
- LinkedIn shows no new associates / staff accountants hired in 3+ yrs.
- No advisory/CFO services on offer (just compliance work).
- No social media presence; no blog updates in 2+ yrs.
- Owner is also tax preparer AND audit partner AND firm administrator.

**Active acquirer platforms (Layer 4):**

- **Top PE-backed consolidators (very active 2024-2026):**
  - **Citrin Cooperman** (TowerBrook-backed).
  - **Aprio** (Charlesbank + Warburg Pincus).
  - **Schellman & Co** (Lightyear).
  - **EisnerAmper** (TowerBrook).
  - **CBIZ** (public).
  - **Wipfli** (PE-backed regional).
  - **BPM** (PE).
  - **Withum** (PE-backed).
  - **Cherry Bekaert** (Apax-backed).
  - **Carr Riggs & Ingram** (independent acquirer).
- **Strategic / national:** BDO USA (private), RSM (Stone Point investment), Baker Tilly (Hellman & Friedman + Valeas).
- **TX-active regional:** Whitley Penn, Brewer Eyeford, Maxwell Locke & Ritter (Austin), Calvetti Ferguson (Houston).
- **SBA 7(a) financeability:** YES. CPA firms are top-quartile SBA-financed (recurring revenue, professional license moat).
- **ETA / search-fund appetite:** RAPIDLY RISING. Stanford Search Fund Study now lists prof services + accounting as top-15. Solo CPA $500K-$2M SDE = perfect searcher profile.
- Multiples: 1-1.5x revenue or 3-5x SDE for solo firms; 5-7x EBITDA for $1M+ EBITDA; premium for advisory/audit mix.

**SBA-size estimation:**

- Solo CPA + 1-2 staff ≈ $300K-$700K rev.
- Solo CPA + 3-5 staff ≈ $700K-$1.5M.
- 2-3 partner firm ≈ $1.5M-$4M.
- 4-10 partner firm ≈ $4M-$10M.
- Revenue per CPA: $250K-$500K typical; advisory-heavy = higher.
- EBITDA / SDE margin: 30-45% solo; 20-30% multi-partner.
- Tax-only solo: lower; full-service with audit/advisory: higher.

**Sub-market nudges (Layer 4):**

- **Major TX metro suburban:** +3 (high client density of small businesses).
- **Premium suburban (West Lake Hills, Plano West, Sugar Land, Bellaire, Southlake):** +5.
- **Hot business-growth metros (Austin, Frisco/Allen, Cypress):** +5.
- **Houston/Dallas/Austin downtown:** +3 (mid-market client base; high competition).
- **Exurban / smaller cities (Tyler, Lubbock, Amarillo, Beaumont):** +0 (steady local biz client base).
- **Rural TX:** -3.

**Notes:**

- **CPA firms have inherent succession risk** — clients leave when partners retire if no younger partner inherits relationships. Buyer typically requires 1-2 yr transition agreement.
- **"Boomer retirement wave" is currently peaking** — many CPA owners 65-72 right now, hard exit deadlines.
- **License-board distress signal:** TSBPA disciplinary action (yellow flag for malpractice, gross negligence) = serious. Check `www.tsbpa.texas.gov/php/exam-fp/disciplinary.php`.
- **PCAOB registration** (if firm does public-company audits) = institutional moat, premium multiple. Check `pcaobus.org/registrationandreporting/firm-registration`.
- **Owner age verification:** OV65 + license-issue-date proxy (TX CPAs typically obtain license at 25-28; 60-yr-old CPA has 30-35 yrs tenure).

---

### W1-D. Hearing aid clinics / Audiology (NAICS 446199 + 621399)

**Why this vertical:** Hot consolidator pressure (Sonova/Phonak, Demant/Oticon/HearingLife, Amplifon/Miracle-Ear, GN Hearing, Costco/KS9 hearing aid pricing pressure). Aging owner-audiologists/hearing aid dispensers reaching their own retirement. Recurring revenue: hearing aids are $3-7K cash-pay devices with 5-yr replacement cycles + accessories + warranty + repair revenue. Needs-based for senior population (aging TX = growing market). SBA 7(a) financeable; clinics trade 4-6x SDE.

**Spine source:**

- **Primary:** TDLR Hearing Instrument Fitters and Dispensers License Search at `www.tdlr.texas.gov/LicenseSearch/` — license type "Hearing Instrument Fitter and Dispenser" (HIF/HID).
- **Secondary:** TX State Board of Examiners for Speech-Language Pathology and Audiology (TSBESLPA) audiologist registry at `apps.web.maine.gov/online/aeviewer/ME/14/searchOptions.html` — wait this is Maine. TX board is at `www.dshs.texas.gov/speech-language-pathology-audiology` and the audiologist license search is via TDLR portal (recent consolidation 2022).
- **Spine fetch protocol:** TDLR uses standard search portal; WebFetch should work for individual queries. For bulk, fall back to TDLR's published license roster CSV via PIA.
- **Tertiary:** American Speech-Language-Hearing Association (ASHA) directory + Hearing Industries Association manufacturer dealer directories (Phonak, Oticon, Widex, Starkey, Signia/Sivantos, ReSound = top 6 manufacturer dealers).

**NAICS + filters:**

- NAICS: 446199 (All Other Health and Personal Care Stores — covers hearing aid retail).
- Also: 621399 (Offices of All Other Miscellaneous Health Practitioners — for audiologist private practice).
- **Exclude chain dispensers:**
  - **Miracle-Ear** (Amplifon-owned).
  - **HearingLife** (Demant-owned, was Audibel/Beltone in some markets).
  - **Beltone** (GN-owned).
  - **Connect Hearing** (Sonova-owned).
  - **Audibel** (Starkey-owned).
  - **Costco Hearing Aid Center** (Costco-internal).
  - **Sam's Club hearing center.**
- **Exclude ENT-owned dispensaries** (different business model — physician practice).
- **Include:** Independent owner-audiologists/HID with 1-4 staff, family-name clinics, small multi-location (2-5 clinics) regional independents.

**Successor candidate definition:**

- Second licensed HID/audiologist on staff (5+ yrs tenure) → MEDIUM successor.
- Family-surname (often spouse audiologist) → STRONG successor.
- Solo licensed owner, only assistant staff → NO SUCCESSOR (target).

**Recurring-revenue language (Layer 2):**

- "annual hearing test," "free hearing evaluation," "battery clubs," "wax removal service."
- "trial period," "30-day satisfaction guarantee," "loss & damage protection."
- "hearing aid repair," "warranty service," "free hearing aid cleaning."
- "tinnitus management," "vestibular rehabilitation," "cochlear implant evaluation."
- "VA / Veterans Choice provider," "Federal Blue Cross provider."
- Healthy mix: 65-75% hearing aid sales (cash-pay, 5-yr cycle), 10-15% accessories + batteries (recurring), 10-20% service + repair (recurring).

**Coasting tells (Layer 3):**

- Solo licensed dispenser, 60+ yrs, no associate HID.
- Same office since 1990s, no remodel.
- No telehealth fitting (current tech enables remote programming — owner not modernizing).
- No "rechargeable hearing aid" promotion (industry-defining feature since 2018).
- Website looks 2010-era.
- No reviews-management; newest Google review 3+ months old.
- No social media presence; no patient education content.
- Only carries 1-2 manufacturer brands (Phonak/Oticon only; doesn't offer ReSound, Widex, Signia, Starkey — limits competitive positioning).
- "By appointment only" / Mon-Thu hours.
- Owner is also the dispenser + fitter + receptionist.

**Active acquirer platforms (Layer 4):**

- **Direct manufacturer-owned chains** (vertical integration — strongest acquirers):
  - **Sonova** (Phonak/Connect Hearing/Audibel-Lansing) — most aggressive.
  - **Demant** (Oticon/HearingLife/Bernafon).
  - **Amplifon** (Miracle-Ear).
  - **GN ReSound/Beltone.**
  - **Starkey/Audibel.**
- **PE-backed networks:**
  - **Avada Hearing Care Centers** (PE-backed).
  - **Specialty Network/Concert Hearing.**
- **SBA 7(a) financeability:** YES.
- **ETA / search-fund appetite:** RISING (recurring health + aging demographic).
- Multiples: SDE 3-5x for $200K-$800K SDE; EBITDA 5-7x at $500K+ EBITDA.

**SBA-size estimation:**

- Solo HID, 1 location ≈ $300K-$900K rev.
- 1 location with audiologist + HID ≈ $600K-$1.5M.
- 2-3 location group ≈ $1.5M-$4M.
- Cash-pay margins: 40-55% on hearing aids ($3-7K device retail, $1.5-3K manufacturer cost).
- EBITDA: 15-25% solo; 20-35% multi-location with leverage.

**Sub-market nudges (Layer 4):**

- **High-senior-population TX (Hill Country, Williamson Co, Comal Co, Galveston Co, RGV):** +5.
- **Major TX metro suburban affluent:** +5 (cash-pay demographic).
- **Major TX metro urban:** +0.
- **Rural TX:** -3 (driving distance limits patient pool).
- **VA-clinic-adjacent areas (San Antonio, Killeen, El Paso, Houston):** +5 (VA contract revenue stream).

**Notes:**

- **Costco hearing aid pricing pressure is significant** — Costco sells hearing aids at $1,500-$2,500/pair vs. independent $4,000-$7,000/pair. Independent owners feel this; motivates exits.
- **Telehealth / remote fitting is fragmenting industry** — younger audiologists are using teleaudiology while older HIDs are not. Strong coasting tell.
- **Audiologist (AuD) > HID (license)** — audiologists have doctoral training, can diagnose hearing loss, fit cochlear implants, do vestibular work. HIDs only dispense aids. A clinic with audiologist on staff = higher service mix, premium multiple.

---

## WAVE 2 (To be added when Wave 1 spines complete)

### W2-A. Pool service & maintenance (NAICS 561790)

### W2-B. Garage door services (NAICS 238290 / 444190)

### W2-C. Landscaping / commercial lawn maintenance (NAICS 561730)

### W2-D. Painting contractors — residential + commercial (NAICS 238320)

## WAVE 3 (To be added when Wave 2 spines complete)

### W3-A. Welding / metal fabrication shops (NAICS 332710 / 332323)

### W3-B. Glass services — flat + shower (NAICS 238150)

### W3-C. Janitorial / commercial cleaning (NAICS 561720)

### W3-D. Industrial machine shops — CNC (NAICS 332710)
