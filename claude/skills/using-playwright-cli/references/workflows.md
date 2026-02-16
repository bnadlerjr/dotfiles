# Workflows

Common patterns and multi-step workflows for playwright-cli.

**Shorthand:** All examples below omit the `npx @playwright/cli` prefix.

## The Snapshot-First Loop

Every interaction follows this loop:

```
snapshot -> read refs -> interact -> snapshot -> read refs -> ...
```

Element references (e.g., `e15`) are assigned by `snapshot` and are valid only
until the next navigation event. Always re-snapshot after:

- `goto` (new URL)
- `click` that triggers navigation
- `reload`
- `go-back` / `go-forward`
- Form submission that redirects

**Safe operations** that do NOT invalidate refs: `fill`, `type`, `press`, `hover`,
`check`, `uncheck`, `select`, `screenshot`, `pdf`.

## Form Filling Workflow

```bash
open https://example.com/register
snapshot
# Read snapshot output -- identify form field refs
fill e10 "Jane Doe"              # Name field
fill e12 "jane@example.com"      # Email field
fill e14 "secure-password-123"   # Password field
select e16 "US"                  # Country dropdown
check e18                        # Terms checkbox
click e20                        # Submit button
snapshot                         # Verify success page
close
```

**Tips:**
- Use `fill` (not `type`) for input fields -- `fill` clears first
- Use `select` for dropdowns, `check`/`uncheck` for checkboxes
- Use `press e14 Tab` to move between fields if needed
- Snapshot after submit to verify the result

## Data Scraping Workflow

```bash
open https://example.com/products
snapshot --filename=products.yaml
# Read products.yaml to extract product data
# If paginated, navigate to next page:
click e50  # Next page button
snapshot --filename=products-page2.yaml
close
```

**Tips:**
- Save snapshots to files for easier parsing with the Read tool
- For large datasets, paginate through results
- Use `eval` for data that is not visible in the snapshot:
  ```bash
  eval "JSON.stringify(window.__PRODUCT_DATA__)"
  ```

## Multi-Page Navigation Workflow

```bash
open https://example.com
snapshot
click e5       # Navigate to About page
snapshot       # MUST re-snapshot -- refs changed
click e12      # Navigate to Team page
snapshot       # MUST re-snapshot again
screenshot --filename=team.png
close
```

## Authentication Workflow

### Login and Save State

```bash
open https://example.com/login
snapshot
fill e10 "user@example.com"
fill e12 "password"
click e15       # Login button
snapshot        # Verify logged in
state-save logged-in
close
```

### Reuse Saved State

```bash
open https://example.com
state-load logged-in
goto https://example.com/dashboard
snapshot
close
```

## Multi-Tab Workflow

```bash
open https://example.com
tab-new https://example.com/settings
tab-list                    # See all tabs
tab-select 0                # Switch to first tab
snapshot                    # Snapshot first tab
tab-select 1                # Switch to settings tab
snapshot                    # Snapshot settings tab
close
```

## Parallel Sessions Workflow

Run multiple independent browsers simultaneously.

```bash
# Open two sessions
-s=admin open https://example.com/admin --headed
-s=customer open https://example.com/shop --headed

# Work in admin session
-s=admin snapshot
-s=admin click e10  # Create a product

# Work in customer session
-s=customer snapshot
-s=customer click e5  # Browse products

# Verify the product appears for the customer
-s=customer reload
-s=customer snapshot

# Clean up
close-all
```

## Screenshot Comparison Workflow

```bash
open https://example.com
screenshot --filename=before.png
# Make changes (click, fill, etc.)
click e10
snapshot
screenshot --filename=after.png
close
# Use Read tool to view both screenshots
```

## Debugging a Failing Interaction

When a command does not produce the expected result:

1. **Take a snapshot** -- confirm the element ref exists and points to what you expect
2. **Use `--headed`** -- open browser with `--headed` flag to see what is happening
3. **Check console** -- run `console` to see JavaScript errors
4. **Check network** -- run `network` to see failed requests
5. **Try eval** -- use `eval` to inspect the DOM directly

```bash
open https://example.com --headed
snapshot
click e15                   # Did not work as expected
console                     # Check for JS errors
network                     # Check for failed requests
eval "document.querySelector('#submit').disabled"  # Check element state
```

## PDF Generation Workflow

```bash
open https://example.com/report
# Wait for dynamic content to load
snapshot   # Verify content is present
pdf --filename=report.pdf
close
```

## Persistent Profile Workflow

Maintain browser state across sessions (login, preferences, etc.).

```bash
# First run -- set up profile
open https://example.com --persistent --profile=./my-profile
snapshot
# Log in, set preferences, etc.
close

# Later runs -- profile is preserved
open https://example.com --persistent --profile=./my-profile
snapshot  # Already logged in, preferences intact
close
```

## Tracing Workflow

Record a trace for debugging complex interactions.

```bash
open https://example.com
tracing-start
# Perform all interactions
snapshot
click e10
fill e20 "data"
click e30
tracing-stop --filename=trace.zip
close
# Open trace.zip in Playwright Trace Viewer for detailed analysis
```

## Video Recording Workflow

```bash
open https://example.com
video-start --filename=session.webm
# Perform all interactions
snapshot
click e10
snapshot
video-stop
close
```
