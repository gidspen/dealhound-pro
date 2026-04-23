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

  const { email, deal_id, archived } = req.body;

  // Validate required fields
  if (!email || !deal_id || typeof archived !== 'boolean') {
    return res.status(400).json({ error: 'Missing or invalid fields: email, deal_id, archived' });
  }

  try {
    if (archived === true) {
      // Upsert into user_deal_archives
      const { error } = await supabase
        .from('user_deal_archives')
        .upsert(
          {
            user_email: email,
            deal_id: deal_id,
            archived_at: new Date().toISOString()
          },
          { onConflict: 'user_email,deal_id' }
        );

      if (error) throw error;
    } else {
      // Delete from user_deal_archives
      const { error } = await supabase
        .from('user_deal_archives')
        .delete()
        .eq('user_email', email)
        .eq('deal_id', deal_id);

      if (error) throw error;
    }

    return res.status(200).json({ ok: true });
  } catch (error) {
    console.error('Archive deal error:', error);
    return res.status(500).json({ error: error.message });
  }
};
