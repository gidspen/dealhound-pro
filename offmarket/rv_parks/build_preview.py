"""Build a self-contained preview HTML with data embedded inline.

Run after offmarket.rv_parks.run to produce a single .html file the user
can open directly in any browser (no server, no fetch).
"""
from __future__ import annotations

import json
from pathlib import Path


def build() -> Path:
    here = Path(__file__).parent
    data = json.loads((here / "data" / "poc_leads.json").read_text())
    template = (here / "preview.html").read_text()

    # Replace the fetch with inline data
    inline_script = (
        f"async function loadLeads() {{\n"
        f"  const data = {json.dumps(data)};\n"
    )
    rebuilt = template.replace(
        "async function loadLeads() {\n  const data = await fetch('data/poc_leads.json').then(r => r.json());\n",
        inline_script,
    )

    out = here / "preview-standalone.html"
    out.write_text(rebuilt)
    return out


if __name__ == "__main__":
    p = build()
    print(f"Wrote {p}")
    print(f"Size: {p.stat().st_size:,} bytes")
