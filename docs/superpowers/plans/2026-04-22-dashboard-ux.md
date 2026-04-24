# Dashboard UX Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a Claude-style authenticated dashboard at `/dashboard/` with a left sidebar (buy boxes + highlighted deals) and a main content area (chat or deal drill-down), replacing the fragmented post-login page-per-step flow.

**Architecture:** Single HTML page at `dashboard/index.html` using vanilla JS and the existing CSS variable system (`--bg`, `--gold`, `--surface`, etc.). A new `api/user-data.js` Vercel function powers the sidebar by fetching the user's buy boxes and top deals from Supabase. A new `api/deal-chat.js` function handles deal Q&A (separate from buy box intake chat). State is managed via a flat `appState` object with a `renderView()` dispatch function that swaps the main content panel between three views: `welcome`, `chat`, and `deal`.

**Tech Stack:** Vanilla HTML/CSS/JS, Vercel serverless functions (Node.js/CommonJS), Supabase via service key (server-side only), Cormorant Garamond + Outfit fonts, existing CSS design system.

**Staging:** Every push to the `feature/dashboard-ux` branch gets an automatic Vercel preview deployment. That URL is staging. No extra config needed.

---

## File Map

| Action | Path | Responsibility |
|--------|------|----------------|
| Create | `dashboard/index.html` | Full dashboard SPA — layout, sidebar, views, settings panel, JS |
| Create | `api/user-data.js` | GET endpoint — returns user's buy boxes + top deals from Supabase |
| Create | `api/deal-chat.js` | POST streaming endpoint — deal Q&A chat with deal context injected |
| Modify | `vercel.json` | Add function configs for two new API endpoints |

Existing pages (`chat/`, `scan/`, `results/`) are untouched. The dashboard links out to them as needed.

---

## Layout Reference

```
┌──────────────────────────────────────────────────────────────────┐
│ SIDEBAR (240px)          │  MAIN CONTENT AREA (flex: 1)         │
│                           │                                       │
│  ⚡ Deal Hound            │  [welcome]  Start a scan or select   │
│                           │             a deal from the sidebar   │
│  [+ New Scan]             │                                       │
│  ─────────────────────   │  [chat]     Buy-box intake chat       │
│  BUY BOXES                │             (reuses /api/chat logic)  │
│  Texas Micro Resorts ●    │                                       │
│    Apr 20 · 3 HOT deals   │  [deal]     Expanded deal card       │
│    [View Results]         │             + AI Q&A chat below it    │
│  + Add Buy Box            │                                       │
│  ─────────────────────   │                                       │
│  HIGHLIGHTED DEALS        │                                       │
│  Cedar Ridge Glamping     │                                       │
│  HOT · $1.2M · TX         │                                       │
│  Hillside B&B             │                                       │
│  STRONG · $850K · CO      │                                       │
│  ─────────────────────   │                                       │
│  ⚙ Settings               │                                       │
│  user@email.com           │                                       │
└──────────────────────────┴───────────────────────────────────────┘
```

Settings slide-in (overlays sidebar when open):
```
┌──────────────────────────┐
│ Settings            [×]  │
│ ─────────────────────── │
│ HELP                     │
│  Documentation →         │
│  Contact Support →       │
│                          │
│ BILLING                  │
│  Plan: Free              │
│  [Upgrade → $29/mo]      │
│                          │
│ NOTIFICATIONS            │
│  Daily Digest  [● ON]    │
│  Digest time   [9:00 AM] │
│ ─────────────────────── │
│  [Sign out]              │
└──────────────────────────┘
```

---

## Task 1: Create Branch

**Files:** none

- [ ] **Step 1: Create the feature branch**

  ```bash
  cd /Users/gideonspencer/dealhound-pro
  git checkout -b feature/dashboard-ux
  ```

- [ ] **Step 2: Verify branch**

  ```bash
  git branch --show-current
  ```
  Expected: `feature/dashboard-ux`

- [ ] **Step 3: Commit**

  ```bash
  git commit --allow-empty -m "chore: start feature/dashboard-ux branch"
  ```

---

## Task 2: Create `api/user-data.js`

**Files:**
- Create: `api/user-data.js`

This endpoint is called once on dashboard load. It returns the user's buy boxes (with scan metadata) and their top deals from the most recent completed scan.

**Contract:**
```
GET /api/user-data?email={email}

200 Response:
{
  "buy_boxes": [
    {
      "id": "uuid",
      "buy_box": { locations, price_min, price_max, property_types, ... },
      "status": "complete" | "scanning" | "ready",
      "run_at": "ISO date",
      "created_at": "ISO date"
    }
  ],
  "recent_deals": [
    {
      "id": "uuid",
      "title": "Cedar Ridge Glamping",
      "location": "Hill Country, TX",
      "price": 1200000,
      "acreage": 14,
      "rooms_keys": 8,
      "score_breakdown": { "strategy": { "overall": "STRONG MATCH" }, "risk": { "level": "MODERATE" } },
      "source": "LandSearch",
      "url": "https://...",
      "search_id": "uuid"
    }
  ],
  "last_scan": { "id": "uuid", "run_at": "ISO date", "status": "complete" } | null
}

400: { "error": "Missing email" }
500: { "error": "Failed to fetch user data" }
```

- [ ] **Step 0: Verify local env vars are configured**

  `npx vercel dev` loads env vars from `.env.local` (or from the linked Vercel project via `vercel env pull`). The three required vars are:
  ```
  SUPABASE_URL=https://[your-project].supabase.co
  SUPABASE_SERVICE_KEY=[service role key from Supabase dashboard]
  ANTHROPIC_API_KEY=[key from console.anthropic.com]
  ```
  Run `vercel env pull .env.local` if you haven't already. Never commit `.env.local`.

- [ ] **Step 1: Write the failing manual test**

  With no `api/user-data.js` file, confirm `GET /api/user-data?email=test@test.com` returns 404 on the Vercel dev server.

  ```bash
  cd /Users/gideonspencer/dealhound-pro
  npx vercel dev --listen 3001 &
  sleep 3
  curl -s http://localhost:3001/api/user-data?email=test@test.com | head -c 200
  ```
  Expected: 404 or "function not found" error.

- [ ] **Step 2: Create the endpoint**

  Create `api/user-data.js`:

  ```javascript
  const { createClient } = require('@supabase/supabase-js');

  const supabase = createClient(
    process.env.SUPABASE_URL,
    process.env.SUPABASE_SERVICE_KEY
  );

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

    const { email } = req.query;
    if (!email) {
      return res.status(400).json({ error: 'Missing email' });
    }

    try {
      // Fetch user's buy boxes, newest first
      const { data: searches, error: searchErr } = await supabase
        .from('deal_searches')
        .select('id, buy_box, status, run_at, created_at')
        .eq('user_email', email)
        .order('created_at', { ascending: false })
        .limit(10);

      if (searchErr) throw searchErr;

      // Top deals from most recent completed scan
      // NOTE: 'complete' is the terminal status set by the scan pipeline.
      // If the scan pipeline uses a different value (e.g. 'done'), update this filter.
      // Verify against the deal_searches table before running: SELECT DISTINCT status FROM deal_searches;
      let recentDeals = [];
      const lastScan = (searches || []).find(s => s.status === 'complete') || null;

      if (lastScan) {
        // Order by passed_hard_filters first (survivors first), then by id desc as a stable tie-breaker.
        // Do NOT order by 'score' — that column may not exist as a materialized column;
        // scoring data lives in the score_breakdown JSONB field.
        const { data: deals, error: dealsErr } = await supabase
          .from('deals')
          .select('id, title, location, price, acreage, rooms_keys, score_breakdown, source, url, search_id')
          .eq('search_id', lastScan.id)
          .eq('passed_hard_filters', true)
          .order('id', { ascending: false })
          .limit(5);

        if (!dealsErr) recentDeals = deals || [];
      }

      return res.status(200).json({
        buy_boxes: searches || [],
        recent_deals: recentDeals,
        last_scan: lastScan
      });

    } catch (err) {
      console.error('user-data error:', err.message);
      return res.status(500).json({ error: 'Failed to fetch user data' });
    }
  };
  ```

- [ ] **Step 3: Verify it returns 400 for missing email**

  ```bash
  curl -s http://localhost:3001/api/user-data
  ```
  Expected: `{"error":"Missing email"}`

- [ ] **Step 4: Verify it returns 200 for valid email (even with no data)**

  ```bash
  curl -s "http://localhost:3001/api/user-data?email=nobody@test.com"
  ```
  Expected: `{"buy_boxes":[],"recent_deals":[],"last_scan":null}`

- [ ] **Step 5: Commit**

  ```bash
  git add api/user-data.js
  git commit -m "feat: add /api/user-data endpoint for dashboard sidebar"
  ```

---

## Task 3: Create `api/deal-chat.js`

**Files:**
- Create: `api/deal-chat.js`

This is a streaming chat endpoint for deal Q&A. It takes a `deal` object (from the deals table) and `buy_box` as context, then lets the user ask questions. It does NOT call `save_buy_box` — it has no tools, just a focused system prompt.

**Contract:**
```
POST /api/deal-chat
Body: {
  "email": "string",
  "deal": { id, title, location, price, acreage, score_breakdown, ... },
  "buy_box": { locations, price_max, property_types, ... },
  "messages": [{ role, content }],
  "conversation_id": "uuid" | null
}

Response: text/event-stream
  data: {"type":"text","text":"..."}\n\n
  data: {"type":"conversation_id","id":"..."}\n\n
  data: {"type":"done"}\n\n
  data: {"type":"error","error":"..."}\n\n
```

- [ ] **Step 1: Create the endpoint**

  Create `api/deal-chat.js`:

  ```javascript
  const Anthropic = require('@anthropic-ai/sdk');
  const { createClient } = require('@supabase/supabase-js');

  const supabase = createClient(
    process.env.SUPABASE_URL,
    process.env.SUPABASE_SERVICE_KEY
  );

  function buildSystemPrompt(deal, buyBox) {
    const bb = buyBox ? JSON.stringify(buyBox, null, 2) : 'Not provided';
    const bd = deal.score_breakdown
      ? (typeof deal.score_breakdown === 'string'
          ? deal.score_breakdown
          : JSON.stringify(deal.score_breakdown, null, 2))
      : 'Not available';

    return `You are Deal Hound, an AI deal analyst. You are helping an investor evaluate a specific hospitality deal.

DEAL CONTEXT:
Name: ${deal.title || 'Unknown'}
Location: ${deal.location || 'Unknown'}
Price: ${deal.price ? '$' + Number(deal.price).toLocaleString() : 'Unknown'}
Acreage: ${deal.acreage ? deal.acreage + ' acres' : 'Unknown'}
Keys/Rooms: ${deal.rooms_keys || 'Unknown'}
Source: ${deal.source || 'Unknown'}
Listing URL: ${deal.url || 'Not provided'}

SCORE BREAKDOWN:
${bd}

INVESTOR BUY BOX:
${bb}

Your role: Answer questions about this specific deal. Be direct and analytical. Use the score breakdown to explain why the deal was rated as it was. Point out specific risks and opportunities. Help the investor decide if it's worth pursuing.

Rules:
- Stay focused on this deal and this investor's criteria
- Reference specific numbers (price, acreage, score) when answering
- If asked something you don't have data for, say so clearly
- Keep answers concise — 2-4 sentences unless more detail is explicitly requested
- Don't add fluff or encouragement. Be a sharp analyst, not a cheerleader`;
  }

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

    const { email, deal, buy_box, messages, conversation_id } = req.body;

    if (!email || !deal || !messages || !Array.isArray(messages)) {
      return res.status(400).json({ error: 'Missing required fields: email, deal, messages' });
    }

    try {
      const client = new Anthropic();

      res.setHeader('Content-Type', 'text/event-stream');
      res.setHeader('Cache-Control', 'no-cache');
      res.setHeader('Connection', 'keep-alive');

      const stream = await client.messages.stream({
        model: 'claude-sonnet-4-20250514',
        max_tokens: 1024,
        system: buildSystemPrompt(deal, buy_box),
        messages: messages.map(m => ({ role: m.role, content: m.content }))
      });

      let fullText = '';

      for await (const event of stream) {
        if (
          event.type === 'content_block_delta' &&
          event.delta.type === 'text_delta'
        ) {
          fullText += event.delta.text;
          res.write(`data: ${JSON.stringify({ type: 'text', text: event.delta.text })}\n\n`);
        }
      }

      // Save conversation
      const dealMsgs = [...messages, { role: 'assistant', content: fullText, timestamp: new Date().toISOString() }];

      if (conversation_id) {
        await supabase
          .from('conversations')
          .update({ messages: dealMsgs, updated_at: new Date().toISOString() })
          .eq('id', conversation_id);
      } else {
        const { data: convo } = await supabase
          .from('conversations')
          .insert({
            user_email: email,
            conversation_type: 'deal_qa',
            messages: dealMsgs,
            deal_id: deal.id || null
          })
          .select('id')
          .single();

        if (convo) {
          res.write(`data: ${JSON.stringify({ type: 'conversation_id', id: convo.id })}\n\n`);
        }
      }

      res.write(`data: ${JSON.stringify({ type: 'done' })}\n\n`);
      res.end();

    } catch (err) {
      console.error('deal-chat error:', err.message);
      if (!res.headersSent) {
        return res.status(500).json({ error: err.message || 'Internal server error' });
      }
      res.write(`data: ${JSON.stringify({ type: 'error', error: err.message })}\n\n`);
      res.end();
    }
  };
  ```

- [ ] **Step 2: Commit**

  ```bash
  git add api/deal-chat.js
  git commit -m "feat: add /api/deal-chat endpoint for deal Q&A"
  ```

---

## Task 4: Update `vercel.json`

**Files:**
- Modify: `vercel.json`

- [ ] **Step 1: Add the two new function configs**

  Current `vercel.json`:
  ```json
  {
    "functions": {
      "api/chat.js": { "maxDuration": 60 },
      "api/scan-start.js": { "maxDuration": 10 },
      "api/scan-progress.js": { "maxDuration": 10 }
    }
  }
  ```

  Updated `vercel.json`:
  ```json
  {
    "functions": {
      "api/chat.js": { "maxDuration": 60 },
      "api/scan-start.js": { "maxDuration": 10 },
      "api/scan-progress.js": { "maxDuration": 10 },
      "api/user-data.js": { "maxDuration": 10 },
      "api/deal-chat.js": { "maxDuration": 60 }
    }
  }
  ```

- [ ] **Step 2: Commit**

  ```bash
  git add vercel.json
  git commit -m "config: add vercel function configs for user-data and deal-chat"
  ```

---

## Task 5: Create `dashboard/index.html` — Layout Shell + CSS

**Files:**
- Create: `dashboard/index.html`

Build the HTML skeleton and full CSS. No JavaScript wiring yet. The page should render visually correct with placeholder content before any JS runs.

- [ ] **Step 1: Confirm the CSS variable set to use**

  The dashboard uses an extended set of CSS variables. Do NOT copy from `chat/index.html` — it is missing `--amber-dim`, `--red`, and `--red-dim`. Use the complete list below exactly:

  ```css
  --bg: #F8F5EF;
  --surface: #FFFFFF;
  --surface2: #F0EDE4;
  --border: rgba(0,0,0,0.08);
  --cream: #1D1D1B;
  --cream-dim: rgba(29,29,27,0.62);
  --cream-sub: rgba(29,29,27,0.38);
  --gold: #243D35;
  --gold-dim: rgba(36,61,53,0.10);
  --gold-glow: rgba(36,61,53,0.04);
  --green: #1a7f37;
  --green-dim: rgba(26,127,55,0.08);
  --amber: #b45309;
  --amber-dim: rgba(180,83,9,0.08);   /* not in chat/index.html — add it */
  --red: #b91c1c;                      /* not in chat/index.html — add it */
  --red-dim: rgba(185,28,28,0.08);    /* not in chat/index.html — add it */
  --sans: 'Outfit', system-ui, sans-serif;
  --serif: 'Cormorant Garamond', Georgia, serif;
  ```

- [ ] **Step 2: Create the file**

  Create `dashboard/index.html` with the full layout. Note the key structural IDs used by JavaScript later:

  - `#email-gate` — shown first; hidden after email entered
  - `#app` — the full dashboard layout; hidden until email entered
  - `#sidebar` — left panel
  - `#buy-boxes-list` — populated by JS
  - `#deals-list` — populated by JS
  - `#settings-panel` — hidden by default, shown when settings opens
  - `#main-content` — contains three children:
    - `#view-welcome` — default state
    - `#view-chat` — buy box intake chat
    - `#view-deal` — deal detail + Q&A

  Full file content:

  ```html
  <!DOCTYPE html>
  <html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Dashboard — Deal Hound</title>
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
    <link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:ital,wght@0,300;0,400;0,500;0,600;1,300;1,400&family=Outfit:wght@300;400;500;600&display=swap" rel="stylesheet" />

    <style>
      *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

      :root {
        --bg:        #F8F5EF;
        --surface:   #FFFFFF;
        --surface2:  #F0EDE4;
        --border:    rgba(0,0,0,0.08);
        --cream:     #1D1D1B;
        --cream-dim: rgba(29,29,27,0.62);
        --cream-sub: rgba(29,29,27,0.38);
        --gold:      #243D35;
        --gold-dim:  rgba(36,61,53,0.10);
        --gold-glow: rgba(36,61,53,0.04);
        --green:     #1a7f37;
        --green-dim: rgba(26,127,55,0.08);
        --amber:     #b45309;
        --amber-dim: rgba(180,83,9,0.08);
        --red:       #b91c1c;
        --red-dim:   rgba(185,28,28,0.08);
        --sans:      'Outfit', system-ui, sans-serif;
        --serif:     'Cormorant Garamond', Georgia, serif;
        --sidebar-w: 240px;
      }

      html, body { height: 100%; overflow: hidden; }

      body {
        background: var(--bg);
        color: var(--cream);
        font-family: var(--sans);
        font-weight: 300;
        line-height: 1.6;
        -webkit-font-smoothing: antialiased;
        display: flex;
        flex-direction: column;
      }

      /* Noise texture */
      body::before {
        content: '';
        position: fixed; inset: 0;
        background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 256 256' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='noise'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.9' numOctaves='4' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23noise)' opacity='0.035'/%3E%3C/svg%3E");
        pointer-events: none; z-index: 999; opacity: 0.4;
      }

      /* ── EMAIL GATE ─────────────────────────────── */
      #email-gate {
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        flex: 1;
        padding: 40px 32px;
        position: relative; z-index: 1;
      }
      #email-gate h1 {
        font-family: var(--serif);
        font-size: 2.4rem; font-weight: 400;
        text-align: center; margin-bottom: 12px;
      }
      #email-gate h1 em { font-style: italic; color: var(--gold); }
      #email-gate p {
        font-size: 0.92rem; color: var(--cream-dim);
        text-align: center; max-width: 400px; margin-bottom: 32px;
      }
      .gate-form {
        display: flex; gap: 10px; width: 100%; max-width: 420px;
      }
      .gate-form input {
        flex: 1; background: var(--surface);
        border: 1px solid var(--border); color: var(--cream);
        padding: 14px 18px; border-radius: 4px;
        font-family: var(--sans); font-size: 0.9rem; outline: none;
        transition: border-color 0.2s;
      }
      .gate-form input:focus { border-color: var(--gold); }
      .btn-primary {
        background: var(--gold); color: #FFF; border: none;
        padding: 14px 24px; border-radius: 4px;
        font-family: var(--sans); font-size: 0.85rem; font-weight: 500;
        letter-spacing: 0.04em; cursor: pointer; white-space: nowrap;
        transition: opacity 0.2s;
      }
      .btn-primary:hover { opacity: 0.88; }
      .btn-primary:disabled { opacity: 0.45; cursor: not-allowed; }

      /* ── APP SHELL ──────────────────────────────── */
      #app {
        display: none; /* shown by JS after email entered */
        flex: 1;
        overflow: hidden;
        position: relative; z-index: 1;
      }
      #app.active { display: flex; }

      /* ── SIDEBAR ────────────────────────────────── */
      #sidebar {
        width: var(--sidebar-w);
        flex-shrink: 0;
        background: var(--surface);
        border-right: 1px solid var(--border);
        display: flex;
        flex-direction: column;
        overflow: hidden;
        position: relative;
      }

      .sidebar-logo {
        padding: 20px 16px 16px;
        display: flex; align-items: center; gap: 8px;
        border-bottom: 1px solid var(--border);
        text-decoration: none; color: var(--cream);
        flex-shrink: 0;
      }
      .sidebar-logo-icon {
        width: 26px; height: 26px; background: var(--gold);
        border-radius: 5px; display: flex; align-items: center;
        justify-content: center;
      }
      .sidebar-logo-text {
        font-family: var(--serif); font-size: 1.1rem; font-weight: 500;
      }

      .sidebar-scroll {
        flex: 1; overflow-y: auto; padding: 12px 0;
      }
      .sidebar-scroll::-webkit-scrollbar { width: 3px; }
      .sidebar-scroll::-webkit-scrollbar-thumb { background: var(--border); border-radius: 2px; }

      /* New Scan button */
      .sidebar-new-scan {
        margin: 0 12px 16px;
        display: flex; align-items: center; gap: 8px;
        padding: 8px 12px; border-radius: 6px;
        background: var(--gold-dim); border: 1px solid rgba(36,61,53,0.15);
        color: var(--gold); font-size: 0.8rem; font-weight: 500;
        cursor: pointer; text-decoration: none;
        transition: background 0.15s;
        letter-spacing: 0.03em;
      }
      .sidebar-new-scan:hover { background: rgba(36,61,53,0.15); }
      .sidebar-new-scan svg { width: 14px; height: 14px; flex-shrink: 0; }

      /* Section headers */
      .sidebar-section-hdr {
        padding: 8px 16px 4px;
        font-size: 0.64rem; font-weight: 600;
        letter-spacing: 0.12em; text-transform: uppercase;
        color: var(--cream-sub);
      }

      /* Buy box row */
      .buybox-row {
        padding: 10px 16px; cursor: pointer;
        transition: background 0.12s;
        border-radius: 0;
      }
      .buybox-row:hover { background: var(--surface2); }
      .buybox-row.active { background: var(--gold-glow); }
      .buybox-row-name {
        font-size: 0.82rem; font-weight: 500; color: var(--cream);
        display: flex; align-items: center; gap: 6px;
        white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
      }
      .buybox-status-dot {
        width: 6px; height: 6px; border-radius: 50%; flex-shrink: 0;
        background: var(--cream-sub);
      }
      .buybox-status-dot.complete { background: var(--green); }
      .buybox-status-dot.scanning { background: var(--amber); }
      .buybox-row-meta {
        font-size: 0.72rem; color: var(--cream-sub);
        margin-top: 2px; padding-left: 12px;
      }
      .buybox-hot-count {
        display: inline-block;
        font-size: 0.65rem; font-weight: 600;
        background: var(--green-dim); color: var(--green);
        border-radius: 100px; padding: 1px 6px;
        margin-left: 4px;
      }
      .buybox-view-btn {
        display: inline-block; margin-top: 4px; margin-left: 12px;
        font-size: 0.7rem; color: var(--gold);
        text-decoration: none; font-weight: 500;
      }
      .buybox-view-btn:hover { text-decoration: underline; }

      .sidebar-add-link {
        display: flex; align-items: center; gap: 6px;
        padding: 8px 16px; font-size: 0.78rem;
        color: var(--cream-sub); cursor: pointer;
        transition: color 0.12s;
        text-decoration: none;
      }
      .sidebar-add-link:hover { color: var(--gold); }

      /* Highlighted deal row */
      .deal-row {
        padding: 10px 16px; cursor: pointer;
        transition: background 0.12s;
      }
      .deal-row:hover { background: var(--surface2); }
      .deal-row.active { background: var(--gold-glow); }
      .deal-row-name {
        font-size: 0.82rem; font-weight: 400; color: var(--cream);
        white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
      }
      .deal-row-meta {
        display: flex; align-items: center; gap: 6px;
        margin-top: 3px; font-size: 0.72rem; color: var(--cream-sub);
      }
      .deal-tier-badge {
        font-size: 0.6rem; font-weight: 600;
        letter-spacing: 0.1em; text-transform: uppercase;
        padding: 1px 6px; border-radius: 100px;
      }
      .tier-hot   { background: var(--green-dim); color: var(--green); }
      .tier-strong { background: var(--gold-dim); color: var(--gold); }
      .tier-watch { background: var(--amber-dim); color: var(--amber); }

      .sidebar-divider {
        height: 1px; background: var(--border);
        margin: 8px 0;
      }

      /* Sidebar bottom — settings + email */
      .sidebar-bottom {
        flex-shrink: 0;
        border-top: 1px solid var(--border);
        padding: 12px 16px;
        display: flex; align-items: center; gap: 10px;
      }
      .settings-btn {
        display: flex; align-items: center; justify-content: center;
        width: 32px; height: 32px;
        border-radius: 6px; border: 1px solid var(--border);
        background: transparent; cursor: pointer;
        transition: background 0.15s, border-color 0.15s;
        color: var(--cream-dim); flex-shrink: 0;
      }
      .settings-btn:hover { background: var(--surface2); border-color: var(--gold); color: var(--gold); }
      .settings-btn svg { width: 15px; height: 15px; }
      .sidebar-email {
        font-size: 0.72rem; color: var(--cream-sub);
        white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
        flex: 1;
      }

      /* ── SETTINGS PANEL ─────────────────────────── */
      #settings-panel {
        position: absolute;
        top: 0; left: 0;
        width: var(--sidebar-w);
        height: 100%;
        background: var(--surface);
        border-right: 1px solid var(--border);
        z-index: 50;
        display: flex; flex-direction: column;
        transform: translateX(-100%);
        transition: transform 0.22s ease;
        overflow-y: auto;
      }
      #settings-panel.open { transform: translateX(0); }

      .settings-header {
        display: flex; align-items: center; justify-content: space-between;
        padding: 20px 16px 16px;
        border-bottom: 1px solid var(--border);
        flex-shrink: 0;
      }
      .settings-title {
        font-family: var(--serif); font-size: 1.1rem; font-weight: 400;
      }
      .settings-close {
        width: 28px; height: 28px;
        display: flex; align-items: center; justify-content: center;
        border-radius: 4px; border: 1px solid var(--border);
        background: none; cursor: pointer; color: var(--cream-dim);
        font-size: 1rem; line-height: 1; transition: background 0.15s;
      }
      .settings-close:hover { background: var(--surface2); }

      .settings-section {
        padding: 16px 16px 8px;
        border-bottom: 1px solid var(--border);
      }
      .settings-section-title {
        font-size: 0.64rem; font-weight: 600;
        letter-spacing: 0.12em; text-transform: uppercase;
        color: var(--cream-sub); margin-bottom: 10px;
      }
      .settings-link {
        display: flex; align-items: center; justify-content: space-between;
        padding: 8px 0; font-size: 0.82rem; color: var(--cream-dim);
        text-decoration: none; cursor: pointer;
        transition: color 0.12s;
        border: none; background: none; width: 100%; text-align: left;
        font-family: var(--sans); font-weight: 300;
      }
      .settings-link:hover { color: var(--gold); }
      .settings-link svg { width: 12px; height: 12px; opacity: 0.4; }

      .billing-plan {
        font-size: 0.78rem; color: var(--cream-dim); margin-bottom: 10px;
      }
      .billing-plan strong { color: var(--cream); font-weight: 500; }
      .btn-upgrade {
        display: block; width: 100%; text-align: center;
        background: var(--gold); color: #FFF;
        padding: 9px 16px; border-radius: 4px;
        font-family: var(--sans); font-size: 0.78rem; font-weight: 500;
        letter-spacing: 0.04em; text-decoration: none;
        transition: opacity 0.2s; border: none; cursor: pointer;
      }
      .btn-upgrade:hover { opacity: 0.88; }

      .notif-row {
        display: flex; align-items: center; justify-content: space-between;
        padding: 8px 0; font-size: 0.82rem; color: var(--cream-dim);
      }
      /* Toggle switch */
      .toggle-wrap { position: relative; width: 36px; height: 20px; flex-shrink: 0; }
      .toggle-wrap input { opacity: 0; width: 0; height: 0; position: absolute; }
      .toggle-track {
        position: absolute; inset: 0;
        background: var(--border); border-radius: 10px;
        cursor: pointer; transition: background 0.2s;
      }
      .toggle-wrap input:checked + .toggle-track { background: var(--gold); }
      .toggle-track::after {
        content: '';
        position: absolute; top: 2px; left: 2px;
        width: 16px; height: 16px;
        background: white; border-radius: 50%;
        transition: transform 0.2s;
      }
      .toggle-wrap input:checked + .toggle-track::after { transform: translateX(16px); }

      .settings-bottom {
        padding: 16px;
        margin-top: auto;
      }
      .btn-signout {
        display: flex; align-items: center; gap: 8px;
        font-size: 0.78rem; color: var(--cream-sub);
        background: none; border: none; cursor: pointer;
        font-family: var(--sans); padding: 6px 0;
        transition: color 0.12s;
      }
      .btn-signout:hover { color: var(--red); }

      /* ── MAIN CONTENT ───────────────────────────── */
      #main-content {
        flex: 1;
        overflow: hidden;
        display: flex;
        flex-direction: column;
        position: relative;
      }

      /* ── VIEW: WELCOME ──────────────────────────── */
      #view-welcome {
        display: none;
        flex: 1;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        padding: 40px;
        text-align: center;
      }
      #view-welcome.active { display: flex; }
      .welcome-icon {
        width: 56px; height: 56px; background: var(--gold);
        border-radius: 12px; display: flex; align-items: center;
        justify-content: center; margin-bottom: 20px;
      }
      #view-welcome h2 {
        font-family: var(--serif); font-size: 1.8rem; font-weight: 400;
        margin-bottom: 10px; color: var(--cream);
      }
      #view-welcome h2 em { font-style: italic; color: var(--gold); }
      #view-welcome p {
        font-size: 0.9rem; color: var(--cream-dim);
        max-width: 380px; margin-bottom: 28px;
      }
      .welcome-actions { display: flex; gap: 12px; flex-wrap: wrap; justify-content: center; }
      .btn-secondary {
        background: var(--surface); border: 1px solid var(--border);
        color: var(--cream-dim); padding: 10px 20px; border-radius: 4px;
        font-family: var(--sans); font-size: 0.82rem; font-weight: 400;
        cursor: pointer; transition: border-color 0.2s, color 0.2s;
        text-decoration: none;
      }
      .btn-secondary:hover { border-color: var(--gold); color: var(--gold); }

      /* ── VIEW: CHAT (buy box intake) ────────────── */
      #view-chat {
        display: none;
        flex: 1;
        flex-direction: column;
        min-height: 0;
      }
      #view-chat.active { display: flex; }

      /* Chat header */
      .chat-header {
        padding: 16px 24px;
        border-bottom: 1px solid var(--border);
        background: rgba(248,245,239,0.92);
        backdrop-filter: blur(12px);
        display: flex; align-items: center; justify-content: space-between;
        flex-shrink: 0;
      }
      .chat-header-title {
        font-size: 0.82rem; font-weight: 500;
        color: var(--cream-dim); letter-spacing: 0.04em;
      }
      .btn-back {
        font-size: 0.75rem; color: var(--cream-sub);
        background: none; border: none; cursor: pointer;
        font-family: var(--sans); padding: 0;
        transition: color 0.15s;
      }
      .btn-back:hover { color: var(--gold); }

      /* Messages */
      .messages {
        flex: 1; overflow-y: auto;
        padding: 24px 32px 16px;
        display: flex; flex-direction: column; gap: 18px;
        max-width: 720px; width: 100%; margin: 0 auto;
      }
      .messages::-webkit-scrollbar { width: 4px; }
      .messages::-webkit-scrollbar-thumb { background: var(--border); border-radius: 4px; }

      .msg { line-height: 1.65; font-size: 0.9rem; animation: fadeIn 0.2s ease; }
      @keyframes fadeIn {
        from { opacity: 0; transform: translateY(6px); }
        to { opacity: 1; transform: translateY(0); }
      }
      .msg-assistant { align-self: flex-start; }
      .msg-assistant .msg-label {
        font-size: 0.68rem; font-weight: 600;
        letter-spacing: 0.1em; text-transform: uppercase;
        color: var(--gold); margin-bottom: 5px;
        display: flex; align-items: center; gap: 5px;
      }
      .msg-assistant .msg-label .dot {
        width: 6px; height: 6px; background: var(--green); border-radius: 50%;
      }
      .msg-assistant .msg-body {
        background: var(--surface); border: 1px solid var(--border);
        padding: 14px 18px; border-radius: 4px 14px 14px 14px;
        color: var(--cream);
      }
      .msg-user {
        align-self: flex-end;
        background: var(--gold); color: #FFF;
        padding: 12px 18px; border-radius: 14px 14px 4px 14px;
        font-weight: 400; max-width: 85%;
      }
      .typing {
        display: flex; gap: 4px; padding: 6px 0;
      }
      .typing span {
        width: 6px; height: 6px;
        background: var(--cream-sub); border-radius: 50%;
        animation: typingDot 1.4s ease-in-out infinite;
      }
      .typing span:nth-child(2) { animation-delay: 0.2s; }
      .typing span:nth-child(3) { animation-delay: 0.4s; }
      @keyframes typingDot {
        0%, 60%, 100% { opacity: 0.3; transform: scale(0.8); }
        30% { opacity: 1; transform: scale(1); }
      }

      /* Buy box confirmed card */
      .buybox-confirmed {
        background: var(--gold-glow); border: 1px solid rgba(36,61,53,0.2);
        border-radius: 10px; padding: 18px 22px; margin-top: 10px;
        animation: fadeIn 0.3s ease;
      }
      .buybox-confirmed .label {
        font-size: 0.68rem; font-weight: 600;
        letter-spacing: 0.12em; text-transform: uppercase;
        color: var(--gold); margin-bottom: 6px;
      }
      .buybox-confirmed .cta {
        display: inline-block; margin-top: 14px;
        background: var(--gold); color: #FFF;
        padding: 10px 24px; border-radius: 4px;
        font-family: var(--sans); font-size: 0.82rem; font-weight: 500;
        letter-spacing: 0.04em; text-decoration: none;
        transition: opacity 0.2s;
      }
      .buybox-confirmed .cta:hover { opacity: 0.88; }

      /* Input bar */
      .input-bar {
        padding: 14px 32px 20px;
        border-top: 1px solid var(--border);
        background: rgba(248,245,239,0.95);
        backdrop-filter: blur(10px);
        flex-shrink: 0;
      }
      .input-inner {
        max-width: 720px; margin: 0 auto;
        display: flex; gap: 10px;
      }
      .input-inner input {
        flex: 1; background: var(--surface);
        border: 1px solid var(--border); color: var(--cream);
        padding: 12px 16px; border-radius: 8px;
        font-family: var(--sans); font-size: 0.9rem; outline: none;
        transition: border-color 0.2s;
      }
      .input-inner input:focus { border-color: var(--gold); }
      .btn-send {
        background: var(--gold); color: #FFF; border: none;
        padding: 12px 18px; border-radius: 8px;
        font-family: var(--sans); font-size: 0.82rem; font-weight: 500;
        cursor: pointer; display: flex; align-items: center; gap: 5px;
        transition: opacity 0.2s;
      }
      .btn-send:hover { opacity: 0.88; }
      .btn-send:disabled { opacity: 0.4; cursor: not-allowed; }
      .btn-send svg { width: 15px; height: 15px; }

      /* ── VIEW: DEAL ──────────────────────────────── */
      #view-deal {
        display: none;
        flex: 1;
        flex-direction: column;
        min-height: 0;
        overflow-y: auto;
      }
      #view-deal.active { display: flex; }

      .deal-detail-header {
        padding: 20px 32px;
        border-bottom: 1px solid var(--border);
        background: rgba(248,245,239,0.92);
        backdrop-filter: blur(12px);
        flex-shrink: 0;
        display: flex; align-items: center; gap: 16px;
      }

      .deal-detail-body {
        padding: 24px 32px;
        max-width: 760px;
        width: 100%;
        margin: 0 auto;
        display: flex;
        flex-direction: column;
        gap: 24px;
      }

      .deal-full-card {
        background: var(--surface); border: 1px solid var(--border);
        border-radius: 14px; padding: 24px;
        position: relative;
      }
      .deal-full-card.hot {
        border-color: rgba(36,61,53,0.25);
        background: linear-gradient(135deg, var(--surface) 0%, rgba(36,61,53,0.02) 100%);
      }

      .deal-meta-grid {
        display: grid; grid-template-columns: repeat(3, 1fr);
        gap: 12px; margin: 16px 0;
      }
      .deal-meta-cell {
        background: var(--surface2); border: 1px solid var(--border);
        border-radius: 8px; padding: 10px 14px;
      }
      .deal-meta-cell .dmc-label {
        font-size: 0.65rem; font-weight: 500;
        letter-spacing: 0.1em; text-transform: uppercase;
        color: var(--cream-sub); margin-bottom: 2px;
      }
      .deal-meta-cell .dmc-value {
        font-size: 0.9rem; font-weight: 500; color: var(--cream);
      }

      .deal-score-bars {
        display: flex; flex-wrap: wrap; gap: 12px; margin: 12px 0;
      }
      .score-bar-item { display: flex; align-items: center; gap: 8px; }
      .score-bar-item .sbi-label {
        font-size: 0.72rem; color: var(--cream-sub); min-width: 60px;
      }
      .score-bar-item .sbi-track {
        width: 64px; height: 5px; background: var(--border);
        border-radius: 3px; overflow: hidden;
      }
      .score-bar-item .sbi-fill {
        height: 100%; background: var(--gold); border-radius: 3px;
      }

      /* Deal Q&A chat section */
      .deal-qa-section {
        background: var(--surface); border: 1px solid var(--border);
        border-radius: 12px; overflow: hidden;
      }
      .deal-qa-header {
        padding: 14px 20px;
        border-bottom: 1px solid var(--border);
        font-size: 0.8rem; font-weight: 500; color: var(--cream-dim);
        background: var(--surface2);
      }
      .deal-qa-messages {
        min-height: 120px; max-height: 320px;
        overflow-y: auto; padding: 16px 20px;
        display: flex; flex-direction: column; gap: 14px;
      }
      .deal-qa-input {
        border-top: 1px solid var(--border);
        padding: 12px 16px;
        display: flex; gap: 8px;
        background: var(--surface);
      }
      .deal-qa-input input {
        flex: 1; background: var(--surface2);
        border: 1px solid var(--border); color: var(--cream);
        padding: 9px 14px; border-radius: 6px;
        font-family: var(--sans); font-size: 0.85rem; outline: none;
        transition: border-color 0.2s;
      }
      .deal-qa-input input:focus { border-color: var(--gold); }
      .btn-qa-send {
        background: var(--gold); color: #FFF; border: none;
        padding: 9px 16px; border-radius: 6px;
        font-size: 0.8rem; font-weight: 500; cursor: pointer;
        transition: opacity 0.2s; white-space: nowrap;
      }
      .btn-qa-send:hover { opacity: 0.88; }
      .btn-qa-send:disabled { opacity: 0.4; cursor: not-allowed; }

      /* Reused tier/risk pills */
      .tier-badge {
        font-size: 0.65rem; font-weight: 600;
        letter-spacing: 0.12em; text-transform: uppercase;
        padding: 3px 10px; border-radius: 100px;
      }
      .risk-pill {
        font-size: 0.7rem; font-weight: 500;
        padding: 3px 10px; border-radius: 100px;
      }
      .risk-low    { background: var(--green-dim); color: var(--green); border: 1px solid rgba(26,127,55,0.2); }
      .risk-moderate { background: var(--gold-dim); color: var(--gold); border: 1px solid rgba(36,61,53,0.2); }
      .risk-high   { background: var(--amber-dim); color: var(--amber); border: 1px solid rgba(180,83,9,0.2); }
      .risk-very-high { background: var(--red-dim); color: var(--red); border: 1px solid rgba(185,28,28,0.2); }

      .deal-actions-row {
        display: flex; align-items: center; gap: 12px;
        padding-top: 14px; border-top: 1px solid var(--border);
        margin-top: 8px;
      }
      .btn-view-listing {
        display: inline-flex; align-items: center; gap: 5px;
        font-size: 0.8rem; font-weight: 500; color: var(--gold);
        text-decoration: none;
      }
      .btn-view-listing:hover { text-decoration: underline; }
      .btn-view-results {
        font-size: 0.75rem; color: var(--cream-dim);
        background: var(--surface2); border: 1px solid var(--border);
        padding: 6px 14px; border-radius: 100px;
        text-decoration: none; transition: all 0.2s; margin-left: auto;
      }
      .btn-view-results:hover { border-color: var(--gold); color: var(--gold); }

      /* ── MOBILE ─────────────────────────────────── */
      .mobile-topbar {
        display: none;
        padding: 12px 16px;
        border-bottom: 1px solid var(--border);
        background: var(--surface);
        align-items: center;
        justify-content: space-between;
        flex-shrink: 0;
        z-index: 10;
      }
      .hamburger {
        background: none; border: none; cursor: pointer;
        color: var(--cream); padding: 4px;
      }
      .hamburger svg { width: 20px; height: 20px; display: block; }

      @media (max-width: 768px) {
        :root { --sidebar-w: 100%; }
        .mobile-topbar { display: flex; }
        #sidebar {
          position: fixed; top: 49px; left: 0; bottom: 0;
          z-index: 40;
          transform: translateX(-100%);
          transition: transform 0.22s ease;
          width: 280px;
        }
        #sidebar.mobile-open { transform: translateX(0); }
        #main-content { flex: 1; overflow: hidden; }
        .messages { padding: 16px 16px 12px; }
        .input-bar { padding: 10px 16px 18px; }
        .deal-detail-body { padding: 16px; }
        .deal-meta-grid { grid-template-columns: repeat(2, 1fr); }
      }
    </style>
  </head>
  <body>

    <!-- EMAIL GATE (shown until user enters email) -->
    <div id="email-gate">
      <h1>Your <em>deal hunting</em><br>command center.</h1>
      <p>Enter your email to access your buy boxes, scan results, and top deals.</p>
      <form class="gate-form" id="gate-form">
        <input type="email" id="gate-email" placeholder="your@email.com" required autocomplete="email" autofocus />
        <button type="submit" class="btn-primary">Open Dashboard</button>
      </form>
    </div>

    <!-- MOBILE TOP BAR -->
    <div class="mobile-topbar" id="mobile-topbar" style="display:none">
      <button class="hamburger" id="hamburger-btn" onclick="toggleMobileSidebar()">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round">
          <line x1="3" y1="6" x2="21" y2="6"/>
          <line x1="3" y1="12" x2="21" y2="12"/>
          <line x1="3" y1="18" x2="21" y2="18"/>
        </svg>
      </button>
      <span style="font-family:var(--serif);font-size:1rem;font-weight:500;">Deal Hound</span>
      <div style="width:28px"></div><!-- spacer -->
    </div>

    <!-- APP SHELL -->
    <div id="app">
      <!-- SIDEBAR -->
      <div id="sidebar">
        <!-- Settings panel (slides over sidebar) -->
        <div id="settings-panel">
          <div class="settings-header">
            <span class="settings-title">Settings</span>
            <button class="settings-close" onclick="closeSettings()">×</button>
          </div>

          <!-- Help -->
          <div class="settings-section">
            <div class="settings-section-title">Help</div>
            <a href="mailto:support@dealhound.pro" class="settings-link">
              Contact Support
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M18 13v6a2 2 0 01-2 2H5a2 2 0 01-2-2V8a2 2 0 012-2h6"/><polyline points="15 3 21 3 21 9"/><line x1="10" y1="14" x2="21" y2="3"/></svg>
            </a>
            <a href="https://dealhound.pro/docs" target="_blank" class="settings-link">
              Documentation
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M18 13v6a2 2 0 01-2 2H5a2 2 0 01-2-2V8a2 2 0 012-2h6"/><polyline points="15 3 21 3 21 9"/><line x1="10" y1="14" x2="21" y2="3"/></svg>
            </a>
          </div>

          <!-- Billing -->
          <div class="settings-section">
            <div class="settings-section-title">Billing</div>
            <div class="billing-plan">Current plan: <strong id="billing-plan-label">Free</strong></div>
            <button class="btn-upgrade" onclick="handleUpgrade()">Upgrade to Pro — $29/mo</button>
          </div>

          <!-- Notifications -->
          <div class="settings-section">
            <div class="settings-section-title">Notifications</div>
            <div class="notif-row">
              <span>Daily digest email</span>
              <label class="toggle-wrap">
                <input type="checkbox" id="notif-digest" onchange="saveNotifPrefs()" />
                <span class="toggle-track"></span>
              </label>
            </div>
          </div>

          <!-- Sign out -->
          <div class="settings-bottom">
            <button class="btn-signout" onclick="signOut()">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M9 21H5a2 2 0 01-2-2V5a2 2 0 012-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>
              Sign out
            </button>
          </div>
        </div><!-- /settings-panel -->

        <!-- Logo -->
        <a href="/dashboard/" class="sidebar-logo">
          <div class="sidebar-logo-icon">
            <svg width="13" height="13" viewBox="0 0 16 16" fill="white"><path d="M8 0 L9.6 6.4 L16 8 L9.6 9.6 L8 16 L6.4 9.6 L0 8 L6.4 6.4 Z"/></svg>
          </div>
          <span class="sidebar-logo-text">Deal Hound</span>
        </a>

        <!-- Scrollable content -->
        <div class="sidebar-scroll">
          <!-- New Scan button -->
          <div style="padding:12px 12px 0">
            <a href="#" class="sidebar-new-scan" onclick="startNewScan(); return false;">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round">
                <line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/>
              </svg>
              New Scan
            </a>
          </div>

          <!-- Buy Boxes -->
          <div class="sidebar-section-hdr" style="margin-top:8px;">Buy Boxes</div>
          <div id="buy-boxes-list">
            <!-- Populated by JS -->
            <div style="padding:8px 16px;font-size:0.78rem;color:var(--cream-sub);">Loading...</div>
          </div>
          <a href="#" class="sidebar-add-link" onclick="startNewScan(); return false;">
            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
            Add Buy Box
          </a>

          <div class="sidebar-divider"></div>

          <!-- Highlighted Deals -->
          <div class="sidebar-section-hdr">Highlighted Deals</div>
          <div id="deals-list">
            <!-- Populated by JS -->
            <div style="padding:8px 16px;font-size:0.78rem;color:var(--cream-sub);">Loading...</div>
          </div>
        </div><!-- /sidebar-scroll -->

        <!-- Bottom: settings + email -->
        <div class="sidebar-bottom">
          <button class="settings-btn" onclick="openSettings()" title="Settings">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round">
              <circle cx="12" cy="12" r="3"/>
              <path d="M19.4 15a1.65 1.65 0 00.33 1.82l.06.06a2 2 0 010 2.83 2 2 0 01-2.83 0l-.06-.06a1.65 1.65 0 00-1.82-.33 1.65 1.65 0 00-1 1.51V21a2 2 0 01-2 2 2 2 0 01-2-2v-.09A1.65 1.65 0 009 19.4a1.65 1.65 0 00-1.82.33l-.06.06a2 2 0 01-2.83 0 2 2 0 010-2.83l.06-.06A1.65 1.65 0 004.68 15a1.65 1.65 0 00-1.51-1H3a2 2 0 01-2-2 2 2 0 012-2h.09A1.65 1.65 0 004.6 9a1.65 1.65 0 00-.33-1.82l-.06-.06a2 2 0 010-2.83 2 2 0 012.83 0l.06.06A1.65 1.65 0 009 4.68a1.65 1.65 0 001-1.51V3a2 2 0 012-2 2 2 0 012 2v.09a1.65 1.65 0 001 1.51 1.65 1.65 0 001.82-.33l.06-.06a2 2 0 012.83 0 2 2 0 010 2.83l-.06.06A1.65 1.65 0 0019.4 9a1.65 1.65 0 001.51 1H21a2 2 0 012 2 2 2 0 01-2 2h-.09a1.65 1.65 0 00-1.51 1z"/>
            </svg>
          </button>
          <span class="sidebar-email" id="sidebar-email">—</span>
        </div>
      </div><!-- /sidebar -->

      <!-- MAIN CONTENT -->
      <div id="main-content">

        <!-- VIEW: WELCOME -->
        <div id="view-welcome">
          <div class="welcome-icon">
            <svg width="24" height="24" viewBox="0 0 16 16" fill="white"><path d="M8 0 L9.6 6.4 L16 8 L9.6 9.6 L8 16 L6.4 9.6 L0 8 L6.4 6.4 Z"/></svg>
          </div>
          <h2>Your agent is <em>ready.</em></h2>
          <p id="welcome-sub">Start a new scan to find deals that match your criteria, or select a deal from the sidebar to drill in.</p>
          <div class="welcome-actions">
            <a href="#" class="btn-primary" onclick="startNewScan(); return false;">Start a New Scan</a>
            <a href="#" id="welcome-view-results" class="btn-secondary" style="display:none">View Latest Results</a>
          </div>
        </div>

        <!-- VIEW: CHAT (buy box intake) -->
        <div id="view-chat">
          <div class="chat-header">
            <span class="chat-header-title">Set Up Buy Box</span>
            <button class="btn-back" onclick="showView('welcome')">← Back</button>
          </div>
          <div class="messages" id="chat-messages"></div>
          <div class="input-bar">
            <div class="input-inner">
              <input type="text" id="chat-input" placeholder="Type your answer..." autocomplete="off" />
              <button class="btn-send" id="chat-send-btn" onclick="sendChatMessage()">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                  <line x1="22" y1="2" x2="11" y2="13"/>
                  <polygon points="22 2 15 22 11 13 2 9 22 2"/>
                </svg>
              </button>
            </div>
          </div>
        </div>

        <!-- VIEW: DEAL DETAIL -->
        <div id="view-deal">
          <div class="deal-detail-header">
            <button class="btn-back" onclick="showView('welcome')">← Back</button>
            <span id="deal-header-title" style="font-size:0.9rem;color:var(--cream-dim);font-weight:400;"></span>
          </div>
          <div class="deal-detail-body" id="deal-detail-body">
            <!-- Populated by renderDealView(deal) -->
          </div>
        </div>

      </div><!-- /main-content -->
    </div><!-- /app -->

    <script>
      // ── STATE ─────────────────────────────────────────────────────────────
      const state = {
        email: null,
        view: 'welcome',
        activeDeal: null,
        buyBoxes: [],
        recentDeals: [],
        lastScan: null,
        settingsOpen: false,
        // chat state
        chatHistory: [],
        chatConversationId: null,
        chatStreaming: false,
        // deal Q&A state
        dealChatHistory: [],
        dealConversationId: null,
        dealChatStreaming: false
      };

      // ── INIT ──────────────────────────────────────────────────────────────
      (function init() {
        const params = new URLSearchParams(window.location.search);
        const urlEmail = params.get('email');
        const stored = localStorage.getItem('dh_email');
        const email = urlEmail || stored;

        if (email) {
          enterDashboard(email);
        }
        // else: email gate is visible by default
      })();

      document.getElementById('gate-form').addEventListener('submit', function(e) {
        e.preventDefault();
        const email = document.getElementById('gate-email').value.trim();
        if (email) enterDashboard(email);
      });

      document.getElementById('chat-input').addEventListener('keydown', function(e) {
        if (e.key === 'Enter' && !e.shiftKey) {
          e.preventDefault();
          sendChatMessage();
        }
      });

      // ── ENTER DASHBOARD ───────────────────────────────────────────────────
      async function enterDashboard(email) {
        state.email = email;
        localStorage.setItem('dh_email', email);

        document.getElementById('email-gate').style.display = 'none';
        document.getElementById('app').classList.add('active');
        document.getElementById('mobile-topbar').style.display = 'flex';
        document.getElementById('sidebar-email').textContent = email;

        // Load notification prefs
        const digestOn = localStorage.getItem('dh_notif_digest') !== 'false';
        document.getElementById('notif-digest').checked = digestOn;

        // Load user data for sidebar
        await loadUserData();

        // Show welcome view
        showView('welcome');
      }

      // ── USER DATA ─────────────────────────────────────────────────────────
      async function loadUserData() {
        try {
          const res = await fetch(`/api/user-data?email=${encodeURIComponent(state.email)}`);
          if (!res.ok) throw new Error('Failed');
          const data = await res.json();
          state.buyBoxes = data.buy_boxes || [];
          state.recentDeals = data.recent_deals || [];
          state.lastScan = data.last_scan || null;
          renderSidebar();
        } catch (err) {
          document.getElementById('buy-boxes-list').innerHTML =
            '<div style="padding:8px 16px;font-size:0.78rem;color:var(--cream-sub);">Could not load data</div>';
          document.getElementById('deals-list').innerHTML = '';
        }
      }

      // ── SIDEBAR RENDER ────────────────────────────────────────────────────
      function renderSidebar() {
        renderBuyBoxes();
        renderDeals();
        // Show "View Latest Results" in welcome view if there's a completed scan
        if (state.lastScan) {
          const btn = document.getElementById('welcome-view-results');
          btn.style.display = 'inline-block';
          btn.href = `/results/?id=${state.lastScan.id}`;
          document.getElementById('welcome-sub').textContent =
            'Your agent found deals on the last scan. Select one from the sidebar to drill in, or start a new scan.';
        }
      }

      function renderBuyBoxes() {
        const el = document.getElementById('buy-boxes-list');
        if (!state.buyBoxes.length) {
          el.innerHTML = '<div style="padding:8px 16px;font-size:0.78rem;color:var(--cream-sub);">No buy boxes yet</div>';
          return;
        }
        el.innerHTML = state.buyBoxes.map(bb => {
          const box = typeof bb.buy_box === 'string' ? JSON.parse(bb.buy_box) : (bb.buy_box || {});
          const label = buyBoxLabel(box);
          const status = bb.status || 'ready';
          const dotClass = status === 'complete' ? 'complete' : (status === 'scanning' ? 'scanning' : '');
          const runDate = bb.run_at ? new Date(bb.run_at).toLocaleDateString('en-US', { month: 'short', day: 'numeric' }) : '';
          return `
            <div class="buybox-row" data-id="${bb.id}">
              <div class="buybox-row-name">
                <span class="buybox-status-dot ${dotClass}"></span>
                ${escHtml(label)}
              </div>
              <div class="buybox-row-meta">
                ${runDate ? runDate + ' · ' : ''}
                ${status === 'complete' ? '<span class="buybox-hot-count">View results</span>' : status}
              </div>
              ${status === 'complete'
                ? `<a href="/results/?id=${bb.id}" class="buybox-view-btn">View Results →</a>`
                : `<a href="/scan/?id=${bb.id}" class="buybox-view-btn">View Scan →</a>`}
            </div>`;
        }).join('');
      }

      function buyBoxLabel(box) {
        if (box.locations && box.locations.length) return box.locations[0];
        if (box.property_types && box.property_types.length) return box.property_types[0].replace(/_/g, ' ');
        return 'Buy Box';
      }

      function renderDeals() {
        const el = document.getElementById('deals-list');
        if (!state.recentDeals.length) {
          el.innerHTML = '<div style="padding:8px 16px;font-size:0.78rem;color:var(--cream-sub);">No deals yet — run a scan</div>';
          return;
        }
        el.innerHTML = state.recentDeals.map((deal, i) => {
          const bd = parseBreakdown(deal.score_breakdown);
          const tier = tierFromStrategy(bd.strategy?.overall);
          const tierLabel = { hot: 'HOT', strong: 'STRONG', watch: 'WATCH' }[tier];
          const price = deal.price ? '$' + fmtPrice(deal.price) : '';
          const loc = deal.location ? deal.location.split(',')[0] : '';
          return `
            <div class="deal-row" onclick="openDeal(${i})" data-i="${i}">
              <div class="deal-row-name">${escHtml(deal.title || 'Untitled')}</div>
              <div class="deal-row-meta">
                <span class="deal-tier-badge tier-${tier}">${tierLabel}</span>
                ${price}${loc ? ' · ' + loc : ''}
              </div>
            </div>`;
        }).join('');
      }

      // ── VIEW MANAGEMENT ───────────────────────────────────────────────────
      function showView(view) {
        state.view = view;
        document.getElementById('view-welcome').classList.toggle('active', view === 'welcome');
        document.getElementById('view-chat').classList.toggle('active', view === 'chat');
        document.getElementById('view-deal').classList.toggle('active', view === 'deal');
        // Close mobile sidebar when navigating
        document.getElementById('sidebar').classList.remove('mobile-open');
      }

      // ── NEW SCAN (chat view) ──────────────────────────────────────────────
      function startNewScan() {
        // Reset chat state
        state.chatHistory = [];
        state.chatConversationId = null;
        state.chatStreaming = false;
        document.getElementById('chat-messages').innerHTML = '';
        document.getElementById('chat-input').value = '';

        showView('chat');
        initChat();
      }

      async function initChat() {
        showChatTyping();
        state.chatHistory = [{ role: 'user', content: 'Hi, I want to set up my buy box.' }];
        try {
          const res = await fetch('/api/chat', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
              email: state.email,
              messages: state.chatHistory,
              conversation_id: null
            })
          });
          hideChatTyping();
          await handleChatStream(res);
        } catch (err) {
          hideChatTyping();
          addChatMessage('assistant', 'Something went wrong. Please refresh.');
        }
      }

      async function sendChatMessage() {
        if (state.chatStreaming) return;
        const input = document.getElementById('chat-input');
        const text = input.value.trim();
        if (!text) return;
        input.value = '';
        addChatMessage('user', text);
        state.chatHistory.push({ role: 'user', content: text });
        state.chatStreaming = true;
        document.getElementById('chat-send-btn').disabled = true;
        showChatTyping();
        try {
          const res = await fetch('/api/chat', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
              email: state.email,
              messages: state.chatHistory,
              conversation_id: state.chatConversationId
            })
          });
          hideChatTyping();
          await handleChatStream(res);
        } catch (err) {
          hideChatTyping();
          addChatMessage('assistant', 'Connection lost. Try again.');
        }
        state.chatStreaming = false;
        document.getElementById('chat-send-btn').disabled = false;
        document.getElementById('chat-input').focus();
      }

      async function handleChatStream(response) {
        const reader = response.body.getReader();
        const decoder = new TextDecoder();
        let assistantText = '';
        let msgEl = null;
        let buffer = '';

        while (true) {
          const { done, value } = await reader.read();
          if (done) break;
          buffer += decoder.decode(value, { stream: true });
          const lines = buffer.split('\n');
          buffer = lines.pop();
          for (const line of lines) {
            if (!line.startsWith('data: ')) continue;
            const json = line.slice(6);
            if (!json) continue;
            try {
              const event = JSON.parse(json);
              if (event.type === 'text') {
                if (!msgEl) msgEl = addChatMessage('assistant', '');
                assistantText += event.text;
                msgEl.querySelector('.msg-body').textContent = assistantText;
                scrollChatToBottom();
              } else if (event.type === 'conversation_id') {
                state.chatConversationId = event.id;
              } else if (event.type === 'buy_box_saved') {
                showBuyBoxConfirmed(event.buy_box, event.search_id);
              } else if (event.type === 'error') {
                addChatMessage('assistant', 'Error: ' + event.error);
              }
            } catch (e) { /* skip */ }
          }
        }
        if (assistantText) state.chatHistory.push({ role: 'assistant', content: assistantText });
      }

      function addChatMessage(role, text) {
        const msgs = document.getElementById('chat-messages');
        const div = document.createElement('div');
        div.className = `msg msg-${role}`;
        if (role === 'assistant') {
          div.innerHTML = `<div class="msg-label"><span class="dot"></span> Deal Hound</div><div class="msg-body">${escHtml(text)}</div>`;
        } else {
          div.textContent = text;
        }
        msgs.appendChild(div);
        scrollChatToBottom();
        return div;
      }

      function showChatTyping() {
        const msgs = document.getElementById('chat-messages');
        if (document.getElementById('chat-typing')) return;
        const t = document.createElement('div');
        t.id = 'chat-typing';
        t.className = 'msg msg-assistant';
        t.innerHTML = `<div class="msg-label"><span class="dot"></span> Deal Hound</div><div class="typing"><span></span><span></span><span></span></div>`;
        msgs.appendChild(t);
        scrollChatToBottom();
      }
      function hideChatTyping() {
        const t = document.getElementById('chat-typing');
        if (t) t.remove();
      }
      function scrollChatToBottom() {
        const msgs = document.getElementById('chat-messages');
        msgs.scrollTop = msgs.scrollHeight;
      }

      function showBuyBoxConfirmed(buyBox, searchId) {
        const msgs = document.getElementById('chat-messages');
        const div = document.createElement('div');
        div.className = 'buybox-confirmed';
        const summary = [];
        if (buyBox.locations) summary.push(`Markets: ${buyBox.locations.join(', ')}`);
        if (buyBox.price_min || buyBox.price_max) {
          const min = buyBox.price_min ? '$' + fmtPrice(buyBox.price_min) : 'No min';
          const max = buyBox.price_max ? '$' + fmtPrice(buyBox.price_max) : 'No max';
          summary.push(`Price: ${min} – ${max}`);
        }
        if (buyBox.property_types) summary.push(`Types: ${buyBox.property_types.join(', ')}`);
        div.innerHTML = `
          <div class="label">Buy Box Saved</div>
          <div style="font-size:0.85rem;color:var(--cream-dim);line-height:1.7;">${summary.join('<br>')}</div>
          <a href="/scan/?id=${searchId}" class="cta">Run First Scan →</a>
        `;
        msgs.appendChild(div);
        document.querySelector('#view-chat .input-bar').style.display = 'none';
        scrollChatToBottom();
        // Reload sidebar after short delay
        setTimeout(loadUserData, 1500);
      }

      // ── DEAL VIEW ─────────────────────────────────────────────────────────
      function openDeal(idx) {
        const deal = state.recentDeals[idx];
        if (!deal) return;
        state.activeDeal = deal;
        state.dealChatHistory = [];
        state.dealConversationId = null;
        state.dealChatStreaming = false;
        document.getElementById('deal-header-title').textContent = deal.title || 'Deal Detail';
        renderDealView(deal);
        showView('deal');
        document.getElementById('sidebar').classList.remove('mobile-open');
      }

      function renderDealView(deal) {
        const bd = parseBreakdown(deal.score_breakdown);
        const risk = bd.risk || {};
        const strategy = bd.strategy || {};
        const tier = tierFromStrategy(strategy.overall);
        const tierLabel = { hot: 'HOT', strong: 'STRONG', watch: 'WATCH' }[tier];
        const riskCls = riskClass(risk.level);

        const price = deal.price ? '$' + Number(deal.price).toLocaleString() : '—';
        const acreage = deal.acreage ? deal.acreage + ' ac' : '—';
        const keys = deal.rooms_keys ? deal.rooms_keys + ' keys' : '—';

        let barsHtml = '';
        if (strategy.market_match !== undefined || strategy.revenue_match !== undefined) {
          const bars = [
            { label: 'Market', val: strategy.market_match },
            { label: 'Revenue', val: strategy.revenue_match },
            { label: 'Fit', val: strategy.property_fit }
          ].filter(b => b.val !== undefined && b.val !== null);
          if (bars.length) {
            barsHtml = `<div class="deal-score-bars">${bars.map(b => `
              <div class="score-bar-item">
                <span class="sbi-label">${b.label}</span>
                <div class="sbi-track"><div class="sbi-fill" style="width:${Math.min(100,(b.val/30)*100)}%"></div></div>
              </div>`).join('')}</div>`;
          }
        }

        const body = document.getElementById('deal-detail-body');
        body.innerHTML = `
          <div class="deal-full-card ${tier}">
            <div style="display:flex;align-items:flex-start;justify-content:space-between;margin-bottom:12px;">
              <div>
                <div style="font-size:0.72rem;font-weight:500;letter-spacing:0.1em;text-transform:uppercase;color:var(--cream-sub);margin-bottom:6px;">${escHtml(deal.source || '')}</div>
                <div style="font-family:var(--serif);font-size:1.6rem;font-weight:500;line-height:1.2;color:var(--cream);">${escHtml(deal.title || 'Unnamed Property')}</div>
                <div style="font-size:0.88rem;color:var(--cream-dim);margin-top:4px;">${escHtml(deal.location || '')}</div>
              </div>
              <span class="tier-badge tier-${tier}" style="flex-shrink:0;margin-left:12px;">${tierLabel}</span>
            </div>
            <div class="deal-meta-grid">
              <div class="deal-meta-cell"><div class="dmc-label">Price</div><div class="dmc-value">${price}</div></div>
              <div class="deal-meta-cell"><div class="dmc-label">Acreage</div><div class="dmc-value">${acreage}</div></div>
              <div class="deal-meta-cell"><div class="dmc-label">Keys</div><div class="dmc-value">${keys}</div></div>
            </div>
            <div style="display:flex;align-items:center;gap:8px;margin-bottom:12px;">
              ${risk.level ? `<span class="risk-pill ${riskCls}">${risk.level} Risk</span>` : ''}
              ${strategy.overall ? `<span style="font-size:0.78rem;color:var(--cream-sub);">${strategyLabel(strategy.overall)}</span>` : ''}
            </div>
            ${barsHtml}
            <div class="deal-actions-row">
              <a href="${deal.url || '#'}" target="_blank" rel="noopener" class="btn-view-listing">View Listing →</a>
              ${state.lastScan ? `<a href="/results/?id=${deal.search_id}" class="btn-view-results">All Results →</a>` : ''}
            </div>
          </div>

          <div class="deal-qa-section">
            <div class="deal-qa-header">Ask AI about this deal</div>
            <div class="deal-qa-messages" id="deal-qa-messages">
              <div style="font-size:0.82rem;color:var(--cream-sub);text-align:center;padding:16px 0;">Ask anything about this deal — scoring rationale, risks, due diligence steps.</div>
            </div>
            <div class="deal-qa-input">
              <input type="text" id="deal-qa-input" placeholder="Why is this rated HOT?" autocomplete="off" />
              <button class="btn-qa-send" id="deal-qa-send" onclick="sendDealMessage()">Ask</button>
            </div>
          </div>`;

        document.getElementById('deal-qa-input').addEventListener('keydown', function(e) {
          if (e.key === 'Enter') { e.preventDefault(); sendDealMessage(); }
        });
      }

      async function sendDealMessage() {
        if (state.dealChatStreaming) return;
        const input = document.getElementById('deal-qa-input');
        const text = input.value.trim();
        if (!text) return;
        input.value = '';

        addDealMessage('user', text);
        state.dealChatHistory.push({ role: 'user', content: text });
        state.dealChatStreaming = true;
        document.getElementById('deal-qa-send').disabled = true;

        // Find the buy box for context (use most recent one)
        const buyBox = state.buyBoxes.length
          ? (typeof state.buyBoxes[0].buy_box === 'string'
              ? JSON.parse(state.buyBoxes[0].buy_box)
              : state.buyBoxes[0].buy_box)
          : null;

        try {
          const res = await fetch('/api/deal-chat', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
              email: state.email,
              deal: state.activeDeal,
              buy_box: buyBox,
              messages: state.dealChatHistory,
              conversation_id: state.dealConversationId
            })
          });
          await handleDealStream(res);
        } catch (err) {
          addDealMessage('assistant', 'Connection lost. Try again.');
        }

        state.dealChatStreaming = false;
        document.getElementById('deal-qa-send').disabled = false;
        input.focus();
      }

      async function handleDealStream(response) {
        const reader = response.body.getReader();
        const decoder = new TextDecoder();
        let assistantText = '';
        let msgEl = null;
        let buffer = '';

        while (true) {
          const { done, value } = await reader.read();
          if (done) break;
          buffer += decoder.decode(value, { stream: true });
          const lines = buffer.split('\n');
          buffer = lines.pop();
          for (const line of lines) {
            if (!line.startsWith('data: ')) continue;
            const json = line.slice(6);
            if (!json) continue;
            try {
              const event = JSON.parse(json);
              if (event.type === 'text') {
                if (!msgEl) msgEl = addDealMessage('assistant', '');
                assistantText += event.text;
                msgEl.querySelector('.msg-body').textContent = assistantText;
                scrollDealChat();
              } else if (event.type === 'conversation_id') {
                state.dealConversationId = event.id;
              }
            } catch (e) { /* skip */ }
          }
        }
        if (assistantText) state.dealChatHistory.push({ role: 'assistant', content: assistantText });
      }

      function addDealMessage(role, text) {
        const msgs = document.getElementById('deal-qa-messages');
        if (!msgs) return null;
        const div = document.createElement('div');
        div.className = `msg msg-${role}`;
        if (role === 'assistant') {
          div.innerHTML = `<div class="msg-label"><span class="dot"></span> Deal Hound</div><div class="msg-body">${escHtml(text)}</div>`;
        } else {
          div.textContent = text;
        }
        msgs.appendChild(div);
        scrollDealChat();
        return div;
      }

      function scrollDealChat() {
        const msgs = document.getElementById('deal-qa-messages');
        if (msgs) msgs.scrollTop = msgs.scrollHeight;
      }

      // ── SETTINGS ──────────────────────────────────────────────────────────
      function openSettings() {
        state.settingsOpen = true;
        document.getElementById('settings-panel').classList.add('open');
      }
      function closeSettings() {
        state.settingsOpen = false;
        document.getElementById('settings-panel').classList.remove('open');
      }
      function saveNotifPrefs() {
        const on = document.getElementById('notif-digest').checked;
        localStorage.setItem('dh_notif_digest', on ? 'true' : 'false');
      }
      function handleUpgrade() {
        // Stripe portal — not yet wired; show intent
        alert('Upgrade coming soon! Email support@dealhound.pro to get early access to Pro.');
      }
      function signOut() {
        localStorage.removeItem('dh_email');
        window.location.href = '/dashboard/';
      }

      // ── MOBILE SIDEBAR ────────────────────────────────────────────────────
      function toggleMobileSidebar() {
        document.getElementById('sidebar').classList.toggle('mobile-open');
      }

      // ── HELPERS ───────────────────────────────────────────────────────────
      function parseBreakdown(raw) {
        if (!raw) return {};
        try { return typeof raw === 'string' ? JSON.parse(raw) : raw; }
        catch { return {}; }
      }
      // Tier mapping — intentional:
      // score_breakdown.strategy.overall values are: "STRONG MATCH", "MATCH", "PARTIAL", "MISS"
      // "STRONG MATCH" → HOT (green badge)
      // "MATCH"        → STRONG (gold badge)
      // "PARTIAL" and "MISS" both → WATCH (amber badge)
      // Only deals with passed_hard_filters=true reach the sidebar, so MISS is rare here.
      function tierFromStrategy(overall) {
        switch ((overall || '').toUpperCase()) {
          case 'STRONG MATCH': return 'hot';
          case 'MATCH': return 'strong';
          default: return 'watch';
        }
      }
      function riskClass(level) {
        if (!level) return 'risk-moderate';
        switch (level.toUpperCase()) {
          case 'LOW': return 'risk-low';
          case 'MODERATE': return 'risk-moderate';
          case 'HIGH': return 'risk-high';
          case 'VERY HIGH': return 'risk-very-high';
          default: return 'risk-moderate';
        }
      }
      function strategyLabel(overall) {
        const map = { 'STRONG MATCH': 'Strong Match', 'MATCH': 'Strategy Match', 'PARTIAL': 'Partial Match', 'MISS': 'Strategy Miss' };
        return map[overall] || overall || '';
      }
      function fmtPrice(n) {
        if (n >= 1000000) return (n / 1000000).toFixed(1) + 'M';
        if (n >= 1000) return Math.round(n / 1000) + 'k';
        return String(n);
      }
      function escHtml(str) {
        const d = document.createElement('div');
        d.textContent = str;
        return d.innerHTML;
      }
    </script>
  </body>
  </html>
  ```

- [ ] **Step 3: Verify the file was created**

  ```bash
  ls dashboard/index.html
  ```
  Expected: file exists.

- [ ] **Step 4: Open the page in a browser and verify structure (no JS yet)**

  Open `http://localhost:3001/dashboard/` in a browser.
  Expected:
  - Email gate shows (cream background, serif heading, email input)
  - No console errors on load
  - Page matches overall Deal Hound aesthetic (same fonts, colors)

- [ ] **Step 5: Commit**

  ```bash
  git add dashboard/index.html
  git commit -m "feat: add dashboard page — layout, sidebar, all three views, settings panel"
  ```

---

## Task 6: Integration Test — Full User Flow

Test the end-to-end flow manually using `npx vercel dev`.

- [ ] **Step 1: Start the dev server (if not running)**

  ```bash
  cd /Users/gideonspencer/dealhound-pro
  npx vercel dev
  ```
  Note the port (default 3000).

- [ ] **Step 2: Test email gate**

  Open `http://localhost:3000/dashboard/`.
  Expected: email gate visible. Enter `test@example.com` → gate disappears, sidebar + main content appear.

- [ ] **Step 3: Test sidebar loads user data**

  Sidebar should show "Loading..." then:
  - If the Supabase env vars are set and the email has records: real buy boxes and deals appear
  - If no records: shows "No buy boxes yet" and "No deals yet — run a scan"

  No JS errors in console. Network tab should show a `200 GET /api/user-data?email=...`.

- [ ] **Step 4: Test settings panel**

  Click the gear icon (⚙) at sidebar bottom.
  Expected: Settings panel slides in over the sidebar.
  - "Help" section shows two links
  - "Billing" section shows plan + upgrade button
  - "Notifications" section shows the daily digest toggle
  - Click × → panel slides out

- [ ] **Step 5: Test "New Scan" → chat view**

  Click "New Scan" button in sidebar.
  Expected:
  - Main content switches to chat view
  - Deal Hound typing indicator appears
  - Claude streams its intro message (requires `ANTHROPIC_API_KEY` env var set)
  - User can type responses and receive streaming replies

- [ ] **Step 5b: Test `/api/deal-chat` streaming directly (no DB required)**

  This test bypasses the UI to verify the streaming endpoint works with the Anthropic key.

  ```bash
  curl -s -N -X POST http://localhost:3000/api/deal-chat \
    -H "Content-Type: application/json" \
    -d '{
      "email": "test@example.com",
      "deal": {
        "id": "test-id",
        "title": "Hilltop Glamping Resort",
        "location": "Hill Country, TX",
        "price": 1200000,
        "acreage": 14,
        "rooms_keys": 8,
        "source": "LandSearch",
        "url": "https://example.com",
        "score_breakdown": { "strategy": { "overall": "STRONG MATCH", "market_match": 25, "revenue_match": 22 }, "risk": { "level": "MODERATE" } }
      },
      "buy_box": { "locations": ["Texas"], "price_max": 2000000, "property_types": ["micro_resort"] },
      "messages": [{ "role": "user", "content": "Why is this deal rated HOT?" }],
      "conversation_id": null
    }' | head -20
  ```

  Expected: A stream of `data: {"type":"text","text":"..."}` lines followed by `data: {"type":"done"}`. No HTTP 5xx.

- [ ] **Step 6: Test deal drill-down**

  If there are deals in the sidebar (need real Supabase data with `passed_hard_filters=true`), click one.
  Expected:
  - Main content switches to deal view
  - Deal card shows title, location, price, acreage, keys, tier badge, risk pill
  - Score bars render if breakdown data is present
  - "Ask AI about this deal" section shows at bottom
  - Type a question → response streams correctly (verified independently in Step 5b above)

- [ ] **Step 7: Test sign out**

  Open settings → click "Sign out".
  Expected: page reloads, email gate visible again. localStorage `dh_email` is cleared.

- [ ] **Step 8: Test mobile layout**

  In Chrome DevTools, enable mobile emulation (375px width).
  Expected:
  - Mobile topbar with hamburger visible
  - Sidebar hidden by default
  - Tap hamburger → sidebar slides in
  - Tap a deal → sidebar closes, deal view shows

- [ ] **Step 9: Commit test pass**

  ```bash
  git add -p  # only if any fixes were needed
  git commit -m "fix: integration test fixes for dashboard UX"
  # If no changes needed:
  git commit --allow-empty -m "test: dashboard integration flow verified"
  ```

---

## Task 7: Deploy to Staging (Vercel Preview)

- [ ] **Step 1: Push the branch to GitHub**

  ```bash
  git push -u origin feature/dashboard-ux
  ```

- [ ] **Step 2: Confirm Vercel preview URL**

  Vercel will automatically build a preview deployment for this branch. Check the Vercel dashboard or wait for the GitHub status check to get the URL.

  Format: `https://dealhound-pro-git-feature-dashboard-ux-[team].vercel.app`

  Or use:
  ```bash
  npx vercel ls --environment preview 2>/dev/null | head -5
  ```

- [ ] **Step 3: Verify `/dashboard/` is accessible at the preview URL**

  Open `https://[preview-url]/dashboard/` in a browser.
  Expected: Same behavior as local dev. Email gate visible. Env vars are inherited from Vercel project settings.

- [ ] **Step 4: Smoke test the new API endpoints at the preview URL**

  ```bash
  PREVIEW_URL="https://[your-preview-url]"
  curl -s "$PREVIEW_URL/api/user-data?email=test@test.com" | python3 -m json.tool
  ```
  Expected: `{"buy_boxes":[],"recent_deals":[],"last_scan":null}`

---

## Summary: What Gets Built

| Feature | Where | How to Test |
|---------|-------|-------------|
| Email gate → dashboard | `/dashboard/` | Enter email, app loads |
| Sidebar: buy boxes list | `#buy-boxes-list` | Shows user's scans from Supabase |
| Sidebar: highlighted deals | `#deals-list` | Shows top 5 deals from last scan |
| Settings panel | `#settings-panel` | Click gear icon |
| Help links | Settings → Help | Links to support email + docs |
| Billing section | Settings → Billing | Shows plan, upgrade CTA |
| Notification toggle | Settings → Notifications | Persisted to localStorage |
| Sign out | Settings bottom | Clears email, returns to gate |
| New Scan chat | `#view-chat` | Click New Scan → Claude responds |
| Deal drill-down | `#view-deal` | Click deal in sidebar |
| Deal Q&A chat | Deal view → Q&A section | Type question, Claude answers |
| Mobile sidebar | `#sidebar.mobile-open` | Hamburger button on ≤768px |

## Limitations (Intentional for MVP)

1. **Notification preferences stored in localStorage**, not Supabase. Actual email send logic is a separate feature (daily digest pipeline).
2. **Billing upgrade shows an alert**, not a real Stripe checkout. Stripe paywall is a separate feature per the product spec.
3. **Buy box labels auto-generated** from first location or property type. No custom naming yet.
4. **Session is email-only** (no password/JWT). Magic link auth is a future feature per the spec — this plan keeps that boundary.
