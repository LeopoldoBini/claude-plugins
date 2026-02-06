# Time Tracking Endpoints Reference

## Get Time Entries (Team)

```
GET /team/{team_id}/time_entries
```

Query params:
- `start_date` (int) — Start of range in Unix ms (default: 30 days ago)
- `end_date` (int) — End of range in Unix ms (default: now)
- `assignee` (int) — Filter by user ID (comma-separated for multiple)
- `include_task_tags` (bool)
- `include_location_names` (bool)
- `space_id` (int) — Filter by space
- `folder_id` (int) — Filter by folder
- `list_id` (int) — Filter by list
- `task_id` (string) — Filter by task

Response:
```json
{
  "data": [
    {
      "id": "time_entry_id",
      "task": {
        "id": "task_id",
        "name": "Task Name",
        "status": { "status": "in progress" },
        "custom_type": null
      },
      "wid": "team_id",
      "user": {
        "id": 192240249,
        "username": "Raul Leopoldo Bini",
        "profilePicture": "..."
      },
      "billable": false,
      "start": "1707321600000",
      "end": "1707325200000",
      "duration": "3600000",
      "description": "Working on feature",
      "tags": [],
      "source": "clickup",
      "at": "1707325200000"
    }
  ]
}
```

Duration is in milliseconds. 3600000 = 1 hour.

## Get Time Entries (Task)

```
GET /task/{task_id}/time
```

Returns time entries only for the specified task.

## Create Time Entry

```
POST /team/{team_id}/time_entries
```

Body:
```json
{
  "description": "Work description",
  "start": 1707321600000,
  "duration": 3600000,
  "assignee": 192240249,
  "tid": "task_id",
  "billable": false,
  "tags": [{ "name": "dev" }]
}
```

Notes:
- `start` is Unix ms timestamp (when work started)
- `duration` is in milliseconds
- `tid` is the task ID to track time against
- If `end` is provided instead of `duration`, duration is calculated

Helper to calculate duration:
```bash
# 2.5 hours in ms
echo $((2 * 3600000 + 30 * 60000))  # 9000000

# or in Python
python3 -c "print(int(2.5 * 3600000))"  # 9000000
```

## Update Time Entry

```
PUT /team/{team_id}/time_entries/{time_entry_id}
```

Body (include only fields to update):
```json
{
  "description": "Updated description",
  "start": 1707321600000,
  "duration": 7200000,
  "tid": "new_task_id",
  "billable": true,
  "tags": [{ "name": "updated-tag" }]
}
```

## Delete Time Entry

```
DELETE /team/{team_id}/time_entries/{time_entry_id}
```

## Running Timer

### Get running timer
```
GET /team/{team_id}/time_entries/current
```

Response:
```json
{
  "data": {
    "id": "timer_id",
    "task": { "id": "task_id", "name": "..." },
    "start": "1707321600000",
    "duration": null
  }
}
```

If no timer running, `data` is null or empty.

### Start timer
```
POST /team/{team_id}/time_entries/start
```

Body:
```json
{
  "tid": "task_id",
  "description": "Starting work",
  "billable": false
}
```

### Stop timer
```
POST /team/{team_id}/time_entries/stop
```

Returns the completed time entry with calculated duration.

## Useful Patterns

### Total time for a task
```bash
CU_API="${CLAUDE_PLUGIN_ROOT}/skills/clickup-api/scripts/cu-api.sh"
"$CU_API" GET "/task/abc123/time" | python3 -c "
import sys, json
data = json.load(sys.stdin)
entries = data.get('data', [])
total_ms = sum(int(e.get('duration', 0)) for e in entries)
hours = total_ms / 3600000
print(f'Total: {hours:.1f}h across {len(entries)} entries')
"
```

### This week's time entries
```bash
# Start of this week (Monday) in ms
start_ms=$(python3 -c "
from datetime import datetime, timedelta
now = datetime.now()
monday = now - timedelta(days=now.weekday())
monday = monday.replace(hour=0, minute=0, second=0, microsecond=0)
print(int(monday.timestamp() * 1000))
")
"$CU_API" GET "/team/${CLICKUP_TEAM_ID}/time_entries?start_date=$start_ms"
```

### Book time (helper)
```bash
# Book 2 hours on task abc123, starting now
now_ms=$(($(date +%s) * 1000))
dur_ms=$((2 * 3600000))
"$CU_API" POST "/team/${CLICKUP_TEAM_ID}/time_entries" "{
  \"tid\": \"abc123\",
  \"start\": $now_ms,
  \"duration\": $dur_ms,
  \"description\": \"Development work\"
}"
```
