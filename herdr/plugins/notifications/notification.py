#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.8"
# dependencies = []
# ///

import glob
import json
import os
import platform
import random
import subprocess
import sys
import tempfile
import time


def get_dedup_file():
    """Get the path to the deduplication tracking file."""
    return os.path.join(tempfile.gettempdir(), "herdr_notification_dedup.json")


def should_skip_notification(event_key, dedup_window=5.0):
    """Check if we should skip this notification due to recent duplicate."""
    dedup_file = get_dedup_file()
    current_time = time.time()

    try:
        # Read existing deduplication data
        if os.path.exists(dedup_file):
            with open(dedup_file, "r") as f:
                dedup_data = json.load(f)
        else:
            dedup_data = {}

        # Check if this event type was recently notified
        if event_key in dedup_data:
            last_time = dedup_data[event_key]
            if current_time - last_time < dedup_window:
                return True  # Skip this notification

        # Update the timestamp for this event type
        dedup_data[event_key] = current_time

        # Clean old entries (older than 60 seconds)
        dedup_data = {k: v for k, v in dedup_data.items() if current_time - v < 60}

        # Write updated data
        with open(dedup_file, "w") as f:
            json.dump(dedup_data, f)

        return False  # Don't skip

    except Exception:
        # If anything goes wrong with dedup, just allow the notification
        return False


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


def get_custom_sound(sound_type):
    """Get a random sound file from the specified sounds subdirectory."""
    script_dir = os.path.dirname(os.path.abspath(__file__))
    sounds_dir = os.path.join(script_dir, "sounds", sound_type)

    # Find all audio files in the directory
    patterns = ["*.mp3", "*.wav", "*.ogg", "*.oga", "*.m4a", "*.flac"]
    sound_files = []

    if os.path.exists(sounds_dir):
        for pattern in patterns:
            sound_files.extend(glob.glob(os.path.join(sounds_dir, pattern)))

    if sound_files:
        return random.choice(sound_files)
    return None


def get_sound_for_event(status):
    """Select a custom sound based on the agent status."""
    if status == "done":
        return "CUSTOM_STOP"
    return "CUSTOM_NOTIFICATION"


def format_agent_name(event_data):
    """Return a readable name for the agent that emitted the event."""
    if display_name := event_data.get("display_agent"):
        return str(display_name)
    name = event_data.get("agent") or "Agent"
    return str(name).replace("-", " ").replace("_", " ").title()


def format_notification_message(event_data, context):
    """Format a Herdr agent-status event as a notification."""
    status = event_data["agent_status"]
    agent_name = format_agent_name(event_data)
    title = f"{agent_name} {'Finished' if status == 'done' else 'Needs Input'}"

    project_dir = context.get("workspace_cwd") or context.get("focused_pane_cwd")
    project_name = extract_project_name(project_dir, project_dir)
    body = f"Project: {project_name}" if project_name not in ["home", "root"] else status

    return title, body


def send_macos_notification(title, message, sound):
    """Send a macOS notification using osascript with sound."""
    try:
        # Escape quotes in title and message
        title = title.replace('"', '\\"')
        message = message.replace('"', '\\"')

        # Handle custom sounds
        if sound in ["CUSTOM_NOTIFICATION", "CUSTOM_STOP"]:
            # Get custom sound file
            sound_type = "notification" if sound == "CUSTOM_NOTIFICATION" else "stop"
            sound_file = get_custom_sound(sound_type)

            if sound_file:
                # Send notification without sound
                script = f'display notification "{message}" with title "{title}"'
                subprocess.run(
                    ["osascript", "-e", script],
                    capture_output=True,
                    text=True,
                    check=False,
                )
                # Play custom sound separately using afplay
                subprocess.run(
                    ["afplay", sound_file],
                    capture_output=True,
                    check=False,
                )
            else:
                # Fallback to default sound
                fallback_sound = (
                    "Submarine" if sound == "CUSTOM_NOTIFICATION" else "Glass"
                )
                script = f'display notification "{message}" with title "{title}" sound name "{fallback_sound}"'
                subprocess.run(
                    ["osascript", "-e", script],
                    capture_output=True,
                    text=True,
                    check=False,
                )
        else:
            # Use system sound
            script = f'display notification "{message}" with title "{title}" sound name "{sound}"'
            subprocess.run(
                ["osascript", "-e", script],
                capture_output=True,
                text=True,
                check=False,
            )
    except Exception as e:
        print(f"Failed to send notification: {e}", file=sys.stderr)


def play_linux_sound(sound_name):
    """Play a sound on Linux using available sound players."""
    try:
        # Handle custom sounds
        if sound_name == "CUSTOM_NOTIFICATION":
            sound_file = get_custom_sound("notification")
            if not sound_file:
                # Fallback to default notification sound
                sound_name = "Submarine"
                sound_file = get_linux_sound_file(sound_name)
        elif sound_name == "CUSTOM_STOP":
            sound_file = get_custom_sound("stop")
            if not sound_file:
                # Fallback to default stop sound
                sound_name = "Glass"
                sound_file = get_linux_sound_file(sound_name)
        else:
            # Get the system sound file path
            sound_file = get_linux_sound_file(sound_name)

        if not sound_file:
            return

        # Try pw-play first (PipeWire)
        result = subprocess.run(
            ["pw-play", sound_file], capture_output=True, check=False
        )

        if result.returncode != 0 and sound_name not in [
            "CUSTOM_NOTIFICATION",
            "CUSTOM_STOP",
        ]:
            # Try canberra-gtk-play with sound theme (only for system sounds)
            sound_theme_names = {
                "Glass": "complete",
                "Ping": "message",
                "Hero": "bell",
                "Submarine": "suspend-error",
                "Pop": "dialog-information",
            }
            theme_name = sound_theme_names.get(sound_name)
            if theme_name:
                result = subprocess.run(
                    ["canberra-gtk-play", "-i", theme_name],
                    capture_output=True,
                    check=False,
                )

            if result.returncode != 0:
                # Final fallback to paplay (PulseAudio compatibility layer)
                subprocess.run(["paplay", sound_file], capture_output=True, check=False)
    except Exception:
        # Silently ignore sound playback errors
        pass


def get_linux_sound_file(sound_name):
    """Map macOS sound names to Linux freedesktop sound files."""
    # Map to freedesktop sound theme sounds
    sound_map = {
        "Glass": "/usr/share/sounds/freedesktop/stereo/complete.oga",
        "Ping": "/usr/share/sounds/freedesktop/stereo/message.oga",
        "Hero": "/usr/share/sounds/freedesktop/stereo/bell.oga",
        "Submarine": "/usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga",
        "Pop": "/usr/share/sounds/freedesktop/stereo/dialog-information.oga",
    }

    # Check if the mapped file exists
    sound_file = sound_map.get(sound_name)
    if sound_file and os.path.exists(sound_file):
        return sound_file

    # Fallback to any available sound
    for fallback in sound_map.values():
        if os.path.exists(fallback):
            return fallback

    return None


def send_linux_notification(title, message, sound_name):
    """Send a Linux desktop notification using notify-send with sound."""
    try:
        # Determine urgency based on title content
        urgency = "critical" if "Needs Input" in title else "normal"

        # Build notify-send command
        cmd = [
            "notify-send",
            "-u",
            urgency,
            "-a",
            "Herdr",
            "-c",
            "im",
            title,
            message,
        ]

        # Send notification
        subprocess.run(cmd, capture_output=True, text=True, check=False)

        # Play sound if available
        play_linux_sound(sound_name)

    except Exception as e:
        print(f"Failed to send notification: {e}", file=sys.stderr)


def main():
    if os.environ.get("HERDR_NO_NOTIFY"):
        sys.exit(0)

    system = platform.system()
    if system not in ["Darwin", "Linux"]:
        sys.exit(0)

    try:
        event = json.loads(os.environ.get("HERDR_PLUGIN_EVENT_JSON", "{}"))
        context = json.loads(os.environ.get("HERDR_PLUGIN_CONTEXT_JSON", "{}"))
        event_data = event.get("data", {})
        status = event_data.get("agent_status")
        if status not in ["done", "blocked"]:
            sys.exit(0)

        event_key = f"{event_data.get('pane_id', 'unknown')}:{status}"
        if should_skip_notification(event_key):
            sys.exit(0)

        title, body = format_notification_message(event_data, context)
        sound = get_sound_for_event(status)

        if system == "Darwin":
            send_macos_notification(title, body, sound)
        elif system == "Linux":
            send_linux_notification(title, body, sound)

        sys.exit(0)

    except json.JSONDecodeError as e:
        print(f"Error: Invalid Herdr event JSON: {e}", file=sys.stderr)
        sys.exit(0)
    except Exception as e:
        print(f"Unexpected error: {e}", file=sys.stderr)
        sys.exit(0)


if __name__ == "__main__":
    main()
