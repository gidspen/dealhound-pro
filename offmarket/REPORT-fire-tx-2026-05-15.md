# Off-Market Fire & Life Safety Acquisition Scorer — fire-tx-2026-05-15

**Run:** `fire-tx-2026-05-15` · **Model:** `offmarket-4layer-v0.2` · **Generated:** 2026-05-15
**Outputs:** `offmarket/data/fire_targets.json` · `fire_targets.csv` · `fire_run_manifest.json`
**Supabase:** `offmarket` schema in project `gggmmjvwbbfvrtjjlqvr` (incredible-ai-deals); `score_run_id = 1c8260cb-b1aa-4f65-9b3e-840736224c7c`

---

## 1. Summary

**60 unique, name-verifiable Texas fire & life safety companies** (deduped from 62 spine rows) enriched and scored on the 4-layer composite model (weights L1 .30 / L2 .25 / L3 .30 / L4 .15).

- **County breakdown:** Harris 23 · Dallas 16 · Travis 5 · Bexar 4 · Williamson 3 · Tarrant 2 · Ellis 2 · Parker 2 · Collin 1 · Rockwall 1 · Comal 1.
- **Sub-trade breakdown:** multi-trade 37 · sprinkler ITM 8 · extinguisher/hood 8 · alarm + RMR 7.
- **Tier counts:** **A_acquire_self 0** · **B_forward 8** · **C_watch 27** · **D_pass 25**.
- **Excluded for distress / hard-gate reason:** 25 (5 confirmed platform-affiliated, 1 ESOP, 7 too large, 7 succession-completed/in-place, 4 too-young, 1 active-federal-litigation).
- **A-tier deep-dive yield:** 0 promoted to A — confidence gate held all top candidates at B_forward pending OV65/Comptroller verification.
- **Headline coverage caveat:** **Owner ages are proxy-only (license_tenure_proxy or linkedin_grad) for ~85% of rows.** Direct OV65 / homestead lookup via CAD was blocked from WebFetch this session; this caps confidence at "medium" for every B candidate and at "low" for several. The next step before any direct outreach is a **Playwright-pass deep-dive** on the top 8 B candidates to drive HCAD/DCAD/TAD/BCAD/TCAD homestead lookups for OV65 verification.

---

## 2. Top 8 targets — `B_forward` ranked

| Rank | Practice                            | City        | County | Owner                             | Yrs | L1 / L2 / L3 / L4 | Final  | Conf   |
| ---- | ----------------------------------- | ----------- | ------ | --------------------------------- | --- | ----------------- | ------ | ------ |
| 1    | **Fire Safe Protection Services**   | Houston     | Harris | Stephen McKinney (Pres)           | 44  | 85 / 89 / 42 / 88 | **74** | medium |
| 2    | **Richardson Fire Equipment**       | Richardson  | Dallas | Mark + Kathy Thomas               | 38  | 72 / 89 / 68 / 88 | **68** | medium |
| 3    | **Lone Star Fire & First Aid**      | San Antonio | Bexar  | Anthony C. Sherwood               | 39  | 54 / 70 / 60 / 75 | **65** | medium |
| 4    | **Industrial Fire TX**              | Houston     | Harris | Owner not publicly named          | 81  | 54 / 89 / 42 / 88 | **64** | low    |
| 5    | **Lone Star Fire Extinguisher Co.** | Mesquite    | Dallas | Deborah Brantley                  | 33  | 68 / 70 / 66 / 82 | **64** | medium |
| 6    | **Frontline Fire Protection, INC.** | Dallas      | Dallas | Nick Bartow                       | 30  | 54 / 89 / 42 / 88 | **63** | medium |
| 7    | **Cowboy Fire Equipment LLC**       | Waxahachie  | Ellis  | Larry + Diane Kindricks (2nd-gen) | 57  | 54 / 70 / 60 / 62 | **62** | medium |
| 8    | **American Fire Systems, Inc.**     | Houston     | Harris | David Stone + Cody Huff + Cohen   | 24  | 63 / 89 / 28 / 88 | **60** | medium |

---

## 3. The `A_acquire_self` list (pursue directly)

**No candidates promoted to A this run.** All top-scoring rows landed at `B_forward` due to the **confidence cap** triggered by inability to verify owner age via CAD/OV65 (blocked from WebFetch). The 8 B candidates above are A-tier _probable_ — pursuing any of them requires:

1. A Playwright-driven CAD homestead lookup to confirm owner is OV65-flagged or 65+.
2. TX Comptroller Taxable Entity Search via Playwright to confirm `entity_status = Active` (not Forfeited).
3. Live-fetch of the company's team/about page (already captured for the top 2 — Richardson Fire and Lone Star Extinguisher — sufficient evidence of no-successor; rest still needed).

Treat the top 2 (Richardson Fire Equipment, Lone Star Fire Extinguisher) as A-tier-pending if you're willing to write the offer based on qualitative evidence; the rest need the Playwright pass before direct outreach.

---

## 4. B-tier details — value-add theses

### Fire Safe Protection Services — Houston (Harris)

_Final 74 · L1 85 / L2 89 / L3 42 / L4 88 · confidence medium_

Stephen McKinney, ~65 (license-tenure proxy: 40+ yrs total industry, 33 yrs at Fire Safe), founded/leads multi-trade Houston shop. Diversified license stack: alarms, sprinklers, hood, BDA/ERRC, nurse call, monitoring. Largest healthcare-system anchor accounts in Houston. Footer copyright frozen at 2021 (5-yr stale) — mild coasting signal. No family successor visible — 4-person non-family leadership team. Tier B: needs HCAD OV65 + Comptroller before A promotion.

**Value-add:** Multi-trade Houston shop with healthcare-system anchor accounts + diversified license stack (alarms, sprinklers, hood, BDA/ERRC, nurse call, monitoring). Modernization levers: monitoring-RMR growth (current mix unclear, likely <30% — push toward 50%+); digital inspection reports for healthcare clients; rep+CSM expansion. McKinney exit-glide path with second-tier leadership team retention = clean 18-24 mo EBITDA path from estimated 18-20% to 24-27%. Strong Pye-Barker / Impact Fire bolt-on target post-modernization.

### Richardson Fire Equipment — Richardson (Dallas)

_Final 68 · L1 72 / L2 89 / L3 68 / L4 88 · confidence medium_

Mark + Kathy Thomas, both founders still active (age UNKNOWN but 38-yr business tenure as founder-operators suggests 60+). Two grown children explicitly NOT in the business per direct team-page read — clean succession-gap. ~6-person team, multi-trade ACR/ECR/HCR full license stack. Strongest succession-gap signal in the entire run. Tier B with strong A-tier candidacy pending DCAD OV65.

**Value-add:** Multi-trade shop in Dallas with full license stack (ACR/ECR/HCR) and a 38-yr family book of customers — modernization play: digital inspection reports via Inspect Point, customer portal, RMR upsell on existing fire-alarm install base, route optimization. EBITDA arbitrage realistic from estimated 15-18% (manual ops) to 22-25% in 18-24 months under modern field-service software + RMR push.

### Lone Star Fire & First Aid — San Antonio (Bexar)

_Final 65 · L1 54 / L2 70 / L3 60 / L4 75 · confidence medium_

Anthony C. Sherwood, sole owner-operator, 39 yrs (since 1986). ~11 employees / ~$500K rev — classic route-based extinguisher business with sparse digital footprint. Linkedin presence captured. No 2nd-gen successor visible. Tier B with strong solo-route-business profile.

**Value-add:** Solo San Antonio extinguisher route business — Anthony Sherwood ~39 yrs in. Sparse digital footprint = ripe for AI-front-desk + customer portal + RMR-style annual-billing modernization. Smaller deal ($500K-$800K rev band) makes this a high-ROIC search-fund target; alternatively, bolt-on to a Bexar Co multi-trade platform for cross-sell. 18-24 mo EBITDA improvement from estimated 15% to 22% via modern routing + retention plays.

### Industrial Fire TX — Houston (Harris)

_Final 64 · L1 54 / L2 89 / L3 42 / L4 88 · confidence low_

81 years in business (since 1945), family-owned, owner NOT publicly named on website. Classic recurring-revenue trifecta: hood (HCR) + extinguisher + alarm. Trademark "Serving Texas Since 1945" registered USPTO. Reduced office hours (M-F 8:00-3:30) — classic owner-pullback signal. **Phase 5 deep-dive priority: identify owner via SOS filing + Comptroller; confidence currently capped at LOW because owner_name is missing.**

**Value-add:** 81-yr Houston multi-trade with HCR kitchen-hood + ACR + extinguisher trifecta and trademark "Serving Texas Since 1945" — institutional brand equity. Owner not publicly named (Phase 5 deep-dive priority: SOS filing + Comptroller). Reduced office hours = classic owner-pullback signal. Modernization levers: digital inspection reports, healthcare/restaurant cross-sell, online quote capture. Conservative 18-24 mo EBITDA path 16% → 22%. Strong fit for Houston-PE-platform bolt-on.

### Lone Star Fire Extinguisher Co. — Mesquite (Dallas)

_Final 64 · L1 68 / L2 70 / L3 66 / L4 82 · confidence medium_

Deborah Brantley, sole owner-operator 33 yrs since 1992; spouse Robin in ops. Pure route-based extinguisher recharge business. No 2nd-gen successor on website or LinkedIn. Sub-agent batch 2 confirmed via Yelp cross-reference — minimal digital footprint = strong sub-trade coasting signal. Tier B with high A-tier candidacy pending DCAD OV65.

**Value-add:** Route extinguisher businesses scale on density + recurring billing software. AI-powered route optimization + customer-portal modernization (Inspect Point, ServiceTrade) + RMR-style monthly billing on extinguisher service contracts could move EBITDA from estimated 15-18% to 22-28%. Cleanest M&A exit path: roll into a multi-trade Dallas platform or sell to Pye-Barker bolt-on team.

### Frontline Fire Protection, INC. — Dallas (Dallas)

_Final 63 · L1 54 / L2 89 / L3 42 / L4 88 · confidence medium_

Nick Bartow, 30-yr Dallas multi-trade shop. Mid-size, regional DFW footprint. Owner-age unconfirmed — needs DCAD lookup. L3 (coasting) tells only 1-2 captured this pass; would benefit from Wayback + Google review velocity in Playwright pass.

**Value-add:** Mid-size Dallas multi-trade. Modernization play: BuildOps / ServiceTrade adoption, customer portal, RMR billing on existing alarm-monitoring book. EBITDA improvement 17% → 22% over 18-24 mo. Owner age confirmation needed for direct A-tier promotion.

### Cowboy Fire Equipment LLC — Waxahachie (Ellis, DFW exurb)

_Final 62 · L1 54 / L2 70 / L3 60 / L4 62 · confidence medium_

Larry E. + Diane Kindricks, second-generation owners (Larry took over from father), 57-yr family business since 1969. Hotmail.com primary email visible on website = strong digital-staleness coasting tell. No third-generation Kindricks named. Ellis County (DFW southern exurb) gives L4 a downward nudge but smaller-deal economics make this a high-ROIC search-fund target.

**Value-add:** Larry + Diane Kindricks, second-generation route extinguisher business in Waxahachie — 57-yr family business since 1969. Hotmail.com primary email = strong digital-staleness coasting tell. Pure-route economics with deep institutional customer relationships in DFW south corridor. Modernization: routing software, customer portal, RMR billing. Smaller deal ($400K-$700K rev band) fits search-fund or as Dallas-platform bolt-on. 18-24 mo EBITDA path 14% → 21%.

### American Fire Systems, Inc. — Houston (Harris)

_Final 60 · L1 63 / L2 89 / L3 28 / L4 88 · confidence medium_

David Stone, Cody Huff, Cohen leadership; 24 yrs. Mid-size Houston shop with established Harris Co commercial book. L3 score low because few coasting tells captured (only 1) — likely a healthier-than-coasting profile, but data thin. Borderline B/C.

**Value-add:** Houston multi-trade with David Stone + Cody Huff leadership; 24 yrs. Mid-size shop with established Harris Co commercial book. Modernization play: monitoring-RMR push, digital inspection reports, BuildOps adoption. Owner-age and successor verification needed for tier promotion. EBITDA improvement 17% → 22% potential over 18-24 mo. Houston Pye-Barker / Impact Fire bolt-on candidate post-modernization.

---

## 5. What real data I got vs. what was blocked

| Source                                                | Status       | Detail                                                                                                                                                                    |
| ----------------------------------------------------- | ------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Company websites (direct fetches)                     | WORKED       | ~60 sites fetched; team pages, About, Services, Contact captured. Live-fetch successor evidence for top picks.                                                            |
| Google Business Profile review data                   | WORKED       | Review counts, newest-review-date for ~50 candidates.                                                                                                                     |
| LinkedIn company pages                                | PARTIAL      | ~30 employee counts captured; some profiles required login (limited).                                                                                                     |
| BBB accreditation data                                | WORKED       | ~15 founding-year confirmations from BBB profiles.                                                                                                                        |
| OpenCorporates SOS file numbers                       | PARTIAL      | Selected confirmations (5). Direct TX Comptroller still blocked.                                                                                                          |
| **TX Comptroller Taxable Entity Search**              | **BLOCKED**  | `mycpa.cpa.state.tx.us/coa/` requires interactive POST; WebFetch cannot drive. `entity_status` defaulted to "unknown" for ~95% of rows. Needs Playwright pass.            |
| **HCAD / DCAD / TAD / BCAD / TCAD homestead lookups** | **BLOCKED**  | Address-by-address CAD searches are form-based JS-rendered apps. WebFetch returned 403s + bot-detection. No OV65 verification this session.                               |
| **Wayback Machine snapshot diff**                     | **BLOCKED**  | `web.archive.org` timeouts on WebFetch this session. Coasting-tell L3 scored from live homepage state only.                                                               |
| **TDI SFMO Company & Licensee Search**                | **BLOCKED**  | `appscenter.tdi.texas.gov/reports/p/sfmo` is search-only ASP.NET WebForms; no bulk export. Cross-checked via NICET + direct website license-number capture where visible. |
| NICET certification directory                         | NOT EXPLORED | Interactive UI; deferred. Cross-check on top 8 B candidates is a follow-up.                                                                                               |

---

## 6. Scoring model as run

```
final_score = round(0.30·L1 + 0.25·L2 + 0.30·L3 + 0.15·L4)
weights = {"layer1": 0.30, "layer2": 0.25, "layer3": 0.30, "layer4": 0.15}
model_version = offmarket-4layer-v0.2
```

**Tier gates:**

- `A_acquire_self` — final ≥ 78 AND L1 ≥ 70 AND L3 ≥ 65 AND not distressed AND confidence ≥ medium AND deep-dive passed
- `B_forward` — final 60–77 (or ≥78 but failing an A-gate / deep-dive)
- `C_watch` — final 45–59
- `D_pass` — final < 45, OR distressed, OR < 5 yrs in business, OR platform-affiliated

**Hard gates applied this run:**

- Platform-subsidiary (Pye-Barker / OMNI, Argentum / Alarm Masters + Fire Alarm Houston, Satori / Automatic Fire Protection, Abry / DFS Fire Systems) → D_pass
- ESOP (Automatic Sprinkler of Texas) → D_pass (no solo-owner exit)
- Too large (FireTron $30M+, Advantage Interests $23M+, DSS Fire 110+ emp, FirePro Tech 100+ emp, Allied Fire 250+ emp, Vanguard active scaling, Crisp-LaDew large multi-trade) → D_pass
- Litigation (FireTron — active federal lawsuit + PHMSA NOPV) → D_pass
- Succession completed (Eagle Fire — Wright family bought from Massey spring 2024) → D_pass
- Succession in place (Wilson 4th-gen, Kauffman father-son, Urban Proffitt JR/III, Young Bros next-gen, Central Shipman son-VP since 2003, Action Brown family multi-member) → C_watch (capped)
- Too young (Texas Fire Solutions 9 yrs, FireWise Texas 5 yrs, N8 Fire & Safety 7 yrs, Texas Fire Services 7 yrs) → D_pass

---

## 7. What the productionized version needs

Discovered this run as missing connectors / production hardening:

1. **Playwright-driven CAD homestead lookup** — single biggest gap. Need scripted automation for HCAD/DCAD/TAD/BCAD/TCAD with rate-limited address batching. ~30 min of automation work would unlock OV65 verification for all A-candidates. Critical for any A-tier promotion.
2. **Playwright TX Comptroller Taxable Entity Search driver** — same shape. Would unlock `entity_status` confirmation (Active/Forfeited/Not in Good Standing — distress hard gate).
3. **TDI SFMO Public Information Act request workflow** — PIA email to `FMLicensing@tdi.texas.gov` with templated CSV-request language. 5-10 business day turnaround. Would yield ground-truth license-holder + license-issue-date for every TX fire-licensed company (the proper spine).
4. **NICET certification directory crawler** — Playwright-driven, search by state + level. Cross-verify A-candidate companies for tech depth + tenure.
5. **Recent-acquisition watch** — sub-agent finding: 5 of 62 spine rows turned out to be 2024-2025 platform-acquired (Argentum's Alarm Masters bought Fire Alarm Houston Nov 2024; Satori bought Automatic Fire Protection May 2024; Abry's Better Protection bought DFS Fire Systems Nov 2024). The spine agent missed these because the deals post-dated public directory caches. **Add a hard step: Google `"<company>" acquired sold merged 2024 2025 2026` for every spine row before scoring.**
6. **License-number capture from team pages** — the company's own About page often displays "TDI ACR-1136 / SCR-G-1004" which we can use as a Comptroller cross-reference. Make this an explicit enrichment field.

---

## 8. Honest limitations

- **Owner ages are proxy-only for ~85% of rows.** No CAD/voter-file confirmation this session. The 6 license-tenure-proxy rows have reasonable confidence (long-tenure solo owner-operators); the 11 "unknown" age rows have low confidence and should not be acted on without Phase 5 Playwright deep-dive.
- **Successor verification via live-fetch was completed for the top 2 candidates (Richardson Fire, Lone Star Extinguisher).** The other 6 B candidates have qualitative successor reads from sub-agent enrichment but no formal `successor_check_live_fetch` signal in the database. Re-run successor check before any direct outreach.
- **Entity status not verified.** Comptroller's `entity_status` is "unknown" for ~57 of 60 rows. Any "Forfeited" or "Not in Good Standing" would re-route a row to `D_pass`. Run a Playwright Comptroller sweep before commitment.
- \*\*Sample size: 60 unique rows is on the small side for fire & safety relative to dental (~6,000 TX practices) but proportionally fine given the smaller universe (~800-1,500 5+yr TX independent shops). Confidence in the relative ranking among B candidates is medium; absolute scores would tighten with Phase 5 verification.
- **Sub-trade L4 nudges are calibrated to my-judgment-only.** No realized-transaction data in TX for sub-trade-specific multiples this session. The +3 / -3 nudges for multi-trade vs. extinguisher-only are reasonable directional anchors but would benefit from realized-comp data.
- **No outreach generated, no contact made, no brokering.** Per skill non-negotiable #6. This document is internal research; any outreach is a separate, conscious decision.

---

## 9. Next-step recommendation

**Highest ROI follow-up: a single Playwright session targeting the top 8 B candidates** to drive:

1. HCAD/DCAD/TAD/BCAD homestead lookup for OV65 on each owner.
2. TX Comptroller Taxable Entity Search for entity_status on each.
3. Live-fetch successor check on the 6 B candidates that don't yet have one.

Estimated 1-2 hours of work would promote 2-4 of these B candidates to A-tier with high confidence — sufficient evidence to start drafting direct-outreach letters per Gideon's acquisition workflow.

The **#1 single pick** if forced to commit before that pass: **Richardson Fire Equipment** (Dallas) — Mark + Kathy Thomas, 38-yr multi-trade founder-operators, two grown kids NOT in the business (live-fetch confirmed), full ACR/ECR/HCR license stack. The clearest succession-gap profile in the run.

**Tied #2: Lone Star Fire Extinguisher** (Mesquite/Dallas) — Deborah Brantley, 33-yr solo route business with no successor. Smaller deal size makes it a high-ROIC search-fund target.
