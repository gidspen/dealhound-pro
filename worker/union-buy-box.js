/**
 * union-buy-box.js
 *
 * Reads all active deal_searches.buy_box rows and computes a merged buy box
 * that covers all users' criteria. The daily scrape uses this so new users
 * hit the pool on Day 2 instead of always triggering on-demand.
 *
 * Writes output to: <dealhound-pro>/worker/daily-buy-box.json
 *
 * Run: node union-buy-box.js
 * Or:  npm run union-buy-box
 */

const { createClient } = require('@supabase/supabase-js');
const path = require('path');
const fs = require('fs');

// Load env
const envPath = process.env.DOTENV_PATH || path.join(__dirname, '../.env.local');
if (fs.existsSync(envPath) && !process.env.SUPABASE_URL) {
  require('dotenv').config({ path: envPath });
}

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_KEY
);

const OUTPUT_PATH = process.env.UNION_BOX_OUTPUT || path.join(__dirname, 'daily-buy-box.json');

/**
 * Merge strategy:
 *   price_min  — take lowest (cast widest net)
 *   price_max  — take highest
 *   acreage_min — take lowest
 *   states      — union of all states (array)
 *   property_types — union of all types (array)
 *   keywords    — union of all keywords (array, deduplicated)
 *
 * Any field not present in a buy box is ignored for that dimension.
 * The daily scrape will find more than any single user needs — Phase 3
 * scoring/filtering per user narrows it down to what matches their box.
 */
function mergeBuyBoxes(buyBoxes) {
  const union = {
    price_min: Infinity,
    price_max: 0,
    acreage_min: Infinity,
    states: new Set(),
    property_types: new Set(),
    keywords: new Set(),
    is_union: true,
    source_count: buyBoxes.length,
    generated_at: new Date().toISOString(),
  };

  for (const box of buyBoxes) {
    if (!box || typeof box !== 'object') continue;

    if (typeof box.price_min === 'number') union.price_min = Math.min(union.price_min, box.price_min);
    if (typeof box.price_max === 'number') union.price_max = Math.max(union.price_max, box.price_max);
    if (typeof box.acreage_min === 'number') union.acreage_min = Math.min(union.acreage_min, box.acreage_min);

    const states = box.states || box.state ? [].concat(box.states || box.state) : [];
    states.forEach((s) => s && union.states.add(String(s).trim().toUpperCase()));

    const types = box.property_types || box.property_type ? [].concat(box.property_types || box.property_type) : [];
    types.forEach((t) => t && union.property_types.add(String(t).trim().toLowerCase()));

    const kws = box.keywords ? [].concat(box.keywords) : [];
    kws.forEach((k) => k && union.keywords.add(String(k).trim().toLowerCase()));
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
  };
}

async function main() {
  const required = ['SUPABASE_URL', 'SUPABASE_SERVICE_KEY'];
  const missing = required.filter((k) => !process.env[k]);
  if (missing.length > 0) {
    console.error(`FATAL: missing env vars: ${missing.join(', ')}`);
    process.exit(1);
  }

  // Fetch all active searches with a buy_box defined
  const { data: searches, error } = await supabase
    .from('deal_searches')
    .select('user_email, buy_box')
    .not('buy_box', 'is', null)
    .not('status', 'eq', 'cancelled');

  if (error) {
    console.error('ERROR fetching deal_searches:', error.message);
    process.exit(1);
  }

  const buyBoxes = searches.map((s) => s.buy_box).filter(Boolean);
  const count = buyBoxes.length;
  console.log(`Found ${count} active buy box(es) across ${new Set(searches.map((s) => s.user_email)).size} user(s)`);

  if (count === 0) {
    console.log('No active buy boxes — writing default broad buy box');
    const fallback = {
      price_min: 300_000,
      price_max: 5_000_000,
      acreage_min: 1,
      states: [],
      property_types: ['glamping', 'micro resort', 'boutique hotel', 'cabin resort'],
      keywords: ['micro resort for sale', 'glamping resort for sale', 'boutique hotel for sale'],
      is_union: true,
      source_count: 0,
      generated_at: new Date().toISOString(),
    };
    fs.writeFileSync(OUTPUT_PATH, JSON.stringify(fallback, null, 2));
    console.log(`Wrote fallback buy box → ${OUTPUT_PATH}`);
    return;
  }

  const union = mergeBuyBoxes(buyBoxes);
  fs.writeFileSync(OUTPUT_PATH, JSON.stringify(union, null, 2));
  console.log(`Wrote union buy box (${count} source(s)) → ${OUTPUT_PATH}`);
  console.log(`  price: $${(union.price_min / 1000).toFixed(0)}k–$${(union.price_max / 1000).toFixed(0)}k`);
  console.log(`  states: ${union.states.length > 0 ? union.states.join(', ') : '(any)'}`);
  console.log(`  types: ${union.property_types.length > 0 ? union.property_types.join(', ') : '(any)'}`);
}

main().catch((err) => {
  console.error('FATAL:', err);
  process.exit(1);
});
