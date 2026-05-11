#!/usr/bin/env bash
# overnight-build-template.sh — REFERENCE TEMPLATE, not directly executable.
#
# This template replaces the previous `--dangerously-skip-permissions` pattern
# with an explicit `--allowedTools` allowlist. Two reasons:
#
#   1. Even with model-side prompt-scope fences, scraped broker content can
#      contain prompt injection. With `--dangerously-skip-permissions`, the
#      harness offers no second line of defense — any rm/curl/chmod call goes
#      through.
#
#   2. The project + global `settings.json` `deny` rules (in
#      `~/.claude/settings.json` and `.claude/settings.json`) provide a third
#      layer that fires even within the allowlist if an entry is too broad.
#
# Combined defense in depth:
#   Layer 1: Prompt scope fence (in $PROMPT_FILE)
#   Layer 2: --allowedTools (this file)
#   Layer 3: deny rules (settings.json)
#   Layer 4: Pre-push verification gate (.husky/pre-push)
#
# To use: copy this file, fill in the variables, source .env, run from the
# repo root. NEVER run blind — verify $PROMPT_FILE first.

set -euo pipefail

# ─── Fill these in ─────────────────────────────────────────────────────────
PROMPT_FILE="${PROMPT_FILE:-prompts/overnight-build-NAME.md}"
BRANCH="${BRANCH:-feat/your-overnight-build}"
MAX_TURNS="${MAX_TURNS:-150}"
# ───────────────────────────────────────────────────────────────────────────

# Sanitize branch name for filesystem paths (replace / with -).
SAFE_BRANCH="${BRANCH//\//-}"

# Pre-flight checks.
if [ ! -f "$PROMPT_FILE" ]; then
  echo "❌ PROMPT_FILE not found: $PROMPT_FILE"
  exit 1
fi
if [ ! -f .env ]; then
  echo "❌ .env not found in $(pwd)"
  exit 1
fi
set -a; . ./.env; set +a
if [ -z "${ANTHROPIC_API_KEY:-}" ]; then
  echo "❌ ANTHROPIC_API_KEY not loaded"
  exit 1
fi

# Create the feature branch (idempotent).
git checkout -B "$BRANCH"

# ─── The allowlist ─────────────────────────────────────────────────────────
# Build up over multiple lines for readability. Groups:
#   - git: status / add / commit / push to origin / log / diff / branch /
#          checkout / stash / pull / fetch
#   - gh: pr/issue management
#   - build tools: npm, python3
#   - filesystem inspection: cat, ls, mkdir -p, cp, mv (no rm — covered by deny)
#   - utilities: jq, source, tee, date, wc, echo, which, command
#   - Claude file tools: Read, Write, Edit
#   - WebSearch (broker discovery)
#   - Playwright MCP (scraping)
#
# NOTE: the global + project `deny` rules apply on top of this allowlist, so
# even if a pattern here is broader than intended (e.g. `Bash(rm *)` if you
# add it), `Bash(rm -rf *)` from deny still wins.
#
# Pattern syntax: `Bash(command pattern *)` with trailing space-wildcard,
# matching the existing convention in `.claude/settings.json` (e.g.
# `Bash(pm2 logs *)`). Do NOT use colon syntax — it's a different format.
ALLOWED_TOOLS=$(cat <<'EOF'
Bash(git status *) Bash(git status) Bash(git add *) Bash(git commit *) Bash(git push origin *) Bash(git log *) Bash(git diff *) Bash(git branch *) Bash(git branch) Bash(git checkout *) Bash(git stash *) Bash(git pull *) Bash(git pull) Bash(git fetch *) Bash(gh *) Bash(npm run *) Bash(npm install) Bash(python3 *) Bash(cat *) Bash(ls *) Bash(ls) Bash(mkdir -p *) Bash(cp *) Bash(mv *) Bash(jq *) Bash(source *) Bash(tee *) Bash(date *) Bash(date) Bash(wc *) Bash(echo *) Bash(which *) Bash(command *) Read Write Edit WebSearch mcp__playwright__browser_navigate mcp__playwright__browser_snapshot mcp__playwright__browser_click mcp__playwright__browser_type mcp__playwright__browser_fill_form mcp__playwright__browser_wait_for mcp__playwright__browser_evaluate mcp__playwright__browser_take_screenshot
EOF
)
# Collapse multi-line to single line for the CLI flag.
ALLOWED_TOOLS="${ALLOWED_TOOLS//$'\n'/ }"

# ─── Run the build ─────────────────────────────────────────────────────────
echo "▶ Starting overnight build"
echo "   prompt: $PROMPT_FILE"
echo "   branch: $BRANCH"
echo "   max-turns: $MAX_TURNS"
echo

claude \
  --allowedTools "$ALLOWED_TOOLS" \
  --max-turns "$MAX_TURNS" \
  -p "$(cat "$PROMPT_FILE")" \
  2>&1 | tee "logs/overnight-${SAFE_BRANCH}-$(date +%Y%m%d-%H%M%S).log"

# ─── Pre-push verification gate ────────────────────────────────────────────
# .husky/pre-push will refuse to push agent-authored commits unless
# verification/ship-approved-${SAFE_BRANCH}.md exists. The agent must
# write this file as the final step of the build, OR a human reviews and
# writes it manually before re-running `git push`.
APPROVAL_FILE="verification/ship-approved-${SAFE_BRANCH}.md"
if [ ! -f "$APPROVAL_FILE" ]; then
  echo
  echo "⚠️  Build finished but $APPROVAL_FILE was not written."
  echo "    Push will be blocked. Review the diff, write the approval file,"
  echo "    then run: git push -u origin $BRANCH"
  exit 0
fi

echo "✅ Approval file present — push gate should clear."
