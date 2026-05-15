/**
 * union-buy-box.js
 *
 * Reads all active buy_boxes rows and computes a merged buy box that covers
 * all users' criteria. The group-scan-runner uses this so ONE Claude scrape
 * covers all active users, then per-user scoring narrows it down.
 *
 * Usage (standalone):
 *   node union-buy-box.js           — writes worker/daily-buy-box.json
 *   npm run union-buy-box
 *
 * Library usage (from group-scan-runner.js):
 *   const { buildUnionAndPerUser } = require('./union-buy-box');
 *   const { unionBuyBox, perUserBoxes } = await buildUnionAndPerUser(supabase);
 */

'use strict';

const { createClient } = require('@supabase/supabase-js');
const path = require('path');
const fs = require('fs');

// Load env (only when running standalone, not when require()'d as a library)
const envPath = process.env.DOTENV_PATH || path.join(__dirname, '../.env.local');
if (fs.existsSync(envPath) && !process.env.SUPABASE_URL) {
  require('dotenv').config({ path: envPath });
}

const OUTPUT_PATH = process.env.UNION_BOX_OUTPUT || path.join(__dirname, 'daily-buy-box.json');

/**
 * Normalize a single criteria object into the canonical paid buy-box shape.
 *
 * Two shapes flow in from buy_boxes.criteria:
 *   Paid box:      { states, property_types, keywords, price_min, price_max, acreage_min, locations, … }
 *   Free-scan box: { asset_type, market, … }
 *
 * Locations are passed through as-is (may include sub-region strings like
 * "East Texas"). The pipeline.py agent handles geocoding downstream.
 */
function normalizeCriteria(criteria) {
  if (!criteria || typeof criteria !== 'object') return {};

  // Free-scan shape: map asset_type → property_types, market → states/locations
  if (criteria.asset_type && !criteria.property_types) {
    return {
      property_types: [].concat(criteria.asset_type),
      states: criteria.market ? [].concat(criteria.market) : [],
      keywords: [],
      locations: [],
    };
  }

  return criteria;
}

/**
 * Merge strategy:
 *   price_min      — take lowest (cast widest net)
 *   price_max      — take highest
 *   acreage_min    — take lowest
 *   states         — union of all states (array)
 *   property_types — union of all types (array)
 *   keywords       — union of all keywords (array, deduplicated)
 *   locations      — union of all location strings (passed through verbatim)
 *
 * Any field not present in a buy box is ignored for that dimension.
 * The scrape will find more than any single user needs — per-user
 * scoring/filtering narrows it down to what matches their box.
 *
 * @param {object[]} criteriaList  — array of normalized criteria objects
 * @returns {object} merged union buy box
 */
function mergeBuyBoxes(criteriaList) {
  const union = {
    price_min: Infinity,
    price_max: 0,
    acreage_min: Infinity,
    states: new Set(),
    property_types: new Set(),
    keywords: new Set(),
    locations: new Set(),
    is_union: true,
    source_count: criteriaList.length,
    generated_at: new Date().toISOString(),
  };

  for (const box of criteriaList) {
    if (!box || typeof box !== 'object') continue;

    if (typeof box.price_min === 'number')
      union.price_min = Math.min(union.price_min, box.price_min);
    if (typeof box.price_max === 'number')
      union.price_max = Math.max(union.price_max, box.price_max);
    if (typeof box.acreage_min === 'number')
      union.acreage_min = Math.min(union.acreage_min, box.acreage_min);

    const states = box.states || box.state ? [].concat(box.states || box.state) : [];
    states.forEach((s) => s && union.states.add(String(s).trim().toUpperCase()));

    const types =
      box.property_types || box.property_type
        ? [].concat(box.property_types || box.property_type)
        : [];
    types.forEach((t) => t && union.property_types.add(String(t).trim().toLowerCase()));

    const kws = box.keywords ? [].concat(box.keywords) : [];
    kws.forEach((k) => k && union.keywords.add(String(k).trim().toLowerCase()));

    // locations: sub-region strings (e.g. "East Texas") — pass through verbatim
    const locs = box.locations ? [].concat(box.locations) : [];
    locs.forEach((l) => l && union.locations.add(String(l).trim()));
  }

  // Defaults if no users have a preference (fallback to broad DealHound defaults)
  if (union.price_min === Infinity) union.price_min = 300_000;
  if (union.price_max === 0) union.price_max = 5_000_000;
  if (union.acreage_min === Infinity) union.acreage_min = 1;

  return {
    ...union,
    states: [...union.states].sort(),
    property_types: [...union.property_types].sort(),
    keywords: [...union.keywords].sort(),
    locations: [...union.locations].sort(),
  };
}

const FALLBACK_UNION = {
  price_min: 300_000,
  price_max: 5_000_000,
  acreage_min: 1,
  states: [],
  property_types: ['glamping', 'micro resort', 'boutique hotel', 'cabin resort'],
  keywords: ['micro resort for sale', 'glamping resort for sale', 'boutique hotel for sale'],
  locations: [],
  is_union: true,
  source_count: 0,
  generated_at: new Date().toISOString(),
};

/**
 * buildUnionAndPerUser — primary library export.
 *
 * Queries buy_boxes WHERE status = 'active', normalizes each criteria jsonb,
 * merges into a union buy box for the scrape phase, and returns the per-user
 * list for the per-user scoring phase.
 *
 * @param {import('@supabase/supabase-js').SupabaseClient} supabaseClient
 * @returns {Promise<{
 *   unionBuyBox: object,
 *   perUserBoxes: Array<{ buy_box_id: string, user_email: string, criteria: object }>,
 * }>}
 */
async function buildUnionAndPerUser(supabaseClient) {
  const { data: boxes, error } = await supabaseClient
    .from('buy_boxes')
    .select('id, user_email, criteria')
    .eq('status', 'active');

  if (error) {
    throw new Error(`union-buy-box: failed to fetch buy_boxes — ${error.message}`);
  }

  if (!boxes || boxes.length === 0) {
    return {
      unionBuyBox: { ...FALLBACK_UNION, generated_at: new Date().toISOString() },
      perUserBoxes: [],
    };
  }

  const perUserBoxes = boxes.map((b) => ({
    buy_box_id: b.id,
    user_email: b.user_email,
    criteria: normalizeCriteria(b.criteria),
  }));

  const criteriaList = perUserBoxes.map((b) => b.criteria);
  const unionBuyBox = mergeBuyBoxes(criteriaList);

  return { unionBuyBox, perUserBoxes };
}

// ── Standalone CLI ────────────────────────────────────────────────────────────
// Only runs when executed directly: `node union-buy-box.js`

if (require.main === module) {
  (async () => {
    const required = ['SUPABASE_URL', 'SUPABASE_SERVICE_KEY'];
    const missing = required.filter((k) => !process.env[k]);
    if (missing.length > 0) {
      console.error(`FATAL: missing env vars: ${missing.join(', ')}`);
      process.exit(1);
    }

    const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_KEY);

    const { unionBuyBox, perUserBoxes } = await buildUnionAndPerUser(supabase);
    const count = perUserBoxes.length;

    if (count === 0) {
      console.log('No active buy boxes — writing default broad buy box');
    } else {
      console.log(
        `Found ${count} active buy box(es) across ${new Set(perUserBoxes.map((b) => b.user_email)).size} user(s)`
      );
    }

    fs.writeFileSync(OUTPUT_PATH, JSON.stringify(unionBuyBox, null, 2));
    console.log(`Wrote union buy box (${count} source(s)) → ${OUTPUT_PATH}`);
    console.log(
      `  price: $${(unionBuyBox.price_min / 1000).toFixed(0)}k–$${(unionBuyBox.price_max / 1000).toFixed(0)}k`
    );
    console.log(
      `  states: ${unionBuyBox.states.length > 0 ? unionBuyBox.states.join(', ') : '(any)'}`
    );
    console.log(
      `  types: ${unionBuyBox.property_types.length > 0 ? unionBuyBox.property_types.join(', ') : '(any)'}`
    );
  })().catch((err) => {
    console.error('FATAL:', err);
    process.exit(1);
  });
}

module.exports = { buildUnionAndPerUser, mergeBuyBoxes, normalizeCriteria };
