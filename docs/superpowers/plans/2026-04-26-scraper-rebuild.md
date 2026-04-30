# Scraper Rebuild: Railway + ScraperAPI + Claude Extraction

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rebuild the DealHound scraper to match the /find-deals skill's quality — Claude reads pages instead of CSS selectors, conservative filtering (null = pass with flag), cross-source deduplication, and Opus mitigations.

**Architecture:** Railway-hosted Playwright fetches pages through ScraperAPI residential proxy (bypasses Cloudflare/Akamai). Claude Sonnet extracts structured listing data from page text (universal — works on any site, no per-site selectors). Shared listing pool in Supabase — one daily scrape serves all users. Vercel handles orchestration, filtering, and scoring.

**Tech Stack:** Python 3.12 / FastAPI / Playwright (Railway), ScraperAPI residential proxy, Anthropic Claude API (Sonnet for extraction + classification, Opus for mitigations), Supabase (PostgreSQL), Node.js / Vercel serverless functions.

---

## File Structure

### Critical conventions
- **All `api/` files use CommonJS** (`require` / `module.exports`). Do NOT use ESM `import`/`export` in any runtime API file. Tests under `tests/` can use ESM (vitest handles it).
- **Existing `scraper-service/` files use synchronous Playwright.** New async code requires converting `server.py`'s `/scrape` handler to `async def` (FastAPI supports this natively).
- **Vercel serverless: never respond before work is done.** Once `res.json()` fires, execution may terminate. Always `await` all work, then respond.

### New files
| File | Responsibility |
|------|---------------|
| `scraper-service/claude_extract.py` | Universal listing extractor — sends page text to Sonnet, returns structured listings |
| `scraper-service/test_claude_extract.py` | Tests for extraction module |
| `api/_lib/process-listings.js` | Shared filter + score + Supabase write logic (used by both scan-pipeline.js and scan-continue.js) |
| `api/scan-continue.js` | Webhook endpoint — Railway calls this when scraping completes. Reads raw listings from Supabase (scraper writes them), runs filtering + scoring via process-listings.js. **Uses CommonJS.** |
| `api/cron/daily-scan.js` | Daily cron — triggers shared pool scrape across all active locations. **Uses CommonJS.** |
| `tests/integration/filters.test.js` | Tests for null-safe filtering + dedup |
| `tests/fixtures/` | Saved page text from each site for extraction testing |

### Modified files
| File | What changes |
|------|-------------|
| `scraper-service/scraper.py` | Add ScraperAPI proxy config, add universal `scrape_site_with_claude()` (async), keep LandSearch native scraper (sync) |
| `scraper-service/server.py` | Convert `/scrape` to `async def`. Accept `sites` array + `search_id`. Add Supabase client — scraper writes raw listings + progress directly to DB. POST only `search_id` to callback (not listings in body — idempotent). |
| `scraper-service/requirements.txt` | Add `anthropic`, `supabase` |
| `scraper-service/Dockerfile` | Add `claude_extract.py` to COPY |
| `api/_lib/scrape.js` | Pass `sites` array + `search_id` + `callback_url` to scraper. CommonJS. |
| `api/_lib/filters.js` | Null-safe filtering, three-tier cross-source dedup (in-memory before Supabase insert — address field not stored in DB), STR market viability |
| `api/_lib/score.js` | Opus for mitigations (model swap), false-negative protection prompt, batch size 25 |
| `api/_lib/discover.js` | Return `sites` array to pipeline (currently discarded) |
| `api/scan-pipeline.js` | Refactor: extract filter+score+write into `_lib/process-listings.js`. Pass sites to scraper. |
| `vercel.json` | Add `scan-continue.js` + `cron/daily-scan.js` function configs + cron schedule |

---

## Task 1: Claude Extraction Module

Build the universal listing extractor that replaces CSS selectors.

**Files:**
- Create: `scraper-service/claude_extract.py`
- Create: `scraper-service/test_claude_extract.py`
- Create: `tests/fixtures/landsearch-sample.html`
- Create: `tests/fixtures/bizbuysell-sample.html`

- [ ] **Step 1: Save test fixture HTML**

Navigate to LandSearch resort listings for Texas in a browser. Save the page text (not full HTML — just `document.body.innerText` output) to `tests/fixtures/landsearch-sample.txt`. Do the same for BizBuySell via ScraperAPI to get a real page: `tests/fixtures/bizbuysell-sample.txt`. These are gold-standard test inputs.

- [ ] **Step 2: Write the failing test**

```python
# scraper-service/test_claude_extract.py
import pytest
import json
from pathlib import Path
from claude_extract import extract_listings_from_page_text

FIXTURES = Path(__file__).parent.parent / "tests" / "fixtures"

@pytest.mark.asyncio
async def test_extracts_listings_from_landsearch():
    page_text = (FIXTURES / "landsearch-sample.txt").read_text()
    listings = await extract_listings_from_page_text(
        page_text=page_text,
        source_url="https://www.landsearch.com/properties/resort/texas",
        source_name="landsearch"
    )
    assert len(listings) >= 5, f"Expected at least 5 listings, got {len(listings)}"
    first = listings[0]
    assert "title" in first
    assert "url" in first
    assert "source" in first
    assert first["source"] == "landsearch"

@pytest.mark.asyncio
async def test_extracts_listings_from_bizbuysell():
    page_text = (FIXTURES / "bizbuysell-sample.txt").read_text()
    listings = await extract_listings_from_page_text(
        page_text=page_text,
        source_url="https://www.bizbuysell.com/texas/campgrounds-and-rv-parks-for-sale/",
        source_name="bizbuysell"
    )
    assert len(listings) >= 1, f"Expected at least 1 listing, got {len(listings)}"
    first = listings[0]
    assert "title" in first
    assert "price" in first or first.get("price") is None  # price can be null
    assert "url" in first

@pytest.mark.asyncio
async def test_returns_empty_for_non_listing_page():
    listings = await extract_listings_from_page_text(
        page_text="Welcome to our blog! Here are 10 tips for buying property...",
        source_url="https://example.com/blog",
        source_name="example"
    )
    assert listings == []

@pytest.mark.asyncio
async def test_all_fields_present():
    """Every listing must have all schema fields (can be null but must exist)."""
    page_text = (FIXTURES / "landsearch-sample.txt").read_text()
    listings = await extract_listings_from_page_text(
        page_text=page_text,
        source_url="https://www.landsearch.com/properties/resort/texas",
        source_name="landsearch"
    )
    required_keys = {"title", "price", "price_raw", "location", "url",
                     "acreage", "rooms_keys", "revenue_hint", "dom_hint",
                     "condition_hint", "description", "property_type", "source"}
    for listing in listings:
        missing = required_keys - set(listing.keys())
        assert not missing, f"Missing keys: {missing} in listing: {listing.get('title')}"
```

- [ ] **Step 3: Run test to verify it fails**

Run: `cd /Users/gideonspencer/dealhound-pro && python3 -m pytest scraper-service/test_claude_extract.py -v`
Expected: FAIL with `ModuleNotFoundError: No module named 'claude_extract'`

- [ ] **Step 4: Implement claude_extract.py**

```python
# scraper-service/claude_extract.py
"""
Universal listing extractor. Sends page text to Claude Sonnet,
returns structured listing data. Works on any real estate listing page
with zero per-site configuration.
"""
import json
import os
from anthropic import AsyncAnthropic

client = AsyncAnthropic(api_key=os.environ.get("ANTHROPIC_API_KEY", ""))

EXTRACTION_PROMPT = """You are extracting real estate property listings from a webpage.
Extract EVERY listing visible on this page. Do not filter or skip any listing.
If the page has no property listings, return an empty array.

For each listing, extract these fields (use null if not visible on the page):
- title: property name or headline text
- price: integer dollar amount (no commas, no $). null if not shown.
- price_raw: original price text exactly as shown (e.g. "$1,200,000")
- location: "City, State" format
- address: street address if visible. null if not shown.
- url: full URL to the individual listing page. If relative, prefix with the site domain.
- acreage: number (float). null if not shown.
- rooms_keys: number of rooms, units, or keys (integer). null if not shown.
- revenue_hint: any revenue, income, or cash flow text. null if none.
- dom_hint: days on market or date listed. null if not shown.
- condition_hint: any signals about condition (turnkey, fixer, as-is, renovated). null if none.
- description: first 300 characters of the listing description. null if none.
- property_type: best guess (resort, hotel, cabin, lodge, campground, rv park, land, etc). null if unclear.

Return ONLY a JSON array of objects. No markdown, no explanation, no preamble.
If zero listings found, return: []

PAGE URL: {source_url}
PAGE TEXT:
{page_text}"""

LISTING_SCHEMA = {
    "title": None, "price": None, "price_raw": None, "location": None,
    "address": None, "url": None, "acreage": None, "rooms_keys": None,
    "revenue_hint": None, "dom_hint": None, "condition_hint": None,
    "description": None, "property_type": None, "source": None,
}

async def extract_listings_from_page_text(
    page_text: str,
    source_url: str,
    source_name: str,
    max_text_chars: int = 100_000,
) -> list[dict]:
    """
    Universal extractor. Works on any site. No CSS selectors.
    
    Args:
        page_text: Raw text from document.body.innerText (no HTML tags)
        source_url: The URL this page was loaded from
        source_name: Slug for the source site (e.g. "bizbuysell")
        max_text_chars: Truncate page text to this length to control token cost
    
    Returns:
        List of listing dicts matching the standard schema.
        Empty list if no listings found or extraction fails.
    """
    truncated = page_text[:max_text_chars]
    
    prompt = EXTRACTION_PROMPT.format(
        source_url=source_url,
        page_text=truncated,
    )
    
    try:
        response = await client.messages.create(
            model="claude-sonnet-4-20250514",
            max_tokens=4096,
            messages=[{"role": "user", "content": prompt}],
        )
        
        raw_text = response.content[0].text.strip()
        # Handle markdown code blocks if model wraps response
        if raw_text.startswith("```"):
            raw_text = raw_text.split("\n", 1)[1]
            if raw_text.endswith("```"):
                raw_text = raw_text[:-3].strip()
        
        listings = json.loads(raw_text)
        
        if not isinstance(listings, list):
            return []
        
        # Normalize: ensure all schema fields exist, set source
        normalized = []
        for item in listings:
            listing = {**LISTING_SCHEMA, **item}
            listing["source"] = source_name
            # Ensure price is int or None
            if listing["price"] is not None:
                try:
                    listing["price"] = int(float(str(listing["price"]).replace(",", "").replace("$", "")))
                except (ValueError, TypeError):
                    listing["price"] = None
            # Ensure acreage is float or None
            if listing["acreage"] is not None:
                try:
                    listing["acreage"] = float(str(listing["acreage"]).replace(",", ""))
                except (ValueError, TypeError):
                    listing["acreage"] = None
            normalized.append(listing)
        
        return normalized
        
    except (json.JSONDecodeError, Exception) as e:
        print(f"[claude_extract] Extraction failed for {source_url}: {e}")
        return []
```

- [ ] **Step 5: Run tests to verify they pass**

Run: `cd /Users/gideonspencer/dealhound-pro && ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY python3 -m pytest scraper-service/test_claude_extract.py -v`
Expected: All 4 tests PASS

- [ ] **Step 6: Commit**

```bash
git add scraper-service/claude_extract.py scraper-service/test_claude_extract.py tests/fixtures/
git commit -m "feat: add Claude-based universal listing extractor"
```

---

## Task 2: ScraperAPI Proxy + Universal Scraper Function

Add residential proxy to Playwright and build the universal scrape function that uses Claude extraction.

**Files:**
- Modify: `scraper-service/scraper.py`
- Modify: `scraper-service/requirements.txt`

- [ ] **Step 1: Write failing test for proxy + Claude scraping**

```python
# Add to scraper-service/test_claude_extract.py

@pytest.mark.asyncio
async def test_scrape_site_with_claude_integration():
    """Integration test: Playwright fetches a real page, Claude extracts."""
    from scraper import scrape_site_with_claude, create_browser
    
    browser = await create_browser(use_proxy=False)  # No proxy for LandSearch (not blocked)
    page = await browser.new_page()
    
    listings = await scrape_site_with_claude(
        page=page,
        site_url="https://www.landsearch.com/properties/resort/texas",
        site_name="landsearch",
        max_pages=1,
    )
    
    await browser.close()
    
    assert len(listings) >= 5
    assert all("title" in l for l in listings)
    assert all(l["source"] == "landsearch" for l in listings)
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd /Users/gideonspencer/dealhound-pro && python3 -m pytest scraper-service/test_claude_extract.py::test_scrape_site_with_claude_integration -v`
Expected: FAIL — `scrape_site_with_claude` doesn't exist yet

- [ ] **Step 3: Add ScraperAPI proxy config and universal scraper to scraper.py**

Add these to `scraper-service/scraper.py` — do NOT remove existing scraper functions yet (LandSearch native scraper stays):

```python
# --- Add at top of scraper.py, after existing imports ---
import asyncio
from claude_extract import extract_listings_from_page_text

SCRAPER_API_KEY = os.environ.get("SCRAPER_API_KEY", "")
PROXY_SERVER = "http://scraperapi:@proxy-server.scraperapi.com:8001"

async def create_browser(use_proxy: bool = True):
    """Launch Playwright Chromium with optional ScraperAPI residential proxy."""
    p = await async_playwright().start()
    launch_args = {
        "headless": True,
        "args": ["--disable-blink-features=AutomationControlled"],
    }
    if use_proxy and SCRAPER_API_KEY:
        launch_args["proxy"] = {
            "server": PROXY_SERVER,
            "username": "scraperapi",
            "password": SCRAPER_API_KEY,
        }
    browser = await p.chromium.launch(**launch_args)
    return browser


async def scrape_site_with_claude(
    page,
    site_url: str,
    site_name: str,
    max_pages: int = MAX_PAGES,
    max_listings: int = MAX_LISTINGS,
) -> list[dict]:
    """
    Universal scraper. Playwright fetches the page, Claude extracts listings.
    Works on ANY site — no CSS selectors, no per-site configuration.
    """
    all_listings = []
    current_url = site_url
    
    for page_num in range(1, max_pages + 1):
        if len(all_listings) >= max_listings:
            break
        
        try:
            await page.goto(current_url, wait_until="networkidle", timeout=30000)
            await page.wait_for_timeout(2000)  # Let dynamic content settle
        except Exception as e:
            print(f"[scraper] Failed to load {current_url}: {e}")
            break
        
        # Get page text — no HTML, no selectors
        page_text = await page.evaluate("document.body.innerText")
        
        if not page_text or len(page_text.strip()) < 100:
            print(f"[scraper] Empty page at {current_url}")
            break
        
        # Claude extracts listings from the text
        page_listings = await extract_listings_from_page_text(
            page_text=page_text,
            source_url=current_url,
            source_name=site_name,
        )
        
        if not page_listings:
            print(f"[scraper] No listings found on page {page_num} of {site_name}")
            break
        
        all_listings.extend(page_listings)
        print(f"[scraper] {site_name} page {page_num}: {len(page_listings)} listings (total: {len(all_listings)})")
        
        # Try to find next page — check for common pagination patterns
        next_url = await _find_next_page(page, current_url)
        if not next_url:
            break
        
        current_url = next_url
        await asyncio.sleep(DELAY)
    
    return all_listings[:max_listings]


async def _find_next_page(page, current_url: str) -> str | None:
    """Find the next page URL. Tries common pagination patterns."""
    try:
        # Look for "Next" link
        next_link = await page.query_selector(
            'a:has-text("Next"), a:has-text("next"), a[aria-label="Next"], '
            'a.next, a.pagination-next, [class*="next"] a'
        )
        if next_link:
            href = await next_link.get_attribute("href")
            if href and href != current_url:
                if href.startswith("/"):
                    from urllib.parse import urlparse
                    parsed = urlparse(current_url)
                    return f"{parsed.scheme}://{parsed.netloc}{href}"
                return href
    except Exception:
        pass
    
    return None
```

- [ ] **Step 4: Update requirements.txt**

```
fastapi==0.115.6
uvicorn==0.34.0
playwright==1.49.1
pydantic==2.10.4
anthropic>=0.39.0
supabase>=2.0.0
pytest>=8.0.0
pytest-asyncio>=0.23.0
```

- [ ] **Step 5: Run the integration test**

Run: `cd /Users/gideonspencer/dealhound-pro && ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY python3 -m pytest scraper-service/test_claude_extract.py::test_scrape_site_with_claude_integration -v`
Expected: PASS

- [ ] **Step 6: Test against a blocked site (BizBuySell) with ScraperAPI**

```python
# Manual test — run in Python REPL or as a script
# scraper-service/test_proxy_manual.py
import asyncio
from scraper import create_browser, scrape_site_with_claude

async def test_bizbuysell():
    browser = await create_browser(use_proxy=True)  # Uses ScraperAPI
    page = await browser.new_page()
    listings = await scrape_site_with_claude(
        page=page,
        site_url="https://www.bizbuysell.com/texas/campgrounds-and-rv-parks-for-sale/",
        site_name="bizbuysell",
        max_pages=1,
    )
    await browser.close()
    print(f"Found {len(listings)} listings from BizBuySell")
    for l in listings[:3]:
        print(f"  - {l['title']} | {l['price_raw']} | {l['location']}")

asyncio.run(test_bizbuysell())
```

Run: `cd /Users/gideonspencer/dealhound-pro/scraper-service && ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY SCRAPER_API_KEY=$SCRAPER_API_KEY python3 test_proxy_manual.py`
Expected: Listings returned from BizBuySell (previously blocked with 403).

- [ ] **Step 7: Commit**

```bash
git add scraper-service/scraper.py scraper-service/requirements.txt scraper-service/test_proxy_manual.py
git commit -m "feat: add ScraperAPI proxy + universal Claude-based scraper function"
```

---

## Task 3: Update server.py — Accept Sites Array + Supabase Writes

**Files:**
- Modify: `scraper-service/server.py`

- [ ] **Step 1: Write failing test**

```python
# scraper-service/test_server.py
import pytest
from httpx import AsyncClient, ASGITransport
from server import app

@pytest.mark.asyncio
async def test_scrape_accepts_sites_array():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        resp = await client.post("/scrape", json={
            "locations": ["Texas"],
            "property_types": ["resort"],
            "sites": [
                {"name": "LandSearch", "url": "https://landsearch.com", "listings_url": "https://www.landsearch.com/properties/resort/texas"}
            ],
            "search_id": "test-123",
            "token": "test"
        })
        assert resp.status_code == 200
        data = resp.json()
        assert "listings" in data
        assert "sources_scraped" in data

@pytest.mark.asyncio
async def test_health_endpoint():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        resp = await client.get("/health")
        assert resp.status_code == 200
        assert resp.json()["status"] == "ok"
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd /Users/gideonspencer/dealhound-pro && python3 -m pytest scraper-service/test_server.py -v`
Expected: FAIL — `ScrapeRequest` doesn't accept `sites` or `search_id`

- [ ] **Step 3: Update server.py (sync→async + Supabase writes + callback)**

The existing `/scrape` handler is `def scrape(req)` (sync). New scraping logic uses `async` Playwright + Claude extraction. Convert the handler to `async def`.

Replace the `ScrapeRequest` model and `/scrape` endpoint in `scraper-service/server.py`:

```python
# --- Updated model (replaces lines 108-111) ---
class ScrapeRequest(BaseModel):
    locations: list[str]
    property_types: list[str] = []
    sites: list[dict] = []           # Discovered sites with listings_url
    search_id: str = ""              # For Supabase progress + raw listing writes
    callback_url: str = ""           # Vercel webhook to POST when done
    token: str = ""
```

Convert handler to `async def scrape(req: ScrapeRequest)` and update the logic:

1. Scrape hardcoded sites (landsearch native, bizbuysell/landwatch/crexi via `scrape_site_with_claude` with proxy)
2. ALSO scrape any additional sites from the `sites` array using `scrape_site_with_claude()` with proxy
3. If `search_id` provided:
   - Write progress rows to Supabase `scan_progress` table after each site completes
   - Write all raw listings to Supabase `raw_listings` table (new table — stores the raw extraction output before filtering)
4. If `callback_url` provided, POST `{"search_id": search_id}` to it when scraping completes (body is just the ID — listings are in Supabase, making the callback idempotent)

Key changes:
- `async def scrape(req)` (was sync `def scrape(req)`)
- Use `create_browser(use_proxy=True)` for blocked sites, `use_proxy=False` for LandSearch
- For sites in the `sites` array, use `scrape_site_with_claude()` with proxy
- Write progress after each site completes
- Write raw listings to Supabase after all scraping done
- Fire callback at end with just `search_id`

**Note:** This requires a new `raw_listings` table in Supabase. Create it with columns matching the listing schema: `search_id`, `title`, `price`, `price_raw`, `location`, `address`, `url`, `acreage`, `rooms_keys`, `revenue_hint`, `dom_hint`, `condition_hint`, `description`, `property_type`, `source`. This table stores the raw scraper output — the `deals` table stores the scored/filtered output.

- [ ] **Step 4: Run tests**

Run: `cd /Users/gideonspencer/dealhound-pro && python3 -m pytest scraper-service/test_server.py -v`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add scraper-service/server.py scraper-service/test_server.py
git commit -m "feat: server accepts sites array, writes progress to Supabase"
```

---

## Task 4: Fix filters.js — Null-Safe + Cross-Source Dedup

Port the skill's conservative filtering from `apply-buybox.md`.

**Files:**
- Modify: `api/_lib/filters.js`
- Create: `tests/integration/filters.test.js`

- [ ] **Step 1: Write failing tests**

```javascript
// tests/integration/filters.test.js
import { describe, it, expect } from 'vitest';
import { applyHardFilters } from '../../api/_lib/filters.js';

const baseBuyBox = {
  price_max: 3000000,
  price_min: '300000',
  acreage_min: 1.0,
  exclusions: ['mobile home'],
};

describe('null-safe filtering', () => {
  it('passes listing with null price (flags it)', () => {
    const listings = [{ title: 'Resort', price: null, acreage: 5, location: 'TX' }];
    const result = applyHardFilters(listings, baseBuyBox);
    expect(result[0].passed_hard_filters).toBe(true);
    expect(result[0].flags).toContain('price_unknown');
  });

  it('passes listing with null acreage (flags it)', () => {
    const listings = [{ title: 'Resort', price: 500000, acreage: null, location: 'TX' }];
    const result = applyHardFilters(listings, baseBuyBox);
    expect(result[0].passed_hard_filters).toBe(true);
    expect(result[0].flags).toContain('acreage_unknown');
  });

  it('fails listing with price over max', () => {
    const listings = [{ title: 'Resort', price: 5000000, acreage: 5, location: 'TX' }];
    const result = applyHardFilters(listings, baseBuyBox);
    expect(result[0].passed_hard_filters).toBe(false);
  });

  it('fails listing matching exclusion keyword', () => {
    const listings = [{ title: 'Mobile Home Park', price: 500000, acreage: 5, location: 'TX' }];
    const result = applyHardFilters(listings, baseBuyBox);
    expect(result[0].passed_hard_filters).toBe(false);
  });
});

describe('cross-source deduplication', () => {
  it('deduplicates by address (tier 1)', () => {
    const listings = [
      { title: 'Lake Resort A', price: 500000, location: 'Austin, TX', address: '123 Lake Dr', url: 'https://a.com/1', source: 'bizbuysell' },
      { title: 'Lake Resort B', price: 500000, location: 'Austin, TX', address: '123 Lake Drive', url: 'https://b.com/1', source: 'landwatch' },
    ];
    const result = applyHardFilters(listings, baseBuyBox);
    const passed = result.filter(r => r.passed_hard_filters);
    expect(passed.length).toBe(1);
    expect(passed[0].also_listed_on).toBeTruthy();
  });

  it('deduplicates by price+city+title (tier 2)', () => {
    const listings = [
      { title: 'Lakefront Glamping Resort', price: 1200000, location: 'Austin, TX', url: 'https://a.com/1', source: 'bizbuysell' },
      { title: 'Glamping Resort Lakefront', price: 1230000, location: 'Austin, TX', url: 'https://b.com/1', source: 'landwatch' },
    ];
    const result = applyHardFilters(listings, baseBuyBox);
    const passed = result.filter(r => r.passed_hard_filters);
    expect(passed.length).toBe(1);
  });

  it('flags possible dupes by price+city only (tier 3)', () => {
    const listings = [
      { title: 'Resort Investment', price: 1200000, location: 'Austin, TX', url: 'https://a.com/1', source: 'bizbuysell' },
      { title: 'Commercial Property', price: 1230000, location: 'Austin, TX', url: 'https://b.com/1', source: 'landwatch' },
    ];
    const result = applyHardFilters(listings, baseBuyBox);
    const passed = result.filter(r => r.passed_hard_filters);
    expect(passed.length).toBe(2);  // Both kept
    expect(passed[0].possible_duplicate).toBe(true);
    expect(passed[1].possible_duplicate).toBe(true);
  });
});
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd /Users/gideonspencer/dealhound-pro && npx vitest run tests/integration/filters.test.js`
Expected: FAIL — current `applyHardFilters` doesn't return `flags` or handle dedup

- [ ] **Step 3: Rewrite filters.js**

Replace the full content of `api/_lib/filters.js` with the null-safe + dedup implementation. Key logic:

1. `deduplicateListings(listings)` — three-tier cross-source dedup (runs first)
2. `applyHardFilters(listings, buyBox)` — null = pass with flag, exclusions, price/acreage checks
3. Each listing gets: `passed_hard_filters`, `miss_reason`, `flags[]`, `possible_duplicate`, `also_listed_on[]`

Dedup tiers from skill's `apply-buybox.md`:
- Tier 1: Normalize addresses (St→Street, Dr→Drive, etc.), exact match = definitive dupe
- Tier 2: Price within 5% + same city/state + 2+ significant title words = probable dupe
- Tier 3: Price within 5% + same city/state only = flag, keep both

- [ ] **Step 4: Run tests**

Run: `cd /Users/gideonspencer/dealhound-pro && npx vitest run tests/integration/filters.test.js`
Expected: All tests PASS

- [ ] **Step 5: Commit**

```bash
git add api/_lib/filters.js tests/integration/filters.test.js
git commit -m "feat: null-safe filtering + three-tier cross-source dedup"
```

---

## Task 5: Fix score.js — Opus Mitigations + False-Negative Protection

Port the skill's scoring approach from `scoring-rubric.md`.

**Files:**
- Modify: `api/_lib/score.js`

- [ ] **Step 1: Update Sonnet classification prompt (Stage A)**

In `api/_lib/score.js`, find the `classifyWithSonnet` function. Make these changes:

1. **Batch size**: Change from 10 to 25 (line ~23 area where batch loop is defined)
2. **Add false-negative protection** to the system prompt. Add this text to the existing prompt:

```
CRITICAL FALSE-NEGATIVE PROTECTION: When you are uncertain between PARTIAL and MISS for any criterion, ALWAYS default to PARTIAL. Only use MISS when a deal CLEARLY and UNAMBIGUOUSLY fails that criterion. A false positive (weak deal proceeds to review) costs $0.05 in API calls. A false negative (good deal dropped forever) costs the investor a real opportunity they will never see. When in doubt, keep the deal alive.
```

- [ ] **Step 2: Switch mitigations model from Sonnet to Opus (Stage B)**

In `api/_lib/score.js`, find the `writeMitigations` function (~line 120). Change:

```javascript
// BEFORE (line ~146):
model: 'claude-sonnet-4-20250514',

// AFTER:
model: 'claude-opus-4-20250514',
```

Also update the mitigation prompt to match the skill's quality standard. Add to the system prompt:

```
Write specific mitigation prescriptions for each risk factor rated 3 or higher. Not generic advice — specific to what THIS listing's data tells you. Reference actual details from the listing (price, location, acreage, condition signals, revenue data).

Examples of the quality expected:
- "Information risk (4): 148 leased acres — verify USACE lease terms, renewal timeline, and improvement restrictions before making an offer. Leased land = no equity."
- "Execution risk (3): Multi-revenue ops (marina + motel + cabins + fuel). Retain the existing manager for 90 days minimum post-close or you lose operational continuity."
```

- [ ] **Step 3: Update batch size for Opus mitigations**

Change mitigation batch size from 5 to 10 (Opus can handle it, and we only send deals with risk >= 3).

- [ ] **Step 4: Run existing scoring tests if any, verify no regressions**

Run: `cd /Users/gideonspencer/dealhound-pro && npx vitest run`
Expected: All existing tests still pass

- [ ] **Step 5: Commit**

```bash
git add api/_lib/score.js
git commit -m "feat: Opus mitigations, false-negative protection, batch size 25"
```

---

## Task 6: Update discover.js — Return Sites to Pipeline

**Files:**
- Modify: `api/_lib/discover.js`

- [ ] **Step 1: Read current discover.js and identify where sites are returned**

The current `discoverListings(buyBox)` returns `{sites, listings}` but the pipeline in `scan-pipeline.js` only uses `listings`. The fix is in the pipeline (Task 7), but first verify that `discover.js` already returns the sites array.

- [ ] **Step 2: If discover.js doesn't return sites, add it**

Ensure the return value includes: `{ sites: [...], listings: [...] }`

Each site should have: `{ name, url, listings_url, notes }`

- [ ] **Step 3: Commit if changes were needed**

```bash
git add api/_lib/discover.js
git commit -m "fix: ensure discover.js returns sites array for scraper"
```

---

## Task 7: Update Pipeline + Create scan-continue Webhook

Wire the new scraper into the pipeline with timeout handling.

**Files:**
- Modify: `api/_lib/scrape.js`
- Modify: `api/scan-pipeline.js`
- Create: `api/scan-continue.js`
- Modify: `vercel.json`

- [ ] **Step 1: Update scrape.js to pass sites + search_id**

Modify `api/_lib/scrape.js` to send the discovered sites array and search_id to the scraper:

```javascript
// api/_lib/scrape.js
const SCRAPER_URL = process.env.SCRAPER_SERVICE_URL || 'http://localhost:8080';
const SCRAPER_TOKEN = process.env.SCRAPER_API_TOKEN;
const WEBHOOK_SECRET = process.env.SCRAPER_WEBHOOK_SECRET || '';

export async function scrapeMarketplaces(buyBox, sites = [], searchId = '') {
  const baseUrl = process.env.VERCEL_URL
    ? `https://${process.env.VERCEL_URL}`
    : 'http://localhost:3000';

  const resp = await fetch(`${SCRAPER_URL}/scrape`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      locations: buyBox.locations || [],
      property_types: buyBox.property_types || [],
      sites: sites || [],
      search_id: searchId,
      callback_url: `${baseUrl}/api/scan-continue?secret=${WEBHOOK_SECRET}`,
      token: SCRAPER_TOKEN,
    }),
    signal: AbortSignal.timeout(120_000),
  });

  if (!resp.ok) {
    throw new Error(`Scraper returned ${resp.status}: ${await resp.text()}`);
  }

  return resp.json();
}
```

- [ ] **Step 2: Extract shared filter+score logic into process-listings.js**

This avoids duplicating filter/score/write logic between scan-pipeline.js and scan-continue.js.

```javascript
// api/_lib/process-listings.js (CommonJS)
const { applyHardFilters } = require('./filters.js');
const { scoreDeals } = require('./score.js');
const { writeProgress, supabase } = require('./progress.js');

/**
 * Shared pipeline: filter → score → write to Supabase.
 * Called by both scan-pipeline.js (on-demand) and scan-continue.js (webhook).
 */
async function processListings(searchId, listings, buyBox) {
  // Phase 3: Hard filters (null-safe + dedup)
  await writeProgress(searchId, 'filtering', 'running',
    `Screening ${listings.length} listings against buy box...`);
  const filtered = applyHardFilters(listings, buyBox);
  const survivors = filtered.filter(l => l.passed_hard_filters);
  const eliminated = filtered.filter(l => !l.passed_hard_filters);
  await writeProgress(searchId, 'filtering', 'complete',
    `${survivors.length} survived screening, ${eliminated.length} filtered out`,
    survivors.length);

  if (survivors.length === 0) {
    await supabase.from('deal_searches').update({ status: 'complete' }).eq('id', searchId);
    await writeProgress(searchId, 'done', 'complete', 'No deals survived screening');
    return { scored: [], eliminated };
  }

  // Phase 4: AI Scoring
  await writeProgress(searchId, 'scoring', 'running', `Scoring ${survivors.length} deals...`);
  const { scored, missed } = await scoreDeals(survivors, buyBox);

  // Insert scored deals
  const scoredRows = scored.map(d => ({
    search_id: searchId, source: d.source, url: d.url, source_url: d.source_url,
    title: d.title, price: d.price, acreage: d.acreage,
    location: d.location, property_type: d.property_type,
    passed_hard_filters: true,
    score: d.priority_score, score_breakdown: d.score_breakdown,
    brief: d.brief, raw_description: (d.description || '').substring(0, 500),
    scraped_at: new Date().toISOString(),
  }));
  if (scoredRows.length > 0) {
    await supabase.from('deals').insert(scoredRows);
  }

  // Insert eliminated deals (cap at 50)
  const elimRows = [...eliminated, ...missed].slice(0, 50).map(d => ({
    search_id: searchId, source: d.source, url: d.url, source_url: d.source_url,
    title: d.title, price: d.price, acreage: d.acreage,
    location: d.location, property_type: d.property_type,
    passed_hard_filters: false,
    miss_reason: d.miss_reason || 'strategy_miss',
    scraped_at: new Date().toISOString(),
  }));
  if (elimRows.length > 0) {
    await supabase.from('deals').insert(elimRows);
  }

  await writeProgress(searchId, 'scoring', 'complete',
    `${scored.length} deals scored and ranked`, scored.length);
  await supabase.from('deal_searches').update({ status: 'complete' }).eq('id', searchId);
  await writeProgress(searchId, 'done', 'complete',
    `Scan complete — ${scored.length} deals worth your attention`);

  return { scored, eliminated };
}

module.exports = { processListings };
```

- [ ] **Step 3: Create scan-continue.js webhook (CommonJS, await before respond)**

The scraper writes raw listings directly to Supabase. This webhook receives only the `search_id`, reads listings from Supabase, then runs filtering + scoring. This is idempotent — if the webhook fails and Railway retries, it re-reads the same data.

```javascript
// api/scan-continue.js (CommonJS — matches all other api/ files)
const { createClient } = require('@supabase/supabase-js');
const { processListings } = require('./_lib/process-listings.js');

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_KEY
);

module.exports = async function handler(req, res) {
  if (req.method === 'OPTIONS') return res.status(200).end();
  if (req.method !== 'POST') return res.status(405).json({ error: 'POST only' });

  const secret = req.query.secret || '';
  if (secret !== process.env.SCRAPER_WEBHOOK_SECRET) {
    return res.status(401).json({ error: 'unauthorized' });
  }

  const { search_id } = req.body;
  if (!search_id) return res.status(400).json({ error: 'search_id required' });

  try {
    // Read raw listings written by scraper to Supabase
    const { data: rawListings } = await supabase
      .from('raw_listings')
      .select('*')
      .eq('search_id', search_id);

    // Read buy box
    const { data: search } = await supabase
      .from('deal_searches')
      .select('buy_box')
      .eq('id', search_id)
      .single();

    if (!search || !rawListings) {
      return res.status(404).json({ error: 'search not found' });
    }

    // Run the shared filter → score → write pipeline
    // IMPORTANT: await ALL work before responding (Vercel may kill after res.json)
    const result = await processListings(search_id, rawListings, search.buy_box);

    return res.status(200).json({
      status: 'complete',
      scored: result.scored.length,
      eliminated: result.eliminated.length,
    });

  } catch (err) {
    console.error('[scan-continue] Error:', err);
    return res.status(500).json({ error: err.message });
  }
};
```

- [ ] **Step 4: Update scan-pipeline.js to use fire-and-forget + process-listings.js**

Modify `api/scan-pipeline.js` so Phase 2 (scraping) fires off to Railway and returns immediately. Railway calls back to `scan-continue.js` when done. The pipeline no longer waits for scraping to finish — it just kicks it off.

Key change: after discovery completes, call `scrapeMarketplaces(buyBox, discovered.sites, search_id)` but don't await the full result in the pipeline. The scraper runs independently and calls back.

- [ ] **Step 4: Update vercel.json**

Add `scan-continue.js` to the functions config:

```json
"api/scan-continue.js": { "maxDuration": 300 }
```

- [ ] **Step 5: Run all tests**

Run: `cd /Users/gideonspencer/dealhound-pro && npx vitest run`
Expected: All tests pass

- [ ] **Step 6: Commit**

```bash
git add api/_lib/scrape.js api/_lib/process-listings.js api/scan-pipeline.js api/scan-continue.js vercel.json
git commit -m "feat: webhook-based pipeline — scraper calls back when done, no Vercel timeout"
```

---

## Task 8: Deploy + End-to-End Verification

**Files:**
- Modify: `scraper-service/Dockerfile` (if deps changed)
- Railway deployment
- Vercel deployment

- [ ] **Step 1: Update Dockerfile if requirements changed**

The Dockerfile already copies `scraper.py` and `server.py`. Add the new `claude_extract.py`:

```dockerfile
COPY scraper.py server.py claude_extract.py ./
```

- [ ] **Step 2: Set environment variables on Railway**

Add to Railway service environment:
- `ANTHROPIC_API_KEY` — for Claude extraction
- `SCRAPER_API_KEY` — for ScraperAPI residential proxy
- `SUPABASE_URL` — for progress writes
- `SUPABASE_SERVICE_KEY` — for progress writes

- [ ] **Step 3: Set environment variables on Vercel**

Add to Vercel:
- `SCRAPER_WEBHOOK_SECRET` — shared secret for callback auth

- [ ] **Step 4: Deploy scraper to Railway**

```bash
cd /Users/gideonspencer/dealhound-pro/scraper-service
railway up
```

- [ ] **Step 5: Deploy API to Vercel**

```bash
cd /Users/gideonspencer/dealhound-pro
vercel --prod
```

- [ ] **Step 6: End-to-end test — run a scan through the dashboard**

1. Open dashboard in browser
2. Trigger a scan with a test buy box (Texas, micro resorts, $300k-$3M)
3. Watch the progress feed — verify all sites are scraped (including previously blocked BizBuySell, LandWatch, Crexi)
4. Verify results appear with:
   - Listings from all 4+ sources
   - No null-data drops (listings with missing acreage should appear with flags)
   - Cross-source duplicates merged
   - Opus mitigations on high-risk deals (check for specific, data-driven advice, not generic)
   - Priority scores matching the skill's arithmetic

- [ ] **Step 7: Compare against /find-deals skill output**

Run the /find-deals skill locally with the same buy box. Compare:
- Total listings found (product should find >= skill count)
- Scoring quality (strategy match labels should be similar)
- Mitigation quality (Opus output should be specific and data-driven)

If gaps exist, iterate on the Claude extraction prompt in `claude_extract.py`.

- [ ] **Step 8: Test failure modes**

1. Stop Railway service → verify dashboard shows "scraper offline" error, not hang
2. Use invalid ScraperAPI key → verify graceful error
3. Send empty locations → verify graceful empty result

- [ ] **Step 9: Commit any fixes from testing**

```bash
git add -A
git commit -m "fix: end-to-end testing fixes"
```

---

## Task 9: Daily Cron — Shared Pool Architecture

Optimize for multi-user: one daily scrape, all users filter from it.

**Files:**
- Create: `api/cron/daily-scan.js`
- Modify: `vercel.json`

- [ ] **Step 1: Create daily-scan.js (CommonJS)**

```javascript
// api/cron/daily-scan.js (CommonJS — matches all other api/ files)
const { createClient } = require('@supabase/supabase-js');
const { discoverListings } = require('../_lib/discover.js');
const { scrapeMarketplaces } = require('../_lib/scrape.js');

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_KEY
);

module.exports = async function handler(req, res) {
  // Verify cron secret (Vercel Cron sends this)
  if (req.headers.authorization !== `Bearer ${process.env.CRON_SECRET}`) {
    return res.status(401).json({ error: 'unauthorized' });
  }

  try {
    // Get all unique locations from active buy boxes
    const { data: searches } = await supabase
      .from('deal_searches')
      .select('buy_box')
      .eq('status', 'complete');

    if (!searches || searches.length === 0) {
      return res.status(200).json({ message: 'No active buy boxes' });
    }

    // Deduplicate locations across all users
    const allLocations = new Set();
    const allPropertyTypes = new Set();
    for (const s of searches) {
      (s.buy_box.locations || []).forEach(l => allLocations.add(l));
      (s.buy_box.property_types || []).forEach(t => allPropertyTypes.add(t));
    }

    const mergedBuyBox = {
      locations: [...allLocations],
      property_types: [...allPropertyTypes],
    };

    // Create a shared search record
    const { data: search } = await supabase
      .from('deal_searches')
      .insert({
        user_email: 'system@dealhound.pro',
        buy_box: mergedBuyBox,
        status: 'scanning',
      })
      .select()
      .single();

    // Fire off the scraper (it will call back to scan-continue)
    const discovered = await discoverListings(mergedBuyBox);
    await scrapeMarketplaces(mergedBuyBox, discovered.sites || [], search.id);

    return res.status(200).json({
      message: 'Daily scan triggered',
      search_id: search.id,
      locations: [...allLocations],
    });

  } catch (err) {
    console.error('[daily-scan] Error:', err);
    return res.status(500).json({ error: err.message });
  }
};
```

- [ ] **Step 2: Add cron config to vercel.json**

```json
"crons": [
  {
    "path": "/api/cron/daily-scan",
    "schedule": "0 6 * * *"
  }
]
```

Also add function config:
```json
"api/cron/daily-scan.js": { "maxDuration": 60 }
```

- [ ] **Step 3: Test manually**

```bash
curl -X POST https://your-vercel-url.vercel.app/api/cron/daily-scan \
  -H "Authorization: Bearer $CRON_SECRET"
```
Expected: Returns 200 with search_id. Scraper fires. Results appear in Supabase.

- [ ] **Step 4: Commit**

```bash
git add api/cron/daily-scan.js vercel.json
git commit -m "feat: daily cron shared pool scan across all user locations"
```

---

## Task 10: Shared Pool Fan-Out — Users See Shared Results

The daily cron writes scored deals to a system search (`system@dealhound.pro`). Individual users need to see deals from the shared pool that match their buy box. This task adds the fan-out: after the shared scan scores deals, each user's dashboard queries deals from the shared pool filtered by their buy box.

**Files:**
- Modify: `api/user-data.js` or create `api/user-deals.js`
- Modify: `api/scan-progress.js` (to show shared scan results)

- [ ] **Step 1: Design the fan-out query**

When a user opens their dashboard, the frontend currently fetches deals from their specific `search_id`. With the shared pool, the query changes to: "show me scored deals from the most recent shared scan where the deal matches my buy box criteria (location, price range, property type)."

This is a Supabase query with filters:
```sql
SELECT * FROM deals
WHERE search_id = (latest system search)
AND location ILIKE ANY(user_locations)
AND price BETWEEN user_price_min AND user_price_max
AND passed_hard_filters = true
ORDER BY score DESC
```

- [ ] **Step 2: Implement the query in the API**

Add a function that takes a user's buy box and returns matching deals from the shared pool. This supplements (not replaces) the per-user on-demand scan — users see both their own scans and the daily shared pool.

- [ ] **Step 3: Update frontend to show shared pool deals**

The Sidebar component should show a "Daily Scan" section with deals from the shared pool, in addition to the user's on-demand scan results.

- [ ] **Step 4: Test**

Verify: Two users with overlapping locations both see the same deals from the daily scan, without running separate scrapes.

- [ ] **Step 5: Commit**

```bash
git add api/user-deals.js dashboard/src/components/Sidebar.jsx
git commit -m "feat: users see scored deals from shared daily scan pool"
```
