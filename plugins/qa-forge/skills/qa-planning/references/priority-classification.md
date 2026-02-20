# Priority Classification — P0 to P3

## P0 — Critical (Must Pass)

Tests that verify core application functionality. If any P0 fails, the application is considered broken for production use.

### Criteria
- User cannot complete the primary task the app is built for
- Data loss or corruption is possible
- Authentication/authorization bypass
- Payment or financial transaction failures
- Complete page crashes or blank screens

### Examples
| Feature | P0 Test |
|---------|---------|
| E-commerce | Add item to cart → checkout → payment succeeds |
| Auth | Login with valid credentials → redirects to dashboard |
| CRUD app | Create record → appears in list → can edit → can delete |
| Search | Type query → results appear → clicking result navigates correctly |
| Form submission | Fill required fields → submit → confirmation shown → data persisted |
| Navigation | All primary nav links lead to correct pages (no 404s) |

### How many P0s?
Typically 5-15 per feature. If you have more than 20, you're likely including P1s.

---

## P1 — High (Should Pass)

Tests that verify data integrity, validation rules, and error handling. Failures cause significant user frustration or potential data issues.

### Criteria
- Validation rules not enforced (can submit invalid data)
- Error messages missing or incorrect
- Auth edge cases (expired sessions, wrong permissions)
- Data displayed incorrectly (wrong format, missing fields)
- API errors not handled gracefully (raw error shown to user)

### Examples
| Feature | P1 Test |
|---------|---------|
| Form | Submit with empty required fields → shows specific error per field |
| Form | Enter invalid email format → shows "Invalid email" message |
| Auth | Access protected page without login → redirects to login |
| Table | Sort by column → data reorders correctly |
| Table | Filter results → count updates, data matches filter |
| API | Server returns 500 → user sees friendly error, not stack trace |
| State | Navigate away from unsaved form → warns user or preserves data |

### How many P1s?
Typically 10-30 per feature. These are your validation and error-handling tests.

---

## P2 — Medium (Nice to Pass)

Tests that verify experience quality: edge cases, responsive layout, performance, and unusual interactions.

### Criteria
- App works but layout breaks at specific viewport
- Edge case inputs cause unexpected behavior (but no data loss)
- Loading states missing or janky
- Performance issues on expected data volumes
- Double-submit or race condition scenarios

### Examples
| Feature | P2 Test |
|---------|---------|
| Responsive | Form layout intact at 375px width |
| Responsive | Table scrolls horizontally on mobile (no content cut off) |
| Edge case | Paste 500-character string into name field → handled gracefully |
| Edge case | Submit form while previous submission still loading |
| Edge case | Navigate with browser back/forward → state preserved |
| Performance | Table with 100+ rows renders without freezing |
| UX | Loading spinner shown during async operations |

### How many P2s?
Typically 15-40 per feature. Responsive tests multiply quickly across breakpoints.

---

## P3 — Low (Good to Have)

Tests that verify accessibility, polish, and cross-feature interactions. Failures affect specific user groups or non-critical UX details.

### Criteria
- Keyboard navigation doesn't work for a component
- Screen reader can't understand the page structure
- Color contrast fails WCAG AA
- Tab order is illogical
- Focus management issues (focus lost after modal close)
- Hover states or micro-interactions broken

### Examples
| Feature | P3 Test |
|---------|---------|
| A11y | Form can be completed using only keyboard (Tab, Enter, Space) |
| A11y | Images have alt text, buttons have labels |
| A11y | Error messages announced to screen readers (aria-live) |
| A11y | Color is not the only way to convey information |
| Polish | Hover effects on interactive elements |
| Cross-feature | Creating item in feature A reflects in feature B's count |
| Cross-feature | Deleting user also removes their comments |

### How many P3s?
Typically 5-15 per feature. Focus on high-impact accessibility issues.

---

## Classification Decision Tree

```
Is the app unusable if this fails?
  YES → P0
  NO ↓

Can the user submit bad data or see wrong data?
  YES → P1
  NO ↓

Does it affect experience quality (layout, edge cases, performance)?
  YES → P2
  NO ↓

Is it accessibility, polish, or cross-feature?
  YES → P3
  NO → Probably not worth testing
```

## Anti-patterns

- **Everything is P0**: If more than 30% of tests are P0, you're over-prioritizing
- **No P2/P3 tests**: Edge cases and accessibility matter — don't skip them
- **Generic tests**: "Page loads" is not a real test case. What specifically should be visible?
- **Duplicate across priorities**: A test should have exactly one priority level
