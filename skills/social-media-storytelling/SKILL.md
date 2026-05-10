---
name: social-media-storytelling
description: >
  Pulls recent merged GitHub PRs from gidspen/dealhound-pro and writes a
  paired set of platform-native posts — one for X (Twitter) and one for
  LinkedIn — in Gideon's founder voice. Posts are personal, building-in-public,
  honest about the grind, and formatted to each platform's audience-growth best
  practices. Output is structured for the daily briefing approval flow: drafts
  are presented for approval and, once approved, posted automatically.
  Use when Gideon says "write a post", "what should I post", "social update",
  "content from my PRs", "building-in-public", or as a prerequisite step in
  the daily briefing skill.
---

# Social Media Storytelling

You're turning Gideon's recent GitHub activity into platform-native social posts
that grow a founder audience around Deal Hound. One set of posts per run:
one for X and one for LinkedIn. Same underlying story, different execution.

The audience is real estate investors — boutique hotel buyers, micro resort
operators, STR investors — plus founders and builders interested in the
"AI replacing real estate grunt work" angle. They don't read changelogs.
They follow people.

---

## Step 1 — Pull recent merged PRs

Use `mcp__github__list_pull_requests` to fetch the last 10 PRs from
`gidspen/dealhound-pro` with `state: "closed"`, sorted by `updated` desc.
Filter for `merged_at` not null.

Keep PRs merged in the last 7 days. If fewer than 2 exist, widen to 14 days.

For each merged PR, extract:
- Title (raw)
- First 3–4 sentences of the PR body (before ## Test plan)
- Merge date
- Branch prefix (`fix/`, `feat/`, `chore/`)

---

## Step 2 — Find the story

Identify the **one strongest story** from the batch. Prefer:
1. A user-facing fix that was embarrassing/frustrating before
2. A new capability investors couldn't do yesterday
3. A "I shipped this overnight" moment with a good before/after
4. An honest failure that led to a better outcome

Group related PRs if they form a single arc (e.g., the bug that exposed the
need for the fix). Use that group as one story.

Distill to:
- **The problem** (concrete, relatable to someone making financial decisions)
- **What changed** (in plain language, no code terms)
- **Why it matters** (how it affects deal flow, trust, velocity)
- **The human moment** (what it felt like building this, what it reveals about
  the bigger vision)

If all PRs are infrastructure/chore work, still find the story:
"I spent the week making the foundation more reliable" is honest and earns
credibility. Don't skip infra runs — they signal commitment.

---

## Step 3 — Write the X post

### X (Twitter) best practices for founder product growth

**Goal:** grow a following of founders, indie hackers, RE investors, and AI
watchers who share the build journey. Virality comes from honesty, specificity,
and making people feel something.

**Format rules:**
- Hook: first line must stop the scroll. 8–12 words. No period. Often a
  paradox, a confession, a specific number, or a counter-intuitive statement.
- Use hard line breaks every 1–2 sentences. White space = readability on mobile.
- 3–5 paragraphs of 1–3 lines each.
- End with either a question (drives replies) or a punchy statement (drives RTs).
- Hashtags: 2–3 max, tucked at the very end. Use `#buildinpublic` always.
  Add one niche tag (`#realestateinvesting`, `#proptech`, or `#aistartup`).
- Total length: 220–280 characters for a standalone post. If the story needs
  more space, write a **thread** (2–4 tweets, numbered 1/, 2/, 3/).
- No em dashes. Short sentences. Fragments are fine.

**Thread format:**
```
1/ [hook — the strongest line]

[2 lines of setup]

2/ [the meat — what happened, what broke, what you did]

[concrete detail]

3/ [the lesson or the forward look]

[1 punchy closing line]

#buildinpublic #realestateinvesting
```

**Tone:** raw, direct, occasionally self-deprecating. Like a smart founder
texting a friend who gets it.

---

## Step 4 — Write the LinkedIn post

### LinkedIn best practices for founder product growth

**Goal:** reach real estate investors, commercial brokers, and professionals
who are adjacent to Deal Hound's buyer profile. Secondary: founders and
operators interested in the "building with AI" angle. LinkedIn rewards depth
and earned vulnerability.

**Format rules:**
- Hook: first line is the only thing visible before "...see more". Make it
  work alone. No "I'm excited to announce." No "Great news." Start with a
  specific observation, a number, or a confession.
- Every paragraph is 1–2 sentences. Hard return between each.
- Structure: hook → problem/context (2–3 paras) → what changed (2–3 paras)
  → what this means / lesson (1–2 paras) → soft CTA (1 line).
- Length: 150–250 words. Long enough to earn the "see more" click; short
  enough to read in one breath.
- Hashtags: 3–5, at the bottom on their own line. Mix founder tags
  (`#buildinpublic`, `#solofounder`) with audience tags (`#realestateinvesting`,
  `#commercialrealestate`, `#boutiquehospitality`).
- No bullet points for the body (save those for product demos). Prose only.
- CTA is always low-friction: "link in bio" / "free scan at dealhound.pro" /
  "Founding Member offer open now if you've been watching."

**Tone:** thoughtful, grounded, a level more polished than X but still
personal. The founder reflecting on the build, not announcing a press release.

---

## Step 5 — Output format

Present both posts clearly labeled. The output of this skill is designed to
slot directly into Sophie's daily briefing as the social media section.

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SOCIAL POSTS FOR APPROVAL
Source PRs: #XX, #YY  |  Story: [one-line story summary]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[X LOGO] X / TWITTER
────────────────────
[post or thread, copy-paste ready]

[in LOGO] LINKEDIN
────────────────────
[post, copy-paste ready]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Approve both, approve one, or say what to change.
When approved, these will be posted automatically.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Step 6 — Handle approval

If Gideon says:
- **"Approve" / "post both" / "looks good"** → mark both as approved in the
  briefing output. The posting step will be handled by the daily briefing
  skill's posting flow. Return `{ approved: ["x", "linkedin"], posts: { x, linkedin } }`.
- **"Approve X only"** → mark X approved, hold LinkedIn.
- **"Change [X]"** → apply the change and show the revised draft. Don't
  re-draft the other platform unless asked.
- **"Skip" / "not today"** → note in briefing output that social was skipped.
  Return `{ approved: [], reason: "skipped" }`.

---

## Edge cases

**No PRs in last 14 days:** Offer to write from the product roadmap, the
launch strategy (Founding Member offer, free scan), or a specific moment
Gideon describes manually. The story doesn't have to come from code.

**Only chore/infra PRs:** These still earn posts. "Infrastructure week" is
a real founder story. Reliability and care for the product *is* the message.

**Big feature launch (new skill, major capability):** Go longer on LinkedIn
(up to 300 words), write a 4-tweet thread on X. This is worth the extra
weight.

**Founding Member window open:** Every CTA should reference it specifically —
"$49/mo lifetime, first 50 only, link in bio." Don't bury it.

**Story used in previous run:** Check if the same PR numbers appeared in the
last output. If so, skip them and find the next unused PRs, or flag that
there's nothing new to post.

---

## Voice guardrails

- **Do:** Name concrete things ("the chat was labeling Deal 7 as Deal 1",
  "I ran this overnight and woke up to three queued PRs")
- **Do:** Show the before/after ("before: broken. after: fixed. five-minute
  detective work, then one line of code.")
- **Do:** Connect to the investor's world ("when you're making a $2M decision,
  you want your AI agent's Deal 1 to actually be the best deal")
- **Don't:** Use startup-speak ("excited to share", "game-changer",
  "thrilled to announce", "we're on a mission")
- **Don't:** Over-explain the tech ("refactored the scoring pipeline" →
  "the ranking was wrong, now it's right")
- **Don't:** Be falsely humble or falsely confident. Specificity beats both.
