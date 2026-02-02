---
name: developing-bash
description: |
  Shell scripting expertise covering POSIX-compliant and Bash-specific patterns, defensive scripting practices, cross-platform compatibility, and command-line automation.

  Use when working with .sh files, shell scripts, or when the user mentions Bash, POSIX, shell scripting, shebang, pipelines, or CLI automation. Also use for set -e, traps, parameter expansion, or cross-platform shell compatibility.
---

# Developing Bash

Expert guidance for writing robust, portable shell scripts.

## Quick Start

For immediate help, identify your task type and consult the relevant reference:

| Working On | Reference File | Key Topics |
|------------|----------------|------------|
| Portable scripts, sh compatibility | [posix-scripting](references/posix-scripting.md) | POSIX subset, portability |
| Arrays, advanced expansion | [bash-features](references/bash-features.md) | Bash-specific extensions |
| Error handling, safety flags | [defensive-patterns](references/defensive-patterns.md) | set flags, traps, validation |
| macOS vs Linux differences | [cross-platform](references/cross-platform.md) | GNU vs BSD, path differences |

## Core Principles

These principles apply across all shell scripting:

### Defensive by Default

1. Start every script with safety flags: `set -euo pipefail`
2. Quote all variable expansions: `"$var"` not `$var`
3. Use `[[ ]]` for conditionals in Bash (more predictable than `[ ]`)
4. Validate inputs before using them
5. Clean up resources with traps

### Explicit Over Clever

1. Prefer readable pipelines over dense one-liners
2. Use descriptive variable names: `input_file` not `f`
3. Add comments for non-obvious shell constructs
4. Avoid relying on shell-specific behavior without documenting it

### Fail Fast, Fail Loud

1. Exit immediately on errors (`set -e`)
2. Treat unset variables as errors (`set -u`)
3. Propagate pipeline failures (`set -o pipefail`)
4. Provide meaningful error messages with context

### Portability Awareness

1. Know your target: POSIX sh, Bash 3.x, Bash 4+, or Zsh
2. Document shell requirements in script header
3. Test on target platforms, not just development machine
4. Prefer POSIX when portability matters more than features

## Script Template

```bash
#!/usr/bin/env bash
set -euo pipefail

# Description: What this script does
# Usage: script.sh <arg1> [arg2]

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_NAME="$(basename "$0")"

cleanup() {
    # Remove temp files, kill background processes
    :
}
trap cleanup EXIT

die() {
    echo "${SCRIPT_NAME}: error: $*" >&2
    exit 1
}

usage() {
    echo "Usage: ${SCRIPT_NAME} <arg1> [arg2]"
    exit 1
}

main() {
    [[ $# -lt 1 ]] && usage
    local arg1="$1"

    # Implementation here
}

main "$@"
```

## Anti-Patterns to Avoid

### Safety Violations
- Unquoted variables: `$var` instead of `"$var"`
- Missing error handling: no `set -e` or explicit checks
- Parsing `ls` output instead of using globs or `find -print0`
- Using `eval` with untrusted input

### Portability Traps
- Bash arrays in `#!/bin/sh` scripts
- GNU-specific flags without fallbacks
- Hardcoded paths (`/usr/local/bin` vs `/usr/bin`)
- Assuming `echo` behavior (use `printf` for portability)

### Maintainability Issues
- Magic numbers without explanation
- Deep nesting instead of early returns
- Massive functions doing multiple things
- No usage message or help flag

## Reference File IDs

For programmatic access: `posix-scripting` · `bash-features` · `defensive-patterns` · `cross-platform`
