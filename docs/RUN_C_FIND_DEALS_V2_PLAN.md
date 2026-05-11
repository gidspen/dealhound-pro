# Run C — find-deals v2 Phase 3 Plan (Telemetry + Loop Closure)

## Goal

Close the discovery → scrape → score → registry-update loop. Surface the rank-vs-yield analysis Gideon asked for. After Run C, every full pipeline run leaves measurable evidence in `discovered-sites.json` of which sources produced match-or-better deals, and a single Python script renders the rank histogram on demand.

## Scope (spec §6 Phase 3)

- **3.1** Wire `apply-buybox.md` Step 3 (or thereabouts) to update `discovered-sites.json` `performance_metadata` per source after scoring completes.
- **3.2** Build `scripts/find-deals-source-yield.py` (read-only analysis, stdlib only).
- **3.3** Test gate E: full `/find-deals full` end-to-end. Acceptance: scored deals in Supabase, perf metadata updated, yield script prints non-empty histogram.

## Where the wiring goes

`apply-buybox.md` already has clear "after scoring" landing zones:

- **Step 5** (Update Scored Deals in Supabase) — runs the per-deal Supabase PATCH loop. The aggregate-by-source telemetry update should run **after** Step 5 completes (so we know which deals scored MATCH or better) and **before** Step 6 (Save Local Results File). Insert as a new **Step 5c: Update Source Performance Metadata**.

Why there:
- All deals are already classified (`passed_hard_filters`, `score`, `score_breakdown.strategy.overall`).
- The full deduped listing array (`all_listings`) is in scope, with `source` field populated from Step 1.
- Local results file write (Step 6) doesn't depend on registry, so registry update can come either before or after; placing it before keeps the registry consistent before any error in file write could leak.

## Data flow

```
all_listings (with source field)        scored_deals (with score + tier)
        │                                       │
        └────────────┬──────────────────────────┘
                     ▼
        Group by source → counts per source:
          - listings_returned_total (total raw listings from this source)
          - deals_scored_match_or_better (overall MATCH or STRONG MATCH)
          - deals_scored_strong_or_hot (overall STRONG MATCH only — closest to "HOT")
        ▼
        Read discovered-sites.json
        ▼
        For each source domain:
          - Find row in `sites` by URL host match (registry uses `url` field; listings use `source` which maps to a slug — handle both)
          - If row missing: skip (Bucket B individual listing source — not in registry)
          - If `performance_metadata` block missing: initialize with zeros (backward-compat for pre-v2 rows)
          - Update:
              scrapes += 1
              last_scrape_at = now (UTC ISO)
              last_scrape_status = "complete" if listings > 0 else "empty"
              listings_returned_total += <count>
              deals_scored_match_or_better += <count>
              deals_scored_strong_or_hot += <count>
              consecutive_empty_scrapes = 0 if listings > 0 else +=1
        ▼
        Write discovered-sites.json atomically (.tmp → mv)
```

### Source-key matching

Listings in `raw-listings-*.json` have a `source` field set by the scraper. Examples observed: "naiohb", "campground-marketplace", "bbteam", "landsearch". These are slugs — not URLs.

Registry rows in `discovered-sites.json` have `name`, `url`, and (after v2) `discovery_metadata`. There's no slug field. Matching strategy:

1. Build slug from registry row by lowercasing+normalizing the URL host (strip `www.`, strip `.com`, strip non-alphanum).
2. Compare to listing `source` after the same normalization.
3. If still ambiguous, also try matching by name token overlap.
4. If no match: log "source [X] not found in registry" and continue. Don't fail the run.

Backward-compat note: the **current** `discovered-sites.json` on `main` has zero rows with `performance_metadata`. The wiring must initialize the block from defaults (per spec §5.2 schema) on first encounter.

## Yield script algorithm

`scripts/find-deals-source-yield.py` — pure stdlib. Read-only.

```
Load discovered-sites.json
For each site row:
  rank = site.discovery_metadata.rank_in_results (skip if missing)
  pm = site.performance_metadata or zeros
  scrapes = max(pm.scrapes, 0)
  if scrapes == 0: skip from yield avg (no signal yet) — but count in "discovered" total
  yield_rate = pm.deals_scored_match_or_better / scrapes
  hot_rate = pm.deals_scored_strong_or_hot / scrapes

Bucket by rank: 1-10, 11-25, 26-50, 51+
For each bucket:
  N sources with scrapes>0
  total_scrapes
  avg yield_rate (across sources, simple mean)
  avg hot_rate

Top 10 sources by hot_rate (then by yield_rate, then by name):
  Print: rank, scrapes, hot_rate, yield_rate, name
```

### Output format

```
=== SOURCE YIELD BY DISCOVERY RANK ===

Rank 1-10   ([N] sources, [X] total scrapes): avg yield Y.Y%, avg hot Z.Z%
Rank 11-25  ([N] sources, [X] total scrapes): avg yield Y.Y%, avg hot Z.Z%
Rank 26-50  ([N] sources, [X] total scrapes): avg yield Y.Y%, avg hot Z.Z%
Rank 51+    ([N] sources, [X] total scrapes): avg yield Y.Y%, avg hot Z.Z%

=== TOP 10 SOURCES BY HOT RATE ===
1. [name] (rank #X, Y scrapes, Z.Z% hot rate, W.W% match-or-better)
...
```

If a bucket is empty: print "(no scraped sources yet)" rather than crashing.
If no rows have `discovery_metadata` (old-schema-only registry): print explicit "no v2-discovered sources yet — run /find-deals discover after the v2 PRs land".

No external deps. Single file, stdlib only (`json`, `sys`, `pathlib`, `statistics`, `urllib.parse` for host normalization if needed in the registry-update path).

## Files to change

| File | Change | Estimated size |
|------|--------|---------------|
| `~/skills/find-deals/apply-buybox.md` | Insert Step 5c (Update Source Performance Metadata) | +60–80 lines |
| `~/skills/find-deals/scripts/find-deals-source-yield.py` | New — yield histogram | +120 lines |

## Test plan

### Test gate E (end-to-end)

1. Snapshot current `discovered-sites.json` to `/tmp/discovered-sites-before-run-c.json`.
2. Run `/find-deals full` from a fresh shell via subscription (`claude -p`).
3. Wait for completion (60+ minutes is realistic).
4. Validate:
   - At least 5 sources show `scrapes > before-snapshot` value
   - `last_scrape_at` is recent (today)
   - Supabase `deals` table has new rows (count delta > 0 in last 2 hours)
   - `python3 scripts/find-deals-source-yield.py` prints non-empty histogram

### Scaled-down fallback

If full run takes >2 hours OR fails: run `/find-deals scrape` against top 5 sites only via worker, then `/find-deals score`. Step 5c still fires, telemetry still updates, yield script still has data. Document the shortcut in PR body.

## Risks

1. **Source-to-slug mapping is fuzzy.** Registry uses `url`, listings use `source` slug. Mismatch = silently no-op telemetry update. **Mitigation:** print "matched/unmatched" counts at end of Step 5c. If unmatched > 50%, surface a warning.

2. **Backward-compat shim must trigger.** Current registry has zero `performance_metadata` blocks. Telemetry code must initialize on first touch, not assume. **Mitigation:** explicit defaults dict in code. Test gate E will fail loudly if this is wrong.

3. **Atomic write matters.** A crash mid-write would corrupt the registry. **Mitigation:** write to `.tmp` then `os.replace()` — atomic on POSIX.

4. **`/find-deals full` is a 60+-minute test.** Easy to lose patience. **Mitigation:** scaled-down fallback + clear progress monitoring via background log tail.

5. **Concurrent registry writes.** If multiple `/find-deals` runs happen at once, the registry update could race. **Mitigation:** Step 5c reads registry → updates in-memory → writes atomically. Last-writer-wins is acceptable for v2 — this is single-tenant. Note for future multi-tenant.

## Sub-agent plan

- **Sub-agent 1 (Sonnet):** Author Step 5c addition to `apply-buybox.md`. Single-shot. Spec is precise enough.
- **Sub-agent 2 (Sonnet):** Write `scripts/find-deals-source-yield.py`. Single-shot.
- Direct (Opus): orchestration, branch ops, test gate E, PR open, evidence saves.

Total expected sub-agent spawns: 2.

## Stack pattern

Branch off `feat/find-deals-v2-extractor` (Run B). PR base = Run B's branch. Merge order: Run A PR #1 → main, Run B PR #2 → main, Run C PR #3 → main.
