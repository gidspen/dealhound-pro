BEGIN;
INSERT INTO offmarket.business_signals (id, business_id, layer, signal_key, direction, evidence, source, source_url, observed_at) VALUES (
  'f83e37ba-caac-5774-958e-ff08e5d4f95a',
  '4b09aa53-c8f2-5e31-8919-fdc54939f4d4', 3, 'successor_check_live_fetch', 'positive',
  'Live team-page fetched 2026-05-16 at https://3asigns.com/. AAA Electrical Signs (Donna TX, Hidalgo Co., founded 1970 by Paul W. Sullivan) is a 56-year multi-city RGV + South-TX sign shop with extraordinary coasting signals: **website copyright 2003 (23 years stale)**, founder Paul W. Sullivan still listed as CEO at 76+, no family Sullivan named, no modern web/customer infrastructure. Live team-page fetch (3asigns.com/about-us, 2026-05-16) confirms sole-Sullivan principal with long-tenured trade managers (Plant Mgr 32yr, Sr Designer 43yr) who provide ops continuity but cannot credentialed-buy. 9-city service footprint (Pharr/Brownsville/Donna/Corpus Christi/San Antonio/Laredo/Mission/Harlingen/McAllen) = real route revenue. Border-metro (+2) + low-PE-attention vertical = quiet acquire-self target.',
  'live_website_fetch',
  'https://3asigns.com/',
  '2026-05-16'
) ON CONFLICT DO NOTHING;
INSERT INTO offmarket.business_signals (id, business_id, layer, signal_key, direction, evidence, source, source_url, observed_at) VALUES (
  '2a1268e3-cfa7-5932-aa8c-c4d539b71388',
  '4b09aa53-c8f2-5e31-8919-fdc54939f4d4', 1, 'owner_age_verification', 'positive',
  'Paul W. Sullivan (CEO + Founder): owner_age_source=founder_tenure_inference. Paul W. Sullivan founded AAA Electrical Signs in 1970 — 56-yr tenure as CEO. Sole listed owner/principal. Founder-tenure inference puts him in late 70s to early 80s. No family successor named (no other Sullivan); operational managers Joe Herrera (43yr), Mike Hill (32yr) are de facto operators but not credentialed owner-buyers. **Hard hit on natural-exit window.**',
  'founder_tenure_inference',
  'https://3asigns.com/',
  '2026-05-16'
) ON CONFLICT DO NOTHING;
INSERT INTO offmarket.business_signals (id, business_id, layer, signal_key, direction, evidence, source, source_url, observed_at) VALUES (
  'bd657319-0f67-52ac-ae05-78b2d4b191df',
  '4b09aa53-c8f2-5e31-8919-fdc54939f4d4', 2, 'sellability_assessment', 'positive',
  '57 years; 9-city RGV + South TX + San Antonio service footprint (Pharr, Brownsville, Donna, Corpus Christi, San Antonio, Laredo, Mission, Harlingen, McAllen). Multi-city = real route business + recurring repair/maintenance revenue. Estimated $1.5M-$4M rev — solid SBA band. Long-tenured operational managers (32-43yr Plant Mgr + Sr Designer) = ops continuity for buyer.',
  'multi_source_synthesis',
  'https://3asigns.com/',
  '2026-05-16'
) ON CONFLICT DO NOTHING;
INSERT INTO offmarket.business_signals (id, business_id, layer, signal_key, direction, evidence, source, source_url, observed_at) VALUES (
  '19332f1a-055d-5ccf-90bc-78d1fb104313',
  '4b09aa53-c8f2-5e31-8919-fdc54939f4d4', 3, 'coasting_trigger_assessment', 'positive',
  '**Website copyright 2003 = 23 YEARS STALE — extreme tell.** No online quote, no customer portal, no SMS, no modern tech stack visible. Founder Paul W. Sullivan at 76+ still listed as CEO. Site itself is the strongest coasting tell I''ve seen across this vertical.',
  'multi_source_synthesis',
  'https://3asigns.com/',
  '2026-05-16'
) ON CONFLICT DO NOTHING;
INSERT INTO offmarket.business_signals (id, business_id, layer, signal_key, direction, evidence, source, source_url, observed_at) VALUES (
  '96cc7c5b-b691-56bb-9888-09a29c9f40b3',
  '4b09aa53-c8f2-5e31-8919-fdc54939f4d4', 4, 'market_pull_assessment', 'positive',
  'RGV/border metro (+2 sub-market nudge per signage vertical config) + multi-city South TX route + low-PE-attention sign vertical. Hidalgo County base with Cameron + Webb service area = bilingual + cross-border B2B growth markets.',
  'vertical_config_baseline',
  'https://3asigns.com/',
  '2026-05-16'
) ON CONFLICT DO NOTHING;
INSERT INTO offmarket.business_signals (id, business_id, layer, signal_key, direction, evidence, source, source_url, observed_at) VALUES (
  '8da04fc8-0c01-543a-99bf-4529fd00046b',
  'bb7828c9-2372-59ba-804e-d84c68822734', 3, 'successor_check_live_fetch', 'positive',
  'Live team-page fetched 2026-05-16 at https://globalsignsinc.com/. Global Signs (Fort Worth Tarrant Co., founded 1987 by Rick Robertson) is a 39-year shop with **multi-brand national-account base (Domino''s, Honda, Starbucks, AutoZone, Chicken Express)** — that''s contractual multi-location service revenue. Live team-page fetch (globalsignsinc.com/about-us, 2026-05-16) confirms Rick Robertson is the sole listed principal; no son/daughter/co-principal/GM named. Site copyright 2021 = 5-yr-stale + minimal team transparency = coasting profile. Sole-principal aging founder + premium-brand national-account L2 + DFW corridor = strong A_acquire_self.',
  'live_website_fetch',
  'https://globalsignsinc.com/',
  '2026-05-16'
) ON CONFLICT DO NOTHING;
INSERT INTO offmarket.business_signals (id, business_id, layer, signal_key, direction, evidence, source, source_url, observed_at) VALUES (
  '1984ec4a-27f5-530c-843a-e445be6cd4f9',
  'bb7828c9-2372-59ba-804e-d84c68822734', 1, 'owner_age_verification', 'positive',
  'Rick Robertson (Founder): owner_age_source=founder_tenure_inference. Rick Robertson founded Global Signs in 1987 — 39-yr tenure as sole listed founder. No co-founder, son/daughter, or co-principal named on About page. License-tenure + founder-tenure inference puts him in 60s-70s. Sole-principal aging founder profile.',
  'founder_tenure_inference',
  'https://globalsignsinc.com/',
  '2026-05-16'
) ON CONFLICT DO NOTHING;
INSERT INTO offmarket.business_signals (id, business_id, layer, signal_key, direction, evidence, source, source_url, observed_at) VALUES (
  'd9e13664-becd-588f-9dc5-7aa035254161',
  'bb7828c9-2372-59ba-804e-d84c68822734', 2, 'sellability_assessment', 'positive',
  '39 years Fort Worth Tarrant Co.; named national-account customers explicit on About: **Domino''s, Honda, Starbucks, AutoZone, Chicken Express**. That''s recurring multi-location service revenue with named premium brands. TDLR-licensed journeyman sign electricians on staff. Estimated $1.5M-$4M rev = mid-upper SBA band.',
  'multi_source_synthesis',
  'https://globalsignsinc.com/',
  '2026-05-16'
) ON CONFLICT DO NOTHING;
INSERT INTO offmarket.business_signals (id, business_id, layer, signal_key, direction, evidence, source, source_url, observed_at) VALUES (
  '23c0ac69-398f-5af2-ab3e-f520eda9ea9f',
  'bb7828c9-2372-59ba-804e-d84c68822734', 3, 'coasting_trigger_assessment', 'positive',
  'Site copyright 2021 (5 yrs stale = coasting tell). About page names ONLY Rick Robertson — no specific staff (which is itself a tell; modern shops list their team). No specific online quote form visible.',
  'multi_source_synthesis',
  'https://globalsignsinc.com/',
  '2026-05-16'
) ON CONFLICT DO NOTHING;
INSERT INTO offmarket.business_signals (id, business_id, layer, signal_key, direction, evidence, source, source_url, observed_at) VALUES (
  '278d228e-e6ce-5ef5-98e0-a490467500e1',
  'bb7828c9-2372-59ba-804e-d84c68822734', 4, 'market_pull_assessment', 'positive',
  'DFW metro + Fort Worth (Tarrant) + multi-state national-account footprint + low-PE-attention vertical. National-brand customers = scale of service business raises L4.',
  'vertical_config_baseline',
  'https://globalsignsinc.com/',
  '2026-05-16'
) ON CONFLICT DO NOTHING;
INSERT INTO offmarket.business_signals (id, business_id, layer, signal_key, direction, evidence, source, source_url, observed_at) VALUES (
  '85bf303b-937d-528c-b78e-aae8f7ed849a',
  '88b1aa2f-35a1-5001-be2c-8247f0c01896', 1, 'owner_age_verification', 'positive',
  'Family-owned (multi-generation since 1946): owner_age_source=license_tenure_proxy + founder_era_inference. NEC / Neon Electric Corporation has been family-owned and operated since 1946 — 80-year tenure. Founder generation unknown but family is multi-generation by tenure alone. Per snippets, company is ''family owned and operated'' and ''has been involved in manufacturing and servicing of signs for over 54 years''. Live team-page not yet fetched — successor status needs verification.',
  'license_tenure_proxy + founder_era_inference',
  'https://necsigns.net/',
  '2026-05-16'
) ON CONFLICT DO NOTHING;
INSERT INTO offmarket.business_signals (id, business_id, layer, signal_key, direction, evidence, source, source_url, observed_at) VALUES (
  'dd18991c-00ae-5e10-a235-1494c8f7aefa',
  '88b1aa2f-35a1-5001-be2c-8247f0c01896', 2, 'sellability_assessment', 'positive',
  '80 years Houston Harris Co.; manufacturing + installation + servicing + architectural metal products. Multi-service mid-large shop. Estimated $1.5M-$5M rev = solid upper SBA band.',
  'multi_source_synthesis',
  'https://necsigns.net/',
  '2026-05-16'
) ON CONFLICT DO NOTHING;
INSERT INTO offmarket.business_signals (id, business_id, layer, signal_key, direction, evidence, source, source_url, observed_at) VALUES (
  'b151e69d-7bf8-5493-9572-9205438303ae',
  '88b1aa2f-35a1-5001-be2c-8247f0c01896', 4, 'market_pull_assessment', 'positive',
  'Houston Harris Co. + 80-yr local reputation + low-PE-attention sign vertical.',
  'vertical_config_baseline',
  'https://necsigns.net/',
  '2026-05-16'
) ON CONFLICT DO NOTHING;
INSERT INTO offmarket.business_signals (id, business_id, layer, signal_key, direction, evidence, source, source_url, observed_at) VALUES (
  '6872822e-bdb8-5a7e-9ba2-e5d09e8def29',
  '81b015fe-a824-5463-993e-2b5a42f37382', 3, 'successor_check_live_fetch', 'negative',
  'Live team-page fetched 2026-05-16 at https://www.atlassigns.com/. Atlas Sign Services (Houston, founded 1979 by Stan & Linda Titlow) is a 47-year UL-Listed family multi-service sign shop with significant CNC capability. **Live team-page fetch (atlassigns.com/about-us 2026-05-16) reveals son Stanford Titlow active as Master Sign Electrician — internal-buy-in candidate.** Site is 4 yrs stale with 3-4 coasting tells; mid SBA-band financials. Demoted from A→B because Stanford Titlow is the natural internal buyer. Hand to ETA/searcher community as a ''structured family handoff'' opportunity rather than Gideon-acquire-self.',
  'live_website_fetch',
  'https://www.atlassigns.com/',
  '2026-05-16'
) ON CONFLICT DO NOTHING;
INSERT INTO offmarket.business_signals (id, business_id, layer, signal_key, direction, evidence, source, source_url, observed_at) VALUES (
  '67153a09-301d-5fdf-9754-498e667fcbd9',
  '81b015fe-a824-5463-993e-2b5a42f37382', 1, 'owner_age_verification', 'positive',
  'Stan Titlow + Linda Titlow (founders); Stanford Titlow (son, Master Sign Electrician): owner_age_source=license_tenure_proxy + founder_tenure_inference. Stan + Linda Titlow founded Atlas Sign Services in 1979 — 47-yr tenure; both still listed as ''Founders'' on About page (no retirement noted). Son Stanford Titlow active as Master Sign Electrician. Founders likely 70+; license-tenure proxy only (no OV65 pulled).',
  'license_tenure_proxy + founder_tenure_inference',
  'https://www.atlassigns.com/',
  '2026-05-16'
) ON CONFLICT DO NOTHING;
INSERT INTO offmarket.business_signals (id, business_id, layer, signal_key, direction, evidence, source, source_url, observed_at) VALUES (
  'a1299dbf-875e-5a6f-bc5b-e31c54a16de7',
  '81b015fe-a824-5463-993e-2b5a42f37382', 2, 'sellability_assessment', 'positive',
  'Houston Harris-County multi-service shop: CNC channel-letter fabrication + 275-ton CNC press brake + plasma + LED message centers + 10-yr warranty. UL-Listed quality signal. Estimated $1M-$3M rev — solid SBA-band. Mon-Fri 7am-4pm only schedule.',
  'multi_source_synthesis',
  'https://www.atlassigns.com/',
  '2026-05-16'
) ON CONFLICT DO NOTHING;
INSERT INTO offmarket.business_signals (id, business_id, layer, signal_key, direction, evidence, source, source_url, observed_at) VALUES (
  '89412339-c067-5511-87b8-7a701be61ae6',
  '81b015fe-a824-5463-993e-2b5a42f37382', 4, 'market_pull_assessment', 'positive',
  'Houston Harris County baseline (+3 sub-market nudge for commercial corridor density). Low-PE-attention vertical (sign cos = quiet rollup target = better entry multiples). UL-Listed + CNC mfg = premium quality.',
  'vertical_config_baseline',
  'https://www.atlassigns.com/',
  '2026-05-16'
) ON CONFLICT DO NOTHING;
INSERT INTO offmarket.business_signals (id, business_id, layer, signal_key, direction, evidence, source, source_url, observed_at) VALUES (
  '97b67588-62b4-59e4-8801-928e6b0d27ad',
  '18f03f1b-b372-58ed-a6d5-193b73b26095', 3, 'successor_check_live_fetch', 'negative',
  'Live team-page fetched 2026-05-16 at https://signsmanufacturing.com/. Signs Manufacturing Corp (Dallas, founded 1979 by the Watson Family) is a 47-yr DFW industry leader with multi-generation Master Electrician / Master Sign Electrician family successors actively operating the business. Per their own history page, ''most male family members are licensed electricians (two are Masters)'' with 25+ yrs each. **This is a structured internal-buyout target, not coasting-solo-to-outside.** Demote to B_forward; hand to searcher community as a ''next-generation family handoff'' opportunity if family elects external sale.',
  'live_website_fetch',
  'https://signsmanufacturing.com/',
  '2026-05-16'
) ON CONFLICT DO NOTHING;
INSERT INTO offmarket.business_signals (id, business_id, layer, signal_key, direction, evidence, source, source_url, observed_at) VALUES (
  '6a4d043b-3897-5559-acc5-e98d08a1e8b4',
  '18f03f1b-b372-58ed-a6d5-193b73b26095', 1, 'owner_age_verification', 'positive',
  'Watson Family (multi-generation, multi-Master): owner_age_source=founder_tenure_inference. Signs Manufacturing founded 1979 by Watson Family — 47-yr tenure. Multi-generation family operation: ''most male family members are licensed electricians (two are Masters)'' per their history page, with 25+ yr individual tenure. Family is multi-generation; succession in place internally.',
  'founder_tenure_inference',
  'https://signsmanufacturing.com/',
  '2026-05-16'
) ON CONFLICT DO NOTHING;
INSERT INTO offmarket.business_signals (id, business_id, layer, signal_key, direction, evidence, source, source_url, observed_at) VALUES (
  '60ded97c-129a-5f20-b1fe-8486b8017db4',
  '18f03f1b-b372-58ed-a6d5-193b73b26095', 2, 'sellability_assessment', 'positive',
  'Watson Family multi-Master-Electrician + 5-building Dallas fabrication facility + automated channel-letter pioneer + Master Sign Electrician + Master Electrician dual licensure. Largest custom sign mfg in DFW Metroplex per their materials. Estimated $3M-$8M rev — upper SBA band approaching enterprise.',
  'multi_source_synthesis',
  'https://signsmanufacturing.com/',
  '2026-05-16'
) ON CONFLICT DO NOTHING;
INSERT INTO offmarket.business_signals (id, business_id, layer, signal_key, direction, evidence, source, source_url, observed_at) VALUES (
  'c84e0c1d-5f16-5f12-907e-d04ac5e98ee8',
  '18f03f1b-b372-58ed-a6d5-193b73b26095', 4, 'market_pull_assessment', 'positive',
  'DFW + family-pioneer reputation + automated CNC pioneer status — high-quality shop; LOW-PE-attention vertical premium; but already-rolling internal succession reduces external-buyer urgency.',
  'vertical_config_baseline',
  'https://signsmanufacturing.com/',
  '2026-05-16'
) ON CONFLICT DO NOTHING;
INSERT INTO offmarket.business_signals (id, business_id, layer, signal_key, direction, evidence, source, source_url, observed_at) VALUES (
  '1392b6f6-1dff-5a94-a836-94d624d7ab20',
  '846f313d-bd1e-532d-bc12-64d1e330e2ff', 1, 'owner_age_verification', 'positive',
  'Parsons Family (K. Parsons + Josh Parsons): owner_age_source=license_tenure_proxy. Willow Creek Signs founded 1995 — 31-yr tenure. Site lists K. Parsons + Josh Parsons; multi-Parsons pattern strongly suggests family ownership with internal succession (not verified by explicit language but signal is clear).',
  'license_tenure_proxy',
  'https://www.willowcreeksigns.com/',
  '2026-05-16'
) ON CONFLICT DO NOTHING;
INSERT INTO offmarket.business_signals (id, business_id, layer, signal_key, direction, evidence, source, source_url, observed_at) VALUES (
  '958f985a-5996-5ba6-b3a3-806f0743d25c',
  '846f313d-bd1e-532d-bc12-64d1e330e2ff', 2, 'sellability_assessment', 'positive',
  '30k sqft Haslet mfg facility; ''retail sign programs, bank re-brands, custom projects, service + installation NATIONWIDE''; **150 years combined sign experience** team. National-account recurring revenue language is explicit and strong. Estimated $3M-$7M rev = upper SBA band.',
  'multi_source_synthesis',
  'https://www.willowcreeksigns.com/',
  '2026-05-16'
) ON CONFLICT DO NOTHING;
INSERT INTO offmarket.business_signals (id, business_id, layer, signal_key, direction, evidence, source, source_url, observed_at) VALUES (
  'e81ddb99-4d5f-5c4d-b148-3aaac2a197a8',
  '846f313d-bd1e-532d-bc12-64d1e330e2ff', 4, 'market_pull_assessment', 'positive',
  'DFW corridor (Haslet) + national-account base + low-PE-attention vertical + high L2 (national-account recurring).',
  'vertical_config_baseline',
  'https://www.willowcreeksigns.com/',
  '2026-05-16'
) ON CONFLICT DO NOTHING;
INSERT INTO offmarket.business_signals (id, business_id, layer, signal_key, direction, evidence, source, source_url, observed_at) VALUES (
  '3e0f6386-9bb1-595d-a4bf-498c667e168b',
  'eeb2b17f-3795-5b92-a21b-0060b8f67e12', 3, 'successor_check_live_fetch', 'negative',
  'Live team-page fetched 2026-05-16 at https://www.aetnasign.com/. Aetna Sign Group (San Antonio, founded 1929) is a 97-year, **4th-generation family-owned** sign company servicing all major TX metros statewide. Multi-generation succession is explicit on the website. **This is a structured internal-family operation, not a coasting-solo-to-outside profile.** Demote to B_forward; route to searcher community as a ''rare 4-generation family handoff'' opportunity if/when the 4th gen elects to sell to outside vs preserve internally.',
  'live_website_fetch',
  'https://www.aetnasign.com/',
  '2026-05-16'
) ON CONFLICT DO NOTHING;
INSERT INTO offmarket.business_signals (id, business_id, layer, signal_key, direction, evidence, source, source_url, observed_at) VALUES (
  'f5fc363b-ec94-59e1-8cea-555601bdd979',
  'eeb2b17f-3795-5b92-a21b-0060b8f67e12', 1, 'owner_age_verification', 'positive',
  'Aetna Family (4th generation): owner_age_source=founder_tenure_inference. Aetna Sign Group founded 1929 by Aetna family in San Antonio. Site explicitly states ''4th generation, family-owned company'' — current operators are 4th-gen. Founder generation deceased; current owner-of-record likely 50s-60s 4th-gen.',
  'founder_tenure_inference',
  'https://www.aetnasign.com/',
  '2026-05-16'
) ON CONFLICT DO NOTHING;
INSERT INTO offmarket.business_signals (id, business_id, layer, signal_key, direction, evidence, source, source_url, observed_at) VALUES (
  '1d64890e-fa5c-5614-970a-64d63f2656d1',
  'eeb2b17f-3795-5b92-a21b-0060b8f67e12', 2, 'sellability_assessment', 'positive',
  '97 years San Antonio Bexar; statewide TX service (SA + Austin + Dallas + Houston + RGV + Laredo); design + installation + maintenance + LED + directional. Estimated $3M-$8M rev = upper SBA band. Cross-state TX coverage = real route business.',
  'multi_source_synthesis',
  'https://www.aetnasign.com/',
  '2026-05-16'
) ON CONFLICT DO NOTHING;
INSERT INTO offmarket.business_signals (id, business_id, layer, signal_key, direction, evidence, source, source_url, observed_at) VALUES (
  '72df5ebc-9ae5-5969-b5f7-6a54cd7030ca',
  'eeb2b17f-3795-5b92-a21b-0060b8f67e12', 4, 'market_pull_assessment', 'positive',
  'Multi-metro TX statewide + 97-yr brand reputation + low-PE-attention sign vertical premium.',
  'vertical_config_baseline',
  'https://www.aetnasign.com/',
  '2026-05-16'
) ON CONFLICT DO NOTHING;
INSERT INTO offmarket.business_signals (id, business_id, layer, signal_key, direction, evidence, source, source_url, observed_at) VALUES (
  '4886c533-74a6-572b-b312-95b2e2d5637a',
  '1991864d-d6ea-5e1f-825f-2f68442efbb7', 3, 'successor_check_live_fetch', 'negative',
  'Live team-page fetched 2026-05-16 at https://barnettsigns.com/. Barnett Signs (Mesquite DFW, founded 1971 by Nolan R. Barnett) is a 55-yr multi-generation family operation with **''4 Generations Strong''** explicit on website — current operations almost certainly involve 3rd-gen + 4th-gen Barnetts. **This is a textbook internal-buy-in candidate, not a coasting-solo-to-outside profile.** Demote to B_forward; route to searcher community as ''mature multi-gen handoff opportunity'' if/when family elects sale.',
  'live_website_fetch',
  'https://barnettsigns.com/',
  '2026-05-16'
) ON CONFLICT DO NOTHING;
INSERT INTO offmarket.business_signals (id, business_id, layer, signal_key, direction, evidence, source, source_url, observed_at) VALUES (
  '4947f5e1-3c05-5305-8c62-4bd87aadeea0',
  '1991864d-d6ea-5e1f-825f-2f68442efbb7', 1, 'owner_age_verification', 'positive',
  'Barnett Family (4 generations: Nolan + Barry + 3rd + 4th gen): owner_age_source=founder_tenure_inference. Barnett Signs founded 1971 by Nolan R. Barnett; son Barry Barnett joined within months; site explicitly says ''4 Generations Strong'' + ''150+ Years of Sign Experience''. Multi-generation family succession structured. Nolan likely 80+; Barry likely 70+; 3rd + 4th gen actively in business.',
  'founder_tenure_inference',
  'https://barnettsigns.com/',
  '2026-05-16'
) ON CONFLICT DO NOTHING;
INSERT INTO offmarket.business_signals (id, business_id, layer, signal_key, direction, evidence, source, source_url, observed_at) VALUES (
  '96039f53-352e-572d-b926-e9489ea08cc6',
  '1991864d-d6ea-5e1f-825f-2f68442efbb7', 2, 'sellability_assessment', 'positive',
  '55 years; Mesquite multi-location-project capable; estimated $2M-$5M rev = upper-mid SBA band. ''Multi-generational family-run'' + ''multi-location projects'' = healthy service base.',
  'multi_source_synthesis',
  'https://barnettsigns.com/',
  '2026-05-16'
) ON CONFLICT DO NOTHING;
INSERT INTO offmarket.business_signals (id, business_id, layer, signal_key, direction, evidence, source, source_url, observed_at) VALUES (
  'b045ffbc-d899-5068-8cf6-7ebefa104315',
  '1991864d-d6ea-5e1f-825f-2f68442efbb7', 4, 'market_pull_assessment', 'positive',
  'DFW metro + Mesquite (DFW exurban) + low-PE-attention sign vertical baseline.',
  'vertical_config_baseline',
  'https://barnettsigns.com/',
  '2026-05-16'
) ON CONFLICT DO NOTHING;
COMMIT;
