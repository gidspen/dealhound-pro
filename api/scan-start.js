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

    // Seed the init progress step
    await supabase.from('scan_progress').insert([
      { search_id, step: 'init', status: 'complete', message: 'Buy box loaded — starting scan', listing_count: null },
    ]);

    // Fire the real scan pipeline (non-blocking)
    // The pipeline function scrapes marketplaces, filters, scores with Claude,
    // and updates scan_progress + deal_searches as it goes
    const pipelineUrl = `https://${req.headers.host}/api/scan-pipeline`;
    fetch(pipelineUrl, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ search_id }),
    }).catch(err => console.error('Pipeline trigger failed:', err.message));

    return res.json({ status: 'scanning', search_id });

  } catch (err) {
    console.error('Scan start error:', err);
    return res.status(500).json({ error: 'Internal server error' });
  }
};
