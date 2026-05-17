#!/usr/bin/env python3
"""Generate SQL chunks for Supabase persistence of autorepair run.

Reads autorepair_targets.json, emits SQL chunks under offmarket/data/sql/
that can be applied via the Supabase MCP execute_sql tool.

Schema reference from offmarket/schema.sql.
"""
import json
import os
import uuid
from datetime import datetime, timezone

OUTDIR = "/Users/gideonspencer/dealhound-pro/.claude/worktrees/crazy-khayyam-7adaed/offmarket/data"
SQLDIR = f"{OUTDIR}/sql"
os.makedirs(SQLDIR, exist_ok=True)

SCORE_RUN_ID = "72d217c5-7a7d-4a8e-9834-fe925dd4a1b2"
RUN_LABEL = "autorepair-tx-2026-05-15"


def esc(s):
    """Escape single quotes for SQL literal."""
    if s is None:
        return "NULL"
    if isinstance(s, bool):
        return "true" if s else "false"
    if isinstance(s, (int, float)):
        return str(s)
    if isinstance(s, (list, dict)):
        return "'" + json.dumps(s).replace("'", "''") + "'::jsonb"
    return "'" + str(s).replace("'", "''") + "'"


with open(f"{OUTDIR}/autorepair_targets.json") as f:
    data = json.load(f)

businesses = data["businesses"]

# --- 10_businesses.sql: businesses upsert ---
with open(f"{SQLDIR}/10_autorepair_businesses.sql", "w") as f:
    f.write("-- Auto Repair businesses upsert (run autorepair-tx-2026-05-15)\n")
    f.write("BEGIN;\n\n")
    for b in businesses:
        cols = [
            "id", "vertical", "legal_name", "dba_name", "naics_code",
            "address", "city", "county", "state", "zip", "phone", "website",
            "license_number", "license_type", "license_status", "license_issue_date",
            "license_holder_name",
            "entity_sos_file_number", "entity_formation_date", "entity_status", "registered_agent",
            "years_in_business", "employee_count_estimate", "provider_count_estimate",
            "employee_count_source", "owner_name", "owner_age_estimate", "owner_age_source",
            "owner_tenure_years", "owner_homestead_address", "owner_property_deed_date",
            "is_distressed", "distress_reasons", "data_sources", "raw_enrichment", "notes",
        ]
        vals = [
            esc(b["id"]),
            esc(b["vertical"]),
            esc(b["legal_name"]),
            esc(b.get("dba_name")),
            esc(b.get("naics_code")),
            esc(b.get("address")),
            esc(b.get("city")),
            esc(b.get("county")),
            esc(b.get("state")),
            esc(b.get("zip")),
            esc(b.get("phone")),
            esc(b.get("website")),
            esc(b.get("license_number")),
            esc(b.get("license_type")),
            esc(b.get("license_status")),
            esc(b.get("license_issue_date")),
            esc(b.get("license_holder_name")),
            esc(b.get("entity_sos_file_number")),
            esc(b.get("entity_formation_date")),
            esc(b.get("entity_status")),
            esc(b.get("registered_agent")),
            esc(b.get("years_in_business")),
            esc(b.get("employee_count_estimate")),
            esc(b.get("provider_count_estimate")),
            esc(b.get("employee_count_source")),
            esc(b.get("owner_name")),
            esc(b.get("owner_age_estimate")),
            esc(b.get("owner_age_source")),
            esc(b.get("owner_tenure_years")),
            esc(b.get("owner_homestead_address")),
            esc(b.get("owner_property_deed_date")),
            esc(b.get("is_distressed", False)),
            esc(b.get("distress_reasons", [])),
            esc(b.get("data_sources", [])),
            esc(b.get("raw_enrichment", {})),
            esc(None),
        ]
        f.write(
            f"INSERT INTO offmarket.businesses ({', '.join(cols)})\n"
            f"VALUES ({', '.join(vals)})\n"
            f"ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET\n"
            f"  website = EXCLUDED.website,\n"
            f"  owner_name = EXCLUDED.owner_name,\n"
            f"  owner_age_estimate = EXCLUDED.owner_age_estimate,\n"
            f"  owner_age_source = EXCLUDED.owner_age_source,\n"
            f"  owner_tenure_years = EXCLUDED.owner_tenure_years,\n"
            f"  years_in_business = EXCLUDED.years_in_business,\n"
            f"  data_sources = EXCLUDED.data_sources,\n"
            f"  raw_enrichment = EXCLUDED.raw_enrichment,\n"
            f"  updated_at = now();\n\n"
        )
    f.write("COMMIT;\n")

# --- 20_signals.sql ---
with open(f"{SQLDIR}/20_autorepair_signals.sql", "w") as f:
    f.write("-- Auto Repair business_signals (run autorepair-tx-2026-05-15)\n")
    f.write("BEGIN;\n\n")
    for b in businesses:
        for s in b.get("signals", []):
            sig_id = str(uuid.uuid4())
            f.write(
                f"INSERT INTO offmarket.business_signals "
                f"(id, business_id, layer, signal_key, direction, evidence, source, source_url, observed_at) "
                f"VALUES ("
                f"{esc(sig_id)}, "
                f"{esc(b['id'])}, "
                f"{esc(s['layer'])}, "
                f"{esc(s['signal_key'])}, "
                f"{esc(s['direction'])}, "
                f"{esc(s['evidence'])}, "
                f"{esc(s['source'])}, "
                f"{esc(s.get('source_url'))}, "
                f"{esc(s.get('observed_at'))}"
                f") ON CONFLICT DO NOTHING;\n"
            )
    f.write("\nCOMMIT;\n")

# --- 30_scores.sql ---
with open(f"{SQLDIR}/30_autorepair_scores.sql", "w") as f:
    f.write("-- Auto Repair business_scores (run autorepair-tx-2026-05-15)\n")
    f.write("BEGIN;\n\n")
    for b in businesses:
        score_id = str(uuid.uuid4())
        f.write(
            f"INSERT INTO offmarket.business_scores "
            f"(id, business_id, score_run_id, layer1_base_rate, layer1_comment, "
            f"layer2_sellability, layer2_comment, layer3_behavioral_trigger, layer3_comment, "
            f"layer4_market_pull, layer4_comment, final_score, final_tier, final_comment, "
            f"value_add_thesis, confidence, data_completeness) VALUES ("
            f"{esc(score_id)}, "
            f"{esc(b['id'])}, "
            f"{esc(SCORE_RUN_ID)}, "
            f"{esc(b['layer1_base_rate'])}, "
            f"{esc(b['layer1_comment'])}, "
            f"{esc(b['layer2_sellability'])}, "
            f"{esc(b['layer2_comment'])}, "
            f"{esc(b['layer3_behavioral_trigger'])}, "
            f"{esc(b['layer3_comment'])}, "
            f"{esc(b['layer4_market_pull'])}, "
            f"{esc(b['layer4_comment'])}, "
            f"{esc(b['final_score'])}, "
            f"{esc(b['final_tier'])}, "
            f"{esc(b['final_comment'])}, "
            f"{esc(b['value_add_thesis'])}, "
            f"{esc(b['confidence'])}, "
            f"{esc(b['data_completeness'])}"
            f") ON CONFLICT (business_id, score_run_id) DO UPDATE SET "
            f"  layer1_base_rate = EXCLUDED.layer1_base_rate, "
            f"  layer1_comment = EXCLUDED.layer1_comment, "
            f"  layer2_sellability = EXCLUDED.layer2_sellability, "
            f"  layer2_comment = EXCLUDED.layer2_comment, "
            f"  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger, "
            f"  layer3_comment = EXCLUDED.layer3_comment, "
            f"  layer4_market_pull = EXCLUDED.layer4_market_pull, "
            f"  layer4_comment = EXCLUDED.layer4_comment, "
            f"  final_score = EXCLUDED.final_score, "
            f"  final_tier = EXCLUDED.final_tier, "
            f"  final_comment = EXCLUDED.final_comment, "
            f"  value_add_thesis = EXCLUDED.value_add_thesis, "
            f"  confidence = EXCLUDED.confidence, "
            f"  data_completeness = EXCLUDED.data_completeness;\n"
        )
    f.write("\nCOMMIT;\n")

# --- 40_finalize.sql ---
with open(f"{SQLDIR}/40_autorepair_finalize.sql", "w") as f:
    f.write(
        f"UPDATE offmarket.score_runs SET business_count = {len(businesses)}\n"
        f"WHERE id = {esc(SCORE_RUN_ID)};\n"
    )

print(f"SQL chunks written to {SQLDIR}")
print(f"  10_autorepair_businesses.sql: {len(businesses)} businesses")
nsigs = sum(len(b.get('signals', [])) for b in businesses)
print(f"  20_autorepair_signals.sql: {nsigs} signals")
print(f"  30_autorepair_scores.sql: {len(businesses)} scores")
print(f"  40_autorepair_finalize.sql: business_count update")
