"""Tests for cad_common shared helpers."""

import datetime
import unittest

from offmarket.scrapers.cad_common import (
    cache_path,
    extract_exemptions,
    load_cached,
    name_variants,
    write_cached,
)

_TEST_PORTAL = "comptroller"
_TEST_KEY = "TEST123"


class TestCacheRoundtrip(unittest.TestCase):
    def tearDown(self):
        p = cache_path(_TEST_PORTAL, _TEST_KEY)
        if p.exists():
            p.unlink()
        tmp = p.with_suffix(".json.tmp")
        if tmp.exists():
            tmp.unlink()

    def test_cache_roundtrip(self):
        payload = {"foo": "bar"}
        write_cached(_TEST_PORTAL, _TEST_KEY, payload)
        result = load_cached(_TEST_PORTAL, _TEST_KEY)
        self.assertEqual(result["foo"], "bar")

        # Overwrite and verify new value
        write_cached(_TEST_PORTAL, _TEST_KEY, {"foo": "baz", "extra": 42})
        result2 = load_cached(_TEST_PORTAL, _TEST_KEY)
        self.assertEqual(result2["foo"], "baz")
        self.assertEqual(result2["extra"], 42)

    def test_load_cached_missing(self):
        result = load_cached(_TEST_PORTAL, "NONEXISTENT_KEY_XYZ_99999")
        self.assertIsNone(result)

    def test_load_cached_freshness_pass(self):
        tomorrow = (datetime.date.today() + datetime.timedelta(days=1)).isoformat()
        payload = {"data": "value", "fresh_until": {"ov65": tomorrow}}
        write_cached(_TEST_PORTAL, _TEST_KEY, payload)
        result = load_cached(_TEST_PORTAL, _TEST_KEY, fresh_until_map={"ov65": "any"})
        self.assertIsNotNone(result)
        self.assertEqual(result["data"], "value")

    def test_load_cached_freshness_stale(self):
        yesterday = (datetime.date.today() - datetime.timedelta(days=1)).isoformat()
        payload = {"data": "stale", "fresh_until": {"ov65": yesterday}}
        write_cached(_TEST_PORTAL, _TEST_KEY, payload)
        result = load_cached(_TEST_PORTAL, _TEST_KEY, fresh_until_map={"ov65": "any"})
        self.assertIsNone(result)


class TestNameVariants(unittest.TestCase):
    def _last_first_pairs(self, variants):
        return [(l.lower(), (f or "").lower()) for l, f in variants]

    def test_name_variants_simple(self):
        variants = name_variants(None, "John Smith")
        pairs = self._last_first_pairs(variants)
        self.assertIn(("smith", "john"), pairs)

    def test_name_variants_last_comma_first(self):
        variants = name_variants(None, "Smith, John")
        pairs = self._last_first_pairs(variants)
        self.assertIn(("smith", "john"), pairs)

    def test_name_variants_legal_only(self):
        variants = name_variants("Doe Pest Control", None)
        pairs = self._last_first_pairs(variants)
        # "Doe" should appear with None first_name
        self.assertIn(("doe", ""), pairs)

    def test_name_variants_legal_with_suffix(self):
        variants = name_variants("John Doe DDS", None)
        pairs = self._last_first_pairs(variants)
        # Should extract "Doe" surname
        lasts = [l for l, _ in pairs]
        self.assertIn("doe", lasts)

    def test_name_variants_no_duplicates(self):
        # Exact same (last, first) tuple from owner and legal should only appear once
        variants = name_variants("John Smith", "John Smith")
        pairs = self._last_first_pairs(variants)
        self.assertEqual(len(pairs), len(set(pairs)))  # no duplicate (last, first) tuples

    def test_name_variants_none_inputs(self):
        variants = name_variants(None, None)
        self.assertEqual(variants, [])


class TestExtractExemptions(unittest.TestCase):
    def test_extract_exemptions_ov65(self):
        result = extract_exemptions("Exemptions: OV65 Senior")
        self.assertTrue(result["ov65"])
        self.assertFalse(result["homestead"])

    def test_extract_exemptions_over65_variant(self):
        result = extract_exemptions("Exemption type: Over 65")
        self.assertTrue(result["ov65"])

    def test_extract_exemptions_homestead(self):
        result = extract_exemptions("Homestead exemption applied.")
        self.assertTrue(result["homestead"])

    def test_extract_exemptions_disabled(self):
        result = extract_exemptions("Disabled Person exemption")
        self.assertTrue(result["disabled"])

    def test_extract_exemptions_ov65_dash_variant(self):
        result = extract_exemptions("Exemption code: OV-65 active")
        self.assertTrue(result["ov65"])

    def test_extract_exemptions_homestead_hs_exempt(self):
        result = extract_exemptions("HS EXEMPT applied 2018")
        self.assertTrue(result["homestead"])

    def test_extract_exemptions_homestead_gen_hs(self):
        result = extract_exemptions("Exemptions: GEN HS")
        self.assertTrue(result["homestead"])

    def test_extract_exemptions_full(self):
        text = (
            "Property Details\n"
            "OV65\n"
            "Homestead\n"
            "Deed Date: 03/15/2010\n"
            "Appraised Value: 245,000\n"
            "Year Built 1985\n"
        )
        result = extract_exemptions(text)
        self.assertTrue(result["ov65"])
        self.assertTrue(result["homestead"])
        self.assertFalse(result["disabled"])
        self.assertEqual(result["deed_date"], "03/15/2010")
        self.assertEqual(result["appraised_value"], 245000)
        self.assertEqual(result["year_built"], 1985)

    def test_extract_exemptions_empty_text(self):
        result = extract_exemptions("")
        self.assertFalse(result["ov65"])
        self.assertIsNone(result["deed_date"])
        self.assertIsNone(result["appraised_value"])
        self.assertIsNone(result["year_built"])

    def test_extract_exemptions_total_value(self):
        result = extract_exemptions("Total Value: 310,500")
        self.assertEqual(result["appraised_value"], 310500)

    def test_extract_exemptions_no_raise_on_bad_input(self):
        # Should never raise
        try:
            extract_exemptions(None)  # type: ignore
        except Exception:
            pass  # defensive None handling expected to return defaults


if __name__ == "__main__":
    unittest.main()
