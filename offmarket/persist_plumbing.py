"""
Persist plumbing data to Supabase via a single Python orchestrator that
prepares all SQL chunks and writes a markdown 'persist_status' for the
agent to execute via MCP calls.

This script writes one large multi-VALUES insert per Supabase MCP call,
sized at ~20KB each. It does NOT execute against Supabase — it prepares
artifacts that the MCP agent can iterate through.
"""
import json
import uuid
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
    s = json.dumps(obj, ensure_ascii=False).replace("'", "''")
    return f"'{s}'::jsonb"

with open(ROOT / "data" / "plumbing_targets.json") as f:
    data = json.load(f)

# Filter out the 10 already-inserted businesses (spine_ids plm-001 to plm-010)
already_inserted = set(['plm-001','plm-002','plm-003','plm-004','plm-005','plm-006','plm-007','plm-008','plm-009','plm-010'])
remaining = [b for b in data["businesses"] if b["spine_id"] not in already_inserted]
print(f"Total: {len(data['businesses'])}, Already inserted: {len(already_inserted)}, Remaining: {len(remaining)}")

# Build compact insert rows
biz_cols = "id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, years_in_business, employee_count_estimate, provider_count_estimate, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, is_distressed, distress_reasons, data_sources, raw_enrichment, notes"

upsert_clause = """ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  license_number = EXCLUDED.license_number, license_type = EXCLUDED.license_type,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  employee_count_estimate = EXCLUDED.employee_count_estimate,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons,
  raw_enrichment = EXCLUDED.raw_enrichment,
  notes = EXCLUDED.notes,
  updated_at = NOW()"""

# Compact rows
rows = []
for b in remaining:
    lid = b.get("license_issue_date")
    if lid and (lid.startswith("Pre-1990") or not lid[:4].isdigit()):
        lid = None
    # Truncate verbose notes to fit limits
    notes = (b.get('verification_notes') or '')[:300]
    row = (
        f"({esc(b['id'])},'plumbing',{esc(b['legal_name'])},{esc(b.get('dba_name'))},'238220',"
        f"{esc(b.get('address'))},{esc(b.get('city'))},{esc(b.get('county'))},'TX',{esc(b.get('zip'))},"
        f"{esc(b.get('phone'))},{esc(b.get('website'))},{esc(b.get('license_number'))},"
        f"{esc(b.get('license_type'))},{esc(b.get('license_status'))},{esc(lid)},"
        f"{esc(b.get('license_holder_name'))},{num(b.get('years_in_business'))},"
        f"{num(b.get('employee_count_estimate'))},{num(b.get('provider_count_estimate'))},"
        f"{esc(b.get('owner_name'))},{num(b.get('owner_age_estimate'))},"
        f"{esc(b.get('owner_age_source'))},{num(b.get('owner_tenure_years'))},"
        f"{'TRUE' if b.get('is_distressed') else 'FALSE'},"
        f"{jsonb(b.get('distress_reasons',[]))},{jsonb(b.get('data_sources',[]))},"
        f"{jsonb({'platform_check':b.get('platform_affiliation_check'),'spine_id':b.get('spine_id')})},"
        f"{esc(notes)})"
    )
    rows.append(row)

# Chunk to ~20KB per query
out_dir = ROOT / "data" / "sql_minimal"
out_dir.mkdir(exist_ok=True)

current = []
current_size = 0
chunk_idx = 0
header = f"INSERT INTO offmarket.businesses ({biz_cols}) VALUES "
for row in rows:
    addn = len(row) + 3
    if current_size + addn > 18000 and current:
        sql = header + ",".join(current) + " " + upsert_clause + ";"
        with open(out_dir / f"biz_{chunk_idx:02d}.sql", "w") as f:
            f.write(sql)
        chunk_idx += 1
        current = []
        current_size = 0
    current.append(row)
    current_size += addn
if current:
    sql = header + ",".join(current) + " " + upsert_clause + ";"
    with open(out_dir / f"biz_{chunk_idx:02d}.sql", "w") as f:
        f.write(sql)

print(f"Wrote {chunk_idx+1} biz chunks")

# Same for scores — all 100 (idempotent upserts)
score_cols = "business_id, score_run_id, layer1_base_rate, layer1_comment, layer2_sellability, layer2_comment, layer3_behavioral_trigger, layer3_comment, layer4_market_pull, layer4_comment, final_score, final_tier, final_comment, value_add_thesis, confidence, data_completeness"

score_upsert_clause = """ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate, layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability, layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger, layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull, layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score, final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment, value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence, data_completeness = EXCLUDED.data_completeness"""

score_header = f"INSERT INTO offmarket.business_scores ({score_cols}) VALUES "

score_rows = []
for b in data["businesses"]:
    s = b["scores"]
    # Truncate comments to fit
    l1c = s.get('layer1_comment','')[:500]
    l2c = s.get('layer2_comment','')[:500]
    l3c = s.get('layer3_comment','')[:500]
    l4c = s.get('layer4_comment','')[:500]
    fc = s.get('final_comment','')[:800]
    va = (s.get('value_add_thesis','') or '')[:800]
    score_rows.append(
        f"({esc(b['id'])},{esc(SCORE_RUN_ID)},{num(s['layer1_base_rate'])},{esc(l1c)},"
        f"{num(s['layer2_sellability'])},{esc(l2c)},{num(s['layer3_behavioral_trigger'])},{esc(l3c)},"
        f"{num(s['layer4_market_pull'])},{esc(l4c)},{num(s['final_score'])},{esc(s['final_tier'])},"
        f"{esc(fc)},{esc(va)},{esc(s.get('confidence','low'))},{num(s.get('data_completeness',0.3))})"
    )

current = []
current_size = 0
chunk_idx = 0
for row in score_rows:
    addn = len(row) + 3
    if current_size + addn > 18000 and current:
        sql = score_header + ",".join(current) + " " + score_upsert_clause + ";"
        with open(out_dir / f"score_{chunk_idx:02d}.sql", "w") as f:
            f.write(sql)
        chunk_idx += 1
        current = []
        current_size = 0
    current.append(row)
    current_size += addn
if current:
    sql = score_header + ",".join(current) + " " + score_upsert_clause + ";"
    with open(out_dir / f"score_{chunk_idx:02d}.sql", "w") as f:
        f.write(sql)

print(f"Wrote {chunk_idx+1} score chunks")

# Signals for A-tier (3 candidates)
sig_rows = []
for b in data["businesses"]:
    s = b["scores"]
    if s["final_tier"] == "A_acquire_self":
        evidence = (s.get('layer3_comment','') or '')[:800]
        sig_rows.append(
            f"({esc(b['id'])},3,'successor_check_live_fetch','positive',{esc(evidence)},'live_website_fetch',{esc(b.get('website'))},'2026-05-16')"
        )

sig_sql = f"INSERT INTO offmarket.business_signals (business_id,layer,signal_key,direction,evidence,source,source_url,observed_at) VALUES " + ",".join(sig_rows) + ";"
with open(out_dir / "signals_00.sql", "w") as f:
    f.write(sig_sql)
print(f"Wrote 1 signal chunk with {len(sig_rows)} A-tier successor checks")

# List final file sizes
import os
for fname in sorted(os.listdir(out_dir)):
    sz = os.path.getsize(out_dir / fname)
    print(f"  {fname}: {sz} bytes")
