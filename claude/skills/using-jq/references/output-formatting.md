# Output Formatting

Patterns for getting jq output into the right shape for shell consumption.

## Raw Output (`-r`)

Always use `-r` when output feeds into shell variables, pipes, or further text processing. Without `-r`, strings include surrounding double quotes.

```bash
# Without -r: "John Smith" (with quotes)
# With -r:    John Smith   (bare string)
echo '{"name":"John Smith"}' | jq -r '.name'

# MUST use -r for:
# - Shell variable assignment
# - Piping to other commands (grep, awk, cut)
# - @tsv, @csv, @text formatters
# - Any output consumed as plain text
```

## Tab-Separated Values (`@tsv`)

Use `@tsv` to produce columnar output suitable for `column`, `cut`, or `awk`.

```bash
# Basic TSV
jq -r '.users[] | [.name, .email, .role] | @tsv'

# With column alignment
jq -r '.users[] | [.name, .email, .role] | @tsv' data.json | column -t

# With header row
{
  echo -e "NAME\tEMAIL\tROLE"
  jq -r '.users[] | [.name, .email, .role] | @tsv' data.json
} | column -t

# Handling nulls in TSV (replace with empty string)
jq -r '.items[] | [.name, (.email // ""), (.phone // "")] | @tsv'
```

## CSV Output (`@csv`)

```bash
# Basic CSV (values are quoted and escaped)
jq -r '.users[] | [.name, .email, .role] | @csv'

# With header
{
  echo '"Name","Email","Role"'
  jq -r '.users[] | [.name, .email, .role] | @csv'
} > output.csv

# Note: @csv properly escapes embedded commas and quotes
echo '[{"name":"Smith, John","note":"He said \"hi\""}]' |
  jq -r '.[] | [.name, .note] | @csv'
# Output: "Smith, John","He said ""hi"""
```

## Shell Variable Assignment

```bash
# Single value
name="$(echo "$json" | jq -r '.name')"

# Multiple values from one parse (avoid parsing JSON multiple times)
read -r name email role <<< "$(echo "$json" | jq -r '[.name, .email, .role] | @tsv')"

# Into separate variables with explicit IFS
IFS=$'\t' read -r key summary status <<< "$(
  echo "$json" | jq -r '[.key, .fields.summary, .fields.status.name] | @tsv'
)"
```

## Loop Processing

```bash
# Iterate JSON array elements
echo "$json" | jq -r '.items[].name' | while read -r name; do
  echo "Processing: $name"
done

# Iterate with multiple fields per row
echo "$json" | jq -r '.items[] | [.id, .name] | @tsv' |
  while IFS=$'\t' read -r id name; do
    echo "Item $id: $name"
  done

# Populate a bash array
mapfile -t names < <(echo "$json" | jq -r '.items[].name')
echo "Found ${#names[@]} items"
for name in "${names[@]}"; do
  echo "- $name"
done

# Associative array from key-value pairs
declare -A config
while IFS=$'\t' read -r key value; do
  config["$key"]="$value"
done < <(echo "$json" | jq -r 'to_entries[] | [.key, .value] | @tsv')
```

## Null Handling

Null values are a common source of bugs when jq output feeds into shell scripts.

```bash
# Skip nulls entirely (produce no output for that element)
jq -r '.items[].optional_field // empty'

# Replace nulls with defaults
jq -r '.name // "unknown"'
jq -r '.count // 0'
jq -r '.tags // []'

# Strip null values from an array
jq '[.items[] | values]'                  # remove null elements
jq 'map(select(. != null))'              # equivalent explicit filter

# Strip null-valued keys from objects
jq 'with_entries(select(.value != null))'

# Conditional output based on null
jq -r 'if .email then "Email: \(.email)" else "No email on file" end'
```

## Compact vs Pretty Print

```bash
# Pretty-print (default) — for human reading
jq '.' data.json

# Compact (-c) — one JSON object per line, for JSONL or piping
jq -c '.items[]' data.json

# Compact is essential for:
# - Writing JSONL (newline-delimited JSON)
# - Storing JSON in variables without newlines
# - Feeding JSON objects to xargs or parallel
jq -c '.items[]' data.json | while read -r item; do
  echo "$item" | jq -r '.name'
done
```

## Formatting Strings

```bash
# String interpolation for custom formats
jq -r '"\(.key): \(.fields.summary) [\(.fields.status.name)]"'

# Padding/alignment with printf after jq
jq -r '.items[] | [.id, .name] | @tsv' | while IFS=$'\t' read -r id name; do
  printf "%-8s %s\n" "$id" "$name"
done

# JSON to markdown table
{
  echo "| Key | Summary | Status |"
  echo "| --- | ------- | ------ |"
  jq -r '.issues[] | "| \(.key) | \(.fields.summary) | \(.fields.status.name) |"'
} <<< "$json"

# Colorized output (for terminal display)
jq -r '.items[] | select(.status == "error") |
  "\u001b[31m\(.name)\u001b[0m: \(.message)"'
```
