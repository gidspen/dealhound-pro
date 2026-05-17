INSERT INTO offmarket.businesses (
        id, vertical, legal_name, dba_name, naics_code, address, city, county, state, zip,
        phone, website, license_number, license_type, license_status, license_issue_date, license_holder_name,
        entity_sos_file_number, entity_formation_date, entity_status, registered_agent,
        years_in_business, employee_count_estimate, provider_count_estimate, employee_count_source,
        owner_name, owner_age_estimate, owner_age_source, owner_tenure_years,
        owner_homestead_address, owner_property_deed_date,
        is_distressed, distress_reasons, data_sources, raw_enrichment, notes
    ) VALUES
('9a06b76e-232a-5c2f-9eb7-47b3bc600a83','hvac_residential','Douglas Mechanical, Inc.',NULL,'238220',NULL,'Houston','Harris','TX',NULL,NULL,'https://douglas-inc.com/',NULL,'ACR_unknown_class',NULL,NULL,NULL,NULL,NULL,'unknown',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'unknown',NULL,NULL,NULL,FALSE,'[]'::jsonb,'[]'::jsonb,'{}'::jsonb,'Houston Trane Comfort Specialist. Independent dealer.'),
('1facfad1-ce56-5b76-bcd6-169653474973','hvac_residential','Nick''s Air Conditioning',NULL,'238220',NULL,'Houston','Harris','TX',NULL,NULL,'https://nicksairconditioning.com/',NULL,'ACR_unknown_class',NULL,NULL,NULL,NULL,NULL,'unknown',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'unknown',NULL,NULL,NULL,FALSE,'[]'::jsonb,'[]'::jsonb,'{}'::jsonb,'Houston Trane Comfort Specialist.')
    ON CONFLICT (vertical, legal_name, city, state) DO UPDATE SET
        updated_at = now()
    RETURNING id, legal_name;