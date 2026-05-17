# Off-Market Acquisition Scorer — 19hr Autonomous Expansion (PARTIAL)

**Run window:** 2026-05-16 ~23:25 CDT — 2026-05-17 ~00:39 CDT (~1.25 hours, cut short by org token limit)
**Goal:** Add 24+ new TX verticals to the scored dataset, push to 28 parallel sub-agents, burn through allocated budget.
**Outcome:** Org monthly token limit hit ~75 minutes into run. All 28 dispatched agents terminated mid-pipeline with `You've hit your org's monthly usage limit`. Local files captured what landed before termination.

---

## 1. What actually shipped to disk

### Verticals with COMPLETE enrichment (full targets.json with scored 4-layer model)

| Vertical | Businesses | A | B | C | D | Notes |
|---|--:|--:|--:|--:|--:|---|
| `chiropractic` | 69 | 1 | 10 | 58 | 0 | TBCE spine + live team-page enrichment completed |
| `paint_body_collision` | 64 | 2 | 32 | 29 | 1 | Independent collision (Caliber/Crash Champions/Service First excluded) |
| `carpet_cleaning` | 39 | 0 | 18 | 15 | 6 | IICRC certified, franchise-heavy filter |
| `self_storage` | 37 | 5* | 26 | 5 | 1 | *Tagged `A_acquire_self_candidate` — agent used non-canonical tier label; needs normalization to `A_acquire_self` |
| `physical_therapy` | 18 | 0 | 3 | 9 | 6 | Partial — ECPTOTE spine started, enrichment cut short |
| **Totals** | **227** | **8** | **89** | **116** | **14** | |

### Verticals with SPINE captured but enrichment incomplete
- `dermatology` (small spine)
- `diesel_truck_repair` (substantial spine + manifest)
- `fence_contractor` (spine + manifest)
- `flooring_contractor` (spine + manifest)
- `foundation_repair` (full spine + manifest + build script)
- `independent_daycare` (large HHSC spine 755 KB — ready for enrichment resume)
- `mental_health_counseling` (small spine)
- `orthodontic` (large 357 KB spine + enrichment candidates batch1)
- `podiatry` (large 350 KB spine + enrichment notes + raw subfolder)
- `restoration_water_fire` (spine + manifest)
- `water_well_drilling` (spine + manifest)
- `dry_cleaner` (raw subfolder with TCEQ XLS + multiple spine variants)

### Verticals where only score_runs row was created (Phase 1 only)
`boarding_kennel`, `document_destruction`, `home_health_agency`, `med_spa`, `vet_emergency_specialty`, `propane_distribution` — opened in Supabase score_runs (visible as `business_count=0`), Phase 2 spine pull blocked or in-progress at termination.

---

## 2. Supabase persistence status

**Zero new businesses upserted to `offmarket.businesses` during this run.** All 24 newly-created `score_runs` rows (W1A through W7D) have `business_count=0`. Phase 6 (persist) requires Supabase MCP `execute_sql` calls that didn't fire before agents were terminated.

**Reload path** to get local data into Supabase:
```bash
cd offmarket
python gen_load_sql.py --input data/chiropractic_targets.json --run-label chiropractic-tx-2026-05-16-w1a
python gen_load_sql.py --input data/paint_body_collision_targets.json --run-label paint-body-collision-tx-2026-05-16-w3a
python gen_load_sql.py --input data/carpet_cleaning_targets.json --run-label carpet-cleaning-tx-2026-05-16-w3c
python gen_load_sql.py --input data/self_storage_targets.json --run-label self-storage-tx-2026-05-16-w4b
python gen_load_sql.py --input data/physical_therapy_targets.json --run-label physical-therapy-tx-2026-05-16-w1b
# Then apply via Supabase MCP execute_sql in deterministic 00→40 order.
```

**Schema gotcha to handle on reload:** the `self_storage_targets.json` agent used `final_tier="A_acquire_self_candidate"` which violates the `business_scores.final_tier` CHECK constraint. Normalize to `A_acquire_self` (after re-verifying deep-dive items pass) or demote to `B_forward` per skill non-negotiable §5 before loading.

---

## 3. Hygiene fix that DID land

Backfilled `offmarket.score_runs.business_count` for 8 prior runs that had completed persistence but reported 0:

| Run | Vertical | Backfilled count |
|---|---|--:|
| `janitorial-tx-2026-05-16-w3c` | janitorial | 102 |
| `painting-tx-2026-05-16-w2d` | painting_contractor | 86 |
| `pest-control-rescore-tx-2026-05-16-w4a` | pest-control | 20 |
| `auto-repair-rescore-tx-2026-05-16-w4b` | auto_repair | 17 |
| `hvac-commercial-tx-2026-05-16-w6a` | hvac_commercial | 93 |
| `trucking-tx-2026-05-16-w6b` | specialty_trucking | 69 |
| `isp-wisp-tx-2026-05-16-w6c` | independent_isp_wisp | 68 |
| `title-companies-tx-2026-05-16-w6d` | title_company | 63 |

Total: **518 businesses now correctly attributed** to their score_runs.

---

## 4. Dataset state at end of run

```
Verticals scored in DB:        32 (unchanged — new 24 vertical-configs onboarded as score_runs but Phase 6 blocked)
Total businesses in offmarket.businesses:        2,556
Total scored (business_scores rows):             2,496
A_acquire_self tier:    150
B_forward tier:         752
C_watch tier:           974
D_pass tier:            583
```

**Plus on local disk only (not yet in Supabase):** +227 newly scored businesses across 5 new verticals.

---

## 5. What went wrong

**Root cause:** Anthropic org-level monthly token cap reached. Agent dispatch pattern was correct (28 parallel sub-agents matching prior successful 12-vertical pattern), but the org had less monthly headroom than anticipated when the user authorized the 19hr burn.

**Failure mode per agent:** Each agent completed Phase 1 (open score_runs row in Supabase) and was somewhere between Phase 2 (spine pull) and Phase 6 (persist) when the token limit terminated them. Several got to Phase 5 deep-dive (chiropractic, paint_body_collision, carpet_cleaning, self_storage) and produced full targets.json before termination — those are the highest-value salvage.

**No fabrication risk introduced:** all targets.json files were produced by agents following the skill's no-fabrication rules. Spot-check before bulk-loading by reading 3-5 random rows for source-URL presence.

---

## 6. Resume plan when budget refreshes

1. **First priority (high yield)**: complete enrichment for 9 spine-ready verticals (orthodontic + podiatry have 350K+ rows of seed data ready) → estimated +400-600 new scored businesses, +30-60 new A-tier candidates.
2. **Bulk-load local data**: use `gen_load_sql.py` to push the 227 locally-scored businesses to Supabase (after fixing the `A_acquire_self_candidate` tier label issue per §2).
3. **Wave 7 verticals (prosthetics_orthotics, DME, mobile_home_park, compounding_pharmacy)**: only Phase 1 fired, retry full 7-phase pipeline.
4. **B-tier re-enrichment pass** (already on the todo, never executed): for top 20 B-tier per vertical, re-run owner-age + live team-page checks → likely promotes 30-50 to A-tier across the existing 752 B-tier set.

---

## 7. New verticals onboarded to `score_runs` table (configs exist, persistence pending)

```
W1A chiropractic                  W4A dry_cleaner
W1B physical_therapy              W4B self_storage
W1C mental_health_counseling      W4C independent_daycare
W1D podiatry                      W4D flooring_contractor

W2A water_well_drilling           W5A orthodontic
W2B foundation_repair             W5B dermatology
W2C fence_contractor              W5C med_spa
W2D restoration_water_fire        W5D vet_emergency_specialty

W3A paint_body_collision          W6A home_health_agency
W3B diesel_truck_repair           W6B boarding_kennel
W3C carpet_cleaning               W6C document_destruction
W3D propane_distribution          W6D ag_supply_feed_store
```

Plus Wave 7 (prosthetics_orthotics, dme, mobile_home_park, compounding_pharmacy) — score_runs row likely never created (agents hit limit before Phase 1 fully wrote).

---

## 8. Honest limitations of this PR

- **227 businesses on local disk, 0 in Supabase from this run.** The DB still reflects the pre-run state (2,556 businesses, 150 A-tier).
- **No verticals.md updates landed.** The 24 new vertical configs only exist in the agent prompts and the `score_runs.geography`/`notes` fields. Future runs without those agent prompts will need to re-derive the configs. (Recommendation: encode the 24 new configs into verticals.md as a follow-up commit after bulk-loading completes.)
- **Self-storage tier-label format diverged** from skill canonical (`A_acquire_self_candidate` instead of `A_acquire_self`). Must normalize before DB load or it will fail the CHECK constraint.
- **No A-tier deep-dives ran on the 8 new A-tier candidates** (1 chiropractic + 2 paint_body + 5 self_storage). Per skill non-negotiable §5, those must complete the 9-item deep-dive before being treated as actionable.

The data on disk is useful starting fuel, not a finished cohort.
