# Ship Approval — claude/fervent-kilby-9ed36a (4-vertical off-market acquisition scorer run)

## Intent

Capture the artifacts from an off-market acquisition research run across 4 Texas verticals — Fire & Life Safety, Independent P&C Insurance, Veterinary, Optometry. This is an additive output-only commit: it adds run-output JSON/CSV files, markdown reports, reusable scoring scripts, and a future-enrichment backlog under `offmarket/`. It does NOT modify any application source code (no changes to `app/`, `worker/`, `dashboard/`, `api/`, etc.). The scoring data itself is also written to Supabase project `gggmmjvwbbfvrtjjlqvr` schema `offmarket` (254 businesses, 254 scores, ~810 signals); the JSON files committed here are the local-files-also output per the skill's "always write the local files" rule.

The run scored 254 businesses across 4 verticals. After a Playwright-driven A-tier deep-dive verification pass (the 5th sub-deliverable in this run), 6 candidates were promoted to `A_acquire_self` with verified OV65 / Comptroller / successor-check evidence: Whitaker Insurance (San Antonio), Bankhead Insurance Agency (Dallas), Animal Hospital of Valley Ranch (Irving), Bridge Street Animal Clinic (Fort Worth), Longenbaugh Veterinary Hospital (Houston), North Texas Eye Care (Southlake). 55 additional candidates are `B_forward` (forward to ETA / search-fund community). Whitaker Insurance is the highest-confidence pick (Bexar CAD OV65 verified, IIAT 2023 Drex Foreman lifetime achievement award = strong imminent-sale signal).

The branch also reflects per-vertical config updates to the offmarket scorer skill at `/Users/gideonspencer/.claude/skills/offmarket-acquisition-scorer/verticals.md` (Fire stub fully fleshed out; Vet + Insurance + Optometry sections added). Those are outside this repo (they live in Gideon's global Claude skills directory) so they don't appear in this diff but ARE saved on disk.

## Files changed

### Reports (5 markdown files)

- `offmarket/REPORT-fire-tx-2026-05-15.md` — Fire & Life Safety run summary: 60 scored businesses, 8 B_forward, top picks Fire Safe Protection Services + Richardson Fire Equipment + Lone Star Fire Extinguisher.
- `offmarket/REPORT-insurance-tx-2026-05-15.md` — Insurance run summary: 50 scored, 18 B_forward, top picks Whitaker Insurance + Perdue + Bankhead.
- `offmarket/REPORT-vet-tx-2026-05-15.md` — Veterinary run summary: 65 scored, 24 B_forward, top picks Mellina Animal Hospital + White Rock + Colleyville.
- `offmarket/REPORT-optometry-tx-2026-05-15.md` — Optometry run summary: 79 scored, 14 B_forward, top picks Altig Optical + Vision Plus + Bellaire Optometry.
- `offmarket/REPORT-CROSS-VERTICAL-2026-05-15.md` — Cross-vertical synthesis with strategic-map: which vertical fits roll-up-and-sell vs scale-and-run vs cash-flow strategies; top 12 candidates across all 4 verticals; data-limitation analysis; recommended next steps.

### Future enrichment backlog (1 file)

- `offmarket/FUTURE-ENRICHMENT-IDEAS.md` — 15 categorized future-enrichment options (Tier A: scoring confidence improvements; Tier B: M&A intelligence; Tier C: long-tail / restricted-access; Tier D: aspirational / experimental). Captures decisions on D&B/ZoomInfo, SBA 7(a) public data, PitchBook subscription, voter file access, etc. Flagged for review when 2-3 active acquisition conversations are in motion.

### Scoring scripts (6 files, reusable for future quarterly runs)

- `offmarket/score_fire.py` — Rule-based scorer: applies 4-layer model + hard gates (platform-affiliation, ESOP, succession-completed, too-young, too-large) for the Fire & Life Safety vertical.
- `offmarket/score_insurance.py` — Same pattern for Insurance: captive-vs-independent filter, platform-subsidiary filter, franchise filter (Goosehead/TWFG), succession-in-place demotions.
- `offmarket/score_vet.py` — Same pattern for Veterinary: platform consolidator filter (NVA/SVP/Innovetive/Lakefield/Thrive/VetCor/PPV/CityVet), recent-acquisition filter, succession-in-place demotions.
- `offmarket/score_optometry.py` — Same pattern for Optometry: retail-chain filter (MyEyeDr/Acuity/Keplr/AEG/US Vision), Vision Source members included as independent co-op (NOT platform), Today's Vision franchise filter (discovered mid-run).
- `offmarket/fire_overrides.py` — Orchestrator manual overrides applied after the rule-based scorer: demotes Eagle Fire Extinguisher (Wright-bought-from-Massey 2024 = succession completed), promotes Richardson Fire Equipment + Lone Star Fire Extinguisher based on sub-agent qualitative successor-gap evidence, writes value_add_thesis text for B candidates.
- `offmarket/insurance_overrides.py` — Same pattern for Insurance: demotes Bosworth & Associates (Cambridge Bosworth 2nd-gen in training = succession in motion), promotes Bankhead with confirmed age=70, writes value_add_thesis text.

### Spine + enrichment + scored data (per vertical, 41 JSON/CSV files)

- `offmarket/data/fire_spine.json` — 62 verified TX fire & life safety companies (spine).
- `offmarket/data/fire_enrich_batch_{1,2,3,4}.json` — 4 enrichment batches (16+16+15+15 rows).
- `offmarket/data/fire_targets.json` — 60 unique scored rows (deduped) + scoring metadata.
- `offmarket/data/fire_targets.csv` — Flat 32-column export, one row per business.
- `offmarket/data/fire_run_manifest.json` — Sources worked/blocked, model version, weights, timestamps.
- `offmarket/data/fire_supabase_write.json` — Persistence agent's verification summary.

Same shape for `insurance_*` (3 enrich batches, 50 rows), `vet_*` (3 enrich batches, 65 rows), and `optometry_*` (4 enrich batches, 79 rows).

### Deep-dive verification artifacts (8 files)

- `offmarket/data/top15_for_deep_dive.json` — Top 15 B_forward candidates extracted for Playwright deep-dive.
- `offmarket/data/deep_dive_verification.json` — Machine-readable verification summary: 6 A-tier promotions, 3 C_watch demotions, success metrics by source.
- `offmarket/data/deep_dive_raw/comptroller_results.json` — Raw TX Comptroller Taxable Entity Search results per candidate (entity_status, formation_date, registered_agent, sos_file_number).
- `offmarket/data/deep_dive_raw/cad_results.json` — Raw CAD homestead lookup results per candidate (OV65, deed dates, owner name on deed).
- `offmarket/data/deep_dive_raw/team_page_results.json` — Raw team/about page successor-check results per candidate.
- `offmarket/data/deep_dive_raw/01_whitaker_comptroller.json` — Per-candidate detailed Comptroller PIR for Whitaker (top A pick).
- `offmarket/data/deep_dive_raw/02_whiterock_comptroller.json` — Same for White Rock Animal Hospital.
- `offmarket/data/deep_dive_raw/06_perdue_comptroller.json` — Same for Perdue Insurance Agency.

## Confirmation

No files outside the intended scope were modified. All changes are additive under `offmarket/` (a previously-existing folder for off-market acquisition research output). Zero changes to application source code (`app/`, `worker/`, `api/`, `dashboard/`, `lib/`, etc.). Zero changes to schema, migrations, or runtime configuration. The Supabase writes were performed against the existing `offmarket` schema (created in a prior spike); no DDL changes. Pre-commit prettier hook reformatted JSON/markdown to project style; those formatting changes are in the second commit (`693bbf6`). No `--no-verify` used. No force-push. Branch is `claude/fervent-kilby-9ed36a`, not main.
