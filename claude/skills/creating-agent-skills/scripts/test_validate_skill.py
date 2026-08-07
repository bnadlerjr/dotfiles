# /// script
# requires-python = ">=3.11"
# dependencies = ["pyyaml", "pytest"]
# ///
"""Tests for validate_skill.py.

Run: uv run scripts/test_validate_skill.py
"""

import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).parent))
# Importing validate_skill would otherwise leave a scripts/__pycache__/ directory in
# the skill, alongside the .pytest_cache/ suppressed at the bottom of this file.
sys.dont_write_bytecode = True

from validate_skill import has_errors, validate

MINIMAL_DESC = "Does a thing. Use when the user asks for the thing."


def make_skill(
    root, name="my-skill", frontmatter=None, body="# My Skill\n", files=None
):
    """Build a skill directory and return its path.

    frontmatter: dict merged over {name, description}. A value of None drops the key.
        Values are emitted as raw YAML, so quote them ('"1.0"') when the test needs
        a specific YAML type rather than whatever the scalar would infer.
    files: {relative_path: contents} written alongside SKILL.md.
    """
    fields = {"name": name, "description": MINIMAL_DESC}
    fields.update(frontmatter or {})

    lines = []
    for key, value in fields.items():
        if value is None:
            continue
        if isinstance(value, dict):
            lines.append(f"{key}:")
            lines.extend(f"  {k}: {v}" for k, v in value.items())
        elif isinstance(value, list):
            lines.append(f"{key}:")
            lines.extend(f"  - {item}" for item in value)
        else:
            lines.append(f"{key}: {value}")

    skill_dir = root / name
    skill_dir.mkdir(parents=True, exist_ok=True)
    (skill_dir / "SKILL.md").write_text("---\n" + "\n".join(lines) + "\n---\n\n" + body)

    for rel, contents in (files or {}).items():
        target = skill_dir / rel
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(contents)

    return skill_dir


def errors(problems):
    return {p.code for p in problems if p.level == "error"}


def warnings(problems):
    return {p.code for p in problems if p.level == "warning"}


# --- baseline ------------------------------------------------------------


def test_minimal_valid_skill_has_no_problems(tmp_path):
    assert validate(make_skill(tmp_path)) == []


def test_all_optional_spec_fields_are_accepted(tmp_path):
    skill = make_skill(
        tmp_path,
        frontmatter={
            "license": "Apache-2.0",
            "compatibility": "Requires git and jq",
            "metadata": {"author": "example-org", "version": '"1.0"'},
            "allowed-tools": "Read Grep Bash(git:*)",
        },
    )
    assert validate(skill) == []


def test_missing_skill_md_is_an_error(tmp_path):
    empty = tmp_path / "empty-skill"
    empty.mkdir()
    assert "E001" in errors(validate(empty))


def test_missing_frontmatter_is_an_error(tmp_path):
    skill = tmp_path / "no-frontmatter"
    skill.mkdir()
    (skill / "SKILL.md").write_text("# Just a heading\n")
    assert "E002" in errors(validate(skill))


# --- name ----------------------------------------------------------------


def test_missing_name_is_an_error(tmp_path):
    # The spec makes name required; an omitted name is not "defaults to the directory".
    skill = make_skill(tmp_path, frontmatter={"name": None})
    assert "E010" in errors(validate(skill))


@pytest.mark.parametrize(
    "bad_name",
    [
        "PDF-Processing",
        "-pdf",
        "pdf-",
        "pdf--processing",
        "pdf_processing",
        "pdf processing",
    ],
)
def test_malformed_names_are_errors(tmp_path, bad_name):
    skill = make_skill(tmp_path, name="placeholder", frontmatter={"name": bad_name})
    assert "E011" in errors(validate(skill))


def test_name_over_64_characters_is_an_error(tmp_path):
    skill = make_skill(tmp_path, name="placeholder", frontmatter={"name": "a" * 65})
    assert "E012" in errors(validate(skill))


def test_name_must_match_parent_directory(tmp_path):
    skill = make_skill(tmp_path, name="my-skill", frontmatter={"name": "other-skill"})
    assert "E013" in errors(validate(skill))


# --- description ---------------------------------------------------------


def test_missing_description_is_an_error(tmp_path):
    skill = make_skill(tmp_path, frontmatter={"description": None})
    assert "E020" in errors(validate(skill))


def test_empty_description_is_an_error(tmp_path):
    skill = make_skill(tmp_path, frontmatter={"description": '""'})
    assert "E021" in errors(validate(skill))


def test_description_over_1024_characters_is_an_error(tmp_path):
    # 1024 is a hard spec limit, not Claude Code's 1,536-char listing truncation.
    skill = make_skill(tmp_path, frontmatter={"description": "x" * 1025})
    assert "E022" in errors(validate(skill))


def test_description_of_exactly_1024_characters_is_allowed(tmp_path):
    skill = make_skill(tmp_path, frontmatter={"description": "x" * 1024})
    assert "E022" not in errors(validate(skill))


# --- compatibility / metadata / allowed-tools ----------------------------


def test_compatibility_over_500_characters_is_an_error(tmp_path):
    skill = make_skill(tmp_path, frontmatter={"compatibility": "x" * 501})
    assert "E030" in errors(validate(skill))


def test_metadata_with_non_string_values_is_an_error(tmp_path):
    skill = make_skill(tmp_path, frontmatter={"metadata": {"version": "1.0"}})
    # Unquoted 1.0 parses as a float; the spec requires a string-to-string map.
    assert "E031" in errors(validate(skill))


def test_allowed_tools_as_a_yaml_list_warns(tmp_path):
    skill = make_skill(tmp_path, frontmatter={"allowed-tools": ["Read", "Grep"]})
    assert "W040" in warnings(validate(skill))


def test_non_standard_frontmatter_field_warns_about_portability(tmp_path):
    skill = make_skill(tmp_path, frontmatter={"when_to_use": "extra triggers"})
    problems = validate(skill)
    assert "W041" in warnings(problems)
    assert errors(problems) == set()


def test_disable_model_invocation_warns_separately_from_ignored_fields(tmp_path):
    # Non-spec, but honoured natively by Claude Code and Pi and via a sidecar by
    # Codex, so it must not be reported as a field other agents ignore.
    skill = make_skill(tmp_path, frontmatter={"disable-model-invocation": "true"})
    problems = validate(skill)
    assert "W042" in warnings(problems)
    assert "W041" not in warnings(problems)


# --- body size -----------------------------------------------------------


def test_body_budget_excludes_frontmatter(tmp_path):
    # 498 body lines plus 5 of frontmatter is over the limit as a file and under
    # it as a body; the spec budgets the body.
    skill = make_skill(tmp_path, body="# My Skill\n" + "filler\n" * 497)
    assert "W050" not in warnings(validate(skill))


def test_skill_md_over_500_lines_warns(tmp_path):
    skill = make_skill(tmp_path, body="# My Skill\n" + "filler\n" * 600)
    assert "W050" in warnings(validate(skill))


def test_skill_md_over_5000_tokens_warns(tmp_path):
    skill = make_skill(tmp_path, body="# My Skill\n" + ("word " * 12000))
    assert "W051" in warnings(validate(skill))


# --- links and reachability ----------------------------------------------


def test_broken_relative_link_is_an_error(tmp_path):
    skill = make_skill(tmp_path, body="# My Skill\n\nSee [gone](references/gone.md).\n")
    assert "E060" in errors(validate(skill))


def test_router_pattern_two_hops_is_allowed(tmp_path):
    # SKILL.md -> workflows/build.md -> references/api.md is the router pattern
    # this skill teaches, and must not be flagged.
    skill = make_skill(
        tmp_path,
        body="# My Skill\n\nRun [build](workflows/build.md).\n",
        files={
            "workflows/build.md": "# Build\n\nRead [api](../references/api.md).\n",
            "references/api.md": "# API\n",
        },
    )
    problems = validate(skill)
    assert errors(problems) == set()
    assert "W061" not in warnings(problems)


def test_chain_deeper_than_two_hops_warns(tmp_path):
    skill = make_skill(
        tmp_path,
        body="# My Skill\n\nSee [a](references/a.md).\n",
        files={
            "references/a.md": "# A\n\nSee [b](b.md).\n",
            "references/b.md": "# B\n\nSee [c](c.md).\n",
            "references/c.md": "# C\n",
        },
    )
    assert "W061" in warnings(validate(skill))


def test_file_unreachable_from_skill_md_warns_as_orphan(tmp_path):
    skill = make_skill(
        tmp_path,
        body="# My Skill\n",
        files={"workflows/orphan.md": "# Orphan\n"},
    )
    problems = validate(skill)
    assert "W070" in warnings(problems)
    assert any("workflows/orphan.md" in p.message for p in problems)


def test_script_referenced_only_in_a_code_block_is_not_an_orphan(tmp_path):
    skill = make_skill(
        tmp_path,
        body="# My Skill\n\nRun it:\n\n```bash\nuv run scripts/go.py --check\n```\n",
        files={"scripts/go.py": "print('hi')\n"},
    )
    assert "W070" not in warnings(validate(skill))


def test_relative_path_still_checks_against_the_real_directory_name(
    tmp_path, monkeypatch
):
    # validate(".") must resolve before comparing name to the parent directory,
    # otherwise Path(".").name is "" and every skill fails E013.
    make_skill(tmp_path)
    monkeypatch.chdir(tmp_path / "my-skill")
    assert "E013" not in errors(validate(Path(".")))


def test_placeholder_links_are_not_reported_as_broken(tmp_path):
    # Template files under assets/ legitimately contain unresolved {{placeholders}}.
    skill = make_skill(
        tmp_path,
        body="# My Skill\n\nCopy [the template](assets/tpl.md).\n",
        files={"assets/tpl.md": "# Template\n\nSee [wf](workflows/{{name}}.md).\n"},
    )
    assert "E060" not in errors(validate(skill))


def test_file_reachable_only_through_a_workflow_is_not_an_orphan(tmp_path):
    skill = make_skill(
        tmp_path,
        body="# My Skill\n\nRun [build](workflows/build.md).\n",
        files={
            "workflows/build.md": "# Build\n\nCopy [template](../assets/tpl.md).\n",
            "assets/tpl.md": "# Template\n",
        },
    )
    assert "W070" not in warnings(validate(skill))


# --- exit behaviour ------------------------------------------------------


def test_warnings_alone_do_not_make_the_skill_invalid(tmp_path):
    skill = make_skill(tmp_path, files={"workflows/orphan.md": "# Orphan\n"})
    problems = validate(skill)
    assert warnings(problems)
    assert not has_errors(problems)


def test_errors_make_the_skill_invalid(tmp_path):
    skill = make_skill(tmp_path, name="my-skill", frontmatter={"name": "mismatch"})
    assert has_errors(validate(skill))


if __name__ == "__main__":
    # no:cacheprovider keeps pytest from writing .pytest_cache/ into the skill, where
    # it would show up in every `ls -R` an agent runs against it.
    raise SystemExit(pytest.main([__file__, "-q", "-p", "no:cacheprovider"]))
