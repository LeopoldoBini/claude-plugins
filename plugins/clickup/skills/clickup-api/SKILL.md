---
name: clickup-api
description: "Full ClickUp API integration via direct curl. Use when the user asks about tasks, projects, time tracking, or any ClickUp operation. Covers 100+ endpoints: tasks CRUD, hierarchy (teams/spaces/folders/lists), comments, time entries, docs, custom fields, and more. Uses cu-api.sh wrapper with auto-auth and retry."
---

# ClickUp API - Direct Integration

You have full access to the ClickUp API v2 via helper scripts. This replaces MCP tools with direct curl for complete control over all endpoints.

## Authentication & Setup

Token resolves automatically (in order):
1. `~/.config/clickup/token` - file with just the token
2. `$CLICKUP_API_KEY` - environment variable
3. Legacy: `~/.config/saltacompra/clickup.env`

Config: `~/.config/clickup/config.env` has `CLICKUP_TEAM_ID` and other defaults.

**Auth header**: `Authorization: <token>` (no "Bearer" prefix — ClickUp personal tokens don't use Bearer).

## Helper Scripts

All scripts are in `${CLAUDE_PLUGIN_ROOT}/skills/clickup-api/scripts/`.

### cu-api.sh — Core API wrapper
```bash
# Syntax: cu-api.sh METHOD /endpoint [json_body]
cu-api.sh GET /user
cu-api.sh GET /team/${CLICKUP_TEAM_ID}/space
cu-api.sh GET /task/abc123
cu-api.sh POST /list/123/task '{"name":"New task","status":"open"}'
cu-api.sh PUT /task/abc123 '{"status":"complete"}'
cu-api.sh DELETE /task/abc123
cu-api.sh setup   # Interactive workspace discovery
```
- Auto-retry on 429 (rate limit) with exponential backoff (2s, 4s, 8s)
- Outputs raw JSON to stdout, errors to stderr
- Exit 0 on 2xx, exit 1 on errors

### cu-format.py — JSON formatter
```bash
cu-api.sh GET /list/123/task | cu-format.py tasks    # Table view
cu-api.sh GET /task/abc123 | cu-format.py task        # Card view
cu-api.sh GET /team/123/space | cu-format.py spaces   # Tree view
cu-api.sh GET /team/123/time_entries | cu-format.py time  # Time table
echo '...' | cu-format.py auto                        # Auto-detect
```

### cu-paginate.sh — Pagination handler
```bash
cu-paginate.sh "/list/123/task?statuses[]=open"  # Fetches all pages
```
Merges all results into a single JSON array. 0.3s delay between pages.

## ClickUp Hierarchy

```
Team (Workspace)
  └── Space (Project)
       ├── Folder (optional grouping)
       │    └── List (board/backlog)
       │         └── Task
       │              └── Subtask (also a task with parent)
       └── List (folderless)
            └── Task
```

## Common Operations Quick Reference

| Operation | Method | Endpoint |
|-----------|--------|----------|
| Get user info | GET | `/user` |
| List spaces | GET | `/team/{team_id}/space` |
| Get space | GET | `/space/{space_id}` |
| List folders | GET | `/space/{space_id}/folder` |
| List folderless lists | GET | `/space/{space_id}/list` |
| List folder's lists | GET | `/folder/{folder_id}/list` |
| Get list (with statuses) | GET | `/list/{list_id}` |
| **Get task** | GET | `/task/{task_id}` |
| **Create task** | POST | `/list/{list_id}/task` |
| **Update task** | PUT | `/task/{task_id}` |
| Delete task | DELETE | `/task/{task_id}` |
| List tasks in list | GET | `/list/{list_id}/task` |
| Search tasks | GET | `/team/{team_id}/task?name=term` |
| Get comments | GET | `/task/{task_id}/comment` |
| Add comment | POST | `/task/{task_id}/comment` |
| Time entries (task) | GET | `/task/{task_id}/time` |
| Time entries (team) | GET | `/team/{team_id}/time_entries` |
| Create time entry | POST | `/team/{team_id}/time_entries` |
| Get custom fields | GET | `/list/{list_id}/field` |
| Set custom field | POST | `/task/{task_id}/field/{field_id}` |

For complete endpoint documentation, see the reference files in `${CLAUDE_PLUGIN_ROOT}/skills/clickup-api/references/`.

## Reference Files (load as needed)

- `references/endpoints-tasks.md` — Tasks CRUD, filtering, custom fields, bulk ops
- `references/endpoints-hierarchy.md` — Teams, spaces, folders, lists
- `references/endpoints-advanced.md` — Comments, checklists, dependencies, attachments, tags
- `references/endpoints-time.md` — Time tracking entries and timers
- `references/endpoints-docs.md` — Documents and pages API
- `references/endpoints-admin.md` — Members, views, goals, webhooks
- `references/error-handling.md` — HTTP errors, rate limits, retry patterns
- `references/best-practices.md` — Search-before-create, URLs, timestamps, pagination

## Per-Project Context

Check `.claude/clickup.local.md` in the current project root for project-specific config:
- space_id, default list IDs, list aliases
- Status mappings and conventions
- Custom workflows

If the file exists, **always read it first** before making ClickUp API calls to use the correct IDs and follow project conventions.

## Key Rules

1. **Always search before creating** — avoid duplicates
2. **Always return clickable URLs**: `https://app.clickup.com/t/{task_id}`
3. **Discover statuses first**: `GET /list/{list_id}` → `.statuses[]` before assigning status
4. **Timestamps are Unix milliseconds** — multiply seconds × 1000
5. **Pagination is 0-indexed** — first page is `page=0`, default 100 per page
6. **IDs are strings** — always quote them in JSON bodies
7. **Rate limit**: 100 req/min for personal tokens. Script handles 429 automatically.
8. **For bulk operations**, delegate to the `clickup-explorer` agent to avoid context bloat

## Subagents

- **clickup-explorer** — Read-only bulk operations: mass searches, workspace mapping, audits. Use when operation requires many API calls.
- **clickup-reporter** — Analytics and reports: task distribution, time tracking summaries, overdue analysis.
