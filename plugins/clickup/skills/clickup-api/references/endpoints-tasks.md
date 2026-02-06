# Tasks Endpoints Reference

## Get Task

```
GET /task/{task_id}
GET /task/{task_id}?include_subtasks=true&include_markdown_description=true
```

Query params:
- `include_subtasks` (bool) — include subtask objects
- `include_markdown_description` (bool) — description in markdown format
- `custom_task_ids` (bool) — use custom task ID instead of ClickUp ID
- `team_id` (string) — required if using custom_task_ids

Response key fields:
```json
{
  "id": "abc123",
  "custom_id": null,
  "name": "Task name",
  "text_content": "Description as plain text",
  "description": "Description as plain text",
  "markdown_description": "Description in **markdown**",
  "status": { "status": "open", "color": "#d3d3d3", "type": "open" },
  "orderindex": "1.00000000000000000000",
  "date_created": "1707321600000",
  "date_updated": "1707321600000",
  "date_closed": null,
  "date_done": null,
  "creator": { "id": 192240249, "username": "...", "email": "..." },
  "assignees": [{ "id": 192240249, "username": "...", "profilePicture": "..." }],
  "watchers": [],
  "checklists": [],
  "tags": [{ "name": "tag-name", "tag_fg": "#fff", "tag_bg": "#000" }],
  "parent": null,
  "priority": { "id": "2", "priority": "high", "color": "#ffcc00" },
  "due_date": "1707321600000",
  "start_date": "1707321600000",
  "points": null,
  "time_estimate": 3600000,
  "time_spent": 1800000,
  "custom_fields": [...],
  "dependencies": [],
  "linked_tasks": [],
  "list": { "id": "123", "name": "Backlog", "access": true },
  "folder": { "id": "456", "name": "Sprint 1", "hidden": false, "access": true },
  "space": { "id": "789" },
  "url": "https://app.clickup.com/t/abc123",
  "subtasks": [...]
}
```

Priority values: `1`=Urgent, `2`=High, `3`=Normal, `4`=Low, `null`=None

## Create Task

```
POST /list/{list_id}/task
```

Body:
```json
{
  "name": "Task name (required)",
  "description": "Plain text description",
  "markdown_description": "**Markdown** description",
  "assignees": [192240249],
  "tags": ["tag1", "tag2"],
  "status": "open",
  "priority": 3,
  "due_date": 1707321600000,
  "due_date_time": true,
  "start_date": 1707321600000,
  "start_date_time": true,
  "time_estimate": 3600000,
  "notify_all": false,
  "parent": "parent_task_id",
  "links_to": "task_id_to_link",
  "custom_fields": [
    { "id": "field_uuid", "value": "field value" }
  ]
}
```

Notes:
- `assignees` is an array of user IDs (integers)
- `status` must match a valid status name for the list (case-insensitive)
- `due_date` and `start_date` are Unix timestamps in **milliseconds**
- `time_estimate` is in milliseconds (3600000 = 1 hour)
- `parent` creates a subtask under the specified task

## Update Task

```
PUT /task/{task_id}
```

Body — include only fields to update:
```json
{
  "name": "Updated name",
  "description": "Updated description",
  "status": "in progress",
  "priority": 2,
  "due_date": 1707321600000,
  "assignees": { "add": [192240249], "rem": [111111] },
  "archived": false
}
```

Notes:
- `assignees` uses `add`/`rem` arrays for partial updates
- Setting `status` to a "closed" type status marks the task as done

## Delete Task

```
DELETE /task/{task_id}
```

Returns `{}` on success.

## List Tasks in List

```
GET /list/{list_id}/task
```

Query params (all optional):
- `archived` (bool) — include archived tasks
- `include_closed` (bool) — include closed/done tasks
- `page` (int) — 0-indexed, default 0
- `order_by` (string) — `created`, `updated`, `due_date`, `priority`
- `reverse` (bool) — reverse sort order
- `subtasks` (bool) — include subtasks
- `statuses[]` (string, repeatable) — filter by status names
- `assignees[]` (int, repeatable) — filter by assignee IDs
- `tags[]` (string, repeatable) — filter by tag names
- `due_date_gt` (int) — due date greater than (ms)
- `due_date_lt` (int) — due date less than (ms)
- `date_created_gt` (int) — created after (ms)
- `date_created_lt` (int) — created before (ms)
- `date_updated_gt` (int) — updated after (ms)
- `date_updated_lt` (int) — updated before (ms)
- `include_markdown_description` (bool)

Response:
```json
{
  "tasks": [...],
  "last_page": true
}
```

When `last_page` is `false`, increment `page` to get more results.

## Search Tasks (Team-wide)

```
GET /team/{team_id}/task
```

Additional query params beyond list tasks:
- `name` (string) — fuzzy search by name (URL-encoded)
- `space_ids[]` (string) — filter by space IDs
- `list_ids[]` (string) — filter by list IDs
- `folder_ids[]` (string) — filter by folder IDs
- `project_ids[]` (string) — alias for folder_ids (deprecated)

Example: Search for "deploy" across workspace:
```
GET /team/90133019410/task?name=deploy&include_closed=true
```

## Custom Fields

### Discover fields for a list
```
GET /list/{list_id}/field
```

Response:
```json
{
  "fields": [
    {
      "id": "uuid-here",
      "name": "Field Name",
      "type": "text",
      "type_config": {},
      "date_created": "...",
      "hide_from_guests": false,
      "required": false
    }
  ]
}
```

Field types: `text`, `number`, `drop_down`, `date`, `checkbox`, `url`, `email`, `phone`, `currency`, `labels`, `automatic_progress`, `short_text`, `attachment`, `relationship`

### Set custom field value
```
POST /task/{task_id}/field/{field_id}
```

Body varies by field type:
```json
{"value": "text value"}                    // text, short_text, url, email, phone
{"value": 42}                              // number, currency
{"value": true}                            // checkbox
{"value": 1707321600000}                   // date (ms)
{"value": "option_uuid"}                   // drop_down (use orderindex or uuid)
{"value": ["uuid1", "uuid2"]}             // labels (array of option uuids)
```

### Remove custom field value
```
DELETE /task/{task_id}/field/{field_id}
```

## Bulk Operations

### Update multiple tasks
```
PUT /list/{list_id}/task
```

Body:
```json
{
  "task_ids": ["abc", "def", "ghi"],
  "status": "complete",
  "priority": 3,
  "assignees": { "add": [192240249] }
}
```
