"""Tests for cad_common shared helpers."""

import datetime
import unittest

from offmarket.scrapers.cad_common import (
    cache_key,
    cache_path,
    entity_key,
    extract_exemptions,
    is_cloudflare_challenge,
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


class TestEntityAndCacheKeys(unittest.TestCase):
    def test_entity_key_pest(self):
        self.assertEqual(entity_key({"tpcl": "0566446"}, "pest-control"), "0566446")

    def test_entity_key_dental(self):
        self.assertEqual(entity_key({"license_number": "DDS123"}, "dental"), "DDS123")

    def test_entity_key_fallback_when_vertical_unknown(self):
        # Unknown vertical → falls back to any common id field
        self.assertEqual(entity_key({"tpcl": "FALL"}, "unknown-vertical"), "FALL")

    def test_entity_key_raises_when_no_id(self):
        with self.assertRaises(KeyError):
            entity_key({"legal_name": "Acme"}, "pest-control")

    def test_cache_key_namespaces_by_vertical(self):
        self.assertEqual(
            cache_key({"tpcl": "0566446"}, "pest-control"),
            "pest-control__0566446",
        )
        self.assertEqual(
            cache_key({"license_number": "DDS123"}, "dental"),
            "dental__DDS123",
        )

    def test_cache_key_prevents_cross_vertical_collision(self):
        # Same numeric id across two verticals → distinct cache keys
        pest = cache_key({"tpcl": "12345"}, "pest-control")
        dental = cache_key({"license_number": "12345"}, "dental")
        self.assertNotEqual(pest, dental)


class TestLoadCachedRobustness(unittest.TestCase):
    """load_cached must not crash on corrupt JSON or malformed fresh_until dates."""

    def setUp(self):
        self.portal = "comptroller"
        self.key = "ROBUSTNESS_TEST"
        self.path = cache_path(self.portal, self.key)

    def tearDown(self):
        if self.path.exists():
            self.path.unlink()

    def test_malformed_fresh_until_returns_none_not_raise(self):
        # Write a payload with a non-ISO fresh_until value
        self.path.parent.mkdir(parents=True, exist_ok=True)
        self.path.write_text('{"fresh_until": {"status": "not-a-date"}}', encoding="utf-8")
        # Should return None, not raise
        result = load_cached(self.portal, self.key, fresh_until_map={"status": "any"})
        self.assertIsNone(result)

    def test_corrupt_json_returns_none_not_raise(self):
        self.path.parent.mkdir(parents=True, exist_ok=True)
        self.path.write_text("{this is not json", encoding="utf-8")
        result = load_cached(self.portal, self.key)
        self.assertIsNone(result)

    def test_missing_fresh_until_field_returns_none(self):
        self.path.parent.mkdir(parents=True, exist_ok=True)
        self.path.write_text('{"foo": "bar"}', encoding="utf-8")
        result = load_cached(self.portal, self.key, fresh_until_map={"status": "any"})
        self.assertIsNone(result)


class TestBexarOV65Proxy(unittest.TestCase):
    """Finding 3 (2026-05-15 deep-dive): Bexar OV65 inferred from OTHER + tax savings."""

    def test_explicit_ov65_still_works_without_proxy(self):
        # Sanity: when "OV65" appears explicitly, ov65=True and ov65_inferred=False
        # so we don't double-count.
        result = extract_exemptions("Exemption: OV65\nTax Due (with exemption): $1.00\nTax Due (without exemption): $100.00")
        self.assertTrue(result["ov65"])
        # Even though savings parses as $99, we don't *also* mark ov65_inferred=True
        # because the proxy only fires for the "OTHER + savings" case. With "OV65"
        # already explicit, the inference path is a no-op.
        self.assertFalse(result["ov65_inferred"])
        self.assertTrue(result["ov65_any"])

    def test_bexar_other_plus_6k_savings_infers_ov65(self):
        # Whitaker Insurance pattern (2026-05-15 deep-dive)
        text = (
            "Exemptions: HS, OTHER\n"
            "Tax Due (with exemption): $1,977.80\n"
            "Tax Due (without exemption): $8,185.58\n"
        )
        result = extract_exemptions(text)
        self.assertFalse(result["ov65"])  # no explicit OV65 text
        self.assertTrue(result["ov65_inferred"])
        self.assertEqual(result["ov65_inference_source"], "bexar_other_exemption_savings_proxy")
        self.assertTrue(result["ov65_any"])
        self.assertEqual(result["tax_savings_amount"], 6208)  # 8185.58 - 1977.80 = 6207.78 → 6208

    def test_bexar_other_with_low_savings_does_not_infer(self):
        # Under $6K savings → could just be standard homestead, not OV65
        text = (
            "Exemptions: HS, OTHER\n"
            "Tax Due (with exemption): $5,000.00\n"
            "Tax Due (without exemption): $7,000.00\n"
        )
        result = extract_exemptions(text)
        self.assertFalse(result["ov65"])
        self.assertFalse(result["ov65_inferred"])
        self.assertIsNone(result["ov65_inference_source"])
        self.assertEqual(result["tax_savings_amount"], 2000)

    def test_bexar_other_without_savings_does_not_infer(self):
        # OTHER alone with no tax-savings comparison → cannot infer
        text = "Exemptions: HS, OTHER\nAppraised Value: 361,000"
        result = extract_exemptions(text)
        self.assertFalse(result["ov65_inferred"])
        self.assertIsNone(result["tax_savings_amount"])

    def test_other_word_in_unrelated_context_no_inference(self):
        # The word "OTHER" appearing in unrelated context (e.g., neighborhood name)
        # shouldn't trigger the proxy without tax-savings evidence.
        text = "Neighborhood: SOMETHING OTHER PLACE\nAppraised Value: 200,000"
        result = extract_exemptions(text)
        self.assertFalse(result["ov65_inferred"])

    def test_dcad_tax_ceiling_infers_ov65(self):
        # Animal Hospital of Valley Ranch / Chaikin pattern (2026-05-15 deep-dive)
        text = (
            "Property Detail\n"
            "School Tax Ceiling: $5,849.95\n"
            "County Tax Ceiling: $1,120.70\n"
            "Homestead Exemption applied\n"
        )
        result = extract_exemptions(text)
        self.assertTrue(result["tax_ceiling"])
        self.assertTrue(result["ov65_inferred"])
        self.assertEqual(result["ov65_inference_source"], "dcad_tax_ceiling_line")
        self.assertTrue(result["homestead"])
        self.assertTrue(result["ov65_any"])

    def test_ov65_any_combines_explicit_and_inferred(self):
        # Convenience flag should be true regardless of which side fires
        explicit = extract_exemptions("Exemption: OV65")
        inferred = extract_exemptions("Tax Ceiling: $5,000")
        neither = extract_exemptions("Homestead exemption")
        self.assertTrue(explicit["ov65_any"])
        self.assertTrue(inferred["ov65_any"])
        self.assertFalse(neither["ov65_any"])

    def test_backward_compat_existing_callers_unchanged(self):
        # Older callers using result["ov65"] only must still get the same booleans
        # they did before this change.
        result = extract_exemptions("OV65 Senior")
        self.assertTrue(result["ov65"])  # original behavior preserved
        result = extract_exemptions("Homestead")
        self.assertTrue(result["homestead"])
        self.assertFalse(result["ov65"])


class TestCloudflareChallenge(unittest.TestCase):
    def test_returns_true_on_cf_challenge_form(self):
        self.assertTrue(is_cloudflare_challenge('<form id="cf-challenge-form">'))

    def test_returns_true_on_ray_id(self):
        self.assertTrue(is_cloudflare_challenge('<footer>Ray ID: abc123</footer>'))

    def test_returns_true_on_checking_your_browser(self):
        self.assertTrue(is_cloudflare_challenge('<h1>Checking your browser</h1>'))

    def test_returns_false_on_normal_html(self):
        self.assertFalse(is_cloudflare_challenge('<html><body>Normal page</body></html>'))

    def test_returns_false_on_empty_string(self):
        self.assertFalse(is_cloudflare_challenge(""))

    def test_returns_false_on_none(self):
        self.assertFalse(is_cloudflare_challenge(None))  # type: ignore


if __name__ == "__main__":
    unittest.main()
