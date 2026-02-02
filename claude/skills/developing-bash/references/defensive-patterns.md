# Defensive Shell Scripting

Patterns for robust, reliable shell scripts.

## The Essential Preamble

```bash
#!/usr/bin/env bash
set -euo pipefail
```

### What Each Flag Does

| Flag | Effect | Why Use It |
|------|--------|------------|
| `-e` | Exit on error | Stops script when command fails |
| `-u` | Error on unset variables | Catches typos and missing args |
| `-o pipefail` | Pipeline fails if any command fails | Catches hidden failures in pipes |

### Additional Flags

```bash
set -E              # ERR traps inherited by functions
set -x              # Debug: print commands as executed
set -v              # Debug: print input lines as read
shopt -s nullglob   # Globs with no matches expand to nothing
shopt -s failglob   # Globs with no matches cause error
```

## Error Handling

### Die Function

```bash
die() {
    local code="${2:-1}"
    echo "Error: $1" >&2
    exit "$code"
}

# Usage
[[ -f "$config" ]] || die "Config file not found: $config"
command_that_might_fail || die "Command failed" $?
```

### Structured Error Handling

```bash
error() {
    local parent_lineno="$1"
    local message="${2:-}"
    local code="${3:-1}"
    if [[ -n "$message" ]]; then
        echo "Error on line ${parent_lineno}: ${message}; exit code ${code}" >&2
    else
        echo "Error on line ${parent_lineno}; exit code ${code}" >&2
    fi
    exit "$code"
}

trap 'error ${LINENO}' ERR
```

### Try-Catch Pattern

```bash
try() {
    set +e
    "$@"
    local exit_code=$?
    set -e
    return $exit_code
}

# Usage
if try some_command; then
    echo "Success"
else
    echo "Failed with code $?"
fi
```

## Resource Cleanup

### Basic Trap

```bash
cleanup() {
    rm -f "$temp_file"
    [[ -n "${pid:-}" ]] && kill "$pid" 2>/dev/null
}
trap cleanup EXIT
```

### Multiple Signals

```bash
cleanup() {
    local exit_code=$?
    rm -rf "$temp_dir"
    exit $exit_code
}

trap cleanup EXIT
trap 'trap - EXIT; cleanup; kill -INT $$' INT
trap 'trap - EXIT; cleanup; kill -TERM $$' TERM
```

### Temporary Files

```bash
# Secure temp file creation
temp_file=$(mktemp) || die "Failed to create temp file"
trap 'rm -f "$temp_file"' EXIT

# Temp directory
temp_dir=$(mktemp -d) || die "Failed to create temp directory"
trap 'rm -rf "$temp_dir"' EXIT

# Multiple temp files
declare -a temp_files=()
cleanup_temps() {
    rm -f "${temp_files[@]}"
}
trap cleanup_temps EXIT

add_temp() {
    local f=$(mktemp)
    temp_files+=("$f")
    echo "$f"
}
```

## Input Validation

### Argument Checking

```bash
usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS] <input_file>

Options:
    -o, --output FILE    Output file (default: stdout)
    -v, --verbose        Enable verbose output
    -h, --help           Show this help

Arguments:
    input_file           File to process
EOF
}

# Require minimum arguments
[[ $# -ge 1 ]] || { usage; exit 1; }

# Parse options
verbose=false
output="/dev/stdout"

while [[ $# -gt 0 ]]; do
    case "$1" in
        -o|--output)
            output="$2"
            shift 2
            ;;
        -v|--verbose)
            verbose=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        -*)
            die "Unknown option: $1"
            ;;
        *)
            break
            ;;
    esac
done

input_file="${1:-}"
[[ -n "$input_file" ]] || die "Input file required"
```

### File Validation

```bash
require_file() {
    local file="$1"
    local desc="${2:-File}"
    [[ -f "$file" ]] || die "$desc not found: $file"
    [[ -r "$file" ]] || die "$desc not readable: $file"
}

require_dir() {
    local dir="$1"
    local desc="${2:-Directory}"
    [[ -d "$dir" ]] || die "$desc not found: $dir"
    [[ -x "$dir" ]] || die "$desc not accessible: $dir"
}

require_command() {
    local cmd="$1"
    command -v "$cmd" >/dev/null 2>&1 || die "Required command not found: $cmd"
}

# Usage
require_file "$config" "Config file"
require_dir "$data_dir" "Data directory"
require_command jq
```

### Type Validation

```bash
is_integer() {
    [[ "$1" =~ ^-?[0-9]+$ ]]
}

is_positive_integer() {
    [[ "$1" =~ ^[0-9]+$ ]] && [[ "$1" -gt 0 ]]
}

is_valid_ip() {
    local ip="$1"
    local IFS='.'
    read -ra octets <<< "$ip"
    [[ ${#octets[@]} -eq 4 ]] || return 1
    for octet in "${octets[@]}"; do
        is_integer "$octet" || return 1
        ((octet >= 0 && octet <= 255)) || return 1
    done
}

# Usage
is_integer "$port" || die "Port must be an integer"
```

## Safe Operations

### Safe File Operations

```bash
# Safe overwrite (atomic)
safe_write() {
    local dest="$1"
    local temp="${dest}.tmp.$$"
    cat > "$temp" && mv "$temp" "$dest"
}

# Backup before modify
backup_and_edit() {
    local file="$1"
    cp "$file" "${file}.bak.$(date +%Y%m%d%H%M%S)"
    "${EDITOR:-vi}" "$file"
}

# Safe directory operations
mkdir -p "$dir" || die "Cannot create directory: $dir"
cd "$dir" || die "Cannot change to directory: $dir"
```

### Safe Command Execution

```bash
# Run with timeout
run_with_timeout() {
    local timeout="$1"
    shift
    timeout "$timeout" "$@"
}

# Retry with backoff
retry() {
    local max_attempts="${1:-3}"
    local delay="${2:-1}"
    shift 2
    local attempt=1
    while [[ $attempt -le $max_attempts ]]; do
        if "$@"; then
            return 0
        fi
        echo "Attempt $attempt failed, retrying in ${delay}s..." >&2
        sleep "$delay"
        ((attempt++))
        ((delay *= 2))
    done
    return 1
}

# Usage
retry 3 2 curl -f "$url" -o "$output"
```

## Logging

```bash
readonly LOG_FILE="${LOG_FILE:-/dev/null}"

log() {
    local level="$1"
    shift
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $*" | tee -a "$LOG_FILE" >&2
}

log_info()  { log "INFO"  "$@"; }
log_warn()  { log "WARN"  "$@"; }
log_error() { log "ERROR" "$@"; }
log_debug() { [[ "${DEBUG:-}" == "true" ]] && log "DEBUG" "$@"; }

# Usage
log_info "Starting process"
log_error "Failed to connect to $host"
```

## Concurrent Execution

### Background Jobs with Tracking

```bash
declare -a pids=()

cleanup_jobs() {
    for pid in "${pids[@]}"; do
        kill "$pid" 2>/dev/null
    done
    wait
}
trap cleanup_jobs EXIT

run_background() {
    "$@" &
    pids+=($!)
}

wait_all() {
    local failed=0
    for pid in "${pids[@]}"; do
        wait "$pid" || ((failed++))
    done
    return $failed
}
```

### Parallel Execution with Limit

```bash
parallel_limit() {
    local max_jobs="$1"
    shift
    local job_count=0

    for item in "$@"; do
        process_item "$item" &
        ((job_count++))
        if ((job_count >= max_jobs)); then
            wait -n  # Wait for any job (Bash 4.3+)
            ((job_count--))
        fi
    done
    wait
}
```
