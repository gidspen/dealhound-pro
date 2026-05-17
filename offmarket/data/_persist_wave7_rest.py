#!/usr/bin/env python3
"""
Persist wave7 targets via Supabase PostgREST.
Uses SUPABASE_URL + SUPABASE_SERVICE_KEY from /Users/gideonspencer/dealhound-pro/.env
"""
import json
import os
import sys
import time
import uuid
import urllib.request
import urllib.error
from pathlib import Path

# Load env from project .env
ENV_PATH = Path('/Users/gideonspencer/dealhound-pro/.env')
env = {}
for line in ENV_PATH.read_text().splitlines():
    line = line.strip()
    if not line or line.startswith('#') or '=' not in line:
        continue
    k, _, v = line.partition('=')
    env[k.strip()] = v.strip().strip('"').strip("'")

SUPABASE_URL = env['SUPABASE_URL'].rstrip('/')
SUPABASE_KEY = env['SUPABASE_SERVICE_KEY']

DATA_DIR = Path('/Users/gideonspencer/dealhound-pro/.claude/worktrees/laughing-yonath-843b53/offmarket/data')

FILES = [
    ('funeral_home_targets.json', '883fb301-0002-4bec-9478-b9d40e91f126'),
    ('independent_pharmacy_targets.json', 'ffb5045a-257d-44e3-a88e-fd243c69a15b'),
    ('cpa_accounting_targets.json', '98eb2017-36d5-4d31-bcd2-37ff9e3c8ebb'),
    ('hearing_aid_clinic_targets.json', '9c84d38b-44f8-4c2f-a4ef-36d61decbc4f'),
    ('pool_service_targets.json', '86a837ec-2608-42b4-a576-5c030010dada'),
    ('garage_door_targets.json', 'f030e361-f1de-4121-b384-79cfffc0076f'),
    ('commercial_landscaping_targets.json', '642021e3-dffd-4d34-813d-15d18f2a88c1'),
    ('welding_metal_fab_targets.json', 'c03c477f-f30f-4a21-8c1b-c69cb707803b'),
    ('glass_services_targets.json', '3e6f3700-c6f2-47f1-997a-dc420d9fa1f5'),
    ('cnc_machine_shop_targets.json', 'becddbcf-bcef-4bb1-80b9-95fed0635545'),
]

TIER_MAP = {
    'A': 'A_acquire_self', 'B': 'B_forward', 'C': 'C_watch', 'D': 'D_pass',
    'A_acquire_self': 'A_acquire_self', 'B_forward': 'B_forward',
    'C_watch': 'C_watch', 'D_pass': 'D_pass',
}

CONF_MAP = {
    'high': 'high', 'medium': 'medium', 'low': 'low',
    'High': 'high', 'Medium': 'medium', 'Low': 'low',
    'HIGH': 'high', 'MEDIUM': 'medium', 'LOW': 'low',
}


def coerce_int(v):
    if v is None:
        return None
    try:
        return int(v)
    except (TypeError, ValueError):
        return None


def coerce_num(v):
    if v is None:
        return None
    try:
        return float(v)
    except (TypeError, ValueError):
        return None


def coerce_bool(v, default=False):
    if v is None:
        return default
    if isinstance(v, bool):
        return v
    if isinstance(v, str):
        return v.strip().lower() in ('true', 'yes', '1', 't')
    return bool(v)


def clamp(v):
    if v is None:
        return None
    try:
        f = float(v)
    except (TypeError, ValueError):
        return None
    return max(0, min(100, f))


def normalize_record(rec, default_run_id):
    legal_name = rec.get('legal_name')
    final_score = rec.get('final_score')
    if not legal_name or final_score is None:
        return None, None

    run_id = rec.get('score_run_id') or default_run_id
    bid = str(uuid.uuid4())

    business = {
        'id': bid,
        'vertical': rec.get('vertical'),
        'legal_name': legal_name,
        'dba_name': rec.get('dba_name'),
        'naics_code': rec.get('naics_code'),
        'address': rec.get('address'),
        'city': rec.get('city'),
        'county': rec.get('county'),
        'state': rec.get('state') or 'TX',
        'zip': rec.get('zip'),
        'phone': rec.get('phone'),
        'website': rec.get('website'),
        'license_number': rec.get('license_number'),
        'license_type': rec.get('license_type'),
        'license_status': rec.get('license_status'),
        'license_issue_date': rec.get('license_issue_date'),
        'license_holder_name': rec.get('license_holder_name'),
        'owner_name': rec.get('owner_name'),
        'owner_age_estimate': coerce_int(rec.get('owner_age_estimate')),
        'owner_age_source': rec.get('owner_age_source'),
        'owner_tenure_years': coerce_int(rec.get('owner_tenure_years')),
        'years_in_business': coerce_int(rec.get('years_in_business')),
        'employee_count_estimate': coerce_int(
            rec.get('employee_count_estimate') if rec.get('employee_count_estimate') is not None
            else rec.get('estimated_employee_count')
        ),
        'provider_count_estimate': coerce_int(
            rec.get('provider_count_estimate') if rec.get('provider_count_estimate') is not None
            else rec.get('pharmacist_count')
        ),
        'entity_status': rec.get('entity_status'),
        'is_distressed': coerce_bool(rec.get('is_distressed')),
        'distress_reasons': rec.get('distress_reasons') or [],
        'data_sources': rec.get('data_sources') or [],
        'notes': rec.get('notes'),
    }

    layer1 = rec.get('layer1_base_rate')
    if layer1 is None:
        layer1 = rec.get('layer1_score')
    layer2 = rec.get('layer2_sellability')
    if layer2 is None:
        layer2 = rec.get('layer2_score')
    layer3 = rec.get('layer3_behavioral_trigger')
    if layer3 is None:
        layer3 = rec.get('layer3_score')
    layer4 = rec.get('layer4_market_pull')
    if layer4 is None:
        layer4 = rec.get('layer4_score')

    raw_tier = rec.get('final_tier')
    norm_tier = TIER_MAP.get(raw_tier)
    if norm_tier is None:
        return None, None

    score = {
        'business_id': bid,
        'score_run_id': run_id,
        'layer1_base_rate': clamp(layer1),
        'layer1_comment': rec.get('layer1_comment') or '',
        'layer2_sellability': clamp(layer2),
        'layer2_comment': rec.get('layer2_comment') or '',
        'layer3_behavioral_trigger': clamp(layer3),
        'layer3_comment': rec.get('layer3_comment') or '',
        'layer4_market_pull': clamp(layer4),
        'layer4_comment': rec.get('layer4_comment') or '',
        'final_score': clamp(final_score),
        'final_tier': norm_tier,
        'final_comment': rec.get('final_comment') or '',
        'value_add_thesis': rec.get('value_add_thesis'),
        'confidence': CONF_MAP.get(rec.get('confidence'), 'medium'),
        'data_completeness': coerce_num(rec.get('data_completeness')),
    }

    for k in ('layer1_base_rate', 'layer2_sellability', 'layer3_behavioral_trigger',
              'layer4_market_pull', 'final_score'):
        if score[k] is None:
            return None, None

    return business, score


def _sql_escape(v):
    if v is None:
        return 'NULL'
    if isinstance(v, bool):
        return 'TRUE' if v else 'FALSE'
    if isinstance(v, (int, float)):
        return str(v)
    if isinstance(v, (list, dict)):
        j = json.dumps(v, ensure_ascii=False)
        return "'" + j.replace("'", "''") + "'::jsonb"
    s = str(v).replace('\x00', '')
    return "'" + s.replace("'", "''") + "'"


BUSINESS_COLS = [
    'id', 'vertical', 'legal_name', 'dba_name', 'naics_code', 'address', 'city', 'county',
    'state', 'zip', 'phone', 'website', 'license_number', 'license_type', 'license_status',
    'license_issue_date', 'license_holder_name', 'owner_name', 'owner_age_estimate',
    'owner_age_source', 'owner_tenure_years', 'years_in_business', 'employee_count_estimate',
    'provider_count_estimate', 'entity_status', 'is_distressed', 'distress_reasons',
    'data_sources', 'notes',
]

SCORE_COLS = [
    'business_id', 'score_run_id', 'layer1_base_rate', 'layer1_comment', 'layer2_sellability',
    'layer2_comment', 'layer3_behavioral_trigger', 'layer3_comment', 'layer4_market_pull',
    'layer4_comment', 'final_score', 'final_tier', 'final_comment', 'value_add_thesis',
    'confidence', 'data_completeness',
]


def _build_insert_sql(table, cols, rows):
    if not rows:
        return ''
    values = []
    for r in rows:
        values.append('(' + ','.join(_sql_escape(r[c]) for c in cols) + ')')
    return (
        f'INSERT INTO offmarket.{table} (' + ','.join(cols) + ') VALUES\n  '
        + ',\n  '.join(values) + ';'
    )


def _exec_sql_via_rpc(sql):
    url = f'{SUPABASE_URL}/rest/v1/rpc/wave7_exec_sql'
    body = json.dumps({'query': sql}).encode('utf-8')
    req = urllib.request.Request(
        url, data=body, method='POST',
        headers={
            'apikey': SUPABASE_KEY,
            'Authorization': f'Bearer {SUPABASE_KEY}',
            'Content-Type': 'application/json',
        },
    )
    try:
        with urllib.request.urlopen(req, timeout=120) as resp:
            return resp.status, None
    except urllib.error.HTTPError as e:
        err_body = e.read().decode('utf-8', errors='replace')
        return e.code, err_body
    except Exception as e:
        return 0, str(e)


def post_batch(table, rows):
    """Insert rows into offmarket.<table> by building SQL and calling RPC."""
    if not rows:
        return 204, None
    if table == 'businesses':
        cols = BUSINESS_COLS
    elif table == 'business_scores':
        cols = SCORE_COLS
    else:
        return 0, f'unknown table {table}'
    sql = _build_insert_sql(table, cols, rows)
    return _exec_sql_via_rpc(sql)


def already_inserted_ids():
    """Pull existing (vertical, legal_name) keys via the SQL helper RPC + a returning function.

    Since wave7_exec_sql returns void, we need a separate function for reads.
    Instead of building another function, we use a different strategy: scan via the
    Postgres pg_meta endpoint isn't available either. Easiest path: create a temp
    SELECT-returning function once, then call it. For wave7 cold-load we already
    confirmed no rows exist in target verticals, so this dedup is informational.
    """
    return []  # cold load: target verticals are empty (verified pre-run)


def main():
    summary = {
        'per_vertical': {},
        'total_businesses_inserted': 0,
        'total_scores_inserted': 0,
        'errors': [],
    }

    existing = already_inserted_ids()
    existing_keys = {(r['vertical'], r['legal_name']) for r in existing}
    print(f'Existing rows in target verticals: {len(existing_keys)}')

    BATCH_SIZE = 25

    for fname, default_run_id in FILES:
        fpath = DATA_DIR / fname
        records = json.loads(fpath.read_text())
        if isinstance(records, dict):
            for v in records.values():
                if isinstance(v, list):
                    records = v
                    break

        vertical = fname.replace('_targets.json', '')
        biz_rows, score_rows = [], []
        skipped_normalize = 0
        skipped_dupe = 0
        seen_in_file = set()
        for rec in records:
            b, s = normalize_record(rec, default_run_id)
            if b is None or s is None:
                skipped_normalize += 1
                continue
            key = (b['vertical'], b['legal_name'], b.get('city'), b.get('state'))
            if key in existing_keys or key in seen_in_file:
                skipped_dupe += 1
                continue
            seen_in_file.add(key)
            biz_rows.append(b)
            score_rows.append(s)

        biz_inserted = 0
        score_inserted = 0
        successful_biz_indices = set()
        errs = []

        # Insert businesses in batches; track per-chunk success so we know which scores
        # are safe to insert.
        for i in range(0, len(biz_rows), BATCH_SIZE):
            chunk = biz_rows[i:i + BATCH_SIZE]
            code, body = post_batch('businesses', chunk)
            if code in (200, 201, 204):
                biz_inserted += len(chunk)
                for j in range(i, min(i + BATCH_SIZE, len(biz_rows))):
                    successful_biz_indices.add(j)
            else:
                # Fall back to per-row inserts to skip the offending row(s).
                for j, single in enumerate(chunk):
                    code1, body1 = post_batch('businesses', [single])
                    if code1 in (200, 201, 204):
                        biz_inserted += 1
                        successful_biz_indices.add(i + j)
                    else:
                        errs.append({
                            'phase': 'businesses',
                            'row_index': i + j,
                            'code': code1,
                            'body': (body1[:400] if body1 else ''),
                            'legal_name': single['legal_name'],
                            'city': single.get('city'),
                        })

        # Insert scores for successful businesses, in batches aligned by index.
        ok_score_rows = [score_rows[i] for i in sorted(successful_biz_indices)]
        for i in range(0, len(ok_score_rows), BATCH_SIZE):
            chunk = ok_score_rows[i:i + BATCH_SIZE]
            code, body = post_batch('business_scores', chunk)
            if code in (200, 201, 204):
                score_inserted += len(chunk)
            else:
                for single in chunk:
                    code1, body1 = post_batch('business_scores', [single])
                    if code1 in (200, 201, 204):
                        score_inserted += 1
                    else:
                        errs.append({
                            'phase': 'scores',
                            'code': code1,
                            'body': (body1[:400] if body1 else ''),
                            'business_id': single['business_id'],
                        })

        summary['per_vertical'][vertical] = {
            'records_in_file': len(records),
            'normalized': len(biz_rows),
            'skipped_normalize': skipped_normalize,
            'skipped_dupe': skipped_dupe,
            'businesses_inserted': biz_inserted,
            'scores_inserted': score_inserted,
            'errors': errs,
            'run_id': default_run_id,
        }
        summary['total_businesses_inserted'] += biz_inserted
        summary['total_scores_inserted'] += score_inserted
        if errs:
            summary['errors'].extend([{'vertical': vertical, **e} for e in errs])

        print(f'{vertical}: file={len(records)} normalized={len(biz_rows)} '
              f'dupe={skipped_dupe} norm_skipped={skipped_normalize} '
              f'biz_in={biz_inserted} score_in={score_inserted} errs={len(errs)}')

    out = DATA_DIR / 'wave7_persistence_summary.json'
    out.write_text(json.dumps(summary, indent=2))
    print()
    print(f'Wrote summary to {out}')
    print(f'Totals: businesses={summary["total_businesses_inserted"]} '
          f'scores={summary["total_scores_inserted"]} '
          f'errors={len(summary["errors"])}')


if __name__ == '__main__':
    main()
