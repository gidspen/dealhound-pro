// api/free-scan-start.js
//
// Public free scan endpoint. No auth required.
// Rate limited to 1 scan per IP per 24 hours via Supabase.
// Inserts into free_scan_requests, then queues a scrape_job.

const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_KEY
);

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

    // Insert free_scan_request row
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
      console.error('free-scan-start: insert error:', insertError);
      return res.status(500).json({ error: 'Failed to queue scan. Please try again.' });
    }

    const scanId = scanRow.id;

    // Trigger async worker — same pattern as scan-start.js
    // Insert a scrape_job so the worker picks it up
    const { error: jobError } = await supabase.from('scrape_jobs').insert({
      search_id: scanId,
      buy_box: buyBox,
      status: 'pending',
      source: 'free_scan',   // lets worker distinguish free vs paid
      notify_email: email,   // worker uses this to send result email
    });

    if (jobError) {
      console.error('free-scan-start: scrape_jobs insert error:', jobError);
      // Update request to failed state — don't hard-fail the response,
      // but do return an error so the UI knows
      await supabase
        .from('free_scan_requests')
        .update({ status: 'failed' })
        .eq('id', scanId);
      return res.status(500).json({ error: 'Failed to start scan. Please try again.' });
    }

    // Mark as running
    await supabase
      .from('free_scan_requests')
      .update({ status: 'running' })
      .eq('id', scanId);

    return res.json({ success: true, scanId });

  } catch (err) {
    console.error('free-scan-start: unexpected error:', err);
    if (!res.headersSent) {
      return res.status(500).json({ error: 'Internal server error.' });
    }
  }
};
