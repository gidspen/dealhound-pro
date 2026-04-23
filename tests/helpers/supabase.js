import { createClient } from '@supabase/supabase-js';

export function getTestSupabase() {
  const url = process.env.SUPABASE_URL;
  const key = process.env.SUPABASE_SERVICE_KEY;
  if (!url || !key) {
    throw new Error('Missing SUPABASE_URL or SUPABASE_SERVICE_KEY env vars');
  }
  return createClient(url, key);
}

export async function cleanupTestData(supabase, email) {
  const { data: searches } = await supabase
    .from('deal_searches')
    .select('id')
    .eq('user_email', email)
    .eq('test_data', true);

  const searchIds = (searches || []).map(s => s.id);

  if (searchIds.length > 0) {
    await supabase.from('deals').delete().in('search_id', searchIds);
    await supabase.from('scan_progress').delete().in('search_id', searchIds);
    await supabase.from('conversations').delete().in('search_id', searchIds);
    await supabase.from('deal_searches').delete().in('id', searchIds);
  }

  await supabase.from('conversations').delete().eq('user_email', email);
}
