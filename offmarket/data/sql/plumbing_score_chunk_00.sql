INSERT INTO offmarket.business_scores (
  business_id, score_run_id, layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment, layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment, final_score, final_tier, final_comment,
  value_add_thesis, confidence, data_completeness
) VALUES (
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='Santhoff Plumbing Company' AND city='Houston' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  70, 'Joe Santhoff founder ~age 72-78 (1974 founding + ~30 yr at founding = age ~75). Long tenure but family succession already structured — Jason (GM) + James (MP) + Julie (Office) Santhoff are clearly the next generation.',
  88, 'Excellent: 52-yr operation, 14+ named techs + 2 MPs, Santhoff Family Club membership = recurring revenue, 840 Google reviews 4.9-star, multi-trade scope. ≈ $2.5-4M rev band, SBA-financeable mid-shop.',
  50, 'Limited coasting tells — Family Club membership active, Yelp/Google review velocity strong (840 reviews 4.9), ''Request Service'' modernized form. Successor check NEGATIVE: live team page fetched 2026-05-16 lists Joe + Jason (GM) + James (MP) + Julie (Office Mgr). NOT a coasting-solo profile.',
  90, 'Houston rollup hot, Santhoff is platform-acquirer sweet-spot size at $2.5-4M rev, premium 5-county Houston metro service area.',
  72, 'B_forward',
  'Joe Santhoff, ~75 (founded Santhoff Plumbing 1974, family-business proxy), runs the company with second-generation children Jason (GM), James (Master Plumber), and Julie (Office Mgr) — verified via live team-page fetch on santhoffplumbingco.com/about-us 2026-05-16. Multi-generation structured family succession is in place; this is NOT the coasting-solo-to-outside-buyer profile. Healthy mid-shop ($2.5-4M rev band), Santhoff Family Club $20/mo membership, 840 Google reviews 4.9-star. B_forward — strong bolt-on candidate for the Mastermind / ETA buyer community but not Gideon-acquire-self.', 'Mid-shop Houston multi-gen family plumbing operation with strong existing membership program and review base. Forward to ETA / search-fund / Apex-Wrench-platform buyer community as a B-tier bolt-on. Value-add levers: ServiceTitan dispatch migration, $5M+ revenue stretch via geographic expansion into Sugar Land + Katy, recurring revenue conversion from one-time customers.',
  'high', 0.8
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
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='Strutton Plumbing Company, Inc.' AND city='Houston' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  72, 'Strutton Plumbing ''third-generation family-owned'' since 1971. Current operator age ~60-70.',
  70, '55-yr operation, mid-shop multi-trade plumbing + new construction + underground utilities, Houston 77074.',
  55, 'Successor check NEGATIVE: live website states ''third-generation family-owned business'' = internal succession explicit. No coasting-solo thesis.',
  78, 'Houston rollup hot.',
  67, 'B_forward',
  'Strutton Plumbing Company, 55-yr-old explicit 3rd-generation family operation in Houston 77074. Internal succession in place. B_forward — bolt-on candidate.', 'Mid-shop Houston multi-trade plumbing + underground utilities specialty. Forward to ETA/PE community as B-tier bolt-on.',
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
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='The Lindsay Company Plumbing' AND city='Cypress' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  65, 'Lindsay Company since 1982. Owner age ~60-70.',
  70, '44-yr NW Houston shop, multi-service plumbing + water filtration + gas generator. ≈ $1-2M rev.',
  55, 'Thin web detail — no team page, no membership, no booking visible. Family-owned 1982. Possible coasting profile.',
  78, 'Houston rollup hot, NW Harris baseline.',
  65, 'B_forward',
  'The Lindsay Company Plumbing — 44-yr NW Houston family. Thin online presence, possible coasting. B_forward pending deeper team verification.', 'NW Houston plumbing modernization candidate. Forward to ETA / PE bolt-on after live team page deep-dive.',
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
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='Cooper Plumbing' AND city='Houston' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  50, 'Unverified.',
  50, 'Unverified.',
  35, 'Unverified.',
  75, 'Houston baseline.',
  49, 'C_watch',
  'Cooper Plumbing — unverified candidate; common name. C_watch pending verification.', 'N/A — unverified.',
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
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='Nick''s Plumbing Services' AND city='Houston' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  60, 'Nick''s Plumbing family-owned since 1979. Owner age proxy ~60 from biz history.',
  88, 'Excellent: 47-yr operation, multi-trade plumbing + HVAC + electric (TACLA0012793E + TACLB85298E), Nick''s Smart VIP membership program, online booking. ≈ $3-6M rev band.',
  35, 'FEW coasting tells — Nick''s Smart VIP membership = active recurring revenue, true online booking, premium Houston Galleria/Bellaire/Memorial service area = high-end clients. Modernized = NOT coasting profile.',
  92, 'Houston rollup hot + premium Galleria/Bellaire/Memorial submarket nudge +5.',
  64, 'B_forward',
  'Nick''s Plumbing, 47-yr family-owned Houston shop with active VIP membership program, true online booking, multi-trade scope (plumbing+HVAC+electric), premium service area (Galleria/Bellaire/Memorial). $3-6M revenue band. This is NOT a coasting-owner — modernization signals are intact. B_forward — premium platform-acquirer bolt-on candidate for Apex/Wrench/Service Champions.', 'Premium Houston Galleria/Bellaire/Memorial multi-trade plumbing+HVAC+electric is a platform-acquirer prize. Forward to Apex / Wrench / Service Champions / Sila as a $5-10M sale target.',
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
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='Wedgeworth Plumbing' AND city='Houston' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  65, 'Wedgeworth Plumbing — current owner Sean (2nd-gen, inherited from Mr & Mrs Wedgeworth per customer testimonial). Age likely 50-60.',
  75, 'Mid-shop Houston (77055 — Spring Branch). 14+ named techs >10 yrs experience each. Multi-trade scope (water heaters, tankless, drain cleaning, hydro-jet, sewer, slab leak, gas, A/C condensate). ≈ $2-3.5M rev band.',
  50, 'Successor check NEGATIVE — Sean inherited from Mr & Mrs Wedgeworth (2nd-gen succession already done). Whether Sean has his own successor is unclear but family-succession pattern fires.',
  85, 'Houston rollup hot. Spring Branch is ordinary Houston metro submarket.',
  66, 'B_forward',
  'Wedgeworth Plumbing — Sean (2nd-gen) inherited from Mr & Mrs Wedgeworth. Mid-shop ($2-3.5M rev) with 14+ long-tenured techs. B_forward — bolt-on candidate.', 'Mid-shop Houston Spring Branch plumbing with strong technician retention. Forward to ETA / Apex / Wrench platform as bolt-on.',
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
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='DYZ Plumbing' AND city='Bellaire' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  50, '19 yrs experience — owner likely 45-55.',
  65, 'Bellaire/Memorial focus, small shop ≈ $500K-1M rev.',
  50, 'Mid coasting tells.',
  80, 'Houston Bellaire/Memorial premium +3.',
  58, 'C_watch',
  'DYZ Plumbing — 19 yrs Bellaire shop, owner age too young, C_watch.', 'N/A — borderline.',
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
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='David Hicks Plumbing' AND city='Houston' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  82, 'David Hicks is 2nd-generation owner of a 74-year operation (founded by father George Hicks 1952). David''s MP license M-8529 is a low-number pre-1990 legacy = 35+ yrs MP tenure. Estimated age ~67 derived from family-business history proxy (George founded 1952, David ~30 yr generational gap = born ~1957-65). NO 3rd-gen Hicks visible. Confidence: medium pending Harris CAD OV65 check on personal residence.',
  78, '74-yr operation in elite River Oaks/Montrose Houston submarket (77019). Multi-licensed (TX Master Plumber + multiple service registrations 1488, 20904, REG12333, REG13208, 15453, M-8529 = multi-trade scope). 50+ Yelp reviews. SBA-financeable size — ''fully stocked trucks'' (plural) + commercial+residential services + leak detection/repipe/tankless = solo-to-mid shop ≈ $1-2M revenue band.',
  75, 'Strong coasting tells: (a) NO membership plan or recurring service agreement visible on davidhicksplumbing.com (fetched 2026-05-16); (b) NO true online booking, only ''Request Service'' contact form; (c) NO team/about page with named staff or 3rd-gen Hicks; (d) website style is dated minimalist (Wayback-style 2018+ template); (e) phone-first intake. 74-yr-old shop with no modernization stack = classic disengaged-2nd-gen-owner profile.',
  88, 'Houston is top-3 TX rollup metro for plumbing. Wrench Group, Apex Service Partners, ARS, Roto-Rooter Service Co, Service Champions all active in Houston with $1M+ EBITDA bolt-on bids at 7-12× EBITDA. River Oaks/Montrose 77019 ZIP = older 1920s-1960s housing stock = high recurring repair revenue density. Sub-market nudge +3 for older Houston housing. Plumbing rollup is currently HOT (+9 modifier).',
  80, 'A_acquire_self',
  'David Hicks, ~67 yrs old (2nd-gen owner; father George founded the company in 1952; David''s MP license M-8529 is pre-1990 = 35+ yrs MP tenure), runs David Hicks Plumbing out of 2023 Fairview St in Houston''s River Oaks/Montrose 77019. 74-year-old family-owned shop. NO 3rd-generation Hicks visible on the website (fetched 2026-05-16) or in BBB profile — the line ends at David. Strong coasting tells: no membership plan, no online booking, no team page, dated website. Premium River Oaks submarket = older housing = strong recurring service base. Houston plumbing rollup is hot (Wrench Group, Apex, ARS all paying premium multiples). A_acquire_self pending Harris CAD OV65 verification.', 'AI dispatch (ServiceTitan migration), true online booking, recurring service-agreement program (Hicks Family Plan $25-30/mo, targeting River Oaks demographic), modern field-service software, automated review generation, technician hiring funnel + sale-leaseback on Fairview St building (CAD lookup). 74-yr River Oaks customer base = the asset; modernization unlocks 2-3× revenue from existing customers + commands premium multiple on exit. Credible 30-50% EBITDA uplift over 18-24 months.',
  'medium', 0.7
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
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='Best Plumbing' AND city='Houston' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  50, 'Unverified.',
  50, 'Unverified.',
  35, 'Unverified.',
  75, 'Houston baseline.',
  49, 'C_watch',
  'Best Plumbing Houston — unverified, common name. C_watch.', 'N/A.',
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
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='Southern Plumbing' AND city='Houston' AND state='TX'),
  '6cbb9025-2383-4e26-bbd2-992f0e1a906f',
  45, 'Southern Plumbing 22 yrs. Owner age likely 50-60.',
  65, 'Houston metro shop, ≈ $700K-1.5M rev.',
  45, 'Some coasting indicators (small website).',
  75, 'Houston baseline.',
  54, 'C_watch',
  'Southern Plumbing — 22-yr Houston small-mid shop. C_watch.', 'N/A — not yet retirement-window.',
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