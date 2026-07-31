"""Tests for the lint hook's precondition logic.

The hook skips silently when a project is not set up to use a tool, so a
mis-specified precondition produces a linter that quietly never runs. These
tests assert which commands would run for a given directory tree, without
executing any linter.

Run with: uv run --with pytest pytest claude/hooks/test_lint.py
"""

import pytest

import lint


@pytest.fixture(autouse=True)
def all_drivers_available(monkeypatch):
    """Pretend every driver binary resolves, so trees decide the outcome."""
    monkeypatch.setattr(lint.shutil, "which", lambda name: f"/usr/bin/{name}")


def repo(tmp_path):
    """Create a repository root that bounds the upward marker search."""
    (tmp_path / ".git").mkdir()
    return tmp_path


def tools(commands):
    """Reduce commands to the tool each one invokes, for readable assertions."""
    return [argv[1] if argv[0] == "mix" else argv[0] for argv, _ in commands]


def cwd_for(commands, tool):
    """The working directory chosen for the command invoking a given tool."""
    return next(cwd for argv, cwd in commands if tool in argv)


def test_standalone_exs_gets_format_but_not_credo(tmp_path):
    root = repo(tmp_path)
    script = root / "docket.exs"
    script.touch()

    assert tools(lint.lint_commands(str(script))) == ["format"]


def test_exs_inside_mix_project_gets_both(tmp_path):
    root = repo(tmp_path)
    (root / "mix.exs").touch()
    source = root / "lib" / "thing.ex"
    source.parent.mkdir()
    source.touch()

    commands = lint.lint_commands(str(source))

    assert sorted(tools(commands)) == ["credo", "format"]
    assert cwd_for(commands, "credo") == str(root)


def test_format_runs_from_the_formatter_config_directory(tmp_path):
    root = repo(tmp_path)
    (root / "mix.exs").touch()
    (root / ".formatter.exs").touch()
    source = root / "lib" / "thing.ex"
    source.parent.mkdir()
    source.touch()

    commands = lint.lint_commands(str(source))

    # Run from lib/ instead and mix format silently ignores import_deps,
    # plugins, and locals_without_parens.
    assert cwd_for(commands, "format") == str(root)


def test_format_falls_back_to_the_file_directory_without_config(tmp_path):
    root = repo(tmp_path)
    script = root / "bin" / "docket.exs"
    script.parent.mkdir()
    script.touch()

    commands = lint.lint_commands(str(script))

    assert cwd_for(commands, "format") == str(script.parent)


def test_elixir_root_wins_over_enclosing_js_project(tmp_path):
    root = repo(tmp_path)
    (root / "package.json").touch()
    app = root / "apps" / "core"
    app.mkdir(parents=True)
    (app / "mix.exs").touch()
    source = app / "lib" / "thing.ex"
    source.parent.mkdir()
    source.touch()

    commands = lint.lint_commands(str(source))

    assert cwd_for(commands, "credo") == str(app)


def test_ruby_without_rubocop_config_is_skipped(tmp_path):
    root = repo(tmp_path)
    (root / "Gemfile").touch()
    script = root / "bin" / "report.rb"
    script.parent.mkdir()
    script.touch()

    assert lint.lint_commands(str(script)) == []


def test_ruby_with_rubocop_config_runs(tmp_path):
    root = repo(tmp_path)
    (root / "Gemfile").touch()
    (root / ".rubocop.yml").touch()
    script = root / "report.rb"
    script.touch()

    commands = lint.lint_commands(str(script))

    assert tools(commands) == ["bundle"]
    assert cwd_for(commands, "rubocop") == str(root)


def test_python_needs_no_config(tmp_path):
    root = repo(tmp_path)
    source = root / "hook.py"
    source.touch()

    assert tools(lint.lint_commands(str(source))) == ["uvx", "uvx"]


def subcommands(commands):
    """The ruff/mix/terraform subcommand each command invokes."""
    return [argv[2] if argv[0] == "uvx" else argv[1] for argv, _ in commands]


def test_ruff_formats_before_it_checks(tmp_path):
    """Checking first would report findings against pre-format content."""
    source = repo(tmp_path) / "hook.py"
    source.touch()

    assert subcommands(lint.lint_commands(str(source))) == ["format", "check"]


def test_elixir_formats_before_credo_reads(tmp_path):
    root = repo(tmp_path)
    (root / "mix.exs").touch()
    source = root / "thing.ex"
    source.touch()

    assert subcommands(lint.lint_commands(str(source))) == ["format", "credo"]


def test_terraform_formats_before_it_validates(tmp_path):
    root = repo(tmp_path)
    (root / ".terraform").mkdir()
    config = root / "main.tf"
    config.touch()

    assert subcommands(lint.lint_commands(str(config))) == ["fmt", "validate"]


def test_eslint_skipped_when_binary_absent_but_prettier_runs(tmp_path):
    root = repo(tmp_path)
    (root / "eslint.config.js").touch()
    bin_dir = root / "node_modules" / ".bin"
    bin_dir.mkdir(parents=True)
    (bin_dir / "prettier").touch()
    source = root / "app.ts"
    source.touch()

    commands = lint.lint_commands(str(source))

    assert tools(commands) == ["npx"]
    assert "prettier" in commands[0][0]


def test_prettier_skipped_when_not_installed(tmp_path):
    root = repo(tmp_path)
    source = root / "app.tsx"
    source.touch()

    assert lint.lint_commands(str(source)) == []


def test_eslint_config_and_binary_may_live_in_different_directories(tmp_path):
    root = repo(tmp_path)
    hoisted = root / "node_modules" / ".bin"
    hoisted.mkdir(parents=True)
    (hoisted / "eslint").touch()
    (root / "pnpm-lock.yaml").touch()
    package = root / "packages" / "web"
    package.mkdir(parents=True)
    (package / "eslint.config.js").touch()
    source = package / "app.ts"
    source.touch()

    commands = lint.lint_commands(str(source))

    assert tools(commands) == ["pnpm"]
    assert cwd_for(commands, "eslint") == str(package)


def test_eslint_fixes_before_prettier_writes(tmp_path):
    """Both rewrite the file, so they must not overlap and order is fixed."""
    root = repo(tmp_path)
    (root / "eslint.config.js").touch()
    bin_dir = root / "node_modules" / ".bin"
    bin_dir.mkdir(parents=True)
    (bin_dir / "eslint").touch()
    (bin_dir / "prettier").touch()
    source = root / "app.ts"
    source.touch()

    commands = lint.lint_commands(str(source))

    assert ["eslint" in argv for argv, _ in commands] == [True, False]
    assert "prettier" in commands[1][0]


def test_run_all_runs_commands_in_order(monkeypatch):
    calls = []
    monkeypatch.setattr(
        lint,
        "run_command",
        lambda argv, cwd: calls.append(argv[0]) or {"returncode": 0},
    )

    lint.run_all([(["first"], "/tmp"), (["second"], "/tmp"), (["third"], "/tmp")])

    assert calls == ["first", "second", "third"]


def test_terraform_validate_requires_initialized_directory(tmp_path):
    root = repo(tmp_path)
    config = root / "main.tf"
    config.touch()

    assert tools(lint.lint_commands(str(config))) == ["terraform"]

    (root / ".terraform").mkdir()

    assert len(lint.lint_commands(str(config))) == 2


def test_path_containing_a_space_stays_one_argument(tmp_path):
    root = repo(tmp_path)
    source = root / "my project" / "hook.py"
    source.parent.mkdir()
    source.touch()

    argv, _ = lint.lint_commands(str(source))[0]

    assert str(source) in argv


def test_unknown_extension_is_skipped(tmp_path):
    source = repo(tmp_path) / "notes.md"
    source.touch()

    assert lint.lint_commands(str(source)) == []


def test_search_stops_at_a_worktree_whose_git_is_a_file(tmp_path):
    outer = tmp_path / "outer"
    outer.mkdir()
    (outer / "mix.exs").touch()
    worktree = outer / "worktree"
    worktree.mkdir()
    (worktree / ".git").write_text("gitdir: /elsewhere\n")
    source = worktree / "thing.ex"
    source.touch()

    assert tools(lint.lint_commands(str(source))) == ["format"]


def edit_of(file_path):
    """A hook payload representing an edit to a file."""
    return {"tool_name": "Edit", "tool_input": {"file_path": str(file_path)}}


def test_skipped_file_exits_silently(tmp_path):
    source = repo(tmp_path) / "notes.md"
    source.touch()

    assert lint.lint_file(edit_of(source)) == 0


def test_unwatched_tool_exits_silently():
    assert (
        lint.lint_file({"tool_name": "Read", "tool_input": {"file_path": "a.py"}}) == 0
    )


def test_findings_block_the_edit(tmp_path, monkeypatch):
    monkeypatch.setattr(
        lint,
        "run_all",
        lambda commands: [
            {"command": "ruff", "returncode": 1, "stdout": "F401", "stderr": ""}
        ],
    )
    source = repo(tmp_path) / "app.py"
    source.touch()

    assert lint.lint_file(edit_of(source)) == 2


def test_tool_failure_reports_without_blocking(tmp_path, monkeypatch):
    monkeypatch.setattr(
        lint,
        "run_all",
        lambda commands: [
            {
                "command": "ruff",
                "returncode": lint.TOOL_FAILURE,
                "stdout": "",
                "stderr": "timed out",
            }
        ],
    )
    source = repo(tmp_path) / "app.py"
    source.touch()

    assert lint.lint_file(edit_of(source)) == 1


def test_findings_and_tool_failures_are_partitioned():
    results = [
        {"command": "a", "returncode": 1, "stdout": "offense", "stderr": ""},
        {"command": "b", "returncode": lint.TOOL_FAILURE, "stdout": "", "stderr": "x"},
        {"command": "c", "returncode": 0, "stdout": "", "stderr": ""},
    ]

    findings, failures = lint.partition_results(results, "f.ex")

    assert len(findings) == 1
    assert len(failures) == 1
    assert "Linting error" in findings[0]
    assert "Linter could not run" in failures[0]
