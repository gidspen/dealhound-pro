#!/usr/bin/env python3
"""Produce compact SQL inserts for surveying_targets.json for Supabase MCP upload.
Splits into 3 chunks: businesses_compact.sql, signals_compact.sql, scores_compact.sql.
Skips raw_enrichment (too verbose) and data_sources (keep only minimal)."""
import json, uuid, os

ROOT = os.path.dirname(os.path.abspath(__file__))
DATA = json.load(open(os.path.join(ROOT, "..", "surveying_targets.json")))
RUN_ID = DATA["run"]["score_run_id"]
NS = uuid.UUID("6f1d2c00-0000-4000-8000-000000000001")
SKIP = set()  # set of license_numbers already inserted

# IDs of the 5 A-tier already inserted
ALREADY = {"10014800","10034800","10057100","10133000","10057300"}

def bid(b):
    key = f"{b.get('vertical','land_surveying')}|{b['legal_name']}|{b.get('city','')}|{b.get('state','TX')}"
    return str(uuid.uuid5(NS, "business:" + key))

def esc(v):
    if v is None: return "NULL"
    if isinstance(v, bool): return "true" if v else "false"
    if isinstance(v, (int, float)): return str(v)
    if isinstance(v, (dict, list)):
        return "'" + json.dumps(v).replace("'", "''") + "'::jsonb"
    return "'" + str(v).replace("'", "''") + "'"

# Compact business rows: drop raw_enrichment + verbose data_sources, keep critical fields
BCOLS = ["vertical","legal_name","dba_name","naics_code","address","city","county","state","zip","phone","website",
         "license_number","license_type","license_status","license_issue_date","license_holder_name",
         "entity_sos_file_number","entity_formation_date","entity_status","registered_agent",
         "years_in_business","employee_count_estimate","provider_count_estimate","employee_count_source",
         "owner_name","owner_age_estimate","owner_age_source","owner_tenure_years","owner_homestead_address","owner_property_deed_date",
         "is_distressed","distress_reasons"]

def compact_data_sources(b):
    # Reduce to essential sources only (first 3)
    return b.get('data_sources', [])[:3]

def compact_raw_enrichment(b):
    # Drop full enrichment, keep spine + score metadata
    re_obj = b.get('raw_enrichment', {})
    return {
        "vertical": "land_surveying",
        "spine_priority": re_obj.get("spine_priority"),
        "geo_bucket": re_obj.get("geo_bucket"),
        "n_active_rpls": re_obj.get("n_active_rpls"),
        "principals_names": [p.get("name") for p in re_obj.get("principals", [])],
    }

print("-- COMPACT BUSINESSES UPSERT (drops raw_enrichment, keeps top 3 data_sources)")
rows = []
for b in DATA["businesses"]:
    if b["license_number"] in ALREADY:
        continue
    i = bid(b)
    vals = ", ".join(esc(b.get(c)) for c in BCOLS)
    vals += f", {esc(compact_data_sources(b))}"
    vals += f", {esc(compact_raw_enrichment(b))}"
    vals += f", NULL"
    rows.append(f"({esc(i)}, {vals})")

# Split into 4 batches
batch_size = 25
for i in range(0, len(rows), batch_size):
    batch = rows[i:i+batch_size]
    fn = f"compact_businesses_{i//batch_size+1:02d}.sql"
    with open(os.path.join(ROOT, fn), "w") as f:
        f.write(f"insert into offmarket.businesses (id, {', '.join(BCOLS)}, data_sources, raw_enrichment, notes) values\n")
        f.write(",\n".join(batch))
        f.write("\non conflict (vertical, legal_name, city, state) do nothing;\n")
    print(f"  Wrote {fn} ({len(batch)} rows, {os.path.getsize(os.path.join(ROOT, fn))} bytes)")

# Scores: write full scores, link by uuid5 derived business_id
SCOLS = ["layer1_base_rate","layer1_comment","layer2_sellability","layer2_comment",
         "layer3_behavioral_trigger","layer3_comment","layer4_market_pull","layer4_comment",
         "final_score","final_tier","final_comment","value_add_thesis","confidence","data_completeness"]

score_rows = []
for b in DATA["businesses"]:
    sc = b['score']
    i = bid(b)
    vals = [esc(i), esc(RUN_ID)] + [esc(sc.get(c)) for c in SCOLS]
    score_rows.append("(" + ", ".join(vals) + ")")

for i in range(0, len(score_rows), batch_size):
    batch = score_rows[i:i+batch_size]
    fn = f"compact_scores_{i//batch_size+1:02d}.sql"
    with open(os.path.join(ROOT, fn), "w") as f:
        setc = ", ".join(f"{c} = excluded.{c}" for c in SCOLS)
        f.write(f"insert into offmarket.business_scores (business_id, score_run_id, {', '.join(SCOLS)}) values\n")
        f.write(",\n".join(batch))
        f.write(f"\non conflict (business_id, score_run_id) do update set {setc};\n")
    print(f"  Wrote {fn} ({len(batch)} rows, {os.path.getsize(os.path.join(ROOT, fn))} bytes)")

# Signals: keep all 3-10 per business
sig_rows = []
for b in DATA["businesses"]:
    i = bid(b)
    for s in b.get("signals", []):
        vals = [esc(i), esc(s.get("layer")), esc(s.get("signal_key")), esc(s.get("direction")),
                esc(s.get("weight")), esc(s.get("evidence")[:1500] if s.get("evidence") else None),
                esc(s.get("source")), esc(s.get("source_url")), esc(s.get("observed_at"))]
        sig_rows.append("(" + ", ".join(vals) + ")")

# Wipe + insert
clear_sql_path = os.path.join(ROOT, "compact_signals_00_clear.sql")
ids = ", ".join(esc(bid(b)) for b in DATA["businesses"])
with open(clear_sql_path, "w") as f:
    f.write(f"delete from offmarket.business_signals where business_id in ({ids});\n")
print(f"  Wrote compact_signals_00_clear.sql ({os.path.getsize(clear_sql_path)} bytes)")

sig_batch_size = 35
for i in range(0, len(sig_rows), sig_batch_size):
    batch = sig_rows[i:i+sig_batch_size]
    fn = f"compact_signals_{i//sig_batch_size+1:02d}.sql"
    with open(os.path.join(ROOT, fn), "w") as f:
        f.write("insert into offmarket.business_signals (business_id, layer, signal_key, direction, weight, evidence, source, source_url, observed_at) values\n")
        f.write(",\n".join(batch))
        f.write(";\n")
    print(f"  Wrote {fn} ({len(batch)} rows, {os.path.getsize(os.path.join(ROOT, fn))} bytes)")

# Finalize
with open(os.path.join(ROOT, "compact_finalize.sql"), "w") as f:
    f.write(f"update offmarket.score_runs set business_count = (select count(*) from offmarket.business_scores where score_run_id = {esc(RUN_ID)}) where id = {esc(RUN_ID)};\n")

print(f"\nTotal score_rows: {len(score_rows)}, signal rows: {len(sig_rows)}")
