# Edge Case Encyclopedia

Comprehensive catalog of edge cases by category. Use this as inspiration when generating test plans — not every edge case applies to every feature, but scanning this list ensures nothing obvious is missed.

---

## Text Input Edge Cases

### Length Extremes
- Empty string (0 chars)
- Single character
- Exactly at maxlength boundary
- One over maxlength
- 500+ characters (paste test)
- 10,000+ characters (stress test for textareas)

### Special Characters
- `<script>alert('xss')</script>` — XSS attempt
- `'; DROP TABLE users; --` — SQL injection
- `" onmouseover="alert(1)` — Attribute injection
- `../../../etc/passwd` — Path traversal
- `${7*7}` — Template injection
- `{{constructor.constructor('return this')()}}` — Prototype pollution

### Unicode & Encoding
- Emojis: `😀🎉🔥` (multi-byte characters)
- CJK characters: `日本語テスト`
- RTL text: `مرحبا` (Arabic), `שלום` (Hebrew)
- Combining characters: `é` (e + combining accent) vs `é` (single codepoint)
- Zero-width characters: `​` (zero-width space), `‌` (zero-width non-joiner)
- Null byte: `test\x00value`
- Newlines: `line1\nline2`, `line1\r\nline2`

### Whitespace
- Leading spaces: `  hello`
- Trailing spaces: `hello  `
- Only spaces: `     `
- Tab characters: `hello\tworld`
- Multiple consecutive spaces: `hello     world`
- Non-breaking space: `hello\u00A0world`

### Format-Specific
- Email: `test@`, `@domain.com`, `test@.com`, `a@b.c`, `test+alias@gmail.com`, `test@subdomain.domain.com`
- Phone: `+1234567890`, `(555) 123-4567`, `555.123.4567`, letters in phone
- URL: `http://`, `ftp://evil.com`, `javascript:alert(1)`, no protocol
- Date: `2000-02-29` (leap year), `2001-02-29` (not leap), `9999-12-31`, `0000-01-01`

---

## Numeric Input Edge Cases

- `0` (zero — often treated differently)
- `-1` (negative when only positive expected)
- `0.1 + 0.2` (floating point precision)
- Very large: `999999999999999`
- Very small: `0.000000001`
- `NaN`, `Infinity`, `-Infinity` (as strings)
- Leading zeros: `007`
- Scientific notation: `1e10`
- Comma as decimal: `3,14` (locale-dependent)
- Currency symbols: `$100`, `€50`

---

## Date/Time Edge Cases

- Midnight: `00:00:00` vs `24:00:00`
- End of day: `23:59:59`
- Leap year: February 29
- Month boundaries: Jan 31 → Feb 1
- DST transitions (spring forward / fall back)
- Timezone edge: UTC midnight vs local midnight
- Year 2038 (Unix timestamp overflow for 32-bit)
- Far future: year 9999
- Far past: year 0001
- Date format ambiguity: `01/02/03` (M/D/Y vs D/M/Y)

---

## State & Timing Edge Cases

### Double Actions
- Double-click submit button
- Click submit, then click again during loading
- Double-click delete confirmation
- Press Enter twice quickly in form

### Race Conditions
- Submit form → immediately navigate away
- Start two searches simultaneously
- Delete item while it's being edited in another tab
- Update item while list is refreshing

### Navigation Timing
- Click link during page transition
- Hit browser back during form submission
- Refresh page during async operation
- Close tab during save (beforeunload)

### Stale State
- Open form → wait 30 minutes → submit (session expiry?)
- Open list in two tabs → delete in tab A → refresh tab B
- Start editing → someone else edits same record → save conflict

---

## Browser & Environment Edge Cases

### Viewport
- 320px wide (smallest practical mobile)
- 375px (iPhone SE)
- 414px (iPhone Plus/Max)
- 768px (iPad portrait)
- 1024px (iPad landscape / small laptop)
- 1920px (Full HD)
- 2560px+ (Ultra-wide)
- Browser zoom 50%, 100%, 150%, 200%

### Connectivity
- Slow network (3G simulation)
- Request timeout (server doesn't respond)
- Response mid-stream disconnect
- Offline → online transition

### Browser Features
- JavaScript disabled (graceful degradation?)
- Cookies disabled
- LocalStorage full / disabled
- Popup blocker active
- Ad blocker active (may block analytics/tracking scripts)
- Private/incognito mode

---

## File & Upload Edge Cases

- File with no extension
- File with double extension: `image.jpg.exe`
- File with very long name (255+ characters)
- File with spaces in name: `my file (copy).pdf`
- File with Unicode in name: `档案.pdf`
- Empty file (0 bytes)
- File that's actually a different type (rename .txt to .jpg)
- Symbolic link instead of real file
- File being written to by another process

---

## List & Pagination Edge Cases

- List with 0 items
- List with exactly 1 item
- List with exactly page-size items (e.g., exactly 10)
- List with page-size + 1 items (2 pages, second has 1 item)
- Delete all items on current page → what shows?
- Delete last item → page count should decrease
- Navigate to page that no longer exists (via URL manipulation)
- Very large page number in URL

---

## Authentication & Authorization Edge Cases

- Login with email in different case: `User@Email.COM`
- Password at exact minimum length
- Password at exact maximum length
- Password with only special characters
- Copy-paste password (some sites block this)
- Session token expired mid-action
- Concurrent sessions (login on two devices)
- Direct URL access to protected resource
- API endpoint access without auth header
- Role change while user is active (admin → user)
- Account disabled while session is active

---

## Data Display Edge Cases

- Missing/null fields (name is null, image URL is empty)
- Very long text in fixed-width columns
- HTML entities in user data (`&amp;`, `&lt;`)
- URLs in text content (should they be clickable?)
- Numbers: negative, zero, very large, decimals
- Dates: different timezones, relative display ("2 minutes ago" edge cases)
- Currency: different formats, negative amounts
- Lists with mixed content types
- Deeply nested data structures in UI
