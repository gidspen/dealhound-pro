// api/scan-start.js
const { createClient } = require('@supabase/supabase-js');
const { triggerScan } = require('./_lib/scan-trigger');
const { checkPaywall, incrementAgentRuns } = require('./_lib/paywall');

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

    // Gate: check subscription before triggering the scan
    const paywall = await checkPaywall(search.user_email, supabase);
    if (!paywall.allowed) {
      return res.status(paywall.status).json(paywall.body);
    }

    await triggerScan(search_id, search.buy_box, supabase);

    // Increment run counter after successful scan trigger (not on error)
    await incrementAgentRuns(search.user_email, supabase);

    await supabase.from('scan_progress').insert([
      { search_id, step: 'init', status: 'complete', message: 'Buy box loaded - queuing scan job' },
      { search_id, step: 'queued', status: 'running', message: 'Waiting for deal scanner to pick up your request...' },
    ]);

    return res.json({ status: 'queued', search_id });

  } catch (err) {
    console.error('Scan start error:', err);
    if (!res.headersSent) {
      return res.status(500).json({ error: 'Internal server error' });
    }
  }
};
