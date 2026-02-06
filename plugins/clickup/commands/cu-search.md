---
description: "Search ClickUp tasks by name or fetch by ID"
argument-hint: "<search term or task ID>"
---

# ClickUp Search

Search term: `$ARGUMENTS`

## Instructions

1. First, check if `.claude/clickup.local.md` exists in the project root. If it does, read it for project-specific IDs and conventions.

2. Load config:
   ```bash
   source ~/.config/clickup/config.env
   ```

3. Determine if the input looks like a task ID (6-9 alphanumeric characters, no spaces) or a search term.

4. **If task ID**: Fetch the task directly:
   ```bash
   ${CLAUDE_PLUGIN_ROOT}/skills/clickup-api/scripts/cu-api.sh GET "/task/$ARGUMENTS?include_subtasks=true&include_markdown_description=true"
   ```
   Format with: `| ${CLAUDE_PLUGIN_ROOT}/skills/clickup-api/scripts/cu-format.py task`

5. **If search term**: Search across the team:
   ```bash
   ${CLAUDE_PLUGIN_ROOT}/skills/clickup-api/scripts/cu-api.sh GET "/team/${CLICKUP_TEAM_ID}/task?name=$(python3 -c 'import urllib.parse; print(urllib.parse.quote("$ARGUMENTS"))')&include_closed=true"
   ```
   Format with: `| ${CLAUDE_PLUGIN_ROOT}/skills/clickup-api/scripts/cu-format.py tasks`

6. Always include clickable URLs: `https://app.clickup.com/t/{task_id}`

7. Present results concisely. If many results, show top 10 with a note about total count.
