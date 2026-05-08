// @ts-check
const { createClient } = require('@supabase/supabase-js');

/** @type {import('@supabase/supabase-js').SupabaseClient<import('../types/database').Database>} */
const supabase = createClient(
  process.env.SUPABASE_URL ?? '',
  process.env.SUPABASE_SERVICE_KEY ?? ''
);

/**
 * @param {import('http').IncomingMessage & { method?: string; query?: Record<string, string> }} req
 * @param {import('http').ServerResponse & { status: (n: number) => any; json: (v: unknown) => any; setHeader: (k: string, v: string) => void }} res
 */
module.exports = async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');

  try {
    const { error } = await supabase.from('users').select('email').limit(1);
    if (error) throw error;
    return res.status(200).json({ status: 'ok', timestamp: new Date().toISOString() });
  } catch (err) {
    const message = err instanceof Error ? err.message : String(err);
    console.error('Health check failed:', message);
    return res.status(500).json({ status: 'error', error: message });
  }
};
