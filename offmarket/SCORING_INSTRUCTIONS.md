# Per-Vertical Scoring Subagent — Reusable Template

When all enrichment batches for a vertical are complete, the orchestrator spawns ONE scoring subagent for that vertical. Below is the template prompt.

## Inputs the orchestrator will fill in

- `{VERTICAL}` — e.g. "funeral_home", "independent_pharmacy", "cpa_accounting"
- `{ENRICH_FILES}` — list of paths to all enrichment batches for this vertical
- `{SCORE_RUN_ID}` — Supabase score_runs UUID (orchestrator created earlier)
- `{VERTICAL_CONFIG_REF}` — path to vertical-configs-2026-05-16.md section to reference

## The scoring template

````
You are a SCORING sub-agent for the off-market acquisition scorer. Score all enriched businesses for the {VERTICAL} vertical and write {VERTICAL}_targets.json + .csv.

## Input
Read all enrichment batch files:
{list of full paths to *_enrich_batch_*.json files}

Concatenate into single working list.

## Output
Write to:
- offmarket/data/{VERTICAL}_targets.json — full scored records
- offmarket/data/{VERTICAL}_targets.csv — flattened 32-column

## Scoring model (apply EXACTLY)

### Hard gates (apply BEFORE the weighted formula)
1. Cannot verify business is real / operating → DROP from output entirely.
2. is_distressed=true → final_tier=D_pass, final_score ≤ 25, fill distress_reasons.
3. years_in_business < 5 → final_score ≤ 35, max C_watch.
4. Confidence < medium AND would otherwise land in A → cap at B_forward.
5. Successor verification not done on candidate A/B → cap at C_watch.
6. A-tier deep-dive not completed → cap at B_forward.

### Layer 1 — Base Rate (owner natural-exit timing) — Weight 0.30
- Owner age band → score:
  - 68+ → 88-100
  - 63-67 → 75-90
  - 58-62 → 55-78
  - 53-57 → 35-58
  - <53 or only weak proxy → 10-35
- Tenure modifier: ≥25 yrs personally running → nudge +3-5. <10 yrs → nudge -5-8.
- Recent buyer (1-3 yrs) → almost always D_pass.

### Layer 2 — Sellability (real, healthy, SBA-financeable) — Weight 0.25
- Clean multi-provider 10+ yr recurring-revenue, SBA size → 80-95
- Clean solo 10+ yr → 65-82
- Clean 5-9 yr, multi-staff → 55-72
- <5 yrs → ≤35 (hard gate)
- Any disciplinary/lapsed license/forfeited → heavy penalty → usually D

### Layer 3 — Coasting Trigger — Weight 0.30
- 4+ strong coasting tells → 80-100
- 2-3 → 55-80
- Exactly 1 → 30-55
- None → 10-30
- Successor verification gate: A/B candidates with "sole listed provider" tell MUST have live-fetch URL evidence; otherwise cap confidence at low and tier at C.

### Layer 4 — Market Pull — Weight 0.15
- Hot vertical × top-3 TX metro × premium ZIP → 85-95
- Hot vertical × major TX metro × ordinary → 75-85
- Hot vertical × secondary TX metro → 65-78
- Hot vertical × exurban / rural → 50-68
- Cold or saturated sub-vertical → 40-60
- Apply per-vertical sub-market nudges from vertical-configs-2026-05-16.md / vertical-configs-wave-2-2026-05-16.md / vertical-configs-wave-3-2026-05-16.md.

### Final score
final_score = round(0.30·L1 + 0.25·L2 + 0.30·L3 + 0.15·L4)

### Tiers
- A_acquire_self: final ≥78 AND L1 ≥70 AND L3 ≥65 AND not distressed AND confidence ≥medium AND deep-dive passed (for now, mark "deep_dive_pending: true" if final ≥78 — orchestrator handles deep-dive).
- B_forward: final 60-77 (or ≥78 but failing an A-gate / deep-dive)
- C_watch: final 45-59
- D_pass: final <45, OR distressed, OR <5 yrs

## Output per business (in {VERTICAL}_targets.json)

```json
{
  "legal_name": "...",
  "city": "...",
  "county": "...",
  "state": "TX",
  "zip": "...",
  "vertical": "{VERTICAL}",
  "naics_code": "...",
  "license_number": "...",
  "license_holder_name": "...",
  "license_issue_date": "...",
  "owner_name": "...",
  "owner_age_estimate": null,
  "owner_age_source": null,
  "owner_tenure_years": null,
  "years_in_business": null,
  "employee_count_estimate": null,
  "entity_status": "Active",
  "is_distressed": false,
  "distress_reasons": [],
  "data_sources": [...],
  "score_run_id": "{SCORE_RUN_ID}",
  "layer1_base_rate": 75,
  "layer1_comment": "...",
  "layer2_sellability": 70,
  "layer2_comment": "...",
  "layer3_behavioral_trigger": 65,
  "layer3_comment": "...",
  "layer4_market_pull": 80,
  "layer4_comment": "...",
  "final_score": 73,
  "final_tier": "B_forward",
  "final_comment": "...",
  "value_add_thesis": "...",
  "confidence": "medium",
  "data_completeness": 0.78,
  "deep_dive_pending": false
}
````

## Comments format

- layer1_comment: 1-2 sentences citing source + URL where possible.
- layer2_comment: 1-2 sentences with recurring revenue + size estimate.
- layer3_comment: list specific tells + sources.
- layer4_comment: name platforms + financeability + sub-market nudge.
- final_comment: 3-6 sentences synthesizing.
- value_add_thesis: 1-3 sentences (AI/ops levers + EBITDA-uplift).

## Token budget

~150K. Read all enrichment batches, apply scoring, write {VERTICAL}\_targets.json + .csv. Persist incrementally.

Return one-sentence summary: tier counts, top 3 A/B candidates.

```

```
