# Dashboard UX Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a three-panel Preact dashboard at `/dashboard/` with sidebar navigation, conversational chat (SSE streaming), and a contextual preview panel — delivering the "agent debrief" experience where a named AI analyst presents deals and the user works them through conversation.

**Architecture:** Preact SPA (built with Vite) at `dashboard/`, four new Vercel serverless API endpoints, one modified endpoint. Three-panel layout: sidebar (220px) for navigation, chat (flex) for conversation, preview (300px, collapsible) for deal context. State managed via Preact signals. Conversations cached in-memory with LRU eviction.

**Tech Stack:** Preact + Vite + @preact/preset-vite, Vercel serverless functions (Node.js/CommonJS), Supabase PostgreSQL, Anthropic Claude API (SSE streaming), CSS custom properties (existing design system).

**Spec:** `docs/superpowers/specs/2026-04-22-dashboard-ux-design.md`

---

## File Map

| Action | Path | Responsibility |
|--------|------|----------------|
| Create | `vite.config.js` | Vite config with Preact preset + API proxy |
| Create | `dashboard/index.html` | SPA entry point — loads Preact bundle |
| Create | `dashboard/src/main.jsx` | Preact render entry point |
| Create | `dashboard/src/app.jsx` | Root component — email gate + three-panel layout |
| Create | `dashboard/src/lib/state.js` | Preact signals state + conversation cache |
| Create | `dashboard/src/lib/api.js` | API client — fetch wrappers + SSE streaming |
| Create | `dashboard/src/lib/utils.js` | Shared helpers — price formatting, tier mapping, escapeHtml |
| Create | `dashboard/src/components/Sidebar.jsx` | Sidebar panel — logo, new scan, deal list, scan list, footer |
| Create | `dashboard/src/components/Chat.jsx` | Chat panel — messages, streaming, input bar |
| Create | `dashboard/src/components/Preview.jsx` | Preview panel — deal list (scan) or deal detail (thread) |
| Create | `dashboard/src/components/DealCard.jsx` | Reusable deal card — used in chat + preview |
| Create | `dashboard/src/components/Settings.jsx` | Settings overlay — help, billing, notifications, sign out |
| Create | `dashboard/src/styles.css` | Full CSS — design system tokens + all component styles |
| Create | `api/user-data.js` | GET — sidebar data + agent name |
| Create | `api/deal-chat.js` | POST — deal thread SSE streaming |
| Create | `api/conversation.js` | GET — load conversation messages |
| Create | `api/star-deal.js` | POST — toggle deal star |
| Modify | `api/chat.js:80-206` | Add `mode` + `agent_name` params for scan_debrief |
| Modify | `vercel.json` | Add function configs + SPA rewrite |
| Modify | `package.json` | Add preact, vite, @preact/preset-vite |

---

## Task 1: Create Branch + Install Dependencies

**Files:**
- Modify: `package.json`
- Create: `vite.config.js`
- Modify: `vercel.json`

- [ ] **Step 1: Create the feature branch**

```bash
cd /Users/gideonspencer/dealhound-pro
git checkout -b feature/dashboard-ux
```

- [ ] **Step 2: Install Preact + Vite**

```bash
npm install preact
npm install --save-dev vite @preact/preset-vite
```

- [ ] **Step 3: Create `vite.config.js`**

```javascript
import { defineConfig } from 'vite';
import preact from '@preact/preset-vite';

export default defineConfig({
  plugins: [preact()],
  root: 'dashboard',
  build: {
    outDir: '../dashboard-dist',
    emptyOutDir: true
  },
  server: {
    port: 5173,
    proxy: {
      '/api': 'http://localhost:3000'
    }
  }
});
```

- [ ] **Step 4: Add build script to `package.json`**

Add to `package.json`:
```json
{
  "scripts": {
    "build": "vite build"
  }
}
```

Vercel auto-detects and runs `npm run build` during deployment. Vite outputs the SPA to `dashboard-dist/`.

- [ ] **Step 5: Update `vercel.json`**

Add function configs for new endpoints, SPA rewrite, and build output directory:

```json
{
  "buildCommand": "npm run build",
  "outputDirectory": ".",
  "functions": {
    "api/chat.js": { "maxDuration": 60 },
    "api/scan-start.js": { "maxDuration": 10 },
    "api/scan-progress.js": { "maxDuration": 10 },
    "api/user-data.js": { "maxDuration": 10 },
    "api/deal-chat.js": { "maxDuration": 60 },
    "api/conversation.js": { "maxDuration": 10 },
    "api/star-deal.js": { "maxDuration": 10 }
  },
  "rewrites": [
    { "source": "/dashboard", "destination": "/dashboard-dist/index.html" },
    { "source": "/dashboard/(.*)", "destination": "/dashboard-dist/index.html" }
  ]
}
```

`buildCommand` tells Vercel to run `vite build`. `outputDirectory: "."` tells Vercel the project root contains both static files AND the build output. The rewrites map `/dashboard` and `/dashboard/*` to the SPA entry point in `dashboard-dist/`.

- [ ] **Step 6: Add `.superpowers/` to `.gitignore`**

Append to `.gitignore`:
```
.superpowers/
dashboard-dist/
```

- [ ] **Step 7: Verify Vite starts**

```bash
mkdir -p dashboard/src
echo '<html><body><div id="app">Vite works</div><script type="module" src="/src/main.jsx"></script></body></html>' > dashboard/index.html
echo 'document.getElementById("app").textContent = "Preact works"' > dashboard/src/main.jsx
npx vite --open
```
Expected: Browser opens at `localhost:5173` showing "Preact works".

- [ ] **Step 8: Commit**

```bash
git add package.json package-lock.json vite.config.js vercel.json .gitignore dashboard/
git commit -m "chore: add Preact + Vite build pipeline for dashboard"
```

---

## Task 2: Database Migrations

**Files:**
- No files — Supabase SQL executed via MCP or dashboard

These migrations create the `users` and `user_deal_stars` tables, and add `search_id` to `conversations`.

- [ ] **Step 1: Create `users` table**

```sql
CREATE TABLE IF NOT EXISTS users (
  email TEXT PRIMARY KEY,
  agent_name TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

- [ ] **Step 2: Create `user_deal_stars` table**

```sql
CREATE TABLE IF NOT EXISTS user_deal_stars (
  user_email TEXT REFERENCES users(email) ON DELETE CASCADE,
  deal_id UUID REFERENCES deals(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (user_email, deal_id)
);
```

- [ ] **Step 3: Add `search_id` column to `conversations`**

```sql
ALTER TABLE conversations
ADD COLUMN IF NOT EXISTS search_id UUID;
```

- [ ] **Step 4: Verify tables exist**

```sql
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'public'
AND table_name IN ('users', 'user_deal_stars');
```
Expected: Both rows returned.

- [ ] **Step 5: Commit (empty — DB changes are external)**

```bash
git commit --allow-empty -m "chore: database migrations — users, user_deal_stars, conversations.search_id"
```

---

## Task 3: API — `/api/user-data.js`

**Files:**
- Create: `api/user-data.js`

- [ ] **Step 1: Create the endpoint**

```javascript
const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_KEY
);

const AGENT_NAMES = [
  'Scout', 'Nora', 'Kit', 'Stella', 'Sophie', 'Quinn',
  'Wren', 'Ellis', 'Reid', 'Sloane', 'Harper', 'Hunter'
];

async function getOrCreateUser(email) {
  const { data: existing } = await supabase
    .from('users')
    .select('email, agent_name')
    .eq('email', email)
    .single();

  if (existing) return existing;

  const agentName = AGENT_NAMES[Math.floor(Math.random() * AGENT_NAMES.length)];
  const { data: created, error } = await supabase
    .from('users')
    .insert({ email, agent_name: agentName })
    .select('email, agent_name')
    .single();

  if (error) throw error;
  return created;
}

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
    const user = await getOrCreateUser(email);

    // Scans with deal counts
    const { data: scans } = await supabase
      .from('deal_searches')
      .select('id, buy_box, status, run_at, created_at')
      .eq('user_email', email)
      .order('created_at', { ascending: false })
      .limit(20);

    // Get conversation_ids for scan debriefs
    const scanIds = (scans || []).map(s => s.id);
    let scanConvos = [];
    if (scanIds.length > 0) {
      const { data } = await supabase
        .from('conversations')
        .select('id, search_id')
        .eq('conversation_type', 'scan_debrief')
        .eq('user_email', email)
        .in('search_id', scanIds);
      scanConvos = data || [];
    }
    const scanConvoMap = {};
    scanConvos.forEach(c => { scanConvoMap[c.search_id] = c.id; });

    // Deals from all scans (passed hard filters only)
    let deals = [];
    if (scanIds.length > 0) {
      const { data } = await supabase
        .from('deals')
        .select('id, title, location, price, acreage, rooms_keys, score_breakdown, source, url, search_id, passed_hard_filters')
        .in('search_id', scanIds)
        .eq('passed_hard_filters', true)
        .order('id', { ascending: false })
        .limit(50);
      deals = data || [];
    }

    // Star status
    const dealIds = deals.map(d => d.id);
    let starredIds = new Set();
    if (dealIds.length > 0) {
      const { data: stars } = await supabase
        .from('user_deal_stars')
        .select('deal_id')
        .eq('user_email', email)
        .in('deal_id', dealIds);
      starredIds = new Set((stars || []).map(s => s.deal_id));
    }

    // Active deal threads
    const { data: threadConvos } = await supabase
      .from('conversations')
      .select('id, deal_id')
      .eq('conversation_type', 'deal_qa')
      .eq('user_email', email)
      .not('deal_id', 'is', null);

    // Deal counts per scan
    const dealCountMap = {};
    deals.forEach(d => {
      dealCountMap[d.search_id] = (dealCountMap[d.search_id] || 0) + 1;
    });

    return res.status(200).json({
      agent_name: user.agent_name,
      scans: (scans || []).map(s => ({
        id: s.id,
        buy_box: s.buy_box,
        status: s.status,
        run_at: s.run_at,
        deal_count: dealCountMap[s.id] || 0,
        conversation_id: scanConvoMap[s.id] || null
      })),
      deals: deals.map(d => ({
        id: d.id,
        title: d.title,
        location: d.location,
        price: d.price,
        acreage: d.acreage,
        rooms_keys: d.rooms_keys,
        score_breakdown: d.score_breakdown,
        source: d.source,
        url: d.url,
        search_id: d.search_id,
        starred: starredIds.has(d.id)
      })),
      active_threads: (threadConvos || []).map(c => ({
        deal_id: c.deal_id,
        conversation_id: c.id
      }))
    });

  } catch (err) {
    console.error('user-data error:', err.message);
    return res.status(500).json({ error: 'Failed to fetch user data' });
  }
};
```

- [ ] **Step 2: Test with curl (missing email)**

```bash
curl -s http://localhost:3000/api/user-data | python3 -m json.tool
```
Expected: `{"error": "Missing email"}`

- [ ] **Step 3: Test with curl (valid email)**

```bash
curl -s "http://localhost:3000/api/user-data?email=test@example.com" | python3 -m json.tool
```
Expected: JSON with `agent_name` (one of the 12 names), `scans: []`, `deals: []`, `active_threads: []`.

- [ ] **Step 4: Test idempotency (same email returns same agent name)**

```bash
curl -s "http://localhost:3000/api/user-data?email=test@example.com" | python3 -c "import sys,json; print(json.load(sys.stdin)['agent_name'])"
curl -s "http://localhost:3000/api/user-data?email=test@example.com" | python3 -c "import sys,json; print(json.load(sys.stdin)['agent_name'])"
```
Expected: Same name printed both times.

- [ ] **Step 5: Commit**

```bash
git add api/user-data.js
git commit -m "feat: add /api/user-data endpoint — sidebar data + agent name assignment"
```

---

## Task 4: API — `/api/conversation.js`

**Files:**
- Create: `api/conversation.js`

- [ ] **Step 1: Create the endpoint**

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

  const { id, email } = req.query;
  if (!id || !email) {
    return res.status(400).json({ error: 'Missing id or email' });
  }

  try {
    const { data, error } = await supabase
      .from('conversations')
      .select('id, conversation_type, messages, deal_id, search_id')
      .eq('id', id)
      .eq('user_email', email)
      .single();

    if (error || !data) {
      return res.status(404).json({ error: 'Conversation not found' });
    }

    return res.status(200).json(data);

  } catch (err) {
    console.error('conversation error:', err.message);
    return res.status(500).json({ error: 'Failed to fetch conversation' });
  }
};
```

- [ ] **Step 2: Test (missing params)**

```bash
curl -s http://localhost:3000/api/conversation | python3 -m json.tool
```
Expected: `{"error": "Missing id or email"}`

- [ ] **Step 3: Test (nonexistent conversation)**

```bash
curl -s "http://localhost:3000/api/conversation?id=00000000-0000-0000-0000-000000000000&email=test@example.com" | python3 -m json.tool
```
Expected: `{"error": "Conversation not found"}`

- [ ] **Step 4: Commit**

```bash
git add api/conversation.js
git commit -m "feat: add /api/conversation endpoint — load conversation history"
```

---

## Task 5: API — `/api/star-deal.js`

**Files:**
- Create: `api/star-deal.js`

- [ ] **Step 1: Create the endpoint**

```javascript
const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_KEY
);

module.exports = async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');

  if (req.method === 'OPTIONS') {
    res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
    return res.status(200).end();
  }

  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const { email, deal_id, starred } = req.body;

  if (!email || !deal_id || typeof starred !== 'boolean') {
    return res.status(400).json({ error: 'Missing email, deal_id, or starred (boolean)' });
  }

  try {
    if (starred) {
      const { error } = await supabase
        .from('user_deal_stars')
        .upsert({ user_email: email, deal_id }, { onConflict: 'user_email,deal_id' });
      if (error) throw error;
    } else {
      const { error } = await supabase
        .from('user_deal_stars')
        .delete()
        .eq('user_email', email)
        .eq('deal_id', deal_id);
      if (error) throw error;
    }

    return res.status(200).json({ ok: true });

  } catch (err) {
    console.error('star-deal error:', err.message);
    return res.status(500).json({ error: 'Failed to update star' });
  }
};
```

- [ ] **Step 2: Commit**

```bash
git add api/star-deal.js
git commit -m "feat: add /api/star-deal endpoint — toggle deal star"
```

---

## Task 6: API — `/api/deal-chat.js`

**Files:**
- Create: `api/deal-chat.js`

- [ ] **Step 1: Create the endpoint**

```javascript
const Anthropic = require('@anthropic-ai/sdk');
const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_KEY
);

function buildDealPrompt(deal, buyBox, agentName) {
  const bb = buyBox ? JSON.stringify(buyBox, null, 2) : 'Not provided';
  const bd = deal.score_breakdown
    ? (typeof deal.score_breakdown === 'string' ? deal.score_breakdown : JSON.stringify(deal.score_breakdown, null, 2))
    : 'Not available';

  return `You are ${agentName}, an AI deal hunting agent. You're helping an investor evaluate a specific hospitality deal.

Your personality: Direct, knowledgeable, confident. You sound like a sharp deal analyst, not a chatbot. Keep responses concise — 2-4 sentences unless more detail is explicitly requested.

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

Rules:
- Stay focused on this deal and this investor's criteria
- Reference specific numbers when answering
- If asked something you don't have data for, say so clearly
- No filler. No encouragement. Be a sharp analyst.
- When the user shares new information (broker call notes, financials), acknowledge and analyze it immediately`;
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

  const { email, deal, buy_box, messages, conversation_id, agent_name } = req.body;

  if (!email || !deal || !messages || !Array.isArray(messages)) {
    return res.status(400).json({ error: 'Missing required fields' });
  }

  try {
    const client = new Anthropic();

    res.setHeader('Content-Type', 'text/event-stream');
    res.setHeader('Cache-Control', 'no-cache');
    res.setHeader('Connection', 'keep-alive');

    const stream = await client.messages.stream({
      model: 'claude-sonnet-4-20250514',
      max_tokens: 1024,
      system: buildDealPrompt(deal, buy_box, agent_name || 'Scout'),
      messages: messages.map(m => ({ role: m.role, content: m.content }))
    });

    let fullText = '';

    for await (const event of stream) {
      if (event.type === 'content_block_delta' && event.delta.type === 'text_delta') {
        fullText += event.delta.text;
        res.write(`data: ${JSON.stringify({ type: 'text', text: event.delta.text })}\n\n`);
      }
    }

    // Save conversation
    const allMsgs = [...messages, { role: 'assistant', content: fullText, timestamp: new Date().toISOString() }];

    if (conversation_id) {
      await supabase
        .from('conversations')
        .update({ messages: allMsgs, updated_at: new Date().toISOString() })
        .eq('id', conversation_id);
    } else {
      const { data: convo } = await supabase
        .from('conversations')
        .insert({
          user_email: email,
          conversation_type: 'deal_qa',
          messages: allMsgs,
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

- [ ] **Step 2: Test streaming with curl**

```bash
curl -s -N -X POST http://localhost:3000/api/deal-chat \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","deal":{"id":"test","title":"Cedar Ridge Glamping","location":"Hill Country, TX","price":1200000,"acreage":14,"rooms_keys":8,"source":"LandSearch","score_breakdown":{"strategy":{"overall":"STRONG MATCH"},"risk":{"level":"MODERATE"}}},"buy_box":{"locations":["Texas"],"price_max":2000000,"property_types":["micro_resort"],"revenue_requirement":"cash_flow_day_1"},"messages":[{"role":"user","content":"Break down why this is a strong match."}],"conversation_id":null,"agent_name":"Scout"}' | head -20
```
Expected: SSE stream with `data: {"type":"text",...}` lines.

- [ ] **Step 3: Commit**

```bash
git add api/deal-chat.js
git commit -m "feat: add /api/deal-chat endpoint — deal thread SSE streaming"
```

---

## Task 7: API — Extend `/api/chat.js` with scan_debrief mode

**Files:**
- Modify: `api/chat.js:9-33` (system prompt section)
- Modify: `api/chat.js:94` (destructure mode + search_id)
- Modify: `api/chat.js:108-117` (conditional system prompt + tools)
- Modify: `api/chat.js:180-188` (conversation save with search_id)

- [ ] **Step 1: Add scan debrief system prompt builder**

Add this function ABOVE the `module.exports` line (after the `TOOLS` array, around line 78):

```javascript
async function buildDebriefPrompt(searchId, agentName) {
  // Fetch deals for this scan
  const { data: deals } = await supabase
    .from('deals')
    .select('title, location, price, acreage, rooms_keys, score_breakdown, source, url, passed_hard_filters')
    .eq('search_id', searchId)
    .eq('passed_hard_filters', true)
    .order('id', { ascending: false });

  // Fetch the buy box
  const { data: search } = await supabase
    .from('deal_searches')
    .select('buy_box')
    .eq('id', searchId)
    .single();

  const dealSummaries = (deals || []).map((d, i) => {
    const bd = typeof d.score_breakdown === 'string' ? JSON.parse(d.score_breakdown) : (d.score_breakdown || {});
    const tier = bd.strategy?.overall || 'UNKNOWN';
    const risk = bd.risk?.level || 'UNKNOWN';
    return `Deal ${i + 1}: ${d.title || 'Unnamed'}
  Location: ${d.location || '?'} | Price: ${d.price ? '$' + Number(d.price).toLocaleString() : '?'} | Acreage: ${d.acreage || '?'} | Keys: ${d.rooms_keys || '?'}
  Source: ${d.source || '?'} | Tier: ${tier} | Risk: ${risk}
  Listing: ${d.url || 'N/A'}
  Score: ${JSON.stringify(bd)}`;
  }).join('\n\n');

  const buyBox = search?.buy_box ? JSON.stringify(search.buy_box, null, 2) : 'Not available';

  return `You are ${agentName}, an AI deal hunting agent. You just finished scanning marketplaces and are debriefing the investor on what you found.

Your personality: Direct, knowledgeable, confident. You sound like a sharp deal analyst sitting across the table. Keep responses concise.

INVESTOR'S BUY BOX:
${buyBox}

DEALS FOUND (${(deals || []).length} survived the buy box filter):
${dealSummaries || 'No deals survived the filter.'}

Instructions:
- Present the deals with your honest assessment. Lead with the strongest match.
- For each deal, give a one-liner on why it made the cut and what the main risk is.
- End with a clear recommendation: which one to call about first and why.
- If the investor asks to compare deals, be specific — reference numbers, not generalities.
- If they ask to drill into a deal, give detailed analysis using the score breakdown.
- Be brief. No filler. No cheerleading. Sharp opinions backed by data.
${(deals || []).length === 0 ? '\nNo deals matched. Suggest adjusting the buy box — be specific about which criteria are too narrow.' : ''}`;
}
```

- [ ] **Step 2: Update request destructuring**

Change line 94 from:
```javascript
  const { email, messages, conversation_id } = req.body;
```
to:
```javascript
  const { email, messages, conversation_id, mode, search_id, agent_name } = req.body;
```

- [ ] **Step 3: Build system prompt conditionally**

Replace lines 108-117 (the `stream` creation) with:

```javascript
    // Build system prompt based on mode
    const isDebrief = mode === 'scan_debrief';
    let systemPrompt = SYSTEM_PROMPT;
    let tools = TOOLS;

    if (isDebrief) {
      if (!search_id) {
        return res.status(400).json({ error: 'search_id required for scan_debrief mode' });
      }
      systemPrompt = await buildDebriefPrompt(search_id, agent_name || 'Scout');
      tools = undefined; // No tools in debrief mode
    } else if (agent_name) {
      // Inject agent name into onboarding prompt
      systemPrompt = SYSTEM_PROMPT.replace(
        'You are Deal Hound, an AI deal hunting agent',
        `You are ${agent_name}, an AI deal hunting agent`
      );
    }

    const stream = await client.messages.stream({
      model: 'claude-sonnet-4-20250514',
      max_tokens: 1024,
      system: systemPrompt,
      ...(tools ? { tools } : {}),
      messages: messages.map(m => ({
        role: m.role,
        content: m.content
      }))
    });
```

- [ ] **Step 4: Update conversation save to include search_id**

In the `else` branch of conversation saving (around line 180), change the insert to:

```javascript
      const { data: convo } = await supabase
        .from('conversations')
        .insert({
          user_email: email,
          conversation_type: isDebrief ? 'scan_debrief' : 'buy_box_intake',
          messages: [...messages, { role: 'assistant', content: fullText, timestamp: new Date().toISOString() }],
          ...(isDebrief && search_id ? { search_id } : {})
        })
        .select('id')
        .single();
```

- [ ] **Step 5: Verify backward compatibility — existing chat page still works**

Open `http://localhost:3000/chat/` in browser. Enter email, go through onboarding flow.
Expected: Same behavior as before — no regressions. The `mode` param is optional and defaults to buy_box_intake.

- [ ] **Step 6: Commit**

```bash
git add api/chat.js
git commit -m "feat: extend /api/chat with scan_debrief mode + agent name injection"
```

---

## Task 8: Frontend — CSS Design System

**Files:**
- Create: `dashboard/src/styles.css`

- [ ] **Step 1: Create the stylesheet**

Create `dashboard/src/styles.css`. This is the COMPLETE CSS file — every class referenced by the Preact components. No inline styles in components.

```css
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
  --sidebar-w: 220px;
  --preview-w: 300px;
}

html, body { height: 100%; overflow: hidden; }

body {
  background: var(--bg); color: var(--cream);
  font-family: var(--sans); font-weight: 300;
  line-height: 1.6; -webkit-font-smoothing: antialiased;
}

body::before {
  content: ''; position: fixed; inset: 0;
  background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 256 256' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='noise'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.9' numOctaves='4' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23noise)' opacity='0.035'/%3E%3C/svg%3E");
  pointer-events: none; z-index: 999; opacity: 0.4;
}

/* ── EMAIL GATE ──────────────────────────────── */
.email-gate {
  display: flex; flex-direction: column; align-items: center;
  justify-content: center; height: 100vh; padding: 40px 32px;
}
.email-gate h1 {
  font-family: var(--serif); font-size: 2.4rem; font-weight: 400;
  text-align: center; margin-bottom: 12px;
}
.email-gate h1 em { font-style: italic; color: var(--gold); }
.email-gate p {
  font-size: 0.92rem; color: var(--cream-dim);
  text-align: center; max-width: 400px; margin-bottom: 32px;
}
.gate-form { display: flex; gap: 10px; width: 100%; max-width: 420px; }
.gate-form input {
  flex: 1; background: var(--surface); border: 1px solid var(--border);
  color: var(--cream); padding: 14px 18px; border-radius: 4px;
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

/* ── APP SHELL ───────────────────────────────── */
#app-shell {
  display: flex; height: 100vh; overflow: hidden; position: relative;
}

/* ── SIDEBAR ─────────────────────────────────── */
#sidebar {
  width: var(--sidebar-w); flex-shrink: 0;
  background: var(--surface); border-right: 1px solid var(--border);
  display: flex; flex-direction: column; overflow: hidden;
}
.sidebar-logo {
  padding: 20px 16px 16px;
  display: flex; align-items: center; gap: 8px;
  border-bottom: 1px solid var(--border); flex-shrink: 0;
  text-decoration: none; color: var(--cream);
}
.sidebar-logo-icon {
  width: 26px; height: 26px; background: var(--gold);
  border-radius: 5px; display: flex; align-items: center;
  justify-content: center;
}
.sidebar-logo-text { font-family: var(--serif); font-size: 1.1rem; font-weight: 500; }
.sidebar-scroll { flex: 1; overflow-y: auto; padding: 0; }
.sidebar-scroll::-webkit-scrollbar { width: 3px; }
.sidebar-scroll::-webkit-scrollbar-thumb { background: var(--border); border-radius: 2px; }
.sidebar-section-pad { padding: 12px 12px 0; }
.sidebar-new-scan {
  display: flex; align-items: center; gap: 8px; width: 100%;
  padding: 8px 12px; border-radius: 6px;
  background: var(--gold-dim); border: 1px solid rgba(36,61,53,0.15);
  color: var(--gold); font-family: var(--sans);
  font-size: 0.8rem; font-weight: 500; cursor: pointer;
  transition: background 0.15s; letter-spacing: 0.03em;
}
.sidebar-new-scan:hover { background: rgba(36,61,53,0.15); }
.sidebar-section-hdr {
  padding: 12px 16px 4px; font-size: 0.64rem; font-weight: 600;
  letter-spacing: 0.12em; text-transform: uppercase; color: var(--cream-sub);
}
.sidebar-empty {
  padding: 4px 16px 8px; font-size: 0.78rem;
  color: var(--cream-sub); font-style: italic;
}
.sidebar-divider { height: 1px; background: var(--border); margin: 8px 0; }

/* Sidebar deal row */
.sidebar-deal-row {
  padding: 8px 16px; cursor: pointer;
  transition: background 0.12s; border-left: 2px solid transparent;
}
.sidebar-deal-row:hover { background: var(--surface2); }
.sidebar-deal-row.active { background: var(--gold-glow); border-left-color: var(--green); }
.sidebar-deal-name {
  display: flex; align-items: center; justify-content: space-between;
  font-size: 0.82rem; font-weight: 400; color: var(--cream);
}
.sidebar-tier {
  font-size: 0.58rem; font-weight: 600; letter-spacing: 0.1em;
  padding: 1px 5px; border-radius: 100px;
}
.sidebar-deal-meta { font-size: 0.72rem; color: var(--cream-sub); margin-top: 2px; }

/* Sidebar scan row */
.sidebar-scan-row {
  padding: 8px 16px; cursor: pointer;
  transition: background 0.12s; border-left: 2px solid transparent;
}
.sidebar-scan-row:hover { background: var(--surface2); }
.sidebar-scan-row.active { background: var(--gold-glow); border-left-color: var(--gold); }
.sidebar-scan-name { font-size: 0.82rem; color: var(--cream); }
.sidebar-scan-meta { font-size: 0.72rem; color: var(--cream-sub); }

/* Sidebar footer */
.sidebar-footer {
  flex-shrink: 0; padding: 12px 16px;
  border-top: 1px solid var(--border);
  display: flex; align-items: center; gap: 10px;
}
.sidebar-settings-btn {
  width: 32px; height: 32px; border-radius: 6px;
  border: 1px solid var(--border); background: transparent;
  cursor: pointer; color: var(--cream-dim); flex-shrink: 0;
  display: flex; align-items: center; justify-content: center;
  transition: background 0.15s, border-color 0.15s;
}
.sidebar-settings-btn:hover { background: var(--surface2); border-color: var(--gold); color: var(--gold); }
.sidebar-email {
  font-size: 0.72rem; color: var(--cream-sub);
  white-space: nowrap; overflow: hidden; text-overflow: ellipsis; flex: 1;
}

/* ── CHAT PANEL ──────────────────────────────── */
#chat-panel {
  flex: 1; min-width: 0;
  display: flex; flex-direction: column; overflow: hidden;
}
.chat-messages { flex: 1; overflow-y: auto; padding: 24px 32px 16px; }
.chat-messages::-webkit-scrollbar { width: 4px; }
.chat-messages::-webkit-scrollbar-thumb { background: var(--border); border-radius: 4px; }
.chat-messages-inner { max-width: 640px; width: 100%; margin: 0 auto; display: flex; flex-direction: column; gap: 18px; }

.msg { line-height: 1.65; font-size: 0.9rem; animation: fadeIn 0.2s ease; }
@keyframes fadeIn {
  from { opacity: 0; transform: translateY(6px); }
  to { opacity: 1; transform: translateY(0); }
}
.msg-assistant { align-self: flex-start; }
.msg-label {
  font-size: 0.68rem; font-weight: 600;
  letter-spacing: 0.1em; text-transform: uppercase;
  color: var(--gold); margin-bottom: 5px;
  display: flex; align-items: center; gap: 5px;
}
.msg-dot { width: 6px; height: 6px; background: var(--green); border-radius: 50%; display: inline-block; }
.msg-body {
  background: var(--surface); border: 1px solid var(--border);
  padding: 14px 18px; border-radius: 4px 14px 14px 14px;
  color: var(--cream); white-space: pre-wrap;
}
.msg-user {
  align-self: flex-end; background: var(--gold); color: #FFF;
  padding: 12px 18px; border-radius: 14px 14px 4px 14px;
  font-weight: 400; max-width: 85%;
}
.msg-system {
  text-align: center; font-size: 0.82rem; color: var(--cream-sub);
  padding: 8px 0;
}

/* Typing indicator */
.typing { display: flex; gap: 4px; padding: 6px 0; }
.typing span {
  width: 6px; height: 6px; background: var(--cream-sub);
  border-radius: 50%; animation: typingDot 1.4s ease-in-out infinite;
}
.typing span:nth-child(2) { animation-delay: 0.2s; }
.typing span:nth-child(3) { animation-delay: 0.4s; }
@keyframes typingDot {
  0%, 60%, 100% { opacity: 0.3; transform: scale(0.8); }
  30% { opacity: 1; transform: scale(1); }
}

/* Chat input */
.chat-input-bar {
  padding: 14px 32px 20px; border-top: 1px solid var(--border);
  background: rgba(248,245,239,0.95); backdrop-filter: blur(10px);
  flex-shrink: 0;
}
.chat-input-inner { max-width: 640px; margin: 0 auto; display: flex; gap: 10px; }
.chat-input-inner input {
  flex: 1; background: var(--surface); border: 1px solid var(--border);
  color: var(--cream); padding: 12px 16px; border-radius: 8px;
  font-family: var(--sans); font-size: 0.9rem; outline: none;
  transition: border-color 0.2s;
}
.chat-input-inner input:focus { border-color: var(--gold); }
.btn-send {
  background: var(--gold); color: #FFF; border: none;
  padding: 12px 18px; border-radius: 8px;
  font-family: var(--sans); cursor: pointer;
  display: flex; align-items: center;
  transition: opacity 0.2s;
}
.btn-send:hover { opacity: 0.88; }
.btn-send:disabled { opacity: 0.4; cursor: not-allowed; }

/* ── PREVIEW PANEL ───────────────────────────── */
#preview-panel {
  flex-shrink: 0; background: var(--surface);
  border-left: 1px solid var(--border);
  display: flex; flex-direction: column;
  transition: width 0.22s ease, opacity 0.22s ease;
  overflow: hidden;
}
#preview-panel.preview-open { width: var(--preview-w); opacity: 1; }
#preview-panel.preview-collapsed { width: 0; opacity: 0; border-left: none; }

.preview-header {
  padding: 14px 16px; border-bottom: 1px solid var(--border);
  display: flex; align-items: center; justify-content: space-between;
  font-size: 0.72rem; font-weight: 600; letter-spacing: 0.08em;
  text-transform: uppercase; color: var(--cream-sub); flex-shrink: 0;
}
.preview-close {
  width: 24px; height: 24px; border-radius: 4px;
  border: 1px solid var(--border); background: none;
  cursor: pointer; color: var(--cream-dim); font-size: 1rem;
  display: flex; align-items: center; justify-content: center;
  transition: background 0.15s;
}
.preview-close:hover { background: var(--surface2); }
.preview-body { flex: 1; overflow-y: auto; padding: 12px; }
.preview-body::-webkit-scrollbar { width: 3px; }
.preview-body::-webkit-scrollbar-thumb { background: var(--border); border-radius: 2px; }
.preview-empty { font-size: 0.82rem; color: var(--cream-sub); text-align: center; padding: 24px 0; }

/* ── DEAL CARD ───────────────────────────────── */
.deal-card {
  background: var(--surface); border: 1px solid var(--border);
  border-radius: 10px; padding: 14px 16px; margin-bottom: 8px;
}
.deal-card-hot {
  background: linear-gradient(135deg, var(--surface) 0%, rgba(36,61,53,0.03) 100%);
  border-color: rgba(36,61,53,0.2);
}
.deal-card-header {
  display: flex; justify-content: space-between; align-items: start;
  margin-bottom: 8px;
}
.deal-card-title { font-weight: 500; font-size: 0.9rem; color: var(--cream); }
.deal-card-location { font-size: 0.75rem; color: var(--cream-sub); margin-top: 2px; }
.deal-card-actions-top { display: flex; align-items: center; gap: 6px; flex-shrink: 0; }
.deal-star-btn {
  background: none; border: none; cursor: pointer;
  font-size: 1rem; color: var(--cream-sub); padding: 0;
  transition: color 0.15s;
}
.deal-star-btn:hover { color: var(--amber); }
.deal-card-metrics {
  display: flex; gap: 10px; flex-wrap: wrap;
  font-size: 0.78rem; color: var(--cream-dim); margin-bottom: 8px;
}
.deal-card-summary {
  font-size: 0.78rem; color: var(--cream-sub); font-style: italic;
  margin-bottom: 8px; padding-top: 6px; border-top: 1px solid var(--border);
}
.deal-card-footer {
  display: flex; align-items: center; justify-content: space-between;
  padding-top: 8px; border-top: 1px solid var(--border);
}
.deal-listing-link {
  font-size: 0.75rem; font-weight: 500; color: var(--gold);
  text-decoration: none;
}
.deal-listing-link:hover { text-decoration: underline; }
.deal-open-thread-btn {
  font-size: 0.72rem; font-weight: 500; color: var(--green);
  background: var(--green-dim); border: none;
  padding: 3px 10px; border-radius: 4px; cursor: pointer;
  transition: background 0.15s;
}
.deal-open-thread-btn:hover { background: rgba(26,127,55,0.15); }

/* Tier badges */
.tier-hot { background: var(--green-dim); color: var(--green); border: 1px solid rgba(26,127,55,0.2); }
.tier-strong { background: var(--gold-dim); color: var(--gold); border: 1px solid rgba(36,61,53,0.2); }
.tier-watch { background: var(--amber-dim); color: var(--amber); border: 1px solid rgba(180,83,9,0.2); }
.deal-tier-badge {
  font-size: 0.6rem; font-weight: 600; letter-spacing: 0.1em;
  text-transform: uppercase; padding: 2px 7px; border-radius: 100px;
}

/* Risk classes */
.risk-low { color: var(--green); }
.risk-moderate { color: var(--amber); }
.risk-high { color: var(--red); }
.risk-very-high { color: var(--red); font-weight: 500; }

/* ── DEAL DETAIL (preview) ───────────────────── */
.deal-detail { padding: 4px 0; }
.deal-detail-top {
  display: flex; justify-content: space-between; align-items: start;
  margin-bottom: 14px;
}
.deal-detail-title { font-weight: 500; font-size: 1rem; color: var(--cream); }
.deal-detail-location { font-size: 0.82rem; color: var(--cream-sub); margin-top: 2px; }
.deal-detail-grid {
  display: grid; grid-template-columns: 1fr 1fr; gap: 8px; margin-bottom: 14px;
}
.deal-detail-cell {
  background: var(--surface2); border: 1px solid var(--border);
  border-radius: 6px; padding: 8px 12px;
}
.deal-detail-cell-label {
  font-size: 0.62rem; font-weight: 500; letter-spacing: 0.08em;
  text-transform: uppercase; color: var(--cream-sub); margin-bottom: 2px;
}
.deal-detail-cell-value { font-size: 0.88rem; font-weight: 500; color: var(--cream); }
.deal-detail-assessment { margin-bottom: 14px; }
.deal-detail-assessment-label {
  font-size: 0.62rem; font-weight: 600; letter-spacing: 0.08em;
  text-transform: uppercase; color: var(--cream-sub); margin-bottom: 6px;
}
.deal-detail-assessment p {
  font-size: 0.82rem; color: var(--cream-dim); line-height: 1.5;
}
.deal-detail-listing-link {
  display: block; text-align: center; font-size: 0.78rem;
  color: var(--cream-dim); background: var(--surface2);
  border: 1px solid var(--border); border-radius: 6px;
  padding: 8px; text-decoration: none; transition: border-color 0.15s;
}
.deal-detail-listing-link:hover { border-color: var(--gold); color: var(--gold); }

/* ── SETTINGS ────────────────────────────────── */
#settings-overlay {
  position: fixed; inset: 0; background: rgba(0,0,0,0.3);
  z-index: 100; display: flex; align-items: center; justify-content: center;
}
.settings-panel {
  background: var(--surface); border-radius: 12px;
  width: 360px; max-height: 80vh; overflow-y: auto;
  box-shadow: 0 8px 30px rgba(0,0,0,0.12);
  display: flex; flex-direction: column;
}
.settings-header {
  display: flex; align-items: center; justify-content: space-between;
  padding: 20px 20px 16px; border-bottom: 1px solid var(--border);
}
.settings-title { font-family: var(--serif); font-size: 1.1rem; font-weight: 400; }
.settings-close-btn {
  width: 28px; height: 28px; border-radius: 4px;
  border: 1px solid var(--border); background: none;
  cursor: pointer; color: var(--cream-dim); font-size: 1rem;
  display: flex; align-items: center; justify-content: center;
}
.settings-close-btn:hover { background: var(--surface2); }
.settings-section { padding: 16px 20px; border-bottom: 1px solid var(--border); }
.settings-section-title {
  font-size: 0.64rem; font-weight: 600; letter-spacing: 0.12em;
  text-transform: uppercase; color: var(--cream-sub); margin-bottom: 10px;
}
.settings-link {
  display: block; padding: 6px 0; font-size: 0.82rem;
  color: var(--cream-dim); text-decoration: none;
  transition: color 0.12s;
}
.settings-link:hover { color: var(--gold); }
.settings-plan { font-size: 0.82rem; color: var(--cream-dim); margin-bottom: 10px; }
.settings-plan strong { color: var(--cream); font-weight: 500; }
.settings-upgrade-btn {
  display: block; width: 100%; text-align: center;
  background: var(--gold); color: #FFF; border: none;
  padding: 10px; border-radius: 4px;
  font-family: var(--sans); font-size: 0.78rem; font-weight: 500;
  cursor: pointer; transition: opacity 0.2s;
}
.settings-upgrade-btn:hover { opacity: 0.88; }
.settings-notif-row {
  display: flex; align-items: center; justify-content: space-between;
  padding: 6px 0; font-size: 0.82rem; color: var(--cream-dim);
}
.toggle { position: relative; width: 36px; height: 20px; flex-shrink: 0; }
.toggle input { opacity: 0; width: 0; height: 0; position: absolute; }
.toggle-track {
  position: absolute; inset: 0; background: var(--border);
  border-radius: 10px; cursor: pointer; transition: background 0.2s;
}
.toggle input:checked + .toggle-track { background: var(--gold); }
.toggle-track::after {
  content: ''; position: absolute; top: 2px; left: 2px;
  width: 16px; height: 16px; background: white;
  border-radius: 50%; transition: transform 0.2s;
}
.toggle input:checked + .toggle-track::after { transform: translateX(16px); }
.settings-bottom { padding: 16px 20px; }
.settings-signout {
  font-size: 0.78rem; color: var(--cream-sub); background: none;
  border: none; cursor: pointer; font-family: var(--sans); padding: 0;
  transition: color 0.12s;
}
.settings-signout:hover { color: var(--red); }
```

- [ ] **Step 2: Commit**

```bash
git add dashboard/src/styles.css
git commit -m "feat: add dashboard CSS design system — all component styles"
```

---

## Task 9: Frontend — State Management + API Client

**Files:**
- Create: `dashboard/src/lib/state.js`
- Create: `dashboard/src/lib/api.js`
- Create: `dashboard/src/lib/utils.js`

- [ ] **Step 1: Create `dashboard/src/lib/utils.js`**

```javascript
export function fmtPrice(n) {
  if (n == null) return '—';
  if (n >= 1000000) return '$' + (n / 1000000).toFixed(1) + 'M';
  if (n >= 1000) return '$' + Math.round(n / 1000) + 'k';
  return '$' + n;
}

export function tierFromStrategy(overall) {
  switch ((overall || '').toUpperCase()) {
    case 'STRONG MATCH': return 'hot';
    case 'MATCH': return 'strong';
    default: return 'watch';
  }
}

export function tierLabel(tier) {
  return { hot: 'HOT', strong: 'STRONG', watch: 'WATCH' }[tier] || 'WATCH';
}

export function riskClass(level) {
  if (!level) return 'risk-moderate';
  switch (level.toUpperCase()) {
    case 'LOW': return 'risk-low';
    case 'MODERATE': return 'risk-moderate';
    case 'HIGH': return 'risk-high';
    case 'VERY HIGH': return 'risk-very-high';
    default: return 'risk-moderate';
  }
}

export function parseBreakdown(raw) {
  if (!raw) return {};
  try { return typeof raw === 'string' ? JSON.parse(raw) : raw; }
  catch { return {}; }
}

export function escHtml(str) {
  const d = document.createElement('div');
  d.textContent = str || '';
  return d.innerHTML;
}
```

- [ ] **Step 2: Create `dashboard/src/lib/state.js`**

```javascript
import { signal, computed } from '@preact/signals';

// ── Core state signals ──────────────────────────────────────────
export const email = signal(null);
export const agentName = signal(null);
export const view = signal('gate'); // 'gate' | 'onboarding' | 'scan' | 'deal'
export const activeThreadId = signal(null); // scan ID or deal ID
export const settingsOpen = signal(false);
export const previewOpen = signal(false);

// ── Data from /api/user-data ────────────────────────────────────
export const scans = signal([]);
export const deals = signal([]);
export const activeThreads = signal([]);
export const starredDealIds = signal(new Set());

// ── Chat state ──────────────────────────────────────────────────
export const chatMessages = signal([]);
export const chatConversationId = signal(null);
export const chatStreaming = signal(false);

// ── Conversation cache ──────────────────────────────────────────
const MAX_CACHE = 8;
const cache = new Map(); // threadId → { messages, conversationId, lastAccessed }

export function cacheGet(threadId) {
  const entry = cache.get(threadId);
  if (entry) {
    entry.lastAccessed = Date.now();
    return entry;
  }
  return null;
}

export function cacheSet(threadId, data) {
  cache.set(threadId, { ...data, lastAccessed: Date.now() });
  // Evict oldest if over limit
  if (cache.size > MAX_CACHE) {
    let oldestKey = null, oldestTime = Infinity;
    for (const [key, val] of cache) {
      if (key !== activeThreadId.value && val.lastAccessed < oldestTime) {
        oldestTime = val.lastAccessed;
        oldestKey = key;
      }
    }
    if (oldestKey) cache.delete(oldestKey);
  }
}

// ── Computed values ─────────────────────────────────────────────
export const activeDeals = computed(() => {
  const threadDealIds = new Set(activeThreads.value.map(t => t.deal_id));
  return deals.value.filter(d => threadDealIds.has(d.id));
});

export const currentScan = computed(() => {
  if (view.value !== 'scan') return null;
  return scans.value.find(s => s.id === activeThreadId.value) || null;
});

export const currentDeal = computed(() => {
  if (view.value !== 'deal') return null;
  return deals.value.find(d => d.id === activeThreadId.value) || null;
});

export const dealsForCurrentScan = computed(() => {
  const scan = currentScan.value;
  if (!scan) return [];
  return deals.value.filter(d => d.search_id === scan.id);
});
```

- [ ] **Step 3: Create `dashboard/src/lib/api.js`**

```javascript
import {
  email, agentName, scans, deals, activeThreads, starredDealIds,
  chatMessages, chatConversationId, chatStreaming,
  cacheGet, cacheSet, activeThreadId
} from './state.js';

const API_BASE = '';

// ── Load user data ──────────────────────────────────────────────
export async function loadUserData() {
  const res = await fetch(`${API_BASE}/api/user-data?email=${encodeURIComponent(email.value)}`);
  if (!res.ok) throw new Error('Failed to load user data');
  const data = await res.json();

  agentName.value = data.agent_name;
  scans.value = data.scans || [];
  deals.value = data.deals || [];
  activeThreads.value = data.active_threads || [];
  starredDealIds.value = new Set(data.deals.filter(d => d.starred).map(d => d.id));
}

// ── Load conversation ───────────────────────────────────────────
export async function loadConversation(conversationId) {
  const res = await fetch(
    `${API_BASE}/api/conversation?id=${conversationId}&email=${encodeURIComponent(email.value)}`
  );
  if (!res.ok) throw new Error('Conversation not found');
  return res.json();
}

// ── Switch to a thread (scan or deal) ───────────────────────────
export async function switchThread(threadId, type, conversationId) {
  activeThreadId.value = threadId;

  // Check cache first
  const cached = cacheGet(threadId);
  if (cached) {
    chatMessages.value = cached.messages;
    chatConversationId.value = cached.conversationId;
    return;
  }

  // Load from API if we have a conversation ID
  if (conversationId) {
    try {
      const data = await loadConversation(conversationId);
      chatMessages.value = data.messages || [];
      chatConversationId.value = conversationId;
      cacheSet(threadId, { messages: data.messages || [], conversationId });
    } catch {
      chatMessages.value = [];
      chatConversationId.value = null;
    }
  } else {
    // New conversation — no history
    chatMessages.value = [];
    chatConversationId.value = null;
  }
}

// ── Send chat message (SSE streaming) ───────────────────────────
export async function sendMessage(text, endpoint, extraBody = {}) {
  const userMsg = { role: 'user', content: text };
  chatMessages.value = [...chatMessages.value, userMsg];
  chatStreaming.value = true;

  const allMessages = chatMessages.value.map(m => ({ role: m.role, content: m.content }));

  try {
    const res = await fetch(`${API_BASE}${endpoint}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email: email.value,
        messages: allMessages,
        conversation_id: chatConversationId.value,
        agent_name: agentName.value,
        ...extraBody
      })
    });

    const reader = res.body.getReader();
    const decoder = new TextDecoder();
    let assistantText = '';
    let buffer = '';

    while (true) {
      const { done, value } = await reader.read();
      if (done) break;

      buffer += decoder.decode(value, { stream: true });
      const lines = buffer.split('\n');
      buffer = lines.pop();

      for (const line of lines) {
        if (!line.startsWith('data: ')) continue;
        try {
          const event = JSON.parse(line.slice(6));

          if (event.type === 'text') {
            assistantText += event.text;
            // Update the last message or add new one
            const msgs = [...chatMessages.value];
            const lastMsg = msgs[msgs.length - 1];
            if (lastMsg && lastMsg.role === 'assistant' && lastMsg._streaming) {
              msgs[msgs.length - 1] = { role: 'assistant', content: assistantText, _streaming: true };
            } else {
              msgs.push({ role: 'assistant', content: assistantText, _streaming: true });
            }
            chatMessages.value = msgs;
          } else if (event.type === 'conversation_id') {
            chatConversationId.value = event.id;
          } else if (event.type === 'buy_box_saved') {
            // Emit custom event for the chat component to handle
            window.dispatchEvent(new CustomEvent('buybox-saved', { detail: event }));
          } else if (event.type === 'error') {
            const msgs = [...chatMessages.value];
            msgs.push({ role: 'assistant', content: 'Error: ' + event.error });
            chatMessages.value = msgs;
          }
        } catch { /* skip malformed JSON */ }
      }
    }

    // Finalize — remove _streaming flag
    if (assistantText) {
      const msgs = [...chatMessages.value];
      const lastMsg = msgs[msgs.length - 1];
      if (lastMsg && lastMsg._streaming) {
        msgs[msgs.length - 1] = { role: 'assistant', content: assistantText };
      }
      chatMessages.value = msgs;
    }

    // Cache the conversation
    cacheSet(activeThreadId.value, {
      messages: chatMessages.value,
      conversationId: chatConversationId.value
    });

  } catch (err) {
    const msgs = [...chatMessages.value];
    msgs.push({ role: 'system', content: 'Connection lost. Try again.' });
    chatMessages.value = msgs;
  }

  chatStreaming.value = false;
}

// ── Star/unstar a deal ──────────────────────────────────────────
export async function toggleStar(dealId) {
  const currentlyStarred = starredDealIds.value.has(dealId);
  const newStarred = !currentlyStarred;

  // Optimistic update
  const updated = new Set(starredDealIds.value);
  if (newStarred) updated.add(dealId); else updated.delete(dealId);
  starredDealIds.value = updated;

  try {
    const res = await fetch(`${API_BASE}/api/star-deal`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email: email.value, deal_id: dealId, starred: newStarred })
    });
    if (!res.ok) throw new Error();
  } catch {
    // Revert on failure
    const reverted = new Set(starredDealIds.value);
    if (currentlyStarred) reverted.add(dealId); else reverted.delete(dealId);
    starredDealIds.value = reverted;
  }
}
```

- [ ] **Step 4: Commit**

```bash
git add dashboard/src/lib/
git commit -m "feat: add state management, API client, and utility helpers"
```

---

## Task 10: Frontend — Root App Component + Email Gate

**Files:**
- Create: `dashboard/src/app.jsx`
- Modify: `dashboard/src/main.jsx`
- Modify: `dashboard/index.html`

- [ ] **Step 1: Update `dashboard/index.html`**

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
</head>
<body>
  <div id="app"></div>
  <script type="module" src="/src/main.jsx"></script>
</body>
</html>
```

- [ ] **Step 2: Update `dashboard/src/main.jsx`**

```jsx
import { render } from 'preact';
import { App } from './app.jsx';
import './styles.css';

render(<App />, document.getElementById('app'));
```

- [ ] **Step 3: Create `dashboard/src/app.jsx`**

```jsx
import { useEffect } from 'preact/hooks';
import { email, view, agentName, scans } from './lib/state.js';
import { loadUserData, switchThread } from './lib/api.js';
import { Sidebar } from './components/Sidebar.jsx';
import { Chat } from './components/Chat.jsx';
import { Preview } from './components/Preview.jsx';
import { Settings } from './components/Settings.jsx';

function EmailGate() {
  const handleSubmit = async (e) => {
    e.preventDefault();
    const val = e.target.elements.email.value.trim();
    if (!val) return;
    email.value = val;
    localStorage.setItem('dh_email', val);

    try {
      await loadUserData();
      // Determine initial view
      const completedScans = scans.value.filter(s => s.status === 'complete');
      if (completedScans.length > 0) {
        // Open most recent scan debrief
        const latest = completedScans[0];
        view.value = 'scan';
        await switchThread(latest.id, 'scan', latest.conversation_id);
      } else if (scans.value.length > 0) {
        // Has scans but none complete — show welcome
        view.value = 'onboarding';
      } else {
        // Brand new user — start onboarding
        view.value = 'onboarding';
      }
    } catch {
      view.value = 'onboarding';
    }
  };

  return (
    <div class="email-gate">
      <h1>Your <em>deal hunting</em><br />command center.</h1>
      <p>Enter your email to access your buy boxes, scan results, and top deals.</p>
      <form class="gate-form" onSubmit={handleSubmit}>
        <input type="email" name="email" placeholder="your@email.com" required autocomplete="email" autofocus />
        <button type="submit" class="btn-primary">Open Dashboard</button>
      </form>
    </div>
  );
}

export function App() {
  // Check for stored email on mount
  useEffect(() => {
    const stored = localStorage.getItem('dh_email');
    if (stored) {
      email.value = stored;
      loadUserData().then(() => {
        const completedScans = scans.value.filter(s => s.status === 'complete');
        if (completedScans.length > 0) {
          view.value = 'scan';
          switchThread(completedScans[0].id, 'scan', completedScans[0].conversation_id);
        } else {
          view.value = 'onboarding';
        }
      }).catch(() => {
        view.value = 'onboarding';
      });
    }
  }, []);

  if (!email.value) {
    return <EmailGate />;
  }

  return (
    <div id="app-shell">
      <Settings />
      <Sidebar />
      <Chat />
      <Preview />
    </div>
  );
}
```

- [ ] **Step 4: Verify email gate renders**

```bash
npx vite
```
Open `http://localhost:5173`. Expected: Email gate with heading "Your deal hunting command center." and email form.

- [ ] **Step 5: Commit**

```bash
git add dashboard/
git commit -m "feat: add root app component with email gate"
```

---

## Task 11: Frontend — Sidebar Component

**Files:**
- Create: `dashboard/src/components/Sidebar.jsx`

- [ ] **Step 1: Create the component**

```jsx
import { email, agentName, view, activeThreadId, scans, deals, activeThreads, activeDeals, settingsOpen } from '../lib/state.js';
import { switchThread, loadUserData } from '../lib/api.js';
import { tierFromStrategy, tierLabel, fmtPrice, parseBreakdown } from '../lib/utils.js';

function SidebarDealRow({ deal }) {
  const bd = parseBreakdown(deal.score_breakdown);
  const tier = tierFromStrategy(bd.strategy?.overall);
  const isActive = view.value === 'deal' && activeThreadId.value === deal.id;

  const thread = activeThreads.value.find(t => t.deal_id === deal.id);

  const handleClick = () => {
    view.value = 'deal';
    switchThread(deal.id, 'deal', thread?.conversation_id);
  };

  return (
    <div class={`sidebar-deal-row ${isActive ? 'active' : ''}`} onClick={handleClick}>
      <div class="sidebar-deal-name">
        <span>{deal.title || 'Untitled'}</span>
        <span class={`sidebar-tier tier-${tier}`}>{tierLabel(tier)}</span>
      </div>
      <div class="sidebar-deal-meta">{fmtPrice(deal.price)} · {deal.location?.split(',')[0] || ''}</div>
    </div>
  );
}

function SidebarScanRow({ scan }) {
  const isActive = view.value === 'scan' && activeThreadId.value === scan.id;
  const date = scan.run_at ? new Date(scan.run_at).toLocaleDateString('en-US', { month: 'short', day: 'numeric' }) : '';

  const handleClick = () => {
    view.value = 'scan';
    switchThread(scan.id, 'scan', scan.conversation_id);
  };

  return (
    <div class={`sidebar-scan-row ${isActive ? 'active' : ''}`} onClick={handleClick}>
      <div class="sidebar-scan-name">{date} Scan</div>
      <div class="sidebar-scan-meta">{scan.deal_count || 0} deals</div>
    </div>
  );
}

export function Sidebar() {
  const activeDealsList = activeDeals.value;
  const completedScans = scans.value.filter(s => s.status === 'complete');

  const startNewScan = () => {
    view.value = 'onboarding';
    activeThreadId.value = null;
  };

  return (
    <div id="sidebar">
      {/* Logo */}
      <div class="sidebar-logo">
        <div class="sidebar-logo-icon">
          <svg width="13" height="13" viewBox="0 0 16 16" fill="white"><path d="M8 0 L9.6 6.4 L16 8 L9.6 9.6 L8 16 L6.4 9.6 L0 8 L6.4 6.4 Z"/></svg>
        </div>
        <span class="sidebar-logo-text">{agentName.value || 'Deal Hound'}</span>
      </div>

      {/* Scrollable content */}
      <div class="sidebar-scroll">
        {/* New Scan */}
        <div class="sidebar-section-pad">
          <button class="sidebar-new-scan" onClick={startNewScan}>
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round">
              <line x1="12" y1="5" x2="12" y2="19" /><line x1="5" y1="12" x2="19" y2="12" />
            </svg>
            New Scan
          </button>
        </div>

        {/* Active Deals */}
        <div class="sidebar-section-hdr">Active Deals</div>
        {activeDealsList.length === 0 ? (
          <div class="sidebar-empty">None yet</div>
        ) : (
          activeDealsList.map(deal => <SidebarDealRow key={deal.id} deal={deal} />)
        )}

        <div class="sidebar-divider" />

        {/* Scans */}
        <div class="sidebar-section-hdr">Scans</div>
        {completedScans.length === 0 ? (
          <div class="sidebar-empty">No scans yet</div>
        ) : (
          completedScans.map(scan => <SidebarScanRow key={scan.id} scan={scan} />)
        )}

        <div class="sidebar-divider" />

        {/* Buy Box Setup — always accessible */}
        <div class="sidebar-scan-row" onClick={startNewScan}>
          <div class="sidebar-scan-name">Buy Box Setup</div>
          <div class="sidebar-scan-meta">Edit criteria</div>
        </div>
      </div>

      {/* Footer */}
      <div class="sidebar-footer">
        <button class="sidebar-settings-btn" onClick={() => { settingsOpen.value = true; }} title="Settings">
          <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round">
            <circle cx="12" cy="12" r="3" />
            <path d="M19.4 15a1.65 1.65 0 00.33 1.82l.06.06a2 2 0 010 2.83 2 2 0 01-2.83 0l-.06-.06a1.65 1.65 0 00-1.82-.33 1.65 1.65 0 00-1 1.51V21a2 2 0 01-4 0v-.09A1.65 1.65 0 009 19.4a1.65 1.65 0 00-1.82.33l-.06.06a2 2 0 01-2.83-2.83l.06-.06A1.65 1.65 0 004.68 15a1.65 1.65 0 00-1.51-1H3a2 2 0 010-4h.09A1.65 1.65 0 004.6 9a1.65 1.65 0 00-.33-1.82l-.06-.06a2 2 0 012.83-2.83l.06.06A1.65 1.65 0 009 4.68a1.65 1.65 0 001-1.51V3a2 2 0 014 0v.09a1.65 1.65 0 001 1.51 1.65 1.65 0 001.82-.33l.06-.06a2 2 0 012.83 2.83l-.06.06A1.65 1.65 0 0019.4 9a1.65 1.65 0 001.51 1H21a2 2 0 010 4h-.09a1.65 1.65 0 00-1.51 1z" />
          </svg>
        </button>
        <span class="sidebar-email">{email.value}</span>
      </div>
    </div>
  );
}
```

- [ ] **Step 2: Commit**

```bash
git add dashboard/src/components/Sidebar.jsx
git commit -m "feat: add Sidebar component — navigation, deal list, scan list"
```

---

## Task 12: Frontend — DealCard Component

**Files:**
- Create: `dashboard/src/components/DealCard.jsx`

- [ ] **Step 1: Create the component**

This is the reusable deal card used in both the chat (inline) and preview panel.

```jsx
import { starredDealIds } from '../lib/state.js';
import { toggleStar } from '../lib/api.js';
import { fmtPrice, tierFromStrategy, tierLabel, riskClass, parseBreakdown } from '../lib/utils.js';

export function DealCard({ deal, variant = 'preview', onOpenThread }) {
  const bd = parseBreakdown(deal.score_breakdown);
  const strategy = bd.strategy || {};
  const risk = bd.risk || {};
  const tier = tierFromStrategy(strategy.overall);
  const isStarred = starredDealIds.value.has(deal.id);

  const acreage = deal.acreage ? deal.acreage + ' ac' : null;
  const keys = deal.rooms_keys ? deal.rooms_keys + ' keys' : null;

  return (
    <div class={`deal-card deal-card-${variant} ${tier === 'hot' ? 'deal-card-hot' : ''}`}>
      <div class="deal-card-header">
        <div>
          <div class="deal-card-title">{deal.title || 'Unnamed Property'}</div>
          <div class="deal-card-location">{deal.location || ''}{deal.source ? ` · ${deal.source}` : ''}</div>
        </div>
        <div class="deal-card-actions-top">
          <button class="deal-star-btn" onClick={(e) => { e.stopPropagation(); toggleStar(deal.id); }} title={isStarred ? 'Unstar' : 'Star'}>
            {isStarred ? '★' : '☆'}
          </button>
          <span class={`deal-tier-badge tier-${tier}`}>{tierLabel(tier)}</span>
        </div>
      </div>

      <div class="deal-card-metrics">
        {deal.price != null && <span>{fmtPrice(deal.price)}</span>}
        {acreage && <span>{acreage}</span>}
        {keys && <span>{keys}</span>}
        {risk.level && <span class={riskClass(risk.level)}>{risk.level} Risk</span>}
      </div>

      {strategy.summary && (
        <div class="deal-card-summary">{strategy.summary}</div>
      )}

      <div class="deal-card-footer">
        {deal.url && <a href={deal.url} target="_blank" rel="noopener" class="deal-listing-link">Listing →</a>}
        {onOpenThread && (
          <button class="deal-open-thread-btn" onClick={(e) => { e.stopPropagation(); onOpenThread(deal); }}>
            Open Thread →
          </button>
        )}
      </div>
    </div>
  );
}
```

- [ ] **Step 2: Commit**

```bash
git add dashboard/src/components/DealCard.jsx
git commit -m "feat: add DealCard component — reusable in chat + preview"
```

---

## Task 13: Frontend — Chat Component

**Files:**
- Create: `dashboard/src/components/Chat.jsx`

- [ ] **Step 1: Create the component**

```jsx
import { useRef, useEffect } from 'preact/hooks';
import { view, agentName, chatMessages, chatStreaming, chatConversationId, activeThreadId, scans, currentDeal } from '../lib/state.js';
import { sendMessage, loadUserData, switchThread } from '../lib/api.js';

function TypingIndicator() {
  return (
    <div class="msg msg-assistant">
      <div class="msg-label"><span class="msg-dot" />{agentName.value || 'Agent'}</div>
      <div class="typing"><span /><span /><span /></div>
    </div>
  );
}

export function Chat() {
  const msgsRef = useRef(null);
  const inputRef = useRef(null);

  // Auto-scroll on new messages
  useEffect(() => {
    if (msgsRef.current) {
      msgsRef.current.scrollTop = msgsRef.current.scrollHeight;
    }
  }, [chatMessages.value]);

  // Auto-trigger onboarding or debrief on view change
  useEffect(() => {
    if (view.value === 'onboarding' && chatMessages.value.length === 0) {
      // Start onboarding conversation
      sendMessage('Hi, I want to set up my buy box.', '/api/chat', { mode: 'buy_box_intake' });
    } else if (view.value === 'scan' && chatMessages.value.length === 0 && activeThreadId.value) {
      // Start debrief conversation
      sendMessage('Show me my scan results.', '/api/chat', { mode: 'scan_debrief', search_id: activeThreadId.value });
    } else if (view.value === 'deal' && chatMessages.value.length === 0 && currentDeal.value) {
      // Start deal thread
      const scan = scans.value.find(s => s.id === currentDeal.value.search_id);
      const buyBox = scan?.buy_box || {};
      sendMessage('Break down this deal for me.', '/api/deal-chat', { deal: currentDeal.value, buy_box: buyBox });
    }
  }, [view.value, activeThreadId.value]);

  // Listen for buy_box_saved events
  useEffect(() => {
    const handler = async (e) => {
      const { search_id } = e.detail;
      // Reload user data to get new scan
      await loadUserData();
      // Switch to scan debrief (scan will be in 'ready' state — user needs to run it)
    };
    window.addEventListener('buybox-saved', handler);
    return () => window.removeEventListener('buybox-saved', handler);
  }, []);

  const handleSend = () => {
    if (chatStreaming.value) return;
    const text = inputRef.current?.value?.trim();
    if (!text) return;
    inputRef.current.value = '';

    if (view.value === 'deal' && currentDeal.value) {
      const scan = scans.value.find(s => s.id === currentDeal.value.search_id);
      sendMessage(text, '/api/deal-chat', { deal: currentDeal.value, buy_box: scan?.buy_box || {} });
    } else {
      const extra = {};
      if (view.value === 'scan' && activeThreadId.value) {
        extra.mode = 'scan_debrief';
        extra.search_id = activeThreadId.value;
      }
      sendMessage(text, '/api/chat', extra);
    }
  };

  const handleKeyDown = (e) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      handleSend();
    }
  };

  return (
    <div id="chat-panel">
      <div class="chat-messages" ref={msgsRef}>
        <div class="chat-messages-inner">
          {chatMessages.value.map((msg, i) => (
            <div key={i} class={`msg msg-${msg.role}`}>
              {msg.role === 'assistant' ? (
                <>
                  <div class="msg-label"><span class="msg-dot" />{agentName.value || 'Agent'}</div>
                  <div class="msg-body">{msg.content}</div>
                </>
              ) : msg.role === 'system' ? (
                <div class="msg-system">{msg.content}</div>
              ) : (
                msg.content
              )}
            </div>
          ))}
          {chatStreaming.value && chatMessages.value[chatMessages.value.length - 1]?.role !== 'assistant' && (
            <TypingIndicator />
          )}
        </div>
      </div>

      <div class="chat-input-bar">
        <div class="chat-input-inner">
          <input
            ref={inputRef}
            type="text"
            placeholder={view.value === 'deal' ? 'Ask about this deal...' : 'Talk to your agent...'}
            autocomplete="off"
            onKeyDown={handleKeyDown}
          />
          <button class="btn-send" onClick={handleSend} disabled={chatStreaming.value}>
            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <line x1="22" y1="2" x2="11" y2="13" /><polygon points="22 2 15 22 11 13 2 9 22 2" />
            </svg>
          </button>
        </div>
      </div>
    </div>
  );
}
```

- [ ] **Step 2: Commit**

```bash
git add dashboard/src/components/Chat.jsx
git commit -m "feat: add Chat component — messages, SSE streaming, input"
```

---

## Task 14: Frontend — Preview Component

**Files:**
- Create: `dashboard/src/components/Preview.jsx`

- [ ] **Step 1: Create the component**

```jsx
import { useEffect } from 'preact/hooks';
import { view, previewOpen, currentDeal, dealsForCurrentScan, currentScan, starredDealIds, activeThreads } from '../lib/state.js';
import { switchThread, loadUserData } from '../lib/api.js';
import { DealCard } from './DealCard.jsx';
import { fmtPrice, tierFromStrategy, tierLabel, riskClass, parseBreakdown } from '../lib/utils.js';

function ScanDealList() {
  const scan = currentScan.value;
  const scanDeals = dealsForCurrentScan.value;

  const openThread = async (deal) => {
    // Switch to deal thread view — first message will auto-trigger via Chat component
    view.value = 'deal';
    await switchThread(deal.id, 'deal', null);
    // Refresh user data to update active_threads
    await loadUserData();
  };

  return (
    <>
      <div class="preview-header">
        <span>{scan ? `${new Date(scan.run_at).toLocaleDateString('en-US', { month: 'short', day: 'numeric' })} Scan · ${scanDeals.length} Deals` : 'Deals'}</span>
        <button class="preview-close" onClick={() => { previewOpen.value = false; }}>×</button>
      </div>
      <div class="preview-body">
        {scanDeals.length === 0 ? (
          <div class="preview-empty">No deals in this scan.</div>
        ) : (
          scanDeals.map(deal => (
            <DealCard key={deal.id} deal={deal} variant="preview" onOpenThread={openThread} />
          ))
        )}
      </div>
    </>
  );
}

function DealDetail() {
  const deal = currentDeal.value;
  if (!deal) return null;

  const bd = parseBreakdown(deal.score_breakdown);
  const strategy = bd.strategy || {};
  const risk = bd.risk || {};
  const tier = tierFromStrategy(strategy.overall);

  return (
    <>
      <div class="preview-header">
        <span>Deal Detail</span>
        <button class="preview-close" onClick={() => { previewOpen.value = false; }}>×</button>
      </div>
      <div class="preview-body">
        <div class="deal-detail">
          <div class="deal-detail-top">
            <div>
              <div class="deal-detail-title">{deal.title || 'Unnamed'}</div>
              <div class="deal-detail-location">{deal.location || ''}</div>
            </div>
            <span class={`deal-tier-badge tier-${tier}`}>{tierLabel(tier)}</span>
          </div>

          <div class="deal-detail-grid">
            <div class="deal-detail-cell">
              <div class="deal-detail-cell-label">Price</div>
              <div class="deal-detail-cell-value">{fmtPrice(deal.price)}</div>
            </div>
            <div class="deal-detail-cell">
              <div class="deal-detail-cell-label">Acreage</div>
              <div class="deal-detail-cell-value">{deal.acreage ? deal.acreage + ' ac' : '—'}</div>
            </div>
            <div class="deal-detail-cell">
              <div class="deal-detail-cell-label">Keys</div>
              <div class="deal-detail-cell-value">{deal.rooms_keys || '—'}</div>
            </div>
            <div class="deal-detail-cell">
              <div class="deal-detail-cell-label">Risk</div>
              <div class={`deal-detail-cell-value ${riskClass(risk.level)}`}>{risk.level || '—'}</div>
            </div>
          </div>

          {strategy.summary && (
            <div class="deal-detail-assessment">
              <div class="deal-detail-assessment-label">Agent Assessment</div>
              <p>{strategy.summary}</p>
            </div>
          )}

          {deal.url && (
            <a href={deal.url} target="_blank" rel="noopener" class="deal-detail-listing-link">View Original Listing →</a>
          )}
        </div>
      </div>
    </>
  );
}

export function Preview() {
  const shouldShow = (view.value === 'scan' && dealsForCurrentScan.value.length > 0) || view.value === 'deal';

  // Auto-open preview when switching to scan/deal view (in effect, not during render)
  useEffect(() => {
    if (shouldShow && !previewOpen.value) {
      previewOpen.value = true;
    } else if (!shouldShow && previewOpen.value) {
      previewOpen.value = false;
    }
  }, [shouldShow]);

  if (!previewOpen.value) {
    return <div id="preview-panel" class="preview-collapsed" />;
  }

  return (
    <div id="preview-panel" class="preview-open">
      {view.value === 'scan' && <ScanDealList />}
      {view.value === 'deal' && <DealDetail />}
    </div>
  );
}
```

- [ ] **Step 2: Commit**

```bash
git add dashboard/src/components/Preview.jsx
git commit -m "feat: add Preview component — deal list + deal detail"
```

---

## Task 15: Frontend — Settings Component

**Files:**
- Create: `dashboard/src/components/Settings.jsx`

- [ ] **Step 1: Create the component**

```jsx
import { settingsOpen, email } from '../lib/state.js';

export function Settings() {
  if (!settingsOpen.value) return null;

  const digestOn = localStorage.getItem('dh_notif_digest') !== 'false';

  const toggleDigest = (e) => {
    localStorage.setItem('dh_notif_digest', e.target.checked ? 'true' : 'false');
  };

  const signOut = () => {
    localStorage.removeItem('dh_email');
    localStorage.removeItem('dh_notif_digest');
    window.location.reload();
  };

  return (
    <div id="settings-overlay" onClick={(e) => { if (e.target.id === 'settings-overlay') settingsOpen.value = false; }}>
      <div class="settings-panel">
        <div class="settings-header">
          <span class="settings-title">Settings</span>
          <button class="settings-close-btn" onClick={() => { settingsOpen.value = false; }}>×</button>
        </div>

        {/* Help */}
        <div class="settings-section">
          <div class="settings-section-title">Help</div>
          <a href="mailto:support@dealhound.pro" class="settings-link">Contact Support →</a>
          <a href="https://dealhound.pro" target="_blank" class="settings-link">Documentation →</a>
        </div>

        {/* Billing */}
        <div class="settings-section">
          <div class="settings-section-title">Billing</div>
          <div class="settings-plan">Current plan: <strong>Free</strong></div>
          <button class="settings-upgrade-btn" onClick={() => alert('Upgrade coming soon! Email support@dealhound.pro for early access.')}>
            Upgrade to Pro — $29/mo
          </button>
        </div>

        {/* Notifications */}
        <div class="settings-section">
          <div class="settings-section-title">Notifications</div>
          <div class="settings-notif-row">
            <span>Daily digest email</span>
            <label class="toggle">
              <input type="checkbox" checked={digestOn} onChange={toggleDigest} />
              <span class="toggle-track" />
            </label>
          </div>
        </div>

        {/* Sign out */}
        <div class="settings-bottom">
          <button class="settings-signout" onClick={signOut}>Sign out</button>
        </div>
      </div>
    </div>
  );
}
```

- [ ] **Step 2: Commit**

```bash
git add dashboard/src/components/Settings.jsx
git commit -m "feat: add Settings component — help, billing, notifications, sign out"
```

---

## Task 16: Integration Test + Push to Staging

- [ ] **Step 1: Start both servers**

Terminal 1 (API):
```bash
cd /Users/gideonspencer/dealhound-pro
npx vercel dev --listen 3000
```

Terminal 2 (Frontend):
```bash
cd /Users/gideonspencer/dealhound-pro
npx vite
```

- [ ] **Step 2: Test email gate**

Open `http://localhost:5173`. Enter email. Expected: gate disappears, three-panel layout appears.

- [ ] **Step 3: Test sidebar**

Expected: sidebar shows agent name in logo area, "Active Deals" section (empty or populated), "Scans" section, settings gear at bottom.

- [ ] **Step 4: Test new scan → onboarding chat**

Click "+ New Scan". Expected: chat area shows agent introduction with personalized name. Agent asks first buy box question. User can respond and continue the onboarding flow.

- [ ] **Step 5: Test scan debrief (requires completed scan in DB)**

If a completed scan exists, click it in sidebar. Expected: chat shows agent debrief with deal analysis. Preview panel opens with deal card list.

- [ ] **Step 6: Test deal thread**

Click "Open Thread" on a deal card in preview. Expected: view switches to deal thread. Preview shows deal detail. Chat shows agent's initial analysis of the deal.

- [ ] **Step 7: Test settings**

Click gear icon. Expected: settings panel opens. Help links, billing section, notification toggle visible. "Sign out" clears email and reloads.

- [ ] **Step 8: Test star toggle**

Click star button on a deal card. Expected: star fills/unfills. If Supabase is connected, persists across page reload.

- [ ] **Step 9: Commit any integration fixes**

```bash
git add -A
git commit -m "fix: integration test fixes for dashboard"
```

- [ ] **Step 10: Push branch for Vercel preview deployment**

```bash
git push -u origin feature/dashboard-ux
```

Vercel will automatically create a preview deployment at a URL like:
`https://dealhound-pro-git-feature-dashboard-ux-*.vercel.app`

- [ ] **Step 11: Verify `/dashboard/` at preview URL**

Open the preview URL + `/dashboard/`. Expected: same behavior as local.

---

## Summary

| Task | What It Produces |
|------|-----------------|
| 1 | Branch + Vite + Preact + vercel.json |
| 2 | Database tables (users, user_deal_stars, conversations.search_id) |
| 3 | `/api/user-data` — sidebar data + agent name |
| 4 | `/api/conversation` — load conversation history |
| 5 | `/api/star-deal` — toggle star |
| 6 | `/api/deal-chat` — deal thread streaming |
| 7 | `/api/chat` extended with scan_debrief mode |
| 8 | CSS design system |
| 9 | State management + API client + utilities |
| 10 | Root app + email gate |
| 11 | Sidebar component |
| 12 | DealCard component (reusable) |
| 13 | Chat component (SSE streaming) |
| 14 | Preview component (deal list + deal detail) |
| 15 | Settings component |
| 16 | Integration test + staging deploy |
