---
description: Configure adr-sync plugin for this project — creates .claude/adr-sync.local.md
allowed-tools: Read, Write, Glob, Bash(mkdir:*)
---

Guide the user through configuring the adr-sync plugin for their project.

## Step 1: Detect Project Structure

Explore the project to understand its structure:

1. Check if `.claude/adr-sync.local.md` already exists
   - If yes, inform the user and ask if they want to reconfigure
2. Look for common ADR locations:
   - `docs/architecture/decisions/`
   - `docs/decisions/`
   - `docs/adr/`
   - `adr/`
   - Any directory containing files matching `ADR-*.md` or `adr-*.md`
3. Look for common documentation files:
   - `CLAUDE.md`
   - `README.md`
   - `docs/plan/MASTER-PLAN.md` or similar
   - `docs/plan/PROGRESS.md` or similar
   - `CHANGELOG.md`

## Step 2: Confirm with User

Present what was found and ask the user to confirm or adjust:

1. "I found ADRs in [path]. Is this correct?"
2. "I found these documentation files that could be sync targets: [list]. Which ones should the plugin keep in sync with ADRs?"
3. For each sync target, ask: "What sections of [file] should be updated when ADRs change?"

Use AskUserQuestion for structured choices when possible.

## Step 3: Create Configuration

1. Ensure `.claude/` directory exists (create if needed)
2. Create `.claude/adr-sync.local.md` with:
   - YAML frontmatter with all configuration
   - Markdown body with project context based on what was discovered
3. Populate sync_targets based on user's choices
4. Set `auto_update: true` (default)
5. Set `mark_synced: true` (default)

## Step 4: Validate

1. Verify all configured paths exist
2. Check if there are existing ADRs that haven't been synced yet
3. If there are unsynced ADRs, inform the user:
   "Found X existing ADRs without sync status. Run `/verificar-adrs --fix` to sync them all."

## Step 5: Remind About Gitignore

Check if `.gitignore` includes `.claude/*.local.md`. If not, suggest adding it:

"Add `.claude/*.local.md` to your `.gitignore` — the settings file is user-specific and shouldn't be committed."

## Completion

Confirm setup is complete and show:
- Path to settings file
- Number of sync targets configured
- Next steps (create an ADR or run /verificar-adrs)
