BEGIN;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  '2ae50897-380f-592b-823b-a881738c6581',
  '4b09aa53-c8f2-5e31-8919-fdc54939f4d4',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  88, 'Paul W. Sullivan founded AAA Electrical Signs in 1970 — 56-yr tenure as CEO. Sole listed owner/principal. Founder-tenure inference puts him in late 70s to early 80s. No family successor named (no other Sullivan); operational managers Joe Herrera (43yr), Mike Hill (32yr) are de facto operators but not credentialed owner-buyers. **Hard hit on natural-exit window.**',
  72, '57 years; 9-city RGV + South TX + San Antonio service footprint (Pharr, Brownsville, Donna, Corpus Christi, San Antonio, Laredo, Mission, Harlingen, McAllen). Multi-city = real route business + recurring repair/maintenance revenue. Estimated $1.5M-$4M rev — solid SBA band. Long-tenured operational managers (32-43yr Plant Mgr + Sr Designer) = ops continuity for buyer.',
  85, '**Website copyright 2003 = 23 YEARS STALE — extreme tell.** No online quote, no customer portal, no SMS, no modern tech stack visible. Founder Paul W. Sullivan at 76+ still listed as CEO. Site itself is the strongest coasting tell I''ve seen across this vertical.',
  75, 'RGV/border metro (+2 sub-market nudge per signage vertical config) + multi-city South TX route + low-PE-attention sign vertical. Hidalgo County base with Cameron + Webb service area = bilingual + cross-border B2B growth markets.',
  81, 'A_acquire_self', 'AAA Electrical Signs (Donna TX, Hidalgo Co., founded 1970 by Paul W. Sullivan) is a 56-year multi-city RGV + South-TX sign shop with extraordinary coasting signals: **website copyright 2003 (23 years stale)**, founder Paul W. Sullivan still listed as CEO at 76+, no family Sullivan named, no modern web/customer infrastructure. Live team-page fetch (3asigns.com/about-us, 2026-05-16) confirms sole-Sullivan principal with long-tenured trade managers (Plant Mgr 32yr, Sr Designer 43yr) who provide ops continuity but cannot credentialed-buy. 9-city service footprint (Pharr/Brownsville/Donna/Corpus Christi/San Antonio/Laredo/Mission/Harlingen/McAllen) = real route revenue. Border-metro (+2) + low-PE-attention vertical = quiet acquire-self target.', 'Concrete levers: (1) Modern website + online quote intake to replace 23-yr-stale 2003-era site — first-month win; (2) Customer portal for service tickets + photo documentation (RGV retail-chain customers will adopt fast); (3) Formalize multi-city route + maintenance-contract program leveraging existing 9-city footprint; (4) AI dispatch + telematics for the trade-managers running ops; (5) Bilingual digital signage / LED retrofit upsell for Mexican retail expansion in Brownsville/Laredo. Asset-rich (RGV warehouse + service fleet) supports SBA 504 + SBA 7(a) stack. Long-tenured operational managers provide multi-year ops continuity post-close.',
  'medium', 0.78
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  '8e867a9f-0a7a-5a0c-aedb-1da8cce5e938',
  'bb7828c9-2372-59ba-804e-d84c68822734',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  80, 'Rick Robertson founded Global Signs in 1987 — 39-yr tenure as sole listed founder. No co-founder, son/daughter, or co-principal named on About page. License-tenure + founder-tenure inference puts him in 60s-70s. Sole-principal aging founder profile.',
  80, '39 years Fort Worth Tarrant Co.; named national-account customers explicit on About: **Domino''s, Honda, Starbucks, AutoZone, Chicken Express**. That''s recurring multi-location service revenue with named premium brands. TDLR-licensed journeyman sign electricians on staff. Estimated $1.5M-$4M rev = mid-upper SBA band.',
  75, 'Site copyright 2021 (5 yrs stale = coasting tell). About page names ONLY Rick Robertson — no specific staff (which is itself a tell; modern shops list their team). No specific online quote form visible.',
  78, 'DFW metro + Fort Worth (Tarrant) + multi-state national-account footprint + low-PE-attention vertical. National-brand customers = scale of service business raises L4.',
  78, 'A_acquire_self', 'Global Signs (Fort Worth Tarrant Co., founded 1987 by Rick Robertson) is a 39-year shop with **multi-brand national-account base (Domino''s, Honda, Starbucks, AutoZone, Chicken Express)** — that''s contractual multi-location service revenue. Live team-page fetch (globalsignsinc.com/about-us, 2026-05-16) confirms Rick Robertson is the sole listed principal; no son/daughter/co-principal/GM named. Site copyright 2021 = 5-yr-stale + minimal team transparency = coasting profile. Sole-principal aging founder + premium-brand national-account L2 + DFW corridor = strong A_acquire_self.', '(1) Customer portal for the national-account base (Domino''s etc.) — service-ticket photo documentation + inspection scheduling is highest-ROI lever; (2) Modernize From 5-yr-stale site to current portfolio CMS; (3) Online quote engine for non-account smaller projects; (4) Formalize maintenance-contract pricing tiers for the existing national-brand customer pipeline; (5) Add LED-retrofit program for the channel-letter installed base. National-account book is the asset — buyer should preserve relationships through the transition.',
  'medium', 0.72
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  '18d13105-4531-5d7c-b872-3a9e426ffcce',
  '88b1aa2f-35a1-5001-be2c-8247f0c01896',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  85, 'NEC / Neon Electric Corporation has been family-owned and operated since 1946 — 80-year tenure. Founder generation unknown but family is multi-generation by tenure alone. Per snippets, company is ''family owned and operated'' and ''has been involved in manufacturing and servicing of signs for over 54 years''. Live team-page not yet fetched — successor status needs verification.',
  75, '80 years Houston Harris Co.; manufacturing + installation + servicing + architectural metal products. Multi-service mid-large shop. Estimated $1.5M-$5M rev = solid upper SBA band.',
  70, 'Snippet-level evidence only (live About-page fetch not yet performed in this run for this row — cap confidence at low until done). Multi-decade tenure + ''family owned'' language suggests potential coasting but not verified.',
  78, 'Houston Harris Co. + 80-yr local reputation + low-PE-attention sign vertical.',
  77, 'B_forward', 'Neon Electric Corporation / NEC (Houston Harris Co., founded 1946) is an 80-year family-owned multi-service sign manufacturer + service shop. Family-owned status confirmed via Procore + BBB profiles but live team-page not yet verified for explicit successor candidates. Per skill non-negotiable on successor verification for A-tier candidates: capped at B_forward until live team-page fetch verifies sole-principal vs multi-gen-family structure. Re-fetch on next run, or treat as B-forward to searcher community pending verification.', 'Pending live team-page verification. If sole-principal: AI dispatch + customer portal + national-account maintenance pitch leveraging 80-yr Houston commercial-corridor reputation. If multi-gen: family handoff candidate.',
  'medium', 0.55
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  '55c2f626-a73b-5c3a-8751-1dbfdcc38210',
  '81b015fe-a824-5463-993e-2b5a42f37382',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  55, 'Stan + Linda Titlow founded Atlas Sign Services in 1979 — 47-yr tenure; both still listed as ''Founders'' on About page (no retirement noted). Son Stanford Titlow active as Master Sign Electrician. Founders likely 70+; license-tenure proxy only (no OV65 pulled).',
  75, 'Houston Harris-County multi-service shop: CNC channel-letter fabrication + 275-ton CNC press brake + plasma + LED message centers + 10-yr warranty. UL-Listed quality signal. Estimated $1M-$3M rev — solid SBA-band. Mon-Fri 7am-4pm only schedule.',
  65, 'Site copyright 2022 (4 yrs stale); no online quote form, no customer portal, no formal maintenance program language; Mon-Fri only hours (no Sat). 3-4 visible coasting tells. Live team-page fetched 2026-05-16 atlassigns.com/about-us/.',
  78, 'Houston Harris County baseline (+3 sub-market nudge for commercial corridor density). Low-PE-attention vertical (sign cos = quiet rollup target = better entry multiples). UL-Listed + CNC mfg = premium quality.',
  66, 'B_forward', 'Atlas Sign Services (Houston, founded 1979 by Stan & Linda Titlow) is a 47-year UL-Listed family multi-service sign shop with significant CNC capability. **Live team-page fetch (atlassigns.com/about-us 2026-05-16) reveals son Stanford Titlow active as Master Sign Electrician — internal-buy-in candidate.** Site is 4 yrs stale with 3-4 coasting tells; mid SBA-band financials. Demoted from A→B because Stanford Titlow is the natural internal buyer. Hand to ETA/searcher community as a ''structured family handoff'' opportunity rather than Gideon-acquire-self.', 'If outside buyer wants to compete: Online quote engine to replace phone-only intake, customer portal for permit + project tracking, formalize maintenance-contract program for the existing Houston commercial client base (CNC + UL-Listed quality already supports it). Existing CNC + 275-ton press brake is asset-rich for SBA 504 financing.',
  'high', 0.75
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  '01d6da4d-0e04-5d29-9e95-60ead2abe1f0',
  '18f03f1b-b372-58ed-a6d5-193b73b26095',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  60, 'Signs Manufacturing founded 1979 by Watson Family — 47-yr tenure. Multi-generation family operation: ''most male family members are licensed electricians (two are Masters)'' per their history page, with 25+ yr individual tenure. Family is multi-generation; succession in place internally.',
  80, 'Watson Family multi-Master-Electrician + 5-building Dallas fabrication facility + automated channel-letter pioneer + Master Sign Electrician + Master Electrician dual licensure. Largest custom sign mfg in DFW Metroplex per their materials. Estimated $3M-$8M rev — upper SBA band approaching enterprise.',
  50, 'Site (signsmanufacturing.com) reachable; family-history page detailed and active. Modest coasting tells — site looks pre-2020s. Limited; family is actively engaged. Successor candidate explicitly present (multi-gen Watson family).',
  78, 'DFW + family-pioneer reputation + automated CNC pioneer status — high-quality shop; LOW-PE-attention vertical premium; but already-rolling internal succession reduces external-buyer urgency.',
  65, 'B_forward', 'Signs Manufacturing Corp (Dallas, founded 1979 by the Watson Family) is a 47-yr DFW industry leader with multi-generation Master Electrician / Master Sign Electrician family successors actively operating the business. Per their own history page, ''most male family members are licensed electricians (two are Masters)'' with 25+ yrs each. **This is a structured internal-buyout target, not coasting-solo-to-outside.** Demote to B_forward; hand to searcher community as a ''next-generation family handoff'' opportunity if family elects external sale.', 'If outside buyer somehow wins: Modernize digital tooling (BuildOps / ServiceTrade for service routes), customer portal for project + maintenance tracking, leverage their CNC pioneer reputation for premium-positioning marketing. Upper-SBA-band; SBA 504 viable for 5-building real-estate-heavy footprint.',
  'high', 0.8
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  '0f7e47fa-9470-5a4f-9946-eaf90b4adc4c',
  '272e6035-275e-5d7a-b963-187bbada9dff',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  65, 'Hancock Sign Company near I-30/Hwy 360 (Irving) — TDLR license # suggests 23+ yr operation; owner unknown from public sources. License-tenure proxy weak. About page TLS cert invalid (could not fetch securely).',
  60, 'Full-service: design + manufacture + install + service of electric signs (channel letters, cabinets, monument, cast stone, pole signs, LED EMCs). North-Central TX service area. Estimated $900K-$2M rev — mid SBA band.',
  55, 'HTTP-only site (no HTTPS) = strong coasting tell (pre-2015 tech); TLS cert invalid on About page = unable to verify team. Multiple snippet-level tells of dated site present.',
  75, 'Dallas metro (Irving sub-market) — low-PE-attention vertical baseline.',
  62, 'C_watch', 'Hancock Sign Company (Irving DFW) operates with an HTTP-only website (no HTTPS), and its About page returned a TLS certificate error on fetch. Per skill team-page-unreachable protocol, confidence is capped at low and tier at C_watch. The HTTP-only website is itself a strong pre-2015 coasting tell — promising but cannot promote without verified team composition. Re-score after manual outreach or Wayback fetch.', 'If verifiable: SSL/HTTPS migration + modern site rebuild, online quote intake, customer service-ticket portal, formalize the service-line of cabinet repair into a monthly maintenance contract pitch.',
  'low', 0.4
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  '24c98de4-ac9e-5502-af77-1fc75c21f45e',
  '846f313d-bd1e-532d-bc12-64d1e330e2ff',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  50, 'Willow Creek Signs founded 1995 — 31-yr tenure. Site lists K. Parsons + Josh Parsons; multi-Parsons pattern strongly suggests family ownership with internal succession (not verified by explicit language but signal is clear).',
  82, '30k sqft Haslet mfg facility; ''retail sign programs, bank re-brands, custom projects, service + installation NATIONWIDE''; **150 years combined sign experience** team. National-account recurring revenue language is explicit and strong. Estimated $3M-$7M rev = upper SBA band.',
  50, 'Site copyright 2026 (current); team named with extensions (modern contact patterns); national-account language modern. Coasting tells minimal.',
  80, 'DFW corridor (Haslet) + national-account base + low-PE-attention vertical + high L2 (national-account recurring).',
  62, 'B_forward', 'Willow Creek Signs (Haslet TX DFW, founded 1995) is a 31-yr 30k-sqft national-program sign company — **retail sign programs, bank re-brands, multi-location maintenance** with 150 years combined sign experience. Live team-page fetch (willowcreeksigns.com/about, 2026-05-16) names Josh Parsons + K. Parsons + David Flory — multi-Parsons family pattern strongly suggests internal succession. Current modern website. Demote A→B due to likely-family-successor pattern; route to searcher community as a ''mature national-account program'' opportunity.', 'If outside buyer wins: Leverage existing national-account base (retail rebrand + bank rebrand programs are sticky multi-year contracts) and add LED-retrofit-as-a-service to existing customer footprint. Strong asset base + national recurring contracts = SBA 7(a) jumbo viable.',
  'medium', 0.72
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  '2885bac0-7295-5363-a026-e1d14b6f0be9',
  'eeb2b17f-3795-5b92-a21b-0060b8f67e12',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  45, 'Aetna Sign Group founded 1929 by Aetna family in San Antonio. Site explicitly states ''4th generation, family-owned company'' — current operators are 4th-gen. Founder generation deceased; current owner-of-record likely 50s-60s 4th-gen.',
  80, '97 years San Antonio Bexar; statewide TX service (SA + Austin + Dallas + Houston + RGV + Laredo); design + installation + maintenance + LED + directional. Estimated $3M-$8M rev = upper SBA band. Cross-state TX coverage = real route business.',
  50, 'Modern site; 4-gen family operating = anti-coasting signal; not a ''coasting solo'' profile. Few visible coasting tells.',
  80, 'Multi-metro TX statewide + 97-yr brand reputation + low-PE-attention sign vertical premium.',
  60, 'B_forward', 'Aetna Sign Group (San Antonio, founded 1929) is a 97-year, **4th-generation family-owned** sign company servicing all major TX metros statewide. Multi-generation succession is explicit on the website. **This is a structured internal-family operation, not a coasting-solo-to-outside profile.** Demote to B_forward; route to searcher community as a ''rare 4-generation family handoff'' opportunity if/when the 4th gen elects to sell to outside vs preserve internally.', 'If outside buyer wins: preserve the 97-yr brand (its primary moat), modernize digital tooling (BuildOps / ServiceTrade), add LED-retrofit-as-a-service program leveraging statewide TX coverage, customer portal for the existing statewide customer base.',
  'high', 0.78
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  'd03cd445-1924-5ba8-8b90-56067d839b77',
  '1991864d-d6ea-5e1f-825f-2f68442efbb7',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  45, 'Barnett Signs founded 1971 by Nolan R. Barnett; son Barry Barnett joined within months; site explicitly says ''4 Generations Strong'' + ''150+ Years of Sign Experience''. Multi-generation family succession structured. Nolan likely 80+; Barry likely 70+; 3rd + 4th gen actively in business.',
  80, '55 years; Mesquite multi-location-project capable; estimated $2M-$5M rev = upper-mid SBA band. ''Multi-generational family-run'' + ''multi-location projects'' = healthy service base.',
  45, 'Site copyright 2026 (current, modern). 4-gen succession = anti-coasting signal. Few visible coasting tells; team page exists.',
  78, 'DFW metro + Mesquite (DFW exurban) + low-PE-attention sign vertical baseline.',
  59, 'B_forward', 'Barnett Signs (Mesquite DFW, founded 1971 by Nolan R. Barnett) is a 55-yr multi-generation family operation with **''4 Generations Strong''** explicit on website — current operations almost certainly involve 3rd-gen + 4th-gen Barnetts. **This is a textbook internal-buy-in candidate, not a coasting-solo-to-outside profile.** Demote to B_forward; route to searcher community as ''mature multi-gen handoff opportunity'' if/when family elects sale.', 'Asset-rich (multi-location Mesquite facility), recurring multi-location project base, family-trained successor in place — buyer''s path is preserving brand + adding ops tech (BuildOps / ServiceTrade), not transformation.',
  'high', 0.8
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  'eba49664-b830-5286-908e-dcc1020849dd',
  '4804b432-4c68-5b37-95b7-b83503b1fec0',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  60, 'Casteel & Associates founded 1987 in Houston, now Dallas-based; sole-owner Warren T. Casteel (39 yrs as founder; likely 60s-70s). License-tenure proxy only; OV65 not pulled this run. Owner-age estimate medium confidence.',
  60, 'Architectural + ADA + electronic signage (Daktronics dealer). Commercial + public sector mix. Estimated $1.5M-$4M rev — mid SBA-band. Healthy specialty (architectural metal letters + ADA + LED EMCs); no recurring contract language confirmed.',
  50, 'Site copyright 2026 (current); About page URL 404''d (could not verify team composition or successor candidates). Per skill rules, team-page-unreachable caps confidence at low; this layer reflects uncertain coasting status with some positive signals (Daktronics LED partnership).',
  70, 'Dallas metro + architectural-signage specialty + commercial/public-sector clientele. Low-PE-attention vertical baseline = +3 nudge.',
  58, 'C_watch', 'Casteel & Associates (Dallas, founded 1987 by Warren T. Casteel) is a 39-yr architectural / ADA / commercial sign shop with Daktronics LED dealer status. About page returned 404 on direct fetch; cannot verify successor candidates or team composition. Per skill protocol team-page-unreachable caps tier at C_watch. Re-score in 90 days when site is reachable or after Comptroller/CAD lookup confirms owner age + property ownership.', 'If verifiable as sole-principal: AI quote engine for architectural signage estimates, online job-portfolio CMS to refresh stale About content, customer portal for service tickets and inspection reports — Daktronics partnership is leverageable for LED retrofit upsell program.',
  'low', 0.45
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  'ac7a3544-2e70-529d-b8e9-e8d06f31944c',
  '66af723d-9271-5703-a1ef-0a70ce223b58',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  50, 'Mike Hunter founded Hunter Graphics in 2000 — 26-yr tenure. Family-owned per BBB. About-page fetch returned 403; cannot verify family-successor status.',
  55, 'Fort Worth Tarrant; UL Certified; gas station + LED signs + vehicle wraps + graphics turnkey imaging. Smaller shop ~$700K-$1.5M rev.',
  55, 'About page 403 = unable to verify team / coasting tells. Site presence modest.',
  70, 'DFW corridor + low-PE-attention vertical.',
  56, 'C_watch', 'Hunter Graphics (Fort Worth, founded 2000 by Mike Hunter) is a 26-yr UL-Certified family-owned shop specializing in gas station signs + LED + vehicle wraps. About page returned 403 on fetch; cannot verify whether family-owned = sole-principal or has visible successor candidates. Per skill team-page-unreachable rule, cap at C_watch. Re-score after manual outreach.', 'If verifiable: Customer portal for gas-station-chain maintenance accounts, AI dispatch for vehicle-wrap mobile production, modernize quoting for vehicle-wrap volume.',
  'low', 0.4
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  'fbf83db3-623a-5bac-9d3e-09426b617593',
  '3625e303-6999-531b-a096-2b8875b8d7c7',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  50, 'Republic Sign / Sign Technologies Inc founded 1992 — 34-yr tenure; family-owned per site but only ''Brent'' named as contact. Surname + age unknown; license-tenure proxy only. Multi-entity structure (parent Sign Technologies + Texarkana sister) hints at structured family operation.',
  65, 'San Antonio Bexar — multi-service: install, maintenance, LED retrofits, permitting, consulting, custom + manufactured signs. ''service, update, repair, replacement'' language = recurring revenue signal. Estimated $900K-$2.5M rev. State-licensed + fully insured.',
  45, 'Site copyright 2026 (current); no specific coasting tells confirmed from About page (only ''Brent'' named). Live fetch was successful but content thin. Per skill rules, can''t verify single-vs-multi-principal — successor verification incomplete = cap tier.',
  73, 'San Antonio Bexar baseline; low-PE-attention vertical premium; family multi-entity setup attractive to searchers.',
  56, 'C_watch', 'Republic Sign (San Antonio, founded 1992; dba of Sign Technologies Inc with Texarkana sister) is a 34-yr family-owned service-focused shop. Live About-page fetch (2026-05-16) named only ''Brent'' as contact — could not verify whether family-owned = sole-Brent or multi-principal structure. Per skill non-negotiable, B/A candidates require live team-page successor verification; ambiguous result caps at C_watch. Re-score after manual phone/email verification of principal structure.', 'If verifiable as sole-principal aging owner: AI dispatch for service routes, customer portal for service-ticket tracking, formal national-rollout-maintenance pitch leveraging the multi-state Texarkana sister footprint, modernize permitting service into recurring-revenue line.',
  'low', 0.55
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  '6e5935b8-e552-578a-836c-ff97ec5c92f9',
  'f82400dd-9b04-545f-bc32-61d23499c388',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  50, 'License-tenure proxy only (TDLR ESC #18050, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 08/18/2026); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  73, 'GRAND PRAIRIE Dallas County — sub-market nudge 1. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  51, 'C_watch', 'ACCENT GRAPHICS INC (GRAND PRAIRIE, Dallas Co.) — TDLR ESC #18050 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  '88ba0d26-2632-52d2-b459-1210f58d8f28',
  '8cbd44d8-e3ed-5d0c-9cdd-f8cd2e211653',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  50, 'License-tenure proxy only (TDLR ESC #18066, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 03/26/2027); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  73, 'HOUSTON Harris County — sub-market nudge 3. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  51, 'C_watch', 'APACHE SIGN AND SERVICE INC (HOUSTON, Harris Co.) — TDLR ESC #18066 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  '15f18734-6236-5e60-a4b8-c70860eb5c9a',
  '3e45be6f-f9de-5bef-b4ce-49e80c150d57',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  50, 'License-tenure proxy only (TDLR ESC #18044, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 06/23/2027); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  71, 'MAGNOLIA Montgomery County — sub-market nudge 1. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  51, 'C_watch', 'CENTURY SIGN BUILDERS (MAGNOLIA, Montgomery Co.) — TDLR ESC #18044 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  '0088a63b-cd79-5593-bc10-5c5216585b00',
  '166fa7a8-ec55-58d2-80d9-b419ceadda70',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  50, 'License-tenure proxy only (TDLR ESC #18074, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 12/12/2025); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  71, 'BEAUMONT Jefferson County — sub-market nudge 1. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  51, 'C_watch', 'D & S SIGN & SUPPLY, INC (BEAUMONT, Jefferson Co.) — TDLR ESC #18074 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  '7bcb27cc-3432-55b1-b509-77f58bf62cf7',
  '91790d52-5a91-5c32-9669-4f3cab980747',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  50, 'License-tenure proxy only (TDLR ESC #18012, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 10/09/2026); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  71, 'CORPUS CHRISTI Nueces County — sub-market nudge 1. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  51, 'C_watch', 'HOMEPORT SIGN SERVICE & LIGHTING MAINTEN (CORPUS CHRISTI, Nueces Co.) — TDLR ESC #18012 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  '7222c6e2-c54f-5185-b0b1-af4573da03ea',
  'db3a6aea-0256-5f3d-9fbb-faf6809defa5',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  50, 'License-tenure proxy only (TDLR ESC #18052, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 02/19/2027); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  73, 'HOUSTON Harris County — sub-market nudge 3. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  51, 'C_watch', 'INDUSTRIAL NEON SIGN (HOUSTON, Harris Co.) — TDLR ESC #18052 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  'de5182d1-cde3-5a43-8d2b-ecde6f1c3c97',
  'c7fc1313-f4a9-5052-9abd-2b1432407d9b',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  50, 'License-tenure proxy only (TDLR ESC #18067, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 05/31/2026); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  71, 'BUDA Hays County — sub-market nudge 1. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  51, 'C_watch', 'LEWIS SIGN BUILDERS, INC (BUDA, Hays Co.) — TDLR ESC #18067 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  '00757a75-b409-5a4c-9516-c9edc53c2739',
  'faedb599-f644-5818-aafa-a3afe3f0257c',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  50, 'License-tenure proxy only (TDLR ESC #18086, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 12/30/2026); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  70, 'STAFFORD Fort Bend County — sub-market nudge 0. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  51, 'C_watch', 'SCANLIN SIGN SERVICE INC (STAFFORD, Fort Bend Co.) — TDLR ESC #18086 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  '08da9bc8-92ab-5567-8e8c-deab83b2edf8',
  '2c349ea3-76d6-5afb-8dfb-c3477098e63f',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  50, 'License-tenure proxy only (TDLR ESC #18053, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 10/15/2025); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  72, 'HARLINGEN Cameron County — sub-market nudge 2. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  51, 'C_watch', 'SON & DAUGHTERS INC (HARLINGEN, Cameron Co.) — TDLR ESC #18053 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  'adf985bc-15ea-5509-a4b7-800c57a67abe',
  '0c7c2e91-4c92-53ff-b228-687c5c09be02',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  50, 'License-tenure proxy only (TDLR ESC #18027, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 06/12/2027); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  73, 'SAN ANTONIO Bexar County — sub-market nudge 3. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  51, 'C_watch', 'SOUTHWEST SIGN GROUP, INC (SAN ANTONIO, Bexar Co.) — TDLR ESC #18027 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  '6ac517e8-5a1a-5564-9c21-47abed9d8529',
  '45016f62-e870-5448-acc0-61d357051a5e',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  50, 'License-tenure proxy only (TDLR ESC #18021, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 05/21/2026); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  73, 'SAN ANTONIO Bexar County — sub-market nudge 3. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  51, 'C_watch', 'TEXAS NEON & LED SIGN COMPANY, LLC (SAN ANTONIO, Bexar Co.) — TDLR ESC #18021 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  'f13b96db-5b65-59e7-9078-41e3c448e828',
  '9566159b-33e4-5659-8504-ef278557fd00',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  50, 'License-tenure proxy only (TDLR ESC #18049, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 08/18/2026); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  73, 'HOUSTON Harris County — sub-market nudge 3. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  51, 'C_watch', 'THE SIGN FACTORY, INC (HOUSTON, Harris Co.) — TDLR ESC #18049 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  '3f288556-0396-5984-86ea-f085c6f53d67',
  '1030b03c-23b6-582e-96e4-f01a1a1ca7ba',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  50, 'License-tenure proxy only (TDLR ESC #18064, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 11/21/2026); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  73, 'HOUSTON Harris County — sub-market nudge 3. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  51, 'C_watch', 'VISUAL FX (HOUSTON, Harris Co.) — TDLR ESC #18064 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  '4d046d9d-915c-5904-a2c2-008c61865cbc',
  '4cc4e982-46fd-58d2-b135-012454813890',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  45, 'License-tenure proxy only (TDLR ESC #18100, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 01/21/2027); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  73, 'SAN ANTONIO Comal County — sub-market nudge 3. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  50, 'C_watch', 'A-1 SIGNS (SAN ANTONIO, Comal Co.) — TDLR ESC #18100 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  '5b6175ef-2902-5abc-b343-ec6cee8528f0',
  '5ab38e78-25db-516e-969c-85cbec70eae5',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  45, 'License-tenure proxy only (TDLR ESC #18199, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 02/12/2027); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  73, 'RICHLAND HILLS Tarrant County — sub-market nudge 0. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  50, 'C_watch', 'ADVANTAGE SIGNS INC (RICHLAND HILLS, Tarrant Co.) — TDLR ESC #18199 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  'cf6fe86e-ff8c-5895-858a-507fe194054e',
  '7fd7e1f6-a733-54c5-8e20-c8851c0ca0ff',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  45, 'License-tenure proxy only (TDLR ESC #18151, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 02/28/2027); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  73, 'IRVING Dallas County — sub-market nudge 1. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  50, 'C_watch', 'BYRUM SIGN & LIGHTING INC (IRVING, Dallas Co.) — TDLR ESC #18151 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  'c9126cb5-b9fd-5b04-aa46-5e6d858eb0ed',
  'eec46b48-7bef-5e2e-96d2-cf879fa43925',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  45, 'License-tenure proxy only (TDLR ESC #18156, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 07/12/2026); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  73, 'DALLAS Dallas County — sub-market nudge 3. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  50, 'C_watch', 'CITY SIGN SERVICE INC (DALLAS, Dallas Co.) — TDLR ESC #18156 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  '8552d784-0fee-5a3e-9543-d733a8f4044d',
  'b745e267-3604-5284-a231-0decba6e0a66',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  45, 'License-tenure proxy only (TDLR ESC #18202, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 04/03/2027); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  73, 'SAN ANTONIO Bexar County — sub-market nudge 3. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  50, 'C_watch', 'GENERATION SIGNS INC (SAN ANTONIO, Bexar Co.) — TDLR ESC #18202 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  '1f197c5a-0570-5d87-9e82-ab7730a1b631',
  'ffdd0144-4180-5470-9d51-776d494c9f47',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  45, 'License-tenure proxy only (TDLR ESC #18144, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 01/06/2027); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  73, 'SAN ANTONIO Bexar County — sub-market nudge 3. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  50, 'C_watch', 'KELLER CUSTOM SIGNS & DESIGNS (SAN ANTONIO, Bexar Co.) — TDLR ESC #18144 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  'f284dbde-95b9-5653-b57f-bed6172c33f6',
  '874fe81c-db36-59d8-81c6-f582b364c32b',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  45, 'License-tenure proxy only (TDLR ESC #18242, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 06/25/2027); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  73, 'RICHARDSON Dallas County — sub-market nudge 1. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  50, 'C_watch', 'MULTI-QUEST, INC (RICHARDSON, Dallas Co.) — TDLR ESC #18242 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  'bbac89b5-f788-5cb6-a874-e587363c9a59',
  'b8a40e0e-f6f2-59fb-bb98-7880be5d2f5f',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  45, 'License-tenure proxy only (TDLR ESC #18174, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 07/11/2025); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  73, 'HOUSTON Harris County — sub-market nudge 3. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  50, 'C_watch', 'NATIONAL SIGN MFG (HOUSTON, Harris Co.) — TDLR ESC #18174 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  '55ee9c02-f8ef-5b11-bba0-69d79a76d09b',
  '96426c64-3c6d-5901-90c3-401291c482cc',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  45, 'License-tenure proxy only (TDLR ESC #18243, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 08/04/2026); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  73, 'HOUSTON Harris County — sub-market nudge 3. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  50, 'C_watch', 'NP SIGN SYSTEM INC (HOUSTON, Harris Co.) — TDLR ESC #18243 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  'b108fcbf-49ba-563f-ba70-f41c3952bdd8',
  '9a78c414-eb6b-5d6b-8022-18669af7ad2f',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  45, 'License-tenure proxy only (TDLR ESC #18164, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 12/06/2026); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  73, 'FORT WORTH Tarrant County — sub-market nudge 3. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  50, 'C_watch', 'PATTISON SIGN GROUP INC DBA PATTISON ID (FORT WORTH, Tarrant Co.) — TDLR ESC #18164 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  '08e8b507-4990-5d01-a26e-9b7c74278174',
  '6fd171ac-da47-5d47-bfee-d9dd5cc42eb5',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  45, 'License-tenure proxy only (TDLR ESC #18205, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 06/21/2027); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  73, 'ARLINGTON Tarrant County — sub-market nudge 1. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  50, 'C_watch', 'PERFECT SIGNS (ARLINGTON, Tarrant Co.) — TDLR ESC #18205 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  '58d2ddc9-fb39-53cd-9670-67c5c3b23c48',
  '723939e2-fefd-534d-a092-d598b539f6ec',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  45, 'License-tenure proxy only (TDLR ESC #18120, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 10/06/2026); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  73, 'HOUSTON Harris County — sub-market nudge 3. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  50, 'C_watch', 'PRINCE SIGNS LLC (HOUSTON, Harris Co.) — TDLR ESC #18120 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  '48092e4d-41d5-5220-8a31-c175dcce46d4',
  '1c6c1252-f7b8-571b-bbc7-538f4add9eba',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  45, 'License-tenure proxy only (TDLR ESC #18130, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 03/23/2025); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  73, 'HOUSTON Harris County — sub-market nudge 3. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  50, 'C_watch', 'REGAN ELECTRIC SIGN CO (HOUSTON, Harris Co.) — TDLR ESC #18130 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  '23a6f37a-50fc-5e3f-bf77-d00c09c668ce',
  'acd8648a-c668-5e30-92cb-6d41b5595d3e',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  45, 'License-tenure proxy only (TDLR ESC #18132, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 12/22/2026); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  73, 'HOUSTON Harris County — sub-market nudge 3. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  50, 'C_watch', 'RELIABLE SIGN & ENGRAVING (HOUSTON, Harris Co.) — TDLR ESC #18132 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  'e0509642-8d71-5115-9d9b-c46f35f31e28',
  'e18ae397-3ffc-5a4a-8d5d-a9375f60f36a',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  45, 'License-tenure proxy only (TDLR ESC #18133, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 11/13/2026); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  73, 'HOUSTON Harris County — sub-market nudge 3. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  50, 'C_watch', 'SONG SIGNS INC (HOUSTON, Harris Co.) — TDLR ESC #18133 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  '6b21a371-958e-5f4d-b9a8-bbcf0953a649',
  '3c0ec7d1-deeb-5215-a33f-110b677130ea',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  45, 'License-tenure proxy only (TDLR ESC #18110, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 11/11/2026); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  73, 'SAN ANTONIO Bexar County — sub-market nudge 3. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  50, 'C_watch', 'SOUTHWEST TEXAS SIGN SERVICE, INC (SAN ANTONIO, Bexar Co.) — TDLR ESC #18110 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  'ad8eb3b8-0290-551e-8aaa-f7d3349b324f',
  '5a0ae6a1-add7-5da8-88a2-8286ba71b3fb',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  45, 'License-tenure proxy only (TDLR ESC #18226, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 06/10/2026); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  73, 'RICHARDSON Dallas County — sub-market nudge 1. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  50, 'C_watch', 'STA ADVERTISING GROUP (RICHARDSON, Dallas Co.) — TDLR ESC #18226 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  '7da8c248-5a0f-500f-983d-a56e844fd8fe',
  '89e69b57-5034-52e9-b9ff-7606ab47bc48',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  45, 'License-tenure proxy only (TDLR ESC #18197, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 01/10/2027); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  73, 'GRAND PRARIE Dallas County — sub-market nudge 0. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  50, 'C_watch', 'TURNER SIGN SYSTEMS (GRAND PRARIE, Dallas Co.) — TDLR ESC #18197 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  'c3b9c0ef-f691-50c4-9f6e-b3d6049a0bac',
  'b26bc4df-db12-5627-83b2-c8bc63f77f89',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  45, 'License-tenure proxy only (TDLR ESC #18235, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 09/22/2026); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  72, 'EL PASO El Paso County — sub-market nudge 2. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  49, 'C_watch', 'A & A SIGNS (EL PASO, El Paso Co.) — TDLR ESC #18235 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  '3594ef35-e798-572f-b4b2-a0017537e845',
  '0fa37c61-2149-5814-8635-fff2c3eabe7a',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  45, 'License-tenure proxy only (TDLR ESC #18193, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 01/05/2027); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  71, 'KATY Fort Bend County — sub-market nudge 1. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  49, 'C_watch', 'AD DISPLAY SIGN SYSTEMS INC (KATY, Fort Bend Co.) — TDLR ESC #18193 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  '3d25c225-f1ae-55b4-a347-f4ac16914dac',
  'cacedff9-9224-5c4c-bf60-18dc637d7e8c',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  45, 'License-tenure proxy only (TDLR ESC #18189, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 12/13/2026); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  72, 'EL PASO El Paso County — sub-market nudge 2. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  49, 'C_watch', 'EDDIE WEARDEN, INC (EL PASO, El Paso Co.) — TDLR ESC #18189 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  '88e04484-2e69-5651-91f5-17667c20be08',
  'a00fbb4f-33f5-5044-8917-f9d36e24819f',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  45, 'License-tenure proxy only (TDLR ESC #18225, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 07/22/2026); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  72, 'EL PASO El Paso County — sub-market nudge 2. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  49, 'C_watch', 'ELECTRIC NEON SIGNS (EL PASO, El Paso Co.) — TDLR ESC #18225 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  'a38effbd-f190-587b-af01-b13306f38f3b',
  '18708dfc-17bc-588c-bc10-03fa29cb4750',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  45, 'License-tenure proxy only (TDLR ESC #18248, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 03/11/2027); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  72, 'HARLINGEN Cameron County — sub-market nudge 2. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  49, 'C_watch', 'LAMAR TEXAS LIMITED PARTNERSHIP (HARLINGEN, Cameron Co.) — TDLR ESC #18248 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  '7c6276f8-b1ec-5cf5-b421-54e56b6c8ea4',
  'cac0d3d2-1fc7-5730-9e71-d77571d6349b',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  45, 'License-tenure proxy only (TDLR ESC #18115, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 09/27/2026); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  70, 'GEORGETOWN Williamson County — sub-market nudge 0. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  49, 'C_watch', 'LIBERTY SIGNS INC (GEORGETOWN, Williamson Co.) — TDLR ESC #18115 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  '62b269fe-6cb5-5013-82c5-98ea63f0b4d7',
  'fa59704d-3b40-588d-a552-38fc54cca470',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  45, 'License-tenure proxy only (TDLR ESC #18146, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 05/05/2027); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  70, 'PINEHURST Montgomery County — sub-market nudge 0. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  49, 'C_watch', 'MCP NEON & SIGN (PINEHURST, Montgomery Co.) — TDLR ESC #18146 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  '99987f40-5085-52dd-b381-45716a2e4770',
  '65cff51e-a061-5704-8f1b-884cd533ff09',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  45, 'License-tenure proxy only (TDLR ESC #18185, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 05/31/2026); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  71, 'CONROE Montgomery County — sub-market nudge 1. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  49, 'C_watch', 'SIGN REMEDY INC (CONROE, Montgomery Co.) — TDLR ESC #18185 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  '6a02b83a-65c4-5e80-ab27-ba135355f2b6',
  'c07bce10-54f0-50a6-9304-ac7695db09ca',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  45, 'License-tenure proxy only (TDLR ESC #18220, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 01/27/2027); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  72, 'LAREDO Webb County — sub-market nudge 2. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  49, 'C_watch', 'SOUTH TEXAS NEON SIGN CO INC (LAREDO, Webb Co.) — TDLR ESC #18220 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  '5b9b2e2e-4148-5347-b3b5-d8e7b6f0aa16',
  '0f0bbf9e-818d-5e61-9c42-b4bb0a7c9f76',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  45, 'License-tenure proxy only (TDLR ESC #18159, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 11/20/2026); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  70, 'NEW BRAUNFELS Comal County — sub-market nudge 0. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  49, 'C_watch', 'U S SIGNS (NEW BRAUNFELS, Comal Co.) — TDLR ESC #18159 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  'c99de6ee-d8fb-51fc-8326-a629e9334388',
  'a540a43e-12b5-5fb6-9cb6-61b634fa432f',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  40, 'License-tenure proxy only (TDLR ESC #18262, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 02/15/2027); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  71, 'CONROE Montgomery County — sub-market nudge 1. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  48, 'C_watch', 'ADVERTISING HIGHER DBA (CONROE, Montgomery Co.) — TDLR ESC #18262 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  'ccb6e4a7-659a-5cd9-ae07-1d8da08ee43b',
  'f6500175-64d8-5294-9907-ec4c91fb4855',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  40, 'License-tenure proxy only (TDLR ESC #18286, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 12/27/2026); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  73, 'DALLAS Dallas County — sub-market nudge 3. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  48, 'C_watch', 'ARTOGRAFX, INC. (DALLAS, Dallas Co.) — TDLR ESC #18286 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  '85887b9f-1c4d-563f-98be-6d8a47db21d2',
  'ff2d8db6-0e7d-5bd2-a1f6-d43afa53727f',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  40, 'License-tenure proxy only (TDLR ESC #18376, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 11/09/2026); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  73, 'AUSTIN Travis County — sub-market nudge 3. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  48, 'C_watch', 'AUTOMATED DISPLAY SYSTEMS LP (AUSTIN, Travis Co.) — TDLR ESC #18376 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  'a2b0071c-127e-5f27-a2ca-301607c93ff4',
  '03593600-1e2e-5531-8aa6-5e9a817570df',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  40, 'License-tenure proxy only (TDLR ESC #18365, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 11/13/2026); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  73, 'FT WORTH Tarrant County — sub-market nudge 3. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  48, 'C_watch', 'BAKER SIGN COMPANY (FT WORTH, Tarrant Co.) — TDLR ESC #18365 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  'd987ef15-0c9d-5498-97e6-fef89465f0f3',
  '079d5746-3165-57b4-b7c7-93f726fee8dd',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  40, 'License-tenure proxy only (TDLR ESC #18374, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 09/23/2026); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  71, 'SPRING Montgomery County — sub-market nudge 1. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  48, 'C_watch', 'BEACON SOLUTIONS GROUP LLC (SPRING, Montgomery Co.) — TDLR ESC #18374 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  'b965f28c-e577-5b50-8109-c4fe816f26fa',
  '3a05064f-1fe9-5695-bb95-e59b4e5ae21f',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  40, 'License-tenure proxy only (TDLR ESC #18378, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 12/15/2026); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  73, 'HOUSTON Harris County — sub-market nudge 3. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  48, 'C_watch', 'BRAZO SIGN COMPANY LLC (HOUSTON, Harris Co.) — TDLR ESC #18378 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  '9034cca6-fe71-5e17-82d3-4c1b740d2409',
  '4a478d99-4a95-5758-a29e-e4d4ba26448d',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  40, 'License-tenure proxy only (TDLR ESC #18350, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 01/24/2027); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  73, 'AUSTIN Travis County — sub-market nudge 3. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  48, 'C_watch', 'BUILDING IMAGE GROUP INC (AUSTIN, Travis Co.) — TDLR ESC #18350 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  'a5bb8a4c-d32e-59b6-9349-6d34d3bd2300',
  '75d7becc-de50-5537-8e5d-1565852a1d99',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  40, 'License-tenure proxy only (TDLR ESC #18320, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 02/14/2027); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  73, 'DEER PARK Harris County — sub-market nudge 0. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  48, 'C_watch', 'CLASSIC SIGN COMPANY (DEER PARK, Harris Co.) — TDLR ESC #18320 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  'b6af7008-d6c7-59e3-99ef-d3beec83d814',
  'ba1b5679-5090-5082-91db-e61465c3e519',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  40, 'License-tenure proxy only (TDLR ESC #18348, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 06/05/2027); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  71, 'TEXAS CITY Galveston County — sub-market nudge 1. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  48, 'C_watch', 'CREATIVE & CAASCO SIGNS, INC (TEXAS CITY, Galveston Co.) — TDLR ESC #18348 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  '258fbdb0-7083-503c-b9d0-ebdf94509d7f',
  'eed3391e-c041-50d9-852a-843dc9fb05dd',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  40, 'License-tenure proxy only (TDLR ESC #18390, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 03/12/2027); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  73, 'ROWLETT Dallas County — sub-market nudge 1. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  48, 'C_watch', 'DATATRONIC CONTROL INC (ROWLETT, Dallas Co.) — TDLR ESC #18390 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  '9f9c0ee1-c930-5100-90d5-3089f6ee4ad2',
  '571bb51c-78a9-5fd2-b091-6c28a8a7c90a',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  40, 'License-tenure proxy only (TDLR ESC #18352, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 05/31/2027); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  73, 'GRAND PRAIRIE Dallas County — sub-market nudge 1. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  48, 'C_watch', 'ENTECH SIGNS-ALPHA LED LLC (GRAND PRAIRIE, Dallas Co.) — TDLR ESC #18352 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  'e33ac398-df74-53cb-b601-4918273a11f0',
  'ff0af4b6-9b9d-5345-ba44-3c52965a552e',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  40, 'License-tenure proxy only (TDLR ESC #18330, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 04/06/2027); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  70, 'SAN MARCOS Hays County — sub-market nudge 0. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  48, 'C_watch', 'EXECUTIVE SIGNS ENTERPRISES INC (SAN MARCOS, Hays Co.) — TDLR ESC #18330 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  'dbabb044-fa5c-5e42-a6b6-23df08d66727',
  'b82ff66e-12a9-5e90-ba75-d40cd9be6a96',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  40, 'License-tenure proxy only (TDLR ESC #18407, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 12/06/2026); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  73, 'HOUSTON Harris County — sub-market nudge 3. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  48, 'C_watch', 'EZZI SIGNS INC. (HOUSTON, Harris Co.) — TDLR ESC #18407 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  'bbb2954d-ca20-5d8d-b54a-b7531396872b',
  '0d37cc78-d3cd-58d4-b9d3-aeeb6cbfdf28',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  40, 'License-tenure proxy only (TDLR ESC #18398, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 04/17/2027); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  72, 'PHARR Hidalgo County — sub-market nudge 2. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  48, 'C_watch', 'FRANK''S SIGN CO (PHARR, Hidalgo Co.) — TDLR ESC #18398 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  '6f7d0816-c37b-59c7-ab01-9add43e56a37',
  '29b051d2-62f2-546a-8dae-8b640d45a98f',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  40, 'License-tenure proxy only (TDLR ESC #18385, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 04/16/2027); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  73, 'HOUSTON Harris County — sub-market nudge 3. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  48, 'C_watch', 'FUTURE SIGN CO (HOUSTON, Harris Co.) — TDLR ESC #18385 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  'e2d15237-4981-5284-bcec-0a798c49a291',
  '5b4c2822-5def-5305-808a-aca4f3567794',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  40, 'License-tenure proxy only (TDLR ESC #18360, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 04/12/2027); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  73, 'HOUSTON Harris County — sub-market nudge 3. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  48, 'C_watch', 'GRAPHTEC INC (HOUSTON, Harris Co.) — TDLR ESC #18360 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  'bc7b7a05-3657-5ddf-a0a7-889b91cefa62',
  '81b4b782-7e05-53aa-b72b-3c62a1b83509',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  40, 'License-tenure proxy only (TDLR ESC #18379, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 11/20/2026); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  72, 'EDINBURG Hidalgo County — sub-market nudge 2. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  48, 'C_watch', 'GTO SIGNS & SERVICE (EDINBURG, Hidalgo Co.) — TDLR ESC #18379 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  '1cfbdcc8-80f2-5dcb-95ef-bc4f2e63950e',
  '62e349c3-a2b4-5c67-9966-96e8aa3fb32d',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  40, 'License-tenure proxy only (TDLR ESC #18285, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 12/10/2026); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  70, 'SAN BENITO Cameron County — sub-market nudge 0. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  48, 'C_watch', 'GULF COAST SIGN CO, INC (SAN BENITO, Cameron Co.) — TDLR ESC #18285 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  '8cd088c0-43ac-53b3-a3a9-97cf11d17f76',
  '8559684f-4b63-51ac-9b55-ba003d987907',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  40, 'License-tenure proxy only (TDLR ESC #18349, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 06/12/2027); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  73, 'HOUSTON Harris County — sub-market nudge 3. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  48, 'C_watch', 'HATIMI CORP DBA SMB SIGNS & BANNERS (HOUSTON, Harris Co.) — TDLR ESC #18349 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  'c7fa621d-a9aa-5231-ac8e-e199dc1d1b61',
  '942b5403-9ff4-57eb-a265-006ff30822a8',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  40, 'License-tenure proxy only (TDLR ESC #18263, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 01/19/2027); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  73, 'AUSTIN Travis County — sub-market nudge 3. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  48, 'C_watch', 'HOLLIFIELD SIGNS (AUSTIN, Travis Co.) — TDLR ESC #18263 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  'a56a503b-07e1-59f1-98f6-8f9a6897c945',
  '5da8b245-9301-5624-a7f5-c744dca4bfbc',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  40, 'License-tenure proxy only (TDLR ESC #18335, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 02/17/2027); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  71, 'CORPUS CHRISTI Nueces County — sub-market nudge 1. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  48, 'C_watch', 'INNOVATIVE SIGN DESIGNS LLC (CORPUS CHRISTI, Nueces Co.) — TDLR ESC #18335 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  '99ddce9c-ab5d-5bf1-950e-55c284b3fd7b',
  '6692428e-4b6d-561b-bf3a-01353f3a973b',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  40, 'License-tenure proxy only (TDLR ESC #18274, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 01/13/2026); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  72, 'EL PASO El Paso County — sub-market nudge 2. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  48, 'C_watch', 'INTERNATIONAL NEON SIGN CO (EL PASO, El Paso Co.) — TDLR ESC #18274 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  '9d81b82a-d6eb-56bf-ae85-9ab7f4d2ad63',
  'ee9562b4-121b-5af8-8934-6f3be214e82e',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  40, 'License-tenure proxy only (TDLR ESC #18295, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 02/19/2027); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  70, 'RICHMOND Fort Bend County — sub-market nudge 0. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  48, 'C_watch', 'INTEX UNITED, INC. (RICHMOND, Fort Bend Co.) — TDLR ESC #18295 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  'da8feab1-f79d-5012-8781-8d373b25bfb9',
  '09ee7caa-332a-5aee-ab48-b04f2183f940',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  40, 'License-tenure proxy only (TDLR ESC #18341, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 06/27/2026); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  73, 'AUSTIN Travis County — sub-market nudge 3. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  48, 'C_watch', 'ION ART INC (AUSTIN, Travis Co.) — TDLR ESC #18341 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  '45eb51b6-d875-5746-bde4-5a7e0cf07423',
  '2d15fb94-5d77-5736-b1cd-cafef63a062e',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  40, 'License-tenure proxy only (TDLR ESC #18388, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 02/07/2027); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  73, 'DALLAS Dallas County — sub-market nudge 3. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  48, 'C_watch', 'JAMES SUNG INC DBA J ART SIGN CO (DALLAS, Dallas Co.) — TDLR ESC #18388 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  '708ab0a0-c984-5149-bd34-98a1a6e894a6',
  '4c86d607-3cd8-5dc4-a7fb-052066d1c929',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  40, 'License-tenure proxy only (TDLR ESC #18306, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 10/19/2026); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  73, 'CYPRESS Harris County — sub-market nudge 1. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  48, 'C_watch', 'LOZANO SIGNS (CYPRESS, Harris Co.) — TDLR ESC #18306 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  'f531683d-1543-5317-8551-791cd3a36bf1',
  'd577c685-74be-5531-b425-4657a6f1956f',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  40, 'License-tenure proxy only (TDLR ESC #18384, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 01/07/2027); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  73, 'SOMERSET Bexar County — sub-market nudge 0. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  48, 'C_watch', 'M A D DESIGNS (SOMERSET, Bexar Co.) — TDLR ESC #18384 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  'e669044d-ba4c-53e0-a41b-60769d09f004',
  '1aae9105-bf6a-5f83-90d4-fd539a8d1d9a',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  40, 'License-tenure proxy only (TDLR ESC #18403, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 08/19/2026); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  73, 'DALLAS Dallas County — sub-market nudge 3. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  48, 'C_watch', 'MASTERCO, INC (DALLAS, Dallas Co.) — TDLR ESC #18403 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  '1c7343ab-8704-5c49-b33d-3eba2dc1c34b',
  '911d6584-8743-501b-a340-eecd0228c0ad',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  40, 'License-tenure proxy only (TDLR ESC #18266, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 11/02/2026); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  73, 'EULESS Tarrant County — sub-market nudge 0. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  48, 'C_watch', 'OLEN WILLIAMS INC (EULESS, Tarrant Co.) — TDLR ESC #18266 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  'aeb18f70-acbe-5a4b-80a4-00e5d300ccde',
  'c3e02a14-7a11-5805-9bba-d98d6dc15fd1',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  40, 'License-tenure proxy only (TDLR ESC #18291, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 05/06/2027); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  72, 'EL PASO El Paso County — sub-market nudge 2. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  48, 'C_watch', 'RICK''S SIGN SHOP (EL PASO, El Paso Co.) — TDLR ESC #18291 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  '2fa27376-3391-56a5-8129-7b58da1b13eb',
  '353f2f2a-7cfd-5b92-b6fd-0e0834119b66',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  40, 'License-tenure proxy only (TDLR ESC #18287, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 01/10/2027); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  73, 'EULESS Tarrant County — sub-market nudge 0. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  48, 'C_watch', 'SIGN ERECTION LTD (EULESS, Tarrant Co.) — TDLR ESC #18287 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  '42283c4d-d7e4-55e1-9cbb-8cd20d005c74',
  'fef713ef-72bc-5cd1-b322-18a2d6d9bcfc',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  40, 'License-tenure proxy only (TDLR ESC #18319, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 02/06/2027); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  73, 'HOUSTON Harris County — sub-market nudge 3. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  48, 'C_watch', 'SIGN METRO (HOUSTON, Harris Co.) — TDLR ESC #18319 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  '572ebfed-9cdd-5c50-a1e8-587d0d798b07',
  'af14b432-8384-5c35-9fd3-0e9ed0a779bd',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  40, 'License-tenure proxy only (TDLR ESC #18334, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 07/23/2026); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  70, 'SELMA Guadalupe County — sub-market nudge 0. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  48, 'C_watch', 'SIGNTEK INC. (SELMA, Guadalupe Co.) — TDLR ESC #18334 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  '19198a68-c851-56ae-8ed9-c84d3fce6287',
  'efdf7c86-0e34-5aaa-b060-879d55832948',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  40, 'License-tenure proxy only (TDLR ESC #18280, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 01/19/2027); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  71, 'CORPUS CHRISTI Nueces County — sub-market nudge 1. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  48, 'C_watch', 'SOTO SIGNS (CORPUS CHRISTI, Nueces Co.) — TDLR ESC #18280 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  'afd3a894-827a-5fc3-b8f0-4a67cd86b1e7',
  'e7aeb4f6-4024-5a66-bfe5-0199ca809a17',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  40, 'License-tenure proxy only (TDLR ESC #18359, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 10/16/2026); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  72, 'BROWNSVILLE Cameron County — sub-market nudge 2. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  48, 'C_watch', 'SRS ADVERTISING (BROWNSVILLE, Cameron Co.) — TDLR ESC #18359 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  '3e9aa063-b791-50cd-a1d4-72c2a4801185',
  'd80e8dd9-7a0a-5e5b-ba3e-a80137d39fc4',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  40, 'License-tenure proxy only (TDLR ESC #18361, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 06/09/2027); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  71, 'CEDAR PARK Williamson County — sub-market nudge 1. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  48, 'C_watch', 'TEXAS CUSTOM SIGNS LTD (CEDAR PARK, Williamson Co.) — TDLR ESC #18361 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  '62e39c7d-5242-5250-b07d-4cc0585bda71',
  '77ec1acf-37e9-57d3-8176-b709cd5cbf71',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  40, 'License-tenure proxy only (TDLR ESC #18363, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 08/23/2026); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  73, 'HOUSTON Harris County — sub-market nudge 3. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  48, 'C_watch', 'UNITED SIGNS (HOUSTON, Harris Co.) — TDLR ESC #18363 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  'fe1b5dcf-b2c6-5da7-9998-b69aeee6ebed',
  '2e28c3b2-4209-5905-b056-3cc57fe09b65',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  40, 'License-tenure proxy only (TDLR ESC #18282, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. ',
  55, 'Active TX Electrical Sign Contractor license (current expiration 01/25/2027); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  73, 'HOUSTON Harris County — sub-market nudge 3. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  48, 'C_watch', 'UNITY SIGNS (HOUSTON, Harris Co.) — TDLR ESC #18282 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  'f8f98b63-0532-5a57-942b-88fcb6d89bdf',
  '9efc8426-eabb-5288-9afe-5bbb6a365b02',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  32, 'License-tenure proxy only (TDLR ESC #18307, est. issuance 2003, ~23 yrs). Owner identity + age unverified in this run. Legal name suggests multi-generation family (''& Sons/Bros/Family'' pattern), nudged down for likely internal succession.',
  55, 'Active TX Electrical Sign Contractor license (current expiration 08/29/2026); located in TX metro/sub-market. SBA-band size + recurring-revenue mix not verified this run; scored as default-healthy operating business.',
  38, 'Live team-page fetch + Wayback diff + customer portal check not completed in this run. Per skill protocol, cap confidence at low and tier at C_watch until verification completes.',
  73, 'SAN ANTONIO Bexar County — sub-market nudge 3. Low-PE-attention sign vertical = quiet rollup target = better entry multiples (3-5x EBITDA range); ETA/search-fund appetite growing.',
  46, 'C_watch', 'BRATTON BROS SIGN CO (SAN ANTONIO, Bexar Co.) — TDLR ESC #18307 (~23 yrs license tenure). Spine row not deep-enriched this run; conservative-default scoring lands at C_watch. Re-fetch live website + team page + Comptroller status before promoting to A/B.', 'If verified active with sole-principal aging owner: AI quote engine, online intake, customer portal for service tickets, formalize maintenance-contract revenue, LED-retrofit upsell program for existing channel-letter installed base. Vertical-level: low-PE-attention = better acquisition economics vs hotter trades.',
  'low', 0.32
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  '8cd273c0-c6a0-50aa-bcdf-24a1d07a898d',
  '90a6351e-bb6b-57b2-bc33-8f7389fdae28',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  30, 'Walton family multi-generation (predecessor 1934; current 1980, ~46 yrs). Family multi-gen succession in place — Gary Walton''s grandfather founded; line continues. Not a natural-exit candidate.',
  30, 'Healthy but ~$40M revenue per Konaequity — exceeds SBA 7(a) $5M ceiling; this is a platform-scale enterprise, not SBA territory.',
  20, 'Modern website, broad service mix (45+ years implementing brands across multiple sectors), active national-account program. No coasting tells.',
  30, 'Large national sign company — TX commercial signage rollup is quiet (low PE attention vertical) but Walton itself is roll-up-acquirer-size, not target-size.',
  27, 'D_pass', 'Walton Signage (San Antonio, founded 1980 by Gary Walton building on 1934 predecessor) is a $40M+ national sign company servicing restaurant/retail/bank multi-location accounts — far above SBA 7(a) acquisition range. Multi-generation family ownership confirmed via public records. D_pass on size gate alone; would only be a strategic-buyer or PE platform-level transaction.', 'N/A — out of target size band.',
  'high', 0.85
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  'ca6aac7b-dcee-5c03-bd23-42ae8e62b099',
  '113211bb-45b0-5126-9a86-cb927b05971f',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  15, 'Federal Heath traces to 1901; current company is multi-state with HQ Hurst TX and ~500 employees. Not a single-founder natural-exit candidate.',
  30, '500 employees + 5-state mfg footprint + national customer base — estimated $75M+ rev. Far above SBA 7(a) $5M ceiling.',
  10, 'Active national operations — no coasting signals.',
  20, 'Platform-scale; out of off-market thesis.',
  18, 'D_pass', 'Federal Heath Sign Company (Hurst TX HQ; Houston branch) traces founding to 1901 and currently operates with ~500 employees across 5-state manufacturing facilities (TX, OH, MI, WI). This is a national mfg enterprise (~$75M+ rev) — far above SBA 7(a) target. D_pass on size gate.', 'N/A — out of target size band.',
  'high', 0.8
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
INSERT INTO offmarket.business_scores (
  id, business_id, score_run_id,
  layer1_base_rate, layer1_comment,
  layer2_sellability, layer2_comment,
  layer3_behavioral_trigger, layer3_comment,
  layer4_market_pull, layer4_comment,
  final_score, final_tier, final_comment, value_add_thesis,
  confidence, data_completeness
) VALUES (
  '162e6fed-7cf7-54d5-9c49-7c7d65b0eb70',
  '1d952390-ba38-5805-b40a-a653a712ea81',
  '0b92ff99-cec4-4878-8c30-99378609acbb',
  10, 'Comet Signs founded 1958 by Arthur Sitterle Jr.; leadership passed to Arthur ''Pete'' Sitterle III in 1990s; **acquired by Stratus Unlimited in December 2022**. Owner-of-record is now a PE platform, not an aging individual.',
  30, 'Multi-location TX sign manufacturer (5 facilities, 250k+ sqft mfg). Healthy but platform-scale; already rolled up.',
  10, 'Stratus-acquired entity — no coasting tells apply; this is a corporate subsidiary actively integrating with parent''s national accounts program.',
  20, 'Already rolled up — not an off-market target.',
  16, 'D_pass', 'Comet Signs (San Antonio, founded 1958 by Sitterle family) was acquired by Stratus Unlimited (Vestar Capital Partners-backed PE roll-up) in December 2022. This is now a platform subsidiary operating 5 TX facilities under the Stratus umbrella — already rolled up, not an off-market acquisition target. D_pass per skill exclusion rule for platform subsidiaries.', 'N/A — already acquired.',
  'high', 0.85
)
ON CONFLICT (business_id, score_run_id) DO UPDATE SET
  layer1_base_rate = EXCLUDED.layer1_base_rate,
  layer1_comment = EXCLUDED.layer1_comment,
  layer2_sellability = EXCLUDED.layer2_sellability,
  layer2_comment = EXCLUDED.layer2_comment,
  layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
  layer3_comment = EXCLUDED.layer3_comment,
  layer4_market_pull = EXCLUDED.layer4_market_pull,
  layer4_comment = EXCLUDED.layer4_comment,
  final_score = EXCLUDED.final_score,
  final_tier = EXCLUDED.final_tier,
  final_comment = EXCLUDED.final_comment,
  value_add_thesis = EXCLUDED.value_add_thesis,
  confidence = EXCLUDED.confidence,
  data_completeness = EXCLUDED.data_completeness;
COMMIT;
