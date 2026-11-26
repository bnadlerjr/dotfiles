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


def test_eval_comparison_checks_only_sentence_classifications():
    runner = load_eval_runner()
    expected = {"sentences": [{"text": "Changed it.", "category": "WHAT"}]}
    actual = {**expected, "ignored": "extra classifier prose"}

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


def test_verbose_diff_after_scissors_is_removed_before_validation(validator):
    text = (
        "Add Jira snippet\n\n"
        "# ------------------------ >8 ------------------------\n"
        "diff --git a/alfred/snippet.json b/alfred/snippet.json\n"
        "--- /dev/null\n"
        "+++ b/alfred/snippet.json\n"
    )

    assert validator.clean_message(text) == "Add Jira snippet"
    assert validator.check_format(text) == ([], [])


def test_format_checks_and_long_subject_warning(validator):
    violations, warnings = validator.check_format("fix cleanup.\nBody without gap")

    assert "subject must start with a capital letter" in violations
    assert "subject must not end with a period" in violations
    assert "body must be separated from subject by a blank line" in violations
    assert warnings == []

    subject = "Fix " + "A" * 47
    assert validator.check_format(subject) == (
        [],
        ["subject is 51 characters; aim for 50 or fewer"],
    )

    violations, _warnings = validator.check_format("Fix " + "A" * 69)
    assert "subject exceeds 72 characters" in violations


@pytest.mark.parametrize(
    "subject",
    [
        "POPS-123 Fix timeout",
        "POPS-123: Fix timeout",
        "[POPS-123] Fix timeout",
        "#123 Fix timeout",
    ],
)
def test_issue_id_prefix_is_allowed(validator, subject):
    assert validator.check_format(subject) == ([], [])


def test_body_sentences_are_split_deterministically(validator):
    body = (
        "The first reason wraps across\n"
        "two lines. The second stands alone.\n\n"
        "Based on findings from:\n"
        "https://example.com/research"
    )

    assert validator.body_sentences(body) == [
        "The first reason wraps across two lines.",
        "The second stands alone.",
        "Based on findings from: https://example.com/research",
    ]


def test_body_sentence_boundaries_handle_quotes_and_abbreviations(validator):
    body = (
        'The constraint is external." Update the retry loop. '
        "Editors such as VS Code, e.g. local runs, need the same behavior. "
        "Retries cover network failures, etc. Update the timeout too. "
        "U.S. servers use the same limit."
    )

    assert validator.body_sentences(body) == [
        'The constraint is external."',
        "Update the retry loop.",
        "Editors such as VS Code, e.g. local runs, need the same behavior.",
        "Retries cover network failures, etc.",
        "Update the timeout too.",
        "U.S. servers use the same limit.",
    ]


def test_classifier_prompt_contains_only_sentences_and_staged_context(validator):
    message = validator.Message(
        "POPS-123 Fix timeout", "Reason one. Reason two.", ()
    )
    context = validator.Context("diff", {"app.py": "code"})

    prompt = validator.build_prompt(message, context)
    payload = json.loads(prompt[len(validator.CLASSIFIER_INSTRUCTIONS) :])

    assert payload == {
        "body_sentences": ["Reason one.", "Reason two."],
        "staged_diff": "diff",
        "indexed_files": {"app.py": "code"},
    }


@pytest.mark.parametrize(
    "subject",
    [
        "POPS-123 fix timeout",
        "POPS-123: fix timeout",
        "[POPS-123] fix timeout",
        "#123 fix timeout",
        "fix timeout",
    ],
)
def test_subject_text_must_start_with_a_capital_letter(validator, subject):
    violations, _warnings = validator.check_format(subject)

    assert "subject must start with a capital letter" in violations


@pytest.mark.parametrize(
    "subject", ["POPS-123", "POPS-123:", "[POPS-123]", "#123"]
)
def test_issue_id_prefix_requires_subject_text(validator, subject):
    violations, _warnings = validator.check_format(subject)

    assert "subject must include text after issue ID" in violations


@pytest.mark.parametrize(
    "subject",
    [
        "Remove a duplicate test for the hidden Edit action",
        "Delete a duplicate spec for hiding the Edit action",
        "Test hiding Edit only at the section level",
        "Cover singular and plural vet headings",
        "POPS-123 Remove a duplicate test",
        "[POPS-123] Cover singular and plural vet headings",
    ],
)
def test_known_imperative_verbs_do_not_warn(validator, subject):
    assert validator.check_format(subject) == ([], [])


def test_unknown_imperative_verb_only_warns(validator):
    assert validator.check_format("Frobnicate cleanup") == (
        [],
        ["subject starts with unrecognized imperative verb 'Frobnicate'"],
    )


@pytest.mark.parametrize(
    "message",
    [
        "Cover singular and plural vet headings",
        "Fix date-added behavior",
        "Move card policy to the section",
        "Guard UserSession.refresh against expiry",
        "Fix timeout defined in settings.py",
        "Explain /tmp/result",
    ],
)
def test_names_filenames_and_paths_are_allowed(validator, message):
    violations, _warnings = validator.check_format(message)

    assert not any("reference" in violation or "path" in violation for violation in violations)


def test_standalone_long_url_is_allowed_in_body(validator):
    text = (
        "Improve Elixir worktree setup\n\n"
        "Based on findings from:\n"
        "https://ryanzidago.com/posts/"
        "reducing-elixir-worktree-setup-time-by-83-percent/"
    )

    assert validator.check_format(text) == ([], [])


@pytest.mark.parametrize(
    "line",
    [
        "A" * 73,
        "See https://example.com/" + "long-path/" * 7,
    ],
)
def test_non_url_body_lines_must_not_exceed_72_characters(validator, line):
    violations, _warnings = validator.check_format(f"Explain constraint\n\n{line}")

    assert "body lines must not exceed 72 characters" in violations


def test_urls_are_not_treated_as_file_paths(validator):
    violations, _warnings = validator.check_format(
        "Explain external requirement\n\nSee https://example.com/issues/19."
    )

    assert not any("path" in violation for violation in violations)


@pytest.mark.parametrize(
    "message",
    [
        "Document 127.0.0.1:3000 for local access",
        "Document example.com:443 for callbacks",
        "Document docs.rs:443 for callbacks",
        "Document service.sh:8080 for local access",
        "Document release v1.2:3 behavior",
    ],
)
def test_host_ports_and_versions_are_not_line_locations(validator, message):
    violations, _warnings = validator.check_format(message)

    assert not any("line reference" in violation for violation in violations)


def test_exact_line_locations_are_rejected(validator):
    violations, _warnings = validator.check_format(
        "Explain /tmp/result\n\n"
        "See src/jobs.py:42, /foo.py:5, ~/Gemfile:6, ./app.py:7, "
        "../lib.py:8, and line 19."
    )

    for reference in (
        "src/jobs.py:42",
        "/foo.py:5",
        "~/Gemfile:6",
        "./app.py:7",
        "../lib.py:8",
    ):
        assert f"message contains path or line reference '{reference}'" in violations
    assert "message contains line reference 'line 19'" in violations
    assert not any("'/tmp/result'" in violation for violation in violations)
    assert not any("'src/jobs.py'" in violation for violation in violations)


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


def test_pi_uses_gpt_5_6_luna_by_default(validator, monkeypatch):
    calls = []
    output = {"sentences": []}

    def run(argv, **kwargs):
        calls.append(argv)
        return subprocess.CompletedProcess(argv, 0, json.dumps(output), "")

    monkeypatch.delenv("COMMIT_MESSAGE_MODEL", raising=False)
    monkeypatch.setattr(validator.subprocess, "run", run)

    validator.invoke_pi("prompt")

    assert calls[0][0] == "pi"
    assert calls[0][calls[0].index("--model") + 1] == "openai-codex/gpt-5.6-luna"
    assert "--thinking" in calls[0]
    assert "off" in calls[0]
    assert "--no-tools" in calls[0]
    assert "--no-session" in calls[0]


def test_pi_timeout_is_an_operational_error(validator, monkeypatch):
    def timeout(*args, **kwargs):
        raise subprocess.TimeoutExpired("pi", 60)

    monkeypatch.setattr(validator.subprocess, "run", timeout)

    with pytest.raises(validator.OperationalError, match="timed out after 60 seconds"):
        validator.invoke_pi("prompt")


def test_structured_pi_output_is_required(validator):
    expected = {"sentences": []}
    assert validator.parse_pi_output(json.dumps(expected)) == expected
    assert validator.parse_pi_output(
        f"```json\n{json.dumps(expected)}\n```\n"
    ) == expected

    with pytest.raises(validator.OperationalError, match="structured output"):
        validator.parse_pi_output(json.dumps({"result": "looks good"}))


def test_warning_free_generated_success_is_silent(tmp_path):
    message = tmp_path / "COMMIT_EDITMSG"
    message.write_text("fixup! Add cache\n")

    result = subprocess.run(
        [str(CLI), str(message)], capture_output=True, text=True, check=False
    )

    assert result.returncode == 0
    assert result.stdout == ""
    assert result.stderr == ""


def test_non_why_body_category_becomes_deterministic_violation(
    tmp_path, validator, monkeypatch
):
    message = tmp_path / "COMMIT_EDITMSG"
    message.write_text("Improve cleanup\n\nUpdate the cleanup loop.\n")
    context = validator.Context("diff", {"app.py": "code"})
    monkeypatch.setattr(validator, "collect_context", lambda cwd: context)
    monkeypatch.setattr(
        validator,
        "invoke_pi",
        lambda prompt: {
            "sentences": [{"text": "Update the cleanup loop.", "category": "WHAT"}],
        },
    )

    violations, warnings = validator.validate(message, tmp_path)

    assert violations == [
        "body sentence is WHAT, not WHY: Update the cleanup loop."
    ]
    assert warnings == []


def test_subject_only_message_skips_git_and_pi(tmp_path, validator, monkeypatch):
    message = tmp_path / "COMMIT_EDITMSG"
    message.write_text("Fix cleanup\n")
    monkeypatch.setattr(
        validator,
        "collect_context",
        lambda cwd: pytest.fail("subject-only message collected Git context"),
    )
    monkeypatch.setattr(
        validator,
        "invoke_pi",
        lambda prompt: pytest.fail("subject-only message invoked Pi"),
    )

    assert validator.validate(message, tmp_path) == ([], [])


def test_classifier_must_return_the_complete_body(tmp_path, validator, monkeypatch):
    message = tmp_path / "COMMIT_EDITMSG"
    message.write_text("Improve cleanup\n\nReason one. Reason two.\n")
    context = validator.Context("diff", {"app.py": "code"})
    monkeypatch.setattr(validator, "collect_context", lambda cwd: context)
    monkeypatch.setattr(
        validator,
        "invoke_pi",
        lambda prompt: {
            "sentences": [
                {"text": "Reason one. Reason two.", "category": "WHY"}
            ]
        },
    )

    with pytest.raises(validator.OperationalError, match="supplied body sentences"):
        validator.validate(message, tmp_path)


@pytest.mark.parametrize("change_kind", ["test-only", "rename", "refactor"])
def test_why_only_body_is_allowed_for_any_change_kind(
    tmp_path, validator, monkeypatch, change_kind
):
    message = tmp_path / "COMMIT_EDITMSG"
    body = "The old arrangement made the constraint easy to miss."
    message.write_text(f"Improve cleanup\n\n{body}\n")
    context = validator.Context(f"{change_kind} diff", {"app.py": "code"})
    monkeypatch.setattr(validator, "collect_context", lambda cwd: context)
    monkeypatch.setattr(
        validator,
        "invoke_pi",
        lambda prompt: {"sentences": [{"text": body, "category": "WHY"}]},
    )

    assert validator.validate(message, tmp_path) == ([], [])


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
        raise validator.OperationalError("Pi failed")

    monkeypatch.setattr(validator, "validate", fail)
    assert validator.main([str(message)]) == 2
    assert "Pi failed" in capsys.readouterr().err
