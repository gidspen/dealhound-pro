# Ship approval — feat/autonomous-build-security

## Intent
Add a four-layer defense against prompt-injection-driven destructive operations during autonomous overnight Deal Hound builds. The four layers are: model-side scope fence in skill prompts, an explicit `--allowedTools` allowlist in the launcher, a `deny` array in both project and global `settings.json`, and a pre-push verification gate in `.husky/pre-push` that fires only on agent-authored commits.

## Files changed (in the harness commit immediately prior, 1f2622c)
- `.claude/settings.json` — added 18-entry `deny` array under `permissions` (sibling of `allow`). Blocks rm variants, `git push --force/--force-with-lease`, `git reset --hard`, `git clean -f`, `curl|sh`, `wget|sh`, `chmod 777`, `sudo *`.
- `.husky/pre-push` — added autonomous-build verification gate. Only fires when the last commit body contains `noreply@anthropic.com`. Requires `verification/ship-approved-${SAFE_BRANCH}.md` before push.
- `scripts/overnight-build-template.sh` — new reference launcher using `--allowedTools` instead of `--dangerously-skip-permissions`. Curated allowlist for find-deals-style overnight runs.
- `tests/security/prompt-injection-sample.txt` — fixture with five injection-pattern variants (HTML comment, JSON-LD, alt text, plain text, Unicode obfuscation).
- `tests/security/README.md` — verification test instructions and pass/fail criteria.
- `docs/SECURITY_AUTONOMOUS_BUILDS.md` — full design doc (threat model, four-layer diagram, how to extend the allowlist, known limitations).
- `docs/security-build-checkpoint.md` — build audit trail.

## Files changed in this approval commit
- `verification/ship-approved-feat-autonomous-build-security.md` — this file.

## Confirmation
No files outside the intended scope were modified. find-deals pipeline code (`scorer.py`, `pipeline.py`, `scrapers/`), production worker, dashboard, and API routes were not touched. The skills repo received a companion edit in a separate branch + PR (gidspen/find-deals-skill#5).
