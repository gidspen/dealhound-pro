# Scraper Location Slug + Keyword Expansion Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix two bugs in the LandSearch scraper: raw buy box location strings (e.g. "North Carolina near major metros") are passed directly into URLs causing 404s, and LandSearch URL slugs are hardcoded instead of being driven by the buy box `property_types` array.

**Architecture:** Add two pure utility functions (`normalize_location_slug` and `property_types_to_landsearch_slugs`) to `scraper.py`, update `scrape_landsearch()` to accept them as parameters, and thread the values through `run()` and `main()`. Both functions are side-effect-free and fully unit-testable without a browser.

**Tech Stack:** Python 3.12, pytest, existing `read_buy_box()` helper in scraper.py

---

## File Map

| Action | File | What changes |
|--------|------|--------------|
| Modify | `~/.claude/skills/find-deals/scrapers/scraper.py` | Add 2 utility functions; update `scrape_landsearch()`, `run()`, `main()` |
| Create | `~/.claude/skills/find-deals/tests/test_scraper_utils.py` | Unit tests for both utility functions |

---

## Task 1: Add `normalize_location_slug()` + tests

**Files:**
- Modify: `~/.claude/skills/find-deals/scrapers/scraper.py` (after `read_buy_box()`, ~line 80)
- Create: `~/.claude/skills/find-deals/tests/test_scraper_utils.py`

### Context

LandSearch URLs look like `landsearch.com/resort/east-texas` and `landsearch.com/cabin/north-carolina`. The buy box `locations` array contains human-readable strings like `"North Carolina near major metros"` — these go directly into the URL today, producing invalid paths and zero results.

We need a function that strips qualifier phrases and converts to a hyphenated slug.

- [ ] **Step 1: Create the test file with failing tests**

Create `~/.claude/skills/find-deals/tests/test_scraper_utils.py`:

```python
"""Unit tests for scraper utility functions (no browser required)."""
import sys
from pathlib import Path

# Import from scraper.py in the parent scrapers/ directory
sys.path.insert(0, str(Path(__file__).parent.parent / "scrapers"))
from scraper import normalize_location_slug, property_types_to_landsearch_slugs


class TestNormalizeLocationSlug:
    def test_simple_state(self):
        assert normalize_location_slug("texas") == "texas"

    def test_multi_word_state(self):
        assert normalize_location_slug("East Texas") == "east-texas"

    def test_strips_near_major_metros(self):
        assert normalize_location_slug("North Carolina near major metros") == "north-carolina"

    def test_strips_near_major_cities(self):
        assert normalize_location_slug("South Carolina near major cities") == "south-carolina"

    def test_strips_near_metro(self):
        assert normalize_location_slug("Georgia near metro") == "georgia"

    def test_strips_near_metros(self):
        assert normalize_location_slug("Tennessee near metros") == "tennessee"

    def test_already_a_slug(self):
        assert normalize_location_slug("north-carolina") == "north-carolina"

    def test_preserves_existing_hyphens(self):
        # If someone already passed a slug, don't mangle it
        assert normalize_location_slug("east-texas") == "east-texas"

    def test_collapses_extra_spaces(self):
        assert normalize_location_slug("  Texas  ") == "texas"
```

- [ ] **Step 2: Run tests — confirm they all fail**

```bash
cd ~/.claude/skills/find-deals
python3 -m pytest tests/test_scraper_utils.py::TestNormalizeLocationSlug -v 2>&1 | head -30
```

Expected: `ImportError` or `AttributeError: module 'scraper' has no attribute 'normalize_location_slug'`

- [ ] **Step 3: Implement `normalize_location_slug` in scraper.py**

Add immediately after the `read_buy_box()` block (~line 80). The qualifier list must be ordered longest-first so shorter substrings don't partially match before the full phrase is stripped.

```python
# ── Location normalization ────────────────────────────────────────────────────

# Phrases appended to buy box location strings that are meaningless in URLs.
# Order matters: longest first to avoid partial substring matches.
_LOCATION_QUALIFIERS = [
    "near major metros",
    "near major cities",
    "near metros",
    "near metro",
    "near cities",
    "near city",
]


def normalize_location_slug(location: str) -> str:
    """Normalize a raw buy box location string to a LandSearch URL slug.

    Strips qualifier phrases, lowercases, and replaces whitespace with hyphens.

    Examples:
        "East Texas"                        → "east-texas"
        "North Carolina near major metros"  → "north-carolina"
        "texas"                             → "texas"
    """
    loc = location.lower().strip()
    for qualifier in _LOCATION_QUALIFIERS:
        loc = loc.replace(qualifier, "").strip()
    # Collapse any remaining whitespace/underscores into hyphens
    loc = re.sub(r"[\s_]+", "-", loc).strip("-")
    return loc
```

- [ ] **Step 4: Run tests — confirm `TestNormalizeLocationSlug` passes**

```bash
cd ~/.claude/skills/find-deals
python3 -m pytest tests/test_scraper_utils.py::TestNormalizeLocationSlug -v
```

Expected: All 9 tests PASS

- [ ] **Step 5: Commit**

```bash
cd ~/.claude/skills/find-deals
git add scrapers/scraper.py tests/test_scraper_utils.py
git commit -m "feat(scraper): add normalize_location_slug + tests"
```

---

## Task 2: Add `property_types_to_landsearch_slugs()` + tests

**Files:**
- Modify: `~/.claude/skills/find-deals/scrapers/scraper.py` (after `normalize_location_slug`)
- Modify: `~/.claude/skills/find-deals/tests/test_scraper_utils.py` (add new test class)

### Context

`scrape_landsearch()` today hardcodes `slugs = ["resort", "lodge", "cabin"]` regardless of what's in the buy box. A glamping-only buyer should hit `/glamping/`, `/resort/`, `/cabin/` — not `/lodge/` (which has zero glamping inventory on LandSearch). We need a function that maps `property_types` from the buy box to the right slug union.

- [ ] **Step 1: Add failing tests to test file**

Append to `~/.claude/skills/find-deals/tests/test_scraper_utils.py`:

```python
class TestPropertyTypesToLandsearchSlugs:
    def test_micro_resort_default(self):
        result = property_types_to_landsearch_slugs(["micro_resort"])
        assert result == ["resort", "lodge", "cabin"]

    def test_glamping(self):
        result = property_types_to_landsearch_slugs(["glamping"])
        assert result == ["glamping", "resort", "cabin"]

    def test_boutique_hotel(self):
        result = property_types_to_landsearch_slugs(["boutique_hotel"])
        assert result == ["hotel", "lodge", "inn"]

    def test_campground(self):
        result = property_types_to_landsearch_slugs(["campground"])
        assert result == ["campground", "rv-park", "cabin"]

    def test_rv_park(self):
        result = property_types_to_landsearch_slugs(["rv_park"])
        assert result == ["rv-park", "campground"]

    def test_union_micro_resort_and_glamping(self):
        # glamping adds "glamping" at front; resort/lodge/cabin already covered
        result = property_types_to_landsearch_slugs(["micro_resort", "glamping"])
        # resort, lodge, cabin from micro_resort; glamping new, resort/cabin already seen
        assert "resort" in result
        assert "lodge" in result
        assert "cabin" in result
        assert "glamping" in result
        # No duplicates
        assert len(result) == len(set(result))

    def test_empty_list_returns_default(self):
        result = property_types_to_landsearch_slugs([])
        assert result == ["resort", "lodge", "cabin"]

    def test_none_returns_default(self):
        result = property_types_to_landsearch_slugs(None)
        assert result == ["resort", "lodge", "cabin"]

    def test_unknown_type_returns_default(self):
        result = property_types_to_landsearch_slugs(["industrial_park"])
        assert result == ["resort", "lodge", "cabin"]

    def test_no_duplicates_in_output(self):
        # Both micro_resort and campground share "cabin" — should appear once
        result = property_types_to_landsearch_slugs(["micro_resort", "campground"])
        assert result.count("cabin") == 1
```

- [ ] **Step 2: Run tests — confirm new class fails**

```bash
cd ~/.claude/skills/find-deals
python3 -m pytest tests/test_scraper_utils.py::TestPropertyTypesToLandsearchSlugs -v 2>&1 | head -20
```

Expected: `AttributeError: module 'scraper' has no attribute 'property_types_to_landsearch_slugs'`

- [ ] **Step 3: Implement `property_types_to_landsearch_slugs` in scraper.py**

Add immediately after `normalize_location_slug`:

```python
# ── Property type → LandSearch slug mapping ──────────────────────────────────

_PROPERTY_TYPE_SLUGS: dict[str, list[str]] = {
    "micro_resort":   ["resort", "lodge", "cabin"],
    "glamping":       ["glamping", "resort", "cabin"],
    "boutique_hotel": ["hotel", "lodge", "inn"],
    "campground":     ["campground", "rv-park", "cabin"],
    "rv_park":        ["rv-park", "campground"],
}
_DEFAULT_LANDSEARCH_SLUGS = ["resort", "lodge", "cabin"]


def property_types_to_landsearch_slugs(property_types) -> list[str]:
    """Map buy box property_types to a deduplicated list of LandSearch URL slugs.

    Unknown types fall back to the default slug set. If property_types is empty
    or None, returns the defaults (preserves current behavior for existing runs).

    Examples:
        ["micro_resort"]          → ["resort", "lodge", "cabin"]
        ["glamping"]              → ["glamping", "resort", "cabin"]
        ["micro_resort","glamping"] → ["resort", "lodge", "cabin", "glamping"]
        []                        → ["resort", "lodge", "cabin"]
        None                      → ["resort", "lodge", "cabin"]
    """
    if not property_types:
        return list(_DEFAULT_LANDSEARCH_SLUGS)

    seen: set[str] = set()
    result: list[str] = []
    has_known = False

    for pt in property_types:
        pt_key = str(pt).lower().strip()
        slugs = _PROPERTY_TYPE_SLUGS.get(pt_key)
        if slugs:
            has_known = True
            for slug in slugs:
                if slug not in seen:
                    seen.add(slug)
                    result.append(slug)

    # If every type was unknown, fall back to defaults
    if not has_known:
        return list(_DEFAULT_LANDSEARCH_SLUGS)

    return result
```

- [ ] **Step 4: Run all tests — confirm both classes pass**

```bash
cd ~/.claude/skills/find-deals
python3 -m pytest tests/test_scraper_utils.py -v
```

Expected: All 19 tests PASS

- [ ] **Step 5: Commit**

```bash
cd ~/.claude/skills/find-deals
git add scrapers/scraper.py tests/test_scraper_utils.py
git commit -m "feat(scraper): add property_types_to_landsearch_slugs + tests"
```

---

## Task 3: Wire utilities into `scrape_landsearch()`, `run()`, and `main()`

**Files:**
- Modify: `~/.claude/skills/find-deals/scrapers/scraper.py`
  - `scrape_landsearch()` signature + body (~line 679)
  - `run()` signature + landsearch call (~line 1344, 1367)
  - `main()` buy box read + `run()` call (~line 1468, 1487)

### Context

The two utility functions exist but aren't called yet. This task wires them in:
1. `scrape_landsearch()` gets a `slugs` param (defaults to `_DEFAULT_LANDSEARCH_SLUGS`) and normalizes the location before URL construction.
2. `run()` gets a `slugs` param and passes it to the landsearch call.
3. `main()` reads `property_types` from the buy box, computes slugs, and passes to `run()`.

No new tests needed — the behavior is covered by Tasks 1 & 2. A quick smoke check confirms the wiring.

- [ ] **Step 1: Update `scrape_landsearch()` signature and body**

Find this block in `scrape_landsearch()` (line ~696–701):

```python
    listings = []
    slugs = ["resort", "lodge", "cabin"]
    price_qs = f"?minPrice={min_price}&maxPrice={max_price}" if (min_price and max_price) else ""

    for slug in slugs:
        base_url = f"https://www.landsearch.com/{slug}/{location}"
```

Replace with:

```python
    listings = []
    active_slugs = slugs if slugs is not None else _DEFAULT_LANDSEARCH_SLUGS
    normalized_loc = normalize_location_slug(location)
    price_qs = f"?minPrice={min_price}&maxPrice={max_price}" if (min_price and max_price) else ""

    for slug in active_slugs:
        base_url = f"https://www.landsearch.com/{slug}/{normalized_loc}"
```

Also update the function signature from:

```python
def scrape_landsearch(page, location="texas", min_price=None, max_price=None):
```

To:

```python
def scrape_landsearch(page, location="texas", min_price=None, max_price=None, slugs=None):
```

- [ ] **Step 2: Update `run()` signature and landsearch dispatch**

Find `run()` signature (line ~1344):

```python
def run(sites, location, output_dir, headless=DEFAULT_HEADLESS, min_price=None, max_price=None):
```

Change to:

```python
def run(sites, location, output_dir, headless=DEFAULT_HEADLESS, min_price=None, max_price=None, slugs=None):
```

Find the landsearch dispatch block (line ~1367):

```python
            if site == "landsearch" and (min_price or max_price):
                listings = scraper_fn(page, location, min_price=min_price, max_price=max_price)
            else:
                listings = scraper_fn(page, location)
```

Replace with:

```python
            if site == "landsearch":
                kwargs = {}
                if min_price or max_price:
                    kwargs["min_price"] = min_price
                    kwargs["max_price"] = max_price
                if slugs is not None:
                    kwargs["slugs"] = slugs
                listings = scraper_fn(page, location, **kwargs)
            else:
                listings = scraper_fn(page, location)
```

- [ ] **Step 3: Update `main()` to compute slugs and pass to `run()`**

**Important scoping note:** `landsearch_slugs` must be computed unconditionally — both the `--location` CLI path and the buy-box-file path need it. The fix is to always call `read_buy_box()` once upfront, then use it for both location fallback and slug resolution.

Find this block in `main()` (line ~1462):

```python
    # Resolve locations: explicit --location → buy box file → default "texas"
    # Reading from the buy box file avoids bash-quoting issues with multi-word
    # location names like "East Texas" or "North Carolina".
    if args.location is not None:
        locations = [args.location]
    else:
        bb = read_buy_box()
        raw_locations = bb.get("locations") or []
        locations = [str(l).strip() for l in raw_locations if str(l).strip()] or ["texas"]
```

Replace with:

```python
    # Always read the buy box — both paths need property_types for slug expansion.
    # Note: re is already imported at the top of this file.
    bb = read_buy_box()

    # Resolve locations: explicit --location → buy box file → default "texas"
    # Reading from the buy box file avoids bash-quoting issues with multi-word
    # location names like "East Texas" or "North Carolina".
    if args.location is not None:
        locations = [args.location]
    else:
        raw_locations = bb.get("locations") or []
        locations = [str(l).strip() for l in raw_locations if str(l).strip()] or ["texas"]

    # Compute LandSearch slugs from property_types — works for both CLI and buy-box paths.
    landsearch_slugs = property_types_to_landsearch_slugs(bb.get("property_types") or [])
```

Then find the `run()` call inside the location loop (line ~1487):

```python
        loc_results = run(sites, loc, output_dir, headless=headless, min_price=min_price, max_price=max_price)
```

Change to:

```python
        loc_results = run(sites, loc, output_dir, headless=headless, min_price=min_price, max_price=max_price, slugs=landsearch_slugs)
```

Also update the print block (line ~1472) to log the slugs:

```python
    print(f"Locations: {locations}")
    print(f"LandSearch slugs: {landsearch_slugs}")
```

- [ ] **Step 4: Run existing unit tests — confirm nothing regressed**

```bash
cd ~/.claude/skills/find-deals
python3 -m pytest tests/test_scraper_utils.py -v
```

Expected: All 19 tests PASS

- [ ] **Step 5: Smoke-check the wiring with a dry import**

```bash
cd ~/.claude/skills/find-deals/scrapers
python3 -c "
from scraper import normalize_location_slug, property_types_to_landsearch_slugs, scrape_landsearch, run
import inspect

# Confirm scrape_landsearch accepts slugs param
sig = inspect.signature(scrape_landsearch)
assert 'slugs' in sig.parameters, 'slugs param missing from scrape_landsearch'

# Confirm run accepts slugs param
sig2 = inspect.signature(run)
assert 'slugs' in sig2.parameters, 'slugs param missing from run'

# Confirm location normalization works end-to-end
assert normalize_location_slug('North Carolina near major metros') == 'north-carolina'

# Confirm slug mapping works end-to-end
slugs = property_types_to_landsearch_slugs(['micro_resort'])
assert slugs == ['resort', 'lodge', 'cabin'], f'Got: {slugs}'

print('All wiring checks PASSED')
"
```

Expected output: `All wiring checks PASSED`

- [ ] **Step 6: Run provenance gate tests to ensure no regressions**

```bash
cd ~/.claude/skills/find-deals
python3 test_provenance_gate.py
```

Expected: All existing provenance tests pass (same as before this change).

- [ ] **Step 7: Commit**

```bash
cd ~/.claude/skills/find-deals
git add scrapers/scraper.py
git commit -m "feat(scraper): wire location slug normalization and keyword expansion into landsearch"
```

---

## Verification

After all tasks are complete, confirm the fix handles the real-world buy box that caused the zero-listing failure:

```bash
cd ~/.claude/skills/find-deals/scrapers
python3 -c "
from scraper import normalize_location_slug, property_types_to_landsearch_slugs

locations = ['East Texas', 'North Carolina near major metros', 'South Carolina near major metros']
property_types = ['micro_resort']

slugs = property_types_to_landsearch_slugs(property_types)
print('Slugs:', slugs)

for loc in locations:
    norm = normalize_location_slug(loc)
    for slug in slugs:
        print(f'  → landsearch.com/{slug}/{norm}')
"
```

Expected output:
```
Slugs: ['resort', 'lodge', 'cabin']
  → landsearch.com/resort/east-texas
  → landsearch.com/lodge/east-texas
  → landsearch.com/cabin/east-texas
  → landsearch.com/resort/north-carolina
  → landsearch.com/lodge/north-carolina
  → landsearch.com/cabin/north-carolina
  → landsearch.com/resort/south-carolina
  → landsearch.com/lodge/south-carolina
  → landsearch.com/cabin/south-carolina
```

---

## What This Does NOT Fix

- BizBuySell and LoopNet (Akamai-blocked) — separate problem requiring residential proxies
- Crexi and LandWatch (Cloudflare-blocked) — same
- LandSearch returning zero results if there are genuinely no listings in a region (valid outcome)
- LandSearch geo slug accuracy for sub-regions like "East Texas" — LandSearch may not have a dedicated `/east-texas/` path; it may fall back to all-Texas results, which is acceptable behavior
