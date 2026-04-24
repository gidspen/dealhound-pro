const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_KEY
);

module.exports = async function handler(req, res) {
  if (req.method === 'OPTIONS') {
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
    return res.status(200).end();
  }

  if (req.method !== 'GET') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  res.setHeader('Access-Control-Allow-Origin', '*');

  const searchId = req.query.id;

  if (!searchId) {
    return res.status(400).json({ error: 'Missing id parameter' });
  }

  try {
    // Get search status
    const { data: search, error: searchError } = await supabase
      .from('deal_searches')
      .select('status, buy_box, user_email')
      .eq('id', searchId)
      .single();

    if (searchError || !search) {
      return res.status(404).json({ error: 'Search not found' });
    }

    // Get progress steps
    const { data: steps } = await supabase
      .from('scan_progress')
      .select('*')
      .eq('search_id', searchId)
      .order('created_at', { ascending: true });

    // Detect stale scans (no new progress in 5 minutes)
    const isStale = search.status === 'scanning' &&
      steps && steps.length > 0 &&
      (new Date() - new Date(steps[steps.length - 1].created_at)) > 5 * 60 * 1000;

    // If complete, get deal count
    let dealCount = 0;
    let hotCount = 0;
    if (search.status === 'complete') {
      const { count } = await supabase
        .from('deals')
        .select('*', { count: 'exact', head: true })
        .eq('search_id', searchId)
        .eq('passed_hard_filters', true);
      dealCount = count || 0;

      const { data: hotDeals } = await supabase
        .from('deals')
        .select('score_breakdown')
        .eq('search_id', searchId)
        .eq('passed_hard_filters', true);

      if (hotDeals) {
        hotCount = hotDeals.filter(d => {
          const strategy = d.score_breakdown?.strategy?.overall;
          return strategy === 'STRONG MATCH';
        }).length;
      }
    }

    return res.json({
      status: isStale ? 'error' : search.status,
      buy_box: search.buy_box,
      steps: steps || [],
      stale: isStale,
      summary: search.status === 'complete' ? {
        total_deals: dealCount,
        hot_deals: hotCount
      } : null
    });

  } catch (err) {
    console.error('Scan progress error:', err);
    return res.status(500).json({ error: 'Internal server error' });
  }
};
