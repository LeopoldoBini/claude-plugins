# Framework Detection Guide

How to identify the framework and find key files for QA planning.

## Detection Order

1. Check `package.json` for framework dependencies
2. Check config files (`next.config.*`, `nuxt.config.*`, `vite.config.*`, etc.)
3. Check directory structure for framework-specific patterns

---

## Next.js (App Router)

**Detect**: `next` in package.json dependencies, `next.config.js|ts|mjs`

**Routes**:
```
app/
├── page.tsx                    → /
├── about/page.tsx              → /about
├── products/[id]/page.tsx      → /products/:id
├── (auth)/login/page.tsx       → /login (route group)
└── api/users/route.ts          → /api/users
```

**Key files to analyze**:
- `app/**/page.tsx` — All pages (routes)
- `app/**/layout.tsx` — Shared layouts (nav, sidebar)
- `app/**/loading.tsx` — Loading states
- `app/**/error.tsx` — Error boundaries
- `app/api/**/route.ts` — API routes
- `middleware.ts` — Auth guards, redirects
- `components/**` — Shared UI components
- `lib/validations.*` or `schemas/**` — Zod/Yup schemas

**Patterns to grep**:
```
"use server"         → Server actions
"use client"         → Client components
useFormState         → Form handling with server actions
redirect(            → Server-side redirects
cookies()            → Cookie usage
```

## Next.js (Pages Router)

**Detect**: `pages/` directory instead of `app/`

**Routes**:
```
pages/
├── index.tsx                   → /
├── about.tsx                   → /about
├── products/[id].tsx           → /products/:id
└── api/users.ts                → /api/users
```

**Key files**: `pages/**/*.tsx`, `pages/api/**/*.ts`

---

## React (Vite / CRA)

**Detect**: `react` + `react-dom` in package.json, no `next`

**Routes**: Look for router config
```bash
# React Router
grep -r "createBrowserRouter\|<Route\|<Routes" src/
# File-based (TanStack Router)
grep -r "createFileRoute\|createRootRoute" src/
```

**Key files**:
- `src/App.tsx` — Root component, often has router
- `src/routes/**` or `src/pages/**` — Route components
- `src/components/**` — Shared components
- Router config file (varies by project)

---

## Vue 3

**Detect**: `vue` in package.json, `vite.config.ts` with `@vitejs/plugin-vue`

**Routes**:
```
src/router/index.ts    → Route definitions
src/views/**/*.vue     → Page components
src/pages/**/*.vue     → Alternative convention
```

**Key files**:
- `src/router/index.ts` — All route definitions
- `src/views/**/*.vue` — Page-level components
- `src/components/**/*.vue` — Shared components
- `src/stores/**` — Pinia stores (state)
- `src/composables/**` — Shared logic

---

## Nuxt 3

**Detect**: `nuxt` in package.json, `nuxt.config.ts`

**Routes**: File-based routing
```
pages/
├── index.vue                   → /
├── about.vue                   → /about
├── products/[id].vue           → /products/:id
```

**Key files**:
- `pages/**/*.vue` — All routes
- `layouts/**/*.vue` — Layout components
- `components/**/*.vue` — Auto-imported components
- `server/api/**` — API routes
- `middleware/**` — Route middleware
- `composables/**` — Auto-imported composables

---

## SvelteKit

**Detect**: `@sveltejs/kit` in package.json, `svelte.config.js`

**Routes**:
```
src/routes/
├── +page.svelte                → /
├── about/+page.svelte          → /about
├── products/[id]/+page.svelte  → /products/:id
├── +layout.svelte              → Shared layout
└── api/users/+server.ts        → /api/users
```

**Key files**:
- `src/routes/**/+page.svelte` — Pages
- `src/routes/**/+page.server.ts` — Server load functions
- `src/routes/**/+server.ts` — API endpoints
- `src/lib/components/**` — Shared components
- `src/hooks.server.ts` — Server hooks (auth)

---

## Astro

**Detect**: `astro` in package.json, `astro.config.mjs`

**Routes**:
```
src/pages/
├── index.astro                 → /
├── about.astro                 → /about
├── posts/[slug].astro          → /posts/:slug
└── api/data.ts                 → /api/data
```

**Key files**:
- `src/pages/**/*.astro` — All routes
- `src/components/**` — UI components (may use React/Vue/Svelte)
- `src/layouts/**` — Layout components

---

## Remix

**Detect**: `@remix-run/react` in package.json

**Routes**:
```
app/routes/
├── _index.tsx                  → /
├── about.tsx                   → /about
├── products.$id.tsx            → /products/:id
```

**Key files**:
- `app/routes/**/*.tsx` — Routes with loaders/actions
- `app/root.tsx` — Root layout
- `app/components/**` — Shared components

---

## Angular

**Detect**: `@angular/core` in package.json, `angular.json`

**Routes**: `app-routing.module.ts` or `app.routes.ts`

**Key files**:
- `src/app/**/*.component.ts` — Components
- `src/app/**/*.module.ts` — Modules
- `src/app/**/*.service.ts` — Services
- `src/app/app-routing.module.ts` — Routes

---

## Universal Analysis Patterns

Regardless of framework, always look for:

```bash
# Forms and validation
grep -r "onSubmit\|handleSubmit\|useForm\|<form" src/
grep -r "z\.object\|z\.string\|yup\.object\|Joi\.object" src/

# Auth patterns
grep -r "signIn\|signOut\|useAuth\|useSession\|isAuthenticated" src/
grep -r "middleware\|guard\|protect\|authorize" src/

# Data fetching
grep -r "fetch(\|axios\.\|useSWR\|useQuery\|trpc\." src/

# Error handling
grep -r "try.*catch\|ErrorBoundary\|error\.tsx\|onError" src/

# Modals and dialogs
grep -r "Dialog\|Modal\|Drawer\|Sheet\|Popover" src/

# Tables and lists
grep -r "DataTable\|<table\|useTable\|columns.*accessor" src/
```
