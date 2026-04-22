# Deal Hound Dashboard UX — Design Spec

## What We're Building

A three-panel dashboard at `/dashboard/` that replaces the fragmented page-per-step flow with a unified experience. The user sits across the table from their named AI deal agent, who debriefs them on new deals, answers questions, compares properties, and helps them work deals over time.

The magic is the conversation — not a dashboard, not a listing feed. A personal deal analyst who scanned 30+ marketplaces while you slept and has opinions about what you should pursue.

## Core Experience

The user opens Deal Hound. Their agent (randomly named from a curated roster) says: "I found 3 deals overnight. Cedar Ridge is the one I'd call about today." The user pushes back, compares deals, drills into specifics — all in conversation. When they decide to pursue a deal, they open a thread for it. That thread lives for weeks: broker call notes, due diligence checklists, negotiation strategy. The sidebar is their deal pipeline. The product becomes where they build their deal-hunting life.

## Information Architecture

### Objects

| Object | Description | Storage |
|--------|-------------|---------|
| **User** | Identified by email. Has a randomly assigned agent name. | Supabase `users` table (email + agent_name) |
| **Buy Box** | Investment criteria, created through onboarding conversation. | Supabase `deal_searches.buy_box` (JSONB) |
| **Scan** | A run of the agent across marketplaces. Produces deals. | Supabase `deal_searches` table |
| **Deal** | A property that survived buy box filtering. Can be starred. Can have its own conversation thread. | Supabase `deals` table |
| **Conversation** | A chat thread. Types: `buy_box_intake`, `scan_debrief`, `deal_qa`. | Supabase `conversations` table |

### Views

All views use the same three-panel layout. The panels adapt to context:

| View | Sidebar | Chat | Preview |
|------|---------|------|---------|
| **Onboarding** (new user, `buy_box_intake`) | Empty — no scans yet | Agent introduces itself, asks buy box questions | Collapsed (hidden) |
| **Scan Debrief** | Scan highlighted | Agent presents deals, discusses them, gives recommendations | Deal card list with star + "Open Thread" actions |
| **Deal Thread** | Deal highlighted under "Active Deals" | Focused conversation about that deal (persists over weeks) | Deal detail card with key metrics |
| **Just Chatting** (buy box edits, general Q&A) | Most recent item highlighted | Conversation | Collapsed (hidden) |

### User Flows

**New user:**
1. Email gate → enters dashboard
2. Agent introduces itself: "I'm Scout, your deal hunting agent. I'm going to learn exactly what you're looking for..."
3. Onboarding conversation (same Q&A flow as current `/chat/`)
4. Buy box saved → scan triggers → scan appears in sidebar
5. Scan completes → user clicks it → debrief conversation begins
6. User stars deals, opens threads on ones they want to pursue

**Returning user (new scan completed):**
1. Email recognized from localStorage → enters dashboard
2. Latest scan highlighted in sidebar
3. User clicks it → debrief conversation begins (or resumes if they already started it)
4. Continue working deals from previous scans via sidebar

**Returning user (no new scan):**
1. Enters dashboard → lands on most recent conversation (deal thread or scan debrief)
2. Continue where they left off, or click another thread in sidebar

## Layout Architecture

### Three Panels

```
┌─────────────┬──────────────────────────┬──────────────────┐
│  SIDEBAR    │         CHAT             │    PREVIEW       │
│  220px      │         flex: 1          │    300px         │
│  fixed      │         always present   │    collapsible   │
│  navigation │         primary action   │    contextual    │
└─────────────┴──────────────────────────┴──────────────────┘
```

- **Sidebar** (220px, fixed): Navigation only. Logo, "New Scan" button, Active Deals list, Scans list, Settings gear + email at bottom.
- **Chat** (flex: 1): The primary interaction surface. Always present. Conversation messages, input bar.
- **Preview** (300px, collapsible): Shows/hides based on context. Deal list during scan debrief, deal detail during deal thread. Slides in/out with animation. Close button on panel header.

### Sidebar Structure

```
[Logo + Agent Name]
[+ New Scan]
─────────────────
ACTIVE DEALS
  Cedar Ridge  HOT     ← green left border when selected
  Hillside B&B STRONG
─────────────────
SCANS
  Apr 22 Scan · 3 deals
  Apr 21 Scan · 2 deals
─────────────────
[Buy Box Setup]         ← onboarding conversation, always accessible
─────────────────
                        ← flex spacer
[⚙ Settings]  email@...
```

- **Active Deals**: Deals the user has opened threads for. Ordered by most recently active. Each shows name + tier badge.
- **Scans**: Scan history grouped by date. Each shows date + deal count.
- **Settings**: Gear icon opens settings panel (slides over sidebar). Contains: Help (support email, docs link), Billing (current plan, upgrade CTA), Notifications (daily digest toggle). Sign out at bottom.

### Preview Panel — Scan Debrief Context

When viewing a scan debrief, the preview shows the deal list:

```
┌─────────────────────────────┐
│ Apr 22 Scan · 3 Deals    ✕ │
├─────────────────────────────┤
│ ┌─────────────────────────┐ │
│ │ Cedar Ridge Glamping  ☆ │ │
│ │ HOT · $1.2M · 14ac · 8k│ │
│ │ Revenue day 1. Strongest│ │
│ │ Listing → | Open Thread→│ │
│ └─────────────────────────┘ │
│ ┌─────────────────────────┐ │
│ │ Hillside B&B          ☆ │ │
│ │ STRONG · $850K · 3.2ac  │ │
│ │ Turnkey. Low risk.      │ │
│ │ Listing → | Open Thread→│ │
│ └─────────────────────────┘ │
│ ┌─────────────────────────┐ │
│ │ Lakefront Retreat     ☆ │ │
│ │ STRONG · $675K · 8ac    │ │
│ │ Best price. Needs work. │ │
│ │ Listing → | Open Thread→│ │
│ └─────────────────────────┘ │
└─────────────────────────────┘
```

Each deal card shows: name, tier badge, key metrics (price, acreage, keys), agent one-liner, star button, listing link, "Open Thread" action.

### Preview Panel — Deal Thread Context

When viewing a deal thread, the preview shows the deal detail:

```
┌─────────────────────────────┐
│ Deal Detail               ✕ │
├─────────────────────────────┤
│ Cedar Ridge Glamping    HOT │
│ Hill Country, TX            │
│                             │
│ ┌──────────┬──────────────┐ │
│ │ Price    │ Acreage      │ │
│ │ $1.2M   │ 14 ac        │ │
│ ├──────────┼──────────────┤ │
│ │ Keys     │ Risk         │ │
│ │ 8        │ Moderate     │ │
│ └──────────┴──────────────┘ │
│                             │
│ Agent Assessment:           │
│ Revenue from day 1. 14ac   │
│ expansion optionality.     │
│ Seasonal concentration is  │
│ the primary risk.          │
│                             │
│ [View Original Listing →]   │
│ [☆ Starred]                 │
└─────────────────────────────┘
```

## Agent Personality

### Name Assignment

Each user is randomly assigned an agent name on first use from a curated roster:

**Scout, Nora, Kit, Stella, Sophie, Quinn, Wren, Ellis, Reid, Sloane, Harper, Hunter**

The name is stored in Supabase alongside the user's email and persists forever. It's used everywhere: message labels, onboarding intro, sidebar logo area. Names are NOT unique per-user — multiple users may share the same agent name. This is intentional: with 12 names, collisions are expected and fine. The name is a personality trait, not an identifier.

### Voice

The agent is a sharp deal analyst, not a chatbot. Direct, opinionated, specific to the user's buy box. No filler, no cheerleading.

**Onboarding intro example:**
> "I'm Scout, your deal hunting agent. I scan 30+ marketplaces daily and score every listing against your exact criteria — so you only see the ones worth your time. Let's set up your buy box. What asset class are you focused on?"

**Debrief example:**
> "Scanned 7 marketplaces overnight. 287 listings reviewed, 3 survived your buy box. Cedar Ridge is the standout — revenue from day 1, strong location, and the only HOT match. What do you want to dig into?"

**Deal analysis example:**
> "$210K gross on 8 keys is $26K/unit — solid. At $1.2M that's a 17.5% gross yield. With a motivated seller, I'd push for $1.05M based on the seasonal concentration risk."

## Tech Stack

| Layer | Choice | Rationale |
|-------|--------|-----------|
| **Frontend framework** | Preact (3KB) | Dashboard is a SPA with panel navigation, SSE streaming, conversation switching. Vanilla JS would require hand-rolled DOM diffing. Preact gives real components + state without framework weight. |
| **Existing pages** | Vanilla JS (unchanged) | `/chat/`, `/scan/`, `/results/` stay as-is. Only the dashboard uses Preact. |
| **Backend** | Vercel serverless functions (Node.js/CommonJS) | Matches existing stack. |
| **Database** | Supabase PostgreSQL | Matches existing stack. |
| **AI** | Anthropic Claude API (claude-sonnet-4-20250514) via SSE streaming | Matches existing stack. |
| **Styling** | CSS custom properties | Existing design system variables. All visual decisions are tokens. |
| **Fonts** | Cormorant Garamond (serif) + Outfit (sans) | Matches existing design. |

## Modular Component Architecture

Each visual piece is a self-contained Preact component. Upgrade one without touching the others.

### Sidebar Components
- `SidebarHeader` — Logo + agent name
- `NewScanButton` — Triggers onboarding or re-scan flow
- `ActiveDealsList` — Deals with open threads, tier badges
- `ScanList` — Scan history grouped by date
- `SidebarFooter` — Settings gear + user email

### Chat Components
- `MessageBubble` — User or assistant message (handles streaming text append)
- `DealCard` — Rich deal card rendered inline in chat (reused in preview)
- `BuyBoxCard` — Buy box confirmation after onboarding
- `TypingIndicator` — Three-dot animation during streaming
- `ChatInput` — Input bar + send button

### Preview Components
- `PreviewHeader` — Panel title + close button
- `DealList` — Scan context: scrollable deal cards with star + open thread
- `DealDetail` — Deal thread context: full detail card with metrics + assessment
- `SettingsPanel` — Slides over sidebar (Help, Billing, Notifications, Sign Out)

### Component Reuse
`DealCard` is used in BOTH chat (inline) and preview (list/detail). Change it once → updates everywhere. Same for `MessageBubble` which works identically in scan debrief and deal thread conversations.

## State Management

Single flat state object with smart re-rendering:

```javascript
const state = {
  // User
  email: null,
  agentName: null,           // "Scout", "Nora", etc.
  
  // Navigation
  view: 'onboarding',        // 'onboarding' | 'scan' | 'deal'
  activeThreadId: null,       // scan ID or deal ID
  
  // Data (from /api/user-data)
  scans: [],
  deals: [],                  // all deals across scans
  activeThreads: [],          // deals with open conversation threads
  starredDealIds: new Set(),
  
  // Conversation cache
  conversationCache: new Map(), // threadId → { messages, conversationId, lastAccessed }
  
  // Current chat
  chat: {
    messages: [],
    conversationId: null,
    streaming: false
  },
  
  // UI
  previewOpen: false,
  settingsOpen: false
};
```

### Conversation Caching

- `Map<threadId, { messages, conversationId, lastAccessed }>` in memory
- First access: fetch from `/api/conversation`, cache result
- Subsequent access: serve from cache
- Evict oldest entry when cache exceeds 8 conversations
- Active conversation is never evicted
- Cache is per-session only (no localStorage persistence for messages)

## Data Layer — API Contracts

### Auth Note (Phase 1)

Phase 1 uses email-only identification (matching the current codebase). There is no JWT or session token. This means API endpoints are not authenticated — anyone who knows an email can access that user's data. This is acceptable for MVP/beta testing but MUST be addressed before public launch. Phase 2 should add magic link auth with JWT per the product spec.

For now, all endpoints accept `email` as the user identifier and trust it.

### 1. `POST /api/chat` (extended)

Existing endpoint, extended with an optional `mode` parameter. **Backward compatible**: if `mode` is omitted, behaves exactly as today (buy box intake). The existing `/chat/` page continues to work without changes.

**Request:**
```json
{
  "email": "string",
  "mode": "buy_box_intake | scan_debrief (optional, defaults to buy_box_intake)",
  "search_id": "uuid (required when mode is scan_debrief)",
  "messages": [{ "role": "user | assistant", "content": "string" }],
  "conversation_id": "uuid | null"
}
```

**Response:** SSE stream
```
data: {"type":"text","text":"..."}\n\n
data: {"type":"conversation_id","id":"..."}\n\n
data: {"type":"buy_box_saved","search_id":"...","buy_box":{...}}\n\n
data: {"type":"done"}\n\n
data: {"type":"error","error":"..."}\n\n
```

**Behavior by mode:**
- `buy_box_intake` (default): Current behavior. System prompt asks buy box questions. Has `save_buy_box` tool. Conversation saved as `conversation_type: 'buy_box_intake'` (matches existing code).
- `scan_debrief`: Fetches deals for `search_id` from Supabase. Injects deal data + user's buy box into system prompt. Agent presents deals with opinions and recommendations. No tools. Conversation saved as `conversation_type: 'scan_debrief'`.

### 2. `POST /api/deal-chat` (new)

Deal thread conversations with deal context injected.

**Request:**
```json
{
  "email": "string",
  "deal": { "id", "title", "location", "price", "acreage", "rooms_keys", "score_breakdown", "source", "url" },
  "buy_box": { "locations", "price_max", "property_types", ... },
  "messages": [{ "role": "user | assistant", "content": "string" }],
  "conversation_id": "uuid | null"
}
```

**Response:** SSE stream (same format as `/api/chat`)

**Behavior:** Deal + buy box injected into system prompt. Agent is a deal analyst focused on this specific property. No tools. Conversation saved as `conversation_type: 'deal_qa'` with `deal_id`.

### 3. `GET /api/user-data?email={email}` (new)

Powers the sidebar and initial load.

**Response:**
```json
{
  "agent_name": "Scout",
  "scans": [
    { "id": "uuid", "buy_box": {...}, "status": "complete", "run_at": "ISO",
      "deal_count": 3, "conversation_id": "uuid | null" }
  ],
  "deals": [
    { "id": "uuid", "title": "string", "location": "string", "price": 1200000,
      "acreage": 14, "rooms_keys": 8, "score_breakdown": {...},
      "source": "string", "url": "string", "search_id": "uuid", "starred": true }
  ],
  "active_threads": [
    { "deal_id": "uuid", "conversation_id": "uuid" }
  ]
}
```

Note: `scans[].conversation_id` is populated by looking up conversations with `conversation_type: 'scan_debrief'` and matching `search_id`. This allows the frontend to resume an existing debrief without an extra API call. If null, the debrief hasn't started yet.
```

### 4. `GET /api/conversation?id={conversation_id}&email={email}` (new)

Load a conversation's message history for the cache. Requires `email` parameter to scope access — only returns conversations belonging to that user.

**Response:**
```json
{
  "id": "uuid",
  "conversation_type": "buy_box_intake | scan_debrief | deal_qa",
  "messages": [{ "role": "string", "content": "string", "timestamp": "ISO" }],
  "deal_id": "uuid | null",
  "search_id": "uuid | null"
}
```

Returns 404 if conversation doesn't exist or doesn't belong to the given email.
```

### 5. `POST /api/star-deal` (new)

Toggle star on a deal.

**Request:**
```json
{ "email": "string", "deal_id": "uuid", "starred": true }
```

**Response:**
```json
{ "ok": true }
```

## Database Changes

### New table: `users`

| Column | Type | Description |
|--------|------|-------------|
| email | text, primary key | User identifier |
| agent_name | text, not null | Randomly assigned from roster |
| created_at | timestamptz | |

Agent name is assigned on first interaction — the `/api/user-data` endpoint checks if the user exists; if not, creates them with a random name.

### New table: `user_deal_stars`

Stars are per-user, not per-deal (deals may appear in multiple users' scans).

| Column | Type | Description |
|--------|------|-------------|
| user_email | text, FK → users.email | |
| deal_id | uuid, FK → deals.id | |
| created_at | timestamptz | |
| PRIMARY KEY | (user_email, deal_id) | |

The `/api/user-data` endpoint joins this table to set the `starred` flag on each deal in the response. The `/api/star-deal` endpoint inserts/deletes from this table.

### Modified table: `conversations`

Add column:
- `search_id` (uuid, nullable) — links scan debrief conversations to their scan

Existing columns used:
- `deal_id` — links deal thread conversations to their deal
- `conversation_type` — 'onboarding' | 'scan_debrief' | 'deal_qa'

## Build Pipeline

The dashboard uses Preact with JSX, which requires a build step. Use **Vite** (lightweight, fast, native ESM).

**Setup:**
```
npm install preact vite @preact/preset-vite --save-dev
```

**`vite.config.js`** (project root):
```javascript
import { defineConfig } from 'vite';
import preact from '@preact/preset-vite';

export default defineConfig({
  plugins: [preact()],
  root: 'dashboard',
  build: {
    outDir: '../dashboard-dist',
    emptyOutDir: true
  }
});
```

**Development:** `npx vite` serves the dashboard with HMR at `localhost:5173`. API calls proxy to `npx vercel dev` running on port 3000 (add `server.proxy` in vite config).

**Production:** `npx vite build` outputs to `dashboard-dist/`. Vercel serves static files from this directory. Add a `vercel.json` rewrite so `/dashboard/*` routes to `dashboard-dist/index.html` for SPA routing.

**Vercel rewrite** (add to `vercel.json`):
```json
{
  "rewrites": [
    { "source": "/dashboard/(.*)", "destination": "/dashboard-dist/index.html" }
  ]
}
```

## Error & Loading States

| Scenario | Behavior |
|----------|----------|
| `/api/user-data` fails | Sidebar shows "Could not load your data. Try refreshing." Retry button. |
| Scan has zero deals | Debrief conversation: agent says "No deals matched your buy box this scan. Want to adjust your criteria?" Preview stays collapsed. |
| SSE connection drops mid-stream | Show last received text + "Connection lost. Tap to retry." message below. |
| Conversation cache fetch fails | Show "Couldn't load this conversation. Try again." in chat area. Don't evict from cache on failure. |
| User has no scans | Sidebar shows empty state under Scans: "No scans yet." Welcome view prompts onboarding. |
| `/api/star-deal` fails | Revert star toggle in UI, show brief toast: "Couldn't save. Try again." |

## File Map

| Action | Path | Responsibility |
|--------|------|----------------|
| Create | `dashboard/index.html` | Entry point — loads Preact app bundle |
| Create | `dashboard/src/app.js` | Root Preact component, state management, routing |
| Create | `dashboard/src/components/Sidebar.js` | Sidebar panel + all sub-components |
| Create | `dashboard/src/components/Chat.js` | Chat panel — messages, streaming, input |
| Create | `dashboard/src/components/Preview.js` | Preview panel — deal list + deal detail |
| Create | `dashboard/src/components/DealCard.js` | Reusable deal card (chat + preview) |
| Create | `dashboard/src/components/Settings.js` | Settings overlay panel |
| Create | `dashboard/src/lib/api.js` | API client — fetch wrappers, SSE streaming |
| Create | `dashboard/src/lib/state.js` | State management + conversation cache |
| Create | `dashboard/src/styles.css` | All CSS using existing design system variables |
| Create | `api/user-data.js` | GET — sidebar data |
| Create | `api/deal-chat.js` | POST — deal thread streaming |
| Create | `api/conversation.js` | GET — load conversation history |
| Create | `api/star-deal.js` | POST — toggle star |
| Modify | `api/chat.js` | Add `mode` param for scan_debrief support |
| Modify | `vercel.json` | Add function configs for new endpoints |
| Modify | `package.json` | Add Preact dependency |

## What's NOT in Phase 1

- Mobile optimization (sidebar collapse, responsive panels)
- Deal status pipeline (Active → Under Contract → Closed)
- Auto-captured notes from conversation
- Daily digest email notifications
- Stripe billing integration (upgrade button shows "coming soon")
- Real-time scan progress in dashboard (user goes to `/scan/` page for now)

## Phase 2 Hooks (Built For, Not Built)

The modular architecture makes these straightforward to add:

- **Deal status pipeline**: Add `status` field to deals, update `DealDetail` component
- **Auto-notes**: Add `DealNotes` component to preview panel, extract from conversation via API
- **Mobile**: Add responsive CSS + hamburger for sidebar, button for preview toggle
- **Real-time scan**: Add SSE listener in sidebar that updates scan status live
- **Framework migration**: Each Preact component maps 1:1 to React. Drop-in replacement.
