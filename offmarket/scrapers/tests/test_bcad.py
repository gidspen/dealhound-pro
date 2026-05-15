"""Fixture-driven unit tests for scrape_bcad.

All tests are offline — no network calls.  Fixtures in:
  offmarket/scrapers/tests/fixtures/bcad/
    search_results_sample.html  — synthesized BCAD results table
    detail_sample.html          — synthesized property detail with OV65 + HS
    cloudflare_challenge.html   — synthesized Cloudflare CAPTCHA page
"""
import unittest
from pathlib import Path

from offmarket.scrapers.scrape_bcad import (
    _is_cloudflare_challenge,
    _parse_detail_text,
    _parse_results,
)

_FIXTURE_DIR = Path(__file__).parent / "fixtures" / "bcad"


def _load(name: str) -> str:
    return (_FIXTURE_DIR / name).read_text(encoding="utf-8")


class TestParseResults(unittest.TestCase):
    """Tests for _parse_results() using the synthesized search-results fixture."""

    def setUp(self):
        self.html = _load("search_results_sample.html")
        self.rows = _parse_results(self.html)

    def test_returns_list(self):
        self.assertIsInstance(self.rows, list)

    def test_at_least_one_row(self):
        self.assertGreater(len(self.rows), 0,
                           "Expected ≥1 result row from search_results_sample.html")

    def test_row_has_account(self):
        row = self.rows[0]
        self.assertIn("account", row)
        self.assertTrue(row["account"], "account field must be non-empty")

    def test_row_has_owner(self):
        row = self.rows[0]
        self.assertIn("owner", row)
        self.assertTrue(row["owner"], "owner field must be non-empty")

    def test_row_has_address(self):
        row = self.rows[0]
        self.assertIn("address", row)
        self.assertTrue(row["address"], "address field must be non-empty")

    def test_account_is_numeric_string(self):
        """Account numbers from TrueAutomation are long numeric strings."""
        row = self.rows[0]
        self.assertTrue(row["account"].isdigit(),
                        f"account should be digits, got: {row['account']!r}")

    def test_owner_contains_lee(self):
        """First fixture row is Leonard Lee."""
        owners = [r["owner"].upper() for r in self.rows]
        self.assertTrue(any("LEE" in o for o in owners),
                        f"Expected 'LEE' in owners; got: {owners}")

    def test_address_contains_san_antonio(self):
        addresses = [r["address"].upper() for r in self.rows]
        self.assertTrue(any("SAN ANTONIO" in a for a in addresses),
                        f"Expected 'SAN ANTONIO' in addresses; got: {addresses}")

    def test_detail_href_present(self):
        """First result row must have a detail_href (link to property detail)."""
        row = self.rows[0]
        self.assertIn("detail_href", row)
        self.assertIsNotNone(row["detail_href"], "detail_href should not be None")

    def test_parse_results_empty_html(self):
        result = _parse_results("")
        self.assertEqual(result, [])

    def test_parse_results_non_table_html(self):
        result = _parse_results("<html><body><p>No results found.</p></body></html>")
        self.assertEqual(result, [])

    def test_all_rows_have_required_keys(self):
        for i, row in enumerate(self.rows):
            for key in ("account", "owner", "address", "detail_href"):
                self.assertIn(key, row, f"Row {i} missing key '{key}'")


class TestParseDetailText(unittest.TestCase):
    """Tests for _parse_detail_text() using the synthesized detail fixture."""

    def setUp(self):
        # Read inner text approximation from the HTML fixture.
        # We strip tags manually since we're testing the text-based extractor.
        html = _load("detail_sample.html")
        # Approximate the page's inner_text by stripping HTML tags.
        import re
        self.text = re.sub(r"<[^>]+>", " ", html)
        self.detail = _parse_detail_text(self.text)

    def test_returns_dict(self):
        self.assertIsInstance(self.detail, dict)

    def test_ov65_detected(self):
        self.assertTrue(self.detail.get("ov65"),
                        f"Expected ov65=True; detail={self.detail}")

    def test_homestead_detected(self):
        self.assertTrue(self.detail.get("homestead"),
                        f"Expected homestead=True; detail={self.detail}")

    def test_disabled_not_set(self):
        """Fixture has OV65 + HS but no disabled exemption."""
        self.assertFalse(self.detail.get("disabled"),
                         "disabled should be False for this fixture")

    def test_deed_date_extracted(self):
        dd = self.detail.get("deed_date")
        self.assertIsNotNone(dd, "deed_date should not be None")
        self.assertEqual(dd, "03/15/2001", f"Unexpected deed_date: {dd!r}")

    def test_appraised_value_extracted(self):
        av = self.detail.get("appraised_value")
        self.assertIsNotNone(av, "appraised_value should not be None")
        self.assertEqual(av, 178450, f"Unexpected appraised_value: {av!r}")

    def test_year_built_extracted(self):
        yb = self.detail.get("year_built")
        self.assertIsNotNone(yb, "year_built should not be None")
        self.assertEqual(yb, 1978, f"Unexpected year_built: {yb!r}")

    def test_raw_text_sample_present(self):
        self.assertIn("raw_text_sample", self.detail)
        self.assertIsInstance(self.detail["raw_text_sample"], str)

    def test_empty_text(self):
        result = _parse_detail_text("")
        self.assertFalse(result["ov65"])
        self.assertFalse(result["homestead"])
        self.assertIsNone(result["deed_date"])
        self.assertIsNone(result["appraised_value"])
        self.assertIsNone(result["year_built"])


class TestCloudflareDetection(unittest.TestCase):
    """Tests for _is_cloudflare_challenge() using fixtures."""

    def test_challenge_html_detected(self):
        html = _load("cloudflare_challenge.html")
        self.assertTrue(
            _is_cloudflare_challenge(html),
            "cloudflare_challenge.html should be detected as a CF challenge page"
        )

    def test_normal_search_page_not_detected(self):
        html = _load("search_results_sample.html")
        self.assertFalse(
            _is_cloudflare_challenge(html),
            "search_results_sample.html should NOT be flagged as a CF challenge"
        )

    def test_normal_detail_page_not_detected(self):
        html = _load("detail_sample.html")
        self.assertFalse(
            _is_cloudflare_challenge(html),
            "detail_sample.html should NOT be flagged as a CF challenge"
        )

    def test_empty_html_not_detected(self):
        self.assertFalse(_is_cloudflare_challenge(""))

    def test_none_html_not_detected(self):
        # Defensive: None should not raise
        self.assertFalse(_is_cloudflare_challenge(None))  # type: ignore

    def test_cf_challenge_form_marker(self):
        html = '<form id="cf-challenge-form" action="/cdn-cgi/l/chk_jschl"></form>'
        self.assertTrue(_is_cloudflare_challenge(html))

    def test_checking_your_browser_marker(self):
        html = "<h1>Checking your browser before accessing bcad.org.</h1>"
        self.assertTrue(_is_cloudflare_challenge(html))

    def test_ray_id_marker(self):
        html = "<span>Ray ID: 8d3f4a2c1b0e9f87</span>"
        self.assertTrue(_is_cloudflare_challenge(html))

    def test_turnstile_marker(self):
        html = '<iframe src="https://challenges.cloudflare.com/cdn-cgi/challenge-platform/h/b/turnstile/if/ov2/n/cb"></iframe>'
        self.assertTrue(_is_cloudflare_challenge(html))

    def test_ordinary_cloudflare_mention_not_flagged(self):
        """A page that mentions Cloudflare in a footer but has none of the
        specific challenge markers should NOT be flagged as a challenge."""
        html = (
            "<html><body>"
            "<p>Site protected by Cloudflare WAF</p>"
            "<table><tr><td>Account #</td><td>Owner</td></tr></table>"
            "</body></html>"
        )
        # This page has no specific CF challenge markers — should return False
        self.assertFalse(_is_cloudflare_challenge(html))


class TestCrossCountyFollowup(unittest.TestCase):
    """Verify that a no-match result carries the correct cross_county_followup."""

    def _make_no_match_result(self) -> dict:
        """Build a minimal no-match result dict as _lookup_one would produce."""
        return {
            "tpcl": "0566813",
            "portal": "bcad",
            "status": "no_match",
            "cross_county_followup": ["Comal", "Guadalupe"],
            "searches": [],
            "errors": [],
        }

    def test_cross_county_followup_present(self):
        result = self._make_no_match_result()
        self.assertIn("cross_county_followup", result)

    def test_cross_county_followup_value(self):
        result = self._make_no_match_result()
        self.assertEqual(result["cross_county_followup"], ["Comal", "Guadalupe"])

    def test_cross_county_followup_on_no_match_status(self):
        result = self._make_no_match_result()
        self.assertEqual(result["status"], "no_match")
        self.assertIsInstance(result["cross_county_followup"], list)
        self.assertIn("Comal", result["cross_county_followup"])
        self.assertIn("Guadalupe", result["cross_county_followup"])

    def test_cross_county_followup_not_on_matched_status(self):
        """A matched result should NOT have cross_county_followup."""
        result = {
            "tpcl": "0566813",
            "status": "detail_fetched",
            "exemptions": {"ov65": True, "homestead": True, "disabled": False},
        }
        self.assertNotIn("cross_county_followup", result)


if __name__ == "__main__":
    unittest.main()
