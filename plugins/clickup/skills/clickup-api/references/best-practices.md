# Best Practices Reference

## Search Before Create

Always search for existing tasks before creating new ones to avoid duplicates:

```bash
SCRIPT="${CLAUDE_PLUGIN_ROOT}/skills/clickup-api/scripts/cu-api.sh"

# Search team-wide by name
"$SCRIPT" GET "/team/${CLICKUP_TEAM_ID}/task?name=deploy%20pipeline"

# Search within a specific list
"$SCRIPT" GET "/list/901325162865/task?page=0"
```

## Always Return Clickable URLs

When presenting tasks to the user, always include the clickable URL:
```
https://app.clickup.com/t/{task_id}
```

For lists:
```
https://app.clickup.com/90133019410/v/li/{list_id}
```

For spaces:
```
https://app.clickup.com/90133019410/v/s/{space_id}
```

## Discover Statuses Before Assigning

```bash
SCRIPT="${CLAUDE_PLUGIN_ROOT}/skills/clickup-api/scripts/cu-api.sh"

# Get valid statuses for a list
"$SCRIPT" GET /list/901325162865 | python3 -c "
import sys, json
data = json.load(sys.stdin)
for s in data.get('statuses', []):
    print(f\"  {s['status']} ({s['type']})\")
"
```

## Timestamps

ClickUp uses **Unix milliseconds** everywhere:
```python
# Python: datetime to ClickUp timestamp
import time
ts_ms = int(time.time() * 1000)

# Bash: current time in ms
echo $(($(date +%s) * 1000))

# Specific date (2024-01-15 23:59:59)
echo $(($(date -j -f "%Y-%m-%d %H:%M:%S" "2024-01-15 23:59:59" +%s) * 1000))
```

## Pagination

- Pages are **0-indexed** (first page is `page=0`)
- Default page size is 100 tasks
- Check `last_page` field — when `true`, you have all results
- For automated full retrieval, use `cu-paginate.sh`

```bash
# Manual pagination
page=0
while true; do
    result=$("$SCRIPT" GET "/list/123/task?page=$page")
    # process result...
    last_page=$(echo "$result" | python3 -c "import sys,json; print(json.load(sys.stdin).get('last_page', True))")
    [[ "$last_page" == "True" ]] && break
    page=$((page + 1))
    sleep 0.3
done
```

## Project-Specific Context

Always check for `.claude/clickup.local.md` in the project root:

```bash
# Find and read project context
local_config=""
for dir in . .. ../.. ; do
    if [[ -f "$dir/.claude/clickup.local.md" ]]; then
        local_config="$dir/.claude/clickup.local.md"
        break
    fi
done
```

This file contains:
- YAML frontmatter with space_id, list IDs, aliases
- Markdown body with project conventions and workflows

## Assignee Discovery

```bash
# List members of a list (can assign tasks to these users)
"$SCRIPT" GET /list/901325162865/member

# Common user: Raul Leopoldo Bini = 192240249
```

## Efficient Patterns

### Get task with all context
```bash
"$SCRIPT" GET "/task/abc123?include_subtasks=true&include_markdown_description=true"
```

### Filter tasks by multiple statuses
```bash
"$SCRIPT" GET '/list/123/task?statuses[]=open&statuses[]=in%20progress'
```

### Create task with full metadata
```bash
"$SCRIPT" POST /list/123/task '{
  "name": "Task name",
  "markdown_description": "## Details\n\nDescription here",
  "assignees": [192240249],
  "status": "open",
  "priority": 3,
  "tags": ["implementation"],
  "due_date": '"$(($(date +%s) * 1000 + 86400000))"',
  "due_date_time": true
}'
```

### Batch status check (are my tasks done?)
```bash
"$SCRIPT" GET '/list/123/task?assignees[]=192240249&statuses[]=complete&include_closed=true'
```

## When to Use Subagents

Delegate to `clickup-explorer` when:
- Searching across multiple spaces or lists
- Fetching >50 tasks (pagination needed)
- Mapping workspace structure
- Any operation that would make >5 API calls

Delegate to `clickup-reporter` when:
- User asks for summaries, reports, or analytics
- Time tracking analysis
- Status distribution across lists
- Overdue task analysis
