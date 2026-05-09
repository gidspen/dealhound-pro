// api/sba-scan-start.js
const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_KEY
);

module.exports = async function handler(req, res) {
  // CORS
  if (req.method === 'OPTIONS') {
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
    return res.status(200).end();
  }
  if (req.method !== 'POST') return res.status(405).json({ error: 'Method not allowed' });
  res.setHeader('Access-Control-Allow-Origin', '*');

  const { email, vertical, state, city, lead_count } = req.body;
  if (!email) return res.status(400).json({ error: 'Missing email' });

  try {
    // Look up user
    const { data: user } = await supabase
      .from('users')
      .select('id')
      .eq('email', email)
      .single();

    if (!user) return res.status(404).json({ error: 'User not found' });

    // Create sba_scans row
    const { data: scan, error: scanError } = await supabase
      .from('sba_scans')
      .insert({
        user_id: user.id,
        vertical: vertical || 'dental',
        state: state || 'TX',
        city: city || null,
        target_lead_count: lead_count || 20,
        status: 'scanning'
      })
      .select('id')
      .single();

    if (scanError) {
      console.error('sba_scans insert error:', scanError);
      // Fallback: return a mock scan_id if table doesn't exist yet
      return res.json({
        status: 'mock',
        scan_id: 'mock-scan-' + Date.now(),
        message: 'SBA table not yet migrated — returning mock scan ID'
      });
    }

    return res.json({ status: 'scanning', scan_id: scan.id });
  } catch (err) {
    console.error('sba-scan-start error:', err);
    return res.status(500).json({ error: 'Internal server error' });
  }
};
