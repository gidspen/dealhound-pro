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