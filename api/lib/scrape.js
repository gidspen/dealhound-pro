// api/lib/scrape.js

const SCRAPER_URL = process.env.SCRAPER_SERVICE_URL || 'http://localhost:8080';
const SCRAPER_TOKEN = process.env.SCRAPER_API_TOKEN || '';

/**
 * Phase 2: Call Railway Playwright scraper service.
 *
 * Sends buy box locations and property types to the scraper,
 * which runs headless Chromium against marketplace sites.
 *
 * Reference: ~/.claude/skills/find-deals/scrape-site.md
 * Scraper source: scraper-service/scraper.py (from /find-deals skill)
 */
async function scrapeMarketplaces(buyBox) {
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
