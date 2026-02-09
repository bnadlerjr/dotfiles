#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = ["pyyaml"]
# ///

"""
Save an approved Claude plan as a vault artifact.

Two modes of operation:

1. **Hook mode** (no CLI args): UserPromptSubmit hook that detects plan-mode-to-
   normal transition. When plan mode exits and the user submits their first prompt
   in normal mode, this hook fires once to find the latest plan file and save it.
   The marker file is written by plan-mode-context.py during plan mode and consumed
   (deleted) here so the save fires exactly once.

2. **CLI mode** (plan file path as argument): Directly saves the given plan file
   as a vault artifact. Useful for manual runs or re-processing.

Usage:
    # CLI mode
    save-plan-artifact.py <plan-file-path>

    # Hook mode (called by Claude Code via stdin JSON)
    echo '{"permission_mode":"default"}' | save-plan-artifact.py
"""

import json
import os
import re
import subprocess
import sys
from datetime import date
from pathlib import Path

import yaml

MARKER_FILE = Path.home() / ".claude" / ".plan-mode-active"
PLANS_DIR = Path.home() / ".claude" / "plans"

PLAN_PREFIX_RE = re.compile(r"^(Implementation\s+)?Plan\s*[:—–-]\s*", re.IGNORECASE)
PLAN_SUFFIX_RE = re.compile(r"\s*[—–-]\s*(Implementation\s+)?Plan\s*$", re.IGNORECASE)
GIT_REMOTE_RE = re.compile(r"(?:git@github\.com:|https://github\.com/)(.+?)(?:\.git)?$")

FALLBACK_REMINDER = """<save-plan-artifact>
The plan from this session has not been saved as an artifact yet.
Before starting implementation, save the approved plan to
$CLAUDE_DOCS_ROOT/plans/plan--<slug>.md with full frontmatter
per CLAUDE.md artifact management rules. Look up the project in
projects.yaml. The plan content is in the plan file you just edited.
</save-plan-artifact>"""


def extract_slug(content):
    """Extract a kebab-case slug from the first markdown heading."""
    for line in content.splitlines():
        if line.startswith("# ") or line.startswith("## "):
            heading = line.lstrip("#").strip()
            heading = PLAN_PREFIX_RE.sub("", heading)
            heading = PLAN_SUFFIX_RE.sub("", heading)
            slug = heading.lower()
            slug = re.sub(r"[^a-z0-9]+", "-", slug)
            slug = re.sub(r"-{2,}", "-", slug)
            slug = slug.strip("-")
            return slug
    return None


def parse_git_remote(url):
    """Parse a git remote URL to org/repo format."""
    match = GIT_REMOTE_RE.match(url)
    if match:
        return match.group(1)
    return None


def lookup_project(projects_data, repo_slug):
    """Find the project matching a repo slug in projects.yaml data."""
    for slug, project in projects_data.get("projects", {}).items():
        repos = project.get("repositories", [])
        if repo_slug in repos:
            result = {"slug": slug, "name": project["name"], "area": project["area"]}
            if "jira_epic" in project:
                result["jira_epic"] = project["jira_epic"]
            if "repositories" in project:
                result["repositories"] = project["repositories"]
            return result
    return {"area": "One-off"}


def build_frontmatter(project, today):
    """Build YAML frontmatter string for a plan artifact."""
    today_str = today.isoformat()
    lines = ["---"]
    lines.append("tags: [claude-artifact, resource, plan]")

    area = project["area"]
    if isinstance(area, list):
        lines.append(f"Area: [{', '.join(area)}]")
    else:
        lines.append(f"Area: {area}")

    lines.append(f'Created: "[[{today_str}]]"')
    lines.append(f"Modified: {today_str}")
    lines.append("AutoNoteMover: disable")

    if "name" in project:
        lines.append(f'Project: "[[{project["name"]}]]"')
    if "slug" in project:
        lines.append(f"ProjectSlug: {project['slug']}")
    if "jira_epic" in project:
        lines.append(f"JiraEpic: {project['jira_epic']}")
    if "repositories" in project:
        lines.append(f"Repositories: {json.dumps(project['repositories'])}")

    lines.append("Status: Active")
    lines.append("---")
    return "\n".join(lines) + "\n"


def save_artifact(plan_path, dest_dir, project, today):
    """Save the plan as a vault artifact. Returns dict with result info."""
    content = Path(plan_path).read_text()
    slug = extract_slug(content)

    if slug is None:
        return {"saved": False, "reason": "No heading found in plan file"}

    dest_path = dest_dir / f"plan--{slug}.md"

    if dest_path.exists():
        return {"saved": False, "reason": "already exists", "path": dest_path}

    frontmatter = build_frontmatter(project, today)
    dest_path.write_text(frontmatter + "\n" + content)

    return {"saved": True, "path": dest_path}


def get_repo_slug():
    """Get org/repo from git remote origin in cwd."""
    try:
        result = subprocess.run(
            ["git", "remote", "get-url", "origin"],
            capture_output=True,
            text=True,
            check=True,
        )
        return parse_git_remote(result.stdout.strip())
    except (subprocess.CalledProcessError, FileNotFoundError):
        return None


def resolve_project():
    """Look up the current repo's project from projects.yaml."""
    docs_root = os.environ.get("CLAUDE_DOCS_ROOT")
    if not docs_root:
        return None, {"area": "One-off"}

    docs_root = Path(docs_root)
    projects_file = docs_root / "projects.yaml"
    repo_slug = get_repo_slug()
    project = {"area": "One-off"}

    if repo_slug and projects_file.exists():
        projects_data = yaml.safe_load(projects_file.read_text())
        if projects_data:
            project = lookup_project(projects_data, repo_slug)

    return docs_root, project


def save_and_report(plan_path):
    """Run the full save pipeline and print the result. Returns exit code."""
    docs_root, project = resolve_project()
    if docs_root is None:
        print("$CLAUDE_DOCS_ROOT is not set", file=sys.stderr)
        return 1

    dest_dir = docs_root / "plans"
    today = date.today()
    result = save_artifact(plan_path, dest_dir, project, today)

    if result["saved"]:
        project_label = project.get("name", "One-off")
        print(f"Saved: plans/{result['path'].name} ({project_label})")
        return 0
    elif result["reason"] == "already exists":
        print(f"Skipped: plans/{result['path'].name} (already exists)")
        return 0
    else:
        print(f"Error: {result['reason']}", file=sys.stderr)
        return 1


def find_latest_plan():
    """Find the most recently modified .md file in ~/.claude/plans/."""
    if not PLANS_DIR.exists():
        return None
    plans = sorted(
        PLANS_DIR.glob("*.md"), key=lambda p: p.stat().st_mtime, reverse=True
    )
    if plans:
        return plans[0]
    return None


def run_hook():
    """Hook entry point: read stdin JSON, check marker, save artifact."""
    try:
        input_data = json.load(sys.stdin)
    except json.JSONDecodeError:
        sys.exit(0)

    if input_data.get("permission_mode", "default") == "plan":
        sys.exit(0)

    if not MARKER_FILE.exists():
        sys.exit(0)

    try:
        MARKER_FILE.unlink()
    except OSError:
        pass

    plan_file = find_latest_plan()
    if not plan_file:
        print(FALLBACK_REMINDER)
        sys.exit(0)

    exit_code = save_and_report(plan_file)
    if exit_code != 0:
        print(FALLBACK_REMINDER)

    sys.exit(0)


def run_cli():
    """CLI entry point: accept plan file path as argument."""
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <plan-file-path>", file=sys.stderr)
        sys.exit(1)

    plan_path = Path(sys.argv[1])
    if not plan_path.exists():
        print(f"Plan file not found: {plan_path}", file=sys.stderr)
        sys.exit(1)

    sys.exit(save_and_report(plan_path))


if __name__ == "__main__":
    if len(sys.argv) > 1:
        run_cli()
    else:
        run_hook()
