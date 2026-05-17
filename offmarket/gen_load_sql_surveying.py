#!/usr/bin/env python3
"""Generate SQL to load offmarket/data/dental_targets.json into Supabase schema `offmarket`.
Emits chunked .sql files under offmarket/data/sql/ so each fits comfortably in a single
execute_sql call. Deterministic UUIDs (uuid5) so re-running is idempotent-ish via upsert."""
import json, uuid, os, re

ROOT = os.path.dirname(os.path.abspath(__file__))
DATA = json.load(open(os.path.join(ROOT, "data", "surveying_targets.json")))
OUT = os.path.join(ROOT, "data", "sql_surveying")
os.makedirs(OUT, exist_ok=True)

NS = uuid.UUID("6f1d2c00-0000-4000-8000-000000000001")  # fixed namespace for this dataset
run = DATA["run"]
# Use the Supabase-assigned UUID directly from Phase 1 score_runs insert.
RUN_ID = run.get("score_run_id") or str(uuid.uuid5(NS, "score_run:" + run["run_label"]))

def q(v):
    if v is None: return "NULL"
    if isinstance(v, bool): return "true" if v else "false"
    if isinstance(v, (int, float)): return str(v)
    if isinstance(v, (dict, list)):
        return "'" + json.dumps(v).replace("'", "''") + "'::jsonb"
    return "'" + str(v).replace("'", "''") + "'"

def bid(b):
    key = f"{b.get('vertical','land_surveying')}|{b['legal_name']}|{b.get('city','')}|{b.get('state','TX')}"
    return str(uuid.uuid5(NS, "business:" + key))

# ---- score_runs ----
with open(os.path.join(OUT, "00_run.sql"), "w") as f:
    f.write(
        "insert into offmarket.score_runs (id, run_label, model_version, weights, vertical, geography, business_count, notes) values ("
        f"{q(RUN_ID)}, {q(run['run_label'])}, {q(run['model_version'])}, {q(run['weights'])}, "
        f"{q(run.get('vertical','dental'))}, {q(run.get('geography'))}, {DATA['business_count']}, "
        f"{q('tier_thresholds=' + json.dumps(run.get('tier_thresholds',{})) + '; gates=' + json.dumps(run.get('gates',[])) + '; scored_at=' + str(run.get('scored_at')))}"
        ") on conflict (id) do update set business_count = excluded.business_count, notes = excluded.notes;\n"
    )

BCOLS = ["vertical","legal_name","dba_name","naics_code","address","city","county","state","zip","phone","website",
         "license_number","license_type","license_status","license_issue_date","license_holder_name",
         "entity_sos_file_number","entity_formation_date","entity_status","registered_agent","years_in_business",
         "employee_count_estimate","provider_count_estimate","employee_count_source","owner_name","owner_age_estimate",
         "owner_age_source","owner_tenure_years","owner_homestead_address","owner_property_deed_date",
         "is_distressed","distress_reasons","data_sources","raw_enrichment","notes"]
SCOLS = ["layer1_base_rate","layer1_comment","layer2_sellability","layer2_comment","layer3_behavioral_trigger",
         "layer3_comment","layer4_market_pull","layer4_comment","final_score","final_tier","final_comment",
         "value_add_thesis","confidence","data_completeness"]

biz_rows, sig_rows, score_rows = [], [], []
for b in DATA["businesses"]:
    i = bid(b)
    vals = ", ".join(q(b.get(c)) for c in BCOLS)
    biz_rows.append(f"({q(i)}, {vals})")
    for s in b.get("signals", []):
        sig_rows.append("(" + ", ".join([
            q(i), q(s.get("layer")), q(s.get("signal_key")), q(s.get("direction")), q(s.get("weight")),
            q(s.get("evidence")), q(s.get("source")), q(s.get("source_url")), q(s.get("observed_at"))
        ]) + ")")
    sc = b.get("score", {})
    score_rows.append("(" + ", ".join([q(i), q(RUN_ID)] + [q(sc.get(c)) for c in SCOLS]) + ")")

def chunk(rows, n):
    for k in range(0, len(rows), n): yield rows[k:k+n]

# businesses (10/file)
for idx, ch in enumerate(chunk(biz_rows, 10), 1):
    with open(os.path.join(OUT, f"10_businesses_{idx:02d}.sql"), "w") as f:
        f.write(f"insert into offmarket.businesses (id, {', '.join(BCOLS)}) values\n" + ",\n".join(ch) +
                "\non conflict (vertical, legal_name, city, state) do nothing;\n")

# signals: wipe-and-reinsert for this dataset's businesses, then insert (50/file)
with open(os.path.join(OUT, "20_signals_00_clear.sql"), "w") as f:
    ids = ", ".join(q(bid(b)) for b in DATA["businesses"])
    f.write(f"delete from offmarket.business_signals where business_id in ({ids});\n")
for idx, ch in enumerate(chunk(sig_rows, 50), 1):
    with open(os.path.join(OUT, f"20_signals_{idx:02d}.sql"), "w") as f:
        f.write("insert into offmarket.business_signals (business_id, layer, signal_key, direction, weight, evidence, source, source_url, observed_at) values\n"
                + ",\n".join(ch) + ";\n")

# scores (20/file) with upsert on (business_id, score_run_id)
for idx, ch in enumerate(chunk(score_rows, 8), 1):
    with open(os.path.join(OUT, f"30_scores_{idx:02d}.sql"), "w") as f:
        setc = ", ".join(f"{c} = excluded.{c}" for c in SCOLS)
        f.write(f"insert into offmarket.business_scores (business_id, score_run_id, {', '.join(SCOLS)}) values\n"
                + ",\n".join(ch) + f"\non conflict (business_id, score_run_id) do update set {setc};\n")

# update count
with open(os.path.join(OUT, "40_finalize.sql"), "w") as f:
    f.write(f"update offmarket.score_runs set business_count = (select count(*) from offmarket.business_scores where score_run_id = {q(RUN_ID)}) where id = {q(RUN_ID)};\n")

files = sorted(os.listdir(OUT))
print(f"RUN_ID={RUN_ID}")
print(f"{len(DATA['businesses'])} businesses, {len(sig_rows)} signals, {len(score_rows)} scores")
for fn in files:
    print(fn, os.path.getsize(os.path.join(OUT, fn)))
