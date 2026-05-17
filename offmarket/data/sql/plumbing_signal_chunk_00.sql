INSERT INTO offmarket.business_signals (business_id, layer, signal_key, direction, evidence, source, source_url, observed_at)
VALUES (
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='David Hicks Plumbing' AND city='Houston' AND state='TX'),
  3, 'successor_check_live_fetch', 'positive',
  'Strong coasting tells: (a) NO membership plan or recurring service agreement visible on davidhicksplumbing.com (fetched 2026-05-16); (b) NO true online booking, only ''Request Service'' contact form; (c) NO team/about page with named staff or 3rd-gen Hicks; (d) website style is dated minimalist (Wayback-style 2018+ template); (e) phone-first intake. 74-yr-old shop with no modernization stack = classic disengaged-2nd-gen-owner profile.',
  'live_website_fetch', 'https://davidhicksplumbing.com/', '2026-05-16'
);

INSERT INTO offmarket.business_signals (business_id, layer, signal_key, direction, evidence, source, source_url, observed_at)
VALUES (
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='JOHNS PLUMBING INC' AND city='Houston' AND state='TX'),
  3, 'successor_check_live_fetch', 'positive',
  'EXTREME coasting tells: (a) johnsplumbing-houston.com is a TEMPLATE WEBSITE with literal placeholder text ''Say something interesting about your business here'' and ''What''s a product or service you''d like to show'' — owner has invested ZERO in modernization; (b) no team/about page; (c) no membership plan; (d) no online booking; (e) no SMS dispatch tech; (f) phone-only intake. 44-yr-old shop with template website = the textbook ''disengaged solo owner stopped pushing'' profile. 5 strong coasting tells stacked.',
  'live_website_fetch', NULL, '2026-05-16'
);

INSERT INTO offmarket.business_signals (business_id, layer, signal_key, direction, evidence, source, source_url, observed_at)
VALUES (
  (SELECT id FROM offmarket.businesses WHERE vertical='plumbing' AND legal_name='CK PLUMBING LLC DBA CLARK KENT PLUMBING INC' AND city='Austin' AND state='TX'),
  3, 'successor_check_live_fetch', 'positive',
  'At $10.6M revenue with 15 employees in 2026, the absence of a customer membership plan, the absence of true online booking (only contact form on clarkekentplumbing.com fetched 2026-05-16), and the absence of named technicians on the About page are SIGNIFICANT coasting tells. Modern plumbing shops at this scale all have ServiceTitan + Housecall Pro membership programs + technician hiring funnels. The Hacker-Clarke partnership has stopped pushing modernization in the last 5-7 years per the static About page tone.',
  'live_website_fetch', NULL, '2026-05-16'
);