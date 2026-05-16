# Off-Market Optometry Acquisition Scorer — optometry-tx-2026-05-15

**Run:** `optometry-tx-2026-05-15` · **Model:** `offmarket-4layer-v0.2` · **Generated:** 2026-05-15
**Outputs:** `offmarket/data/optometry_targets.json` · `optometry_targets.csv`
**Supabase:** `offmarket` schema; `score_run_id = 5c31880f-db38-46fb-a1c2-663a0e41a1f6`

## 1. Summary

**79 unique, name-verifiable Texas independent optometry practices** enriched and scored. Largest spine of the 4 verticals — optometry is the most fragmented (lowest consolidator density).

- **County breakdown:** Harris 27, Travis 17, Dallas 14, Tarrant 11, Bexar 10, plus corrections (4 → Fort Bend, 4 → Collin, 2 → Williamson, 1 → Kendall, 1 → Brazos).
- **Practice type:** Medical eye care 54, Mixed 24, Refraction-only 1.
- **Vision Source members (independent co-op, NOT a roll-up):** 20 included as B/C eligible.
- **Tier counts:** **A_acquire_self 0** · **B_forward 14** · **C_watch 35** · **D_pass 30**.
- **D_pass reasons:** 0 distress, 0 recent acquisitions (lowest M&A activity of 4 verticals confirmed). The 30 D_pass are succession-in-place / growth-mode mid-career operators / one misclassified MD ophthalmologist (Alamo Eye Institute) / one optical-retail-with-leased-OD (River Oaks Optical) / one too-young (Modern Spectacle 2 yrs).
- **Today's Vision franchise discovery** mid-run: Klein Eyecare disqualified after enrichment found it's a Today's Vision franchise.
- **Spine over-flag corrections:** Austin Optometry Group (Dr. Wolf 2nd-gen 2009-buyer ~42) and Austin Vision Center (Dr. Clay Barnett multi-practice ~40s) both demoted from spine "STRONG A-tier" flags — practice tenure (50 / 39 yrs) ≠ current-owner tenure.

## 2. Top 8 — `B_forward` ranked

| Rank | Practice | City | County | Owner | Yrs | Final | Conf |
|---|---|---|---|---|---|---|---|
| 1 | **Altig Optical** | Fort Worth | Tarrant | Dr. Altig (private since 1985, ~66, 41 yrs) | 41 | **78** | medium |
| 2 | **Vision Plus** | San Antonio | Bexar | Dr. Thomas Goldstein (NSU 1986 ~64, 32 yrs) | 32 | **77** | medium |
| 3 | **Bellaire Optometry Clinic** | Houston | Harris | Dr. Anne Huyen Le (UHCO 1989 ~63, solo founder) | 37 | **76** | medium |
| 4 | **North Texas Eye Care** | Southlake | Tarrant | Dr. Gregory Kloesel (UHCO 1989 ~62, solo) | 34 | **75** | medium |
| 5 | **Vision Source Aldine** | Houston | Harris | Dr. Ravindra Kankaria (~60, 33 yrs solo) | 33 | **72** | medium |
| 6 | **Park Cities Eye Associates** | Dallas | Dallas | Dr. Cathy Ann Norton (~60, 30 yrs solo, premium 75225) | 30 | **68** | medium |
| 7 | **Parmer Eye Care** | Austin | Travis | Dr. Sundra Lemanski (UH 1995 ~56, 30 yrs) | 30 | **66** | medium |
| 8 | **Southlake Family Eye Care** | Southlake | Tarrant | Dr. Kirk Koogler (UH 1995 ~56, solo 29 yrs) | 29 | **65** | medium |

Plus 6 more B candidates including Lakeside Vision & Optical (Plano), Eagle Ranch Vision, TSO Sugar Land (Dr. Robert Le UH 1994 ~57 + TSO co-op caveat), VisualEyes, Mi Vision Eye Care, Tanglewood Vision Center.

## 3. A-tier list

**No A-tier promotions** — same confidence cap pattern. The single highest-confidence near-A is:

**Altig Optical (Fort Worth)** — Dr. Altig has been in private practice since 1985 (41 yrs) and runs Altig Optical since 1992. Solo OD pattern with full medical eye care. The 3 associates including a former childhood patient (Reynolds) introduces some internal-succession ambiguity — verify before A promotion. **Caveat caught by batch 3 enrichment: succession may be underway.**

Cleaner near-A candidates without succession ambiguity: **Bellaire Optometry Clinic (Houston, Dr. Anne Le UHCO 1989 ~63, 37-yr founder, sole OD, 7 coasting signals captured)** and **Vision Plus (San Antonio, Dr. Goldstein ~64, 32-yr husband-wife operator)**.

## 4. Value-add theses (top picks)

### Bellaire Optometry Clinic — Houston (Harris)
*Final 76 · L1 79 / L2 88 / L3 60 / L4 87 · conf medium*

Dr. Anne Huyen Le, UHCO 1989 founder, ~63 (license-tenure proxy), 37-yr founder-owner tenure, SOLO OD, premium SW Harris (Asian-immigrant repeat-patient demographic). 7 signals captured including Saturday hours active. Slightly more engaged than Vision Corner (Galleria) but stronger long-term value. Value-add: Modernization opportunity is moderate (already mid-tech) — focus on cloud EHR migration if not done, associate OD hire for glide path, medical-eye-care service expansion (dry eye, glaucoma management, diabetic retinopathy screening). EBITDA improvement 22% → 28% over 18-24 mo.

### Vision Plus — San Antonio (Bexar)
*Final 77 · L1 82 / L2 75 / L3 60 / L4 82 · conf medium*

Dr. Thomas Goldstein NSU OK 1986 ~64, 32-yr ownership, husband-wife operator (Jennifer co-owner / business manager) — classic family-run retirement-window profile. One associate (Sanchez, role unclear — needs successor-check). Value-add: associate-to-owner glide path, cloud EHR, online booking, optical-retail rebuild. EBITDA 22% → 28%. Bexar Co MyEyeDr has been less aggressive than DFW — clean entry.

### North Texas Eye Care — Southlake (Tarrant)
*Final 75 · L1 75 / L2 88 / L3 60 / L4 83 · conf medium*

Dr. Gregory Kloesel UHCO 1989 ~62, solo 34-yr tenure, no associate, no modern capex callouts, multi-generational patient base (founding patients now bringing children + grandchildren). Premium Southlake 76092. Value-add: AI recall, online booking, OCT/Optomap capex (if not present), medical-eye-care service expansion. EBITDA 22% → 28% over 18-24 mo. Strong DFW MyEyeDr / Acuity bolt-on candidate.

### Vision Source Aldine — Houston (Harris)
*Final 72 · L1 67 / L2 75 / L3 60 / L4 86 · conf medium*

Dr. Ravindra Kankaria, sole owner since 1993 (33 yr tenure), ~60. Vision Source cooperative member (Vision Source ≠ roll-up, members keep ownership). Single anchor location. Value-add: cloud EHR, online booking, associate hire. EBITDA 22% → 28%. Note: Vision Source member-to-member transfers are allowed and PE platforms do acquire member practices.

### Park Cities Eye Associates — Dallas
*Final 68 · L1 67 / L2 75 / L3 60 / L4 87 · conf medium*

Dr. Cathy Ann Norton, solo-owner 30 yrs at premium 75225 (Park Cities/Highland Park), ~60, no associate bench. Dry eye specialty + LASIK co-management. **Cleanest external-buyer path** — premium ZIP, solo OD, specialty book. Value-add: associate hire, cloud EHR, dry-eye treatment center build-out. EBITDA 24% → 30%. Premium-suburb Dallas optometry is a top MyEyeDr / Acuity target.

## 5. What worked vs blocked

| Source | Status |
|---|---|
| Practice websites + team pages | WORKED (79 direct fetches) |
| Google Business Profile review velocity | WORKED |
| LinkedIn OD profiles (grad year proxy) | WORKED |
| AOA "Find a Doctor" directory | WORKED |
| Vision Source Houston metro directory | WORKED |
| Texas Optometry Board (TOB) license lookup | BLOCKED — search-only UI, intermittent issues per TOB homepage |
| data.texas.gov tm3v-pfq9 dataset | NOT-APPLICABLE — that dataset is Texas Medical Board licenses (38 license types), optometry NOT included (verified during spine setup) |
| CAD homestead / OV65 | BLOCKED |
| TX Comptroller entity status | BLOCKED |
| Wayback Machine | BLOCKED |

## 6. Key findings

- **Lowest M&A activity of 4 verticals.** Zero recent acquisitions surfaced across 79 enriched rows. MyEyeDr, Acuity, AEG, Keplr, EyeCare Partners all active but smaller market share than dental DSO penetration.
- **UH College of Optometry grad year + 26 = age** is the dominant proxy. UHCO is the only TX optometry school; most TX optometrists are UH grads.
- **Today's Vision is a franchise network** — discovered mid-run as new disqualifier (Klein Eyecare was a Today's Vision franchise location). Add to optometry config exclusion list.
- **Vision Source is an independent cooperative, NOT a roll-up.** 20 Vision Source members in the spine were INCLUDED as eligible targets. PE platforms do acquire Vision Source members, but Vision Source itself is buyer-friendly.
- **Spine over-flagged 2 "STRONG A-tier" picks (Austin Optometry Group, Austin Vision Center)** that demoted on enrichment when current-owner tenure (not practice tenure) was checked. Worth recalibrating spine pre-flagging.
- **MD-vs-OD misclassification at the spine layer:** Alamo Eye Institute / Dr. Lynnell Lowry is an MD ophthalmologist (GWU SOM 1993), not an OD. Spine should filter on TBVME license existence before inclusion.

## 7. Limitations

- 14 B_forward is the lowest absolute count of any vertical, but 35 C_watch is the highest — many practices are 25-30 yr solo operators whose owner age couldn't be confirmed.
- TSO Sugar Land has TSO cooperative ROFR/transfer rules that need diligence before pursuing.
- Owner identity opaque for 4 B candidates (Tanglewood Vision Center, Mi Vision Eye Care, Lakeside Vision & Optical) — needs TOB license lookup.

## 8. Next-step recommendation

**Highest ROI follow-up:** TOB Playwright lookup + CAD OV65 verification for the top 5 B candidates (Bellaire Optometry, Vision Plus, North Texas Eye Care, Vision Source Aldine, Park Cities Eye Associates). 1-2 hours of work would likely promote 2-3 to A-tier.

The **#1 single pick**: **Bellaire Optometry Clinic (Houston)** — Dr. Anne Le UHCO 1989 founder ~63, 37-yr SOLO OD founder-owner. Cleanest A-tier-pending profile in the run. Premium SW Harris demographic.

The **#2**: **Vision Plus (San Antonio)** — Dr. Goldstein ~64, 32-yr husband-wife operator. Less consolidator pressure in Bexar than DFW.

The **#3** (premium-ZIP play): **Park Cities Eye Associates (Dallas 75225)** — Dr. Cathy Ann Norton, 30-yr solo, dry-eye specialty, no associate bench. Most direct PE bolt-on candidate.
