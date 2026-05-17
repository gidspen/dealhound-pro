INSERT INTO offmarket.business_scores (
        business_id, score_run_id,
        layer1_base_rate, layer1_comment, layer2_sellability, layer2_comment,
        layer3_behavioral_trigger, layer3_comment, layer4_market_pull, layer4_comment,
        final_score, final_tier, final_comment, value_add_thesis,
        confidence, data_completeness
    ) VALUES
    (
            '9a06b76e-232a-5c2f-9eb7-47b3bc600a83',
            '5457dd0d-bc77-4810-a691-46425b7e9b8b',
            30,
            'Douglas Mechanical, Inc.: year established unverified from spine source. L1 capped at proxy-only score; needs CAD OV65 or website ''serving since'' verification before promotion.',
            63,
            'Douglas Mechanical, Inc.: residential service trade; tenure unknown; sub_trade=residential_commercial. Brand-dealer status present (premium-network membership = quality signal).',
            35,
            'Douglas Mechanical, Inc.: live team-page fetch NOT performed in this run (broad batch); L3 scored conservatively from spine-level signals only — no strong coasting signals captured at spine level. Cap on tier-promotion: requires live-fetch verification per skill non-negotiables.',
            88,
            'Douglas Mechanical, Inc.: TX HVAC roll-up is the hottest skilled-trade vertical in 2026 — Apex Service Partners + Wrench + Service Champions + Sila all actively buying. Harris County sub-market nudge +3. SBA 7(a) financeable to $5M.',
            35,
            'D_pass',
            'Hard gate: less than 5 years in business or year unverified. Cap at C_watch max; default D_pass for unverified entry.',
            'Generic AI/ops modernization possible but not bespoke until live enrichment surfaces specific gaps.',
            'low',
            0.3
        ),
(
            '1facfad1-ce56-5b76-bcd6-169653474973',
            '5457dd0d-bc77-4810-a691-46425b7e9b8b',
            30,
            'Nick''s Air Conditioning: year established unverified from spine source. L1 capped at proxy-only score; needs CAD OV65 or website ''serving since'' verification before promotion.',
            63,
            'Nick''s Air Conditioning: residential service trade; tenure unknown; sub_trade=residential_service. Brand-dealer status present (premium-network membership = quality signal).',
            35,
            'Nick''s Air Conditioning: live team-page fetch NOT performed in this run (broad batch); L3 scored conservatively from spine-level signals only — no strong coasting signals captured at spine level. Cap on tier-promotion: requires live-fetch verification per skill non-negotiables.',
            88,
            'Nick''s Air Conditioning: TX HVAC roll-up is the hottest skilled-trade vertical in 2026 — Apex Service Partners + Wrench + Service Champions + Sila all actively buying. Harris County sub-market nudge +3. SBA 7(a) financeable to $5M.',
            35,
            'D_pass',
            'Hard gate: less than 5 years in business or year unverified. Cap at C_watch max; default D_pass for unverified entry.',
            'Generic AI/ops modernization possible but not bespoke until live enrichment surfaces specific gaps.',
            'low',
            0.3
        )
    ON CONFLICT (business_id, score_run_id) DO UPDATE SET
        layer1_base_rate = EXCLUDED.layer1_base_rate,
        layer1_comment = EXCLUDED.layer1_comment,
        layer2_sellability = EXCLUDED.layer2_sellability,
        layer2_comment = EXCLUDED.layer2_comment,
        layer3_behavioral_trigger = EXCLUDED.layer3_behavioral_trigger,
        layer3_comment = EXCLUDED.layer3_comment,
        layer4_market_pull = EXCLUDED.layer4_market_pull,
        layer4_comment = EXCLUDED.layer4_comment,
        final_score = EXCLUDED.final_score,
        final_tier = EXCLUDED.final_tier,
        final_comment = EXCLUDED.final_comment,
        value_add_thesis = EXCLUDED.value_add_thesis,
        confidence = EXCLUDED.confidence,
        data_completeness = EXCLUDED.data_completeness;
    