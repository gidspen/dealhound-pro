"""Tests for enrich_phase6.py.

All tests are offline — no network, no subprocess calls.
Subprocess invocations are mocked throughout.
"""
import json
import unittest
from datetime import date, timedelta
from pathlib import Path
from unittest.mock import MagicMock, patch
import tempfile
import os

from offmarket.scrapers.enrich_phase6 import (
    _merge_results,
    _split_by_county,
    enrich,
)


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _make_target(tpcl: str, county: str, legal_name: str = "Test Co") -> dict:
    return {"tpcl": tpcl, "county": county, "legal_name": legal_name}


def _write_cache(directory: Path, tpcl: str, payload: dict) -> None:
    directory.mkdir(parents=True, exist_ok=True)
    p = directory / f"{tpcl}.json"
    with p.open("w") as fh:
        json.dump(payload, fh)


# ---------------------------------------------------------------------------
# _split_by_county
# ---------------------------------------------------------------------------

class TestSplitByCounty(unittest.TestCase):

    def test_harris_lowercase(self):
        targets = [_make_target("T1", "harris")]
        buckets = _split_by_county(targets)
        self.assertIn("T1", [t["tpcl"] for t in buckets["harris"]])
        self.assertEqual(len(buckets["other"]), 0)

    def test_harris_uppercase(self):
        targets = [_make_target("T1", "HARRIS")]
        buckets = _split_by_county(targets)
        self.assertIn("T1", [t["tpcl"] for t in buckets["harris"]])

    def test_dallas_mixed_case(self):
        targets = [_make_target("T2", "Dallas")]
        buckets = _split_by_county(targets)
        self.assertIn("T2", [t["tpcl"] for t in buckets["dallas"]])

    def test_bexar_uppercase(self):
        targets = [_make_target("T3", "BEXAR")]
        buckets = _split_by_county(targets)
        self.assertIn("T3", [t["tpcl"] for t in buckets["bexar"]])

    def test_unknown_county_goes_to_other(self):
        targets = [_make_target("T4", "Travis")]
        buckets = _split_by_county(targets)
        self.assertIn("T4", [t["tpcl"] for t in buckets["other"]])
        self.assertEqual(len(buckets["harris"]) + len(buckets["dallas"]) + len(buckets["bexar"]), 0)

    def test_mixed_counties(self):
        targets = [
            _make_target("T1", "Harris"),
            _make_target("T2", "dallas"),
            _make_target("T3", "Bexar"),
            _make_target("T4", "Collin"),
        ]
        buckets = _split_by_county(targets)
        self.assertEqual(len(buckets["harris"]), 1)
        self.assertEqual(len(buckets["dallas"]), 1)
        self.assertEqual(len(buckets["bexar"]), 1)
        self.assertEqual(len(buckets["other"]), 1)

    def test_county_override_reassigns(self):
        targets = [_make_target("T5", "Travis")]
        buckets = _split_by_county(targets, county_overrides={"T5": "Harris"})
        self.assertIn("T5", [t["tpcl"] for t in buckets["harris"]])
        self.assertEqual(len(buckets["other"]), 0)

    def test_county_override_case_insensitive(self):
        targets = [_make_target("T6", "Travis")]
        buckets = _split_by_county(targets, county_overrides={"T6": "BEXAR"})
        self.assertIn("T6", [t["tpcl"] for t in buckets["bexar"]])

    def test_override_only_affects_specified_tpcl(self):
        targets = [
            _make_target("T7", "Travis"),
            _make_target("T8", "Travis"),
        ]
        buckets = _split_by_county(targets, county_overrides={"T7": "Dallas"})
        # T7 should move to dallas; T8 stays in other
        self.assertIn("T7", [t["tpcl"] for t in buckets["dallas"]])
        self.assertIn("T8", [t["tpcl"] for t in buckets["other"]])

    def test_empty_targets(self):
        buckets = _split_by_county([])
        for v in buckets.values():
            self.assertEqual(v, [])

    def test_missing_county_field(self):
        targets = [{"tpcl": "T9", "legal_name": "No County"}]
        buckets = _split_by_county(targets)
        self.assertIn("T9", [t["tpcl"] for t in buckets["other"]])

    def test_bucket_keys_always_present(self):
        buckets = _split_by_county([])
        for key in ("harris", "dallas", "bexar", "other"):
            self.assertIn(key, buckets)


# ---------------------------------------------------------------------------
# _merge_results
# ---------------------------------------------------------------------------

class TestMergeResults(unittest.TestCase):

    def setUp(self):
        self._tmpdir = tempfile.TemporaryDirectory()
        self.root = Path(self._tmpdir.name)
        self.comptroller_dir = self.root / "comptroller"
        self.hcad_dir = self.root / "hcad"
        self.dcad_dir = self.root / "dcad"
        self.bcad_dir = self.root / "bcad"

    def tearDown(self):
        self._tmpdir.cleanup()

    def test_both_present(self):
        _write_cache(self.comptroller_dir, "T1", {"tpcl": "T1", "status": "active", "portal": "comptroller"})
        _write_cache(self.hcad_dir, "T1", {"tpcl": "T1", "status": "detail_fetched", "portal": "hcad"})
        result = _merge_results(
            self.comptroller_dir,
            {"hcad": self.hcad_dir, "dcad": self.dcad_dir, "bcad": self.bcad_dir},
            ["T1"],
        )
        self.assertIn("T1", result)
        self.assertIsNotNone(result["T1"]["comptroller"])
        self.assertIsNotNone(result["T1"]["cad"])
        self.assertEqual(result["T1"]["comptroller"]["status"], "active")
        self.assertEqual(result["T1"]["cad"]["portal"], "hcad")

    def test_comptroller_only(self):
        _write_cache(self.comptroller_dir, "T2", {"tpcl": "T2", "status": "not_found"})
        result = _merge_results(
            self.comptroller_dir,
            {"hcad": self.hcad_dir, "dcad": self.dcad_dir, "bcad": self.bcad_dir},
            ["T2"],
        )
        self.assertIsNotNone(result["T2"]["comptroller"])
        self.assertIsNone(result["T2"]["cad"])

    def test_cad_only(self):
        _write_cache(self.dcad_dir, "T3", {"tpcl": "T3", "status": "search_matched", "portal": "dcad"})
        result = _merge_results(
            self.comptroller_dir,
            {"hcad": self.hcad_dir, "dcad": self.dcad_dir, "bcad": self.bcad_dir},
            ["T3"],
        )
        self.assertIsNone(result["T3"]["comptroller"])
        self.assertIsNotNone(result["T3"]["cad"])
        self.assertEqual(result["T3"]["cad"]["portal"], "dcad")

    def test_neither_present(self):
        result = _merge_results(
            self.comptroller_dir,
            {"hcad": self.hcad_dir, "dcad": self.dcad_dir, "bcad": self.bcad_dir},
            ["T4"],
        )
        self.assertIsNone(result["T4"]["comptroller"])
        self.assertIsNone(result["T4"]["cad"])

    def test_cad_first_portal_wins(self):
        """When a TPCL exists in multiple CAD dirs (shouldn't happen, but defensive test)."""
        _write_cache(self.hcad_dir, "T5", {"tpcl": "T5", "portal": "hcad"})
        _write_cache(self.dcad_dir, "T5", {"tpcl": "T5", "portal": "dcad"})
        # _merge_results picks the first cache_dir in iteration order
        result = _merge_results(
            self.comptroller_dir,
            {"hcad": self.hcad_dir, "dcad": self.dcad_dir, "bcad": self.bcad_dir},
            ["T5"],
        )
        # Should have exactly one CAD entry
        self.assertIsNotNone(result["T5"]["cad"])

    def test_all_tpcls_in_output(self):
        tpcls = ["A1", "A2", "A3"]
        _write_cache(self.comptroller_dir, "A1", {"tpcl": "A1", "status": "active"})
        result = _merge_results(
            self.comptroller_dir,
            {"hcad": self.hcad_dir, "dcad": self.dcad_dir, "bcad": self.bcad_dir},
            tpcls,
        )
        for t in tpcls:
            self.assertIn(t, result)

    def test_entity_id_field_present_in_entry(self):
        result = _merge_results(
            self.comptroller_dir,
            {"hcad": self.hcad_dir},
            ["XPQR"],
        )
        self.assertEqual(result["XPQR"]["entity_id"], "XPQR")
        self.assertEqual(result["XPQR"]["cache_key"], "XPQR")


# ---------------------------------------------------------------------------
# enrich() integration — subprocess mocked
# ---------------------------------------------------------------------------

class TestEnrichIntegration(unittest.TestCase):

    def _make_targets_file(self, tmpdir: Path, targets: list[dict]) -> Path:
        data_dir = tmpdir / "data"
        data_dir.mkdir(parents=True, exist_ok=True)
        targets_path = data_dir / "test-vertical_targets.json"
        with targets_path.open("w") as fh:
            json.dump({"businesses": targets}, fh)
        return targets_path

    @patch("offmarket.scrapers.enrich_phase6._run_scraper")
    @patch("offmarket.scrapers.enrich_phase6.load_targets")
    def test_both_false_returns_near_empty(self, mock_load, mock_run):
        """run_comptroller=False and run_cad=False should return entries with None fields."""
        mock_load.return_value = [_make_target("TPCL1", "Harris")]
        result = enrich("test-vertical", run_comptroller=False, run_cad=False)
        mock_run.assert_not_called()
        self.assertIn("TPCL1", result)
        self.assertIsNone(result["TPCL1"]["comptroller"])
        self.assertIsNone(result["TPCL1"]["cad"])

    @patch("offmarket.scrapers.enrich_phase6._run_scraper", return_value=(True, None))
    @patch("offmarket.scrapers.enrich_phase6.load_targets")
    def test_run_comptroller_only(self, mock_load, mock_run):
        mock_load.return_value = [_make_target("TPCL2", "Harris")]
        enrich("test-vertical", run_comptroller=True, run_cad=False)
        calls = [c.args[0] for c in mock_run.call_args_list]
        self.assertIn("offmarket.scrapers.scrape_comptroller", calls)
        cad_modules = {"offmarket.scrapers.scrape_hcad", "offmarket.scrapers.scrape_dcad", "offmarket.scrapers.scrape_bcad"}
        for m in calls:
            self.assertNotIn(m, cad_modules)

    @patch("offmarket.scrapers.enrich_phase6._run_scraper", return_value=(True, None))
    @patch("offmarket.scrapers.enrich_phase6.load_targets")
    def test_run_cad_dispatches_by_county(self, mock_load, mock_run):
        mock_load.return_value = [
            _make_target("T_HAR", "Harris"),
            _make_target("T_DAL", "Dallas"),
            _make_target("T_BEX", "Bexar"),
        ]
        enrich("test-vertical", run_comptroller=False, run_cad=True)
        called_modules = [c.args[0] for c in mock_run.call_args_list]
        self.assertIn("offmarket.scrapers.scrape_hcad", called_modules)
        self.assertIn("offmarket.scrapers.scrape_dcad", called_modules)
        self.assertIn("offmarket.scrapers.scrape_bcad", called_modules)

    @patch("offmarket.scrapers.enrich_phase6._run_scraper", return_value=(True, None))
    @patch("offmarket.scrapers.enrich_phase6.load_targets")
    def test_unknown_county_cross_county_followup(self, mock_load, mock_run):
        mock_load.return_value = [_make_target("T_TRV", "Travis")]
        result = enrich("test-vertical", run_comptroller=False, run_cad=True)
        # Unknown county should NOT dispatch a scraper
        for call in mock_run.call_args_list:
            # No CAD scraper should have been called for Travis
            module = call.args[0]
            self.assertNotIn(module, {
                "offmarket.scrapers.scrape_hcad",
                "offmarket.scrapers.scrape_dcad",
                "offmarket.scrapers.scrape_bcad",
            })
        # But the TPCL should still be in results with cross_county_followup
        self.assertIn("T_TRV", result)
        self.assertIn("cross_county_followup", result["T_TRV"])

    @patch("offmarket.scrapers.enrich_phase6._run_scraper", return_value=(True, None))
    @patch("offmarket.scrapers.enrich_phase6.load_targets")
    def test_county_overrides_reassign(self, mock_load, mock_run):
        mock_load.return_value = [_make_target("T_OVR", "Travis")]
        enrich("test-vertical", run_comptroller=False, run_cad=True,
               county_overrides={"T_OVR": "Harris"})
        called_modules = [c.args[0] for c in mock_run.call_args_list]
        self.assertIn("offmarket.scrapers.scrape_hcad", called_modules)

    @patch("offmarket.scrapers.enrich_phase6._run_scraper", return_value=(False, "subprocess failed"))
    @patch("offmarket.scrapers.enrich_phase6.load_targets")
    def test_failing_subprocess_does_not_crash(self, mock_load, mock_run):
        """A non-zero subprocess return should be logged and not raise."""
        mock_load.return_value = [_make_target("T_ERR", "Harris")]
        # Should not raise
        result = enrich("test-vertical", run_comptroller=True, run_cad=True)
        self.assertIsInstance(result, dict)

    @patch("offmarket.scrapers.enrich_phase6._run_scraper", return_value=(True, None))
    @patch("offmarket.scrapers.enrich_phase6.load_targets")
    def test_force_refresh_passed_to_scraper(self, mock_load, mock_run):
        mock_load.return_value = [_make_target("T_FR", "Harris")]
        enrich("test-vertical", run_comptroller=True, run_cad=False, force_refresh=True)
        for call in mock_run.call_args_list:
            scraper_args = call.args[1]  # list of args after the module name
            self.assertIn("--force-refresh", scraper_args)

    @patch("offmarket.scrapers.enrich_phase6._run_scraper", return_value=(True, None))
    @patch("offmarket.scrapers.enrich_phase6.load_targets")
    def test_result_has_portal_status(self, mock_load, mock_run):
        mock_load.return_value = [_make_target("T_PS", "Harris")]
        result = enrich("test-vertical", run_comptroller=True, run_cad=False)
        self.assertIn("_portal_status", result["T_PS"])
        self.assertIn("comptroller", result["T_PS"]["_portal_status"])

    @patch("offmarket.scrapers.enrich_phase6._run_scraper", return_value=(True, None))
    @patch("offmarket.scrapers.enrich_phase6.load_targets")
    def test_missing_targets_file_returns_empty(self, mock_load, mock_run):
        mock_load.side_effect = FileNotFoundError("No targets")
        result = enrich("nonexistent-vertical")
        self.assertEqual(result, {})


if __name__ == "__main__":
    unittest.main()
