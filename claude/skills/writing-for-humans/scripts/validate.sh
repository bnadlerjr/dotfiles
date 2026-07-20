#!/usr/bin/env bash
set -euo pipefail
#
# Gate a rewrite against local human-writing detectors.
# Usage: validate.sh <file>
#
# Runs every available detector and combines their verdicts with OR: the gate
# fails if ANY detector flags the text, and skips only when NO detector could
# run. All detection is local — no text leaves the machine.
#
# Exit codes (the contract callers rely on):
#   0  text passes the gate — nothing to fix
#   1  text still reads as AI-generated — stdout lists the specific issues
#   2  cannot validate (no detector available, or bad input) — skip
#
# Env:
#   SLOP_THRESHOLD          ai-slop score at/above which text fails the gate. The
#                           score sums weighted detector hits; higher means more
#                           AI tells. Default 15 gates obvious slop while
#                           tolerating a stray tell or two.
#   AI_WRITING_DETECTOR_CLI Path to the built ai-writing-detector `dist/cli.js`
#                           (pertrai1/ai-writing-detector). Unset, missing, or
#                           without `node` on PATH -> that detector is skipped.
#                           Build it manually, once, pinned to a reviewed commit
#                           SHA — it is never auto-installed here.
#   AI_WRITING_THRESHOLD    ai-writing-detector probability score (0-100) at/above
#                           which text fails the gate. Default 60 ("Likely AI").
#

readonly SCRIPT_NAME="$(basename "$0")"
readonly SLOP_THRESHOLD="${SLOP_THRESHOLD:-15}"
readonly AI_WRITING_THRESHOLD="${AI_WRITING_THRESHOLD:-60}"

skip() {
    echo "${SCRIPT_NAME}: $* — skipping validation" >&2
    exit 2
}

# Strip ANSI SGR color codes from stdin. ai-writing-detector decorates its
# report; the ESC byte is spelled with $'\033' so BSD (macOS) sed matches it.
strip_ansi() {
    local esc=$'\033'
    sed "s/${esc}\[[0-9;]*m//g"
}

# Each detector returns a verdict via exit code — 0 pass, 1 fail, 2 skip — and
# prints its hits to stdout on a fail. The combiner in main() reads both.

run_ai_slop() {
    local file="$1"
    command -v ai-slop >/dev/null 2>&1 || return 2

    local output rc=0
    output="$(ai-slop --fail-on "$SLOP_THRESHOLD" -- "$file" 2>&1)" || rc=$?
    case "$rc" in
        0) return 0 ;;                        # passed the gate
        2) printf '%s\n' "$output"; return 1 ;;  # failed — pass the hits through
        *) return 2 ;;                        # detector error — skip
    esac
}

run_ai_writing_detector() {
    local file="$1"
    local cli="${AI_WRITING_DETECTOR_CLI:-}"
    [[ -n "$cli" && -f "$cli" ]] || return 2
    command -v node >/dev/null 2>&1 || return 2

    local report rc=0
    report="$(node "$cli" analyze "$file" 2>&1)" || rc=$?
    [[ "$rc" -eq 0 ]] || return 2             # detector error — skip

    report="$(printf '%s' "$report" | strip_ansi)"

    local score
    score="$(printf '%s\n' "$report" \
        | grep -oE 'AI PROBABILITY SCORE: [0-9]+' \
        | grep -oE '[0-9]+$' || true)"
    # Require exactly one numeric score in 0-100. Anything else — missing,
    # an ambiguous multi-line match, or out of range — is unparseable, so
    # skip rather than risk a false verdict. 10# forces base-10 so a
    # zero-padded score isn't read as octal (which would error and, inside
    # the arithmetic below, silently fall through to a pass).
    [[ "$score" =~ ^[0-9]+$ ]] || return 2
    (( ${#score} <= 3 )) || return 2          # 0-100 is 3 digits max; guards 64-bit overflow
    score=$((10#$score))
    (( score <= 100 )) || return 2

    if (( score >= AI_WRITING_THRESHOLD )); then
        printf '%s\n' "$report"               # report includes the category breakdown
        return 1
    fi
    return 0
}

main() {
    [[ $# -ge 1 ]] || skip "no file given (usage: ${SCRIPT_NAME} <file>)"
    local file="$1"
    [[ -f "$file" ]] || skip "cannot read '${file}'"

    local detector out hits="" any_ran=0 any_failed=0 verdict
    for detector in run_ai_slop run_ai_writing_detector; do
        verdict=0
        out="$("$detector" "$file")" || verdict=$?
        case "$verdict" in
            0) any_ran=1 ;;                            # pass
            1) any_ran=1; any_failed=1; hits+="${out}"$'\n' ;;  # fail — collect hits
            2) : ;;                                    # skip
        esac
    done

    if [[ "$any_failed" -eq 1 ]]; then
        printf '%s' "$hits"
        exit 1
    fi
    [[ "$any_ran" -eq 1 ]] && exit 0
    skip "no detector available"
}

main "$@"
