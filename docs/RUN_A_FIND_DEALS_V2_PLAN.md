# Run A — find-deals v2 Phase 1 (Deep Discovery) Plan

**Branch (skill repo):** `feat/find-deals-v2-discovery` off `main` at gidspen/find-deals-skill
**Worktree branch (dealhound-pro):** `claude/sad-visvesvaraya-35b506`
**Spec:** `docs/superpowers/specs/2026-05-09-find-deals-v2-discovery-and-extraction.md` §5.2
**Date:** 2026-05-09

## Goal

Ship Phase 1 of v2 spec: `/find-deals discover` produces ≥50 verified Bucket A sources for hospitality buy box, ≥30 for industrial, with rank-position metadata on every row.

## File-by-file change list (skill repo)

| File                               | Change                                                                                                                                                      | Why                                     |
| ---------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------- |
| `discover-sites.md` Step 2         | Replace 5 hardcoded query patterns with a 40–80 query matrix generator: `(type_token × geo_token × marketplace_pattern)`                                    | Spec §5.2 step 2 — fan out 8×           |
| `discover-sites.md` Step 3         | Capture per-URL `found_via_query`, `rank_in_results`, `search_engine`                                                                                       | Spec D4 — rank-position telemetry       |
| `discover-sites.md` Step 4         | Verification cap → top 60 candidate domains                                                                                                                 | Spec §5.2 step 5 — overshoot to land 50 |
| `discover-sites.md` Step 6         | Document new `discovery_metadata` + `performance_metadata` blocks on each site row; backward-compat note that readers default missing fields to zeros/nulls | Spec §5.2 step 6                        |
| `discover-sites.md` Step 7         | Print rank-vs-signal histogram (rank 1–10, 11–25, 26–50, 51+)                                                                                               | Spec §5.2 step 7                        |
| `buy-box-industrial-test.md` (new) | Industrial buy box for Test Gate I                                                                                                                          | Per spec R3 + run prompt §Phase 4       |

## Query matrix design

**Property type tokens** (extract from buy box `ALLOWED_PROPERTY_TYPES` + strategy descriptions, dedupe):

- Hospitality buy box → ["micro resort", "RV park", "RV resort", "campground", "glamping resort", "cabin resort", "waterfront resort", "boutique hotel"]
- Industrial buy box → ["warehouse", "light manufacturing", "flex space", "distribution center", "last-mile logistics", "self-storage facility"]

**Geography tokens** (extract from `STATES`):

- Hospitality → ["East Texas", "North Carolina", "Tennessee", "South Carolina"]
- Industrial → ["Texas", "Ohio", "Tennessee", "Pennsylvania"]
- Always include one wildcard token: "" (empty geo) so queries fan into national broker sites too

**Marketplace patterns** (8 templates):

1. `"[type]" for sale [geo] broker`
2. `"[type]" listings [geo] marketplace`
3. `best site to buy [type] [geo]`
4. `[type] for sale by owner [geo]`
5. `[type] auction [geo]`
6. `[type] specialist broker [geo]`
7. `niche [type] listings [geo]`
8. `boutique [type] for sale [geo]` (only when type contains: hotel, resort, lodge, inn, glamping)

**Generation algorithm:**

```
queries = []
for type_token in type_tokens:
  for geo_token in geo_tokens + [""]:
    for pattern in marketplace_patterns:
      if pattern == 'boutique [type]...' and type doesn't qualify: skip
      q = pattern.format(type=type_token, geo=geo_token).strip()
      queries.add(q)
queries = dedupe(queries)
# Cap: 40 minimum, 80 maximum. If >80, prioritize by template index 1-6 then trim.
```

**Hospitality estimate:** 8 types × 5 geos × 8 patterns = 320 raw → after dedupe + cap → ~64 queries.
**Industrial estimate:** 6 types × 5 geos × 7 patterns (no boutique) = 210 raw → after dedupe + cap → ~50 queries.

**Throttling:** Issue in batches of 5–10 concurrent. Add 1–2s jitter between batches to dodge rate limits.

## Industrial buy box construction

`/Users/gideonspencer/skills/find-deals/buy-box-industrial-test.md`:

- Allowed types: warehouse, light manufacturing facility, flex industrial space, distribution center, last-mile logistics warehouse, self-storage facility
- States: TX, OH, TN, PA
- Price band: $300k–$3M
- MIN_ACREAGE: 0.5 (industrial often smaller plots)
- STR_MARKET_REQUIRED: false (not applicable)
- Strategy: value-add operator buying underperforming industrial assets in tier-2/3 metros along major freight corridors

## Test execution plan

**Test Gate H (hospitality):**

1. `cd /tmp && rm -f raw-listings-*.json discovered-sites-*.json`
2. `zsh -c 'source ~/.zshrc && cd /tmp && claude -p "/find-deals discover" --max-turns 50 --dangerously-skip-permissions'`
3. Copy output to `verification/run-a-hospitality-discovered-sites.json`
4. Validate ≥50 verified Bucket A; iterate up to 3 attempts if short

**Test Gate I (industrial):**

1. `cp /Users/gideonspencer/skills/find-deals/buy-box.md /tmp/buy-box-backup.md`
2. `cp /Users/gideonspencer/skills/find-deals/buy-box-industrial-test.md /Users/gideonspencer/skills/find-deals/buy-box.md`
3. Repeat fresh-shell discover
4. Validate ≥30 verified Bucket A
5. **Always restore** buy-box.md from backup
6. Save to `verification/run-a-industrial-discovered-sites.json`

## Risks identified

| Risk                                                                     | Mitigation                                                                                                       |
| ------------------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------- |
| WebSearch rate-limits at 60+ queries/run                                 | Throttle to batches of 5–10 + jitter; instruction to skill to fall back to staggered runs if rate limit detected |
| `/find-deals discover` skill flow unbounded turns                        | `--max-turns 50` cap; skill internally throttles                                                                 |
| Industrial long tail thinner than hospitality                            | Acceptable per spec — 30-source bar (vs. 50). If <30 after 3 attempts, document gap and ship anyway              |
| WebSearch returns blog/SEO content drowning out broker sites             | Step 3 classifier already filters; spec doesn't require this hardening                                           |
| Backward compat: existing `discovered-sites.json` rows lack new metadata | Document the read-time default (zeros/nulls) in Step 6 of `discover-sites.md`                                    |

## Sub-agent spawn plan (estimate)

| Phase  | Sub-agents        | Purpose                                                                                                                           |
| ------ | ----------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| BUILD  | 1 (combined edit) | Refactor discover-sites.md Steps 2,3,4,6,7 in one Sonnet pass — small file, single coherent change, one diff is cleaner than five |
| BUILD  | 1                 | Create buy-box-industrial-test.md                                                                                                 |
| VERIFY | 0                 | Direct shell ops — must orchestrate fresh-shell `claude -p` invocation                                                            |
| SHIP   | 1                 | Open PR via `gh pr create` (small task, but Sonnet-friendly)                                                                      |

Total estimate: 3 sub-agent spawns vs. ~10 direct work items (file reads, git ops, test invocations, evidence collection).
