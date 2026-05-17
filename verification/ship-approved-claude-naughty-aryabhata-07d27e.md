## Intent

This branch gates the Deal Hound homepage behind a waitlist. All "Get My First Free Scan" CTAs have been replaced with email capture forms that submit to a new `/api/waitlist` endpoint, which subscribes the email to the "Deal Hunter Early Access" tag in Kit (ConvertKit). Internal testing bypass: if `KIT_PREVIEW_DOMAINS` is set in Vercel env, emails from those domains skip the waitlist confirmation and redirect to `/dashboard` instead.

## Files changed

- `index.html` — Replace 5 CTA buttons + nav button with waitlist email forms; add `submitWaitlist()` JS; update hero disclaimer to "Coming soon"
- `api/waitlist.js` — New Vercel serverless function: validates email, calls Kit via `addToKitNurture`, returns redirect signal for preview domains
- `scripts/migrations/2026-05-17-waitlist.sql` — New Supabase `waitlist` table with RLS (optional backup store, Kit is primary)
- `vercel.json` — Register `api/waitlist.js` as a serverless function with 10s timeout

## Confirmation

No files outside the intended scope were modified.
