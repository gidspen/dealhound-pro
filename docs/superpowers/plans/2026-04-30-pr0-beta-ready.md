# PR 0 — Beta-Ready for Group Demo Today

**Goal:** Make the existing product solid and honest about being in beta so Gideon can give it to a group of beta testers TODAY for feedback. No payments, no new auth, no major features. Just hide the fake stuff, add a feedback channel, hand off the worker to the Mac mini, and smoke-test the live site.

**Branch:** new branch `pr0-beta-ready` off `main` (not `mvp-launch-paywall` — that branch holds PR 1-3 work).

**Time estimate:** 45-60 min CC + Gideon's manual Mac mini handoff in parallel.

---

## What's in scope

- Replace `alert('Upgrade coming soon!')` in `Settings.jsx` with honest beta copy
- Add "Send feedback" mailto link in Settings
- Verify beta badge is visible enough that users know it's beta
- Quick smoke test of the full flow on the live deployment, fix obvious bugs
- Mac mini handoff (Gideon's manual step, runs in parallel)

## What's NOT in scope (explicitly deferred)

- Stripe / payments / paywall — that's PR 1
- Magic-link auth — PR 2
- HOT/STRONG threshold metering — PR 2
- Token budgets — PR 2
- PostHog analytics, usage indicator, polish animations — PR 3

---

## Tasks

### Task 1: Branch off main

- [ ] Switch back to main and pull latest

```bash
git checkout main
git pull
git checkout -b pr0-beta-ready
git branch --show-current
```

Expected: `pr0-beta-ready`

### Task 2: Replace the fake "Upgrade to Pro" with honest beta copy

**File:** `dashboard/src/components/Settings.jsx`

Currently lines 41-47 render:

```jsx
<div class="settings-section">
  <div class="settings-section-title">Billing</div>
  <div class="settings-plan">Current plan: <strong>Free</strong></div>
  <button class="settings-upgrade-btn" onClick={() => alert('Upgrade coming soon! Email support@dealhound.pro for early access.')}>
    Upgrade to Pro — $29/mo
  </button>
</div>
```

Replace with:

```jsx
<div class="settings-section">
  <div class="settings-section-title">Account</div>
  <div class="settings-plan">Status: <strong>Beta access</strong></div>
  <div class="settings-plan-meta">Unlimited free use during preview. Payments coming soon.</div>
</div>
```

Plus add this CSS to `dashboard/src/styles.css` if `.settings-plan-meta` isn't already there:

```css
.settings-plan-meta {
  font-size: 12px;
  color: var(--cream-dim);
  margin: 4px 0 0;
}
```

(This style block is already speced in PR 1 — including it now is harmless and saves a churn later.)

### Task 3: Add Send Feedback link in Settings Help section

**File:** `dashboard/src/components/Settings.jsx`

Currently lines 35-39 render:

```jsx
<div class="settings-section">
  <div class="settings-section-title">Help</div>
  <a href="mailto:support@dealhound.pro" class="settings-link">Contact Support →</a>
  <a href="https://dealhound.pro" target="_blank" class="settings-link">Documentation →</a>
</div>
```

Replace with:

```jsx
<div class="settings-section">
  <div class="settings-section-title">Help</div>
  <a
    href={`mailto:gideon@stonemontcap.com?subject=${encodeURIComponent('Deal Hound feedback')}&body=${encodeURIComponent('What worked? What didn\'t? What surprised you?\n\n')}`}
    class="settings-link"
  >
    Send feedback →
  </a>
  <a href="mailto:support@dealhound.pro" class="settings-link">Contact support →</a>
</div>
```

Reasoning: the prior "Documentation →" link routed to the marketing site which doesn't have docs yet (would confuse beta users). Replaced with feedback. Email goes to Gideon directly so he sees it without a forwarding hop.

### Task 4: Verify beta badge is visible

**File:** `dashboard/src/components/Sidebar.jsx`

Check around line 182 — beta badge should already render next to the "Deal Hound" logo text:

```jsx
<span class="sidebar-logo-text">Deal Hound</span><span class="beta-badge">beta</span>
```

Verify it's there and styled. If `.beta-badge` doesn't exist in styles.css, add:

```css
.beta-badge {
  display: inline-block;
  background: var(--gold-dim);
  color: var(--gold);
  font-size: 10px;
  font-weight: 500;
  padding: 2px 6px;
  border-radius: 3px;
  margin-left: 6px;
  letter-spacing: 0.04em;
  text-transform: uppercase;
  vertical-align: middle;
}
```

(Quick visual check on local dev — should be a subtle gold pill next to logo.)

### Task 5: Build verify

- [ ] Run the build to make sure nothing broke

```bash
npm run build
```

Expected: build succeeds, dashboard-dist updated.

### Task 6: Smoke test against the live deployment

After deploying (Task 8), walk through the full flow as a NEW user:

- [ ] Open dealhound.pro in an incognito window
- [ ] See landing page, click "Get started"
- [ ] Land at email gate, enter a fresh email (`gideon+beta1@stonemontcap.com`)
- [ ] Click submit → should land in dashboard
- [ ] If this is a brand-new email with no pool match: should land in onboarding chat with Scout/agent
- [ ] If pool match exists: should skip to deal view
- [ ] Try the buy box conversational onboarding: tell agent location, price, type
- [ ] Confirm buy box → should kick off scan or show pool deals
- [ ] Click into a deal → should see brief + chat → ask agent a question
- [ ] Open Settings → should see "Beta access" status, "Send feedback" link, no fake Upgrade button
- [ ] Click "Send feedback" → email client opens with prefilled subject + body
- [ ] Toggle daily digest in Settings → should persist (currently localStorage-only, that's OK for PR 0)
- [ ] Sign out → should return to email gate
- [ ] Sign back in with same email → should restore deals + state

If any step breaks: capture the bug, fix it before sharing with the group.

### Task 7: Commit + ship

- [ ] Commit the changes

```bash
git add dashboard/src/components/Settings.jsx dashboard/src/styles.css
git commit -m "$(cat <<'EOF'
feat(beta): hide fake upgrade button, add send feedback link

PR 0 of MVP rollout. Removes the placeholder 'Upgrade to Pro' alert
that promised something we don't have yet. Replaces with honest 'Beta
access' status. Adds Send Feedback mailto link routed direct to Gideon
so beta users have a frictionless feedback channel.

No new functionality. Mac mini takes over scrape worker duties out of
band.

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>
EOF
)"
```

### Task 8: Push and deploy

- [ ] Push branch and open PR

```bash
git push -u origin pr0-beta-ready
gh pr create --title "feat(beta): hide fake upgrade, add feedback channel — PR 0" --body "$(cat <<'EOF'
## Summary
- Replace fake 'Upgrade coming soon' alert with honest 'Beta access' status
- Add 'Send feedback' mailto link → gideon@stonemontcap.com
- Beta badge already in sidebar; verified styling

## Why this PR
Gideon is demoing to a group today. Existing product works; just needs
honesty about beta state and a feedback channel before sharing.

## Out of scope
- Payments (PR 1)
- Magic-link auth (PR 2)
- Polish (PR 3)

## Test plan
- [ ] Live smoke test as new user
- [ ] Send Feedback link opens email client correctly
- [ ] No 'Upgrade' button visible
- [ ] Beta badge visible in sidebar

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

- [ ] Merge PR after smoke test passes
- [ ] Vercel auto-deploys main → live site updates within ~60s
- [ ] Re-run smoke test on the live URL once deploy completes

---

## Mac Mini Handoff (Gideon's manual steps, parallel to my work)

The dealhound heartbeat agent at `~/.claude/agents/dealhound/` polls `scrape_jobs` and runs scrapes via the `/find-deals` skill. It currently runs on Gideon's laptop. For paying customers (PR 1+) this needs to move to the always-on Mac mini.

For the BETA group today: it's OK if the worker is still on the laptop, but moving to Mac mini before sharing reduces the chance of the laptop sleeping during a demo.

### Steps

1. **Sit at the Mac mini.** Verify Wi-Fi + power.
2. **Disable sleep:**
   - System Settings → Battery → Prevent automatic sleep when display is off: ON
   - Energy Saver / Schedule → uncheck "Sleep" or set to "Never"
3. **Install Claude Code if not already:** https://docs.claude.com/en/docs/claude-code/setup
4. **Sync agent files from laptop to Mac mini:**

   ```bash
   # On laptop
   rsync -avz ~/.claude/agents/dealhound/ <mac-mini-hostname>:~/.claude/agents/dealhound/
   ```

   Or scp / iCloud / manual copy.

5. **Copy environment variables.** The agent needs `SUPABASE_URL` and `SUPABASE_SERVICE_KEY`. These are likely in `~/.claude/.env` or in your shell profile on the laptop. Copy to Mac mini.

6. **Verify the agent starts:** Open Claude Code on Mac mini, trigger the dealhound agent loop. It should poll `scrape_jobs` table and update `~/.claude/agents/dealhound/heartbeat.md`.

7. **Test:** From the dashboard on a new user account, run a scan that requires fresh scrape (use a buy box that doesn't match the pool). Watch the heartbeat file on the Mac mini update. Confirm scan completes.

8. **Stop the laptop agent.** You don't want both running — they'll race on the same `scrape_jobs` rows.

If any step fails: roll back to laptop-only for now, ship PR 0 anyway, schedule Mac mini setup for tomorrow.

---

## Risks & Mitigations

| Risk | Mitigation |
|---|---|
| Smoke test reveals a regression | Fix in same PR before merging. If unfixable in <30 min, ship PR 0 without that flow and document the broken path |
| Mac mini Wi-Fi drops during demo | Keep laptop ready as backup worker; can re-enable agent in <2 min |
| Beta user is confused by lack of payment | "Beta access" + "Payments coming soon" copy addresses this; feedback link gives them a channel |
| Beta user sends feedback to wrong email | gideon@stonemontcap.com is your direct inbox — no forwarding loss |

---

## Definition of done

- [ ] PR merged to main
- [ ] Live site reflects changes (incognito test)
- [ ] No "Upgrade to Pro" button visible
- [ ] Send feedback link works
- [ ] Beta badge visible in sidebar
- [ ] Mac mini running scrape worker (or laptop confirmed reliable for the demo window)
- [ ] Gideon has shared the link with the group
