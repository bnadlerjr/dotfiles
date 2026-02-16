---
name: using-playwright-cli
description: |
  Browser automation via playwright-cli (microsoft/playwright-cli), the
  AI-agent-focused CLI for controlling browsers through Bash commands. Covers
  element reference system, snapshot workflow, session management, cookies,
  storage, network interception, and content capture.

  Use when the user asks to automate a browser, scrape a webpage, fill a form,
  test a UI flow interactively, capture screenshots, manage cookies/storage,
  intercept network requests, or drive any browser interaction from the terminal.
  NOT for npx playwright test runner or codegen.
---

# Playwright CLI

Browser automation through `npx @playwright/cli` commands executed
in Bash. This is the AI-agent-focused CLI, not the test runner.

## Required Reading

**Read the relevant reference before using commands:**

| Working On | Reference File | Key Topics |
|------------|----------------|------------|
| Commands, flags, syntax | [command-reference](references/command-reference.md) | All 50+ commands with flags and examples |
| Workflow patterns, sessions | [workflows](references/workflows.md) | Snapshot-first workflow, sessions, state, multi-tab |
| Network, cookies, storage | [state-and-network](references/state-and-network.md) | Cookies, localStorage, sessionStorage, route interception |

## Core Concept: Snapshot-First Workflow

Playwright-cli uses **element references** (e.g., `e15`, `e21`) to identify
interactive elements on a page. These references come from snapshots.

```bash
# 1. Open a page
npx @playwright/cli open https://example.com

# 2. Take a snapshot to discover element references
npx @playwright/cli snapshot

# 3. Interact using element references from the snapshot
npx @playwright/cli click e15
npx @playwright/cli fill e21 "search query"

# 4. Take another snapshot to see the result
npx @playwright/cli snapshot

# 5. Clean up
npx @playwright/cli close
```

**Key rule:** Always `snapshot` before interacting. Element references reset on
navigation, so re-snapshot after `goto`, `click` (if it navigates), or `reload`.

## Quick Examples

### "Scrape the product names from this page"

```bash
npx @playwright/cli open https://example.com/products
npx @playwright/cli snapshot
# Read the snapshot output to extract data
npx @playwright/cli close
```

### "Log into this site with these credentials"

```bash
npx @playwright/cli open https://example.com/login
npx @playwright/cli snapshot
# Snapshot shows: e10=username, e12=password, e15=submit button
npx @playwright/cli fill e10 "user@example.com"
npx @playwright/cli fill e12 "password123"
npx @playwright/cli click e15
npx @playwright/cli snapshot  # Verify login succeeded
npx @playwright/cli close
```

### "Take a screenshot of this page"

```bash
npx @playwright/cli open https://example.com
npx @playwright/cli screenshot --filename=capture.png
npx @playwright/cli close
```

### "Walk through the checkout flow on this shop"

```bash
npx @playwright/cli -s=checkout open https://shop.example.com
npx @playwright/cli -s=checkout snapshot
npx @playwright/cli -s=checkout click e20  # Add to cart
npx @playwright/cli -s=checkout snapshot
npx @playwright/cli -s=checkout click e35  # Checkout
npx @playwright/cli -s=checkout snapshot
npx @playwright/cli -s=checkout close
```

## Command Overview

| Category | Commands |
|----------|----------|
| **Browser lifecycle** | `open`, `goto`, `close`, `close-all`, `kill-all` |
| **Interaction** | `click`, `dblclick`, `fill`, `type`, `press`, `hover`, `check`, `uncheck`, `select`, `upload`, `drag` |
| **Navigation** | `go-back`, `go-forward`, `reload` |
| **Content capture** | `snapshot`, `screenshot`, `pdf` |
| **Tab management** | `tab-list`, `tab-new`, `tab-close`, `tab-select` |
| **Cookies** | `cookie-list`, `cookie-get`, `cookie-set`, `cookie-delete`, `cookie-clear` |
| **LocalStorage** | `localstorage-list`, `localstorage-get`, `localstorage-set`, `localstorage-delete`, `localstorage-clear` |
| **SessionStorage** | `sessionstorage-list`, `sessionstorage-get`, `sessionstorage-set`, `sessionstorage-delete`, `sessionstorage-clear` |
| **State** | `state-save`, `state-load` |
| **Network** | `route`, `route-list`, `unroute`, `network` |
| **Debugging** | `console`, `eval`, `run-code`, `tracing-start`, `tracing-stop`, `video-start`, `video-stop` |
| **Sessions** | `-s=name` prefix, `list` |

## Important Rules

- **Always snapshot before interacting** -- element refs come from snapshots
- **Re-snapshot after navigation** -- refs reset on page load
- **Use `--headed` for debugging** -- shows the browser window visually
- **Use `-s=name` for parallel sessions** -- each session is an independent browser
- **Use `--persistent` to save profile** -- browser state survives restarts
- **Prefer `fill` over `type`** -- `fill` clears existing text first, `type` appends
- **Use `snapshot --filename=out.yaml`** to save snapshots to files for later reading

## Anti-Patterns

### Interacting Without a Snapshot

```bash
# BAD -- element refs are unknown
npx @playwright/cli open https://example.com
npx @playwright/cli click e15  # What is e15? Might not exist

# GOOD -- snapshot first to discover refs
npx @playwright/cli open https://example.com
npx @playwright/cli snapshot
npx @playwright/cli click e15  # Now we know what e15 is
```

### Forgetting to Re-Snapshot After Navigation

```bash
# BAD -- refs from old page
npx @playwright/cli click e10  # Navigates to new page
npx @playwright/cli click e20  # e20 is from OLD snapshot!

# GOOD -- re-snapshot after navigation
npx @playwright/cli click e10  # Navigates to new page
npx @playwright/cli snapshot   # Get new refs
npx @playwright/cli click e20  # e20 is from CURRENT page
```

### Using type Instead of fill for Form Fields

```bash
# BAD -- type appends to existing text
npx @playwright/cli type e10 "new text"  # Appended to whatever was there

# GOOD -- fill clears first, then types
npx @playwright/cli fill e10 "new text"  # Field is cleared first
```

## Success Criteria

- Browser session opened and closed cleanly (no orphaned processes)
- Every interaction preceded by a snapshot
- Element references re-obtained after every navigation event
- Extracted data or screenshots saved to files when requested
- Errors diagnosed using console, network, or headed mode

## Reference File IDs

For programmatic access: `command-reference` . `workflows` . `state-and-network`
