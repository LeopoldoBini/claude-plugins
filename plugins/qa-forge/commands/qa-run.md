---
description: "Execute QA tests with Playwright MCP — run a previous test plan or test a URL directly"
allowed-tools: Read, Glob, Grep, Task
argument-hint: "[URL or 'plan' to execute previous test plan]"
---

# QA-Forge — Test Execution

You are executing QA tests against a running web application using the qa-operator agent.

## Step 1: Determine What to Execute

From `$ARGUMENTS`:

### Option A: URL Provided
If `$ARGUMENTS` contains a URL (starts with `http://` or `https://`):
- Use that as the target URL
- No formal test plan — the qa-operator will use expert instincts
- Good for quick exploratory testing of a specific page

### Option B: "plan" or Test Plan Reference
If `$ARGUMENTS` contains "plan" or references a previous test plan:
- Look for the most recent test plan in the conversation context
- If no plan exists in context, ask the user to run `/qa-plan` first or provide a URL

### Option C: No Arguments
- Check `.claude/qa-forge.local.md` for base_url
- If available, ask: "Test the full application or a specific page?"
- If not available, ask for a URL

## Step 2: Gather Configuration

1. Read `.claude/qa-forge.local.md` if it exists:
   - `base_url` — Target URL
   - `auth` — Authentication config
   - `viewports` — Custom breakpoints
   - Application context from markdown body

2. If auth is configured, prepare auth instructions for the agent.

3. Determine viewport breakpoints:
   - Custom from config, or
   - Default: 375, 414, 640, 768, 1024, 1280, 1536

## Step 3: Launch qa-operator

Use the **Task** tool to launch the `qa-operator` agent.

### With a Test Plan
Construct the agent prompt with:
```
Execute the following QA test plan against [base_url]:

[Full test plan content]

Authentication:
[Auth instructions if applicable, or "No auth required"]

Responsive breakpoints: [list]

Execute ALL tests. Do not stop at the first failure. Screenshot everything.
Return a complete execution report.
```

### Without a Test Plan (URL Only)
Construct the agent prompt with:
```
Perform exploratory QA testing on: [URL]

You are testing this page as a Senior QA Engineer. Use your expert instincts to:
1. Identify all interactive elements on the page
2. Test each element: happy path, validation, edge cases
3. Check responsive behavior at breakpoints: [list]
4. Run accessibility quick checks
5. Check console for JavaScript errors
6. Document every bug found with full reproduction steps

[Application context from qa-forge.local.md if available]

Authentication:
[Auth instructions if applicable, or "No auth required"]

Return a complete QA report.
```

## Step 4: Process Results

When the qa-operator returns:

1. **Review the report** for completeness
2. **Present to the user** in a clean, organized format:
   - Executive summary first (pass/fail/bug counts)
   - Bugs by severity (critical first)
   - Detailed test results
   - Responsive and accessibility findings
   - Recommendations

3. If `save_reports: true` in config:
   - Save the report to the configured `report_dir` (default: `.claude/qa-reports/`)
   - Filename: `qa-report-[date]-[target].md`

## Error Handling

- **App not running**: If the qa-operator reports connection failures, inform the user: "The application doesn't seem to be running at [URL]. Please start it and try again."
- **Auth failure**: If login fails, report it and ask the user to verify credentials in `qa-forge.local.md`
- **Partial execution**: If some tests couldn't run (blocked), report which ones and why
