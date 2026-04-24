// api/lib/discover.js
const Anthropic = require('@anthropic-ai/sdk');

const anthropic = new Anthropic();

/**
 * Phase 1: Discover marketplaces and individual listings via web search.
 *
 * Extracts keywords from the buy box, searches the web, classifies results
 * into sites (Bucket A) and individual listings (Bucket B).
 *
 * Reference: ~/.claude/skills/find-deals/discover-sites.md
 */
async function discoverListings(buyBox) {
  // Step 1: Extract keywords from buy box
  const propertyTypes = (buyBox.property_types || []).map(t => t.replace(/_/g, ' '));
  const locations = buyBox.locations || [];
  const priceMax = buyBox.price_max || 3000000;

  // Step 2: Generate search queries
  const queries = [];
  for (const pType of propertyTypes) {
    queries.push(`"${pType}" for sale listings`);
    queries.push(`${pType} for sale marketplace broker`);
  }
  for (const loc of locations) {
    for (const pType of propertyTypes.slice(0, 2)) {
      queries.push(`${pType} for sale ${loc}`);
    }
  }

  // Step 3: Search and classify results using Claude
  // We send all queries to Claude with web search enabled and ask it to
  // find and classify results into sites vs individual listings
  const searchPrompt = `You are a real estate deal finder. Search for properties matching these criteria:

PROPERTY TYPES: ${propertyTypes.join(', ')}
LOCATIONS: ${locations.join(', ')}
PRICE RANGE: ${buyBox.price_min && buyBox.price_min !== 'null' ? '$' + Number(buyBox.price_min).toLocaleString() : 'No min'} – $${Number(priceMax).toLocaleString()}

Search these queries:
${queries.map((q, i) => `${i + 1}. ${q}`).join('\n')}

For each result you find, classify it as:
- SITE: A marketplace or broker with multiple listings (e.g., landsearch.com, bizbuysell.com)
- LISTING: A specific property for sale that matches the criteria

Return a JSON object with:
{
  "sites": [{"name": "...", "url": "...", "listings_url": "...", "notes": "..."}],
  "listings": [{"title": "...", "price": number_or_null, "location": "...", "url": "...", "source": "domain.com", "description": "first 200 chars"}]
}

Focus on finding INDIVIDUAL LISTINGS — those are immediate leads. Include sites too but prioritize actual properties for sale. Return ONLY the JSON, no other text.`;

  try {
    const response = await anthropic.messages.create({
      model: 'claude-sonnet-4-20250514',
      max_tokens: 4000,
      messages: [{ role: 'user', content: searchPrompt }],
    });

    const text = response.content[0]?.text || '{}';
    const jsonStr = text.replace(/```json\n?/g, '').replace(/```\n?/g, '').trim();
    return JSON.parse(jsonStr);
  } catch (e) {
    console.error('Discovery failed:', e.message);
    return { sites: [], listings: [] };
  }
}

module.exports = { discoverListings };
