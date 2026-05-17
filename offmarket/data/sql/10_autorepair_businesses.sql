-- Auto Repair businesses upsert (run autorepair-tx-2026-05-15)
BEGIN;

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('a5fe39a4-260d-5723-852f-e3a10e06efbf', 'auto_repair', 'Collinsworth Car Care Center', 'Collinsworth Car Care', '811111', '3201 Saturn Rd, Garland, TX 75041', 'Garland', 'Dallas', 'TX', NULL, NULL, 'https://www.collinsworthcarcare.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, 'Collinsworth family (specific names not on website)', NULL, NULL, NULL, NULL, 70, NULL, NULL, NULL, 'Collinsworth family (specific names not on website)', 90, 'license_tenure_proxy', 70, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://www.collinsworthcarcare.com/", "fetched_at": "2026-05-15"}, {"source": "live_website_fetch", "url": "https://www.collinsworthcarcare.com/", "fetched_at": "2026-05-15T23:55:00Z"}]'::jsonb, '{"live_fetch_summary": "Live fetch 2026-05-15: ''Since 1956'' = 70-yr Collinsworth-name business, ASE-certified, fleet pricing + pickup/delivery, SMS via Text START, M-F only weekends closed. No specific Collinsworth family members on page. Strong recurring fleet signal."}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('39cd68fa-a682-53e7-be1c-e5fb36d9b6a8', 'auto_repair', 'Poutous 1960 Auto Repair', 'Poutous Automotive', '811111', '8911 Mills Rd, Houston, TX 77064', 'Jersey Village', 'Harris', 'TX', '77040', NULL, 'https://www.poutousautorepair.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, 'Poutous family (specific name not on website)', NULL, NULL, NULL, NULL, 58, NULL, NULL, NULL, 'Poutous family (specific name not on website)', 90, 'license_tenure_proxy', 58, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://www.poutousautorepair.com/", "fetched_at": "2026-05-15"}, {"source": "live_website_fetch", "url": "https://www.poutousautorepair.com/", "fetched_at": "2026-05-15T23:55:00Z"}]'::jsonb, '{"live_fetch_summary": "Live fetch 2026-05-15: ''Since 1968'', ''ASE-Certified Master Technician'', fleet services language, M-F only Sat-Sun closed. No online booking visible. No specific owner name on website. Multi-decade Houston NW independent."}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('40b06b8e-1546-547b-9b90-a5b6ca1ac093', 'auto_repair', 'Reliant Complete Auto Care', 'Reliant Auto Care', '811111', '3511 FM 1960 E, Humble, TX 77338', 'Humble', 'Harris', 'TX', NULL, NULL, 'https://www.reliantautocare.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, 'Family-owned (no names visible)', NULL, NULL, NULL, NULL, 81, NULL, NULL, NULL, 'Family-owned (no names visible)', 90, 'license_tenure_proxy', 81, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://www.reliantautocare.com/about-us/index.html", "fetched_at": "2026-05-15"}, {"source": "live_website_fetch", "url": "https://www.reliantautocare.com/", "fetched_at": "2026-05-15T23:55:00Z"}]'::jsonb, '{"live_fetch_summary": "Live fetch 2026-05-15: ''Since 1945'' = **81-yr** Humble TX business (oldest in spine), Bosch-certified (German import specialist), serves ''largest fleets in the nation'', phone-only intake, Sat by appointment only. No online booking. No SMS. No EV. Strong coasting signal stack on tech modernization despite multi-decade business."}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('cfe8bc6a-a4fb-552e-a39b-f285424c2fa7', 'auto_repair', 'Addison Auto Repair', 'Addison Automotive', '811111', '14735 Inwood Rd, Addison, TX 75001', 'Addison', 'Dallas', 'TX', NULL, NULL, 'https://addisonautorepairdfw.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, 'Family-owned (no specific names on website)', NULL, NULL, NULL, NULL, 54, NULL, NULL, NULL, 'Family-owned (no specific names on website)', 86, 'license_tenure_proxy', 54, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://addisonautorepairdfw.com/", "fetched_at": "2026-05-15"}, {"source": "live_website_fetch", "url": "https://addisonautorepairdfw.com/", "fetched_at": "2026-05-15T23:55:00Z"}]'::jsonb, '{"live_fetch_summary": "Live fetch 2026-05-15: ''Since 1972'', 54-yr business, family-owned (no names), ASE-certified, fleet program offered, online booking + SMS active. Reduced Friday hours (8-5 vs 8-6) and weekend closure. No family names on site."}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('ec396231-2353-5443-9cb7-2e01c53b0db2', 'auto_repair', 'Byrd Automotive', 'Byrd Automotive', '811111', '2445 High Timbers Dr, The Woodlands TX 77380 + 311 N Live Oak St, Tomball TX 77375', 'The Woodlands', 'Montgomery', 'TX', NULL, NULL, 'https://www.byrdautomotive.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, 'Byrd family (specific names not on website)', NULL, NULL, NULL, NULL, 37, NULL, NULL, NULL, 'Byrd family (specific names not on website)', 69, 'license_tenure_proxy', 37, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://www.byrdautomotive.com/", "fetched_at": "2026-05-15"}, {"source": "live_website_fetch", "url": "https://www.byrdautomotive.com/", "fetched_at": "2026-05-15T23:55:00Z"}]'::jsonb, '{"live_fetch_summary": "Live fetch 2026-05-15: ''Since 1989'' = 37-yr Byrd-name Woodlands+Tomball business, AAA Top Rated 100% CSI + ASE, fleet services, free shuttle + pickup/delivery, M-F only, 2 locations. No specific Byrd family members on site."}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('a52eba26-bb47-55a6-80cf-82eae50ec20c', 'auto_repair', 'Hillin''s Auto Repair', 'Hillin''s Auto Repair', '811111', '1511 Somerset Rd, San Antonio, TX 78211', 'San Antonio', 'Bexar', 'TX', NULL, NULL, 'https://hillinsautorepair.net/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, 'Hillin family (specific names not on website)', NULL, NULL, NULL, NULL, 44, NULL, NULL, NULL, 'Hillin family (specific names not on website)', 76, 'license_tenure_proxy', 44, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://hillinsautorepair.net/", "fetched_at": "2026-05-15"}, {"source": "live_website_fetch", "url": "https://hillinsautorepair.net/", "fetched_at": "2026-05-15T23:55:00Z"}]'::jsonb, '{"live_fetch_summary": "Live fetch 2026-05-15: ''Since 1982'' = 44-yr Hillin-name SA business, ''Master ASE Certified technicians'', online booking, M-F only. No Hillin family members named on team page."}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('08b025d0-f105-511a-aa42-53548db55b43', 'auto_repair', 'Arbor Autoworks', 'Arbor Autoworks', '811111', '5422 Burnet Road, Austin, TX 78756', 'Austin', 'Travis', 'TX', NULL, NULL, 'https://arborautoworks.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, 'Michael Phan (Owner & Service Advisor)', NULL, NULL, NULL, NULL, 36, NULL, NULL, NULL, 'Michael Phan (Owner & Service Advisor)', 68, 'license_tenure_proxy', 36, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://arborautoworks.com/", "fetched_at": "2026-05-15"}, {"source": "live_website_fetch", "url": "https://arborautoworks.com/", "fetched_at": "2026-05-15T23:55:00Z"}]'::jsonb, '{"live_fetch_summary": "Live fetch 2026-05-15: ''Since 1990'' = 36-yr Austin business, **Michael Phan: Owner & Service Advisor** (carrying front-counter load = coasting tell), 4 named techs (Matt Doyle, Larry Swank, Daniel James, Matt Millen \u2014 all ''mechanical engineers'') + fleet service + ASE-certified + online booking + M-F only. No clear internal successor \u2014 techs are skilled labor not successor-track."}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('aff2f20e-f17f-5f07-b1e9-d850708915ed', 'auto_repair', 'AutoWorks', 'AutoWorks San Antonio', '811111', '4727 Timco W, San Antonio, TX 78238', 'San Antonio', 'Bexar', 'TX', NULL, NULL, 'https://autoworksatx.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, 'Family-owned (no names visible)', NULL, NULL, NULL, NULL, 43, NULL, NULL, NULL, 'Family-owned (no names visible)', 75, 'license_tenure_proxy', 43, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://autoworksatx.com/", "fetched_at": "2026-05-15"}, {"source": "live_website_fetch", "url": "https://autoworksatx.com/", "fetched_at": "2026-05-15T23:55:00Z"}]'::jsonb, '{"live_fetch_summary": "Live fetch 2026-05-15: ''Since 1983'' = 43-yr SA business, ASE + RepairPal + CarMax Warranty, Randy shop manager, online booking + SMS, **explicitly excludes EV vehicles** + reduced Friday hours (8:30-4) = coasting tell stack."}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('276077e8-6273-5e26-970a-ec1340d818a5', 'auto_repair', 'Midtown Auto Service & Repair', 'Midtown Auto Service', '811111', 'Houston, TX 77004 Midtown / Almeda Road', 'Houston', 'Harris', 'TX', '77004', NULL, 'https://www.midtownautoservice.net/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, 'Mike Yu', NULL, NULL, NULL, NULL, 39, NULL, NULL, NULL, 'Mike Yu', 71, 'license_tenure_proxy', 39, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://www.midtownautoservice.net/", "fetched_at": "2026-05-15"}, {"source": "live_website_fetch", "url": "https://www.midtownautoservice.net/", "fetched_at": "2026-05-15T23:55:00Z"}]'::jsonb, '{"live_fetch_summary": "Live fetch 2026-05-15: ''Mike Yu running shop for 25 years'', AAA Approved + NAPA AutoCare + ASE Certified, founded 1987 = 39-yr business. No online booking, no SMS, no EV. Strong triple-cert (ASE+AAA+NAPA) independent."}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('fcd4a2b9-79e9-550e-a3c9-e0c46e2b948b', 'auto_repair', 'Lorentz Automotive', 'Lorentz Auto Denton', '811111', '505 N Elm St, Denton, TX 76201', 'Denton', 'Denton', 'TX', '76201', NULL, 'https://lorentzautodenton.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, 'Lorentz family (specific names not on website)', NULL, NULL, NULL, NULL, 44, NULL, NULL, NULL, 'Lorentz family (specific names not on website)', 76, 'license_tenure_proxy', 44, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://lorentzautodenton.com/about-us/", "fetched_at": "2026-05-15"}, {"source": "live_website_fetch", "url": "https://lorentzautodenton.com/about-us/", "fetched_at": "2026-05-15T23:55:00Z"}]'::jsonb, '{"live_fetch_summary": "Live fetch 2026-05-15: ''Since 1982'' = 44-yr Lorentz-family business in Denton, ASE-certified, 40+ yrs combined tech experience. No specific Lorentz family members visible on team page. M-F only."}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('61725396-46ac-5585-b226-ded456364592', 'auto_repair', 'Vick''s Expertune Automotive', 'Vick''s Expertune', '811111', '1806 W Howard Lane Suite D, Austin, TX 78728', 'Austin', 'Travis', 'TX', NULL, NULL, 'https://vicks-expertune.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, 'Vick (specific full name not visible)', NULL, NULL, NULL, NULL, 39, NULL, NULL, NULL, 'Vick (specific full name not visible)', 71, 'license_tenure_proxy', 39, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://vicks-expertune.com/", "fetched_at": "2026-05-15"}, {"source": "live_website_fetch", "url": "https://vicks-expertune.com/", "fetched_at": "2026-05-15T23:55:00Z"}]'::jsonb, '{"live_fetch_summary": "Live fetch 2026-05-15: ''Since 1987'' = 39-yr Vick-name Austin business, ASE-certified, online booking, M-F only. Dane in reviews. No clear family successor."}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('c7587b4d-c161-5510-a919-2539b30784e1', 'auto_repair', 'Green & White Automotive', 'Green & White Automotive', '811111', '1020 Spring Cypress Rd, Spring, TX 77373', 'Spring', 'Harris', 'TX', NULL, NULL, 'https://greenandwhiteauto.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, 'Kent Morris', NULL, NULL, NULL, NULL, 49, NULL, NULL, NULL, 'Kent Morris', 81, 'license_tenure_proxy', 49, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://greenandwhiteauto.com/about/", "fetched_at": "2026-05-15"}, {"source": "live_website_fetch", "url": "https://greenandwhiteauto.com/about/", "fetched_at": "2026-05-15T23:55:00Z"}]'::jsonb, '{"live_fetch_summary": "Live fetch 2026-05-15: ''Kent Morris owner'', ''since 1977'', AAA Approved + ASE + BBB A+, BG Protection Plan + 30K interval maintenance, online booking active, M-Sat hours. 49-yr business, single named owner, no successor on site."}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('1161c6b8-52d2-5065-929e-a6cfffa3372e', 'auto_repair', 'Montrose Automotive', 'Montrose Automotive & Bodywork', '811111', '4720 Montrose Blvd, Houston, TX 77006', 'Houston', 'Harris', 'TX', '77006', NULL, 'https://montroseautocenter.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, 'Family-owned (no names on website)', NULL, NULL, NULL, NULL, 57, NULL, NULL, NULL, 'Family-owned (no names on website)', 89, 'license_tenure_proxy', 57, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://montroseautocenter.com/", "fetched_at": "2026-05-15"}, {"source": "live_website_fetch", "url": "https://montroseautocenter.com/", "fetched_at": "2026-05-15T23:55:00Z"}]'::jsonb, '{"live_fetch_summary": "Live fetch 2026-05-15: ''55+ Years serving'' since 1969 = 57-yr Houston Montrose business, AAA Approved + ASE, weekend/evening hours available, online booking via ''Book Service Now''. ''Family-owned warmth'' language but no specific family members named."}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('fcb5ae05-5c1d-5fe0-ade1-965c3661663e', 'auto_repair', 'Ross & Greenville Automotive', 'Ross & Greenville', '811111', '11051 Garland Rd, Dallas, TX 75218', 'Dallas', 'Dallas', 'TX', NULL, NULL, 'https://rossandgreenvilleautomotive.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, 'Jacob (owner/manager - last name not on site)', NULL, NULL, NULL, NULL, 80, NULL, NULL, NULL, 'Jacob (owner/manager - last name not on site)', 90, 'license_tenure_proxy', 80, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://rossandgreenvilleautomotive.com/", "fetched_at": "2026-05-15"}, {"source": "live_website_fetch", "url": "https://rossandgreenvilleautomotive.com/", "fetched_at": "2026-05-15T23:55:00Z"}]'::jsonb, '{"live_fetch_summary": "Live fetch 2026-05-15: ''Family Owned Since 1946'' = 80-yr business, Jacob owner/manager, ASE-certified, online scheduling, Sat half-day. Three named staff (Jacob, Alan, Laurie). No multi-generation family surname visible. Maintenance plan referenced."}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('4ba5ab8a-6d6b-5915-85a6-ab309182d432', 'auto_repair', 'Today''s European Cars', 'Today''s European Cars Inc', '811111', '6261 Richmond Avenue, Houston, TX 77057', 'Houston', 'Harris', 'TX', NULL, NULL, 'https://www.cars-autos.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, 'Family-owned (no names visible)', NULL, NULL, NULL, NULL, 42, NULL, NULL, NULL, 'Family-owned (no names visible)', 74, 'license_tenure_proxy', 42, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://www.cars-autos.com/", "fetched_at": "2026-05-15"}, {"source": "live_website_fetch", "url": "https://www.cars-autos.com/", "fetched_at": "2026-05-15T23:55:00Z"}]'::jsonb, '{"live_fetch_summary": "Live fetch 2026-05-15: ''Family-owned since 1984'' = 42-yr Houston German-import specialist (Mercedes/BMW/Audi/VW/Mini), online booking + SMS + digital inspections + factory-scheduled maintenance reminders. M-F only. No certifications explicitly stated. No specific family members."}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('5087daf8-2bfe-5f47-b5f5-0031f133452f', 'auto_repair', 'Bolen''s Automotive', 'Bolen''s Automotive', '811111', '5200 McCart Ave, Fort Worth, TX 76115', 'Fort Worth', 'Tarrant', 'TX', NULL, NULL, 'https://bolensauto.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, 'Bolen family (specific names not on website)', NULL, NULL, NULL, NULL, 48, NULL, NULL, NULL, 'Bolen family (specific names not on website)', 80, 'license_tenure_proxy', 48, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://bolensauto.com/", "fetched_at": "2026-05-15"}, {"source": "live_website_fetch", "url": "https://bolensauto.com/", "fetched_at": "2026-05-15T23:55:00Z"}]'::jsonb, '{"live_fetch_summary": "Live fetch 2026-05-15: ''Since 1978'' = 48-yr Bolen-name Fort Worth business, 5 named staff (Mark mgr, Joe, John, Rob, Paula) \u2014 NO BOLEN surname in named staff = no visible family successor. ASE-certified, online booking, hybrid repair, M-F only. Strong A-candidate signal: founder still active, no internal successor."}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('1e821135-c79f-5fbc-89a3-6fd8c27d9ad6', 'auto_repair', 'Carlisle Air Automotive', 'Carlisle Air Auto', '811111', '3500 West Loop 1604 South, San Antonio, TX 78245', 'San Antonio', 'Bexar', 'TX', NULL, NULL, 'https://carlisleautoair.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, 'Carlisle family (specific names not on website)', NULL, NULL, NULL, NULL, 71, NULL, NULL, NULL, 'Carlisle family (specific names not on website)', 90, 'license_tenure_proxy', 71, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://carlisleautoair.com/west-san-antonio/", "fetched_at": "2026-05-15"}, {"source": "live_website_fetch", "url": "https://carlisleautoair.com/west-san-antonio/", "fetched_at": "2026-05-15T23:55:00Z"}]'::jsonb, '{"live_fetch_summary": "Live fetch 2026-05-15: ''Since 1955'' = 71-yr Carlisle-name business in West SA, ASE-certified, online appointment scheduling, Sat half-day. ''Family-owned'' but no specific Carlisle members named on site."}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('c2ced8e5-4526-5d35-a8d5-190a294f8c01', 'auto_repair', 'AB&T Diesel Repair', 'AB&T Diesel Pflugerville', '811111', NULL, 'Pflugerville', 'Travis', 'TX', NULL, NULL, 'https://www.fordpowerstrokediesel-tx.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 51, NULL, NULL, NULL, 'Central Texas family-owned', 83, 'license_tenure_proxy', 51, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://www.fordpowerstrokediesel-tx.com/auto-repairs-pflugerville-tx/", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('0501d0c7-ad95-54a2-9259-1c9bcb853894', 'auto_repair', 'Auto Pros Houston', 'Auto Pros', '811111', NULL, 'Bellaire', 'Harris', 'TX', '77081', NULL, 'https://autoproshouston.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 51, NULL, NULL, NULL, 'unknown', 83, 'license_tenure_proxy', 51, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://autoproshouston.com/", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('62dfdaf4-bb3f-5ccf-b0a5-14e3613f94ec', 'auto_repair', 'Collins Auto Repair', 'Collins Auto Repair', '811111', NULL, 'Houston', 'Harris', 'TX', NULL, NULL, NULL, NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 41, NULL, NULL, NULL, 'Collins family (40+ yrs)', 73, 'license_tenure_proxy', 41, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://www.facebook.com/p/Collins-Auto-Repair-Family-owned-and-operated-since-1985-100082505596704/", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('557f951a-bd0b-5774-95a8-1162e914248e', 'auto_repair', 'Hance''s Uptown Collision Center', 'Hance Auto', '811111', NULL, 'Plano', 'Collin', 'TX', NULL, NULL, 'https://www.hanceauto.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 71, NULL, NULL, NULL, 'Hance family (multi-generation)', 90, 'license_tenure_proxy', 71, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://www.hanceauto.com/", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('18aa5008-05b2-5770-a14d-2c08c2e1e4bb', 'auto_repair', 'Heights Auto Repair', 'Heights Auto Repair', '811111', '735 W. 19th St., Houston, TX 77008', 'Houston', 'Harris', 'TX', '77008', NULL, 'https://heightsautorepair.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, 'Alfredo (full name not visible)', NULL, NULL, NULL, NULL, 31, NULL, NULL, NULL, 'Alfredo (full name not visible)', 63, 'license_tenure_proxy', 31, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://heightsautorepair.com/", "fetched_at": "2026-05-15"}, {"source": "live_website_fetch", "url": "https://heightsautorepair.com/", "fetched_at": "2026-05-15T23:55:00Z"}]'::jsonb, '{"live_fetch_summary": "Live fetch 2026-05-15: ''Since 1995'' = 31-yr Heights Houston business, Alfredo named as owner leading ''his hard-working team'', online booking + SMS + Sat open, **expanding to 2nd location Summer 2026** = NOT coasting, growth-mode. Demote A consideration; B for forward."}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('77fb8ce3-0c21-555c-9a0f-060390c33ea3', 'auto_repair', 'Leonard''s Automotive Service Center', 'Leonard''s Auto Austin', '811111', NULL, 'Austin', 'Travis', 'TX', NULL, NULL, NULL, NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 54, NULL, NULL, NULL, 'Leonard family (54+ yrs)', 86, 'license_tenure_proxy', 54, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://repairpal.com/auto-repair-near-me/auto-repair-in-austin-texas", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('17ffc523-6e0d-588c-89b4-1f113bf6105c', 'auto_repair', 'RMS Auto Care', 'RMS Auto Care', '811111', NULL, 'Houston', 'Harris', 'TX', NULL, NULL, 'https://rmsautocare.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 42, NULL, NULL, NULL, 'Veteran 2nd-gen family', 74, 'license_tenure_proxy', 42, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://rmsautocare.com/", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('f00dd203-e150-5466-935c-6193a741dbf0', 'auto_repair', 'Southwest Muffler & Brake', 'Southwest Muffler & Brake', '811111', NULL, 'Stafford', 'Fort Bend', 'TX', '77477', NULL, 'https://www.southwestmuffler.com/location/stafford/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 67, NULL, NULL, NULL, 'long-tenured family ownership', 90, 'license_tenure_proxy', 67, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://www.southwestmuffler.com/location/stafford/", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('ec177604-959d-5676-bd83-83d76f5121e6', 'auto_repair', 'Bellaire Auto Center', 'Bellaire Auto Center', '811111', NULL, 'Bellaire', 'Harris', 'TX', NULL, NULL, 'https://bellaireautocenter.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 36, NULL, NULL, NULL, 'family-owned independent', 68, 'license_tenure_proxy', 36, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://bellaireautocenter.com/", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('b7d2aa14-c570-54ee-bfa1-172eb4eb8f6d', 'auto_repair', 'Classic Auto Repair of Lantana', 'Classic Auto Repair Lantana', '811111', NULL, 'Bartonville', 'Denton', 'TX', NULL, NULL, 'https://texasrepairshop.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 46, NULL, NULL, NULL, 'family-owned 45+ yrs (classics specialist)', 78, 'license_tenure_proxy', 46, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://texasrepairshop.com/", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('740c5e44-4589-5363-a779-b496d33f31c4', 'auto_repair', 'Kenneth''s Car Care', 'Kenneth''s Car Care', '811111', '1900 Northpark Drive, Kingwood, TX 77339', 'Kingwood', 'Harris', 'TX', NULL, NULL, 'https://www.kennethscarcare.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, 'Kenneth (specific full name not visible)', NULL, NULL, NULL, NULL, 50, NULL, NULL, NULL, 'Kenneth (specific full name not visible)', 82, 'license_tenure_proxy', 50, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://www.kennethscarcare.com/", "fetched_at": "2026-05-15"}, {"source": "live_website_fetch", "url": "https://www.kennethscarcare.com/", "fetched_at": "2026-05-15T23:55:00Z"}]'::jsonb, '{"live_fetch_summary": "Live fetch 2026-05-15: ''Starting our business in 1976'' = 50-yr Kenneth-name Kingwood business, 20+ bays, GM Grayson Gerloff identified + 7 named staff (Chris, Luke, Jonathan, Marvin, David, Natalie, Candy). Modern ops: online scheduling, SMS, photo estimates, I-CAR Gold. **Internal successor candidate: GM Gerloff** = demotes from A to B."}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('851edc2a-14e6-5ecf-87b7-88677ccdc588', 'auto_repair', 'Phil''s Service', 'Phil''s Service Killeen', '811111', '503 S 2nd St, Killeen, TX 76541', 'Killeen', 'Bell', 'TX', NULL, NULL, 'https://philsservice.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, 'Phil (specific full name not visible)', NULL, NULL, NULL, NULL, 30, NULL, NULL, NULL, 'Phil (specific full name not visible)', 62, 'license_tenure_proxy', 30, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://philsservice.com/", "fetched_at": "2026-05-15"}, {"source": "live_website_fetch", "url": "https://philsservice.com/", "fetched_at": "2026-05-15T23:55:00Z"}]'::jsonb, '{"live_fetch_summary": "Live fetch 2026-05-15: ''Since 1996'' = 30-yr Phil-name Killeen business, **ASE Blue Seal of Excellence** (top ~1500 nationally) + TechNet Professional + NAPA payment, mobile app for customer portal, online scheduling. Ms. Sally is staff but not successor-titled. Killeen (Bell County) = exurban/military-adjacent."}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('4e20491d-56df-5720-9e54-e2fbacc1dc75', 'auto_repair', 'Uzi''s Autohaus', 'Uzi''s Autohaus', '811111', '4201 Bellaire Blvd, Houston, TX 77025', 'Bellaire', 'Harris', 'TX', NULL, NULL, 'https://uzisautohaus.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, 'Uzi family (2nd generation operating)', NULL, NULL, NULL, NULL, 41, NULL, NULL, NULL, 'Uzi family (2nd generation operating)', 73, 'license_tenure_proxy', 41, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://uzisautohaus.com/", "fetched_at": "2026-05-15"}, {"source": "live_website_fetch", "url": "https://uzisautohaus.com/", "fetched_at": "2026-05-15T23:55:00Z"}]'::jsonb, '{"live_fetch_summary": "Live fetch 2026-05-15: ''Since 1985'' = 41-yr Uzi-family Bellaire business, **EXPLICITLY ''2nd generation of family operating''** = succession in place = NOT off-market target. Scheduled Maintenance Plans offered, online booking, ASE-certified. Demote to D_pass / C_watch \u2014 internal succession executed."}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('19cf8068-7ef5-5abe-96a8-1335a887abf2', 'auto_repair', 'David''s Auto Central', 'David''s Auto Central', '811111', NULL, 'Stafford', 'Fort Bend', 'TX', NULL, NULL, NULL, NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 37, NULL, NULL, NULL, 'David (family-owned)', 69, 'license_tenure_proxy', 37, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://www.facebook.com/DavidsAutoCentral/", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('c85b432e-a56b-5165-99de-b4fbe2c6032c', 'auto_repair', 'Kingwood Service Center', 'Kingwood Service Center', '811111', NULL, 'Kingwood', 'Harris', 'TX', NULL, NULL, 'https://www.kingwoodservicecenter.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 34, NULL, NULL, NULL, 'unknown', 66, 'license_tenure_proxy', 34, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://www.kingwoodservicecenter.com/", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('70ac912c-be48-5e14-a258-7c7ef9e14049', 'auto_repair', 'NB Exxon', 'NB Exxon Richardson', '811111', NULL, 'Richardson', 'Dallas', 'TX', NULL, NULL, 'https://www.nb-exxon.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 34, NULL, NULL, NULL, 'NB family-owned', 66, 'license_tenure_proxy', 34, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://www.nb-exxon.com/", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('0061f14b-e8ad-506d-939a-d06c7e44981d', 'auto_repair', 'Ruben''s Auto Repair', 'Ruben''s Auto Care', '811111', NULL, 'San Antonio', 'Bexar', 'TX', NULL, NULL, 'https://rubensautocare.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 34, NULL, NULL, NULL, 'Ruben (family-owned 30+ yrs)', 66, 'license_tenure_proxy', 34, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://rubensautocare.com/", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('dc67ef7a-79f3-57bc-9cea-9f8421b2a2ab', 'auto_repair', 'Lopez Auto Repair', 'Lopez Automotive Austin', '811111', NULL, 'Austin', 'Travis', 'TX', NULL, NULL, 'https://lopezautorepair.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 32, NULL, NULL, NULL, 'Lopez family', 64, 'license_tenure_proxy', 32, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://lopezautorepair.com/", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('5229c565-a888-5ae6-9922-c929191a0087', 'auto_repair', 'MTZ Engine Rebuilders', 'MTZ Engine Rebuilders', '811111', NULL, 'Sugar Land', 'Fort Bend', 'TX', NULL, NULL, NULL, NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 32, NULL, NULL, NULL, 'MTZ family (Hispanic-owned)', 64, 'license_tenure_proxy', 32, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://www.yelp.com/search?find_desc=Auto+Services&find_loc=Sugar+Land,+TX", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('a78586ea-014e-5171-a1b8-0fc8913a3200', 'auto_repair', 'Hance''s European', 'Hance''s European Auto Repair', '811111', NULL, 'Dallas', 'Dallas', 'TX', NULL, NULL, 'https://www.hanceseuropean.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 31, NULL, NULL, NULL, 'Hance family', 63, 'license_tenure_proxy', 31, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://www.hanceseuropean.com/", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('a294d04d-66a6-57a6-b024-711532608fc5', 'auto_repair', 'Newman''s Automotive', 'Newman''s Auto', '811111', NULL, 'Austin', 'Travis', 'TX', NULL, NULL, 'https://www.newmansauto.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 31, NULL, NULL, NULL, 'Newman family (31+ yrs)', 63, 'license_tenure_proxy', 31, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://www.newmansauto.com/", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('87565e87-e0af-5111-896a-58eda7838323', 'auto_repair', 'Rob and Son''s Garage', 'Rob and Son''s Auto', '811111', NULL, 'Arlington', 'Tarrant', 'TX', NULL, NULL, 'https://robandsongarage.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 35, NULL, NULL, NULL, 'Rob and son (family multi-generation)', 67, NULL, 35, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://robandsongarage.com/", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('2ce38081-881c-54ec-8997-7c08cbea8dde', 'auto_repair', 'Adair & Sons', 'Adair and Sons Round Rock', '811111', NULL, 'Round Rock', 'Williamson', 'TX', NULL, NULL, 'https://www.adairandsons.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 35, NULL, NULL, NULL, 'Adair family (multi-generation - ''and Sons'')', 67, NULL, 35, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://www.adairandsons.com/domestic-auto-service-repair-round-rock/", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('9016ab94-dd2d-51e7-9686-a4fca8304fc3', 'auto_repair', 'Craig''s Car Care', 'Craig''s Car Care Allen', '811111', NULL, 'Allen', 'Collin', 'TX', NULL, NULL, 'https://craigscarcare.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 30, NULL, NULL, NULL, 'Craig (family-owned)', 62, 'license_tenure_proxy', 30, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://craigscarcare.com/", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('5f458c51-6698-578f-9279-de55f7c360d0', 'auto_repair', 'A&R Automotive', 'A&R Automotive Garland', '811111', NULL, 'Garland', 'Dallas', 'TX', NULL, NULL, 'https://anrautomotive.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 29, NULL, NULL, NULL, 'family-owned', 61, 'license_tenure_proxy', 29, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://anrautomotive.com/", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('0972eccb-d711-5836-a279-9f32ea1663de', 'auto_repair', 'Dave''s Ultimate Automotive', 'Dave''s Ultimate Auto', '811111', NULL, 'Cedar Park', 'Williamson', 'TX', NULL, NULL, 'https://davesultimateautomotive.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 29, NULL, NULL, NULL, 'Dave (family-owned, multi-location, ASE Tech of the Year)', 61, 'license_tenure_proxy', 29, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://davesultimateautomotive.com/", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('0290c923-29b0-54b6-9b62-86f0f815ec50', 'auto_repair', 'Current 2 Classics', 'Current 2 Classics SA', '811111', NULL, 'San Antonio', 'Bexar', 'TX', NULL, NULL, 'https://www.current2classics.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 28, NULL, NULL, NULL, 'family-owned (30+ yrs)', 60, NULL, 28, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://www.current2classics.com/", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('6530e222-f36e-5953-a3a4-35fd1ea12ef6', 'auto_repair', 'Rick and Ray''s Auto Plaza', 'Rick and Ray''s', '811111', NULL, 'Fort Worth', 'Tarrant', 'TX', NULL, NULL, 'https://rickandraysautoplaza.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 28, NULL, NULL, NULL, 'Rick & Ray (30+ yrs)', 60, NULL, 28, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://rickandraysautoplaza.com/", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('9af1bbe4-115c-5fa4-be0e-1ca28c601995', 'auto_repair', 'Tech One Automotive', 'Tech One Auto Austin', '811111', NULL, 'Austin', 'Travis', 'TX', NULL, NULL, 'https://www.techoneauto.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 27, NULL, NULL, NULL, 'family-owned', 59, 'license_tenure_proxy', 27, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://www.techoneauto.com/", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('dd29e9d6-0b3b-5f84-ab33-23e714462574', 'auto_repair', 'Texas Auto Service Inc', 'Texas Auto Service Keller', '811111', NULL, 'Keller', 'Tarrant', 'TX', NULL, NULL, 'https://texasautoservice.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 27, NULL, NULL, NULL, 'Tim Sosebee (family-owned)', 59, 'license_tenure_proxy', 27, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://texasautoservice.com/about-us/", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('1ac67cd7-7298-5e1e-8a2d-403d3723eb8b', 'auto_repair', 'Friendswood Auto Center', 'Friendswood Auto Center', '811111', NULL, 'Friendswood', 'Galveston', 'TX', '77546', NULL, 'https://www.friendswoodautocenter.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 26, NULL, NULL, NULL, 'family business (non-chain)', 58, 'license_tenure_proxy', 26, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://www.friendswoodautocenter.com/about-us/", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('de89b51c-7e8a-566b-8591-e4091d91fe52', 'auto_repair', 'Auto Service Experts', 'Auto Service Experts SA', '811111', NULL, 'San Antonio', 'Bexar', 'TX', NULL, NULL, 'https://www.autorepairsanantonio.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 24, NULL, NULL, NULL, 'family-owned (ASE Blue Seal)', 56, 'license_tenure_proxy', 24, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://www.autorepairsanantonio.com/", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('23dd2898-1f75-5f99-8605-ae18bee56b27', 'auto_repair', 'Bert''s Gene Brown Transmissions', 'Bert''s Gene Brown Transmissions', '811111', NULL, 'San Antonio', 'Bexar', 'TX', NULL, NULL, 'https://brokentransmission.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 20, NULL, NULL, NULL, 'Brown family (long-tenured transmission specialist)', 52, NULL, 20, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://brokentransmission.com/", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('b092293c-2f13-5bda-875b-cb931f2c0eba', 'auto_repair', 'Ichiban Autos', 'Ichiban Autos', '811111', NULL, 'Fort Worth', 'Tarrant', 'TX', NULL, NULL, 'https://ichibanautos.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 24, NULL, NULL, NULL, 'family-owned (Japanese import specialist)', 56, 'license_tenure_proxy', 24, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://ichibanautos.com/", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('ada8e96b-a656-5042-a6eb-e3d2df57dccf', 'auto_repair', 'Vo Automotive Service Center', 'Vo Automotive', '811111', NULL, 'Fort Worth', 'Tarrant', 'TX', NULL, NULL, 'https://www.voautomotive.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 24, NULL, NULL, NULL, 'Vo family', 56, 'license_tenure_proxy', 24, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://www.voautomotive.com/", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('e7dca4c4-0d74-50f3-93ad-6abd1d90fe62', 'auto_repair', 'A Plus Auto Repair', 'A Plus Auto Repair Spring', '811111', NULL, 'Spring', 'Harris', 'TX', NULL, NULL, 'https://www.aplusautospring.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 20, NULL, NULL, NULL, 'family-owned', 52, NULL, 20, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://www.aplusautospring.com/", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('24e556fd-0663-520e-a89d-079e68b86d9b', 'auto_repair', 'A1 Committed Auto Care', 'A1 Committed Autocare', '811111', NULL, 'Arlington', 'Tarrant', 'TX', NULL, NULL, 'https://www.a1committedautocare.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 20, NULL, NULL, NULL, 'family-owned 21+ yrs', 52, NULL, 20, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://www.a1committedautocare.com/", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('750bda9b-2ec1-5a2e-8e65-deee7cca4de6', 'auto_repair', 'Adams Automotive', 'Adams Automotive Cypress', '811111', NULL, 'Cypress', 'Harris', 'TX', NULL, NULL, 'https://www.adamsautomotiveservices.com/locations/cypress', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 20, NULL, NULL, NULL, 'Adams family', 52, NULL, 20, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://www.adamsautomotiveservices.com/locations/cypress", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('07d3f1fe-4604-5f5c-b284-00f924dbfbf5', 'auto_repair', 'Advanced Auto Tech', 'Advanced Auto Tech Houston', '811111', NULL, 'Houston', 'Harris', 'TX', NULL, NULL, 'https://advancedautotechhouston.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 20, NULL, NULL, NULL, 'family-owned', 52, NULL, 20, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://advancedautotechhouston.com/", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('5636ee8d-789f-5411-9791-d56e7e2a6a9a', 'auto_repair', 'Advanced Tire & Auto Service', 'Advanced Tire & Auto', '811111', NULL, 'Arlington', 'Tarrant', 'TX', NULL, NULL, 'https://www.advancedtireandautoservice.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 20, NULL, NULL, NULL, 'family-owned', 52, 'license_tenure_proxy', 20, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://www.advancedtireandautoservice.com/", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('e8e1ec2f-fbbd-5a00-8d6e-14077a52d065', 'auto_repair', 'Anchias Fleet Care', 'Anchias Diesel Repair', '811111', NULL, 'Houston', 'Harris', 'TX', NULL, NULL, 'https://www.dieselrepairhoustontx.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 20, NULL, NULL, NULL, 'Anchias family', 52, NULL, 20, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://www.dieselrepairhoustontx.com/", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('8f65c744-5a33-5a09-9b8d-569ba0981f08', 'auto_repair', 'Autobahn Werke', 'Autobahn Werke', '811111', NULL, 'Humble', 'Harris', 'TX', NULL, NULL, 'https://autobahnwerke.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 20, NULL, NULL, NULL, 'family-owned (European specialist)', 52, NULL, 20, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://autobahnwerke.com/", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('2a865d98-1ed4-5e8b-a2f4-d915317b0245', 'auto_repair', 'Colony One Auto Center', 'Colony One Auto', '811111', NULL, 'Stafford', 'Fort Bend', 'TX', NULL, NULL, 'https://www.colonyoneauto.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 20, NULL, NULL, NULL, 'family-owned (Stafford/Missouri City/Sugar Land)', 52, NULL, 20, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://www.colonyoneauto.com/", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('1d569a39-8c01-55c6-9c8f-60c9f035c820', 'auto_repair', 'Dennis Road Automotive', 'Dennis Road Auto', '811111', NULL, 'Dallas', 'Dallas', 'TX', NULL, NULL, 'https://www.dennisroadautomotive.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 20, NULL, NULL, NULL, 'Dennis (family-owned ASE-certified)', 52, NULL, 20, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://www.dennisroadautomotive.com/index.php/affiliations/ase-certified", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('19f24428-8d46-5a77-8ef5-c2a1bb23e3aa', 'auto_repair', 'Excalibur Auto Repair', 'Excalibur Auto', '811111', NULL, 'Austin', 'Travis', 'TX', NULL, NULL, 'https://excaliburautorepair.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 20, NULL, NULL, NULL, 'family-owned', 52, NULL, 20, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://excaliburautorepair.com/", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('1c3e3286-ab81-55ba-903f-670a7cb9c7a4', 'auto_repair', 'Family Auto Center', 'Family Auto Center Houston', '811111', NULL, 'Houston', 'Harris', 'TX', '77015', NULL, 'https://www.familyautocenterhouston.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 20, NULL, NULL, NULL, 'family-owned (AAA-approved + NAPA Auto Care)', 52, NULL, 20, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://www.napaonline.com/en/autocare/?facilityId=324993", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('bba61dd0-8f7e-5c57-8335-a831339adcb7', 'auto_repair', 'Jason''s Tire & Automotive', 'Jason''s Tire & Automotive', '811111', NULL, 'Humble', 'Harris', 'TX', NULL, NULL, 'https://www.jasonstireandautomotive.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 20, NULL, NULL, NULL, 'Jason (family)', 52, NULL, 20, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://www.jasonstireandautomotive.com/", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('43fa8e49-4bac-54d6-ae7d-5d9338ef829e', 'auto_repair', 'Kennedy Auto Solutions', 'Kennedy Auto Solutions', '811111', NULL, 'Tomball', 'Harris', 'TX', NULL, NULL, 'https://www.kennedyautosolutions.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 20, NULL, NULL, NULL, 'Kennedy family', 52, NULL, 20, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://www.kennedyautosolutions.com/", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('dfe0eb79-bd9b-55d2-8710-58df6178600a', 'auto_repair', 'Mario''s Automotive', 'Mario''s Automotive Inc', '811111', NULL, 'Houston', 'Harris', 'TX', NULL, NULL, 'https://www.mariosautomotiveinc.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 20, NULL, NULL, NULL, 'Mario (family-owned)', 52, NULL, 20, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://www.mariosautomotiveinc.com/", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('a9be5e49-41dc-5af7-a730-f87d4cff247a', 'auto_repair', 'North Houston Beemer', 'North Houston Beemer', '811111', NULL, 'Spring', 'Harris', 'TX', NULL, NULL, 'https://www.nhbeemer.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 20, NULL, NULL, NULL, 'family-owned (BMW/Mercedes/Audi/MINI specialist)', 52, NULL, 20, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://www.nhbeemer.com/", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('b8673ea0-6134-5840-94e1-c9f292a12824', 'auto_repair', 'Northrich Automotive', 'Northrich Auto', '811111', NULL, 'Richardson', 'Dallas', 'TX', NULL, NULL, 'https://www.northrichauto.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 20, NULL, NULL, NULL, 'family-owned', 52, NULL, 20, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://www.northrichauto.com/", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('9e90c2ce-4b3d-5752-9a2f-b97dd82fc476', 'auto_repair', 'Overseas Haus', 'Overseas Haus', '811111', NULL, 'Dallas', 'Dallas', 'TX', NULL, NULL, 'https://www.overseashaus.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 20, NULL, NULL, NULL, 'European import specialist family-owned', 52, NULL, 20, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://www.overseashaus.com/", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('4f9ceca7-3266-51ab-8901-c19c7ff800ee', 'auto_repair', 'Payne''s Automotive', 'Payne''s Automotive', '811111', NULL, 'Houston', 'Harris', 'TX', NULL, NULL, 'https://www.paynesautomotive.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 20, NULL, NULL, NULL, 'Payne family', 52, NULL, 20, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://www.paynesautomotive.com/", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('86cf1f04-20ee-5dd8-89c2-690c67b43115', 'auto_repair', 'Pristal''s Automotive', 'Pristal''s Auto Tomball', '811111', NULL, 'Tomball', 'Harris', 'TX', NULL, NULL, 'https://pristalsautotomball.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 20, NULL, NULL, NULL, 'Pristal family', 52, NULL, 20, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://pristalsautotomball.com/", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('546517c8-7d3d-513f-b323-df8dce21a2c9', 'auto_repair', 'QualTech Automotive', 'QualTech Auto Austin', '811111', NULL, 'Austin', 'Travis', 'TX', NULL, NULL, 'https://www.qualtechauto.com/locations/austin-tx', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 20, NULL, NULL, NULL, 'family-owned', 52, NULL, 20, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://www.qualtechauto.com/locations/austin-tx", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('4767c077-7dea-55e2-87d3-5108723f2d51', 'auto_repair', 'Southwest Auto', 'Southwest Auto Garland', '811111', NULL, 'Garland', 'Dallas', 'TX', NULL, NULL, 'https://www.southwestauto.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 20, NULL, NULL, NULL, 'European/Import specialist family-owned', 52, NULL, 20, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://www.southwestauto.com/auto-repair-garland-tx", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('8aeffa18-91d4-5494-af94-360e7d896161', 'auto_repair', 'Stafford Auto Tech', 'Stafford Auto Tech', '811111', NULL, 'Stafford', 'Fort Bend', 'TX', NULL, NULL, 'https://staffordautotech.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 20, NULL, NULL, NULL, 'family-owned', 52, NULL, 20, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://staffordautotech.com/", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('71a6677c-422c-50f7-815b-39fbfcb9e88e', 'auto_repair', 'Sugar Creek Auto', 'Sugar Creek Automotive', '811111', NULL, 'Stafford', 'Fort Bend', 'TX', NULL, NULL, 'https://www.sugarcreekauto.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 20, NULL, NULL, NULL, 'family-owned', 52, NULL, 20, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://www.sugarcreekauto.com/", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('6ba03b67-77ff-523a-8192-47a57856c0f3', 'auto_repair', 'Taylor Auto Repair', 'Taylor Auto Repair Dallas', '811111', NULL, 'Dallas', 'Dallas', 'TX', NULL, NULL, 'https://taylorautorepairdallas.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 20, NULL, NULL, NULL, 'Taylor family', 52, NULL, 20, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://taylorautorepairdallas.com/", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('4e7dd95d-8f2d-539b-8450-6377d0d1d13a', 'auto_repair', 'The Auto Doc', 'The Auto Doc', '811111', NULL, 'Houston', 'Harris', 'TX', '77019', NULL, NULL, NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 20, NULL, NULL, NULL, 'David and Denise Skorka (family-owned)', 52, NULL, 20, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://www.autoyas.com/US/Houston/254995953338/The-Auto-Doc", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('a7cb24fb-72b4-53d9-b3b1-d75880c671a8', 'auto_repair', '2nd Opinion Auto Center', '2nd Opinion Auto', '811111', NULL, 'Fort Worth', 'Tarrant', 'TX', NULL, NULL, 'https://www.2ndopinionautocenter.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 20, NULL, NULL, NULL, 'family-owned', 52, NULL, 20, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://www.2ndopinionautocenter.com/", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('cfc6a6e2-d86b-50d1-bac7-84aa79aa6af2', 'auto_repair', 'AM Lube & Auto Care', 'AM Lube & Auto Care', '811111', NULL, 'Sugar Land', 'Fort Bend', 'TX', NULL, NULL, NULL, NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 20, NULL, NULL, NULL, 'family-owned', 52, NULL, 20, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://www.yelp.com/search?find_desc=Auto+Services&find_loc=Sugar+Land,+TX", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('13ffe6a1-f1d7-50a8-915a-38ebc3617fcf', 'auto_repair', 'ATL Automotive Group', 'ATL Automotive SA', '811111', NULL, 'San Antonio', 'Bexar', 'TX', NULL, NULL, 'https://atlag.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 20, NULL, NULL, NULL, 'family-owned (Family Over Franchise positioning)', 52, NULL, 20, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://atlag.com/", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('c175729e-1af7-52a5-873a-4dc132fe554c', 'auto_repair', 'Chad Miller Auto Care', 'Chad Miller Auto', '811111', NULL, 'San Antonio', 'Bexar', 'TX', NULL, NULL, 'https://cmautocare.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 20, NULL, NULL, NULL, 'Chad Miller (family-owned)', 52, NULL, 20, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://cmautocare.com/", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('c27a974e-bae3-540f-8920-43e10dba55b8', 'auto_repair', 'Cliff''s Auto Repair', 'Cliff''s Auto', '811111', NULL, 'Houston', 'Harris', 'TX', NULL, NULL, 'https://cliffsautorepair.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 19, NULL, NULL, NULL, 'Cliff (family-owned 15+ yrs)', 51, 'license_tenure_proxy', 19, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://cliffsautorepair.com/", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('9679f546-5dbf-5049-a75d-81669978aa56', 'auto_repair', 'Family Tire and Automotive Service', 'Family Tire & Auto Grapevine', '811111', NULL, 'Grapevine', 'Tarrant', 'TX', NULL, NULL, 'https://www.ftagrapevine.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 20, NULL, NULL, NULL, 'family-owned', 52, NULL, 20, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://www.ftagrapevine.com/", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('ef198887-53ae-543e-ad0c-c3784f261562', 'auto_repair', 'Fifth Gear Automotive', 'Fifth Gear Automotive', '811111', NULL, 'Lewisville', 'Denton', 'TX', NULL, NULL, 'https://fifthgear.biz/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 22, NULL, NULL, NULL, 'family-owned (multi-location)', 54, 'license_tenure_proxy', 22, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://fifthgear.biz/about-us/", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('b888b5ab-ebb7-5e1f-b60e-091820966a66', 'auto_repair', 'Little Automotive', 'Little Auto League City', '811111', NULL, 'League City', 'Galveston', 'TX', NULL, NULL, NULL, NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 20, NULL, NULL, NULL, 'Little family', 52, NULL, 20, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://www.2coolfishing.com/threads/mechanics-in-friendswood-league-city-pearland-area.422802/", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('b51a9e9c-6264-559e-8285-4c7a772b1ec0', 'auto_repair', 'Lonestar Elite Automotive', 'Lonestar Elite Auto', '811111', NULL, 'Keller', 'Tarrant', 'TX', NULL, NULL, 'https://lonestareliteauto.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 20, NULL, NULL, NULL, 'family-owned', 52, NULL, 20, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://lonestareliteauto.com/", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('4edb1f51-58c2-5d37-b344-71c0affa5f1e', 'auto_repair', 'Mustang Auto', 'Mustang Auto Friendswood', '811111', NULL, 'Friendswood', 'Galveston', 'TX', NULL, NULL, NULL, NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 20, NULL, NULL, NULL, 'Scott (family-owned ''for many years'')', 52, NULL, 20, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://www.2coolfishing.com/threads/mechanics-in-friendswood-league-city-pearland-area.422802/", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('d990f5ca-4c6c-539d-9251-40bb898d54e7', 'auto_repair', 'O''Brien''s Automotive', 'O''Brien''s Auto SA', '811111', NULL, 'San Antonio', 'Bexar', 'TX', NULL, NULL, 'https://obriensautomotive.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 20, NULL, NULL, NULL, 'O''Brien family', 52, NULL, 20, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://obriensautomotive.com/", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('45bbaceb-6971-54e2-955c-925cf87cf65f', 'auto_repair', 'Reserve Customs & Service', 'Reserve Customs', '811111', NULL, 'Lewisville', 'Denton', 'TX', NULL, NULL, 'https://www.reservecustoms.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 20, NULL, NULL, NULL, 'independent family-owned', 52, NULL, 20, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://www.reservecustoms.com/", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('5a1132e7-e5b6-5792-b09e-db1bed691696', 'auto_repair', 'Round Rock Auto Center', 'Round Rock Auto', '811111', NULL, 'Round Rock', 'Williamson', 'TX', NULL, NULL, 'https://www.roundrockautocenter.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 20, NULL, NULL, NULL, 'locally-owned family-operated independent', 52, NULL, 20, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://www.roundrockautocenter.com/", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('0ff300fb-184b-5809-a935-8901efbf3599', 'auto_repair', 'Silva Family Automotive', 'Silva Family Auto', '811111', NULL, 'San Antonio', 'Bexar', 'TX', NULL, NULL, 'https://www.silvafamilyautomotive.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 20, NULL, NULL, NULL, 'Silva family (veteran-owned)', 52, NULL, 20, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://www.silvafamilyautomotive.com/", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('23445531-bc5f-5b71-b401-38031f50b74c', 'auto_repair', 'Texan Auto Repair & Collision', 'Texan Auto Repair', '811111', NULL, 'Sugar Land', 'Fort Bend', 'TX', NULL, NULL, NULL, NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 22, NULL, NULL, NULL, 'family-owned', 54, 'license_tenure_proxy', 22, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://www.yelp.com/search?find_desc=Auto+Services&find_loc=Sugar+Land,+TX", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('9f667fc9-7a03-5f79-8cde-e66a80777197', 'auto_repair', 'Texas C.A.R.S', 'Texas C.A.R.S Addison', '811111', NULL, 'Addison', 'Dallas', 'TX', NULL, NULL, 'https://www.mytexascars.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 21, NULL, NULL, NULL, 'family-owned NAPA AutoCare', 53, 'license_tenure_proxy', 21, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://www.mytexascars.com/About", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('1d74a0aa-64eb-596a-bda6-c74e527e8940', 'auto_repair', 'Reliable Auto Repair', 'Reliable Auto Repair Houston', '811111', NULL, 'Houston', 'Harris', 'TX', NULL, NULL, 'https://reliableautorepairs.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 18, NULL, NULL, NULL, 'family-owned', 50, 'license_tenure_proxy', 18, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://reliableautorepairs.com/", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('c08365bb-dd2c-521e-97c6-9ff875e02214', 'auto_repair', 'Rusty''s Garage', 'Rusty''s Garage Woodlands', '811111', NULL, 'The Woodlands', 'Montgomery', 'TX', NULL, NULL, NULL, NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 17, NULL, NULL, NULL, 'Rusty (family-owned, AAA-approved)', 49, 'license_tenure_proxy', 17, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://www.aaa.com/autorepair/locations/tomball-tx", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('4657cf6b-37d7-57c5-9374-4c1a961dcbb2', 'auto_repair', 'TMJ Bimmers', 'TMJ Bimmers Houston', '811111', NULL, 'Houston', 'Harris', 'TX', NULL, NULL, 'https://www.tmjbimmers.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 16, NULL, NULL, NULL, 'TMJ family (BMW/MINI/Mercedes/Porsche specialist - 15+ yrs)', 48, 'license_tenure_proxy', 16, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://www.tmjbimmers.com/", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('78413aed-73d8-5d33-b820-fed3129b2cbc', 'auto_repair', 'Sims Automotive Repair', 'Sims Auto Copperas Cove', '811111', NULL, 'Copperas Cove', 'Coryell', 'TX', NULL, NULL, 'https://www.simsautomotiverepair.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 20, NULL, NULL, NULL, 'Sims (family-owned, only ASE Blue Seal within 15 mi)', 52, NULL, 20, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://www.simsautomotiverepair.com/the-ase-blue-seal-difference-why-sims-automotive-stands-out-from-other-local-repair-shops", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('3176e9f7-c0b0-5917-9212-a0c589d14f18', 'auto_repair', 'A&B Car Experts', 'A&B Auto Round Rock', '811111', NULL, 'Round Rock', 'Williamson', 'TX', NULL, NULL, 'https://www.abcarexperts.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'unknown', NULL, NULL, 0, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://www.abcarexperts.com/", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('84871033-9372-59fe-8288-3c537b0c947e', 'auto_repair', 'Auto Clinique', 'Auto Clinique Certified Auto Care', '811111', NULL, 'Dallas', 'Dallas', 'TX', NULL, NULL, 'https://theautoclinique.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'unknown', NULL, NULL, 0, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://theautoclinique.com/", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('04f1fad7-1cee-52f8-80f8-f84cae994abc', 'auto_repair', 'Auto Revival', 'Auto Revival Keller', '811111', NULL, 'Keller', 'Tarrant', 'TX', NULL, NULL, 'https://www.auto-revival.com/keller', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'unknown', NULL, NULL, 0, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://www.auto-revival.com/keller", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('d973013a-c18a-5276-a348-578fe0082a4b', 'auto_repair', 'Discount Car Clinic', 'Discount Car Clinic Sugar Land', '811111', NULL, 'Sugar Land', 'Fort Bend', 'TX', NULL, NULL, NULL, NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'AAA-approved independent', NULL, NULL, 0, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://www.aaa.com/autorepair/locations/sugar-land-tx", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('4ae4ac43-b7c7-50d1-a052-5d5c1184c7bb', 'auto_repair', 'European Cars Limited', 'European Cars Limited Houston', '811111', NULL, 'Houston', 'Harris', 'TX', NULL, NULL, NULL, NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'unknown European specialist', NULL, NULL, 0, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://location.com/categories/automotive-and-vehicles/tx/houston/en/european-cars-limited-2302893953", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('8bd209c2-b857-5c7c-935c-14706dcae870', 'auto_repair', 'Genuine Automotive & Diesel', 'Genuine Auto & Diesel', '811111', NULL, 'Austin', 'Travis', 'TX', NULL, NULL, 'https://genuineautomotive.net/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'unknown', NULL, NULL, 0, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://genuineautomotive.net/", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('5f3b195b-09c7-534f-8064-16cced48cfdb', 'auto_repair', 'Guaranteed Tire & Auto Service', 'Guaranteed Tire & Auto', '811111', NULL, 'Arlington', 'Tarrant', 'TX', NULL, NULL, 'https://www.guaranteedtireauto.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'unknown', NULL, NULL, 0, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://www.guaranteedtireauto.com/", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('e92cc82c-e912-5f8f-800e-f7122bdef836', 'auto_repair', 'Heights Mobile Carcare', 'Heights Expert Automotive', '811111', NULL, 'Houston', 'Harris', 'TX', NULL, NULL, 'https://www.heightsmobilcarcare.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'unknown', NULL, NULL, 0, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://www.heightsmobilcarcare.com/", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('6ff8ef85-c873-5ac3-a276-f1e7bb4472b2', 'auto_repair', 'Horeb Auto Repair', 'Horeb Auto Repair', '811111', NULL, 'Houston', 'Harris', 'TX', NULL, NULL, 'https://horebautorepair.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'unknown', NULL, NULL, 0, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://horebautorepair.com/", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('e0e899e4-a5c6-5fde-93bd-241031932768', 'auto_repair', 'Keller Alliance Auto Repair', 'Keller Alliance Auto', '811111', NULL, 'Keller', 'Tarrant', 'TX', NULL, NULL, 'https://www.kellerallianceautorepairs.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'unknown', NULL, NULL, 0, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://www.kellerallianceautorepairs.com/", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('cb7d3b1b-8f1e-5f32-81d1-da456a4d2680', 'auto_repair', 'Montrose Tire & Wheel', 'Montrose Tire & Auto', '811111', NULL, 'Houston', 'Harris', 'TX', NULL, NULL, 'https://www.montrosetw.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'AAA-approved', NULL, NULL, 0, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://www.aaa.com/autorepair/shop/montrose-tire-auto-center-77554", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('e156bbac-727b-58ef-b152-46737bf891b6', 'auto_repair', 'NLine Automotive', 'NLine Auto Sugar Land', '811111', NULL, 'Sugar Land', 'Fort Bend', 'TX', NULL, NULL, NULL, NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'AAA-approved independent', NULL, NULL, 0, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://www.aaa.com/autorepair/locations/sugar-land-tx", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('26c089b9-7896-5fe9-9482-5916392de7b9', 'auto_repair', 'Rapid Repair Auto Center', 'Rapid Repair Sugar Land', '811111', NULL, 'Sugar Land', 'Fort Bend', 'TX', NULL, NULL, NULL, NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'AAA-approved independent', NULL, NULL, 0, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://www.aaa.com/autorepair/locations/sugar-land-tx", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('f6cd9bce-2cd8-5d6f-811b-9aab7d71b8f4', 'auto_repair', 'River Oaks Automotive Center', 'River Oaks Automotive', '811111', NULL, 'Houston', 'Harris', 'TX', NULL, NULL, 'https://www.riveroaksautomotivecenter.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'unknown (European/import specialist)', NULL, NULL, 0, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://www.riveroaksautomotivecenter.com/", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('2748be4f-93de-500e-9db3-d8fa85a4ef04', 'auto_repair', 'Sav-Mor Automotive', 'Sav-Mor Automotive Richardson', '811111', NULL, 'Richardson', 'Dallas', 'TX', NULL, NULL, 'https://sav-morautomotive.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'unknown', NULL, NULL, 0, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://sav-morautomotive.com/auto-repair-in-richardson-texas/", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('ac9ce896-6dc0-54ba-8ba7-f9498fcd36bc', 'auto_repair', 'Simba Automotive', 'Simba Auto', '811111', NULL, 'Sugar Land', 'Fort Bend', 'TX', NULL, NULL, NULL, NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'AAA-approved independent', NULL, NULL, 0, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://www.aaa.com/autorepair/locations/sugar-land-tx", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('0e906c5c-18d8-5bb2-a520-bab9111a8cee', 'auto_repair', 'The Star Auto Service', 'The Star Auto Service Richardson', '811111', NULL, 'Richardson', 'Dallas', 'TX', NULL, NULL, 'https://thestarautoservice.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'unknown', NULL, NULL, 0, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://thestarautoservice.com/", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('8e1258d7-7bc9-5f56-a2a0-4bdea22dd6d4', 'auto_repair', 'Westside Automotive', 'Westside Automotive Houston', '811111', NULL, 'Houston', 'Harris', 'TX', NULL, NULL, NULL, NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'AAA-approved independent', NULL, NULL, 0, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://www.aaa.com/autorepair/locations/sugar-land-tx", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('be5b7220-bba6-5164-bf9d-201c4c1ee48e', 'auto_repair', 'West Pearland Tire & Auto', 'West Pearland Tire & Auto', '811111', NULL, 'Pearland', 'Brazoria', 'TX', NULL, NULL, NULL, NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'AAA-approved independent', NULL, NULL, 0, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://www.aaa.com/autorepair/locations/sugar-land-tx", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('9bfc5171-685d-5b79-bbc3-e2beb940ebd2', 'auto_repair', 'Anchias Diesel Repair', 'Anchias Fleet Care', '811111', NULL, 'Pasadena', 'Harris', 'TX', NULL, NULL, 'https://www.dieselrepairhoustontx.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 20, NULL, NULL, NULL, 'Anchias family (diesel/fleet specialist)', NULL, NULL, NULL, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://www.dieselrepairhoustontx.com/", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('07205d6c-3a1d-5b4b-9263-96c6c5912078', 'auto_repair', 'Austin''s Automotive Specialists', 'Austin''s Automotive Specialists', '811111', NULL, 'Austin', 'Travis', 'TX', NULL, NULL, 'https://www.greatwater360autocare.com/shops/austins-automotive-specialists-north-austin-1607', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Greatwater 360 affiliated - VERIFY independence', NULL, NULL, NULL, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://www.greatwater360autocare.com/shops/austins-automotive-specialists-north-austin-1607", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('e626318b-073e-5daf-a8e4-0caf42bc2ffc', 'auto_repair', 'Rising Sun Automotive', 'Rising Sun Auto Austin', '811111', '1001 S. Lamar Blvd, Austin, TX 78704', 'Austin', 'Travis', 'TX', NULL, NULL, 'https://risingsunautomotive.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, 'Locally-owned (no names visible)', NULL, NULL, NULL, NULL, 51, NULL, NULL, NULL, 'Locally-owned (no names visible)', NULL, NULL, NULL, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://risingsunautomotive.com/", "fetched_at": "2026-05-15"}, {"source": "live_website_fetch", "url": "https://risingsunautomotive.com/", "fetched_at": "2026-05-15T23:55:00Z"}]'::jsonb, '{"live_fetch_summary": "Live fetch 2026-05-15: ''Since 1975'' = 51-yr S Austin business, ASE + AAA affiliate + DPS emissions, online booking + SMS + digital invoicing. Three named techs (Jeremy, Heath, John) \u2014 no family successor on site."}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

INSERT INTO offmarket.businesses (id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name, entity_sos_file_number, entity_formation_date, entity_status, registered_agent, years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source, owner_name, owner_age_estimate, owner_age_source, owner_tenure_years, owner_homestead_address, owner_property_deed_date, is_distressed, distress_reasons, data_sources, raw_enrichment, notes)
VALUES ('3e79a181-e4bf-5bae-8bb5-323b8cc84091', 'auto_repair', 'Texans Auto Repair Blackhawk', 'Texans Auto Repair', '811111', NULL, 'Houston', 'Harris', 'TX', NULL, NULL, 'https://texansrepair.com/', NULL, 'NAICS 811111 - General Automotive Repair', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 15, NULL, NULL, NULL, 'family-owned (Webster origin)', NULL, NULL, NULL, NULL, NULL, false, '[]'::jsonb, '[{"source": "spine_curated_websearch", "url": "https://texansrepair.com/", "fetched_at": "2026-05-15"}]'::jsonb, '{}'::jsonb, NULL)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  website = EXCLUDED.website,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  owner_tenure_years = EXCLUDED.owner_tenure_years,
  years_in_business = EXCLUDED.years_in_business,
  data_sources = EXCLUDED.data_sources,
  raw_enrichment = EXCLUDED.raw_enrichment,
  updated_at = now();

COMMIT;
