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

  const { id, email } = req.query;
  if (!id || !email) {
    return res.status(400).json({ error: 'Missing id or email' });
  }

  try {
    const { data, error } = await supabase
      .from('conversations')
      .select('id, conversation_type, messages, deal_id, search_id')
      .eq('id', id)
      .eq('user_email', email)
      .single();

    if (error || !data) {
      return res.status(404).json({ error: 'Conversation not found' });
    }

    return res.status(200).json(data);

  } catch (err) {
    console.error('conversation error:', err.message);
    return res.status(500).json({ error: 'Failed to fetch conversation' });
  }
};
