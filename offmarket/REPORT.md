# Off-Market Texas Dental Acquisition Scorer — Spike Report

**Run:** `dental-tx-spike-2026-05-12` · **Model:** `offmarket-dental-4layer-v0.1` · **Generated:** 2026-05-12
**Outputs:** `offmarket/data/dental_targets.json` · `offmarket/data/dental_targets.csv` · `offmarket/data/run_manifest.json`
**Supabase:** **WRITTEN** — loaded into schema `offmarket` (project `gggmmjvwbbfvrtjjlqvr`) by the main session via the Supabase MCP after the autonomous sub-agent's own `execute_sql` call was permission-denied. `score_runs` id = `38f59bde-c3a1-5f3a-8434-e0f6ef717462`; 60 `businesses`, 213 `business_signals`, 60 `business_scores`. Query via the `offmarket.scored_targets` view. The load is reproducible from `offmarket/data/dental_targets.json` via `offmarket/gen_load_sql.py` (deterministic uuid5 keys) → ordered SQL chunks under `offmarket/data/sql/`.

---

## 1. Summary

**60 real, name-verifiable Texas dental practices** were enriched and scored on the 4-layer composite model (Layer 1 owner base-rate / Layer 2 sellability / Layer 3 behavioral "coasting" trigger / Layer 4 market pull; weights L1 .30 / L2 .25 / L3 .30 / L4 .15).

- **County breakdown:** Harris 26 · Dallas 19 · Travis 7 · Fort Bend 3 · Williamson 2 · Montgomery 2 · Brazoria 1. (Williamson/Montgomery/Brazoria rows are Austin/Houston-metro suburbs kept as lower-priority rows; the three core target counties — Harris/Dallas/Travis — account for 52 of the 60.)
- **Tier counts:** **A_acquire_self 4** · **B_forward 23** · **C_watch 30** · **D_pass 3**.
- **Excluded for distress:** **0.** No public distress signal (franchise-tax forfeiture, disciplinary action, lien/judgment/malpractice, closing notice, complaint spike) surfaced for any practice in this run — but the distress screen is *incomplete* (the Comptroller, county-clerk and disciplinary checks were not reachable; see §4). A human should re-run those checks before acting on any lead. The 3 `D_pass` rows are there because their owner is mid-career / recently bought the practice (low L1, low L3), not because they're distressed.
- **Headline coverage caveat:** **owner ages are proxies** — almost entirely license-tenure / dental-school-grad-year (or "in practice since") proxies, *not* OV65 homestead exemptions, voter-file DOB, or DMV. The state licensing-board bulk data (`tsbde.texas.gov`, `data.texas.gov`) and the county appraisal-district bulk files (HCAD/DCAD/TCAD) were not retrievable in this sandbox (403s / not-in-allowlist), so license numbers, exact license issue dates, franchise-tax status, and SoS formation data are missing across the board. Confidence is `medium` at best for the strongest rows and `low` for ~40 of the 60.

---

## 2. Top 15 targets

| Practice | City | County | Owner (age + how known) | Yrs in biz | L1/L2/L3/L4 | Final | Tier |
|---|---|---|---|---|---|---|---|
| Stanley LaCroix, DDS, P.C. | West Lake Hills | Travis | Dr. Stanley LaCroix (~71; license_tenure_proxy) | 36 | 92/78/72/88 | 82 | A_acquire_self |
| Fantastic Smiles of Houston | Houston | Harris | Dr. Jean D. Morency (~72; license_tenure_proxy) | 40 | 90/74/72/86 | 80 | A_acquire_self |
| Leffall Family Dentistry, P.C. | Dallas | Dallas | Dr. Martia Lewis Leffall (~68; license_tenure_proxy) | 41 | 88/72/72/84 | 79 | A_acquire_self |
| Michael V. Woolwine, D.D.S. | Austin | Travis | Dr. Michael V. Woolwine (~66; license_tenure_proxy) | 41 | 86/76/70/88 | 79 | A_acquire_self |
| Kidwell & Albus Preventive and Restorative Dentistry of Dallas | Dallas | Dallas | Dr. (R. Bruce) Kidwell (with Dr. Derek M. Albus) (~73; license_tenure_proxy) | 60 | 86/82/62/88 | 78 | B_forward |
| Grant K. Parish, DDS | Dallas | Dallas | Dr. Grant K. Parish (~65; license_tenure_proxy) | 39 | 84/72/70/83 | 77 | B_forward |
| The Houston Dentists | Bellaire | Harris | Dr. Kathy Frazar (~62; license_tenure_proxy) | 37 | 75/85/62/88 | 76 | B_forward |
| Lora M. Mason, D.D.S., P.A. | Bellaire | Harris | Dr. Lora M. Mason (~60; license_tenure_proxy) | 68 | 72/80/68/86 | 75 | B_forward |
| Barry H. Buchanan, DDS | Dallas | Dallas | Dr. Barry H. Buchanan (~63; license_tenure_proxy) | 37 | 78/78/66/84 | 75 | B_forward |
| Bruce A. Matson, D.D.S. | Houston | Harris | Dr. Bruce A. Matson (~62; license_tenure_proxy) | 36 | 80/76/66/82 | 75 | B_forward |
| Ronald K. Rich, DDS, MAGD | Sugar Land | Fort Bend | Dr. Ronald K. Rich (~67; license_tenure_proxy) | 30 | 82/60/78/78 | 75 | B_forward |
| Mary F. Riley, D.D.S., P.C. | Houston | Harris | Dr. Mary F. Riley (~60; license_tenure_proxy) | 32 | 72/76/70/85 | 74 | B_forward |
| Katy Family Dentists | Katy | Harris | Dr. Byron 'Joey' Hall (~60; license_tenure_proxy) | 29 | 74/76/66/84 | 74 | B_forward |
| Park Cities Family Dentistry, P.A. | Dallas | Dallas | Dr. Jeffrey W. Hubbard (~62; license_tenure_proxy) | 37 | 76/84/58/88 | 74 | B_forward |
| Woodhill Family Dental | Dallas | Dallas | Dr. Jack Freudenfeld Jr. (with Dr. Amy Horton) (~65; license_tenure_proxy) | 38 | 78/80/60/86 | 74 | B_forward |

(Full 60-row list with all four layer comments, final comment, value-add thesis, and confidence in `dental_targets.csv` / `dental_targets.json`.)

---

## 3. The `A_acquire_self` list (pursue directly)

All clear the A gates: final ≥ 78, L1 ≥ 70, L3 ≥ 65, not distressed, confidence ≥ medium.

### Leffall Family Dentistry, P.C. (Martia Lewis Leffall, DDS) — Dallas (Dallas), 75224
*Final 79 · L1 88 / L2 72 / L3 72 / L4 84 · confidence medium*

Dr. Martia Lewis Leffall, ~68 (license_tenure_proxy), runs Leffall Family Dentistry, P.C. (Martia Lewis Leffall, DDS) in Dallas, Dallas County. Dr. Leffall has ~42 years of dental experience (grad ~1983/84), founded the practice with her late husband Dr. Lindell Leffall Jr. in 1985, and is now the sole owner/CEO — tenure proxy ~67-70, squarely in the natural-exit window, with no junior partner. The co-founder's death and her age make a sale highly plausible in 1-3 yrs. Medium confidence (proxy age, but consistent across sources). NPI 1144399460. Strong coasting profile: sole listed provider with no associate, founder near a natural exit after the co-founder's death, dated web brand, no visible recent expansion or hiring, single location of 40+ yrs. Healthy P&L, disengaged operating posture — not distress. Dallas is a top-tier DSO/PE dental market; an established Oak Cliff practice with a loyal multigenerational base is a clean SBA-financeable bolt-on, and the buyer community actively seeks transition-ready solo practices. Composite 79/100. Tier A — Gideon should pursue this one directly.

**Value-add:** AI front desk + automated recall to reactivate the lapsed-hygiene base, online scheduling, modern PMS migration, automated review generation, and an associate-to-owner glide path — a credible 1.5-2x EBITDA path over 18-24 months in a stable urban catchment.

### Stanley LaCroix, DDS, P.C. (LaCroix Family Dental) — West Lake Hills (Travis), 78746
*Final 82 · L1 92 / L2 78 / L3 72 / L4 88 · confidence medium*

Dr. Stanley LaCroix, ~71 (license_tenure_proxy), runs Stanley LaCroix, DDS, P.C. (LaCroix Family Dental) in West Lake Hills, Travis County. Dr. LaCroix earned his DDS from UT Health Science Center Houston in 1978 (~48 yrs licensed) and has practiced family dentistry in Westlake Hills for 36+ yrs — tenure proxy ~70-73, deep in the natural-exit window; solo owner with no associate. The single cleanest base-rate signal in this run. Medium confidence (proxy age, but strongly corroborated). Strong coasting profile: solo provider with no associate, 36+ yrs in the same area/building, dated web presence, no visible recent expansion or hiring, owner well past typical retirement age. Healthy practice, classic pre-sale disengaged-growth posture — not distress. Westlake Hills / Bee Caves Rd is a premium Austin catchment; Austin is a top-3 active DSO/PE dental market and a clean long-tenured solo GP in 78746 is a prime SBA-financed acquisition and a hotly-sought forward to searchers. Composite 82/100. Tier A — Gideon should pursue this one directly.

**Value-add:** AI front desk + recall automation to reactivate the lapsed-hygiene base, online scheduling, modern PMS migration, automated reviews, plus immediate associate hire on a buy-in path — a credible 1.5-2x EBITDA path over 18-24 months in a premium, supply-constrained catchment.

### Michael V. Woolwine, D.D.S. (The Grove Austin Family Dentistry) — Austin (Travis), 78731
*Final 79 · L1 86 / L2 76 / L3 70 / L4 88 · confidence medium*

Dr. Michael V. Woolwine, ~66 (license_tenure_proxy), runs Michael V. Woolwine, D.D.S. (The Grove Austin Family Dentistry) in Austin, Travis County. Dr. Woolwine (UT Health San Antonio DDS) has practiced in the same Austin building since 1985 (~41 yrs) — tenure proxy ~64-68, squarely in the natural-exit window; solo owner with no associate. Strong base-rate signal. Medium confidence (proxy age). Strong coasting profile: solo provider with no associate, same building for 41 yrs, recent cosmetic rebrand but otherwise dated presence, no visible recent expansion or hiring, owner near a natural exit. Healthy, disengaged-growth — not distress. Central Austin (78731, near 38th St/Mopac) is a premium, supply-constrained catchment; Austin is a top DSO/PE dental market and a clean long-tenured solo GP there is a prime SBA-financed acquisition. Composite 79/100. Tier A — Gideon should pursue this one directly.

**Value-add:** AI front desk + recall automation, online scheduling, modern PMS migration, automated reviews, plus an associate-to-owner glide path; the recent rebrand gives a marketing platform to build on — credible 1.5-2x EBITDA path over 18-24 months.

### Fantastic Smiles of Houston (Jean D. Morency, DMD) — Houston (Harris), 77025
*Final 80 · L1 90 / L2 74 / L3 72 / L4 86 · confidence medium*

Dr. Jean D. Morency, ~72 (license_tenure_proxy), runs Fantastic Smiles of Houston (Jean D. Morency, DMD) in Houston, Harris County. Dr. Morency earned his DMD from Harvard School of Dental Medicine in 1977 (~49 yrs licensed; ~40 yrs running his Houston practice) — tenure proxy ~71-74, deep in the natural-exit window; solo owner ('Company Owner' on LinkedIn) with no associate. The cleanest base-rate signal in the run alongside LaCroix. Medium confidence (proxy age, strongly corroborated). Strong coasting profile: solo provider with no associate after ~40 yrs, dated web brand (the site is dated and design-old), single location, no visible recent expansion or hiring, owner well past typical retirement age. Healthy practice, classic pre-sale disengaged-growth — not distress. West University Place / Medical Center Houston (77025) is a premium, supply-constrained catchment; an implant-capable long-tenured solo practice there is a prime SBA-financed acquisition and a hotly-sought forward to searchers. Industry context: dental is ~30%+ DSO-penetrated and rising; Houston/Dallas/Austin are all active DSO/PE roll-up metros with strong SBA-7(a) financeability and high ETA/search-fund appetite. Composite 80/100. Tier A — Gideon should pursue this one directly.

**Value-add:** AI front desk + recall automation to reactivate the lapsed-hygiene base, online scheduling, modern PMS migration, automated reviews, plus an immediate associate hire on a buy-in path — a credible 1.5-2x EBITDA path over 18-24 months in a premium catchment.

> **Just below the A line:** Kidwell & Albus (Dallas, final 78 — B only because L3 = 62: founder ~73 with a built-in successor, so a textbook associate-buy-in rather than a coasting grab); Grant K. Parish DDS (Dallas, final 77, L1 84 / L3 70 — a 39-yr solo GP same-location-since-1986, a near-A); The Houston Dentists / Dr. Kathy Frazar (Bellaire, final 76); Lora M. Mason DDS (Bellaire, 75); Barry H. Buchanan DDS (Dallas, 75); Bruce A. Matson DDS (Houston, 75). These are the strongest `B_forward` rows.

---

## 4. What real data I got vs. what was blocked

| Source | Status | Detail |
|---|---|---|
| **Google web search (search index summaries)** | **WORKED** | Primary discovery + enrichment channel. Practice names, addresses, owner-dentist names, founding / dental-school-grad years, hours, review counts via indexed snippets of practice websites and directory profiles. |
| **Yelp / Healthgrades / WebMD / US News / ADA Find-a-Dentist / NPI registry** | **WORKED (via search summaries)** | Review counts, addresses, license-holder confirmation, NPI numbers (e.g., Leffall NPI 1144399460, Salha NPI 1467553792, Matson NPI 1184135322). Surfaced through search; consistent direct page fetches not available. |
| **Practice websites (direct fetch via WebFetch)** | **PARTIAL / BLOCKED** | Most small-practice sites returned HTTP 403 to WebFetch (bot protection / Cloudflare). Facts recovered from Google index summaries of those pages plus directory profiles. |
| **TSBDE — licensee lists / public license search** (`tsbde.texas.gov`, `ls.tsbde.texas.gov`) | **BLOCKED** | HTTP 403 Forbidden to the automated fetcher (known sandbox quirk for `.gov`). Could not download the bulk licensee CSVs or hit the license-verification search → **license numbers and exact original-issue dates missing for all rows**; license tenure proxied from grad year / "in practice since". |
| **Texas Open Data Portal (`data.texas.gov` / Socrata) — TSBDE "DataSet-01 All Licenses" (`tm3v-pfq9`)** | **BLOCKED** | HTTP 403 to WebFetch *and* host not in the bash allowlist. Dataset existence confirmed via search (dev.socrata.com foundry page) but the JSON endpoint could not be queried. |
| **TX Comptroller — Taxable Entity Search** (`comptroller.texas.gov`) | **NOT REACHED (expected-blocked, `.gov`)** | Franchise-tax status (a distress signal) and SoS file numbers / officers **unverified**. No business confirmed forfeited; equally, none confirmed in good standing. |
| **TX SOSDirect — formation dates, assumed-name certs** (`sos.state.tx.us`) | **NOT ATTEMPTED** | Paid ($1/search) and `.gov`. `entity_formation_date` / `entity_sos_file_number` missing for all rows. |
| **County Appraisal Districts — HCAD / DCAD / TCAD — OV65 homestead exemptions, bulk PDATA** | **NOT OBTAINED** | Bulk appraisal-roll downloads not retrievable in this sandbox → the cleanest legal owner-age signal (OV65 self-declared 65+) and owner-property/deed-date data unavailable. Owner ages fall back to license-tenure proxies. |
| **Texas voter file (DOB) / Texas DMV** | **NOT OBTAINED (and restricted-use)** | Not retrievable here, and restricted: TX Election Code limits voter-roll use to non-commercial/election; DPPA limits DMV use. Authorized for Gideon's private research only — **none used in this run; no PII from these sources in any output.** |
| **Wayback Machine (web.archive.org)** | **NOT SYSTEMATICALLY USED** | Not run per-practice this pass (turn budget). "Dated web brand" L3 signals inferred from current presentation, not snapshot diffs. |
| **WHOIS · Indeed/Glassdoor hiring · Facebook/Instagram recency · county deed records** | **NOT USED** | Out of scope for this turn-budget-limited pass; in §6. |

---

## 5. Scoring model as run (so you can retune)

- **Four layers, each 0-100, each with a 1-3 sentence evidence-citing comment:**
  - **L1 Base Rate** — owner natural-exit timing (owner age via OV65 ⇒ ≥65, voter DOB, else license-tenure proxy; owner tenure; entity/practice age; long homestead tenure). Anchors: owner 68+ → 88-100; 63-67 → 75-90; 58-62 → 55-78; 53-57 → 35-58; <53 / weak proxies → 10-35. ≥25 yr tenure nudges up; <10 down.
  - **L2 Sellability / Quality** — real, healthy, SBA-financeable, *not distressed*, not a fresh startup; recurring/needs-based revenue (hygiene recall ✓), 5+ yrs in business, more than one person / systems, clean license, plausible SBA size (~\$500k-\$5M revenue est. from provider/chair count + review volume + footprint). Anchors: clean multi-provider 10+ yr recurring-revenue practice of reasonable size → 80-95; clean solo 10+ yr → 65-82; <5 yrs → ≤35; any disciplinary action → heavy penalty.
  - **L3 Behavioral Trigger ("coasting owner")** — healthy P&L, owner has visibly stopped pushing: website not meaningfully updated 3+ yrs / outdated tech / no SSL / not mobile; review velocity flat or declining / newest review >60 days; no new associate in years; zero job postings in 12 mo; sole listed provider / "& Associates" with no associates; no online booking / no modern PMS; reduced or "by appointment only" hours creep; no recent capex; owner owns the building; lapsed assumed-name cert; OV65 filed. Coasting ≠ distress (distress = excluded). Anchors: 4+ strong tells → 80-100; 2-3 → 55-80; exactly 1 → 30-55; none → 10-30.
  - **L4 Market Pull** — acquirer demand for the vertical × metro: dental DSO/PE roll-up activity (very high — ~30%+ DSO penetration and climbing; many TX-focused DSOs/PE platforms); comparable-transaction velocity in the metro (Houston/Dallas/Austin all active); SBA 7(a) financeability of dental acquisitions (top-tier); ETA/search-fund/independent-sponsor appetite. Mostly a vertical+metro constant (~80-90) for TX-dental-in-a-major-metro, nudged by sub-market and specialty (perio/endo/pedo/prostho vs. general; metro vs. exurb).
- **Hard gates first:** distressed → `D_pass`, final ≤ 25; <5 yrs in business → final capped ≤ 35; can't verify the practice is real → drop entirely. (No practice in this run hit either cap — all 60 are real and ≥5 yrs old.)
- **Weights:** L1 0.30, L2 0.25, L3 0.30, L4 0.15. `final_score = round(0.30·L1 + 0.25·L2 + 0.30·L3 + 0.15·L4)`. (Recorded in `run_manifest.json.weights` and the intended `score_runs.weights` row.)
- **Tiers:** `A_acquire_self` = final ≥ 78 AND L1 ≥ 70 AND L3 ≥ 65 AND not distressed AND confidence ≥ medium → pursue directly. `B_forward` = final 60-77 (or ≥78 but failing an A gate) → hand to the buyer/searcher community. `C_watch` = final 45-59 → re-score in ~90 days. `D_pass` = final < 45, or distressed, or too young.

**Retuning notes:** L4 currently flat-lines ~80-88 by design (dental-in-major-TX-metro). To make the model discriminate more on market, push L4's weight up and widen its spread by sub-market (premium ZIP +5, exurb -8, narrow specialty -6). L1 is the biggest lever on the A list and is the layer most degraded by the missing OV65/voter data — once those connectors exist, expect several current `B_forward` rows to firm up into `A`.

---

## 6. What the productionized `offmarket-acquisition-scorer` skill needs

**Connectors to build (priority order):**
1. **TSBDE bulk licensee CSV / `data.texas.gov` Socrata (`tm3v-pfq9`)** — the practice spine: licensee name, license #, type/status, **original issue date** (the proper license-tenure signal), city/county/ZIP, disciplinary flags, dental-entity registrations. Pull statewide nightly; the issue date alone replaces most of this run's hand-built proxies. (Needs a non-`.gov`-403-ing fetch path: rotate UA / Socrata API key / proxy.)
2. **County appraisal districts — HCAD (Harris), DCAD (Dallas), TCAD (Travis), then statewide** — OV65 homestead-exemption flag + owner name + homestead address + **deed/acquisition date**. The single cleanest legal owner-age signal in Texas and the biggest accuracy gap in this run. Bulk "PDATA"-style downloads; refresh annually (rolls update each January).
3. **TX Comptroller Taxable Entity Search** — entity legal name, SOS file #, registered agent, officers, **franchise-tax status** (forfeited = distress → exclude). Per-practice lookup at enrich time.
4. **Wayback Machine** — per-practice snapshot-frequency + last-meaningful-change diff (the proper L3 "digital decay" signal). Free API; run at enrich time.
5. **Google Places API** (with a key) — name, address, phone, website, **# reviews + most-recent-review date + rating + hours + owner-responds/photos** — the L3 "activity decline" + L2 size-estimate inputs.
6. **WHOIS** (domain reg/update dates), **Indeed/Glassdoor** (hiring last 12 mo), **Facebook/Instagram** (last-post date), **county deed records** (owner-owns-the-building) — secondary L3 stack.
7. **Voter-file / DMV ingestion (restricted-use)** — only for Gideon's private research; tag every value with `owner_age_source`; never redistribute; keep in `offmarket` schema / local files only. Realistically a manual bulk-file load, not an API.

**Manual-verification checklist (exact source columns to confirm per lead):**
- TSBDE license search → license #, status = active, original issue date, no disciplinary action against the dentist of record.
- Comptroller → franchise-tax status = active / "in good standing" (not "forfeited").
- County appraisal → owner name matches the dentist; OV65 exemption present? deed/acquisition date (long homestead tenure)? does the owner own the practice building?
- Google Maps → review count, newest-review date (>60 days = a tell), rating trend, hours (4-day week / "by appointment only" = a tell), "owner answers" recency.
- Practice website → SSL? mobile-responsive? online booking? modern PMS/patient portal? footer copyright year? sole dentist listed / "& Associates" with no associates? team page stale?
- County clerk + a free PACER-lite search → no tax liens, civil judgments, or malpractice suits.
- Wayback → last meaningful site change; snapshot frequency falling off.

**Refresh cadence:** TSBDE nightly; Comptroller + Google Places + Wayback at enrich time (re-score the `C_watch` cohort every ~90 days, the `B_forward` cohort every ~6 months); county appraisal OV65 rolls annually (January).

**Where the scoring weights should live:** in the `score_runs.weights` jsonb (one row per run) so every scored cohort is reproducible and the weights are A/B-testable across runs — the shape used here.

---

## 7. Honest limitations (double-check before acting on a lead)

1. **Owner ages are proxies, not facts.** Almost every `owner_age_estimate` is a license-tenure / grad-year proxy (or an "in practice since" statement). No OV65, voter DOB, or DMV data obtained. Confidence is `medium` for the ~20 strongest rows and `low` for ~40. Confirm the dentist of record's actual age (county appraisal OV65, or call / LinkedIn) before treating any L1 ≥ 80 as gospel.
2. **The distress screen is incomplete.** No Comptroller franchise-tax check, no TSBDE disciplinary check, no county-clerk lien/judgment search, no PACER. Zero practices were *flagged* distressed because no public signal surfaced through web search — that is not the same as "verified clean." Run those four checks on any lead you intend to approach.
3. **License numbers, SoS formation data, building-ownership, and Wayback-based decay signals are missing** across all rows because the relevant `.gov` / `data.texas.gov` / appraisal-district endpoints were not reachable. The L3 "digital decay" judgments are inferred from each practice's *current* presentation, not historical snapshots.
4. **Sample size is a proof run, not a market census** — 60 practices, hand-curated from web search, weighted to Harris/Dallas/Travis. A productionized run off the TSBDE bulk file would surface thousands.
5. **Some "practices" may be group/DSO-owned, not single-owner.** Fort Bend Dental, Dallas Dental Specialists, Musso Family Dentistry, Today's Dental, The Dentists at North Cypress, Heritage Family Dentistry, Pasadena Family Dentistry, Lovers Lane Dental, Preston Smiles, North Dallas Family Dental and Antoine Dental Center all need an ownership-structure check before being treated as a single-owner target — flagged in their notes.
6. **A few rows are recent-buyer / mid-career owners scored low on purpose** (Vanderbrook, Baucum, Diemer, Doyle, Slaughter, Vlachakis, Vintage Smile, West University Dentistry, etc.) — real, healthy practices, just not aligned with the "coasting owner about to sell" thesis right now; they sit in `C_watch` / `D_pass` as a deliberate re-score-later cohort, not as rejects.
7. **Supabase was not written** (MCP `execute_sql` permission denied). The data is complete in `dental_targets.json`; loading it into schema `offmarket` (create the `score_runs` row first, capture its `id`, then `businesses` / `business_signals` / `business_scores`, then `update score_runs set business_count = 60`) is a straight load from that file.
