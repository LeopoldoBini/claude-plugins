# Responsive Testing Matrix

7-breakpoint protocol for systematic responsive QA.

---

## Standard Breakpoints

| Breakpoint | Width | Height | Device Category | Representative Device |
|------------|-------|--------|----------------|----------------------|
| XS | 375px | 812px | Small phone | iPhone SE / 13 Mini |
| SM | 414px | 896px | Large phone | iPhone 14 Plus / Pixel 7 |
| MD | 640px | 900px | Small tablet / landscape phone | — |
| LG | 768px | 1024px | Tablet portrait | iPad Mini / iPad |
| XL | 1024px | 768px | Tablet landscape / small laptop | iPad landscape |
| 2XL | 1280px | 800px | Laptop | MacBook Air 13" |
| 3XL | 1536px | 960px | Desktop | Large monitor |

These align with Tailwind CSS default breakpoints (sm: 640, md: 768, lg: 1024, xl: 1280, 2xl: 1536) plus the two most common mobile widths.

---

## Execution Protocol

### Per Page

For each page under test:

```
1. Start at 3XL (1536px) — desktop baseline
2. Screenshot + snapshot
3. Resize to 2XL (1280px) — check for first layout shift
4. Screenshot + compare
5. Resize to XL (1024px) — tablet landscape / nav changes likely
6. Screenshot + check for hamburger menu, layout reflow
7. Resize to LG (768px) — tablet portrait, major layout shifts
8. Screenshot + verify grid changes (3-col → 2-col, sidebar collapse)
9. Resize to MD (640px) — transitional breakpoint
10. Screenshot + check for stacking
11. Resize to SM (414px) — large phone
12. Screenshot + check touch targets, text readability
13. Resize to XS (375px) — smallest supported width
14. Screenshot + full mobile verification
```

### What to Check at Each Breakpoint

| Check | Details |
|-------|---------|
| **Horizontal overflow** | `scrollWidth > clientWidth` — nothing should scroll horizontally |
| **Text truncation** | Content shouldn't be cut off without ellipsis or "show more" |
| **Element overlap** | No elements stacking on top of each other |
| **Touch targets** | Interactive elements at least 44x44px on mobile (≤768px) |
| **Image scaling** | Images scale down, don't overflow containers |
| **Font readability** | Text remains readable (minimum 14px on mobile) |
| **Navigation** | Desktop nav → hamburger or drawer on mobile |
| **Forms** | Inputs full-width on mobile, labels visible |
| **Tables** | Horizontal scroll or card view on mobile |
| **Modals** | Full-screen or properly sized on mobile |
| **Fixed elements** | Sticky headers/footers don't cover content |
| **Spacing** | Padding/margins adjust (less spacing on mobile) |

---

## Quick Responsive JS Check

Run this at each breakpoint to get a quick health check:

```javascript
({
  viewport: { width: window.innerWidth, height: window.innerHeight },
  hasHorizontalScroll: document.documentElement.scrollWidth > document.documentElement.clientWidth,
  overflowingElements: Array.from(document.querySelectorAll('*'))
    .filter(el => {
      const rect = el.getBoundingClientRect();
      return rect.right > window.innerWidth + 1 || rect.left < -1;
    })
    .slice(0, 5)
    .map(el => ({
      tag: el.tagName,
      class: (el.className?.toString() || '').slice(0, 40),
      right: Math.round(el.getBoundingClientRect().right),
      windowWidth: window.innerWidth
    })),
  smallTouchTargets: Array.from(document.querySelectorAll('a, button, input, select, [role="button"]'))
    .filter(el => {
      const rect = el.getBoundingClientRect();
      return rect.width > 0 && rect.height > 0 && (rect.width < 44 || rect.height < 44);
    })
    .slice(0, 5)
    .map(el => ({
      tag: el.tagName,
      text: (el.textContent || '').trim().slice(0, 20),
      size: `${Math.round(el.getBoundingClientRect().width)}x${Math.round(el.getBoundingClientRect().height)}`
    }))
});
```

---

## Reporting Format

```markdown
## Responsive Test Results

### Page: [URL]

| Breakpoint | Overflow | Layout | Touch Targets | Issues |
|------------|----------|--------|---------------|--------|
| 375px (XS) | ✅/❌ | ✅/❌ | ✅/❌ | [notes] |
| 414px (SM) | ✅/❌ | ✅/❌ | ✅/❌ | [notes] |
| 640px (MD) | ✅/❌ | ✅/❌ | N/A | [notes] |
| 768px (LG) | ✅/❌ | ✅/❌ | ✅/❌ | [notes] |
| 1024px (XL) | ✅/❌ | ✅/❌ | N/A | [notes] |
| 1280px (2XL) | ✅/❌ | ✅/❌ | N/A | [notes] |
| 1536px (3XL) | ✅/❌ | ✅/❌ | N/A | [notes] |
```

Touch targets only checked at ≤768px (mobile/tablet breakpoints).

---

## Custom Breakpoints

If the project's `qa-forge.local.md` specifies custom viewports, use those instead of (or in addition to) the standard 7. Always test at least:
- The smallest specified
- The largest specified
- Any breakpoint where the design changes significantly

## Common Responsive Issues by Component

| Component | Common Mobile Issue |
|-----------|-------------------|
| Tables | Columns overflow; need horizontal scroll or card layout |
| Sidebars | Don't collapse; overlap main content |
| Multi-column grids | Don't stack to single column |
| Fixed headers | Cover too much viewport on small screens |
| Modals | Don't go full-screen; content unreachable |
| Long URLs/strings | Overflow containers (no word-break) |
| Images | Don't scale down; push layout horizontally |
| Horizontal nav | Items wrap awkwardly or overflow |
| Date pickers | Calendar doesn't fit screen width |
| Forms | Labels beside inputs instead of above on mobile |
