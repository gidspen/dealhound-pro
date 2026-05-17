const { addToKitNurture } = require('../worker/kit-nurture');

// Domains that bypass the waitlist and get redirected into the product.
// Set KIT_PREVIEW_DOMAINS=stonemontcap.com,incredibleai.pro in Vercel env.
const PREVIEW_DOMAINS = (process.env.KIT_PREVIEW_DOMAINS || '')
  .split(',').map(d => d.trim().toLowerCase()).filter(Boolean);

module.exports = async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') return res.status(200).end();
  if (req.method !== 'POST') return res.status(405).json({ error: 'Method not allowed' });

  const { email } = req.body || {};
  if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
    return res.status(400).json({ error: 'Valid email required' });
  }

  const normalised = email.toLowerCase().trim();
  const domain = normalised.split('@')[1] || '';

  // Internal preview bypass — still subscribes them, then signals a redirect
  const isPreview = PREVIEW_DOMAINS.includes(domain);

  const tag = process.env.KIT_WAITLIST_TAG || 'Deal Hunter Early Access';
  await addToKitNurture({ email: normalised, tag });

  return res.status(200).json({ ok: true, redirect: isPreview ? '/dashboard' : null });
};
