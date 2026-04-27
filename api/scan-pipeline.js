// api/scan-pipeline.js
/**
 * Scan Pipeline — orchestrates the full deal-finding pipeline.
 *
 * Phase 1: Discovery — web search for marketplaces + individual listings
 * Phase 2: Scraping — fires off to Railway (async, calls back to scan-continue)
 * Phase 3: Scoring — runs immediately on discovery listings via processListings;
 *          scraped listings are scored when the callback arrives
 *
 * Each phase writes progress to scan_progress for real-time frontend updates.
 * Called by scan-start.js.
 */

const { writeProgress, supabase } = require('./_lib/progress');
const { discoverListings } = require('./_lib/discover');
const { scrapeMarketplaces } = require('./_lib/scrape');
const { processListings } = require('./_lib/process-listings');

module.exports = async function runPipeline(search_id) {
  try {
    // Load buy box
    const { data: search, error: searchError } = await supabase
      .from('deal_searches')
      .select('*')
      .eq('id', search_id)
      .single();

    if (searchError || !search) {
      console.error('Pipeline: search not found', search_id);
      return;
    }

    const buyBox = search.buy_box;
    let discoveredSites = [];
    let directListings = [];

    // ── Phase 1: Discovery ──────────────────────────────────────
    await writeProgress(search_id, 'discovery', 'running', 'Searching the web for listings matching your buy box...');

    try {
      const discovered = await discoverListings(buyBox);
      directListings = (discovered.listings || []).map(l => ({
        ...l, source: l.source || 'web_search',
      }));
      discoveredSites = discovered.sites || [];

      await writeProgress(
        search_id, 'discovery', 'complete',
        `Found ${directListings.length} individual listings + ${discoveredSites.length} marketplace sites`,
        directListings.length
      );
    } catch (e) {
      console.error('Discovery failed:', e.message);
      await writeProgress(search_id, 'discovery', 'error', 'Web search unavailable — continuing with marketplace scraping');
    }

    // ── Phase 2: Scraping (fire-and-forget) ─────────────────────
    // Railway scraper runs independently. When it finishes, it writes raw
    // listings to Supabase and calls back to /api/scan-continue, which
    // runs processListings on the scraped data and marks the scan complete.
    await writeProgress(search_id, 'scraping', 'running', 'Scraping marketplace sites...');

    try {
      await scrapeMarketplaces(buyBox, discoveredSites, search_id);
      await writeProgress(search_id, 'scraping', 'running',
        'Scraper acknowledged — scraping in progress');
    } catch (e) {
      // Timeout is expected — Railway keeps running, callback will arrive later
      if (e.name === 'AbortError' || e.message?.includes('abort')) {
        console.log('[pipeline] Scraper HTTP timeout (expected) — callback will arrive');
        await writeProgress(search_id, 'scraping', 'running',
          'Scraper is running — results will arrive shortly');
      } else {
        console.error('Scraping failed:', e.message);
        await writeProgress(search_id, 'scraping', 'error', `Scraper service unavailable: ${e.message}`);
      }
    }

    // ── Process discovery listings immediately ──────────────────
    // Direct listings from web search are processed now.
    // Scraped listings will be processed when scan-continue receives the callback.
    // markComplete=false — scan-continue will mark complete after scraper finishes.
    if (directListings.length > 0) {
      await processListings(search_id, directListings, buyBox, false);
    }

  } catch (err) {
    console.error('Pipeline fatal error:', err);
    await writeProgress(search_id, 'error', 'error', 'Scan encountered an error — try again');
    await supabase.from('deal_searches').update({ status: 'error' }).eq('id', search_id);
  }
};
