# Run A — Foundation Slice Implementation Plan

## Scope
Ship `/sba` route in the Preact dashboard SPA with 20 mock TX dental practice leads scored 0–100 (HOT/STRONG/WATCH) with signal stacks and drafted outreach. No real scrapers.

## File-by-file change list

### Config / Infrastructure
| File | Change | Why |
|---|---|---|
| `vercel.json` | Add `/sba` and `/sba/(.*)` rewrites → `/dashboard-dist/index.html` + function entries for new API routes | Route SBA traffic to the SPA |
| `eslint.config.js` | Add new CJS files (`api/_lib/sba-scoring.js`, `api/_lib/sba-outreach.js`, `api/sba-*.js`) to CJS files list | Prevent lint errors from CJS `require` in new files |
| `supabase/migrations/20260509_sba_tables.sql` | Create `sba_scans` + `sba_leads` tables per SBA_BUILD_DECISIONS.md | Schema for SBA data persistence |

### Backend (API)
| File | Change | Why |
|---|---|---|
| `api/_lib/sba-scoring.js` | Pure scoring function: 13 signals, weighted sum 0–100, tier assignment. CJS. | Core scoring engine |
| `api/_lib/sba-outreach.js` | Outreach generator calling Anthropic Sonnet with tone guardrails. CJS. | Draft outreach per lead |
| `api/_lib/sba-outreach.prompt.txt` | System prompt template for outreach (succession-not-sale tone). | Editable without redeploy |
| `api/sba-scan-start.js` | POST — creates sba_scans row, returns scan_id. No paywall. | Mirror scan-start.js for SBA |
| `api/sba-leads.js` | GET — returns leads for a user/scan. Falls back to mock fixture if table empty. | Lead data endpoint |
| `api/sba-deal-chat.js` | POST — Q&A on a specific SBA lead, streaming. | Mirror deal-chat.js for SBA |

### Frontend
| File | Change | Why |
|---|---|---|
| `dashboard/src/lib/state.js` | Add `product` signal (default 'realestate'), `sbaLeads` signal, `sbaScans` signal, `activeSbaLeadId` signal, SBA computed signals | Product-level state branching |
| `dashboard/src/lib/api.js` | Add `loadSbaData()`, `submitSbaBuyBox()`, `fetchSbaLeads()` functions | SBA API integration |
| `dashboard/src/app.jsx` | Detect `/sba` URL → set product='sba'. Branch `routeAfterLoad` for SBA. Add SBA component imports. | Route SBA users to SBA views |
| `dashboard/src/components/SbaBuyBox.jsx` | New: SBA buy box form (vertical/state/city/lead count) | SBA onboarding entry point |
| `dashboard/src/components/SbaLeadCard.jsx` | New: Lead card with retirement_score badge, tier color, signal count | SBA lead list item |
| `dashboard/src/components/SbaLeadDetail.jsx` | New: Full lead detail with signal stack, outreach draft, contact info | SBA lead detail panel |
| `dashboard/src/components/Sidebar.jsx` | Branch on `product.value === 'sba'` for SBA sidebar (leads grouped by tier) | SBA sidebar mode |
| `dashboard/src/components/Chat.jsx` | Branch on `product.value === 'sba'` for SBA chat (lead Q&A) | SBA chat mode |
| `dashboard/src/components/Preview.jsx` | Branch on `product.value === 'sba'` for SBA preview panel | SBA preview mode |
| `dashboard/src/styles.css` | Add SBA tier colors (red/orange/yellow), signal stack styles, outreach card styles | SBA visual treatment |

### Scripts / Tests
| File | Change | Why |
|---|---|---|
| `scripts/sba-mock-data.js` | Generate 20 mock TX dental leads with realistic signals across tiers. Can insert into Supabase or write to JSON. | Mock data for Run A verification |
| `tests/unit/sba-scoring.test.js` | 5 cases: HOT (score 85), STRONG (score 68), WATCH (score 45), DISCARD (score 25), edge (score exactly 80) | Scoring engine validation |

### Docs
| File | Change | Why |
|---|---|---|
| `docs/RUN_A_PLAN.md` | This file | Build plan |
| `docs/RUN_A_CHECKPOINT.md` | Phase checkpoints | Progress tracking |

## Order of operations
1. Config: vercel.json + eslint.config.js + migration SQL
2. Backend: scoring engine → outreach generator → API routes
3. Frontend: state/api → components → integration
4. Mock data: fixture generation
5. Verification: dev server + screenshot + tests
6. Ship: commit + push + PR

## Risks
1. **Supabase migration**: MCP tool may not be available. Fallback: write .sql file, document for manual apply. API falls back to mock fixture.
2. **Pre-push hook**: typecheck + integration tests must pass. New CJS files need ESLint CJS config.
3. **Frontend complexity**: Branching on product signal in 3+ components risks merge conflicts with main. Mitigated by keeping SBA code in new components where possible.
4. **Mock data realism**: Needs convincing signal stacks to verify scoring engine. Will hand-craft 5 archetypal leads and generate 15 variants.

## Sub-agent spawn plan
- Wave 1 (6 parallel): scoring engine, outreach prompt, vercel rewrites, migration, ESLint, mock fixture
- Wave 2 (3 parallel): 3 API routes
- Wave 3 (3 parallel): state/api, SBA components, sidebar/chat/preview integration
- Wave 4 (1): CSS styles
- Wave 5 (1): verification
- Estimated: ~14 sub-agent spawns
