-- 2026-05-15: deals.html_snapshot
--
-- Adds a wide TEXT column that captures the raw detail-page HTML for each
-- scraped listing. Two motivations:
--
--   1. Crexi (and a few other Angular SPA sources) hide the full property
--      description behind heuristic-resistant DOM structures that our generic
--      extract_description() function consistently misses. Capturing the raw
--      page once, while we already have the browser session warm, lets us
--      re-extract richer fields later via Claude or richer selectors without
--      another live scrape.
--
--   2. Adds resiliency for fields we don't have a column for yet (cap rate,
--      NOI, year built, sqft, broker contact, photos). When we add a column,
--      we can backfill from existing html_snapshot rows in bulk.
--
-- Read profile: never SELECT-ed by the dashboard query (api/user-data.js
-- selects explicit columns). Storage is bounded by DETAIL_VISIT_CAP (currently
-- 120 listings per source per scan) and per-page size (~100–500 KB raw HTML).
--
-- Reversible:
--   ALTER TABLE public.deals DROP COLUMN html_snapshot;

ALTER TABLE public.deals
  ADD COLUMN IF NOT EXISTS html_snapshot text;

COMMENT ON COLUMN public.deals.html_snapshot IS
  'Raw HTML of the listing detail page at scrape time. Used for offline re-extraction of fields we did not initially pull. Captured by find-deals/scrapers/scraper.py during enrich_with_descriptions.';
