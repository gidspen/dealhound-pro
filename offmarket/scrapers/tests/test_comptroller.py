"""Tests for the refactored scrape_comptroller.py.

All tests are offline — no network calls.  urllib is mocked throughout.
"""
import json
import unittest
from datetime import date, timedelta
from pathlib import Path
from unittest.mock import MagicMock, patch, call
import tempfile

from offmarket.scrapers.scrape_comptroller import (
    _lookup_one,
    is_sole_proprietor_name,
    normalize,
    parse_pir_html,
    words_compatible,
)
from offmarket.scrapers.cad_common import (
    cache_path,
    load_cached,
    write_cached,
)


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _mock_urlopen(search_payload: dict, detail_payload: dict):
    """Context manager factory: patches urllib.request.urlopen with canned responses."""

    class _FakeResponse:
        def __init__(self, data: bytes):
            self._data = data

        def read(self):
            return self._data

        def __enter__(self):
            return self

        def __exit__(self, *a):
            pass

    def _side_effect(req, timeout=None, context=None):
        # urllib.request.Request objects expose .full_url in Python 3.4+
        url = getattr(req, 'full_url', None) or getattr(req, 'get_full_url', lambda: str(req))()
        # Detail URL: /franchise-tax/{taxpayerId} — no query string, path has 2+ segments
        # after "franchise-tax", OR the URL does NOT contain "?name="
        if "franchise-tax" in url and "?name=" not in url and url.rstrip("/") != "https://comptroller.texas.gov/data-search/franchise-tax":
            return _FakeResponse(json.dumps(detail_payload).encode())
        # Search URL
        return _FakeResponse(json.dumps(search_payload).encode())

    return patch("offmarket.scrapers.scrape_comptroller.urllib.request.urlopen", side_effect=_side_effect)


def _search_response(names: list[str], taxpayer_id: str = "123456789", zip_code: str = "78201") -> dict:
    return {
        "success": True,
        "count": len(names),
        "data": [
            {"name": n, "taxpayerId": taxpayer_id, "mailingAddressZip": zip_code}
            for n in names
        ],
    }


def _detail_response(status: str = "Active", taxpayer_id: str = "123456789") -> dict:
    return {
        "success": True,
        "data": {
            "rightToTransactTX": status,
            "sosRegistrationStatus": "In Existence",
            "sosFileNumber": "0800012345",
            "effectiveSosRegistrationDate": "2005-03-15",
            "registeredAgentName": "Jane Agent",
            "registeredAgentStreet": "100 Main St",
            "registeredAgentCity": "Austin",
            "registeredAgentState": "TX",
            "registeredAgentZip": "78701",
            "mailingAddressStreet": "200 Oak Ave",
            "mailingAddressCity": "San Antonio",
            "mailingAddressZip": "78201",
            "stateOfFormation": "TX",
            "dbaName": None,
        }
    }


def _make_biz(tpcl: str = "TPCL001", legal: str = "Acme Pest Control LLC",
              business_name: str = "Acme Pest", zip_code: str = "78201",
              county: str = "Bexar") -> dict:
    return {
        "tpcl": tpcl,
        "legal_name": legal,
        "business_name_used": business_name,
        "zip": zip_code,
        "county": county,
    }


# ---------------------------------------------------------------------------
# Tests for pure helpers
# ---------------------------------------------------------------------------

class TestNormalize(unittest.TestCase):
    def test_uppercase(self):
        self.assertEqual(normalize("acme pest"), "ACME PEST")

    def test_strips_trailing_llc(self):
        self.assertEqual(normalize("Acme LLC"), "ACME")

    def test_strips_trailing_inc(self):
        self.assertEqual(normalize("Acme Inc"), "ACME")

    def test_does_not_strip_embedded_corp_word(self):
        # "CORPORATION" embedded in a longer word should not be affected
        result = normalize("Acme Pest Control")
        self.assertIn("CONTROL", result)

    def test_replaces_ampersand(self):
        self.assertIn("AND", normalize("A & B Pest"))


class TestIsSoleProp(unittest.TestCase):
    def test_sole_prop_person_name(self):
        self.assertTrue(is_sole_proprietor_name("John Smith"))

    def test_corp_with_llc(self):
        self.assertFalse(is_sole_proprietor_name("Acme Pest LLC"))

    def test_corp_with_inc(self):
        self.assertFalse(is_sole_proprietor_name("Termix Inc"))

    def test_pest_name_is_corp(self):
        self.assertFalse(is_sole_proprietor_name("Best Pest Control"))


class TestWordsCompatible(unittest.TestCase):
    def test_exact_match(self):
        self.assertTrue(words_compatible(["ACME", "PEST"], ["ACME", "PEST", "LLC"]))

    def test_prefix_match(self):
        # words_compatible requires matched >= 2, so test with a 2-word query
        # where one word uses prefix matching
        self.assertTrue(words_compatible(["ACME", "EXTER"], ["ACME", "EXTERMINATORS"]))

    def test_no_match(self):
        self.assertFalse(words_compatible(["ALPHA", "BETA"], ["GAMMA", "DELTA"]))

    def test_one_noise_word_tolerance(self):
        # Allow 1 unmatched word
        self.assertTrue(words_compatible(["ACME", "PEST"], ["ACME", "PEST", "SOLUTIONS"]))


# ---------------------------------------------------------------------------
# Tests for _lookup_one (pure API-call function)
# ---------------------------------------------------------------------------

class TestLookupOne(unittest.TestCase):

    def test_corp_found_returns_status(self):
        biz = _make_biz(legal="Acme Pest Control LLC", business_name="Acme Pest Control")
        search = _search_response(["ACME PEST CONTROL LLC"], taxpayer_id="999000111", zip_code="78201")
        detail = _detail_response(status="Active", taxpayer_id="999000111")
        with _mock_urlopen(search, detail):
            result = _lookup_one(biz)
        self.assertEqual(result["tpcl"], "TPCL001")
        self.assertIsNotNone(result.get("status"))
        self.assertEqual(result["portal"], "comptroller")

    def test_payload_has_required_keys(self):
        biz = _make_biz()
        search = _search_response(["ACME PEST CONTROL LLC"])
        detail = _detail_response()
        with _mock_urlopen(search, detail):
            result = _lookup_one(biz)
        for key in ("tpcl", "portal", "fetched_at", "fresh_until", "raw_term", "owner_match", "errors"):
            self.assertIn(key, result, f"Missing key: {key}")

    def test_fresh_until_status_is_30_days(self):
        biz = _make_biz()
        search = _search_response(["ACME PEST CONTROL LLC"])
        detail = _detail_response()
        with _mock_urlopen(search, detail):
            result = _lookup_one(biz)
        self.assertIn("fresh_until", result)
        self.assertIn("status", result["fresh_until"])
        expected = (date.today() + timedelta(days=30)).isoformat()
        self.assertEqual(result["fresh_until"]["status"], expected)

    def test_not_found_when_no_candidates(self):
        biz = _make_biz(legal="John Smith", business_name="")
        search = {"success": True, "count": 0, "data": []}
        detail = {}
        with _mock_urlopen(search, detail):
            result = _lookup_one(biz)
        self.assertEqual(result["status"], "not_found")
        self.assertIsNone(result["owner_match"])

    def test_api_error_returns_error_status(self):
        biz = _make_biz()
        with patch("offmarket.scrapers.scrape_comptroller._get_json",
                   return_value={"error": "connection_refused"}):
            result = _lookup_one(biz)
        self.assertEqual(result["status"], "error")
        self.assertTrue(len(result["errors"]) > 0)

    def test_zip_preferred_match(self):
        """When multiple candidates exist, prefer the one matching the target zip."""
        biz = _make_biz(zip_code="78201")
        search = {
            "success": True,
            "count": 2,
            "data": [
                {"name": "ACME PEST CONTROL LLC", "taxpayerId": "AAA111", "mailingAddressZip": "90210"},
                {"name": "ACME PEST CONTROL LLC", "taxpayerId": "BBB222", "mailingAddressZip": "78201"},
            ]
        }
        detail = _detail_response(taxpayer_id="BBB222")
        with _mock_urlopen(search, detail):
            result = _lookup_one(biz)
        # The taxpayerId with matching zip should be preferred
        self.assertEqual(result.get("taxpayer_id"), "BBB222")

    def test_portal_field_is_comptroller(self):
        biz = _make_biz()
        search = _search_response(["ACME PEST LLC"])
        detail = _detail_response()
        with _mock_urlopen(search, detail):
            result = _lookup_one(biz)
        self.assertEqual(result["portal"], "comptroller")


# ---------------------------------------------------------------------------
# Cache hit path
# ---------------------------------------------------------------------------

class TestCacheHitPath(unittest.TestCase):
    """Test that the main() orchestration layer uses the cache correctly.

    We test this by directly invoking load_cached / write_cached and checking
    that the cache-first logic works at the cad_common layer.
    """

    def setUp(self):
        self._test_tpcl = "_TEST_COMPT_999"
        self._portal = "comptroller"

    def tearDown(self):
        p = cache_path(self._portal, self._test_tpcl)
        if p.exists():
            p.unlink(missing_ok=True)
        tmp = p.with_suffix(".json.tmp")
        if tmp.exists():
            tmp.unlink(missing_ok=True)

    def test_fresh_cache_returned_without_api_call(self):
        """Writing a fresh cache entry and loading it back should skip the API."""
        tomorrow = (date.today() + timedelta(days=1)).isoformat()
        payload = {
            "tpcl": self._test_tpcl,
            "portal": "comptroller",
            "status": "Active",
            "fetched_at": "2026-05-15T10:00:00+00:00",
            "fresh_until": {"status": tomorrow},
        }
        write_cached(self._portal, self._test_tpcl, payload)

        # load_cached with fresh_until_map should return the payload
        loaded = load_cached(self._portal, self._test_tpcl, fresh_until_map={"status": "any"})
        self.assertIsNotNone(loaded)
        self.assertEqual(loaded["status"], "Active")

    def test_stale_cache_returns_none(self):
        """A cache entry with an expired fresh_until.status should return None."""
        yesterday = (date.today() - timedelta(days=1)).isoformat()
        payload = {
            "tpcl": self._test_tpcl,
            "portal": "comptroller",
            "status": "Active",
            "fetched_at": "2026-05-01T10:00:00+00:00",
            "fresh_until": {"status": yesterday},
        }
        write_cached(self._portal, self._test_tpcl, payload)
        loaded = load_cached(self._portal, self._test_tpcl, fresh_until_map={"status": "any"})
        self.assertIsNone(loaded)

    def test_cache_write_produces_correct_ttl(self):
        """_lookup_one result should embed ~30-day fresh_until.status."""
        biz = {
            "tpcl": self._test_tpcl,
            "legal_name": "Cache Test LLC",
            "business_name_used": "",
            "zip": "78201",
            "county": "Bexar",
        }
        search = _search_response(["CACHE TEST LLC"])
        detail = _detail_response()
        with _mock_urlopen(search, detail):
            result = _lookup_one(biz)
        write_cached(self._portal, self._test_tpcl, result)
        loaded = load_cached(self._portal, self._test_tpcl)
        self.assertIsNotNone(loaded)
        self.assertIn("fresh_until", loaded)
        self.assertIn("status", loaded["fresh_until"])
        expected = (date.today() + timedelta(days=30)).isoformat()
        self.assertEqual(loaded["fresh_until"]["status"], expected)


class TestParsePirHtml(unittest.TestCase):
    """Finding 1 (2026-05-15 deep-dive): extract officer list from Comptroller HTML page."""

    _WHITAKER_HTML = """
    <html><body>
    <h2>Account Status</h2>
    <div>Public Information Report (2024)</div>
    <table>
      <tr><th>Title</th><th>Name</th><th>Address</th></tr>
      <tr><td>PRESIDENT</td><td>CHESTER D WHITAKER</td><td>8626 TESORO DRIVE STE 310, SAN ANTONIO, TX 78217</td></tr>
      <tr><td>VICE PRESIDENT</td><td>GARY D WHITAKER</td><td>8626 TESORO DRIVE STE 310, SAN ANTONIO, TX 78217</td></tr>
      <tr><td>SECRETARY</td><td>LANA P WHITAKER</td><td>8626 TESORO DRIVE STE 310, SAN ANTONIO, TX 78217</td></tr>
    </table>
    </body></html>
    """

    def test_extracts_pir_year(self):
        result = parse_pir_html(self._WHITAKER_HTML)
        self.assertEqual(result["pir_year"], 2024)

    def test_extracts_three_officers(self):
        result = parse_pir_html(self._WHITAKER_HTML)
        self.assertEqual(len(result["officers"]), 3)

    def test_officer_fields(self):
        result = parse_pir_html(self._WHITAKER_HTML)
        first = result["officers"][0]
        self.assertEqual(first["title"], "PRESIDENT")
        self.assertEqual(first["name"], "CHESTER D WHITAKER")
        self.assertIn("8626 TESORO", first["address"])

    def test_alternate_pir_year_format(self):
        html = "<div>PIR 2023</div><table></table>"
        result = parse_pir_html(html)
        self.assertEqual(result["pir_year"], 2023)

    def test_no_pir_returns_empty(self):
        result = parse_pir_html("<html><body><p>nothing here</p></body></html>")
        self.assertIsNone(result["pir_year"])
        self.assertEqual(result["officers"], [])

    def test_empty_html_returns_empty(self):
        result = parse_pir_html("")
        self.assertIsNone(result["pir_year"])
        self.assertEqual(result["officers"], [])

    def test_none_html_returns_empty(self):
        result = parse_pir_html(None)  # type: ignore
        self.assertIsNone(result["pir_year"])
        self.assertEqual(result["officers"], [])

    def test_filters_out_non_officer_rows(self):
        # Random 3-column rows that aren't officer rows should be skipped
        html = """
        <table>
          <tr><th>Header A</th><th>Header B</th><th>Header C</th></tr>
          <tr><td>Some Random Field</td><td>Some Value</td><td>Another Value</td></tr>
          <tr><td>PRESIDENT</td><td>JANE DOE</td><td>1 Main St</td></tr>
          <tr><td>Address Type</td><td>Mailing</td><td>123 Oak</td></tr>
        </table>
        """
        result = parse_pir_html(html)
        self.assertEqual(len(result["officers"]), 1)
        self.assertEqual(result["officers"][0]["name"], "JANE DOE")

    def test_managing_member_recognized_as_officer(self):
        html = """
        <table>
          <tr><td>MANAGING MEMBER</td><td>BOB BUILDER</td><td>500 Oak Rd</td></tr>
        </table>
        """
        result = parse_pir_html(html)
        self.assertEqual(len(result["officers"]), 1)
        self.assertEqual(result["officers"][0]["title"], "MANAGING MEMBER")

    def test_html_entities_decoded(self):
        html = """
        <table>
          <tr><td>PRESIDENT</td><td>JONES &amp; SMITH LLC</td><td>1 Main St&nbsp;Apt 5</td></tr>
        </table>
        """
        result = parse_pir_html(html)
        self.assertEqual(result["officers"][0]["name"], "JONES & SMITH LLC")
        self.assertIn("Apt 5", result["officers"][0]["address"])


if __name__ == "__main__":
    unittest.main()
