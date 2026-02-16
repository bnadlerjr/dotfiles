# State and Network

Managing cookies, storage, browser state, and network interception.

**Shorthand:** All examples below omit the `npx @playwright/cli` prefix.

## Cookies

### Inspecting Cookies

```bash
cookie-list                    # List all cookies
cookie-get session_id          # Get specific cookie
```

### Setting Cookies

```bash
# Simple cookie
cookie-set name=theme value=dark

# Full cookie with all attributes
cookie-set name=session_id value=abc123 domain=.example.com path=/ secure=true httpOnly=true sameSite=Strict expires=1735689600
```

**Cookie attributes:**

| Attribute | Example | Description |
|-----------|---------|-------------|
| `name` | `name=token` | Cookie name (required) |
| `value` | `value=abc` | Cookie value (required) |
| `domain` | `domain=.example.com` | Domain scope (leading dot = include subdomains) |
| `path` | `path=/api` | Path scope |
| `secure` | `secure=true` | HTTPS only |
| `httpOnly` | `httpOnly=true` | No JavaScript access |
| `sameSite` | `sameSite=Lax` | `Strict`, `Lax`, or `None` |
| `expires` | `expires=1735689600` | Unix timestamp |

### Managing Cookies

```bash
cookie-delete session_id      # Delete one cookie
cookie-clear                  # Delete all cookies
```

### Cookie Workflow: Inject Auth Token

```bash
open https://example.com
cookie-set name=auth_token value=eyJhbG... domain=.example.com path=/ secure=true httpOnly=true
reload                        # Reload to apply cookie
snapshot                      # Verify authenticated state
```

## LocalStorage

### Read and Write

```bash
localstorage-list                      # List all keys
localstorage-get theme                 # Get value for key
localstorage-set theme dark            # Set key=value
localstorage-set user '{"name":"Bob"}' # JSON values as strings
```

### Clean Up

```bash
localstorage-delete theme              # Delete one key
localstorage-clear                     # Delete all keys
```

### LocalStorage Workflow: Set App Preferences

```bash
open https://example.com
localstorage-set language en
localstorage-set theme dark
localstorage-set onboarding_complete true
reload                                 # Apply preferences
snapshot
```

## SessionStorage

Same interface as localStorage. Data persists only for the browser tab lifetime.

```bash
sessionstorage-list
sessionstorage-get key
sessionstorage-set key value
sessionstorage-delete key
sessionstorage-clear
```

## State Save/Load

Save and restore full browser state (cookies + storage + URL) as named states.

### Save State

```bash
open https://example.com/login
snapshot
fill e10 "user@example.com"
fill e12 "password"
click e15
snapshot                      # Verify logged in
state-save logged-in          # Save as named state
```

### Load State

```bash
open https://example.com
state-load logged-in          # Restore cookies, storage, URL
snapshot                      # Verify restored state
```

### State File

```bash
state-save --filename=auth-state.json    # Save to file
state-load --filename=auth-state.json    # Load from file
```

State files are portable -- save once, load in any future session.

## Network Interception

### Route Basics

Intercept HTTP requests matching a URL pattern and return mock responses.

```bash
# Mock an API endpoint
route "**/api/users" '{"status": 200, "body": "[{\"id\": 1, \"name\": \"Mock User\"}]", "headers": {"content-type": "application/json"}}'

# Block requests (return 404)
route "**/*.png" '{"status": 404}'
route "**/analytics/**" '{"status": 404}'

# Return custom error
route "**/api/checkout" '{"status": 500, "body": "Internal Server Error"}'
```

**URL patterns** use glob matching:
- `**` matches any path segments
- `*` matches any single path segment
- Patterns match against the full URL

### Managing Routes

```bash
route-list                    # List active intercepts
unroute "**/api/users"        # Remove specific intercept
```

### Network Monitoring

```bash
network                       # Show recent requests/responses
network --limit=50            # Show more entries
```

### Route Workflow: Mock API for Testing

```bash
open https://example.com

# Set up mocks before navigating
route "**/api/products" '{"status": 200, "body": "[{\"name\": \"Test Product\", \"price\": 9.99}]", "headers": {"content-type": "application/json"}}'
route "**/api/user" '{"status": 200, "body": "{\"name\": \"Test User\", \"role\": \"admin\"}", "headers": {"content-type": "application/json"}}'

goto https://example.com/dashboard
snapshot                      # Page loads with mocked data
```

### Route Workflow: Simulate Errors

```bash
open https://example.com/checkout

# Mock a payment failure
route "**/api/payment" '{"status": 402, "body": "{\"error\": \"Payment declined\"}", "headers": {"content-type": "application/json"}}'

snapshot
fill e10 "4111111111111111"   # Card number
click e20                     # Submit payment
snapshot                      # Verify error handling UI
unroute "**/api/payment"      # Remove mock for normal flow
```

### Route Workflow: Block Third-Party Resources

```bash
# Speed up page load by blocking non-essential resources
route "**/*.gif" '{"status": 404}'
route "**/analytics/**" '{"status": 404}'
route "**/ads/**" '{"status": 404}'
route "**/tracking/**" '{"status": 404}'

open https://example.com      # Loads faster without blocked resources
snapshot
```

## Combining State and Network

### Full Test Setup

```bash
# 1. Open browser
open https://example.com

# 2. Inject auth state
cookie-set name=auth_token value=test-token domain=.example.com secure=true httpOnly=true
localstorage-set user_prefs '{"theme":"dark","locale":"en"}'

# 3. Mock external APIs
route "**/api/external-service" '{"status": 200, "body": "{\"status\": \"healthy\"}", "headers": {"content-type": "application/json"}}'

# 4. Navigate and interact
goto https://example.com/dashboard
snapshot

# 5. Save this setup for reuse
state-save test-setup
```

### Restore Full Setup

```bash
open https://example.com
state-load test-setup
route "**/api/external-service" '{"status": 200, "body": "{\"status\": \"healthy\"}", "headers": {"content-type": "application/json"}}'
goto https://example.com/dashboard
snapshot
```

Note: `state-load` restores cookies and storage but not network routes.
Re-apply routes after loading state.
