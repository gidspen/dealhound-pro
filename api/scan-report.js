const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_KEY
);

module.exports = async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');

  if (req.method === 'OPTIONS') {
    res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
    return res.status(200).end();
  }

  if (req.method !== 'GET') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  // ── Magic-link bridge ────────────────────────────────────────────────────
  // Folded into this file to stay under Vercel Hobby's 12-function cap.
  // See vercel.json rewrite: /api/magic-link → /api/scan-report?_action=magic-link.
  if (req.query._action === 'magic-link') {
    const { handleMagicLink } = require('./_lib/magic-link-route');
    return handleMagicLink(req, res);
  }

  const { id } = req.query;

  if (!id) {
    return res.status(400).json({ error: 'Missing id parameter' });
  }

  try {
    const { data: scan, error: scanError } = await supabase
      .from('deal_searches')
      .select('id, buy_box, status, run_at')
      .eq('id', id)
      .single();

    if (scanError || !scan) {
      return res.status(404).json({ error: 'Scan not found' });
    }

    if (scan.status !== 'complete') {
      return res.status(202).json({
        scan: { id: scan.id, status: scan.status, buy_box: scan.buy_box, run_at: scan.run_at },
        deals: []
      });
    }

    const { data: deals, error: dealsError } = await supabase
      .from('deals')
      .select('id, title, location, price, acreage, rooms_keys, score_breakdown, source, url, property_type, brief')
      .eq('search_id', id)
      .eq('passed_hard_filters', true)
      .order('id', { ascending: false })
      .limit(50);

    if (dealsError) {
      console.error('scan-report deals error:', dealsError.message);
      return res.status(500).json({ error: 'Failed to fetch deals' });
    }

    return res.status(200).json({
      scan: {
        id: scan.id,
        status: scan.status,
        buy_box: scan.buy_box,
        run_at: scan.run_at
      },
      deals: deals || []
    });

  } catch (err) {
    console.error('scan-report error:', err.message);
    return res.status(500).json({ error: 'Internal server error' });
  }
};
