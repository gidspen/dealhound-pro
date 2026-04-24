// api/lib/progress.js
const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_KEY
);

async function writeProgress(searchId, step, status, message, listingCount = null) {
  await supabase.from('scan_progress').insert([
    { search_id: searchId, step, status, message, listing_count: listingCount },
  ]);
}

module.exports = { writeProgress, supabase };
