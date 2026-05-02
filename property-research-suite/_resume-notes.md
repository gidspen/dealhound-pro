# Resume Notes — Property Research Suite Capture

_Written: 2026-04-26 during paused capture session._
_To resume: just say "resume the CoStar skill capture" in any future Cowork session and Claude will read this file._

## Where we are in the capture

We're in the middle of executing the **property pipeline** manually so the
skills can be filled in with real CoStar UI details. Captured so far:

- ✅ `costar-login` — fully captured. Login URL, session caching behavior,
  2FA trigger (fires on Properties click, not initial login if cached),
  2FA page structure on `secure.costargroup.com/mfa/otp/verify`,
  "Enter code" textbox + "Verify" button + resend link, code expiration
  behavior, and the chrome-extension permission limitation on the 2FA
  subdomain. 1Password CLI fetch pattern wired in.
- ✅ `costar-property-report` Steps 1–3 — search page UI captured (URL,
  "Address or Location" textbox, autocomplete behavior, Enter-to-search
  pattern, the nearby-properties list result, the toolbar with
  Reports button, the property type sub-tabs).
- 🟡 `costar-property-report` Step 4+ — **paused here**. We had reached
  the property list ("47 Properties / 3 Spaces" near Lafayette Ave in
  Saint Louis, MO). Next step was to click the specific property card
  matching the searched address, opening the property **detail panel on
  the right side** of the screen.

## Address being researched at pause

Gideon was searching for a property in or near Lafayette Ave, Saint Louis, MO 63104.
Map was zoomed to coordinates ~38.61346, -90.216365. Result list contained
47 properties / 3 spaces. (We didn't capture the exact address Gideon
typed — re-confirm at resume.)

## What's still TBD when we resume

In `costar-property-report/SKILL.md`:
- Step 4 — what the property detail panel looks like; which sections
  matter (overview, sale history, comps, tenant, photos, financials);
  how to navigate between detail sections; how to scroll/expand sections.
- Step 5 — the Reports button flow: which report type to choose, format
  options (PDF? Excel?), default filename CoStar assigns, where the file
  downloads to, how long it takes.
- The screenshot capture pattern: which sections of the property page to
  always grab.

In `email-research-report/SKILL.md`:
- Step 3 — which email tool/connector to use (Gmail MCP? Outlook?
  compose-as-draft?), default behavior (send vs draft).

In `archive-property-docs/SKILL.md`:
- Verification that the actual file movement/folder creation flow works
  as designed when wired up to a real CoStar download.

In `costar-login/SKILL.md`:
- The fresh-login 2FA UI (next session's first login should re-trigger
  this since the browser MCP session resets — capture the page state
  thoroughly).

In `costar-market-report/SKILL.md`:
- Everything — we never started market-pipeline capture. Where market
  reports live in the CoStar UI, how to specify the market/filter, what
  the export flow looks like.

In `archive-market-report/SKILL.md`:
- Same — confirm the file movement flow when wired to a real market
  report download.

## How to resume

1. Open Cowork. Say "resume the CoStar skill capture" or similar.
2. Claude will read this file and the relevant SKILL.md files to load context.
3. Open Claude in Chrome, create a fresh tab, navigate to
   `https://product.costar.com`. Expect login + 2FA — capture the fresh
   login UI thoroughly this time.
4. Pick up from Step 4 of `costar-property-report`: click the property
   card that matches the target address.
5. Continue narrating clicks per the protocol established earlier:
   "moved" at each transition, narrate WHY for non-obvious choices.

## Tasks still pending (TaskList state at pause)

- #2 ✅ Capture Step 1 — CoStar login (with WhatsApp 2FA hand-off)
- #3 🟡 Capture Step 2 — Property report download + screenshots ← IN PROGRESS, paused mid-flow
- #4 ⏳ Capture Step 3 — Email recipient with attachments + brief message
- #5 ⏳ Capture Step 4 — Archive docs to reference folder
- #16 ⏳ One-time 1Password CLI setup for CoStar credentials

The market pipeline (`costar-market-report`, `archive-market-report`,
`market-research-orchestrator`) is fully scaffolded but not yet
field-tested against the real CoStar UI.

## Sanity check on resume

Before continuing, the resuming Claude should:
1. Read this file end to end.
2. Read `costar-login/SKILL.md` and `costar-property-report/SKILL.md` to
   refresh on what's already captured.
3. Confirm with Gideon: "Resuming from clicking the property detail card.
   Same workflow, different address, or different goal entirely?"
4. Then proceed.
