const { createClient } = require('@supabase/supabase-js');
const runPipeline = require('./scan-pipeline');

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

    // Seed the init progress step
    await supabase.from('scan_progress').insert([
      { search_id, step: 'init', status: 'complete', message: 'Buy box loaded — starting scan', listing_count: null },
    ]);

    // Send response immediately so the frontend starts polling
    res.json({ status: 'scanning', search_id });

    // Run the pipeline inline after the response is sent
    // Vercel keeps the function alive for maxDuration (300s) after res.end()
    await runPipeline(search_id);

  } catch (err) {
    console.error('Scan start error:', err);
    if (!res.headersSent) {
      return res.status(500).json({ error: 'Internal server error' });
    }
  }
};
