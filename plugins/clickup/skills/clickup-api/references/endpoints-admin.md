# Admin Endpoints Reference

## Members

### Get workspace members
```
GET /team/{team_id}
```
Members are in the `teams[0].members[]` array from the `/team` response.

### Get list members
```
GET /list/{list_id}/member
```

### Get task members (watchers + assignees)
```
GET /task/{task_id}
```
Check `assignees[]` and `watchers[]` in the task response.

### Invite user to workspace
```
POST /team/{team_id}/user
```
Body: `{"email": "user@example.com"}`

## Views

### Get list views
```
GET /list/{list_id}/view
```

### Get space views
```
GET /space/{space_id}/view
```

### Get view
```
GET /view/{view_id}
```

Response:
```json
{
  "view": {
    "id": "view_id",
    "name": "Board View",
    "type": "board",
    "parent": { "id": "list_id", "type": 6 },
    "grouping": { "field": "status" },
    "sorting": { "fields": [] },
    "filters": { "fields": [] },
    "columns": { "fields": [] },
    "settings": {}
  }
}
```

View types: `list`, `board`, `calendar`, `gantt`, `table`, `timeline`, `workload`, `map`, `activity`

### Get view tasks
```
GET /view/{view_id}/task
```
Returns tasks as filtered/sorted by the view, with pagination.

## Goals

### List goals
```
GET /team/{team_id}/goal
```

### Get goal
```
GET /goal/{goal_id}
```

Response:
```json
{
  "goal": {
    "id": "goal_id",
    "name": "Q1 Objectives",
    "team_id": "team_id",
    "creator": 192240249,
    "color": "#000000",
    "date_created": "...",
    "start_date": null,
    "due_date": "1707321600000",
    "description": "...",
    "private": false,
    "archived": false,
    "multiple_owners": true,
    "folder_id": null,
    "members": [],
    "key_results": [
      {
        "id": "kr_id",
        "name": "Key Result 1",
        "type": "number",
        "steps_start": 0,
        "steps_end": 100,
        "steps_current": 42,
        "unit": "%"
      }
    ],
    "percent_completed": 42
  }
}
```

### Create goal
```
POST /team/{team_id}/goal
```

Body:
```json
{
  "name": "Goal Name",
  "due_date": 1707321600000,
  "description": "Goal description",
  "multiple_owners": true,
  "owners": [192240249],
  "color": "#000000"
}
```

### Create key result
```
POST /goal/{goal_id}/key_result
```

Body:
```json
{
  "name": "Key Result",
  "owners": [192240249],
  "type": "number",
  "steps_start": 0,
  "steps_end": 100,
  "unit": "%",
  "task_ids": [],
  "list_ids": []
}
```

Key result types: `number`, `currency`, `boolean`, `percentage`, `automatic`

## Webhooks

### List webhooks
```
GET /team/{team_id}/webhook
```

### Create webhook
```
POST /team/{team_id}/webhook
```

Body:
```json
{
  "endpoint": "https://your-server.com/webhook",
  "events": [
    "taskCreated",
    "taskUpdated",
    "taskDeleted",
    "taskStatusUpdated",
    "taskAssigneeUpdated",
    "taskDueDateUpdated",
    "taskCommentPosted"
  ],
  "space_id": "space_id",
  "folder_id": "folder_id",
  "list_id": "list_id",
  "task_id": "task_id"
}
```

Available events:
- `taskCreated`, `taskUpdated`, `taskDeleted`, `taskMoved`
- `taskStatusUpdated`, `taskAssigneeUpdated`, `taskDueDateUpdated`
- `taskPriorityUpdated`, `taskTagUpdated`
- `taskCommentPosted`, `taskCommentUpdated`
- `taskTimeEstimateUpdated`, `taskTimeTrackedUpdated`
- `listCreated`, `listUpdated`, `listDeleted`
- `folderCreated`, `folderUpdated`, `folderDeleted`
- `spaceCreated`, `spaceUpdated`, `spaceDeleted`
- `goalCreated`, `goalUpdated`, `goalDeleted`
- `keyResultCreated`, `keyResultUpdated`, `keyResultDeleted`

### Update webhook
```
PUT /webhook/{webhook_id}
```

### Delete webhook
```
DELETE /webhook/{webhook_id}
```

## Templates

### Get task templates
```
GET /team/{team_id}/taskTemplate?page=0
```

### Create task from template
```
POST /list/{list_id}/taskTemplate/{template_id}
```

Body: `{"name": "Task from template"}`
