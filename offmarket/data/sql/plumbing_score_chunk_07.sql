INSERT INTO offmarket.business_scores (
  business_id, score_run_id, layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment, layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment, final_score, final_tier, final_comment,
  value_add_thesis, confidence, data_completeness
) VALUES (
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='HERNANDEZ PLUMBING & SEWER INC' AND city='San Antonio' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  55, 'Antonio Hernandez M-39327 since 2009 + MEDGAS/MRF.',
  60, 'SA west — COMMERCIAL NEW CONSTRUCTION focus per BuildZoom (628 permitted projects, retail/restaurant/office/hotel/municipal). FILTER: pure new-construction excluded per skill rules.',
  50, 'N/A — filtered.',
  85, 'SA rollup hot.',
  59, 'C_watch',
  'Hernandez Plumbing & Sewer — pure commercial new-construction focus per BuildZoom (628 commercial permits). EXCLUDE per filter. D_pass.', 'N/A — filtered out (pure new construction).',
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
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='ALAMO PLUMBING A/C & HEAT LLC' AND city='San Antonio' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  65, 'Samuel Longoria M-36584 since 2003.',
  75, 'Multi-trade plumbing+AC+heat, SA NW 78253.',
  50, 'BuildZoom top 8% but no team detail.',
  88, 'SA rollup hot.',
  66, 'B_forward',
  'Alamo Plumbing AC & Heat — Longoria 22-yr SA multi-trade. B_forward.', 'Forward.',
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
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='RUTKOWSKI PLUMBING' AND city='Helotes' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  80, 'Carl Rutkowski M-16201 since 1986 + 2 sons Matt + Luke.',
  65, 'Helotes premium NW Bexar.',
  50, 'Successor check NEGATIVE: 2 sons including Luke as plumber.',
  88, 'SA rollup hot + Helotes premium +3.',
  68, 'B_forward',
  'Rutkowski Plumbing — Carl 39-yr + sons. B_forward.', 'Helotes SA premium family. Forward.',
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
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='J & M PLUMBING (J & M ORTIZ INC DBA)' AND city='San Antonio' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  75, 'Jesse Ortiz M-18468 since 1993.',
  60, 'SA south 78224.',
  50, 'No website. Cap.',
  80, 'SA baseline.',
  64, 'B_forward',
  'J&M Plumbing (Ortiz) — 32-yr SA MP, no website. C_watch.', 'N/A — thin.',
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
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='CAROLINA''S PLUMBING SERVICES' AND city='San Antonio' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  35, 'Carolina Martinez M-42230 since 2017 (8 yrs). Too young.',
  50, 'Hard gate: 8 yrs near boundary; depth thin.',
  35, 'Mid.',
  80, 'SA baseline.',
  46, 'C_watch',
  'Carolina''s Plumbing — 8-yr SA MP, owner too young. D_pass (5-yr-gate marginal, age too young).', 'N/A — too young.',
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
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='SWINGING D CONSTRUCTION LLC' AND city='San Antonio' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  60, 'Patrick Dennis M-37493 since 2005.',
  55, 'SA premium 78261 Stone Oak edge.',
  50, 'Construction-leaning — verify residential mix.',
  88, 'SA rollup hot + premium +3.',
  60, 'B_forward',
  'Swinging D Construction — 20-yr SA premium. C_watch — construction-leaning needs filter check.', 'N/A — borderline.',
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
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='Austin Plumbing, Heating, Air & Electric' AND city='Austin' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  75, 'Austin Plumbing (Team Austin) 3rd-gen Smith. Eric Smith President. Son Austin already on team.',
  88, '92-yr operation, multi-trade plumbing + HVAC + electric + water well + air duct + water conditioning. Very large. ≈ $5-15M rev. Platform-scale.',
  35, 'Successor check NEGATIVE: 3rd-gen Smith with son Austin already in role. Explicit succession.',
  92, 'Austin rollup very hot.',
  69, 'B_forward',
  'Team Austin — 92-yr 3-gen Smith multi-trade Austin platform-scale. Not off-market thesis target. B_forward at best — likely already on Apex/Wrench radar.', 'Platform-scale Austin multi-trade. Forward to ETA community as awareness only.',
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
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='Johnny Rooter Plumbing' AND city='Austin' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  60, 'Johnny Rooter 2nd-gen Austin since 1993. CAUTION: ''Rooter'' name — needs Roto-Rooter franchise verification.',
  60, 'Austin.',
  50, 'Successor check NEGATIVE (2nd-gen).',
  90, 'Austin rollup very hot.',
  62, 'B_forward',
  'Johnny Rooter — 2nd-gen Austin. NEEDS Roto-Rooter franchise filter verification. B_forward.', 'Forward — verify franchise status first.',
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

INSERT INTO offmarket.business_scores (
  business_id, score_run_id, layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment, layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment, final_score, final_tier, final_comment,
  value_add_thesis, confidence, data_completeness
) VALUES (
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='Mustang Plumbing' AND city='Round Rock' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  75, 'Todd Cox MP since 1983 (youngest MP in TX history at 18-22) = age 61-65. Sons in business (TX State University grads).',
  70, '27-yr Round Rock operation. Residential + new construction + commercial. Schedule a Call form.',
  50, 'Successor check NEGATIVE: 2 sons in business (mgmt + construction science backgrounds). Family succession path explicit.',
  80, 'Austin/Round Rock rollup very hot. ',
  67, 'B_forward',
  'Mustang Plumbing — Todd Cox + 2 sons family operation. B_forward.', 'Round Rock multi-gen plumbing with sons in management track. Forward to ETA/Apex bolt-on.',
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
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='The Plumbinator' AND city='Round Rock' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  45, 'Plumbinator 2009. Husband+wife.',
  60, 'Round Rock small.',
  50, 'Mid.',
  90, 'Austin/Round Rock rollup very hot.',
  57, 'C_watch',
  'The Plumbinator — small Round Rock husband+wife operation. C_watch.', 'N/A — too small + young.',
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