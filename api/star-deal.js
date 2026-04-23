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

  const { email, deal_id, starred } = req.body;

  if (!email || !deal_id || typeof starred !== 'boolean') {
    return res.status(400).json({ error: 'Missing email, deal_id, or starred (boolean)' });
  }

  try {
    if (starred) {
      const { error } = await supabase
        .from('user_deal_stars')
        .upsert({ user_email: email, deal_id }, { onConflict: 'user_email,deal_id' });
      if (error) throw error;
    } else {
      const { error } = await supabase
        .from('user_deal_stars')
        .delete()
        .eq('user_email', email)
        .eq('deal_id', deal_id);
      if (error) throw error;
    }

    return res.status(200).json({ ok: true });

  } catch (err) {
    console.error('star-deal error:', err.message);
    return res.status(500).json({ error: 'Failed to update star' });
  }
};
