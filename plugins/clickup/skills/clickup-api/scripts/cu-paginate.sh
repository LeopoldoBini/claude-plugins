#!/usr/bin/env bash
# cu-paginate.sh - Fetch all pages from a ClickUp list endpoint
# Usage: cu-paginate.sh "/list/{list_id}/task[?filters]"
# Output: Single JSON array with all tasks merged
#
# Example:
#   cu-paginate.sh "/list/901325162865/task?statuses[]=open"
#   cu-paginate.sh "/list/901325162865/task?include_closed=true"

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CU_API="$SCRIPT_DIR/cu-api.sh"
DELAY=0.3

if [[ $# -lt 1 ]]; then
    echo "Usage: cu-paginate.sh \"/list/{list_id}/task[?filters]\"" >&2
    exit 1
fi

endpoint="$1"
page=0
all_tasks="[]"

# Determine separator for query params
if [[ "$endpoint" == *"?"* ]]; then
    sep="&"
else
    sep="?"
fi

while true; do
    result=$("$CU_API" GET "${endpoint}${sep}page=${page}" 2>/dev/null) || {
        echo "Error fetching page $page" >&2
        break
    }

    # Extract tasks from response
    page_tasks=$(echo "$result" | python3 -c "
import sys, json
data = json.load(sys.stdin)
tasks = data.get('tasks', [])
print(json.dumps(tasks))
" 2>/dev/null)

    # Check if empty
    count=$(echo "$page_tasks" | python3 -c "import sys,json; print(len(json.load(sys.stdin)))" 2>/dev/null)
    if [[ "$count" == "0" ]]; then
        break
    fi

    # Merge into all_tasks
    all_tasks=$(python3 -c "
import json, sys
existing = json.loads('''$all_tasks''') if '''$all_tasks''' != '[]' else []
new = json.loads(sys.stdin.read())
existing.extend(new)
print(json.dumps(existing))
" <<< "$page_tasks" 2>/dev/null)

    echo "Page $page: $count tasks" >&2

    # Check last_page
    last_page=$(echo "$result" | python3 -c "import sys,json; print(json.load(sys.stdin).get('last_page', True))" 2>/dev/null)
    if [[ "$last_page" == "True" ]]; then
        break
    fi

    page=$((page + 1))
    sleep "$DELAY"
done

total=$(echo "$all_tasks" | python3 -c "import sys,json; print(len(json.load(sys.stdin)))" 2>/dev/null)
echo "Total: $total tasks across $((page + 1)) pages" >&2

# Output merged result in same format as API
echo "{\"tasks\": $all_tasks, \"last_page\": true}"
