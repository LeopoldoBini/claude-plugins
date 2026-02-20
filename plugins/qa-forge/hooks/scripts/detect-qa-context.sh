#!/usr/bin/env bash
# detect-qa-context.sh — SessionStart hook for QA-Forge
# Detects if the current project has QA-Forge configuration
# Outputs JSON with systemMessage if config found

set -euo pipefail

CONFIG_FILE=".claude/qa-forge.local.md"
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(dirname "$(dirname "$(realpath "$0")")")/..}"

# Check if we're in a project with qa-forge config
if [ -f "$CONFIG_FILE" ]; then
  # Extract base_url from YAML frontmatter
  base_url=$(sed -n '/^---$/,/^---$/p' "$CONFIG_FILE" | grep '^base_url:' | head -1 | sed 's/base_url: *"\{0,1\}\([^"]*\)"\{0,1\}/\1/')

  # Detect framework
  framework="unknown"
  if [ -f "package.json" ]; then
    framework=$(bash "$PLUGIN_ROOT/scripts/detect-project-type.sh" "package.json")
  fi

  # Build context message
  msg="QA-Forge is configured for this project."
  if [ -n "$base_url" ]; then
    msg="$msg Base URL: $base_url."
  fi
  if [ "$framework" != "unknown" ]; then
    msg="$msg Framework: $framework."
  fi
  msg="$msg Commands available: /qa (full workflow), /qa-plan (plan only), /qa-run (execute only)."

  # Output system message
  cat <<EOF
{"systemMessage": "$msg"}
EOF
else
  # No config — silent exit
  exit 0
fi
