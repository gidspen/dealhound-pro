#!/usr/bin/env python3
"""Produce minimal SQL inserts (just essential columns) for Supabase upload."""
import json, uuid, os

ROOT = os.path.dirname(os.path.abspath(__file__))
DATA = json.load(open(os.path.join(ROOT, "..", "surveying_targets.json")))
RUN_ID = DATA["run"]["score_run_id"]
NS = uuid.UUID("6f1d2c00-0000-4000-8000-000000000001")

# IDs of the 23 already inserted in the chat (5 A-tier + 18 from compact_businesses_01)
ALREADY = {
    # 5 from chat
    "10014800","10034800","10057100","10133000","10057300",
    # 18 from compact_businesses_01 manual push
    "10104700","10068300","10091800","10040200","10194225","10105700","10124200",
    "10118600","10002700","10158900","10041000","10043300","10059800","10064100",
    "10002000","10045400","10040700","10095700",
}

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

# Minimal business rows: keep only critical columns for cross-vertical view
rows = []
for b in DATA["businesses"]:
    if b["license_number"] in ALREADY:
        continue
    i = bid(b)
    enrich = b.get('raw_enrichment',{}) or {}
    re_obj = {"spine_priority": enrich.get("spine_priority"), "geo_bucket": enrich.get("geo_bucket")}
    rows.append("(" + ", ".join([
        esc(i),
        esc("land_surveying"),
        esc(b["legal_name"]),
        esc(b["city"]),
        esc(b["county"]),
        esc("TX"),
        esc(b["zip"]),
        esc(b["address"]),
        esc(b.get("phone")),
        esc(b.get("website")),
        esc(b["license_number"]),
        esc("Surveying Firm Registration (TBPELS)"),
        esc("Registered"),
        esc(b.get("license_issue_date")),
        esc(b.get("license_holder_name")),
        esc(b.get("years_in_business")),
        esc(b.get("provider_count_estimate")),
        esc("tbpels_rpls_roster"),
        esc(b.get("owner_name")),
        esc(b.get("owner_age_estimate")),
        esc(b.get("owner_age_source")),
        esc(b.get("owner_tenure_years")),
        esc(b.get("is_distressed", False)),
        esc(b.get("distress_reasons", [])),
        esc([]),
        esc(re_obj),
        esc("541370"),
    ]) + ")")

# Split into 4 batches
BCOLS_SQL = "id, vertical, legal_name, city, county, state, zip, address, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, years_in_business, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, is_distressed, distress_reasons, data_sources, raw_enrichment, naics_code"

# Write 3 chunks of ~28 rows each
chunk_size = 28
for i in range(0, len(rows), chunk_size):
    chunk = rows[i:i+chunk_size]
    fn = f"minimal_businesses_{i//chunk_size+1:02d}.sql"
    with open(os.path.join(ROOT, fn), "w") as f:
        f.write(f"insert into offmarket.businesses ({BCOLS_SQL}) values\n")
        f.write(",\n".join(chunk))
        f.write("\non conflict (vertical, legal_name, city, state) do nothing;\n")
    print(f"  Wrote {fn} ({len(chunk)} rows, {os.path.getsize(os.path.join(ROOT, fn))} bytes)")
