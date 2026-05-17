#!/usr/bin/env python3
"""Load the 5 new verticals from the 19-hr run into Supabase.
Run: python3 offmarket/load_five_verticals.py
Prints chunked SQL to stdout; redirect per-chunk to apply via MCP execute_sql."""
import json, uuid, os

ROOT = os.path.dirname(os.path.abspath(__file__))
DATA_DIR = os.path.join(ROOT, "data")
NS = uuid.UUID("6f1d2c00-0000-4000-8000-000000000001")

# score_run UUIDs from Supabase (already created in Phase 1 of the run)
SCORE_RUN_IDS = {
    "chiropractic":       "cced6783-5b94-4026-a389-1b07afae75a5",
    "paint_body_collision": "55e31636-bd81-4737-a5c0-6993b4155f8e",
    "carpet_cleaning":    "f94863b8-60e1-4b8f-a9a4-5707143a4a4f",
    "self_storage":       "b271f067-65af-470e-b691-04c479d5f163",
    "physical_therapy":   "a33b72c5-d692-4272-8e81-659939ffed05",
}

VERTICALS = {
    "chiropractic":       "chiropractic_targets.json",
    "paint_body_collision": "paint_body_collision_targets.json",
    "carpet_cleaning":    "carpet_cleaning_targets.json",
    "self_storage":       "self_storage_targets.json",
    "physical_therapy":   "physical_therapy_targets.json",
}

def q(v):
    if v is None: return "NULL"
    if isinstance(v, bool): return "true" if v else "false"
    if isinstance(v, (int, float)): return str(v)
    if isinstance(v, (dict, list)):
        return "'" + json.dumps(v).replace("'", "''") + "'::jsonb"
    return "'" + str(v).replace("'", "''") + "'"

def bid(vertical, legal_name, city, state="TX"):
    key = f"{vertical}|{legal_name}|{city}|{state}"
    return str(uuid.uuid5(NS, "business:" + key))

BCOLS = [
    "vertical","legal_name","dba_name","naics_code","address","city","county","state","zip",
    "phone","website","license_number","license_type","license_status","license_issue_date",
    "license_holder_name","entity_sos_file_number","entity_formation_date","entity_status",
    "registered_agent","years_in_business","employee_count_estimate","provider_count_estimate",
    "employee_count_source","owner_name","owner_age_estimate","owner_age_source",
    "owner_tenure_years","owner_homestead_address","owner_property_deed_date",
    "is_distressed","distress_reasons","data_sources","raw_enrichment","notes"
]
SCOLS = [
    "layer1_base_rate","layer1_comment","layer2_sellability","layer2_comment",
    "layer3_behavioral_trigger","layer3_comment","layer4_market_pull","layer4_comment",
    "final_score","final_tier","final_comment","value_add_thesis","confidence","data_completeness"
]

OUT = os.path.join(DATA_DIR, "sql_new")
os.makedirs(OUT, exist_ok=True)

all_biz_rows = []
all_sig_rows = []
all_score_rows = []
all_biz_ids = []
totals = {}

for vertical, filename in VERTICALS.items():
    path = os.path.join(DATA_DIR, filename)
    raw = json.load(open(path))
    # Handle both dict-with-businesses and bare list formats
    if isinstance(raw, list):
        businesses = raw
    else:
        businesses = raw.get("businesses", [])

    run_id = SCORE_RUN_IDS[vertical]
    count = 0

    for b in businesses:
        # Ensure vertical is set on the business
        b_vertical = b.get("vertical") or vertical
        legal_name = b.get("legal_name", "")
        city = b.get("city", "")
        state = b.get("state", "TX")
        business_id = bid(b_vertical, legal_name, city, state)
        all_biz_ids.append(business_id)

        # Business row
        b["vertical"] = b_vertical
        vals = ", ".join(q(b.get(c)) for c in BCOLS)
        all_biz_rows.append(f"({q(business_id)}, {vals})")

        # Signals
        for s in b.get("signals", []):
            all_sig_rows.append("(" + ", ".join([
                q(business_id), q(s.get("layer")), q(s.get("signal_key")),
                q(s.get("direction")), q(s.get("weight")), q(s.get("evidence")),
                q(s.get("source")), q(s.get("source_url")), q(s.get("observed_at"))
            ]) + ")")

        # Scores — flat on business object (not nested under "score")
        all_score_rows.append("(" + ", ".join(
            [q(business_id), q(run_id)] + [q(b.get(c)) for c in SCOLS]
        ) + ")")
        count += 1

    totals[vertical] = count
    print(f"  {vertical}: {count} businesses")

def chunk(rows, n):
    for k in range(0, len(rows), n): yield rows[k:k+n]

# businesses (upsert on conflict do nothing — idempotent)
biz_chunks = list(chunk(all_biz_rows, 10))
for idx, ch in enumerate(biz_chunks, 1):
    with open(os.path.join(OUT, f"10_businesses_{idx:02d}.sql"), "w") as f:
        f.write(f"insert into offmarket.businesses (id, {', '.join(BCOLS)}) values\n"
                + ",\n".join(ch)
                + "\non conflict (vertical, legal_name, city, state) do nothing;\n")

# signals: clear then insert
with open(os.path.join(OUT, "20_signals_00_clear.sql"), "w") as f:
    ids = ", ".join(q(i) for i in all_biz_ids)
    f.write(f"delete from offmarket.business_signals where business_id in ({ids});\n")
for idx, ch in enumerate(chunk(all_sig_rows, 50), 1):
    with open(os.path.join(OUT, f"20_signals_{idx:02d}.sql"), "w") as f:
        f.write("insert into offmarket.business_signals "
                "(business_id, layer, signal_key, direction, weight, evidence, source, source_url, observed_at) values\n"
                + ",\n".join(ch) + ";\n")

# scores (upsert)
for idx, ch in enumerate(chunk(all_score_rows, 10), 1):
    with open(os.path.join(OUT, f"30_scores_{idx:02d}.sql"), "w") as f:
        setc = ", ".join(f"{c} = excluded.{c}" for c in SCOLS)
        f.write(f"insert into offmarket.business_scores (business_id, score_run_id, {', '.join(SCOLS)}) values\n"
                + ",\n".join(ch)
                + f"\non conflict (business_id, score_run_id) do update set {setc};\n")

# finalize: update business_count on all 5 score_run rows
with open(os.path.join(OUT, "40_finalize.sql"), "w") as f:
    for vertical, run_id in SCORE_RUN_IDS.items():
        f.write(f"update offmarket.score_runs set finished_at = now(), "
                f"business_count = (select count(*) from offmarket.business_scores "
                f"where score_run_id = {q(run_id)}) "
                f"where id = {q(run_id)};\n")

files = sorted(os.listdir(OUT))
print(f"\nGenerated {len(files)} SQL files in {OUT}")
print(f"Totals: {sum(totals.values())} businesses, {len(all_sig_rows)} signals, {len(all_score_rows)} scores")
for fn in files:
    print(f"  {fn}  {os.path.getsize(os.path.join(OUT, fn))} bytes")
