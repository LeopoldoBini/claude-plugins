# ADR Verification Methodology

Detailed step-by-step process for verifying ADR consistency across project documentation.

## Full Verification Process

### Step 1: Inventory ADRs

1. Glob for all files matching `adr_pattern` in `adr_path`
2. For each ADR file:
   - Parse YAML frontmatter (if present)
   - Extract `sync_status` and `last_synced`
   - Read the ADR body to extract:
     - **Title** (from H1)
     - **Status** (Proposed/Accepted/Deprecated/Superseded)
     - **Decision** (from Decision section)
     - **Technologies mentioned** (libraries, frameworks, tools)
     - **Supersedes/Superseded by** references
3. Build inventory table:
   ```
   ADR-001 | Accepted  | synced  | 2026-02-12 | React 19 + Vite
   ADR-002 | Accepted  | pending | -          | TypeSafe E2E tooling
   ADR-003 | Deprecated| synced  | 2026-02-10 | (superseded by ADR-005)
   ```

### Step 2: Analyze Each Sync Target

For each file in `sync_targets`:

1. **Read the file completely**
2. **For each Accepted ADR**, check:
   - Does the file mention or reflect the decision?
   - Are the specific technologies/patterns referenced?
   - If the ADR added tasks, are they in the file?
   - Is the ADR referenced where appropriate?
3. **For each Deprecated/Superseded ADR**, check:
   - Is the file still referencing the old decision?
   - Has the superseding decision replaced it?
4. **Record findings** per file per ADR:
   - `in_sync` — file correctly reflects ADR
   - `missing` — file doesn't mention ADR at all
   - `outdated` — file references deprecated/superseded decision
   - `contradicts` — file says something different from ADR

### Step 3: Cross-ADR Consistency

Check relationships between ADRs:

1. **Supersession chain**: If ADR-005 supersedes ADR-003, verify:
   - ADR-003 has `Status: Superseded by ADR-005`
   - ADR-005 exists and is Accepted
   - No docs still reference ADR-003's decisions
2. **Technology conflicts**: If ADR-001 picks React and ADR-007 picks Vue:
   - Flag as conflict
   - Check which is newer/supersedes
3. **Completeness**: For each phase/module in the plan:
   - Are there ADRs covering the key decisions?
   - Are there decisions made in docs without corresponding ADRs?

### Step 4: Generate Report

Structure the report clearly:

```markdown
# ADR Consistency Report — [date]

## Summary
- Total ADRs: X (Y accepted, Z deprecated)
- Fully synced: A
- Needing updates: B
- Conflicts found: C

## Detailed Findings

### CLAUDE.md
| ADR | Status | Finding |
|-----|--------|---------|
| ADR-001 | ✅ In sync | Stack table reflects React 19 + Vite |
| ADR-002 | ❌ Missing | TanStack Query not in stack table |
| ADR-003 | ⚠️ Outdated | Still references old auth approach |

### docs/plan/MASTER-PLAN.md
...

## Cross-ADR Issues
- ADR-003 and ADR-007 both address auth but ADR-003 not marked superseded

## Recommended Fixes
1. Update CLAUDE.md stack table to include TanStack Query (from ADR-002)
2. Mark ADR-003 as superseded by ADR-007
3. ...
```

## Common Inconsistency Patterns

### Pattern: Stack Table Drift
**Symptom**: ADR selects a technology but it's not in the main stack table.
**Fix**: Add/update the row in the stack table. Include ADR reference.
**Example**: ADR-002 chose TanStack Query but CLAUDE.md stack table doesn't list it.

### Pattern: Missing Implementation Tasks
**Symptom**: ADR implies new setup/configuration work but no tasks exist in the plan.
**Fix**: Add tasks to the appropriate phase in MASTER-PLAN and PROGRESS.
**Example**: ADR-002 adds Orval, TanStack Router, Zod — but Fase 0 doesn't have setup tasks for these.

### Pattern: Progress Not Updated
**Symptom**: ADR is finalized (Accepted) but PROGRESS.md doesn't reflect it.
**Fix**: Mark the ADR item as completed in PROGRESS.md with date.
**Example**: ADR-001 is Accepted but PROGRESS.md still shows `- [ ] ADR-001`.

### Pattern: Superseded But Still Referenced
**Symptom**: An ADR is superseded but docs still reference the old decision.
**Fix**: Update doc references to point to the superseding ADR.
**Example**: Docs say "per ADR-003, use session auth" but ADR-003 was superseded by ADR-007 (JWT).

### Pattern: Orphan References
**Symptom**: A document references an ADR that doesn't exist.
**Fix**: Either create the missing ADR or remove the reference.
**Example**: CLAUDE.md mentions "per ADR-010" but no ADR-010 file exists.

### Pattern: Date Stamp Staleness
**Symptom**: CLAUDE.md "Ultima Actualizacion" date is older than recent ADRs.
**Fix**: Update the date and change description.
**Example**: CLAUDE.md says "updated 2026-01-15" but ADR-005 was created 2026-02-12.

## Edge Cases

### ADR Without Standard Structure
Some ADRs may not follow the standard template (Context/Decision/Consequences).
- Try to extract the decision from whatever structure exists
- Flag that the ADR doesn't follow conventions
- Still attempt to sync based on content

### ADR With No Clear Decision
Some ADRs may be in "Proposed" status without a clear decision yet.
- Skip sync for Proposed ADRs
- Only sync Accepted ADRs
- Report Proposed ADRs as "pending decision"

### Multiple ADRs Affecting Same File Section
When two ADRs both affect the same section:
- Process chronologically (by ADR number)
- Later ADRs take precedence for conflicting information
- Both should be reflected if they address different aspects

### Large Documentation Files
For very large files (>500 lines):
- Focus on configured `sections` from sync_targets
- Use Grep to find relevant sections instead of reading the whole file
- Make targeted edits only in relevant sections
