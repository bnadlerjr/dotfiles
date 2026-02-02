# Bash-Specific Features

Advanced features available in Bash 3.x and 4.x+.

## When to Use Bash Features

Choose Bash-specific features when:
- Script explicitly requires `#!/bin/bash` or `#!/usr/bin/env bash`
- Target systems have Bash 4+ (Linux) or Bash 3.2 (macOS default)
- Features significantly improve readability or functionality
- You've documented the Bash version requirement

## Arrays

### Indexed Arrays

```bash
# Declaration
declare -a fruits=("apple" "banana" "cherry")
files=(*.txt)              # Glob expansion into array

# Access
echo "${fruits[0]}"        # First element
echo "${fruits[-1]}"       # Last element (Bash 4.3+)
echo "${fruits[@]}"        # All elements (preserves spacing)
echo "${#fruits[@]}"       # Array length

# Iteration
for fruit in "${fruits[@]}"; do
    echo "$fruit"
done

# Slicing
echo "${fruits[@]:1:2}"    # Elements 1-2 (banana cherry)

# Append
fruits+=("date")

# Delete element
unset 'fruits[1]'          # Leaves gap in indices
```

### Associative Arrays (Bash 4+)

```bash
declare -A colors
colors[red]="#ff0000"
colors[green]="#00ff00"
colors[blue]="#0000ff"

echo "${colors[red]}"      # Access by key
echo "${!colors[@]}"       # All keys
echo "${colors[@]}"        # All values

# Iterate
for key in "${!colors[@]}"; do
    echo "$key: ${colors[$key]}"
done

# Check key exists
if [[ -v colors[red] ]]; then
    echo "red exists"
fi
```

## Extended Test Constructs

### [[ ]] Double Brackets

```bash
# Pattern matching (no quotes on pattern)
[[ "$file" == *.txt ]]

# Regex matching
[[ "$email" =~ ^[a-z]+@[a-z]+\.[a-z]+$ ]]
echo "${BASH_REMATCH[0]}"  # Full match
echo "${BASH_REMATCH[1]}"  # First capture group

# Logical operators
[[ -f "$file" && -r "$file" ]]
[[ "$a" == "x" || "$a" == "y" ]]

# No word splitting - safe without quotes
[[ $var == "test" ]]       # Works even with spaces in var
```

### (( )) Arithmetic

```bash
# Arithmetic evaluation
((count++))
((total = a + b * c))
((i += 5))

# Arithmetic conditionals
if ((count > 10)); then
    echo "large"
fi

# Ternary
((result = (a > b) ? a : b))
```

## Parameter Expansion

### Substring Operations

```bash
str="Hello World"
echo "${str:0:5}"          # Hello (offset:length)
echo "${str:6}"            # World (offset to end)
echo "${str: -5}"          # World (last 5, note space)
echo "${#str}"             # 11 (length)
```

### Search and Replace

```bash
path="/usr/local/bin/script.sh"

# Remove patterns
echo "${path#*/}"          # usr/local/bin/script.sh (shortest from start)
echo "${path##*/}"         # script.sh (longest from start)
echo "${path%/*}"          # /usr/local/bin (shortest from end)
echo "${path%%/*}"         # (empty - longest from end)

# Substitution
echo "${path/bin/lib}"     # First occurrence
echo "${path//\//\\}"      # All occurrences (/ to \)
```

### Case Modification (Bash 4+)

```bash
str="Hello World"
echo "${str,,}"            # hello world (lowercase)
echo "${str^^}"            # HELLO WORLD (uppercase)
echo "${str^}"             # Hello world (capitalize first)
```

### Default Values

```bash
# If unset or null
echo "${var:-default}"     # Use default
echo "${var:=default}"     # Assign default
echo "${var:?error msg}"   # Error if unset
echo "${var:+alternate}"   # Use alternate if set
```

## Process Substitution

```bash
# Treat command output as file
diff <(sort file1) <(sort file2)

# Feed into command expecting file
while read -r line; do
    echo "$line"
done < <(find . -name "*.txt")

# Write to multiple destinations
tee >(gzip > file.gz) >(wc -l > count.txt) < input.txt
```

## Here Strings

```bash
# Feed string to stdin
grep "pattern" <<< "$variable"

# Versus here document
grep "pattern" <<EOF
$variable
EOF
```

## Coprocesses (Bash 4+)

```bash
# Start coprocess
coproc myproc { while read -r line; do echo "GOT: $line"; done; }

# Write to coprocess
echo "hello" >&"${myproc[1]}"

# Read from coprocess
read -r response <&"${myproc[0]}"
echo "$response"

# Close
exec {myproc[1]}>&-
```

## Useful Bash Built-ins

### mapfile / readarray (Bash 4+)

```bash
# Read file into array
mapfile -t lines < file.txt

# Read with callback
mapfile -t -C 'process_line' -c 1 lines < file.txt

# From command
mapfile -t files < <(find . -name "*.txt")
```

### printf -v

```bash
# Assign to variable instead of stdout
printf -v formatted "Value: %05d" "$number"
echo "$formatted"
```

### read Options

```bash
# Timeout
read -t 5 -p "Enter value: " value

# Silent (passwords)
read -s -p "Password: " password

# Single character
read -n 1 -p "Continue? [y/n] " answer

# With default via -i (Bash 4+)
read -e -i "default" -p "Value: " value
```

## Version Detection

```bash
# Check Bash version
if ((BASH_VERSINFO[0] >= 4)); then
    declare -A assoc_array
else
    echo "Bash 4+ required for associative arrays" >&2
    exit 1
fi

# Feature detection
if [[ -v BASH_VERSINFO ]]; then
    echo "Running in Bash"
fi
```
