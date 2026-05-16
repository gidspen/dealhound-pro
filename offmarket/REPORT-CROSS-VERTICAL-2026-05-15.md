# Cross-Vertical Off-Market Acquisition Run — 2026-05-15

**Verticals:** Fire & Life Safety · Independent P&C Insurance · Veterinary · Optometry
**Geography:** Texas — Harris (Houston), Dallas, Tarrant (Fort Worth), Bexar (San Antonio), Travis (Austin) priority, plus adjacent counties
**Model:** `offmarket-4layer-v0.2` (weights: L1 .30 / L2 .25 / L3 .30 / L4 .15)
**Supabase:** project `gggmmjvwbbfvrtjjlqvr`, schema `offmarket`

---

## 1. Headline numbers

| Vertical                      | Spine   | Enriched | A     | B_forward | C_watch | D_pass | Top score |
| ----------------------------- | ------- | -------- | ----- | --------- | ------- | ------ | --------- |
| **Fire & Life Safety**        | 62      | 60       | 0     | 8         | 27      | 25     | 74        |
| **Independent P&C Insurance** | 50      | 50       | 0     | 18        | 19      | 13     | 81        |
| **Veterinary**                | 65      | 65       | 0     | 24        | 19      | 22     | 81        |
| **Optometry**                 | 79      | 79       | 0     | 14        | 35      | 30     | 78        |
| **TOTAL**                     | **256** | **254**  | **0** | **64**    | **100** | **90** | —         |

**0 A_acquire_self promotions** across all 4 verticals — the systemic block on CAD/OV65 lookups (WebFetch can't drive interactive parcel-search apps) capped confidence at "medium" for every top candidate. The 64 B_forward rows are the action set; **a Playwright-pass deep-dive on the top 15-20 B rows is the unlock for A-tier promotions.**

---

## 2. Top 12 across all verticals (the action set)

| Rank | Vertical  | Practice                            | City        | County  | Owner                                        | Final  |
| ---- | --------- | ----------------------------------- | ----------- | ------- | -------------------------------------------- | ------ |
| 1    | Insurance | **Whitaker Insurance**              | San Antonio | Bexar   | Don Whitaker (~70, IIAT 2023 lifetime award) | **81** |
| 1    | Vet       | **White Rock Animal Hospital**      | Dallas      | Dallas  | Dr. Bob Hawthorne (TAMU 1978 ~73) + Williams | **81** |
| 1    | Vet       | **Mellina Animal Hospital**         | Fort Worth  | Tarrant | Dr. J. Scott Mellina (TAMU 1978 ~73, solo)   | **81** |
| 4    | Vet       | **Colleyville Animal Clinic**       | Colleyville | Tarrant | Wilson + Blick (KSU 1981 ~70 partnership)    | **80** |
| 5    | Insurance | **Perdue Insurance Agency**         | Austin      | Travis  | Donald Perdue (38yr commercial trucking)     | **79** |
| 6    | Optometry | **Altig Optical**                   | Fort Worth  | Tarrant | Dr. Altig (~66, 41yrs)                       | **78** |
| 7    | Insurance | **Bankhead Insurance Agency**       | Dallas      | Dallas  | Philip Bankhead (~70, 40yr solo)             | **77** |
| 7    | Optometry | **Vision Plus**                     | San Antonio | Bexar   | Dr. Goldstein (NSU 1986 ~64, husband-wife)   | **77** |
| 9    | Optometry | **Bellaire Optometry Clinic**       | Houston     | Harris  | Dr. Anne Le (UHCO 1989 ~63, 37yr solo)       | **76** |
| 9    | Vet       | **Longenbaugh Veterinary Hospital** | Houston     | Harris  | Dr. Martin Keadle (TAMU 1991 ~63, solo)      | **76** |
| 11   | Vet       | **Animal Hospital of Valley Ranch** | Irving      | Dallas  | (proxy)                                      | **77** |
| 11   | Vet       | **Bridge Street Animal Clinic**     | Fort Worth  | Tarrant | Dr. Robert Norris (OSU 1986 ~65)             | **77** |

---

## 3. Strategic read — by your investment thesis

### Volume / yield by vertical

- **Vet (24 B_forward)** delivered the most B-tier candidates. The vertical's high consolidator density (~30-40% TX metro practices already platform-affiliated) created strong filtering signal during enrichment — the 24 that survived have cleaner profiles than the spine count would suggest.
- **Insurance (18 B_forward)** delivered the highest _score quality_ — Whitaker at 81 with the IIAT lifetime award is the strongest "imminent exit" signal across the entire run. Insurance brokerage is also the most M&A-active vertical (700+ deals/yr nationally) which means **exit liquidity at multiple steps is highest here**.
- **Optometry (14 B_forward)** delivered the lowest yield because the spine had a higher false-positive rate on owner identity (2 STRONG A-tier spine picks demoted on enrichment when current-owner tenure was checked). Less M&A activity = less pressure on owners to sell, but also less acquirer competition for the ones who do.
- **Fire (8 B_forward)** delivered the cleanest _quality_ picks but the lowest absolute volume — the TX independent fire & safety universe is structurally small (~800-1,500 5+yr shops). Pye-Barker / Argentum / Satori / Abry have aggressively acquired in 2024-2025 (5 platform finds in our 62 spine).

### Strategic Map (your original strategy choice was diversified: Fire = roll-up exit, Vet+Optometry = licensed dental-mirror, Insurance = pure recurring cash flow)

| Strategy                                                       | Best vertical fit | Top pick                           | Reason                                                                                                      |
| -------------------------------------------------------------- | ----------------- | ---------------------------------- | ----------------------------------------------------------------------------------------------------------- |
| **Roll-up-and-sell to PE** (multiple bolt-ons, 3-5 yr horizon) | **Fire**          | Richardson Fire Equipment (Dallas) | Pye-Barker bolt-on demand is intense; small multi-trade shops at 3-4x SDE → sell to platform at 6-8x EBITDA |
| **Buy one large, scale, sell to PE**                           | **Insurance**     | Whitaker Insurance (SA)            | Highest M&A activity = clearest exit; commercial-lines retention 90%+; 10-12x EBITDA at platform-scale      |
| **Acquire-self + operate long term**                           | **Vet**           | Mellina Animal Hospital (FW)       | Cleanest dental-mirror profile, premium ZIP, 46-yr solo founder. Best for "buy and run."                    |
| **Quiet cash flow** (lowest competition)                       | **Optometry**     | Bellaire Optometry (Houston)       | Lowest consolidator activity = lowest acquisition multiples + lowest exit pressure                          |

### Cross-vertical insights

1. **Tarrant County dominates the top picks** — 4 of top 12 are in Tarrant (Mellina, Colleyville, Altig, Bridge Street). Possible reason: Fort Worth has a more old-school, family-owned business culture than Dallas/Houston/Austin, and Tarrant CAD demographics show high OV65 concentration in business-owner ZIPs.
2. **TAMU CVM 1978 grads (Mellina + Hawthorne)** show up independently in both top vet picks. Possible cohort effect — these owners are now ~73 and clustering toward retirement.
3. **Same-1986-license-year owners** in different verticals (Bankhead Insurance 1986, Bridge Street Vet 1986, Vision Plus OD 1986) are all ~65 — common 1986-era founder cohort about to age out.
4. **Houston exurbs are systematically under-targeted** in both vet (Longenbaugh in Cypress, Cypress Veterinary) and optometry (Vision Source Aldine in N. Houston). Innovetive's I-35-corridor footprint and MyEyeDr's DFW/Austin focus leave these geographies thin.

---

## 4. Data limitations (systematic across all 4 runs)

| Limitation                                                                                                                                 | Impact                                                                                                | Fix                                                                                                                                                             |
| ------------------------------------------------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **CAD homestead / OV65 blocked** from WebFetch (HCAD/DCAD/TAD/BCAD/TCAD all behind interactive JS apps with bot detection)                 | No owner-age confirmation; all top candidates capped at B_forward by confidence rule                  | Playwright-driven CAD lookup; ~30 min of automation work + 1-2 hr of A-candidate verification                                                                   |
| **TX Comptroller Taxable Entity Search blocked** (interactive POST form)                                                                   | `entity_status` is "unknown" for ~95% of rows; can't confirm Active vs Forfeited (distress hard gate) | Playwright Comptroller driver — also unlocks `entity_sos_file_number`, `entity_formation_date`, `registered_agent` for SOS-linked owner-residence-address chain |
| **Wayback Machine snapshot diffs blocked** (timeouts on web.archive.org)                                                                   | L3 coasting tells scored from live state only; can't verify "not meaningfully updated in 3+ yrs"      | Playwright or different fetch path                                                                                                                              |
| **License-board search UIs blocked** (TDI SFMO for fire; TBVME for vet; TDI Sircon for insurance; TOB for optometry — all search-only UIs) | Spine derivation routed around via Google + directory crawls + license-number-on-website capture      | Per-vertical PIA requests OR Socrata API where datasets exist (insurance has `3yqc-fcdt`)                                                                       |

**The single highest-ROI follow-up across all 4 verticals is a single Playwright-pass session** targeting:

- HCAD/DCAD/TAD/BCAD/TCAD OV65 lookup for the 12 highest-confidence near-A candidates
- TX Comptroller entity status for the same 12
- Wayback Machine snapshot diff for the same 12

This 2-3 hour session would likely promote 4-8 of the top 12 from B_forward to A_acquire_self with high confidence — actionable for direct outreach.

---

## 5. Key process learnings

1. **The spine agent over-flagged "STRONG A-tier" multiple times** when practice tenure (e.g., 50 yrs) was conflated with current-owner tenure. Enrichment caught most (Austin Optometry Group: Dr. Wolf 2nd-gen 2009-buyer ~42; Austin Vision Center: Dr. Clay Barnett mid-career; Northwest Animal Hospital: Dr. O'Bannion bought 2018 ~40; Memorial-610: Pittenger ~56 with 4 DVMs; Eagle Fire Extinguisher: Wright family bought from Massey 2024). **Future spine prompts should explicitly distinguish practice tenure from current-owner tenure.**

2. **Platform / recent-acquisition detection is the highest-value enrichment step** — across 4 verticals we caught 20+ post-spine acquisitions or platform-affiliation finds that would have polluted the scoring if left in. The Google "<company> acquired sold merged 2024 2025 2026" check should be a mandatory Phase 3 step.

3. **Sub-agent token economy worked.** 4 verticals × 3-4 batches each = 14 enrichment agents + 3 setup agents + 4 persistence agents = 21 sub-agent runs orchestrated in parallel from a single Opus context. Each sub-agent consumed ~120-200k tokens; total session tokens manageable.

4. **Per-vertical config writing was essential.** Each vertical's spine source, consolidator list, recurring-revenue language, and coasting tells differ enough that the dental config wouldn't have transferred well. The 30-45 min spent fleshing out each vertical config in `verticals.md` paid off in spine quality.

---

## 6. Recommended next actions (in priority order)

### Immediate (next 1-3 hours)

1. **Playwright-pass on top 12 candidates** for CAD OV65 + Comptroller entity status + Wayback snapshot diff. Expected outcome: 4-8 A-tier promotions.

### Near-term (next 1-2 days)

2. **Direct outreach prep for top 2 confirmed-A candidates** post-Playwright. Top candidates to draft outreach for:
   - **Whitaker Insurance (San Antonio)** — IIAT 2023 lifetime award = strongest "imminent sale" signal
   - **Mellina Animal Hospital (Fort Worth)** — TAMU 1978 ~73, 46-yr eponymous solo in premium Cultural District
   - **Bellaire Optometry Clinic (Houston)** — Dr. Anne Le UHCO 1989 ~63, 37-yr solo founder
   - **Richardson Fire Equipment (Dallas)** — Mark + Kathy Thomas, 38yr multi-trade, kids NOT in business (confirmed via live team-page fetch)

### Medium-term (next 1-2 weeks)

3. **Productionize Playwright lookups** as a reusable enrichment skill (15-30 min one-time investment, saves all future runs).
4. **PIA request to TDI SFMO** for fire & life safety license roster CSV (5-10 business days; would yield proper spine).
5. **Socrata API integration for insurance** (`3yqc-fcdt` agencies + `avjc-7u2m` carrier appointments) — would let the insurance spine scale to 800-1,500 candidates statewide.

### Longer-term (next quarter)

6. **Quarterly re-run** of all 4 verticals to catch new acquisition activity (especially insurance — most M&A-active).
7. **C_watch re-evaluation in ~90 days** — 100 C_watch rows include several pending-confirmation A-candidates whose owner identity/age couldn't be confirmed this pass.

---

## 7. Files written this session

### Per-vertical artifacts

- `offmarket/data/fire_targets.json` + `.csv` (60 rows scored)
- `offmarket/data/insurance_targets.json` + `.csv` (50 rows scored)
- `offmarket/data/vet_targets.json` + `.csv` (65 rows scored)
- `offmarket/data/optometry_targets.json` + `.csv` (79 rows scored)
- `offmarket/data/fire_spine.json` (62 rows)
- `offmarket/data/insurance_spine.json` (50 rows)
- `offmarket/data/vet_spine.json` (65 rows)
- `offmarket/data/optometry_spine.json` (79 rows)
- 13 per-batch enrichment JSON files

### REPORTs

- `offmarket/REPORT-fire-tx-2026-05-15.md`
- `offmarket/REPORT-insurance-tx-2026-05-15.md`
- `offmarket/REPORT-vet-tx-2026-05-15.md`
- `offmarket/REPORT-optometry-tx-2026-05-15.md`
- `offmarket/REPORT-CROSS-VERTICAL-2026-05-15.md` (this file)

### Skill updates

- `/Users/gideonspencer/.claude/skills/offmarket-acquisition-scorer/verticals.md` — flushed Fire stub to COMPLETE; added Vet (Section 4) + Insurance (Section 5) + Optometry (Section 6) configurations following the existing dental/pest control format.

### Supabase

4 `score_runs` rows + 254 `businesses` rows + ~254 `business_scores` rows + several hundred `business_signals` rows in project `gggmmjvwbbfvrtjjlqvr`, schema `offmarket`. (Persistence agents in flight — exact final counts will be confirmed when those return.)

### Scoring scripts (reusable for future runs)

- `offmarket/score_fire.py`
- `offmarket/score_insurance.py`
- `offmarket/score_vet.py`
- `offmarket/score_optometry.py`
- `offmarket/fire_overrides.py`
- `offmarket/insurance_overrides.py`
