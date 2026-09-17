"""Tests for the wt-ralph-loop Worktrunk subcommand.

Run with: uv run --with pytest pytest bin/wt_ralph_loop_test.py
"""

import importlib.util
import json
import os
import re
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


@pytest.fixture(autouse=True)
def current_herdr_workspace(monkeypatch):
    monkeypatch.setenv("HERDR_ENV", "1")
    monkeypatch.setenv("HERDR_WORKSPACE_ID", "w-parent")


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
    assert reports == 1


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
    assert reports == 2


def fake_herdr_command(tmp_path, monkeypatch, *, statuses=None):
    commands = tmp_path / "herdr-commands"
    commands.mkdir()
    arguments = tmp_path / "herdr-arguments.jsonl"
    state_path = tmp_path / "herdr-state.json"
    state_path.write_text(json.dumps({"statuses": statuses or [], "status_index": 0}))
    executable(
        commands / "herdr",
        f"""#!/usr/bin/env python3
import json
import os
import sys
from pathlib import Path

arguments = Path({str(arguments)!r})
state_path = Path({str(state_path)!r})
args = sys.argv[1:]
with arguments.open("a") as output:
    output.write(json.dumps(args) + "\\n")

failure = os.environ.get("FAKE_HERDR_FAILURE")
if failure and args[:len(failure.split())] == failure.split():
    print(json.dumps({{"error": {{"message": "fake herdr failure"}}}}), file=sys.stderr)
    raise SystemExit(1)
malformed = os.environ.get("FAKE_HERDR_MALFORMED")
if malformed and args[:len(malformed.split())] == malformed.split():
    print("not-json")
    raise SystemExit(0)

if args[:2] == ["tab", "create"]:
    result = {{"tab": {{"tab_id": "w1:t2"}}, "root_pane": {{"pane_id": "w1:p2"}}}}
elif args[:2] == ["agent", "start"]:
    result = {{"agent": {{"agent_status": "idle", "pane_id": "w1:p2"}}}}
elif args[:2] == ["agent", "prompt"]:
    result = {{"submitted": True}}
elif args[:2] in (["agent", "get"], ["agent", "wait"]):
    state = json.loads(state_path.read_text())
    index = state["status_index"]
    statuses = state["statuses"]
    item = statuses[min(index, len(statuses) - 1)]
    state["status_index"] = index + 1
    state_path.write_text(json.dumps(state))
    if isinstance(item, dict):
        status = item["status"]
        if item.get("complete"):
            plan = Path(item["plan"])
            plan.write_text(plan.read_text().replace("- [ ]", "- [x]"))
        elif item.get("malformed"):
            Path(item["plan"]).write_text("not a plan")
    else:
        status = item
    if status == "missing":
        print(json.dumps({{"error": {{"message": "agent not found"}}}}), file=sys.stderr)
        raise SystemExit(1)
    result = {{"agent": {{"agent_status": status, "pane_id": "w1:p2"}}}}
else:
    raise SystemExit(f"unexpected herdr arguments: {{args}}")
print(json.dumps({{"id": "fake", "result": result}}))
""",
    )
    monkeypatch.setenv("PATH", f"{commands}{os.pathsep}{os.environ['PATH']}")
    return arguments, state_path


def test_the_loop_requires_the_current_herdr_workspace_before_creating_worktrees(
    tmp_path, monkeypatch
):
    root, log = command_doubles(tmp_path, monkeypatch)
    monkeypatch.delenv("HERDR_ENV", raising=False)
    monkeypatch.delenv("HERDR_WORKSPACE_ID", raising=False)

    plan_path = incomplete_plan(tmp_path / "plan.md")

    def fake_claude(selected, *_args):
        complete_phase(plan_path, selected)
        return "finished"

    with pytest.raises(ralph.LoopError, match="inside Herdr"):
        ralph.run_loop(
            plan_path,
            start_dir=root,
            run_dir=tmp_path / "run",
            claude_runner=fake_claude,
        )

    assert not log.exists()


def test_each_phase_starts_interactive_claude_in_a_selected_subtask_tab(
    tmp_path, monkeypatch
):
    plan_path = tmp_path / "plan.md"
    plan_path.write_text(
        phase(1, "POPS-101", cycle=" ") + "\n" + phase(2, "POPS-102", cycle=" ")
    )
    worktree = tmp_path / "worktree"
    worktree.mkdir()
    arguments, _state = fake_herdr_command(
        tmp_path,
        monkeypatch,
        statuses=[{"status": "done", "complete": True, "plan": str(plan_path)}],
    )
    monkeypatch.setenv("HERDR_ENV", "1")
    monkeypatch.setenv("HERDR_WORKSPACE_ID", "w-parent")
    first = ralph.run_claude(
        ralph.Phase(1, "One", "POPS-101", False),
        worktree,
        plan_path.resolve(),
        tmp_path / "run",
    )
    second = ralph.run_claude(
        ralph.Phase(2, "Two", "POPS-102", False),
        worktree,
        plan_path.resolve(),
        tmp_path / "run",
    )

    calls = [json.loads(line) for line in arguments.read_text().splitlines()]
    tab_calls = [call for call in calls if call[:2] == ["tab", "create"]]
    assert tab_calls == [
        [
            "tab",
            "create",
            "--workspace",
            "w-parent",
            "--cwd",
            str(worktree),
            "--label",
            "POPS-101",
            "--focus",
        ],
        [
            "tab",
            "create",
            "--workspace",
            "w-parent",
            "--cwd",
            str(worktree),
            "--label",
            "POPS-102",
            "--focus",
        ],
    ]
    start_calls = [call for call in calls if call[:2] == ["agent", "start"]]
    names = [call[2] for call in start_calls]
    assert re.fullmatch(r"p1-pops-101-[0-9a-f]{8}", names[0])
    assert re.fullmatch(r"p2-pops-102-[0-9a-f]{8}", names[1])
    assert names[0] != names[1]
    assert all(
        call[3:7] == ["--kind", "claude", "--pane", "w1:p2"] for call in start_calls
    )
    assert all(
        call[7:11] == ["--", "--permission-mode", "auto", "--session-id"]
        for call in start_calls
    )
    for phase_number, issue, start_call in zip(
        (1, 2), ("POPS-101", "POPS-102"), start_calls, strict=True
    ):
        metadata = json.loads(
            (tmp_path / "run" / f"phase-{phase_number}-{issue}.json").read_text()
        )
        assert metadata["sessionId"] == start_call[11]
        assert metadata["agentName"] == start_call[2]
        assert metadata["workspaceId"] == "w-parent"
        assert metadata["tabId"] == "w1:t2"
        assert metadata["paneId"] == "w1:p2"
    assert first is None
    assert second is None


def test_agent_names_respect_herdrs_length_limit_for_large_phase_numbers():
    name = ralph.agent_name(
        ralph.Phase(
            1234567890123456789012345678901234567890,
            "One",
            "VERYLONGPROJECT-123456",
            False,
        ),
        "a1b2c3d4-0000-0000-0000-000000000000",
    )

    assert len(name) <= 32
    assert re.fullmatch(r"[a-z][a-z0-9_-]{0,31}", name)


def run_interactive_phase(tmp_path, monkeypatch, statuses):
    plan_path = incomplete_plan(tmp_path / "plan.md")
    worktree = tmp_path / "worktree"
    worktree.mkdir()
    arguments, state_path = fake_herdr_command(
        tmp_path, monkeypatch, statuses=statuses(plan_path)
    )
    monkeypatch.setenv("HERDR_ENV", "1")
    monkeypatch.setenv("HERDR_WORKSPACE_ID", "w-parent")
    result = ralph.run_claude(
        ralph.Phase(1, "One", "POPS-101", False),
        worktree,
        plan_path.resolve(),
        tmp_path / "run",
    )
    return result, plan_path, arguments, state_path


def test_an_interactive_phase_completes_after_claude_settles(tmp_path, monkeypatch):
    result, plan_path, _arguments, _state = run_interactive_phase(
        tmp_path,
        monkeypatch,
        lambda plan: [{"status": "done", "complete": True, "plan": str(plan)}],
    )

    assert result is None
    assert ralph.parse_plan(plan_path.read_text())[0].complete is True
    metadata = json.loads((tmp_path / "run" / "phase-1-POPS-101.json").read_text())
    assert metadata["status"] == "succeeded"
    assert "createdAt" in metadata
    assert "completedAt" in metadata
    assert "eventLog" not in metadata
    assert not list((tmp_path / "run").glob("*.jsonl"))


def test_a_blocked_phase_continues_after_human_input(tmp_path, monkeypatch, capsys):
    result, plan_path, arguments, state_path = run_interactive_phase(
        tmp_path,
        monkeypatch,
        lambda plan: [
            "blocked",
            "working",
            {"status": "done", "complete": True, "plan": str(plan)},
        ],
    )

    calls = [json.loads(line) for line in arguments.read_text().splitlines()]
    observations = [call[:2] for call in calls if call[1] in {"get", "wait"}]
    assert observations == [["agent", "get"], ["agent", "get"], ["agent", "wait"]]
    assert result is None
    assert json.loads(state_path.read_text())["status_index"] == 3
    assert ralph.parse_plan(plan_path.read_text())[0].complete is True
    assert "needs correction" in capsys.readouterr().err.lower()


def test_each_repeated_block_reports_that_the_phase_needs_correction(
    tmp_path, monkeypatch, capsys
):
    run_interactive_phase(
        tmp_path,
        monkeypatch,
        lambda plan: [
            "blocked",
            "working",
            "blocked",
            "working",
            {"status": "done", "complete": True, "plan": str(plan)},
        ],
    )

    assert capsys.readouterr().err.lower().count("needs correction") == 2


def test_an_idle_incomplete_phase_waits_for_manual_correction(
    tmp_path, monkeypatch, capsys
):
    result, plan_path, _arguments, state_path = run_interactive_phase(
        tmp_path,
        monkeypatch,
        lambda plan: [
            "idle",
            "working",
            {"status": "done", "complete": True, "plan": str(plan)},
        ],
    )

    assert result is None
    assert json.loads(state_path.read_text())["status_index"] == 3
    assert ralph.parse_plan(plan_path.read_text())[0].complete is True
    assert "needs correction" in capsys.readouterr().err.lower()


def test_an_exited_agent_fails_without_removing_its_phase_metadata(
    tmp_path, monkeypatch
):
    plan_path = incomplete_plan(tmp_path / "plan.md")
    worktree = tmp_path / "worktree"
    worktree.mkdir()
    fake_herdr_command(tmp_path, monkeypatch, statuses=["missing"])
    monkeypatch.setenv("HERDR_ENV", "1")
    monkeypatch.setenv("HERDR_WORKSPACE_ID", "w-parent")

    with pytest.raises(ralph.ClaudeError, match="agent.*unavailable"):
        ralph.run_claude(
            ralph.Phase(1, "One", "POPS-101", False),
            worktree,
            plan_path.resolve(),
            tmp_path / "run",
        )

    metadata = json.loads((tmp_path / "run" / "phase-1-POPS-101.json").read_text())
    assert metadata["status"] == "failed"
    assert metadata["tabId"] == "w1:t2"


def test_malformed_herdr_json_is_reported(tmp_path, monkeypatch):
    plan_path = incomplete_plan(tmp_path / "plan.md")
    worktree = tmp_path / "worktree"
    worktree.mkdir()
    fake_herdr_command(tmp_path, monkeypatch, statuses=["done"])
    monkeypatch.setenv("HERDR_ENV", "1")
    monkeypatch.setenv("HERDR_WORKSPACE_ID", "w-parent")
    monkeypatch.setenv("FAKE_HERDR_MALFORMED", "tab create")

    with pytest.raises(ralph.ClaudeError, match="invalid JSON"):
        ralph.run_claude(
            ralph.Phase(1, "One", "POPS-101", False),
            worktree,
            plan_path.resolve(),
            tmp_path / "run",
        )


def test_a_herdr_command_failure_is_reported(tmp_path, monkeypatch):
    plan_path = incomplete_plan(tmp_path / "plan.md")
    worktree = tmp_path / "worktree"
    worktree.mkdir()
    fake_herdr_command(tmp_path, monkeypatch, statuses=["done"])
    monkeypatch.setenv("HERDR_ENV", "1")
    monkeypatch.setenv("HERDR_WORKSPACE_ID", "w-parent")
    monkeypatch.setenv("FAKE_HERDR_FAILURE", "agent start")

    with pytest.raises(ralph.ClaudeError, match="herdr agent start failed"):
        ralph.run_claude(
            ralph.Phase(1, "One", "POPS-101", False),
            worktree,
            plan_path.resolve(),
            tmp_path / "run",
        )


def test_keyboard_interrupt_records_the_run_as_interrupted(tmp_path, monkeypatch):
    run_dir = tmp_path / "run"
    run_dir.mkdir()
    plan_path = tmp_path / "plan.md"
    plan_path.write_text(phase())
    monkeypatch.setattr(ralph, "create_run_dir", lambda: run_dir)
    monkeypatch.setattr(
        ralph,
        "run_loop",
        lambda *_args, **_kwargs: (_ for _ in ()).throw(KeyboardInterrupt()),
    )

    try:
        result = ralph.main([str(plan_path)])
    except KeyboardInterrupt:
        pytest.fail("main did not record the interrupted run")

    assert result == 130
    state = json.loads((run_dir / "run.json").read_text())
    assert state["status"] == "interrupted"
    assert "completedAt" in state


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


def test_a_real_interactive_run_reports_the_preserved_worktree_for_a_malformed_plan(
    tmp_path, monkeypatch
):
    root, _log = command_doubles(tmp_path, monkeypatch)
    plan_path = incomplete_plan(tmp_path / "plan.md")
    fake_herdr_command(
        tmp_path,
        monkeypatch,
        statuses=[{"status": "done", "malformed": True, "plan": str(plan_path)}],
    )

    with pytest.raises(
        ralph.LoopError, match="plan became invalid.*worktree preserved"
    ):
        ralph.run_loop(plan_path, start_dir=root, run_dir=tmp_path / "run")


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

    assert reports == 0
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
    assert "inside Herdr" in result.stdout
    assert "current workspace" in result.stdout
    assert "tab" in result.stdout
