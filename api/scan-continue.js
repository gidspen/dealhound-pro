// api/scan-continue.js
// Webhook endpoint — Railway scraper calls this when scraping completes.
// Reads raw listings from Supabase, runs filter + score via process-listings.js.
// Idempotent: if Railway retries, it re-reads the same data.

const { createClient } = require('@supabase/supabase-js');
const { processListings } = require('./_lib/process-listings.js');

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_KEY
);

module.exports = async function handler(req, res) {
  if (req.method === 'OPTIONS') return res.status(200).end();
  if (req.method !== 'POST') return res.status(405).json({ error: 'POST only' });

  // Auth via header (not query string — keeps secret out of logs)
  const secret = req.headers['x-webhook-secret'] || '';
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
    // markComplete=true — this is the final step, scan is done
    // IMPORTANT: await ALL work before responding (Vercel may kill after res.json)
    const result = await processListings(search_id, rawListings, search.buy_box, true);

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
