# Command Reference

Complete reference for all `npx @playwright/cli` commands.

**Shorthand:** All examples below omit the `npx @playwright/cli` prefix.
In practice, every command starts with `npx @playwright/cli`.

## Contents

- [Global Flags](#global-flags)
- [Browser Lifecycle](#browser-lifecycle) -- open, goto, close, close-all, kill-all
- [Interaction Commands](#interaction-commands) -- click, dblclick, fill, type, press, hover, check, uncheck, select, upload, drag
- [Navigation](#navigation) -- go-back, go-forward, reload
- [Content Capture](#content-capture) -- snapshot, screenshot, pdf
- [Tab Management](#tab-management) -- tab-list, tab-new, tab-close, tab-select
- [Cookie Commands](#cookie-commands) -- cookie-list, cookie-get, cookie-set, cookie-delete, cookie-clear
- [LocalStorage Commands](#localstorage-commands) -- list, get, set, delete, clear
- [SessionStorage Commands](#sessionstorage-commands) -- list, get, set, delete, clear
- [State Commands](#state-commands) -- state-save, state-load
- [Network Commands](#network-commands) -- route, route-list, unroute, network
- [Debugging Commands](#debugging-commands) -- console, eval, run-code, tracing, video
- [Session Management](#session-management) -- named sessions, list

## Global Flags

| Flag | Description |
|------|-------------|
| `-s=<name>` | Named session (parallel browser instances) |
| `--browser=<name>` | Browser engine: `chromium` (default), `firefox`, `webkit` |
| `--headed` | Show browser UI (useful for debugging) |
| `--persistent` | Persist browser profile to disk |
| `--profile=<path>` | Path for persistent profile storage |

## Browser Lifecycle

### open

Launch a browser and navigate to a URL.

```bash
open https://example.com
open https://example.com --browser=firefox
open https://example.com --headed
open https://example.com --persistent --profile=./my-profile
open https://example.com -s=session1
```

| Flag | Description |
|------|-------------|
| `--browser=<name>` | `chromium` (default), `firefox`, `webkit` |
| `--headed` | Show browser window |
| `--persistent` | Save profile to disk |
| `--profile=<path>` | Profile directory path |

### goto

Navigate current page to a new URL (keeps same browser session).

```bash
goto https://example.com/other-page
```

### close

Close the current browser session.

```bash
close
close -s=session1
```

### close-all

Close all open browser sessions.

```bash
close-all
```

### kill-all

Force-kill all browser processes (emergency cleanup).

```bash
kill-all
```

## Interaction Commands

All interaction commands use element references from `snapshot` output.

### click

Click an element.

```bash
click e15
click e15 --button=right     # Right-click
click e15 --count=2           # Double-click (alternative to dblclick)
click e15 --modifiers=Shift   # Shift+click
```

| Flag | Description |
|------|-------------|
| `--button=<left\|right\|middle>` | Mouse button (default: left) |
| `--count=<n>` | Click count |
| `--modifiers=<key>` | Modifier keys: `Shift`, `Control`, `Alt`, `Meta` |

### dblclick

Double-click an element.

```bash
dblclick e15
```

### fill

Clear a field and type new text. **Preferred for form fields.**

```bash
fill e21 "Hello World"
fill e21 ""               # Clear the field
```

### type

Type text character by character (appends to existing text). Use `fill` instead
for form fields unless you specifically need to append.

```bash
type e21 "appended text"
type e21 "slow typing" --delay=100  # 100ms between keystrokes
```

| Flag | Description |
|------|-------------|
| `--delay=<ms>` | Delay between keystrokes in milliseconds |

### press

Press a keyboard key or key combination.

```bash
press e21 Enter
press e21 Control+a
press e21 Tab
press e21 ArrowDown
press e21 Meta+c           # Cmd+C on macOS
```

Common key names: `Enter`, `Tab`, `Escape`, `Backspace`, `Delete`, `ArrowUp`,
`ArrowDown`, `ArrowLeft`, `ArrowRight`, `Home`, `End`, `PageUp`, `PageDown`,
`F1`-`F12`, `Control`, `Shift`, `Alt`, `Meta`.

### hover

Hover over an element.

```bash
hover e15
```

### check

Check a checkbox or radio button.

```bash
check e30
```

### uncheck

Uncheck a checkbox.

```bash
uncheck e30
```

### select

Select an option from a `<select>` dropdown by value.

```bash
select e30 "option-value"
select e30 "value1" "value2"   # Multi-select
```

### upload

Upload a file to a file input.

```bash
upload e40 /path/to/file.pdf
upload e40 /path/to/file1.pdf /path/to/file2.pdf  # Multiple files
```

### drag

Drag one element to another.

```bash
drag e10 e20  # Drag e10 onto e20
```

## Navigation

### go-back

Navigate back in browser history.

```bash
go-back
```

### go-forward

Navigate forward in browser history.

```bash
go-forward
```

### reload

Reload the current page. **Re-snapshot after this -- element refs reset.**

```bash
reload
```

## Content Capture

### snapshot

Capture page state with element references. This is the primary way to discover
what elements exist on the page and get their reference IDs.

```bash
snapshot                          # Output to stdout
snapshot --filename=page.yaml     # Save to file
```

| Flag | Description |
|------|-------------|
| `--filename=<path>` | Save snapshot to file instead of stdout |

Output is a compact representation of visible page elements with reference IDs
(e.g., `e15`, `e21`) that can be used in interaction commands.

### screenshot

Take a screenshot of the current page.

```bash
screenshot                            # Output to stdout (base64)
screenshot --filename=capture.png     # Save to file
screenshot --full-page                # Full page, not just viewport
```

| Flag | Description |
|------|-------------|
| `--filename=<path>` | Save screenshot to file |
| `--full-page` | Capture full scrollable page |

### pdf

Generate a PDF of the current page (Chromium only).

```bash
pdf                              # Output to stdout
pdf --filename=page.pdf          # Save to file
```

| Flag | Description |
|------|-------------|
| `--filename=<path>` | Save PDF to file |

## Tab Management

### tab-list

List all open tabs in the current session.

```bash
tab-list
```

### tab-new

Open a new tab with optional URL.

```bash
tab-new
tab-new https://example.com
```

### tab-close

Close the current tab.

```bash
tab-close
```

### tab-select

Switch to a tab by index (0-based).

```bash
tab-select 0    # First tab
tab-select 2    # Third tab
```

## Cookie Commands

### cookie-list

List all cookies for the current page.

```bash
cookie-list
```

### cookie-get

Get a specific cookie by name.

```bash
cookie-get session_id
```

### cookie-set

Set a cookie.

```bash
cookie-set name=session_id value=abc123
cookie-set name=token value=xyz domain=.example.com path=/ secure=true httpOnly=true
```

| Parameter | Description |
|-----------|-------------|
| `name=<name>` | Cookie name (required) |
| `value=<value>` | Cookie value (required) |
| `domain=<domain>` | Cookie domain |
| `path=<path>` | Cookie path |
| `secure=<bool>` | HTTPS only |
| `httpOnly=<bool>` | Not accessible via JavaScript |
| `sameSite=<Strict\|Lax\|None>` | SameSite attribute |
| `expires=<timestamp>` | Expiration timestamp |

### cookie-delete

Delete a specific cookie by name.

```bash
cookie-delete session_id
```

### cookie-clear

Clear all cookies for the current page.

```bash
cookie-clear
```

## LocalStorage Commands

### localstorage-list

List all localStorage keys and values.

```bash
localstorage-list
```

### localstorage-get

Get a localStorage value by key.

```bash
localstorage-get theme
```

### localstorage-set

Set a localStorage key-value pair.

```bash
localstorage-set theme dark
```

### localstorage-delete

Delete a localStorage key.

```bash
localstorage-delete theme
```

### localstorage-clear

Clear all localStorage.

```bash
localstorage-clear
```

## SessionStorage Commands

Same interface as localStorage commands.

```bash
sessionstorage-list
sessionstorage-get key
sessionstorage-set key value
sessionstorage-delete key
sessionstorage-clear
```

## State Commands

### state-save

Save current browser state (cookies, storage, URL) to a named state.

```bash
state-save logged-in
state-save --filename=state.json
```

### state-load

Restore a previously saved browser state.

```bash
state-load logged-in
state-load --filename=state.json
```

## Network Commands

### route

Intercept and mock network requests matching a URL pattern.

```bash
route "**/api/users" '{"status": 200, "body": "[{\"name\": \"mock\"}]"}'
route "**/api/slow" '{"status": 200, "body": "fast", "headers": {"content-type": "text/plain"}}'
route "**/*.png" '{"status": 404}'  # Block images
```

URL patterns use glob matching (`**` matches any path segment).

### route-list

List all active route intercepts.

```bash
route-list
```

### unroute

Remove a route intercept by URL pattern.

```bash
unroute "**/api/users"
```

### network

Show recent network activity (requests and responses).

```bash
network
network --limit=20
```

| Flag | Description |
|------|-------------|
| `--limit=<n>` | Number of recent entries to show |

## Debugging Commands

### console

Show browser console messages (log, warn, error).

```bash
console
console --limit=50
```

### eval

Evaluate a JavaScript expression in the page context.

```bash
eval "document.title"
eval "window.location.href"
eval "document.querySelectorAll('a').length"
```

### run-code

Run a JavaScript file in the page context.

```bash
run-code script.js
```

### tracing-start

Start recording a trace (for Playwright Trace Viewer).

```bash
tracing-start
tracing-start --filename=trace.zip
```

### tracing-stop

Stop recording and save the trace.

```bash
tracing-stop
tracing-stop --filename=trace.zip
```

### video-start

Start recording video of the browser.

```bash
video-start
video-start --filename=video.webm
```

### video-stop

Stop video recording.

```bash
video-stop
```

## Session Management

### Named Sessions

Prefix any command with `-s=<name>` to run in a named session. Each session is
an independent browser instance.

```bash
-s=admin open https://example.com/admin
-s=user open https://example.com
-s=admin snapshot
-s=user snapshot
```

### list

List all active sessions.

```bash
list
```
