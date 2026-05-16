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
