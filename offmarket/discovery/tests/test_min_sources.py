"""Live smoke test: discover_sources returns >= 15 candidates with variety."""
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
BUY_BOX_PATH = REPO_ROOT / "data" / "buy_box_hospitality_national.json"


def test_min_sources_hospitality_national():
    from offmarket.discovery.source_discovery import discover_sources

    buy_box = json.loads(BUY_BOX_PATH.read_text())

    result = discover_sources(buy_box, min_count=15)

    assert len(result) >= 15, (
        f"Expected >= 15 candidates, got {len(result)}: "
        f"{[c.url for c in result]}"
    )

    for c in result:
        assert c.url.startswith("https://"), f"non-https URL: {c.url}"
        assert c.name and c.name.strip(), f"empty name for {c.url}"

    kinds = {c.kind for c in result}
    assert "marketplace" in kinds, (
        f"Expected at least one marketplace, got kinds={kinds}. "
        "Discovery is broker-only — not catching niche marketplaces."
    )
