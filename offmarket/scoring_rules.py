"""Scoring rules — succession-completed detection + owner-name verification.

Encodes Findings 4 and 5 from the 2026-05-15 A-tier deep-dive (PR #65).

Finding 4 — succession-completed downgrade:
  3 of 15 top candidates had succession already in motion that initial scoring missed.
  Signals to detect:
    - Founder absent from team page (founder-name not in any current team role)
    - Non-family Chief of Staff / Lead / Director title held by someone OTHER than
      the JSON owner_name's family
    - Comptroller PIR shows 2+ co-Directors at DIFFERENT residential addresses
      (= internal buyout structure, not single-founder exit)
    - Recent-grad associate hired (license issue year within last 5 yrs) =
      planned internal buy-in

Finding 5 — owner-name verification gap:
  Original scoring trusted the JSON-stated owner_name without cross-checking
  Comptroller equity ownership. Two cases that surfaced:
    - Fire Safe: JSON owner_name = "Stephen McKinney" (President) but legal owner
      is Bruce L. Burianek (sole manager of GP entity Sherwood Forest Enterprises).
    - Perdue: JSON owner_name = "Donald Perdue" but operational control is the
      Cloud family (Brandon=CEO, Kevin=GM, Kristopher=Agent).
  Fix: when Comptroller PIR officers ≠ JSON owner_name (or the JSON name appears
  ONLY in a non-control title), downgrade confidence pending re-verification.

This module is pure-Python — no I/O. Callers pass in already-fetched Comptroller
PIR data + optional team-page data; the module returns structured advisories.
Designed to be testable without network.
"""
from __future__ import annotations

import re
from dataclasses import dataclass, field
from typing import Iterable, Optional


# ---------------------------------------------------------------------------
# Title classification — which titles indicate operational/equity control
# ---------------------------------------------------------------------------

# Titles that imply current operational control. JSON owner_name MUST appear
# in at least one of these for full confidence.
_CONTROL_TITLES = {
    "PRESIDENT", "CEO", "CHIEF EXECUTIVE OFFICER", "OWNER", "MANAGING MEMBER",
    "MANAGING PARTNER", "MANAGER", "PRINCIPAL", "GENERAL PARTNER", "TRUSTEE",
}

# Titles that imply ceremonial / passive / non-control roles. JSON owner_name
# appearing ONLY here = succession-completed signal (Founder steps back to
# Director-only or Secretary-only).
_NON_CONTROL_TITLES = {
    "SECRETARY", "TREASURER", "DIRECTOR", "VICE PRESIDENT", "VP",
    "FOUNDER", "FOUNDING DIRECTOR", "DIRECTOR EMERITUS", "EMERITUS",
    "ADVISOR", "ADVISORY", "BOARD MEMBER",
}


# ---------------------------------------------------------------------------
# Result types
# ---------------------------------------------------------------------------

@dataclass
class OwnerVerificationResult:
    """Outcome of cross-checking JSON owner_name against Comptroller PIR officers."""

    owner_verified: bool                       # True iff JSON owner matches a control-title officer
    has_pir_data: bool                          # False = no PIR officers fetched (incomplete data)
    mismatch_kind: Optional[str] = None         # "not_found_in_pir" | "non_control_role_only" | "no_pir_data" | None
    matched_officer: Optional[dict] = None      # the PIR officer that matched, if any
    recommended_confidence_cap: Optional[str] = None  # "low" | "medium" | None (None = no cap)
    notes: list[str] = field(default_factory=list)


@dataclass
class SuccessionCheckResult:
    """Outcome of detecting whether internal succession is already in motion."""

    succession_completed: bool = False
    signals: list[str] = field(default_factory=list)
    recommended_tier_cap: Optional[str] = None  # "C_watch" | "B_forward" | None (None = no cap)
    notes: list[str] = field(default_factory=list)


# ---------------------------------------------------------------------------
# Name normalization
# ---------------------------------------------------------------------------

_NAME_STRIP_PREFIXES = re.compile(
    r'^\s*(?:Dr\.?|Mr\.?|Mrs\.?|Ms\.?|Prof\.?)\s+', re.I
)
_NAME_STRIP_SUFFIXES = re.compile(
    r'\s*(?:,?\s*(?:DDS|DMD|MD|DO|DVM|OD|AuD|OptD|JD|CPA|PA|PLLC|LLC|Inc\.?|'
    r'II|III|IV|Jr\.?|Sr\.?))+\s*$',
    re.I,
)


def _normalize_name(name: str) -> str:
    """Uppercase, strip titles/suffixes, collapse whitespace. For comparison only."""
    if not name:
        return ""
    n = _NAME_STRIP_PREFIXES.sub("", name)
    n = _NAME_STRIP_SUFFIXES.sub("", n)
    n = re.sub(r'\s+', ' ', n).strip().upper()
    return n


def _last_name(normalized: str) -> str:
    """Best-effort last-name extraction from an already-normalized name."""
    if not normalized:
        return ""
    if "," in normalized:
        # "WHITAKER, CHESTER D" form
        return normalized.split(",", 1)[0].strip()
    parts = normalized.split()
    if not parts:
        return ""
    return parts[-1]


def _tokens(normalized: str) -> set[str]:
    """Token set for fuzzy comparison (last + first + middle initials)."""
    if not normalized:
        return set()
    cleaned = normalized.replace(",", " ")
    return {t for t in cleaned.split() if t}


def _classify_title(title: str) -> str:
    """Return 'control' | 'non_control' | 'unknown'."""
    if not title:
        return "unknown"
    t = title.upper().strip()
    for canon in _CONTROL_TITLES:
        if canon in t:
            return "control"
    for canon in _NON_CONTROL_TITLES:
        if canon in t:
            return "non_control"
    return "unknown"


# ---------------------------------------------------------------------------
# Owner-name verification (Finding 5)
# ---------------------------------------------------------------------------

def verify_owner_name(
    json_owner_name: str | None,
    pir_officers: Iterable[dict] | None,
    registered_agent_name: str | None = None,
) -> OwnerVerificationResult:
    """Cross-check JSON owner_name against Comptroller PIR + registered agent.

    Returns OwnerVerificationResult with:
      - owner_verified=True if the JSON owner appears in a CONTROL-title PIR
        officer OR is the registered agent.
      - mismatch_kind="not_found_in_pir" if PIR exists but no token overlap.
      - mismatch_kind="non_control_role_only" if owner is in PIR but only with
        a non-control title (Director / VP / Secretary / Founder-Emeritus).
      - mismatch_kind="no_pir_data" if PIR officers list is empty/None (caller
        can't conclude — treat as "incomplete data" not "verified").
      - recommended_confidence_cap="low" for any mismatch.
    """
    result = OwnerVerificationResult(owner_verified=False, has_pir_data=False)

    if not json_owner_name:
        result.notes.append("no_json_owner_name_to_verify")
        result.recommended_confidence_cap = "low"
        return result

    json_norm = _normalize_name(json_owner_name)
    json_tokens = _tokens(json_norm)
    json_last = _last_name(json_norm)

    # Registered agent — secondary signal. If owner_name matches the agent,
    # that's good evidence the JSON name is right (agent is usually the principal
    # for small-business filings).
    if registered_agent_name:
        agent_norm = _normalize_name(registered_agent_name)
        agent_tokens = _tokens(agent_norm)
        if json_last and json_last in agent_tokens and len(json_tokens & agent_tokens) >= 2:
            result.owner_verified = True
            result.matched_officer = {
                "title": "REGISTERED AGENT",
                "name": registered_agent_name,
                "address": None,
            }
            result.notes.append("matched_via_registered_agent")
            # Don't return yet — keep checking PIR for the stronger control-title evidence.

    officers = list(pir_officers or [])
    if not officers:
        if not result.owner_verified:
            result.mismatch_kind = "no_pir_data"
            result.recommended_confidence_cap = "low"
            result.notes.append("no_pir_officers_fetched_or_present")
        else:
            result.has_pir_data = False
            result.notes.append("registered_agent_match_but_no_pir_to_corroborate")
        return result

    result.has_pir_data = True

    # Find the best officer match: prefer control-title + token overlap
    best_control_match = None
    best_non_control_match = None
    for off in officers:
        off_norm = _normalize_name(off.get("name", ""))
        off_tokens = _tokens(off_norm)
        off_last = _last_name(off_norm)
        if not off_tokens:
            continue
        # Token-overlap rule: require last-name match AND at least one other token
        # (first name or middle initial) to consider it a match.
        if json_last and off_last and json_last == off_last:
            shared = json_tokens & off_tokens
            if len(shared) >= 2 or (len(json_tokens) == 1 and len(off_tokens) >= 1):
                cls = _classify_title(off.get("title", ""))
                if cls == "control" and best_control_match is None:
                    best_control_match = off
                elif cls == "non_control" and best_non_control_match is None:
                    best_non_control_match = off
                elif best_control_match is None and best_non_control_match is None:
                    # unknown title — treat as non-control for safety
                    best_non_control_match = off

    if best_control_match:
        # Strongest evidence — promote (overrides any prior registered-agent-only flag)
        result.owner_verified = True
        result.matched_officer = best_control_match
        # If we previously matched only via registered_agent, the control-title PIR
        # match is the more authoritative signal; clear any earlier confidence cap.
        result.recommended_confidence_cap = None
        result.notes.append(f"matched_control_title: {best_control_match.get('title')}")
        return result

    if best_non_control_match:
        # Owner is in PIR but only as Director / VP / Secretary / etc. —
        # Finding 5: this is the "Founder stepped back" pattern.
        result.mismatch_kind = "non_control_role_only"
        result.matched_officer = best_non_control_match
        result.recommended_confidence_cap = "low"
        result.notes.append(
            f"owner_in_pir_but_only_non_control_title: {best_non_control_match.get('title')} — "
            f"possible succession-in-motion"
        )
        return result

    # JSON owner_name not found among PIR officers.
    # Two sub-cases that need different treatment:
    #   (a) Family-owned: registered_agent matched AND at least one PIR officer
    #       shares the owner's surname → benign (Whitaker pattern). Keep
    #       owner_verified=True, no confidence cap.
    #   (b) Fire Safe / Burianek pattern: registered_agent did or didn't match,
    #       but PIR officers are an entirely different family → cap LOW.
    pir_surnames = {
        _last_name(_normalize_name(o.get("name", "")))
        for o in officers
        if o.get("name")
    }
    pir_surnames.discard("")

    if result.owner_verified and json_last and json_last in pir_surnames:
        # Registered-agent match corroborated by same-surname presence in PIR (family-owned).
        result.notes.append(
            f"registered_agent_match_plus_same_surname_in_pir ({json_last}) — family-owned pattern"
        )
        return result

    if result.owner_verified and json_last and json_last not in pir_surnames:
        # Registered-agent matched BUT no same-surname in PIR. The Burianek
        # warning sign — agent might be a proxy / attorney while equity sits
        # with a different family entirely. Demote.
        result.owner_verified = False
        result.mismatch_kind = "registered_agent_match_but_pir_different_family"
        result.recommended_confidence_cap = "low"
        result.notes.append(
            f"registered_agent matched but PIR officers ({len(officers)}) share no surname with "
            f"json owner '{json_owner_name}' — agent may be a proxy; equity likely elsewhere"
        )
        return result

    result.mismatch_kind = "not_found_in_pir"
    result.recommended_confidence_cap = "low"
    result.notes.append(
        f"json_owner '{json_owner_name}' not found among {len(officers)} PIR officers — "
        f"equity ownership likely differs from website-stated principal"
    )
    return result


# ---------------------------------------------------------------------------
# Succession-completed detection (Finding 4)
# ---------------------------------------------------------------------------

def detect_succession_completed(
    json_owner_name: str | None,
    pir_officers: Iterable[dict] | None,
    team_page: dict | None = None,
    license_issue_dates: list[str] | None = None,
    recent_grad_threshold_years: int = 5,
    current_year: int = 2026,
) -> SuccessionCheckResult:
    """Detect signals that internal succession is already complete or imminent.

    Arguments:
      json_owner_name           — original owner_name from the business record
      pir_officers              — list of {title, name, address} from Comptroller PIR
      team_page                 — optional {team_members: [{name, title, ...}],
                                  founder_present: bool | None, chief_of_staff_name: str | None,
                                  fetched_at: str | None}
                                  team_page reflects what the LIVE website team/about page shows.
                                  Pass None if not fetched.
      license_issue_dates       — optional list of ISO date strings for current staff
                                  (for "recent-grad associate hired" detection)
      recent_grad_threshold_years — staff with license issued within this many years = "recent grad"
      current_year              — for license-tenure comparison (override in tests)

    Returns SuccessionCheckResult with:
      - succession_completed=True if any STRONG signal fires
      - signals[] enumerating which signals triggered
      - recommended_tier_cap='C_watch' if succession_completed (Phase 5 demotion)
    """
    result = SuccessionCheckResult()

    officers = list(pir_officers or [])
    json_norm = _normalize_name(json_owner_name or "")
    json_last = _last_name(json_norm)

    # ---- Signal A: ≥2 co-Directors at DIFFERENT residential addresses ----
    # The Bellaire Optometry pattern: Le + Nguyen at separate residences =
    # internal buyout structure. Distinguish from same-family-at-same-address
    # (Whitaker pattern — 3 Whitakers at one address = family-owned, NOT exit).
    if len(officers) >= 2:
        control_officers = [o for o in officers if _classify_title(o.get("title", "")) == "control"]
        if len(control_officers) >= 2:
            # Compare normalized addresses (strip suite numbers, normalize whitespace)
            addresses = [_normalize_address(o.get("address") or "") for o in control_officers]
            distinct_addresses = {a for a in addresses if a}
            # Different surnames among control officers
            surnames = [_last_name(_normalize_name(o.get("name", ""))) for o in control_officers]
            distinct_surnames = {s for s in surnames if s}
            if len(distinct_addresses) >= 2 and len(distinct_surnames) >= 2:
                result.succession_completed = True
                result.signals.append(
                    "pir_multi_control_officers_different_addresses_different_surnames"
                )
                result.notes.append(
                    f"{len(control_officers)} control-title officers at {len(distinct_addresses)} "
                    f"different addresses with {len(distinct_surnames)} different surnames — "
                    f"internal buyout structure, not single-founder exit"
                )

    # ---- Signal B: Founder absent from team page ----
    if team_page is not None and json_last:
        team_members = team_page.get("team_members") or []
        founder_present_flag = team_page.get("founder_present")
        if founder_present_flag is False:
            result.succession_completed = True
            result.signals.append("founder_absent_from_team_page")
            result.notes.append(
                "team_page.founder_present=False — founder no longer listed in current team"
            )
        elif team_members:
            # Auto-detect: does any team_member's name include the founder's last name?
            found = False
            for m in team_members:
                m_norm = _normalize_name(m.get("name", ""))
                if json_last and json_last in _tokens(m_norm):
                    found = True
                    break
            if not found:
                result.succession_completed = True
                result.signals.append("founder_surname_not_on_team_page")
                result.notes.append(
                    f"team page lists {len(team_members)} members; founder surname '{json_last}' "
                    f"not among them"
                )

    # ---- Signal C: Non-family Chief of Staff / Lead title ----
    if team_page is not None and json_last:
        chief_name = team_page.get("chief_of_staff_name")
        if chief_name:
            chief_norm = _normalize_name(chief_name)
            chief_tokens = _tokens(chief_norm)
            if json_last and json_last not in chief_tokens:
                result.succession_completed = True
                result.signals.append("non_family_chief_of_staff")
                result.notes.append(
                    f"team_page.chief_of_staff_name='{chief_name}' — surname differs from "
                    f"founder '{json_last}' (non-family operational lead)"
                )

    # ---- Signal D: Recent-grad associate hired ----
    if license_issue_dates:
        recent_count = 0
        for iso_date in license_issue_dates:
            try:
                year = int(iso_date[:4])
                if current_year - year <= recent_grad_threshold_years:
                    recent_count += 1
            except (ValueError, TypeError):
                continue
        if recent_count >= 1:
            # Recent-grad on its own isn't strong; only fire if combined with another signal
            # already-firing OR if there are 2+ recent grads.
            if result.succession_completed or recent_count >= 2:
                result.signals.append(f"recent_grad_associate_count={recent_count}")
                result.notes.append(
                    f"{recent_count} associate(s) licensed within last {recent_grad_threshold_years} "
                    f"yrs — planned internal buy-in pattern"
                )
                result.succession_completed = True

    if result.succession_completed:
        result.recommended_tier_cap = "C_watch"

    return result


def _normalize_address(addr: str) -> str:
    """Normalize for distinct-address comparison: strip suite numbers, whitespace, punctuation."""
    if not addr:
        return ""
    a = addr.upper()
    a = re.sub(r'\b(?:STE|SUITE|#|UNIT|APT|FLOOR|FLR)\s*[\w-]+', '', a)
    a = re.sub(r'[,.]', ' ', a)
    a = re.sub(r'\s+', ' ', a).strip()
    # Keep just the street + city (drop ZIP+state for fuzzy matching)
    return a


# ---------------------------------------------------------------------------
# Combined verdict — what to do with a candidate
# ---------------------------------------------------------------------------

def apply_verification_gates(
    business: dict,
    comptroller: dict | None,
    team_page: dict | None = None,
    license_issue_dates: list[str] | None = None,
) -> dict:
    """Apply Findings 4+5 gates to a candidate. Returns advisory dict.

    Caller is expected to merge this into the candidate's final scoring decision.
    Does NOT mutate inputs.

    Output:
      {
        "owner_verification": {OwnerVerificationResult fields...},
        "succession_check": {SuccessionCheckResult fields...},
        "recommended_tier_cap": "C_watch" | None,
        "recommended_confidence_cap": "low" | None,
        "combined_notes": [str, ...],
      }
    """
    pir_officers = (comptroller or {}).get("pir_officers") or []
    registered_agent = (comptroller or {}).get("registered_agent_name")
    json_owner_name = business.get("owner_name")

    ov = verify_owner_name(json_owner_name, pir_officers, registered_agent)
    sc = detect_succession_completed(
        json_owner_name=json_owner_name,
        pir_officers=pir_officers,
        team_page=team_page,
        license_issue_dates=license_issue_dates,
    )

    # Combine caps — pick the strictest (lowest confidence / lowest tier).
    tier_cap = sc.recommended_tier_cap
    conf_cap = ov.recommended_confidence_cap

    combined_notes = []
    if ov.mismatch_kind:
        combined_notes.append(f"owner_verification: {ov.mismatch_kind}")
    if sc.signals:
        combined_notes.append(f"succession_signals: {', '.join(sc.signals)}")

    return {
        "owner_verification": {
            "owner_verified": ov.owner_verified,
            "has_pir_data": ov.has_pir_data,
            "mismatch_kind": ov.mismatch_kind,
            "matched_officer": ov.matched_officer,
            "recommended_confidence_cap": ov.recommended_confidence_cap,
            "notes": ov.notes,
        },
        "succession_check": {
            "succession_completed": sc.succession_completed,
            "signals": sc.signals,
            "recommended_tier_cap": sc.recommended_tier_cap,
            "notes": sc.notes,
        },
        "recommended_tier_cap": tier_cap,
        "recommended_confidence_cap": conf_cap,
        "combined_notes": combined_notes,
    }
