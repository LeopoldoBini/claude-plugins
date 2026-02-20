# Accessibility Quick Checklist

Fast accessibility checks to run during QA execution. These are not a full WCAG audit — they catch the most common and impactful issues.

---

## Keyboard Navigation (30 seconds per page)

### Test Protocol
1. Start at the top of the page
2. Press `Tab` repeatedly through all interactive elements
3. Verify focus order is logical (left-to-right, top-to-bottom)
4. Verify all interactive elements can be reached
5. Press `Enter` or `Space` on buttons/links — they should activate
6. Press `Escape` on open modals/dropdowns — they should close
7. Test `Arrow` keys on menus, tabs, radio groups

### Common Failures
| Issue | How to Spot |
|-------|-------------|
| Focus not visible | Tab through and watch — can you see where focus is? |
| Skip link missing | Tab from top — first focusable should be "Skip to content" (optional but good practice) |
| Focus trap (bad) | Tab gets stuck in a section with no way out |
| Focus trap missing (bad) | Tab inside modal escapes to background content |
| Unreachable element | Button or link can't be reached via Tab |
| Wrong order | Focus jumps around illogically |

### JavaScript Check
```javascript
// Check for focusable elements without visible focus styles
const focusable = document.querySelectorAll('a[href], button, input, select, textarea, [tabindex]');
const noOutline = Array.from(focusable).filter(el => {
  const styles = getComputedStyle(el);
  return styles.outlineStyle === 'none' && styles.boxShadow === 'none';
}).length;
({ totalFocusable: focusable.length, missingFocusStyles: noOutline });
```

---

## Form Accessibility (20 seconds per form)

### Check
1. Every `<input>` has a visible `<label>` associated via `for`/`id` or wrapping
2. Required fields marked with `aria-required="true"` (not just red asterisk)
3. Error messages associated with fields via `aria-describedby`
4. Error messages use `aria-live="polite"` or `role="alert"` for dynamic errors
5. Form can be submitted via keyboard (Enter key in last field or Tab to submit button)

### JavaScript Check
```javascript
const inputs = document.querySelectorAll('input, select, textarea');
Array.from(inputs).map(input => {
  const id = input.id;
  const label = id ? document.querySelector(`label[for="${id}"]`) : null;
  const ariaLabel = input.getAttribute('aria-label');
  const ariaLabelledBy = input.getAttribute('aria-labelledby');
  return {
    name: input.name || input.type,
    hasLabel: !!(label || ariaLabel || ariaLabelledBy || input.closest('label')),
    required: input.required || input.getAttribute('aria-required') === 'true',
    type: input.type
  };
});
```

---

## Semantic Structure (15 seconds per page)

### Check
1. Page has exactly one `<h1>`
2. Heading hierarchy doesn't skip levels (h1 → h3 without h2)
3. Main content wrapped in `<main>` landmark
4. Navigation wrapped in `<nav>`
5. Lists use `<ul>`/`<ol>`, not styled divs
6. Tables use `<table>` with `<thead>`, not div grids

### JavaScript Check
```javascript
const headings = Array.from(document.querySelectorAll('h1,h2,h3,h4,h5,h6'));
const landmarks = {
  main: document.querySelectorAll('main, [role="main"]').length,
  nav: document.querySelectorAll('nav, [role="navigation"]').length,
  banner: document.querySelectorAll('header, [role="banner"]').length,
  contentinfo: document.querySelectorAll('footer, [role="contentinfo"]').length,
};
({
  headings: headings.map(h => ({ level: h.tagName, text: h.textContent.trim().slice(0, 30) })),
  h1Count: headings.filter(h => h.tagName === 'H1').length,
  landmarks,
  headingOrderValid: headings.every((h, i) => {
    if (i === 0) return true;
    const curr = parseInt(h.tagName[1]);
    const prev = parseInt(headings[i-1].tagName[1]);
    return curr <= prev + 1;
  })
});
```

---

## Images & Media (10 seconds)

### Check
1. All `<img>` have `alt` attribute
2. Decorative images have `alt=""`
3. Meaningful images have descriptive alt text
4. Icons used as buttons/links have accessible labels

### JavaScript Check
```javascript
const images = document.querySelectorAll('img');
({
  totalImages: images.length,
  missingAlt: Array.from(images).filter(img => !img.hasAttribute('alt')).length,
  emptyAlt: Array.from(images).filter(img => img.alt === '').length,
  withAlt: Array.from(images).filter(img => img.alt && img.alt.length > 0).length,
  iconButtons: Array.from(document.querySelectorAll('button, a')).filter(el => {
    const hasText = el.textContent.trim().length > 0;
    const hasAriaLabel = el.getAttribute('aria-label');
    const hasTitle = el.getAttribute('title');
    return !hasText && !hasAriaLabel && !hasTitle;
  }).length
});
```

---

## Color & Contrast (10 seconds)

### Visual Check
1. Information is NOT conveyed by color alone (errors have icons/text too)
2. Text appears readable against its background
3. Interactive elements are distinguishable from non-interactive

### Note
Automated contrast checking requires specialized tools. During QA execution, flag any text that appears visually hard to read — the dev team can then verify with a contrast checker.

---

## ARIA Usage (Quick Scan)

### Common Issues to Spot
| Pattern | Problem |
|---------|---------|
| `<div onclick>` | Should be `<button>` or have `role="button"` + `tabindex="0"` |
| `<span>` as link | Should be `<a href>` or have `role="link"` |
| Custom dropdown | Needs `role="listbox"`, `role="option"`, `aria-expanded` |
| Tab interface | Needs `role="tablist"`, `role="tab"`, `role="tabpanel"`, `aria-selected` |
| Toggle | Needs `aria-pressed` or `aria-checked` |
| Loading state | Container should have `aria-busy="true"` |
| Live updates | Toast/alerts need `role="alert"` or `aria-live="polite"` |

---

## Reporting Format

```markdown
## Accessibility Quick Check — [Page/Feature]

| Category | Status | Issues |
|----------|--------|--------|
| Keyboard Navigation | ✅/⚠️/❌ | [details] |
| Form Labels | ✅/⚠️/❌ | [details] |
| Heading Structure | ✅/⚠️/❌ | [details] |
| Image Alt Text | ✅/⚠️/❌ | [details] |
| Focus Indicators | ✅/⚠️/❌ | [details] |
| Semantic HTML | ✅/⚠️/❌ | [details] |
| Color Independence | ✅/⚠️/❌ | [details] |

Legend: ✅ Pass | ⚠️ Minor issues | ❌ Significant issues
```
