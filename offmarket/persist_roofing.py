"""Generate SQL chunks to upsert businesses, signals, scores for the roofing run."""

import json
import os

CWD = '/Users/gideonspencer/dealhound-pro/.claude/worktrees/crazy-khayyam-7adaed'
SCORE_RUN_ID = 'ae0694e6-a997-4b9a-96b2-10cc75ca1d4b'

with open(f'{CWD}/offmarket/data/roofing_targets.json') as f:
    out = json.load(f)

targets = out['businesses']

def sql_str(s):
    """Escape single quotes for SQL literal."""
    if s is None: return 'NULL'
    return "'" + str(s).replace("'", "''") + "'"

def sql_int(n):
    if n is None: return 'NULL'
    return str(int(n))

def sql_num(n):
    if n is None: return 'NULL'
    return str(n)

def sql_bool(b):
    return 'true' if b else 'false'

def sql_jsonb(obj):
    """JSON-encode for jsonb column."""
    if obj is None: return "'{}'::jsonb"
    j = json.dumps(obj, default=str)
    return sql_str(j) + '::jsonb'

# Output directory
os.makedirs(f'{CWD}/offmarket/data/sql', exist_ok=True)

# 1) businesses inserts (chunked 25 per file)
business_inserts = []
for t in targets:
    cols = [
        'id', 'vertical', 'legal_name', 'dba_name', 'naics_code',
        'address', 'city', 'county', 'state', 'zip', 'phone', 'website',
        'license_number', 'license_type', 'license_status', 'license_issue_date',
        'license_holder_name',
        'entity_sos_file_number', 'entity_formation_date', 'entity_status', 'registered_agent',
        'years_in_business', 'employee_count_estimate', 'provider_count_estimate', 'employee_count_source',
        'owner_name', 'owner_age_estimate', 'owner_age_source', 'owner_tenure_years',
        'owner_homestead_address', 'owner_property_deed_date',
        'is_distressed', 'distress_reasons',
        'data_sources', 'raw_enrichment', 'notes',
    ]
    vals = [
        sql_str(t['id']),
        sql_str('roofing'),
        sql_str(t['legal_name']),
        sql_str(t.get('dba_name')),
        sql_str(t.get('naics_code')),
        sql_str(t.get('address')),
        sql_str(t.get('city')),
        sql_str(t.get('county')),
        sql_str(t.get('state', 'TX')),
        sql_str(t.get('zip')),
        sql_str(t.get('phone')),
        sql_str(t.get('website')),
        sql_str(t.get('license_number')),
        sql_str(t.get('license_type')),
        sql_str(t.get('license_status')),
        sql_str(t.get('license_issue_date')),
        sql_str(t.get('license_holder_name')),
        sql_str(t.get('entity_sos_file_number')),
        sql_str(t.get('entity_formation_date')),
        sql_str(t.get('entity_status')),
        sql_str(t.get('registered_agent')),
        sql_int(t.get('years_in_business')),
        sql_int(t.get('employee_count_estimate')),
        sql_int(t.get('provider_count_estimate')),
        sql_str(t.get('employee_count_source')),
        sql_str(t.get('owner_name')),
        sql_int(t.get('owner_age_estimate')),
        sql_str(t.get('owner_age_source')),
        sql_int(t.get('owner_tenure_years')),
        sql_str(t.get('owner_homestead_address')),
        sql_str(t.get('owner_property_deed_date')),
        sql_bool(t.get('is_distressed', False)),
        sql_jsonb(t.get('distress_reasons', [])),
        sql_jsonb(t.get('data_sources', [])),
        sql_jsonb(t.get('raw_enrichment', {})),
        sql_str(t.get('notes', '')[:1000]),
    ]
    stmt = f"INSERT INTO offmarket.businesses ({', '.join(cols)}) VALUES ({', '.join(vals)});"
    business_inserts.append(stmt)

# Write to chunked files
chunk_size = 25
chunks = [business_inserts[i:i+chunk_size] for i in range(0, len(business_inserts), chunk_size)]
for i, chunk in enumerate(chunks):
    with open(f'{CWD}/offmarket/data/sql/10_roofing_businesses_{i+1:02}.sql', 'w') as f:
        f.write('\n'.join(chunk) + '\n')
print(f'Wrote {len(chunks)} businesses SQL chunks ({len(business_inserts)} statements).')

# 2) business_signals inserts
signal_inserts = []
for t in targets:
    for sig in t.get('signals', []):
        # Map direction values
        d = sig.get('direction', 'positive')
        if d not in ('positive', 'negative', 'disqualifying'):
            d = 'positive' if d == 'ambiguous' else 'disqualifying'
        cols = ['business_id', 'layer', 'signal_key', 'direction', 'evidence',
                'source', 'source_url', 'observed_at']
        vals = [
            sql_str(t['id']),
            sql_int(sig.get('layer')),
            sql_str(sig.get('signal_key', 'unknown')),
            sql_str(d),
            sql_str((sig.get('evidence') or '')[:5000]),
            sql_str(sig.get('source')),
            sql_str(sig.get('source_url')),
            sql_str(sig.get('observed_at', '2026-05-16')),
        ]
        stmt = f"INSERT INTO offmarket.business_signals ({', '.join(cols)}) VALUES ({', '.join(vals)});"
        signal_inserts.append(stmt)

chunks = [signal_inserts[i:i+chunk_size*3] for i in range(0, len(signal_inserts), chunk_size*3)]
for i, chunk in enumerate(chunks):
    with open(f'{CWD}/offmarket/data/sql/20_roofing_signals_{i+1:02}.sql', 'w') as f:
        f.write('\n'.join(chunk) + '\n')
print(f'Wrote {len(chunks)} signals SQL chunks ({len(signal_inserts)} statements).')

# 3) business_scores
score_inserts = []
for t in targets:
    cols = ['business_id', 'score_run_id',
            'layer1_base_rate', 'layer1_comment',
            'layer2_sellability', 'layer2_comment',
            'layer3_behavioral_trigger', 'layer3_comment',
            'layer4_market_pull', 'layer4_comment',
            'final_score', 'final_tier', 'final_comment',
            'value_add_thesis', 'confidence', 'data_completeness']
    vals = [
        sql_str(t['id']),
        sql_str(SCORE_RUN_ID),
        sql_num(t['layer1_base_rate']),
        sql_str((t.get('layer1_comment') or '')[:3000]),
        sql_num(t['layer2_sellability']),
        sql_str((t.get('layer2_comment') or '')[:3000]),
        sql_num(t['layer3_behavioral_trigger']),
        sql_str((t.get('layer3_comment') or '')[:3000]),
        sql_num(t['layer4_market_pull']),
        sql_str((t.get('layer4_comment') or '')[:3000]),
        sql_num(t['final_score']),
        sql_str(t['final_tier']),
        sql_str((t.get('final_comment') or '')[:5000]),
        sql_str((t.get('value_add_thesis') or '')[:3000]),
        sql_str(t.get('confidence', 'low')),
        sql_num(t.get('data_completeness', 0)),
    ]
    stmt = f"INSERT INTO offmarket.business_scores ({', '.join(cols)}) VALUES ({', '.join(vals)});"
    score_inserts.append(stmt)

chunks = [score_inserts[i:i+chunk_size] for i in range(0, len(score_inserts), chunk_size)]
for i, chunk in enumerate(chunks):
    with open(f'{CWD}/offmarket/data/sql/30_roofing_scores_{i+1:02}.sql', 'w') as f:
        f.write('\n'.join(chunk) + '\n')
print(f'Wrote {len(chunks)} scores SQL chunks ({len(score_inserts)} statements).')

# 4) Finalize
with open(f'{CWD}/offmarket/data/sql/40_roofing_finalize.sql', 'w') as f:
    f.write(f"UPDATE offmarket.score_runs SET business_count = {len(targets)} WHERE id = '{SCORE_RUN_ID}';\n")

print('All SQL files written.')
