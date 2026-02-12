#!/bin/bash
# ADR Sync — PostToolUse Hook Script
# Detects when an ADR file is written or edited in the configured directory.
# If an ADR was modified, returns a systemMessage instructing Claude to invoke
# the adr-sync-checker agent.

set -euo pipefail

# Read hook input from stdin
INPUT=$(cat)

# Validate input is valid JSON
if ! echo "$INPUT" | jq empty 2>/dev/null; then
  exit 0
fi

# Extract tool name and file path from input
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Only process Write and Edit tools
if [[ "$TOOL_NAME" != "Write" && "$TOOL_NAME" != "Edit" ]]; then
  exit 0
fi

# No file path means nothing to check
if [[ -z "$FILE_PATH" ]]; then
  exit 0
fi

# Loop prevention: if the sync agent is currently running, skip
# The agent creates this lock file before writing and removes it after
LOCK_FILE="/tmp/.adr-sync-in-progress"
if [[ -f "$LOCK_FILE" ]]; then
  exit 0
fi

# Read project configuration
STATE_FILE=".claude/adr-sync.local.md"

if [[ ! -f "$STATE_FILE" ]]; then
  # Plugin not configured for this project — skip silently
  exit 0
fi

# Parse frontmatter
FRONTMATTER=$(sed -n '/^---$/,/^---$/{ /^---$/d; p; }' "$STATE_FILE")

# Extract ADR path and pattern from settings
ADR_PATH=$(echo "$FRONTMATTER" | grep '^adr_path:' | sed 's/adr_path: *//' | sed 's/^"//;s/"$//')
ADR_PATTERN=$(echo "$FRONTMATTER" | grep '^adr_pattern:' | sed 's/adr_pattern: *//' | sed 's/^"//;s/"$//')

# Defaults if not configured
ADR_PATH="${ADR_PATH:-docs/architecture/decisions}"
ADR_PATTERN="${ADR_PATTERN:-ADR-*.md}"

# Normalize the ADR path to absolute for proper comparison
if [[ "$ADR_PATH" = /* ]]; then
  ABS_ADR_PATH="$ADR_PATH"
else
  ABS_ADR_PATH="$(pwd)/$ADR_PATH"
fi
# Remove trailing slash
ABS_ADR_PATH="${ABS_ADR_PATH%/}"

# Normalize the file path to absolute
if [[ "$FILE_PATH" = /* ]]; then
  ABS_FILE_PATH="$FILE_PATH"
else
  ABS_FILE_PATH="$(pwd)/$FILE_PATH"
fi

FILE_DIR=$(dirname "$ABS_FILE_PATH")
FILE_NAME=$(basename "$ABS_FILE_PATH")

# Check if file is in the ADR directory (exact prefix match, respects path boundaries)
IS_ADR=false
if [[ "$FILE_DIR" == "$ABS_ADR_PATH" || "$FILE_DIR" == "$ABS_ADR_PATH"/* ]]; then
  # Use native bash glob matching (not regex conversion)
  if [[ "$FILE_NAME" == $ADR_PATTERN ]]; then
    IS_ADR=true
  fi
fi

if [[ "$IS_ADR" != "true" ]]; then
  # Not an ADR file — skip
  exit 0
fi

# Check if ADR already has sync_status: synced (avoid re-triggering on sync updates)
if [[ -f "$ABS_FILE_PATH" ]]; then
  if grep -q '^sync_status: synced' "$ABS_FILE_PATH" 2>/dev/null; then
    exit 0
  fi
fi

# ADR detected! Return systemMessage to trigger the agent
cat <<EOF
{
  "systemMessage": "An ADR file was just written or modified: ${FILE_PATH}. Use the Task tool to launch the adr-sync-checker agent to process this ADR. The agent should: 1) Read the ADR, 2) Read project settings from .claude/adr-sync.local.md, 3) Cross-reference against all sync target files, 4) Update affected documentation, 5) Mark the ADR with sync_status: synced in its frontmatter. IMPORTANT: Before writing any files, create /tmp/.adr-sync-in-progress lock file. Remove it when done."
}
EOF
