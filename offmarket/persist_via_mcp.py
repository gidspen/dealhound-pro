"""Generate compact INSERT statements suitable for MCP execute_sql submission.

Outputs: many small files of ~5KB each (≤ 8 rows per file) for safe submission.
"""

import json
import os

CWD = '/Users/gideonspencer/dealhound-pro/.claude/worktrees/crazy-khayyam-7adaed'
SCORE_RUN_ID = 'ae0694e6-a997-4b9a-96b2-10cc75ca1d4b'

with open(f'{CWD}/offmarket/data/roofing_targets.json') as f:
    out = json.load(f)

targets = out['businesses']
INSERTED = {'e9b2469f-cb0f-5bc9-8a69-b22ed62d1a2d', '1adbcf30-4476-580e-a653-9b67d5cc99f0'}

def s(v):
    if v is None: return 'NULL'
    if isinstance(v, bool): return 'true' if v else 'false'
    if isinstance(v, (int, float)): return str(v)
    return "'" + str(v).replace("'", "''") + "'"

def j(obj, max_len=2000):
    """JSON-encode and truncate notes for jsonb."""
    if obj is None: return "'{}'::jsonb"
    txt = json.dumps(obj, default=str)
    if len(txt) > max_len:
        txt = txt[:max_len-3] + '..."'
    return s(txt) + '::jsonb'

# Compact business inserts — keep notes short
business_inserts = []
for t in targets:
    if t['id'] in INSERTED: continue
    notes_short = (t.get('notes') or '')[:500]
    raw_short = {k: (str(v)[:500] if isinstance(v, str) else v)
                 for k, v in (t.get('raw_enrichment') or {}).items()}
    stmt = (
        f"({s(t['id'])}, 'roofing', {s(t['legal_name'])}, {s(t.get('dba_name'))}, '238160', "
        f"{s(t.get('address'))}, {s(t.get('city'))}, {s(t.get('county'))}, 'TX', {s(t.get('zip'))}, "
        f"{s(t.get('phone'))}, {s(t.get('website'))}, "
        f"'no_state_roofing_license_in_tx', 'n/a', 'unknown', "
        f"{s(t.get('years_in_business'))}, 'license_tenure_proxy', {s(t.get('owner_tenure_years'))}, false, "
        f"{j(t.get('data_sources', []), 1000)}, {j(raw_short, 1500)}, {s(notes_short)})"
    )
    business_inserts.append(stmt)

print(f'Business inserts: {len(business_inserts)}')

# Group large per chunk; aiming for ≤45KB per chunk
biz_cols = "(id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_type, license_status, entity_status, years_in_business, owner_age_source, owner_tenure_years, is_distressed, data_sources, raw_enrichment, notes)"
header = f"INSERT INTO offmarket.businesses {biz_cols} VALUES\n"

chunks = []
chunk_size = 35
for i in range(0, len(business_inserts), chunk_size):
    chunk = business_inserts[i:i+chunk_size]
    sql = header + ',\n'.join(chunk) + ';'
    chunks.append(sql)

os.makedirs(f'{CWD}/offmarket/data/sql_mcp', exist_ok=True)
for i, sql in enumerate(chunks):
    fn = f'{CWD}/offmarket/data/sql_mcp/biz_{i+1:02}.sql'
    with open(fn, 'w') as f:
        f.write(sql)
    if i < 2:
        print(f'{fn}: {len(sql)} bytes')
print(f'Wrote {len(chunks)} business chunks.')

# Signals — compact (only essential fields, trim evidence)
def signal_sql(business_id, sig):
    d = sig.get('direction', 'positive')
    if d not in ('positive', 'negative', 'disqualifying'):
        d = 'positive' if 'amb' in d else 'disqualifying'
    ev = (sig.get('evidence') or '')[:1500]
    return (
        f"({s(business_id)}, {s(sig.get('layer'))}, {s(sig.get('signal_key', 'unknown'))}, "
        f"{s(d)}, {s(ev)}, {s(sig.get('source'))}, {s(sig.get('source_url'))}, "
        f"{s(sig.get('observed_at', '2026-05-16'))})"
    )

sig_inserts = []
for t in targets:
    if t['id'] in INSERTED:
        # Still need signals for these
        pass
    for sig in t.get('signals', []):
        sig_inserts.append(signal_sql(t['id'], sig))

print(f'Signal inserts: {len(sig_inserts)}')

sig_header = "INSERT INTO offmarket.business_signals (business_id, layer, signal_key, direction, evidence, source, source_url, observed_at) VALUES\n"
sig_chunk_size = 30
sig_chunks = []
for i in range(0, len(sig_inserts), sig_chunk_size):
    chunk = sig_inserts[i:i+sig_chunk_size]
    sql = sig_header + ',\n'.join(chunk) + ';'
    sig_chunks.append(sql)

for i, sql in enumerate(sig_chunks):
    fn = f'{CWD}/offmarket/data/sql_mcp/sig_{i+1:02}.sql'
    with open(fn, 'w') as f:
        f.write(sql)
print(f'Wrote {len(sig_chunks)} signal chunks.')

# Scores
score_inserts = []
for t in targets:
    fc = (t.get('final_comment') or '')[:1500]
    vat = (t.get('value_add_thesis') or '')[:1500]
    l1c = (t.get('layer1_comment') or '')[:600]
    l2c = (t.get('layer2_comment') or '')[:600]
    l3c = (t.get('layer3_comment') or '')[:1000]
    l4c = (t.get('layer4_comment') or '')[:600]
    stmt = (
        f"({s(t['id'])}, {s(SCORE_RUN_ID)}, "
        f"{s(t['layer1_base_rate'])}, {s(l1c)}, "
        f"{s(t['layer2_sellability'])}, {s(l2c)}, "
        f"{s(t['layer3_behavioral_trigger'])}, {s(l3c)}, "
        f"{s(t['layer4_market_pull'])}, {s(l4c)}, "
        f"{s(t['final_score'])}, {s(t['final_tier'])}, {s(fc)}, "
        f"{s(vat)}, {s(t.get('confidence', 'low'))}, {s(t.get('data_completeness', 0))})"
    )
    score_inserts.append(stmt)

print(f'Score inserts: {len(score_inserts)}')

score_header = "INSERT INTO offmarket.business_scores (business_id, score_run_id, layer1_base_rate, layer1_comment, layer2_sellability, layer2_comment, layer3_behavioral_trigger, layer3_comment, layer4_market_pull, layer4_comment, final_score, final_tier, final_comment, value_add_thesis, confidence, data_completeness) VALUES\n"
score_chunk_size = 25
score_chunks = []
for i in range(0, len(score_inserts), score_chunk_size):
    chunk = score_inserts[i:i+score_chunk_size]
    sql = score_header + ',\n'.join(chunk) + ';'
    score_chunks.append(sql)

for i, sql in enumerate(score_chunks):
    fn = f'{CWD}/offmarket/data/sql_mcp/score_{i+1:02}.sql'
    with open(fn, 'w') as f:
        f.write(sql)
print(f'Wrote {len(score_chunks)} score chunks.')
print()
print(f'TOTAL files to submit: {len(chunks)} biz + {len(sig_chunks)} signals + {len(score_chunks)} scores = {len(chunks)+len(sig_chunks)+len(score_chunks)} chunks')
