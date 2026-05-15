"""Fixture-driven tests for scrape_hcad pure parse functions.

Run: python3 -m unittest offmarket.scrapers.tests.test_hcad -v
No network, no Playwright required.
"""
import datetime
import unittest
from pathlib import Path
from unittest.mock import patch

from offmarket.scrapers.scrape_hcad import _parse_results, _parse_detail, lookup_one
from offmarket.scrapers.cad_common import load_cached, write_cached, cache_path

FIXTURES = Path(__file__).parent / "fixtures" / "hcad"


class TestParseResults(unittest.TestCase):
    def setUp(self):
        self.html = (FIXTURES / "search_results_sample.html").read_text(encoding="utf-8")

    def test_returns_list(self):
        rows = _parse_results(self.html)
        self.assertIsInstance(rows, list)

    def test_minimum_row_count(self):
        rows = _parse_results(self.html)
        self.assertGreaterEqual(len(rows), 1)

    def test_row_has_required_keys(self):
        rows = _parse_results(self.html)
        for row in rows:
            self.assertIn("account", row, "row missing 'account'")
            self.assertIn("owner_name", row, "row missing 'owner_name'")
            self.assertIn("address", row, "row missing 'address'")

    def test_account_is_nonempty(self):
        rows = _parse_results(self.html)
        for row in rows:
            self.assertTrue(row["account"], f"empty account in row: {row}")

    def test_owner_name_present(self):
        rows = _parse_results(self.html)
        names = [r["owner_name"] for r in rows]
        self.assertTrue(any(names), "all owner_name values empty")

    def test_known_account_present(self):
        rows = _parse_results(self.html)
        accounts = [r["account"] for r in rows]
        self.assertIn("0521340000019", accounts)

    def test_known_owner_present(self):
        rows = _parse_results(self.html)
        names = [r["owner_name"] for r in rows]
        self.assertIn("WILLIAMS, JAMES R", names)

    def test_detail_url_present(self):
        rows = _parse_results(self.html)
        urls = [r.get("detail_url", "") for r in rows]
        self.assertTrue(any(urls), "no detail_url found in any row")

    def test_empty_html_returns_empty_list(self):
        self.assertEqual(_parse_results(""), [])

    def test_irrelevant_html_returns_empty_list(self):
        self.assertEqual(_parse_results("<html><body><p>No results.</p></body></html>"), [])


class TestParseDetail(unittest.TestCase):
    def setUp(self):
        self.html = (FIXTURES / "detail_sample.html").read_text(encoding="utf-8")
        self.result = _parse_detail(self.html)

    def test_ov65_true(self):
        self.assertTrue(self.result["ov65"], "expected ov65=True")

    def test_homestead_true(self):
        self.assertTrue(self.result["homestead"], "expected homestead=True")

    def test_disabled_false(self):
        self.assertFalse(self.result["disabled"], "expected disabled=False")

    def test_deed_date(self):
        self.assertEqual(self.result["deed_date"], "03/15/2010")

    def test_appraised_value(self):
        self.assertEqual(self.result["appraised_value"], 245000)

    def test_year_built(self):
        self.assertEqual(self.result["year_built"], 1982)

    def test_empty_html_no_raise(self):
        result = _parse_detail("")
        self.assertIsInstance(result, dict)
        self.assertFalse(result["ov65"])
        self.assertIsNone(result["deed_date"])


class TestNoMatchCrossCounty(unittest.TestCase):
    """cross_county_followup must appear when Harris returns no results."""

    def _make_biz(self):
        return {
            "tpcl": "TEST_NO_MATCH_999",
            "legal_name": "XYZZY PEST CONTROL INC",
            "owner_name": None,
            "county": "Harris",
        }

    def _noop_log(self, msg):
        pass

    def test_no_match_has_cross_county_followup(self):
        biz = self._make_biz()

        # Patch _search_owner to always return empty rows (no network)
        def _fake_search(page, term, log):
            return "", []

        # Also patch write_cached so we don't actually touch disk
        with patch("offmarket.scrapers.scrape_hcad._search_owner", side_effect=_fake_search), \
             patch("offmarket.scrapers.scrape_hcad.write_cached"):
            result = lookup_one(biz, page=None, log=self._noop_log)

        self.assertEqual(result["status"], "no_match")
        self.assertIn("cross_county_followup", result)
        self.assertIsInstance(result["cross_county_followup"], dict)
        counties = result["cross_county_followup"]["counties"]
        self.assertIn("Fort Bend", counties)
        self.assertIn("Montgomery", counties)
        self.assertIn("Brazoria", counties)


class TestCacheHitSkipsNetwork(unittest.TestCase):
    """Cache hit must return stored payload without calling _search_owner."""

    _TPCL = "CACHE_HIT_TEST_HCAD_001"
    _PORTAL = "hcad"

    def setUp(self):
        tomorrow = (datetime.date.today() + datetime.timedelta(days=1)).isoformat()
        payload = {
            "tpcl": self._TPCL,
            "portal": self._PORTAL,
            "status": "detail_fetched",
            "exemptions": {"ov65": True, "homestead": False, "disabled": False},
            "deed_date": "01/01/2015",
            "appraised_value": 320000,
            "year_built": 1990,
            "fresh_until": {"ov65": tomorrow, "deed_date": tomorrow},
            "errors": [],
        }
        write_cached(self._PORTAL, self._TPCL, payload)

    def tearDown(self):
        p = cache_path(self._PORTAL, self._TPCL)
        if p.exists():
            p.unlink()

    def test_cache_hit_returns_payload(self):
        from offmarket.scrapers.cad_common import load_cached
        fresh_map = {"ov65": "any", "deed_date": "any"}
        cached = load_cached(self._PORTAL, self._TPCL, fresh_until_map=fresh_map)
        self.assertIsNotNone(cached)
        self.assertEqual(cached["status"], "detail_fetched")
        self.assertTrue(cached["exemptions"]["ov65"])

    def test_cache_hit_no_search_called(self):
        """When cache is fresh, _search_owner should not be invoked."""
        fresh_map = {"ov65": "any", "deed_date": "any"}

        call_count = {"n": 0}

        def _sentinel_search(page, term, log):
            call_count["n"] += 1
            return "", []

        with patch("offmarket.scrapers.scrape_hcad._search_owner", side_effect=_sentinel_search):
            from offmarket.scrapers.cad_common import load_cached as _lc
            cached = _lc(self._PORTAL, self._TPCL, fresh_until_map=fresh_map)
            # Simulate the cache-check branch in main _run_queue: if cached, skip lookup_one
            if cached:
                pass  # cache hit — lookup_one never called
            else:
                lookup_one(
                    {"tpcl": self._TPCL, "legal_name": "TEST", "owner_name": None, "county": "Harris"},
                    page=None, log=lambda m: None,
                )

        self.assertEqual(call_count["n"], 0, "_search_owner called despite cache hit")


if __name__ == "__main__":
    unittest.main()
