INSERT INTO offmarket.business_scores (
  business_id, score_run_id, layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment, layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment, final_score, final_tier, final_comment,
  value_add_thesis, confidence, data_completeness
) VALUES (
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='PAZ PLUMBING' AND city='South Houston' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  75, 'Jorge De Paz MP since 1993.',
  55, 'South Houston small shop.',
  50, 'No website found. Cap confidence.',
  75, 'Houston baseline.',
  62, 'B_forward',
  'Paz Plumbing — 32-yr South Houston shop, no website. C_watch.', 'N/A — thin data.',
  'low', 0.3
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate, layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability, layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger, layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull, layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score, final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment, value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence, data_completeness = EXCLUDED.data_completeness;

INSERT INTO offmarket.business_scores (
  business_id, score_run_id, layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment, layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment, final_score, final_tier, final_comment,
  value_add_thesis, confidence, data_completeness
) VALUES (
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='W MCLAIN PLUMBING LLC' AND city='Pasadena' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  80, 'W McLain MP M-9313 legacy pre-1990.',
  55, 'Pasadena Houston metro older housing.',
  50, 'No website. Strong age proxy but cap confidence.',
  75, 'Houston baseline + Pasadena older housing +3.',
  64, 'B_forward',
  'W McLain Plumbing — legacy MP, Pasadena older housing. C_watch — no website caps to C tier.', 'N/A — thin data.',
  'low', 0.3
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate, layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability, layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger, layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull, layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score, final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment, value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence, data_completeness = EXCLUDED.data_completeness;

INSERT INTO offmarket.business_scores (
  business_id, score_run_id, layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment, layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment, final_score, final_tier, final_comment,
  value_add_thesis, confidence, data_completeness
) VALUES (
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='THIRD COAST PLUMBING SERVICES LLC' AND city='Pasadena' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  75, 'Gregorio Martinez MP M-15152 since 1985.',
  55, 'Pasadena older Houston metro.',
  50, 'No website. Cap confidence.',
  75, 'Houston baseline + Pasadena +3.',
  62, 'B_forward',
  'Third Coast Plumbing — long-tenured Pasadena MP. C_watch.', 'N/A — thin data.',
  'low', 0.3
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate, layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability, layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger, layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull, layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score, final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment, value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence, data_completeness = EXCLUDED.data_completeness;

INSERT INTO offmarket.business_scores (
  business_id, score_run_id, layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment, layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment, final_score, final_tier, final_comment,
  value_add_thesis, confidence, data_completeness
) VALUES (
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='W ELAM PLUMBING COMPANY' AND city='Houston' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  75, 'Wesley Elam MP pre-1990 legacy.',
  60, 'South Houston small shop.',
  40, 'Successor check NEGATIVE: paired with Elam Plumbing Company (Mack A Elam) = multi-Elam family.',
  75, 'Houston baseline.',
  61, 'B_forward',
  'W Elam Plumbing — multi-Elam family. B_forward / D — thin.', 'Multi-Elam family Houston. Forward.',
  'low', 0.3
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate, layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability, layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger, layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull, layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score, final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment, value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence, data_completeness = EXCLUDED.data_completeness;

INSERT INTO offmarket.business_scores (
  business_id, score_run_id, layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment, layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment, final_score, final_tier, final_comment,
  value_add_thesis, confidence, data_completeness
) VALUES (
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='ELAM PLUMBING COMPANY' AND city='Houston' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  80, 'Mack A Elam MP M-5233 legacy pre-1990.',
  60, 'South Houston small.',
  40, 'Multi-Elam family.',
  75, 'Houston baseline.',
  62, 'B_forward',
  'Elam Plumbing — Mack A Elam legacy. Multi-Elam family. B_forward / D — thin.', 'Forward.',
  'low', 0.3
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate, layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability, layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger, layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull, layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score, final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment, value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence, data_completeness = EXCLUDED.data_completeness;

INSERT INTO offmarket.business_scores (
  business_id, score_run_id, layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment, layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment, final_score, final_tier, final_comment,
  value_add_thesis, confidence, data_completeness
) VALUES (
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='FRANCIS PLUMBING AND UTILITY' AND city='Houston' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  75, 'David Francis MP legacy pre-1990.',
  55, 'Fort Bend small.',
  45, 'No website.',
  75, 'Fort Bend Houston metro baseline.',
  61, 'B_forward',
  'Francis Plumbing & Utility — long-tenured Fort Bend MP. C_watch — thin data.', 'N/A — thin.',
  'low', 0.3
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate, layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability, layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger, layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull, layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score, final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment, value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence, data_completeness = EXCLUDED.data_completeness;

INSERT INTO offmarket.business_scores (
  business_id, score_run_id, layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment, layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment, final_score, final_tier, final_comment,
  value_add_thesis, confidence, data_completeness
) VALUES (
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='Dallas Plumbing Company' AND city='Dallas' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  65, 'Dallas Plumbing Company 4th-gen ownership over 123-yr history (founded 1903). Current owner age likely 50-70.',
  90, 'Excellent: 123-yr operation (TX''s oldest), multi-trade plumbing + AC, very large platform-scale shop. ≈ $10M+ rev.',
  45, 'Successor check NEGATIVE: explicit 4-gen family succession. Not coasting-solo profile.',
  92, 'Dallas rollup very hot.',
  69, 'B_forward',
  'Dallas Plumbing Company, 123-yr operation, 4-gen family. Already platform-scale ($10M+ rev). Not off-market thesis target. B_forward at best — likely already on Apex/Wrench radar, may already have informal LOIs.', 'Platform-scale Dallas multi-trade. NOT off-market thesis target — Forward to ETA community only as awareness.',
  'low', 0.5
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate, layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability, layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger, layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull, layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score, final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment, value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence, data_completeness = EXCLUDED.data_completeness;

INSERT INTO offmarket.business_scores (
  business_id, score_run_id, layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment, layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment, final_score, final_tier, final_comment,
  value_add_thesis, confidence, data_completeness
) VALUES (
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='Public Service Plumbers, Inc.' AND city='Dallas' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  72, 'Public Service Plumbers 3rd-gen DiFrancesco MP since 1981 = age ~65-70.',
  90, 'Excellent: 67-yr operation, multi-trade plumbing + drain/sewer + AC + heating + electrical + generator, Shield Membership $14.95/mo active recurring revenue, Dallas Lakewood/Lower Greenville 75206.',
  48, 'Successor check NEGATIVE: 3rd-gen DiFrancesco explicit. Shield Membership active. Not coasting-solo profile.',
  92, 'Dallas rollup very hot + premium Lakewood/Lower Greenville submarket nudge +3.',
  72, 'B_forward',
  'Public Service Plumbers, 67-yr 3rd-gen DiFrancesco family, $5-10M revenue, multi-trade with active Shield Membership program. Premium Dallas submarket. B_forward — premium platform-acquirer bolt-on for Wrench/Apex/Service Champions.', 'Premium Dallas multi-trade with strong recurring revenue book + 67 yrs brand equity. Forward to Apex / Wrench / Service Champions platforms as $8-15M bolt-on target.',
  'medium', 0.65
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate, layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability, layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger, layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull, layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score, final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment, value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence, data_completeness = EXCLUDED.data_completeness;

INSERT INTO offmarket.business_scores (
  business_id, score_run_id, layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment, layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment, final_score, final_tier, final_comment,
  value_add_thesis, confidence, data_completeness
) VALUES (
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='Cody & Sons Plumbing, Heating & Air' AND city='Dallas' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  68, 'Cody & Sons founded 1969 by Bill+Shirley Cody + 3 sons. Currently operating with ''sons'' generation.',
  85, '57-yr operation, multi-trade plumbing + heating + AC + generators + indoor air quality + duct cleaning. MVP membership. Online estimate booking.',
  45, 'Successor check NEGATIVE: ''and Sons'' in name = explicit succession. Modernized (MVP plan + online).',
  88, 'Dallas/Plano hot rollup. ',
  68, 'B_forward',
  'Cody & Sons Plumbing — 57-yr ''and Sons'' explicit succession family operation. B_forward bolt-on for Wrench/Apex platforms.', 'Multi-trade Dallas/Plano with active MVP membership + multi-gen family. Forward to ETA / Wrench / Apex as bolt-on.',
  'medium', 0.6
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate, layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability, layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger, layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull, layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score, final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment, value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence, data_completeness = EXCLUDED.data_completeness;

INSERT INTO offmarket.business_scores (
  business_id, score_run_id, layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment, layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment, final_score, final_tier, final_comment,
  value_add_thesis, confidence, data_completeness
) VALUES (
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='Reeves Family Plumbing' AND city='Dallas' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  60, 'Reeves Family Plumbing 1960 + woman-owned HUB.',
  70, 'Dallas mid-shop.',
  50, 'BOOK ONLINE + ''Family'' brand. Mid coasting.',
  88, 'Dallas rollup hot.',
  64, 'B_forward',
  'Reeves Family Plumbing — 66-yr, woman-owned. B_forward.', 'Mid-shop Dallas family. Forward.',
  'low', 0.4
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate, layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability, layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger, layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull, layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score, final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment, value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence, data_completeness = EXCLUDED.data_completeness;