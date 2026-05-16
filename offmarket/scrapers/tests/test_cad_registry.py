"""Tests for cad_registry — bimodal CAD classification + alternative paths."""

import unittest

from offmarket.scrapers.cad_registry import (
    CAD_REGISTRY,
    get_alt_paths,
    get_cad_status,
    is_blocked,
)


class TestCadStatus(unittest.TestCase):
    def test_works_counties(self):
        self.assertEqual(get_cad_status("dallas"), "works")
        self.assertEqual(get_cad_status("bexar"), "works")

    def test_blocked_by_law(self):
        # Harris is masked by Texas law (residential owner-age info hidden)
        self.assertEqual(get_cad_status("harris"), "blocked_by_law")

    def test_blocked_spa(self):
        # Tarrant, Hays, Fort Bend, Williamson all SPA-blocked per deep-dive findings
        self.assertEqual(get_cad_status("tarrant"), "blocked_spa")
        self.assertEqual(get_cad_status("hays"), "blocked_spa")
        self.assertEqual(get_cad_status("fort_bend"), "blocked_spa")
        self.assertEqual(get_cad_status("williamson"), "blocked_spa")

    def test_untested_counties(self):
        self.assertEqual(get_cad_status("travis"), "untested")
        self.assertEqual(get_cad_status("collin"), "untested")

    def test_unknown_county_returns_untested(self):
        # Counties not in registry should default to "untested" so caller can skip
        self.assertEqual(get_cad_status("podunk"), "untested")
        self.assertEqual(get_cad_status(""), "untested")
        self.assertEqual(get_cad_status(None), "untested")  # type: ignore

    def test_county_normalization(self):
        # Should be case-insensitive and whitespace-tolerant
        self.assertEqual(get_cad_status("HARRIS"), "blocked_by_law")
        self.assertEqual(get_cad_status(" dallas "), "works")
        self.assertEqual(get_cad_status("Bexar"), "works")


class TestAltPaths(unittest.TestCase):
    def test_works_counties_have_no_alt_paths(self):
        # No fallback needed when primary works
        self.assertEqual(get_alt_paths("dallas"), [])
        self.assertEqual(get_alt_paths("bexar"), [])

    def test_harris_alt_paths_priority_order(self):
        paths = get_alt_paths("harris")
        self.assertGreater(len(paths), 0)
        # First path should be the unrestricted public-records option
        strategies = [p["strategy"] for p in paths]
        self.assertIn("harris_county_clerk_deed_records", strategies)
        # Voter file should be present but flagged as restricted
        self.assertIn("tx_voter_file", strategies)
        # County-clerk deed records should be FIRST (lowest compliance overhead)
        self.assertEqual(paths[0]["strategy"], "harris_county_clerk_deed_records")

    def test_tarrant_alt_paths_include_county_clerk(self):
        paths = get_alt_paths("tarrant")
        strategies = [p["strategy"] for p in paths]
        self.assertIn("tarrant_county_clerk_deed_records", strategies)

    def test_alt_paths_have_required_fields(self):
        # Every alt-path entry should have strategy + url + yield_estimate + rationale
        for county, entry in CAD_REGISTRY.items():
            for alt in entry.get("alt_paths", []):
                self.assertIn("strategy", alt, f"{county}: missing strategy")
                self.assertIn("yield_estimate", alt, f"{county}: missing yield_estimate")
                self.assertIn("rationale", alt, f"{county}: missing rationale")

    def test_unknown_county_returns_empty_alt_paths(self):
        self.assertEqual(get_alt_paths("nowhere"), [])
        self.assertEqual(get_alt_paths(""), [])


class TestIsBlocked(unittest.TestCase):
    def test_works_counties_not_blocked(self):
        self.assertFalse(is_blocked("dallas"))
        self.assertFalse(is_blocked("bexar"))

    def test_spa_blocked_counties_blocked(self):
        self.assertTrue(is_blocked("tarrant"))
        self.assertTrue(is_blocked("hays"))
        self.assertTrue(is_blocked("fort_bend"))
        self.assertTrue(is_blocked("williamson"))

    def test_law_blocked_counties_blocked(self):
        self.assertTrue(is_blocked("harris"))

    def test_untested_not_blocked(self):
        # Untested != blocked — we just haven't probed yet
        self.assertFalse(is_blocked("travis"))


class TestRegistryStructure(unittest.TestCase):
    """The CAD_REGISTRY is a load-bearing reference — guard its shape."""

    def test_every_entry_has_required_keys(self):
        required = {"portal_name", "url", "status", "scraper_module", "notes", "alt_paths"}
        for county, entry in CAD_REGISTRY.items():
            missing = required - set(entry.keys())
            self.assertFalse(
                missing,
                f"county={county} missing required keys: {missing}",
            )

    def test_status_values_are_valid(self):
        valid_statuses = {"works", "blocked_spa", "blocked_by_law", "untested"}
        for county, entry in CAD_REGISTRY.items():
            self.assertIn(
                entry["status"], valid_statuses,
                f"county={county} has invalid status={entry['status']!r}",
            )

    def test_works_counties_have_scraper_modules(self):
        # If a CAD is marked "works", it must point to a real scraper
        for county, entry in CAD_REGISTRY.items():
            if entry["status"] == "works":
                self.assertIsNotNone(
                    entry["scraper_module"],
                    f"works-county {county} missing scraper_module",
                )

    def test_blocked_counties_have_alt_paths(self):
        # Blocked counties MUST have at least one alternative-path strategy
        for county, entry in CAD_REGISTRY.items():
            if entry["status"] in ("blocked_spa", "blocked_by_law"):
                self.assertGreater(
                    len(entry["alt_paths"]), 0,
                    f"blocked county {county} has no alt_paths",
                )


if __name__ == "__main__":
    unittest.main()
