"""Generate compact multi-VALUES batched INSERTs for Supabase MCP."""
import json
from pathlib import Path

ROOT = Path("/Users/gideonspencer/dealhound-pro/.claude/worktrees/crazy-khayyam-7adaed/offmarket")
SCORE_RUN_ID = "6cbb9025-2383-4e26-bbd2-992f0e1a906f"

def esc(s):
    if s is None:
        return "NULL"
    s = str(s).replace("'", "''")
    return f"'{s}'"

def num(n):
    return "NULL" if n is None else str(n)

def jsonb(obj):
    if obj is None:
        return "'{}'::jsonb"
    s = json.dumps(obj).replace("'", "''")
    return f"'{s}'::jsonb"

with open(ROOT / "data" / "plumbing_targets.json") as f:
    data = json.load(f)

# Batched businesses inserts — 50 per chunk
biz_rows = []
score_rows = []
for b in data["businesses"]:
    biz_id = b["id"]
    lid = b.get("license_issue_date")
    if lid and (lid.startswith("Pre-1990") or not lid[:4].isdigit()):
        lid = None

    distress_reasons_str = jsonb(b.get('distress_reasons', []))
    data_sources_str = jsonb(b.get('data_sources', []))
    raw_enrichment_str = jsonb({'platform_check': b.get('platform_affiliation_check'), 'spine_id': b.get('spine_id'), 'verification_notes': b.get('verification_notes')})

    row = f"({esc(biz_id)}, 'plumbing', {esc(b['legal_name'])}, {esc(b['dba_name'])}, '238220', {esc(b['address'])}, {esc(b['city'])}, {esc(b['county'])}, 'TX', {esc(b['zip'])}, {esc(b['phone'])}, {esc(b['website'])}, {esc(b['license_number'])}, {esc(b['license_type'])}, {esc(b['license_status'])}, {esc(lid)}, {esc(b['license_holder_name'])}, NULL, NULL, {num(b.get('years_in_business'))}, {num(b.get('employee_count_estimate'))}, {num(b.get('provider_count_estimate'))}, {esc(b.get('employee_count_source'))}, {esc(b.get('owner_name'))}, {num(b.get('owner_age_estimate'))}, {esc(b.get('owner_age_source'))}, {num(b.get('owner_tenure_years'))}, {'TRUE' if b.get('is_distressed') else 'FALSE'}, {distress_reasons_str}, {data_sources_str}, {raw_enrichment_str}, {esc(b.get('verification_notes'))})"
    biz_rows.append(row)

    s = b['scores']
    score_row = f"({esc(biz_id)}, {esc(SCORE_RUN_ID)}, {num(s['layer1_base_rate'])}, {esc(s['layer1_comment'])}, {num(s['layer2_sellability'])}, {esc(s['layer2_comment'])}, {num(s['layer3_behavioral_trigger'])}, {esc(s['layer3_comment'])}, {num(s['layer4_market_pull'])}, {esc(s['layer4_comment'])}, {num(s['final_score'])}, {esc(s['final_tier'])}, {esc(s['final_comment'])}, {esc(s['value_add_thesis'])}, {esc(s['confidence'])}, {num(s['data_completeness'])})"
    score_rows.append(score_row)

# Write chunked SQL — 25 rows per insert
out_dir = ROOT / "data" / "sql_compact"
out_dir.mkdir(exist_ok=True)

biz_cols = "id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, is_distressed, distress_reasons, data_sources, raw_enrichment, notes"

biz_upsert_clause = """ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()"""

# Skip first 10 (already inserted)
remaining_biz = biz_rows[10:]
chunk_size = 30
for i in range(0, len(remaining_biz), chunk_size):
    chunk = remaining_biz[i:i+chunk_size]
    idx = i // chunk_size
    out = f"INSERT INTO offmarket.businesses ({biz_cols}) VALUES\n  " + ",\n  ".join(chunk) + f"\n{biz_upsert_clause};"
    with open(out_dir / f"biz_remaining_{idx:02d}.sql", "w") as f:
        f.write(out)

# All scores
score_cols = "business_id, score_run_id, layer1_base_rate, layer1_comment, layer2_sellability, layer2_comment, layer3_behavioral_trigger, layer3_comment, layer4_market_pull, layer4_comment, final_score, final_tier, final_comment, value_add_thesis, confidence, data_completeness"

# Use score row's business_id as the actual ID (we have it)
score_upsert_clause = """ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate, layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability, layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger, layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull, layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score, final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment, value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence, data_completeness = EXCLUDED.data_completeness"""

for i in range(0, len(score_rows), chunk_size):
    chunk = score_rows[i:i+chunk_size]
    idx = i // chunk_size
    out = f"INSERT INTO offmarket.business_scores ({score_cols}) VALUES\n  " + ",\n  ".join(chunk) + f"\n{score_upsert_clause};"
    with open(out_dir / f"score_chunk_{idx:02d}.sql", "w") as f:
        f.write(out)

print(f"Wrote {(len(remaining_biz)+chunk_size-1)//chunk_size} business chunks (remaining)")
print(f"Wrote {(len(score_rows)+chunk_size-1)//chunk_size} score chunks (all)")
