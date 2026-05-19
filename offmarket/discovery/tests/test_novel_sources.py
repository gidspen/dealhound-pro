"""Live churn test: second run with seed_known excluded still finds novel sources.

Proves discovery is live (not a cached static list) and asset-class-aware:
threshold for "how many new sources must we find" comes from
fixtures/expected_churn.json, keyed by asset_type.
"""
from __future__ import annotations

import json
import os
from pathlib import Path

import pytest

pytestmark = pytest.mark.skipif(
    not os.environ.get("ANTHROPIC_API_KEY"),
    reason="ANTHROPIC_API_KEY not set; skipping live discovery test.",
)


REPO_ROOT = Path(__file__).resolve().parents[3]
BUY_BOX_PATH = REPO_ROOT / "data" / "buy_box_rv_parks_tx.json"
CHURN_FIXTURE = Path(__file__).parent / "fixtures" / "expected_churn.json"


def _load_churn_thresholds() -> dict:
    if not CHURN_FIXTURE.exists():
        return {}
    try:
        return json.loads(CHURN_FIXTURE.read_text())
    except Exception:
        return {}


def test_second_run_finds_novel_sources():
    from offmarket.discovery.source_discovery import discover_sources

    buy_box = json.loads(BUY_BOX_PATH.read_text())
    asset_types = buy_box.get("asset_types") or []

    churn = _load_churn_thresholds()
    thresholds = []
    for at in asset_types:
        entry = churn.get(at, {})
        thresholds.append(int(entry.get("weekly_min_new", 1)))
    threshold = max(thresholds) if thresholds else 1

    r1 = discover_sources(buy_box)
    assert r1, "First run returned no candidates — discovery broken upstream."

    seed = [c.url for c in r1]
    r2 = discover_sources(buy_box, seed_known=seed)

    r1_urls = {c.url.lower().rstrip("/") for c in r1}
    novel = [c for c in r2 if c.url.lower().rstrip("/") not in r1_urls]

    assert len(r2) >= threshold, (
        f"Second run returned only {len(r2)} candidates "
        f"(threshold={threshold} for asset_types={asset_types}). "
        "Discovery may be returning a static list."
    )
    assert len(novel) >= threshold, (
        f"Second run found only {len(novel)} URLs not in first run "
        f"(threshold={threshold}). Discovery is not truly live — "
        "results overlap too much with the first run."
    )
