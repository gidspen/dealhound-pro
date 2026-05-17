INSERT INTO offmarket.business_scores (
  business_id, score_run_id, layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment, layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment, final_score, final_tier, final_comment,
  value_add_thesis, confidence, data_completeness
) VALUES (
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='Beyer Plumbing Services' AND city='San Antonio' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  50, 'Beyer Plumbing since 1990. Owner age likely 50-65.',
  88, 'Large SA + 30+ cities. Plumbing Plan recurring.',
  35, 'Modernized intake.',
  88, 'SA rollup hot.',
  61, 'B_forward',
  'Beyer Plumbing — 36-yr large SA family operation. Mid-large platform-acquirer target. B_forward.', 'Large SA multi-area. Forward to PE/ETA.',
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
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='Anchor Plumbing Services' AND city='San Antonio' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  40, 'Anchor Plumbing since 2016.',
  75, 'SA mid. Membership $19.95/mo.',
  35, 'Modernized = low coasting.',
  85, 'SA rollup hot.',
  54, 'C_watch',
  'Anchor Plumbing — 10-yr SA, modernized, owner too young. D_pass (under 5-yr-band/10-yr-young).', 'N/A — too young.',
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
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='Chavarria''s Plumbing of SA, Inc.' AND city='San Antonio' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  50, 'Chavarria Fernando Jr (2nd-gen from father''s Laredo biz 1981).',
  60, 'SA Stone Oak.',
  50, 'Successor check unclear but he is 2nd-gen.',
  85, 'SA rollup hot.',
  58, 'C_watch',
  'Chavarria''s Plumbing — Fernando Jr 2nd-gen Stone Oak SA. B_forward.', 'Forward.',
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
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='American Auger Plumbing' AND city='San Antonio' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  50, 'American Auger 30+ yrs combined experience.',
  65, 'SA Bexar.',
  50, 'Jobber online + BBB cert = modernized.',
  85, 'SA rollup hot.',
  59, 'C_watch',
  'American Auger Plumbing — SA Bexar family. B_forward.', 'Forward.',
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
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='S&S Plumbing' AND city='San Antonio' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  45, 'Steven Stanush M-36596.',
  60, 'SA. 20 yrs.',
  50, 'Mid.',
  85, 'SA rollup hot.',
  56, 'C_watch',
  'S&S Plumbing — 20-yr SA MP. C_watch.', 'N/A — too young.',
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
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='J.C. Enriquez and Son Plumbing' AND city='San Antonio' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  75, 'Joe Enriquez Sr (founder 1968) ~age 78. Joe Jr. + Joe III also active.',
  80, '58-yr SA operation, multi-trade plumbing + HVAC + remodeling + water restoration, Maintenance Plan recurring, San Antonio 78249.',
  40, 'Successor check NEGATIVE: 3-gen Enriquez explicit (Sr + Jr + III). Strong family succession. Not coasting-solo.',
  85, 'San Antonio rollup hot. ',
  67, 'B_forward',
  'J.C. Enriquez and Son — 3-gen Enriquez family operation since 1968. B_forward.', 'Long-tenured SA multi-trade with active maintenance plan. Forward to ETA/PE bolt-on community.',
  'high', 0.75
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
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='210 Plumbing' AND city='San Antonio' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  80, 'Russell Walker owner since 1977. Steve Walker brother MP. Russell age ~75.',
  60, '49-yr SA shop, small-mid scale 3-5 trucks, drain camera + water softeners + leak detection. ≈ $700K-1.5M rev.',
  50, 'Mixed: extensive Walker family in business (brother Steve, sister Jacquelyn, daughter Brandi as apprentice) = INTERNAL SUCCESSION IN PLACE (daughter on plumber track). No online booking + no membership = strong coasting tells but offset by family-succession.',
  80, 'San Antonio rollup hot.',
  66, 'B_forward',
  '210 Plumbing — Walker family multi-gen (Russell + brother Steve + sister Jacquelyn + daughter Brandi as apprentice). Strong coasting tells (no online booking, no membership, phone-only) but family succession via daughter. B_forward.', 'SA multi-gen Walker family plumbing with thin tech stack. Forward to ETA/PE bolt-on community.',
  'high', 0.7
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
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='Will''s Plumbing & Testing Service' AND city='San Antonio' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  50, 'Will''s Plumbing 24/7.',
  70, 'SA + backflow recurring.',
  50, 'Mid.',
  85, 'SA rollup hot.',
  60, 'B_forward',
  'Will''s Plumbing & Testing — SA backflow recurring. B_forward.', 'SA family backflow. Forward.',
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
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='Juan''s Plumbing Services' AND city='San Antonio' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  50, 'Juan Lopez SA.',
  50, 'Small.',
  50, 'Small + no website verified.',
  80, 'SA baseline.',
  54, 'C_watch',
  'Juan''s Plumbing — small SA RMP. C_watch.', 'N/A — too small.',
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
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='J.R.''s Plumbing' AND city='San Antonio' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  70, 'JR''s Plumbing 1980 woman-owned. Owner age 60+.',
  60, 'SA + Boerne small-mid.',
  60, 'Strong coasting tells: no membership, no online booking, phone-only intake — 46 yrs of inertia.',
  80, 'SA rollup hot.',
  66, 'B_forward',
  'JR''s Plumbing — 46-yr SA woman-owned family. Strong coasting tells. B_forward — promote to A pending Bexar CAD OV65 + live team page.', 'Long-tenured SA woman-owned with thin web = strong AI/ops thesis.',
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