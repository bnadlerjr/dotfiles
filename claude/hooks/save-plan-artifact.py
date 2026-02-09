#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.8"
# dependencies = []
# ///

"""
UserPromptSubmit hook that detects plan-mode-to-normal transition.

When plan mode exits and the user submits their first prompt in normal mode,
this hook fires once to remind Claude to save the approved plan as a vault
artifact. The marker file is written by plan-mode-context.py during plan mode
and consumed (deleted) here so the reminder fires exactly once.
"""

import json
import sys
from pathlib import Path


MARKER_FILE = Path.home() / ".claude" / ".plan-mode-active"


def main():
    try:
        input_data = json.load(sys.stdin)
    except json.JSONDecodeError:
        sys.exit(0)

    permission_mode = input_data.get("permission_mode", "default")

    # Only fire when NOT in plan mode and the marker exists
    if permission_mode == "plan":
        sys.exit(0)

    if not MARKER_FILE.exists():
        sys.exit(0)

    # Consume the marker so this fires only once
    try:
        MARKER_FILE.unlink()
    except OSError:
        pass

    print("""<save-plan-artifact>
The plan from this session has not been saved as an artifact yet.
Before starting implementation, save the approved plan to
$CLAUDE_DOCS_ROOT/plans/plan--<slug>.md with full frontmatter
per CLAUDE.md artifact management rules. Look up the project in
projects.yaml. The plan content is in the plan file you just edited.
</save-plan-artifact>""")

    sys.exit(0)


if __name__ == "__main__":
    main()
