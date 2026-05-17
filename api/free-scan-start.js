// api/free-scan-start.js
//
// Public free scan endpoint. No auth required.
// Rate limited to 1 scan per IP per 24 hours via Supabase.
// Inserts into free_scan_requests, then queues a scrape_job.
// Also creates a draft buy_box row for the submitting email.

const { createClient } = require('@supabase/supabase-js');
const { deriveBuyBoxName } = require('./_lib/buy-box-name');

const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_KEY);

module.exports = async function handler(req, res) {
  if (req.method === 'OPTIONS') {
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
    return res.status(200).end();
  }

  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  res.setHeader('Access-Control-Allow-Origin', '*');

  const { assetType, market, priceMin, priceMax, email, _hp } = req.body || {};

  // Honeypot check — bots fill hidden fields, humans don't
  if (_hp && _hp.trim() !== '') {
    // Silently accept to avoid tipping off bots
    return res.json({ success: true, scanId: 'hp-' + Date.now() });
  }

  // Field validation
  if (!assetType || !market || priceMin == null || priceMax == null || !email) {
    return res.status(400).json({ error: 'All fields are required.' });
  }

  if (typeof email !== 'string' || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
    return res.status(400).json({ error: 'Invalid email address.' });
  }

  if (isNaN(parseFloat(priceMin)) || isNaN(parseFloat(priceMax))) {
    return res.status(400).json({ error: 'Price range must be numeric.' });
  }

  if (parseFloat(priceMax) <= parseFloat(priceMin)) {
    return res.status(400).json({ error: 'Max price must be greater than min price.' });
  }

  // Resolve client IP — Vercel sets x-forwarded-for
  const ip =
    (req.headers['x-forwarded-for'] || '').split(',')[0].trim() ||
    req.socket?.remoteAddress ||
    'unknown';

  try {
    // Email rate limit: 1 free scan per email lifetime (no date filter)
    const { count: emailCount, error: emailCountError } = await supabase
      .from('free_scan_requests')
      .select('id', { count: 'exact', head: true })
      .eq('email', email);

    if (emailCountError) {
      console.error('free-scan-start: email rate limit check failed:', emailCountError);
      // Fail open
    } else if (emailCount >= 1) {
      return res.status(429).json({
        error: "You've already used your free scan. Become a Founding Member to run more.",
      });
    }

    // IP rate limit: 1 free scan per IP per 24 hours
    const since = new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString();
    const { count, error: countError } = await supabase
      .from('free_scan_requests')
      .select('id', { count: 'exact', head: true })
      .eq('ip', ip)
      .gte('created_at', since);

    if (countError) {
      console.error('free-scan-start: rate limit check failed:', countError);
      // Fail open — don't block the user if the check itself errors
    } else if (count >= 1) {
      return res.status(429).json({ error: 'One free scan per day per IP.' });
    }

    // Build buy_box object mirroring the shape the worker expects
    const buyBox = {
      asset_type: assetType,
      market,
      price_min: parseFloat(priceMin),
      price_max: parseFloat(priceMax),
    };

    // Ensure the users row exists (buy_boxes.user_email is FK'd to users.email).
    // This is a silent upsert — if the row already exists nothing changes.
    const { error: usersUpsertError } = await supabase
      .from('users')
      .upsert({ email, agent_name: 'Scout' }, { onConflict: 'email', ignoreDuplicates: true });
    if (usersUpsertError) {
      console.error('free-scan-start: users upsert error:', usersUpsertError);
    }

    // Insert a draft buy_box for this email so the criteria persists. We do this
    // BEFORE deal_searches so we can stamp buy_box_id onto the search row.
    const buyBoxName = deriveBuyBoxName(buyBox);
    const { data: buyBoxRow, error: buyBoxInsertError } = await supabase
      .from('buy_boxes')
      .insert({
        user_email: email,
        name: buyBoxName,
        criteria: buyBox,
        status: 'active', // 'draft' was silently ignored by the scheduler (queries WHERE status = 'active')
        version: 1,
      })
      .select('id')
      .single();

    if (buyBoxInsertError) {
      console.error('free-scan-start: buy_boxes insert error:', buyBoxInsertError);
      // Non-fatal — continue without linking buy_box_id so the scan still runs.
    }

    const buyBoxId = buyBoxRow?.id || null;

    // Insert deal_searches row FIRST — scrape_jobs.search_id is FK'd to
    // deal_searches.id, so we can't reuse the free_scan_requests.id directly.
    // The worker reads deal_searches.user_email via resolveUserEmail() and writes
    // deals.search_id pointing back here, so the dashboard's existing
    // search_id-based queries work uniformly for paid + free scans.
    const { data: searchRow, error: searchInsertError } = await supabase
      .from('deal_searches')
      .insert({
        user_email: email,
        buy_box: buyBox,
        status: 'pending',
        ...(buyBoxId ? { buy_box_id: buyBoxId, buy_box_version: 1 } : {}),
      })
      .select('id')
      .single();

    if (searchInsertError) {
      console.error('free-scan-start: deal_searches insert error:', searchInsertError);
      return res.status(500).json({ error: 'Failed to queue scan. Please try again.' });
    }

    const searchId = searchRow.id;

    // Insert free_scan_request row — keeps IP rate-limit, source provenance,
    // and free-scan-specific fields (asset_type/market/price_min/price_max as
    // flat columns) separate from the canonical deal_searches table.
    const { data: scanRow, error: insertError } = await supabase
      .from('free_scan_requests')
      .insert({
        email,
        asset_type: assetType,
        market,
        price_min: parseFloat(priceMin),
        price_max: parseFloat(priceMax),
        ip,
        status: 'queued',
        buy_box: buyBox,
      })
      .select('id')
      .single();

    if (insertError) {
      console.error('free-scan-start: free_scan_requests insert error:', insertError);
      // Roll back the deal_searches row to avoid orphans.
      await supabase.from('deal_searches').delete().eq('id', searchId);
      return res.status(500).json({ error: 'Failed to queue scan. Please try again.' });
    }

    const freeScanId = scanRow.id;

    // Insert scrape_job pointing at the deal_searches row. Worker picks it up.
    const { error: jobError } = await supabase.from('scrape_jobs').insert({
      search_id: searchId,
      buy_box: buyBox,
      status: 'pending',
      source: 'free_scan', // lets worker distinguish free vs paid
      notify_email: email, // worker uses this to send result email
    });

    if (jobError) {
      console.error('free-scan-start: scrape_jobs insert error:', jobError);
      // Mark free_scan_requests row as failed so the UI/admin sees it; the
      // deal_searches row is left in 'pending' so a manual requeue can flip it.
      await supabase.from('free_scan_requests').update({ status: 'failed' }).eq('id', freeScanId);
      return res.status(500).json({ error: 'Failed to start scan. Please try again.' });
    }

    // Mark as running
    await supabase.from('free_scan_requests').update({ status: 'running' }).eq('id', freeScanId);

    // Return searchId (not freeScanId) so the front-end and downstream magic-link
    // both reference the deal_searches row. The free_scan_requests row is an
    // internal/admin artifact.
    return res.json({ success: true, scanId: searchId });
  } catch (err) {
    console.error('free-scan-start: unexpected error:', err);
    if (!res.headersSent) {
      return res.status(500).json({ error: 'Internal server error.' });
    }
  }
};
