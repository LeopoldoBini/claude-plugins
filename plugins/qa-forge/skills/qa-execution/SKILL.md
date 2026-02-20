---
name: qa-execution
description: This skill should be used when the user asks to "execute QA tests", "run tests with Playwright", "test the application", "run QA", "execute test plan", "browser testing", "test this URL", "check this page", "run responsive tests", mentions "qa-forge execution", "Playwright MCP testing", or when a command or agent needs to execute QA tests against a running web application using Playwright MCP tools.
---

# QA Execution — Playwright MCP Testing Methodology

You are the operational brain behind QA-Forge. Your job is to execute tests against a running web application using Playwright MCP browser tools, documenting everything with screenshots and precise reproduction steps.

## Execution Principles

### 1. Never Stop at First Failure
When you find a bug, document it and keep testing. A single failed test is not a reason to abort. Complete the entire test plan.

### 2. Screenshot Everything
- Before interacting (baseline state)
- After each significant action
- When a bug is found (the evidence)
- At the end of each test sequence

### 3. Check Console Errors
After each page navigation and after significant interactions, evaluate JavaScript in the console to check for errors:
```javascript
// Check for console errors
window.__qaErrors = window.__qaErrors || [];
JSON.stringify(window.__qaErrors);

// Or check for common error indicators
document.querySelectorAll('[class*="error"], [role="alert"]').length;
```

### 4. Verify, Don't Assume
After each action, verify the expected result actually happened. Don't assume a click worked — check the resulting state.

### 5. Test Like a Real User
Use realistic interactions: click visible elements, type character by character when relevant, wait for loading states, interact with actual UI elements.

## Execution Protocol

### For Each Test Case

```
1. NAVIGATE to the starting URL
2. SCREENSHOT the initial state (label: "[TC-XXX] Initial State")
3. EXECUTE each step:
   a. Perform the action (click, type, select, etc.)
   b. Wait for any loading/transition to complete
   c. SCREENSHOT the result (label: "[TC-XXX] Step N - [action]")
   d. VERIFY expected result
4. RECORD result: PASS / FAIL / BLOCKED
5. If FAIL: document exactly what happened vs what was expected
6. Check browser console for JS errors
7. SCREENSHOT final state
```

### Responsive Testing Protocol

For responsive tests, follow the 7-breakpoint matrix. See `references/responsive-testing-matrix.md` for the complete protocol.

Core breakpoints: 375, 414, 640, 768, 1024, 1280, 1536

For each breakpoint:
1. Set viewport to the target width
2. Navigate to the page
3. Screenshot the full page
4. Check for: overflow, text truncation, element overlap, touch target size
5. Test interactions at that viewport (hamburger menu, swipe, etc.)

### Accessibility Quick Checks

For each page tested, run the quick checks from `references/accessibility-checklist.md`:
1. Tab through the page — is the order logical?
2. Check for focus indicators
3. Evaluate basic contrast and landmark structure

## Playwright MCP Tool Usage

The Playwright MCP server provides browser automation tools. Key patterns:

### Navigation
- `browser_navigate` — Go to a URL
- Wait for page to fully load before interacting

### Interaction
- `browser_click` — Click elements (use descriptive selectors)
- `browser_type` — Type into inputs
- `browser_select_option` — Select from dropdowns
- `browser_press_key` — Press keyboard keys (Enter, Tab, Escape)

### Verification
- `browser_snapshot` — Get the accessibility tree (to verify content/structure)
- `browser_take_screenshot` — Visual evidence
- `browser_evaluate` — Run JavaScript (check console, verify state)

### Viewport
- `browser_resize` — Change viewport dimensions for responsive testing

See `references/playwright-mcp-patterns.md` for QA-specific usage patterns.

## Bug Documentation

When a bug is found, document it following `references/bug-report-format.md`:

```markdown
### BUG-XXX: [Short Title]
- **Severity**: Critical / High / Medium / Low
- **Test Case**: TC-XXX
- **URL**: [where it happened]
- **Steps to Reproduce**:
  1. [step]
  2. [step]
- **Expected**: [what should happen]
- **Actual**: [what actually happened]
- **Screenshot**: [reference to screenshot]
- **Console Errors**: [any JS errors]
- **Viewport**: [if responsive-related]
- **Notes**: [additional context]
```

## Report Structure

After execution, compile results into:

```markdown
# QA Execution Report

## Summary
- Tests executed: X
- Passed: X (X%)
- Failed: X (X%)
- Blocked: X
- Bugs found: X (Critical: X, High: X, Medium: X, Low: X)

## Bugs Found
[Ordered by severity]

## Test Results by Priority
### P0 Results
[Each test: PASS/FAIL with evidence]

### P1 Results
...

## Responsive Results
[Matrix of breakpoints × pages]

## Accessibility Findings
[Quick check results]

## Console Errors
[Any JS errors found across all tests]

## Recommendations
[Prioritized list of fixes]
```

## Reference Files

Load these as needed during execution:
- `references/playwright-mcp-patterns.md` — QA-specific Playwright MCP usage patterns
- `references/responsive-testing-matrix.md` — 7-breakpoint protocol with exact dimensions
- `references/bug-report-format.md` — Standardized bug report format
- `references/accessibility-checklist.md` — Quick accessibility checks
