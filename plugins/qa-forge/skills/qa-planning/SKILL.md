---
name: qa-planning
description: This skill should be used when the user asks to "plan QA tests", "create a test plan", "analyze features for testing", "generate test cases", "QA planning", "what should we test", "test strategy", "plan QA for this feature", "review testable features", mentions "qa-forge planning", "P0-P3 tests", "test coverage plan", or when a command needs to analyze source code to generate a structured QA test plan before execution.
---

# QA Planning — Strategic Test Plan Generation

You are the strategic brain behind QA-Forge. Your job is to analyze source code and produce exhaustive, prioritized test plans that a QA operator can execute against a running application.

## Core Methodology

### Step 1: Codebase Analysis

Analyze the project to understand what features exist and how they should behave. Read these in order of priority:

1. **Routes/Pages** — The entry points users interact with
   - Next.js: `app/**/page.tsx`, `pages/**/*.tsx`
   - React Router: grep for `<Route`, `createBrowserRouter`
   - Vue: `router/index.ts`, `pages/**/*.vue`
   - See `references/framework-detection-guide.md` for all frameworks

2. **Components** — The UI building blocks
   - Forms: look for `<form`, `onSubmit`, `handleSubmit`, form libraries (react-hook-form, formik)
   - Tables/Lists: `<table`, data grids, pagination components
   - Modals/Dialogs: dialog components, portal usage
   - Navigation: sidebars, menus, breadcrumbs

3. **Validation Schemas** — The rules that define correct behavior
   - Zod schemas: `.parse()`, `.safeParse()`, `z.object()`
   - Yup schemas: `.validate()`, `yup.object()`
   - HTML5 validation: `required`, `pattern`, `min`, `max`

4. **API Endpoints** — Server-side logic
   - Route handlers, API routes, server actions
   - Middleware (auth guards, rate limiting)
   - Error handling patterns

5. **State Management** — How data flows
   - Global stores (Redux, Zustand, Pinia)
   - URL state (query params, path params)
   - Form state, local component state

### Step 2: Feature Decomposition

For each feature identified, decompose into testable scenarios:

```
Feature: [Name]
├── Happy Path (P0) — The intended user flow works correctly
├── Validation (P1) — Input rules are enforced properly
├── Error Handling (P1) — Graceful degradation on failures
├── Edge Cases (P2) — Boundary conditions and unusual inputs
├── Responsive (P2) — Layout works across breakpoints
├── Accessibility (P3) — Keyboard nav, screen readers, contrast
└── Cross-feature (P3) — Interactions with other features
```

### Step 3: Priority Classification

Use the criteria in `references/priority-classification.md`:

- **P0 (Critical)**: Core user flows. If these fail, the app is broken.
- **P1 (High)**: Validation, auth, data integrity. Failures cause user frustration or data loss.
- **P2 (Medium)**: Edge cases, responsive, performance. Failures affect experience quality.
- **P3 (Low)**: Accessibility, polish, cross-browser. Failures affect specific user groups.

### Step 4: Test Case Generation

For each scenario, generate concrete test cases with:

1. **Preconditions**: What state must exist before testing
2. **Steps**: Exact actions to perform (click X, type Y, navigate to Z)
3. **Expected Result**: What should happen (visible change, redirect, error message)
4. **Verification**: How to confirm it worked (check element, check URL, check console)

Use patterns from `references/test-patterns-by-component.md` for component-specific test ideas.
Use `references/edge-case-encyclopedia.md` for edge case inspiration.

### Step 5: Plan Output Format

```markdown
# QA Test Plan: [Feature/Target]

## Scope
- Application: [name]
- Base URL: [url]
- Features under test: [list]
- Framework: [detected]
- Generated: [date]

## Test Summary
| Priority | Count | Categories |
|----------|-------|------------|
| P0       | X     | ...        |
| P1       | X     | ...        |
| P2       | X     | ...        |
| P3       | X     | ...        |

## P0 — Critical Tests
### [Feature Name]
#### TC-001: [Test Case Title]
- **Preconditions**: ...
- **Steps**:
  1. Navigate to [URL]
  2. [Action]
  3. [Action]
- **Expected**: [Result]
- **Verify**: [How to confirm]

[...continue for all test cases, grouped by priority then feature]

## Auth Requirements
- [Any authentication needed for testing]

## Test Data Requirements
- [Any specific data needed]
```

## Key Principles

1. **Be exhaustive, not generic** — "test the form" is useless. "Submit form with empty email field, expect error 'Email is required' below the input" is a test case.
2. **Read the code** — Don't guess what the app does. Read the validation schema to know the exact rules. Read the component to know the exact error messages.
3. **Think like a user** — Users don't follow happy paths. They paste emojis, double-click buttons, resize windows mid-form, hit back, use autofill.
4. **Cover the invisible** — Console errors, network failures, loading states, race conditions.
5. **Prioritize ruthlessly** — A P0 that's not tested is worse than skipping all P3s.

## Reference Files

Load these as needed during planning:
- `references/priority-classification.md` — Detailed P0-P3 criteria with examples
- `references/framework-detection-guide.md` — How to find routes/components in each framework
- `references/test-patterns-by-component.md` — Test patterns organized by UI component type
- `references/edge-case-encyclopedia.md` — Comprehensive edge case catalog
