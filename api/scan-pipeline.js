// api/scan-pipeline.js
/**
 * Scan Pipeline — orchestrates the full /find-deals skill pipeline.
 *
 * Phase 1: Discovery — web search for marketplaces + individual listings
 * Phase 2: Scraping — Railway Playwright service for marketplace sites
 * Phase 3: Scoring — Sonnet classify, Opus mitigations, priority arithmetic
 *
 * Each phase writes progress to scan_progress for real-time frontend updates.
 * Called by scan-start.js.
 */

const { writeProgress, supabase } = require('./lib/progress');
const { discoverListings } = require('./lib/discover');
const { scrapeMarketplaces } = require('./lib/scrape');
const { applyHardFilters } = require('./lib/filters');
const { scoreDeals } = require('./lib/score');

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
    let allListings = [];

    // ── Phase 1: Discovery ──────────────────────────────────────
    await writeProgress(search_id, 'discovery', 'running', 'Searching the web for listings matching your buy box...');

    try {
      const discovered = await discoverListings(buyBox);
      const directListings = (discovered.listings || []).map(l => ({
        ...l, source: l.source || 'web_search',
      }));
      allListings.push(...directListings);

      const siteCount = (discovered.sites || []).length;
      await writeProgress(
        search_id, 'discovery', 'complete',
        `Found ${directListings.length} individual listings + ${siteCount} marketplace sites`,
        directListings.length
      );
    } catch (e) {
      console.error('Discovery failed:', e.message);
      await writeProgress(search_id, 'discovery', 'error', 'Web search unavailable — continuing with marketplace scraping');
    }

    // ── Phase 2: Scraping ───────────────────────────────────────
    await writeProgress(search_id, 'scraping', 'running', 'Scraping marketplace sites with Playwright...');

    try {
      const scrapeResult = await scrapeMarketplaces(buyBox);
      const scraped = scrapeResult.listings || [];
      allListings.push(...scraped);

      const sources = scrapeResult.sources_scraped || [];
      await writeProgress(
        search_id, 'scraping', 'complete',
        `${sources.length > 0 ? sources.join(', ') + ' — ' : ''}${scraped.length} marketplace listings found`,
        scraped.length
      );
    } catch (e) {
      console.error('Scraping failed:', e.message);
      await writeProgress(search_id, 'scraping', 'error', `Scraper service unavailable: ${e.message}`);
    }

    // If both phases returned nothing, mark as complete with 0 results
    if (allListings.length === 0) {
      await writeProgress(search_id, 'complete', 'complete', 'Scan complete — no listings found matching your criteria');
      await supabase.from('deal_searches').update({ status: 'complete' }).eq('id', search_id);
      return;
    }

    // ── Hard filters ────────────────────────────────────────────
    await writeProgress(
      search_id, 'screening', 'running',
      `Screening ${allListings.length} listings against your buy box...`
    );

    const filtered = applyHardFilters(allListings, buyBox);
    const survivors = filtered.filter(l => l.passed_hard_filters);
    const eliminated = filtered.filter(l => !l.passed_hard_filters);

    await writeProgress(
      search_id, 'screening', 'complete',
      `${allListings.length} listings reviewed — ${survivors.length} survived screening`,
      survivors.length
    );

    // ── Phase 3: Scoring ────────────────────────────────────────
    if (survivors.length > 0) {
      await writeProgress(
        search_id, 'scoring', 'running',
        `Scoring ${survivors.length} matches against your investment strategy...`
      );

      const { scored, missed } = await scoreDeals(survivors, buyBox);

      // Add strategy-miss deals to eliminated list
      eliminated.push(...missed);

      // Insert scored deals
      for (const deal of scored) {
        await supabase.from('deals').insert({
          search_id,
          source: deal.source,
          url: deal.url,
          source_url: deal.url,
          title: deal.title,
          price: deal.price,
          acreage: deal.acreage,
          location: deal.location,
          property_type: deal.property_type,
          passed_hard_filters: true,
          score: deal.priority_score,
          score_breakdown: deal.score_breakdown,
          brief: deal.brief,
          raw_description: (deal.description || '').substring(0, 300),
          scraped_at: new Date().toISOString(),
        });
      }

      const hotCount = scored.filter(d => (d.priority_score || 0) >= 70).length;
      await writeProgress(
        search_id, 'scoring', 'complete',
        `Scoring complete — ${scored.length} deals scored, ${hotCount} hot matches`,
        scored.length
      );
    }

    // Insert eliminated deals (capped at 50 for transparency)
    for (const deal of eliminated.slice(0, 50)) {
      await supabase.from('deals').insert({
        search_id,
        source: deal.source,
        url: deal.url,
        source_url: deal.url,
        title: deal.title,
        price: deal.price,
        acreage: deal.acreage,
        location: deal.location,
        property_type: deal.property_type,
        passed_hard_filters: false,
        miss_reason: deal.miss_reason,
        scraped_at: new Date().toISOString(),
      });
    }

    // Mark complete
    await supabase
      .from('deal_searches')
      .update({ status: 'complete' })
      .eq('id', search_id);

    await writeProgress(
      search_id, 'complete', 'complete',
      `Scan complete — ${survivors.length} deals worth your attention`
    );

  } catch (err) {
    console.error('Pipeline fatal error:', err);
    await writeProgress(search_id, 'error', 'error', 'Scan encountered an error — try again');
    await supabase.from('deal_searches').update({ status: 'error' }).eq('id', search_id);
  }
};
