/**
 * queue-daily-job.js
 *
 * Inserts a daily scrape_jobs row for the worker to pick up.
 * Called by daily-scrape.sh with the union buy box file path as argv[2].
 *
 * Usage: node queue-daily-job.js /path/to/daily-buy-box.json
 */

const { createClient } = require('@supabase/supabase-js');
const fs = require('fs');
const path = require('path');

const envPath = path.join(__dirname, '../.env.local');
if (fs.existsSync(envPath) && !process.env.SUPABASE_URL) {
  require('dotenv').config({ path: envPath });
}

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_KEY
);

async function main() {
  const buyBoxFile = process.argv[2];
  if (!buyBoxFile || !fs.existsSync(buyBoxFile)) {
    console.error(`ERROR: buy box file not found: ${buyBoxFile}`);
    process.exit(1);
  }

  const unionBox = JSON.parse(fs.readFileSync(buyBoxFile, 'utf8'));

  const { error } = await supabase.from('scrape_jobs').insert({
    search_id: null,  // daily runs aren't tied to a specific user search
    buy_box: unionBox,
    status: 'pending',
    trigger: 'daily',
  });

  if (error) {
    console.error('ERROR inserting daily scrape job:', error.message);
    process.exit(1);
  }

  console.log('Daily scrape job queued — worker will pick it up within 60s');
}

main().catch((err) => {
  console.error('FATAL:', err.message);
  process.exit(1);
});
