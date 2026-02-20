# Playwright MCP Patterns for QA

QA-specific patterns using Playwright MCP tools. Not generic Playwright docs — these are tested workflows for QA execution.

---

## Core Workflow Pattern

Every QA test follows this cycle:

```
navigate → snapshot → interact → wait → snapshot → verify → screenshot
```

**Always snapshot before interacting** — the accessibility tree tells you what's clickable, what text is present, and the page structure. This prevents blind clicking.

---

## Form Testing Patterns

### Submit Empty Form
```
1. browser_navigate → form page
2. browser_snapshot → identify submit button
3. browser_click → submit button (without filling anything)
4. browser_snapshot → check for validation errors
5. browser_take_screenshot → capture error state
```

### Fill and Submit
```
1. browser_navigate → form page
2. browser_snapshot → identify all form fields
3. For each field:
   a. browser_click → the field (to focus)
   b. browser_type → the test value
4. browser_take_screenshot → filled state
5. browser_click → submit button
6. Wait for response (snapshot until new content appears)
7. browser_take_screenshot → result state
```

### Test Specific Validation
```
1. Fill all fields with valid data EXCEPT the one being tested
2. Put invalid value in target field
3. Submit
4. Verify specific error for that field
5. Correct the field
6. Verify error clears
```

### Test Paste Long String
```
1. browser_click → target field
2. browser_type → [500+ character string]
3. browser_snapshot → check if truncated or handled
4. browser_take_screenshot → evidence
```

---

## Table Testing Patterns

### Verify Sort
```
1. browser_snapshot → read column values in current order
2. browser_click → column header (to sort)
3. browser_snapshot → read column values in new order
4. Verify values are properly sorted (ascending)
5. browser_click → same column header again (descending)
6. browser_snapshot → verify reverse order
```

### Verify Filter
```
1. browser_snapshot → note total items/rows
2. browser_click → filter dropdown or input
3. browser_type or browser_select_option → filter value
4. Wait for table to update
5. browser_snapshot → verify filtered results
6. Verify count decreased and items match filter
```

### Verify Pagination
```
1. browser_snapshot → note current page, total pages
2. browser_click → "Next" or page 2 button
3. browser_snapshot → verify different items shown
4. Verify page indicator updated
5. browser_click → "Previous" → back to page 1
6. Verify original items shown
```

---

## Modal Testing Patterns

### Open → Interact → Close
```
1. browser_snapshot → note page state
2. browser_click → modal trigger button
3. browser_snapshot → verify modal is open (look for dialog role)
4. browser_take_screenshot → modal state
5. [interact with modal content]
6. browser_press_key → Escape (or click close button)
7. browser_snapshot → verify modal is closed
8. Verify page state returned to pre-modal state
```

### Modal Form Submission
```
1. Open modal (as above)
2. Fill form fields inside modal
3. Submit
4. Verify modal closes AND action completed (toast, list updated, etc.)
```

---

## Navigation Testing Patterns

### Verify All Links
```
1. browser_navigate → page with navigation
2. browser_snapshot → identify all nav links
3. For each link:
   a. browser_click → the link
   b. Verify URL changed correctly (browser_evaluate: window.location.href)
   c. browser_snapshot → verify page content loaded
   d. browser_navigate → back to starting page (or use browser_press_key → Alt+Left)
```

### Mobile Menu
```
1. browser_resize → {width: 375, height: 812}
2. browser_navigate → page
3. browser_snapshot → look for hamburger/menu toggle
4. browser_click → menu toggle
5. browser_snapshot → verify menu items visible
6. browser_click → a menu item
7. Verify navigation worked
```

---

## Responsive Testing Pattern

```
For each breakpoint in [375, 414, 640, 768, 1024, 1280, 1536]:
  1. browser_resize → {width: breakpoint, height: 900}
  2. browser_navigate → target page
  3. browser_take_screenshot → full-page evidence
  4. browser_snapshot → check for overflow, hidden content
  5. browser_evaluate → check for horizontal scroll:
     document.documentElement.scrollWidth > document.documentElement.clientWidth
```

---

## JavaScript Evaluation Patterns

### Check for Console Errors
```javascript
// Inject error catcher (do this right after navigation)
window.__qaConsoleErrors = [];
const originalError = console.error;
console.error = function(...args) {
  window.__qaConsoleErrors.push(args.map(a => String(a)).join(' '));
  originalError.apply(console, args);
};

// Later, retrieve errors
JSON.stringify(window.__qaConsoleErrors);
```

### Check Element Visibility
```javascript
const el = document.querySelector('[data-testid="error-message"]');
el ? { visible: el.offsetParent !== null, text: el.textContent } : null;
```

### Check Form Field State
```javascript
const input = document.querySelector('input[name="email"]');
input ? {
  value: input.value,
  valid: input.validity.valid,
  message: input.validationMessage
} : null;
```

### Check Network Activity
```javascript
// Check if any fetch/XHR is pending (approximate)
document.querySelector('[class*="loading"], [class*="spinner"], [aria-busy="true"]') !== null;
```

### Check Overflow (Responsive)
```javascript
({
  hasHorizontalScroll: document.documentElement.scrollWidth > document.documentElement.clientWidth,
  scrollWidth: document.documentElement.scrollWidth,
  clientWidth: document.documentElement.clientWidth,
  overflowElements: Array.from(document.querySelectorAll('*')).filter(el => el.scrollWidth > el.clientWidth + 2).map(el => ({
    tag: el.tagName,
    class: el.className?.toString().slice(0, 50),
    overflow: el.scrollWidth - el.clientWidth
  })).slice(0, 5)
});
```

---

## Waiting Patterns

Playwright MCP doesn't have explicit `waitFor`. Use these strategies:

### Poll via Snapshot
Take a snapshot after an action. If the expected content isn't there yet, wait briefly and snapshot again. Usually 1-2 snapshots suffice for most transitions.

### Poll via Evaluate
```javascript
// Check if loading is done
!document.querySelector('[aria-busy="true"], .loading, .spinner');
```

### Implicit Waits
Most Playwright MCP actions auto-wait for elements to be actionable. If a click fails, the element likely isn't ready — snapshot first to confirm it exists.

---

## Authentication Pattern

```
1. browser_navigate → login page
2. browser_snapshot → identify email/password fields
3. browser_click → email field
4. browser_type → test credentials email
5. browser_click → password field
6. browser_type → test credentials password
7. browser_click → submit/login button
8. Wait for redirect
9. browser_snapshot → verify authenticated state (dashboard, user menu, etc.)
10. browser_take_screenshot → evidence of logged-in state
```

After auth, the session persists for subsequent tests (within the same browser context).

---

## Screenshot Naming Convention

Use descriptive labels for screenshots:
- `[TC-001] Initial State - Login Page`
- `[TC-001] Step 2 - After entering credentials`
- `[TC-001] Result - Dashboard loaded`
- `[BUG-003] Evidence - Missing error message`
- `[Responsive] 375px - Product listing page`
