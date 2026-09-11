"""Focused tests for the validate-commit-message CLI.

Run with: uv run --with pytest pytest bin/validate_commit_message_test.py
"""

import importlib.util
import json
import subprocess
from importlib.machinery import SourceFileLoader
from pathlib import Path

import pytest

CLI = Path(__file__).parent / "validate-commit-message"
EVAL_RUNNER = Path(__file__).parent / "validate_commit_message_evals.py"


def test_cli_exists():
    assert CLI.exists(), "validate-commit-message has not been implemented"


def load_eval_runner():
    assert EVAL_RUNNER.exists(), "semantic eval runner has not been implemented"
    spec = importlib.util.spec_from_file_location(
        "validate_commit_message_evals", EVAL_RUNNER
    )
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def test_eval_comparison_ignores_explanatory_prose():
    runner = load_eval_runner()
    expected = {
        "valid": False,
        "body_warranted": True,
        "sentences": [{"text": "Changed it.", "category": "WHAT"}],
        "references": [],
    }
    actual = {**expected, "reasons": ["wording may vary"]}

    assert runner.compare(actual, expected) == []


def load_validator():
    if not CLI.exists():
        pytest.skip("validate-commit-message has not been implemented")
    spec = importlib.util.spec_from_file_location(
        "validate_commit_message",
        CLI,
        loader=SourceFileLoader("validate_commit_message", str(CLI)),
    )
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


@pytest.fixture
def validator():
    return load_validator()


def git(repo, *args):
    return subprocess.run(
        ["git", *args], cwd=repo, text=True, capture_output=True, check=True
    ).stdout


def repo_with_staged_file(tmp_path, content="new\n"):
    git(tmp_path, "init", "-q")
    git(tmp_path, "config", "user.email", "test@example.com")
    git(tmp_path, "config", "user.name", "Test User")
    source = tmp_path / "app.py"
    source.write_text(content)
    git(tmp_path, "add", "app.py")
    return source


def test_comments_are_removed_before_validation(validator):
    assert validator.clean_message(
        "Fix cleanup\n\nWhy it matters.\n# editor help\n"
    ) == ("Fix cleanup\n\nWhy it matters.")


def test_format_checks_and_long_subject_warning(validator):
    violations, warnings = validator.check_format("fix cleanup.\nBody without gap")

    assert "subject must start with a capital letter" in violations
    assert "subject must not end with a period" in violations
    assert "body must be separated from subject by a blank line" in violations
    assert warnings == []

    subject = "A" * 51
    assert validator.check_format(subject) == (
        [],
        ["subject is 51 characters; aim for 50 or fewer"],
    )

    violations, _warnings = validator.check_format("A" * 73)
    assert "subject exceeds 72 characters" in violations


def test_urls_are_not_treated_as_file_paths(validator):
    violations, _warnings = validator.check_format(
        "Explain external requirement\n\nSee https://example.com/issues/19."
    )

    assert not any("path" in violation for violation in violations)


def test_unambiguous_paths_and_line_locations_are_rejected(validator):
    violations, _warnings = validator.check_format(
        "Explain /tmp/result\n\nSee src/jobs.py:42 and line 19."
    )

    assert "message contains path '/tmp/result'" in violations
    assert "message contains path or line reference 'src/jobs.py:42'" in violations
    assert "message contains path 'src/jobs.py'" not in violations
    assert "message contains line reference 'line 19'" in violations


@pytest.mark.parametrize(
    "subject",
    [
        "Merge branch 'main'",
        'Revert "Add cache"',
        "fixup! Add cache",
        "squash! Add cache",
    ],
)
def test_git_generated_subjects_are_recognized(validator, subject):
    assert validator.is_generated(subject)


def test_trailers_are_split_from_semantic_body(validator):
    parsed = validator.parse_message(
        "Reject reused tokens\n\n"
        "Tokens are single-use.\n\n"
        "Fixes #123\n"
        "Signed-off-by: Dev <dev@example.com>\n"
    )

    assert parsed.body == "Tokens are single-use."
    assert parsed.trailers == ("Fixes #123", "Signed-off-by: Dev <dev@example.com>")


def test_ai_identity_trailer_is_a_violation(validator):
    violations, _warnings = validator.check_format(
        "Improve cleanup\n\nCo-authored-by: Claude <bot@example.com>"
    )

    assert "AI attribution is not allowed" in violations


def test_context_uses_staged_content_not_worktree_content(tmp_path, validator):
    source = repo_with_staged_file(tmp_path, "staged\n")
    source.write_text("unstaged\n")

    context = validator.collect_context(tmp_path)

    assert "staged" in context.files["app.py"]
    assert "unstaged" not in context.files["app.py"]
    assert "+staged" in context.diff


def test_empty_staged_diff_is_an_unsupported_context(tmp_path, validator):
    git(tmp_path, "init", "-q")

    with pytest.raises(validator.OperationalError, match="no staged changes"):
        validator.collect_context(tmp_path)


def test_oversized_indexed_file_fails_closed(tmp_path, validator, monkeypatch):
    repo_with_staged_file(tmp_path, "four")
    monkeypatch.setattr(validator, "MAX_FILE_CHARS", 3)

    with pytest.raises(validator.OperationalError, match="app.py.*3 characters"):
        validator.collect_context(tmp_path)


def test_binary_files_are_skipped(tmp_path, validator):
    repo_with_staged_file(tmp_path, "text\n")
    binary = tmp_path / "image.bin"
    binary.write_bytes(b"\x00\xff")
    git(tmp_path, "add", "image.bin")

    context = validator.collect_context(tmp_path)

    assert "app.py" in context.files
    assert "image.bin" not in context.files


def test_claude_timeout_is_an_operational_error(validator, monkeypatch):
    def timeout(*args, **kwargs):
        raise subprocess.TimeoutExpired("claude", 60)

    monkeypatch.setattr(validator.subprocess, "run", timeout)

    with pytest.raises(validator.OperationalError, match="timed out after 60 seconds"):
        validator.invoke_claude("prompt")


def test_structured_claude_output_is_required(validator):
    expected = {
        "valid": True,
        "body_warranted": False,
        "sentences": [],
        "references": [],
        "reasons": [],
    }
    assert (
        validator.parse_claude_output(json.dumps({"structured_output": expected}))
        == expected
    )

    with pytest.raises(validator.OperationalError, match="structured output"):
        validator.parse_claude_output(json.dumps({"result": "looks good"}))


def test_warning_free_generated_success_is_silent(tmp_path):
    message = tmp_path / "COMMIT_EDITMSG"
    message.write_text("fixup! Add cache\n")

    result = subprocess.run(
        [str(CLI), str(message)], capture_output=True, text=True, check=False
    )

    assert result.returncode == 0
    assert result.stdout == ""
    assert result.stderr == ""


def test_semantic_reasons_become_violations(tmp_path, validator, monkeypatch):
    message = tmp_path / "COMMIT_EDITMSG"
    message.write_text("Improve cleanup\n\nUpdate the cleanup loop.\n")
    context = validator.Context("diff", {"app.py": "code"})
    monkeypatch.setattr(validator, "collect_context", lambda cwd: context)
    monkeypatch.setattr(
        validator,
        "invoke_claude",
        lambda prompt: {
            "valid": False,
            "body_warranted": False,
            "sentences": [{"text": "Update the cleanup loop.", "category": "WHAT"}],
            "references": [],
            "reasons": ["body sentence restates the diff"],
        },
    )

    violations, warnings = validator.validate(message, tmp_path)

    assert violations == ["body sentence restates the diff"]
    assert warnings == []


def test_generated_message_skips_git_and_claude(tmp_path, validator, monkeypatch):
    message = tmp_path / "COMMIT_EDITMSG"
    message.write_text("fixup! Add cache\n")
    monkeypatch.setattr(
        validator,
        "collect_context",
        lambda cwd: pytest.fail("generated message collected Git context"),
    )

    assert validator.validate(message, tmp_path) == ([], [])


def test_main_uses_distinct_exit_codes_and_stderr(
    tmp_path, validator, monkeypatch, capsys
):
    message = tmp_path / "COMMIT_EDITMSG"
    message.write_text("Fix cleanup\n")

    monkeypatch.setattr(validator, "validate", lambda *args, **kwargs: ([], []))
    assert validator.main([str(message)]) == 0
    assert capsys.readouterr().err == ""

    monkeypatch.setattr(
        validator, "validate", lambda *args, **kwargs: (["body repeats the diff"], [])
    )
    assert validator.main([str(message)]) == 1
    assert "body repeats the diff" in capsys.readouterr().err

    def fail(*args, **kwargs):
        raise validator.OperationalError("Claude failed")

    monkeypatch.setattr(validator, "validate", fail)
    assert validator.main([str(message)]) == 2
    assert "Claude failed" in capsys.readouterr().err
