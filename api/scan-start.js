const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_KEY
);

module.exports = async function handler(req, res) {
  if (req.method === 'OPTIONS') {
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
    return res.status(200).end();
  }

  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  res.setHeader('Access-Control-Allow-Origin', '*');

  const { search_id } = req.body;

  if (!search_id) {
    return res.status(400).json({ error: 'Missing search_id' });
  }

  try {
    // Get the search record
    const { data: search, error: searchError } = await supabase
      .from('deal_searches')
      .select('*')
      .eq('id', search_id)
      .single();

    if (searchError || !search) {
      return res.status(404).json({ error: 'Search not found' });
    }

    if (search.status === 'scanning' || search.status === 'complete') {
      return res.json({ status: search.status, search_id });
    }

    // Mark as scanning
    await supabase
      .from('deal_searches')
      .update({ status: 'scanning' })
      .eq('id', search_id);

    // Seed progress steps to give the user something to watch
    // In production, these would be written by the actual scan pipeline
    const steps = [
      { search_id, step: 'init', status: 'complete', message: 'Buy box loaded — starting scan', listing_count: null },
      { search_id, step: 'scrape_landsearch', status: 'running', message: 'Searching LandSearch for resort & cabin listings...', listing_count: null },
    ];

    await supabase.from('scan_progress').insert(steps);

    // Simulate progress over time — in production this would be the real pipeline
    // For MVP, we seed initial steps and Gideon runs the scan manually
    // The scan page polls and picks up new rows as they appear
    setTimeout(async () => {
      await supabase.from('scan_progress').insert([
        { search_id, step: 'scrape_landsearch', status: 'complete', message: 'LandSearch — 238 listings found', listing_count: 238 },
        { search_id, step: 'scrape_campground', status: 'running', message: 'Searching Campground Marketplace...', listing_count: null },
      ]);
    }, 3000);

    setTimeout(async () => {
      await supabase.from('scan_progress').insert([
        { search_id, step: 'scrape_campground', status: 'complete', message: 'Campground Marketplace — 71 listings found', listing_count: 71 },
        { search_id, step: 'scrape_nai', status: 'running', message: 'Searching NAI Outdoor Hospitality...', listing_count: null },
      ]);
    }, 6000);

    setTimeout(async () => {
      await supabase.from('scan_progress').insert([
        { search_id, step: 'scrape_nai', status: 'complete', message: 'NAI Outdoor Hospitality — 22 listings found', listing_count: 22 },
        { search_id, step: 'scrape_misc', status: 'complete', message: 'Parks & Places, B&B Team — 110 listings found', listing_count: 110 },
        { search_id, step: 'screening', status: 'running', message: 'Screening 441 listings against your buy box...', listing_count: null },
      ]);
    }, 8000);

    // Note: The scan doesn't actually complete here.
    // When Gideon manually runs the scan and populates results,
    // he updates deal_searches.status to 'complete' and adds final progress rows.
    // The scan page will show "Your agent is working..." until then,
    // with a note that results will be emailed.

    return res.json({ status: 'scanning', search_id });

  } catch (err) {
    console.error('Scan start error:', err);
    return res.status(500).json({ error: 'Internal server error' });
  }
};
