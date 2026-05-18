# Ship Approval — feat/rls-migration-and-offmarket-script

**Branch:** feat/rls-migration-and-offmarket-script
**Approved:** 2026-05-17

## Changes
- `scripts/migrations/2026-05-17-rls-deals-and-searches.sql` — enables RLS on deal_searches and deals tables
- `offmarket/build_foundation_repair_targets.py` — foundation repair target builder script
- `docs/superpowers/plans/2026-05-17-scraper-location-slug-and-keyword-expansion.md` — implementation plan

## Verification
- Migration reviewed: restricts anon key, service role retains full access
- No application code changed
- Plan doc is non-executable
