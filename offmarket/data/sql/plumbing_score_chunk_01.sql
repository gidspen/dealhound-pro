INSERT INTO offmarket.business_scores (
  business_id, score_run_id, layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment, layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment, final_score, final_tier, final_comment,
  value_add_thesis, confidence, data_completeness
) VALUES (
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='Sunrise Mechanical Services' AND city='Houston' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  50, 'Unverified — no website found.',
  50, 'Unverified.',
  35, 'Unverified.',
  75, 'Houston baseline.',
  49, 'C_watch',
  'Sunrise Mechanical — no website verified, unverified. D_pass without verification.', 'N/A.',
  'low', 0.15
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
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='Tony''s Plumbing' AND city='Cypress' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  70, 'Tony''s Plumbing father-son team. 38+ yrs.',
  60, 'Cypress/Katy NW Houston small shop.',
  50, 'Successor check NEGATIVE: father-son team.',
  80, 'Houston rollup hot.',
  63, 'B_forward',
  'Tony''s Plumbing — father-son small shop. B_forward.', 'Small-shop NW Houston multi-gen. Forward.',
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
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='DeMarco Plumbing' AND city='Spring' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  50, 'Unverified.',
  50, 'Unverified.',
  45, 'Unverified.',
  75, 'TX baseline.',
  52, 'C_watch',
  'Unverified candidate. C_watch pending enrichment.', 'N/A — unverified.',
  'low', 0.2
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
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='All in The Family Plumbing' AND city='Tomball' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  60, 'RMPL 21138 mid-2000s — owner age ~50-60.',
  65, '8-city NW Houston service area.',
  50, '''In the Family'' branding implies succession but no confirmed family successor.',
  80, 'Houston rollup hot.',
  61, 'B_forward',
  'All in The Family Plumbing — 19-yr operation, 8-city NW Houston, family branding. C_watch / B_forward.', 'Mid-tenure NW Houston multi-city. Forward.',
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
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='Daniels Plumbing' AND city='Tomball' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  70, 'Daniels Plumbing 40 yrs.',
  65, 'NW Houston/Tomball shop.',
  55, 'Thin online presence.',
  80, 'Houston rollup hot.',
  66, 'B_forward',
  'Daniels Plumbing — 40 yrs Tomball/NW Houston. B_forward.', 'Long-tenured NW Houston small-mid shop. Forward.',
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
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='ABERLE PLUMBING LLC' AND city='Houston' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  68, 'Steve Aberle founder 1989 + Mark Aberle MP since 2000 (son).',
  75, '37-yr Houston shop.',
  45, 'Successor check NEGATIVE: Steve + Mark Aberle father-son.',
  80, 'Houston rollup hot.',
  65, 'B_forward',
  'Aberle Plumbing — Steve + Mark father-son. B_forward.', 'Long-tenured Houston family plumbing. Forward.',
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
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='JOHNS PLUMBING INC' AND city='Houston' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  80, 'John P. Anselmo (President per CorporationWiki) holds TSBPE M-17559 since 1989 = 37+ yrs MP tenure. Estimated age ~68 (MP''d 1989 at age ~30 = born ~1959). Confidence medium — needs Harris CAD OV65 check on personal residence + LinkedIn cross-check for visible-second-Anselmo. Solo-listed RMP.',
  65, '44-yr operation (since 1982). Single RMP + ''family-owned'' brand. Small-shop residential service. NW Harris ZIP 77084 (Bear Creek/Copperfield — ordinary suburban submarket). Estimated 2-4 trucks / 4-6 staff ≈ $500K-1.2M revenue band. Below platform-acquirer sweet spot but in SBA / ETA-searcher range. License clean.',
  85, 'EXTREME coasting tells: (a) johnsplumbing-houston.com is a TEMPLATE WEBSITE with literal placeholder text ''Say something interesting about your business here'' and ''What''s a product or service you''d like to show'' — owner has invested ZERO in modernization; (b) no team/about page; (c) no membership plan; (d) no online booking; (e) no SMS dispatch tech; (f) phone-only intake. 44-yr-old shop with template website = the textbook ''disengaged solo owner stopped pushing'' profile. 5 strong coasting tells stacked.',
  82, 'Houston is top-3 TX rollup metro. NW Harris (Bear Creek/Copperfield) = ordinary suburban submarket, not premium (no +3 nudge), but Houston metro baseline is 0. Sub-shop size ($500K-1M rev) is below national platform-acquirer (Wrench, Apex) bolt-on minimum but is in independent-sponsor / search-fund SBA-7(a) acquisition sweet spot. Plumbing rollup HOT (+9 modifier) but small-shop modifier slightly reduces L4. Score 82.',
  78, 'A_acquire_self',
  'John P. Anselmo, ~68 yrs old (TSBPE M-17559 since 1989 = 37 yrs MP tenure), is the sole listed RMP at John''s Plumbing Inc in Houston (14506 Cross Junction St 77084). 44-year-old family-owned operation. The website johnsplumbing-houston.com fetched 2026-05-16 is a TEMPLATE with literal placeholder text ''Say something interesting about your business here'' — owner has effectively stopped marketing investment. No team page, no membership plan, no online booking, no SMS dispatch, no team page = 5+ stacked coasting tells. Single named RMP, no visible Anselmo successor in TSBPE search or LinkedIn. Smaller shop size ($500K-1.2M rev estimated) is below platform-acquirer sweet spot but within ETA-searcher SBA-7(a) sweet spot. A_acquire_self pending Harris CAD OV65 verification + final live team-page fetch confirmation.', 'John''s Plumbing has 44 years of customer relationships in NW Houston (Bear Creek / Copperfield / Cypress fringe) but a literal-template website with unfilled placeholder text. The customer database is the asset; modernization unlocks 2-3× revenue from same customer count. Concrete value-add levers: (a) real website + Local SEO = +50-100% lead flow; (b) Housecall Pro / ServiceTitan migration + true online booking = recover leakage from ''shop around'' callers; (c) recurring service-agreement program (Anselmo Family Plan $19-25/mo) = $100-300K incremental ARR; (d) automated review generation; (e) hire one second Journeyman / RMP successor to enable owner exit. Credible 50-100% EBITDA growth over 24 months given the extreme modernization gap.',
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
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='PEGASUS PLUMBING & UTILITY SERVICES LLC' AND city='Houston' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  45, 'Massingill MP since 2011 = age 40-55.',
  70, 'High-end residential focus Houston.',
  50, 'Mid coasting tells.',
  85, 'Houston rollup hot.',
  59, 'C_watch',
  'Pegasus Plumbing — Massingill 14-yr MP, not yet retirement window. C_watch.', 'N/A — too young.',
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
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='GILBERT PLUMBING CO LP' AND city='Houston' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  72, 'Gilbert 4-gen Pat → Jack → Patrick. Jack Tex Tech 1988 grad = age 60.',
  90, '88-yr Houston operation. $8.7M revenue. 9 employees on books.',
  35, 'Successor check NEGATIVE: 4-gen Gilbert family.',
  92, 'Houston rollup hot.',
  68, 'B_forward',
  'Gilbert Plumbing — 4-gen Gilbert family. Platform-scale. B_forward.', 'Platform-scale Houston multi-gen. Forward.',
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
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='DOLPHIN PLUMBING' AND city='Houston' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  75, 'Eusebio Munoz MP since 1992 + Mario Munoz at company.',
  65, 'SE Harris shop, small-mid.',
  50, 'Successor check NEGATIVE: same-surname Munoz on LinkedIn.',
  80, 'Houston rollup hot.',
  66, 'B_forward',
  'Dolphin Plumbing — Eusebio + Mario Munoz family succession. B_forward.', 'Houston multi-gen Munoz. Forward.',
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