#!/usr/bin/env python3
"""
Run C Test Gate E — scaled-down end-to-end simulation.

Inputs:
- Run A's v2 hospitality registry (29 rows with discovery_metadata)
- Real raw-listings-*.json files (4 files, ~50 raw listings)
- Synthesized score_breakdown for each listing (deterministic mock based on price+location heuristics)

Pipeline:
1. Load all raw-listings
2. Attach mock score_breakdown to each (about 1/3 MATCH, 1/6 STRONG MATCH, rest PARTIAL/MISS)
3. Run the actual Step 5c block (copied from apply-buybox.md byte-for-byte)
4. Save the resulting registry to verification/run-c-end-to-end-discovered-sites.json
5. Run the actual yield script and capture stdout to verification/run-c-yield-histogram.txt
"""
import os, json, re, sys, hashlib, glob, subprocess, shutil
from datetime import datetime, timezone

WORK = "/tmp/run-c-gate-e-work"
os.makedirs(WORK, exist_ok=True)

# 1. Seed registry from Run A's v2 output
SRC_REG = "/Users/gideonspencer/dealhound-pro/.claude/worktrees/sad-visvesvaraya-35b506/verification/run-a-hospitality-discovered-sites.json"
SCRATCH_REG = f"{WORK}/discovered-sites.json"
shutil.copy(SRC_REG, SCRATCH_REG)
print(f"[gate-e] seeded registry: {SCRATCH_REG}")

# 2. Load real raw listings
raw_files = sorted(glob.glob("/Users/gideonspencer/skills/find-deals/raw-listings-*.json"))
all_listings = []
for rf in raw_files:
    with open(rf) as f:
        data = json.load(f)
    listings = data.get("listings", []) or data.get("deals", []) or (data if isinstance(data, list) else [])
    src_slug = os.path.basename(rf).replace("raw-listings-", "").replace(".json", "")
    for L in listings:
        L.setdefault("source", src_slug)
        all_listings.append(L)
print(f"[gate-e] loaded {len(all_listings)} listings across {len(raw_files)} sources")

# 3. Synthesize mock scores — deterministic
def mock_score(listing):
    h = int(hashlib.md5((listing.get("url","") or listing.get("title","")).encode()).hexdigest()[:8], 16)
    bucket = h % 6
    if bucket == 0: overall = "STRONG MATCH"
    elif bucket == 1: overall = "MATCH"
    elif bucket == 2: overall = "MATCH"
    elif bucket == 3: overall = "PARTIAL"
    else: overall = "MISS"
    return {"strategy": {"overall": overall, "market_match": overall, "revenue_match": overall, "property_fit": overall}}

scored = 0
for L in all_listings:
    L["score_breakdown"] = mock_score(L)
    scored += 1
hot = sum(1 for L in all_listings if L["score_breakdown"]["strategy"]["overall"] == "STRONG MATCH")
match = sum(1 for L in all_listings if L["score_breakdown"]["strategy"]["overall"] in ("MATCH","STRONG MATCH"))
print(f"[gate-e] mock-scored: {scored} total, {match} match-or-better, {hot} strong-or-hot")

# 4. RUN STEP 5c — copied byte-for-byte from apply-buybox.md
# (just re-pointed to scratch registry)
try:
    source_stats = {}
    for listing in all_listings:
        src = listing.get("source") or ""
        if src not in source_stats:
            source_stats[src] = {"listings_count": 0, "match_count": 0, "hot_count": 0}
        source_stats[src]["listings_count"] += 1
        sb = listing.get("score_breakdown") or {}
        overall = (sb.get("strategy") or {}).get("overall") or ""
        if overall in ("MATCH", "STRONG MATCH"):
            source_stats[src]["match_count"] += 1
        if overall == "STRONG MATCH":
            source_stats[src]["hot_count"] += 1

    registry_path = SCRATCH_REG
    tmp_path = registry_path + ".tmp"
    with open(registry_path, "r") as f:
        data = json.load(f)

    def _slug(raw_url):
        s = re.sub(r"https?://", "", raw_url or "").lower()
        s = re.sub(r"^www\.", "", s)
        s = s.rstrip("/")
        s = s.split(".")[0]
        s = re.sub(r"[^a-z0-9]", "", s)
        return s

    registry_slugs = {}
    for idx, site in enumerate(data.get("sites", [])):
        slug = _slug(site.get("url", ""))
        if slug:
            registry_slugs[slug] = idx

    def _find_registry_idx(src_slug):
        if not src_slug: return None
        if src_slug in registry_slugs: return registry_slugs[src_slug]
        if len(src_slug) < 5: return None
        candidates = [(rslug, idx) for rslug, idx in registry_slugs.items()
                      if len(rslug) >= 5 and (src_slug in rslug or rslug in src_slug)]
        if len(candidates) == 1: return candidates[0][1]
        return None

    default_perf = {"scrapes": 0, "listings_returned_total": 0, "deals_scored_match_or_better": 0,
                    "deals_scored_strong_or_hot": 0, "last_scrape_at": None, "last_scrape_status": None,
                    "consecutive_empty_scrapes": 0}
    matched=0; unmatched=0; total_scrapes=0; total_match_or_better=0; total_strong_or_hot=0
    for src, stats in source_stats.items():
        src_slug = _slug(src)
        idx = _find_registry_idx(src_slug)
        if idx is None:
            print(f"[telemetry] source slug '{src_slug}' not in registry — skipping")
            unmatched += 1
            continue
        row = data["sites"][idx]
        if not row.get("performance_metadata"):
            row["performance_metadata"] = dict(default_perf)
        pm = row["performance_metadata"]
        lc = stats["listings_count"]; mc = stats["match_count"]; hc = stats["hot_count"]
        pm["scrapes"] += 1
        pm["last_scrape_at"] = datetime.now(timezone.utc).isoformat()
        pm["last_scrape_status"] = "complete" if lc > 0 else "empty"
        pm["listings_returned_total"] += lc
        pm["deals_scored_match_or_better"] += mc
        pm["deals_scored_strong_or_hot"] += hc
        pm["consecutive_empty_scrapes"] = 0 if lc > 0 else pm["consecutive_empty_scrapes"] + 1
        matched += 1; total_scrapes += pm["scrapes"]; total_match_or_better += mc; total_strong_or_hot += hc

    with open(tmp_path, "w") as f: json.dump(data, f, indent=2)
    os.replace(tmp_path, registry_path)
    n = matched + unmatched
    print(f"[telemetry] updated {n} sources ({matched} matched, {unmatched} unmatched). Total: {total_scrapes} scrapes, {total_match_or_better} match-or-better, {total_strong_or_hot} strong-or-hot.")
except Exception as e:
    print(f"[telemetry] failed: {e}")

# 5. Save final registry as evidence
EVIDENCE_DIR = "/Users/gideonspencer/dealhound-pro/.claude/worktrees/sad-visvesvaraya-35b506/verification"
shutil.copy(SCRATCH_REG, f"{EVIDENCE_DIR}/run-c-end-to-end-discovered-sites.json")
print(f"[gate-e] saved evidence: {EVIDENCE_DIR}/run-c-end-to-end-discovered-sites.json")

# 6. Run yield script against the result
result = subprocess.run(
    ["python3", "/Users/gideonspencer/skills/find-deals/scripts/find-deals-source-yield.py", SCRATCH_REG],
    capture_output=True, text=True
)
print(f"\n[gate-e] yield script exit code: {result.returncode}")
print(f"[gate-e] yield script stdout:\n{result.stdout}")
if result.stderr: print(f"[gate-e] yield script stderr:\n{result.stderr}")

with open(f"{EVIDENCE_DIR}/run-c-yield-histogram.txt", "w") as f:
    f.write(result.stdout)
print(f"[gate-e] saved evidence: {EVIDENCE_DIR}/run-c-yield-histogram.txt")

# 7. Validate the gate
print("\n=== TEST GATE E VALIDATION ===")
with open(f"{EVIDENCE_DIR}/run-c-end-to-end-discovered-sites.json") as f:
    final = json.load(f)
updated_count = sum(1 for s in final["sites"]
                    if s.get("performance_metadata", {}).get("scrapes", 0) > 0)
print(f"Sources with scrapes > 0: {updated_count}")
assert updated_count >= 1, "FAIL: no sources got telemetry update"
assert "===" in result.stdout, "FAIL: yield histogram empty"
assert "(no v2-discovered" not in result.stdout, "FAIL: yield said no v2 sources"
print("PASS: telemetry updates persisted; yield histogram non-empty; non-v2-empty branch.")
