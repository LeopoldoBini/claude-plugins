# Hierarchy Endpoints Reference

## Teams (Workspaces)

### Get authorized teams
```
GET /team
```

Response:
```json
{
  "teams": [
    {
      "id": "90133019410",
      "name": "Workspace Name",
      "color": "#000000",
      "avatar": null,
      "members": [
        {
          "user": {
            "id": 192240249,
            "username": "Name",
            "email": "...",
            "profilePicture": "..."
          },
          "role": 1
        }
      ]
    }
  ]
}
```

Roles: `1`=Owner, `2`=Admin, `3`=Member, `4`=Guest

## Spaces

### List spaces
```
GET /team/{team_id}/space?archived=false
```

Response:
```json
{
  "spaces": [
    {
      "id": "901313136201",
      "name": "SALTACOMPRA",
      "private": false,
      "statuses": [
        { "status": "Open", "type": "open", "color": "#d3d3d3" },
        { "status": "in progress", "type": "custom", "color": "#4194f6" },
        { "status": "Closed", "type": "closed", "color": "#6bc950" }
      ],
      "multiple_assignees": true,
      "features": {
        "due_dates": { "enabled": true },
        "time_tracking": { "enabled": true },
        "tags": { "enabled": true },
        "custom_fields": { "enabled": true },
        "checklists": { "enabled": true }
      }
    }
  ]
}
```

### Get space
```
GET /space/{space_id}
```

### Create space
```
POST /team/{team_id}/space
```

Body:
```json
{
  "name": "Space Name",
  "multiple_assignees": true,
  "features": {
    "due_dates": { "enabled": true },
    "time_tracking": { "enabled": true },
    "tags": { "enabled": true }
  }
}
```

### Update space
```
PUT /space/{space_id}
```

### Delete space
```
DELETE /space/{space_id}
```

## Folders

### List folders in space
```
GET /space/{space_id}/folder?archived=false
```

Response:
```json
{
  "folders": [
    {
      "id": "folder_id",
      "name": "Folder Name",
      "orderindex": 0,
      "override_statuses": false,
      "hidden": false,
      "space": { "id": "space_id", "name": "Space" },
      "task_count": "15",
      "lists": [
        {
          "id": "list_id",
          "name": "List Name",
          "task_count": 10,
          "status": {}
        }
      ]
    }
  ]
}
```

### Get folder
```
GET /folder/{folder_id}
```

### Create folder
```
POST /space/{space_id}/folder
```

Body: `{"name": "New Folder"}`

### Update / Delete folder
```
PUT /folder/{folder_id}
DELETE /folder/{folder_id}
```

## Lists

### List folderless lists in space
```
GET /space/{space_id}/list?archived=false
```

### List lists in folder
```
GET /folder/{folder_id}/list?archived=false
```

Response:
```json
{
  "lists": [
    {
      "id": "901325162865",
      "name": "Implementados",
      "orderindex": 0,
      "content": "List description (markdown)",
      "status": {},
      "priority": {},
      "assignee": null,
      "task_count": 42,
      "due_date": null,
      "start_date": null,
      "folder": { "id": "...", "name": "...", "hidden": false, "access": true },
      "space": { "id": "901313136201", "name": "SALTACOMPRA", "access": true },
      "archived": false,
      "override_statuses": true,
      "statuses": [
        { "status": "to do", "type": "open", "orderindex": 0, "color": "#d3d3d3" },
        { "status": "in progress", "type": "custom", "orderindex": 1, "color": "#4194f6" },
        { "status": "done", "type": "closed", "orderindex": 2, "color": "#6bc950" }
      ],
      "permission_level": "create"
    }
  ]
}
```

### Get list (includes statuses)
```
GET /list/{list_id}
```

**Important**: Always GET the list first to discover valid `statuses[]` before creating/updating tasks.

### Create list
```
POST /space/{space_id}/list         # Folderless
POST /folder/{folder_id}/list       # In folder
```

Body:
```json
{
  "name": "List Name",
  "content": "Description",
  "due_date": 1707321600000,
  "priority": 2,
  "status": "active"
}
```

### Update / Delete list
```
PUT /list/{list_id}
DELETE /list/{list_id}
```

## List Members (useful for assignee discovery)
```
GET /list/{list_id}/member
```

Response: `{"members": [{"id": 192240249, "username": "...", ...}]}`

## Task Statuses Discovery Pattern

To get valid statuses for a task:
1. Get the list: `GET /list/{list_id}` → check `statuses[]`
2. If `override_statuses` is false, check space-level statuses: `GET /space/{space_id}`
3. Status names are case-insensitive when setting on tasks
