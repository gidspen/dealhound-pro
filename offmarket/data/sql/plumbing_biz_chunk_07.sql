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