#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.8"
# dependencies = []
# ///

"""
UserPromptSubmit hook that injects planning skill reference when in plan mode.

Detects permission_mode == "plan" and outputs a lightweight pointer to the
implementation-planning skill. The skill contains the full methodology.
"""

import json
import sys


def main():
    try:
        input_data = json.load(sys.stdin)
    except json.JSONDecodeError:
        sys.exit(0)

    permission_mode = input_data.get("permission_mode", "default")

    if permission_mode != "plan":
        sys.exit(0)

    # Output context that Claude will see
    # Keep it minimal - the skill has the full instructions
    context = """<plan_mode_context>
For implementation planning, read and follow the skill at:
~/dotfiles/claude/skills/implementation-planning/SKILL.md

Key principles:
• Interactive: Align before detailing (don't dump full plans)
• Grounded: Verify with code, cite file:line references
• Bounded: Include "What We're NOT Doing" section
• Testable: Separate automated vs manual success criteria

Available research agents: serena-codebase-locator, codebase-analyzer, codebase-pattern-finder, docs-locator, docs-analyzer; use `managing-jira` skill for Jira operations

Template at: ~/dotfiles/claude/skills/implementation-planning/templates/plan-template.md
</plan_mode_context>"""

    print(context)
    sys.exit(0)


if __name__ == "__main__":
    main()
