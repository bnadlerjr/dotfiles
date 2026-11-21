"""Tests for the automatic PERFECT review request coordinator."""

import json
import os
import subprocess
import sys
from pathlib import Path

import pytest

CLI = Path(__file__).parent / "cc-perfect-review-requests"
PR_URL = "https://github.com/instinctscience/kong-fu/pull/42"
PR_ROW = f"instinctscience/kong-fu\t42\toctocat\tReview me\t{PR_URL}\n"


def request_row(repository: str, number: int) -> str:
    url = f"https://github.com/{repository}/pull/{number}"
    return f"{repository}\t{number}\toctocat\tReview me\t{url}\n"


def executable(path: Path, content: str) -> None:
    path.write_text(content)
    path.chmod(0o755)


def git(*args: str, cwd: Path) -> None:
    subprocess.run(["git", *args], cwd=cwd, check=True, capture_output=True, text=True)


def add_clone(home: Path, directory: str, repository: str) -> Path:
    clone = home / "dev" / directory
    clone.mkdir(parents=True)
    git("init", cwd=clone)
    git("remote", "add", "origin", f"git@github.com:{repository}.git", cwd=clone)
    return clone


def setup_environment(tmp_path: Path):
    home = tmp_path / "home"
    clone = add_clone(home, "instinct/kong-fu", "instinctscience/kong-fu")

    commands = tmp_path / "commands"
    commands.mkdir()
    queue = tmp_path / "queue.tsv"
    executable(
        commands / "prs-to-review.py",
        '#!/bin/sh\ncat "$QUEUE_FILE"\n',
    )
    executable(
        commands / "cc-perfect-review",
        "#!/bin/sh\n"
        'if [ "${FAIL_URL:-}" = "$1" ]; then echo \'launch failed\' >&2; exit 1; fi\n'
        'printf \'%s\\t%s\\n\' "$PWD" "$1" >> "$LAUNCH_LOG"\n',
    )

    state_home = tmp_path / "state"
    launch_log = tmp_path / "launches.tsv"
    env = os.environ | {
        "HOME": str(home),
        "XDG_STATE_HOME": str(state_home),
        "QUEUE_FILE": str(queue),
        "LAUNCH_LOG": str(launch_log),
        "PATH": f"{commands}{os.pathsep}{os.environ['PATH']}",
    }
    state_path = state_home / "cc-perfect-review-requests" / "state.json"
    return env, clone, queue, launch_log, state_path


def invoke(env: dict[str, str], *args: str):
    return subprocess.run(
        [sys.executable, str(CLI), *args],
        capture_output=True,
        check=False,
        text=True,
        env=env,
    )


def test_first_run_launches_request_and_persists_queue(tmp_path):
    env, clone, queue, launch_log, state_path = setup_environment(tmp_path)
    queue.write_text(PR_ROW)

    result = invoke(env)

    assert result.returncode == 0, result.stderr
    assert "current=1 new=1 launched=1 failed=0" in result.stdout
    assert launch_log.read_text() == f"{clone}\t{PR_URL}\n"
    assert json.loads(state_path.read_text()) == {"requests": [PR_URL]}
    assert not state_path.with_suffix(".tmp").exists()


def test_request_rearms_only_after_disappearing(tmp_path):
    env, clone, queue, launch_log, state_path = setup_environment(tmp_path)
    queue.write_text(PR_ROW)

    assert invoke(env).returncode == 0

    unchanged = invoke(env)
    assert unchanged.returncode == 0
    assert "current=1 new=0 launched=0 failed=0" in unchanged.stdout
    assert launch_log.read_text() == f"{clone}\t{PR_URL}\n"

    queue.write_text("")
    disappeared = invoke(env)
    assert disappeared.returncode == 0
    assert "current=0 new=0 launched=0 failed=0" in disappeared.stdout
    assert json.loads(state_path.read_text()) == {"requests": []}

    queue.write_text(PR_ROW)
    rerequested = invoke(env)
    assert rerequested.returncode == 0
    assert "current=1 new=1 launched=1 failed=0" in rerequested.stdout
    assert launch_log.read_text() == f"{clone}\t{PR_URL}\n{clone}\t{PR_URL}\n"


def test_missing_clone_retries_on_the_next_run(tmp_path):
    env, _clone, queue, _launch_log, state_path = setup_environment(tmp_path)
    missing_url = "https://github.com/instinctscience/missing/pull/9"
    queue.write_text(request_row("instinctscience/missing", 9))

    first = invoke(env)
    second = invoke(env)

    for result in (first, second):
        assert result.returncode == 1
        assert "current=1 new=1 launched=0 failed=1" in result.stdout
        assert (
            "expected one clone for instinctscience/missing, found 0" in result.stderr
        )
    assert json.loads(state_path.read_text()) == {"requests": []}
    assert missing_url not in state_path.read_text()


def test_ambiguous_clone_is_not_launched(tmp_path):
    env, _clone, queue, launch_log, state_path = setup_environment(tmp_path)
    add_clone(Path(env["HOME"]), "personal/kong-fu-copy", "instinctscience/kong-fu")
    queue.write_text(PR_ROW)

    result = invoke(env)

    assert result.returncode == 1
    assert "current=1 new=1 launched=0 failed=1" in result.stdout
    assert "expected one clone for instinctscience/kong-fu, found 2" in result.stderr
    assert not launch_log.exists()
    assert json.loads(state_path.read_text()) == {"requests": []}


def test_mixed_success_persists_success_and_retries_failure(tmp_path):
    env, _clone, queue, launch_log, state_path = setup_environment(tmp_path)
    chunky_clone = add_clone(
        Path(env["HOME"]), "instinct/chunky-kong", "instinctscience/chunky-kong"
    )
    chunky_url = "https://github.com/instinctscience/chunky-kong/pull/43"
    queue.write_text(PR_ROW + request_row("instinctscience/chunky-kong", 43))
    env["FAIL_URL"] = PR_URL

    first = invoke(env)

    assert first.returncode == 1
    assert "current=2 new=2 launched=1 failed=1" in first.stdout
    assert "launch failed" in first.stderr
    assert launch_log.read_text() == f"{chunky_clone}\t{chunky_url}\n"
    assert json.loads(state_path.read_text()) == {"requests": [chunky_url]}

    second = invoke(env)

    assert second.returncode == 1
    assert "current=2 new=1 launched=0 failed=1" in second.stdout
    assert launch_log.read_text() == f"{chunky_clone}\t{chunky_url}\n"


@pytest.mark.parametrize("content", ["{", '{"requests": "not-a-list"}'])
def test_malformed_state_fails_closed_until_reset(tmp_path, content):
    env, _clone, queue, launch_log, state_path = setup_environment(tmp_path)
    queue.write_text(PR_ROW)
    state_path.parent.mkdir(parents=True)
    state_path.write_text(content)

    result = invoke(env)

    assert result.returncode == 1
    assert result.stdout == ""
    assert "state" in result.stderr
    assert "--reset" in result.stderr
    assert state_path.read_text() == content
    assert not launch_log.exists()


def test_state_write_failure_is_reported_without_a_traceback(tmp_path):
    env, _clone, queue, _launch_log, _state_path = setup_environment(tmp_path)
    queue.write_text(PR_ROW)
    blocked = tmp_path / "blocked-state-home"
    blocked.write_text("not a directory")
    env["XDG_STATE_HOME"] = str(blocked)

    result = invoke(env)

    assert result.returncode == 1
    assert "could not save state" in result.stderr
    assert "Traceback" not in result.stderr


def test_reset_clears_state_and_next_run_relaunches_current_queue(tmp_path):
    env, _clone, queue, launch_log, state_path = setup_environment(tmp_path)
    queue.write_text(PR_ROW)
    assert invoke(env).returncode == 0
    launch_log.unlink()

    reset = invoke(env, "--reset")

    assert reset.returncode == 0
    assert "reset" in reset.stdout.lower()
    assert not state_path.exists()
    assert not launch_log.exists()

    relaunched = invoke(env)
    assert relaunched.returncode == 0
    assert "current=1 new=1 launched=1 failed=0" in relaunched.stdout
    assert launch_log.exists()
