#!/usr/bin/env bash
# find-deals v2 — overnight build orchestrator
# Runs three sequential autonomous Claude sessions, each in fresh context.
# Run B fires only if A's PR opened against gidspen/find-deals-skill.
# Run C fires only if B's PR opened.
# Logs to ~/.claude/find-deals-v2-overnight-{timestamp}.log

set -u  # error on undefined vars (NOT -e — we handle exits explicitly per gate)

REPO="/Users/gideonspencer/dealhound-pro"
WORKTREE="/Users/gideonspencer/dealhound-pro/.claude/worktrees/sad-visvesvaraya-35b506"
SKILL_REPO_OWNER="gidspen"
SKILL_REPO_NAME="find-deals-skill"
SKILL_REPO_FULL="${SKILL_REPO_OWNER}/${SKILL_REPO_NAME}"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
LOG_DIR="$HOME/.claude"
LOG_FILE="$LOG_DIR/find-deals-v2-overnight-$TIMESTAMP.log"
mkdir -p "$LOG_DIR"

PROMPTS_DIR="$WORKTREE/scripts/prompts"
RUN_A_PROMPT="$PROMPTS_DIR/find-deals-v2-run-a.txt"
RUN_B_PROMPT="$PROMPTS_DIR/find-deals-v2-run-b.txt"
RUN_C_PROMPT="$PROMPTS_DIR/find-deals-v2-run-c.txt"

# Pre-flight: prompts exist
if [ ! -f "$RUN_A_PROMPT" ] || [ ! -f "$RUN_B_PROMPT" ] || [ ! -f "$RUN_C_PROMPT" ]; then
  echo "ERROR: Missing prompt files in $PROMPTS_DIR" | tee -a "$LOG_FILE"
  exit 1
fi

# Pre-flight: tools
if ! command -v claude >/dev/null 2>&1; then
  echo "ERROR: claude CLI not found in PATH" | tee -a "$LOG_FILE"
  exit 1
fi
if ! command -v gh >/dev/null 2>&1; then
  echo "ERROR: gh CLI not found in PATH" | tee -a "$LOG_FILE"
  exit 1
fi

# Pre-flight: env (subscription path — no ANTHROPIC_API_KEY required)
source ~/.zshrc 2>/dev/null
if [ -z "${SUPABASE_DEALS_URL:-}" ] || [ -z "${SUPABASE_DEALS_ANON_KEY:-}" ]; then
  echo "ERROR: SUPABASE_DEALS_URL or SUPABASE_DEALS_ANON_KEY not loaded from ~/.zshrc" | tee -a "$LOG_FILE"
  exit 1
fi

# Pre-flight: skill repo accessible
if [ ! -d /Users/gideonspencer/skills/find-deals/.git ]; then
  echo "ERROR: skill repo missing at ~/skills/find-deals" | tee -a "$LOG_FILE"
  exit 1
fi

# Pre-flight: gh auth + skill repo access
if ! gh repo view "$SKILL_REPO_FULL" >/dev/null 2>&1; then
  echo "ERROR: gh cannot access $SKILL_REPO_FULL — check auth" | tee -a "$LOG_FILE"
  exit 1
fi

# Pre-flight: verification dir
mkdir -p "$WORKTREE/verification"

cd "$WORKTREE" || { echo "ERROR: cannot cd to $WORKTREE" | tee -a "$LOG_FILE"; exit 1; }

log() {
  echo "[$(date +%H:%M:%S)] $*" | tee -a "$LOG_FILE"
}

# Verify a PR exists for a given branch in the SKILL repo (proof the run completed)
verify_skill_pr_opened() {
  local branch="$1"
  local pr_number
  pr_number=$(gh pr list --repo "$SKILL_REPO_FULL" --head "$branch" --state open --json number --jq '.[0].number' 2>/dev/null)
  if [ -n "$pr_number" ] && [ "$pr_number" != "null" ]; then
    log "✓ Skill PR #$pr_number open for $branch"
    return 0
  else
    log "✗ No open PR found in $SKILL_REPO_FULL for $branch"
    return 1
  fi
}

run_phase() {
  local name="$1"
  local prompt_file="$2"
  local max_turns="$3"
  local expected_skill_branch="$4"

  log "================================================================"
  log "STARTING $name (budget: $max_turns turns, skill-branch: $expected_skill_branch)"
  log "================================================================"

  # Run claude in print mode, fresh session, opus 4.7, bypass perms for unattended
  if claude \
      --model claude-opus-4-7 \
      --max-turns "$max_turns" \
      --dangerously-skip-permissions \
      -p "$(cat "$prompt_file")" \
      2>&1 | tee -a "$LOG_FILE"; then
    log "$name: claude session exited cleanly"
  else
    local exit_code=$?
    log "$name: claude session exited with code $exit_code"
    # Don't stop yet — verify PR regardless. Agent may have opened PR before erroring.
  fi

  # Verification gate: did this run open the expected PR in the skill repo?
  if verify_skill_pr_opened "$expected_skill_branch"; then
    log "$name: GATE PASSED — proceeding"
    return 0
  else
    log "$name: GATE FAILED — no PR opened in $SKILL_REPO_FULL. Stopping chain."
    log "Check $LOG_FILE for details and docs/RUN_*_FIND_DEALS_V2_CHECKPOINT.md for run state."
    return 1
  fi
}

# ─────────────────────────────────────────────────────────────
# Sequence
# ─────────────────────────────────────────────────────────────

log "find-deals v2 overnight chain — start $TIMESTAMP"
log "Worktree (agent cwd): $WORKTREE"
log "Skill repo: $SKILL_REPO_FULL"
log "Log: $LOG_FILE"
log ""

# RUN A — Deep Discovery (Phase 1)
if ! run_phase "RUN A: deep discovery" "$RUN_A_PROMPT" 60 "feat/find-deals-v2-discovery"; then
  log "RUN A failed — exiting before RUN B"
  exit 1
fi

# RUN B — Universal Extractor (Phase 2)
if ! run_phase "RUN B: universal extractor" "$RUN_B_PROMPT" 80 "feat/find-deals-v2-extractor"; then
  log "RUN B failed — exiting before RUN C"
  log "RUN A's PR is still open and merge-ready."
  exit 2
fi

# RUN C — Telemetry (Phase 3)
if ! run_phase "RUN C: telemetry" "$RUN_C_PROMPT" 55 "feat/find-deals-v2-telemetry"; then
  log "RUN C failed."
  log "RUN A and RUN B PRs are still open and merge-ready."
  exit 3
fi

log "================================================================"
log "ALL THREE RUNS COMPLETE"
log "================================================================"
log "Skill PRs queued for review (in merge order):"
gh pr list --repo "$SKILL_REPO_FULL" --head feat/find-deals-v2-discovery --json number,title,url --jq '.[] | "  \(.number): \(.title) — \(.url)"' | tee -a "$LOG_FILE"
gh pr list --repo "$SKILL_REPO_FULL" --head feat/find-deals-v2-extractor --json number,title,url --jq '.[] | "  \(.number): \(.title) — \(.url)"' | tee -a "$LOG_FILE"
gh pr list --repo "$SKILL_REPO_FULL" --head feat/find-deals-v2-telemetry --json number,title,url --jq '.[] | "  \(.number): \(.title) — \(.url)"' | tee -a "$LOG_FILE"
log ""
log "Dealhound-pro evidence: committed directly to worktree branch claude/sad-visvesvaraya-35b506"
log "  (Gideon to open single PR for the spec + plans + evidence when ready)"
log ""
log "Merge order (skill PRs): discovery → extractor → telemetry"
log "Log: $LOG_FILE"
exit 0
