#!/usr/bin/env python3
"""cu-format.py - Format ClickUp JSON responses into readable output.

Usage: echo '...' | cu-format.py [mode]

Modes:
  tasks  - Table of tasks (from list tasks response)
  task   - Detailed card for a single task
  spaces - Tree of spaces/folders/lists
  time   - Time entries table
  auto   - Auto-detect (default)
"""

import json
import sys
from datetime import datetime


def ms_to_date(ms):
    """Convert milliseconds timestamp to readable date."""
    if not ms:
        return "-"
    try:
        return datetime.fromtimestamp(int(ms) / 1000).strftime("%Y-%m-%d")
    except (ValueError, TypeError, OSError):
        return "-"


def ms_to_datetime(ms):
    if not ms:
        return "-"
    try:
        return datetime.fromtimestamp(int(ms) / 1000).strftime("%Y-%m-%d %H:%M")
    except (ValueError, TypeError, OSError):
        return "-"


def ms_to_hours(ms):
    """Convert milliseconds to hours string."""
    if not ms:
        return "-"
    try:
        hours = int(ms) / 3600000
        if hours < 1:
            return f"{int(hours * 60)}m"
        return f"{hours:.1f}h"
    except (ValueError, TypeError):
        return "-"


def priority_label(p):
    if not p or not isinstance(p, dict):
        return "-"
    return p.get("priority", "-") or "-"


def truncate(s, length=40):
    s = str(s or "")
    return s[:length - 1] + "~" if len(s) > length else s


def format_tasks(data):
    """Format task list as table."""
    tasks = data if isinstance(data, list) else data.get("tasks", [])
    if not tasks:
        print("No tasks found.")
        return

    print(f"{'ID':<12} {'Status':<16} {'Pri':<8} {'Assignee':<18} {'Due':<12} {'Name'}")
    print("-" * 100)
    for t in tasks:
        tid = t.get("id", "?")
        status = t.get("status", {}).get("status", "?") if isinstance(t.get("status"), dict) else "?"
        pri = priority_label(t.get("priority"))
        assignees = t.get("assignees", [])
        assignee = assignees[0].get("username", "?")[:16] if assignees else "-"
        due = ms_to_date(t.get("due_date"))
        name = truncate(t.get("name", "?"), 50)
        print(f"{tid:<12} {status:<16} {pri:<8} {assignee:<18} {due:<12} {name}")

    print(f"\nTotal: {len(tasks)} tasks")
    if isinstance(data, dict) and not data.get("last_page", True):
        print("(more pages available)")


def format_task(data):
    """Format single task as detailed card."""
    t = data
    print(f"{'=' * 60}")
    print(f"  {t.get('name', '?')}")
    print(f"{'=' * 60}")
    print(f"  ID:       {t.get('id', '?')}")
    print(f"  URL:      https://app.clickup.com/t/{t.get('id', '?')}")
    print(f"  Status:   {t.get('status', {}).get('status', '?')}")
    print(f"  Priority: {priority_label(t.get('priority'))}")

    assignees = t.get("assignees", [])
    if assignees:
        names = ", ".join(a.get("username", "?") for a in assignees)
        print(f"  Assigned: {names}")
    else:
        print(f"  Assigned: -")

    print(f"  List:     {t.get('list', {}).get('name', '?')} ({t.get('list', {}).get('id', '?')})")
    print(f"  Space:    {t.get('space', {}).get('id', '?')}")
    print(f"  Created:  {ms_to_datetime(t.get('date_created'))}")
    print(f"  Updated:  {ms_to_datetime(t.get('date_updated'))}")
    print(f"  Due:      {ms_to_date(t.get('due_date'))}")
    print(f"  Start:    {ms_to_date(t.get('start_date'))}")
    print(f"  Estimate: {ms_to_hours(t.get('time_estimate'))}")
    print(f"  Spent:    {ms_to_hours(t.get('time_spent'))}")

    tags = t.get("tags", [])
    if tags:
        print(f"  Tags:     {', '.join(tg.get('name', '?') for tg in tags)}")

    # Custom fields
    cfs = t.get("custom_fields", [])
    if cfs:
        print(f"\n  Custom Fields:")
        for cf in cfs:
            val = cf.get("value")
            if val is not None:
                name = cf.get("name", "?")
                if isinstance(val, dict):
                    val = val.get("name", val.get("value", str(val)))
                print(f"    {name}: {val}")

    # Description
    desc = t.get("text_content") or t.get("description") or ""
    if desc:
        print(f"\n  Description:")
        for line in desc.strip().split("\n")[:10]:
            print(f"    {line}")
        if desc.count("\n") > 10:
            print(f"    ... (truncated)")

    # Subtasks
    subtasks = t.get("subtasks", [])
    if subtasks:
        print(f"\n  Subtasks ({len(subtasks)}):")
        for st in subtasks[:10]:
            s_status = st.get("status", {}).get("status", "?")
            print(f"    [{s_status}] {st.get('name', '?')} ({st.get('id', '?')})")

    print(f"{'=' * 60}")


def format_spaces(data):
    """Format spaces response as tree."""
    spaces = data if isinstance(data, list) else data.get("spaces", [])
    if not spaces:
        print("No spaces found.")
        return

    for sp in spaces:
        print(f"Space: {sp.get('name', '?')} (ID: {sp.get('id', '?')})")

        # Check for folders if included
        folders = sp.get("folders", [])
        for f in folders:
            task_count = f.get("task_count", "?")
            print(f"  Folder: {f.get('name', '?')} (ID: {f.get('id', '?')}) [{task_count} tasks]")
            for lst in f.get("lists", []):
                tc = lst.get("task_count", "?")
                print(f"    List: {lst.get('name', '?')} (ID: {lst.get('id', '?')}) [{tc} tasks]")

        # Folderless lists
        lists = sp.get("lists", [])
        for lst in lists:
            tc = lst.get("task_count", "?")
            print(f"  List: {lst.get('name', '?')} (ID: {lst.get('id', '?')}) [{tc} tasks]")

        # Statuses
        statuses = sp.get("statuses", [])
        if statuses:
            status_str = ", ".join(s.get("status", "?") for s in statuses)
            print(f"  Statuses: {status_str}")

        print()


def format_time(data):
    """Format time entries as table."""
    entries = data if isinstance(data, list) else data.get("data", [])
    if not entries:
        print("No time entries found.")
        return

    total_ms = 0
    print(f"{'Date':<12} {'Hours':<8} {'Task':<30} {'User':<20} {'Description'}")
    print("-" * 100)
    for e in entries:
        start = ms_to_date(e.get("start"))
        duration = int(e.get("duration", 0))
        total_ms += duration
        hours = ms_to_hours(duration)
        task = e.get("task", {})
        task_name = truncate(task.get("name", "-"), 28) if task else "-"
        user = truncate(e.get("user", {}).get("username", "-"), 18)
        desc = truncate(e.get("description", ""), 30)
        print(f"{start:<12} {hours:<8} {task_name:<30} {user:<20} {desc}")

    print(f"\nTotal: {len(entries)} entries, {ms_to_hours(total_ms)} total")


def auto_detect(data):
    """Auto-detect response type and format."""
    if isinstance(data, list):
        if data and "duration" in data[0]:
            return "time"
        if data and "status" in data[0] and "name" in data[0]:
            return "tasks"
        if data and "statuses" in data[0]:
            return "spaces"
        return "tasks"

    if "tasks" in data:
        return "tasks"
    if "spaces" in data:
        return "spaces"
    if "data" in data and isinstance(data["data"], list):
        if data["data"] and "duration" in data["data"][0]:
            return "time"
    if "status" in data and "name" in data and "id" in data:
        if "assignees" in data:
            return "task"
        if "statuses" in data:
            return "spaces"
    if "teams" in data:
        return "spaces"

    return "task"


def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else "auto"

    try:
        raw = sys.stdin.read()
        data = json.loads(raw)
    except json.JSONDecodeError as e:
        print(f"Error parsing JSON: {e}", file=sys.stderr)
        print(raw[:500] if raw else "(empty input)")
        sys.exit(1)

    if mode == "auto":
        mode = auto_detect(data)

    formatters = {
        "tasks": format_tasks,
        "task": format_task,
        "spaces": format_spaces,
        "time": format_time,
    }

    formatter = formatters.get(mode)
    if formatter:
        formatter(data)
    else:
        print(f"Unknown mode: {mode}. Use: tasks, task, spaces, time, auto", file=sys.stderr)
        print(json.dumps(data, indent=2)[:2000])
        sys.exit(1)


if __name__ == "__main__":
    main()
