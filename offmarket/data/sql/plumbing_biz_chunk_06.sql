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