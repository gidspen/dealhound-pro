// @ts-check
const { createClient } = require('@supabase/supabase-js');

/** @type {import('@supabase/supabase-js').SupabaseClient<import('../types/database').Database>} */
const supabase = createClient(
  process.env.SUPABASE_URL ?? '',
  process.env.SUPABASE_SERVICE_KEY ?? ''
);

const AGENT_NAMES = [
  'Scout',
  'Nora',
  'Kit',
  'Stella',
  'Sophie',
  'Quinn',
  'Wren',
  'Ellis',
  'Reid',
  'Sloane',
  'Harper',
  'Hunter',
];

/**
 * @param {string} email
 */
async function getOrCreateUser(email) {
  const { data: existing } = await supabase
    .from('users')
    .select('email, agent_name')
    .eq('email', email)
    .single();

  if (existing) return existing;

  const agentName = AGENT_NAMES[Math.floor(Math.random() * AGENT_NAMES.length)];
  // ignoreDuplicates handles concurrent first-time inserts (two smoke runs racing)
  const { error: upsertError } = await supabase
    .from('users')
    .upsert({ email, agent_name: agentName }, { onConflict: 'email', ignoreDuplicates: true });

  if (upsertError) throw upsertError;

  const { data, error } = await supabase
    .from('users')
    .select('email, agent_name')
    .eq('email', email)
    .single();

  if (error) throw error;
  return data;
}

/**
 * @param {import('http').IncomingMessage & { method?: string; query?: Record<string, string> }} req
 * @param {import('http').ServerResponse & { status: (n: number) => any; json: (v: unknown) => any; setHeader: (k: string, v: string) => void }} res
 */
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

  const email = req.query ? req.query['email'] : undefined;
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
    const scanIds = (scans || []).map((s) => s.id);
    /** @type {Array<{ id: string; search_id: string | null }>} */
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
    /** @type {Record<string, string>} */
    const scanConvoMap = {};
    scanConvos.forEach((c) => {
      if (c.search_id) scanConvoMap[c.search_id] = c.id;
    });

    // Deals from all scans (passed hard filters only)
    /** @type {Array<import('../types/database').Database['public']['Tables']['deals']['Row']>} */
    let deals = [];
    if (scanIds.length > 0) {
      const { data } = await supabase
        .from('deals')
        .select(
          'id, title, location, price, acreage, rooms_keys, score_breakdown, source, url, search_id, passed_hard_filters, brief, days_on_market, property_type, raw_description, deal_status'
        )
        .in('search_id', scanIds)
        .eq('passed_hard_filters', true)
        .order('id', { ascending: false })
        .limit(50);
      deals = data || [];
    }

    // Fetch star/view/archive/thread status in parallel
    const dealIds = deals.map((d) => d.id);
    const [starsRes, viewsRes, archivesRes, threadConvosRes] = await Promise.all([
      dealIds.length > 0
        ? supabase
            .from('user_deal_stars')
            .select('deal_id')
            .eq('user_email', email)
            .in('deal_id', dealIds)
        : Promise.resolve({ data: [] }),
      dealIds.length > 0
        ? supabase
            .from('user_deal_views')
            .select('deal_id')
            .eq('user_email', email)
            .in('deal_id', dealIds)
        : Promise.resolve({ data: [] }),
      dealIds.length > 0
        ? supabase
            .from('user_deal_archives')
            .select('deal_id')
            .eq('user_email', email)
            .in('deal_id', dealIds)
        : Promise.resolve({ data: [] }),
      supabase
        .from('conversations')
        .select('id, deal_id')
        .eq('conversation_type', 'deal_qa')
        .eq('user_email', email)
        .not('deal_id', 'is', null),
    ]);

    const starredIds = new Set((starsRes.data || []).map((s) => s.deal_id));
    const viewedIds = new Set((viewsRes.data || []).map((v) => v.deal_id));
    const archivedIds = new Set((archivesRes.data || []).map((a) => a.deal_id));
    const threadConvos = threadConvosRes.data || [];

    // Deal counts per scan
    /** @type {Record<string, number>} */
    const dealCountMap = {};
    deals.forEach((d) => {
      if (d.search_id) dealCountMap[d.search_id] = (dealCountMap[d.search_id] || 0) + 1;
    });

    return res.status(200).json({
      agent_name: user.agent_name,
      scans: (scans || []).map((s) => ({
        id: s.id,
        buy_box: s.buy_box,
        status: s.status,
        run_at: s.run_at,
        deal_count: dealCountMap[s.id] || 0,
        conversation_id: scanConvoMap[s.id] || null,
      })),
      deals: deals.map((d) => ({
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
        starred: starredIds.has(d.id),
        viewed: viewedIds.has(d.id),
        archived: archivedIds.has(d.id),
        brief: d.brief || null,
        days_on_market: d.days_on_market || null,
        property_type: d.property_type || null,
        raw_description: d.raw_description || null,
        deal_status: d.deal_status || null,
      })),
      active_threads: (threadConvos || []).map((c) => ({
        deal_id: c.deal_id,
        conversation_id: c.id,
      })),
    });
  } catch (err) {
    const message = err instanceof Error ? err.message : String(err);
    console.error('user-data error:', message);
    return res.status(500).json({ error: 'Failed to fetch user data' });
  }
};
