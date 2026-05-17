INSERT INTO offmarket.business_scores (
  business_id, score_run_id, layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment, layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment, final_score, final_tier, final_comment,
  value_add_thesis, confidence, data_completeness
) VALUES (
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='Baker Brothers Plumbing, Air & Electric' AND city='Dallas' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  0, 'Platform-excluded.',
  0, 'Platform-excluded.',
  0, 'Platform-excluded.',
  0, 'Platform-excluded.',
  25, 'D_pass',
  'Baker Brothers Plumbing — Wrench Group infrastructure detected on website CDN (wg.scene7.com image paths). EXCLUDE as PE platform-owned per filter rules.', 'N/A — platform-excluded.',
  'high', 0.5
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
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='My Local Plumber' AND city='Farmers Branch' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  55, '25+ yrs.',
  65, 'Farmers Branch N Dallas mid.',
  50, 'Some coasting tells.',
  85, 'Dallas rollup hot.',
  60, 'B_forward',
  'My Local Plumber — 25-yr Farmers Branch family. B_forward.', 'Mid-shop Dallas family. Forward.',
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

INSERT INTO offmarket.business_scores (
  business_id, score_run_id, layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment, layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment, final_score, final_tier, final_comment,
  value_add_thesis, confidence, data_completeness
) VALUES (
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='Watermark Plumbing' AND city='Carrollton' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  50, 'Watermark Plumbing since 2005.',
  65, 'Carrollton small-mid.',
  45, 'Mid.',
  85, 'Dallas rollup hot.',
  58, 'C_watch',
  'Watermark Plumbing — 21-yr Carrollton. C_watch.', 'N/A — too young.',
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

INSERT INTO offmarket.business_scores (
  business_id, score_run_id, layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment, layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment, final_score, final_tier, final_comment,
  value_add_thesis, confidence, data_completeness
) VALUES (
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='Burton''s Mechanical, Inc.' AND city='Dallas' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  45, 'Burton''s Mechanical since 2008.',
  50, 'Commercial construction focus — partial exclusion candidate.',
  35, 'Mid.',
  70, 'Dallas baseline.',
  47, 'C_watch',
  'Burton''s Mechanical — commercial construction focus, less residential service. C_watch / borderline-exclude.', 'N/A.',
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

INSERT INTO offmarket.business_scores (
  business_id, score_run_id, layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment, layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment, final_score, final_tier, final_comment,
  value_add_thesis, confidence, data_completeness
) VALUES (
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='Barbosa Plumbing & Air Conditioning' AND city='Carrollton' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  60, 'Barbosa Mechanical 46+ yrs.',
  65, 'Carrollton/Farmers Branch.',
  50, 'Mid.',
  85, 'Dallas rollup hot.',
  62, 'B_forward',
  'Barbosa Plumbing — 46-yr Carrollton/Farmers Branch. B_forward — needs deeper verification.', 'Long-tenured Dallas family. Forward.',
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
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='Legacy Plumbing' AND city='Frisco' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  45, 'Theron Young M-37588 (~2005) = age 50-60.',
  80, 'Legacy Gold Plan + 2 locations + online booking.',
  40, 'Modernized = low coasting.',
  90, 'Dallas/Frisco rollup very hot.',
  59, 'C_watch',
  'Legacy Plumbing — too young + modernized. C_watch.', 'N/A — owner not retirement-window.',
  'medium', 0.55
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
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='Hackler Plumbing' AND city='McKinney' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  45, 'Brad Hackler M-39169 (~2010).',
  65, 'McKinney small-mid.',
  50, 'Mid.',
  88, 'Collin County rollup hot.',
  58, 'C_watch',
  'Hackler Plumbing — owner too young. C_watch.', 'N/A.',
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
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='Smith and Son Plumbing and Backflow' AND city='McKinney' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  78, 'Smith and Son Plumbing 3rd-gen since 1970.',
  80, 'McKinney + backflow recurring revenue.',
  40, 'Successor check NEGATIVE: 3rd-gen.',
  90, 'Collin rollup hot.',
  69, 'B_forward',
  'Smith and Son — 3-gen McKinney. B_forward.', 'McKinney multi-gen + backflow recurring. Forward.',
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
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='O''Bryan Plumbing Services' AND city='Allen' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  55, 'William O''Bryan 2nd-gen.',
  75, 'Allen + Plano 2 locations, O''Bryan Family Plan, online booking.',
  40, 'Modernized = low coasting.',
  90, 'Collin rollup hot.',
  61, 'B_forward',
  'O''Bryan Plumbing — 2nd-gen William, modernized. B_forward.', 'Allen/Plano family. Forward.',
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
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='Kenny Bunch Plumbing' AND city='Wylie' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  65, 'Kenny Bunch 25 yrs.',
  65, 'Wylie/Plano.',
  50, 'No membership, no online booking — mid coasting.',
  88, 'Collin/Dallas rollup hot.',
  64, 'B_forward',
  'Kenny Bunch Plumbing — 25-yr Wylie. B_forward.', 'N Dallas Collin small-mid. Forward.',
  'low', 0.45
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate, layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability, layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger, layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull, layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score, final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment, value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence, data_completeness = EXCLUDED.data_completeness;