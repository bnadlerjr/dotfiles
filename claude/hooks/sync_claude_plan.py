#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.8"
# dependencies = ["pyyaml"]
# ///

"""
Sync Claude Code plans to project-specific directory.

This PostToolUse hook for ExitPlanMode moves plan files from ~/.claude/plans/
to the project-specific plans directory (via claude-docs-path) and creates
a symlink back for Claude Code compatibility.

The hook receives plan content via tool_response.plan and the file path via
tool_response.filePath when Claude exits plan mode.

The target filename is derived from the H1 header in the markdown content,
following the pattern: YYYY-MM-DD-<slugified-h1>.md

Additionally, this hook ensures proper Obsidian-compatible YAML frontmatter
is present with metadata from `git metadata`.
"""

import json
import re
import subprocess
import sys
from datetime import date
from pathlib import Path

import yaml

FRONTMATTER_PATTERN = re.compile(r"^---\s*\n(.*?)\n---\s*\n", re.DOTALL)

DEFAULT_TAGS = ["plan", "ai"]


class ObsidianDumper(yaml.SafeDumper):
    """Custom YAML dumper for Obsidian-compatible frontmatter."""

    pass


def _str_representer(dumper, data):
    """Represent strings, keeping wiki-links readable."""
    if data.startswith("[[") and data.endswith("]]"):
        return dumper.represent_scalar("tag:yaml.org,2002:str", data, style='"')
    return dumper.represent_scalar("tag:yaml.org,2002:str", data)


ObsidianDumper.add_representer(str, _str_representer)


def get_git_metadata() -> dict[str, str]:
    """Get metadata from git metadata command."""
    try:
        result = subprocess.run(
            ["git", "metadata"],
            capture_output=True,
            text=True,
            timeout=5,
        )
        if result.returncode != 0:
            return {}

        metadata = {}
        for line in result.stdout.strip().split("\n"):
            if ":" in line:
                key, value = line.split(":", 1)
                metadata[key.strip()] = value.strip()
        return metadata
    except (subprocess.TimeoutExpired, FileNotFoundError):
        return {}


def parse_frontmatter(content: str) -> tuple[dict, str]:
    """Parse YAML frontmatter from markdown content.

    Returns:
        Tuple of (frontmatter_dict, body_content)
    """
    match = FRONTMATTER_PATTERN.match(content)
    if match:
        try:
            frontmatter = yaml.safe_load(match.group(1))
            if not isinstance(frontmatter, dict):
                frontmatter = {}
            body = content[match.end() :]
            return frontmatter, body
        except yaml.YAMLError:
            return {}, content
    return {}, content


def build_frontmatter(existing: dict, git_metadata: dict) -> dict:
    """Build complete frontmatter by merging existing with git metadata."""
    today = date.today().isoformat()

    frontmatter = existing.copy()

    # Ensure tags include defaults
    existing_tags = frontmatter.get("tags", [])
    if isinstance(existing_tags, str):
        existing_tags = [existing_tags]
    merged_tags = list(dict.fromkeys(DEFAULT_TAGS + existing_tags))
    frontmatter["tags"] = merged_tags

    # Set Area from git metadata if not present
    if "Area" not in frontmatter and "Area" in git_metadata:
        frontmatter["Area"] = git_metadata["Area"]

    # Set Created if not present (Obsidian wiki-link format)
    if "Created" not in frontmatter:
        frontmatter["Created"] = f"[[{today}]]"

    # Always update Modified
    frontmatter["Modified"] = today

    # Disable AutoNoteMover for plans (they're already in the right place)
    if "AutoNoteMover" not in frontmatter:
        frontmatter["AutoNoteMover"] = "disable"

    return frontmatter


def serialize_frontmatter(frontmatter: dict) -> str:
    """Serialize frontmatter dict to YAML string with --- delimiters."""
    yaml_content = yaml.dump(
        frontmatter,
        Dumper=ObsidianDumper,
        default_flow_style=False,
        allow_unicode=True,
        sort_keys=False,
    )
    return f"---\n{yaml_content}---\n"


def ensure_frontmatter(content: str) -> str:
    """Ensure content has proper Obsidian frontmatter with metadata."""
    git_metadata = get_git_metadata()
    existing_fm, body = parse_frontmatter(content)
    updated_fm = build_frontmatter(existing_fm, git_metadata)
    return serialize_frontmatter(updated_fm) + body


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

    # Only process ExitPlanMode tool
    if input_data.get("tool_name") != "ExitPlanMode":
        sys.exit(0)

    # Get plan content and file path from tool_response
    tool_response = input_data.get("tool_response", {})
    file_path = tool_response.get("filePath", "")
    content = tool_response.get("plan", "")

    if not file_path or not content:
        sys.exit(0)

    file_path = Path(file_path)

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

    # Ensure proper frontmatter with metadata
    updated_content = ensure_frontmatter(content)

    # Write updated content to target location
    try:
        target_path.write_text(updated_content, encoding="utf-8")
    except OSError:
        sys.exit(0)

    # Remove original file and create symlink back
    try:
        file_path.unlink()
        file_path.symlink_to(target_path)
    except OSError:
        # If symlink fails, keep updated content in original location
        try:
            target_path.unlink()
            file_path.write_text(updated_content, encoding="utf-8")
        except OSError:
            pass
        sys.exit(0)


if __name__ == "__main__":
    main()
