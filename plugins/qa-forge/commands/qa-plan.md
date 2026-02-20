---
description: "Generate a QA test plan by analyzing source code — no browser execution, just strategic planning"
allowed-tools: Read, Glob, Grep
argument-hint: "<feature, page, or component to plan tests for>"
---

# QA-Forge — Test Plan Generation

You are generating a comprehensive QA test plan by analyzing the source code. No browser interaction — pure strategic analysis.

## Step 1: Determine Target

From `$ARGUMENTS`:
- If it's a route or page name → find the corresponding source files
- If it's a feature description → search for related components, routes, APIs
- If it's a component name → find it and its usage
- If empty → ask the user what feature to plan tests for

## Step 2: Load Context

1. Check for project config:
   ```
   Read .claude/qa-forge.local.md
   ```
   Extract framework, known issues, key flows, and application context.

2. If no config, detect the framework from `package.json` and directory structure.

## Step 3: Codebase Analysis

Using the **qa-planning** skill methodology, analyze:

1. **Routes & Pages** — Find all routes related to the target feature. Use framework-specific patterns from `${CLAUDE_PLUGIN_ROOT}/skills/qa-planning/references/framework-detection-guide.md`.

2. **Components** — Find UI components used by the target:
   - Forms: field definitions, submit handlers, validation
   - Tables: columns, sorting, filtering, pagination
   - Modals: triggers, content, close behavior
   - Navigation: links, menus, breadcrumbs

3. **Validation** — Find all validation rules:
   - Zod/Yup schemas
   - HTML5 validation attributes
   - Custom validation functions
   - Server-side validation in API routes

4. **API Integration** — Find data flow:
   - What APIs does the feature call?
   - What data does it send/receive?
   - How are errors handled?

5. **State** — How does data flow through the feature?
   - Global stores
   - URL parameters
   - Form state
   - Derived/computed values

## Step 4: Generate Test Plan

For each testable aspect found, create test cases following the priority classification from `${CLAUDE_PLUGIN_ROOT}/skills/qa-planning/references/priority-classification.md`.

Use component-specific patterns from `${CLAUDE_PLUGIN_ROOT}/skills/qa-planning/references/test-patterns-by-component.md`.

Consult edge cases from `${CLAUDE_PLUGIN_ROOT}/skills/qa-planning/references/edge-case-encyclopedia.md`.

### Output Format

```markdown
# QA Test Plan: [Feature/Target]

## Scope
- **Application**: [name from package.json]
- **Framework**: [detected]
- **Features under test**: [list]
- **Source files analyzed**: [list of key files read]
- **Generated**: [date]

## Analysis Summary
[Brief description of what was found in the code — components, validation rules, API calls, etc.]

## Test Summary
| Priority | Count | Categories |
|----------|-------|------------|
| P0       | X     | Core flows |
| P1       | X     | Validation, error handling |
| P2       | X     | Edge cases, responsive |
| P3       | X     | Accessibility |
| **Total** | **X** | |

## P0 — Critical Tests

### [Feature/Component Name]

#### TC-001: [Descriptive Test Case Title]
- **Preconditions**: [What must be true before testing]
- **Steps**:
  1. Navigate to [URL path]
  2. [Concrete action — "Click the 'Submit' button", not "submit the form"]
  3. [Concrete action]
- **Expected**: [Specific observable result]
- **Verify**: [How to confirm — check element text, check URL, check toast]

#### TC-002: [Next Test Case]
...

## P1 — High Priority Tests
[Same format, focusing on validation and error handling]

## P2 — Medium Priority Tests
[Same format, focusing on edge cases and responsive]

## P3 — Low Priority Tests
[Same format, focusing on accessibility]

## Auth Requirements
[Any authentication needed to test these features]

## Test Data Requirements
[Specific data needed — user accounts, sample records, etc.]

## Notes
[Any observations about code quality, missing error handling, potential issues noticed during analysis]
```

## Important Guidelines

- **Read the actual code** — Don't generate generic tests. Read the validation schema to know exact field rules. Read the component to know exact error messages.
- **Be specific** — "Enter 'test@' in email field" not "enter invalid email"
- **Include the source** — Note which source file informed each test case
- **Flag code issues** — If you notice missing validation, missing error handling, or potential bugs during analysis, mention them in the Notes section
- **Don't test what doesn't exist** — If there's no form on the page, don't generate form tests
