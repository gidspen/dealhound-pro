"""RV Parks & Campgrounds — TX off-market lead pipeline (POC).

Vertical: under-managed RV parks and campgrounds in TX, scored for
(a) owner motivation to sell and (b) conversion fitness for repositioning
to micro-resort/glamping.

POC scope:
- Directory-first spine (KOA + ARVC + Good Sam + RV Park Reviews + Google Places)
- Optional CAD enrichment for Dallas + Bexar (existing scrapers)
- 5 motivation signals + 6 conversion-fitness signals
- Lead JSON output + static HTML preview

Production wiring (post-POC):
- Hook into offmarket/scoring_rules.py result schema
- Persist to Supabase rv_park_leads table
- Surface in /offmarket dashboard route
"""
