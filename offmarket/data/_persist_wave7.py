#!/usr/bin/env python3
"""
Generate SQL batches for wave7 persistence.
Reads target JSON files, normalizes fields, emits SQL files we can pipe through execute_sql.
"""
import json
import os
import uuid
from pathlib import Path

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
    'A': 'A_acquire_self',
    'B': 'B_forward',
    'C': 'C_watch',
    'D': 'D_pass',
    'A_acquire_self': 'A_acquire_self',
    'B_forward': 'B_forward',
    'C_watch': 'C_watch',
    'D_pass': 'D_pass',
}

CONFIDENCE_MAP = {
    'high': 'high', 'medium': 'medium', 'low': 'low',
    'High': 'high', 'Medium': 'medium', 'Low': 'low',
    'HIGH': 'high', 'MEDIUM': 'medium', 'LOW': 'low',
}


def sql_escape(v):
    """SQL escape a Python value -> SQL literal."""
    if v is None:
        return 'NULL'
    if isinstance(v, bool):
        return 'TRUE' if v else 'FALSE'
    if isinstance(v, (int, float)):
        return str(v)
    if isinstance(v, (list, dict)):
        # JSON encode then escape single quotes
        j = json.dumps(v, ensure_ascii=False)
        return "'" + j.replace("'", "''") + "'::jsonb"
    s = str(v)
    # strip null chars
    s = s.replace('\x00', '')
    return "'" + s.replace("'", "''") + "'"


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


def coerce_bool(v):
    if v is None:
        return False
    if isinstance(v, bool):
        return v
    if isinstance(v, str):
        return v.strip().lower() in ('true', 'yes', '1', 't')
    return bool(v)


def normalize_record(rec, default_run_id):
    """Map a raw record -> (business_dict, score_dict)."""
    # Required for skipping
    legal_name = rec.get('legal_name')
    final_score = rec.get('final_score')
    if not legal_name or final_score is None:
        return None, None

    run_id = rec.get('score_run_id') or default_run_id

    # ---- businesses fields ----
    business = {
        'id': str(uuid.uuid4()),
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
            rec.get('employee_count_estimate') or rec.get('estimated_employee_count')
        ),
        'provider_count_estimate': coerce_int(
            rec.get('provider_count_estimate') or rec.get('pharmacist_count')
        ),
        'entity_status': rec.get('entity_status'),
        'is_distressed': coerce_bool(rec.get('is_distressed')),
        'distress_reasons': rec.get('distress_reasons') or [],
        'data_sources': rec.get('data_sources') or [],
        'notes': rec.get('notes'),
    }

    # ---- scores fields ----
    # Handle layer1_score vs layer1_base_rate, layer2_score vs layer2_sellability, etc.
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
        # Skip records with unmappable tier
        return None, None

    raw_conf = rec.get('confidence') or 'medium'
    conf = CONFIDENCE_MAP.get(raw_conf, 'medium')

    # Clamp numeric scores to 0..100
    def clamp(v):
        if v is None:
            return None
        try:
            f = float(v)
        except (TypeError, ValueError):
            return None
        if f < 0:
            return 0
        if f > 100:
            return 100
        return f

    score = {
        'business_id': business['id'],
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
        'confidence': conf,
        'data_completeness': coerce_num(rec.get('data_completeness')),
    }

    # Required NOT NULL columns in score (no nullable option in schema): all four layers + final + comments
    required_score_keys = [
        'layer1_base_rate', 'layer2_sellability', 'layer3_behavioral_trigger',
        'layer4_market_pull', 'final_score',
    ]
    for k in required_score_keys:
        if score[k] is None:
            return None, None

    return business, score


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


def build_batch_sql(businesses, scores):
    """Build one SQL string that inserts a batch of businesses + their scores."""
    if not businesses:
        return ''
    parts = []
    # businesses
    biz_vals = []
    for b in businesses:
        row = '(' + ','.join(sql_escape(b[c]) for c in BUSINESS_COLS) + ')'
        biz_vals.append(row)
    parts.append(
        'INSERT INTO offmarket.businesses (' + ','.join(BUSINESS_COLS) + ')\nVALUES\n  '
        + ',\n  '.join(biz_vals) + ';'
    )
    # scores
    score_vals = []
    for s in scores:
        row = '(' + ','.join(sql_escape(s[c]) for c in SCORE_COLS) + ')'
        score_vals.append(row)
    parts.append(
        'INSERT INTO offmarket.business_scores (' + ','.join(SCORE_COLS) + ')\nVALUES\n  '
        + ',\n  '.join(score_vals) + ';'
    )
    return 'BEGIN;\n' + '\n'.join(parts) + '\nCOMMIT;\n'


def main():
    summary = {
        'per_vertical': {},
        'total_businesses_inserted': 0,
        'total_scores_inserted': 0,
        'errors': [],
    }

    out_dir = DATA_DIR / '_wave7_sql'
    out_dir.mkdir(exist_ok=True)

    BATCH_SIZE = 20

    for fname, default_run_id in FILES:
        fpath = DATA_DIR / fname
        with open(fpath) as fh:
            records = json.load(fh)
        if isinstance(records, dict):
            # find the list inside
            for v in records.values():
                if isinstance(v, list):
                    records = v
                    break

        vertical = fname.replace('_targets.json', '')
        skipped = 0
        normalized_biz = []
        normalized_score = []
        for rec in records:
            b, s = normalize_record(rec, default_run_id)
            if b is None or s is None:
                skipped += 1
                continue
            normalized_biz.append(b)
            normalized_score.append(s)

        # Write batched SQL files
        batch_files = []
        for i in range(0, len(normalized_biz), BATCH_SIZE):
            batch_biz = normalized_biz[i:i + BATCH_SIZE]
            batch_score = normalized_score[i:i + BATCH_SIZE]
            sql = build_batch_sql(batch_biz, batch_score)
            out_path = out_dir / f'{vertical}_batch_{i // BATCH_SIZE:03d}.sql'
            out_path.write_text(sql)
            batch_files.append(str(out_path))

        summary['per_vertical'][vertical] = {
            'records_in_file': len(records),
            'normalized': len(normalized_biz),
            'skipped': skipped,
            'batches': len(batch_files),
            'run_id': default_run_id,
        }
        print(f'{vertical}: records={len(records)} normalized={len(normalized_biz)} '
              f'skipped={skipped} batches={len(batch_files)}')

    print()
    print(json.dumps(summary, indent=2))
    (DATA_DIR / '_wave7_normalize_summary.json').write_text(json.dumps(summary, indent=2))


if __name__ == '__main__':
    main()
