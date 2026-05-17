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