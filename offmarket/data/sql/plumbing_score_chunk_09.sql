INSERT INTO offmarket.business_scores (
  business_id, score_run_id, layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment, layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment, final_score, final_tier, final_comment,
  value_add_thesis, confidence, data_completeness
) VALUES (
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='MAG PLUMBING AND SERVICES' AND city='San Marcos' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  60, 'Robert Rocha M-38328 since 2007.',
  50, 'San Marcos Hays exurban Austin.',
  50, 'No website.',
  75, 'Hays exurban -5.',
  57, 'C_watch',
  'MAG Plumbing — 18-yr San Marcos. C_watch.', 'N/A — exurban.',
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
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='PAISLEY PLUMBING' AND city='Wimberley' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  60, 'Daniel Mattingly M-37469 since 2005.',
  50, 'Wimberley Hays exurban.',
  50, 'No website.',
  70, 'Hays exurban -5.',
  56, 'C_watch',
  'Paisley Plumbing — Wimberley exurban. C_watch.', 'N/A — exurban.',
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
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='Lister Plumbing' AND city='Galveston' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  70, 'Lister 3-gen since 1984.',
  70, 'Galveston + HVAC.',
  45, 'Successor check NEGATIVE: 3-gen.',
  70, 'Galveston secondary -3.',
  62, 'B_forward',
  'Lister Plumbing — 3-gen Galveston. B_forward.', 'Forward.',
  'medium', 0.5
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
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='Kona Plumbing' AND city='Galveston' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  50, 'Kona Plumbing 20+ yrs.',
  50, 'Galveston small.',
  50, 'Mid.',
  70, 'Galveston secondary -3.',
  53, 'C_watch',
  'Kona Plumbing — small Galveston. C_watch.', 'N/A — secondary metro.',
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
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='Beaumont Plumbing LLC' AND city='Beaumont' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  45, 'Damian Diaz 20+ yrs.',
  50, 'Beaumont Jefferson — secondary -5.',
  50, 'Mid.',
  60, 'Beaumont secondary -5.',
  50, 'C_watch',
  'Beaumont Plumbing — Beaumont secondary. C_watch.', 'N/A — secondary metro + young.',
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
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='Ballard Plumbing' AND city='Beaumont' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  50, 'Ballard Plumbing.',
  50, 'Beaumont small.',
  50, 'Mid.',
  60, 'Beaumont secondary -5.',
  52, 'C_watch',
  'Ballard Plumbing — Beaumont. C_watch — thin.', 'N/A — secondary.',
  'low', 0.25
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
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='DEWolfe''s Affordable Plumbing' AND city='Plano' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  50, 'DeWolfe''s Plano. Unverified.',
  50, 'Small Plano.',
  50, 'No website.',
  88, 'Collin rollup hot.',
  56, 'C_watch',
  'DeWolfe''s Affordable Plumbing — Plano, no website, unverified. C_watch.', 'N/A — thin.',
  'low', 0.25
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
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='Best Quality Plumbing' AND city='Plano' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  55, 'Best Quality Plano. Senior MP 25 yrs.',
  55, 'Plano small.',
  50, 'Mid.',
  88, 'Collin rollup hot.',
  58, 'C_watch',
  'Best Quality Plumbing — Plano family. B_forward.', 'Plano Collin family. Forward.',
  'low', 0.35
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
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='S & B Plumbing' AND city='Sugar Land' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  75, 'William K Edmunds RMP M-16885 since 1988 = 37+ yrs MP tenure, age ~70. 3-gen MPs.',
  80, '50-yr operation since 1976. Sugar Land Greater Houston. Value Plan membership. Online scheduling. ≈ $1.5-3M rev.',
  40, 'Successor check NEGATIVE: 3-gen Edmunds family MPs. Modernized intake.',
  85, 'Houston rollup hot. Sugar Land Fort Bend = ordinary baseline.',
  67, 'B_forward',
  'S & B Plumbing — 3-gen Edmunds family Sugar Land. B_forward.', 'Long-tenured Sugar Land family plumbing. Forward to ETA / PE bolt-on.',
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
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='BARTSCH SERVICES INC' AND city='The Woodlands' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  55, 'Jeffery Bartsch M-37279 since 2005.',
  60, 'The Woodlands Montgomery.',
  50, 'No website.',
  85, 'Houston rollup hot.',
  59, 'C_watch',
  'Bartsch Services — 20-yr Woodlands MP. C_watch.', 'N/A — thin.',
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