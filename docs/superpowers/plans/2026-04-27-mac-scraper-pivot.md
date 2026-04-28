# Mac-Based Scraper Pivot — Sophie + /find-deals Skill

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the Railway-hosted Playwright scraper with a Mac-local pipeline powered by the existing `/find-deals` skill, invoked via Sophie's cron scheduler and a Supabase job queue for on-demand requests.

**Architecture:** Sophie (Node.js, persistent on Mac) runs `/find-deals full` daily at 6am CT via the `claude` CLI. The skill scrapes all marketplace sites using a real browser (no proxy needed), scores deals with Sonnet + Opus, and writes scored results directly to Supabase. On-demand scans (new user cold-start) write a row to a `scrape_jobs` table; Sophie polls it every 60s and invokes the skill with the user's buy box. Vercel becomes a thin query layer — no scraping at request time.

**Tech Stack:** Sophie (Node.js/Express, Mac), `claude` CLI with `/find-deals` skill, Supabase (PostgreSQL, same project `gggmmjvwbbfvrtjjlqvr`), Vercel serverless (Node.js, frontend + API).

---

## What Gets Deleted

| File/System | Why |
|-------------|-----|
| `scraper-service/` (entire directory) | Replaced by /find-deals skill on Mac |
| Railway deployment + service | No longer needed |
| ScraperAPI subscription | No proxy needed — Mac has residential IP |
| `api/_lib/scrape.js` | Called Railway; replaced by job queue write |
| `api/scan-continue.js` | Webhook from Railway; no longer needed |
| `api/_lib/process-listings.js` | Filtering + scoring now done by the skill |
| `api/_lib/discover.js` | Discovery now done by the skill's Phase 1 |
| `api/_lib/score.js` | Scoring now done by the skill's Phase 3 |

## What Stays

| File | Why |
|------|-----|
| `api/scan-start.js` | Modified: writes job to queue instead of calling Railway |
| `api/scan-progress.js` | Modified: stale timeout increased from 5min to 120min for skill runtime |
| `api/_lib/progress.js` | Unchanged: Supabase progress helper |
| `api/user-data.js`, `api/chat.js`, etc. | Unchanged: dashboard API endpoints |
| `api/health.js` | Unchanged |
| Supabase tables | Same project, same tables — skill already writes to them |
| Vercel frontend/dashboard | Unchanged |

## What's New

| File | Responsibility |
|------|---------------|
| `sophie/pipelines/daily-scrape.js` | Sophie pipeline: invokes `/find-deals full` via `claude` CLI at 6am CT |
| `sophie/pipelines/on-demand-scrape.js` | Sophie pipeline: invokes `/find-deals` with a custom buy box from a job queue row |
| Supabase `scrape_jobs` table | Job queue for on-demand scan requests |
| Sophie `index.js` additions | Cron entry for daily scrape + 60s polling loop for on-demand jobs |

## Key Facts

- The `/find-deals` skill and DealHound Pro use the **same Supabase project** (`gggmmjvwbbfvrtjjlqvr`). Env vars: skill uses `$SUPABASE_DEALS_URL` / `$SUPABASE_DEALS_ANON_KEY`; DealHound Pro uses `$SUPABASE_URL` / `$SUPABASE_SERVICE_KEY`. Both resolve to the same project.
- The skill writes to `deal_searches` and `deals` tables — the same tables the dashboard reads from.
- The skill creates a `search_id` in `deal_searches` and links all scored deals to it. The dashboard already reads deals by `search_id`.
- Sophie runs as a persistent Node.js server on the Mac (Express + node-cron). She invokes `claude` CLI via `spawn` (async, non-blocking).
- The skill takes 30-100 min for a full run (discover → scrape → score). Phase 2A (Playwright) is fast (~2 min for LandSearch). Phase 2B (Chrome browser) is slower for blocked sites.
- The skill writes progress to stdout but NOT to the `scan_progress` table. Sophie's polling loop writes heartbeat progress rows every 5 min during a run.
- **search_id bridging:** On-demand scans pass `DEALHOUND_SEARCH_ID` env var to the `claude` CLI. The skill's `apply-buybox.md` checks for this env var and skips creating a new search record if set. This ensures deals link to the dashboard's search_id deterministically (no prompt engineering).
- **Daily scans** create their own search record with `user_email: "system@dealhound.pro"`. Shared pool fan-out (Epic 6 in PRD) is deferred — daily scan results are visible only to Gideon initially.

---

## Task 1: Create `scrape_jobs` Table in Supabase

**Files:**
- Supabase migration (via MCP or SQL)

- [ ] **Step 1: Create the table**

```sql
CREATE TABLE scrape_jobs (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  search_id UUID REFERENCES deal_searches(id),
  buy_box JSONB NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending',
  picked_up_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  error TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_scrape_jobs_status ON scrape_jobs(status) WHERE status = 'pending';
```

Run via Supabase MCP `apply_migration` or the SQL editor.

- [ ] **Step 2: Verify the table exists**

```sql
SELECT column_name, data_type FROM information_schema.columns
WHERE table_name = 'scrape_jobs' ORDER BY ordinal_position;
```

Expected: 8 columns (id, search_id, buy_box, status, picked_up_at, completed_at, error, created_at).

- [ ] **Step 3: Commit migration file if using local migrations**

---

## Task 2: Create Sophie Daily Scrape Pipeline

**Files:**
- Create: `/Users/gideonspencer/sophie/pipelines/daily-scrape.js`

- [ ] **Step 1: Create the pipeline file**

```javascript
// pipelines/daily-scrape.js
const { spawn } = require('child_process');
const memory = require('../data/memory');

/**
 * Run the /find-deals skill as a non-blocking child process.
 * Returns a promise that resolves with { output, exitCode }.
 * Uses spawn instead of execFileSync so Sophie's event loop stays free
 * for webhooks, cron jobs, and other pipelines during the 30-100 min run.
 */
function runClaude(prompt, env = {}) {
  return new Promise((resolve, reject) => {
    const chunks = [];
    const child = spawn('claude', [
      '-p', prompt,
      '--output-format', 'text',
      '--model', 'claude-opus-4-6',
      '--dangerously-skip-permissions'
    ], {
      env: { ...process.env, ...env },
      cwd: process.env.HOME,
      stdio: ['pipe', 'pipe', 'pipe'],
    });

    child.stdout.on('data', d => chunks.push(d));
    child.stderr.on('data', d => process.stderr.write(d));

    const timeout = setTimeout(() => {
      child.kill('SIGTERM');
      reject(new Error('Skill timed out after 90 minutes'));
    }, 90 * 60 * 1000);

    child.on('close', code => {
      clearTimeout(timeout);
      const output = Buffer.concat(chunks).toString('utf8');
      if (code === 0) resolve({ output, exitCode: code });
      else reject(new Error(`claude exited with code ${code}: ${output.slice(-500)}`));
    });

    child.on('error', err => {
      clearTimeout(timeout);
      reject(err);
    });
  });
}

async function run() {
  console.log('[Sophie] Daily scrape: invoking /find-deals full...');
  memory.appendToDailyNote('Daily scrape pipeline: starting /find-deals full run');

  const startTime = Date.now();

  try {
    const { output } = await runClaude('/find-deals full');

    const durationMin = ((Date.now() - startTime) / 60000).toFixed(1);
    const lines = output.trim().split('\n');
    const summary = lines.slice(-10).join('\n');

    memory.appendToDailyNote(
      `Daily scrape pipeline: completed in ${durationMin}min\n${summary.substring(0, 500)}`
    );

    console.log(`[Sophie] Daily scrape completed in ${durationMin}min`);
    return `Daily deal scan complete (${durationMin}min)\n\n${summary.substring(0, 1200)}`;

  } catch (err) {
    const durationMin = ((Date.now() - startTime) / 60000).toFixed(1);
    console.error(`[Sophie] Daily scrape failed after ${durationMin}min:`, err.message);
    memory.appendToDailyNote(`Daily scrape pipeline: FAILED after ${durationMin}min -- ${err.message}`);
    return `Daily deal scan failed after ${durationMin}min: ${err.message.substring(0, 200)}`;
  }
}

module.exports = { run, runClaude };
```

Note: `runClaude` is exported so `on-demand-scrape.js` can reuse it.

- [ ] **Step 2: Test the pipeline manually**

```bash
cd /Users/gideonspencer/sophie && node -e "require('./pipelines/daily-scrape').run().then(r => console.log(r))"
```

Expected: Skill runs, output appears, deals written to Supabase. This will take 30-100 min.

- [ ] **Step 3: Commit**

```bash
cd /Users/gideonspencer/sophie
git add pipelines/daily-scrape.js
git commit -m "feat: add daily deal scrape pipeline via /find-deals skill"
```

---

## Task 3: Create Sophie On-Demand Scrape Pipeline

**Files:**
- Create: `/Users/gideonspencer/sophie/pipelines/on-demand-scrape.js`

- [ ] **Step 1: Create the pipeline file**

```javascript
// pipelines/on-demand-scrape.js
const { runClaude } = require('./daily-scrape');
const memory = require('../data/memory');

/**
 * Run /find-deals with a custom buy box from a scrape_jobs row.
 * Called by the polling loop when a pending job is found.
 *
 * Passes DEALHOUND_SEARCH_ID as an env var so the skill links deals
 * to the dashboard's search_id instead of creating a new one.
 */
async function run(job) {
  console.log(`[Sophie] On-demand scrape: job ${job.id}, search ${job.search_id}`);

  const bb = job.buy_box;

  // Build a natural-language override string from the buy box
  const overrides = [];
  if (bb.locations && bb.locations.length > 0) {
    overrides.push(`in ${bb.locations.join(', ')}`);
  }
  if (bb.price_max) {
    overrides.push(`under $${(bb.price_max / 1000000).toFixed(1)}M`);
  }
  if (bb.price_min) {
    overrides.push(`above $${(bb.price_min / 1000).toFixed(0)}k`);
  }
  if (bb.property_types && bb.property_types.length > 0) {
    overrides.push(`property types: ${bb.property_types.join(', ')}`);
  }

  const prompt = overrides.length > 0
    ? `/find-deals full -- ${overrides.join(', ')}`
    : '/find-deals full';

  const startTime = Date.now();

  try {
    // DEALHOUND_SEARCH_ID tells the skill to skip creating a new search record
    // and use the existing one from the dashboard. This is the deterministic
    // bridge between the dashboard's search_id and the skill's Supabase writes.
    const { output } = await runClaude(prompt, {
      DEALHOUND_SEARCH_ID: job.search_id,
    });

    const durationMin = ((Date.now() - startTime) / 60000).toFixed(1);
    console.log(`[Sophie] On-demand scrape completed in ${durationMin}min for job ${job.id}`);
    memory.appendToDailyNote(`On-demand scrape: job ${job.id} completed in ${durationMin}min`);

    return { success: true, duration: durationMin, output: output.substring(0, 2000) };

  } catch (err) {
    const durationMin = ((Date.now() - startTime) / 60000).toFixed(1);
    console.error(`[Sophie] On-demand scrape failed for job ${job.id}:`, err.message);
    memory.appendToDailyNote(`On-demand scrape: job ${job.id} FAILED after ${durationMin}min`);
    return { success: false, duration: durationMin, error: err.message };
  }
}

module.exports = { run };
```

- [ ] **Step 2: Commit**

```bash
cd /Users/gideonspencer/sophie
git add pipelines/on-demand-scrape.js
git commit -m "feat: add on-demand scrape pipeline for job queue"
```

---

## Task 4: Add Cron + Polling Loop to Sophie's index.js

**Files:**
- Modify: `/Users/gideonspencer/sophie/index.js`

- [ ] **Step 1: Add imports at the top of index.js**

After the existing `require` statements (around line 15), add:

```javascript
const dailyScrape = require('./pipelines/daily-scrape');
const onDemandScrape = require('./pipelines/on-demand-scrape');
```

- [ ] **Step 2: Add the daily scrape cron entry**

After the existing cron entries (around line 60), add:

```javascript
// Daily deal scrape: 6:00 AM CT = 11:00 UTC, every day
cron.schedule('0 11 * * *', async () => {
  try {
    const result = await dailyScrape.run();
    if (result) await sendMultiPart(result);
  } catch (err) { console.error('[Sophie] Daily scrape error:', err.message); }
});
```

- [ ] **Step 3: Add the on-demand job polling loop**

After all the cron entries but before the webhook handler, add:

```javascript
// --- On-demand scrape job polling (every 60s) ---
const { createClient } = require('@supabase/supabase-js');
const jobSupabase = createClient(
  process.env.SUPABASE_DEALS_URL || process.env.SUPABASE_URL,
  process.env.SUPABASE_DEALS_ANON_KEY || process.env.SUPABASE_SERVICE_KEY
);

let jobRunning = false;

setInterval(async () => {
  if (jobRunning) return; // Don't overlap

  try {
    // Claim the oldest pending job (atomic: only one poller wins)
    const { data: jobs } = await jobSupabase
      .from('scrape_jobs')
      .select('*')
      .eq('status', 'pending')
      .order('created_at', { ascending: true })
      .limit(1);

    if (!jobs || jobs.length === 0) return;

    const job = jobs[0];
    jobRunning = true;

    // Mark as running
    await jobSupabase
      .from('scrape_jobs')
      .update({ status: 'running', picked_up_at: new Date().toISOString() })
      .eq('id', job.id)
      .eq('status', 'pending'); // Optimistic lock

    // Write initial progress
    await jobSupabase.from('scan_progress').insert({
      search_id: job.search_id,
      step: 'scraping',
      status: 'running',
      message: 'Deal scanner is running -- this takes 30-60 minutes',
    });

    console.log(`[Sophie] Picked up scrape job ${job.id}`);

    // Write heartbeat progress every 5 min so dashboard doesn't show stale
    const heartbeat = setInterval(async () => {
      const elapsed = ((Date.now() - Date.now()) / 60000).toFixed(0);
      try {
        await jobSupabase.from('scan_progress').insert({
          search_id: job.search_id,
          step: 'scraping',
          status: 'running',
          message: `Still scanning... deal finder is working`,
        });
      } catch (_) { /* non-fatal */ }
    }, 5 * 60 * 1000);

    let result;
    try {
      result = await onDemandScrape.run(job);
    } finally {
      clearInterval(heartbeat);
    }

    if (result.success) {
      await jobSupabase
        .from('scrape_jobs')
        .update({ status: 'complete', completed_at: new Date().toISOString() })
        .eq('id', job.id);

      await jobSupabase.from('scan_progress').insert({
        search_id: job.search_id,
        step: 'done',
        status: 'complete',
        message: `Scan complete in ${result.duration}min`,
      });

      await jobSupabase
        .from('deal_searches')
        .update({ status: 'complete' })
        .eq('id', job.search_id);
    } else {
      await jobSupabase
        .from('scrape_jobs')
        .update({ status: 'error', error: result.error, completed_at: new Date().toISOString() })
        .eq('id', job.id);

      await jobSupabase.from('scan_progress').insert({
        search_id: job.search_id,
        step: 'error',
        status: 'error',
        message: `Scan failed: ${(result.error || '').substring(0, 200)}`,
      });

      await jobSupabase
        .from('deal_searches')
        .update({ status: 'error' })
        .eq('id', job.search_id);
    }

  } catch (err) {
    console.error('[Sophie] Job polling error:', err.message);
  } finally {
    jobRunning = false;
  }
}, 60000); // Poll every 60 seconds
```

- [ ] **Step 4: Verify Sophie parses without errors**

```bash
cd /Users/gideonspencer/sophie && node --check index.js && echo "Syntax OK"
```

Expected: Prints "Syntax OK" with no errors.

- [ ] **Step 5: Commit**

```bash
cd /Users/gideonspencer/sophie
git add index.js
git commit -m "feat: daily scrape cron + on-demand job queue polling"
```

---

## Task 5: Update Vercel scan-start.js — Write Job Instead of Calling Railway

**Files:**
- Modify: `/Users/gideonspencer/dealhound-pro/api/scan-start.js`

- [ ] **Step 1: Replace scan-start.js**

The new version writes a `scrape_jobs` row instead of calling `runPipeline` (which called Railway). Sophie picks up the job.

```javascript
// api/scan-start.js
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

  const { search_id } = req.body;

  if (!search_id) {
    return res.status(400).json({ error: 'Missing search_id' });
  }

  try {
    // Get the search record
    const { data: search, error: searchError } = await supabase
      .from('deal_searches')
      .select('*')
      .eq('id', search_id)
      .single();

    if (searchError || !search) {
      return res.status(404).json({ error: 'Search not found' });
    }

    if (search.status === 'scanning' || search.status === 'complete') {
      return res.json({ status: search.status, search_id });
    }

    // Mark as scanning
    await supabase
      .from('deal_searches')
      .update({ status: 'scanning' })
      .eq('id', search_id);

    // Seed progress
    await supabase.from('scan_progress').insert([
      { search_id, step: 'init', status: 'complete', message: 'Buy box loaded — queuing scan job' },
      { search_id, step: 'queued', status: 'running', message: 'Waiting for deal scanner to pick up your request...' },
    ]);

    // Write job to queue — Sophie picks this up within 60 seconds
    await supabase.from('scrape_jobs').insert({
      search_id,
      buy_box: search.buy_box,
      status: 'pending',
    });

    return res.json({ status: 'queued', search_id });

  } catch (err) {
    console.error('Scan start error:', err);
    if (!res.headersSent) {
      return res.status(500).json({ error: 'Internal server error' });
    }
  }
};
```

- [ ] **Step 2: Verify syntax**

```bash
cd /Users/gideonspencer/dealhound-pro && node -e "require('./api/scan-start')"
```

Expected: No errors.

- [ ] **Step 3: Commit**

```bash
cd /Users/gideonspencer/dealhound-pro
git add api/scan-start.js
git commit -m "feat: scan-start writes to job queue instead of calling Railway"
```

---

## Task 6: Remove Railway Scraper + Dead Code

**Files:**
- Delete: `scraper-service/` (entire directory)
- Delete: `api/_lib/scrape.js`
- Delete: `api/scan-continue.js`
- Delete: `api/scan-pipeline.js`
- Delete: `api/_lib/process-listings.js`
- Delete: `api/_lib/discover.js`
- Delete: `api/_lib/score.js`
- Modify: `vercel.json` (remove scan-continue config)

- [ ] **Step 1: Delete the scraper service**

```bash
cd /Users/gideonspencer/dealhound-pro
rm -rf scraper-service/
```

- [ ] **Step 2: Delete dead Vercel API files**

```bash
rm api/_lib/scrape.js
rm api/scan-continue.js
rm api/scan-pipeline.js
rm api/_lib/process-listings.js
rm api/_lib/discover.js
rm api/_lib/score.js
rm api/_lib/filters.js
```

Note: `filters.js` has no remaining callers after removing `process-listings.js` and `scan-pipeline.js`. The skill handles all filtering internally. Keep it only if you plan to add query-time filtering on the Vercel side later.

- [ ] **Step 3: Update vercel.json — remove scan-continue function config**

Read `vercel.json`, remove any reference to `scan-continue.js` from the functions config.

- [ ] **Step 4: Check for broken imports**

```bash
cd /Users/gideonspencer/dealhound-pro
grep -r "scan-continue\|scan-pipeline\|scrape\.js\|process-listings\|discover\.js\|score\.js" api/ --include="*.js" -l
```

Expected: Only `scan-start.js` remains and it no longer imports any of the deleted files. Fix any remaining references.

- [ ] **Step 5: Verify remaining API files still parse**

```bash
for f in api/*.js api/_lib/*.js; do node -e "require('./$f')" 2>/dev/null && echo "OK: $f" || echo "FAIL: $f"; done
```

- [ ] **Step 6: Commit**

```bash
cd /Users/gideonspencer/dealhound-pro
git add -A
git commit -m "chore: remove Railway scraper service + dead API code

Replaced by /find-deals skill running on Mac via Sophie.
Removes: scraper-service/, scan-continue.js, scan-pipeline.js,
process-listings.js, discover.js, score.js, scrape.js"
```

---

## Task 7: Bridge Skill Output → Dashboard search_id

The `/find-deals` skill writes scored deals to `deal_searches` + `deals` tables, but it creates its own `search_id` (Step 0 of apply-buybox.md). The on-demand job has a `search_id` from the dashboard. We need the skill's output to be linked to the dashboard's `search_id`.

The fix is deterministic (env var), not prompt engineering. `on-demand-scrape.js` (Task 3) already passes `DEALHOUND_SEARCH_ID` as an env var. This task modifies the skill's `apply-buybox.md` to check for it.

**Files:**
- Modify: `/Users/gideonspencer/.claude/skills/find-deals/apply-buybox.md`

- [ ] **Step 1: Update Step 0 in apply-buybox.md**

Find Step 0 ("Create Search Record in Supabase") and add an env var check before the INSERT. Change the step to:

```markdown
## Step 0: Create Search Record in Supabase

Do this first -- before loading listings. The `search_id` is needed for Step 1c.

**If `$DEALHOUND_SEARCH_ID` is set** (passed by on-demand pipeline), skip the INSERT
and use it directly:

\`\`\`bash
source ~/.zshrc

if [ -n "$DEALHOUND_SEARCH_ID" ]; then
  SEARCH_ID="$DEALHOUND_SEARCH_ID"
  echo "Using existing search_id from dashboard: $SEARCH_ID"
else
  SEARCH_RESPONSE=$(curl -s -X POST "$SUPABASE_DEALS_URL/rest/v1/deal_searches" \
    -H "apikey: $SUPABASE_DEALS_ANON_KEY" \
    -H "Authorization: Bearer $SUPABASE_DEALS_ANON_KEY" \
    -H "Content-Type: application/json" \
    -H "Prefer: return=representation" \
    -d '{"user_email": "gideon@incrediblehospitalityco.com", "buy_box": BUY_BOX_JSON}')

  SEARCH_ID=$(echo $SEARCH_RESPONSE | python3.12 -c "import sys,json; print(json.load(sys.stdin)[0]['id'])")
  echo "Search ID: $SEARCH_ID"
fi
\`\`\`
```

- [ ] **Step 2: Test the env var path**

```bash
export DEALHOUND_SEARCH_ID="test-123"
# Verify the conditional logic works
source ~/.zshrc && if [ -n "$DEALHOUND_SEARCH_ID" ]; then echo "Using: $DEALHOUND_SEARCH_ID"; else echo "Creating new"; fi
unset DEALHOUND_SEARCH_ID
```

Expected: Prints "Using: test-123".

- [ ] **Step 3: Commit**

```bash
cd /Users/gideonspencer/.claude/skills/find-deals
git add apply-buybox.md
git commit -m "feat: support DEALHOUND_SEARCH_ID env var for dashboard integration"
```

---

## Task 7.5: Increase Stale Scan Timeout in scan-progress.js

The dashboard's `scan-progress.js` marks scans as stale after 5 minutes of no progress updates. The skill takes 30-100 min. Even with heartbeat rows every 5 min, we need a larger safety window.

**Files:**
- Modify: `/Users/gideonspencer/dealhound-pro/api/scan-progress.js`

- [ ] **Step 1: Find and update the stale timeout**

Read `api/scan-progress.js`. Find the stale detection timeout (likely a comparison against `now() - interval '5 minutes'` or similar). Change it to 120 minutes.

If the stale detection is a hardcoded number of minutes, change it to `120`. If it's a comparison against a timestamp, change the interval to `'120 minutes'`.

- [ ] **Step 2: Commit**

```bash
cd /Users/gideonspencer/dealhound-pro
git add api/scan-progress.js
git commit -m "fix: increase stale scan timeout from 5min to 120min for skill-based scraping"
```

---

## Task 8: End-to-End Test

- [ ] **Step 1: Restart Sophie with the new code**

```bash
cd /Users/gideonspencer/sophie
# If running via PM2:
pm2 restart sophie
# Or kill and restart:
node index.js
```

- [ ] **Step 2: Test daily scrape manually**

```bash
cd /Users/gideonspencer/sophie
node -e "require('./pipelines/daily-scrape').run().then(r => console.log('Result:', r))"
```

Expected: Skill runs full pipeline (~30-100 min). Check Supabase `deals` table for new rows.

- [ ] **Step 3: Test on-demand scrape via dashboard**

1. Open the DealHound dashboard in a browser
2. Create a new scan with a buy box (e.g., Texas, micro resorts, $300k-$3M)
3. Watch `scrape_jobs` table in Supabase — a `pending` row should appear
4. Watch Sophie's console output — she should pick it up within 60s
5. Progress should appear in the dashboard (via `scan_progress` table)
6. After 30-60 min, scored deals should appear in the dashboard

- [ ] **Step 4: Verify Supabase data integrity**

```sql
-- Check that deals are linked to the correct search_id
SELECT ds.id, ds.status, COUNT(d.id) as deal_count
FROM deal_searches ds
LEFT JOIN deals d ON d.search_id = ds.id
WHERE ds.run_at > now() - interval '1 day'
GROUP BY ds.id, ds.status;
```

- [ ] **Step 5: Deploy Vercel**

```bash
cd /Users/gideonspencer/dealhound-pro
vercel --prod
```

- [ ] **Step 6: Test failure mode — Sophie offline**

Kill Sophie. Trigger a scan from the dashboard. Verify the progress shows "Waiting for deal scanner..." but doesn't crash. Restart Sophie — verify she picks up the queued job.

- [ ] **Step 7: Decommission Railway**

Once E2E is verified:
1. Disconnect the Railway service from the GitHub repo
2. Delete the Railway service
3. Cancel ScraperAPI subscription if no longer needed elsewhere

- [ ] **Step 8: Commit any fixes from testing**

```bash
cd /Users/gideonspencer/dealhound-pro
git add -A
git commit -m "fix: end-to-end testing fixes for Mac scraper pivot"
```
