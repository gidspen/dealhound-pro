## Intent

Fix buy box not being auto-saved when users run a search. Two bugs: (1) `api/chat.js` called `saveBuyBox()` without first ensuring a `users` row existed, causing a silent FK violation that left `buy_boxes` empty and `buy_box_id` null on deal_searches. (2) `api/free-scan-start.js` inserted buy_boxes with `status='draft'`, making them invisible to the scheduler which queries `WHERE status='active'`. Together these meant most users never got recurring scans.

## Files changed

- `api/chat.js` — upsert users row before calling saveBuyBox() so the FK constraint doesn't fail for new users
- `api/free-scan-start.js` — change status from 'draft' to 'active' so the buy-box-scheduler picks up free-scan users for recurring scans
- `tests/integration/free-scan-buy-box.test.js` — update assertion and descriptions to expect 'active' instead of 'draft' to match the corrected behavior

## Confirmation

No files outside the intended scope were modified.
