---
name: adr-consistency
description: This skill should be used when the user asks to "sync ADRs", "process ADR changes", "check ADR consistency", "update docs from ADR", "verify ADR sync status", mentions "adr-sync plugin" or "sync_status", asks to "propagate architecture decisions to documentation", or works with ADR frontmatter fields like sync_status and last_synced.
---

# ADR Consistency Management

Methodology and knowledge for maintaining Architecture Decision Records (ADRs) in sync with project documentation.

## What is ADR Consistency

ADRs capture architecture decisions. The challenge is that decisions affect multiple project files: project instructions (CLAUDE.md), implementation plans, progress trackers, and more. Without systematic sync, documentation drifts from reality.

**Key concepts:**
- ADR = single source of truth for a decision
- Sync targets = files that must reflect ADR decisions
- Sync status = flag in ADR frontmatter indicating processing state
- Auto-update = agent automatically updates target files

## ADR Frontmatter Standard

Every ADR managed by this plugin has YAML frontmatter with sync tracking:

```yaml
---
sync_status: pending | synced
last_synced: YYYY-MM-DD
---

# ADR-NNN: Title

## Status
Proposed | Accepted | Deprecated | Superseded by ADR-XXX

## Context
...
```

- `sync_status: pending` — ADR created/modified but not yet propagated to docs
- `sync_status: synced` — ADR processed, all target files updated
- `last_synced` — date of last successful sync

## Sync Process

When an ADR is created or modified:

1. **Read** the project settings from `.claude/adr-sync.local.md`
2. **Parse** the ADR to extract: decision, technologies chosen, consequences, alternatives
3. **For each sync target file**:
   - Read the file
   - Identify sections affected by the decision
   - Determine if update is needed
   - Apply minimal, targeted edits
4. **Mark** the ADR frontmatter with `sync_status: synced`
5. **Report** what was updated

## Configuration

Project settings live in `.claude/adr-sync.local.md` with YAML frontmatter:

```yaml
adr_path: "docs/architecture/decisions"
adr_pattern: "ADR-*.md"
sync_targets:
  - path: "CLAUDE.md"
    sections: ["Stack Tecnologico"]
  - path: "docs/plan/MASTER-PLAN.md"
    sections: ["Fases de Implementacion"]
auto_update: true
mark_synced: true
```

The markdown body contains project-specific context and sync rules.

To set up configuration, run `/setup-adr-sync` or create the file manually using the template at `${CLAUDE_PLUGIN_ROOT}/templates/adr-sync.local.md.template`.

## Common Update Patterns

### Stack/Technology Tables
When an ADR selects a technology, update the stack table:
- Add new row if technology is new
- Modify existing row if replacing a technology
- Note the ADR reference

### Implementation Task Lists
When an ADR creates new implementation work:
- Add configuration/setup tasks to the relevant phase
- Mark ADR creation itself as completed if tracked

### Progress Checklists
When an ADR is finalized:
- Mark ADR item as completed with date
- Add any new items that arise from the decision

### Cross-References
When an ADR supersedes another:
- Update the old ADR's status to "Superseded by ADR-XXX"
- Ensure docs reference the new ADR, not the old one

## Conflict Resolution

- **Two ADRs contradict**: Report the conflict. Do not auto-update. Let the user create a new ADR resolving the contradiction.
- **Doc says X, ADR says Y**: The ADR wins. Update the doc.
- **ADR is Deprecated**: Remove or mark as deprecated any doc references to the deprecated decision.
- **ADR is Superseded**: Replace references with the superseding ADR's decision.

## Tools

- `/verificar-adrs` — Full manual review of ALL ADRs against all docs
- `/verificar-adrs --fix` — Review and fix all inconsistencies
- `/setup-adr-sync` — Configure the plugin for a project
- Agent `adr-sync-checker` — Autonomous sync processor (invoked by hooks or manually)

## Additional Resources

### Reference Files

For detailed verification methodology and patterns:

- **`references/verification-methodology.md`** — Step-by-step verification process, edge cases, and examples of common inconsistencies
