const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_KEY
);

const AGENT_NAMES = [
  'Scout', 'Nora', 'Kit', 'Stella', 'Sophie', 'Quinn',
  'Wren', 'Ellis', 'Reid', 'Sloane', 'Harper', 'Hunter'
];

async function getOrCreateUser(email) {
  const { data: existing } = await supabase
    .from('users')
    .select('email, agent_name')
    .eq('email', email)
    .single();

  if (existing) return existing;

  const agentName = AGENT_NAMES[Math.floor(Math.random() * AGENT_NAMES.length)];
  const { data: created, error } = await supabase
    .from('users')
    .insert({ email, agent_name: agentName })
    .select('email, agent_name')
    .single();

  if (error) throw error;
  return created;
}

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

  const { email } = req.query;
  if (!email) {
    return res.status(400).json({ error: 'Missing email' });
  }

  try {
    const user = await getOrCreateUser(email);

    // Scans with deal counts
    const { data: scans } = await supabase
      .from('deal_searches')
      .select('id, buy_box, status, run_at')
      .eq('user_email', email)
      .order('run_at', { ascending: false })
      .limit(20);

    // Get conversation_ids for scan debriefs
    const scanIds = (scans || []).map(s => s.id);
    let scanConvos = [];
    if (scanIds.length > 0) {
      const { data } = await supabase
        .from('conversations')
        .select('id, search_id')
        .eq('conversation_type', 'scan_debrief')
        .eq('user_email', email)
        .in('search_id', scanIds);
      scanConvos = data || [];
    }
    const scanConvoMap = {};
    scanConvos.forEach(c => { scanConvoMap[c.search_id] = c.id; });

    // Deals from all scans (passed hard filters only)
    let deals = [];
    if (scanIds.length > 0) {
      const { data } = await supabase
        .from('deals')
        .select('id, title, location, price, acreage, rooms_keys, score_breakdown, source, url, search_id, passed_hard_filters')
        .in('search_id', scanIds)
        .eq('passed_hard_filters', true)
        .order('id', { ascending: false })
        .limit(50);
      deals = data || [];
    }

    // Star status
    const dealIds = deals.map(d => d.id);
    let starredIds = new Set();
    if (dealIds.length > 0) {
      const { data: stars } = await supabase
        .from('user_deal_stars')
        .select('deal_id')
        .eq('user_email', email)
        .in('deal_id', dealIds);
      starredIds = new Set((stars || []).map(s => s.deal_id));
    }

    // Active deal threads
    const { data: threadConvos } = await supabase
      .from('conversations')
      .select('id, deal_id')
      .eq('conversation_type', 'deal_qa')
      .eq('user_email', email)
      .not('deal_id', 'is', null);

    // Deal counts per scan
    const dealCountMap = {};
    deals.forEach(d => {
      dealCountMap[d.search_id] = (dealCountMap[d.search_id] || 0) + 1;
    });

    return res.status(200).json({
      agent_name: user.agent_name,
      scans: (scans || []).map(s => ({
        id: s.id,
        buy_box: s.buy_box,
        status: s.status,
        run_at: s.run_at,
        deal_count: dealCountMap[s.id] || 0,
        conversation_id: scanConvoMap[s.id] || null
      })),
      deals: deals.map(d => ({
        id: d.id,
        title: d.title,
        location: d.location,
        price: d.price,
        acreage: d.acreage,
        rooms_keys: d.rooms_keys,
        score_breakdown: d.score_breakdown,
        source: d.source,
        url: d.url,
        search_id: d.search_id,
        starred: starredIds.has(d.id)
      })),
      active_threads: (threadConvos || []).map(c => ({
        deal_id: c.deal_id,
        conversation_id: c.id
      }))
    });

  } catch (err) {
    console.error('user-data error:', err.message);
    return res.status(500).json({ error: 'Failed to fetch user data' });
  }
};
