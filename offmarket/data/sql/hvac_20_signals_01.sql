INSERT INTO offmarket.business_signals (
        business_id, layer, signal_key, direction, evidence, source, source_url, observed_at
    ) VALUES
    (
            'e9219869-3eeb-57d5-bdb2-6370dedbeff6',
            3,
            'successor_check_live_fetch',
            'positive',
            'Live about page at https://airdepot.com/about-us/ (fetched 2026-05-16): Kenneth Taylor is the primary owner/voice. Quote: ''My brother Paul and I were both owners of Hallmark Air Conditioning'' — indicates Kenneth + Paul co-owned a PRIOR company (Hallmark), and now Kenneth runs Air Depot. NO other family members named in current operations, NO 3rd-gen, NO PE/platform footer. Since 1977 founding verified. Two senior co-owners (Kenneth + Paul Taylor) — semi-internal but no younger generation.',
            'live_website_fetch',
            'https://airdepot.com/about-us/',
            '2026-05-16'
        ),
(
            'e9219869-3eeb-57d5-bdb2-6370dedbeff6',
            1,
            'owner_age_verification',
            'positive',
            'Kenneth Taylor — owner since 1977 (49 yrs at the helm) — estimated late 60s to mid 70s. His brother Paul co-founded the prior company. Source: live about page.',
            'live_website_fetch',
            'https://airdepot.com/about-us/',
            '2026-05-16'
        ),
(
            'e9219869-3eeb-57d5-bdb2-6370dedbeff6',
            2,
            'credentials_nate_acca_bbb',
            'positive',
            'BBB-accredited business; NATE-certified crew; ACCA member; multi-year Nextdoor Neighborhood Favorite. Brands: Lennox, Carrier, Daikin. Strong quality signal.',
            'live_website_fetch',
            'https://airdepot.com/about-us/',
            '2026-05-16'
        ),
(
            'f63d1e43-91e6-5015-bbe1-7201d741680f',
            3,
            'successor_check_live_fetch',
            'disqualifying',
            'Live about page at https://gobvs.com/about/ (fetched 2026-05-16) confirms ''Since 1981 — 45 years serving over 10,000 customers'' and ''family-owned and operated'', formerly Brazos Valley Services. NO named owners, NO team list visible. No PE/platform footer. Cannot verify successor presence/absence from this page alone; team-page-not-found is disqualifying per skill non-negotiable §2.',
            'live_website_fetch_insufficient',
            'https://gobvs.com/about/',
            '2026-05-16'
        ),
(
            'c36394d9-ddf9-5e96-a1cc-4b36c58bcf83',
            3,
            'successor_check_live_fetch',
            'negative',
            'Live about page at https://www.halwatsonac.com/about-us (fetched 2026-05-16) confirms: Founder Hal Watson (retired police officer, founded 1961) passed company to **Leah and her husband Tyler Symens**. **Internal succession already happened — Tyler + Leah Symens are the current operating owners.** Family-owned 60+ years. NO PE/platform footer. Demote to B per verifying-no-successor.md: this is a structured internal-buy-in candidate.',
            'live_website_fetch',
            'https://www.halwatsonac.com/about-us',
            '2026-05-16'
        ),
(
            'c36394d9-ddf9-5e96-a1cc-4b36c58bcf83',
            1,
            'owner_age_verification',
            'negative',
            'Current owners are Leah + Tyler Symens (Leah is Hal''s daughter or daughter-in-law). They are 2nd-generation, likely mid-40s to mid-50s. NOT in natural exit window yet. License_tenure_proxy reflects Hal Watson''s founding tenure (1961), not Tyler/Leah''s age.',
            'live_website_fetch',
            'https://www.halwatsonac.com/about-us',
            '2026-05-16'
        ),
(
            'e29d55e7-0eba-5dbd-97d0-dbbbc99f75fe',
            3,
            'successor_check_live_fetch',
            'negative',
            'Live team page at https://www.houstonnorth.com/our-team.html (fetched 2026-05-16) — Maurice R. Torgan (CEO, founded company in 1980, started HVAC career in 1967 in Dallas — so likely born ~1945, now ~81), **Acie Dickerson (President, joined 1985, promoted from sales → VP → President — clear internal successor already running day-to-day operations, 41 yrs tenure)**, Donna Harness (Controller, joined 1982 — 44 yrs tenure). **Internal succession structurally already in place: Acie Dickerson is functionally the CEO-in-waiting.** Founder Torgan likely already retired or semi-retired. Demote.',
            'live_website_fetch',
            'https://www.houstonnorth.com/our-team.html',
            '2026-05-16'
        ),
(
            'e29d55e7-0eba-5dbd-97d0-dbbbc99f75fe',
            1,
            'owner_age_verification',
            'positive',
            'Maurice R. Torgan founded company 1980, started HVAC career 1967 in Dallas — likely born ~1945, currently ~81 yrs old. Squarely in late-natural-exit. But Acie Dickerson is the de-facto operator now.',
            'live_website_fetch',
            'https://www.houstonnorth.com/our-team.html',
            '2026-05-16'
        ),
(
            'bfdc4fb0-8a42-592e-a7bb-3dc5288ad151',
            3,
            'successor_check_live_fetch',
            'negative',
            'Live homepage at https://valderramainc.com/ (fetched 2026-05-16) confirms: ''Family-owned and operated since 1983'' and ''Three generations of HVAC expertise serving Houston families.'' **Multi-generational, three-gen explicit — internal succession structurally already in place across multiple generations.** No PE/platform affiliation. Demote per family-successor rule from verifying-no-successor.md.',
            'live_website_fetch',
            'https://valderramainc.com/',
            '2026-05-16'
        ),
(
            '80ed548b-55f9-5b24-8167-c185d7716963',
            3,
            'successor_check_live_fetch',
            'disqualifying',
            'Live homepage at https://merricks.co/ (fetched 2026-05-16) — page confirms ''family-owned business'' and ''Since 1946'' (72 yrs serving Houston) and TACLA22411E + TACLA1074C licenses, but NO named owners, NO team list, NO successor information visible. No PE/platform affiliation. Page does not surface enough info to confirm or deny successor presence — live-fetch capped at low confidence per skill non-negotiable §2.',
            'live_website_fetch_insufficient',
            'https://merricks.co/',
            '2026-05-16'
        ),
(
            '80ed548b-55f9-5b24-8167-c185d7716963',
            1,
            'owner_age_verification',
            'negative',
            'Site shows 80 years tenure but does not name current owner. Without owner name, no OV65 / voter / deed verification possible. Cap confidence at low.',
            'live_website_fetch_insufficient',
            'https://merricks.co/',
            '2026-05-16'
        ),
(
            'e0f25290-2025-55fd-9b13-1db9fe6609ad',
            3,
            'successor_check_live_fetch',
            'disqualifying',
            'Live staff page at https://reliantairconditioning.com/our-staff/ (fetched 2026-05-16) — page shows only a ''Reliant Staff'' group photo, NO individuals named with titles or tenure. Founder name NOT disclosed. Owner age NOT disclosed. About-us PE-blog article (https://reliantairconditioning.com/family-owned-hvac-company-unaffected-by-private-equity-firms/) confirms ''Standing Out as a Family-Owned HVAC Company in the Dallas/Ft. Worth Area, Unaffected by Private Equity Firms'' — owner publicly differentiates from PE. NO successor information surfaced. Per skill non-negotiable §2, successor verification is disqualifying — cap at C_watch.',
            'live_website_fetch_insufficient',
            'https://reliantairconditioning.com/our-staff/',
            '2026-05-16'
        ),
(
            'e0f25290-2025-55fd-9b13-1db9fe6609ad',
            4,
            'owner_explicitly_anti_pe',
            'positive',
            'Owner published a blog post explicitly positioning Reliant as ''unaffected by private equity firms'' — a strong independent-mindset signal but also suggests the owner has been approached by PE buyers (otherwise why write the post?). Useful Layer 4 acquirer-demand signal and Layer 1 signal that owner is in the conversation about successor / sale.',
            'live_website_fetch',
            'https://reliantairconditioning.com/family-owned-hvac-company-unaffected-by-private-equity-firms/',
            '2026-05-16'
        ),
(
            'dfb2be3c-ae7d-5a33-9597-a21d82a33eb2',
            3,
            'successor_check_live_fetch',
            'positive',
            'Live team/about page at https://www.climatecontrol-sa.com/about-us/ (fetched 2026-05-16) — only named leadership is Scott Burger (President since January 1988, 38 yrs at helm). NO co-owners, NO second-generation family members named, NO successor candidate identified, NO PE/platform footer affiliation. Founder year 1965 verified.',
            'live_website_fetch',
            'https://www.climatecontrol-sa.com/about-us/',
            '2026-05-16'
        ),
(
            'dfb2be3c-ae7d-5a33-9597-a21d82a33eb2',
            1,
            'owner_age_verification',
            'positive',
            'Scott Burger has led Climate Control as President since January 1988 — 38 years personal tenure. Started his presidency likely in his 30s/40s; now estimated 65-75. Source: company''s own About page. Note: license_tenure_proxy + about-page bio; OV65 NOT yet obtained.',
            'live_website_fetch',
            'https://www.climatecontrol-sa.com/about-us/',
            '2026-05-16'
        ),
(
            'dfb2be3c-ae7d-5a33-9597-a21d82a33eb2',
            2,
            'recurring_revenue_pma_present',
            'positive',
            'Page references ''Annual service agreements and system tune-ups'' as offered service + ''Maintenance Plans'' in nav menu. Recurring revenue base present though % not visible without deeper page-scrape.',
            'live_website_fetch',
            'https://www.climatecontrol-sa.com/about-us/',
            '2026-05-16'
        ),
(
            '48c192a7-7f93-5b44-8e8c-d28194a42ee5',
            3,
            'successor_check_live_fetch',
            'negative',
            'Live team page at https://www.aplusac.com/about-us/our-team/ (fetched 2026-05-16) confirms: Greg Yamin (President since 1982), Sharon Yamin (''The Real Boss'', joined 1988), **Josh Yamin (Home Solutions Manager / Energy Auditor — 2nd generation, UT 2010 grad, has been in the business since youth), Stephanie Yamin (Customer Service — ''literally born into the family business'')**. NO PE/platform footer. **Internal successor candidates already in place: Josh (multi-decade operations involvement, 2nd-gen) and Stephanie. Sharon Yamin is co-owner.** Demote from A → B per verifying-no-successor.md.',
            'live_website_fetch',
            'https://www.aplusac.com/about-us/our-team/',
            '2026-05-16'
        ),
(
            '48c192a7-7f93-5b44-8e8c-d28194a42ee5',
            1,
            'owner_age_verification',
            'positive',
            'Greg Yamin pioneered Austin Energy conservation in 1982 — career started early/mid 1980s, now estimated 65-75. Sharon Yamin joined the company in 1988 when daughter Jackie was born (so daughter is now ~38 yrs old). Multi-generation family business.',
            'live_website_fetch',
            'https://www.aplusac.com/about-us/our-team/',
            '2026-05-16'
        ),
(
            '6c6abecb-4b86-5432-a628-2c58433c190d',
            3,
            'successor_check_live_fetch',
            'positive',
            'Live about/team page at https://efficienttexas.com/about/ (fetched 2026-05-16) — Owners: George Drazic (President) + Molly Drazic (CEO). Leadership team includes Gilbert (Construction Mgr), James (AC Service Mgr), Joe (Fabrication Mgr), Kate (Marketing), Kelly (Master Electrician), Ralph (Purchasing/Estimator), Steve (Master Plumber), Theresa (Controller). **No Drazic children named in current operations — no second-generation successor on team page.** Page mentions ''team members who''ve been with us for 10, 20, and even 30 years'' generally but Steve/Kelly etc are department leads, not Drazic successors. NO PE/platform footer.',
            'live_website_fetch',
            'https://efficienttexas.com/about/',
            '2026-05-16'
        ),
(
            '6c6abecb-4b86-5432-a628-2c58433c190d',
            1,
            'owner_age_verification',
            'positive',
            'Molly + George Drazic purchased Efficient from original founders in 2008 — 18 yrs at the helm. UT-graduates, raised sons here. Drazics now estimated 55-65 yrs old. The 2008 purchase year implies they were probably 40-50 at acquisition, so now 56-67 — solidly in the natural-exit window. NO Drazic children on team page = no internal successor.',
            'live_website_fetch',
            'https://efficienttexas.com/about/',
            '2026-05-16'
        );