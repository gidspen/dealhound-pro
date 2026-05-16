# Skill Doc Patches — Apply After Other Thread Finishes

**Why this file exists:** the `offmarket-acquisition-scorer` skill is actively
in use by another thread. To avoid disrupting that thread's working set, this PR
does NOT edit the live skill markdown files directly. Instead, the patches below
should be applied to the skill files **after** the other thread has finished
(or in coordination with it).

Live skill location:
`/Users/gideonspencer/.claude/skills/offmarket-acquisition-scorer/`

---

## Patch 1 — Update `scoring-model.md`

### Layer 1 (Base Rate) — add the new OV65 inference sources

In the table under "### Inputs (best → worst — use the best you can verify)",
add **two** rows immediately below the existing OV65 row:

```markdown
| Priority | Source | Confidence | `owner_age_source` tag |
|---|---|---|---|
| 1 | County Appraisal District **OV65 homestead exemption** on owner's primary residence | high | `ov65` |
| 1a | **Bexar BCAD "OTHER" exemption + tax-savings ≥ $6K** (inferred OV65 proxy) | high | `ov65_inferred_bexar_other_savings` |
| 1b | **DCAD "Tax Ceiling" line** (inferred OV65 proxy — Dallas/some surrounding) | high | `ov65_inferred_dcad_tax_ceiling` |
| 2 | County Appraisal District deed/acquisition date on homestead | high | (separate `owner_property_deed_date` field) |
...
```

**Rationale:** Per the 2026-05-15 deep-dive, OV65 isn't always labeled
explicitly. Bexar codes it as "OTHER" + a $6K+ tax-savings ratio on the
property page (Whitaker Insurance — $6,207 savings = OV65 confirmed). Dallas
shows it as a "Tax Ceiling" line (Animal Hospital of Valley Ranch — confirmed).
Code: `offmarket/scrapers/cad_common.py` `extract_exemptions()` now returns
`ov65_inferred`, `ov65_inference_source`, `tax_savings_amount`, `tax_ceiling`,
`ov65_any`. Treat `ov65_any=True` as the canonical Layer-1 OV65 boolean.

---

## Patch 2 — Update `scoring-model.md` Hard Gates

In the "Hard gates" section, add **two new gates** after the existing 6:

```markdown
7. **Owner-name mismatch with Comptroller PIR** → `confidence ≤ low`, cap at
   `B_forward`. When the JSON-stated `owner_name` does not appear among the
   Comptroller PIR officers (or only appears in a non-control title like
   Secretary / Director / VP), the equity ownership likely differs from the
   website-stated principal. Source: `offmarket.scoring_rules.verify_owner_name()`.
   Examples that surfaced this gate:
   - Fire Safe Protection Services (JSON: "Stephen McKinney"; PIR: Bruce L. Burianek = sole manager)
   - Perdue Insurance Agency (JSON: "Donald Perdue"; PIR: Cloud family in operational control)

8. **Succession-completed signals on a candidate A/B** → cap at `C_watch`.
   Fires when ANY of:
   - ≥2 co-Directors in Comptroller PIR at DIFFERENT residential addresses with
     different surnames (= internal buyout structure, not single-founder exit)
   - Founder absent from current team page (`founder_present=False` or
     founder surname not among `team_members`)
   - Non-family Chief of Staff / Lead title on the team page
   - 2+ recent-grad (license-issued within 5 yrs) associates on staff
   - Single recent-grad associate combined with any other signal above
   Source: `offmarket.scoring_rules.detect_succession_completed()`.
   Examples that surfaced this gate:
   - Colleyville Animal Clinic (Wilson absent; Erickson = non-family Chief of Staff)
   - Alamo Dog & Cat Hospital (LaBrie family transition in motion — Nick Labrie as Lead Vet)
   - Bellaire Optometry Clinic (Le + Nguyen co-Presidents at separate residences)
```

---

## Patch 3 — Update `verifying-no-successor.md`

Add a new top-level section after the existing rationalization table:

```markdown
## Comptroller PIR officer cross-check (NEW — 2026-05-15)

The TX Comptroller Public Information Report (PIR) lists director/officer/manager
names, titles, and addresses for every active TX entity. This is the single
highest-leverage signal for owner-name verification (Finding 5 of the May 2026
deep-dive).

**Where to find it:** the JSON `franchise-tax/{taxpayerId}` endpoint does NOT
expose PIR officers — only the HTML page at
`https://comptroller.texas.gov/taxes/franchise/account-status/search/{taxpayerId}`.
The `scrape_comptroller.py` scraper now fetches this HTML in addition to the
JSON detail and parses the officer table. The parsed list lands in the cached
result as `pir_officers: [{title, name, address}, ...]` and `pir_year: int`.

**How to use it for successor-check:**

| Pattern | Interpretation | Tier action |
|---|---|---|
| 1 control-title officer (single PRESIDENT / CEO / MANAGER) at same address as registered agent | Clean solo-owner. Cross-check owner_name token-overlap. | OK to consider A_acquire_self |
| Multiple same-surname officers at SAME address | Family-owned (Whitaker pattern). NOT a disqualifier. | OK to consider A_acquire_self |
| Multiple DIFFERENT-surname control-title officers at DIFFERENT addresses | Internal buyout (Bellaire Optometry pattern — Le + Nguyen). | Cap C_watch |
| JSON owner_name only in non-control title (Director / VP / Secretary) | Founder stepped back. Succession-in-motion. | Cap C_watch, confidence=low |
| JSON owner_name not in PIR at all + registered_agent IS the JSON owner | Possible: agent acts as legal proxy; need to verify. | Cap B_forward, confidence=low |
| JSON owner_name not in PIR at all + registered_agent shares no surname with PIR officers | Equity is with a different family entirely (Fire Safe / Burianek pattern). | Cap B_forward, confidence=low |

Code reference: `offmarket.scoring_rules.verify_owner_name()` returns
`{owner_verified, mismatch_kind, matched_officer, recommended_confidence_cap}`.
```

---

## Patch 4 — Update `data-sources-and-compliance.md`

Add a new "CAD portal bimodality" section at the top (above the per-source list):

```markdown
## CAD portal bimodality (2026-05-15 finding)

Texas CAD portals split cleanly into TWO classes that require different
scraping strategies. The orchestrator MUST classify the county before
choosing a strategy.

### Class A — Works with classic Playwright form-back
These portals respond to `<form action="..." method="POST">` submission and
return server-rendered HTML. Headless Chromium drives them reliably.

- **Dallas (DCAD)** — `dallascad.org` — scrape_dcad.py
- **Bexar (BCAD)** — `bexar.trueautomation.com` — scrape_bcad.py

### Class B — Blocked SPAs
JavaScript-only frameworks (ProdigyCAD, eSearch.*). Search fields exist in
the DOM but submit handlers don't trigger under headless. Often missing the
form-action POST endpoint that classic scrapers rely on. **Do NOT rely on
these for Layer-1 owner-age data.**

- **Tarrant (TAD)** — ProdigyCAD — `tarrant.prodigycad.com`
- **Hays (HaysCAD)** — eSearch — `esearch.hayscad.com`
- **Fort Bend (FBCAD)** — eSearch — `esearch.fbcad.org`
- **Williamson (WCAD)** — ProdigyCAD — `wcad.org`
- **Collin (CollinCAD)** — eSearch variant — untested

### Class C — Blocked by Texas law
The portal is reachable, but state law prohibits displaying owner-age data:

- **Harris (HCAD)** — `search.hcad.org` — "Texas law prohibits us from
  displaying residential photographs, sketches, floor plans, or information
  indicating the age of a property owner." OV65 marker is hidden. Tax-ceiling
  proxy likely also masked.

### Alternative-path registry

For Class B and C counties, use the alternative-path registry at
`offmarket/scrapers/cad_registry.py` (`get_alt_paths(county)`). The orchestrator
should try the lowest-compliance-overhead strategy first:

1. **County clerk deed records** (public, free, per-county UI) — gives
   recording-date + grantor/grantee for long-tenure-as-OV65-proxy. ~60-70% yield.
2. **Texas voter file** (DOB anchor — RESTRICTED USE, requires SOS application
   and permitted-use affidavit). 95%+ yield but compliance overhead. Defer
   until pipeline maturity.
3. **License-tenure proxy + confidence cap** (license-issue-year + 26 = age).
   Always available, but scoring layer MUST cap confidence at "low" when this
   is the only Layer-1 source.
```

---

## Patch 5 — Update `pipeline.md`

In Phase 3 (Enrich), after the existing per-business enrichment list, add:

```markdown
### Verification gates (NEW — 2026-05-15)

After Comptroller + CAD data is merged, the orchestrator calls
`offmarket.scoring_rules.apply_verification_gates(business, comptroller, team_page)`.
This returns:

  - `owner_verification.owner_verified` — bool
  - `owner_verification.mismatch_kind` — `not_found_in_pir` |
    `non_control_role_only` | `registered_agent_match_but_pir_different_family` |
    `no_pir_data` | None
  - `succession_check.succession_completed` — bool
  - `succession_check.signals` — list of which signals fired
  - `recommended_tier_cap` — `C_watch` | None
  - `recommended_confidence_cap` — `low` | None

The orchestrator MUST apply these caps in Phase 4 scoring:

  - If `recommended_tier_cap == "C_watch"`, cap final tier at C_watch regardless
    of L1-L4 sum.
  - If `recommended_confidence_cap == "low"`, set confidence to low and (per
    hard-gate 4) cap tier at B_forward.

### CAD status advisory

The merge step also attaches `cad_status_advisory` per business (from
`offmarket.scrapers.cad_registry`). When status is `blocked_spa` or
`blocked_by_law`, the orchestrator should:

  1. Skip the primary CAD scrape (it'll fail or return empty).
  2. Try the listed `alt_paths` in order.
  3. If all alt_paths fail, fall back to license-tenure proxy and cap
     confidence at "low".
```

---

## Patch 6 — Update `a-tier-deep-dive.md`

Add a new item between current Items 2 and 3:

```markdown
### 2.5 PIR officer cross-check

Verify the JSON `owner_name` against the Comptroller Public Information Report
officer list. The `scrape_comptroller.py` scraper now caches `pir_officers`
on every successful match. Open the cached file at
`offmarket/cache/comptroller/<vertical>__<entity_id>.json` and confirm:

  - JSON `owner_name` appears in `pir_officers[*].name` with a CONTROL title
    (PRESIDENT / CEO / MANAGER / OWNER / MANAGING MEMBER / PRINCIPAL).
  - If owner only appears in a non-control title (Director / VP / Secretary),
    treat as succession-in-motion → demote to B_forward.
  - If owner not in PIR at all, treat as owner-name-verification gap →
    demote to B_forward, cap confidence at low.

**Quick test:** can `offmarket.scoring_rules.verify_owner_name(owner_name,
pir_officers, registered_agent)` return `owner_verified=True`? If no, the
candidate is NOT ready for A-tier.
```

---

## How to apply these patches

When the other thread has finished using the skill (or in coordination with it):

```bash
# Skill files live at:
SKILL_DIR=/Users/gideonspencer/.claude/skills/offmarket-acquisition-scorer

# Manually edit each file with the patches above. Recommended order:
# 1. scoring-model.md (Patches 1 + 2)
# 2. verifying-no-successor.md (Patch 3)
# 3. data-sources-and-compliance.md (Patch 4)
# 4. pipeline.md (Patch 5)
# 5. a-tier-deep-dive.md (Patch 6)
```

The code these patches reference (cad_common changes, scrape_comptroller PIR
parser, cad_registry, scoring_rules, enrich_phase6 wiring) is already in this
PR and tested. The skill docs just need to describe the new behavior for the
next orchestrator run.
