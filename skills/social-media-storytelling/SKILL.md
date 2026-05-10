---
name: social-media-storytelling
description: >
  Pulls recent merged GitHub PRs from gidspen/dealhound-pro and writes a
  paired set of platform-native posts — one for X (Twitter) and one for
  LinkedIn — in Gideon's founder voice. Output is structured for the daily
  briefing approval flow: drafts are presented for approval and, once
  approved, posted automatically. Use when Gideon says "write a post",
  "what should I post", "social update", "content from my PRs",
  "building-in-public", or as a prerequisite step in the daily briefing skill.
---

# Social Media Storytelling

You're turning Gideon's recent GitHub activity into platform-native posts that
build a founder audience around Deal Hound. One set per run: one X post (or
thread) and one LinkedIn post. Same underlying story, different execution for
each platform.

The audience is real estate investors — boutique hotel buyers, micro resort
operators, STR investors — plus founders, indie hackers, and AI watchers who
follow the build journey. They don't read changelogs. They follow people.

---

## Gideon's Voice & Brand

Before drafting anything, internalize this. Every post should sound like it
came from Gideon, not from a content writer who read about him.

### Who he is

Gideon is a real estate investor who got tired of doing 3 hours of deal
research by hand every day and built an AI agent to do it instead. He's not
a dev who wandered into real estate — he's an operator (Stone Mont Capital)
who learned to build. That's the credential no one else in this space has.

He ships extremely fast. Multiple PRs in a day. Overnight autonomous builds
where AI writes code while he sleeps and he wakes up to queued PRs. He
states goals publicly ($15K MRR in 3 weeks from a warm audience) and means
them. He fixes bugs because a broken Deal 1 ranking is a real financial risk
for a real investor, not because the tests were failing.

### Tone

**Direct.** Short sentences. No hedging. Says the thing plainly.

**Specific.** Names the actual bug, the actual number, the actual deal type.
"The chat was calling Deal 7 'Deal 1'" not "there was a ranking issue."

**Honest about struggle.** The thing that broke before it worked is part of
the story, not hidden. The overnight autonomous run that produced garbage
output is a story. The 47-line bypass that was sending investors random deals
is a story.

**Investor-first.** Every technical thing connects back to what it means when
you're evaluating a $2M boutique hotel acquisition. That stakes-framing is
always available and always sharpens a post.

**Operator energy.** He doesn't "explore" or "experiment" — he builds, ships,
and moves. The posts feel like someone who measures everything and wastes
nothing.

**No startup-speak.** Kill on sight: "excited to share," "game-changer,"
"thrilled to announce," "we're on a mission," "passionate about," "leverage,"
"synergy," "ecosystem." None of it.

### Narrative angles (use these, rotate them)

1. **The tool I needed and couldn't find** — RE investor building the AI agent
   he wished existed. Authenticity no VC-backed proptech startup can claim.

2. **Sleeping while the AI builds** — the overnight autonomous build runs are
   genuinely cinematic. Waking up to three queued PRs. The machine working
   while you rest.

3. **Every fix is a financial decision** — Deal Hound users aren't playing
   around. They're evaluating acquisitions. Each bug fix is "I made the tool
   more reliable for someone making a $2M decision."

4. **Solo founder, impossible velocity** — one person, full product, shipping
   in days what used to take teams months. The AI-assisted building story.

5. **The compound angle** — every market report makes the next deal sharper,
   every skill shipped makes the platform more valuable for Founding Members
   who bet early.

6. **The numbers story** — transparent about goals ($15K MRR), milestones
   (Founding Member slots filling), and stakes ($49 for life vs. $79 later).

### Content mix (rotate across posts)
- ~40% product updates and demos ("here's what the agent can do now")
- ~30% revenue and milestone transparency (MRR, founding members, scans run)
- ~20% personal journey and honest failures (the late-night bug hunts, the
  plans that didn't work)
- ~10% takes and opinions (AI in real estate, what traditional proptech gets
  wrong, why the old way of deal hunting is broken)

---

## Step 1 — Pull recent merged PRs

Use `mcp__github__list_pull_requests` to fetch the last 10 PRs from
`gidspen/dealhound-pro` with `state: "closed"`, sorted by `updated` desc.
Filter for `merged_at` not null.

Keep PRs merged in the last 7 days. If fewer than 2, widen to 14 days.

For each merged PR, extract:
- Title
- First 3–4 sentences of the PR body (before `## Test plan`)
- Merge date
- Branch prefix (`fix/`, `feat/`, `chore/`)

---

## Step 2 — Find the story

One story per run. Prefer:
1. A user-facing fix that was embarrassing or trust-breaking before the fix
2. A new capability investors couldn't access yesterday
3. A "shipped this overnight" moment with a clear before/after
4. An honest failure that forced a better approach
5. Infra/reliability work — "I spent the week making the foundation solid so
   the next skill ships faster" is real and credible

Group related PRs if they form a single arc. Distill to:
- **The problem** (concrete, investor-relatable)
- **What changed** (plain language, no code terms)
- **Why it matters** (for someone evaluating acquisitions)
- **The human moment** (what it felt like building it)

---

## Step 3 — Write the X post

### Platform mechanics (current as of 2026)

**Hashtags are effectively dead.** X's algorithm reads post content
semantically and categorizes it without hashtag metadata. Use 0 hashtags.
Occasionally 1 if it's genuinely a niche community tag (#buildinpublic) and
it feels organic — never more than 1. Multiple hashtags actively suppress
reach by ~40%.

**External links kill reach.** Don't put a URL in the post body. Put the link
in the **first reply** immediately after posting. This is how levelsio,
marc_louvion, and every informed founder handles it.

**Engagement velocity in the first 30–60 minutes** is the #1 algorithmic
signal. A post that gets fast replies, bookmarks, and author engagement gets
amplified. A post that sits quiet gets buried.

**Bookmarks > likes.** Bookmark is a high-intent signal the algo weights
heavily. Write content that people want to save and come back to.

**Reply to your own post immediately.** The algo weights original-author
replies at +75 vs. +0.5 for a like. Posting a follow-up thought, a stat,
or "here's what I'd do differently" in the first reply drives conversation
depth and reach simultaneously.

**Specific numbers drive clicks.** Posts with concrete figures ("12% more
accurate," "47 deals found overnight," "$49 for life vs. $79 next week")
get ~45% higher engagement than vague equivalents.

### Accounts to study for style reference

- **@levelsio** (Pieter Levels) — the template. Raw, specific, transparent
  about revenue and failures. Over a decade of compounding.
- **@marc_louvion** (Marc Lou) — ships 17 products in 2 years, posts income
  screenshots, honest retrospectives. Watch his thread format.
- **@arvidkahl** — builds slow, posts smart. Psychology of indie SaaS.
  High-quality audience even with lower follower count.
- **@tdinh_me** (Tony Dinh) — clean product update cadence, transparent on
  metrics. Shows what sustainable solo-founder posting looks like.

### Format: single post

Use when the story is punchy and self-contained.

```
[Hook — the strongest line. No period. 8–12 words.]

[2–3 lines of setup or context.]

[The turn — what changed, what you realized, what you built.]

[Closing line — question to drive replies OR punchy observation.]
```

### Format: thread

Use when the story has a before/after arc worth showing in full, or when
you have a number/metric to reveal that earns the context.

```
1/
[Hook — must stand completely alone. This is the only tweet most people see.]

[2–3 lines. The setup. The problem.]

2/
[The meat. What happened, what broke, what you did.]

[Concrete detail. A number if you have one.]

3/
[The lesson, the forward look, or the ask.]

[1 punchy closing line.]
```

**Key thread rules:**
- Tweet 1 must work as a standalone post — it's the only one getting
  distributed initially
- 3–4 tweets max. Past 4, you've lost the room.
- No numbered lists inside threads. That's blog format, not X format.

---

## Step 4 — Write the LinkedIn post

### Platform mechanics (current as of 2026)

**Document carousels (PDF) are the highest-performing format** — 6.60%
engagement rate, 39% more reach than text posts. For product milestones,
feature reveals, or "here's what I built" posts with visual depth, suggest
a carousel format. Note in the output that a carousel version can be created
if Gideon wants.

**Text posts still work** when the hook is exceptional. Default to text unless
the story naturally lends itself to slides.

**External links drop reach ~60%.** Same rule as X: put the URL in the
**first comment** immediately after posting, not in the post body.

**Post length sweet spot: 1,200–1,600 characters** for storytelling/authority
posts. The algorithm rewards dwell time — posts people read slowly outperform
posts people scan.

**The hook is everything.** LinkedIn shows ~210 characters before the "see
more" cutoff. Those first 1–2 sentences must stop the scroll and earn the
click. Test the hook by reading it in isolation — does it make someone curious
even without the rest?

**Hashtags: 3–5, inside the post body.** Not in the comments. They function
as semantic metadata now — not for discovery, but to help the algorithm
categorize your content correctly. Use: one broad tag, two niche tags. E.g.,
`#buildinpublic #realestateinvesting #proptech`. Don't add them mechanically
if they disrupt flow.

**Strategic commenting drives compounding reach.** Comments from the original
author have 15x the algorithmic weight of likes. After posting, engage in the
comments — it's not just politeness, it's distribution.

**"First commenter" move:** Post, then immediately comment on your own post
with the link (to dealhound.pro or the Founding Member offer). This keeps
the post body clean (no link penalty) and adds value in the thread.

**LinkedIn Newsletter is underused and compounds differently.** Worth
considering as a long-term build — subscribers get notified directly,
independent of feed reach.

### Accounts to study

- **Sophie Miller (@prettylittlemarketer)** — grew to 213K+ followers
  documenting her solo founder/content journey on LinkedIn specifically.
  Best case study for building in public on this platform.
- **Arvid Kahl** — active on both X and LinkedIn, consistently high
  engagement from exactly the audience (founders who buy things).
- Strong format reference: the "I almost quit, here's what saved it" arc.
  Posts structured as earned vulnerability — not trauma-dumping, but
  specific challenge → specific insight → what you'd tell someone now.

### Format

```
[Hook — 1 sentence, max 210 characters. Works standalone. No period.]

[Context paragraph — 2–3 sentences. The problem or situation, concrete.]

[The turn — what changed, what you built, what you realized.]

[Zoom out — why this matters in the bigger picture. The investor lens.]

[Soft close — 1 line. Not a hard sell. What's next, or a reflection.]

[Link goes in first comment]

#hashtag1 #hashtag2 #hashtag3
```

**Line breaks between every paragraph.** LinkedIn readers scan before they
read. White space signals "this is worth reading" more than a wall of text.

**Target length: 1,200–1,600 characters.** Write to that ceiling, not below
it — longer posts with high dwell time outperform short ones on LinkedIn.

---

## Step 5 — Output format

Structured for direct use in Sophie's daily briefing:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SOCIAL POSTS FOR APPROVAL
Source PRs: #XX, #YY  |  Story: [one-line summary]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

𝕏  X / TWITTER
────────────────────
[post or thread — copy-paste ready]

[Note: put link in first reply after posting]

──
in  LINKEDIN
────────────────────
[post — copy-paste ready]

[Note: put URL in first comment after posting]
[Note: carousel version available if you want more visual format]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Approve both / approve one / say what to change.
When approved, posts go out automatically.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Step 6 — Approval handling

- **"Approve" / "post both" / "looks good"** → return
  `{ approved: ["x", "linkedin"], posts: { x, linkedin } }` to the briefing
  skill for posting.
- **"Approve X only" / "approve LinkedIn only"** → mark one, hold the other.
- **"Change [X]"** → apply the change, re-show that platform's draft only.
- **"Make it shorter / punchier / less techy / add more struggle"** → apply
  and re-show. Common refinements are in the guardrails below.
- **"Skip" / "not today"** → return `{ approved: [], reason: "skipped" }`.

---

## Edge cases

**No PRs in the last 14 days:** Offer to write from the product roadmap,
the Founding Member offer, the free scan at dealhound.pro, or a story
Gideon describes manually. The post doesn't have to come from code.

**Only infra/chore PRs:** Still post-worthy. "I spent the week making the
foundation solid so I can ship faster" is an honest founder story. Pairs
well with a forward-looking hook about what's coming next.

**Big launch (new skill, major capability):** Go up to 300 words on
LinkedIn, write a 4-tweet thread on X. This earns the extra weight.

**Founding Member window open:** Every CTA should name it specifically —
"$49/mo locked for life, first 50 only" — not just "link in bio."

**Same PR appeared in last run:** Skip it. Find the next unused PR batch
or flag that there's nothing new to post since last time.

---

## Voice guardrails

| Do | Don't |
|---|---|
| "The chat was calling Deal 7 'Deal 1'" | "There was a ranking inconsistency" |
| "I ran this overnight and woke up to 3 PRs" | "I leveraged autonomous AI workflows" |
| "When you're evaluating a $2M acquisition, Deal 1 needs to be Deal 1" | "This improves user experience" |
| "It was a one-line fix. I'd spent 2 hours finding it." | "Resolved the issue efficiently" |
| "Still not perfect. Here's what breaks next." | "Excited to share this milestone" |
| Specific numbers everywhere | Vague claims |
| The struggle before the win | The win only |

---

## The "don't market Claude, market Deal Hound" rule

This is a hard constraint that overrides everything else in this skill.

**The problem:** Posts that lead with "I built this with Claude" or "AI wrote
3 PRs while I slept" read as inspiration for builders — not as reasons for
investors to buy Deal Hound. A developer who hears that story thinks *I could
do this myself*. An investor who hears that story doesn't know what to do
with it. Either way, you've marketed Anthropic's product instead of yours.

**The fix:** Claude and the AI tooling are never the protagonist. They're
infrastructure — like AWS or Postgres. You wouldn't write a post about the
database technology behind Deal Hound. Apply the same logic to the AI layer.

**Two audiences, two framings:**

For the **investor audience** (the buyer):
- The outcome is the story, not the tool that produced it
- "The agent found 12 off-market boutique hotel leads before I had my coffee"
- "It scanned 400 listings overnight and ranked them against your buy box"
- The AI is completely invisible — Deal Hound did it

For the **founder/builder audience** (the audience-builder):
- Gideon's velocity and judgment are the story, not the AI
- "I shipped a full outreach pipeline in a weekend" — not "Claude coded it"
- "Woke up to 3 queued PRs" is fine — it's about *his* process, his output
- Never frame it as "anyone could do this with AI" — the skill is in knowing
  what to build and how to direct it

**The test:** Before finalizing any post, ask: does this make someone want to
buy Deal Hound, or does it make them want to open a Claude account? If the
answer is the latter, reframe. Remove the tool, keep the outcome.

**Always-on redirect:** Any time a post mentions the AI, Claude, or automation
in the build, redirect the sentence to what it produced for investors:
- "Built with AI" → "finds deals before your competitors do"
- "Claude wrote the scorer" → "scored 400 properties against your exact criteria"
- "Autonomous overnight build" → "new capability shipped — here's what it does for your deal flow"
