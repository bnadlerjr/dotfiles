# /// script
# requires-python = ">=3.11"
# dependencies = ["pyyaml"]
# ///
"""Validate a skill directory against the Agent Skills specification.

Checks every mechanical rule in references/agent-skills-spec.md, plus the
structural rules this skill teaches (progressive disclosure, reachability).

Usage:
  uv run scripts/validate_skill.py SKILL_DIR [SKILL_DIR ...]

Options:
  --format {text,json}   Output format (default: text)
  -h, --help             Show this message

Exit codes:
  0  no errors (warnings may still be reported)
  1  at least one error
  2  usage error
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from dataclasses import asdict, dataclass
from pathlib import Path

import yaml

SPEC_FIELDS = {
    "name",
    "description",
    "license",
    "compatibility",
    "metadata",
    "allowed-tools",
}

# Non-spec, but honoured natively by Claude Code and Pi and via a sidecar by Codex,
# so it does not carry the usual "other agents ignore this" caveat.
BROADLY_SUPPORTED_FIELDS = {"disable-model-invocation"}

NAME_PATTERN = re.compile(r"^[a-z0-9]+(-[a-z0-9]+)*$")
NAME_MAX = 64
DESCRIPTION_MAX = 1024
COMPATIBILITY_MAX = 500
BODY_MAX_LINES = 500
BODY_MAX_TOKENS = 5000
MAX_REFERENCE_DEPTH = 2

FRONTMATTER_PATTERN = re.compile(r"\A---\s*\n(.*?)\n---\s*\n", re.DOTALL)
MD_LINK_PATTERN = re.compile(r"\[[^\]]*\]\(([^)\s]+)")
FENCE_OPEN_PATTERN = re.compile(r"^\s*(`{3,})")
FENCE_CLOSE_PATTERN = re.compile(r"^\s*(`{3,})\s*$")

SKIP_DIR_NAMES = {"__pycache__", ".git", "node_modules"}
TEXT_SUFFIXES = {".md", ".py", ".sh", ".js", ".ts", ".txt", ".yaml", ".yml", ".json"}


@dataclass(frozen=True)
class Problem:
    level: str  # "error" | "warning"
    code: str
    message: str


def error(code: str, message: str) -> Problem:
    return Problem("error", code, message)


def warning(code: str, message: str) -> Problem:
    return Problem("warning", code, message)


def has_errors(problems: list[Problem]) -> bool:
    return any(p.level == "error" for p in problems)


def strip_code_fences(text: str) -> str:
    """Blank out fenced code blocks so examples are not read as real links."""
    out: list[str] = []
    fence_len = 0
    for line in text.splitlines():
        if fence_len:
            close = FENCE_CLOSE_PATTERN.match(line)
            if close and len(close.group(1)) >= fence_len:
                fence_len = 0
            out.append("")
            continue
        open_ = FENCE_OPEN_PATTERN.match(line)
        if open_:
            fence_len = len(open_.group(1))
            out.append("")
            continue
        out.append(line)
    return "\n".join(out)


def md_links(text: str) -> list[str]:
    """Local markdown link targets, excluding URLs and bare anchors."""
    targets = []
    for raw in MD_LINK_PATTERN.findall(strip_code_fences(text)):
        target = raw.split("#", 1)[0].strip()
        if not target or "://" in target or target.startswith("mailto:"):
            continue
        # Templates legitimately carry unresolved {{placeholders}}; they are not links.
        if "{{" in target or "}}" in target:
            continue
        targets.append(target)
    return targets


def skill_files(skill_dir: Path) -> list[Path]:
    """Every bundled file except SKILL.md, as paths relative to the skill root."""
    found = []
    for path in sorted(skill_dir.rglob("*")):
        if not path.is_file():
            continue
        rel = path.relative_to(skill_dir)
        if rel == Path("SKILL.md"):
            continue
        if any(part.startswith(".") or part in SKIP_DIR_NAMES for part in rel.parts):
            continue
        found.append(rel)
    return found


def mentions(text: str, source: Path, target: Path) -> bool:
    """True if `text` (from `source`) names `target` by any relative spelling.

    Matches markdown links and bare paths in code blocks alike, so a script
    invoked only inside a fenced example still counts as referenced.
    """
    forms = {
        target.as_posix(),
        Path(*[".."] * len(source.parent.parts), target).as_posix(),
    }
    if source.parent == target.parent:
        forms.add(target.name)
    return any(re.search(r"(?<![\w./-])" + re.escape(form), text) for form in forms)


def check_frontmatter(data: dict, skill_dir: Path) -> list[Problem]:
    problems: list[Problem] = []

    name = data.get("name")
    if name is None:
        problems.append(
            error(
                "E010",
                "`name` is required by the spec (it does not default to the directory name)",
            )
        )
    else:
        name = str(name)
        if len(name) > NAME_MAX:
            problems.append(
                error(
                    "E012",
                    f"`name` is {len(name)} characters; the maximum is {NAME_MAX}",
                )
            )
        if not NAME_PATTERN.match(name):
            problems.append(
                error(
                    "E011",
                    f"`name` {name!r} must be lowercase letters, numbers and single hyphens, "
                    "and must not start or end with a hyphen",
                )
            )
        if name != skill_dir.name:
            problems.append(
                error(
                    "E013",
                    f"`name` {name!r} must match the parent directory name {skill_dir.name!r}",
                )
            )

    if data.get("description") is None:
        problems.append(error("E020", "`description` is required by the spec"))
    else:
        description = str(data["description"])
        if not description.strip():
            problems.append(error("E021", "`description` must be non-empty"))
        elif len(description) > DESCRIPTION_MAX:
            problems.append(
                error(
                    "E022",
                    f"`description` is {len(description)} characters; the spec maximum is "
                    f"{DESCRIPTION_MAX} (Claude Code's 1,536-char listing truncation is a "
                    "display behaviour, not the limit)",
                )
            )

    compatibility = data.get("compatibility")
    if compatibility is not None:
        length = len(str(compatibility))
        if length > COMPATIBILITY_MAX:
            problems.append(
                error(
                    "E030",
                    f"`compatibility` is {length} characters; "
                    f"the maximum is {COMPATIBILITY_MAX}",
                )
            )

    metadata = data.get("metadata")
    if metadata is not None and (
        not isinstance(metadata, dict)
        or not all(
            isinstance(k, str) and isinstance(v, str) for k, v in metadata.items()
        )
    ):
        problems.append(
            error(
                "E031",
                "`metadata` must be a map of string keys to string values (quote numbers)",
            )
        )

    if isinstance(data.get("allowed-tools"), list):
        problems.append(
            warning(
                "W040",
                "`allowed-tools` is a YAML list; the spec defines a space-separated string. "
                "Some clients accept a list, so this limits portability",
            )
        )

    for field in sorted(set(data) - SPEC_FIELDS):
        if field in BROADLY_SUPPORTED_FIELDS:
            problems.append(
                warning(
                    "W042",
                    f"`{field}` is not an Agent Skills field, but is broadly supported — "
                    "check the matrix in references/claude-code-extensions.md before "
                    "treating this as a portability problem",
                )
            )
            continue
        problems.append(
            warning(
                "W041",
                f"`{field}` is not an Agent Skills field; support varies by client and may "
                "be absent entirely. See references/claude-code-extensions.md",
            )
        )

    return problems


def check_body(body: str) -> list[Problem]:
    """Check the markdown body only — the spec budgets body content, not frontmatter."""
    problems: list[Problem] = []
    line_count = len(body.splitlines())
    if line_count > BODY_MAX_LINES:
        problems.append(
            warning(
                "W050",
                f"SKILL.md is {line_count} lines; keep it under {BODY_MAX_LINES}",
            )
        )
    # Four characters per token is the usual rough estimate for English prose.
    tokens = len(body) // 4
    if tokens > BODY_MAX_TOKENS:
        problems.append(
            warning(
                "W051",
                f"SKILL.md is roughly {tokens} tokens; keep it under {BODY_MAX_TOKENS}",
            )
        )
    return problems


def check_links_and_reachability(skill_dir: Path) -> list[Problem]:
    problems: list[Problem] = []
    candidates = skill_files(skill_dir)
    texts: dict[Path, str] = {}

    for rel in [Path("SKILL.md"), *candidates]:
        if rel.suffix in TEXT_SUFFIXES:
            path = skill_dir / rel
            texts[rel] = path.read_text(encoding="utf-8", errors="replace")

    for rel, text in texts.items():
        if rel.suffix != ".md":
            continue
        for target in md_links(text):
            resolved = (skill_dir / rel).parent / target
            if not resolved.exists():
                problems.append(
                    error("E060", f"{rel.as_posix()} links to missing file {target!r}")
                )

    # Breadth-first from SKILL.md, so depth[rel] is the shortest hop count and a
    # file reachable by both a short and a long chain is judged by the short one.
    depth: dict[Path, int] = {Path("SKILL.md"): 0}
    frontier = [Path("SKILL.md")]
    while frontier:
        source = frontier.pop(0)
        text = texts.get(source, "")
        for target in candidates:
            if target in depth or not mentions(text, source, target):
                continue
            depth[target] = depth[source] + 1
            frontier.append(target)

    for rel in candidates:
        if rel not in depth:
            problems.append(
                warning(
                    "W070",
                    f"{rel.as_posix()} is unreachable from SKILL.md — nothing references it",
                )
            )
        elif depth[rel] > MAX_REFERENCE_DEPTH:
            problems.append(
                warning(
                    "W061",
                    f"{rel.as_posix()} is {depth[rel]} hops from SKILL.md; keep chains within "
                    f"{MAX_REFERENCE_DEPTH} so agents reliably reach it",
                )
            )

    return problems


def validate(skill_dir: Path) -> list[Problem]:
    """Return every spec and structural problem found in `skill_dir`."""
    # Resolve so a relative path like "." still compares against the real directory name.
    skill_dir = Path(skill_dir).resolve()
    skill_md = skill_dir / "SKILL.md"
    if not skill_md.is_file():
        return [
            error("E001", f"{skill_dir}/SKILL.md not found; every skill requires one")
        ]

    text = skill_md.read_text(encoding="utf-8")
    match = FRONTMATTER_PATTERN.match(text)
    if not match:
        return [
            error("E002", "SKILL.md must open with YAML frontmatter delimited by ---")
        ]

    try:
        data = yaml.safe_load(match.group(1))
    except yaml.YAMLError as exc:
        return [error("E002", f"frontmatter is not valid YAML: {exc}")]

    if not isinstance(data, dict):
        return [error("E002", "frontmatter must be a YAML mapping")]

    return [
        *check_frontmatter(data, skill_dir),
        *check_body(text[match.end() :]),
        *check_links_and_reachability(skill_dir),
    ]


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        prog="validate_skill.py",
        description="Validate skill directories against the Agent Skills specification.",
        epilog="Exit codes: 0 no errors, 1 errors found, 2 usage error.",
    )
    parser.add_argument(
        "skill_dir", nargs="+", type=Path, help="skill directory to validate"
    )
    parser.add_argument(
        "--format", choices=("text", "json"), default="text", help="output format"
    )
    args = parser.parse_args(argv)

    results = {d: validate(d) for d in args.skill_dir}
    failed = sum(1 for problems in results.values() if has_errors(problems))

    if args.format == "json":
        print(
            json.dumps(
                {
                    str(d): [asdict(p) for p in problems]
                    for d, problems in results.items()
                },
                indent=2,
            )
        )
    else:
        for skill, problems in results.items():
            if not problems:
                print(f"{skill}: OK")
                continue
            for problem in problems:
                print(
                    f"{skill}: {problem.level.upper():7} {problem.code} {problem.message}"
                )

    total = sum(len(problems) for problems in results.values())
    print(
        f"{len(results)} skill(s) checked, {failed} with errors, {total} problem(s) total",
        file=sys.stderr,
    )
    return 1 if failed else 0


if __name__ == "__main__":
    raise SystemExit(main())
