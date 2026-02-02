# Cross-Platform Shell Scripting

Handling differences between macOS, Linux, and BSD systems.

## Platform Detection

```bash
detect_os() {
    case "$(uname -s)" in
        Linux*)  echo "linux";;
        Darwin*) echo "macos";;
        FreeBSD*) echo "freebsd";;
        CYGWIN*|MINGW*|MSYS*) echo "windows";;
        *) echo "unknown";;
    esac
}

OS=$(detect_os)

# More specific Linux detection
if [[ "$OS" == "linux" ]]; then
    if [[ -f /etc/debian_version ]]; then
        DISTRO="debian"
    elif [[ -f /etc/redhat-release ]]; then
        DISTRO="redhat"
    elif [[ -f /etc/alpine-release ]]; then
        DISTRO="alpine"
    fi
fi
```

## GNU vs BSD Core Utilities

### sed Differences

```bash
# In-place editing
# GNU: sed -i 's/old/new/' file
# BSD: sed -i '' 's/old/new/' file

sed_inplace() {
    if [[ "$OS" == "macos" ]]; then
        sed -i '' "$@"
    else
        sed -i "$@"
    fi
}

# Extended regex
# GNU: sed -r or sed -E
# BSD: sed -E only
# Portable: use sed -E (works on both modern GNU and BSD)

sed -E 's/([0-9]+)/[\1]/g' file
```

### grep Differences

```bash
# Perl regex
# GNU: grep -P
# BSD: grep -E (no -P, use perl or install GNU grep)

# Portable extended regex
grep -E 'pattern|other' file

# Color output
# GNU: grep --color=auto (default on many systems)
# BSD: grep --color=auto (macOS 10.8+)
# Portable: GREP_OPTIONS is deprecated, use alias or explicit flag
```

### date Differences

```bash
# Timestamp formatting
# GNU: date -d "2024-01-15" +%s
# BSD: date -j -f "%Y-%m-%d" "2024-01-15" +%s

timestamp_to_epoch() {
    local ts="$1"
    if [[ "$OS" == "macos" ]]; then
        date -j -f "%Y-%m-%d %H:%M:%S" "$ts" +%s 2>/dev/null || \
        date -j -f "%Y-%m-%d" "$ts" +%s
    else
        date -d "$ts" +%s
    fi
}

epoch_to_date() {
    local epoch="$1"
    local format="${2:-%Y-%m-%d %H:%M:%S}"
    if [[ "$OS" == "macos" ]]; then
        date -r "$epoch" "+$format"
    else
        date -d "@$epoch" "+$format"
    fi
}

# Relative dates
# GNU: date -d "yesterday", date -d "2 hours ago"
# BSD: date -v-1d, date -v-2H

yesterday() {
    if [[ "$OS" == "macos" ]]; then
        date -v-1d +%Y-%m-%d
    else
        date -d "yesterday" +%Y-%m-%d
    fi
}
```

### find Differences

```bash
# Delete action
# GNU: find . -name "*.tmp" -delete
# BSD: find . -name "*.tmp" -delete (same, but order matters more)
# Portable: always put -delete last

# Regex
# GNU: find . -regex '.*\.txt'
# BSD: find . -regex '.*\.txt' (POSIX basic by default)
# Use -E for extended regex on BSD

# Executable test
# GNU: find . -executable
# BSD: find . -perm +111

find_executable() {
    if [[ "$OS" == "macos" ]]; then
        find "$@" -perm +111
    else
        find "$@" -executable
    fi
}
```

### stat Differences

```bash
# File size
# GNU: stat -c %s file
# BSD: stat -f %z file

file_size() {
    local file="$1"
    if [[ "$OS" == "macos" ]]; then
        stat -f %z "$file"
    else
        stat -c %s "$file"
    fi
}

# Modification time
# GNU: stat -c %Y file
# BSD: stat -f %m file

file_mtime() {
    local file="$1"
    if [[ "$OS" == "macos" ]]; then
        stat -f %m "$file"
    else
        stat -c %Y "$file"
    fi
}
```

### readlink Differences

```bash
# Canonical path
# GNU: readlink -f path
# BSD: readlink has no -f, use realpath or alternative

realpath_portable() {
    local path="$1"
    if command -v realpath >/dev/null 2>&1; then
        realpath "$path"
    elif [[ "$OS" == "macos" ]]; then
        # Python fallback
        python3 -c "import os; print(os.path.realpath('$path'))"
    else
        readlink -f "$path"
    fi
}

# Script directory (common pattern)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
```

### tar Differences

```bash
# Exclude patterns
# GNU: tar --exclude='*.log'
# BSD: tar --exclude '*.log' (space, not equals)
# Portable: use space

# Compression auto-detect
# GNU: tar -xf file.tar.gz (auto-detects)
# BSD: tar -xzf file.tar.gz (explicit flag needed on older versions)
# Portable: use explicit flags

tar_extract() {
    local file="$1"
    case "$file" in
        *.tar.gz|*.tgz)  tar -xzf "$file";;
        *.tar.bz2|*.tbz) tar -xjf "$file";;
        *.tar.xz|*.txz)  tar -xJf "$file";;
        *.tar)           tar -xf "$file";;
        *)               die "Unknown archive format: $file";;
    esac
}
```

## Path Differences

```bash
# Homebrew paths
# Intel Mac: /usr/local
# Apple Silicon: /opt/homebrew
# Linux: /home/linuxbrew/.linuxbrew (if using Homebrew)

homebrew_prefix() {
    if command -v brew >/dev/null 2>&1; then
        brew --prefix
    elif [[ -d /opt/homebrew ]]; then
        echo "/opt/homebrew"
    elif [[ -d /usr/local/Homebrew ]]; then
        echo "/usr/local"
    else
        echo ""
    fi
}

# Temp directory
# macOS: $TMPDIR (e.g., /var/folders/xx/...)
# Linux: /tmp
TEMP_DIR="${TMPDIR:-/tmp}"
```

## Shell Differences

### Bash Version

```bash
# macOS ships with Bash 3.2 (GPLv2, last version before GPLv3)
# Linux typically has Bash 4.x or 5.x

check_bash_version() {
    local required="${1:-4}"
    if ((BASH_VERSINFO[0] < required)); then
        die "Bash $required+ required (have ${BASH_VERSION})"
    fi
}

# Feature detection instead of version check
if declare -A test_assoc 2>/dev/null; then
    HAVE_ASSOC_ARRAYS=true
    unset test_assoc
else
    HAVE_ASSOC_ARRAYS=false
fi
```

### Zsh Compatibility

```bash
# If script may run under zsh
if [[ -n "${ZSH_VERSION:-}" ]]; then
    setopt SH_WORD_SPLIT     # Split unquoted variables like bash
    setopt KSH_ARRAYS        # 0-indexed arrays like bash
fi

# Or require bash explicitly
if [[ -z "${BASH_VERSION:-}" ]]; then
    die "This script requires Bash"
fi
```

## Abstraction Layer

```bash
# Create platform-specific wrappers

# Initialize platform utilities
init_platform() {
    OS=$(detect_os)

    case "$OS" in
        macos)
            SED_INPLACE=(sed -i '')
            DATE_EPOCH='date -r'
            STAT_SIZE='stat -f %z'
            ;;
        linux|*)
            SED_INPLACE=(sed -i)
            DATE_EPOCH='date -d @'
            STAT_SIZE='stat -c %s'
            ;;
    esac
}

# Usage
init_platform
"${SED_INPLACE[@]}" 's/old/new/' file
$DATE_EPOCH "$timestamp" +%Y-%m-%d
$STAT_SIZE "$file"
```

## Testing Cross-Platform

```bash
# Test matrix approach
test_on_platforms() {
    local script="$1"

    # Docker containers for Linux variants
    docker run --rm -v "$PWD:/work" -w /work ubuntu:22.04 bash "$script"
    docker run --rm -v "$PWD:/work" -w /work alpine:3.18 sh "$script"

    # macOS requires local or CI testing
    # GitHub Actions provides macos-latest runner
}

# CI configuration example (GitHub Actions)
# jobs:
#   test:
#     strategy:
#       matrix:
#         os: [ubuntu-latest, macos-latest]
#     runs-on: ${{ matrix.os }}
#     steps:
#       - run: bash script.sh
```
