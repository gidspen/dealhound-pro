# Ship Approval — worker-hang-fix

## Intent

Fix the pre-existing worker hang documented in the merged PR #64 ("worker spawns Claude PTY → Claude TUI starts but never makes progress → 90-min timeout fires, in-memory state never released"). Two stacked root causes diagnosed and fixed:

1. **Browser profile lock conflict.** The user-scope playwright MCP holds a lock on `~/.dealhound-chrome-profile`. When the worker-spawned Claude tried to launch the same profile while an interactive Claude session had it open, Playwright errored `"Browser is already in use for /Users/gideonspencer/.dealhound-chrome-profile"` and the find-deals skill silently retried forever. Fix: worker spawns Claude with `--mcp-config worker/mcp-config.json --strict-mcp-config`, pointing playwright at a separate profile `~/.dealhound-worker-chrome-profile`.

2. **Cold-profile Crexi nav hang.** Even with profile isolation, the worker's fresh profile has no Cloudflare trust signals. Crexi's anti-bot serves a never-ending JS challenge to detail-page visits and `page.goto(..., timeout=12000)` failed to raise `PlaywrightTimeout` — `enrich_with_descriptions` blocked silently until the worker's 90-min timeout. Fix: `enrich_with_descriptions` in `~/skills/find-deals/scrapers/scraper.py` now enforces three concurrent bail-outs (wall-time 240s, max consecutive failures 5, per-page timeout 8s).

Verified live: my e2e job `c756c963` (search `209907f8`, recipient `gideon+dh-e2e-worker-fix-1778906297153@stonemontcap.com`) completed in **7.8 min** (was: 90+ min hang), scraper scraped **259 LandSearch listings**, worker called email-sender successfully (Resend messageId `bb5f2f02-545b-479c-9705-0b891cba665a`), email arrived in inbox with magic link, magic link 302 → `/dashboard?email=...&scan_id=209907f8...&from=magic` → HTTP 200 dashboard load. End-to-end target outcome — "user enters buy box → receives email when scan complete → email link opens dashboard" — proven through the real worker pipeline for the first time.

## Files changed

- `worker/mcp-config.json` — NEW. Project-scope MCP definition with playwright server pointing at `~/.dealhound-worker-chrome-profile` (instead of user-scope `~/.dealhound-chrome-profile`). Solves the profile-lock contention.
- `worker/pty-runner.js` — Updated `pty.spawn(claudeBin, [...])` argv to include `--mcp-config <abs path> --strict-mcp-config`. Block comment documents the audit and the alternative paths considered.
- `docs/SKILLS_CHANGELOG.md` — New entry "2026-05-16 — Crexi enrichment bail-out + worker browser-profile isolation" describing the scraper-side changes (which live at `~/skills/find-deals/scrapers/scraper.py`, outside this repo).

## Confirmation

No files outside the intended scope were modified.

## Open follow-up (separate ticket)

The skill's Claude session sometimes gets confused by the scraper's exit-1 paths from the old code, skipping Phase 3 (pipeline.py persist + scoring). This results in scraper writing JSON files but no rows landing in `deals`. Fix should update the skill's orchestration prompts to be more resilient to scraper exit codes / partial outputs. Out of scope for this branch — the target outcome (email → magic link → dashboard) is proven; deal population is a content-quality issue separate from the worker-hang fix.
