#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.8"
# dependencies = []
# ///

"""
UserPromptSubmit hook that injects planning skill reference when in plan mode.

Detects permission_mode == "plan" and outputs a conditional pointer: if the
plan is software-related, load the planning-tdd skill; otherwise plan freely.
Keeps plan mode general-purpose (usable for non-software planning).
"""

import json
import sys
from pathlib import Path


MARKER_FILE = Path.home() / ".claude" / ".plan-mode-active"


def write_plan_mode_marker(session_id):
    """Write marker file so save-plan-artifact hook knows plan mode was active."""
    try:
        MARKER_FILE.parent.mkdir(parents=True, exist_ok=True)
        MARKER_FILE.write_text(session_id or "unknown")
    except OSError:
        pass


def main():
    try:
        input_data = json.load(sys.stdin)
    except json.JSONDecodeError:
        sys.exit(0)

    permission_mode = input_data.get("permission_mode", "default")

    if permission_mode != "plan":
        sys.exit(0)

    session_id = input_data.get("session_id", "unknown")
    write_plan_mode_marker(session_id)

    # Output context that Claude will see
    # Keep it minimal - the skill has the full instructions
    context = """<plan_mode_context>
If this is a software implementation plan, read and follow the skill at:
~/dotfiles/claude/skills/planning-tdd/SKILL.md

Otherwise (non-software planning, exploration, general questions), plan freely without loading a skill. Plan mode is general-purpose.

Key principles for software implementation plans:
• Tests Are The Plan: Specify RED test specs + structural context, not implementation code
• Structural Context Not Solutions: Name modules/files in play, not how to build them
• Grounded: Verify with code, cite file:line references
• Bounded: Include "What We're NOT Doing" section
• Dual Verification: Every phase has automated test specs AND manual verification

Available research agents: codebase-navigator, codebase-analyzer, codebase-pattern-finder, docs-locator, docs-analyzer; use `managing-jira` skill for Jira operations

Template at: ~/dotfiles/claude/skills/planning-tdd/templates/plan-template.md
</plan_mode_context>"""

    print(context)
    sys.exit(0)


if __name__ == "__main__":
    main()
