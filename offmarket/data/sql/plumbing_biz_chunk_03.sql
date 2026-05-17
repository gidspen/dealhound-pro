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