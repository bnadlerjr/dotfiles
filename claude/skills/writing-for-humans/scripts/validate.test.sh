#!/usr/bin/env bash
#
# Tests for validate.sh — the human-writing gate wrapper.
# Stubs `ai-slop` on PATH so tests are hermetic (no real tool needed).
# Run: bash validate.test.sh
#
set -uo pipefail

readonly TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly VALIDATE="${TEST_DIR}/validate.sh"
# System dirs the script's shebang and coreutils need. Deliberately excludes
# ~/.local/bin so the real ai-slop never leaks into a test.
readonly SYS_PATH="/usr/bin:/bin"

pass_count=0
fail_count=0

# make_stub <bin_dir> <exit_code> <stdout_text>
# Writes a fake `ai-slop` that records its args to $bin_dir/args, prints
# <stdout_text>, and exits <exit_code>.
make_stub() {
    local bin_dir="$1" code="$2" out="$3"
    mkdir -p "$bin_dir"
    cat > "${bin_dir}/ai-slop" <<STUB
#!/usr/bin/env bash
printf '%s\n' "\$*" > "${bin_dir}/args"
[[ -n '${out}' ]] && printf '%s\n' '${out}'
exit ${code}
STUB
    chmod +x "${bin_dir}/ai-slop"
}

# make_node_stub <bin_dir> <exit_code> <report_file>
# Writes a fake `node` that prints <report_file> verbatim and exits <exit_code>,
# ignoring its args. validate.sh invokes the second detector as
# `node <cli> analyze <file>`, so this stub stands in for the built
# ai-writing-detector CLI without needing the real tool.
make_node_stub() {
    local bin_dir="$1" code="$2" report="$3"
    mkdir -p "$bin_dir"
    cat > "${bin_dir}/node" <<STUB
#!/usr/bin/env bash
cat "${report}"
exit ${code}
STUB
    chmod +x "${bin_dir}/node"
}

# assert <description> <expected_exit> <actual_exit> [<expected_substr> <actual_output>]
assert() {
    local desc="$1" want_exit="$2" got_exit="$3"
    local want_sub="${4-}" got_out="${5-}"
    if [[ "$got_exit" != "$want_exit" ]]; then
        printf 'FAIL: %s\n  expected exit %s, got %s\n' "$desc" "$want_exit" "$got_exit"
        fail_count=$((fail_count + 1))
        return
    fi
    if [[ -n "$want_sub" && "$got_out" != *"$want_sub"* ]]; then
        printf 'FAIL: %s\n  output missing %q\n  got: %s\n' "$desc" "$want_sub" "$got_out"
        fail_count=$((fail_count + 1))
        return
    fi
    printf 'PASS: %s\n' "$desc"
    pass_count=$((pass_count + 1))
}

# --- Test 1: text passes the gate -> exit 0 ---
test_pass() {
    local work; work="$(mktemp -d)"
    make_stub "${work}/bin" 0 ""
    printf 'clean prose\n' > "${work}/draft.md"
    local out; out="$(PATH="${work}/bin:${SYS_PATH}" "$VALIDATE" "${work}/draft.md")"
    assert "passing text exits 0" 0 "$?" "" "$out"
    rm -rf "$work"
}

# --- Test 2: text fails the gate -> exit 1, hits passed through on stdout ---
test_fail_shows_hits() {
    local work; work="$(mktemp -d)"
    make_stub "${work}/bin" 2 "hits: [phrase] 'delve into'"
    printf 'let me delve into this\n' > "${work}/draft.md"
    local out; out="$(PATH="${work}/bin:${SYS_PATH}" "$VALIDATE" "${work}/draft.md")"
    assert "failing text exits 1 and shows hits" 1 "$?" "delve into" "$out"
    rm -rf "$work"
}

# --- Test 3: validator not installed -> exit 2 (skip) ---
test_missing_tool() {
    local work; work="$(mktemp -d)"
    mkdir -p "${work}/bin"   # empty: no ai-slop on PATH
    printf 'prose\n' > "${work}/draft.md"
    PATH="${work}/bin:${SYS_PATH}" "$VALIDATE" "${work}/draft.md" >/dev/null 2>&1
    assert "missing validator exits 2" 2 "$?"
    rm -rf "$work"
}

# --- Test 4: SLOP_THRESHOLD is passed through to ai-slop ---
test_threshold_passthrough() {
    local work; work="$(mktemp -d)"
    make_stub "${work}/bin" 0 ""
    printf 'prose\n' > "${work}/draft.md"
    local rc=0
    SLOP_THRESHOLD=30 PATH="${work}/bin:${SYS_PATH}" "$VALIDATE" "${work}/draft.md" >/dev/null 2>&1 || rc=$?
    local args; args="$(cat "${work}/bin/args")"
    assert "threshold override reaches ai-slop" 0 "$rc" "--fail-on 30" "$args"
    rm -rf "$work"
}

# --- Test 7: detector runs but errors (unexpected exit) -> exit 2 (skip) ---
test_detector_error() {
    local work; work="$(mktemp -d)"
    make_stub "${work}/bin" 1 "boom"   # any exit other than 0/2 is a detector error
    printf 'prose\n' > "${work}/draft.md"
    local rc=0
    PATH="${work}/bin:${SYS_PATH}" "$VALIDATE" "${work}/draft.md" >/dev/null 2>&1 || rc=$?
    assert "detector error exits 2" 2 "$rc"
    rm -rf "$work"
}

# --- Test 5: missing file argument -> exit 2 (exits before ai-slop is consulted) ---
test_missing_arg() {
    PATH="$SYS_PATH" "$VALIDATE" >/dev/null 2>&1
    assert "no file argument exits 2" 2 "$?"
}

# --- Test 6: nonexistent file argument -> exit 2 (exits before ai-slop is consulted) ---
test_nonexistent_file() {
    local work; work="$(mktemp -d)"
    PATH="$SYS_PATH" "$VALIDATE" "${work}/nope.md" >/dev/null 2>&1
    assert "nonexistent file exits 2" 2 "$?"
    rm -rf "$work"
}

# --- Test 8: ai-writing-detector flags text -> exit 1, score passed through ---
test_awd_flags() {
    local work; work="$(mktemp -d)"
    printf 'AI PROBABILITY SCORE: 75/100\nClassification: Likely AI-Generated\n' > "${work}/report"
    make_node_stub "${work}/bin" 0 "${work}/report"   # no ai-slop on PATH -> ai-slop skips
    touch "${work}/cli.js"
    printf 'prose\n' > "${work}/draft.md"
    local out; out="$(AI_WRITING_DETECTOR_CLI="${work}/cli.js" PATH="${work}/bin:${SYS_PATH}" "$VALIDATE" "${work}/draft.md")"
    assert "ai-writing-detector flag exits 1 with score" 1 "$?" "AI PROBABILITY SCORE: 75" "$out"
    rm -rf "$work"
}

# --- Test 9: ai-writing-detector below threshold, ai-slop absent -> exit 0 ---
test_awd_clean_alone() {
    local work; work="$(mktemp -d)"
    printf 'AI PROBABILITY SCORE: 12/100\n' > "${work}/report"
    make_node_stub "${work}/bin" 0 "${work}/report"
    touch "${work}/cli.js"
    printf 'prose\n' > "${work}/draft.md"
    AI_WRITING_DETECTOR_CLI="${work}/cli.js" PATH="${work}/bin:${SYS_PATH}" "$VALIDATE" "${work}/draft.md" >/dev/null 2>&1
    assert "clean ai-writing-detector alone exits 0" 0 "$?"
    rm -rf "$work"
}

# --- Test 10: both detectors flag -> exit 1 with hits from both (OR union) ---
test_both_flag_union() {
    local work; work="$(mktemp -d)"
    make_stub "${work}/bin" 2 "hits: phrase delve-into"       # ai-slop fails
    printf 'AI PROBABILITY SCORE: 88/100\n' > "${work}/report"
    make_node_stub "${work}/bin" 0 "${work}/report"           # ai-writing-detector flags
    touch "${work}/cli.js"
    printf 'prose\n' > "${work}/draft.md"
    local out; out="$(AI_WRITING_DETECTOR_CLI="${work}/cli.js" PATH="${work}/bin:${SYS_PATH}" "$VALIDATE" "${work}/draft.md")"
    local rc=$?
    assert "both flag: exit 1 keeps ai-slop hit" 1 "$rc" "delve-into" "$out"
    assert "both flag: exit 1 keeps awd score" 1 "$rc" "AI PROBABILITY SCORE: 88" "$out"
    rm -rf "$work"
}

# --- Test 11: AI_WRITING_THRESHOLD override flips the verdict for a fixed score ---
test_awd_threshold_override() {
    local work; work="$(mktemp -d)"
    printf 'AI PROBABILITY SCORE: 75/100\n' > "${work}/report"
    make_node_stub "${work}/bin" 0 "${work}/report"
    touch "${work}/cli.js"
    printf 'prose\n' > "${work}/draft.md"
    # Default threshold 60: score 75 fails.
    AI_WRITING_DETECTOR_CLI="${work}/cli.js" PATH="${work}/bin:${SYS_PATH}" "$VALIDATE" "${work}/draft.md" >/dev/null 2>&1
    assert "score 75 fails at default threshold" 1 "$?"
    # Raised threshold 90: the same score now passes.
    AI_WRITING_THRESHOLD=90 AI_WRITING_DETECTOR_CLI="${work}/cli.js" PATH="${work}/bin:${SYS_PATH}" "$VALIDATE" "${work}/draft.md" >/dev/null 2>&1
    assert "score 75 passes when threshold raised to 90" 0 "$?"
    rm -rf "$work"
}

# --- Test 12: ANSI-colored score line still parses -> exit 1 ---
test_awd_strips_ansi() {
    local work; work="$(mktemp -d)"
    printf 'AI PROBABILITY SCORE: \033[31m88\033[0m/100\n' > "${work}/report"
    make_node_stub "${work}/bin" 0 "${work}/report"
    touch "${work}/cli.js"
    printf 'prose\n' > "${work}/draft.md"
    AI_WRITING_DETECTOR_CLI="${work}/cli.js" PATH="${work}/bin:${SYS_PATH}" "$VALIDATE" "${work}/draft.md" >/dev/null 2>&1
    assert "ANSI-colored score still gates (exit 1)" 1 "$?"
    rm -rf "$work"
}

# --- Test 13: detector process errors (node exits non-zero) -> skip ---
test_awd_node_error_skips() {
    local work; work="$(mktemp -d)"
    printf 'AI PROBABILITY SCORE: 88/100\n' > "${work}/report"
    make_node_stub "${work}/bin" 1 "${work}/report"   # node exits non-zero
    touch "${work}/cli.js"
    printf 'prose\n' > "${work}/draft.md"
    AI_WRITING_DETECTOR_CLI="${work}/cli.js" PATH="${work}/bin:${SYS_PATH}" "$VALIDATE" "${work}/draft.md" >/dev/null 2>&1
    assert "detector process error skips (exit 2)" 2 "$?"
    rm -rf "$work"
}

# --- Test 14: AI_WRITING_DETECTOR_CLI points at a missing file -> skip ---
test_awd_missing_cli_skips() {
    local work; work="$(mktemp -d)"
    mkdir -p "${work}/bin"   # no ai-slop; CLI path does not exist
    printf 'prose\n' > "${work}/draft.md"
    AI_WRITING_DETECTOR_CLI="${work}/nope.js" PATH="${work}/bin:${SYS_PATH}" "$VALIDATE" "${work}/draft.md" >/dev/null 2>&1
    assert "missing detector CLI skips (exit 2)" 2 "$?"
    rm -rf "$work"
}

# --- Test 15: node not on PATH -> that detector skips even with CLI set ---
test_awd_no_node_skips() {
    local work; work="$(mktemp -d)"
    mkdir -p "${work}/bin"   # empty: no node, no ai-slop
    touch "${work}/cli.js"
    printf 'prose\n' > "${work}/draft.md"
    AI_WRITING_DETECTOR_CLI="${work}/cli.js" PATH="${work}/bin:${SYS_PATH}" "$VALIDATE" "${work}/draft.md" >/dev/null 2>&1
    assert "no node available skips (exit 2)" 2 "$?"
    rm -rf "$work"
}

# --- Test 16: detector output without a score line -> skip ---
test_awd_unparseable_skips() {
    local work; work="$(mktemp -d)"
    printf 'some report with no score line\n' > "${work}/report"
    make_node_stub "${work}/bin" 0 "${work}/report"
    touch "${work}/cli.js"
    printf 'prose\n' > "${work}/draft.md"
    AI_WRITING_DETECTOR_CLI="${work}/cli.js" PATH="${work}/bin:${SYS_PATH}" "$VALIDATE" "${work}/draft.md" >/dev/null 2>&1
    assert "unparseable detector output skips (exit 2)" 2 "$?"
    rm -rf "$work"
}

# --- Test 19: a failing detector's hits are ANSI-stripped before pass-through ---
test_awd_hits_are_ansi_stripped() {
    local work; work="$(mktemp -d)"
    printf 'AI PROBABILITY SCORE: 88/100\n\033[31mClassification: Likely AI-Generated\033[0m\n' > "${work}/report"
    make_node_stub "${work}/bin" 0 "${work}/report"
    touch "${work}/cli.js"
    printf 'prose\n' > "${work}/draft.md"
    local out; out="$(AI_WRITING_DETECTOR_CLI="${work}/cli.js" PATH="${work}/bin:${SYS_PATH}" "$VALIDATE" "${work}/draft.md")"
    assert "ansi-stripped hits still gate and show text" 1 "$?" "Likely AI-Generated" "$out"
    if [[ "$out" == *$'\033'* ]]; then
        printf 'FAIL: hits are ANSI-stripped\n  output still contains an ESC byte\n'
        fail_count=$((fail_count + 1))
    else
        printf 'PASS: hits are ANSI-stripped\n'
        pass_count=$((pass_count + 1))
    fi
    rm -rf "$work"
}

# --- Test 20: both detectors present and clean -> exit 0 ---
test_both_clean() {
    local work; work="$(mktemp -d)"
    make_stub "${work}/bin" 0 ""                       # ai-slop passes
    printf 'AI PROBABILITY SCORE: 12/100\n' > "${work}/report"
    make_node_stub "${work}/bin" 0 "${work}/report"    # ai-writing-detector below threshold
    touch "${work}/cli.js"
    printf 'prose\n' > "${work}/draft.md"
    AI_WRITING_DETECTOR_CLI="${work}/cli.js" PATH="${work}/bin:${SYS_PATH}" "$VALIDATE" "${work}/draft.md" >/dev/null 2>&1
    assert "both detectors clean exits 0" 0 "$?"
    rm -rf "$work"
}

# --- Test 21: an absurdly long score can't overflow arithmetic into a pass -> skip ---
test_awd_overflow_score_skips() {
    local work; work="$(mktemp -d)"
    printf 'AI PROBABILITY SCORE: 18446744073709551616/100\n' > "${work}/report"
    make_node_stub "${work}/bin" 0 "${work}/report"
    touch "${work}/cli.js"
    printf 'prose\n' > "${work}/draft.md"
    AI_WRITING_DETECTOR_CLI="${work}/cli.js" PATH="${work}/bin:${SYS_PATH}" "$VALIDATE" "${work}/draft.md" >/dev/null 2>&1
    assert "overflow-length score skips (exit 2)" 2 "$?"
    rm -rf "$work"
}

# --- Test 17: a report with two score lines is ambiguous -> skip, never a pass ---
test_awd_multiple_scores_skips() {
    local work; work="$(mktemp -d)"
    printf 'AI PROBABILITY SCORE: 40/100\nAI PROBABILITY SCORE: 88/100\n' > "${work}/report"
    make_node_stub "${work}/bin" 0 "${work}/report"
    touch "${work}/cli.js"
    printf 'prose\n' > "${work}/draft.md"
    AI_WRITING_DETECTOR_CLI="${work}/cli.js" PATH="${work}/bin:${SYS_PATH}" "$VALIDATE" "${work}/draft.md" >/dev/null 2>&1
    assert "ambiguous multi-score report skips (exit 2)" 2 "$?"
    rm -rf "$work"
}

# --- Test 18: a zero-padded score is read base-10, not octal -> gates correctly ---
test_awd_zero_padded_score() {
    local work; work="$(mktemp -d)"
    printf 'AI PROBABILITY SCORE: 088/100\n' > "${work}/report"
    make_node_stub "${work}/bin" 0 "${work}/report"
    touch "${work}/cli.js"
    printf 'prose\n' > "${work}/draft.md"
    AI_WRITING_DETECTOR_CLI="${work}/cli.js" PATH="${work}/bin:${SYS_PATH}" "$VALIDATE" "${work}/draft.md" >/dev/null 2>&1
    assert "zero-padded score 088 gates as 88 (exit 1)" 1 "$?"
    rm -rf "$work"
}

test_pass
test_fail_shows_hits
test_missing_tool
test_threshold_passthrough
test_detector_error
test_missing_arg
test_nonexistent_file
test_awd_flags
test_awd_clean_alone
test_both_flag_union
test_awd_threshold_override
test_awd_strips_ansi
test_awd_node_error_skips
test_awd_missing_cli_skips
test_awd_no_node_skips
test_awd_unparseable_skips
test_awd_multiple_scores_skips
test_awd_zero_padded_score
test_awd_hits_are_ansi_stripped
test_both_clean
test_awd_overflow_score_skips

printf '\n%d passed, %d failed\n' "$pass_count" "$fail_count"
[[ "$fail_count" -eq 0 ]]
