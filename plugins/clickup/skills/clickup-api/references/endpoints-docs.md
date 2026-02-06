# Docs Endpoints Reference

## Search Docs

```
GET /team/{team_id}/doc
```

Query params:
- `workspace_id` (string) — Same as team_id

Response:
```json
{
  "docs": [
    {
      "id": "doc_id",
      "name": "Document Title",
      "workspace_id": "team_id",
      "creator": 192240249,
      "date_created": "1707321600000",
      "date_updated": "1707321600000",
      "deleted": false,
      "parent": {
        "id": "parent_id",
        "type": 7
      },
      "pages": [
        {
          "id": "page_id",
          "name": "Page Title",
          "orderindex": 0,
          "date_created": "...",
          "pages": []
        }
      ]
    }
  ]
}
```

Parent types: `4`=Space, `5`=Folder, `6`=List, `7`=Everything level

## Get Doc Pages

```
GET /doc/{doc_id}/page
```

Lists all pages in the document with their hierarchy.

## Get Page Content

```
GET /doc/{doc_id}/page/{page_id}
```

Response:
```json
{
  "id": "page_id",
  "name": "Page Title",
  "content": "# Markdown content\n\nPage content in markdown...",
  "orderindex": 0,
  "date_created": "...",
  "date_updated": "...",
  "creator": 192240249,
  "deleted": false,
  "archived": false,
  "protected": false,
  "pages": []
}
```

## Create Doc

```
POST /doc
```

Body:
```json
{
  "name": "New Document",
  "parent": {
    "id": "space_id_or_list_id",
    "type": 4
  },
  "visibility": "PUBLIC",
  "create_page": true
}
```

Parent types for creation:
- `4` — Space
- `5` — Folder
- `6` — List

## Create Page

```
POST /doc/{doc_id}/page
```

Body:
```json
{
  "name": "New Page",
  "content": "# Page Content\n\nMarkdown here...",
  "orderindex": 0,
  "parent_page_id": "optional_parent_page_id"
}
```

## Update Page

```
PUT /doc/{doc_id}/page/{page_id}
```

Body (include only fields to update):
```json
{
  "name": "Updated Title",
  "content": "# Updated Content\n\nNew content...",
  "protected": false,
  "archived": false
}
```

**Warning**: Setting `content` replaces the entire page content. To append, first GET the page, append to content, then PUT.

## Delete Page

```
DELETE /doc/{doc_id}/page/{page_id}
```

## Doc URLs

```
https://app.clickup.com/{team_id}/v/dc/{doc_id}/{page_id}
```

Example: `https://app.clickup.com/90133019410/v/dc/abc123/def456`
