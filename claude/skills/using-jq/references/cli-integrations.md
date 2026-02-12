# CLI Tool Integration Patterns

Practical jq patterns for common command-line tools that produce JSON.

## Jira CLI (ankitpokhrel/jira-cli)

### When to Use jq vs Built-in Formatting

The Jira CLI has `--plain` and `--no-headers` for simple tabular output. Use jq when you need:
- Specific nested fields not available in `--columns`
- Conditional filtering beyond JQL
- Custom output formatting or data transformation

### Issue Views (Raw JSON)

```bash
# Get raw JSON for a single issue
jira issue view PROJ-123 --raw | jq -r '.fields.summary'

# Extract multiple fields
jira issue view PROJ-123 --raw | jq -r '{
  key: .key,
  summary: .fields.summary,
  status: .fields.status.name,
  assignee: .fields.assignee.displayName // "Unassigned"
}'

# Get all comments
jira issue view PROJ-123 --raw | jq -r '
  .fields.comment.comments[] |
  "\(.author.displayName) (\(.created[:10])): \(.body)"'

# Extract subtask keys
jira issue view PROJ-123 --raw | jq -r '
  .fields.subtasks[] | "\(.key): \(.fields.summary) [\(.fields.status.name)]"'

# Get custom field value (find field ID first with keys)
jira issue view PROJ-123 --raw | jq '.fields | keys[] | select(startswith("customfield"))'
jira issue view PROJ-123 --raw | jq -r '.fields.customfield_10001'
```

### Issue Lists

```bash
# List issues as TSV for further processing
jira issue list --raw -q "project = PROJ AND sprint in openSprints()" | jq -r '
  .issues[] | [.key, .fields.status.name, .fields.summary] | @tsv'

# Filter by assignee locally (supplement JQL)
jira issue list --raw -q "project = PROJ" | jq -r --arg user "Bob" '
  .issues[] | select(.fields.assignee.displayName == $user) |
  "\(.key): \(.fields.summary)"'

# Count issues by status
jira issue list --raw -q "project = PROJ AND sprint in openSprints()" | jq '
  [.issues[] | .fields.status.name] | group_by(.) |
  map({status: .[0], count: length}) | sort_by(.count) | reverse'

# Extract story points total
jira issue list --raw -q "project = PROJ AND sprint in openSprints()" | jq '
  [.issues[] | .fields.customfield_10001 // 0] | add'
```

### Epic and Sprint Data

```bash
# List epic children with status
jira epic list PROJ-100 --raw | jq -r '
  .issues[] | "\(.key)\t\(.fields.status.name)\t\(.fields.summary)"' | column -t

# Sprint velocity (points completed per sprint)
jira sprint list --board-id 42 --raw | jq -r '
  .values[] | select(.state == "closed") |
  "\(.name): \(.completeDate[:10])"'
```

## GitHub CLI (gh)

### Using `--jq` vs Piping to jq

`gh` has built-in `--jq` for simple extractions. Use external jq for complex transformations:

```bash
# Built-in --jq: simple field extraction
gh pr list --json number,title --jq '.[].title'

# External jq: complex transformations, multiple passes, variables
gh pr list --json number,title,author | jq -r '
  .[] | "\(.number)\t\(.author.login)\t\(.title)"' | column -t
```

### Pull Requests

```bash
# List PRs with key details
gh pr list --json number,title,author,createdAt,reviewDecision | jq -r '
  .[] | [.number, .author.login, .reviewDecision // "PENDING", .title] | @tsv' |
  column -t

# Find PRs needing review
gh pr list --json number,title,reviewDecision,reviewRequests | jq -r '
  .[] | select(.reviewDecision != "APPROVED") |
  "#\(.number): \(.title)"'

# PR review status summary
gh pr list --json number,title,reviewDecision | jq '
  group_by(.reviewDecision) |
  map({decision: .[0].reviewDecision, count: length})'

# Get changed files for a PR
gh pr view 123 --json files | jq -r '.files[].path'

# PR with check status
gh pr list --json number,title,statusCheckRollup | jq -r '
  .[] | "\(.number)\t\(.title)\t\(
    [.statusCheckRollup[]?.conclusion // "PENDING"] |
    if all(. == "SUCCESS") then "PASS" else "FAIL" end
  )"'
```

### Issues

```bash
# List issues with labels
gh issue list --json number,title,labels | jq -r '
  .[] | "\(.number)\t\(.title)\t\([.labels[].name] | join(", "))"' |
  column -t

# Count issues by label
gh issue list --limit 200 --json labels | jq '
  [.[].labels[].name] | group_by(.) |
  map({label: .[0], count: length}) | sort_by(.count) | reverse'

# Find issues assigned to you
gh issue list --json number,title,assignees | jq -r --arg me "$(gh api user | jq -r .login)" '
  .[] | select(.assignees | any(.login == $me)) |
  "#\(.number): \(.title)"'
```

### GitHub API

```bash
# Direct API calls return JSON
gh api repos/{owner}/{repo}/pulls | jq -r '.[].title'

# Paginated results
gh api repos/{owner}/{repo}/issues --paginate | jq -r '.[].title'

# GraphQL queries
gh api graphql -f query='{ viewer { login } }' | jq -r '.data.viewer.login'

# Create with JSON input
gh api repos/{owner}/{repo}/issues -f title="Bug" -f body="Description" |
  jq -r '"Created: #\(.number) - \(.html_url)"'
```

## curl + REST APIs

### Basic Patterns

```bash
# Pretty-print JSON response
curl -s https://api.example.com/data | jq '.'

# Extract specific field
curl -s https://api.example.com/users/1 | jq -r '.name'

# With authentication
curl -s -H "Authorization: Bearer $TOKEN" https://api.example.com/me |
  jq -r '.email'
```

### Error Detection

```bash
# Check for error response before processing
response=$(curl -s https://api.example.com/data)
if echo "$response" | jq -e '.error' >/dev/null 2>&1; then
  echo "API error: $(echo "$response" | jq -r '.error.message')" >&2
  exit 1
fi
echo "$response" | jq -r '.data[]'

# Using HTTP status code + jq
http_code=$(curl -s -o response.json -w '%{http_code}' https://api.example.com/data)
if [[ "$http_code" -ne 200 ]]; then
  jq -r '.message // .error // "Unknown error"' response.json >&2
  exit 1
fi
jq -r '.results[]' response.json
```

### Paginated APIs

```bash
# Follow pagination via Link header (simplified)
url="https://api.example.com/items?per_page=100"
while [[ -n "$url" ]]; do
  response=$(curl -s -D headers.tmp "$url")
  echo "$response" | jq -r '.[] | .name'
  url=$(grep -i '^link:' headers.tmp | grep -o '<[^>]*>; rel="next"' | grep -o 'http[^>]*' || true)
done

# Offset-based pagination
page=1
while true; do
  result=$(curl -s "https://api.example.com/items?page=$page&per_page=50")
  count=$(echo "$result" | jq '.items | length')
  [[ "$count" -eq 0 ]] && break
  echo "$result" | jq -r '.items[] | .name'
  ((page++))
done
```

### POST with JSON Body

```bash
# Send JSON, process response
curl -s -X POST https://api.example.com/items \
  -H 'Content-Type: application/json' \
  -d '{"name": "test", "active": true}' |
  jq -r '"Created: \(.id) - \(.name)"'

# Build request body with jq
payload=$(jq -n --arg name "$NAME" --argjson count "$COUNT" \
  '{name: $name, count: $count}')
curl -s -X POST https://api.example.com/items \
  -H 'Content-Type: application/json' \
  -d "$payload" | jq '.'
```
