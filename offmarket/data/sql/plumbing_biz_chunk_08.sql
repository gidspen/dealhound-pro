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