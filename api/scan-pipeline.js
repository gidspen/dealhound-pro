/**
 * Scan Pipeline — orchestrates scraping + scoring for a deal search.
 *
 * Scraping:  Calls the Railway-hosted Playwright scraper service (from /find-deals skill)
 * Scoring:   Claude API — Sonnet for classification, with strategy match + risk scoring
 * Storage:   Supabase — scan_progress (real-time), deals (results)
 *
 * Called by scan-start.js after the response is sent.
 */

const { createClient } = require('@supabase/supabase-js');
const Anthropic = require('@anthropic-ai/sdk');

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_KEY
);

const anthropic = new Anthropic();

const SCRAPER_URL = process.env.SCRAPER_SERVICE_URL || 'http://localhost:8080';
const SCRAPER_TOKEN = process.env.SCRAPER_API_TOKEN || '';

// ── Scraper service client ──────────────────────────────────────────

async function scrapeListings(buyBox) {
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), 120000); // 2 min timeout

  try {
    const res = await fetch(`${SCRAPER_URL}/scrape`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      signal: controller.signal,
      body: JSON.stringify({
        locations: buyBox.locations || [],
        property_types: buyBox.property_types || [],
        token: SCRAPER_TOKEN,
      }),
    });

    if (!res.ok) {
      const text = await res.text();
      throw new Error(`Scraper returned ${res.status}: ${text}`);
    }

    return await res.json();
  } finally {
    clearTimeout(timeout);
  }
}

// ── Buy box filtering ───────────────────────────────────────────────

function applyHardFilters(listings, buyBox) {
  return listings.map(listing => {
    const reasons = [];

    if (buyBox.price_max && listing.price && listing.price > buyBox.price_max) {
      reasons.push(`Price $${listing.price.toLocaleString()} exceeds max $${buyBox.price_max.toLocaleString()}`);
    }
    if (buyBox.price_min && buyBox.price_min !== 'null' && listing.price && listing.price < buyBox.price_min) {
      reasons.push(`Price $${listing.price.toLocaleString()} below min $${Number(buyBox.price_min).toLocaleString()}`);
    }
    if (buyBox.acreage_min && buyBox.acreage_min !== 'null' && listing.acreage && listing.acreage < buyBox.acreage_min) {
      reasons.push(`Acreage ${listing.acreage} below min ${buyBox.acreage_min}`);
    }
    if (buyBox.exclusions && buyBox.exclusions.length > 0) {
      const text = `${listing.title || ''} ${listing.description || ''}`.toLowerCase();
      for (const excl of buyBox.exclusions) {
        if (text.includes(excl.toLowerCase())) {
          reasons.push(`Matches exclusion: "${excl}"`);
        }
      }
    }

    return {
      ...listing,
      passed_hard_filters: reasons.length === 0,
      miss_reason: reasons.length > 0 ? reasons.join('; ') : null,
    };
  });
}

// ── Claude scoring ──────────────────────────────────────────────────

async function scoreDeals(survivors, buyBox) {
  if (survivors.length === 0) return [];

  const scored = [];
  const batchSize = 5;

  for (let i = 0; i < survivors.length; i += batchSize) {
    const batch = survivors.slice(i, i + batchSize);

    const prompt = `You are a real estate investment analyst. Score these ${batch.length} properties against the investor's buy box.

BUY BOX:
- Locations: ${(buyBox.locations || []).join(', ')}
- Price range: ${buyBox.price_min && buyBox.price_min !== 'null' ? '$' + Number(buyBox.price_min).toLocaleString() : 'No min'} – $${Number(buyBox.price_max).toLocaleString()}
- Property types: ${(buyBox.property_types || []).join(', ').replace(/_/g, ' ')}
- Revenue requirement: ${(buyBox.revenue_requirement || 'any').replace(/_/g, ' ')}
- Exclusions: ${(buyBox.exclusions || []).join(', ') || 'none'}

PROPERTIES TO SCORE:
${batch.map((d, idx) => `
[${idx + 1}] ${d.title}
  Location: ${d.location}
  Price: ${d.price ? '$' + d.price.toLocaleString() : 'unknown'}
  Acreage: ${d.acreage || 'unknown'}
  Source: ${d.source}
  Description: ${(d.description || d.raw_description || '').substring(0, 200)}
`).join('')}

For each property, return a JSON array where each element has:
- "index": the property number (1-based)
- "strategy_overall": one of "STRONG MATCH", "MODERATE MATCH", "WEAK MATCH"
- "strategy_summary": one sentence explaining why
- "risk_level": one of "LOW", "MODERATE", "HIGH", "VERY HIGH"
- "risk_summary": one sentence on key risk factors
- "brief": 2-3 sentence analysis an investor would find useful
- "suggested_next_step": one actionable step

Respond with ONLY the JSON array, no other text.`;

    try {
      const response = await anthropic.messages.create({
        model: 'claude-sonnet-4-20250514',
        max_tokens: 2000,
        messages: [{ role: 'user', content: prompt }],
      });

      const text = response.content[0]?.text || '[]';
      const jsonStr = text.replace(/```json\n?/g, '').replace(/```\n?/g, '').trim();
      const scores = JSON.parse(jsonStr);

      for (const score of scores) {
        const deal = batch[score.index - 1];
        if (!deal) continue;

        scored.push({
          ...deal,
          score_breakdown: {
            strategy: {
              overall: score.strategy_overall,
              summary: score.strategy_summary,
            },
            risk: {
              level: score.risk_level,
              summary: score.risk_summary,
            },
          },
          brief: score.brief,
        });
      }
    } catch (e) {
      console.error('Claude scoring failed for batch:', e.message);
      for (const deal of batch) {
        scored.push({
          ...deal,
          score_breakdown: {
            strategy: { overall: 'MODERATE MATCH', summary: 'Scoring unavailable — review manually' },
            risk: { level: 'MODERATE', summary: 'Unable to assess — needs manual review' },
          },
          brief: 'Automated scoring was unavailable. Review this listing manually.',
        });
      }
    }
  }

  return scored;
}

// ── Progress helper ─────────────────────────────────────────────────

async function writeProgress(searchId, step, status, message, listingCount = null) {
  await supabase.from('scan_progress').insert([
    { search_id: searchId, step, status, message, listing_count: listingCount },
  ]);
}

// ── Main pipeline ───────────────────────────────────────────────────

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

    // Phase 1: Scrape via Railway service
    await writeProgress(search_id, 'scraping', 'running', 'Scanning marketplaces for listings...');

    let scrapeResult;
    try {
      scrapeResult = await scrapeListings(buyBox);
    } catch (e) {
      console.error('Scraper service error:', e.message);
      await writeProgress(search_id, 'scraping', 'error', `Scraper service unavailable: ${e.message}`);
      await supabase.from('deal_searches').update({ status: 'error' }).eq('id', search_id);
      return;
    }

    const allListings = scrapeResult.listings || [];
    const sourcesList = scrapeResult.sources_scraped || [];

    await writeProgress(
      search_id, 'scraping', 'complete',
      `${sourcesList.join(', ')} — ${allListings.length} listings found`,
      allListings.length
    );

    if (allListings.length === 0) {
      await writeProgress(search_id, 'complete', 'complete', 'Scan complete — no listings found matching your criteria');
      await supabase.from('deal_searches').update({ status: 'complete' }).eq('id', search_id);
      return;
    }

    // Phase 2: Apply hard filters
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

    // Phase 3: Score survivors with Claude
    if (survivors.length > 0) {
      await writeProgress(
        search_id, 'scoring', 'running',
        `Scoring ${survivors.length} matches against your investment strategy...`
      );

      const scored = await scoreDeals(survivors, buyBox);

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
          score_breakdown: deal.score_breakdown,
          brief: deal.brief,
          raw_description: (deal.description || '').substring(0, 300),
          scraped_at: new Date().toISOString(),
        });
      }

      const hotCount = scored.filter(d => d.score_breakdown?.strategy?.overall === 'STRONG MATCH').length;
      await writeProgress(
        search_id, 'scoring', 'complete',
        `Scoring complete — ${scored.length} deals scored, ${hotCount} strong matches`,
        scored.length
      );
    }

    // Insert eliminated deals (capped for transparency)
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
