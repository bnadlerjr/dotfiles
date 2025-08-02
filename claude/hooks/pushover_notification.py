#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.8"
# dependencies = [
#   "requests>=2.31.0"
# ]
# ///

import json
import os
import platform
import subprocess
import sys
from typing import Optional

try:
    import requests
except ImportError:
    print("Error: requests library not available", file=sys.stderr)
    sys.exit(0)

# Import formatting functions from notification.py
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
try:
    from notification import extract_project_name, format_notification_message
except ImportError:
    # Fallback implementations if import fails
    def extract_project_name(project_dir=None, cwd=None):
        path = project_dir or cwd or os.getcwd()
        if path == os.path.expanduser("~"):
            return "home"
        if path == "/":
            return "root"
        return os.path.basename(os.path.normpath(path))

    def format_notification_message(event_data):
        hook_type = event_data.get("hook_event_name", "unknown")
        project_name = extract_project_name(event_data.get("cwd"))
        title = f"Claude Code: {hook_type}"
        body = f"Project: {project_name}" if project_name else hook_type
        return title, body


def get_idle_time_macos() -> Optional[float]:
    """Get idle time in seconds on macOS using ioreg."""
    try:
        cmd = "ioreg -c IOHIDSystem | awk '/HIDIdleTime/ {print $NF/1000000000; exit}'"
        result = subprocess.run(
            cmd, shell=True, capture_output=True, text=True, check=False
        )
        if result.returncode == 0 and result.stdout.strip():
            return float(result.stdout.strip())
    except Exception as e:
        print(f"Error getting idle time: {e}", file=sys.stderr)
    return None


def get_pushover_priority(hook_type: str, tool_name: str = "") -> int:
    """Determine Pushover priority based on event type."""
    if hook_type == "Stop":
        return 0  # Normal priority for completion
    elif hook_type == "SubagentStop":
        return 1  # High priority for subagent completion
    elif hook_type == "Notification":
        return 1  # High priority for approval requests
    elif hook_type == "UserPromptSubmit":
        return -1  # Low priority for starts
    else:
        return 0  # Default normal priority


def get_pushover_sound(hook_type: str, tool_name: str = "") -> str:
    """Select Pushover sound based on event type."""
    if hook_type == "Stop" or (hook_type == "PostToolUse" and tool_name):
        return "magic"  # Pleasant chime for completions
    elif hook_type == "PreToolUse" or hook_type == "UserPromptSubmit":
        return "vibrate"  # Subtle alert for starting operations
    elif hook_type == "SubagentStop":
        return "cosmic"  # More prominent sound for subagent completion
    elif hook_type == "Notification":
        return "siren"  # Urgent sound for approval requests
    else:
        return "pushover"  # Default sound


def send_pushover_notification(
    title: str,
    message: str,
    user_key: str,
    app_token: str,
    priority: int = 0,
    sound: str = "pushover",
    url: Optional[str] = None,
    url_title: Optional[str] = None,
) -> bool:
    """Send a notification via Pushover API."""
    try:
        data = {
            "token": app_token,
            "user": user_key,
            "title": title,
            "message": message,
            "priority": priority,
            "sound": sound,
        }

        if url:
            data["url"] = url
            if url_title:
                data["url_title"] = url_title

        response = requests.post(
            "https://api.pushover.net/1/messages.json", data=data, timeout=10
        )

        if response.status_code == 200:
            return True
        else:
            print(
                f"Pushover API error: {response.status_code} - {response.text}",
                file=sys.stderr,
            )
            return False

    except requests.exceptions.RequestException as e:
        print(f"Failed to send Pushover notification: {e}", file=sys.stderr)
        return False
    except Exception as e:
        print(f"Unexpected error sending notification: {e}", file=sys.stderr)
        return False


def main():
    # Check operating system
    system = platform.system()
    if system != "Darwin":
        # Not macOS, exit silently
        sys.exit(0)

    # Get configuration from environment
    user_key = os.environ.get("PUSHOVER_USER_KEY")
    app_token = os.environ.get("PUSHOVER_APP_TOKEN")
    idle_threshold = int(
        os.environ.get("PUSHOVER_IDLE_THRESHOLD", "300")
    )  # 5 minutes default

    if not user_key or not app_token:
        # No credentials configured, exit silently
        sys.exit(0)

    try:
        # Read JSON from stdin
        input_data = json.load(sys.stdin)

        # Filter notifications - show for approvals and when Claude is finished
        hook_type = input_data.get("hook_event_name", "unknown")
        if hook_type not in ["Stop", "SubagentStop", "Notification"]:
            # Exit silently for all other events
            sys.exit(0)

        # Check idle time (but always send Notification events regardless of idle time)
        idle_time = get_idle_time_macos()
        if hook_type != "Notification":
            if idle_time is None:
                print(
                    "Warning: Could not determine idle time, sending notification anyway",
                    file=sys.stderr,
                )
            elif idle_time < idle_threshold:
                # User is at computer, don't send pushover notification for non-approval events
                sys.exit(0)

        # Format notification
        title, body = format_notification_message(input_data)

        # Get priority and sound for event type
        tool_name = input_data.get("tool_name", "")
        priority = get_pushover_priority(hook_type, tool_name)
        sound = get_pushover_sound(hook_type, tool_name)

        # Add idle time info to message
        if idle_time is not None:
            idle_minutes = int(idle_time / 60)
            body += f" • Idle: {idle_minutes}m"

        # Send Pushover notification
        send_pushover_notification(
            title=title,
            message=body,
            user_key=user_key,
            app_token=app_token,
            priority=priority,
            sound=sound,
        )

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
