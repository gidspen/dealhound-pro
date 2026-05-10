---
name: social-media-storytelling
description: >
  Pulls recent merged GitHub PRs from gidspen/dealhound-pro and writes
  social media posts in Gideon's founder voice — personal, building-in-public,
  honest about the grind. Posts are informative without being technical, bring
  the audience along on the journey, and have a natural call-to-action toward
  dealhound.pro. Use when Gideon says "write a post", "what should I post today",
  "do a social update", "write me some content", "generate posts from my PRs",
  or any variation of turning recent dev work into marketing content.
  Also runs on a /loop to generate posts automatically on a schedule.
---

# Social Media Storytelling

You're turning Gideon's recent GitHub activity into founder-voice social media
posts. The audience is real estate investors — boutique hotel buyers, micro resort
operators, STR investors — on Instagram and podcast. They don't care about code.
They care about: what got better, why it matters for finding deals, and whether
Gideon is the kind of builder they can trust with their deal flow.

## Voice

First-person. Present tense where possible. No jargon ("I fixed a bug" not
"I refactored the scoring pipeline"). Specific details anchor credibility —
name the feature, name the problem it solved. Honest about struggle: if
something broke before it worked, say so. Brief sentences. Each post should
feel like a text from a founder who just shipped something and can't help
sharing it.

Not corporate. Not humble-braggy. Not a changelog.

## Step 1 — Pull recent merged PRs

Use `mcp__github__list_pull_requests` to fetch the last 10 PRs from
`gidspen/dealhound-pro` with `state: "closed"`, sorted by `updated` desc.
Filter for `merged_at` not null (actually merged, not just closed).

Keep only PRs merged in the last 7 days. If none, widen to 14 days.

For each merged PR, note:
- Title (raw)
- Body summary (first 3-4 sentences of the PR description, before test plans)
- Merge date
- Branch name (signals whether it's a fix, feat, chore)

## Step 2 — Extract the human story

For each PR, identify the **one-sentence human impact**:

| PR type | Human translation |
|---|---|
| `fix/` — bug | Something was broken for users. Now it's not. |
| `feat/` — feature | Users can now do X they couldn't before. |
| `chore/` — infra | The engine got more reliable / faster. |
| `refactor/` — cleanup | Less likely to break. Foundation for next feature. |

Then identify the **emotional beat**: was this a late-night hunt for a subtle
bug? A feature Gideon has been wanting for months? A quick win? A boring but
necessary foundation piece? The PR body usually signals this.

Group related PRs if they tell a single coherent story (e.g., a bug fix + the
feature that exposed the bug = one story about shipping and iterating).

## Step 3 — Draft posts

Write 1–3 posts depending on how much material is available.

### Post format

**Hook line** — the thing that happened, in plain language. Compelling enough
to stop the scroll. 8-12 words max. No period at the end.

**Body** — 3-6 short paragraphs. Tell the story: what it was, why it broke
or why you built it, what it does now, what that means for an investor using
it. Be concrete: "deals were sorted wrong in the chat" not "there was a
ranking inconsistency." Use line breaks between each paragraph for IG
readability.

**Landing** — one or two sentences that bring it home. Why does this matter
in the bigger picture? What's next?

**CTA** — keep it soft, one line. Usually points to dealhound.pro or the
Founding Member offer.

**Hashtags** — 5-8 relevant tags at the end, separated by spaces, on their
own line. Mix of niche (boutique hotel investing, off-market deals) and broad
(buildinpublic, solofounder, proptech). Don't over-hashtag.

### Length target

Instagram caption sweet spot: 150–300 words. Longer is fine if the story
earns it. Shorter is fine for quick wins.

### Example tone (do not copy verbatim — this is style reference only)

> Fixed something that's been bugging me for a week
>
> When you asked the AI agent about your top deals, it would call them
> "Deal 1, Deal 2, Deal 3" — but those numbers didn't match the ranked list
> on your screen. Deal 1 in the chat might be Deal 7 on your dashboard. Made
> it feel unreliable, even when the analysis was right.
>
> Turned out the chat was reading deals in the order they hit the database,
> not in priority order. A one-line fix. But these are the details that make
> or break trust in a tool you're supposed to use to make real financial
> decisions.
>
> Every time I find one of these I ask: what else are we calling "Deal 1"
> that's actually a "Deal 7"? Good motivation to keep auditing.
>
> If you haven't tried a free scan yet, link in bio.
>
> #buildinpublic #dealhunting #boutiquehotel #realestateinvesting
> #airealestate #solofounder #proptech #aitools

## Step 4 — Present posts

Show Gideon each draft post, clearly labeled:

```
--- POST 1 of N ---
[the post, ready to copy-paste]

Source PRs: #XX, #YY
```

Then ask: "Want me to tweak any of these, or are they good to go?"

Do NOT post anywhere automatically. These are drafts for review.

## Step 5 — Offer refinements

Common asks to anticipate:
- "Make it shorter" → cut the middle, keep hook and landing
- "Less techy" → replace any remaining technical words with outcomes
- "Add more struggle" → emphasize what broke before it worked
- "Make it punchy" → shorten sentences, use fragments intentionally
- "Different platform" → for Twitter/X, break into a thread (each paragraph
  = one tweet, add tweet numbers 1/, 2/ etc.)

## Edge cases

**No PRs in the last 14 days:** Tell Gideon there's no recent shipping to draw
from, then offer to write from the product roadmap or from a specific feature
he describes manually.

**Only chore/infra PRs:** These still have stories. "I spent the last few days
making the foundation more reliable so I can ship features faster" is honest
and relatable. Don't skip infra PRs — they signal commitment and rigor.

**Duplicate story from a previous loop run:** Check if the same PR numbers
were used in the last post. If so, skip them and look for older unposted PRs,
or flag to Gideon that there's nothing new since last time.

## Notes

- The Founding Member window ($49/mo, first 50) is time-limited — when that
  offer is active, CTAs should reference it specifically
- When in doubt, err toward more personal / honest over more polished / safe
- The audience follows Gideon, not the product — write about the person first,
  the tool second
