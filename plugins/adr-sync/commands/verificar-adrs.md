---
description: Full ADR consistency review — cross-references ALL ADRs against project documentation
allowed-tools: Read, Grep, Glob, Write, Edit
argument-hint: [--fix]
---

Perform a comprehensive ADR consistency review for this project, regardless of sync status.

## Setup

1. Read project configuration from `.claude/adr-sync.local.md`
   - If it doesn't exist, inform the user they need to run `/setup-adr-sync` first and stop.
2. Extract: `adr_path`, `adr_pattern`, `sync_targets`, `auto_update`
3. Read the project context from the markdown body of the settings file

## Discovery

1. Use Glob to find ALL ADR files matching the configured pattern in the ADR directory
2. For each ADR found:
   - Read the file
   - Check if it has YAML frontmatter with `sync_status`
   - Extract the decision, status (Accepted/Deprecated/Superseded), and key information
3. Build a complete inventory:
   - Total ADRs found
   - Synced vs unsynced
   - Deprecated/superseded ones

## Cross-Reference Analysis

For each sync target file configured:
1. Read the file completely
2. For EACH ADR (not just unsynced ones), check:
   - Is the ADR's decision reflected in this file?
   - Are there contradictions between what the file says and what the ADR decided?
   - Is the file referencing outdated/superseded ADRs?
3. Check for cross-ADR consistency:
   - Do any ADRs contradict each other?
   - Are superseded ADRs properly marked?
   - Is there an ADR referenced in docs that doesn't exist?

## Report

Present findings in this format:

```
# ADR Consistency Report

## Inventory
- Total ADRs: X
- Synced: Y
- Pending sync: Z
- Deprecated: W

## File-by-File Analysis

### [filename]
- ✅ Reflects ADR-001: [brief]
- ✅ Reflects ADR-002: [brief]
- ❌ Missing ADR-003: [what should be there]
- ⚠️ Contradicts ADR-004: [what's wrong]

### [filename]
...

## Cross-ADR Issues
- [any contradictions or missing superseded markers]

## Recommended Actions
1. [specific action needed]
2. [specific action needed]
```

## Fix Mode

If the user provided `--fix` as argument, or if `$ARGUMENTS` contains "fix" or "arreglar":
- After presenting the report, proceed to fix all identified issues
- Use the adr-sync-checker agent via Task tool for each ADR that needs syncing
- Report what was fixed

If no fix argument:
- Present the report and ask the user if they want to fix the issues found
