## Skill routing

When the user's request matches an available skill, ALWAYS invoke it using the Skill
tool as your FIRST action. Do NOT answer directly, do NOT use other tools first.
The skill has specialized workflows that produce better results than ad-hoc answers.

Key routing rules:

- Product ideas, "is this worth building", brainstorming → invoke office-hours
- Bugs, errors, "why is this broken", 500 errors → invoke investigate
- Ship, deploy, push, create PR → invoke ship
- QA, test the site, find bugs → invoke qa
- Code review, check my diff → invoke review
- Update docs after shipping → invoke document-release
- Weekly retro → invoke retro
- Design system, brand → invoke design-consultation
- Visual audit, design polish → invoke design-review
- Architecture review → invoke plan-eng-review
- Save progress, checkpoint, resume → invoke checkpoint
- Code quality, health check → invoke health
- Create/update Notion task, project, goal, area → invoke notion-task-manager
- Session triage, session wrap, log strategic decision → invoke notion-task-manager
- Mark task done, add proof, update status in Notion → invoke notion-task-manager
- Write a post, social update, content from PRs, building-in-public, what should I post → invoke social-media-storytelling

## Source-of-truth docs

- [LAUNCH_STRATEGY.md](LAUNCH_STRATEGY.md) — locked pricing, positioning, beta strategy
- [PRODUCT_SPEC.md](PRODUCT_SPEC.md) — what we're building
- [docs/USER_FLOWS.md](docs/USER_FLOWS.md) — testable end-to-end user flow spec; the contract Playwright tests assert against. Update whenever a flow changes.

## Deal Pipeline Environment

- Always source `.env` before running the scoring phase of /find-deals (the scorer needs ANTHROPIC_API_KEY loaded)
- Persist scored deals incrementally to disk during scoring, not just at the end, so process kills don't lose in-memory results
- Verify ANTHROPIC_API_KEY credit balance before launching long scoring runs (1000+ deals)

## Git Workflow

- Never edit directly on main — always create a feature branch first before making changes
- main is a protected branch; use PRs for all merges
- Confirm branch with `git branch --show-current` before the first edit in any session

## Supabase Persistence

- Supabase raw inserts/updates have repeatedly returned 400 errors during deal pipeline runs — investigate the schema mismatch on first occurrence rather than deferring
- Always have local JSON fallback when persisting pipeline results
