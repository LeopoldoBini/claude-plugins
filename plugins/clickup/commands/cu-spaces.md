---
description: "Show ClickUp workspace tree (spaces, folders, lists)"
---

# ClickUp Spaces Overview

## Instructions

1. Read `.claude/clickup.local.md` if it exists for project context.

2. Load config:
   ```bash
   source ~/.config/clickup/config.env
   ```

3. Fetch spaces:
   ```bash
   ${CLAUDE_PLUGIN_ROOT}/skills/clickup-api/scripts/cu-api.sh GET "/team/${CLICKUP_TEAM_ID}/space?archived=false"
   ```

4. For each space, fetch folders and folderless lists:
   ```bash
   # Folders (contain lists inside)
   ${CLAUDE_PLUGIN_ROOT}/skills/clickup-api/scripts/cu-api.sh GET "/space/{space_id}/folder?archived=false"

   # Folderless lists
   ${CLAUDE_PLUGIN_ROOT}/skills/clickup-api/scripts/cu-api.sh GET "/space/{space_id}/list?archived=false"
   ```

5. Present as a tree structure:
   ```
   Workspace: {team_name} (ID: {team_id})

   Space: SALTACOMPRA (ID: 901313136201)
     Folder: Folder Name (ID: xxx)
       List: List Name (ID: xxx) [42 tasks]
       List: List Name (ID: xxx) [15 tasks]
     List: Folderless List (ID: xxx) [8 tasks]

   Space: EDDI (ID: 901313136879)
     ...
   ```

6. Include task counts for each list and clickable URLs.
