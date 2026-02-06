---
description: "Get detailed ClickUp task info by ID"
argument-hint: "<task ID>"
---

# ClickUp Task Detail

Task ID: `$ARGUMENTS`

## Instructions

1. Read `.claude/clickup.local.md` if it exists for project context.

2. Fetch the task with full details:
   ```bash
   ${CLAUDE_PLUGIN_ROOT}/skills/clickup-api/scripts/cu-api.sh GET "/task/$ARGUMENTS?include_subtasks=true&include_markdown_description=true"
   ```

3. Fetch the latest comments (last 5):
   ```bash
   ${CLAUDE_PLUGIN_ROOT}/skills/clickup-api/scripts/cu-api.sh GET "/task/$ARGUMENTS/comment"
   ```

4. Fetch time tracked:
   ```bash
   ${CLAUDE_PLUGIN_ROOT}/skills/clickup-api/scripts/cu-api.sh GET "/task/$ARGUMENTS/time"
   ```

5. Present a comprehensive card with:
   - Task name, ID, and URL (`https://app.clickup.com/t/{id}`)
   - Status, priority, assignees
   - Due date, start date, time estimate vs time spent
   - Tags and custom fields (if any)
   - Description (first ~10 lines)
   - Subtasks (if any)
   - Latest comments (last 5, with author and date)
   - Time entries summary

6. Use `cu-format.py task` for the main task data, then append comments and time info.
