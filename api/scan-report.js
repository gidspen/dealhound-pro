// api/scan-report.js
//
// Now ONLY serves as the magic-link bridge endpoint, folded into this file
// to stay under Vercel Hobby's 12-function cap.
//   /api/magic-link → /api/scan-report?_action=magic-link  (see vercel.json)
//
// The public scan-report data endpoint (?id=…) was retired 2026-05-10 along
// with the /scan/:id viewer surface. Magic link → /dashboard is now the only
// path to a delivered scan. See docs/USER_FLOWS.md.

module.exports = async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');

  if (req.method === 'OPTIONS') {
    res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
    return res.status(200).end();
  }

  if (req.method !== 'GET') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  if (req.query._action === 'magic-link') {
    const { handleMagicLink } = require('./_lib/magic-link-route');
    return handleMagicLink(req, res);
  }

  // Any other request to this endpoint is a leftover from the retired public
  // viewer. Send the user to the marketing page.
  return res.status(410).json({
    error: 'The public scan report has been retired. Open your dashboard via the email magic link.',
    redirectTo: '/',
  });
};
