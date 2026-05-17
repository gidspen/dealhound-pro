"""CAD portal registry — bimodal classification + alternative-path strategies.

Finding 2 (2026-05-15 deep-dive): CAD scraping is bimodal.

  WORKS (classic ASP.NET / trueautomation form-back):
    - Dallas    (DCAD, dallascad.org)         → scrape_dcad.py
    - Bexar     (BCAD, bexar.trueautomation)  → scrape_bcad.py

  BLOCKED (JS-rendered SPA — fields exist in DOM but submit doesn't trigger):
    - Tarrant   (TAD, ProdigyCAD)              → blocked_spa
    - Hays      (HaysCAD, esearch.*.com)       → blocked_spa
    - Fort Bend (FBCAD, esearch.*.com)         → blocked_spa
    - Williamson (WCAD, ProdigyCAD)            → blocked_spa
    - Collin    (CollinCAD, esearch variant)   → blocked_spa (uncertain — needs probe)

  BLOCKED_BY_LAW (Texas law masks owner-age info):
    - Harris    (HCAD, search.hcad.org React)  → blocked_by_law (OV65 hidden)

When a CAD is blocked, the orchestrator should try the fallback strategies
listed under `alt_paths`, in order of expected yield. Each strategy points to
either an existing scraper module, a planned scraper, or a manual escalation.

This module is purely declarative — it does NOT implement the fallback paths,
only registers them so the orchestrator can route around blocks.
"""
from typing import Literal

CadStatus = Literal["works", "blocked_spa", "blocked_by_law", "untested"]

# ---------------------------------------------------------------------------
# Per-county registry
# ---------------------------------------------------------------------------

CAD_REGISTRY: dict[str, dict] = {
    # ---- WORKS ----
    "dallas": {
        "portal_name": "DCAD",
        "url": "https://www.dallascad.org",
        "status": "works",
        "scraper_module": "offmarket.scrapers.scrape_dcad",
        "notes": "Classic ASP.NET form-back. Tax Ceiling line = OV65 proxy (cad_common Proxy 2).",
        "alt_paths": [],
    },
    "bexar": {
        "portal_name": "BCAD",
        "url": "https://bexar.trueautomation.com",
        "status": "works",
        "scraper_module": "offmarket.scrapers.scrape_bcad",
        "notes": "TrueAutomation classic. OV65 sometimes coded as 'OTHER' + tax-savings ratio "
                 "(cad_common Proxy 1, $6K+ threshold).",
        "alt_paths": [],
    },
    # ---- BLOCKED_BY_LAW ----
    "harris": {
        "portal_name": "HCAD",
        "url": "https://search.hcad.org",
        "status": "blocked_by_law",
        "scraper_module": "offmarket.scrapers.scrape_hcad",
        "notes": (
            "Texas law restriction: 'Texas law prohibits us from displaying residential "
            "photographs, sketches, floor plans, or information indicating the age of a "
            "property owner.' HCAD does NOT publicly display OV65 — tax-ceiling proxy "
            "likely also masked. Plus React SPA blocks Playwright submit. "
            "scrape_hcad still useful for deed_date / homestead / appraised_value, "
            "but Layer-1 owner-age signal MUST come from elsewhere for Harris targets."
        ),
        "alt_paths": [
            {
                "strategy": "harris_county_clerk_deed_records",
                "url": "https://www.cclerk.hctx.net/applications/websearch/",
                "scraper_module": None,  # not yet built
                "yield_estimate": "60-80%",
                "rationale": (
                    "Harris County Clerk deed records ARE public and include grantor/grantee "
                    "+ recording dates. Cross-reference with Comptroller PIR to derive a "
                    "homestead address + deed-age proxy, then estimate owner age from "
                    "deed acquisition date + long-tenure heuristic."
                ),
            },
            {
                "strategy": "tx_voter_file",
                "url": "https://webservices.sos.state.tx.us/...",
                "scraper_module": None,  # restricted-use, requires SOS application
                "yield_estimate": "95%+",
                "rationale": (
                    "Texas voter file includes DOB. Restricted-use (Gideon's "
                    "private-research-only per skill config). Requires Secretary of State "
                    "application + sworn permitted-use affidavit. Highest fidelity but "
                    "compliance overhead — defer until pipeline maturity justifies."
                ),
            },
            {
                "strategy": "comptroller_pir_officer_address_compare",
                "url": "https://comptroller.texas.gov/taxes/franchise/account-status/search",
                "scraper_module": "offmarket.scrapers.scrape_comptroller",
                "yield_estimate": "30-50%",
                "rationale": (
                    "If Comptroller PIR officer's home address is in Harris County and on "
                    "a residential street (not a commercial suite), it's the owner's "
                    "homestead. Use deed_date from a NON-Harris CAD lookup (if owner has "
                    "another TX property), or accept license-tenure proxy with explicit "
                    "low confidence."
                ),
            },
        ],
    },
    # ---- BLOCKED_SPA (JavaScript-only frameworks, headless submit doesn't trigger) ----
    "tarrant": {
        "portal_name": "TAD (ProdigyCAD)",
        "url": "https://tarrant.prodigycad.com",
        "status": "blocked_spa",
        "scraper_module": None,
        "notes": (
            "ProdigyCAD SPA. URL-param queries return 404; fields exist in DOM but "
            "submit handler doesn't fire under headless. Affects ~6 Fort Worth + "
            "Colleyville + Southlake targets (Mellina, Colleyville Animal Clinic, "
            "Bridge Street, Altig, North Texas Eye Care)."
        ),
        "alt_paths": [
            {
                "strategy": "tarrant_county_clerk_deed_records",
                "url": "https://teos.tarrantcounty.com/recorder",
                "scraper_module": None,
                "yield_estimate": "60-70%",
                "rationale": (
                    "Tarrant County Clerk deed records are public and searchable by "
                    "grantor/grantee name. Returns recording date + property address. "
                    "Combined with long-tenure heuristic + deed age > 15 yrs, gives "
                    "medium-confidence OV65 proxy."
                ),
            },
            {
                "strategy": "tx_voter_file",
                "url": "https://webservices.sos.state.tx.us/...",
                "scraper_module": None,
                "yield_estimate": "95%+",
                "rationale": "Same as Harris — restricted-use, compliance overhead.",
            },
            {
                "strategy": "license_tenure_proxy_with_low_confidence_cap",
                "url": None,
                "scraper_module": None,
                "yield_estimate": "100% (but low confidence)",
                "rationale": (
                    "Fall back to license-issue-year + 26 = est. age proxy. Scoring layer "
                    "MUST cap confidence at 'low' for any target whose Layer-1 anchor is "
                    "proxy-only (no CAD / no voter file / no obit match)."
                ),
            },
        ],
    },
    "hays": {
        "portal_name": "Hays CAD (eSearch)",
        "url": "https://esearch.hayscad.com",
        "status": "blocked_spa",
        "scraper_module": None,
        "notes": (
            "eSearch SPA — Hays/Fort Bend/Collin share this engine. Same submit-not-firing "
            "issue as Tarrant. Affects Perdue Insurance (Buda residence) and other Austin "
            "exurb targets."
        ),
        "alt_paths": [
            {
                "strategy": "hays_county_clerk_deed_records",
                "url": "https://hayscountyclerktx.governmentwindow.com/",
                "scraper_module": None,
                "yield_estimate": "60-70%",
                "rationale": "Hays County deed records — same approach as Tarrant.",
            },
            {
                "strategy": "tx_voter_file",
                "url": None,
                "scraper_module": None,
                "yield_estimate": "95%+",
                "rationale": "Same restricted-use caveat.",
            },
            {
                "strategy": "license_tenure_proxy_with_low_confidence_cap",
                "url": None,
                "scraper_module": None,
                "yield_estimate": "100% (low confidence)",
                "rationale": "Fall back; cap confidence at low.",
            },
        ],
    },
    "fort_bend": {
        "portal_name": "FBCAD (eSearch)",
        "url": "https://esearch.fbcad.org",
        "status": "blocked_spa",
        "scraper_module": None,
        "notes": (
            "eSearch SPA — same engine as Hays. Affects Sugar Land + Richmond optometry / "
            "vet targets (TSO Sugar Land, etc.)."
        ),
        "alt_paths": [
            {
                "strategy": "fort_bend_county_clerk_deed_records",
                "url": "https://fbccpublic.fortbendcountytx.gov/",
                "scraper_module": None,
                "yield_estimate": "60-70%",
                "rationale": "Fort Bend County deed records.",
            },
            {
                "strategy": "tx_voter_file",
                "url": None,
                "scraper_module": None,
                "yield_estimate": "95%+",
                "rationale": "Same restricted-use caveat.",
            },
            {
                "strategy": "license_tenure_proxy_with_low_confidence_cap",
                "url": None,
                "scraper_module": None,
                "yield_estimate": "100% (low confidence)",
                "rationale": "Fall back.",
            },
        ],
    },
    "williamson": {
        "portal_name": "WCAD (ProdigyCAD)",
        "url": "https://wcad.org",
        "status": "blocked_spa",
        "scraper_module": None,
        "notes": "Same ProdigyCAD engine as Tarrant. Affects Round Rock / Cedar Park targets.",
        "alt_paths": [
            {
                "strategy": "williamson_county_clerk_deed_records",
                "url": "https://www.wilco.org/Elected-Officials/County-Clerk",
                "scraper_module": None,
                "yield_estimate": "60-70%",
                "rationale": "Williamson County deed records.",
            },
            {
                "strategy": "tx_voter_file",
                "url": None,
                "scraper_module": None,
                "yield_estimate": "95%+",
                "rationale": "Same restricted-use caveat.",
            },
            {
                "strategy": "license_tenure_proxy_with_low_confidence_cap",
                "url": None,
                "scraper_module": None,
                "yield_estimate": "100% (low confidence)",
                "rationale": "Fall back.",
            },
        ],
    },
    "travis": {
        "portal_name": "TCAD",
        "url": "https://www.traviscad.org",
        "status": "untested",
        "scraper_module": None,
        "notes": (
            "Travis CAD search not yet probed in deep-dive runs. Suspected ProdigyCAD-class. "
            "First Austin-metro probe should determine whether to add a scrape_travis.py."
        ),
        "alt_paths": [
            {
                "strategy": "probe_first_then_classify",
                "url": "https://traviscad.prodigycad.com",
                "scraper_module": None,
                "yield_estimate": "unknown",
                "rationale": "Run a manual Playwright probe; classify as works/blocked.",
            },
        ],
    },
    "collin": {
        "portal_name": "CollinCAD",
        "url": "https://www.collincad.org",
        "status": "untested",
        "scraper_module": None,
        "notes": "Not yet probed. Probable eSearch variant.",
        "alt_paths": [
            {
                "strategy": "probe_first_then_classify",
                "url": None,
                "scraper_module": None,
                "yield_estimate": "unknown",
                "rationale": "Run probe.",
            },
        ],
    },
}


def get_cad_status(county: str) -> CadStatus:
    """Return the bimodal status for a given county.

    'works' / 'blocked_spa' / 'blocked_by_law' / 'untested'.
    Returns 'untested' for counties not in the registry (callers can decide to skip).
    """
    if not county:
        return "untested"
    entry = CAD_REGISTRY.get(county.strip().lower())
    if not entry:
        return "untested"
    return entry["status"]


def get_alt_paths(county: str) -> list[dict]:
    """Return the ordered alternative-path strategies for a blocked county.

    Returns empty list for 'works' counties (no fallback needed) and for counties
    not in the registry. Callers should treat the order as priority — try the
    first non-restricted-use path first.
    """
    if not county:
        return []
    entry = CAD_REGISTRY.get(county.strip().lower())
    if not entry:
        return []
    return list(entry.get("alt_paths", []))


def is_blocked(county: str) -> bool:
    """Convenience: True if the county's primary CAD is blocked (SPA or by law)."""
    return get_cad_status(county) in ("blocked_spa", "blocked_by_law")
