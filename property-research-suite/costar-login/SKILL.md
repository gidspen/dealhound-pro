---
name: costar-login
description: >
  Logs into CoStar (costar.com) on Gideon's behalf, handling the SMS 2FA code
  by pausing the workflow and asking Gideon to forward the code from his phone
  to Sophia's WhatsApp. Use this skill whenever Sophia needs an authenticated
  CoStar session — including before pulling a property report, comp set, or
  any other CoStar lookup. Trigger phrases include "log into CoStar", "open
  CoStar", "get me into CoStar", "start a CoStar session", or any task that
  begins with needing CoStar data on a property.
---

# CoStar Login

You're logging into CoStar so a downstream skill (usually `costar-property-report`)
can pull data. The login uses SMS 2FA — Gideon receives the code on his phone,
he forwards it to Sophia's WhatsApp, and you paste it into the CoStar prompt.

## Config

```
COSTAR_LOGIN_URL = <fill in during first run>
1PASSWORD_ITEM_NAME = "CoStar"   ← the 1Password item that holds username + password
SOPHIA_WHATSAPP_NUMBER = <fill in>
```

Credentials live in Gideon's 1Password vault under an item named `CoStar`
with `username` and `password` fields. They are never stored anywhere in
this skill or the property-research-suite folder — Sophia fetches them at
runtime via the 1Password CLI (`op`).

**Pre-requisite:** `op` CLI installed and authenticated (one-time:
`brew install --cask 1password-cli`, then enable biometric unlock from the
1Password desktop app's Developer settings, then run `op signin` once per
shell session).

## Step 1 — Navigate to CoStar login

Navigate to **`https://product.costar.com`**. CoStar will route to its
login page if there's no active session, or land you on
`https://product.costar.com/suiteapps/home` if you're already authenticated.

**Check for cached session first.** Before pasting credentials, navigate
to `https://product.costar.com/suiteapps/home` and check whether the page
loads (logged in) or redirects to a login screen (not logged in). If
already logged in, skip Steps 2 and 3.

## Step 2 — Submit credentials (via 1Password fetch)

The pattern is **fetch → clipboard → paste** so the plaintext password
never enters the agent's context window or any log.

For the username (email):

```bash
op item get "CoStar" --fields label=username --reveal | pbcopy && echo "username copied"
```

Then in the browser: click the email field and paste with `cmd+v`.

For the password:

```bash
op item get "CoStar" --fields label=password --reveal | pbcopy && echo "password copied"
```

Then click the password field and paste with `cmd+v`.

After both are pasted, click the Sign In / Submit button.

**Why `--reveal`:** without it, `op` redacts password values even when
piped. The combination of `--reveal | pbcopy && echo "copied"` keeps the
plaintext off stdout — only the literal string "password copied" appears
in the tool output. Same for username (where redaction wouldn't normally
apply, but the pattern stays consistent).

**Never** run `op item get` without piping to `pbcopy`, or the credentials
will appear in your context window.

<TBD: capture during first run — exact field selectors, button label, what
happens after submit.>

## Step 3 — Handle the 2FA prompt (when triggered)

CoStar uses SMS-based 2FA, but the trigger pattern is non-obvious:

- 2FA may **NOT** fire at initial credential submission if the session is
  cached or the device is recognized — login appears to succeed and lands
  on `/suiteapps/home`.
- 2FA **does** fire when navigating into specific product areas (clicking
  the **Properties** button in the top nav is the most common trigger).
- When this happens, CoStar redirects to a separate subdomain:
  `https://secure.costargroup.com/mfa/otp/verify?signin={token}`

So the 2FA handler must be ready to fire at any point in the workflow,
not just at initial login. The downstream skills (`costar-property-report`,
`costar-market-report`) should also call back into this skill if they hit
a 2FA redirect mid-flow.

### The 2FA screen

The verification page contains:
- A single text input with placeholder `"Enter code"`
- A `Verify` button
- A `Didn't receive a code?` link that resends the code

### Flow

1. CoStar texts a numeric passcode to Gideon's phone (the number on file
   with CoStar — Gideon's personal mobile, not Sophia's number).
2. Send Gideon a message:
   > "CoStar fired 2FA. Forward the code to my WhatsApp at
   > {SOPHIA_WHATSAPP_NUMBER} and I'll enter it. If the code didn't
   > arrive, I can click 'Didn't receive a code?' to resend."
3. **Wait** for Gideon to forward the code via WhatsApp (or paste it
   directly in the chat if WhatsApp isn't available yet).
4. Type the code into the `Enter code` field.
5. Click the `Verify` button.
6. Confirm the page redirects out of the 2FA flow back into the requested
   product area.

**Note for future automation:** when WhatsApp API auto-capture is wired
up, Sophia will poll her WhatsApp inbox for the code and submit it without
Gideon's involvement. For now, the manual forward is the contract.

### KNOWN ISSUE — Chrome extension permission on the 2FA subdomain

The 2FA page lives on `secure.costargroup.com`, a different subdomain
from the main product. **Claude in Chrome (browser extension) can READ
the page but is blocked from CLICK or TYPE actions on this subdomain**
(Chrome's security policy on auth pages — error: "Cannot access a
chrome-extension:// URL of different extension").

Workarounds Sophia should try in order:
1. **Native browser automation** (e.g., Playwright/Puppeteer running
   outside the extension sandbox) — this avoids Chrome's extension
   restrictions entirely. Likely the right long-term fix.
2. **AppleScript / macOS keyboard simulation** — Sophia uses `osascript`
   to send keystrokes to the focused window. Plaintext code briefly
   lands in the AppleScript command, but stays out of Claude's context
   via the same `pipe-to-clipboard → simulate cmd+v` pattern used for
   the password.
3. **Manual hand-off (current fallback)** — pause and ask Gideon to type
   the code in himself. Loses automation but unblocks the workflow.

Until one of (1) or (2) is wired up, the 2FA step is a hard manual
hand-off. Document this clearly in any progress message to Gideon so
he knows to expect it.

## Step 4 — Confirm login succeeded

After credentials submit (and 2FA if triggered), CoStar lands on the
home page at `https://product.costar.com/suiteapps/home`.

Confirm by checking:
- URL contains `/suiteapps/home`
- The top nav has a `Properties` button (entry point for property search)
- The search bar reads "Market, Address, Building Name or Company"

Take a screenshot of the post-login home for proof of session, then return
control to the caller.

If login fails (wrong code, timeout, account locked), tell Gideon exactly what
you see and stop — don't retry blindly.

**Common 2FA failure modes:**
- **"Authentication error" after submitting a code** — most often the
  code expired (CoStar codes appear to last only a few minutes). Click
  the `Didn't receive a code?` link to resend, then submit the new code
  quickly. Don't reuse old codes.
- **Codes arriving slowly** — if Gideon hasn't received the SMS within
  60 seconds, click `Didn't receive a code?` to resend.
- **Repeated failures on fresh codes** — could indicate an account lock
  or an issue with the `signin` token in the URL. Stop and tell Gideon
  to log in manually one time to reset state.

## Output

Return to the caller:
- `session_status: "authenticated"` or `"failed"`
- `screenshot_path` of the post-login dashboard (proof of session)

The browser session stays open for the next skill in the chain to use.

---

## Notes for future automation

- If the manual WhatsApp hand-off becomes a bottleneck, the next iteration is
  Twilio/WhatsApp API auto-capture: Sophia polls a designated inbox for the
  6-digit code and submits it without Gideon's involvement.
- CoStar may persist a session cookie — if so, `costar-property-report` should
  check for an active session first before invoking this skill.
