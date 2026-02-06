# Error Handling Reference

## HTTP Status Codes

| Code | Meaning | Action |
|------|---------|--------|
| 200 | Success | Process response |
| 201 | Created | Process response (POST operations) |
| 204 | No Content | Success, no body (DELETE operations) |
| 400 | Bad Request | Check request body/params |
| 401 | Unauthorized | Token invalid or expired |
| 403 | Forbidden | No permission for this resource |
| 404 | Not Found | Resource doesn't exist or wrong ID |
| 429 | Rate Limited | Wait and retry (cu-api.sh handles this) |
| 500 | Server Error | ClickUp issue, retry later |
| 503 | Service Unavailable | ClickUp down, retry later |

## Error Response Format

```json
{
  "err": "Human-readable error message",
  "ECODE": "ERROR_CODE"
}
```

Common ECODE values:
- `OAUTH_023` — Invalid token
- `ITEM_015` — Task not found
- `ITEM_019` — Cannot set that status (invalid for list)
- `TEAM_025` — Rate limit exceeded
- `INPUT_005` — Missing required field

## Rate Limiting

- **Personal tokens**: 100 requests per minute
- **Response headers**:
  - `X-RateLimit-Limit`: Max requests per minute
  - `X-RateLimit-Remaining`: Remaining requests
  - `X-RateLimit-Reset`: Unix timestamp when limit resets

`cu-api.sh` handles 429 automatically with exponential backoff (2s → 4s → 8s, max 3 retries).

For bulk operations with many calls, add manual delays:
```bash
sleep 0.6  # ~100 req/min = 1 req/0.6s
```

## Common Error Scenarios

### "Task not found" but ID looks correct
- Task might be in Trash — check with `include_closed=true`
- Using custom task ID without `custom_task_ids=true&team_id=...`
- Task was permanently deleted

### "Status not valid for this list"
- Always discover statuses first: `GET /list/{list_id}` → `.statuses[].status`
- Status names are case-insensitive but must match exactly

### "Team not authorized"
- Token doesn't have access to this workspace
- Verify with `GET /team` to list accessible teams

### Empty response from list tasks
- Check `include_closed=true` if expecting completed tasks
- Verify list_id is correct
- Check if filtering params are too restrictive

## Retry Pattern (manual)

```bash
SCRIPT="${CLAUDE_PLUGIN_ROOT}/skills/clickup-api/scripts/cu-api.sh"

# For operations beyond cu-api.sh's built-in retry:
for i in 1 2 3; do
    result=$("$SCRIPT" GET /task/abc123 2>/dev/null) && break
    sleep $((i * 2))
done
```
