"""Tests for the Claude Code adapter around the lint-file CLI.

The adapter's whole job is translation: a PostToolUse payload on stdin becomes
one CLI invocation, and the CLI's exit code becomes the hook's exit code. All
linting knowledge lives in bin/lint-file and is tested there.

Run with: uv run --with pytest pytest claude/hooks/lint_test.py
"""

import importlib.util
import io
import json
import os
import subprocess
from importlib.machinery import SourceFileLoader
from pathlib import Path
from types import SimpleNamespace

import pytest

# Loaded by path under a distinct name: bin/lint_file_test.py also loads a
# module called "lint", and importing by name would make which one wins depend
# on sys.path ordering when both files run in one pytest session.
ADAPTER = Path(__file__).parent / "lint.py"
_spec = importlib.util.spec_from_file_location(
    "lint_adapter", ADAPTER, loader=SourceFileLoader("lint_adapter", str(ADAPTER))
)
adapter = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(adapter)


def edit_of(file_path):
    """A PostToolUse payload representing an edit to a file."""
    return {"tool_name": "Edit", "tool_input": {"file_path": str(file_path)}}


@pytest.fixture
def cli(monkeypatch):
    """Record CLI invocations instead of running the real linter.

    Set `cli.returncode` to control what the stubbed CLI reports back.
    """
    stub = SimpleNamespace(calls=[], returncode=0)

    def fake_run(argv, **_kwargs):
        stub.calls.append(argv)
        return subprocess.CompletedProcess(argv, stub.returncode)

    monkeypatch.setattr(adapter.subprocess, "run", fake_run)

    return stub


def test_the_edited_path_is_passed_to_the_cli(cli):
    adapter.run_hook(edit_of("/tmp/app.py"))

    assert cli.calls == [[str(adapter.CLI), "/tmp/app.py"]]


@pytest.mark.parametrize("code", [0, 1, 2])
def test_the_cli_exit_code_is_passed_through(cli, code):
    """2 is what makes Claude Code block the edit; collapsing it loses the gate."""
    cli.returncode = code

    assert adapter.run_hook(edit_of("/tmp/app.py")) == code


@pytest.mark.parametrize("code", [-9, 127])
def test_an_abnormal_cli_exit_is_reported_as_a_tool_failure(cli, code):
    """The CLI only ever returns 0, 1 or 2, so anything else means it died.

    127 is what /usr/bin/env reports when the shebang's interpreter is not on
    PATH; a negative code is a signal. Passed through, -9 reaches the shell as
    247 and neither is 2, so a dead linter would quietly stop blocking edits.
    """
    cli.returncode = code

    assert adapter.run_hook(edit_of("/tmp/app.py")) == 1


def test_a_payload_without_a_file_path_is_ignored(cli):
    assert adapter.run_hook({"tool_name": "Edit", "tool_input": {}}) == 0
    assert cli.calls == []


def test_a_tool_that_does_not_write_files_is_ignored(cli):
    """The settings matcher should already exclude these; belt and braces."""
    payload = {"tool_name": "Read", "tool_input": {"file_path": "a.py"}}

    assert adapter.run_hook(payload) == 0
    assert cli.calls == []


def test_malformed_stdin_is_reported_without_a_traceback(monkeypatch, capsys):
    """A broken hook must not spray a traceback after every single edit."""
    monkeypatch.setattr("sys.stdin", io.StringIO("this is not json"))

    with pytest.raises(SystemExit) as exit_info:
        adapter.main()

    err = capsys.readouterr().err
    assert exit_info.value.code == 1
    assert "Traceback" not in err
    # Exit 1 does not block, so this line is the only signal the user gets.
    assert "JSONDecodeError" in err


def test_the_adapter_points_at_a_cli_it_can_run():
    """A CLI it cannot run fails open: exit 1, nothing blocked, linting off.

    Executability is the assertion rather than existence, because the adapter
    execs the file: a clone onto a filesystem that drops the mode bit, or a
    container mount with noexec, leaves it present and unrunnable.
    """
    assert os.access(adapter.CLI, os.X_OK), f"{adapter.CLI} is not executable"


def test_settings_registers_a_lint_hook_whose_script_exists():
    """A dangling hook path disables linting silently on every edit."""
    settings = json.loads((ADAPTER.parent.parent / "settings.json").read_text())
    commands = [
        hook["command"]
        for entry in settings["hooks"]["PostToolUse"]
        for hook in entry["hooks"]
        if "lint" in hook["command"]
    ]

    assert commands, "no lint hook registered in settings.json"
    for command in commands:
        script = Path(command.split()[-1]).expanduser()
        assert script.exists(), f"{command} points at a missing script"


def test_the_hook_blocks_an_edit_that_introduces_a_finding(tmp_path):
    """The full registered path: payload on stdin, through the CLI, exit 2."""
    source = tmp_path / "app.py"
    source.write_text("import os\n")

    result = subprocess.run(
        ["uv", "run", str(ADAPTER)],
        input=json.dumps(edit_of(source)),
        capture_output=True,
        text=True,
        timeout=300,
        check=False,
    )

    assert result.returncode == 2, result.stderr
    assert "F401" in result.stderr
