// api/magic-link.js
//
// GET /api/magic-link?token=...
//
// Verifies an HMAC magic link token, then 302-redirects to the dashboard
// with email, scan_id, and from=magic as query params so the dashboard
// can sign the user in without a password.

'use strict';

const { verifyMagicLink } = require('./_lib/magic-link');

module.exports = async function handler(req, res) {
  if (req.method !== 'GET') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const { token } = req.query;

  const result = verifyMagicLink(token);

  if (!result.ok) {
    console.warn('magic-link: verification failed —', result.reason);
    res.setHeader('Content-Type', 'text/html');
    res.writeHead(401, { 'Content-Type': 'text/html' });
    return res.end(`<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Link expired — Deal Hound</title>
  <style>
    body { font-family: system-ui, sans-serif; max-width: 480px; margin: 80px auto; padding: 0 24px; color: #1a1a1a; }
    h1 { font-size: 1.4rem; margin-bottom: 12px; }
    p { color: #555; line-height: 1.6; }
    a { color: #2563eb; text-decoration: none; }
    a:hover { text-decoration: underline; }
  </style>
</head>
<body>
  <h1>This link has expired.</h1>
  <p>
    Hey, this link's expired or invalid. Hop back to your
    <a href="/dashboard">dashboard</a> and we'll get you re-signed-in.
  </p>
</body>
</html>`);
  }

  const { email, scanId } = result;
  const location =
    `/dashboard?email=${encodeURIComponent(email)}&scan_id=${encodeURIComponent(scanId)}&from=magic`;

  res.writeHead(302, { Location: location });
  return res.end();
};
