BEGIN;
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '4b09aa53-c8f2-5e31-8919-fdc54939f4d4', 'commercial_signage', 'AAA ELECTRICAL SIGNS', NULL,
  '339950', '2407 E BUSINESS 83', 'DONNA', 'Hidalgo',
  'TX', '78537', '9566827831', 'https://3asigns.com/',
  '18035', 'Electrical Sign Contractor', 'Active', 'AAA ELECTRICAL SIGNS',
  57,
  'Paul W. Sullivan (CEO + Founder)', 78, 'founder_tenure_inference',
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}, {"source": "company_website", "url": "https://3asigns.com/", "fetched_at": "2026-05-16T05:00:00Z", "fields": ["founded_year", "owner_name", "service_mix", "copyright_year", "successor_signals"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 07/15/2026; Founded 1970; Successor live-fetch verified; A-tier deep-dive passed'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  'bb7828c9-2372-59ba-804e-d84c68822734', 'commercial_signage', 'GLOBALSIGNS INC', NULL,
  '339950', '5105 E CALIFORNIA PK', 'FT WORTH', 'Tarrant',
  'TX', '76119', '8178341123', 'https://globalsignsinc.com/',
  '18048', 'Electrical Sign Contractor', 'Active', 'GLOBALSIGNS INC',
  39,
  'Rick Robertson (Founder)', 68, 'founder_tenure_inference',
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}, {"source": "company_website", "url": "https://globalsignsinc.com/", "fetched_at": "2026-05-16T05:00:00Z", "fields": ["founded_year", "owner_name", "service_mix", "copyright_year", "successor_signals"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 08/03/2025; Founded 1987; Successor live-fetch verified; A-tier deep-dive passed'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '88b1aa2f-35a1-5001-be2c-8247f0c01896', 'commercial_signage', 'NEON ELECTRIC CORPORATION', NULL,
  '339950', '1122 LAUDER ROAD', 'HOUSTON', 'Harris',
  'TX', '77039-2902', '2819871144', 'https://necsigns.net/',
  '18060', 'Electrical Sign Contractor', 'Active', 'NEON ELECTRIC CORPORATION',
  80,
  'Family-owned (multi-generation since 1946)', NULL, 'license_tenure_proxy + founder_era_inference',
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}, {"source": "company_website", "url": "https://necsigns.net/", "fetched_at": "2026-05-16T05:00:00Z", "fields": ["founded_year", "owner_name", "service_mix", "copyright_year", "successor_signals"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 07/18/2026; Founded 1946'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '81b015fe-a824-5463-993e-2b5a42f37382', 'commercial_signage', 'ATLAS SIGN SERVICES', NULL,
  '339950', '6411 AIRLINE DRIVE', 'HOUSTON', 'Harris',
  'TX', '77076', '7136991121', 'https://www.atlassigns.com/',
  '18004', 'Electrical Sign Contractor', 'Active', 'ATLAS SIGN SERVICES',
  47,
  'Stan Titlow + Linda Titlow (founders); Stanford Titlow (son, Master Sign Electrician)', NULL, 'license_tenure_proxy + founder_tenure_inference',
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}, {"source": "company_website", "url": "https://www.atlassigns.com/", "fetched_at": "2026-05-16T05:00:00Z", "fields": ["founded_year", "owner_name", "service_mix", "copyright_year", "successor_signals"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 07/24/2026; Founded 1979; Successor live-fetch verified'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '18f03f1b-b372-58ed-a6d5-193b73b26095', 'commercial_signage', 'SIGNS MANUFACTURING AND MAINTENANCE CORP', NULL,
  '339950', '4610 MINT WAY', 'DALLAS', 'Dallas',
  'TX', '75236-2016', '2143392227', 'https://signsmanufacturing.com/',
  '18015', 'Electrical Sign Contractor', 'Active', 'SIGNS MANUFACTURING AND MAINTENANCE CORP',
  47,
  'Watson Family (multi-generation, multi-Master)', NULL, 'founder_tenure_inference',
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}, {"source": "company_website", "url": "https://signsmanufacturing.com/", "fetched_at": "2026-05-16T05:00:00Z", "fields": ["founded_year", "owner_name", "service_mix", "copyright_year", "successor_signals"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 05/30/2027; Founded 1979; Successor live-fetch verified'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '272e6035-275e-5d7a-b963-187bbada9dff', 'commercial_signage', 'HANCOCK SIGN COMPANY', NULL,
  '339950', '810 W PIONEER DR', 'IRVING', 'Dallas',
  'TX', '75061', '8176406441', 'http://hancocksign.com/',
  '18032', 'Electrical Sign Contractor', 'Active', 'HANCOCK SIGN COMPANY',
  23,
  NULL, NULL, 'license_tenure_proxy',
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}, {"source": "company_website", "url": "http://hancocksign.com/", "fetched_at": "2026-05-16T05:00:00Z", "fields": ["founded_year", "owner_name", "service_mix", "copyright_year", "successor_signals"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 05/29/2027'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '846f313d-bd1e-532d-bc12-64d1e330e2ff', 'commercial_signage', 'WILLOW CREEK SIGNS INC', NULL,
  '339950', '2633 BLUE MOUND ROAD WEST', 'HASLET', 'Tarrant',
  'TX', '76052', '8178470571', 'https://www.willowcreeksigns.com/',
  '18059', 'Electrical Sign Contractor', 'Active', 'WILLOW CREEK SIGNS INC',
  31,
  'Parsons Family (K. Parsons + Josh Parsons)', NULL, 'license_tenure_proxy',
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}, {"source": "company_website", "url": "https://www.willowcreeksigns.com/", "fetched_at": "2026-05-16T05:00:00Z", "fields": ["founded_year", "owner_name", "service_mix", "copyright_year", "successor_signals"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 09/07/2026; Founded 1995'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  'eeb2b17f-3795-5b92-a21b-0060b8f67e12', 'commercial_signage', 'AETNA SIGN GROUP', NULL,
  '339950', '2438 FREEDOM DR', 'SAN ANTONIO', 'Bexar',
  'TX', '78217-4423', '2108262800', 'https://www.aetnasign.com/',
  '18370', 'Electrical Sign Contractor', 'Active', 'AETNA SIGN GROUP',
  97,
  'Aetna Family (4th generation)', NULL, 'founder_tenure_inference',
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}, {"source": "company_website", "url": "https://www.aetnasign.com/", "fetched_at": "2026-05-16T05:00:00Z", "fields": ["founded_year", "owner_name", "service_mix", "copyright_year", "successor_signals"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 10/11/2025; Founded 1929; Successor live-fetch verified'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '1991864d-d6ea-5e1f-825f-2f68442efbb7', 'commercial_signage', 'BARNETT SIGNS, INC', NULL,
  '339950', '4250 ACTION DRIVE', 'MESQUITE', 'Dallas',
  'TX', '75150', '9726818800', 'https://barnettsigns.com/',
  '18034', 'Electrical Sign Contractor', 'Active', 'BARNETT SIGNS, INC',
  55,
  'Barnett Family (4 generations: Nolan + Barry + 3rd + 4th gen)', NULL, 'founder_tenure_inference',
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}, {"source": "company_website", "url": "https://barnettsigns.com/", "fetched_at": "2026-05-16T05:00:00Z", "fields": ["founded_year", "owner_name", "service_mix", "copyright_year", "successor_signals"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 08/06/2026; Founded 1971; Successor live-fetch verified'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '4804b432-4c68-5b37-95b7-b83503b1fec0', 'commercial_signage', 'CASTEEL & ASSOCIATES INC', NULL,
  '339950', '11106 MORRISON', 'DALLAS', 'Dallas',
  'TX', '75229-5607', '2143527446', 'https://www.casteelsign.com/',
  '18003', 'Electrical Sign Contractor', 'Active', 'CASTEEL & ASSOCIATES INC',
  39,
  'Warren T. Casteel', NULL, 'license_tenure_proxy',
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}, {"source": "company_website", "url": "https://www.casteelsign.com/", "fetched_at": "2026-05-16T05:00:00Z", "fields": ["founded_year", "owner_name", "service_mix", "copyright_year", "successor_signals"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 09/12/2026; Founded 1987'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '66af723d-9271-5703-a1ef-0a70ce223b58', 'commercial_signage', 'HUNTER GRAPHICS', NULL,
  '339950', '7733 HARWELL ST', 'FORT WORTH', 'Tarrant',
  'TX', '76108-1807', '8172464848', 'https://www.huntercommercial.net/',
  '18057', 'Electrical Sign Contractor', 'Active', 'HUNTER GRAPHICS',
  26,
  'Mike Hunter (family-owned)', NULL, 'license_tenure_proxy',
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}, {"source": "company_website", "url": "https://www.huntercommercial.net/", "fetched_at": "2026-05-16T05:00:00Z", "fields": ["founded_year", "owner_name", "service_mix", "copyright_year", "successor_signals"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 08/15/2026; Founded 2000'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '3625e303-6999-531b-a096-2b8875b8d7c7', 'commercial_signage', 'SIGN TECHNOLOGIES INC DBA REPUBLIC SIGN', NULL,
  '339950', '8107 INTERCHANGE PKWY STE 101', 'SAN ANTONIO', 'Bexar',
  'TX', '78218', '2103085900', 'https://www.republicsign.com/',
  '18006', 'Electrical Sign Contractor', 'Active', 'SIGN TECHNOLOGIES INC DBA REPUBLIC SIGN',
  34,
  'Family-owned (Brent + unnamed)', NULL, 'license_tenure_proxy',
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}, {"source": "company_website", "url": "https://www.republicsign.com/", "fetched_at": "2026-05-16T05:00:00Z", "fields": ["founded_year", "owner_name", "service_mix", "copyright_year", "successor_signals"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 05/17/2027; Founded 1992'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  'f82400dd-9b04-545f-bc32-61d23499c388', 'commercial_signage', 'ACCENT GRAPHICS INC', NULL,
  '339950', '523 E ROCK ISLAND RD', 'GRAND PRAIRIE', 'Dallas',
  'TX', '75050', '9723990333', NULL,
  '18050', 'Electrical Sign Contractor', 'Active', 'ACCENT GRAPHICS INC',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 08/18/2026'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '8cbd44d8-e3ed-5d0c-9cdd-f8cd2e211653', 'commercial_signage', 'APACHE SIGN AND SERVICE INC', NULL,
  '339950', '1902 KARBACH ST BLDG 1', 'HOUSTON', 'Harris',
  'TX', '77092-8430', '7134623220', NULL,
  '18066', 'Electrical Sign Contractor', 'Active', 'APACHE SIGN AND SERVICE INC',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 03/26/2027'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '3e45be6f-f9de-5bef-b4ce-49e80c150d57', 'commercial_signage', 'CENTURY SIGN BUILDERS', NULL,
  '339950', '5923 DORSEY DRIVE', 'MAGNOLIA', 'Montgomery',
  'TX', '77354-2322', '2813563561', NULL,
  '18044', 'Electrical Sign Contractor', 'Active', 'CENTURY SIGN BUILDERS',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 06/23/2027'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '166fa7a8-ec55-58d2-80d9-b419ceadda70', 'commercial_signage', 'D & S SIGN & SUPPLY, INC', NULL,
  '339950', '790 CHAMBERLIN DR', 'BEAUMONT', 'Jefferson',
  'TX', '77707', '4098421546', NULL,
  '18074', 'Electrical Sign Contractor', 'Active', 'D & S SIGN & SUPPLY, INC',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 12/12/2025'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '91790d52-5a91-5c32-9669-4f3cab980747', 'commercial_signage', 'HOMEPORT SIGN SERVICE & LIGHTING MAINTEN', NULL,
  '339950', '1702 SARATOGA', 'CORPUS CHRISTI', 'Nueces',
  'TX', '78417', '3618518735', NULL,
  '18012', 'Electrical Sign Contractor', 'Active', 'HOMEPORT SIGN SERVICE & LIGHTING MAINTEN',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 10/09/2026'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  'db3a6aea-0256-5f3d-9fbb-faf6809defa5', 'commercial_signage', 'INDUSTRIAL NEON SIGN', NULL,
  '339950', '6223 ST AUGUSTINE ST', 'HOUSTON', 'Harris',
  'TX', '77021', '7137486600', NULL,
  '18052', 'Electrical Sign Contractor', 'Active', 'INDUSTRIAL NEON SIGN',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 02/19/2027'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  'c7fc1313-f4a9-5052-9abd-2b1432407d9b', 'commercial_signage', 'LEWIS SIGN BUILDERS, INC', NULL,
  '339950', '16910 S IH35', 'BUDA', 'Hays',
  'TX', '78610', '5128457200', NULL,
  '18067', 'Electrical Sign Contractor', 'Active', 'LEWIS SIGN BUILDERS, INC',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 05/31/2026'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  'faedb599-f644-5818-aafa-a3afe3f0257c', 'commercial_signage', 'SCANLIN SIGN SERVICE INC', NULL,
  '339950', '13123 MULA CT', 'STAFFORD', 'Fort Bend',
  'TX', '77477', '2815619924', NULL,
  '18086', 'Electrical Sign Contractor', 'Active', 'SCANLIN SIGN SERVICE INC',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 12/30/2026'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '2c349ea3-76d6-5afb-8dfb-c3477098e63f', 'commercial_signage', 'SON & DAUGHTERS INC', NULL,
  '339950', '313 HANMORE INDUSTRIAL PKWY', 'HARLINGEN', 'Cameron',
  'TX', '78550', '9564232689', NULL,
  '18053', 'Electrical Sign Contractor', 'Active', 'SON & DAUGHTERS INC',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 10/15/2025'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '0c7c2e91-4c92-53ff-b228-687c5c09be02', 'commercial_signage', 'SOUTHWEST SIGN GROUP, INC', NULL,
  '339950', '7208 S W W WHITE RD', 'SAN ANTONIO', 'Bexar',
  'TX', '78222-5204', '2107579104', NULL,
  '18027', 'Electrical Sign Contractor', 'Active', 'SOUTHWEST SIGN GROUP, INC',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 06/12/2027'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '45016f62-e870-5448-acc0-61d357051a5e', 'commercial_signage', 'TEXAS NEON & LED SIGN COMPANY, LLC', NULL,
  '339950', '10004 WURZBACH #291', 'SAN ANTONIO', 'Bexar',
  'TX', '78230', '2105593011', NULL,
  '18021', 'Electrical Sign Contractor', 'Active', 'TEXAS NEON & LED SIGN COMPANY, LLC',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 05/21/2026'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '9566159b-33e4-5659-8504-ef278557fd00', 'commercial_signage', 'THE SIGN FACTORY, INC', NULL,
  '339950', '5101 ASHLEY COURT', 'HOUSTON', 'Harris',
  'TX', '77041', '7138494575', NULL,
  '18049', 'Electrical Sign Contractor', 'Active', 'THE SIGN FACTORY, INC',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 08/18/2026'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '1030b03c-23b6-582e-96e4-f01a1a1ca7ba', 'commercial_signage', 'VISUAL FX', NULL,
  '339950', '8564 KATY FREEWAY STE 136', 'HOUSTON', 'Harris',
  'TX', '77024-1831', '2818026200', NULL,
  '18064', 'Electrical Sign Contractor', 'Active', 'VISUAL FX',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 11/21/2026'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '4cc4e982-46fd-58d2-b135-012454813890', 'commercial_signage', 'A-1 SIGNS', NULL,
  '339950', '20286 FM 2252', 'SAN ANTONIO', 'Comal',
  'TX', '78266', '8306096246', NULL,
  '18100', 'Electrical Sign Contractor', 'Active', 'A-1 SIGNS',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 01/21/2027'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '5ab38e78-25db-516e-969c-85cbec70eae5', 'commercial_signage', 'ADVANTAGE SIGNS INC', NULL,
  '339950', '3100 HANDLEY EDERVILLE ROAD SUITE B', 'RICHLAND HILLS', 'Tarrant',
  'TX', '76118', '8175898588', NULL,
  '18199', 'Electrical Sign Contractor', 'Active', 'ADVANTAGE SIGNS INC',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 02/12/2027'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '7fd7e1f6-a733-54c5-8e20-c8851c0ca0ff', 'commercial_signage', 'BYRUM SIGN & LIGHTING INC', NULL,
  '339950', '305 N DELAWARE STREET STE 106', 'IRVING', 'Dallas',
  'TX', '75061', '9727238525', NULL,
  '18151', 'Electrical Sign Contractor', 'Active', 'BYRUM SIGN & LIGHTING INC',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 02/28/2027'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  'eec46b48-7bef-5e2e-96d2-cf879fa43925', 'commercial_signage', 'CITY SIGN SERVICE INC', NULL,
  '339950', '3914 ELM ST', 'DALLAS', 'Dallas',
  'TX', '75226', '2148264475', NULL,
  '18156', 'Electrical Sign Contractor', 'Active', 'CITY SIGN SERVICE INC',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 07/12/2026'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  'b745e267-3604-5284-a231-0decba6e0a66', 'commercial_signage', 'GENERATION SIGNS INC', NULL,
  '339950', '6540 LITTLE JOE TRL', 'SAN ANTONIO', 'Bexar',
  'TX', '78253', '2106883449', NULL,
  '18202', 'Electrical Sign Contractor', 'Active', 'GENERATION SIGNS INC',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 04/03/2027'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  'ffdd0144-4180-5470-9d51-776d494c9f47', 'commercial_signage', 'KELLER CUSTOM SIGNS & DESIGNS', NULL,
  '339950', '1234 SAN FRANCISCO', 'SAN ANTONIO', 'Bexar',
  'TX', '78201', '2106958767', NULL,
  '18144', 'Electrical Sign Contractor', 'Active', 'KELLER CUSTOM SIGNS & DESIGNS',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 01/06/2027'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '874fe81c-db36-59d8-81c6-f582b364c32b', 'commercial_signage', 'MULTI-QUEST, INC', NULL,
  '339950', '1111 COMMERCE DRIVE', 'RICHARDSON', 'Dallas',
  'TX', '75081-2308', '9722352356', NULL,
  '18242', 'Electrical Sign Contractor', 'Active', 'MULTI-QUEST, INC',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 06/25/2027'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  'b8a40e0e-f6f2-59fb-bb98-7880be5d2f5f', 'commercial_signage', 'NATIONAL SIGN MFG', NULL,
  '339950', '7129 MOLINE', 'HOUSTON', 'Harris',
  'TX', '77087', '2812368856', NULL,
  '18174', 'Electrical Sign Contractor', 'Active', 'NATIONAL SIGN MFG',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 07/11/2025'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '96426c64-3c6d-5901-90c3-401291c482cc', 'commercial_signage', 'NP SIGN SYSTEM INC', NULL,
  '339950', '7590 FALLBROOK DR', 'HOUSTON', 'Harris',
  'TX', '77086', '2814444999', NULL,
  '18243', 'Electrical Sign Contractor', 'Active', 'NP SIGN SYSTEM INC',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 08/04/2026'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '9a78c414-eb6b-5d6b-8022-18669af7ad2f', 'commercial_signage', 'PATTISON SIGN GROUP INC DBA PATTISON ID', NULL,
  '339950', '14201 SOVEREIGN', 'FORT WORTH', 'Tarrant',
  'TX', '76155-2644', '9727396545', NULL,
  '18164', 'Electrical Sign Contractor', 'Active', 'PATTISON SIGN GROUP INC DBA PATTISON ID',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 12/06/2026'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '6fd171ac-da47-5d47-bfee-d9dd5cc42eb5', 'commercial_signage', 'PERFECT SIGNS', NULL,
  '339950', '1901 E ARKANSAS LN SUITE 114', 'ARLINGTON', 'Tarrant',
  'TX', '76010', '8172778208', NULL,
  '18205', 'Electrical Sign Contractor', 'Active', 'PERFECT SIGNS',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 06/21/2027'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '723939e2-fefd-534d-a092-d598b539f6ec', 'commercial_signage', 'PRINCE SIGNS LLC', NULL,
  '339950', '6432 CUNNINGHAM RD', 'HOUSTON', 'Harris',
  'TX', '77041-4714', '2813454488', NULL,
  '18120', 'Electrical Sign Contractor', 'Active', 'PRINCE SIGNS LLC',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 10/06/2026'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '1c6c1252-f7b8-571b-bbc7-538f4add9eba', 'commercial_signage', 'REGAN ELECTRIC SIGN CO', NULL,
  '339950', '13114 KALTENBRUN', 'HOUSTON', 'Harris',
  'TX', '77086', '7137031250', NULL,
  '18130', 'Electrical Sign Contractor', 'Active', 'REGAN ELECTRIC SIGN CO',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 03/23/2025'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  'acd8648a-c668-5e30-92cb-6d41b5595d3e', 'commercial_signage', 'RELIABLE SIGN & ENGRAVING', NULL,
  '339950', '8732 MEADOWCROFT', 'HOUSTON', 'Harris',
  'TX', '77063', '7137810504', NULL,
  '18132', 'Electrical Sign Contractor', 'Active', 'RELIABLE SIGN & ENGRAVING',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 12/22/2026'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  'e18ae397-3ffc-5a4a-8d5d-a9375f60f36a', 'commercial_signage', 'SONG SIGNS INC', NULL,
  '339950', '1408 ANTOINE DR', 'HOUSTON', 'Harris',
  'TX', '77055-5126', '7136817039', NULL,
  '18133', 'Electrical Sign Contractor', 'Active', 'SONG SIGNS INC',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 11/13/2026'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '3c0ec7d1-deeb-5215-a33f-110b677130ea', 'commercial_signage', 'SOUTHWEST TEXAS SIGN SERVICE, INC', NULL,
  '339950', '7280 S WW WHITE RD', 'SAN ANTONIO', 'Bexar',
  'TX', '78222-5204', '2106329316', NULL,
  '18110', 'Electrical Sign Contractor', 'Active', 'SOUTHWEST TEXAS SIGN SERVICE, INC',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 11/11/2026'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '5a0ae6a1-add7-5da8-88a2-8286ba71b3fb', 'commercial_signage', 'STA ADVERTISING GROUP', NULL,
  '339950', '405 N  BOWSER RD NO 7A', 'RICHARDSON', 'Dallas',
  'TX', '75081-3315', '9722348568', NULL,
  '18226', 'Electrical Sign Contractor', 'Active', 'STA ADVERTISING GROUP',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 06/10/2026'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '89e69b57-5034-52e9-b9ff-7606ab47bc48', 'commercial_signage', 'TURNER SIGN SYSTEMS', NULL,
  '339950', '1302 AVENUE R', 'GRAND PRARIE', 'Dallas',
  'TX', '75050', '8172220033', NULL,
  '18197', 'Electrical Sign Contractor', 'Active', 'TURNER SIGN SYSTEMS',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 01/10/2027'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  'b26bc4df-db12-5627-83b2-c8bc63f77f89', 'commercial_signage', 'A & A SIGNS', NULL,
  '339950', '7007 COMMERCE AVE', 'EL PASO', 'El Paso',
  'TX', '79915', '9152466937', NULL,
  '18235', 'Electrical Sign Contractor', 'Active', 'A & A SIGNS',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 09/22/2026'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '0fa37c61-2149-5814-8635-fff2c3eabe7a', 'commercial_signage', 'AD DISPLAY SIGN SYSTEMS INC', NULL,
  '339950', '27255 KATY FREEWAY', 'KATY', 'Fort Bend',
  'TX', '77494', '2813922828', NULL,
  '18193', 'Electrical Sign Contractor', 'Active', 'AD DISPLAY SIGN SYSTEMS INC',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 01/05/2027'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  'cacedff9-9224-5c4c-bf60-18dc637d7e8c', 'commercial_signage', 'EDDIE WEARDEN, INC', NULL,
  '339950', '1853 COPO DE ORO', 'EL PASO', 'El Paso',
  'TX', '79936-4357', '9154782815', NULL,
  '18189', 'Electrical Sign Contractor', 'Active', 'EDDIE WEARDEN, INC',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 12/13/2026'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  'a00fbb4f-33f5-5044-8917-f9d36e24819f', 'commercial_signage', 'ELECTRIC NEON SIGNS', NULL,
  '339950', '2300 WYOMING', 'EL PASO', 'El Paso',
  'TX', '79903', '9155444774', NULL,
  '18225', 'Electrical Sign Contractor', 'Active', 'ELECTRIC NEON SIGNS',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 07/22/2026'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '18708dfc-17bc-588c-bc10-03fa29cb4750', 'commercial_signage', 'LAMAR TEXAS LIMITED PARTNERSHIP', NULL,
  '339950', '3826 E EXPRESSWAY 83', 'HARLINGEN', 'Cameron',
  'TX', '78552', '9563994900', NULL,
  '18248', 'Electrical Sign Contractor', 'Active', 'LAMAR TEXAS LIMITED PARTNERSHIP',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 03/11/2027'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  'cac0d3d2-1fc7-5730-9e71-d77571d6349b', 'commercial_signage', 'LIBERTY SIGNS INC', NULL,
  '339950', '7200 N IH 35 BLDG 1', 'GEORGETOWN', 'Williamson',
  'TX', '78626', '5122553887', NULL,
  '18115', 'Electrical Sign Contractor', 'Active', 'LIBERTY SIGNS INC',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 09/27/2026'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  'fa59704d-3b40-588d-a552-38fc54cca470', 'commercial_signage', 'MCP NEON & SIGN', NULL,
  '339950', '31702 INDUSTRIAL PARK DR', 'PINEHURST', 'Montgomery',
  'TX', '77362', '2813569095', NULL,
  '18146', 'Electrical Sign Contractor', 'Active', 'MCP NEON & SIGN',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 05/05/2027'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '65cff51e-a061-5704-8f1b-884cd533ff09', 'commercial_signage', 'SIGN REMEDY INC', NULL,
  '339950', '21281 BLAIR RD BLDG 10', 'CONROE', 'Montgomery',
  'TX', '77385', '2816391560', NULL,
  '18185', 'Electrical Sign Contractor', 'Active', 'SIGN REMEDY INC',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 05/31/2026'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  'c07bce10-54f0-50a6-9304-ac7695db09ca', 'commercial_signage', 'SOUTH TEXAS NEON SIGN CO INC', NULL,
  '339950', '317 MASTERSON RD', 'LAREDO', 'Webb',
  'TX', '78046', '9567234665', NULL,
  '18220', 'Electrical Sign Contractor', 'Active', 'SOUTH TEXAS NEON SIGN CO INC',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 01/27/2027'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '0f0bbf9e-818d-5e61-9c42-b4bb0a7c9f76', 'commercial_signage', 'U S SIGNS', NULL,
  '339950', '258 TRADE CENTER DR', 'NEW BRAUNFELS', 'Comal',
  'TX', '78130', '8306294411', NULL,
  '18159', 'Electrical Sign Contractor', 'Active', 'U S SIGNS',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 11/20/2026'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  'a540a43e-12b5-5fb6-9cb6-61b634fa432f', 'commercial_signage', 'ADVERTISING HIGHER DBA', NULL,
  '339950', '13795 OLD TEXACO RD', 'CONROE', 'Montgomery',
  'TX', '77302', '8323069449', NULL,
  '18262', 'Electrical Sign Contractor', 'Active', 'ADVERTISING HIGHER DBA',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 02/15/2027'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  'f6500175-64d8-5294-9907-ec4c91fb4855', 'commercial_signage', 'ARTOGRAFX, INC.', NULL,
  '339950', '1233 ROUND TABLE DR', 'DALLAS', 'Dallas',
  'TX', '75247', '2143491075', NULL,
  '18286', 'Electrical Sign Contractor', 'Active', 'ARTOGRAFX, INC.',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 12/27/2026'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  'ff2d8db6-0e7d-5bd2-a1f6-d43afa53727f', 'commercial_signage', 'AUTOMATED DISPLAY SYSTEMS LP', NULL,
  '339950', '834 SAN REMO BLVD', 'AUSTIN', 'Travis',
  'TX', '78734-5171', '5128442794', NULL,
  '18376', 'Electrical Sign Contractor', 'Active', 'AUTOMATED DISPLAY SYSTEMS LP',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 11/09/2026'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '03593600-1e2e-5531-8aa6-5e9a817570df', 'commercial_signage', 'BAKER SIGN COMPANY', NULL,
  '339950', '5213 SUN VALLEY DR', 'FT WORTH', 'Tarrant',
  'TX', '76119', '8175727346', NULL,
  '18365', 'Electrical Sign Contractor', 'Active', 'BAKER SIGN COMPANY',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 11/13/2026'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '079d5746-3165-57b4-b7c7-93f726fee8dd', 'commercial_signage', 'BEACON SOLUTIONS GROUP LLC', NULL,
  '339950', '25100 PITKIN RD 80A', 'SPRING', 'Montgomery',
  'TX', '77386', '2814352012', NULL,
  '18374', 'Electrical Sign Contractor', 'Active', 'BEACON SOLUTIONS GROUP LLC',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 09/23/2026'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '3a05064f-1fe9-5695-bb95-e59b4e5ae21f', 'commercial_signage', 'BRAZO SIGN COMPANY LLC', NULL,
  '339950', '7220 CHIPPEWA BLVD', 'HOUSTON', 'Harris',
  'TX', '77086', '2813952770', NULL,
  '18378', 'Electrical Sign Contractor', 'Active', 'BRAZO SIGN COMPANY LLC',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 12/15/2026'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '4a478d99-4a95-5758-a29e-e4d4ba26448d', 'commercial_signage', 'BUILDING IMAGE GROUP INC', NULL,
  '339950', '1200 E 3RD ST', 'AUSTIN', 'Travis',
  'TX', '78702-4314', '5124941466', NULL,
  '18350', 'Electrical Sign Contractor', 'Active', 'BUILDING IMAGE GROUP INC',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 01/24/2027'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '75d7becc-de50-5537-8e5d-1565852a1d99', 'commercial_signage', 'CLASSIC SIGN COMPANY', NULL,
  '339950', '7421 VALEDA', 'DEER PARK', 'Harris',
  'TX', '77536', '7132021800', NULL,
  '18320', 'Electrical Sign Contractor', 'Active', 'CLASSIC SIGN COMPANY',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 02/14/2027'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  'ba1b5679-5090-5082-91db-e61465c3e519', 'commercial_signage', 'CREATIVE & CAASCO SIGNS, INC', NULL,
  '339950', '2719 TEXAS AVENUE', 'TEXAS CITY', 'Galveston',
  'TX', '77590', '4099454929', NULL,
  '18348', 'Electrical Sign Contractor', 'Active', 'CREATIVE & CAASCO SIGNS, INC',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 06/05/2027'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  'eed3391e-c041-50d9-852a-843dc9fb05dd', 'commercial_signage', 'DATATRONIC CONTROL INC', NULL,
  '339950', '5130 DEXHAM RD', 'ROWLETT', 'Dallas',
  'TX', '75088', '9724757879', NULL,
  '18390', 'Electrical Sign Contractor', 'Active', 'DATATRONIC CONTROL INC',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 03/12/2027'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '571bb51c-78a9-5fd2-b091-6c28a8a7c90a', 'commercial_signage', 'ENTECH SIGNS-ALPHA LED LLC', NULL,
  '339950', '1905 W ARBOR ROSE', 'GRAND PRAIRIE', 'Dallas',
  'TX', '75050', '9726410390', NULL,
  '18352', 'Electrical Sign Contractor', 'Active', 'ENTECH SIGNS-ALPHA LED LLC',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 05/31/2027'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  'ff0af4b6-9b9d-5345-ba44-3c52965a552e', 'commercial_signage', 'EXECUTIVE SIGNS ENTERPRISES INC', NULL,
  '339950', '5621 CENTRAL TEXAS DRIVE', 'SAN MARCOS', 'Hays',
  'TX', '78666', '5122929939', NULL,
  '18330', 'Electrical Sign Contractor', 'Active', 'EXECUTIVE SIGNS ENTERPRISES INC',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 04/06/2027'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  'b82ff66e-12a9-5e90-ba75-d40cd9be6a96', 'commercial_signage', 'EZZI SIGNS INC.', NULL,
  '339950', '16611 WEST LITTLE YORK RD', 'HOUSTON', 'Harris',
  'TX', '77084', '7132320771', NULL,
  '18407', 'Electrical Sign Contractor', 'Active', 'EZZI SIGNS INC.',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 12/06/2026'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '0d37cc78-d3cd-58d4-b9d3-aeeb6cbfdf28', 'commercial_signage', 'FRANK''S SIGN CO', NULL,
  '339950', '216 E EXP 83 STE N', 'PHARR', 'Hidalgo',
  'TX', '78577', '9566076103', NULL,
  '18398', 'Electrical Sign Contractor', 'Active', 'FRANK''S SIGN CO',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 04/17/2027'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '29b051d2-62f2-546a-8dae-8b640d45a98f', 'commercial_signage', 'FUTURE SIGN CO', NULL,
  '339950', '426 BLUE BELL', 'HOUSTON', 'Harris',
  'TX', '77037', '7136942291', NULL,
  '18385', 'Electrical Sign Contractor', 'Active', 'FUTURE SIGN CO',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 04/16/2027'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '5b4c2822-5def-5305-808a-aca4f3567794', 'commercial_signage', 'GRAPHTEC INC', NULL,
  '339950', '6209 WINDFERN ROAD', 'HOUSTON', 'Harris',
  'TX', '77040', '7136909999', NULL,
  '18360', 'Electrical Sign Contractor', 'Active', 'GRAPHTEC INC',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 04/12/2027'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '81b4b782-7e05-53aa-b72b-3c62a1b83509', 'commercial_signage', 'GTO SIGNS & SERVICE', NULL,
  '339950', '304 S 85TH ST', 'EDINBURG', 'Hidalgo',
  'TX', '78542-5779', '9563185199', NULL,
  '18379', 'Electrical Sign Contractor', 'Active', 'GTO SIGNS & SERVICE',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 11/20/2026'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '62e349c3-a2b4-5c67-9966-96e8aa3fb32d', 'commercial_signage', 'GULF COAST SIGN CO, INC', NULL,
  '339950', '951 FALCON BLVD', 'SAN BENITO', 'Cameron',
  'TX', '78586', '9563990755', NULL,
  '18285', 'Electrical Sign Contractor', 'Active', 'GULF COAST SIGN CO, INC',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 12/10/2026'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '8559684f-4b63-51ac-9b55-ba003d987907', 'commercial_signage', 'HATIMI CORP DBA SMB SIGNS & BANNERS', NULL,
  '339950', '11913 WINDFERN ROAD', 'HOUSTON', 'Harris',
  'TX', '77064-3200', '8327544716', NULL,
  '18349', 'Electrical Sign Contractor', 'Active', 'HATIMI CORP DBA SMB SIGNS & BANNERS',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 06/12/2027'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '942b5403-9ff4-57eb-a265-006ff30822a8', 'commercial_signage', 'HOLLIFIELD SIGNS', NULL,
  '339950', '4421 GILLIS STREET', 'AUSTIN', 'Travis',
  'TX', '78745-1017', '5126326320', NULL,
  '18263', 'Electrical Sign Contractor', 'Active', 'HOLLIFIELD SIGNS',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 01/19/2027'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '5da8b245-9301-5624-a7f5-c744dca4bfbc', 'commercial_signage', 'INNOVATIVE SIGN DESIGNS LLC', NULL,
  '339950', '5745 AYERS STREET', 'CORPUS CHRISTI', 'Nueces',
  'TX', '78415', '3618509799', NULL,
  '18335', 'Electrical Sign Contractor', 'Active', 'INNOVATIVE SIGN DESIGNS LLC',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 02/17/2027'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '6692428e-4b6d-561b-bf3a-01353f3a973b', 'commercial_signage', 'INTERNATIONAL NEON SIGN CO', NULL,
  '339950', '3115 ALAMEDA AVE', 'EL PASO', 'El Paso',
  'TX', '79907', '9152401697', NULL,
  '18274', 'Electrical Sign Contractor', 'Active', 'INTERNATIONAL NEON SIGN CO',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 01/13/2026'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  'ee9562b4-121b-5af8-8934-6f3be214e82e', 'commercial_signage', 'INTEX UNITED, INC.', NULL,
  '339950', '126 COLLINS RD', 'RICHMOND', 'Fort Bend',
  'TX', '77469', '2815684000', NULL,
  '18295', 'Electrical Sign Contractor', 'Active', 'INTEX UNITED, INC.',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 02/19/2027'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '09ee7caa-332a-5aee-ab48-b04f2183f940', 'commercial_signage', 'ION ART INC', NULL,
  '339950', '407 RADAM LANE A 100', 'AUSTIN', 'Travis',
  'TX', '78745', '5123269333', NULL,
  '18341', 'Electrical Sign Contractor', 'Active', 'ION ART INC',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 06/27/2026'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '2d15fb94-5d77-5736-b1cd-cafef63a062e', 'commercial_signage', 'JAMES SUNG INC DBA J ART SIGN CO', NULL,
  '339950', '2206 JOE FIELD RD', 'DALLAS', 'Dallas',
  'TX', '75229', '9722431155', NULL,
  '18388', 'Electrical Sign Contractor', 'Active', 'JAMES SUNG INC DBA J ART SIGN CO',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 02/07/2027'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '4c86d607-3cd8-5dc4-a7fb-052066d1c929', 'commercial_signage', 'LOZANO SIGNS', NULL,
  '339950', '12215 CYPRESS NORTH HOUST RD R', 'CYPRESS', 'Harris',
  'TX', '77429', '2819550833', NULL,
  '18306', 'Electrical Sign Contractor', 'Active', 'LOZANO SIGNS',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 10/19/2026'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  'd577c685-74be-5531-b425-4657a6f1956f', 'commercial_signage', 'M A D DESIGNS', NULL,
  '339950', '7435 W DIXON', 'SOMERSET', 'Bexar',
  'TX', '78069-3540', '2102648094', NULL,
  '18384', 'Electrical Sign Contractor', 'Active', 'M A D DESIGNS',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 01/07/2027'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '1aae9105-bf6a-5f83-90d4-fd539a8d1d9a', 'commercial_signage', 'MASTERCO, INC', NULL,
  '339950', '5545 PARKDALE', 'DALLAS', 'Dallas',
  'TX', '75227-3205', '2143884727', NULL,
  '18403', 'Electrical Sign Contractor', 'Active', 'MASTERCO, INC',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 08/19/2026'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '911d6584-8743-501b-a340-eecd0228c0ad', 'commercial_signage', 'OLEN WILLIAMS INC', NULL,
  '339950', '1123 S AIRPORT CIR', 'EULESS', 'Tarrant',
  'TX', '76040', '8172673741', NULL,
  '18266', 'Electrical Sign Contractor', 'Active', 'OLEN WILLIAMS INC',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 11/02/2026'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  'c3e02a14-7a11-5805-9bba-d98d6dc15fd1', 'commercial_signage', 'RICK''S SIGN SHOP', NULL,
  '339950', '536 SANDY LANE', 'EL PASO', 'El Paso',
  'TX', '79907', '9155499229', NULL,
  '18291', 'Electrical Sign Contractor', 'Active', 'RICK''S SIGN SHOP',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 05/06/2027'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '353f2f2a-7cfd-5b92-b6fd-0e0834119b66', 'commercial_signage', 'SIGN ERECTION LTD', NULL,
  '339950', '11124 S PIPELINE RD', 'EULESS', 'Tarrant',
  'TX', '76040', '8172671554', NULL,
  '18287', 'Electrical Sign Contractor', 'Active', 'SIGN ERECTION LTD',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 01/10/2027'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  'fef713ef-72bc-5cd1-b322-18a2d6d9bcfc', 'commercial_signage', 'SIGN METRO', NULL,
  '339950', '9224 MONSEY', 'HOUSTON', 'Harris',
  'TX', '77063', '7132712771', NULL,
  '18319', 'Electrical Sign Contractor', 'Active', 'SIGN METRO',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 02/06/2027'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  'af14b432-8384-5c35-9fd3-0e9ed0a779bd', 'commercial_signage', 'SIGNTEK INC.', NULL,
  '339950', '16380 N EVANS ROAD SUITE 2', 'SELMA', 'Guadalupe',
  'TX', '78154', '2109465511', NULL,
  '18334', 'Electrical Sign Contractor', 'Active', 'SIGNTEK INC.',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 07/23/2026'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  'efdf7c86-0e34-5aaa-b060-879d55832948', 'commercial_signage', 'SOTO SIGNS', NULL,
  '339950', '657 OMAHA', 'CORPUS CHRISTI', 'Nueces',
  'TX', '78408', '3618831311', NULL,
  '18280', 'Electrical Sign Contractor', 'Active', 'SOTO SIGNS',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 01/19/2027'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  'e7aeb4f6-4024-5a66-bfe5-0199ca809a17', 'commercial_signage', 'SRS ADVERTISING', NULL,
  '339950', '1124 MORNINGSIDE RD', 'BROWNSVILLE', 'Cameron',
  'TX', '78521', '9568320002', NULL,
  '18359', 'Electrical Sign Contractor', 'Active', 'SRS ADVERTISING',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 10/16/2026'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  'd80e8dd9-7a0a-5e5b-ba3e-a80137d39fc4', 'commercial_signage', 'TEXAS CUSTOM SIGNS LTD', NULL,
  '339950', '2007 WINDY TER STE A', 'CEDAR PARK', 'Williamson',
  'TX', '78613-4296', '5124016500', NULL,
  '18361', 'Electrical Sign Contractor', 'Active', 'TEXAS CUSTOM SIGNS LTD',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 06/09/2027'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '77ec1acf-37e9-57d3-8176-b709cd5cbf71', 'commercial_signage', 'UNITED SIGNS', NULL,
  '339950', '12097 A BEECHNUT STREET', 'HOUSTON', 'Harris',
  'TX', '77072', '2814986367', NULL,
  '18363', 'Electrical Sign Contractor', 'Active', 'UNITED SIGNS',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 08/23/2026'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '2e28c3b2-4209-5905-b056-3cc57fe09b65', 'commercial_signage', 'UNITY SIGNS', NULL,
  '339950', '16611 W LITTLE YORK RD STE # B', 'HOUSTON', 'Harris',
  'TX', '77084', '2816795152', NULL,
  '18282', 'Electrical Sign Contractor', 'Active', 'UNITY SIGNS',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 01/25/2027'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '9efc8426-eabb-5288-9afe-5bbb6a365b02', 'commercial_signage', 'BRATTON BROS SIGN CO', NULL,
  '339950', '993 E SOUTHCROSS BLVD', 'SAN ANTONIO', 'Bexar',
  'TX', '78214-1817', '2109245556', NULL,
  '18307', 'Electrical Sign Contractor', 'Active', 'BRATTON BROS SIGN CO',
  23,
  NULL, NULL, NULL,
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 08/29/2026'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '90a6351e-bb6b-57b2-bc33-8f7389fdae28', 'commercial_signage', 'WALTON ENTERPRISES LTD', NULL,
  '339950', '7373 BROADWAY SUITE  403', 'SAN ANTONIO', 'Bexar',
  'TX', '78209', '8303123354', 'https://www.waltonsignage.com/',
  '18002', 'Electrical Sign Contractor', 'Active', 'WALTON ENTERPRISES LTD',
  46,
  'Gary Walton (Walton family)', NULL, 'founder_tenure_inference',
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}, {"source": "company_website", "url": "https://www.waltonsignage.com/", "fetched_at": "2026-05-16T05:00:00Z", "fields": ["founded_year", "owner_name", "service_mix", "copyright_year", "successor_signals"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 12/12/2026; Founded 1980'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '113211bb-45b0-5126-9a86-cb927b05971f', 'commercial_signage', 'FEDERAL HEATH SIGN COMPANY', NULL,
  '339950', '15534 W HARDY RD SUITE155', 'HOUSTON', 'Harris',
  'TX', '77060', '2812606560', 'https://federalheath.com/',
  '18054', 'Electrical Sign Contractor', 'Active', 'FEDERAL HEATH SIGN COMPANY',
  125,
  'Corporate (multi-state operations)', NULL, 'corporate_entity',
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}, {"source": "company_website", "url": "https://federalheath.com/", "fetched_at": "2026-05-16T05:00:00Z", "fields": ["founded_year", "owner_name", "service_mix", "copyright_year", "successor_signals"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 04/14/2027; Founded 1901'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
INSERT INTO offmarket.businesses (
  id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip, phone, website,
  license_number, license_type, license_status, license_holder_name,
  years_in_business,
  owner_name, owner_age_estimate, owner_age_source,
  is_distressed, distress_reasons, data_sources, raw_enrichment, notes
) VALUES (
  '1d952390-ba38-5805-b40a-a653a712ea81', 'commercial_signage', 'COMET SIGNS LLC', NULL,
  '339950', '5003 STOUT DRIVE', 'SAN ANTONIO', 'Bexar',
  'TX', '78219', '2108122239', 'https://www.cometsigns.com/',
  '18010', 'Electrical Sign Contractor', 'Active', 'COMET SIGNS LLC',
  68,
  'Stratus Unlimited (PE-owned, post-2022)', NULL, 'platform_subsidiary',
  FALSE, '[]'::jsonb, '[{"source": "TDLR Electrical Sign Contractor (ESC) bulk CSV", "url": "https://www.tdlr.texas.gov/dbproduction2/Ltescele.csv", "fetched_at": "2026-05-16T04:51:30Z", "fields": ["license_number", "license_holder_name", "business_name", "business_address", "business_city", "business_county", "business_zip", "business_phone", "license_expiration_date"]}, {"source": "company_website", "url": "https://www.cometsigns.com/", "fetched_at": "2026-05-16T05:00:00Z", "fields": ["founded_year", "owner_name", "service_mix", "copyright_year", "successor_signals"]}]'::jsonb, '{}'::jsonb, 'TDLR ESC license expires 07/26/2026; Founded 1958'
)
ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
  dba_name = EXCLUDED.dba_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  website = EXCLUDED.website,
  license_number = EXCLUDED.license_number,
  license_holder_name = EXCLUDED.license_holder_name,
  years_in_business = EXCLUDED.years_in_business,
  owner_name = EXCLUDED.owner_name,
  owner_age_estimate = EXCLUDED.owner_age_estimate,
  owner_age_source = EXCLUDED.owner_age_source,
  is_distressed = EXCLUDED.is_distressed,
  data_sources = EXCLUDED.data_sources,
  notes = EXCLUDED.notes,
  updated_at = now();
COMMIT;
