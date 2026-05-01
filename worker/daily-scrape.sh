#!/usr/bin/env bash
# daily-scrape.sh
#
# Runs by cron at 6:00 AM CT every day.
# Step 1: recompute the union buy box across all active users
# Step 2: insert a scrape_jobs row for the daily run
# Step 3: the worker picks it up and runs /find-deals full
#
# This script only triggers the job — the worker handles execution.
# Logs to: <dealhound-pro>/worker/logs/daily-scrape.log

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$SCRIPT_DIR/logs"
LOG_FILE="$LOG_DIR/daily-scrape.log"
# worker/ lives inside dealhound-pro/, so ../.env.local is the project env file
ENV_FILE="$SCRIPT_DIR/../.env.local"

mkdir -p "$LOG_DIR"
exec >> "$LOG_FILE" 2>&1

echo ""
echo "========================================"
echo "daily-scrape: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "========================================"

# Source env
if [ -f "$ENV_FILE" ]; then
  set -a
  # shellcheck disable=SC1090
  source "$ENV_FILE"
  set +a
else
  echo "ERROR: env file not found at $ENV_FILE"
  exit 1
fi

# Validate required env vars
for var in SUPABASE_URL SUPABASE_SERVICE_KEY; do
  if [ -z "${!var:-}" ]; then
    echo "ERROR: $var is not set"
    exit 1
  fi
done

# Ensure node is in PATH (cron environments often have a stripped PATH)
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:$PATH"

# Find node
NODE_BIN="$(command -v node 2>/dev/null || true)"
if [ -z "$NODE_BIN" ]; then
  echo "ERROR: node not found in PATH ($PATH)"
  exit 1
fi
echo "Using node: $NODE_BIN ($($NODE_BIN --version))"

# Step 1: Refresh union buy box
echo "→ Refreshing union buy box..."
"$NODE_BIN" "$SCRIPT_DIR/union-buy-box.js"

UNION_BOX_FILE="$SCRIPT_DIR/daily-buy-box.json"
if [ ! -f "$UNION_BOX_FILE" ]; then
  echo "ERROR: union buy box file not written"
  exit 1
fi

# Step 2: Queue daily scrape_job
echo "→ Queuing daily scrape_job..."
"$NODE_BIN" "$SCRIPT_DIR/queue-daily-job.js" "$UNION_BOX_FILE"

echo "→ Done. Worker will process the job within 60s."
