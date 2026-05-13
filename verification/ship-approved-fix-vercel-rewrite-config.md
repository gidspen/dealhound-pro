## Intent
Removes four path-param rewrites from vercel.json (`/api/buy-box/:id` and its action variants) that caused the PR #58 production deployment to error. Vercel rejects rewrites that use `:param` substitution in query-string destinations during its routing-setup phase — the build succeeds but the deploy fails. The buy-box API accepts query params directly, so these convenience rewrites are unnecessary. Removing them unblocks the production deploy.

## Files changed
- `vercel.json` — removed 4 path-param buy-box rewrites that triggered Vercel deployment error

## Confirmation
No files outside the intended scope were modified.
