// api/_lib/process-listings.js
// Shared pipeline: filter → score → write to Supabase.
// Called by both scan-pipeline.js (on-demand) and scan-continue.js (webhook).

const { applyHardFilters } = require('./filters.js');
const { scoreDeals } = require('./score.js');
const { writeProgress, supabase } = require('./progress.js');

/**
 * @param {string} searchId
 * @param {Array} listings - raw listings to process
 * @param {Object} buyBox
 * @param {boolean} markComplete - if true, mark search as complete when done.
 *   Pipeline passes false (scraper callback will mark complete).
 *   scan-continue passes true.
 */
async function processListings(searchId, listings, buyBox, markComplete = true) {
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
    if (markComplete) {
      await supabase.from('deal_searches').update({ status: 'complete' }).eq('id', searchId);
      await writeProgress(searchId, 'done', 'complete', 'No deals survived screening');
    }
    return { scored: [], eliminated };
  }

  // Phase 4: AI Scoring
  await writeProgress(searchId, 'scoring', 'running', `Scoring ${survivors.length} deals...`);
  const { scored, missed } = await scoreDeals(survivors, buyBox);

  // Insert scored deals
  const scoredRows = scored.map(d => ({
    search_id: searchId, source: d.source, url: d.url, source_url: d.url,
    title: d.title, price: d.price, acreage: d.acreage,
    location: d.location, property_type: d.property_type,
    passed_hard_filters: true,
    score: d.priority_score, score_breakdown: d.score_breakdown,
    brief: d.brief, raw_description: (d.description || '').substring(0, 500),
    also_listed_on: d.also_listed_on || [],
    possible_duplicate: d.possible_duplicate || false,
    scraped_at: new Date().toISOString(),
  }));
  if (scoredRows.length > 0) {
    await supabase.from('deals').insert(scoredRows);
  }

  // Insert eliminated deals (cap at 50)
  const elimRows = [...eliminated, ...missed].slice(0, 50).map(d => ({
    search_id: searchId, source: d.source, url: d.url, source_url: d.url,
    title: d.title, price: d.price, acreage: d.acreage,
    location: d.location, property_type: d.property_type,
    passed_hard_filters: false,
    miss_reason: d.miss_reason || 'strategy_miss',
    also_listed_on: d.also_listed_on || [],
    possible_duplicate: d.possible_duplicate || false,
    scraped_at: new Date().toISOString(),
  }));
  if (elimRows.length > 0) {
    await supabase.from('deals').insert(elimRows);
  }

  await writeProgress(searchId, 'scoring', 'complete',
    `${scored.length} deals scored and ranked`, scored.length);

  if (markComplete) {
    await supabase.from('deal_searches').update({ status: 'complete' }).eq('id', searchId);
    await writeProgress(searchId, 'done', 'complete',
      `Scan complete — ${scored.length} deals worth your attention`);
  }

  return { scored, eliminated };
}

module.exports = { processListings };
