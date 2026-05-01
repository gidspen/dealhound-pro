/**
 * PM2 ecosystem config for dealhound-worker.
 *
 * Setup on Mac Mini (run once):
 *   cd ~/dealhound-pro/worker
 *   npm install
 *   pm2 start ecosystem.config.js
 *   pm2 save
 *   pm2 startup   ← run the printed command to enable boot persistence
 *
 * This file is safe to commit — no secrets, no hardcoded user paths.
 */

const path = require('path');

module.exports = {
  apps: [
    {
      name: 'dealhound-worker',
      script: './worker.js',
      cwd: __dirname,           // resolves to wherever this file lives — no hardcoded paths
      watch: false,
      autorestart: true,
      restart_delay: 5000,
      max_restarts: 10,
      min_uptime: '10s',
      env: {
        NODE_ENV: 'production',
        // Secrets loaded from ../.env.local by worker.js — not stored here
      },
      error_file: path.join(__dirname, 'logs/pm2-error.log'),
      out_file: path.join(__dirname, 'logs/pm2-out.log'),
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
      merge_logs: true,
    },
  ],
};
