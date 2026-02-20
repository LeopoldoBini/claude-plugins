---
description: "Full QA workflow — analyze code, generate test plan, execute tests with Playwright, produce professional report"
allowed-tools: Read, Glob, Grep, Bash, Edit, Write, Task
argument-hint: "<feature, page, or URL to test>"
---

# QA-Forge — Full Workflow

You are orchestrating a complete QA cycle for this project. Follow each phase in order.

## Phase 0: Context Gathering

1. Check if a per-project config exists:
   ```
   Read .claude/qa-forge.local.md
   ```
   If it exists, extract: `base_url`, `framework`, `auth` config, `viewports`, `skip_routes`, and any application context from the markdown body.

2. If no config exists, inform the user:
   > No `.claude/qa-forge.local.md` found. I'll detect the framework and you can provide the base URL.
   > To set up persistent config, copy the template:
   > `cp ${CLAUDE_PLUGIN_ROOT}/templates/qa-forge.local.md.template .claude/qa-forge.local.md`

3. Determine the target from `$ARGUMENTS`:
   - If it's a URL → that's the base URL, test the page at that URL
   - If it's a feature name or description → find it in the codebase
   - If empty → ask the user what to test

## Phase 1: Codebase Analysis & Test Planning

Use the **qa-planning** skill knowledge to analyze the codebase.

1. **Detect the framework** — Check `package.json`, config files, directory structure. Use the patterns from the `qa-planning` skill's `references/framework-detection-guide.md` if needed.

2. **Find the target feature** — Based on `$ARGUMENTS`, locate:
   - Route files / page components
   - Form components and their validation schemas
   - API endpoints related to the feature
   - State management related to the feature

3. **Generate the test plan** — Using the qa-planning methodology:
   - Decompose the feature into testable scenarios
   - Generate concrete test cases with preconditions, steps, expected results
   - Classify each test as P0, P1, P2, or P3
   - Include responsive tests and accessibility checks
   - Format as structured markdown

4. **Present the plan to the user** for approval:
   ```
   ## QA Test Plan: [Feature]

   I found [X] testable scenarios across [N] components.

   ### Summary
   | Priority | Tests | Focus |
   |----------|-------|-------|
   | P0 | X | [areas] |
   | P1 | X | [areas] |
   | P2 | X | [areas] |
   | P3 | X | [areas] |

   [Full plan details...]

   Shall I execute this plan? You can also:
   - Remove specific tests
   - Change priorities
   - Add scenarios I missed
   - Adjust the scope
   ```

5. **Wait for user approval** before proceeding to Phase 2. Use AskUserQuestion:
   - "Execute the full plan as-is"
   - "Execute only P0 and P1 tests"
   - "Let me adjust the plan first"

## Phase 2: Test Execution

Once the user approves the plan:

1. **Determine the base URL**:
   - From `qa-forge.local.md` config
   - From `$ARGUMENTS` if it's a URL
   - Ask the user if not available

2. **Launch the qa-operator agent** with the Task tool:
   - Pass the approved test plan
   - Pass the base URL
   - Pass any auth configuration
   - Pass any custom viewports
   - The agent will execute all tests using Playwright MCP

   The prompt for the agent should include:
   - The complete test plan
   - The base URL
   - Auth instructions (if any)
   - Viewport overrides (if any)
   - Instruction to execute ALL tests and return a complete report

3. **Receive results** from the qa-operator agent.

## Phase 3: Report Consolidation

Take the raw results from the qa-operator and produce a polished final report:

1. **Executive summary** — Pass/fail counts, bug counts by severity, overall assessment
2. **Bugs** — Ordered by severity, with all evidence (screenshots, steps, console errors)
3. **Test results** — Grouped by priority, each test with PASS/FAIL/BLOCKED
4. **Responsive results** — If responsive tests were executed
5. **Accessibility findings** — Quick check results
6. **Recommendations** — Prioritized list of fixes, starting with blockers

Present the report to the user. If `save_reports: true` in the config, also save it to the configured `report_dir`.

## Important Notes

- If the application is not running at the base URL, inform the user and suggest starting it first
- If authentication is needed but not configured, ask the user for credentials
- Never skip P0 tests — they define minimum viability
- The test plan phase is valuable on its own — even without execution, a good plan reveals gaps
