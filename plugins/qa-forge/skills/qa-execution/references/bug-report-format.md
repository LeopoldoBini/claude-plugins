# Bug Report Format

Standardized format for documenting bugs found during QA execution.

---

## Single Bug Report

```markdown
### BUG-[NNN]: [Short descriptive title]

**Severity**: Critical | High | Medium | Low
**Test Case**: TC-[NNN] (or "Exploratory" if found outside test plan)
**Priority**: P0 | P1 | P2 | P3
**URL**: [exact URL where bug occurs]
**Viewport**: [width]x[height] (if responsive-related, otherwise "All")

**Steps to Reproduce**:
1. Navigate to [URL]
2. [Precise action]
3. [Precise action]
4. Observe: [what happens]

**Expected Result**:
[What should happen according to the code/design/common sense]

**Actual Result**:
[What actually happens — be specific]

**Screenshot**: [TC-NNN screenshot reference]

**Console Errors**:
```
[Any JS errors captured, or "None"]
```

**Additional Context**:
[Browser, OS, any relevant conditions]
```

---

## Severity Definitions

### Critical
- Application crashes or becomes completely unusable
- Data loss or corruption
- Security vulnerability (auth bypass, data exposure)
- Payment/financial transaction failure
- Infinite loops or memory leaks that freeze the browser

**Example**: Submitting checkout form charges card but shows error page, and order is not recorded.

### High
- Major feature doesn't work but app is still usable
- Data displayed incorrectly (wrong values, wrong user's data)
- Validation completely missing (can submit garbage data)
- Authentication/authorization holes
- Error handling fails (raw stack trace shown to user)

**Example**: Filter on product list doesn't work — always shows all products regardless of selection.

### Medium
- Feature works but with visual/UX issues
- Edge case causes unexpected behavior (no data loss)
- Responsive layout breaks at specific viewport
- Performance issues on expected data volumes
- Missing loading states or poor feedback

**Example**: Table columns overlap at 768px width, making data unreadable.

### Low
- Cosmetic issues that don't affect functionality
- Accessibility issues that affect screen reader users
- Inconsistent spacing, colors, or typography
- Missing hover states or micro-interactions
- Typos or grammar issues in UI text

**Example**: Focus indicator missing on search input — keyboard users can't see where focus is.

---

## Execution Report Template

```markdown
# QA Execution Report — [Feature/Target]

**Date**: [YYYY-MM-DD]
**Tester**: QA-Forge (qa-operator)
**Application**: [name]
**Base URL**: [url]
**Test Plan**: [reference to plan if applicable]

---

## Executive Summary

| Metric | Count |
|--------|-------|
| Total tests executed | XX |
| Passed | XX (XX%) |
| Failed | XX (XX%) |
| Blocked | XX |
| Total bugs found | XX |

### Bugs by Severity

| Severity | Count | Bug IDs |
|----------|-------|---------|
| Critical | X | BUG-001, BUG-005 |
| High | X | BUG-002, BUG-003 |
| Medium | X | BUG-004, BUG-006 |
| Low | X | BUG-007 |

### Overall Assessment
[1-2 sentences: is this feature ready for production? What are the blockers?]

---

## Bugs Found

[All bug reports ordered by severity (Critical first)]

---

## Test Results Detail

### P0 — Critical Tests

| ID | Test Case | Result | Notes |
|----|-----------|--------|-------|
| TC-001 | [title] | ✅ PASS | — |
| TC-002 | [title] | ❌ FAIL | → BUG-001 |
| TC-003 | [title] | ⏸️ BLOCKED | [reason] |

### P1 — High Priority Tests
[same format]

### P2 — Medium Priority Tests
[same format]

### P3 — Low Priority Tests
[same format]

---

## Responsive Results

[Responsive testing matrix from responsive-testing-matrix.md]

---

## Accessibility Findings

| Check | Result | Notes |
|-------|--------|-------|
| Keyboard navigation | ✅/❌ | [details] |
| Focus indicators | ✅/❌ | [details] |
| Form labels | ✅/❌ | [details] |
| Error announcements | ✅/❌ | [details] |
| Heading structure | ✅/❌ | [details] |
| Image alt text | ✅/❌ | [details] |

---

## Console Errors

| Page | Error | Frequency | Impact |
|------|-------|-----------|--------|
| [URL] | [error message] | Every load / Occasional | High/Low |

---

## Recommendations

Prioritized list of recommended fixes:

1. **[CRITICAL]** Fix [BUG-001]: [one-line description and suggested approach]
2. **[HIGH]** Fix [BUG-002]: [one-line description]
3. **[MEDIUM]** Address responsive issues at [breakpoint]
4. **[LOW]** Improve accessibility: [specific fixes]

---

## Test Environment

- Browser: Chromium (Playwright headless)
- Viewport: [default + responsive breakpoints tested]
- Date/Time: [execution timestamp]
- Application version: [if available]
```

---

## Bug ID Numbering

- Bugs are numbered sequentially within a single QA session: BUG-001, BUG-002, etc.
- Test cases retain their plan IDs: TC-001, TC-002, etc.
- If a bug is found during exploratory testing (outside the plan), note "Exploratory" as the test case.
- If one test reveals multiple bugs, create separate bug reports for each distinct issue.
