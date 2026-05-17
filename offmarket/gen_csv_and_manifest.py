"""Generate the flattened CSV + run_manifest.json from roofing_targets.json."""

import json
import csv

CWD = '/Users/gideonspencer/dealhound-pro/.claude/worktrees/crazy-khayyam-7adaed'

with open(f'{CWD}/offmarket/data/roofing_targets.json') as f:
    out = json.load(f)

targets = out['businesses']

# 32-col CSV
cols = [
    'legal_name', 'dba_name', 'city', 'county', 'zip', 'address', 'phone', 'website',
    'owner_name', 'owner_age_estimate', 'owner_age_source', 'owner_tenure_years',
    'years_in_business', 'provider_count_estimate', 'employee_count_estimate',
    'is_distressed', 'distress_reasons',
    'layer1_base_rate', 'layer1_comment', 'layer2_sellability', 'layer2_comment',
    'layer3_behavioral_trigger', 'layer3_comment', 'layer4_market_pull', 'layer4_comment',
    'final_score', 'final_tier', 'final_comment', 'value_add_thesis',
    'confidence', 'data_completeness',
]

with open(f'{CWD}/offmarket/data/roofing_targets.csv', 'w', newline='') as f:
    w = csv.writer(f, quoting=csv.QUOTE_MINIMAL)
    w.writerow(cols)
    for t in targets:
        row = []
        for c in cols:
            v = t.get(c)
            if isinstance(v, list): v = ';'.join(str(x) for x in v)
            row.append('' if v is None else str(v))
        w.writerow(row)
print(f'Wrote CSV: {len(targets)} rows.')

# Run manifest
from collections import Counter
tc = Counter(t['final_tier'] for t in targets)
counties = Counter(t['county'] for t in targets)

manifest = {
    'run_label': 'roofing-tx-2026-05-15',
    'score_run_id': 'ae0694e6-a997-4b9a-96b2-10cc75ca1d4b',
    'model_version': 'offmarket-4layer-v0.2',
    'weights': {'layer1': 0.30, 'layer2': 0.25, 'layer3': 0.30, 'layer4': 0.15},
    'vertical': 'roofing',
    'geography': 'TX — Harris/Dallas/Tarrant/Bexar/Travis/Collin/Denton priority, hail-corridor + coastal',
    'started_at': '2026-05-15T22:00:00Z',
    'finished_at': out['score_run']['finished_at'],
    'counts': {
        'spine_rows': 106,
        'enriched_with_live_fetch': 28,
        'scored': len(targets),
        'tier_a': tc['A_acquire_self'],
        'tier_b': tc['B_forward'],
        'tier_c': tc['C_watch'],
        'tier_d': tc['D_pass'],
        'distress_excluded': 0,
    },
    'county_distribution': dict(counties.most_common()),
    'sources_worked': [
        {'source': 'WebSearch (Google)', 'rows': 106, 'note': 'primary spine assembly via city-by-city searches'},
        {'source': 'company_websites', 'rows': 28, 'note': 'direct fetches on top-priority candidates'},
        {'source': 'manufacturer_directories', 'rows': 12, 'note': 'GAF Master Elite, CertainTeed SELECT, OC Platinum cross-checks'},
        {'source': 'BBB_profiles', 'rows': 8, 'note': 'cross-check on current ownership/president via BBB business profiles'},
        {'source': 'LinkedIn', 'rows': 5, 'note': 'leadership name verification + tenure cross-check'},
        {'source': 'D&B + ZoomInfo', 'rows': 3, 'note': 'D&B + ZoomInfo company profile cross-checks for entity status proxy'},
        {'source': 'D CEO Magazine + Texas HR Resolution', 'rows': 2, 'note': 'Catherine Awtrey + Gill Roofing recognition'},
    ],
    'sources_partial': [
        {'source': 'RCAT Member Directory', 'url': 'https://web.rcat.net/search', 'issue': 'JS-driven search-only UI; WebFetch cannot drive', 'fallback_used': 'WebSearch + manufacturer directories + city-by-city Google + BBB'},
    ],
    'sources_blocked': [
        {'source': 'TX Comptroller Taxable Entity Search', 'url': 'https://mycpa.cpa.state.tx.us/coa/', 'error': 'interactive POST form; WebFetch cannot drive', 'fallback_used': 'entity_status set to "unknown" — required for Phase 6 follow-up via Playwright'},
        {'source': 'CAD homestead OV65 lookups (HCAD/DCAD/BCAD/TCAD/Nueces CAD)', 'error': 'interactive form-based searches blocked from WebFetch', 'fallback_used': 'license_tenure_proxy + owner self-report + WebSearch press recognition'},
        {'source': 'Wayback Machine snapshot diff', 'error': 'WebFetch timeouts on web.archive.org this session', 'fallback_used': 'live homepage fetch only'},
        {'source': 'TX no-state-roofing-license', 'error': 'structural — no license board to enumerate operators', 'fallback_used': 'RCAT + manufacturer cert directories + BBB'},
    ],
    'a_tier_deep_dive': {
        'candidates_evaluated': 5,
        'passed': 2,
        'demoted_to_b': 2,
        'demoted_to_d_distress_surfaced': 0,
        'deferred_pending_live_fetch': 1,
        'demotion_reasons': {
            'non_family_operator_recent_or_in_law': 2,
            'team_page_unreachable': 1,
            'owner_age_proxy_only': 0,
            'successor_found_on_live_site': 0,
            'comptroller_forfeited': 0,
            'disciplinary_action_surfaced': 0,
            'lien_or_judgment_surfaced': 0,
            'metro_pull_recomputed_down': 0,
            'value_add_thesis_too_generic': 0,
        }
    },
    'enrichment_telemetry': {
        'successor_check_positive_live_fetch': 5,  # Texas Roof Mgmt, Mataska (later demoted), Cloud (later demoted via search), Braun's, Marlin
        'successor_check_negative_live_fetch': 13,  # Yuras, Bert, Joe Hall, Rose, Arrington, Ja-Mar, Quality Tops, King of Texas, Andrus Brothers, Lon Smith, Brazos Comm, Smith & Sons, Burch
        'successor_check_ambiguous': 8,
        'successor_check_not_completed': 80,  # remaining spine rows where deep enrichment was not run
    },
    'supabase_write': {'status': 'pending_phase_6', 'reason': 'Phase 6 not yet run'},
}

with open(f'{CWD}/offmarket/data/roofing_run_manifest.json', 'w') as f:
    json.dump(manifest, f, indent=2)
print('Wrote run_manifest.json.')
print()
print('Tier counts:')
for k, v in tc.most_common():
    print(f'  {k}: {v}')
