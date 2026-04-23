const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_KEY
);

module.exports = async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');

  try {
    const { error } = await supabase.from('users').select('email').limit(1);
    if (error) throw error;
    return res.status(200).json({ status: 'ok', timestamp: new Date().toISOString() });
  } catch (err) {
    console.error('Health check failed:', err.message);
    return res.status(500).json({ status: 'error', error: err.message });
  }
};
