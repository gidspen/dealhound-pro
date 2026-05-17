"""Tests for offmarket.scoring_rules — Findings 4 + 5 (2026-05-15 deep-dive)."""

import sys
import unittest
from pathlib import Path

# Make repo root importable
_REPO_ROOT = Path(__file__).resolve().parent.parent.parent
if str(_REPO_ROOT) not in sys.path:
    sys.path.insert(0, str(_REPO_ROOT))

from offmarket.scoring_rules import (  # noqa: E402
    apply_verification_gates,
    detect_succession_completed,
    verify_owner_name,
)


# ---------------------------------------------------------------------------
# Owner-name verification (Finding 5)
# ---------------------------------------------------------------------------

class TestVerifyOwnerName(unittest.TestCase):
    def test_owner_matches_president_control_title(self):
        # Whitaker Insurance pattern — Don Whitaker matches PRESIDENT Chester D Whitaker
        # via last-name match. Token overlap is 1 (WHITAKER) but we also require 2 tokens
        # OR the json owner name is single-token. Don has 2 tokens (DON WHITAKER).
        result = verify_owner_name(
            json_owner_name="Don Whitaker",
            pir_officers=[
                {"title": "PRESIDENT", "name": "CHESTER D WHITAKER", "address": "1 Main St"},
                {"title": "VICE PRESIDENT", "name": "GARY D WHITAKER", "address": "1 Main St"},
            ],
            registered_agent_name="C DON WHITAKER",
        )
        # Don matches via registered agent (DON + WHITAKER in agent tokens)
        self.assertTrue(result.owner_verified)
        self.assertIsNone(result.recommended_confidence_cap)

    def test_fire_safe_pattern_owner_not_found_in_pir(self):
        # Fire Safe: website says Stephen McKinney is President but legal owner is Bruce Burianek
        result = verify_owner_name(
            json_owner_name="Stephen McKinney",
            pir_officers=[
                {"title": "MANAGER", "name": "BRUCE L BURIANEK", "address": "1 Sherwood Way"},
            ],
            registered_agent_name="BRUCE L BURIANEK",
        )
        self.assertFalse(result.owner_verified)
        self.assertEqual(result.mismatch_kind, "not_found_in_pir")
        self.assertEqual(result.recommended_confidence_cap, "low")
        self.assertTrue(any("not found among" in n for n in result.notes))

    def test_perdue_pattern_owner_only_in_non_control_role(self):
        # Perdue: Donald is Founder/President per website but operational control is Cloud family
        # If Donald is listed as DIRECTOR/SECRETARY (non-control) while Brandon Cloud is CEO,
        # we should flag this as succession-in-motion.
        result = verify_owner_name(
            json_owner_name="Donald Perdue",
            pir_officers=[
                {"title": "CEO", "name": "BRANDON CLOUD", "address": "100 Tech Way"},
                {"title": "DIRECTOR", "name": "DONALD PERDUE", "address": "300 Creekside Dr"},
            ],
            registered_agent_name="BRANDON CLOUD",
        )
        self.assertFalse(result.owner_verified)
        self.assertEqual(result.mismatch_kind, "non_control_role_only")
        self.assertEqual(result.recommended_confidence_cap, "low")
        self.assertEqual(result.matched_officer["title"], "DIRECTOR")

    def test_owner_matches_pir_control_title(self):
        # Clean case — JSON owner is also the PIR PRESIDENT
        result = verify_owner_name(
            json_owner_name="Mary Smith",
            pir_officers=[
                {"title": "PRESIDENT", "name": "MARY SMITH", "address": "5 Main St"},
            ],
        )
        self.assertTrue(result.owner_verified)
        self.assertIsNone(result.recommended_confidence_cap)
        self.assertEqual(result.matched_officer["title"], "PRESIDENT")

    def test_no_pir_data_caps_confidence_low(self):
        result = verify_owner_name(
            json_owner_name="Dr. Jane Doe",
            pir_officers=None,
        )
        self.assertFalse(result.owner_verified)
        self.assertEqual(result.mismatch_kind, "no_pir_data")
        self.assertEqual(result.recommended_confidence_cap, "low")

    def test_empty_pir_data_treated_as_no_pir(self):
        result = verify_owner_name(
            json_owner_name="Dr. Jane Doe",
            pir_officers=[],
        )
        self.assertFalse(result.owner_verified)
        self.assertEqual(result.mismatch_kind, "no_pir_data")

    def test_no_json_owner_name_caps_low(self):
        result = verify_owner_name(
            json_owner_name=None,
            pir_officers=[{"title": "PRESIDENT", "name": "JOE BLOGGS", "address": ""}],
        )
        self.assertFalse(result.owner_verified)
        self.assertEqual(result.recommended_confidence_cap, "low")

    def test_credential_suffix_stripped_from_owner_name(self):
        # "Dr. Anne Le, OD" should match an officer named "ANNE H LE" by last-name + first-name
        result = verify_owner_name(
            json_owner_name="Dr. Anne Le, OD",
            pir_officers=[{"title": "PRESIDENT", "name": "ANNE H LE", "address": ""}],
        )
        self.assertTrue(result.owner_verified)

    def test_managing_member_counts_as_control(self):
        result = verify_owner_name(
            json_owner_name="Tom Hanks",
            pir_officers=[{"title": "MANAGING MEMBER", "name": "TOM HANKS", "address": ""}],
        )
        self.assertTrue(result.owner_verified)
        self.assertEqual(result.matched_officer["title"], "MANAGING MEMBER")


# ---------------------------------------------------------------------------
# Succession-completed detection (Finding 4)
# ---------------------------------------------------------------------------

class TestSuccessionDetection(unittest.TestCase):
    def test_two_co_directors_different_addresses_different_surnames_fires(self):
        # Bellaire Optometry pattern — Le + Nguyen as co-PRESIDENTs at separate residences
        result = detect_succession_completed(
            json_owner_name="Dr. Anne Le",
            pir_officers=[
                {"title": "PRESIDENT", "name": "ANNE H LE", "address": "100 Bellaire Blvd, Houston TX"},
                {"title": "PRESIDENT", "name": "JOHN NGUYEN", "address": "500 Memorial Dr, Houston TX"},
            ],
        )
        self.assertTrue(result.succession_completed)
        self.assertIn(
            "pir_multi_control_officers_different_addresses_different_surnames",
            result.signals,
        )
        self.assertEqual(result.recommended_tier_cap, "C_watch")

    def test_same_family_multi_officer_does_not_fire(self):
        # Whitaker pattern — 3 Whitakers at same address = family-owned, NOT exit
        result = detect_succession_completed(
            json_owner_name="Don Whitaker",
            pir_officers=[
                {"title": "PRESIDENT", "name": "CHESTER D WHITAKER", "address": "1 Main St, SA TX"},
                {"title": "VICE PRESIDENT", "name": "GARY D WHITAKER", "address": "1 Main St, SA TX"},
                {"title": "SECRETARY", "name": "LANA P WHITAKER", "address": "1 Main St, SA TX"},
            ],
        )
        # Multiple same-surname officers AND same address → not succession-in-motion
        self.assertFalse(result.succession_completed)

    def test_founder_absent_from_team_page_fires(self):
        result = detect_succession_completed(
            json_owner_name="Dr. Bob Wilson",
            pir_officers=[],
            team_page={
                "founder_present": False,
                "team_members": [
                    {"name": "DR. CASSANDRA ERICKSON", "title": "CHIEF OF STAFF"},
                    {"name": "DR. JANE SMITH", "title": "ASSOCIATE VET"},
                ],
            },
        )
        self.assertTrue(result.succession_completed)
        self.assertIn("founder_absent_from_team_page", result.signals)

    def test_founder_surname_not_on_team_page_fires(self):
        # Auto-detect when founder_present flag isn't set but surname is missing
        result = detect_succession_completed(
            json_owner_name="Dr. Bob Wilson",
            pir_officers=[],
            team_page={
                "team_members": [
                    {"name": "DR. CASSANDRA ERICKSON", "title": "CHIEF OF STAFF"},
                    {"name": "DR. JANE SMITH", "title": "ASSOCIATE VET"},
                ],
            },
        )
        self.assertTrue(result.succession_completed)
        self.assertIn("founder_surname_not_on_team_page", result.signals)

    def test_non_family_chief_of_staff_fires(self):
        # Colleyville Animal Clinic pattern
        result = detect_succession_completed(
            json_owner_name="Dr. Mark Wilson",
            pir_officers=[],
            team_page={
                "chief_of_staff_name": "Dr. Cassandra Erickson",
                "team_members": [
                    {"name": "DR. MARK WILSON", "title": "FOUNDER"},
                    {"name": "DR. CASSANDRA ERICKSON", "title": "CHIEF OF STAFF"},
                ],
            },
        )
        self.assertTrue(result.succession_completed)
        self.assertIn("non_family_chief_of_staff", result.signals)

    def test_recent_grad_alone_does_not_fire(self):
        # Single recent-grad alone is NOT enough — needs to combine with another signal
        result = detect_succession_completed(
            json_owner_name="Dr. Jane Smith",
            pir_officers=[],
            license_issue_dates=["2024-06-15"],
            current_year=2026,
        )
        self.assertFalse(result.succession_completed)

    def test_two_recent_grads_fires(self):
        # 2+ recent grads = clear "planned internal buy-in" pattern
        result = detect_succession_completed(
            json_owner_name="Dr. Jane Smith",
            pir_officers=[],
            license_issue_dates=["2024-06-15", "2023-08-01"],
            current_year=2026,
        )
        self.assertTrue(result.succession_completed)
        self.assertTrue(any("recent_grad_associate_count" in s for s in result.signals))

    def test_recent_grad_amplifies_other_signal(self):
        # 1 recent grad + non-family chief = clearer succession pattern
        result = detect_succession_completed(
            json_owner_name="Dr. Founder",
            pir_officers=[],
            team_page={
                "chief_of_staff_name": "Dr. Newcomer",
            },
            license_issue_dates=["2024-06-15"],
            current_year=2026,
        )
        self.assertTrue(result.succession_completed)
        self.assertEqual(result.recommended_tier_cap, "C_watch")

    def test_no_signals_returns_no_succession(self):
        result = detect_succession_completed(
            json_owner_name="Dr. Jane Smith",
            pir_officers=[
                {"title": "PRESIDENT", "name": "JANE SMITH", "address": "1 Main St"},
            ],
            team_page={
                "team_members": [{"name": "DR. JANE SMITH", "title": "FOUNDER"}],
                "founder_present": True,
            },
        )
        self.assertFalse(result.succession_completed)
        self.assertIsNone(result.recommended_tier_cap)


# ---------------------------------------------------------------------------
# Combined gate application
# ---------------------------------------------------------------------------

class TestApplyVerificationGates(unittest.TestCase):
    def test_clean_case_no_caps(self):
        business = {"owner_name": "Mary Smith"}
        comptroller = {
            "registered_agent_name": "MARY SMITH",
            "pir_officers": [
                {"title": "PRESIDENT", "name": "MARY SMITH", "address": "1 Main St"},
            ],
        }
        result = apply_verification_gates(business, comptroller)
        self.assertTrue(result["owner_verification"]["owner_verified"])
        self.assertFalse(result["succession_check"]["succession_completed"])
        self.assertIsNone(result["recommended_tier_cap"])
        self.assertIsNone(result["recommended_confidence_cap"])

    def test_fire_safe_pattern_caps_confidence(self):
        business = {"owner_name": "Stephen McKinney"}
        comptroller = {
            "registered_agent_name": "BRUCE L BURIANEK",
            "pir_officers": [
                {"title": "MANAGER", "name": "BRUCE L BURIANEK", "address": "1 Sherwood Way"},
            ],
        }
        result = apply_verification_gates(business, comptroller)
        self.assertFalse(result["owner_verification"]["owner_verified"])
        self.assertEqual(result["recommended_confidence_cap"], "low")
        self.assertIn("owner_verification: not_found_in_pir", result["combined_notes"])

    def test_bellaire_pattern_succession_caps_tier(self):
        business = {"owner_name": "Dr. Anne Le"}
        comptroller = {
            "pir_officers": [
                {"title": "PRESIDENT", "name": "ANNE H LE", "address": "100 Bellaire, Houston"},
                {"title": "PRESIDENT", "name": "JOHN NGUYEN", "address": "500 Memorial, Houston"},
            ],
        }
        result = apply_verification_gates(business, comptroller)
        self.assertTrue(result["succession_check"]["succession_completed"])
        self.assertEqual(result["recommended_tier_cap"], "C_watch")

    def test_missing_comptroller_returns_low_confidence(self):
        business = {"owner_name": "Dr. Jane Doe"}
        result = apply_verification_gates(business, None)
        # No PIR data → owner_verification caps confidence at low
        self.assertEqual(result["recommended_confidence_cap"], "low")


if __name__ == "__main__":
    unittest.main()
