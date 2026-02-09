#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///

"""
Archive completed Claude artifacts.

Scans $CLAUDE_DOCS_ROOT/{plans,research,handoffs}/ for markdown files with
Status: Complete and Created date older than 30 days. Updates status to
Archived, sets Modified to today, and moves the file to archived/.
"""

import os
import re
import shutil
from datetime import date, timedelta
from pathlib import Path

FRONTMATTER_RE = re.compile(r"^---\n(.*?)\n---", re.DOTALL)
STATUS_RE = re.compile(r"^Status:\s*Complete\s*$", re.MULTILINE)
CREATED_RE = re.compile(r'Created:\s*"\[\[(\d{4}-\d{2}-\d{2})\]\]"')
MODIFIED_RE = re.compile(r"^Modified:\s*\d{4}-\d{2}-\d{2}\s*$", re.MULTILINE)

SCAN_DIRS = ("plans", "research", "handoffs")
ARCHIVE_DIR = "archived"
AGE_THRESHOLD_DAYS = 30


def resolve_root() -> Path:
    env = os.environ.get("CLAUDE_DOCS_ROOT")
    if env:
        return Path(env).expanduser()
    return Path.home() / "Dropbox" / "vimwiki" / "claude-artifacts"


def is_eligible(content: str, cutoff: date) -> bool:
    fm_match = FRONTMATTER_RE.match(content)
    if not fm_match:
        return False

    frontmatter = fm_match.group(1)

    if not STATUS_RE.search(frontmatter):
        return False

    created_match = CREATED_RE.search(frontmatter)
    if not created_match:
        return False

    created_date = date.fromisoformat(created_match.group(1))
    return created_date <= cutoff


def update_frontmatter(content: str, today: str) -> str:
    content = STATUS_RE.sub("Status: Archived", content)
    content = MODIFIED_RE.sub(f"Modified: {today}", content)
    return content


def main() -> None:
    root = resolve_root()
    assert root.is_dir(), f"Artifact root does not exist: {root}"

    archived_dir = root / ARCHIVE_DIR
    archived_dir.mkdir(exist_ok=True)

    today = date.today()
    cutoff = today - timedelta(days=AGE_THRESHOLD_DAYS)
    today_str = today.isoformat()

    archived: list[str] = []

    for subdir in SCAN_DIRS:
        scan_path = root / subdir
        if not scan_path.is_dir():
            continue

        for md_file in sorted(scan_path.glob("*.md")):
            content = md_file.read_text()

            if not is_eligible(content, cutoff):
                continue

            updated = update_frontmatter(content, today_str)
            md_file.write_text(updated)

            dest = archived_dir / md_file.name
            shutil.move(str(md_file), str(dest))
            archived.append(f"  {subdir}/{md_file.name}")

    if archived:
        print(f"Archived {len(archived)} artifact(s):")
        print("\n".join(archived))
    else:
        print("No artifacts to archive.")


if __name__ == "__main__":
    main()
