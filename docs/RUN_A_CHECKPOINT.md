# Run A — Checkpoints

## ORIENT (Phase 1)
**Status**: Complete
**What was found**:
- Dashboard is a Preact SPA with signal-based view routing (`view` signal in state.js)
- No URL router — all routing via signals. Views: 'gate', 'onboarding', 'scan', 'deal'
- API routes use CJS (`require`/`module.exports`), dashboard uses ESM
- No `supabase/migrations/` directory exists — need to create it
- Pre-push hook runs `tsc --noEmit` (api/ only, checkJs:false) + `vitest run tests/integration`
- ESLint flat config has explicit CJS file lists — new API files must be added

**Turn count**: ~5
**Sub-agent spawns**: 0

---

## BUILD (Phase 3)
**Status**: Complete
**What was done**:
- Wave 1 (6 parallel sub-agents): scoring engine, outreach generator+prompt, vercel rewrites, migration SQL, ESLint config, unit tests
- Wave 2 (4 parallel): sba-scan-start API, sba-leads API, sba-deal-chat API, mock data fixture (20 leads)
- Wave 3 (4 parallel): state+api signals, 3 new SBA components, app/sidebar/chat/preview integration, CSS styles
- Wave 3b (1): dev-mode mock data fallback (static JSON + query param support)
- Bug fix (1): URL constructor crash in SbaLeadDetail

**Turn count through BUILD**: ~15
**Sub-agent spawns**: 16

---

## VERIFY (Phase 4)
**Status**: Complete
**Results**:
- Vite build: PASS (22 modules, 80ms)
- SBA scoring unit tests: 5/5 PASS
- Integration tests: 78/78 PASS (no regressions)
- TypeScript typecheck: PASS (0 errors)
- ESLint: 0 errors, 42 warnings (all no-unused-vars — pre-existing + expected)
- Dev server: starts on :5173, HTTP 200
- Screenshot: `verification/run-a-screenshot.png` — shows 3-panel SBA dashboard:
  - Sidebar: 20 leads grouped HOT(5)/STRONG(7)/WATCH(6), DISCARD(2) hidden
  - Detail panel: Panhandle Dental Group, score 95/100, 10/13 signals fired, signal stack visible
  - Chat: context banner "Discussing: Panhandle Dental Group (HOT)"

**Turn count through VERIFY**: ~20
**Sub-agent spawns through VERIFY**: 19

---

## FINAL (Phase 5)

### What was done — file list
| File | Type | Description |
|---|---|---|
| `vercel.json` | EDIT | Added /sba rewrites + 3 SBA function entries |
| `eslint.config.js` | EDIT | Added sba-scoring.js + sba-outreach.js to CJS list |
| `supabase/migrations/20260509000000_sba_tables.sql` | NEW | sba_scans + sba_leads tables with indexes |
| `api/_lib/sba-scoring.js` | NEW | 13-signal scoring engine, pure function, tier assignment |
| `api/_lib/sba-outreach.js` | NEW | Outreach generator via Anthropic Sonnet, fallback for no API key |
| `api/_lib/sba-outreach.prompt.txt` | NEW | System prompt with succession-not-sale guardrails |
| `api/sba-scan-start.js` | NEW | POST — create sba_scans row, no paywall |
| `api/sba-leads.js` | NEW | GET — return leads, mock fixture fallback |
| `api/sba-deal-chat.js` | NEW | POST — streaming lead Q&A via Anthropic |
| `dashboard/src/lib/state.js` | EDIT | product signal, sbaLeads, sbaScans, activeSbaLeadId, computed signals |
| `dashboard/src/lib/api.js` | EDIT | loadSbaData() with mock fallback, submitSbaBuyBox() |
| `dashboard/src/app.jsx` | EDIT | /sba + ?product=sba detection, SBA routing, SbaBuyBox render |
| `dashboard/src/components/SbaBuyBox.jsx` | NEW | Buy box form (vertical/state/city/count) |
| `dashboard/src/components/SbaLeadCard.jsx` | NEW | Compact lead card with score bar + tier badge |
| `dashboard/src/components/SbaLeadDetail.jsx` | NEW | Full detail: score, signal stack, outreach, contact |
| `dashboard/src/components/Sidebar.jsx` | EDIT | SBA mode with tier-grouped lead list |
| `dashboard/src/components/Chat.jsx` | EDIT | SBA context banner, /api/sba-deal-chat endpoint |
| `dashboard/src/components/Preview.jsx` | EDIT | SbaLeadDetail render for sba-lead view |
| `dashboard/src/styles.css` | EDIT | +230 lines SBA styles (tier colors, buy box, signal stack, outreach) |
| `scripts/sba-mock-data.js` | NEW | Insert 20 mock leads into Supabase (or JSON fallback) |
| `tests/unit/sba-scoring.test.js` | NEW | 5 test cases (HOT/STRONG/WATCH/DISCARD/edge) |
| `tests/fixtures/sba-mock-leads.json` | NEW | 20 mock TX dental leads with realistic signals |
| `dashboard/public/sba-mock-leads.json` | NEW | Static copy for dev-mode fallback |
| `docs/RUN_A_PLAN.md` | NEW | Implementation plan |
| `docs/RUN_A_CHECKPOINT.md` | NEW | This file |

### What was NOT done and why
1. **Supabase migration not applied** — wrote the .sql file but did not run `apply_migration` via MCP. User must apply manually or via `supabase db push`.
2. **Outreach not generated via API** — mock data includes pre-written outreach strings. Real outreach generation (via Anthropic Sonnet) is wired in `sba-outreach.js` but untested end-to-end (requires ANTHROPIC_API_KEY at runtime).
3. **CSV export** — deferred to Run C per spec.
4. **Lead status updates** — deferred to Run C per spec.
5. **LinkedIn signals (25 pts)** — correctly marked as pending in scoring engine and mock data.

### Verification artifacts
- `verification/run-a-screenshot.png` — 3-panel SBA dashboard with 20 scored leads
- Unit tests: 5/5 pass
- Integration tests: 78/78 pass
- Build + typecheck: clean

### Ambiguous items needing human judgment
- None — spec was unambiguous for Run A scope.

### Budget
- Turn count: ~22 of 60 budget
- Sub-agent spawns: 20
- Direct Opus work: 6 (diagnostic reads, plan writing, checkpoint writing)

### What's NEXT (Run B)
- TX Dental Board scraper → real license data
- TX SOS scraper → business registration
- Google Places → reviews, website analysis
- Practice website scraper → owner contact info
- Wire to scoring engine → persist to Supabase
- Verify against 50 real TX practices

### Known gaps for Run B
- LinkedIn signals = 25 pts unscored (need Apollo.io $79/mo for real data)
- Owner enrichment = free path only (scrape website contact page)
- Google Places API key needs verification
