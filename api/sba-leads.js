// api/sba-leads.js
const { createClient } = require('@supabase/supabase-js');
const { readFileSync, existsSync } = require('fs');
const { join } = require('path');

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_KEY
);

// Load mock fixture as fallback
function loadMockData() {
  const fixturePath = join(__dirname, '..', 'tests', 'fixtures', 'sba-mock-leads.json');
  if (existsSync(fixturePath)) {
    return JSON.parse(readFileSync(fixturePath, 'utf8'));
  }
  return [];
}

module.exports = async function handler(req, res) {
  if (req.method === 'OPTIONS') {
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
    return res.status(200).end();
  }
  if (req.method !== 'GET') return res.status(405).json({ error: 'Method not allowed' });
  res.setHeader('Access-Control-Allow-Origin', '*');

  const { email, scan_id } = req.query;
  if (!email) return res.status(400).json({ error: 'Missing email' });

  try {
    // Try Supabase first
    let query = supabase
      .from('sba_leads')
      .select('*')
      .order('retirement_score', { ascending: false });

    if (scan_id) {
      query = query.eq('scan_id', scan_id);
    } else {
      // Get user's leads
      const { data: user } = await supabase
        .from('users')
        .select('id')
        .eq('email', email)
        .single();

      if (user) {
        query = query.eq('user_id', user.id);
      }
    }

    const { data: leads, error } = await query;

    if (error) {
      console.warn('sba_leads query error (table may not exist):', error.message);
      // Fall back to mock data
      return res.json({ leads: loadMockData(), source: 'mock' });
    }

    if (leads && leads.length > 0) {
      return res.json({ leads, source: 'supabase' });
    }

    // No leads in DB — return mock fixture
    return res.json({ leads: loadMockData(), source: 'mock' });

  } catch (err) {
    console.error('sba-leads error:', err);
    // Last resort fallback
    return res.json({ leads: loadMockData(), source: 'mock-fallback' });
  }
};
