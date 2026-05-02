// api/_lib/scan-trigger.js
//
// Single source of truth for queuing a scan job. Always queues — no bypass,
// no pool checks, no shortcut. The skill is the only thing that produces
// scored deals for a user, and a scan is the only way to invoke it for a
// given search_id.
//
// Used by:
//   - api/chat.js after a buy box is saved
//   - api/scan-start.js when the dashboard re-triggers a scan

async function triggerScan(searchId, buyBox, supabase) {
  if (!searchId) throw new Error('triggerScan: searchId is required');
  if (!buyBox)   throw new Error('triggerScan: buyBox is required');
  if (!supabase) throw new Error('triggerScan: supabase client is required');

  const { error: jobError } = await supabase.from('scrape_jobs').insert({
    search_id: searchId,
    buy_box: buyBox,
    status: 'pending',
  });
  if (jobError) throw new Error(`triggerScan: scrape_jobs insert failed: ${jobError.message}`);

  const { error: searchError } = await supabase
    .from('deal_searches')
    .update({ status: 'scanning' })
    .eq('id', searchId);
  if (searchError) throw new Error(`triggerScan: deal_searches update failed: ${searchError.message}`);
}

module.exports = { triggerScan };
