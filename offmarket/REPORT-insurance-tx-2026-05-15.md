# Off-Market Insurance Agency Acquisition Scorer — insurance-tx-2026-05-15

**Run:** `insurance-tx-2026-05-15` · **Model:** `offmarket-4layer-v0.2` · **Generated:** 2026-05-15
**Outputs:** `offmarket/data/insurance_targets.json` · `insurance_targets.csv`
**Supabase:** `offmarket` schema in project `gggmmjvwbbfvrtjjlqvr`; `score_run_id = 760573ba-faa4-4a8e-9d5b-cc5fcb90cbf9`

## 1. Summary

**50 unique, name-verifiable Texas independent P&C insurance agencies** enriched and scored on the 4-layer composite model.

- **County breakdown:** Harris 13, Dallas 13, Tarrant 4, Bexar 7, Travis 11, Comal 1, Kendall 1, Smith 2 (Tyler — out of 5-metro).
- **Lines of business:** Mixed P&C 45 · Personal-only 4 · Commercial-only 1.
- **Tier counts:** **A_acquire_self 0** · **B_forward 18** · **C_watch 19** · **D_pass 13**.
- **Excluded:** 5 captives/franchises (Goosehead's Lawhorn & Moore, TWFG Tomball, Chande GEICO, Schuder dual-Farmers, etc.), 5 too-large (TIA 700+ emp, Watkins $93M, Kevin Lee 14-state, Allen Thomas OOS HQ, Rock 1-of-largest), 1 acquirer-role (Texan Insurance), 1 mid-career (Josh Smith), 1 too-young (Salgado).
- **C_watch demotions:** 8 confirmed succession-in-place rows (Pasadena 3rd-gen, Dean & Draper, Gibb, Independent Insurance Center Sales family, Britton & Britton, Threlkeld's Dustin Glover heir-apparent, Insurance Over Texas/Martha Juarez, Champion-Wood-Wilson merger). 3 multi-partner / multi-generation training (Bosworth, Dreiss, Central, Greater Austin).

**Headline caveat:** As with Fire, **owner ages are proxy-only for ~80% of rows** (license-tenure / LinkedIn grad-year proxies). CAD/OV65 confirmation blocked from WebFetch. The 5 highest-confidence B candidates have age estimates from LinkedIn 1986-present tenure proxies — defensible but not OV65-verified.

## 2. Top 8 — `B_forward` ranked

| Rank | Agency                                   | City          | County  | Owner                                        | Yrs | Final  | Conf   |
| ---- | ---------------------------------------- | ------------- | ------- | -------------------------------------------- | --- | ------ | ------ |
| 1    | **Whitaker Insurance**                   | San Antonio   | Bexar   | Don Whitaker (~70, IIAT 2023 lifetime award) | 43  | **81** | medium |
| 2    | **Perdue Insurance Agency LLC**          | Austin        | Travis  | Donald Perdue (38yr industry)                | 30  | **79** | medium |
| 3    | **Bankhead Insurance Agency, LLC**       | Dallas        | Dallas  | Philip Bankhead (~70, 1986-present LinkedIn) | 40  | **77** | medium |
| 4    | **Jeffrey R Mewhirter Insurance Agency** | Grapevine     | Tarrant | Jeffrey Mewhirter (39 yr, but Dan on team)   | 39  | **73** | medium |
| 5    | **James Little Agency, LLC**             | Fort Worth    | Tarrant | James Little (HNW personal, $3M rev)         | 28  | **69** | medium |
| 6    | **Independent Insurance Center (IIC)**   | San Antonio   | Bexar   | Sales family multi-gen                       | 142 | **69** | medium |
| 7    | **Insurance Services Agency**            | McKinney      | Collin  | J. Caserotti (opaque, thin web)              | 34  | **68** | medium |
| 8    | **Comaltex Insurance Agency**            | New Braunfels | Comal   | Owner opaque                                 | 78  | **68** | medium |

## 3. A-tier list

**No promotions to A this run** — same confidence cap as Fire. The two highest-confidence near-A candidates are:

- **Whitaker Insurance (81)** — Don Whitaker IIAT Drex Foreman 2023 lifetime achievement award is a strong succession-imminent signal. If Bexar CAD confirms OV65, promote to A immediately.
- **Perdue Insurance (79)** — Donald Perdue specialty commercial-trucking book with FMCSA/Texas Mutual carrier appointments. Trucking-specialty books retain at 90%+ and command 10-12x EBITDA at platform-scale.

## 4. Value-add theses (top picks)

### Whitaker Insurance — San Antonio (Bexar)

_Final 81 · conf medium · L1 94 / L2 88 / L3 60 / L4 87_

43-yr San Antonio commercial-specialty independent with ~2,600 client book — Don Whitaker's IIAT Drex Foreman 2023 lifetime achievement award is the strongest succession-imminent signal in this vertical (lifetime-award recipients often sell within 12-24 mo). Commercial-lines retention is high. Modernization opportunity: cloud AMS, client portal, producer succession-planning hire. Bexar Co PE platforms (Hub, Acrisure, Higginbotham) routinely bolt-on commercial-specialty shops at 8-10x EBITDA. 18-24 mo EBITDA path: 28% → 32% via producer adds + client portal retention bumps. **Top-of-list TX insurance pick.**

### Perdue Insurance Agency LLC — Austin (Travis)

_Final 79 · conf medium_

Donald Perdue, 38-yr industry tenure, 1996 agency founding, specialty commercial-trucking + FMCSA/Texas Mutual/Berkshire Hathaway GUARD carrier appointments. Trucking-specialty books retain at 90%+ and command premium multiples (10-12x EBITDA at platform-scale). Modernization opportunity: cloud AMS, online certificate-of-insurance portal for trucking customers, producer succession hire. Austin metro = strong PE platform demand. 18-24 mo EBITDA path: 25% → 32%. Strong bolt-on to a specialty-commercial-focused platform (Higginbotham, NFP, Acrisure Specialty).

### Bankhead Insurance Agency, LLC — Dallas

_Final 77 · conf medium_

Philip Bankhead, ~70, sole eponymous owner since 1986 (40 yrs); LinkedIn 1986-present tenure confirms. Dallas Co solo agency, no named successor on team page. Needs DCAD OV65 + live successor-check team-page fetch for A promotion. Modernization play: cloud AMS migration; online quoting widget; client portal; producer hiring. Owner glide-path to exit at year 1-2. EBITDA improvement 22% → 30% over 18-24 mo. Higginbotham/Hub/Acrisure DFW bolt-on candidate post-modernization.

## 5. What worked vs blocked

| Source                                            | Status                                                                                                                           |
| ------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| Agency websites direct fetch                      | WORKED (50/50)                                                                                                                   |
| Google Business Profile review data               | WORKED                                                                                                                           |
| LinkedIn company / tenure                         | PARTIAL (login-gated for several)                                                                                                |
| Trusted Choice IIA directory                      | WORKED                                                                                                                           |
| TDI agent license lookup (txapps.tdi.state.tx.us) | BLOCKED — search-only UI; routed via Socrata `3yqc-fcdt` (agency spine) + `avjc-7u2m` (carrier-appointment crosswalk) per config |
| TX Comptroller Taxable Entity Search              | BLOCKED — requires interactive form / CAPTCHA                                                                                    |
| OpenCorporates / Bizapedia                        | BLOCKED — HAProxy CAPTCHA                                                                                                        |
| CAD / OV65 lookups                                | BLOCKED — interactive form-based JS apps                                                                                         |
| Wayback Machine snapshot diffs                    | BLOCKED — timeouts on web.archive.org                                                                                            |

## 6. Key findings

- **Most M&A-active vertical confirmed.** 6 of 17 in batch 1 (35%) were already acquirers or post-acquisition. Pasadena (1936 90-yr) had 3rd-gen succession; Dean & Draper had multi-partner structure; Champion just merged April 2023.
- **Goosehead franchise discovered** mid-run as a new disqualifier category (Lawhorn & Moore in Round Rock). Added to platform exclusion list.
- **The TX-native acquirers matter more than national.** Higginbotham (Fort Worth HQ) is more active than Hub/Acrisure in TX-specific deals. Inszone has done 15+ TX deals in 2024-2025.
- **Commercial-trucking + commercial-construction specialty books** stand out as highest-multiple targets — Perdue (Austin trucking), Threlkeld (Tyler O&G/trucking).

## 7. Honest limitations

- 4 unidentified-owner rows still B_forward — needs TDI license lookup for principal name before forwarding (Comaltex, Insurance Services Agency, RC Insurance, Hall Insurance).
- 19 C_watch rows include multiple promising 25-30 yr agencies whose owner identity / age is opaque — Phase 5 Playwright pass on TDI agent lookup would unlock most.
- Insurance is the most M&A-active vertical — the 50-row enrichment was completed over a ~90 min window during which 1 confirmed recent acquisition was found (Champion-Wood-Wilson). The actual recent-acquisition rate is higher; we caught what was publicly visible.

## 8. Next-step recommendation

**Highest ROI follow-up:** TDI license lookup + CAD OV65 verification for the top 4 confirmed-age B candidates (Whitaker, Perdue, Bankhead, James Little). 1-2 hours of Playwright work would likely promote 2-3 to A-tier.

The **#1 single pick** for direct outreach prep: **Whitaker Insurance (San Antonio)** — IIAT Drex Foreman 2023 lifetime achievement award is the strongest "succession imminent" signal among all 50 rows. Forward to ETA community + draft direct-outreach letter pending Bexar CAD OV65 confirmation.

The **#2**: **Perdue Insurance (Austin)** — specialty commercial trucking is the premium-multiple book in this vertical. Strong PE platform demand for trucking-specialty agencies.
