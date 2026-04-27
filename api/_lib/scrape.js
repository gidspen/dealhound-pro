// api/_lib/scrape.js

const SCRAPER_URL = process.env.SCRAPER_SERVICE_URL || 'http://localhost:8080';
const SCRAPER_TOKEN = process.env.SCRAPER_API_TOKEN || '';
const WEBHOOK_SECRET = process.env.SCRAPER_WEBHOOK_SECRET || '';

/**
 * Phase 2: Call Railway Playwright scraper service.
 *
 * Sends buy box locations, property types, discovered sites, and search_id
 * to the scraper. The scraper writes raw listings to Supabase, then calls
 * back to /api/scan-continue when done.
 */
async function scrapeMarketplaces(buyBox, sites, searchId) {
  const baseUrl = process.env.VERCEL_URL
    ? `https://${process.env.VERCEL_URL}`
    : 'http://localhost:3000';

  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), 120000);

  try {
    const res = await fetch(`${SCRAPER_URL}/scrape`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      signal: controller.signal,
      body: JSON.stringify({
        locations: buyBox.locations || [],
        property_types: buyBox.property_types || [],
        sites: sites || [],
        search_id: searchId || '',
        callback_url: `${baseUrl}/api/scan-continue`,
        callback_secret: WEBHOOK_SECRET,
        token: SCRAPER_TOKEN,
      }),
    });

    if (!res.ok) {
      const text = await res.text();
      throw new Error(`Scraper returned ${res.status}: ${text}`);
    }

    return await res.json();
  } finally {
    clearTimeout(timeout);
  }
}

module.exports = { scrapeMarketplaces };
