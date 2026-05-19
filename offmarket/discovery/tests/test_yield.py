"""
End-to-end yield regression test.

Runs the full discovery pipeline against a known buy box and asserts a minimum
matched-listings threshold. Skips when ANTHROPIC_API_KEY is unset (CI without a key).

Live test — costs ~$1 per run (discovery + generic extraction across ~15 sources).
Marked `slow` so it stays out of default test runs.
"""
from __future__ import annotations

import os
import sys
import pytest

REPO_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))


@pytest.mark.slow
def test_yield_minimum_listings_for_rv_parks_tx(tmp_path, monkeypatch):
    if not os.environ.get("ANTHROPIC_API_KEY"):
        pytest.skip("ANTHROPIC_API_KEY not set")

    monkeypatch.chdir(REPO_ROOT)
    if REPO_ROOT not in sys.path:
        sys.path.insert(0, REPO_ROOT)

    from offmarket.discovery.run import run

    output = tmp_path / "discovered_listings.json"

    matched = run([
        "--buy-box", "data/buy_box_rv_parks_tx.json",
        "--output", str(output),
        "--no-persist",
        "--min-sources", "5",  # discovery floor for this test; pinned still runs
    ])

    assert isinstance(matched, list)
    assert len(matched) >= 30, f"Expected ≥30 matched listings, got {len(matched)}"
    assert output.exists()
