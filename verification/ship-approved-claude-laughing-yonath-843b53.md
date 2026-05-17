# Ship Approval — claude/laughing-yonath-843b53

## 1. Intent

This branch is the artifact set from a **19-hour autonomous expansion run** of the off-market acquisition scorer skill on 2026-05-16. The orchestrator (Opus 4.7) spawned 50+ Sonnet sub-agents to: (a) score 12 net-new business verticals (funeral homes, independent pharmacy, CPA firms, hearing aid clinics, pool service, garage door, commercial landscaping, painting contractors, welding/metal fab, glass services, janitorial, CNC machine shops, HVAC commercial, specialty trucking, ISP/WISP, title companies), (b) re-enrich two existing verticals where prior scoring proved unreliable (pest control B-tier with NULL owner_age — 9 A-tier promotions; auto repair B-tier with `license_tenure_proxy` failures — 1 A promotion + 13 corrections), and (c) persist all 1,318 new scored records to the Supabase `offmarket` schema. End result: dataset grew from 1,141 → 2,459 businesses (+115%), A_acquire_self candidates grew from 30 → 150 (+400%). All changes are research artifacts (spine JSONs, enrichment batches, scored targets JSON+CSV, vertical configs, SQL persistence files, mega-report, skill-improvement patches). Every business has at least one verifiable URL in `data_sources` — zero fabrication per the skill's non-negotiables. No application code or infra changed.

## 2. Files changed

- `offmarket/REPORT-MEGA-2026-05-16.md` — cross-vertical mega-report with verified post-persistence numbers
- `offmarket/SKILL_PATCHES_2026-05-16.md` — 7 model-improvement findings encoded for future merge into the skill markdown
- `offmarket/SCORING_INSTRUCTIONS.md` — reusable scoring sub-agent prompt template
- `offmarket/RUN_LOG_2026-05-16.md` — live progress log written during the run
- `offmarket/vertical-configs-2026-05-16.md` — Wave 1 configs (funeral, pharmacy, CPA, hearing aid)
- `offmarket/vertical-configs-wave-2-2026-05-16.md` — Wave 2 configs (pool, garage door, landscaping, painting)
- `offmarket/vertical-configs-wave-3-2026-05-16.md` — Wave 3 configs (welding, glass, janitorial, CNC)
- `offmarket/data/*_spine.json` (16 new) — verified spine candidates per vertical
- `offmarket/data/*_enrich_batch_*.json` (30+) — enrichment evidence per business with URL + timestamp
- `offmarket/data/*_targets.json` and `*_targets.csv` (16 new) — full scored records per vertical
- `offmarket/data/wave4_auto_repair_rescore_results.json`, `wave4_pest_control_rescore_results.json` — Wave 4 re-enrichment outputs
- `offmarket/data/wave4a_pest_db_updates.sql`, `wave4b_auto_repair_db_updates.sql` — Wave 4 Supabase update SQL (already applied)
- `offmarket/data/wave7_persistence_summary.json`, `wave7b_persistence_summary.json`, `wave7c_persistence_summary.json` — per-wave persistence reports
- `offmarket/data/_wave7_sql/` (50+ files) — per-batch persistence SQL transactions for reproducibility
- `offmarket/data/_persist_wave7.py`, `_persist_wave7_rest.py` — persistence helper scripts written by Wave 7 sub-agent
- `offmarket/score_hvac_commercial.py`, `score_pool_service.py`, `score_specialty_trucking.py` — scoring scripts written by Wave 6 scoring sub-agents
- `offmarket/scripts/score_*.py` (5 files) — additional reusable scoring scripts

## 3. Confirmation

No files outside the intended scope were modified. All changes are under `offmarket/` (the off-market acquisition scorer's working directory) plus this verification file. No application code, infra, CI/CD, dependencies, or credentials were touched.
