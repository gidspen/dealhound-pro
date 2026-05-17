# Ship Approval — claude/crazy-khayyam-7adaed

## Intent

Run the off-market acquisition scorer skill across **10 new TX verticals** (HVAC,
plumbing, electrical, auto repair, roofing, commercial signage, locksmith,
septic / OSSF, land surveying, tree care) targeting ~1,000 small businesses
sourced from real TX license-board rosters and verified via live website fetches.
Apply the existing 4-layer scoring model (offmarket-4layer-v0.2), enforce the
`verifying-no-successor.md` failure-mode guard, run A-tier deep-dives with live
team-page fetches, and persist all rows to Supabase project `gggmmjvwbbfvrtjjlqvr`
schema `offmarket`. Output is per-vertical REPORTs, JSON+CSV scored cohorts, SQL
re-load chunks, reusable scoring scripts, and a cross-vertical synthesis report
with 20 confirmed A_acquire_self picks + 10 near-A candidates (one Playwright
CAD-OV65 sprint from promotion) = 30 actionable acquisition targets. No
application code, no infrastructure changes — additive research artifacts only.

## Files changed

### Cross-vertical synthesis report (the main deliverable)

- `offmarket/REPORT-10VERTICAL-CROSSCUT-2026-05-16.md` — the 20 A-tier picks with
  per-target rationale, strategic read by investment thesis, cross-vertical
  insights, lessons learned, 15-vertical future-run brainstorm (10 LOW-PE,
  5 PE-active), and recommended next actions.

### Per-vertical reports (1 file per vertical not returned inline)

- `offmarket/REPORT-surveying-tx-2026-05-15.md` — Land surveying scored cohort
  report (5 A-tier, 82 B-tier).

### Per-vertical structured data (10 verticals × spine/targets/enrich/manifest)

- `offmarket/data/{hvac,plumbing,electrical,autorepair,roofing,signage,locksmith,septic,surveying,treecare}_spine.json` — verified spine candidates per vertical, every row has source URL.
- `offmarket/data/{vertical}_targets.json` + `.csv` — full scored cohort with 4-layer scores, signals, tier, confidence, value-add thesis.
- `offmarket/data/{vertical}_enrich_batch_*.json` — per-batch enrichment evidence (live website fetches, license-board confirmations, family-successor checks).
- `offmarket/data/{vertical}_run_manifest.json` — sources hit/blocked, model + weights, telemetry.
- `offmarket/data/{vertical}_supabase_write.json` — persistence status per vertical.
- `offmarket/data/autorepair_deep_dive.json` + `signage_deep_dive.json` + `surveying_deep_dive.json` — A-tier deep-dive verification evidence.
- `offmarket/data/surveying_raw/` — TBPELS Firms + RPLS Roster CSVs (S3 unlock — major infrastructure win for future runs).
- `offmarket/data/treecare_persist_payloads.json` — intermediate persistence payloads.

### SQL re-load chunks (Supabase upsert SQL for reproducible re-runs)

- `offmarket/data/sql/{10,20,30,40}_{vertical}_{businesses,signals,scores,finalize}.sql` and many chunked variants (`*_chunk_*.sql`, `*_compact_*.sql`, `*_mini_*.sql`) — these are the Supabase load chunks emitted by per-vertical persistence helpers; idempotent on `(vertical, legal_name, city, state)` upsert key. Per-vertical sub-directories (`sql/batches/`, `sql/multi/`, `sql/score_batches/`, `sql/score_compact/`, `sql/score_v2/`, `sql/treecare/`, `sql_compact/`, `sql_mcp/`, `sql_mcp_v2/`, `sql_mcp_v3/`, `sql_minimal/`, `sql_surveying/`) hold per-agent batched variants used during partial-write recovery.
- `offmarket/data/sql/score_v3.sql` — consolidated re-runnable score load.
- `offmarket/data/locksmith_*.sql` — per-file locksmith upsert variants emitted before SQL was relocated to `data/sql/`.

### Reusable scoring + persistence scripts (Python)

- `offmarket/score_autorepair.py` — auto repair scorer (NAICS 811111).
- `offmarket/score_roofing.py` — roofing scorer (NAICS 238160).
- `offmarket/score_surveying.py` — land surveying scorer (NAICS 541370).
- `offmarket/build_plumbing_targets.py` — plumbing target builder (NAICS 238220).
- `offmarket/persist_autorepair.py`, `persist_plumbing.py`, `persist_roofing.py`, `persist_via_mcp.py` — Supabase MCP persistence helpers per vertical.
- `offmarket/gen_compact_sql.py`, `gen_csv_and_manifest.py`, `gen_load_sql_surveying.py`, `gen_plumbing_sql.py` — SQL chunk generators (chunk by token count to fit MCP batch limits).
- `offmarket/split_sql.py` — utility to split oversized SQL files.

## Confirmation

No files outside the intended scope were modified.

All 359 files live under `offmarket/` (the established research artifact directory
from prior commits 2fa9088 + 907c807 + f48cdf0) plus this one verification file.
No application code (`api/`, `src/`, `dashboard/`, `worker/`), no schema
migrations, no CI config, no environment files, no `.env` secrets, no node
configuration touched. The skill files at `/Users/gideonspencer/.claude/skills/offmarket-acquisition-scorer/verticals.md`
were updated by sub-agents but live outside this repo (user-private config dir).
