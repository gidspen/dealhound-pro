INSERT INTO offmarket.business_scores (
  business_id, score_run_id, layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment, layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment, final_score, final_tier, final_comment,
  value_add_thesis, confidence, data_completeness
) VALUES (
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='G & M Plumbing, Inc.' AND city='Pflugerville' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  70, 'Sonny+Eric Martinez brothers since 1987.',
  65, 'Pflugerville Austin metro.',
  50, 'Successor check NEGATIVE: 2-brother partnership = mutual successor.',
  90, 'Austin rollup very hot.',
  66, 'B_forward',
  'G&M Plumbing — Sonny+Eric brothers Pflugerville. B_forward.', 'Forward.',
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
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='Beyond Wow Plumbing' AND city='Austin' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  70, 'Beyond Wow Austin since 1980.',
  65, 'Austin mid.',
  55, 'Mid.',
  92, 'Austin rollup very hot.',
  68, 'B_forward',
  'Beyond Wow — 45-yr Austin. B_forward.', 'Long-tenured Austin family. Forward.',
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
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='Excalibur Plumbing' AND city='Leander' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  40, 'Excalibur Leander 2011.',
  55, 'Leander small.',
  50, 'Modernized.',
  92, 'Austin rollup very hot.',
  55, 'C_watch',
  'Excalibur Plumbing — 14-yr Leander, owner too young. D_pass (just past 5-yr-gate, age too young).', 'N/A.',
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
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='CRESCENT PLUMBING' AND city='Austin' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  78, 'Manuel Rodriguez M-17053 since 1988.',
  55, 'N Austin small.',
  50, 'No website. Cap.',
  90, 'Austin rollup hot.',
  66, 'B_forward',
  'Crescent Plumbing — long-tenured N Austin MP. C_watch.', 'N/A — thin.',
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
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='CK PLUMBING LLC DBA CLARK KENT PLUMBING INC' AND city='Austin' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  78, 'Gary W Hacker President + Cynthia Clarke VP (co-owner partnership). Hacker''s TSBPE M-14195 is a pre-1990 legacy license = 35+ yrs MP tenure. Estimated age ~65 (MP''d before 1990 + journeyman path = born ~1955-1965). Confidence medium pending Travis CAD OV65 check on both Hacker and Clarke residences. Co-owner structure (Hacker + Clarke) means partner-to-partner sale to outside buyer rather than internal-succession-to-junior — fits Gideon''s thesis if both are retirement-age.',
  88, '$10.6M revenue / 15 employees per D&B = squarely in SBA-7(a) jumbo + 504 real-estate financeable platform-bolt-on range. 40-yr operation. Multi-trade plumbing including 24/7 emergency, residential + commercial + hydro-jetting + camera inspection + boiler + lift station = comprehensive scope. PM Plumber license + 4 additional = clean license stack. 200+ Yelp reviews 4.4-star. Strong sellability score.',
  72, 'At $10.6M revenue with 15 employees in 2026, the absence of a customer membership plan, the absence of true online booking (only contact form on clarkekentplumbing.com fetched 2026-05-16), and the absence of named technicians on the About page are SIGNIFICANT coasting tells. Modern plumbing shops at this scale all have ServiceTitan + Housecall Pro membership programs + technician hiring funnels. The Hacker-Clarke partnership has stopped pushing modernization in the last 5-7 years per the static About page tone.',
  90, 'Austin is top-3 TX rollup metro. ZIP 78704 = premium South Austin (Travis Heights, Bouldin Creek, South Congress) = older housing stock + premium incomes = high recurring repair revenue density. Sub-market nudge +5 for premium Austin ZIP. Apex Service Partners (Alpine), Wrench Group, Service Champions all paying premium multiples in Austin. $10.6M revenue shop is in platform-acquirer SWEET SPOT ($300-800K EBITDA bolt-on at 5-7× = $1.5-5.5M sale). Plumbing rollup HOT (+9).',
  80, 'A_acquire_self',
  'Gary Hacker (President + RMP since pre-1990, M-14195) and Cynthia Clarke (VP) co-own Clarke Kent Plumbing, a 40-yr Austin operation generating $10.6M revenue with 15 employees (D&B-verified). Both principals are estimated retirement-window age (Hacker MP''d pre-1990 = age ~65+). At $10M+ revenue, the ABSENCE of a customer membership plan and the ABSENCE of true online booking on clarkekentplumbing.com (fetched 2026-05-16) are highly unusual modernization gaps — the partners have stopped pushing. Premium South Austin ZIP 78704 (Travis Heights / Bouldin / South Congress). Co-owner partnership means partner-to-partner exit to outside buyer rather than internal junior succession — fits Gideon''s thesis. A_acquire_self pending TCAD OV65 verification on Hacker and Clarke residences + confirmation no younger partner-track successor.', 'Clarke Kent has $10.6M revenue at 40-yr operating maturity but zero modern revenue infrastructure: no recurring-service membership program, no true online booking, no SMS dispatch automation, no named technicians on the website. A bolt-on operator could: (a) launch a Plumb Sentinel monthly membership at $24.95/mo across existing customer base = $300-600K incremental ARR within 12 months; (b) migrate to ServiceTitan for dispatch + scheduling = 15-25% windshield-time reduction; (c) build a technician apprenticeship program tied to TSBPE Journeyman ladder = solve the bench-depth problem; (d) automated review generation = leverage 200+ existing 4.4-star reviews into 1000+ across Austin metro. Credible 25-40% EBITDA uplift over 18-24 months. Sale-leaseback on 1408 W Ben White (TCAD lookup) if owned by entity.',
  'medium', 0.75
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
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='GILLINGWATER CONSTRUCTION LLC' AND city='Austin' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  60, 'Martin Jenkins M-20834 since 1999.',
  55, 'Austin NW Hills 78731 premium.',
  50, 'Construction-leaning — verify residential.',
  92, 'Austin rollup very hot + premium +5.',
  61, 'B_forward',
  'Gillingwater Construction — 26-yr Austin NW Hills premium. C_watch — construction-leaning needs filter check.', 'N/A — borderline.',
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
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='CENTEX ELITE PLUMBING LLC' AND city='Austin' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  50, 'Isaac Lopez M-39448 since 2009.',
  55, 'E Austin small.',
  50, 'Mid.',
  88, 'Austin rollup very hot.',
  57, 'C_watch',
  'Centex Elite Plumbing — 16-yr E Austin small. C_watch.', 'N/A — too young.',
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
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='WPM CONSTRUCTION, INC' AND city='Austin' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  50, 'Eric Campos M-39450 since 2009.',
  50, 'SE Austin. Construction-leaning per legal name.',
  50, 'Mid.',
  88, 'Austin rollup very hot.',
  56, 'C_watch',
  'WPM Construction — 16-yr SE Austin construction. C_watch — construction-leaning.', 'N/A — borderline.',
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
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='TK PLUMBING' AND city='Austin' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  45, 'Timothy Kinsey M-41442 since 2015.',
  50, 'Travis small.',
  50, 'Mid.',
  90, 'Austin rollup very hot.',
  54, 'C_watch',
  'TK Plumbing — 10-yr Travis, owner too young. D_pass.', 'N/A.',
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
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='MIKES PLUMBING' AND city='Round Rock' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  70, 'Michael Gavit M-20095 since 1998.',
  55, 'Round Rock small.',
  50, 'No website. Cap.',
  90, 'Austin/Round Rock rollup very hot.',
  63, 'B_forward',
  'Mike''s Plumbing — 27-yr Round Rock MP. C_watch — thin data.', 'N/A — thin.',
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