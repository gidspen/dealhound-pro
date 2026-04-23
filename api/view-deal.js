const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_KEY
);

module.exports = async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');

  if (req.method === 'OPTIONS') {
    res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
    return res.status(200).end();
  }

  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const { email, deal_id } = req.body;

  if (!email || !deal_id) {
    return res.status(400).json({ error: 'Missing email or deal_id' });
  }

  try {
    const { error } = await supabase
      .from('user_deal_views')
      .upsert({ user_email: email, deal_id, viewed_at: new Date().toISOString() }, { onConflict: 'user_email,deal_id' });

    if (error) throw error;

    return res.status(200).json({ ok: true });

  } catch (err) {
    console.error('view-deal error:', err.message);
    return res.status(500).json({ error: 'Failed to record view' });
  }
};
