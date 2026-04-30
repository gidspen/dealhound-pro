# dealhound-worker — Mac Mini Setup

Run these commands once on the Mac Mini.

## Prerequisites

- Node.js v18+ (`node --version`)
- PM2: `npm install -g pm2`
- Claude CLI installed and authenticated (`claude --version`)
- `~/dealhound-pro/.env.local` must exist with `SUPABASE_URL`, `SUPABASE_SERVICE_KEY`, `ANTHROPIC_API_KEY`

## 1. Pull latest code

```bash
cd ~/dealhound-pro
git pull
```

## 2. Install worker dependencies

```bash
cd ~/dealhound-pro/worker
npm install
```

## 3. Start worker with PM2

```bash
pm2 start ecosystem.config.js
pm2 save
pm2 startup   # follow the printed command to enable boot persistence
```

## 4. Install daily cron

```bash
bash ~/dealhound-pro/worker/install-cron.sh
```

## Verify everything is running

```bash
pm2 status                          # worker should show "online"
pm2 logs dealhound-worker --lines 20
crontab -l                          # should show dealhound-daily-scrape entry
```

## Check logs

```bash
pm2 logs dealhound-worker              # live stream
tail -f ~/dealhound-pro/worker/logs/daily-scrape.log
```

## How it works

```
6:00 AM CT (cron)
  └── daily-scrape.sh
        ├── union-buy-box.js    → merges all active user buy boxes → daily-buy-box.json
        └── queue-daily-job.js  → inserts scrape_jobs row (trigger=daily, status=pending)

≤60s later (PM2 worker)
  └── worker.js polls scrape_jobs
        ├── claims job (optimistic lock)
        ├── creates scan_runs row
        └── spawns: claude -p "/find-deals full"
              with DEALHOUND_SEARCH_ID + DEALHOUND_BUY_BOX_FILE env vars

User on second day
  └── pool query finds matching deals → no on-demand scan needed
```

## Restart after code changes

```bash
cd ~/dealhound-pro && git pull
pm2 restart dealhound-worker
```

## Token cost visibility

Every scan is logged to `scan_runs` in Supabase. Query:

```sql
SELECT date_trunc('day', started_at) AS day,
       trigger,
       count(*) AS runs,
       round(avg(duration_ms)/1000) AS avg_seconds,
       sum(input_tokens) AS total_input_tokens,
       sum(output_tokens) AS total_output_tokens
FROM scan_runs
GROUP BY 1, 2
ORDER BY 1 DESC;
```
