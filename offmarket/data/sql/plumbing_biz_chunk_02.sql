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