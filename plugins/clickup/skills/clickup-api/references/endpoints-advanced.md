# Advanced Endpoints Reference

## Comments

### Get task comments
```
GET /task/{task_id}/comment
```

Query params:
- `start` (int) — comment ID to start from
- `start_id` (string) — comment ID cursor

Response:
```json
{
  "comments": [
    {
      "id": "comment_id",
      "comment": [
        { "text": "Comment text content" }
      ],
      "comment_text": "Plain text version",
      "user": { "id": 192240249, "username": "...", "profilePicture": "..." },
      "date": "1707321600000",
      "resolved": false
    }
  ]
}
```

### Create comment on task
```
POST /task/{task_id}/comment
```

Body:
```json
{
  "comment_text": "Plain text comment",
  "notify_all": false,
  "assignee": 192240249
}
```

For rich text:
```json
{
  "comment": [
    { "text": "Hello " },
    { "text": "world", "attributes": { "bold": true } },
    { "text": "\n" }
  ]
}
```

### Update/Delete comment
```
PUT /comment/{comment_id}
DELETE /comment/{comment_id}
```

### Comments on lists/views
```
GET /list/{list_id}/comment
POST /list/{list_id}/comment
GET /view/{view_id}/comment
POST /view/{view_id}/comment
```

## Checklists

### Create checklist on task
```
POST /task/{task_id}/checklist
```

Body: `{"name": "Checklist Name"}`

### Create checklist item
```
POST /checklist/{checklist_id}/checklist_item
```

Body:
```json
{
  "name": "Item name",
  "assignee": 192240249
}
```

### Update checklist item (toggle resolved)
```
PUT /checklist/{checklist_id}/checklist_item/{checklist_item_id}
```

Body: `{"resolved": true}` or `{"name": "Updated name"}`

### Delete checklist / item
```
DELETE /checklist/{checklist_id}
DELETE /checklist/{checklist_id}/checklist_item/{checklist_item_id}
```

## Dependencies

### Add dependency
```
POST /task/{task_id}/dependency
```

Body:
```json
{
  "depends_on": "other_task_id"
}
```

Or for "blocking" direction:
```json
{
  "dependency_of": "other_task_id"
}
```

### Remove dependency
```
DELETE /task/{task_id}/dependency?depends_on={other_task_id}
DELETE /task/{task_id}/dependency?dependency_of={other_task_id}
```

### Link tasks (related, not blocking)
```
POST /task/{task_id}/link/{links_to_task_id}
DELETE /task/{task_id}/link/{links_to_task_id}
```

## Tags

### Get space tags
```
GET /space/{space_id}/tag
```

Response:
```json
{
  "tags": [
    { "name": "urgent", "tag_fg": "#fff", "tag_bg": "#ff0000" }
  ]
}
```

### Create space tag
```
POST /space/{space_id}/tag
```

Body: `{"tag": {"name": "new-tag", "tag_fg": "#fff", "tag_bg": "#000"}}`

### Add tag to task
```
POST /task/{task_id}/tag/{tag_name}
```

### Remove tag from task
```
DELETE /task/{task_id}/tag/{tag_name}
```

## Attachments

### Upload attachment to task
```bash
# Note: multipart/form-data, not JSON
curl -X POST "https://api.clickup.com/api/v2/task/{task_id}/attachment" \
  -H "Authorization: $TOKEN" \
  -F "attachment=@/path/to/file.pdf" \
  -F "filename=file.pdf"
```

Response:
```json
{
  "id": "attachment_id",
  "url": "https://...",
  "title": "file.pdf",
  "extension": "pdf",
  "thumbnail_small": "...",
  "thumbnail_large": "..."
}
```

Note: For attachments, use curl directly (not cu-api.sh) since it requires multipart form data.
