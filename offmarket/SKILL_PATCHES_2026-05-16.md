# Skill Improvements — 2026-05-16 Run Findings

**Purpose:** Encode 7 model-improvement findings discovered during the 12-vertical autonomous expansion run for application to `/Users/gideonspencer/.claude/skills/offmarket-acquisition-scorer/`.

**Apply after this run's worktree is merged.** These patches go on top of the May 15 patches already noted in `SKILL_DOC_PATCHES.md`.

---

## Patch 1 — `scoring-model.md` Layer 1: add `current_owner_explicit` source

### Failure mode discovered
The `license_tenure_proxy` Layer 1 source proved 76% wrong on multi-generation family businesses (auto repair Wave 4B). When a 50-80 year-old business has the founder's grandson as current operator, license-tenure-as-proxy gives the wrong owner age (often 80-90 when current operator is actually 50-65).

### Patch
Add a new highest-priority owner_age_source AT THE TOP of the table:

```markdown
| Priority | Source | Confidence | `owner_age_source` tag |
|---|---|---|---|
| 0 | **Live About/Team page identifies current operating owner BY NAME + AGE-INFERABLE EVIDENCE** (LinkedIn grad year, "founded in 19XX by [Name] who still operates" language, "X years in industry" claim by current operator) | high | `current_owner_explicit` |
| 1 | County Appraisal District OV65 homestead exemption on owner's primary residence | high | `ov65` |
| ... (existing rows continue) |
```

### Enrichment-stage requirement (update `pipeline.md` Phase 3)
For any candidate with `years_in_business >= 30`, enrichment MUST:
1. Live-fetch the About / Our Team / History / Family page.
2. Identify the CURRENT operating owner explicitly (not just "Smith family operation").
3. If the current operator is a 2nd/3rd/4th generation member, use THEIR age, not founder's age.
4. If the current operator is a non-family acquirer (e.g., "Gallagher bought Collinsworth Car Care in 1999"), use the acquisition year for tenure, not the founding year.

**Without this check, multi-gen family businesses systematically overscore.**

---

## Patch 2 — `verticals.md` pest control: SPCB_TPCL as tenure proxy

### Failure mode discovered
TX Dept of Agriculture's Structural Pest Control bulk export ships ALL licensees with `LICENSE_ISSUED = 1990-01-01` — this is a system-import placeholder date, NOT the real license-grant year. Using it for tenure produces uniform 36-year "tenure" across all licensees.

### Patch
Add to the pest control vertical section:

```markdown
### Tenure proxy — IMPORTANT
The TDA bulk export's `LICENSE_ISSUED = 1990-01-01` is a placeholder. Do NOT use it.
Instead, use the **SPCB_TPCL** code (the legacy pest control license number) as a tenure proxy:
- SPCB_TPCL < 500 → license granted ~1971 (original cohort)
- SPCB_TPCL 500-1000 → ~1972-1980
- SPCB_TPCL 1000-2000 → ~1980-1990
- SPCB_TPCL 2000-3000 → ~1990-1998
- SPCB_TPCL 3000-4000 → ~1998-2005
- SPCB_TPCL 4000+ → 2005+

Cross-validate with: years_in_business inferred from the company's website "founded in" language or Google search.
```

---

## Patch 3 — `scoring-model.md` Layer 1: funeral home succession-event boost

### Finding
Funeral homes with **recently-deceased founders**, **widow/widower running solo**, or **founder's obituary published in last 18 months** are the highest-conviction succession-event sellers. These should receive an explicit Layer 1 boost.

### Patch
Add a new vertical-specific Layer 1 modifier under "Tenure modifier" section:

```markdown
### Vertical-specific L1 modifiers

**Funeral homes:**
- Founder's obituary published in last 24 months + no named successor → **+8 boost**
- Widow/widower running solo (spouse founded together, surviving spouse continues) → **+5 boost**
- Multi-generation family with 3rd-gen+ in business (line ends if current owner exits) → **+3 boost**

**CPA / accounting firms:**
- Site explicitly says "not accepting new clients" / "no new clients at this time" → **+15 boost** (strongest single signal)
- Sole CPA approaching 65+ with no associate CPA in pipeline (verified via LinkedIn search) → **+5 boost**

**Pest control (Gideon acquire-self vertical):**
- SPCB_TPCL code < 1000 (1970s cohort) → **+5 boost** (these are the oldest original licensees still operating)
- Owner verifiable via Veripages/OfficialUSA AND age ≥ 70 → confidence cap raised to "medium-high" automatically

**Auto repair:**
- License-tenure-proxy disagrees with current-operator-name from About page by ≥ 15 years → DOWNGRADE confidence to "low" and cap at C_watch. Reflects the multi-gen succession issue.
```

---

## Patch 4 — `verifying-no-successor.md`: detect aggregator/buyer patterns

### Finding
**Carlisle Auto Air** (San Antonio) is actively rolling up TX auto repair (acquired Bolen's Automotive in 2024). They appear in the spine as a normal target, but they're the **competitor aggregator**, not a seller. Other aggregators surfaced this run: Arrow Glass Industries (Kilgore), Anytime Garage Door (multi-state), Pool Troopers/SPS PoolCare (acquired Prime Pool 2023).

### Patch
Add a new top-level section after the rationalization table:

```markdown
## Aggregator/buyer-pattern detection (NEW — 2026-05-16)

A subset of spine candidates are NOT sellers — they're the **aggregator competitors** in the vertical. These show up because they look like family businesses in the spine but are actively executing roll-ups.

**Detection signals (any of these = EXCLUDE/D_pass):**

1. **"We acquired X in YEAR" language on the website** — direct evidence they're buying.
2. **Multi-city/multi-state location pages** with consistent branding — suggests franchise or roll-up.
3. **"Family of brands" / "part of [Group]" footer language** — even if family-named.
4. **Google news: "[Business] acquires [Business]" in last 5 yrs**.
5. **Common SOS registered agent address shared with other "independent" candidates** in the same vertical+geo — typical PE-portfolio tell.
6. **CEO/President LinkedIn lists "M&A" / "Roll-up" / "Strategic acquisitions" as job duties** — sometimes signaled in their About page bio too.

**Where to look:**
- For high-tenure spine candidates with high tier scores (A/B), run a 1-paragraph Google news search before promoting to A.
- For candidates with multi-location footprints, verify each location is operated by the same family/owner, not acquired.

**Known aggregators surfaced 2026-05-16 (add to skill exclusion lists):**

- Carlisle Auto Air (San Antonio) — auto repair
- Anytime Garage Door — garage door (parent of Apple Garage Door, Accent Garage Doors, Hutchins Garage Doors+)
- Arrow Glass Industries (Kilgore) — glass (parent of East Texas Glass, Henderson Glass, possibly Lewisville Glass & Mirror)
- Pool Troopers / SPS PoolCare (national) — pool service
- Hoke Family Companies — recent acquirer of Cherokee Industrial Fabricators (welding)
- Legacy Funeral Group — recent acquirer of Combest (funeral)
- Precision Aerospace Holdings — recent acquirer of Owens Machine, Icon Machine (CNC)
- Innovetive Petcare, Lakefield, CityVet, NVA, etc. (vet — existing list, expand quarterly)
```

---

## Patch 5 — `data-sources-and-compliance.md`: add Veripages + OfficialUSA + LinkedIn snippet workflow

### Finding
Wave 4A pest control re-enrichment unlocked 9 A-tier promotions by using **Veripages** + **OfficialUSA** + **LinkedIn snippet** chains to verify owner age. These are public-record-aggregator sites that consolidate name+age+address+phone records. They were the single biggest yield-unlock of the run.

### Patch
Add a new section to data-sources:

```markdown
## Public-record owner-age aggregators (NEW — 2026-05-16)

For owners whose age cannot be inferred from license tenure, LinkedIn, or website self-report, the following public-record aggregators provide age data:

### Veripages (`veripages.com`)
- Free tier returns name + age + city/state + relatives.
- Use search: `"{owner_first_name} {owner_last_name}" "{city} TX"`.
- Returns address-matched records; **use only when business address ≈ owner residence** (or when only one match exists).
- Confidence: high when address-matched + single match. Medium when multiple candidates of similar age.
- Tag: `owner_age_source = "veripages_age_verified"` or `"veripages_age_range"` (when range given).

### OfficialUSA (`officialusa.com`)
- Returns name + DOB + city + employment records.
- Use for cross-validation of Veripages matches.
- Tag: `owner_age_source = "officialusa_dob_verified"`.

### LinkedIn graduation-year snippet
- Google search: `"{owner_first_name} {owner_last_name}" {profession} linkedin {city}`.
- Capture graduation year from snippet.
- Add 22 (undergrad) or 25 (professional degree like CPA, JD, DDS, AuD) to compute age.
- Tag: `owner_age_source = "linkedin_grad"`.

### Restricted-use boundaries (REINFORCED)
- TX voter file → DOB more reliable but RESTRICTED USE. Requires SOS application + permitted-use affidavit. Do NOT use casually.
- DMV DL DOB → DPPA-restricted. Federal-level prohibition. Do NOT pursue.
- Veripages / OfficialUSA / LinkedIn → public consumer-aggregator data. OK to use for internal research per CCPA/TDPSA. Annotate every age with source.

### Provenance requirement
Every `owner_age_estimate` MUST have an `owner_age_source` tag. Rows with `restricted-use` sources (voter, DMV) are flagged for filtering before any external share to buyer community.
```

---

## Patch 6 — `pipeline.md` Phase 4 Scoring: add per-vertical L4 nudges from new verticals

### Finding
Each of the 12 new verticals scored this run has distinctive Layer 4 (market pull) characteristics. Encode these once for reproducibility.

### Patch
Add per-vertical L4 nudge tables to each vertical's section in `verticals.md`. Already drafted in:
- `/Users/gideonspencer/dealhound-pro/.claude/worktrees/laughing-yonath-843b53/offmarket/vertical-configs-2026-05-16.md`
- `/Users/gideonspencer/dealhound-pro/.claude/worktrees/laughing-yonath-843b53/offmarket/vertical-configs-wave-2-2026-05-16.md`
- `/Users/gideonspencer/dealhound-pro/.claude/worktrees/laughing-yonath-843b53/offmarket/vertical-configs-wave-3-2026-05-16.md`

When applying patches: copy each vertical's section into `verticals.md` as a new top-level section.

---

## Patch 7 — `a-tier-deep-dive.md`: encode top-A-tier verification protocol

### Finding
This run identified 99+ A-tier candidates. The deep-dive protocol (a-tier-deep-dive.md) needs refinement for the high-volume case.

### Patch
Add a "Volume strategy" subsection:

```markdown
## High-volume A-tier strategy

When the orchestrator surfaces 30+ A-tier candidates in a single run (this happened on 2026-05-16 with ~99 A-tier candidates across 12 verticals), the deep-dive protocol becomes a triage problem.

**Triage rules:**
1. **Tier 1A (highest-confidence, immediate):** Candidates where owner_age_source is `current_owner_explicit`, `ov65`, `voter_dob`, `veripages_age_verified`, OR `officialusa_dob_verified`. Limit deep-dive batch to top-20 by final_score.
2. **Tier 1B (high-confidence, batch 2):** Candidates with `linkedin_grad` source AND L1 ≥ 75 AND L3 ≥ 70. Run after Tier 1A clears.
3. **Tier 2 (proxy-only, defer):** Candidates with `license_tenure_proxy` only AND no current_owner_explicit verification. Re-enrichment pass before deep-dive (cf. Wave 4A pest control method).

**Tier 1A deep-dive verification (per candidate, ~15 min):**
1. Comptroller PIR officer cross-check (per existing protocol).
2. CAD homestead deed + OV65 verification (Playwright scrapers).
3. Live team-page fetch for successor verification.
4. Google news scan for recent acquisition activity (aggregator detection per Patch 4).
5. License board disciplinary check.
6. Building ownership via CAD.
7. Sharpen value-add thesis to bespoke specifics.
8. Final A acceptance OR demote-with-notes.

**Volume target:** ~5-10 A-tier candidates verified per hour of deep-dive work. A 99-A-tier run = ~10-20 hours of deep-dive labor; budget accordingly.
```

---

## Files to update (priority order)

When applying these patches to the skill directory:

```bash
SKILL_DIR=/Users/gideonspencer/.claude/skills/offmarket-acquisition-scorer
```

1. **scoring-model.md** — Patches 1, 3 (owner-age source + vertical L1 modifiers)
2. **verifying-no-successor.md** — Patch 4 (aggregator detection)
3. **data-sources-and-compliance.md** — Patch 5 (Veripages/OfficialUSA workflow)
4. **verticals.md** — Patch 2 (pest SPCB_TPCL) + Patch 6 (12 new verticals from worktree configs)
5. **a-tier-deep-dive.md** — Patch 7 (volume strategy)
6. **pipeline.md** — Reference to Patch 1 (`current_owner_explicit` is now required for high-tenure businesses)

---

## Provenance

Findings encoded above were discovered during the **2026-05-16 19-hour autonomous expansion run**, which:
- Scored 12 NEW verticals (Funeral, Pharmacy, CPA, Hearing Aid, Pool Service, Garage Door, Landscaping, Painting, Welding, Glass, Janitorial, CNC)
- Re-enriched 2 existing verticals (Pest Control B-tier with NULL owner_age, Auto Repair B-tier with license_tenure_proxy)
- Promoted ~99 net new A-tier candidates (3.3× baseline)
- Generated `/Users/gideonspencer/dealhound-pro/.claude/worktrees/laughing-yonath-843b53/offmarket/REPORT-MEGA-2026-05-16.md`

The 5-hour Sonnet token budget cap was the natural stopping point for sub-agent work. Orchestrator (Opus) ran throughout, applying all SQL writes via the Supabase MCP.
