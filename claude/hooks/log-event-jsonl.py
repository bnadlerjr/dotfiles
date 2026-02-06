#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.8"
# dependencies = []
# ///

"""Log all Claude Code hook events to daily JSONL files.

Reads the hook event JSON from stdin, enriches it with metadata,
and appends a single JSON line to ~/.claude/events-log/events-YYYY-MM-DD.jsonl.

Supports all 12 hook event types:
  SessionStart, UserPromptSubmit, PreToolUse, PermissionRequest,
  PostToolUse, PostToolUseFailure, Notification, SubagentStart,
  SubagentStop, Stop, PreCompact, SessionEnd
"""

import fcntl
import json
import os
import sys
from datetime import datetime, timezone
from pathlib import Path

LOG_DIR = Path.home() / ".claude" / "events-log"


def extract_project_name(project_dir=None, cwd=None):
    """Extract project name from directory path."""
    path = project_dir or cwd or os.getcwd()
    if path == os.path.expanduser("~"):
        return "home"
    if path == "/":
        return "root"
    return os.path.basename(os.path.normpath(path))


def enrich_event(event_data, now):
    """Add metadata fields to the raw event data."""
    project_dir = os.environ.get("CLAUDE_PROJECT_DIR", event_data.get("cwd"))
    claude_env = {k: v for k, v in os.environ.items() if k.startswith("CLAUDE_")}

    event_data["logged_at"] = now.isoformat()
    event_data["project_name"] = extract_project_name(
        project_dir, event_data.get("cwd")
    )
    event_data["claude_env"] = claude_env

    return event_data


def append_event(event_data, now):
    """Append a JSON line to the daily log file with exclusive file locking."""
    LOG_DIR.mkdir(parents=True, exist_ok=True)

    date_str = datetime.now().strftime("%Y-%m-%d")
    log_path = LOG_DIR / f"events-{date_str}.jsonl"
    line = json.dumps(event_data, separators=(",", ":")) + "\n"

    with open(log_path, "a") as f:
        fcntl.flock(f, fcntl.LOCK_EX)
        f.write(line)


def main():
    try:
        input_data = json.load(sys.stdin)
    except json.JSONDecodeError as e:
        print(f"Invalid JSON input: {e}", file=sys.stderr)
        sys.exit(0)

    try:
        now = datetime.now(timezone.utc)
        enriched = enrich_event(input_data, now)
        append_event(enriched, now)
    except Exception as e:
        print(f"Error logging event: {e}", file=sys.stderr)

    sys.exit(0)


if __name__ == "__main__":
    main()
