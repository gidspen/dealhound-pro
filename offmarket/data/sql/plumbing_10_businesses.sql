
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  'bf539957-9bc0-5eca-9ca9-e2b1360325ed', 'plumbing', 'Santhoff Plumbing Company', 'Santhoff Plumbing',
  '238220', NULL, 'Houston', 'Harris',
  'TX', NULL, '(713) 665-4997', 'https://www.santhoffplumbingco.com/',
  NULL, 'RMP', 'Current',
  NULL, 'Joe Santhoff', NULL,
  NULL, 52,
  16, 3,
  'website_team_page_or_buildzoom_or_dnb', 'Joe Santhoff',
  72, 'biz_history_proxy',
  52, FALSE,
  '[]'::jsonb, '[{"source": "website", "url": "https://www.santhoffplumbingco.com/about-us/", "fetched_at": "2026-05-15", "fields": ["legal_name", "year_established", "license_holder_name"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "Veteran-owned, family-operated since 1974. Owner/operator Joe Santhoff (Master Plumber). 50+ years tenure. Houston metro.", "spine_id": "plm-001"}'::jsonb,
  'Veteran-owned, family-operated since 1974. Owner/operator Joe Santhoff (Master Plumber). 50+ years tenure. Houston metro.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  'bc02d5b4-754d-5976-b66f-836664c41f2d', 'plumbing', 'Strutton Plumbing Company, Inc.', 'Strutton Plumbing',
  '238220', NULL, 'Houston', 'Harris',
  'TX', NULL, NULL, 'https://www.struttonplumbing.com/',
  NULL, 'RMP', 'Current',
  NULL, NULL, NULL,
  NULL, 55,
  8, 2,
  'website_team_page_or_buildzoom_or_dnb', NULL,
  70, 'biz_history_proxy',
  55, FALSE,
  '[]'::jsonb, '[{"source": "web_search_snippet", "url": "https://www.google.com/search?q=Strutton+Plumbing+Houston", "fetched_at": "2026-05-15", "fields": ["legal_name", "year_established"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "Family owned and operated since 1971. Houston-based; serving over 50 yrs.", "spine_id": "plm-002"}'::jsonb,
  'Family owned and operated since 1971. Houston-based; serving over 50 yrs.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '6d817d25-b0af-5873-91e5-83c5019a0810', 'plumbing', 'The Lindsay Company Plumbing', NULL,
  '238220', NULL, 'Cypress', 'Harris',
  'TX', NULL, NULL, 'https://www.lindsayplumbing.com/',
  NULL, 'RMP', 'Current',
  NULL, NULL, NULL,
  NULL, 44,
  8, 1,
  'website_team_page_or_buildzoom_or_dnb', NULL,
  65, 'biz_history_proxy',
  44, FALSE,
  '[]'::jsonb, '[{"source": "website", "url": "https://www.lindsayplumbing.com/", "fetched_at": "2026-05-15", "fields": ["legal_name", "year_established"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "Family-owned and operated since 1982. NW Houston; serves Cypress, Katy, Sugar Land, Spring, Tomball, The Woodlands.", "spine_id": "plm-003"}'::jsonb,
  'Family-owned and operated since 1982. NW Houston; serves Cypress, Katy, Sugar Land, Spring, Tomball, The Woodlands.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '59a9a252-cd1a-5970-a37a-e04579260ff6', 'plumbing', 'Cooper Plumbing', NULL,
  '238220', NULL, 'Houston', 'Harris',
  'TX', NULL, NULL, NULL,
  NULL, 'RMP', 'Current',
  NULL, NULL, NULL,
  NULL, NULL,
  3, 1,
  'website_team_page_or_buildzoom_or_dnb', NULL,
  NULL, 'unverified',
  NULL, FALSE,
  '[]'::jsonb, '[{"source": "web_search_snippet", "url": "https://www.google.com/search?q=Cooper+Plumbing+Houston", "fetched_at": "2026-05-15", "fields": ["legal_name"]}]'::jsonb,
  '{"platform_check": "unverified", "verification_notes": "Family-owned Houston plumbing. Common name \u2014 needs further verification in enrichment phase.", "spine_id": "plm-004"}'::jsonb,
  'Family-owned Houston plumbing. Common name — needs further verification in enrichment phase.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '5d223a7d-aa5a-5b74-9913-fd79544c2b18', 'plumbing', 'Nick''s Plumbing Services', 'Nick''s Plumbing',
  '238220', NULL, 'Houston', 'Harris',
  'TX', NULL, NULL, 'https://www.nicksplumbing.com/',
  NULL, 'RMP', 'Current',
  NULL, NULL, NULL,
  NULL, 47,
  22, 3,
  'website_team_page_or_buildzoom_or_dnb', NULL,
  60, 'biz_history_proxy',
  47, FALSE,
  '[]'::jsonb, '[{"source": "website", "url": "https://www.nicksplumbing.com/", "fetched_at": "2026-05-15", "fields": ["legal_name", "sub_trade"]}]'::jsonb,
  '{"platform_check": "needs_verification", "verification_notes": "Family-owned per site. Four decades of reviews. Serves Galleria, Bellaire, Memorial neighborhoods. Verify platform affiliation in enrichment.", "spine_id": "plm-005"}'::jsonb,
  'Family-owned per site. Four decades of reviews. Serves Galleria, Bellaire, Memorial neighborhoods. Verify platform affiliation in enrichment.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  'ee918259-2025-5af4-a3e6-e3b1b8bd7ca0', 'plumbing', 'Wedgeworth Plumbing', NULL,
  '238220', NULL, 'Houston', 'Harris',
  'TX', NULL, NULL, 'https://wedgeworthplumbing.com/',
  NULL, 'RMP', 'Current',
  NULL, NULL, NULL,
  NULL, 45,
  14, 2,
  'website_team_page_or_buildzoom_or_dnb', NULL,
  55, 'biz_history_proxy',
  25, FALSE,
  '[]'::jsonb, '[{"source": "website", "url": "https://wedgeworthplumbing.com/", "fetched_at": "2026-05-15", "fields": ["legal_name"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "Houston-area plumber. Serves Katy, Memorial, Heights, Montrose, West-U, Sugar Land. Verify history in enrichment.", "spine_id": "plm-006"}'::jsonb,
  'Houston-area plumber. Serves Katy, Memorial, Heights, Montrose, West-U, Sugar Land. Verify history in enrichment.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '758cbae5-75f0-5ce4-bfff-a7db16c7031e', 'plumbing', 'DYZ Plumbing', NULL,
  '238220', NULL, 'Bellaire', 'Harris',
  'TX', '77401', NULL, 'https://dyzplumbing.com/',
  NULL, 'RMP', 'Current',
  NULL, NULL, NULL,
  NULL, 19,
  4, 1,
  'website_team_page_or_buildzoom_or_dnb', NULL,
  50, 'biz_history_proxy',
  19, FALSE,
  '[]'::jsonb, '[{"source": "website", "url": "https://dyzplumbing.com/plumbers-in-bellaire-texas/", "fetched_at": "2026-05-15", "fields": ["legal_name", "city"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "19+ years experience. Bellaire/Memorial/West Houston focus. Need to verify family-ownership.", "spine_id": "plm-007"}'::jsonb,
  '19+ years experience. Bellaire/Memorial/West Houston focus. Need to verify family-ownership.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '083515bc-084a-5c55-833f-5072912d9b36', 'plumbing', 'David Hicks Plumbing', NULL,
  '238220', NULL, 'Houston', 'Harris',
  'TX', NULL, NULL, 'https://davidhicksplumbing.com/',
  NULL, 'RMP', 'Current',
  NULL, 'David Hicks', NULL,
  NULL, 74,
  8, 1,
  'website_team_page_or_buildzoom_or_dnb', 'David Hicks',
  67, 'biz_history_proxy',
  30, FALSE,
  '[]'::jsonb, '[{"source": "website", "url": "https://davidhicksplumbing.com/", "fetched_at": "2026-05-15", "fields": ["legal_name", "license_holder_name"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "Family-owned commercial + residential. Certified Master Plumber license.", "spine_id": "plm-008"}'::jsonb,
  'Family-owned commercial + residential. Certified Master Plumber license.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '2245733d-50e5-5c2a-9f25-bc4a10891dc0', 'plumbing', 'Best Plumbing', NULL,
  '238220', NULL, 'Houston', 'Harris',
  'TX', NULL, NULL, 'https://www.bestplumbing.net/',
  NULL, 'RMP', 'Current',
  NULL, NULL, NULL,
  NULL, NULL,
  NULL, NULL,
  'website_team_page_or_buildzoom_or_dnb', NULL,
  NULL, 'unverified',
  NULL, FALSE,
  '[]'::jsonb, '[{"source": "website", "url": "https://www.bestplumbing.net/about-us/management-team/", "fetched_at": "2026-05-15", "fields": ["legal_name"]}]'::jsonb,
  '{"platform_check": "needs_verification", "verification_notes": "Houston plumbing \u2014 verify in enrichment.", "spine_id": "plm-009"}'::jsonb,
  'Houston plumbing — verify in enrichment.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '4ae6abf4-83b3-5610-a7b2-286db5e56760', 'plumbing', 'Southern Plumbing', NULL,
  '238220', NULL, 'Houston', 'Harris',
  'TX', NULL, NULL, 'https://southernplumbing.com/',
  NULL, 'RMP', 'Current',
  NULL, NULL, NULL,
  NULL, 22,
  5, 1,
  'website_team_page_or_buildzoom_or_dnb', NULL,
  55, 'biz_history_proxy',
  22, FALSE,
  '[]'::jsonb, '[{"source": "website", "url": "https://southernplumbing.com/", "fetched_at": "2026-05-15", "fields": ["legal_name", "year_established"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "Locally-owned since 2004. Serves Houston metro including Katy, Cypress, The Woodlands, Spring, Tomball.", "spine_id": "plm-010"}'::jsonb,
  'Locally-owned since 2004. Serves Houston metro including Katy, Cypress, The Woodlands, Spring, Tomball.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '3db614a4-e4df-521e-9fca-d9cebf7980dd', 'plumbing', 'Sunrise Mechanical Services', NULL,
  '238220', NULL, 'Houston', 'Harris',
  'TX', NULL, NULL, NULL,
  NULL, 'RMP', 'Current',
  NULL, NULL, NULL,
  NULL, NULL,
  NULL, NULL,
  'website_team_page_or_buildzoom_or_dnb', NULL,
  NULL, 'unverified',
  NULL, FALSE,
  '[]'::jsonb, '[{"source": "web_search_snippet", "url": "https://www.google.com/search?q=Sunrise+Mechanical+Services+Houston+plumbing", "fetched_at": "2026-05-15", "fields": ["legal_name"]}]'::jsonb,
  '{"platform_check": "unverified", "verification_notes": "Family-owned 35+ yrs in plumbing. Verify website + RMP in enrichment.", "spine_id": "plm-011"}'::jsonb,
  'Family-owned 35+ yrs in plumbing. Verify website + RMP in enrichment.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '98ac4c3b-adb0-5910-9445-7f696db59181', 'plumbing', 'Tony''s Plumbing', NULL,
  '238220', NULL, 'Cypress', 'Harris',
  'TX', NULL, '(832) 890-8449', 'https://tonysplumbingtx.com/',
  NULL, 'RMP', 'Current',
  NULL, NULL, NULL,
  NULL, 38,
  3, 1,
  'website_team_page_or_buildzoom_or_dnb', NULL,
  60, 'biz_history_proxy',
  38, FALSE,
  '[]'::jsonb, '[{"source": "website", "url": "https://tonysplumbingtx.com/", "fetched_at": "2026-05-15", "fields": ["legal_name", "phone"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "Father-and-son team. 38+ yrs experience. Cypress, Katy, Houston, Tomball, Spring, Woodlands.", "spine_id": "plm-012"}'::jsonb,
  'Father-and-son team. 38+ yrs experience. Cypress, Katy, Houston, Tomball, Spring, Woodlands.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '3586d1e9-aacb-57ef-b3a7-1f38778ab032', 'plumbing', 'DeMarco Plumbing', NULL,
  '238220', NULL, 'Spring', 'Harris',
  'TX', NULL, NULL, 'https://demarco-plumbing.com/',
  NULL, 'RMP', 'Current',
  NULL, 'Kevin DeMarco', NULL,
  NULL, NULL,
  3, 1,
  'website_team_page_or_buildzoom_or_dnb', 'Kevin DeMarco',
  NULL, 'unverified',
  NULL, FALSE,
  '[]'::jsonb, '[{"source": "website", "url": "https://demarco-plumbing.com/about-us/", "fetched_at": "2026-05-15", "fields": ["legal_name", "license_holder_name"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "30+ yrs. Founded and operated by Kevin DeMarco (RMP). Spring/Magnolia/Tomball/Conroe/Cypress/Woodlands/Kingwood/Houston/Katy.", "spine_id": "plm-013"}'::jsonb,
  '30+ yrs. Founded and operated by Kevin DeMarco (RMP). Spring/Magnolia/Tomball/Conroe/Cypress/Woodlands/Kingwood/Houston/Katy.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '2c190237-3168-5f0b-acda-ecbfd8cbbd1c', 'plumbing', 'All in The Family Plumbing', NULL,
  '238220', NULL, 'Tomball', 'Harris',
  'TX', NULL, '(832) 285-7061', 'https://allinthefamilyplumbing.com/',
  'RMPL 21138', 'RMP', 'Current',
  NULL, NULL, NULL,
  NULL, 19,
  5, 1,
  'website_team_page_or_buildzoom_or_dnb', NULL,
  55, 'license_tenure_proxy',
  19, FALSE,
  '[]'::jsonb, '[{"source": "website", "url": "https://allinthefamilyplumbing.com/contact-us-1", "fetched_at": "2026-05-15", "fields": ["legal_name", "license_number", "phone"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "RMPL 21138. Serves Tomball, Jersey Village, Woodlands, Magnolia, Pinehurst, Conroe, Montgomery, Katy.", "spine_id": "plm-014"}'::jsonb,
  'RMPL 21138. Serves Tomball, Jersey Village, Woodlands, Magnolia, Pinehurst, Conroe, Montgomery, Katy.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  'dfe2c963-b389-541d-a187-67975721040d', 'plumbing', 'Daniels Plumbing', NULL,
  '238220', NULL, 'Tomball', 'Harris',
  'TX', NULL, NULL, NULL,
  NULL, 'RMP', 'Current',
  NULL, NULL, NULL,
  NULL, 40,
  5, 1,
  'website_team_page_or_buildzoom_or_dnb', NULL,
  65, 'biz_history_proxy',
  40, FALSE,
  '[]'::jsonb, '[{"source": "web_search_snippet", "url": "https://nextdoor.com/pages/daniels-plumbing-tomball-tx/", "fetched_at": "2026-05-15", "fields": ["legal_name", "year_established"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "Family-owned since 1986. The Woodlands/Tomball/Spring/Cypress/Kingwood/Houston metro.", "spine_id": "plm-015"}'::jsonb,
  'Family-owned since 1986. The Woodlands/Tomball/Spring/Cypress/Kingwood/Houston metro.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '6f22b74c-4e08-53cd-87ef-064de091f000', 'plumbing', 'ABERLE PLUMBING LLC', NULL,
  '238220', '13141 KINSMAN', 'Houston', 'Harris',
  'TX', '77049', '(281) 458-1449', NULL,
  'M-22759', 'M (RMP qualifying license)', 'Current',
  '2000-08-24', 'MARK STEVEN ABERLE', NULL,
  NULL, 37,
  8, 2,
  'website_team_page_or_buildzoom_or_dnb', 'MARK STEVEN ABERLE',
  65, 'license_tenure_proxy',
  37, FALSE,
  '[]'::jsonb, '[{"source": "TSBPE RMP CSV", "url": "https://tsbpe.texas.gov/wp-content/uploads/2015/03/RMP.csv", "fetched_at": "2026-05-15", "fields": ["legal_name", "license_number", "license_issue_date", "license_holder_name", "city", "address", "phone"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "TSBPE primary-source. Master license since 2000 (~25 yrs). NE Harris (77049 \u2014 Sheldon/N Houston) submarket.", "spine_id": "plm-016"}'::jsonb,
  'TSBPE primary-source. Master license since 2000 (~25 yrs). NE Harris (77049 — Sheldon/N Houston) submarket.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '3b8c9465-21b8-503e-843d-890a18d58a08', 'plumbing', 'JOHNS PLUMBING INC', NULL,
  '238220', '14506 CROSS JUNCTION ST', 'Houston', 'Harris',
  'TX', '77084', '(281) 380-8590', NULL,
  'M-17559', 'M (RMP qualifying license)', 'Current',
  '1989-11-28', 'JOHN P ANSELMO', NULL,
  NULL, 44,
  4, 1,
  'website_team_page_or_buildzoom_or_dnb', 'JOHN P ANSELMO',
  68, 'license_tenure_proxy',
  37, FALSE,
  '[]'::jsonb, '[{"source": "TSBPE RMP CSV", "url": "https://tsbpe.texas.gov/wp-content/uploads/2015/03/RMP.csv", "fetched_at": "2026-05-15", "fields": ["legal_name", "license_number", "license_issue_date", "license_holder_name", "address"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "TSBPE primary-source. RMP John Anselmo since 1989 (~37 yrs Master Plumber tenure). NW Harris (77084 \u2014 Bear Creek/Copperfield).", "spine_id": "plm-017"}'::jsonb,
  'TSBPE primary-source. RMP John Anselmo since 1989 (~37 yrs Master Plumber tenure). NW Harris (77084 — Bear Creek/Copperfield).'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  'c94621a4-a474-5691-9bc3-7e6db0b0aa19', 'plumbing', 'PEGASUS PLUMBING & UTILITY SERVICES LLC', NULL,
  '238220', '3023 GOLFCREST BLVD', 'Houston', 'Harris',
  'TX', '77087', '(713) 988-6061', NULL,
  'M-40148', 'M (RMP qualifying license)', 'Current',
  '2011-10-25', 'MICHAEL BURL MASSINGILL', NULL,
  NULL, 15,
  5, 1,
  'website_team_page_or_buildzoom_or_dnb', 'MICHAEL BURL MASSINGILL',
  50, 'license_tenure_proxy',
  14, FALSE,
  '[]'::jsonb, '[{"source": "TSBPE RMP CSV", "url": "https://tsbpe.texas.gov/wp-content/uploads/2015/03/RMP.csv", "fetched_at": "2026-05-15", "fields": ["legal_name", "license_number", "license_issue_date", "license_holder_name", "address"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "TSBPE primary-source. South Harris (77087 \u2014 Golfcrest/South Park). 14+ yrs RMP.", "spine_id": "plm-018"}'::jsonb,
  'TSBPE primary-source. South Harris (77087 — Golfcrest/South Park). 14+ yrs RMP.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '3de49736-2908-5b2c-b536-934484232542', 'plumbing', 'GILBERT PLUMBING CO LP', NULL,
  '238220', '4118 SOUTHERLAND RD', 'Houston', 'Harris',
  'TX', '77092', '(713) 201-2685', NULL,
  'M-39530', 'M (RMP qualifying license)', 'Current',
  '2010-02-23', 'JACK L GILBERT', NULL,
  NULL, 88,
  9, 4,
  'website_team_page_or_buildzoom_or_dnb', 'JACK L GILBERT',
  65, 'biz_history_proxy',
  36, FALSE,
  '[]'::jsonb, '[{"source": "TSBPE RMP CSV", "url": "https://tsbpe.texas.gov/wp-content/uploads/2015/03/RMP.csv", "fetched_at": "2026-05-15", "fields": ["legal_name", "license_number", "license_issue_date", "license_holder_name", "address"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "TSBPE primary-source. NW Houston (77092 \u2014 Oak Forest/Garden Oaks). LP structure suggests family/partnership.", "spine_id": "plm-019"}'::jsonb,
  'TSBPE primary-source. NW Houston (77092 — Oak Forest/Garden Oaks). LP structure suggests family/partnership.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  'aa89e8ea-464d-5bdd-a889-daad67aa0d04', 'plumbing', 'DOLPHIN PLUMBING', NULL,
  '238220', '10511 KIRKHILL', 'Houston', 'Harris',
  'TX', '77089', '(281) 924-4154', NULL,
  'M-18323', 'M (RMP qualifying license)', 'Current',
  '1992-08-13', 'EUSEBIO MUNOZ', NULL,
  NULL, 34,
  4, 2,
  'website_team_page_or_buildzoom_or_dnb', 'EUSEBIO MUNOZ',
  68, 'license_tenure_proxy',
  33, FALSE,
  '[]'::jsonb, '[{"source": "TSBPE RMP CSV", "url": "https://tsbpe.texas.gov/wp-content/uploads/2015/03/RMP.csv", "fetched_at": "2026-05-15", "fields": ["legal_name", "license_number", "license_issue_date", "license_holder_name", "address"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "TSBPE primary-source. SE Harris (77089 \u2014 Sagemont/South Belt). ~33 yrs Master Plumber tenure.", "spine_id": "plm-020"}'::jsonb,
  'TSBPE primary-source. SE Harris (77089 — Sagemont/South Belt). ~33 yrs Master Plumber tenure.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  'ecc04893-4b1b-5a89-9edc-036324720524', 'plumbing', 'PAZ PLUMBING', NULL,
  '238220', NULL, 'South Houston', 'Harris',
  'TX', '77587', '(832) 731-1989', NULL,
  'M-18647', 'M (RMP qualifying license)', 'Current',
  '1993-11-15', 'JORGE ANIBAL DE PAZ', NULL,
  NULL, 32,
  3, 1,
  'website_team_page_or_buildzoom_or_dnb', 'JORGE ANIBAL DE PAZ',
  67, 'license_tenure_proxy',
  32, FALSE,
  '[]'::jsonb, '[{"source": "TSBPE RMP CSV", "url": "https://tsbpe.texas.gov/wp-content/uploads/2015/03/RMP.csv", "fetched_at": "2026-05-15", "fields": ["legal_name", "license_number", "license_issue_date", "license_holder_name", "city"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "TSBPE primary-source. South Houston blue-collar plumber. 32+ yrs Master Plumber tenure.", "spine_id": "plm-021"}'::jsonb,
  'TSBPE primary-source. South Houston blue-collar plumber. 32+ yrs Master Plumber tenure.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  'ca95657a-8dc5-5293-8085-be15d9c4ecdc', 'plumbing', 'W MCLAIN PLUMBING LLC', NULL,
  '238220', '2710 PRESTON', 'Pasadena', 'Harris',
  'TX', '77503', '(281) 802-4615', NULL,
  'M-9313', 'M (RMP qualifying license)', 'Current',
  '1990-01-01', 'WILLIAM DAVID MCLAIN', NULL,
  NULL, 40,
  3, 1,
  'website_team_page_or_buildzoom_or_dnb', 'WILLIAM DAVID MCLAIN',
  72, 'license_tenure_proxy',
  40, FALSE,
  '[]'::jsonb, '[{"source": "TSBPE RMP CSV", "url": "https://tsbpe.texas.gov/wp-content/uploads/2015/03/RMP.csv", "fetched_at": "2026-05-15", "fields": ["legal_name", "license_number", "license_holder_name", "city", "address", "phone"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "TSBPE primary-source. Pasadena (older Houston metro housing). License number 9313 = legacy holder, decades of tenure. WSPS-endorsed.", "spine_id": "plm-022"}'::jsonb,
  'TSBPE primary-source. Pasadena (older Houston metro housing). License number 9313 = legacy holder, decades of tenure. WSPS-endorsed.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  'af34c688-4d7f-5893-ae51-c20ad5ba2688', 'plumbing', 'THIRD COAST PLUMBING SERVICES LLC', NULL,
  '238220', NULL, 'Pasadena', 'Harris',
  'TX', '77506', '(713) 473-0534', NULL,
  'M-15152', 'M (RMP qualifying license)', 'Current',
  '1985-06-17', 'GREGORIO V MARTINEZ', NULL,
  NULL, 40,
  3, 1,
  'website_team_page_or_buildzoom_or_dnb', 'GREGORIO V MARTINEZ',
  67, 'license_tenure_proxy',
  40, FALSE,
  '[]'::jsonb, '[{"source": "TSBPE RMP CSV", "url": "https://tsbpe.texas.gov/wp-content/uploads/2015/03/RMP.csv", "fetched_at": "2026-05-15", "fields": ["legal_name", "license_number", "license_issue_date", "license_holder_name", "city"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "TSBPE primary-source. Pasadena. 40 yrs Master Plumber tenure (1985). Long-tenured candidate.", "spine_id": "plm-023"}'::jsonb,
  'TSBPE primary-source. Pasadena. 40 yrs Master Plumber tenure (1985). Long-tenured candidate.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '0f103301-2179-5297-a0b5-efd1750fe0cb', 'plumbing', 'W ELAM PLUMBING COMPANY', NULL,
  '238220', NULL, 'Houston', 'Harris',
  'TX', '77045', '(713) 433-3996', NULL,
  'M-10139', 'M (RMP qualifying license)', 'Current',
  '1990-01-01', 'WESLEY ELAM', NULL,
  NULL, 40,
  3, 1,
  'website_team_page_or_buildzoom_or_dnb', 'WESLEY ELAM',
  72, 'license_tenure_proxy',
  40, FALSE,
  '[]'::jsonb, '[{"source": "TSBPE RMP CSV", "url": "https://tsbpe.texas.gov/wp-content/uploads/2015/03/RMP.csv", "fetched_at": "2026-05-15", "fields": ["legal_name", "license_number", "license_holder_name", "city"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "TSBPE primary-source. South Houston (77045). License # 10139 = legacy holder. Related to ELAM PLUMBING COMPANY (Mack Elam, #5233) \u2014 likely multi-generation Elam family operation.", "spine_id": "plm-024"}'::jsonb,
  'TSBPE primary-source. South Houston (77045). License # 10139 = legacy holder. Related to ELAM PLUMBING COMPANY (Mack Elam, #5233) — likely multi-generation Elam family operation.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '9a3a6059-4747-577b-a475-8d2d99f6f9af', 'plumbing', 'ELAM PLUMBING COMPANY', NULL,
  '238220', '9019 BRANDON ST', 'Houston', 'Harris',
  'TX', '77051', '(713) 733-0990', NULL,
  'M-5233', 'M (RMP qualifying license)', 'Current',
  '1990-01-01', 'MACK A ELAM', NULL,
  NULL, 50,
  4, 1,
  'website_team_page_or_buildzoom_or_dnb', 'MACK A ELAM',
  78, 'license_tenure_proxy',
  45, FALSE,
  '[]'::jsonb, '[{"source": "TSBPE RMP CSV", "url": "https://tsbpe.texas.gov/wp-content/uploads/2015/03/RMP.csv", "fetched_at": "2026-05-15", "fields": ["legal_name", "license_number", "license_holder_name", "address"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "TSBPE primary-source. South Houston (77051 \u2014 South Park). Very low license # 5233 = decades-long tenure. SAME-SURNAME pattern: also W ELAM PLUMBING (Wesley) = MULTI-GENERATION FAMILY OPERATION = likely INTERNAL SUCCESSOR present.", "spine_id": "plm-025"}'::jsonb,
  'TSBPE primary-source. South Houston (77051 — South Park). Very low license # 5233 = decades-long tenure. SAME-SURNAME pattern: also W ELAM PLUMBING (Wesley) = MULTI-GENERATION FAMILY OPERATION = likely INTERNAL SUCCESSOR present.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '6be9cc31-4de2-560f-b106-756a7072e8d2', 'plumbing', 'FRANCIS PLUMBING AND UTILITY', NULL,
  '238220', NULL, 'Houston', 'Fort Bend',
  'TX', '77053', '(346) 803-1895', NULL,
  'M-10477', 'M (RMP qualifying license)', 'Current',
  '1990-01-01', 'DAVID CARLTON FRANCIS', NULL,
  NULL, 35,
  3, 1,
  'website_team_page_or_buildzoom_or_dnb', 'DAVID CARLTON FRANCIS',
  70, 'license_tenure_proxy',
  35, FALSE,
  '[]'::jsonb, '[{"source": "TSBPE RMP CSV", "url": "https://tsbpe.texas.gov/wp-content/uploads/2015/03/RMP.csv", "fetched_at": "2026-05-15", "fields": ["legal_name", "license_number", "license_holder_name", "city"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "TSBPE primary-source. Fort Bend (SW Houston metro, 77053 \u2014 Sienna/Missouri City area). License # 10477 = legacy holder.", "spine_id": "plm-026"}'::jsonb,
  'TSBPE primary-source. Fort Bend (SW Houston metro, 77053 — Sienna/Missouri City area). License # 10477 = legacy holder.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '2b7c5cde-94cf-57c4-98cf-bf610599c9b4', 'plumbing', 'Dallas Plumbing Company', 'Dallas Plumbing & AC',
  '238220', NULL, 'Dallas', 'Dallas',
  'TX', NULL, NULL, 'https://dallasplumbing.com/',
  NULL, 'RMP', 'Current',
  NULL, NULL, NULL,
  NULL, 123,
  60, 5,
  'website_team_page_or_buildzoom_or_dnb', NULL,
  65, 'biz_history_proxy',
  30, FALSE,
  '[]'::jsonb, '[{"source": "website", "url": "https://dallasplumbing.com/history/", "fetched_at": "2026-05-15", "fields": ["legal_name", "year_established"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "Four generations of family ownership. Founded 1903 \u2014 oldest in TX. Verify NOT rolled-up in enrichment. 120+ yrs.", "spine_id": "plm-027"}'::jsonb,
  'Four generations of family ownership. Founded 1903 — oldest in TX. Verify NOT rolled-up in enrichment. 120+ yrs.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  'c71f00c5-c2ea-5242-b481-4009be669df2', 'plumbing', 'Public Service Plumbers, Inc.', NULL,
  '238220', NULL, 'Dallas', 'Dallas',
  'TX', NULL, NULL, 'https://publicserviceplumbers.com/',
  NULL, 'RMP', 'Current',
  NULL, NULL, NULL,
  NULL, 67,
  30, 4,
  'website_team_page_or_buildzoom_or_dnb', NULL,
  68, 'biz_history_proxy',
  45, FALSE,
  '[]'::jsonb, '[{"source": "website", "url": "https://publicserviceplumbers.com/about-us/", "fetched_at": "2026-05-15", "fields": ["legal_name", "year_established"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "Founded 1959 by John B. DiFrancesco (TX MP since 1950). Third-gen Master Plumber licensed since 1981. SAME-SURNAME multi-generation operation \u2014 likely INTERNAL SUCCESSOR present.", "spine_id": "plm-028"}'::jsonb,
  'Founded 1959 by John B. DiFrancesco (TX MP since 1950). Third-gen Master Plumber licensed since 1981. SAME-SURNAME multi-generation operation — likely INTERNAL SUCCESSOR present.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  'd4a3af42-50c2-5400-b030-c29fe4d423e2', 'plumbing', 'Cody & Sons Plumbing, Heating & Air', 'Cody & Sons',
  '238220', NULL, 'Dallas', 'Dallas',
  'TX', NULL, NULL, 'https://codyandsons.com/',
  NULL, 'RMP', 'Current',
  NULL, NULL, NULL,
  NULL, 57,
  25, 3,
  'website_team_page_or_buildzoom_or_dnb', NULL,
  65, 'biz_history_proxy',
  35, FALSE,
  '[]'::jsonb, '[{"source": "website", "url": "https://codyandsons.com/", "fetched_at": "2026-05-15", "fields": ["legal_name", "year_established"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "Founded 1969 by Bill & Shirley Cody + 3 sons. Multi-gen family. ''And Sons'' = INTERNAL SUCCESSOR by definition. Dallas + Plano.", "spine_id": "plm-029"}'::jsonb,
  'Founded 1969 by Bill & Shirley Cody + 3 sons. Multi-gen family. ''And Sons'' = INTERNAL SUCCESSOR by definition. Dallas + Plano.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '63914b89-5acf-545d-bbdf-f2f42744b4d3', 'plumbing', 'Reeves Family Plumbing', NULL,
  '238220', NULL, 'Dallas', 'Dallas',
  'TX', NULL, NULL, 'https://www.reevesfamilyplumbing.com/',
  NULL, 'RMP', 'Current',
  NULL, NULL, NULL,
  NULL, 66,
  12, 2,
  'website_team_page_or_buildzoom_or_dnb', NULL,
  60, 'biz_history_proxy',
  25, FALSE,
  '[]'::jsonb, '[{"source": "website", "url": "https://www.reevesfamilyplumbing.com/", "fetched_at": "2026-05-15", "fields": ["legal_name", "year_established"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "Founded 1960. Woman-owned. 65 yrs tenure. Dallas. Verify size and succession.", "spine_id": "plm-030"}'::jsonb,
  'Founded 1960. Woman-owned. 65 yrs tenure. Dallas. Verify size and succession.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '847cb6be-ccb8-5f5a-8c34-558e6b3e48d5', 'plumbing', 'Baker Brothers Plumbing, Air & Electric', 'Baker Brothers',
  '238220', NULL, 'Dallas', 'Dallas',
  'TX', NULL, '(214) 296-2136', 'https://bakerbrothersplumbing.com/',
  NULL, 'RMP', 'Current',
  NULL, NULL, NULL,
  NULL, 81,
  NULL, NULL,
  'website_team_page_or_buildzoom_or_dnb', NULL,
  NULL, 'platform_excluded',
  NULL, TRUE,
  '["pe_platform_owned_wrench_group_infrastructure_detected"]'::jsonb, '[{"source": "website", "url": "https://bakerbrothersplumbing.com/", "fetched_at": "2026-05-15", "fields": ["legal_name", "year_established", "phone"]}]'::jsonb,
  '{"platform_check": "needs_verification", "verification_notes": "Founded 1945. 80 yrs. DFW broad coverage. Multi-trade + larger size \u2014 verify not yet acquired by Wrench Group/Apex in enrichment.", "spine_id": "plm-031"}'::jsonb,
  'Founded 1945. 80 yrs. DFW broad coverage. Multi-trade + larger size — verify not yet acquired by Wrench Group/Apex in enrichment.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '6f66e5bd-6932-5ecd-9c6f-50ae713eeff4', 'plumbing', 'My Local Plumber', NULL,
  '238220', NULL, 'Farmers Branch', 'Dallas',
  'TX', NULL, NULL, 'https://mylocalplumber.net/',
  NULL, 'RMP', 'Current',
  NULL, NULL, NULL,
  NULL, 25,
  6, 1,
  'website_team_page_or_buildzoom_or_dnb', NULL,
  60, 'biz_history_proxy',
  25, FALSE,
  '[]'::jsonb, '[{"source": "website", "url": "https://mylocalplumber.net/", "fetched_at": "2026-05-15", "fields": ["legal_name", "city"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "Family-owned 25+ yrs. North Dallas / Farmers Branch. Verify size.", "spine_id": "plm-032"}'::jsonb,
  'Family-owned 25+ yrs. North Dallas / Farmers Branch. Verify size.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '27e4fac2-c5a8-5354-ba7c-a3b0b9de4775', 'plumbing', 'Watermark Plumbing', NULL,
  '238220', NULL, 'Carrollton', 'Dallas',
  'TX', NULL, NULL, 'https://www.watermarkplumbing.com/',
  NULL, 'RMP', 'Current',
  NULL, NULL, NULL,
  NULL, 21,
  4, 1,
  'website_team_page_or_buildzoom_or_dnb', NULL,
  55, 'biz_history_proxy',
  21, FALSE,
  '[]'::jsonb, '[{"source": "website", "url": "https://www.watermarkplumbing.com/", "fetched_at": "2026-05-15", "fields": ["legal_name", "year_established", "city"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "Family owned and operated since 2005. Carrollton-based, DFW area.", "spine_id": "plm-033"}'::jsonb,
  'Family owned and operated since 2005. Carrollton-based, DFW area.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  'e683dd8f-15ba-5a66-8e52-b5c62603d7d8', 'plumbing', 'Burton''s Mechanical, Inc.', NULL,
  '238220', NULL, 'Dallas', 'Dallas',
  'TX', NULL, NULL, 'https://www.burtonsmechanical.com/',
  NULL, 'RMP', 'Current',
  NULL, NULL, NULL,
  NULL, 18,
  5, 1,
  'website_team_page_or_buildzoom_or_dnb', NULL,
  50, 'biz_history_proxy',
  18, FALSE,
  '[]'::jsonb, '[{"source": "website", "url": "https://www.burtonsmechanical.com/", "fetched_at": "2026-05-15", "fields": ["legal_name", "year_established"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "Family-owned since 2008. Commercial construction emphasis \u2014 verify residential service mix in enrichment; may filter as pure new-construction.", "spine_id": "plm-034"}'::jsonb,
  'Family-owned since 2008. Commercial construction emphasis — verify residential service mix in enrichment; may filter as pure new-construction.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '4bcbde81-27a8-5f39-81fb-258252482d58', 'plumbing', 'Barbosa Plumbing & Air Conditioning', 'Barbosa Mechanical',
  '238220', NULL, 'Carrollton', 'Dallas',
  'TX', NULL, NULL, 'https://www.barbosamechanical.com/',
  NULL, 'RMP', 'Current',
  NULL, NULL, NULL,
  NULL, 46,
  6, 1,
  'website_team_page_or_buildzoom_or_dnb', NULL,
  65, 'biz_history_proxy',
  46, FALSE,
  '[]'::jsonb, '[{"source": "website", "url": "https://www.barbosamechanical.com/plumbing-service", "fetched_at": "2026-05-15", "fields": ["legal_name"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "46+ yrs experience. Carrollton/Farmers Branch/Dallas. Multi-trade.", "spine_id": "plm-035"}'::jsonb,
  '46+ yrs experience. Carrollton/Farmers Branch/Dallas. Multi-trade.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '18211e2c-c057-5afe-a6ad-9aa8c80c13db', 'plumbing', 'Legacy Plumbing', NULL,
  '238220', NULL, 'Frisco', 'Collin',
  'TX', NULL, NULL, 'https://legacyplumbing.net/',
  NULL, 'RMP', 'Current',
  NULL, 'Theron Young', NULL,
  NULL, 20,
  12, 1,
  'website_team_page_or_buildzoom_or_dnb', 'Theron Young',
  55, 'license_tenure_proxy',
  20, FALSE,
  '[]'::jsonb, '[{"source": "website", "url": "https://legacyplumbing.net/", "fetched_at": "2026-05-15", "fields": ["legal_name", "license_holder_name"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "RMP Theron Young. Serves Frisco/McKinney/Richardson/Farmers Branch. Collin County.", "spine_id": "plm-036"}'::jsonb,
  'RMP Theron Young. Serves Frisco/McKinney/Richardson/Farmers Branch. Collin County.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '30c050a7-3b97-5aa2-b88d-016840192be6', 'plumbing', 'Hackler Plumbing', NULL,
  '238220', NULL, 'McKinney', 'Collin',
  'TX', NULL, NULL, 'https://hacklerplumbingmckinney.com/',
  NULL, 'RMP', 'Current',
  NULL, NULL, NULL,
  NULL, 16,
  5, 1,
  'website_team_page_or_buildzoom_or_dnb', NULL,
  50, 'license_tenure_proxy',
  16, FALSE,
  '[]'::jsonb, '[{"source": "website", "url": "https://hacklerplumbingmckinney.com/about-our-company/", "fetched_at": "2026-05-15", "fields": ["legal_name"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "Family-owned McKinney plumber. Serves McKinney/Frisco/Allen/N Dallas.", "spine_id": "plm-037"}'::jsonb,
  'Family-owned McKinney plumber. Serves McKinney/Frisco/Allen/N Dallas.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '5fc5b71a-2a6d-5f46-8827-aee5b7df9cb6', 'plumbing', 'Smith and Son Plumbing and Backflow', 'Smith and Son Plumbing',
  '238220', NULL, 'McKinney', 'Collin',
  'TX', NULL, NULL, 'https://smithandsonplumbing.com/',
  NULL, 'RMP', 'Current',
  NULL, NULL, NULL,
  NULL, 55,
  8, 2,
  'website_team_page_or_buildzoom_or_dnb', NULL,
  70, 'biz_history_proxy',
  55, FALSE,
  '[]'::jsonb, '[{"source": "website", "url": "https://smithandsonplumbing.com/", "fetched_at": "2026-05-15", "fields": ["legal_name", "year_established"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "3rd-gen family operated. 55+ yrs since 1970. SAME-SURNAME 3-gen = INTERNAL SUCCESSOR by definition. BACKFLOW = recurring revenue.", "spine_id": "plm-038"}'::jsonb,
  '3rd-gen family operated. 55+ yrs since 1970. SAME-SURNAME 3-gen = INTERNAL SUCCESSOR by definition. BACKFLOW = recurring revenue.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '78cb16f9-aeba-552a-bbac-97fe48bf11d5', 'plumbing', 'O''Bryan Plumbing Services', NULL,
  '238220', NULL, 'Allen', 'Collin',
  'TX', NULL, NULL, 'https://obryanplumbingservices.com/',
  NULL, 'RMP', 'Current',
  NULL, NULL, NULL,
  NULL, 44,
  10, 1,
  'website_team_page_or_buildzoom_or_dnb', NULL,
  55, 'biz_history_proxy',
  25, FALSE,
  '[]'::jsonb, '[{"source": "website", "url": "https://obryanplumbingservices.com/about/", "fetched_at": "2026-05-15", "fields": ["legal_name", "year_established"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "Family-owned Allen-area. 43+ yrs. Allen/Dallas/Collin.", "spine_id": "plm-039"}'::jsonb,
  'Family-owned Allen-area. 43+ yrs. Allen/Dallas/Collin.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  'f651689c-eb73-5552-a4fc-699728c3f557', 'plumbing', 'Kenny Bunch Plumbing', NULL,
  '238220', NULL, 'Wylie', 'Collin',
  'TX', NULL, NULL, 'https://kennybunchplumbing.com/',
  NULL, 'RMP', 'Current',
  NULL, 'Kenny Bunch', NULL,
  NULL, 25,
  5, 1,
  'website_team_page_or_buildzoom_or_dnb', 'Kenny Bunch',
  60, 'biz_history_proxy',
  25, FALSE,
  '[]'::jsonb, '[{"source": "website", "url": "https://kennybunchplumbing.com/", "fetched_at": "2026-05-15", "fields": ["legal_name", "license_holder_name"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "Owner-operated 25+ yrs. Serves Wylie/Plano/Allen/Sachse/Murphy/Richardson. Collin/Dallas County mix.", "spine_id": "plm-040"}'::jsonb,
  'Owner-operated 25+ yrs. Serves Wylie/Plano/Allen/Sachse/Murphy/Richardson. Collin/Dallas County mix.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  'f990485a-7d57-56c9-800f-2479103539ad', 'plumbing', 'FRANK SMITH PLUMBING', NULL,
  '238220', '214 W CLARENDON DR', 'Dallas', 'Dallas',
  'TX', '75208', '(214) 912-2768', NULL,
  'M-16856', 'M (RMP qualifying license)', 'Current',
  '1988-02-29', 'FRANK EDWARD SMITH', NULL,
  NULL, 37,
  3, 1,
  'website_team_page_or_buildzoom_or_dnb', 'FRANK EDWARD SMITH',
  70, 'license_tenure_proxy',
  37, FALSE,
  '[]'::jsonb, '[{"source": "TSBPE RMP CSV", "url": "https://tsbpe.texas.gov/wp-content/uploads/2015/03/RMP.csv", "fetched_at": "2026-05-15", "fields": ["legal_name", "license_number", "license_issue_date", "license_holder_name", "address"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "TSBPE primary-source. Oak Cliff Dallas (75208 \u2014 Bishop Arts/N Oak Cliff). 37+ yrs Master Plumber. Owner-named DBA.", "spine_id": "plm-041"}'::jsonb,
  'TSBPE primary-source. Oak Cliff Dallas (75208 — Bishop Arts/N Oak Cliff). 37+ yrs Master Plumber. Owner-named DBA.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '376ac295-1d08-5ae5-9884-4535782965bf', 'plumbing', 'IC PLUMBING LLC', NULL,
  '238220', '1800 E BELTLINE RD', 'Carrollton', 'Dallas',
  'TX', '75006', '(214) 223-5399', NULL,
  'M-15811', 'M (RMP qualifying license)', 'Current',
  '1986-04-07', 'TERRY LYNN STOKES', NULL,
  NULL, 39,
  3, 1,
  'website_team_page_or_buildzoom_or_dnb', 'TERRY LYNN STOKES',
  70, 'license_tenure_proxy',
  39, FALSE,
  '[]'::jsonb, '[{"source": "TSBPE RMP CSV", "url": "https://tsbpe.texas.gov/wp-content/uploads/2015/03/RMP.csv", "fetched_at": "2026-05-15", "fields": ["legal_name", "license_number", "license_issue_date", "license_holder_name", "address"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "TSBPE primary-source. Carrollton (NW Dallas County). 39+ yrs Master Plumber tenure (1986).", "spine_id": "plm-042"}'::jsonb,
  'TSBPE primary-source. Carrollton (NW Dallas County). 39+ yrs Master Plumber tenure (1986).'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '4d139de2-1d7d-5146-85cd-4a5e257ad4ea', 'plumbing', 'RIDDELL PLUMBING INC', NULL,
  '238220', NULL, 'Mesquite', 'Dallas',
  'TX', '75149', '(972) 682-4860', NULL,
  'M-15275', 'M (RMP qualifying license)', 'Current',
  '1985-08-07', 'RONALD SCOTT RIDDELL', NULL,
  NULL, 40,
  30, 3,
  'website_team_page_or_buildzoom_or_dnb', 'RONALD SCOTT RIDDELL',
  70, 'license_tenure_proxy',
  40, FALSE,
  '[]'::jsonb, '[{"source": "TSBPE RMP CSV", "url": "https://tsbpe.texas.gov/wp-content/uploads/2015/03/RMP.csv", "fetched_at": "2026-05-15", "fields": ["legal_name", "license_number", "license_issue_date", "license_holder_name", "city"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "TSBPE primary-source. Mesquite (E Dallas County, older housing stock). 40+ yrs Master Plumber tenure (1985).", "spine_id": "plm-043"}'::jsonb,
  'TSBPE primary-source. Mesquite (E Dallas County, older housing stock). 40+ yrs Master Plumber tenure (1985).'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '8f4f6416-ef8d-5862-9ba5-6c4413b26f43', 'plumbing', 'AH MECHANICAL CONTRACTORS LLC', NULL,
  '238220', NULL, 'Dallas', 'Dallas',
  'TX', '75235', '(214) 236-2215', NULL,
  'M-37502', 'M (RMP qualifying license)', 'Current',
  '2005-10-20', 'ALFRED HERNANDEZ', NULL,
  NULL, 20,
  3, 1,
  'website_team_page_or_buildzoom_or_dnb', 'ALFRED HERNANDEZ',
  60, 'license_tenure_proxy',
  20, FALSE,
  '[]'::jsonb, '[{"source": "TSBPE RMP CSV", "url": "https://tsbpe.texas.gov/wp-content/uploads/2015/03/RMP.csv", "fetched_at": "2026-05-15", "fields": ["legal_name", "license_number", "license_issue_date", "license_holder_name", "city"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "TSBPE primary-source. Dallas (75235 \u2014 Love Field/Stemmons). 20+ yrs Master Plumber tenure.", "spine_id": "plm-044"}'::jsonb,
  'TSBPE primary-source. Dallas (75235 — Love Field/Stemmons). 20+ yrs Master Plumber tenure.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '927b57e0-df9e-5baf-84da-b6146893e1f4', 'plumbing', 'COLDWATER PLUMBING SERVICES INC', NULL,
  '238220', '15330 LBJ FREEWAY SUITE 206', 'Mesquite', 'Dallas',
  'TX', '75150', '(972) 279-1128', NULL,
  'M-37625', 'M (RMP qualifying license)', 'Current',
  '2006-02-21', 'RUDOLFO NUNEZ', NULL,
  NULL, 19,
  3, 1,
  'website_team_page_or_buildzoom_or_dnb', 'RUDOLFO NUNEZ',
  58, 'license_tenure_proxy',
  19, FALSE,
  '[]'::jsonb, '[{"source": "TSBPE RMP CSV", "url": "https://tsbpe.texas.gov/wp-content/uploads/2015/03/RMP.csv", "fetched_at": "2026-05-15", "fields": ["legal_name", "license_number", "license_issue_date", "license_holder_name", "address"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "TSBPE primary-source. Mesquite. 19+ yrs Master Plumber tenure (2006).", "spine_id": "plm-045"}'::jsonb,
  'TSBPE primary-source. Mesquite. 19+ yrs Master Plumber tenure (2006).'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '99c548bf-4dcd-544d-9335-d1558e8658d0', 'plumbing', 'RON STANLEY & SONS PLUMBING INC', NULL,
  '238220', NULL, 'Dallas', 'Dallas',
  'TX', '75215', '(214) 426-2252', NULL,
  'M-12045', 'M (RMP qualifying license)', 'Current',
  '1990-01-01', 'RONALD LEE STANLEY', NULL,
  NULL, 50,
  5, 1,
  'website_team_page_or_buildzoom_or_dnb', 'RONALD LEE STANLEY',
  75, 'license_tenure_proxy',
  45, FALSE,
  '[]'::jsonb, '[{"source": "TSBPE RMP CSV", "url": "https://tsbpe.texas.gov/wp-content/uploads/2015/03/RMP.csv", "fetched_at": "2026-05-15", "fields": ["legal_name", "license_number", "license_holder_name", "city"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "TSBPE primary-source. Dallas (75215). License # 12045 = legacy holder. ''& SONS'' = MULTI-GENERATION = INTERNAL SUCCESSOR by definition.", "spine_id": "plm-046"}'::jsonb,
  'TSBPE primary-source. Dallas (75215). License # 12045 = legacy holder. ''& SONS'' = MULTI-GENERATION = INTERNAL SUCCESSOR by definition.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  'cbd9b58d-fc7e-578d-bc02-09445fa8fe0b', 'plumbing', 'PELAYO PLUMBING', NULL,
  '238220', '5250 HWY 78 STE 750-114', 'Sachse', 'Dallas',
  'TX', '75048', '(214) 315-7672', NULL,
  'M-36676', 'M (RMP qualifying license)', 'Current',
  '2003-08-14', 'MICHAEL C PELAYO', NULL,
  NULL, 22,
  3, 1,
  'website_team_page_or_buildzoom_or_dnb', 'MICHAEL C PELAYO',
  58, 'license_tenure_proxy',
  22, FALSE,
  '[]'::jsonb, '[{"source": "TSBPE RMP CSV", "url": "https://tsbpe.texas.gov/wp-content/uploads/2015/03/RMP.csv", "fetched_at": "2026-05-15", "fields": ["legal_name", "license_number", "license_issue_date", "license_holder_name", "address"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "TSBPE primary-source. Sachse (NE Dallas County / Collin border). 22+ yrs Master Plumber tenure.", "spine_id": "plm-047"}'::jsonb,
  'TSBPE primary-source. Sachse (NE Dallas County / Collin border). 22+ yrs Master Plumber tenure.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  'd2602629-216f-5114-b766-9dca7a97d8b1', 'plumbing', 'ON TARGET MECHANICAL LLC', NULL,
  '238220', NULL, 'Rowlett', 'Dallas',
  'TX', '75089', '(214) 676-2941', NULL,
  'M-16773', 'M (RMP qualifying license)', 'Current',
  '1988-01-06', 'JAMES S BRINKLEY', NULL,
  NULL, 37,
  3, 1,
  'website_team_page_or_buildzoom_or_dnb', 'JAMES S BRINKLEY',
  67, 'license_tenure_proxy',
  37, FALSE,
  '[]'::jsonb, '[{"source": "TSBPE RMP CSV", "url": "https://tsbpe.texas.gov/wp-content/uploads/2015/03/RMP.csv", "fetched_at": "2026-05-15", "fields": ["legal_name", "license_number", "license_issue_date", "license_holder_name", "city"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "TSBPE primary-source. Rowlett (NE Dallas County). 37+ yrs Master Plumber tenure.", "spine_id": "plm-048"}'::jsonb,
  'TSBPE primary-source. Rowlett (NE Dallas County). 37+ yrs Master Plumber tenure.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '6938ef71-3bc7-57c5-9d3a-3ad1130d2f82', 'plumbing', 'Lasiter and Lasiter Plumbing', 'Lasiter & Lasiter',
  '238220', NULL, 'Fort Worth', 'Tarrant',
  'TX', NULL, NULL, 'https://lasiter.com/',
  NULL, 'RMP', 'Current',
  NULL, NULL, NULL,
  NULL, 52,
  10, 2,
  'website_team_page_or_buildzoom_or_dnb', NULL,
  70, 'license_tenure_proxy',
  40, FALSE,
  '[]'::jsonb, '[{"source": "website", "url": "https://lasiter.com/", "fetched_at": "2026-05-15", "fields": ["legal_name", "year_established"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "Family-owned and operated since 1974. 50+ yrs. Lasiter family name on company \u2014 multi-gen. Fort Worth + DFW.", "spine_id": "plm-049"}'::jsonb,
  'Family-owned and operated since 1974. 50+ yrs. Lasiter family name on company — multi-gen. Fort Worth + DFW.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '0a30f659-fc73-5ba3-b4f0-27ac11b9b97e', 'plumbing', 'Master Repair Plumbing', NULL,
  '238220', NULL, 'Fort Worth', 'Tarrant',
  'TX', NULL, NULL, 'https://www.masterrepairplumbing.com/',
  NULL, 'RMP', 'Current',
  NULL, NULL, NULL,
  NULL, 42,
  6, 1,
  'website_team_page_or_buildzoom_or_dnb', NULL,
  60, 'biz_history_proxy',
  42, FALSE,
  '[]'::jsonb, '[{"source": "website", "url": "https://www.masterrepairplumbing.com/", "fetched_at": "2026-05-15", "fields": ["legal_name", "year_established"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "Family-owned since 1983. 42 yrs Fort Worth + Tarrant area.", "spine_id": "plm-050"}'::jsonb,
  'Family-owned since 1983. 42 yrs Fort Worth + Tarrant area.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '84cc8166-2c63-57dc-acfe-9b9d3ab77b18', 'plumbing', 'Trusted Plumbing & Leak Detection', NULL,
  '238220', NULL, 'Fort Worth', 'Tarrant',
  'TX', NULL, NULL, 'https://www.trustedplumbingfw.com/',
  NULL, 'RMP', 'Current',
  NULL, NULL, NULL,
  NULL, 20,
  5, 1,
  'website_team_page_or_buildzoom_or_dnb', NULL,
  55, 'biz_history_proxy',
  20, FALSE,
  '[]'::jsonb, '[{"source": "website", "url": "https://www.trustedplumbingfw.com/", "fetched_at": "2026-05-15", "fields": ["legal_name"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "Family-owned. Master Plumber + wife + son + uncle/aunt operating team \u2014 multi-gen succession in place.", "spine_id": "plm-051"}'::jsonb,
  'Family-owned. Master Plumber + wife + son + uncle/aunt operating team — multi-gen succession in place.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '26c8c4d7-0007-581e-99de-4089994f0681', 'plumbing', 'Howze Plumbing', NULL,
  '238220', NULL, 'Fort Worth', 'Tarrant',
  'TX', NULL, NULL, 'https://www.howzeplumbing.com/',
  NULL, 'RMP', 'Current',
  NULL, NULL, NULL,
  NULL, 25,
  5, 1,
  'website_team_page_or_buildzoom_or_dnb', NULL,
  55, 'biz_history_proxy',
  25, FALSE,
  '[]'::jsonb, '[{"source": "website", "url": "https://www.howzeplumbing.com/fort-worth-plumbers/", "fetched_at": "2026-05-15", "fields": ["legal_name"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "Family-owned. 25+ yrs. Fort Worth.", "spine_id": "plm-052"}'::jsonb,
  'Family-owned. 25+ yrs. Fort Worth.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  'b5ec38f7-4519-5245-84af-78f948e9d5f4', 'plumbing', 'Ace Plumbing', NULL,
  '238220', NULL, 'Fort Worth', 'Tarrant',
  'TX', NULL, NULL, 'https://www.aceplumbingftwtx.com/',
  NULL, 'RMP', 'Current',
  NULL, NULL, NULL,
  NULL, 36,
  6, 1,
  'website_team_page_or_buildzoom_or_dnb', NULL,
  63, 'biz_history_proxy',
  36, FALSE,
  '[]'::jsonb, '[{"source": "website", "url": "https://www.aceplumbingftwtx.com/", "fetched_at": "2026-05-15", "fields": ["legal_name"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "Family + woman-owned. 30+ yrs. Tarrant County.", "spine_id": "plm-053"}'::jsonb,
  'Family + woman-owned. 30+ yrs. Tarrant County.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '74441347-05e9-5fa6-8c9b-0b9568a6d74e', 'plumbing', 'Double L Plumbing', NULL,
  '238220', NULL, 'Fort Worth', 'Tarrant',
  'TX', NULL, NULL, 'https://doublelplumbingservice.com/',
  NULL, 'RMP', 'Current',
  NULL, NULL, NULL,
  NULL, 15,
  4, 1,
  'website_team_page_or_buildzoom_or_dnb', NULL,
  55, 'biz_history_proxy',
  15, FALSE,
  '[]'::jsonb, '[{"source": "website", "url": "https://doublelplumbingservice.com/service-areas/plumber-fort-worth-tx/", "fetched_at": "2026-05-15", "fields": ["legal_name"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "Family-owned Tarrant County plumber.", "spine_id": "plm-054"}'::jsonb,
  'Family-owned Tarrant County plumber.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  'f9730f39-ac49-57cf-9de8-a051a312e1c9', 'plumbing', 'Curly''s Plumbing Inc.', 'Curly''s Plumbing',
  '238220', NULL, 'Fort Worth', 'Tarrant',
  'TX', NULL, NULL, 'https://www.curlysplumbing.com/',
  NULL, 'RMP', 'Current',
  NULL, NULL, NULL,
  NULL, 15,
  4, 1,
  'website_team_page_or_buildzoom_or_dnb', NULL,
  55, 'biz_history_proxy',
  15, FALSE,
  '[]'::jsonb, '[{"source": "website", "url": "https://www.curlysplumbing.com/service-area/plumbing-fort-worth/", "fetched_at": "2026-05-15", "fields": ["legal_name"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "Family + veteran-owned. Fort Worth.", "spine_id": "plm-055"}'::jsonb,
  'Family + veteran-owned. Fort Worth.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '8ce97b88-e909-59fe-b921-180a04eaa1e0', 'plumbing', 'FB Plumbing (Fischer and Boone)', 'FB Plumbing',
  '238220', NULL, 'Fort Worth', 'Tarrant',
  'TX', NULL, NULL, 'https://fbplumbingdfw.com/',
  NULL, 'RMP', 'Current',
  NULL, NULL, NULL,
  NULL, 15,
  4, 1,
  'website_team_page_or_buildzoom_or_dnb', NULL,
  55, 'biz_history_proxy',
  15, FALSE,
  '[]'::jsonb, '[{"source": "website", "url": "https://fbplumbingdfw.com/", "fetched_at": "2026-05-15", "fields": ["legal_name"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "Master Plumber-overseen team. DFW/Fort Worth.", "spine_id": "plm-056"}'::jsonb,
  'Master Plumber-overseen team. DFW/Fort Worth.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '702147d6-4d52-5e40-8852-feb0a868de2d', 'plumbing', 'RILEY PLUMBING & MECHANICAL', NULL,
  '238220', '6704 AZLE AVENUE', 'Fort Worth', 'Tarrant',
  'TX', '76135', '(817) 237-8104', NULL,
  'M-18265', 'M (RMP qualifying license)', 'Current',
  '1992-04-22', 'ROBERT FRANKLIN RILEY', NULL,
  NULL, 33,
  5, 1,
  'website_team_page_or_buildzoom_or_dnb', 'ROBERT FRANKLIN RILEY',
  70, 'license_tenure_proxy',
  33, FALSE,
  '[]'::jsonb, '[{"source": "TSBPE RMP CSV", "url": "https://tsbpe.texas.gov/wp-content/uploads/2015/03/RMP.csv", "fetched_at": "2026-05-15", "fields": ["legal_name", "license_number", "license_issue_date", "license_holder_name", "address"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "TSBPE primary-source. NW Fort Worth (76135 \u2014 Lake Worth). 33+ yrs Master Plumber tenure. MEDGAS endorsement = adjacency for hospitals/MOB recurring service contracts.", "spine_id": "plm-057"}'::jsonb,
  'TSBPE primary-source. NW Fort Worth (76135 — Lake Worth). 33+ yrs Master Plumber tenure. MEDGAS endorsement = adjacency for hospitals/MOB recurring service contracts.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  'a30385b1-1dfa-5b3a-a2be-36bd1c42ae0d', 'plumbing', 'REED PLUMBING INC', NULL,
  '238220', NULL, 'Kennedale', 'Tarrant',
  'TX', '76060', '(817) 822-5260', NULL,
  'M-15669', 'M (RMP qualifying license)', 'Current',
  '1986-02-18', 'BARTON N REED', NULL,
  NULL, 37,
  5, 2,
  'website_team_page_or_buildzoom_or_dnb', 'BARTON N REED',
  75, 'license_tenure_proxy',
  39, FALSE,
  '[]'::jsonb, '[{"source": "TSBPE RMP CSV", "url": "https://tsbpe.texas.gov/wp-content/uploads/2015/03/RMP.csv", "fetched_at": "2026-05-15", "fields": ["legal_name", "license_number", "license_issue_date", "license_holder_name", "city"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "TSBPE primary-source. Kennedale (S Tarrant County). 39+ yrs Master Plumber tenure (1986). Owner-named DBA.", "spine_id": "plm-058"}'::jsonb,
  'TSBPE primary-source. Kennedale (S Tarrant County). 39+ yrs Master Plumber tenure (1986). Owner-named DBA.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '08ca0239-0974-56c8-bf98-8b086971c930', 'plumbing', 'DIAMOND PLUMBING INDUSTRIES INC', NULL,
  '238220', NULL, 'Crowley', 'Tarrant',
  'TX', '76036', '(817) 925-4347', NULL,
  'M-36171', 'M (RMP qualifying license)', 'Current',
  '2002-04-12', 'ECTOR CANTU GOMEZ', NULL,
  NULL, 23,
  3, 1,
  'website_team_page_or_buildzoom_or_dnb', 'ECTOR CANTU GOMEZ',
  60, 'license_tenure_proxy',
  23, FALSE,
  '[]'::jsonb, '[{"source": "TSBPE RMP CSV", "url": "https://tsbpe.texas.gov/wp-content/uploads/2015/03/RMP.csv", "fetched_at": "2026-05-15", "fields": ["legal_name", "license_number", "license_issue_date", "license_holder_name", "city"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "TSBPE primary-source. Crowley (S Tarrant County). 23+ yrs Master Plumber tenure.", "spine_id": "plm-059"}'::jsonb,
  'TSBPE primary-source. Crowley (S Tarrant County). 23+ yrs Master Plumber tenure.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '8e678c69-a217-51ad-b02c-c2f34e5a9ad9', 'plumbing', 'TRI DAL LLC & AFFILIATES', NULL,
  '238220', '540 COMMERCE ST', 'Southlake', 'Tarrant',
  'TX', '76092', '(817) 319-5141', NULL,
  'M-38937', 'M (RMP qualifying license)', 'Current',
  '2009-02-18', 'EDDIE SHAY THOMAS', NULL,
  NULL, 17,
  4, 1,
  'website_team_page_or_buildzoom_or_dnb', 'EDDIE SHAY THOMAS',
  55, 'license_tenure_proxy',
  17, FALSE,
  '[]'::jsonb, '[{"source": "TSBPE RMP CSV", "url": "https://tsbpe.texas.gov/wp-content/uploads/2015/03/RMP.csv", "fetched_at": "2026-05-15", "fields": ["legal_name", "license_number", "license_issue_date", "license_holder_name", "address"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "TSBPE primary-source. Southlake (premium NE Tarrant County). 16+ yrs Master Plumber tenure. PREMIUM SUBMARKET.", "spine_id": "plm-060"}'::jsonb,
  'TSBPE primary-source. Southlake (premium NE Tarrant County). 16+ yrs Master Plumber tenure. PREMIUM SUBMARKET.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '49d5a8b5-cefa-5324-8d45-a2b9d893149c', 'plumbing', 'Beyer Plumbing Services', 'Beyer Plumbing',
  '238220', NULL, 'San Antonio', 'Bexar',
  'TX', NULL, NULL, 'https://beyerplumbing.com/',
  NULL, 'RMP', 'Current',
  NULL, NULL, NULL,
  NULL, 36,
  30, 4,
  'website_team_page_or_buildzoom_or_dnb', NULL,
  55, 'biz_history_proxy',
  36, FALSE,
  '[]'::jsonb, '[{"source": "website", "url": "https://beyerplumbing.com/", "fetched_at": "2026-05-15", "fields": ["legal_name", "year_established"]}]'::jsonb,
  '{"platform_check": "needs_verification", "verification_notes": "Family-owned since 1990. 35+ yrs. SA + Boerne + New Braunfels + San Marcos + Helotes. Large multi-area = verify if still independent or already platform-acquired.", "spine_id": "plm-061"}'::jsonb,
  'Family-owned since 1990. 35+ yrs. SA + Boerne + New Braunfels + San Marcos + Helotes. Large multi-area = verify if still independent or already platform-acquired.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '4e4dd8a2-8735-5d4e-96d2-afd93db72d38', 'plumbing', 'Anchor Plumbing Services', 'Anchor Plumbing',
  '238220', NULL, 'San Antonio', 'Bexar',
  'TX', NULL, NULL, 'https://anchorplumbingservices.com/',
  NULL, 'RMP', 'Current',
  NULL, NULL, NULL,
  NULL, 10,
  6, 1,
  'website_team_page_or_buildzoom_or_dnb', NULL,
  45, 'biz_history_proxy',
  10, FALSE,
  '[]'::jsonb, '[{"source": "website", "url": "https://anchorplumbingservices.com/", "fetched_at": "2026-05-15", "fields": ["legal_name"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "TX-licensed; Master Plumber-led. Serves SA, Bexar, New Braunfels area.", "spine_id": "plm-062"}'::jsonb,
  'TX-licensed; Master Plumber-led. Serves SA, Bexar, New Braunfels area.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  'fef7fcda-d40f-5a3b-b8b9-c5cc602f28b2', 'plumbing', 'Chavarria''s Plumbing of SA, Inc.', 'Chavarria''s Plumbing',
  '238220', NULL, 'San Antonio', 'Bexar',
  'TX', NULL, NULL, 'https://chavarriasplumbingsa.com/',
  NULL, 'RMP', 'Current',
  NULL, NULL, NULL,
  NULL, 22,
  5, 1,
  'website_team_page_or_buildzoom_or_dnb', NULL,
  50, 'biz_history_proxy',
  22, FALSE,
  '[]'::jsonb, '[{"source": "website", "url": "https://chavarriasplumbingsa.com/", "fetched_at": "2026-05-15", "fields": ["legal_name"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "Family-owned and operated. Owner 20+ yrs full-time experience. SA + surrounding.", "spine_id": "plm-063"}'::jsonb,
  'Family-owned and operated. Owner 20+ yrs full-time experience. SA + surrounding.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  'bee99f15-b5cd-52d1-8c76-ef3209a48532', 'plumbing', 'American Auger Plumbing', NULL,
  '238220', NULL, 'San Antonio', 'Bexar',
  'TX', NULL, NULL, 'https://americanaugerplumbing.com/',
  NULL, 'RMP', 'Current',
  NULL, NULL, NULL,
  NULL, 30,
  4, 1,
  'website_team_page_or_buildzoom_or_dnb', NULL,
  55, 'biz_history_proxy',
  30, FALSE,
  '[]'::jsonb, '[{"source": "website", "url": "https://americanaugerplumbing.com/", "fetched_at": "2026-05-15", "fields": ["legal_name"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "Family-owned. 30+ yrs combined experience. All Bexar County.", "spine_id": "plm-064"}'::jsonb,
  'Family-owned. 30+ yrs combined experience. All Bexar County.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '5de3cac7-5394-520c-9bb1-e010aa272796', 'plumbing', 'S&S Plumbing', NULL,
  '238220', NULL, 'San Antonio', 'Bexar',
  'TX', NULL, NULL, 'https://www.ss-plumbing.com/',
  'M36596', 'RMP', 'Current',
  NULL, 'Steven Stanush', NULL,
  NULL, 20,
  4, 1,
  'website_team_page_or_buildzoom_or_dnb', 'Steven Stanush',
  50, 'license_tenure_proxy',
  20, FALSE,
  '[]'::jsonb, '[{"source": "website", "url": "https://www.ss-plumbing.com/", "fetched_at": "2026-05-15", "fields": ["legal_name", "license_number", "license_holder_name"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "Founder Steven Stanush, Master Plumber TX M36596. 20 yrs local experience. SA.", "spine_id": "plm-065"}'::jsonb,
  'Founder Steven Stanush, Master Plumber TX M36596. 20 yrs local experience. SA.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  'eca24d83-c71a-5afa-acb4-eac45bc824d2', 'plumbing', 'J.C. Enriquez and Son Plumbing', 'J.C. Enriquez Plumbing',
  '238220', NULL, 'San Antonio', 'Bexar',
  'TX', NULL, NULL, 'https://jcenriquezplumbing.com/',
  NULL, 'RMP', 'Current',
  NULL, NULL, NULL,
  NULL, 58,
  12, 3,
  'website_team_page_or_buildzoom_or_dnb', NULL,
  78, 'biz_history_proxy',
  58, FALSE,
  '[]'::jsonb, '[{"source": "website", "url": "https://jcenriquezplumbing.com/", "fetched_at": "2026-05-15", "fields": ["legal_name", "year_established"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "Founded 1968 by Joe Enriquez Sr. ''and Son'' = MULTI-GEN = INTERNAL SUCCESSOR by definition. 57+ yrs SA.", "spine_id": "plm-066"}'::jsonb,
  'Founded 1968 by Joe Enriquez Sr. ''and Son'' = MULTI-GEN = INTERNAL SUCCESSOR by definition. 57+ yrs SA.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  'c8a3d9fe-3fa2-5b69-9f71-02af7759e72c', 'plumbing', '210 Plumbing', NULL,
  '238220', NULL, 'San Antonio', 'Bexar',
  'TX', NULL, NULL, 'https://www.210plumber.com',
  NULL, 'RMP', 'Current',
  NULL, 'Russell Walker', NULL,
  NULL, 49,
  5, 2,
  'website_team_page_or_buildzoom_or_dnb', 'Russell Walker',
  75, 'biz_history_proxy',
  49, FALSE,
  '[]'::jsonb, '[{"source": "website", "url": "https://www.210plumber.com", "fetched_at": "2026-05-15", "fields": ["legal_name", "year_established", "license_holder_name"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "Two generations Walker family since 1977. 48+ yrs. SAME-SURNAME 2-gen = INTERNAL SUCCESSOR by definition.", "spine_id": "plm-067"}'::jsonb,
  'Two generations Walker family since 1977. 48+ yrs. SAME-SURNAME 2-gen = INTERNAL SUCCESSOR by definition.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '8bce62b5-cc50-5aad-bf17-f57140141236', 'plumbing', 'Will''s Plumbing & Testing Service', 'Will''s Plumbing',
  '238220', NULL, 'San Antonio', 'Bexar',
  'TX', NULL, NULL, 'https://willsplumbing.com/',
  NULL, 'RMP', 'Current',
  NULL, NULL, NULL,
  NULL, 25,
  6, 1,
  'website_team_page_or_buildzoom_or_dnb', NULL,
  55, 'biz_history_proxy',
  25, FALSE,
  '[]'::jsonb, '[{"source": "website", "url": "https://willsplumbing.com/", "fetched_at": "2026-05-15", "fields": ["legal_name"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "SA plumbing + backflow testing. 24-hour. Need to verify family-ownership in enrichment.", "spine_id": "plm-068"}'::jsonb,
  'SA plumbing + backflow testing. 24-hour. Need to verify family-ownership in enrichment.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '665eafbf-331b-537b-8d79-137dc8dd5867', 'plumbing', 'Juan''s Plumbing Services', NULL,
  '238220', NULL, 'San Antonio', 'Bexar',
  'TX', NULL, NULL, NULL,
  NULL, 'RMP', 'Current',
  NULL, 'Juan Lopez', NULL,
  NULL, 15,
  2, 1,
  'website_team_page_or_buildzoom_or_dnb', 'Juan Lopez',
  55, 'biz_history_proxy',
  15, FALSE,
  '[]'::jsonb, '[{"source": "web_search_snippet", "url": "https://nextdoor.com/pages/juans-plumbing-services-san-antonio-tx/", "fetched_at": "2026-05-15", "fields": ["legal_name", "license_holder_name"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "Family-owned. Juan Lopez = RMP. Small SA plumbing operation.", "spine_id": "plm-069"}'::jsonb,
  'Family-owned. Juan Lopez = RMP. Small SA plumbing operation.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '5d5744e7-8b51-5221-af33-909add3d7845', 'plumbing', 'J.R.''s Plumbing', NULL,
  '238220', NULL, 'San Antonio', 'Bexar',
  'TX', NULL, NULL, 'https://www.jrsplumbing.net/',
  NULL, 'RMP', 'Current',
  NULL, NULL, NULL,
  NULL, 46,
  5, 1,
  'website_team_page_or_buildzoom_or_dnb', NULL,
  67, 'biz_history_proxy',
  46, FALSE,
  '[]'::jsonb, '[{"source": "website", "url": "https://www.jrsplumbing.net/", "fetched_at": "2026-05-15", "fields": ["legal_name"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "Family + woman-owned. 40+ yrs SA. Long tenure.", "spine_id": "plm-070"}'::jsonb,
  'Family + woman-owned. 40+ yrs SA. Long tenure.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  'f3f2f987-602a-5dba-bfd9-ac6688e336d8', 'plumbing', 'HERNANDEZ PLUMBING & SEWER INC', NULL,
  '238220', '2747 BENRUS', 'San Antonio', 'Bexar',
  'TX', '78228', '(210) 912-5119', NULL,
  'M-39327', 'M (RMP qualifying license)', 'Current',
  '2009-10-15', 'ANTONIO S HERNANDEZ', NULL,
  NULL, 16,
  5, 1,
  'website_team_page_or_buildzoom_or_dnb', 'ANTONIO S HERNANDEZ',
  50, 'license_tenure_proxy',
  16, FALSE,
  '[]'::jsonb, '[{"source": "TSBPE RMP CSV", "url": "https://tsbpe.texas.gov/wp-content/uploads/2015/03/RMP.csv", "fetched_at": "2026-05-15", "fields": ["legal_name", "license_number", "license_issue_date", "license_holder_name", "address"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "TSBPE primary-source. SA west side (78228 \u2014 NW Loop 410). 16+ yrs Master Plumber tenure. MEDGAS + MRF endorsements = medical/multi-family adjacency = recurring service contract potential.", "spine_id": "plm-071"}'::jsonb,
  'TSBPE primary-source. SA west side (78228 — NW Loop 410). 16+ yrs Master Plumber tenure. MEDGAS + MRF endorsements = medical/multi-family adjacency = recurring service contract potential.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '50d67917-eb12-57bd-815c-731ab42e7151', 'plumbing', 'ALAMO PLUMBING A/C & HEAT LLC', NULL,
  '238220', '12810 OAK PASS', 'San Antonio', 'Bexar',
  'TX', '78253', '(210) 548-1113', NULL,
  'M-36584', 'M (RMP qualifying license)', 'Current',
  '2003-06-04', 'SAMUEL L LONGORIA', NULL,
  NULL, 22,
  6, 1,
  'website_team_page_or_buildzoom_or_dnb', 'SAMUEL L LONGORIA',
  60, 'license_tenure_proxy',
  22, FALSE,
  '[]'::jsonb, '[{"source": "TSBPE RMP CSV", "url": "https://tsbpe.texas.gov/wp-content/uploads/2015/03/RMP.csv", "fetched_at": "2026-05-15", "fields": ["legal_name", "license_number", "license_issue_date", "license_holder_name", "address"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "TSBPE primary-source. SA NW (78253 \u2014 Westover Hills). 22+ yrs Master Plumber tenure. Multi-trade plumbing + HVAC.", "spine_id": "plm-072"}'::jsonb,
  'TSBPE primary-source. SA NW (78253 — Westover Hills). 22+ yrs Master Plumber tenure. Multi-trade plumbing + HVAC.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '07c1385e-9494-52ab-9bb6-21d5516e550b', 'plumbing', 'RUTKOWSKI PLUMBING', NULL,
  '238220', NULL, 'Helotes', 'Bexar',
  'TX', '78023', '(210) 695-3276', NULL,
  'M-16201', 'M (RMP qualifying license)', 'Current',
  '1986-11-24', 'CARL WAYNE RUTKOWSKI', NULL,
  NULL, 39,
  5, 2,
  'website_team_page_or_buildzoom_or_dnb', 'CARL WAYNE RUTKOWSKI',
  70, 'license_tenure_proxy',
  39, FALSE,
  '[]'::jsonb, '[{"source": "TSBPE RMP CSV", "url": "https://tsbpe.texas.gov/wp-content/uploads/2015/03/RMP.csv", "fetched_at": "2026-05-15", "fields": ["legal_name", "license_number", "license_issue_date", "license_holder_name", "city"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "TSBPE primary-source. Helotes (premium NW Bexar/Hill Country edge). 39+ yrs Master Plumber tenure (1986). Owner-named DBA.", "spine_id": "plm-073"}'::jsonb,
  'TSBPE primary-source. Helotes (premium NW Bexar/Hill Country edge). 39+ yrs Master Plumber tenure (1986). Owner-named DBA.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '19bd3820-e45e-51eb-a4eb-fc9ee5253e9d', 'plumbing', 'J & M PLUMBING (J & M ORTIZ INC DBA)', 'J & M Plumbing',
  '238220', NULL, 'San Antonio', 'Bexar',
  'TX', '78224', '(210) 921-0668', NULL,
  'M-18468', 'M (RMP qualifying license)', 'Current',
  '1993-03-19', 'JESSE A ORTIZ', NULL,
  NULL, 32,
  3, 1,
  'website_team_page_or_buildzoom_or_dnb', 'JESSE A ORTIZ',
  65, 'license_tenure_proxy',
  32, FALSE,
  '[]'::jsonb, '[{"source": "TSBPE RMP CSV", "url": "https://tsbpe.texas.gov/wp-content/uploads/2015/03/RMP.csv", "fetched_at": "2026-05-15", "fields": ["legal_name", "license_number", "license_issue_date", "license_holder_name", "city"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "TSBPE primary-source. SA south (78224 \u2014 South Side). 32+ yrs Master Plumber tenure (1993).", "spine_id": "plm-074"}'::jsonb,
  'TSBPE primary-source. SA south (78224 — South Side). 32+ yrs Master Plumber tenure (1993).'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '7413ddee-f397-5cd7-bfa7-37f27b01e796', 'plumbing', 'CAROLINA''S PLUMBING SERVICES', NULL,
  '238220', NULL, 'San Antonio', 'Bexar',
  'TX', NULL, NULL, NULL,
  'M-42230', 'M (RMP qualifying license)', 'Current',
  '2017-12-05', 'CAROLINA ADEL MARTINEZ', NULL,
  NULL, 8,
  2, 1,
  'website_team_page_or_buildzoom_or_dnb', 'CAROLINA ADEL MARTINEZ',
  40, 'license_tenure_proxy',
  8, FALSE,
  '[]'::jsonb, '[{"source": "TSBPE RMP CSV", "url": "https://tsbpe.texas.gov/wp-content/uploads/2015/03/RMP.csv", "fetched_at": "2026-05-15", "fields": ["legal_name", "license_number", "license_issue_date", "license_holder_name"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "TSBPE primary-source. SA Bexar. Less than 10 yrs RMP \u2014 borderline new for thesis. Hard-gate risk.", "spine_id": "plm-075"}'::jsonb,
  'TSBPE primary-source. SA Bexar. Less than 10 yrs RMP — borderline new for thesis. Hard-gate risk.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '6d2d1a13-db14-5df1-8f6b-4ec2484d6e11', 'plumbing', 'SWINGING D CONSTRUCTION LLC', NULL,
  '238220', NULL, 'San Antonio', 'Bexar',
  'TX', '78261', '(210) 286-4056', NULL,
  'M-37493', 'M (RMP qualifying license)', 'Current',
  '2005-10-14', 'PATRICK NICHOLAS DENNIS', NULL,
  NULL, 20,
  4, 1,
  'website_team_page_or_buildzoom_or_dnb', 'PATRICK NICHOLAS DENNIS',
  58, 'license_tenure_proxy',
  20, FALSE,
  '[]'::jsonb, '[{"source": "TSBPE RMP CSV", "url": "https://tsbpe.texas.gov/wp-content/uploads/2015/03/RMP.csv", "fetched_at": "2026-05-15", "fields": ["legal_name", "license_number", "license_issue_date", "license_holder_name", "city"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "TSBPE primary-source. SA premium ZIP 78261 (Cibolo Canyons/Stone Oak periphery). 20+ yrs Master Plumber tenure. Construction-leaning \u2014 verify residential service mix.", "spine_id": "plm-076"}'::jsonb,
  'TSBPE primary-source. SA premium ZIP 78261 (Cibolo Canyons/Stone Oak periphery). 20+ yrs Master Plumber tenure. Construction-leaning — verify residential service mix.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '9c6492ea-29eb-5ec7-bf94-475fd9a42edd', 'plumbing', 'Austin Plumbing, Heating, Air & Electric', 'Team Austin',
  '238220', NULL, 'Austin', 'Travis',
  'TX', NULL, NULL, 'https://teamaustin.com/',
  NULL, 'RMP', 'Current',
  NULL, NULL, NULL,
  NULL, 92,
  40, 6,
  'website_team_page_or_buildzoom_or_dnb', NULL,
  68, 'biz_history_proxy',
  35, FALSE,
  '[]'::jsonb, '[{"source": "website", "url": "https://teamaustin.com/about/", "fetched_at": "2026-05-15", "fields": ["legal_name"]}]'::jsonb,
  '{"platform_check": "needs_verification", "verification_notes": "Founded 90+ yrs ago by Austin Smith. Now 3rd-gen family ownership. SAME-SURNAME 3-gen = INTERNAL SUCCESSOR by definition. Verify NOT yet acquired (multi-trade + 90 yrs = likely platform-adjacent).", "spine_id": "plm-077"}'::jsonb,
  'Founded 90+ yrs ago by Austin Smith. Now 3rd-gen family ownership. SAME-SURNAME 3-gen = INTERNAL SUCCESSOR by definition. Verify NOT yet acquired (multi-trade + 90 yrs = likely platform-adjacent).'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '74c21340-3925-5a03-8e5f-3cbbf2b123b8', 'plumbing', 'Johnny Rooter Plumbing', 'Johnny Rooter',
  '238220', NULL, 'Austin', 'Travis',
  'TX', NULL, NULL, 'https://johnnyrooter.com',
  NULL, 'RMP', 'Current',
  NULL, NULL, NULL,
  NULL, 33,
  6, 1,
  'website_team_page_or_buildzoom_or_dnb', NULL,
  55, 'biz_history_proxy',
  33, FALSE,
  '[]'::jsonb, '[{"source": "website", "url": "https://johnnyrooter.com/about/", "fetched_at": "2026-05-15", "fields": ["legal_name", "year_established"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "2nd-gen family. Greater Austin since 1993. 32 yrs.", "spine_id": "plm-078"}'::jsonb,
  '2nd-gen family. Greater Austin since 1993. 32 yrs.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  'c057c513-e871-5082-82da-c6259dbaedf0', 'plumbing', 'Mustang Plumbing', NULL,
  '238220', NULL, 'Round Rock', 'Williamson',
  'TX', NULL, NULL, 'https://mustangplumbingrr.com/',
  NULL, 'RMP', 'Current',
  '1983 (Master Plumber)', 'Todd Cox', NULL,
  NULL, 27,
  8, 1,
  'website_team_page_or_buildzoom_or_dnb', 'Todd Cox',
  63, 'license_tenure_proxy',
  43, FALSE,
  '[]'::jsonb, '[{"source": "website", "url": "https://mustangplumbingrr.com/about-us/", "fetched_at": "2026-05-15", "fields": ["legal_name", "year_established", "license_holder_name"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "Founded May 1999. Todd Cox MP since 1983 (youngest MP in TX history). Sons in business \u2014 SAME-SURNAME = INTERNAL SUCCESSOR by definition.", "spine_id": "plm-079"}'::jsonb,
  'Founded May 1999. Todd Cox MP since 1983 (youngest MP in TX history). Sons in business — SAME-SURNAME = INTERNAL SUCCESSOR by definition.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  'cf4efe8a-7148-5aa7-8b76-0c7b136bc59b', 'plumbing', 'The Plumbinator', NULL,
  '238220', NULL, 'Round Rock', 'Williamson',
  'TX', NULL, NULL, 'https://www.plumbinatoraustin.com/',
  NULL, 'RMP', 'Current',
  NULL, 'Mickey (Master Plumber)', NULL,
  NULL, 17,
  4, 1,
  'website_team_page_or_buildzoom_or_dnb', 'Mickey (Master Plumber)',
  50, 'biz_history_proxy',
  17, FALSE,
  '[]'::jsonb, '[{"source": "website", "url": "https://www.plumbinatoraustin.com/about", "fetched_at": "2026-05-15", "fields": ["legal_name", "year_established", "license_holder_name"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "Family-run, started 2009 by owner Wendy + Mickey (MP 30+ yrs). Round Rock + Austin metro + Cedar Park + Leander + Pflugerville.", "spine_id": "plm-080"}'::jsonb,
  'Family-run, started 2009 by owner Wendy + Mickey (MP 30+ yrs). Round Rock + Austin metro + Cedar Park + Leander + Pflugerville.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '3023cbef-2660-5f84-a512-026b1a796406', 'plumbing', 'G & M Plumbing, Inc.', NULL,
  '238220', '15303 Tacon Lane', 'Pflugerville', 'Travis',
  'TX', '78660', NULL, 'https://gandmplumbingtx.com/',
  NULL, 'RMP', 'Current',
  NULL, NULL, NULL,
  NULL, 38,
  5, 2,
  'website_team_page_or_buildzoom_or_dnb', NULL,
  63, 'biz_history_proxy',
  38, FALSE,
  '[]'::jsonb, '[{"source": "website", "url": "https://gandmplumbingtx.com/", "fetched_at": "2026-05-15", "fields": ["legal_name", "year_established", "address"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "Family-owned since 1987. 38 yrs. Master Plumber TX. Pflugerville/Austin.", "spine_id": "plm-081"}'::jsonb,
  'Family-owned since 1987. 38 yrs. Master Plumber TX. Pflugerville/Austin.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '596f875b-29be-59ce-9bf9-0180164514d0', 'plumbing', 'Beyond Wow Plumbing', NULL,
  '238220', NULL, 'Austin', 'Travis',
  'TX', NULL, NULL, 'https://beyondwow.com/',
  NULL, 'RMP', 'Current',
  NULL, NULL, NULL,
  NULL, 45,
  6, 1,
  'website_team_page_or_buildzoom_or_dnb', NULL,
  65, 'biz_history_proxy',
  45, FALSE,
  '[]'::jsonb, '[{"source": "website", "url": "https://beyondwow.com/", "fetched_at": "2026-05-15", "fields": ["legal_name", "year_established"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "Austin since 1980. 45+ yrs. Verify family-ownership in enrichment.", "spine_id": "plm-082"}'::jsonb,
  'Austin since 1980. 45+ yrs. Verify family-ownership in enrichment.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '0c9abe5f-dc27-5576-98b6-7cf5134712e8', 'plumbing', 'Excalibur Plumbing', NULL,
  '238220', NULL, 'Leander', 'Williamson',
  'TX', NULL, NULL, 'https://www.excaliburplumbing.com/',
  NULL, 'RMP', 'Current',
  NULL, NULL, NULL,
  NULL, 14,
  4, 1,
  'website_team_page_or_buildzoom_or_dnb', NULL,
  50, 'biz_history_proxy',
  14, FALSE,
  '[]'::jsonb, '[{"source": "website", "url": "https://www.excaliburplumbing.com/", "fetched_at": "2026-05-15", "fields": ["legal_name", "year_established"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "Leander/Metro Austin since 2011. Certified MP. 14 yrs (just past 5-yr gate).", "spine_id": "plm-083"}'::jsonb,
  'Leander/Metro Austin since 2011. Certified MP. 14 yrs (just past 5-yr gate).'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  'd3af4c1d-5b45-56a2-ba82-48e563e7c399', 'plumbing', 'CRESCENT PLUMBING', NULL,
  '238220', NULL, 'Austin', 'Travis',
  'TX', '78728', '(512) 251-0419', NULL,
  'M-17053', 'M (RMP qualifying license)', 'Current',
  '1988-08-16', 'MANUEL E RODRIGUEZ', NULL,
  NULL, 37,
  3, 1,
  'website_team_page_or_buildzoom_or_dnb', 'MANUEL E RODRIGUEZ',
  70, 'license_tenure_proxy',
  37, FALSE,
  '[]'::jsonb, '[{"source": "TSBPE RMP CSV", "url": "https://tsbpe.texas.gov/wp-content/uploads/2015/03/RMP.csv", "fetched_at": "2026-05-15", "fields": ["legal_name", "license_number", "license_issue_date", "license_holder_name", "city"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "TSBPE primary-source. North Austin (78728 \u2014 Wells Branch). 37+ yrs Master Plumber tenure (1988).", "spine_id": "plm-084"}'::jsonb,
  'TSBPE primary-source. North Austin (78728 — Wells Branch). 37+ yrs Master Plumber tenure (1988).'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  'ba51b9d1-9e62-578c-954d-ac31a151632b', 'plumbing', 'CK PLUMBING LLC DBA CLARK KENT PLUMBING INC', 'Clark Kent Plumbing',
  '238220', NULL, 'Austin', 'Travis',
  'TX', '78704', '(512) 477-2200', NULL,
  'M-14195', 'M (RMP qualifying license)', 'Current',
  '1990-01-01', 'GARY WAYNE HACKER', NULL,
  NULL, 40,
  15, 2,
  'website_team_page_or_buildzoom_or_dnb', 'GARY WAYNE HACKER',
  65, 'license_tenure_proxy',
  40, FALSE,
  '[]'::jsonb, '[{"source": "TSBPE RMP CSV", "url": "https://tsbpe.texas.gov/wp-content/uploads/2015/03/RMP.csv", "fetched_at": "2026-05-15", "fields": ["legal_name", "license_number", "license_holder_name", "city"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "TSBPE primary-source. Austin (78704 \u2014 South Austin/Travis Heights = premium older-housing). License # 14195 = legacy holder, decades-long tenure.", "spine_id": "plm-085"}'::jsonb,
  'TSBPE primary-source. Austin (78704 — South Austin/Travis Heights = premium older-housing). License # 14195 = legacy holder, decades-long tenure.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  'ece33457-c9bd-5a4f-924d-d83a88534b4e', 'plumbing', 'GILLINGWATER CONSTRUCTION LLC', NULL,
  '238220', NULL, 'Austin', 'Travis',
  'TX', '78731', '(737) 313-8115', NULL,
  'M-20834', 'M (RMP qualifying license)', 'Current',
  '1999-06-16', 'MARTIN JAY JENKINS', NULL,
  NULL, 26,
  4, 1,
  'website_team_page_or_buildzoom_or_dnb', 'MARTIN JAY JENKINS',
  60, 'license_tenure_proxy',
  26, FALSE,
  '[]'::jsonb, '[{"source": "TSBPE RMP CSV", "url": "https://tsbpe.texas.gov/wp-content/uploads/2015/03/RMP.csv", "fetched_at": "2026-05-15", "fields": ["legal_name", "license_number", "license_issue_date", "license_holder_name", "city"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "TSBPE primary-source. Austin (78731 \u2014 Northwest Hills, premium). 26+ yrs Master Plumber tenure. Construction-leaning \u2014 verify service mix.", "spine_id": "plm-086"}'::jsonb,
  'TSBPE primary-source. Austin (78731 — Northwest Hills, premium). 26+ yrs Master Plumber tenure. Construction-leaning — verify service mix.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '82ca6ae9-0486-5aa2-8e3d-39cef6417961', 'plumbing', 'CENTEX ELITE PLUMBING LLC', NULL,
  '238220', '10007 HERMES DR', 'Austin', 'Travis',
  'TX', '78725', '(512) 284-6859', NULL,
  'M-39448', 'M (RMP qualifying license)', 'Current',
  '2009-12-28', 'ISAAC LOPEZ', NULL,
  NULL, 16,
  3, 1,
  'website_team_page_or_buildzoom_or_dnb', 'ISAAC LOPEZ',
  55, 'license_tenure_proxy',
  16, FALSE,
  '[]'::jsonb, '[{"source": "TSBPE RMP CSV", "url": "https://tsbpe.texas.gov/wp-content/uploads/2015/03/RMP.csv", "fetched_at": "2026-05-15", "fields": ["legal_name", "license_number", "license_issue_date", "license_holder_name", "address"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "TSBPE primary-source. East Austin (78725). 16+ yrs Master Plumber tenure. Just past 5-yr gate.", "spine_id": "plm-087"}'::jsonb,
  'TSBPE primary-source. East Austin (78725). 16+ yrs Master Plumber tenure. Just past 5-yr gate.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  'f3a29759-5ba8-5381-8fc2-6f3f2a6e2fb5', 'plumbing', 'WPM CONSTRUCTION, INC', NULL,
  '238220', '5415 MCKINNEY FALLS PKWY', 'Austin', 'Travis',
  'TX', '78744', '(810) 606-1400', NULL,
  'M-39450', 'M (RMP qualifying license)', 'Current',
  '2009-12-28', 'ERIC JOSEPH CAMPOS', NULL,
  NULL, 16,
  3, 1,
  'website_team_page_or_buildzoom_or_dnb', 'ERIC JOSEPH CAMPOS',
  55, 'license_tenure_proxy',
  16, FALSE,
  '[]'::jsonb, '[{"source": "TSBPE RMP CSV", "url": "https://tsbpe.texas.gov/wp-content/uploads/2015/03/RMP.csv", "fetched_at": "2026-05-15", "fields": ["legal_name", "license_number", "license_issue_date", "license_holder_name", "address"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "TSBPE primary-source. SE Austin (78744). 16+ yrs Master Plumber tenure. Construction-leaning \u2014 needs service-mix verification.", "spine_id": "plm-088"}'::jsonb,
  'TSBPE primary-source. SE Austin (78744). 16+ yrs Master Plumber tenure. Construction-leaning — needs service-mix verification.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '5af1e4ab-eef5-5137-9350-e6865d64f1c5', 'plumbing', 'TK PLUMBING', NULL,
  '238220', NULL, 'Austin', 'Travis',
  'TX', NULL, NULL, NULL,
  'M-41442', 'M (RMP qualifying license)', 'Current',
  '2015-11-03', 'TIMOTHY W KINSEY', NULL,
  NULL, 10,
  2, 1,
  'website_team_page_or_buildzoom_or_dnb', 'TIMOTHY W KINSEY',
  45, 'license_tenure_proxy',
  10, FALSE,
  '[]'::jsonb, '[{"source": "TSBPE RMP CSV", "url": "https://tsbpe.texas.gov/wp-content/uploads/2015/03/RMP.csv", "fetched_at": "2026-05-15", "fields": ["legal_name", "license_number", "license_issue_date", "license_holder_name"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "TSBPE primary-source. Travis. 10 yrs RMP tenure \u2014 borderline for 5-yr gate, owner could be young (likely C-tier).", "spine_id": "plm-089"}'::jsonb,
  'TSBPE primary-source. Travis. 10 yrs RMP tenure — borderline for 5-yr gate, owner could be young (likely C-tier).'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '3c42a556-0271-5f33-839b-ec83341915e5', 'plumbing', 'MIKES PLUMBING', NULL,
  '238220', NULL, 'Round Rock', 'Williamson',
  'TX', '78683', '(512) 636-4160', NULL,
  'M-20095', 'M (RMP qualifying license)', 'Current',
  '1998-12-10', 'MICHAEL E GAVIT', NULL,
  NULL, 27,
  3, 1,
  'website_team_page_or_buildzoom_or_dnb', 'MICHAEL E GAVIT',
  65, 'license_tenure_proxy',
  27, FALSE,
  '[]'::jsonb, '[{"source": "TSBPE RMP CSV", "url": "https://tsbpe.texas.gov/wp-content/uploads/2015/03/RMP.csv", "fetched_at": "2026-05-15", "fields": ["legal_name", "license_number", "license_issue_date", "license_holder_name", "city"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "TSBPE primary-source. Round Rock. 27+ yrs Master Plumber tenure. Owner-named DBA.", "spine_id": "plm-090"}'::jsonb,
  'TSBPE primary-source. Round Rock. 27+ yrs Master Plumber tenure. Owner-named DBA.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  'c19fd902-e90a-59ff-991c-f755ef72e5ce', 'plumbing', 'MAG PLUMBING AND SERVICES', NULL,
  '238220', NULL, 'San Marcos', 'Hays',
  'TX', '78666', '(512) 353-4024', NULL,
  'M-38328', 'M (RMP qualifying license)', 'Current',
  '2007-10-19', 'ROBERT ROCHA', NULL,
  NULL, 18,
  3, 1,
  'website_team_page_or_buildzoom_or_dnb', 'ROBERT ROCHA',
  55, 'license_tenure_proxy',
  18, FALSE,
  '[]'::jsonb, '[{"source": "TSBPE RMP CSV", "url": "https://tsbpe.texas.gov/wp-content/uploads/2015/03/RMP.csv", "fetched_at": "2026-05-15", "fields": ["legal_name", "license_number", "license_issue_date", "license_holder_name", "city"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "TSBPE primary-source. San Marcos (Hays \u2014 Austin metro south edge). 18+ yrs Master Plumber tenure. Adjacent to Travis priority.", "spine_id": "plm-091"}'::jsonb,
  'TSBPE primary-source. San Marcos (Hays — Austin metro south edge). 18+ yrs Master Plumber tenure. Adjacent to Travis priority.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '944d8995-5467-524b-a455-bc750afaa9d3', 'plumbing', 'PAISLEY PLUMBING', NULL,
  '238220', NULL, 'Wimberley', 'Hays',
  'TX', '78676', '(512) 618-1890', NULL,
  'M-37469', 'M (RMP qualifying license)', 'Current',
  '2005-09-26', 'DANIEL PATRICK MATTINGLY', NULL,
  NULL, 20,
  2, 1,
  'website_team_page_or_buildzoom_or_dnb', 'DANIEL PATRICK MATTINGLY',
  55, 'license_tenure_proxy',
  20, FALSE,
  '[]'::jsonb, '[{"source": "TSBPE RMP CSV", "url": "https://tsbpe.texas.gov/wp-content/uploads/2015/03/RMP.csv", "fetched_at": "2026-05-15", "fields": ["legal_name", "license_number", "license_issue_date", "license_holder_name", "city"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "TSBPE primary-source. Wimberley (Hays \u2014 exurban Austin). 20+ yrs Master Plumber tenure. Exurban = L4 -5.", "spine_id": "plm-092"}'::jsonb,
  'TSBPE primary-source. Wimberley (Hays — exurban Austin). 20+ yrs Master Plumber tenure. Exurban = L4 -5.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  'f7d306c7-1962-5a25-907b-d021f0161800', 'plumbing', 'Lister Plumbing', NULL,
  '238220', NULL, 'Galveston', 'Galveston',
  'TX', NULL, NULL, 'https://www.listerplumbinginc.com/',
  'M17798', 'RMP', 'Current',
  NULL, NULL, NULL,
  NULL, 42,
  8, 3,
  'website_team_page_or_buildzoom_or_dnb', NULL,
  65, 'biz_history_proxy',
  42, FALSE,
  '[]'::jsonb, '[{"source": "website", "url": "https://www.listerplumbinginc.com/about-us", "fetched_at": "2026-05-15", "fields": ["legal_name", "year_established", "license_number"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "Family-owned since 1984. 3rd-gen Master Plumbers. License M17798. Serves Dickinson, Texas City, La Marque, Galveston, Santa Fe.", "spine_id": "plm-093"}'::jsonb,
  'Family-owned since 1984. 3rd-gen Master Plumbers. License M17798. Serves Dickinson, Texas City, La Marque, Galveston, Santa Fe.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '69f13874-e34f-5874-92e8-c24745b1a2d7', 'plumbing', 'Kona Plumbing', NULL,
  '238220', NULL, 'Galveston', 'Galveston',
  'TX', NULL, NULL, 'https://www.konaplumbing.net/',
  NULL, 'RMP', 'Current',
  NULL, NULL, NULL,
  NULL, 20,
  3, 1,
  'website_team_page_or_buildzoom_or_dnb', NULL,
  50, 'biz_history_proxy',
  20, FALSE,
  '[]'::jsonb, '[{"source": "website", "url": "https://www.konaplumbing.net/", "fetched_at": "2026-05-15", "fields": ["legal_name"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "Family-owned. 20+ yrs Galveston + Houston areas.", "spine_id": "plm-094"}'::jsonb,
  'Family-owned. 20+ yrs Galveston + Houston areas.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '91602aed-d3ba-5a47-b6af-45624baa98b6', 'plumbing', 'Beaumont Plumbing LLC', NULL,
  '238220', NULL, 'Beaumont', 'Jefferson',
  'TX', NULL, NULL, 'https://www.beaumontplumbingllc.com/',
  NULL, 'RMP', 'Current',
  NULL, NULL, NULL,
  NULL, 21,
  3, 1,
  'website_team_page_or_buildzoom_or_dnb', NULL,
  45, 'biz_history_proxy',
  20, FALSE,
  '[]'::jsonb, '[{"source": "website", "url": "https://www.beaumontplumbingllc.com/", "fetched_at": "2026-05-15", "fields": ["legal_name"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "MP-led 20+ yrs experience. Beaumont/Jefferson \u2014 secondary metro, L4 -3 to -5.", "spine_id": "plm-095"}'::jsonb,
  'MP-led 20+ yrs experience. Beaumont/Jefferson — secondary metro, L4 -3 to -5.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  'ab50cd85-3740-522b-a2a1-c52630b39f7c', 'plumbing', 'Ballard Plumbing', NULL,
  '238220', NULL, 'Beaumont', 'Jefferson',
  'TX', NULL, NULL, 'https://www.ballardplumbing.net/',
  NULL, 'RMP', 'Current',
  NULL, NULL, NULL,
  NULL, 15,
  3, 1,
  'website_team_page_or_buildzoom_or_dnb', NULL,
  50, 'biz_history_proxy',
  15, FALSE,
  '[]'::jsonb, '[{"source": "website", "url": "https://www.ballardplumbing.net/", "fetched_at": "2026-05-15", "fields": ["legal_name"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "Beaumont. Verify family-ownership + tenure in enrichment.", "spine_id": "plm-096"}'::jsonb,
  'Beaumont. Verify family-ownership + tenure in enrichment.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '5a67c1a3-0f89-51f7-8334-7f6c63fd622d', 'plumbing', 'DEWolfe''s Affordable Plumbing', NULL,
  '238220', NULL, 'Plano', 'Collin',
  'TX', NULL, NULL, NULL,
  NULL, 'RMP', 'Current',
  NULL, NULL, NULL,
  NULL, 20,
  3, 1,
  'website_team_page_or_buildzoom_or_dnb', NULL,
  55, 'unverified',
  20, FALSE,
  '[]'::jsonb, '[{"source": "web_search_snippet", "url": "https://nextdoor.com/pages/dewolfes-affordable-plumbing-plano-tx/", "fetched_at": "2026-05-15", "fields": ["legal_name", "city"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "Plano. Owner-named DBA. Need website + RMP verification.", "spine_id": "plm-097"}'::jsonb,
  'Plano. Owner-named DBA. Need website + RMP verification.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '897ccdd9-2d99-57f2-a55b-97b5f2032ad3', 'plumbing', 'Best Quality Plumbing', NULL,
  '238220', NULL, 'Plano', 'Collin',
  'TX', NULL, NULL, 'https://www.bestqualityplumbingtx.com/',
  NULL, 'RMP', 'Current',
  NULL, NULL, NULL,
  NULL, 25,
  3, 1,
  'website_team_page_or_buildzoom_or_dnb', NULL,
  55, 'biz_history_proxy',
  25, FALSE,
  '[]'::jsonb, '[{"source": "website", "url": "https://www.bestqualityplumbingtx.com/", "fetched_at": "2026-05-15", "fields": ["legal_name"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "Family-owned. Senior tech is MP with 25+ yrs experience. Plano/Collin.", "spine_id": "plm-098"}'::jsonb,
  'Family-owned. Senior tech is MP with 25+ yrs experience. Plano/Collin.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '2522b234-7807-5862-8ad0-2b1e87fad8a6', 'plumbing', 'S & B Plumbing', NULL,
  '238220', NULL, 'Sugar Land', 'Fort Bend',
  'TX', '77478', '(281) 898-0202', 'https://www.sandbplumbing.com/',
  'M-16885', 'M (RMP qualifying license)', 'Current',
  '1988-03-14', 'WILLIAM K EDMUNDS', NULL,
  NULL, 50,
  10, 3,
  'website_team_page_or_buildzoom_or_dnb', 'WILLIAM K EDMUNDS',
  70, 'license_tenure_proxy',
  37, FALSE,
  '[]'::jsonb, '[{"source": "website", "url": "https://www.sandbplumbing.com/", "fetched_at": "2026-05-15", "fields": ["legal_name", "year_established"]}, {"source": "TSBPE RMP CSV", "url": "https://tsbpe.texas.gov/wp-content/uploads/2015/03/RMP.csv", "fetched_at": "2026-05-15", "fields": ["license_number", "license_issue_date", "license_holder_name"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "Locally-owned-and-operated, three generations of Master Plumbers since 1976. 49 yrs. Sugar Land + Greater Houston. SAME-SURNAME 3-gen = INTERNAL SUCCESSOR by definition.", "spine_id": "plm-099"}'::jsonb,
  'Locally-owned-and-operated, three generations of Master Plumbers since 1976. 49 yrs. Sugar Land + Greater Houston. SAME-SURNAME 3-gen = INTERNAL SUCCESSOR by definition.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;


INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
  phone, website, license_number, license_type, license_status, license_issue_date,
  license_holder_name, entity_status, registered_agent, years_in_business,
  employee_count_estimate, provider_count_estimate, employee_count_source,
  owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '8c42d90a-db28-52e7-8117-f183e5fc86d7', 'plumbing', 'BARTSCH SERVICES INC', NULL,
  '238220', NULL, 'The Woodlands', 'Montgomery',
  'TX', '77380', '(281) 364-1944', NULL,
  'M-37279', 'M (RMP qualifying license)', 'Current',
  '2005-03-18', 'JEFFERY G BARTSCH', NULL,
  NULL, 20,
  3, 1,
  'website_team_page_or_buildzoom_or_dnb', 'JEFFERY G BARTSCH',
  55, 'license_tenure_proxy',
  20, FALSE,
  '[]'::jsonb, '[{"source": "TSBPE RMP CSV", "url": "https://tsbpe.texas.gov/wp-content/uploads/2015/03/RMP.csv", "fetched_at": "2026-05-15", "fields": ["legal_name", "license_number", "license_issue_date", "license_holder_name", "city"]}]'::jsonb,
  '{"platform_check": "independent", "verification_notes": "TSBPE primary-source. The Woodlands (Montgomery \u2014 Houston metro N). 20+ yrs Master Plumber tenure.", "spine_id": "plm-100"}'::jsonb,
  'TSBPE primary-source. The Woodlands (Montgomery — Houston metro N). 20+ yrs Master Plumber tenure.'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name, address = EXCLUDED.address, zip = EXCLUDED.zip,
  phone = EXCLUDED.phone, website = EXCLUDED.website, license_number = EXCLUDED.license_number,
  license_type = EXCLUDED.license_type, license_status = EXCLUDED.license_status,
  license_issue_date = EXCLUDED.license_issue_date, license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business, employee_count_estimate = EXCLUDED.employee_count_estimate,
  provider_count_estimate = EXCLUDED.provider_count_estimate, owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate, owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years, is_distressed = EXCLUDED.is_distressed,
  distress_reasons = EXCLUDED.distress_reasons, data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment, notes = EXCLUDED.notes, updated_at = NOW()
RETURNING id;
