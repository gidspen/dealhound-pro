const { createClient } = require('@supabase/supabase-js');
const Anthropic = require('@anthropic-ai/sdk');

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_KEY
);

const anthropic = new Anthropic();

// ── Marketplace scrapers ────────────────────────────────────────────
// Tested against live sites 2026-04-23. LandSearch/BizBuySell/Crexi/LoopNet
// all return 403 (bot protection). LandWatch and LandAndFarm work via
// direct HTTP fetch — they share the same platform and HTML structure.

const SOURCES = [
  {
    name: 'LandWatch',
    step: 'scrape_landwatch',
    message: 'Searching LandWatch for land & hospitality properties...',
    scrape: scrapeLandWatch,
  },
  {
    name: 'Land And Farm',
    step: 'scrape_landandfarm',
    message: 'Searching Land And Farm for rural properties...',
    scrape: scrapeLandAndFarm,
  },
];

// ── LandWatch / LandAndFarm shared parser ───────────────────────────
// Both sites share the same platform. Listing cards use:
//   - href="/county-state-type-for-sale/pid/123456" for listing URLs
//   - <span class="_47a280d">$1,234,567</span> for prices
//   - Acreage in nearby text as "123 Acres" or "42.7 ac"
// Verified against live HTML 2026-04-23.

function parseListingCards(html, state, sourceName, baseUrl) {
  const listings = [];

  // Both LandWatch and LandAndFarm use span._47a280d for prices.
  // LandWatch links: /county-state-type-for-sale/pid/123456
  // LandAndFarm links: /property/property-name-12345678/
  // Match: listing href followed by price span within the same card area
  const cardPattern = /href="(\/(?:property\/[^"]+|[^"]*\/pid\/\d+))"[\s\S]*?<span[^>]*class="_47a280d"[^>]*>(\$[\d,]+)<\/span>/gi;
  let match;

  while ((match = cardPattern.exec(html)) !== null) {
    const url = match[1];
    const price = parsePrice(match[2]);
    if (!price) continue;

    // Extract title from URL slug
    let title;
    if (url.includes('/property/')) {
      // LandAndFarm: /property/luxury-equestrian-estate-41050259/
      title = url.split('/property/')[1]?.replace(/[-/]/g, ' ').replace(/\d{6,}/, '').trim();
    } else {
      // LandWatch: /county-state-type-for-sale/pid/123
      title = url.split('/').filter(Boolean)[0] || '';
      title = title.replace(/-for-sale$/, '').replace(/-/g, ' ');
    }
    title = title.replace(/\b\w/g, c => c.toUpperCase()).trim();

    // Look for acreage in the surrounding 500 chars after this match
    const after = html.substring(match.index, match.index + 500);
    const acresMatch = after.match(/([\d,.]+)\s*(?:Acres?|ac\b)/i);
    const acreage = acresMatch ? parseFloat(acresMatch[1].replace(',', '')) : null;

    // Extract county from URL (LandWatch pattern)
    const countyMatch = url.match(/\/([a-z-]+)-county-/i);
    const county = countyMatch
      ? countyMatch[1].replace(/-/g, ' ').replace(/\b\w/g, c => c.toUpperCase()) + ' County'
      : null;

    listings.push({
      title: title || `Property in ${state}`,
      price,
      acreage,
      location: county ? `${county}, ${state}` : state,
      url: `${baseUrl}${url}`,
      source: sourceName,
      property_type: 'land',
    });
  }

  return dedupeListings(listings, sourceName);
}

async function scrapeLandWatch(buyBox) {
  const listings = [];

  for (const location of buyBox.locations || []) {
    const state = extractState(location);
    if (!state) continue;

    const slug = state.toLowerCase().replace(/\s+/g, '-');
    const url = `https://www.landwatch.com/${slug}-land-for-sale`;

    try {
      const html = await fetchPage(url);
      const parsed = parseListingCards(html, state, 'LandWatch', 'https://www.landwatch.com');
      listings.push(...parsed);
    } catch (e) {
      console.error(`LandWatch failed for ${url}:`, e.message);
    }
  }

  return listings;
}

async function scrapeLandAndFarm(buyBox) {
  const listings = [];

  for (const location of buyBox.locations || []) {
    const state = extractState(location);
    if (!state) continue;

    const slug = state.toLowerCase().replace(/\s+/g, '-');
    const stateAbbrev = getStateAbbrev(state);
    const url = `https://www.landandfarm.com/search/${stateAbbrev}/all-land/`;

    try {
      const html = await fetchPage(url);
      const parsed = parseListingCards(html, state, 'Land And Farm', 'https://www.landandfarm.com');
      listings.push(...parsed);
    } catch (e) {
      console.error(`LandAndFarm failed for ${url}:`, e.message);
    }
  }

  return listings;
}

// ── Utility functions ───────────────────────────────────────────────

async function fetchPage(url) {
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), 15000);

  try {
    const res = await fetch(url, {
      signal: controller.signal,
      headers: {
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        'Accept-Language': 'en-US,en;q=0.9',
      },
    });
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    return await res.text();
  } finally {
    clearTimeout(timeout);
  }
}

function parsePrice(str) {
  return parseInt(str.replace(/[$,]/g, ''), 10) || null;
}

const STATE_ABBREVS = {
  'AL': 'Alabama', 'AK': 'Alaska', 'AZ': 'Arizona', 'AR': 'Arkansas',
  'CA': 'California', 'CO': 'Colorado', 'CT': 'Connecticut', 'DE': 'Delaware',
  'FL': 'Florida', 'GA': 'Georgia', 'HI': 'Hawaii', 'ID': 'Idaho',
  'IL': 'Illinois', 'IN': 'Indiana', 'IA': 'Iowa', 'KS': 'Kansas',
  'KY': 'Kentucky', 'LA': 'Louisiana', 'ME': 'Maine', 'MD': 'Maryland',
  'MA': 'Massachusetts', 'MI': 'Michigan', 'MN': 'Minnesota', 'MS': 'Mississippi',
  'MO': 'Missouri', 'MT': 'Montana', 'NE': 'Nebraska', 'NV': 'Nevada',
  'NH': 'New Hampshire', 'NJ': 'New Jersey', 'NM': 'New Mexico', 'NY': 'New York',
  'NC': 'North Carolina', 'ND': 'North Dakota', 'OH': 'Ohio', 'OK': 'Oklahoma',
  'OR': 'Oregon', 'PA': 'Pennsylvania', 'RI': 'Rhode Island', 'SC': 'South Carolina',
  'SD': 'South Dakota', 'TN': 'Tennessee', 'TX': 'Texas', 'UT': 'Utah',
  'VT': 'Vermont', 'VA': 'Virginia', 'WA': 'Washington', 'WV': 'West Virginia',
  'WI': 'Wisconsin', 'WY': 'Wyoming',
};

function getStateAbbrev(stateName) {
  for (const [abbrev, name] of Object.entries(STATE_ABBREVS)) {
    if (name === stateName) return abbrev;
  }
  return stateName.substring(0, 2).toUpperCase();
}

function extractState(location) {
  // Check for state abbreviation (e.g., "NC", "TX")
  const abbrevMatch = location.match(/\b([A-Z]{2})\b/);
  if (abbrevMatch && STATE_ABBREVS[abbrevMatch[1]]) {
    return STATE_ABBREVS[abbrevMatch[1]];
  }

  // Check for full state name
  const allStates = Object.values(STATE_ABBREVS);
  for (const state of allStates) {
    if (location.toLowerCase().includes(state.toLowerCase())) {
      return state;
    }
  }

  // Check for known regions/cities → state mapping
  const cityStateMap = {
    'dallas': 'Texas', 'houston': 'Texas', 'austin': 'Texas', 'san antonio': 'Texas',
    'hill country': 'Texas', 'lake travis': 'Texas',
    'wilmington': 'North Carolina', 'surf city': 'North Carolina', 'outer banks': 'North Carolina',
    'asheville': 'North Carolina', 'charlotte': 'North Carolina',
    'orlando': 'Florida', 'miami': 'Florida', 'tampa': 'Florida', 'jacksonville': 'Florida',
    'gatlinburg': 'Tennessee', 'pigeon forge': 'Tennessee', 'nashville': 'Tennessee',
    'savannah': 'Georgia', 'atlanta': 'Georgia',
    'myrtle beach': 'South Carolina', 'charleston': 'South Carolina',
    'branson': 'Missouri', 'ozarks': 'Missouri',
    'sedona': 'Arizona', 'scottsdale': 'Arizona',
    'big bear': 'California', 'lake tahoe': 'California', 'napa': 'California',
  };

  const lower = location.toLowerCase();
  for (const [city, state] of Object.entries(cityStateMap)) {
    if (lower.includes(city)) return state;
  }

  return null;
}

function dedupeListings(listings, source) {
  const seen = new Set();
  return listings.filter(l => {
    const key = `${l.title}-${l.price}`;
    if (seen.has(key)) return false;
    seen.add(key);
    return true;
  });
}

// ── Buy box filtering ───────────────────────────────────────────────

function applyHardFilters(listings, buyBox) {
  return listings.map(listing => {
    const reasons = [];

    // Price filter
    if (buyBox.price_max && listing.price > buyBox.price_max) {
      reasons.push(`Price $${listing.price.toLocaleString()} exceeds max $${buyBox.price_max.toLocaleString()}`);
    }
    if (buyBox.price_min && buyBox.price_min !== 'null' && listing.price < buyBox.price_min) {
      reasons.push(`Price $${listing.price.toLocaleString()} below min $${buyBox.price_min.toLocaleString()}`);
    }

    // Acreage filter
    if (buyBox.acreage_min && buyBox.acreage_min !== 'null' && listing.acreage && listing.acreage < buyBox.acreage_min) {
      reasons.push(`Acreage ${listing.acreage} below min ${buyBox.acreage_min}`);
    }

    // Exclusions
    if (buyBox.exclusions && buyBox.exclusions.length > 0) {
      const titleLower = listing.title.toLowerCase();
      const descLower = (listing.raw_description || '').toLowerCase();
      for (const excl of buyBox.exclusions) {
        if (titleLower.includes(excl.toLowerCase()) || descLower.includes(excl.toLowerCase())) {
          reasons.push(`Matches exclusion: "${excl}"`);
        }
      }
    }

    return {
      ...listing,
      passed_hard_filters: reasons.length === 0,
      miss_reason: reasons.length > 0 ? reasons.join('; ') : null,
    };
  });
}

// ── Claude scoring ──────────────────────────────────────────────────

async function scoreDeals(survivors, buyBox) {
  if (survivors.length === 0) return [];

  // Batch survivors into groups of 5 to reduce API calls
  const scored = [];
  const batchSize = 5;

  for (let i = 0; i < survivors.length; i += batchSize) {
    const batch = survivors.slice(i, i + batchSize);

    const prompt = `You are a real estate investment analyst. Score these ${batch.length} properties against the investor's buy box.

BUY BOX:
- Locations: ${(buyBox.locations || []).join(', ')}
- Price range: ${buyBox.price_min && buyBox.price_min !== 'null' ? '$' + Number(buyBox.price_min).toLocaleString() : 'No min'} – $${Number(buyBox.price_max).toLocaleString()}
- Property types: ${(buyBox.property_types || []).join(', ').replace(/_/g, ' ')}
- Revenue requirement: ${(buyBox.revenue_requirement || 'any').replace(/_/g, ' ')}
- Exclusions: ${(buyBox.exclusions || []).join(', ') || 'none'}

PROPERTIES TO SCORE:
${batch.map((d, idx) => `
[${idx + 1}] ${d.title}
  Location: ${d.location}
  Price: $${d.price?.toLocaleString() || 'unknown'}
  Acreage: ${d.acreage || 'unknown'}
  Source: ${d.source}
  Type: ${d.property_type?.replace(/_/g, ' ') || 'unknown'}
`).join('')}

For each property, return a JSON array where each element has:
- "index": the property number (1-based)
- "strategy_overall": one of "STRONG MATCH", "MODERATE MATCH", "WEAK MATCH"
- "strategy_summary": one sentence explaining why
- "risk_level": one of "LOW", "MODERATE", "HIGH", "VERY HIGH"
- "risk_summary": one sentence on key risk factors
- "brief": 2-3 sentence analysis an investor would find useful — what makes this interesting or concerning
- "suggested_next_step": one actionable step (e.g., "Request seller financials", "Drive the property")

Respond with ONLY the JSON array, no other text.`;

    try {
      const response = await anthropic.messages.create({
        model: 'claude-sonnet-4-20250514',
        max_tokens: 2000,
        messages: [{ role: 'user', content: prompt }],
      });

      const text = response.content[0]?.text || '[]';
      // Extract JSON from response (handle markdown code fences)
      const jsonStr = text.replace(/```json\n?/g, '').replace(/```\n?/g, '').trim();
      const scores = JSON.parse(jsonStr);

      for (const score of scores) {
        const deal = batch[score.index - 1];
        if (!deal) continue;

        scored.push({
          ...deal,
          score_breakdown: {
            strategy: {
              overall: score.strategy_overall,
              summary: score.strategy_summary,
            },
            risk: {
              level: score.risk_level,
              summary: score.risk_summary,
            },
          },
          brief: score.brief,
        });
      }
    } catch (e) {
      console.error('Claude scoring failed for batch:', e.message);
      // If scoring fails, still include deals with no score
      for (const deal of batch) {
        scored.push({
          ...deal,
          score_breakdown: {
            strategy: { overall: 'MODERATE MATCH', summary: 'Scoring unavailable — review manually' },
            risk: { level: 'MODERATE', summary: 'Unable to assess — needs manual review' },
          },
          brief: 'Automated scoring was unavailable. Review this listing manually against your buy box.',
        });
      }
    }
  }

  return scored;
}

// ── Progress helper ─────────────────────────────────────────────────

async function writeProgress(searchId, step, status, message, listingCount = null) {
  await supabase.from('scan_progress').insert([
    { search_id: searchId, step, status, message, listing_count: listingCount },
  ]);
}

// ── Main pipeline ───────────────────────────────────────────────────

// Direct function export — called inline by scan-start.js after sending the response
module.exports = async function runPipeline(search_id) {
  try {
    // Load buy box
    const { data: search, error: searchError } = await supabase
      .from('deal_searches')
      .select('*')
      .eq('id', search_id)
      .single();

    if (searchError || !search) {
      console.error('Pipeline: search not found', search_id);
      return;
    }

    const buyBox = search.buy_box;
    let allListings = [];
    let sourcesSucceeded = 0;

    // Scrape each source sequentially
    for (const source of SOURCES) {
      await writeProgress(search_id, source.step, 'running', source.message);

      try {
        const listings = await source.scrape(buyBox);
        allListings.push(...listings);
        sourcesSucceeded++;

        await writeProgress(
          search_id, source.step, 'complete',
          `${source.name} — ${listings.length} listings found`,
          listings.length
        );
      } catch (e) {
        console.error(`Pipeline: ${source.name} failed:`, e.message);
        await writeProgress(
          search_id, source.step, 'error',
          `${source.name} — could not connect (will retry next scan)`
        );
      }
    }

    // If zero sources worked, mark as error
    if (sourcesSucceeded === 0) {
      await writeProgress(search_id, 'screening', 'error', 'All marketplace sources failed — try again later');
      await supabase.from('deal_searches').update({ status: 'error' }).eq('id', search_id);
      return;
    }

    // Apply hard filters
    await writeProgress(
      search_id, 'screening', 'running',
      `Screening ${allListings.length} listings against your buy box...`
    );

    const filtered = applyHardFilters(allListings, buyBox);
    const survivors = filtered.filter(l => l.passed_hard_filters);
    const eliminated = filtered.filter(l => !l.passed_hard_filters);

    await writeProgress(
      search_id, 'screening', 'complete',
      `${allListings.length} listings reviewed — ${survivors.length} survived initial screening`,
      survivors.length
    );

    // Score survivors with Claude
    if (survivors.length > 0) {
      await writeProgress(
        search_id, 'scoring', 'running',
        `Scoring ${survivors.length} matches against your investment strategy...`
      );

      const scored = await scoreDeals(survivors, buyBox);

      // Insert scored deals
      for (const deal of scored) {
        await supabase.from('deals').insert({
          search_id,
          source: deal.source,
          url: deal.url,
          source_url: deal.url,
          title: deal.title,
          price: deal.price,
          acreage: deal.acreage,
          location: deal.location,
          property_type: deal.property_type,
          passed_hard_filters: true,
          score_breakdown: deal.score_breakdown,
          brief: deal.brief,
          raw_description: deal.raw_description || null,
          scraped_at: new Date().toISOString(),
        });
      }

      const hotCount = scored.filter(d => d.score_breakdown?.strategy?.overall === 'STRONG MATCH').length;
      await writeProgress(
        search_id, 'scoring', 'complete',
        `Scoring complete — ${scored.length} deals scored, ${hotCount} strong matches`,
        scored.length
      );
    }

    // Insert eliminated deals (for "show the work" transparency)
    for (const deal of eliminated.slice(0, 50)) { // Cap at 50 to avoid huge inserts
      await supabase.from('deals').insert({
        search_id,
        source: deal.source,
        url: deal.url,
        source_url: deal.url,
        title: deal.title,
        price: deal.price,
        acreage: deal.acreage,
        location: deal.location,
        property_type: deal.property_type,
        passed_hard_filters: false,
        miss_reason: deal.miss_reason,
        score_breakdown: null,
        brief: null,
        raw_description: null,
        scraped_at: new Date().toISOString(),
      });
    }

    // Mark scan as complete
    await supabase
      .from('deal_searches')
      .update({ status: 'complete' })
      .eq('id', search_id);

    await writeProgress(
      search_id, 'complete', 'complete',
      `Scan complete — ${survivors.length} deals worth your attention`
    );

  } catch (err) {
    console.error('Pipeline fatal error:', err);
    await writeProgress(search_id, 'error', 'error', 'Scan encountered an error — try again');
    await supabase.from('deal_searches').update({ status: 'error' }).eq('id', search_id);
  }
};
