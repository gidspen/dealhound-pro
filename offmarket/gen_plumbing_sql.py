"""Generate Supabase SQL inserts for plumbing run."""
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

def boolean(b):
    return "TRUE" if b else "FALSE"

def jsonb(obj):
    if obj is None:
        return "'{}'::jsonb"
    return f"'{json.dumps(obj).replace(chr(39), chr(39)+chr(39))}'::jsonb"

with open(ROOT / "data" / "plumbing_targets.json") as f:
    data = json.load(f)

print(f"-- Insert {len(data['businesses'])} plumbing businesses + signals + scores")
print(f"-- score_run_id = {SCORE_RUN_ID}")
print()

biz_inserts = []
score_inserts = []
signal_inserts = []

for b in data["businesses"]:
    biz_id = b["id"]
    # Convert license issue date to proper format
    lid = b.get("license_issue_date")
    if lid and lid.startswith("Pre-1990"):
        lid = "1990-01-01"  # placeholder
    elif lid and not lid[:4].isdigit():
        lid = None

    biz_inserts.append(f"""
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  {esc(biz_id)}, {esc(b['vertical'])}, {esc(b['legal_name'])}, {esc(b['dba_name'])},
  {esc(b['naics_code'])}, {esc(b['address'])}, {esc(b['city'])}, {esc(b['county'])},
  {esc(b['state'])}, {esc(b['zip'])}, {esc(b['phone'])}, {esc(b['website'])},
  {esc(b['license_number'])}, {esc(b['license_type'])}, {esc(b['license_status'])},
  {esc(lid)}, {esc(b['license_holder_name'])}, {esc(b.get('entity_status'))},
  {esc(b.get('registered_agent'))}, {num(b.get('years_in_business'))},
  {num(b.get('employee_count_estimate'))}, {num(b.get('provider_count_estimate'))},
  {esc(b.get('employee_count_source'))}, {esc(b.get('owner_name'))},
  {num(b.get('owner_age_estimate'))}, {esc(b.get('owner_age_source'))},
  {num(b.get('owner_tenure_years'))}, {boolean(b.get('is_distressed', False))},
  {jsonb(b.get('distress_reasons', []))}, {jsonb(b.get('data_sources', []))},
  {jsonb({'platform_check': b.get('platform_affiliation_check'), 'verification_notes': b.get('verification_notes'), 'spine_id': b.get('spine_id')})},
  {esc(b.get('verification_notes'))}
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;
""")

    s = b["scores"]
    score_inserts.append(f"""
INSERT INTO offmarket.business_scores (
  business_id, score_run_id, layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment, layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment, final_score, final_tier, final_comment,
  value_add_thesis, confidence, data_completeness
) VALUES (
  (SELECT id FROM offmarket.businesses WHERE vertical={esc(b['vertical'])} AND legal_name={esc(b['legal_name'])} AND city={esc(b['city'])} AND state={esc(b['state'])}),
  {esc(SCORE_RUN_ID)},
  {num(s['layer1_base_rate'])}, {esc(s['layer1_comment'])},
  {num(s['layer2_sellability'])}, {esc(s['layer2_comment'])},
  {num(s['layer3_behavioral_trigger'])}, {esc(s['layer3_comment'])},
  {num(s['layer4_market_pull'])}, {esc(s['layer4_comment'])},
  {num(s['final_score'])}, {esc(s['final_tier'])},
  {esc(s['final_comment'])}, {esc(s['value_add_thesis'])},
  {esc(s['confidence'])}, {num(s['data_completeness'])}
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate, layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability, layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger, layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull, layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score, final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment, value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence, data_completeness = EXCLUDED.data_completeness;
""")

    # Signals for top candidates
    if s["final_tier"] == "A_acquire_self":
        signal_inserts.append(f"""
INSERT INTO offmarket.business_signals (business_id, layer, signal_key, direction, evidence, source, source_url, observed_at)
VALUES (
  (SELECT id FROM offmarket.businesses WHERE vertical={esc(b['vertical'])} AND legal_name={esc(b['legal_name'])} AND city={esc(b['city'])} AND state={esc(b['state'])}),
  3, 'successor_check_live_fetch', 'positive',
  {esc(s['layer3_comment'])},
  'live_website_fetch', {esc(b.get('website'))}, '2026-05-16'
);""")

# Write SQL files
sql_dir = ROOT / "data" / "sql"
sql_dir.mkdir(exist_ok=True)

with open(sql_dir / "plumbing_10_businesses.sql", "w") as f:
    f.write("\n".join(biz_inserts))

with open(sql_dir / "plumbing_30_scores.sql", "w") as f:
    f.write("\n".join(score_inserts))

with open(sql_dir / "plumbing_20_signals.sql", "w") as f:
    f.write("\n".join(signal_inserts))

print(f"Wrote {len(biz_inserts)} businesses, {len(score_inserts)} scores, {len(signal_inserts)} signals SQL.")
print(f"Files: {sql_dir}/plumbing_10_businesses.sql, plumbing_20_signals.sql, plumbing_30_scores.sql")
