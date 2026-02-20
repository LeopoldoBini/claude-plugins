#!/usr/bin/env bash
# detect-project-type.sh — Detects the web framework of the current project
# Outputs a single word: nextjs, react, vue, nuxt, svelte, sveltekit, angular, astro, remix, unknown

set -euo pipefail

PKG="${1:-package.json}"

if [ ! -f "$PKG" ]; then
  echo "unknown"
  exit 0
fi

# Read package.json dependencies
deps=$(cat "$PKG" 2>/dev/null || echo "{}")

has_dep() {
  echo "$deps" | grep -q "\"$1\"" 2>/dev/null
}

# Check in priority order (most specific first)
if has_dep "@sveltejs/kit"; then
  echo "sveltekit"
elif has_dep "nuxt"; then
  echo "nuxt"
elif has_dep "@remix-run/react"; then
  echo "remix"
elif has_dep "astro"; then
  echo "astro"
elif has_dep "next"; then
  echo "nextjs"
elif has_dep "svelte"; then
  echo "svelte"
elif has_dep "@angular/core"; then
  echo "angular"
elif has_dep "vue"; then
  echo "vue"
elif has_dep "react"; then
  echo "react"
else
  echo "unknown"
fi
