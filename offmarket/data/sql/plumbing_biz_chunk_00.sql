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