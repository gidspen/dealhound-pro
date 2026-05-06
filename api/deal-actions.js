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

  const { action, email, deal_id, starred, archived } = req.body;

  if (!action || !email || !deal_id) {
    return res.status(400).json({ error: 'Missing action, email, or deal_id' });
  }

  try {
    if (action === 'star') {
      if (typeof starred !== 'boolean') {
        return res.status(400).json({ error: 'Missing starred (boolean)' });
      }
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

    } else if (action === 'view') {
      const { error } = await supabase
        .from('user_deal_views')
        .upsert(
          { user_email: email, deal_id, viewed_at: new Date().toISOString() },
          { onConflict: 'user_email,deal_id' }
        );
      if (error) throw error;

    } else if (action === 'archive') {
      if (typeof archived !== 'boolean') {
        return res.status(400).json({ error: 'Missing archived (boolean)' });
      }
      if (archived) {
        const { error } = await supabase
          .from('user_deal_archives')
          .upsert(
            { user_email: email, deal_id, archived_at: new Date().toISOString() },
            { onConflict: 'user_email,deal_id' }
          );
        if (error) throw error;
      } else {
        const { error } = await supabase
          .from('user_deal_archives')
          .delete()
          .eq('user_email', email)
          .eq('deal_id', deal_id);
        if (error) throw error;
      }

    } else {
      return res.status(400).json({ error: `Unknown action: ${action}` });
    }

    return res.status(200).json({ ok: true });

  } catch (err) {
    console.error(`deal-actions [${action}] error:`, err.message);
    return res.status(500).json({ error: 'Failed to update deal' });
  }
};
