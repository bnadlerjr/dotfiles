#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.8"
# dependencies = []
# ///

import json
import os
import platform
import subprocess
import sys


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


def get_sound_for_event(hook_type, tool_name):
    """Select appropriate sound based on event type."""
    if hook_type == "Stop" or (hook_type == "PostToolUse" and tool_name):
        return "Glass"  # Pleasant chime for completions
    elif hook_type == "PreToolUse" or hook_type == "UserPromptSubmit":
        return "Ping"  # Quick alert for starting operations
    elif hook_type == "SubagentStop":
        return "Hero"  # More prominent sound for subagent completion
    elif hook_type == "Notification":
        return "Submarine"  # Deep, prominent ping for approval requests
    else:
        return "Pop"  # Gentle sound for general notifications


def format_notification_message(event_data):
    """Format event data into notification title and body."""
    hook_type = event_data.get("hook_event_name", "unknown")
    tool_name = event_data.get("tool_name", "")

    # Get project info
    project_dir = os.environ.get("CLAUDE_PROJECT_DIR", event_data.get("cwd"))
    project_name = extract_project_name(project_dir, event_data.get("cwd"))

    # Format title based on hook type
    if hook_type == "Notification":
        title = "Claude Code Needs Approval"
    elif hook_type == "Stop":
        title = "Claude Code Finished"
    elif hook_type == "UserPromptSubmit":
        title = "Claude Code Processing"
    elif hook_type == "PreToolUse" and tool_name:
        title = f"Claude Code: {tool_name}"
    elif hook_type == "PostToolUse" and tool_name:
        title = f"Claude Code: {tool_name} Complete"
    elif hook_type == "SubagentStop":
        title = "Claude Code Subagent Complete"
    else:
        title = f"Claude Code: {hook_type}"

    # Format body
    body_parts = []
    if project_name and project_name not in ["home", "root"]:
        body_parts.append(f"Project: {project_name}")

    if hook_type == "UserPromptSubmit":
        prompt = event_data.get("prompt", "")
        if prompt:
            # Truncate long prompts
            prompt_preview = prompt[:50] + "..." if len(prompt) > 50 else prompt
            body_parts.append(f"Prompt: {prompt_preview}")
    elif tool_name:
        # Add tool-specific info
        tool_input = event_data.get("tool_input", {})
        if isinstance(tool_input, dict):
            if (
                tool_name in ["Edit", "Write", "MultiEdit"]
                and "file_path" in tool_input
            ):
                file_path = tool_input["file_path"]
                file_name = os.path.basename(file_path)
                body_parts.append(f"File: {file_name}")
            elif tool_name == "Bash" and "command" in tool_input:
                cmd = tool_input["command"]
                cmd_preview = cmd[:30] + "..." if len(cmd) > 30 else cmd
                body_parts.append(f"Command: {cmd_preview}")

    body = " • ".join(body_parts) if body_parts else hook_type

    return title, body


def send_macos_notification(title, message, sound):
    """Send a macOS notification using osascript with sound."""
    try:
        # Escape quotes in title and message
        title = title.replace('"', '\\"')
        message = message.replace('"', '\\"')

        # Build osascript command with sound
        script = f'display notification "{message}" with title "{title}" sound name "{sound}"'

        # Execute osascript
        subprocess.run(
            ["osascript", "-e", script],
            capture_output=True,
            text=True,
            check=False,  # Don't raise on non-zero exit
        )
    except Exception as e:
        print(f"Failed to send notification: {e}", file=sys.stderr)


def main():
    # Check operating system
    system = platform.system()
    if system != "Darwin":
        # Not macOS, exit silently
        sys.exit(0)

    try:
        # Read JSON from stdin
        input_data = json.load(sys.stdin)

        # Filter notifications - show for approvals and when Claude is finished
        hook_type = input_data.get("hook_event_name", "unknown")
        if hook_type not in ["Stop", "SubagentStop", "Notification"]:
            # Exit silently for all other events
            sys.exit(0)

        # Format notification
        title, body = format_notification_message(input_data)

        # Get appropriate sound for event type
        tool_name = input_data.get("tool_name", "")
        sound = get_sound_for_event(hook_type, tool_name)

        # Send notification with sound
        send_macos_notification(title, body, sound)

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
