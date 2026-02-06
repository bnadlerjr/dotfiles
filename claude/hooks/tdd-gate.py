#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.8"
# dependencies = []
# ///
"""PreToolUse hook that enforces TDD by detecting production code writes."""

import json
import re
import sys

CODE_FILE_PATTERN = r"\.(ex|exs|ts|tsx)$"
TEST_FILE_PATTERN = r"(_test\.exs|\.test\.tsx?|\.spec\.tsx?)$"


def main() -> None:
    """Detect production code writes and instruct Claude to activate TDD skill first."""
    try:
        input_data = json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError) as e:
        print(f"Error: Invalid JSON input: {e}", file=sys.stderr)
        sys.exit(1)

    tool_input = input_data.get("tool_input", {})
    file_path = tool_input.get("file_path") or tool_input.get("path") or ""

    if not file_path:
        sys.exit(0)

    is_code = bool(re.search(CODE_FILE_PATTERN, file_path, re.IGNORECASE))
    is_test = bool(re.search(TEST_FILE_PATTERN, file_path, re.IGNORECASE))

    if is_code and not is_test:
        print(f"TDD gate triggered for: {file_path}", file=sys.stderr)

        print(
            """\
INSTRUCTION: MANDATORY TDD SKILL ACTIVATION

You are about to write production code. Before proceeding:

1. ACTIVATE Skill(practicing-tdd) NOW
2. Write or update the corresponding test file FIRST
3. Only then write the production code

If tests already exist for this change, confirm they cover the new behavior.
If no tests exist, create them before this file.

CRITICAL: Do not skip this. Activate Skill(practicing-tdd) before continuing."""
        )

    sys.exit(0)


if __name__ == "__main__":
    main()
