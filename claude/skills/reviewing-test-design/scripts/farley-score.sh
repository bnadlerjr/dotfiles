#!/usr/bin/env bash
set -euo pipefail

# farley-score.sh - Compute Dave Farley's weighted test-quality score.
#
# Usage:
#   scripts/farley-score.sh -u U -m M -r R -a A -n N -g G -f F -t T
#
# All 8 flags required. Each score must be an integer 1-10.
# Output (stdout): "<score> <rating>" (e.g., "8.3 Excellent").
# On invalid input, exits non-zero with an error on stderr.
#
# Keep formula weights and tier thresholds in sync with SKILL.md.

readonly SCRIPT_NAME="$(basename "$0")"

die() {
    printf '%s: error: %s\n' "$SCRIPT_NAME" "$*" >&2
    exit 1
}

usage() {
    printf 'Usage: %s -u U -m M -r R -a A -n N -g G -f F -t T\n' "$SCRIPT_NAME" >&2
    printf 'All flags required; each score must be integer 1-10.\n' >&2
    exit 1
}

validate_score() {
    local name="$1"
    local value="$2"
    [[ -z "$value" ]] && die "-$name is required"
    if ! [[ "$value" =~ ^[0-9]+$ ]] || (( value < 1 || value > 10 )); then
        die "-$name must be integer 1-10 (got: $value)"
    fi
}

lookup_tier() {
    local score="$1"
    # score is always produced by printf '%.1f', so stripping '.' yields a
    # 2- or 3-digit integer suitable for direct comparison against scaled
    # thresholds (tier boundaries from SKILL.md multiplied by 10).
    local s10="${score/./}"
    if   (( s10 >= 90 )); then printf 'Exemplary'
    elif (( s10 >= 75 )); then printf 'Excellent'
    elif (( s10 >= 60 )); then printf 'Good'
    elif (( s10 >= 45 )); then printf 'Fair'
    elif (( s10 >= 30 )); then printf 'Poor'
    else                       printf 'Critical'
    fi
}

main() {
    local U="" M="" R="" A="" N="" G="" F="" T=""

    while getopts "u:m:r:a:n:g:f:t:" opt; do
        case "$opt" in
            u) U="$OPTARG" ;;
            m) M="$OPTARG" ;;
            r) R="$OPTARG" ;;
            a) A="$OPTARG" ;;
            n) N="$OPTARG" ;;
            g) G="$OPTARG" ;;
            f) F="$OPTARG" ;;
            t) T="$OPTARG" ;;
            *) usage ;;
        esac
    done

    validate_score u "$U"
    validate_score m "$M"
    validate_score r "$R"
    validate_score a "$A"
    validate_score n "$N"
    validate_score g "$G"
    validate_score f "$F"
    validate_score t "$T"

    local raw
    raw=$(printf 'scale=4; (%s*1.5 + %s*1.5 + %s*1.25 + %s*1.0 + %s*1.0 + %s*1.0 + %s*0.75 + %s*1.0) / 9\n' \
        "$U" "$M" "$R" "$A" "$N" "$G" "$F" "$T" | bc)

    local score
    score=$(printf '%.1f' "$raw")

    local rating
    rating=$(lookup_tier "$score")

    printf '%s %s\n' "$score" "$rating"
}

main "$@"
