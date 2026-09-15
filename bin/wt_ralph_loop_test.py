"""Tests for the wt-ralph-loop Worktrunk subcommand.

Run with: uv run --with pytest pytest bin/wt_ralph_loop_test.py
"""

import importlib.util
import json
import os
import subprocess
import sys
from importlib.machinery import SourceFileLoader
from pathlib import Path

import pytest

CLI = Path(__file__).parent / "wt-ralph-loop"
_spec = importlib.util.spec_from_file_location(
    "wt_ralph_loop", CLI, loader=SourceFileLoader("wt_ralph_loop", str(CLI))
)
ralph = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(ralph)


def phase(number=1, issue="POPS-101", cycle="x", automated="x", done="x"):
    return f"""### Phase {number}: Build thing {number}

**Subtask**: {issue}, "Build thing {number}"

#### Pull Request Description

Build the thing.

#### TDD Cycles

##### Cycle 1: It works

- [{cycle}] Complete

**Behavior:** Given input, when run, then output.

#### Automated Testing

- [{automated}] Unit: it works

**Run:** `pytest`

#### Done When

- [{done}] The thing works
"""


def test_a_complete_plan_has_no_next_phase():
    plan = ralph.parse_plan(phase())

    assert ralph.next_phase(plan) is None


def test_the_first_incomplete_phase_is_selected_in_document_order():
    plan = ralph.parse_plan(
        phase(1, "POPS-101") + "\n" + phase(2, "POPS-102", cycle=" ")
    )

    selected = ralph.next_phase(plan)

    assert (selected.number, selected.issue, selected.title) == (
        2,
        "POPS-102",
        "Build thing 2",
    )


def test_a_partially_complete_phase_remains_selected():
    plan = ralph.parse_plan(
        phase(1, "POPS-101", done=" ") + "\n" + phase(2, "POPS-102", cycle=" ")
    )

    assert ralph.next_phase(plan).issue == "POPS-101"


def test_every_tdd_cycle_requires_its_own_completion_checkbox():
    second_cycle = (
        """\n##### Cycle 2: Another behavior\n\n**Behavior:** Another behavior.\n"""
    )
    text = phase().replace(
        "#### Automated Testing", second_cycle + "\n#### Automated Testing"
    )

    with pytest.raises(ralph.PlanError, match="Cycle 2.*completion checkbox"):
        ralph.parse_plan(text)


def test_the_manually_processed_three_hash_nesting_is_accepted():
    parsed = ralph.parse_plan("# Plan\n\n" + phase())

    assert len(parsed) == 1
    assert parsed[0].complete is True


def test_automated_testing_can_name_multiple_run_commands():
    text = phase().replace(
        "**Run:** `pytest`", "**Run:** `pytest unit` and `pytest integration`"
    )

    assert ralph.parse_plan(text)[0].complete is True


@pytest.mark.parametrize(
    ("text", "message"),
    [
        (phase().replace('**Subtask**: POPS-101, "Build thing 1"\n\n', ""), "Subtask"),
        (
            phase().replace(
                '**Subtask**: POPS-101, "Build thing 1"',
                "**Subtask**: POPS-101\n\n**Subtask**: POPS-102",
            ),
            "exactly one Subtask",
        ),
        (
            phase().replace("#### Pull Request Description", "#### Description"),
            "Pull Request Description",
        ),
        (phase().replace("#### TDD Cycles", "#### Cycles"), "TDD Cycles"),
        (
            phase().replace("#### Automated Testing", "#### Tests"),
            "Automated Testing",
        ),
        (phase().replace("**Run:** `pytest`", ""), "Run"),
        (phase().replace("#### Done When", "#### Finished"), "Done When"),
    ],
)
def test_missing_or_duplicate_contract_parts_are_rejected(text, message):
    with pytest.raises(ralph.PlanError, match=message):
        ralph.parse_plan(text)


def test_a_malformed_completion_checkbox_is_rejected():
    with pytest.raises(ralph.PlanError, match="malformed checkbox"):
        ralph.parse_plan(phase(cycle="maybe"))


def test_two_hash_phase_headings_are_rejected():
    with pytest.raises(ralph.PlanError, match="expected '### Phase N:'"):
        ralph.parse_plan(phase().replace("### Phase 1:", "## Phase 1:"))


def executable(path, content):
    path.write_text(content)
    path.chmod(0o755)


def command_doubles(tmp_path, monkeypatch):
    commands = tmp_path / "commands"
    commands.mkdir()
    log = tmp_path / "commands.jsonl"
    worktrees = tmp_path / "worktrees.json"
    machete = tmp_path / "machete"
    root = tmp_path / "repo"
    root.mkdir()
    machete.write_text("main\n")
    worktrees.write_text(json.dumps([{"path": str(root), "branch": "main"}]))

    shared = f"""#!/usr/bin/env python3
import json
import os
import sys
from pathlib import Path

log = Path({str(log)!r})
state_path = Path({str(worktrees)!r})
with log.open("a") as output:
    output.write(json.dumps({{"command": Path(sys.argv[0]).name, "args": sys.argv[1:], "cwd": os.getcwd()}}) + "\\n")
state = json.loads(state_path.read_text())
command = Path(sys.argv[0]).name
if command == "git":
    if sys.argv[1:3] == ["branch", "--show-current"]:
        print(next(item["branch"] for item in state if item["path"] == os.getcwd()))
    elif sys.argv[1:4] == ["worktree", "list", "--porcelain"]:
        for item in state:
            print(f'worktree {{item["path"]}}')
            print('HEAD deadbeef')
            print(f'branch refs/heads/{{item["branch"]}}\\n')
    elif sys.argv[1:3] == ["machete", "file"]:
        print({str(machete)!r})
    elif sys.argv[1:3] == ["machete", "add"]:
        pass
    else:
        raise SystemExit(f"unexpected git arguments: {{sys.argv[1:]}}")
elif command == "wt":
    if os.environ.get("FAKE_WT_FAILURE"):
        print(os.environ.get("FAKE_WT_MESSAGE", "wt failed"), file=sys.stderr)
        raise SystemExit(9)
    issue = sys.argv[2]
    branch = f'feature/{{issue}}-work'
    path = str(Path.cwd().parent / branch.replace('/', '-'))
    Path(path).mkdir()
    state.append({{"path": path, "branch": branch}})
    state_path.write_text(json.dumps(state))
else:
    raise SystemExit(f"unexpected command: {{command}}")
"""
    executable(commands / "git", shared)
    executable(commands / "wt", shared)
    monkeypatch.setenv("PATH", f"{commands}{os.pathsep}{os.environ['PATH']}")
    return root, log


def complete_phase(plan_path, selected):
    text = plan_path.read_text()
    start = text.index(f"### Phase {selected.number}:")
    next_start = text.find("### Phase ", start + 1)
    end = len(text) if next_start == -1 else next_start
    completed = text[start:end].replace("- [ ]", "- [x]")
    plan_path.write_text(text[:start] + completed + text[end:])


def test_orchestration_composes_wt_jira_and_registers_the_new_worktree(
    tmp_path, monkeypatch
):
    root, log = command_doubles(tmp_path, monkeypatch)
    plan_path = tmp_path / "plan.md"
    plan_path.write_text(phase(cycle=" ", automated=" ", done=" "))
    claude_calls = []

    def fake_claude(selected, worktree, absolute_plan, run_dir):
        claude_calls.append((selected.issue, worktree, absolute_plan, run_dir))
        complete_phase(absolute_plan, selected)
        return "finished"

    reports = ralph.run_loop(
        plan_path, start_dir=root, run_dir=tmp_path / "run", claude_runner=fake_claude
    )

    commands = [json.loads(line) for line in log.read_text().splitlines()]
    wt_call = next(call for call in commands if call["command"] == "wt")
    machete_call = next(
        call
        for call in commands
        if call["command"] == "git" and call["args"][:2] == ["machete", "add"]
    )
    created = root.parent / "feature-POPS-101-work"
    assert wt_call == {"command": "wt", "args": ["jira", "POPS-101"], "cwd": str(root)}
    assert machete_call["args"] == [
        "machete",
        "add",
        "feature/POPS-101-work",
        "--onto=main",
        "--yes",
    ]
    assert claude_calls[0][1:3] == (created, plan_path.resolve())
    assert reports == ["finished"]


def test_each_phase_uses_the_previous_phase_as_its_parent(tmp_path, monkeypatch):
    root, log = command_doubles(tmp_path, monkeypatch)
    plan_path = tmp_path / "plan.md"
    plan_path.write_text(
        phase(1, "POPS-101", cycle=" ") + "\n" + phase(2, "POPS-102", cycle=" ")
    )
    claude_worktrees = []

    def fake_claude(selected, worktree, absolute_plan, run_dir):
        claude_worktrees.append(worktree)
        complete_phase(absolute_plan, selected)
        return selected.issue

    reports = ralph.run_loop(
        plan_path, start_dir=root, run_dir=tmp_path / "run", claude_runner=fake_claude
    )

    commands = [json.loads(line) for line in log.read_text().splitlines()]
    wt_calls = [call for call in commands if call["command"] == "wt"]
    machete_calls = [
        call
        for call in commands
        if call["command"] == "git" and call["args"][:2] == ["machete", "add"]
    ]
    first = root.parent / "feature-POPS-101-work"
    second = root.parent / "feature-POPS-102-work"
    assert [call["cwd"] for call in wt_calls] == [str(root), str(first)]
    assert machete_calls[1]["args"][3] == "--onto=feature/POPS-101-work"
    assert claude_worktrees == [first, second]
    assert reports == ["POPS-101", "POPS-102"]


def fake_claude_command(tmp_path, monkeypatch):
    commands = tmp_path / "claude-commands"
    commands.mkdir()
    arguments = tmp_path / "claude-arguments.jsonl"
    executable(
        commands / "claude",
        f"""#!/usr/bin/env python3
import json
import os
import sys
from pathlib import Path

with Path({str(arguments)!r}).open("a") as output:
    output.write(json.dumps(sys.argv[1:]) + "\\n")
mode = os.environ.get("FAKE_CLAUDE_MODE", "success")
if mode == "malformed":
    print("not-json", flush=True)
    raise SystemExit(0)
print(json.dumps({{"type": "assistant", "message": {{"content": [{{"type": "tool_use", "id": "1", "name": "Read", "input": {{"file_path": "lib/app.ex"}}}}]}}}}), flush=True)
print(json.dumps({{"type": "user", "message": {{"content": [{{"type": "tool_result", "tool_use_id": "1"}}]}}}}), flush=True)
print(json.dumps({{"type": "result", "result": "phase finished", "is_error": False}}), flush=True)
raise SystemExit(7 if mode == "failure" else 0)
""",
    )
    monkeypatch.setenv("PATH", f"{commands}{os.pathsep}{os.environ['PATH']}")
    return arguments


def test_each_phase_gets_a_new_claude_session_and_retained_stream(
    tmp_path, monkeypatch, capsys
):
    arguments = fake_claude_command(tmp_path, monkeypatch)
    run_dir = tmp_path / "run"
    worktree = tmp_path / "worktree"
    worktree.mkdir()
    plan_path = (tmp_path / "plan.md").resolve()

    first = ralph.run_claude(
        ralph.Phase(1, "One", "POPS-101", False), worktree, plan_path, run_dir
    )
    second = ralph.run_claude(
        ralph.Phase(2, "Two", "POPS-102", False), worktree, plan_path, run_dir
    )

    calls = [json.loads(line) for line in arguments.read_text().splitlines()]
    first_session = calls[0][calls[0].index("--session-id") + 1]
    second_session = calls[1][calls[1].index("--session-id") + 1]
    assert first_session != second_session
    assert all("--resume" not in call and "--continue" not in call for call in calls)
    assert calls[0][-1] == f"/implement-next-phase {plan_path}"
    assert first == second == "phase finished"
    assert "[claude] → Read" in capsys.readouterr().err
    raw_log = run_dir / "phase-1-POPS-101.jsonl"
    assert '"type": "result"' in raw_log.read_text()
    metadata = json.loads((run_dir / "phase-1-POPS-101.json").read_text())
    assert metadata["sessionId"] == first_session
    assert metadata["eventLog"] == str(raw_log)


def test_malformed_claude_json_is_reported_and_retained(tmp_path, monkeypatch):
    fake_claude_command(tmp_path, monkeypatch)
    monkeypatch.setenv("FAKE_CLAUDE_MODE", "malformed")
    worktree = tmp_path / "worktree"
    worktree.mkdir()
    run_dir = tmp_path / "run"

    with pytest.raises(ralph.ClaudeError, match="invalid JSON"):
        ralph.run_claude(
            ralph.Phase(1, "One", "POPS-101", False),
            worktree,
            tmp_path / "plan.md",
            run_dir,
        )

    assert (run_dir / "phase-1-POPS-101.jsonl").read_text() == "not-json\n"


def test_a_nonzero_claude_exit_is_reported(tmp_path, monkeypatch):
    fake_claude_command(tmp_path, monkeypatch)
    monkeypatch.setenv("FAKE_CLAUDE_MODE", "failure")
    worktree = tmp_path / "worktree"
    worktree.mkdir()

    with pytest.raises(ralph.ClaudeError, match="status 7"):
        ralph.run_claude(
            ralph.Phase(1, "One", "POPS-101", False),
            worktree,
            tmp_path / "plan.md",
            tmp_path / "run",
        )


def test_a_claude_start_failure_is_recorded(tmp_path, monkeypatch):
    monkeypatch.setenv("PATH", str(tmp_path))
    worktree = tmp_path / "worktree"
    worktree.mkdir()
    run_dir = tmp_path / "run"

    with pytest.raises(ralph.ClaudeError, match="could not start"):
        ralph.run_claude(
            ralph.Phase(1, "One", "POPS-101", False),
            worktree,
            tmp_path / "plan.md",
            run_dir,
        )

    metadata = json.loads((run_dir / "phase-1-POPS-101.json").read_text())
    assert metadata["status"] == "failed"


def incomplete_plan(path):
    path.write_text(phase(cycle=" ", automated=" ", done=" "))
    return path


def test_an_unregistered_starting_branch_stops_before_worktree_creation(
    tmp_path, monkeypatch
):
    root, log = command_doubles(tmp_path, monkeypatch)
    (tmp_path / "machete").write_text("")

    with pytest.raises(ralph.LoopError, match="register it before running"):
        ralph.run_loop(
            incomplete_plan(tmp_path / "plan.md"),
            start_dir=root,
            run_dir=tmp_path / "run",
        )

    commands = [json.loads(line) for line in log.read_text().splitlines()]
    assert not any(call["command"] == "wt" for call in commands)


def test_an_existing_phase_worktree_is_preserved_and_not_retried(tmp_path, monkeypatch):
    root, log = command_doubles(tmp_path, monkeypatch)
    existing = root.parent / "feature-POPS-101-work"
    existing.mkdir()
    monkeypatch.setenv("FAKE_WT_FAILURE", "1")
    monkeypatch.setenv("FAKE_WT_MESSAGE", f"branch already exists at {existing}")

    with pytest.raises(ralph.LoopError, match="wt jira POPS-101 failed"):
        ralph.run_loop(
            incomplete_plan(tmp_path / "plan.md"),
            start_dir=root,
            run_dir=tmp_path / "run",
        )

    commands = [json.loads(line) for line in log.read_text().splitlines()]
    assert sum(call["command"] == "wt" for call in commands) == 1
    assert existing.is_dir()


def test_a_successful_claude_run_without_plan_progress_stops(tmp_path, monkeypatch):
    root, _log = command_doubles(tmp_path, monkeypatch)

    with pytest.raises(ralph.LoopError, match="without completing Phase 1"):
        ralph.run_loop(
            incomplete_plan(tmp_path / "plan.md"),
            start_dir=root,
            run_dir=tmp_path / "run",
            claude_runner=lambda *_args: "stopped",
        )

    assert (root.parent / "feature-POPS-101-work").is_dir()


def test_a_plan_that_becomes_malformed_stops_after_the_current_phase(
    tmp_path, monkeypatch
):
    root, log = command_doubles(tmp_path, monkeypatch)
    plan_path = incomplete_plan(tmp_path / "plan.md")

    def corrupt_plan(*_args):
        plan_path.write_text("not a plan")
        return "finished"

    with pytest.raises(
        ralph.LoopError, match="plan became invalid.*worktree preserved"
    ):
        ralph.run_loop(
            plan_path,
            start_dir=root,
            run_dir=tmp_path / "run",
            claude_runner=corrupt_plan,
        )

    commands = [json.loads(line) for line in log.read_text().splitlines()]
    assert sum(call["command"] == "wt" for call in commands) == 1


def test_a_complete_plan_runs_no_external_commands(tmp_path, monkeypatch):
    root, log = command_doubles(tmp_path, monkeypatch)
    plan_path = tmp_path / "plan.md"
    plan_path.write_text(phase())

    reports = ralph.run_loop(
        plan_path,
        start_dir=root,
        run_dir=tmp_path / "run",
    )

    assert reports == []
    assert not log.exists()


def test_help_documents_the_strict_stack_and_failure_contract():
    result = subprocess.run(
        [sys.executable, str(CLI), "--help"],
        text=True,
        stdout=subprocess.PIPE,
        check=True,
    )

    assert "wt ralph-loop PLAN-FILE" in result.stdout
    assert "### Phase N:" in result.stdout
    assert "stack" in result.stdout
    assert "XDG_STATE_HOME" in result.stdout
    assert "preserved" in result.stdout
