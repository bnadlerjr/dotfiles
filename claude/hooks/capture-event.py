#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.8"
# dependencies = []
# ///

import json
import os
import sqlite3
import sys
from datetime import datetime, timezone
from pathlib import Path


def extract_project_name(project_dir=None, cwd=None):
    """Extract project name from directory path."""
    path = project_dir or cwd or os.getcwd()
    # Handle special cases
    if path == os.path.expanduser("~"):
        return "home"
    if path == "/":
        return "root"
    # Get last component of path
    return os.path.basename(os.path.normpath(path))


def get_claude_env_vars():
    """Get all environment variables starting with CLAUDE_."""
    return {k: v for k, v in os.environ.items() if k.startswith("CLAUDE_")}


def ensure_database(db_path):
    """Create database and tables if they don't exist."""
    db_dir = db_path.parent
    db_dir.mkdir(parents=True, exist_ok=True)

    conn = sqlite3.connect(str(db_path))
    conn.execute("PRAGMA journal_mode=WAL")  # Enable WAL for better concurrency

    # Create table if it doesn't exist
    conn.execute("""
        CREATE TABLE IF NOT EXISTS claude_events (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            event_id TEXT UNIQUE NOT NULL,
            hook_type TEXT NOT NULL,
            session_id TEXT,
            project_name TEXT,
            project_dir TEXT,
            timestamp TEXT,
            tool_name TEXT,
            tool_input TEXT,
            tool_output TEXT,
            user_prompt TEXT,
            transcript_path TEXT,
            cwd TEXT,
            environment TEXT,
            full_event TEXT NOT NULL,
            created_at TEXT DEFAULT CURRENT_TIMESTAMP
        )
    """)

    # Create indexes
    indexes = [
        "CREATE INDEX IF NOT EXISTS idx_hook_type ON claude_events(hook_type)",
        "CREATE INDEX IF NOT EXISTS idx_tool_name ON claude_events(tool_name)",
        "CREATE INDEX IF NOT EXISTS idx_session_id ON claude_events(session_id)",
        "CREATE INDEX IF NOT EXISTS idx_project_name ON claude_events(project_name)",
        "CREATE INDEX IF NOT EXISTS idx_timestamp ON claude_events(timestamp)",
    ]

    for index in indexes:
        conn.execute(index)

    conn.commit()
    return conn


def generate_event_id(session_id, timestamp, hook_type):
    """Generate a unique event ID."""
    # Use session_id, timestamp, and hook_type to create unique ID
    components = [
        session_id or "no-session",
        timestamp or datetime.now(timezone.utc).isoformat(),
        hook_type or "unknown",
    ]
    return "-".join(str(c).replace(" ", "_") for c in components)


def store_event(conn, event_data):
    """Store event in database."""
    try:
        # Extract fields from event data
        hook_type = event_data.get("hook_event_name", "unknown")
        session_id = event_data.get("session_id")
        timestamp = event_data.get("timestamp")
        transcript_path = event_data.get("transcript_path")
        cwd = event_data.get("cwd")

        # Tool-related fields
        tool_name = event_data.get("tool_name")
        tool_input = event_data.get("tool_input")
        tool_output = event_data.get("tool_output")

        # User prompt (for UserPromptSubmit events)
        user_prompt = event_data.get("prompt")

        # Get project info
        project_dir = os.environ.get("CLAUDE_PROJECT_DIR", cwd)
        project_name = extract_project_name(project_dir, cwd)

        # Capture environment
        env_vars = get_claude_env_vars()

        # Generate unique event ID
        event_id = generate_event_id(session_id, timestamp, hook_type)

        # Convert complex fields to JSON strings
        tool_input_json = json.dumps(tool_input) if tool_input else None
        tool_output_json = json.dumps(tool_output) if tool_output else None
        environment_json = json.dumps(env_vars)
        full_event_json = json.dumps(event_data)

        # Insert into database
        conn.execute(
            """
            INSERT OR REPLACE INTO claude_events (
                event_id, hook_type, session_id, project_name, project_dir,
                timestamp, tool_name, tool_input, tool_output, user_prompt,
                transcript_path, cwd, environment, full_event
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """,
            (
                event_id,
                hook_type,
                session_id,
                project_name,
                project_dir,
                timestamp,
                tool_name,
                tool_input_json,
                tool_output_json,
                user_prompt,
                transcript_path,
                cwd,
                environment_json,
                full_event_json,
            ),
        )

        conn.commit()

    except Exception as e:
        print(f"Error storing event: {e}", file=sys.stderr)
        # Don't raise - we don't want to block Claude Code


def main():
    try:
        # Read JSON from stdin
        input_data = json.load(sys.stdin)

        # Set up database
        db_path = Path.home() / ".claude" / "events.db"
        conn = ensure_database(db_path)

        # Store the event
        store_event(conn, input_data)

        # Close connection
        conn.close()

        # Always exit successfully to avoid blocking
        sys.exit(0)

    except json.JSONDecodeError as e:
        print(f"Error: Invalid JSON input: {e}", file=sys.stderr)
        sys.exit(0)
    except Exception as e:
        print(f"Unexpected error: {e}", file=sys.stderr)
        sys.exit(0)


if __name__ == "__main__":
    main()
