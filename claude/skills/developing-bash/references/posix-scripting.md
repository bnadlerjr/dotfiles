# POSIX Shell Scripting

Patterns for maximum portability across Unix-like systems.

## When to Use POSIX

Choose POSIX sh when:
- Script runs on minimal systems (Alpine, BusyBox, embedded)
- Targeting multiple Unix variants (Linux, macOS, BSDs, Solaris)
- Writing system init scripts or package maintainer scripts
- Bash may not be installed or is an older version

## Shebang Lines

```bash
#!/bin/sh              # System POSIX shell (may be dash, ash, etc.)
#!/usr/bin/env sh      # Portable, uses PATH lookup
```

## POSIX-Safe Constructs

### Conditionals

```bash
# Use [ ] (test) not [[ ]]
if [ "$var" = "value" ]; then
    echo "match"
fi

# String comparison uses single =
[ "$a" = "$b" ]    # Correct
[ "$a" == "$b" ]   # Bash-only, avoid

# Numeric comparison
[ "$num" -eq 5 ]
[ "$num" -lt 10 ]
[ "$num" -gt 0 ]

# File tests
[ -f "$file" ]     # Regular file exists
[ -d "$dir" ]      # Directory exists
[ -r "$file" ]     # Readable
[ -w "$file" ]     # Writable
[ -x "$file" ]     # Executable
[ -s "$file" ]     # Non-empty file
```

### Variables

```bash
# No arrays in POSIX - use space-separated strings or positional params
items="one two three"
for item in $items; do    # Intentionally unquoted for word splitting
    echo "$item"
done

# Use positional parameters as pseudo-array
set -- one two three
echo "$1"          # one
echo "$@"          # all items
shift              # remove first item

# Default values
: "${VAR:=default}"        # Set if unset or empty
: "${VAR:-default}"        # Use default but don't set
value="${VAR:-fallback}"   # Assign with fallback
```

### String Operations

```bash
# Substring extraction (limited in POSIX)
# Use parameter expansion where possible:
file="document.txt"
name="${file%.*}"          # Remove shortest suffix: document
ext="${file##*.}"          # Remove longest prefix: txt

path="/home/user/file.txt"
dir="${path%/*}"           # Directory: /home/user
base="${path##*/}"         # Basename: file.txt

# For complex string ops, use external tools
echo "$string" | cut -c1-5
echo "$string" | sed 's/old/new/g'
```

### Functions

```bash
# POSIX function syntax (no 'function' keyword)
my_func() {
    local var="$1"         # local is widely supported but not strictly POSIX
    echo "$var"
    return 0
}

# Call without parentheses
my_func "argument"
```

### Loops

```bash
# For loop with list
for item in one two three; do
    echo "$item"
done

# For loop with command output
for file in *.txt; do
    [ -f "$file" ] || continue    # Handle no matches
    echo "$file"
done

# While loop
while read -r line; do
    echo "$line"
done < file.txt

# C-style for loops are NOT POSIX
# Use while instead:
i=0
while [ "$i" -lt 10 ]; do
    echo "$i"
    i=$((i + 1))
done
```

### Arithmetic

```bash
# POSIX arithmetic expansion
result=$((5 + 3))
result=$((a * b))
i=$((i + 1))

# NOT POSIX: let, (( )), +=
# Avoid: let "i++"
# Avoid: ((i++))
# Avoid: i+=1
```

### Command Substitution

```bash
# Use $() not backticks (both POSIX, but $() nests better)
today=$(date +%Y-%m-%d)
files=$(find . -name "*.txt")

# Nested substitution
dir=$(dirname "$(readlink -f "$0")")
```

## POSIX Pitfalls

### Echo Portability

```bash
# echo behavior varies - printf is portable
printf '%s\n' "$message"           # Newline
printf '%s' "$message"             # No newline
printf 'Value: %d\n' "$number"     # Formatted

# Avoid: echo -n, echo -e (not portable)
```

### Test Command Edge Cases

```bash
# Always quote variables in tests
[ "$var" = "" ]      # Safe
[ $var = "" ]        # Breaks if var contains spaces or is unset

# Use -n/-z for empty string tests
[ -n "$var" ]        # True if not empty
[ -z "$var" ]        # True if empty
```

### Word Splitting

```bash
# Quoting prevents word splitting
file="my file.txt"
cat "$file"          # Correct: one argument
cat $file            # Wrong: two arguments "my" and "file.txt"

# Intentional splitting for iteration
IFS=:
for dir in $PATH; do
    echo "$dir"
done
```

## Testing POSIX Compliance

```bash
# Run with dash (strict POSIX shell)
dash ./script.sh

# ShellCheck with POSIX mode
shellcheck --shell=sh script.sh

# Check for bashisms
checkbashisms script.sh    # Debian devscripts package
```
