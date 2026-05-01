#!/usr/bin/env bash
# install-cron.sh
#
# Adds the DealHound daily scrape trigger to crontab.
# Safe to re-run — checks for existing entry before adding.
#
# Usage: bash ~/dealhound-pro/worker/install-cron.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CRON_CMD="0 11 * * * /usr/bin/env bash $SCRIPT_DIR/daily-scrape.sh"
MARKER="dealhound-daily-scrape"

echo "Installing DealHound daily scrape cron..."
echo "Script: $SCRIPT_DIR/daily-scrape.sh"
echo "Schedule: 6:00 AM CT (11:00 UTC)"

# Check if already installed
if crontab -l 2>/dev/null | grep -q "$MARKER"; then
  echo "✅ Cron entry already installed — skipping."
  crontab -l | grep "$MARKER"
  exit 0
fi

# Append to existing crontab (or create new)
(crontab -l 2>/dev/null; echo "# $MARKER"; echo "$CRON_CMD") | crontab -

echo "✅ Cron installed:"
crontab -l | grep -A1 "$MARKER"
