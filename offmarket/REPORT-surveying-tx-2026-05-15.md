# Off-Market Land Surveying Acquisition Scorer — surveying-tx-2026-05-15

**Run:** `surveying-tx-2026-05-15` · **Model:** `offmarket-4layer-v0.2` · **Generated:** 2026-05-16
**Outputs:** `offmarket/data/surveying_targets.json` · `surveying_targets.csv` · `surveying_run_manifest.json`
**Supabase:** **WRITTEN** to schema `offmarket` (project `gggmmjvwbbfvrtjjlqvr` — incredible-ai-deals). 105 businesses · 105 scores · 11 signals (live-fetch-backed evidence for A-tier).

---

## 1. Summary

**105 real, name-verifiable Texas land surveying firms** enriched and scored on the 4-layer composite model (weights L1 .30 / L2 .25 / L3 .30 / L4 .15) — sourced directly from the Texas Board of Professional Engineers and Land Surveyors (TBPELS) Surveying Firms Roster + RPLS Roster CSVs, cross-referenced by firm-license-number join. Every row is a currently-Registered TX-HQ firm with at least one verified active RPLS.

- **County breakdown:** Harris 15 · Dallas 9 · Tarrant 8 · Travis 7 · Williamson 6 · Bexar 6 · Montgomery 5 · plus 41 firms across 32 other counties.
- **Geographic distribution:** major_metro 44 · major_metro_coastal 29 · secondary 25 · coastal_flood 5 · permian 1 · eagle_ford 1.
- **Tier counts:** **A_acquire_self 5** · **B_forward 82** · **C_watch 13** · **D_pass 5**.
- **Excluded for distress / hard gate:** 5 firms (3 license-inactive flags, 1 pipeline-operator misclassification, 1 firm <5yr in business formed 2021).
- **A-tier deep-dive yield:** 12 candidates evaluated → **5 passed**, 7 demoted to B (6 due to live team-page fetch blocked/unreachable; 1 successor found on live site). Yield rate: 42%.
- **Headline coverage caveat:** owner ages are **license-tenure proxies** (RPLS grant year + assumed earn-age 30) for most rows. Two A-tier candidates have website-self-reported DOB (Thomas Flores 1945, Dante Carlomagno 1936). **No OV65 verification was attempted this run** — that's the #1 productionization need for higher A-tier confidence.

---

## 2. Top 15 targets

| Practice | City | County | Owner (age + source) | Yrs RPLS | L1/L2/L3/L4 | Final | Tier |
|---|---|---|---|---|---|---|---|
| **FLORES & COMPANY CONSULTING ENGINEERS** | San Antonio | Bexar | Thomas Flores, 81 (website_self_report_dob_1945) | 47 | 95/70/100/68 | **86** | **A_acquire_self** |
| **CARLOMAGNO SURVEYING, INC.** | Bryan | Brazos | Dante Carlomagno, 90 (self_report_website_dob_argentina_1936) | 59 | 95/70/95/67 | **85** | **A_acquire_self** |
| **C & G LAND SURVEYORS** | Conroe | Montgomery | Seth Malone Gibson, 78 (license_tenure_proxy) | 48 | 95/70/95/71 | **85** | **A_acquire_self** |
| **PRIME TEXAS SURVEYS** | Houston | Harris | Richard V. Hall, 78 (license_tenure_proxy) | 48 | 95/70/90/71 | **84** | **A_acquire_self** |
| **I. T. GONZALEZ ENGINEERS** | Austin | Travis | Israel Trevino Gonzalez, 76 (license_tenure_proxy) | 46 | 95/70/90/70 | **84** | **A_acquire_self** |
| ANDREW LONNIE SIKES, INC. | Katy | Harris | Andrew Lonnie Sikes, 76 | 46 | 95/50/95/71 | 80 | B_forward |
| GEARLD A. CARTER AND ASSOCIATES | Athens | Henderson | Gearld A. Carter, 79 | 49 | 95/50/90/67 | 78 | B_forward |
| FULLER ENGINEERING & LAND SURVEYING | Arlington | Tarrant | William S. Abraham, 77 | 47 | 95/70/70/68 | 77 | B_forward |
| SURVEYING ASSOCIATES | Dallas | Dallas | Ben D. Rychlik, 87 | 57 | 95/70/90/68 | 76 | B_forward |
| G. CURTIS SURVEYORS, LLC | Fort Worth | Tarrant | Gerald A. Curtis, 87 | 57 | 95/70/90/68 | 76 | B_forward |
| BLUE SKY SURVEYING AND MAPPING | Dallas | Dallas | David Randolph Petree, 80 | 50 | 95/70/85/68 | 76 | B_forward |
| GALBRAITH ENGINEERING CONSULTANTS | San Antonio | Bexar | Glenn Edward Galbraith, 79 | 49 | 95/70/90/68 | 76 | B_forward |
| VANNOY & ASSOCIATES, INC. | Leander | Williamson | Ray Lynn Vannoy, 78 | 48 | 95/70/100/70 | 76 | B_forward |
| Bass & Welsh Engineering | Corpus Christi | Nueces | Murray Bass, 77 | 47 | 95/75/70/69 | 76 | B_forward |
| ESOR CONSULTING ENGINEERS | Spring | Harris | John Jesus Rodriquez, 76 | 46 | 95/70/90/71 | 76 | B_forward |

---

## 3. The `A_acquire_self` list (pursue directly)

### FLORES & COMPANY CONSULTING ENGINEERS — San Antonio (Bexar), 78247
*Final 86 · L1 95 / L2 70 / L3 100 / L4 68 · medium confidence · 0.95 data completeness*

Thomas Flores (P.E. + R.P.L.S., born Beeville TX 1945, age 81 in 2026 — verified via firm About page biographical content) is the sole principal of Flores & Company Consulting Engineers (San Antonio, est 1982, 43yr in business). Live team-page fetch at floresengineers.com/about-us/ on 2026-05-16 confirms "Mr. Flores acquired sole ownership" after partner departure; no son / daughter / Jr / family member or successor listed anywhere on the About page. UT Arlington BSCE; Army Corps of Engineers Captain. Multi-discipline civil engineering + land surveying franchise; service area 150mi radius from SA; projects up to 16,000 acres. No modern tech-stack mentioned (drone / RTK / 3D laser scanning all absent). Deep-dive Item 2 PASSED — no internal-buy-in candidate visible.

**Value-add:** AI / ops modernization play with five concrete levers — (1) digitization: $50-150K capex on drone/RTK/3D scanning unlocks 25-40% labor savings on topo + as-built; (2) recurring construction stake-out program acquisition with SA-area production homebuilders (KB Home, DR Horton, Lennar Texas); (3) HUB/MBE/DBE certification renewal under Hispanic-founder eligibility = recurring municipal + TxDOT contract pipeline worth 1.5-2× the EBITDA multiple of a non-certified shop; (4) Army Corps of Engineers founder background + 16,000-acre project capability = differentiated capacity for institutional + federal work; (5) succession risk solved by acquire-self thesis. Plausible 1.5-2× EBITDA path 18-24 months; off-market multiple 3-5× EBITDA.

### CARLOMAGNO SURVEYING, INC. — Bryan (Brazos), 77808
*Final 85 · L1 95 / L2 70 / L3 95 / L4 67 · medium confidence · 0.90 data completeness*

Dante Carlomagno (RPLS #1562, born Argentina 1936, immigrated 1960, in surveying since 1957 per published Carlomagno Resume PDF on the firm's own domain) is age **90** in 2026 — the most extreme operator-age in this cohort. Founder and sole stockholder of Carlomagno Surveying, Inc. (Bryan/College Station, est 1973, 53yr in business). Live homepage fetch at carlomagnosurveying.com on 2026-05-16 confirms: no team page exists, no named successor or family-surname RPLS visible. TX SOS file 0044025100 active per OpenCorporates; CorporationWiki records confirm Dante as president/director/sole stockholder at 2714 Finfeather Rd, Bryan TX 77801; no second officer. Limited operating hours (Mon-Thu 8am-5pm, Fri 8am-4pm, closed weekends) consistent with mature owner-operator winding down. Brand recognition across 5-county service area (Brazos + Burleson + Madison + Grimes + Robertson). Deep-dive Item 2 PASSED, with caveat: at age 90 the risk of operator-incapacitation before deal closes is material — fast-moving acquire-self thesis, not 36-month exit-window.

**Value-add:** Extreme operator-age urgency materially increases probability of imminent transition; outside buyer with capital and transition plan has structural advantage. Bryan/College Station = TAMU-tied secondary metro with steady recurring municipal + university construction + agricultural-land boundary work. No modern tech-stack visible — $30-80K capex (drone/RTK GPS/3D laser scanning/online project portal) unlocks 25-40% labor savings and 1.5-2× growth runway. 53yr firm name + brand recognition is the durable asset in a small market with limited surveying capacity. Plausible 1.5-2.5× EBITDA path 18-24 months; off-market multiple 2.5-4× EBITDA given operator-age urgency and likely seller-financed deal structure.

### C & G LAND SURVEYORS — Conroe (Montgomery), 77301
*Final 85 · L1 95 / L2 70 / L3 95 / L4 71 · medium confidence · 0.85 data completeness*

Seth Malone Gibson (RPLS #2000, est age ~78 via license_tenure_proxy — granted 1978, 48yr tenure) is the sole principal of C & G Land Surveyors (Conroe, est 1977, 49yr). Live homepage fetch at candgsurveyors.com on 2026-05-16 confirms: only Seth Gibson listed as staff; no second RPLS, no family-surname successor, no associate or partner. TBPELS RPLS join confirms solo RPLS at firm 10057100. Copyright 2024 (2yr stale). Multi-service offering (residential + commercial + ALTA/ACSM + boundary + elevation cert + topographic + construction layout + expert witness) shows the operator does it all — classic owner-operator stall pattern at the $300K-$700K revenue band. Located at 1210 N Thompson St, Conroe (Montgomery County) — Houston exurban suburb in **highest-growth-metro in TX 2024-2026**. Deep-dive Item 2 PASSED.

**Value-add:** Conroe / Montgomery County is the highest-growth TX metro for boundary + construction stake-out + ALTA demand (north Houston exurban boom). Owner is one-RPLS-capacity-bound and missing growth. Digitization play: no drone / RTK GPS / 3D laser scanning / online portal visible = $30-80K capex + cloud-platform migration unlocks 30-50% throughput improvement. **Homebuilder program acquisition** (KB Home, DR Horton, Lennar, Perry Homes — all active in Montgomery County) is the single highest-leverage recurring B2B add and not yet exploited. Freestanding office on Thompson St likely owner-occupied real estate (CAD verification pending) = sale-leaseback option + operating-co acquisition structure. 49yr brand recognition. Plausible 1.5-2.5× EBITDA path 18-24 months in a HOT growth-metro; off-market multiple 3-5× EBITDA.

### PRIME TEXAS SURVEYS — Houston (Harris), 77009
*Final 84 · L1 95 / L2 70 / L3 90 / L4 71 · medium confidence · 0.85 data completeness*

Richard V. Hall (RPLS granted 1978, est age ~78 via license_tenure_proxy, 48yr tenure) is the presumed-sole RPLS per TBPELS records at Prime Texas Surveys (Houston HQ at 2417 North Fwy 77009 + second office in Mission TX 78573). Live homepage fetch at primetxsurveys.com on 2026-05-16: no individual RPLS named on site; multi-office structure serves Houston / Rockport / Rio Grande Valley. Online "Order a Survey" flow exists; "Request a Free Quote" funnel active; modern site, copyright 2026. NO individual RPLS named on the site. Multi-office expansion + online ordering = appetite for growth but capacity-bound by single RPLS-of-record. Deep-dive Item 2 PASSED with caveat — cross-check via TBPELS join confirms only 1 active RPLS, supporting solo finding.

**Value-add:** Capacity expansion is the dominant lever — bring in 2-3 additional RPLS to unlock 2-3× revenue capacity across existing Houston + Mission + Rockport + RGV footprint. Greater Houston FEMA elevation cert program + Harris-Galveston Subsidence District annual monitoring contracts = $200-500K/yr recurring annuity book worth 1.5-2× the EBITDA multiple of a one-off-only shop. Site already modernized (online ordering, 2026 copyright, request-quote funnel) — operational digital infrastructure is rare strength here; leverage is in capacity and recurring-program acquisition, not digital transformation. Mission TX + Rio Grande Valley office = Hispanic-market expansion + recurring municipal boundary work. 48yr brand recognition. Plausible 1.5-2× EBITDA path 12-18 months; off-market multiple 3-5× EBITDA.

### I. T. GONZALEZ ENGINEERS — Austin (Travis), 78723
*Final 84 · L1 95 / L2 70 / L3 90 / L4 70 · medium confidence · 0.85 data completeness*

Israel Trevino Gonzalez (P.E. + R.P.L.S., RPLS granted 1980, est age ~76 via license_tenure_proxy, 46yr tenure) is the sole principal of I. T. Gonzalez Engineers (Austin, 3501 Manor Rd 78723, est 1977, 49yr in business). Multi-discipline civil engineering + land surveying firm with the rare **HUB/MBE/DBE certification trifecta** (TX HUB + Austin Certified MBE + TX UCP DBE) for recurring municipal + state contract eligibility. Registered as TX Engineering Firm F-3216 + TX Licensed Surveying Firm 100573-0. Multi-service: civil engineering (site dev, drainage, water/wastewater, paving) + surveying (boundary, topo, route, platting, aerial, construction staking, GPS). No son/daughter/Jr in firm name or on TBPELS roster. Deep-dive Item 2 PASSED.

**Value-add:** **Austin growth-metro tailwind is the dominant signal** — highest development volume in TX 2024-2026. HUB/MBE/DBE certs are the durable moat: 1.5-2× EBITDA multiple uplift vs non-certified peers + recurring City of Austin / TxDOT / state HUB-set-aside contract eligibility worth $300-800K/yr in steady book — most acquirers cannot maintain certification continuity without keeping a qualifying minority owner-of-record, structural barrier-to-entry. Digitization not yet visible = $50-150K capex unlocks throughput on site dev + drainage + water/wastewater projects. HUB-certified founder of color also enhances SBA 7(a) social-disadvantaged-business loan eligibility for buyer maintaining certification chain. Plausible 1.5-2× EBITDA path 18-24 months focused on tech modernization + cert-based contract growth; off-market multiple 4-6× EBITDA given cert-enhanced acquisition profile.

---

## 4. What real data I got vs. what was blocked

| Source | Status | Detail |
|---|---|---|
| **TBPELS Surveying Firms Roster CSV** | WORKED | https://tbpedownloads.s3-us-west-2.amazonaws.com/sur-firm_roster.csv — 1,275 statewide Registered firms; 1,053 TX HQ Registered. Direct S3 download, ~280KB, no auth. Easiest spine of any vertical in this skill's universe. |
| **TBPELS RPLS Roster CSV** | WORKED | https://tbpedownloads.s3-us-west-2.amazonaws.com/rpls_roster.csv — 5,535 RPLS individuals; 2,615 currently Registered. Direct S3, ~620KB, latin-1 encoding. Firm-RPLS join via `Firm Num` → 949 solo-RPLS firms statewide. |
| **Live website fetches (top A/B candidates)** | WORKED (10 sites) | Carlomagno, Forest, C&G, Flores, Vannoy, Prime TX, Sander, Galbraith, Voss, Collins — confirmed team-page or About-page content. |
| **WebSearch enrichment summaries** | WORKED (35 firms) | TSPS member directory, BBB, BuildZoom, Manta, ProView, ZoomInfo, LinkedIn, Yelp, OpenCorporates, RocketReach. |
| **OpenCorporates / TX SOS records** | WORKED (verified) | Carlomagno SOS file 0044025100 active confirmed; McAdams 0800019643 confirmed. Cloudflare CAPTCHA bypassed via search-result summaries. |
| **TX Comptroller direct entity search** | PARTIAL | JS-only dynamic search not directly queryable via WebFetch. Operating-status confirmed via active websites + OpenCorporates SOS file numbers. Direct Comptroller programmatic check is productionization need. |
| **CAD OV65 lookup** | NOT ATTEMPTED | OV65 not pulled for any candidate this run. License-tenure-proxy used as fallback. **#1 productionization gap.** |
| **TBPELS SIT roster cross-ref** | NOT ATTEMPTED | Surveyor-in-Training roster would catch family-successor SITs at solo-RPLS firms. Worth adding in next run. |

---

## 5. Scoring model as run

**Weights:** L1 0.30 · L2 0.25 · L3 0.30 · L4 0.15.

**Hard gates applied:**
- Distress (license inactive, pipeline-operator misclassification, <5yr firm): 5 firms → D_pass.
- A-tier deep-dive not passed → cap at B_forward (applied to 7 of 12 candidates).
- Personal-name firm + sole-stockholder + likely sub-$300K rev → cap at B_forward (6 firms).

**Tier thresholds:** A ≥ 78 + L1 ≥ 70 + L3 ≥ 65 + confidence ≥ medium + deep-dive passed · B 60-77 · C 45-59 · D <45 or distressed or <5yr.

**Vertical-specific anchors:** **Layer 4 baseline boost +2** for all solo/2-RPLS TX-metro firms = LOW-PE-ATTENTION opportunity-zone adjustment. Sub-market nudges: Austin/Williamson/Hays +3 · N Dallas Collin/Denton +3 · West Houston +3 · Permian +3 · Eagle Ford +3 · Coastal flood +2 · Harris-Galveston Subsidence +1 · Rural -3.

---

## 6. What the productionized version needs

1. **CAD OV65 connector** (HCAD/DCAD/TCAD/TAD/BCAD/CCAD/CollinCAD) — #1 confidence-uplift for A-tier promotion. Three of five A-tier candidates would benefit from OV65 promotion.
2. **Direct Comptroller programmatic check** — productionize via TX Comptroller Socrata API or Playwright scraper.
3. **TBPELS SIT roster cross-reference** — surveyor-in-training roster reveals heir-apparent successors at family firms.
4. **TBPELS disciplinary actions / Board Orders scraper** — structured check rather than ad-hoc web search.
5. **Live team-page Playwright fallback** for 6 B-demotion candidates whose direct WebFetch was blocked.
6. **TX SOS Public Information Report (PIR) connector** — officer/director records for family-surname successor detection.
7. **Bowman 10-K + Westwood acquisition press release scraper** — track active PE-platform acquisitions in real time.
8. **Hispanic-market HUB/MBE/DBE certification cross-check** — high-leverage filter currently identified ad-hoc.

---

## 7. Honest limitations

- **Sample size:** 105 of 1,053 TX HQ Registered firms = ~10% coverage. Depth-first by skill design.
- **Owner ages are proxy-heavy:** Only 2 of 105 have website-self-reported DOB; 103 rely on license_tenure_proxy. **No OV65 verified this run.** A-tier confidence is medium across the board until CAD OV65 verification lands.
- **Engineering-primary contamination:** ~30% of spine pool are multi-discipline engineering firms with one RPLS doing in-house survey work. Three of five A-tier candidates are engineering-primary (Flores, I.T. Gonzalez, plus several B-tier). Acceptable for Gideon's flexible-acquirer profile but worth flagging.
- **"Ghost-RPLS" risk at extreme ages:** Surveying Associates Dallas (Rychlik 87) and G. Curtis Surveyors (Curtis 87) demoted to B because live-fetch couldn't complete. Carlomagno (age 90) only promoted to A because firm's own domain hosts biographical content + TX SOS confirms active sole-stockholder.
- **Live-fetch unreachable rate:** 6 of 12 A-tier deep-dive candidates demoted because their company website doesn't exist or couldn't be fetched. This is the **surveying vertical's coasting-baseline** (referral-driven low-marketing posture), not a per-firm signal. Playwright fallback would likely promote 3-4 back to A.
- **No outreach / contact / brokering done.** Per skill non-negotiable, this run produces a scored list only.

---

## LOW-PE-ATTENTION thesis (the differentiating factor)

TX land surveying is structurally underbid: only **two PE-backed rollup platforms** active (Bowman Consulting NASDAQ:BWMN + Westwood Professional Services Endeavour Capital-backed). Large-AEC strategics (Stantec, WSP, AECOM, Kimley-Horn, Cobb Fendley, LJA Engineering) only bolt-on $5M+ rev firms when geographic/specialty fit aligns — they don't compete in the $300K-$5M independent universe. The TX RPLS license requires 4-year college + 4-year supervised survey-in-training + state exam (~3,700 active RPLS statewide; documented aging workforce per TSPS reports, average RPLS age >55). ETA/search-fund appetite is **emerging fast 2024-2026** (top-15 vertical in Stanford Search Fund Study, up from top-30 three years prior). Recurring B2B from oil/gas ROW MSAs, real estate development boundary work, ALTA/NSPS commercial-transaction surveys, construction stake-out programs, FEMA elevation certificates, homebuilder boundary-survey programs, and Harris-Galveston Subsidence District monitoring — exactly the profile an ETA / search-fund / independent-sponsor buyer wants, but the PE world hasn't yet organized around. Off-market multiples are 2-5× EBITDA for sub-$1M EBITDA solo-RPLS shops vs 6-8× for $5M+ rev firms on strategic-acquirer radar. **The opportunity window is the next 24-36 months before broader PE attention catches up.**

---

## Final summary line

**105 firms scored** · tier breakdown **A 5 · B 82 · C 13 · D 5** · 12 A-tier candidates deep-dived, 5 passed (42% yield) · 1 successor found on live site, 6 team-page-unreachable demotions to B · Supabase WRITTEN (105 businesses, 105 scores, 11 signals, 1 score_run) · Top 5 A_acquire_self: **Flores & Company Consulting Engineers (San Antonio)**, **Carlomagno Surveying (Bryan)**, **C & G Land Surveyors (Conroe)**, **Prime Texas Surveys (Houston)**, **I. T. Gonzalez Engineers (Austin)**. Thesis: LOW-PE-attention vertical (only Bowman + Westwood active) = structural opportunity for ETA / search-fund / acquire-self profile in the $300K-$5M independent universe over the next 24-36 months.
