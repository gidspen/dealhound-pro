# Skills Changelog

The `/find-deals` skill lives at `~/skills/find-deals/` (user-scope, outside this repo) because the same skill powers both DealHound Pro and Gideon's interactive Claude sessions. Code changes there don't show up in PRs to this repo. This file tracks them so reviewers can correlate skill behavior with product behavior.

When you change skill code, append an entry here in the same commit that lands the product-side change that depends on it.

---

## 2026-05-15 — Crexi description enrichment + HTML snapshot capture

**Why:** Audit of 420 Crexi deals over the prior 14 days showed average description length of **46 characters and max of 99** — every single one was the API tagline, not the full property description. `enrich_with_descriptions()` was visiting detail pages (`DETAIL_VISIT_CAP=120`, so coverage wasn't the issue) but consistently returning nothing usable.

**Root cause (two failures stacked):**

1. **Selector miss.** Crexi renders the description inside `<crx-asset-description-card>` Angular components. The generic `_DESC_SELECTORS` list only had class-attribute selectors (`[class*='PropertyDescription']`, `[class*='description-text']`, etc.) which never match Angular component tags. When dedicated selectors found nothing, `extract_description()` fell through to `meta[name='description']` — which is the same short tagline that comes back from the listing API. The extractor was returning a "success" of ~99 chars that was identical to what we started with.

2. **No render budget.** Crexi is a heavy Angular SPA. Even after `wait_until="domcontentloaded"`, the description block needs a beat to mount. The hard-coded 400ms post-load wait wasn't enough; the component shell exists in DOM but its text content arrives later via lazy fetches.

**Changes:**

- `scrapers/scraper.py`
  - `_DESC_SELECTORS`: added `crx-asset-description-card`, `crx-property-overview`, `[class*='AssetDescription']`, `[class*='asset-description']`, `[class*='property-overview']` at the **top** of the list (priority order matters — first match wins).
  - New `_BLOCKED_TITLES` constant + `_is_blocked_page(page)` helper. Detects `"Just a moment"` / `"Access Denied"` / `"Attention Required"` title (Cloudflare / Akamai). `extract_description()` now short-circuits and returns `None` on a blocked page so we don't write the challenge page's meta description into Supabase.
  - New `_CREXI_READY_SELECTORS` list. `enrich_with_descriptions()` now branches on `source_label`: for Crexi it waits on any of those selectors via `page.wait_for_selector(sel, timeout=4000, state="attached")` then a 1.5s settle wait. Generic sources keep the old 400ms behavior.
  - On every successful detail visit (Crexi or not), capture `page.content()` and stash it on the listing dict as `html_snapshot`. Best-effort — `_capture_html_snapshot()` swallows exceptions so a flaky page doesn't kill the run.
  - Added a new `blocked` counter to the per-source summary log: `[crexi] description enrichment: visited=X enriched=Y skipped=Z blocked=W failed=V`.

- `pipeline.py`
  - `supabase_insert_raw()` now persists `html_snapshot` into `deals.html_snapshot`. Per-row size is capped at 4 MB to bound row size on outliers (real Crexi pages run ~250 KB).

**Product-side dependency (this repo):**

- Migration `scripts/migrations/2026-05-15-deals-html-snapshot.sql` adds the column.
- `api/user-data.js` is **not** updated — it intentionally never SELECTs `html_snapshot` so the dashboard query stays small. The snapshot is for offline re-extraction, not live read.
- No change to `dashboard/src/components/Preview.jsx` — the existing `raw_description` render path will now have real Crexi text to display (was returning the 99-char tagline before).

**How to verify:** After a fresh Crexi-backed worker run, query Supabase:

```sql
SELECT
  COUNT(*) AS total,
  ROUND(AVG(LENGTH(raw_description))) AS avg_desc_len,
  COUNT(*) FILTER (WHERE LENGTH(raw_description) >= 500) AS rich,
  COUNT(*) FILTER (WHERE html_snapshot IS NOT NULL) AS has_snapshot
FROM deals
WHERE source = 'crexi' AND scraped_at >= NOW() - INTERVAL '1 hour';
```

Pre-change baseline: avg ~46, rich = 0, snapshot count = 0.
Target post-change: avg >> 500, rich > 0, snapshot count ≈ total.

**Reversal:** Revert scraper.py + pipeline.py changes. The `html_snapshot` column is safe to leave in place (nullable, ignored by dashboard).

---

## 2026-05-16 — Crexi enrichment bail-out + worker browser-profile isolation

**Why:** The worker (PM2 daemon spawning `claude --dangerously-skip-permissions`) was hanging at 90+ minutes per scan with `outputKB` plateauing around 294 KB. Investigation found two stacked failures:

1. **Profile lock conflict.** The user-scope playwright MCP registration uses `--user-data-dir /Users/gideonspencer/.dealhound-chrome-profile`. When an interactive Claude session already had the profile open (likely whenever Gideon was using `/find-deals` himself), the worker-spawned Claude tried to launch the same profile and got `"Browser is already in use for /Users/gideonspencer/.dealhound-chrome-profile, use --isolated to run multiple instances of the same browser"`. The find-deals skill silently retried forever.

2. **Cold-profile Crexi hang.** Even with the profile lock cleared, the worker's profile is cold (no Cloudflare trust signals). Crexi's anti-bot served a never-ending JS challenge to detail-page visits, and `page.goto(..., wait_until="domcontentloaded", timeout=12000)` did NOT raise `PlaywrightTimeout` as documented — it just blocked. `enrich_with_descriptions` ran out the worker's 90-min budget before writing any listings to Supabase.

**Changes (skill-side, `~/skills/find-deals/scrapers/scraper.py`):**

- `enrich_with_descriptions()` now enforces three concurrent bail-outs:
  - `MAX_WALL_SECONDS = 240` — total per-source enrichment budget, hard cap.
  - `MAX_CONSECUTIVE_FAILURES = 5` — after 5 consecutive nav timeouts / Cloudflare bounces, bail. A cold profile fails the first 5 fast and skips the rest with API-tagline descriptions.
  - Per-page `page.goto(..., timeout=8000)` (down from 12000) and per-selector `wait_for_selector(..., timeout=2000)` (down from 4000) — fail-fast when the page isn't going to render.
- Reset `consecutive_failures = 0` on each successful enrichment so a single stall doesn't terminate enrichment for a still-healthy profile.
- Enrichment summary now logs wall-time alongside counts: `[crexi] description enrichment: visited=5, enriched=0, skipped=0, blocked=5, failed=0 (19.3s)`.

**Product-side dependency (this repo):**

- `worker/mcp-config.json` — NEW. Project-scope MCP definition pointing playwright at `/Users/gideonspencer/.dealhound-worker-chrome-profile` (separate from the user-scope profile). Loaded via `claude --mcp-config worker/mcp-config.json --strict-mcp-config` in `worker/pty-runner.js`.
- `worker/pty-runner.js` — UPDATED. Adds the two flags above to the `pty.spawn(claudeBin, [...])` argv. Comment block explains the audit.

**How to verify:**

```sh
# Before fix: scraper hung indefinitely on cold profile
# After fix: bails out in ~20s, writes 60 listings with API-tagline descriptions
cd ~/skills/find-deals/scrapers && python3 scraper.py --site crexi --location texas --headless --output-dir /tmp/dh-debug
```

Expected tail:

```
=== Scraping CREXI ===
  Crexi: https://www.crexi.com/properties/TX [filter: Hospitality]
  → API returned 60 items (totalCount=635)
  → kept 60 (matched filter 'Hospitality'); running total: 60
  [crexi] 5 consecutive failures — bailing (profile likely cold or anti-bot-blocked)
  [crexi] description enrichment: visited=5, enriched=0, skipped=0, blocked=5, failed=0 (19.3s)
  crexi: 60 unique listings
EXIT=0
```

**Trade-off:** A cold worker profile gets API-tagline descriptions (25-99 char) instead of rich detail-page descriptions (500-5800 char). The interactive `/find-deals` path on the warm user profile still gets rich descriptions. Future work: warm the worker profile from the user profile's cookies, or accept warm-up as an explicit pre-launch step.

**Reversal:** Revert the bail-out block in `enrich_with_descriptions` (search for `MAX_WALL_SECONDS`).
