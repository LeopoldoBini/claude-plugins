# Test Patterns by Component Type

Exhaustive test patterns organized by UI component. For each component type, test ideas are grouped by priority.

---

## Forms

The most test-dense component. A single form can generate 20+ test cases.

### P0 — Core Functionality
- Fill all required fields with valid data → submit → success feedback
- Each field accepts its intended input type (text, email, number, date)
- Submit triggers the correct API call with correct payload
- Success state: redirect, toast, modal close, or data appears in list

### P1 — Validation
- Submit with all fields empty → each required field shows error
- Submit with each required field empty (one at a time) → specific error shown
- Enter invalid format for each field (wrong email, letters in phone, etc.)
- Exceed maxlength on each text field
- Enter value below minimum / above maximum for number fields
- Enter past date when only future dates allowed (and vice versa)
- Upload wrong file type when file input present
- Upload file exceeding size limit
- Validation errors clear when user corrects the field
- Inline validation (on blur) vs submit-time validation

### P2 — Edge Cases
- Paste text with leading/trailing whitespace
- Paste multi-line text into single-line field
- Enter Unicode characters (emojis, CJK, RTL text)
- Paste 500+ characters into each text field
- Double-click submit button rapidly
- Submit while previous submission still loading
- Fill form → navigate away → come back → is data preserved?
- Browser autofill populates fields correctly
- Tab through all fields in logical order
- Enter SQL injection strings (`'; DROP TABLE--`)
- Enter XSS strings (`<script>alert(1)</script>`)
- Special characters in every text field (`&<>"'`)

### P3 — Accessibility
- Complete form using only keyboard (Tab, Shift+Tab, Enter, Space)
- Each field has visible label associated via `for`/`id` or `aria-label`
- Error messages are announced by screen readers (aria-live or aria-describedby)
- Required fields indicated visually AND programmatically (aria-required)
- Focus moves to first error after failed submission
- Color alone doesn't indicate errors (icon or text accompanies red border)

---

## Tables / Data Grids

### P0 — Core
- Table renders with data (not empty, not loading forever)
- Correct columns displayed with correct data in each cell
- Row click/action navigates to detail or triggers expected action
- Pagination: navigate between pages, correct items per page

### P1 — Data Operations
- Sort by each sortable column (ascending and descending)
- Sort stability: equal values maintain relative order
- Filter by each filterable field → results match filter
- Filter + sort combined → both applied correctly
- Search → results match query, clear search → all results return
- Pagination updates after filter (total count, page numbers)
- Empty state shown when no results match filter/search

### P2 — Edge Cases
- Table with 0 rows → empty state, not broken layout
- Table with 1 row → renders correctly
- Table with 100+ rows → renders and scrolls smoothly
- Very long cell content → truncated or wrapped (not breaking layout)
- Rapidly toggle sort → final state is consistent
- Filter then paginate then clear filter → back to page 1
- Column with null/undefined values → graceful display (dash, "N/A")
- Resize browser → table adapts (horizontal scroll on mobile)

### P3 — Accessibility
- Table has proper `<thead>` and semantic markup
- Sort state indicated via aria-sort
- Keyboard navigation between rows and pagination
- Screen reader can understand table structure

---

## Modals / Dialogs

### P0 — Core
- Modal opens when trigger is clicked
- Modal content loads correctly
- Modal action buttons work (submit, confirm, cancel)
- Modal closes after successful action

### P1 — Behavior
- Close via X button
- Close via Cancel/Close button
- Close via Escape key
- Close via clicking backdrop/overlay
- Multiple modals don't stack unexpectedly
- Form inside modal validates correctly
- Errors inside modal display correctly

### P2 — Edge Cases
- Open modal → resize window → layout still correct
- Open modal → scroll attempt on background → background doesn't scroll
- Submit action in modal → loading state shown → button disabled during submission
- Modal with long content → scrollable within modal
- Open modal → switch browser tab → return → modal still open and functional

### P3 — Accessibility
- Focus trapped inside modal (Tab doesn't leave modal)
- Focus moves to modal on open
- Focus returns to trigger element on close
- Modal has aria-modal="true" and role="dialog"
- Close button has accessible label

---

## Navigation (Navbar, Sidebar, Menus)

### P0 — Core
- All nav links navigate to correct pages
- Active state shows on current page's nav item
- Brand/logo link goes to home

### P1 — State
- Mobile menu opens and closes
- Dropdown menus open on hover/click
- Nested menu items accessible
- Auth-dependent items show/hide correctly (logged in vs out)

### P2 — Edge Cases
- Rapidly open/close mobile menu → no stuck states
- Resize from mobile to desktop → menu state resets correctly
- Deep link to page → correct nav item highlighted
- Very long nav item text → doesn't break layout

### P3 — Accessibility
- `<nav>` element used with aria-label
- Mobile menu toggle has aria-expanded
- Keyboard navigable (arrow keys in menu)
- Skip navigation link present

---

## Search

### P0 — Core
- Type query → results appear
- Click result → navigates to correct page/item
- Empty query → shows all or appropriate default state

### P1 — Behavior
- No results → "No results found" message
- Results update as user types (debounced)
- Clear search → results reset
- Search preserves context (doesn't lose filters)

### P2 — Edge Cases
- Special characters in search query
- Very long search query (100+ chars)
- Rapid typing → no race conditions (last result matches last query)
- Search for exact matches vs partial matches
- Leading/trailing spaces handled

### P3 — Accessibility
- Search input has proper role and label
- Results announced to screen readers
- Keyboard selection of results (arrow keys + Enter)

---

## File Upload

### P0 — Core
- Select file → preview shown or filename displayed
- Upload → progress indicator → success message
- Uploaded file accessible after upload

### P1 — Validation
- Upload wrong file type → error message
- Upload file exceeding size limit → error message
- Upload empty file → handled gracefully

### P2 — Edge Cases
- Upload file with spaces in name
- Upload file with Unicode characters in name
- Drag and drop file upload works
- Upload multiple files (if supported)
- Cancel upload mid-progress
- Upload very large file → timeout handling

### P3 — Accessibility
- File input has label
- Drag zone has keyboard alternative
- Upload status announced to screen readers

---

## Authentication Flows

### P0 — Core
- Login with valid credentials → redirected to dashboard/home
- Logout → redirected to login, session cleared
- Protected pages redirect to login when unauthenticated

### P1 — Security
- Login with wrong password → error message (not "user not found")
- Login with non-existent user → same error as wrong password
- Session expiry → graceful re-auth prompt
- Cannot access admin routes as regular user

### P2 — Edge Cases
- Login → close tab → reopen → still logged in (persistent session)
- Multiple failed logins → rate limiting or lockout
- Login with email that has uppercase → works (case-insensitive)
- Password with special characters → works correctly

### P3 — Accessibility
- Login form fully keyboard accessible
- Error messages announced
- Password field can be toggled visible
