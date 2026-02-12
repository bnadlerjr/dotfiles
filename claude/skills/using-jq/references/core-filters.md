# Core jq Filters

Practical reference for jq filter syntax and built-in functions.

## Basic Access

```bash
# Field access
jq '.name'                   # top-level field
jq '.user.name'              # nested field
jq '.["key-with-dashes"]'    # keys with special characters
jq '.user["first-name"]'     # mixed access

# Optional access (suppress errors on null/missing)
jq '.user.name?'             # no error if .user is null
jq '.items[]?'               # no error if .items is null
```

## Array Operations

```bash
# Index access
jq '.[0]'                    # first element
jq '.[-1]'                   # last element
jq '.[2:5]'                  # slice (index 2, 3, 4)
jq '.[:3]'                   # first 3 elements
jq '.[-2:]'                  # last 2 elements

# Iteration
jq '.[]'                     # iterate all elements
jq '.items[]'                # iterate array at key

# Length and membership
jq 'length'                  # array/object/string length
jq '.items | length'         # count items
jq 'first'                   # first element (same as .[0])
jq 'last'                    # last element (same as .[-1])

# map — transform each element
jq 'map(.name)'              # extract field from each
jq 'map(. + 1)'              # add 1 to each number
jq 'map(select(. > 5))'     # keep elements > 5

# select — filter elements
jq '.[] | select(.age > 30)'                     # filter by condition
jq '.[] | select(.status == "active")'            # filter by string match
jq '.[] | select(.name | test("^A"))'             # filter by regex
jq '.[] | select(.tags | any(. == "important"))'  # filter by array contents

# Sorting and uniqueness
jq 'sort'                    # sort array
jq 'sort_by(.name)'          # sort by field
jq 'sort_by(.date) | reverse'  # sort descending
jq 'unique'                  # deduplicate
jq 'unique_by(.id)'          # deduplicate by field
jq 'group_by(.category)'     # group into sub-arrays

# Flattening
jq 'flatten'                 # flatten nested arrays
jq 'flatten(1)'              # flatten one level
```

## Object Construction

```bash
# Build new objects
jq '{name: .user.name, email: .user.email}'    # pick fields
jq '{(.key): .value}'                           # computed key
jq '{id, name}'                                 # shorthand for {id: .id, name: .name}

# Merge objects
jq '. + {status: "active"}'    # add/overwrite field
jq '. * {defaults: true}'      # recursive merge
jq '.[0] + .[1]'               # merge two objects

# Delete fields
jq 'del(.password)'            # remove a field
jq 'del(.users[0])'            # remove array element

# Object introspection
jq 'keys'                      # array of keys
jq 'values'                    # array of values
jq 'has("name")'               # check key existence
jq 'to_entries'                # [{key, value}, ...]
jq 'from_entries'              # reverse of to_entries
jq 'with_entries(select(.value != null))'  # filter by value
jq 'with_entries(.value |= tostring)'      # transform values
```

## Conditionals

```bash
# if-then-else
jq 'if .status == "active" then "yes" else "no" end'

# Alternative operator (null coalescing)
jq '.name // "unknown"'         # default if null/false
jq '.items // []'               # default empty array
jq '.count // 0'                # default zero

# try-catch
jq 'try .foo.bar catch "missing"'
jq 'try (.num | tonumber) catch 0'

# Type checking
jq '.value | type'              # "string", "number", "array", etc.
jq 'if type == "array" then length else 1 end'
```

## String Operations

```bash
# String interpolation
jq '"Name: \(.name), Age: \(.age)"'
jq '"\(.first) \(.last)"'

# Manipulation
jq '.name | ascii_downcase'
jq '.name | ascii_upcase'
jq '.text | ltrimstr("prefix_")'
jq '.text | rtrimstr("_suffix")'
jq '.csv | split(",")'          # string -> array
jq '.tags | join(", ")'         # array -> string

# Regex
jq '.name | test("^[A-Z]")'                  # boolean match
jq '.log | capture("(?<code>\\d{3})")'       # named capture groups
jq '.items[] | select(.name | test("error"; "i"))'  # case-insensitive
jq '.text | scan("[0-9]+")'                   # find all matches
jq '.text | gsub("old"; "new")'              # global replace

# Length and containment
jq '.name | length'             # string length
jq '.name | contains("foo")'   # substring check
jq '.name | startswith("pre")'
jq '.name | endswith("suf")'
```

## Common Built-ins

```bash
# Type conversion
jq '.num | tostring'
jq '.str | tonumber'
jq '.val | type'

# Math
jq '[.prices[]] | add'          # sum
jq '[.scores[]] | add / length' # average
jq '[.values[]] | min'
jq '[.values[]] | max'
jq '.num | floor'
jq '.num | ceil'
jq '.num | fabs'                # absolute value

# Array reduction
jq 'any(. > 10)'               # true if any element matches
jq 'all(. > 0)'                # true if all elements match
jq '[.items[] | .price] | add'  # sum a field

# Null handling
jq '.items | values'            # strip null elements
jq 'map(select(. != null))'    # explicit null filter
jq '.field // empty'            # suppress null (produce no output)

# Dates (jq 1.6+)
jq '.timestamp | todate'                    # epoch -> ISO 8601
jq '.date | fromdateiso8601'                # ISO 8601 -> epoch
jq 'now | todate'                           # current time
```

## Combining Filters

```bash
# Pipe — feed output to next filter
jq '.items[] | .name | ascii_upcase'

# Comma — multiple outputs from same input
jq '.name, .email'              # two separate outputs
jq '{name, email}'              # combine into object instead

# Concatenation
jq '[.a[], .b[]]'               # merge two arrays
jq '.arr1 + .arr2'              # concatenate arrays

# Recursive descent — search all levels of nested structure
jq '.. | .id? // empty'         # find all "id" fields at any depth
jq '.. | objects | select(has("error"))'  # find objects with "error" key
jq '[.. | numbers]'             # collect all numbers in the tree
jq '.. | strings | select(test("TODO"))'  # find strings matching pattern

# Transpose parallel arrays
jq '[.names, .ages] | transpose | map({name: .[0], age: .[1]})'
```

## Variable Binding

```bash
# Internal variables
jq '.max as $m | .items[] | select(.val > $m)'
jq '. as $root | .ids[] | $root.users[.]'

# External variables from shell
jq --arg status "$STATUS" '.[] | select(.status == $status)'
jq --argjson limit "$LIMIT" '.[:$limit]'
jq --argjson enabled true '.settings.feature = $enabled'
jq --rawfile template tmpl.txt '.body = $template'
jq --slurpfile config config.json '. + $config[0]'

# Multiple external variables
jq --arg user "$USER" --arg role "$ROLE" \
  '.[] | select(.user == $user and .role == $role)'
```

## Slurp Mode

```bash
# Process multiple JSON inputs as a single array
jq -s '.'                       # collect all inputs into array
jq -s 'add'                     # merge multiple objects
jq -s 'map(.count) | add'       # sum field across files
jq -s 'sort_by(.date)'          # sort records from multiple inputs

# Process JSONL (newline-delimited JSON)
jq -s 'length' events.jsonl     # count lines
jq -s 'group_by(.type)' events.jsonl
```
