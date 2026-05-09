#!/usr/bin/env bash
# Deal Hound SBA — overnight build orchestrator
# Runs three sequential autonomous Claude sessions, each in fresh context.
# Run B fires only if A's PR opened. Run C fires only if B's PR opened.
# Logs to ~/.claude/sba-overnight-{timestamp}.log

set -u  # error on undefined vars (NOT -e — we handle exits explicitly per gate)

REPO="/Users/gideonspencer/dealhound-pro"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
LOG_DIR="$HOME/.claude"
LOG_FILE="$LOG_DIR/sba-overnight-$TIMESTAMP.log"
mkdir -p "$LOG_DIR"

PROMPTS_DIR="$REPO/scripts/prompts"
RUN_A_PROMPT="$PROMPTS_DIR/run-a.txt"
RUN_B_PROMPT="$PROMPTS_DIR/run-b.txt"
RUN_C_PROMPT="$PROMPTS_DIR/run-c.txt"

# Pre-flight
if [ ! -f "$RUN_A_PROMPT" ] || [ ! -f "$RUN_B_PROMPT" ] || [ ! -f "$RUN_C_PROMPT" ]; then
  echo "ERROR: Missing prompt files in $PROMPTS_DIR" | tee -a "$LOG_FILE"
  exit 1
fi

if ! command -v claude >/dev/null 2>&1; then
  echo "ERROR: claude CLI not found in PATH" | tee -a "$LOG_FILE"
  exit 1
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "ERROR: gh CLI not found in PATH" | tee -a "$LOG_FILE"
  exit 1
fi

cd "$REPO" || { echo "ERROR: cannot cd to $REPO" | tee -a "$LOG_FILE"; exit 1; }

log() {
  echo "[$(date +%H:%M:%S)] $*" | tee -a "$LOG_FILE"
}

# Verify a PR exists for a given branch (proof the run completed its goal)
verify_pr_opened() {
  local branch="$1"
  local pr_number
  pr_number=$(gh pr list --head "$branch" --state open --json number --jq '.[0].number' 2>/dev/null)
  if [ -n "$pr_number" ] && [ "$pr_number" != "null" ]; then
    log "✓ PR #$pr_number open for $branch"
    return 0
  else
    log "✗ No open PR found for $branch"
    return 1
  fi
}

run_phase() {
  local name="$1"
  local prompt_file="$2"
  local max_turns="$3"
  local expected_branch="$4"

  log "================================================================"
  log "STARTING $name (budget: $max_turns turns, branch: $expected_branch)"
  log "================================================================"

  # Run claude in print mode, fresh session, opus 4.7, bypass perms for unattended
  # Output streams to log file in real time
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

  # Verification gate: did this run open the expected PR?
  if verify_pr_opened "$expected_branch"; then
    log "$name: GATE PASSED — proceeding"
    return 0
  else
    log "$name: GATE FAILED — no PR opened. Stopping chain."
    log "Check $LOG_FILE for details and docs/RUN_*_CHECKPOINT.md for run state."
    return 1
  fi
}

# ─────────────────────────────────────────────────────────────
# Sequence
# ─────────────────────────────────────────────────────────────

log "Deal Hound SBA overnight chain — start $TIMESTAMP"
log "Repo: $REPO"
log "Log: $LOG_FILE"
log ""

# RUN A
if ! run_phase "RUN A: foundation" "$RUN_A_PROMPT" 60 "feat/sba-foundation"; then
  log "RUN A failed — exiting before RUN B"
  exit 1
fi

# RUN B
if ! run_phase "RUN B: data pipeline" "$RUN_B_PROMPT" 90 "feat/sba-data-pipeline"; then
  log "RUN B failed — exiting before RUN C"
  log "RUN A's PR is still open and merge-ready."
  exit 2
fi

# RUN C
if ! run_phase "RUN C: buddy polish" "$RUN_C_PROMPT" 40 "feat/sba-buddy-polish"; then
  log "RUN C failed."
  log "RUN A and RUN B PRs are still open and merge-ready."
  exit 3
fi

log "================================================================"
log "ALL THREE RUNS COMPLETE"
log "================================================================"
log "PRs queued for review:"
gh pr list --head feat/sba-foundation --json number,title --jq '.[] | "  \(.number): \(.title)"' | tee -a "$LOG_FILE"
gh pr list --head feat/sba-data-pipeline --json number,title --jq '.[] | "  \(.number): \(.title)"' | tee -a "$LOG_FILE"
gh pr list --head feat/sba-buddy-polish --json number,title --jq '.[] | "  \(.number): \(.title)"' | tee -a "$LOG_FILE"
log ""
log "Merge order: foundation → data-pipeline → buddy-polish"
log "Log: $LOG_FILE"
exit 0
