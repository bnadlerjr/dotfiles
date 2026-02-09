#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.8"
# dependencies = []
# ///
"""PostToolUse hook that reminds to run code-simplifier after code edits."""

import json
import re
import sys

CODE_FILE_PATTERN = r"\.(ex|exs|ts|tsx)$"


def main() -> None:
    """Print a reminder to run code-simplifier after code writes."""
    try:
        input_data = json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError) as e:
        print(f"Error: Invalid JSON input: {e}", file=sys.stderr)
        sys.exit(0)

    tool_input = input_data.get("tool_input", {})
    file_path = tool_input.get("file_path") or tool_input.get("path") or ""

    if not file_path:
        sys.exit(0)

    is_code = bool(re.search(CODE_FILE_PATTERN, file_path, re.IGNORECASE))

    if is_code:
        print(
            "REMINDER: After completing your current set of edits, run the "
            "code-simplifier sub-agent to review modified files for unnecessary "
            "complexity, noisy comments, and YAGNI violations.\n"
            "\n"
            "Use the Task tool:\n"
            "  subagent_type: code-simplifier\n"
            "  prompt: Review and simplify: " + file_path
        )

    sys.exit(0)


if __name__ == "__main__":
    main()
