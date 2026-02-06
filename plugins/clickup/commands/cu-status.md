---
description: "Quick ClickUp dashboard - tasks grouped by status"
---

# ClickUp Status Dashboard

## Instructions

1. Read `.claude/clickup.local.md` if it exists. Use the project's default list IDs. If no local config, ask which list to check or use all lists from the current space.

2. Load config:
   ```bash
   source ~/.config/clickup/config.env
   ```

3. For each relevant list, fetch tasks (including closed):
   ```bash
   ${CLAUDE_PLUGIN_ROOT}/skills/clickup-api/scripts/cu-api.sh GET "/list/{list_id}/task?include_closed=true&page=0"
   ```

4. If a list has more than 100 tasks, use pagination:
   ```bash
   ${CLAUDE_PLUGIN_ROOT}/skills/clickup-api/scripts/cu-paginate.sh "/list/{list_id}/task?include_closed=true"
   ```

5. Group tasks by status and present a dashboard:
   ```
   ## List Name (ID: xxx)

   | Status       | Count | Overdue |
   |-------------|-------|---------|
   | to do        | 15    | 0       |
   | in progress  | 5     | 1       |
   | complete     | 22    | -       |

   Overdue tasks:
   - [Task Name](https://app.clickup.com/t/xxx) - Due: 2024-01-15

   Recently updated (last 7 days):
   - [Task Name](https://app.clickup.com/t/xxx) - Status: in progress
   ```

6. Highlight overdue tasks (due_date < now and status not closed).

7. Show total counts and a brief summary at the bottom.
