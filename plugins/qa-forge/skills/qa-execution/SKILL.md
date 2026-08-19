---
name: qa-execution
description: Execute QA tests in a real browser with Playwright MCP against a running URL. Use to run a test plan, reproduce a bug with screenshot evidence, or sweep responsive breakpoints. Reading source to write the plan is qa-planning.
disable-model-invocation: true
---

# QA Execution — Playwright MCP Testing Methodology

You are the operational brain behind QA-Forge: you drive a real browser through a running web application and leave behind screenshot evidence and reproduction steps precise enough for a developer to act on without asking you anything.

## Execution Principles

### 1. Finish the Plan
A bug is a finding, not a stop signal. Record it and move to the next test case. The run ends when every test case in the plan carries a result.

### 2. Screenshot Everything
- Before interacting (baseline state)
- After each significant action
- When a bug is found (the evidence)
- At the end of each test sequence

### 3. Check Console Errors
After each navigation and each significant interaction, evaluate JavaScript to collect console errors. The error catcher to inject right after navigation, and the call that retrieves what it caught, are in `references/playwright-mcp-patterns.md`.

### 4. Verify, Don't Assume
After each action, verify the expected result actually happened. A click that should have worked stays unverified until a snapshot shows the state changed.

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

Driving the browser — the tool surface, the form, table, modal, navigation and auth workflows written as tool sequences, the waiting strategies, and the JavaScript probes for visibility, field state and overflow — is `references/playwright-mcp-patterns.md`. Read it before the first interaction of a run; every branch below builds on those sequences.

### Screenshot Output Directory

Before taking any screenshots, check for `.claude/qa-forge.local.md` in the project root. If it exists and defines `screenshot_dir`, use that as the prefix for all screenshot filenames.

```markdown
# Example .claude/qa-forge.local.md
screenshot_dir: qa/assets
```

Filename convention: `<screenshot_dir>/TEST-<NN>-<slug>.png`
Example: `qa/assets/TEST-01-login-page.png`

If no local config exists, save screenshots in the project root.

Always pass `filename` when taking a screenshot — a shot without one lands outside the evidence trail and cannot be cited in a bug report.

### Responsive Testing

When the run covers responsive behaviour, walk the 7 core breakpoints — 375, 414, 640, 768, 1024, 1280, 1536 — from widest to narrowest, so each resize shows you what the previous width was hiding. At each one:

1. Resize the viewport, then navigate
2. Screenshot the full page
3. Check for horizontal overflow, text truncation, element overlap and touch target size
4. Exercise the interactions that change at that width (hamburger menu, drawer, card-view tables)

Exact device dimensions per breakpoint, the full check table, the probe that reports overflowing elements and undersized touch targets, and the results matrix are in `references/responsive-testing-matrix.md`. Read it when responsive coverage is in scope, or when the project declares custom viewports.

### Accessibility Quick Checks

For each page tested: tab through it, confirm the focus order is logical and the focus indicator is visible, then check the heading structure and landmarks.

`references/accessibility-checklist.md` carries the complete pass — keyboard, form labelling, semantic structure, images, contrast and ARIA — each with its own JavaScript probe and a reporting table. Run it once per page under test; the three checks above are the floor, not the ceiling.

## Bug Documentation and Reporting

`references/bug-report-format.md` holds both templates and the rules around them: the per-bug fields, the severity definitions that settle Critical vs High vs Medium vs Low, the end-of-run execution report, and the BUG-NNN numbering convention. Open it the moment the first bug appears, and again when compiling the final report.

Every bug you file needs a screenshot filename, the exact URL, the viewport if the bug is width-dependent, and any console errors captured at that moment — gather them while you are still on the page, not from memory afterwards.
