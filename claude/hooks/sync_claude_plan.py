#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.8"
# dependencies = []
# ///

"""
Sync Claude Code plans to project-specific directory.

This PostToolUse hook moves plan files from ~/.claude/plans/ to the
project-specific plans directory (via claude-docs-path) and creates
a symlink back for Claude Code compatibility.

The target filename is derived from the H1 header in the markdown content,
following the pattern: YYYY-MM-DD-<slugified-h1>.md
"""

import json
import re
import shutil
import subprocess
import sys
from datetime import date
from pathlib import Path


def get_target_plans_dir() -> str | None:
    """Get the project-specific plans directory using claude-docs-path."""
    try:
        result = subprocess.run(
            ["claude-docs-path", "plans"],
            capture_output=True,
            text=True,
            timeout=5,
        )
        if result.returncode == 0:
            return result.stdout.strip()
    except (subprocess.TimeoutExpired, FileNotFoundError):
        pass
    return None


def extract_h1(content: str) -> str | None:
    """Extract the first H1 header from markdown content."""
    for line in content.split("\n"):
        line = line.strip()
        if line.startswith("# "):
            return line[2:].strip()
    return None


def slugify(text: str, max_length: int = 50) -> str:
    """Convert text to a URL/filename-safe slug."""
    # Remove common prefixes
    text = re.sub(r"^Plan:\s*", "", text, flags=re.IGNORECASE)

    # Convert to lowercase
    text = text.lower()

    # Replace spaces and underscores with hyphens
    text = re.sub(r"[\s_]+", "-", text)

    # Remove characters that aren't alphanumeric or hyphens
    text = re.sub(r"[^a-z0-9-]", "", text)

    # Collapse multiple hyphens
    text = re.sub(r"-+", "-", text)

    # Strip leading/trailing hyphens
    text = text.strip("-")

    # Truncate to max length (at word boundary if possible)
    if len(text) > max_length:
        text = text[:max_length].rsplit("-", 1)[0]

    return text


def generate_filename(content: str, fallback_name: str) -> str:
    """Generate a descriptive filename from content H1 or use fallback."""
    h1 = extract_h1(content)

    if h1:
        slug = slugify(h1)
        if slug:
            today = date.today().isoformat()
            return f"{today}-{slug}.md"

    # Fallback to original filename
    return fallback_name


def find_unique_path(target_dir: Path, filename: str) -> Path:
    """Find a unique path, appending -1, -2, etc. if file exists."""
    target_path = target_dir / filename

    if not target_path.exists():
        return target_path

    # File exists, try with suffix
    stem = filename.rsplit(".", 1)[0]
    suffix = ".md"
    counter = 1

    while True:
        new_filename = f"{stem}-{counter}{suffix}"
        target_path = target_dir / new_filename
        if not target_path.exists():
            return target_path
        counter += 1
        if counter > 100:  # Safety limit
            return target_dir / filename  # Give up, overwrite


def main():
    try:
        input_data = json.load(sys.stdin)
    except json.JSONDecodeError:
        sys.exit(0)

    # Only process Write tool
    if input_data.get("tool_name") != "Write":
        sys.exit(0)

    tool_input = input_data.get("tool_input", {})
    file_path = tool_input.get("file_path", "")
    content = tool_input.get("content", "")

    if not file_path:
        sys.exit(0)

    # Only process files in ~/.claude/plans/
    claude_plans_dir = Path.home() / ".claude" / "plans"
    file_path = Path(file_path)

    if not str(file_path).startswith(str(claude_plans_dir)):
        sys.exit(0)

    # Skip if already a symlink (already processed)
    if file_path.is_symlink():
        sys.exit(0)

    # Skip if file doesn't exist
    if not file_path.exists():
        sys.exit(0)

    # Get target directory
    target_dir = get_target_plans_dir()
    if not target_dir:
        sys.exit(0)

    target_dir = Path(target_dir)
    target_dir.mkdir(parents=True, exist_ok=True)

    # Generate descriptive filename from H1 header
    target_filename = generate_filename(content, file_path.name)
    target_path = find_unique_path(target_dir, target_filename)

    # Move file to target location
    try:
        shutil.move(str(file_path), str(target_path))
    except OSError:
        sys.exit(0)

    # Create symlink back to original location
    try:
        file_path.symlink_to(target_path)
    except OSError:
        # If symlink fails, restore the file
        shutil.move(str(target_path), str(file_path))
        sys.exit(0)


if __name__ == "__main__":
    main()
