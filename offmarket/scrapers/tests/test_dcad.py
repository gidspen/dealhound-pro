"""Fixture-driven unit tests for scrape_dcad.py pure parse functions.

No network access — all tests load HTML from disk and call pure functions.
Run from the repo root:
    python3 -m unittest offmarket.scrapers.tests.test_dcad -v
"""
import sys
import unittest
from pathlib import Path

# Ensure repo root is on sys.path when running directly
_REPO_ROOT = Path(__file__).resolve().parent.parent.parent.parent
if str(_REPO_ROOT) not in sys.path:
    sys.path.insert(0, str(_REPO_ROOT))

from offmarket.scrapers.scrape_dcad import (
    CROSS_COUNTY_FALLBACK,
    _make_no_match_result,
    _parse_detail_text,
    _parse_results,
)
from offmarket.scrapers.cad_common import extract_exemptions

_FIXTURES = Path(__file__).parent / "fixtures" / "dcad"


def _load(filename: str) -> str:
    return (_FIXTURES / filename).read_text(encoding="utf-8")


class TestParseResults(unittest.TestCase):
    """_parse_results scopes to the DCAD GridView, not nav/sidebar tables."""

    def setUp(self):
        self.html = _load("search_results_sample.html")
        self.rows = _parse_results(self.html)

    def test_returns_expected_row_count(self):
        """Fixture contains 3 data rows."""
        self.assertEqual(len(self.rows), 3)

    def test_first_row_account_number(self):
        """Account number is extracted from the anchor text in the first cell."""
        self.assertEqual(self.rows[0]["account_no"], "00000123456789")

    def test_first_row_owner_name(self):
        self.assertEqual(self.rows[0]["owner_name"], "FINCANNON DAVID W")

    def test_first_row_situs_address(self):
        self.assertIn("1234 OAK GROVE", self.rows[0]["situs_address"])

    def test_second_row_account_number(self):
        self.assertEqual(self.rows[1]["account_no"], "00000987654321")

    def test_second_row_owner_name(self):
        self.assertEqual(self.rows[1]["owner_name"], "FINCANNON DAVID R")

    def test_third_row_account_number(self):
        self.assertEqual(self.rows[2]["account_no"], "00000555555555")

    def test_detail_links_present(self):
        """Each row must carry a detail_link pointing to AcctDetail pages."""
        for row in self.rows:
            self.assertIsNotNone(row.get("detail_link"), f"Missing detail_link in row: {row}")
            self.assertIn("AcctDetail", row["detail_link"])

    def test_no_nav_rows_included(self):
        """Navigation/sidebar table rows must not appear in results."""
        all_texts = " ".join(
            " ".join(r.get("raw_cells", [])) for r in self.rows
        ).upper()
        self.assertNotIn("HOME", all_texts)
        self.assertNotIn("QUICK LINKS", all_texts)

    def test_returns_list_of_dicts(self):
        for row in self.rows:
            self.assertIsInstance(row, dict)
            self.assertIn("account_no", row)
            self.assertIn("owner_name", row)
            self.assertIn("situs_address", row)


class TestParseResultsNoMatch(unittest.TestCase):
    """_parse_results on a no-match page returns an empty list."""

    def test_no_match_returns_empty_list(self):
        html = _load("one_no_match.html")
        rows = _parse_results(html)
        self.assertEqual(rows, [])

    def test_no_match_is_list_type(self):
        html = _load("one_no_match.html")
        rows = _parse_results(html)
        self.assertIsInstance(rows, list)


class TestParseDetailText(unittest.TestCase):
    """_parse_detail_text on the detail fixture extracts correct exemption fields."""

    def setUp(self):
        html = _load("detail_sample.html")
        # _parse_detail_text takes innerText, not raw HTML.
        # Simulate browser innerText by stripping tags with a simple approach:
        # Extract visible text from the HTML using html.parser.
        from html.parser import HTMLParser

        class _TextExtractor(HTMLParser):
            def __init__(self):
                super().__init__()
                self.chunks = []
                self._skip = False

            def handle_starttag(self, tag, attrs):
                if tag in ("script", "style"):
                    self._skip = True

            def handle_endtag(self, tag):
                if tag in ("script", "style"):
                    self._skip = False
                if tag in ("td", "th", "tr", "p", "div", "br"):
                    self.chunks.append("\n")

            def handle_data(self, data):
                if not self._skip:
                    stripped = data.strip()
                    if stripped:
                        self.chunks.append(stripped)

        extractor = _TextExtractor()
        extractor.feed(html)
        self.text = " ".join(extractor.chunks)
        self.result = _parse_detail_text(self.text)

    def test_ov65_detected(self):
        self.assertTrue(self.result["ov65"], "OV65 exemption should be detected")

    def test_homestead_detected(self):
        self.assertTrue(self.result["homestead"], "Homestead exemption should be detected")

    def test_hs_exempt_variant_detected(self):
        """HS EXEMPT token (separate from GEN HS) must also trigger homestead=True."""
        text = "Exemption Type: HS EXEMPT  Dallas County  $40,000"
        r = _parse_detail_text(text)
        self.assertTrue(r["homestead"])

    def test_gen_hs_variant_detected(self):
        """GEN HS token must trigger homestead=True."""
        text = "GEN HS  Dallas County  $40,000"
        r = _parse_detail_text(text)
        self.assertTrue(r["homestead"])

    def test_disabled_not_set_in_fixture(self):
        self.assertFalse(self.result["disabled"])

    def test_deed_date_extracted(self):
        self.assertEqual(self.result["deed_date"], "06/14/2003")

    def test_appraised_value_extracted(self):
        self.assertEqual(self.result["appraised_value"], 263500)

    def test_year_built_extracted(self):
        self.assertEqual(self.result["year_built"], 1978)

    def test_page_text_sample_present(self):
        sample = self.result.get("page_text_sample", "")
        self.assertIsInstance(sample, str)
        self.assertGreater(len(sample), 0)


class TestCrossCountyFollowup(unittest.TestCase):
    """cross_county_followup is set to the 4 fallback counties on no-match."""

    def test_no_match_result_has_cross_county_followup(self):
        result = _make_no_match_result(
            tpcl="12345",
            legal_name="ACME PEST CONTROL",
            owner_name="John Smith",
            searches=[{"term": "Smith John", "rows": 0, "err": None}],
        )
        self.assertEqual(result["status"], "no_match")
        self.assertIn("cross_county_followup", result)
        self.assertIsInstance(result["cross_county_followup"], list)

    def test_cross_county_fallback_counties(self):
        result = _make_no_match_result("12345", "ACME", "John", [])
        counties = result["cross_county_followup"]
        self.assertIn("Collin", counties)
        self.assertIn("Denton", counties)
        self.assertIn("Tarrant", counties)
        self.assertIn("Rockwall", counties)

    def test_cross_county_fallback_count(self):
        result = _make_no_match_result("12345", "ACME", "John", [])
        self.assertEqual(len(result["cross_county_followup"]), 4)

    def test_cross_county_constant_matches_result(self):
        """CROSS_COUNTY_FALLBACK constant is what gets embedded in no-match results."""
        result = _make_no_match_result("12345", "ACME", "John", [])
        self.assertEqual(result["cross_county_followup"], CROSS_COUNTY_FALLBACK)


class TestExtractExemptionsIntegration(unittest.TestCase):
    """Verify cad_common.extract_exemptions handles DCAD-specific tokens end-to-end."""

    def test_hs_exempt_token(self):
        result = extract_exemptions("Exemption Type: HS EXEMPT  Dallas County")
        self.assertTrue(result["homestead"])
        self.assertFalse(result["ov65"])

    def test_gen_hs_token(self):
        result = extract_exemptions("GEN HS  City of Dallas  $40,000")
        self.assertTrue(result["homestead"])

    def test_ov65_token_standalone(self):
        result = extract_exemptions("OV65  Dallas County  $10,000")
        self.assertTrue(result["ov65"])

    def test_combined_ov65_and_hs_exempt(self):
        text = (
            "GEN HS  Dallas County  $40,000\n"
            "HS EXEMPT  City of Dallas  $40,000\n"
            "OV65  Dallas County  $10,000\n"
        )
        result = extract_exemptions(text)
        self.assertTrue(result["ov65"])
        self.assertTrue(result["homestead"])

    def test_deed_date_in_dcad_format(self):
        """DCAD deed dates appear as MM/DD/YYYY in a Deed Date table row."""
        text = "Deed Date\nDeed Type\n06/14/2003\nWD\nPREVIOUS OWNER"
        result = extract_exemptions(text)
        self.assertEqual(result["deed_date"], "06/14/2003")

    def test_appraised_value_with_dollar_sign(self):
        """DCAD value tables include a dollar-sign prefix; ensure it strips cleanly."""
        text = "Appraised Value\n$263,500"
        result = extract_exemptions(text)
        self.assertEqual(result["appraised_value"], 263500)

    def test_no_exemptions_returns_false_flags(self):
        text = "Property Details\nYear Built: 1978\nLiving Area: 1842"
        result = extract_exemptions(text)
        self.assertFalse(result["ov65"])
        self.assertFalse(result["homestead"])
        self.assertFalse(result["disabled"])


if __name__ == "__main__":
    unittest.main()
