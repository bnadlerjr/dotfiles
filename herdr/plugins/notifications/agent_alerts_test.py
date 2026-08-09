"""Tests for the herdr agent alert poller's decision logic.

The poller decides whether to alert from two snapshots and a clock, so these
tests drive it the way launchd does: repeated calls, each one fed the state the
previous call returned. State is opaque here on purpose. A test that builds a
state dict by hand asserts the shape of a private structure, and would keep
passing after a change that stopped alerting.

Run with: uv run --with pytest pytest herdr/plugins/notifications/agent_alerts_test.py
"""

import http.client
import importlib.util
import json
import subprocess
from importlib.machinery import SourceFileLoader
from pathlib import Path

import pytest

MODULE = Path(__file__).parent / "agent_alerts.py"
_spec = importlib.util.spec_from_file_location(
    "agent_alerts", MODULE, loader=SourceFileLoader("agent_alerts", str(MODULE))
)
agent_alerts = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(agent_alerts)


def listing(*entries):
    """Wrap agents the way `herdr agent list` does, under `result`."""
    return json.dumps(
        {
            "id": "cli:agent:list",
            "result": {"agents": list(entries), "type": "agent_list"},
        }
    )


def agent(status, pane_id="wQ:pQ", focused=False):
    """One entry shaped like `herdr agent list` reports it."""
    return {
        "pane_id": pane_id,
        "agent_status": status,
        "focused": focused,
        "agent": "claude",
        "cwd": "/Users/bobnadler/dev/instinct/kong-fu",
        "terminal_title_stripped": "Fix Jira POPS-1937",
    }


def raised(alerts):
    """Flatten alerts to (pane, kind) pairs for assertions."""
    return [(entry["pane_id"], kind) for entry, kind in alerts]


# --- blocked ---------------------------------------------------------------


def test_blocked_agent_is_not_alerted_before_the_threshold():
    alerts, _ = agent_alerts.decide_alerts([agent("blocked")], {}, now=1000.0)

    assert raised(alerts) == []


def test_blocked_agent_is_alerted_once_the_threshold_passes():
    _, state = agent_alerts.decide_alerts([agent("blocked")], {}, now=1000.0)

    later = 1000.0 + agent_alerts.BLOCKED_AFTER_SECONDS
    alerts, _ = agent_alerts.decide_alerts([agent("blocked")], state, now=later)

    assert raised(alerts) == [("wQ:pQ", "blocked")]


def test_blocked_agent_is_not_alerted_twice_for_one_episode():
    _, state = agent_alerts.decide_alerts([agent("blocked")], {}, now=1000.0)
    later = 1000.0 + agent_alerts.BLOCKED_AFTER_SECONDS
    _, state = agent_alerts.decide_alerts([agent("blocked")], state, now=later)

    alerts, _ = agent_alerts.decide_alerts([agent("blocked")], state, now=later + 600.0)

    assert raised(alerts) == []


def test_answering_a_prompt_starts_a_fresh_episode():
    _, state = agent_alerts.decide_alerts([agent("blocked")], {}, now=1000.0)
    later = 1000.0 + agent_alerts.BLOCKED_AFTER_SECONDS
    _, state = agent_alerts.decide_alerts([agent("blocked")], state, now=later)

    # Answered, so the pane goes back to work and blocks again on a later prompt.
    _, state = agent_alerts.decide_alerts([agent("working")], state, now=later + 10.0)
    _, state = agent_alerts.decide_alerts([agent("blocked")], state, now=later + 20.0)
    alerts, _ = agent_alerts.decide_alerts(
        [agent("blocked")], state, now=later + 20.0 + agent_alerts.BLOCKED_AFTER_SECONDS
    )

    assert raised(alerts) == [("wQ:pQ", "blocked")]


def test_a_focused_pane_still_alerts():
    # herdr's `focused` is its own internal focus, not the terminal's, so it
    # stays true after you walk away from the machine. Treating it as "you are
    # watching this" silences the exact case the alert exists for: an agent
    # left blocked on a pane that happens to be the focused one.
    _, state = agent_alerts.decide_alerts(
        [agent("blocked", focused=True)], {}, now=1000.0
    )

    later = 1000.0 + agent_alerts.BLOCKED_AFTER_SECONDS
    alerts, _ = agent_alerts.decide_alerts(
        [agent("blocked", focused=True)], state, now=later
    )

    assert raised(alerts) == [("wQ:pQ", "blocked")]


def test_an_untracked_status_does_not_re_arm_an_alerted_pane():
    # `unknown` is reachable when detection fails. Dropping the pane from state
    # would lose the alerted flag and fire a second time for the same episode.
    _, state = agent_alerts.decide_alerts([agent("blocked")], {}, now=1000.0)
    later = 1000.0 + agent_alerts.BLOCKED_AFTER_SECONDS
    _, state = agent_alerts.decide_alerts([agent("blocked")], state, now=later)

    _, state = agent_alerts.decide_alerts([agent("unknown")], state, now=later + 10.0)
    _, state = agent_alerts.decide_alerts([agent("blocked")], state, now=later + 20.0)

    # Far enough past the blip that a re-armed episode would have fired.
    alerts, _ = agent_alerts.decide_alerts(
        [agent("blocked")], state, now=later + 20.0 + agent_alerts.BLOCKED_AFTER_SECONDS
    )

    assert raised(alerts) == []


# --- finished --------------------------------------------------------------
#
# herdr has a `done` status, but no detection rule for Claude ever produces it:
# a finished pane reports `idle`. Completion is therefore the working -> idle
# transition, which only a poller that remembers the previous status can see.


def test_an_agent_that_stops_working_is_alerted_as_finished():
    _, state = agent_alerts.decide_alerts([agent("working")], {}, now=1000.0)

    alerts, _ = agent_alerts.decide_alerts([agent("idle")], state, now=1060.0)

    assert raised(alerts) == [("wQ:pQ", "finished")]


def test_a_pane_already_idle_when_polling_starts_is_not_a_completion():
    # Every pane is idle on the first poll after a reboot. Alerting on idle
    # itself would fire for all of them, for work finished hours ago.
    alerts, state = agent_alerts.decide_alerts([agent("idle")], {}, now=1000.0)

    still_idle, _ = agent_alerts.decide_alerts([agent("idle")], state, now=1060.0)

    assert raised(alerts) == []
    assert raised(still_idle) == []


def test_a_finished_agent_is_alerted_only_once():
    _, state = agent_alerts.decide_alerts([agent("working")], {}, now=1000.0)
    _, state = agent_alerts.decide_alerts([agent("idle")], state, now=1060.0)

    alerts, _ = agent_alerts.decide_alerts([agent("idle")], state, now=1120.0)

    assert raised(alerts) == []


def test_finishing_alerts_even_after_the_same_pane_was_alerted_blocked():
    _, state = agent_alerts.decide_alerts([agent("blocked")], {}, now=1000.0)
    later = 1000.0 + agent_alerts.BLOCKED_AFTER_SECONDS
    blocked, state = agent_alerts.decide_alerts([agent("blocked")], state, now=later)

    # Answered, works on, then finishes.
    _, state = agent_alerts.decide_alerts([agent("working")], state, now=later + 10.0)
    finished, _ = agent_alerts.decide_alerts([agent("idle")], state, now=later + 70.0)

    assert raised(blocked) == [("wQ:pQ", "blocked")]
    assert raised(finished) == [("wQ:pQ", "finished")]


def test_a_completion_survives_a_permission_prompt_at_a_poll_boundary():
    # The ordinary Claude flow: works, asks to run something, is approved,
    # finishes. A poll landing on the prompt makes the last seen status
    # `blocked` rather than `working`, and that must still read as finished.
    _, state = agent_alerts.decide_alerts([agent("working")], {}, now=1000.0)
    _, state = agent_alerts.decide_alerts([agent("blocked")], state, now=1060.0)

    alerts, _ = agent_alerts.decide_alerts([agent("idle")], state, now=1120.0)

    assert raised(alerts) == [("wQ:pQ", "finished")]


def test_a_stale_observation_is_not_read_as_a_completion():
    # Laptop sleeps with a pane working and wakes the next morning. The pane is
    # idle now, but the working reading is hours old and says nothing about
    # when it stopped.
    _, state = agent_alerts.decide_alerts([agent("working")], {}, now=1000.0)

    tomorrow = 1000.0 + 16 * 60 * 60
    alerts, _ = agent_alerts.decide_alerts([agent("idle")], state, now=tomorrow)

    assert raised(alerts) == []


def test_a_long_detection_outage_is_not_read_as_a_completion():
    # The mirror of the case above, on a machine that stayed awake. Detection
    # failed for an hour, so every poll in that hour read `unknown`. The pane
    # is idle now, but the last real `working` reading is an hour old and says
    # no more about when the agent stopped than a reading across a sleep does.
    _, state = agent_alerts.decide_alerts([agent("working")], {}, now=1000.0)

    now = 1000.0
    for _ in range(60):
        now += 60.0
        _, state = agent_alerts.decide_alerts([agent("unknown")], state, now=now)

    alerts, _ = agent_alerts.decide_alerts([agent("idle")], state, now=now + 60.0)

    assert raised(alerts) == []


def test_a_pane_blocked_across_a_sleep_still_alerts():
    # The counterpart to the two staleness cases above: a stale `working`
    # reading is a guess, but a pane that is still blocked is still blocked,
    # however long the gap.
    _, state = agent_alerts.decide_alerts([agent("blocked")], {}, now=1000.0)

    tomorrow = 1000.0 + 16 * 60 * 60
    alerts, _ = agent_alerts.decide_alerts([agent("blocked")], state, now=tomorrow)

    assert raised(alerts) == [("wQ:pQ", "blocked")]


def test_an_entry_with_no_status_does_not_stop_the_poll():
    # herdr is a separate tool with its own release channel, and thus its
    # reply can change. An entry that this script cannot read must not stop
    # the poll, because a poll that stops writes no state, and the next poll
    # then reads the same reply and stops in the same manner.
    alerts, state = agent_alerts.decide_alerts(
        [{"pane_id": "wA:p1"}, agent("blocked", pane_id="wB:p2")], {}, now=1000.0
    )

    assert raised(alerts) == []
    assert state.keys() == {"wB:p2"}


def test_each_pane_is_judged_independently():
    working_pair = [
        agent("working", pane_id="wA:p1"),
        agent("working", pane_id="wB:p2"),
    ]
    _, state = agent_alerts.decide_alerts(working_pair, {}, now=1000.0)

    alerts, _ = agent_alerts.decide_alerts(
        [agent("idle", pane_id="wA:p1"), agent("working", pane_id="wB:p2")],
        state,
        now=1060.0,
    )

    assert raised(alerts) == [("wA:p1", "finished")]


# --- message formatting ----------------------------------------------------


def test_a_blocked_alert_names_the_agent_and_the_repo():
    payload = agent_alerts.format_alert(agent("blocked"), "blocked")

    assert payload["headline"] == "🔴 Claude is blocked in kong-fu"
    assert payload["body"] == "Fix Jira POPS-1937\n`herdr agent focus wQ:pQ`"


def test_a_finished_alert_uses_the_finished_mark_and_verb():
    payload = agent_alerts.format_alert(agent("idle"), "finished")

    assert payload["headline"] == "✅ Claude finished in kong-fu"


def test_a_worktree_is_named_for_its_repo_not_its_branch():
    # Real cwd from this machine. The leaf is the branch, and naming the alert
    # after it buries which repo is actually stuck.
    in_worktree = agent("blocked")
    in_worktree["cwd"] = (
        "/Users/bobnadler/dev/instinct/kong-fu.worktrees/feature-POPS-1937-kf-cleanup"
    )

    payload = agent_alerts.format_alert(in_worktree, "blocked")

    assert payload["headline"] == "🔴 Claude is blocked in kong-fu"


def test_a_hyphenated_agent_kind_reads_as_words():
    kimi = agent("idle")
    kimi["agent"] = "kimi-code"

    payload = agent_alerts.format_alert(kimi, "finished")

    assert payload["headline"] == "✅ Kimi Code finished in kong-fu"


def test_an_untitled_pane_leaves_no_blank_first_line():
    untitled = agent("blocked")
    untitled["terminal_title_stripped"] = ""

    payload = agent_alerts.format_alert(untitled, "blocked")

    assert payload["body"] == "`herdr agent focus wQ:pQ`"


# --- inputs and credentials ------------------------------------------------


def test_the_environment_overrides_the_url_file(tmp_path, monkeypatch):
    url_file = tmp_path / "slack-trigger-url"
    url_file.write_text("https://hooks.slack.com/triggers/from-file\n")
    monkeypatch.setenv(
        "HERDR_SLACK_TRIGGER_URL", "https://hooks.slack.com/triggers/env"
    )

    assert (
        agent_alerts.resolve_trigger_url(url_file)
        == "https://hooks.slack.com/triggers/env"
    )


def test_the_url_file_is_read_when_the_environment_is_unset(tmp_path, monkeypatch):
    url_file = tmp_path / "slack-trigger-url"
    url_file.write_text("https://hooks.slack.com/triggers/from-file\n")
    monkeypatch.delenv("HERDR_SLACK_TRIGGER_URL", raising=False)

    assert (
        agent_alerts.resolve_trigger_url(url_file)
        == "https://hooks.slack.com/triggers/from-file"
    )


def test_no_url_anywhere_resolves_to_nothing(tmp_path, monkeypatch):
    monkeypatch.delenv("HERDR_SLACK_TRIGGER_URL", raising=False)

    assert agent_alerts.resolve_trigger_url(tmp_path / "absent") is None


def test_output_that_cannot_be_read_is_not_an_empty_agent_list():
    # The distinction carries the alert-once guarantee. Reading a failed poll
    # as "no agents" clears every pane's history, and the next poll re-alerts.
    assert agent_alerts.parse_agents("") is None
    assert agent_alerts.parse_agents("herdr: command not found") is None


def test_a_genuinely_empty_session_reads_as_no_agents():
    assert agent_alerts.parse_agents(listing()) == []


def test_agents_are_read_out_of_the_result_envelope():
    stdout = listing({"agent": "claude", "agent_status": "idle", "pane_id": "wQ:pQ"})

    assert agent_alerts.parse_agents(stdout) == [
        {"agent": "claude", "agent_status": "idle", "pane_id": "wQ:pQ"}
    ]


def test_a_herdr_that_exits_nonzero_reports_failure(monkeypatch):
    def failed_run(*args, **kwargs):
        return subprocess.CompletedProcess(args, returncode=1, stdout="", stderr="boom")

    monkeypatch.setattr(agent_alerts.subprocess, "run", failed_run)

    assert agent_alerts.read_agent_list() is None


# --- state -----------------------------------------------------------------


def test_the_first_poll_starts_from_empty_state(tmp_path):
    assert agent_alerts.load_state(tmp_path / "absent.json") == {}


def test_a_replace_failure_leaves_the_previous_state_and_no_litter(
    tmp_path, monkeypatch
):
    # `update_symlinks.sh` boots the job out on every run, so the poller can be
    # killed at any point, including mid-write. A write that truncates the file
    # first leaves invalid JSON, which reads back as no state at all: every pane
    # loses its `alerted` flag and the next poll repeats every alert.
    #
    # The atomicity of os.replace cannot be tested in this process. This test
    # covers what it can: the failure path keeps the previous file and removes
    # the temporary one.
    state_file = tmp_path / "state.json"
    _, first = agent_alerts.decide_alerts([agent("blocked")], {}, now=1000.0)
    agent_alerts.save_state(state_file, first)

    _, second = agent_alerts.decide_alerts([agent("working")], first, now=1060.0)

    def killed(*args):
        raise OSError("killed mid-write")

    monkeypatch.setattr(agent_alerts.os, "replace", killed)
    with pytest.raises(OSError):
        agent_alerts.save_state(state_file, second)

    assert agent_alerts.load_state(state_file) == first
    assert [path.name for path in tmp_path.iterdir()] == ["state.json"]


def test_a_state_file_that_is_not_an_object_does_not_stop_the_poll(tmp_path):
    # Valid JSON, and thus no JSONDecodeError, but there are no panes in it.
    state_file = tmp_path / "state.json"
    state_file.write_text("[]")

    assert agent_alerts.load_state(state_file) == {}


def test_a_state_file_of_unreadable_bytes_does_not_stop_the_poll(tmp_path):
    # A file that is not UTF-8 stops at the read, before the JSON parser.
    state_file = tmp_path / "state.json"
    state_file.write_bytes(b'{"wQ:pQ": "\xff\xfe"}')

    assert agent_alerts.load_state(state_file) == {}


def test_state_from_a_different_shape_of_the_script_is_thrown_away(
    tmp_path, monkeypatch, capsys
):
    # The state file stays on disk while the script changes, and the launchd
    # job runs the script from the repository. Thus an edit goes live in less
    # than a minute, with the state that the previous shape wrote. Such a file
    # must not stop the poll: a poll that stops never writes the file again,
    # and the poller then fails at each cycle until a person removes the file.
    #
    # This is a record of a real event. `last_seen` became `last_tracked`, and
    # the poller made 35 tracebacks in 35 minutes, in silence.
    state_file = tmp_path / "state.json"
    state_file.write_text(
        json.dumps(
            {
                "wQ:pQ": {
                    "status": "working",
                    "since": 1000.0,
                    "alerted": False,
                    "last_seen": 1000.0,
                }
            }
        )
    )
    monkeypatch.setattr(agent_alerts, "STATE_FILE", state_file)
    monkeypatch.setattr(agent_alerts, "TRIGGER_URL_FILE", tmp_path / "no-url")
    monkeypatch.delenv("HERDR_SLACK_TRIGGER_URL", raising=False)
    monkeypatch.setattr(agent_alerts, "read_agent_list", lambda: listing(agent("idle")))

    agent_alerts.main()
    written = capsys.readouterr()

    # The pane is new to this shape of the script, exactly as after a restart,
    # so the poll says nothing about work it never watched. The log gets a
    # line, because a poll that throws the state away at each cycle reports
    # nothing at all, and is thus as quiet as a script that does not run.
    assert written.out == ""
    assert "Discarded state" in written.err

    # The poll went on and wrote the state, and thus a completion that comes
    # after it still gives an alert.
    monkeypatch.setattr(
        agent_alerts, "read_agent_list", lambda: listing(agent("working"))
    )
    agent_alerts.main()
    monkeypatch.setattr(agent_alerts, "read_agent_list", lambda: listing(agent("idle")))
    agent_alerts.main()

    assert "Claude finished in kong-fu" in capsys.readouterr().out


def test_state_survives_a_round_trip_to_disk(tmp_path):
    state_file = tmp_path / "nested" / "state.json"
    _, state = agent_alerts.decide_alerts([agent("blocked")], {}, now=1000.0)

    agent_alerts.save_state(state_file, state)

    later = 1000.0 + agent_alerts.BLOCKED_AFTER_SECONDS
    alerts, _ = agent_alerts.decide_alerts(
        [agent("blocked")], agent_alerts.load_state(state_file), now=later
    )
    assert raised(alerts) == [("wQ:pQ", "blocked")]


# --- the whole poll --------------------------------------------------------


def test_a_failed_poll_does_not_re_arm_an_already_alerted_pane(tmp_path, monkeypatch):
    monkeypatch.setattr(agent_alerts, "STATE_FILE", tmp_path / "state.json")
    monkeypatch.setattr(agent_alerts, "TRIGGER_URL_FILE", tmp_path / "no-url")
    monkeypatch.delenv("HERDR_SLACK_TRIGGER_URL", raising=False)

    monkeypatch.setattr(
        agent_alerts, "read_agent_list", lambda: listing(agent("working"))
    )
    agent_alerts.main()
    monkeypatch.setattr(agent_alerts, "read_agent_list", lambda: listing(agent("idle")))
    agent_alerts.main()

    # herdr restarts, so the next poll cannot be answered at all.
    monkeypatch.setattr(agent_alerts, "read_agent_list", lambda: None)
    agent_alerts.main()

    # The pane is still there and still idle once herdr is back.
    monkeypatch.setattr(agent_alerts, "read_agent_list", lambda: listing(agent("idle")))
    printed = []
    monkeypatch.setattr("builtins.print", lambda *a, **k: printed.append(a))
    agent_alerts.main()

    assert printed == []


def test_a_resolved_url_receives_the_formatted_payload(tmp_path, monkeypatch):
    # The other whole-poll tests all run with no URL, which is the branch that
    # prints instead of sending. Without this test, a poll that stops sending
    # to Slack keeps each of them green.
    monkeypatch.setattr(agent_alerts, "STATE_FILE", tmp_path / "state.json")
    monkeypatch.setenv("HERDR_SLACK_TRIGGER_URL", "https://example.test/trigger")

    sent = []
    monkeypatch.setattr(
        agent_alerts, "post_alert", lambda url, payload: sent.append((url, payload))
    )

    monkeypatch.setattr(
        agent_alerts, "read_agent_list", lambda: listing(agent("working"))
    )
    agent_alerts.main()
    monkeypatch.setattr(agent_alerts, "read_agent_list", lambda: listing(agent("idle")))
    agent_alerts.main()

    assert sent == [
        (
            "https://example.test/trigger",
            {
                "headline": "✅ Claude finished in kong-fu",
                "body": "Fix Jira POPS-1937\n`herdr agent focus wQ:pQ`",
            },
        )
    ]


def test_an_unexpected_send_failure_still_records_the_poll(tmp_path, monkeypatch):
    # `urlopen` raises more than the errors that the loop names: the classes
    # in http.client for a bad reply are not OSError. The state must land
    # whatever stops the send, or each alert of the poll goes out again at the
    # next poll. One alert that is lost is better than an alert that repeats.
    monkeypatch.setattr(agent_alerts, "STATE_FILE", tmp_path / "state.json")
    monkeypatch.setenv("HERDR_SLACK_TRIGGER_URL", "https://example.test/trigger")
    monkeypatch.setattr(
        agent_alerts, "read_agent_list", lambda: listing(agent("working"))
    )
    agent_alerts.main()

    def exploded(url, payload):
        raise http.client.BadStatusLine("")

    monkeypatch.setattr(agent_alerts, "post_alert", exploded)
    monkeypatch.setattr(agent_alerts, "read_agent_list", lambda: listing(agent("idle")))
    with pytest.raises(http.client.BadStatusLine):
        agent_alerts.main()

    sent = []
    monkeypatch.setattr(
        agent_alerts, "post_alert", lambda url, payload: sent.append(payload)
    )
    agent_alerts.main()

    assert sent == []


def test_one_unformattable_agent_does_not_lose_the_whole_poll(
    tmp_path, monkeypatch, capsys
):
    # If one entry has no `cwd`, the message for it cannot be made. An abort
    # there also stops the poll before it writes the state, so the good pane
    # alerts again at each poll that follows.
    monkeypatch.setattr(agent_alerts, "STATE_FILE", tmp_path / "state.json")
    monkeypatch.setattr(agent_alerts, "TRIGGER_URL_FILE", tmp_path / "no-url")
    monkeypatch.delenv("HERDR_SLACK_TRIGGER_URL", raising=False)

    good = agent("working", pane_id="wA:p1")
    bad = agent("working", pane_id="wB:p2")
    del bad["cwd"]

    def polls(status):
        return lambda: listing(
            dict(good, agent_status=status), dict(bad, agent_status=status)
        )

    monkeypatch.setattr(agent_alerts, "read_agent_list", polls("working"))
    agent_alerts.main()
    monkeypatch.setattr(agent_alerts, "read_agent_list", polls("idle"))
    agent_alerts.main()
    first = capsys.readouterr()

    agent_alerts.main()
    second = capsys.readouterr()

    assert "Claude finished in kong-fu" in first.out
    assert "wB:p2" in first.err
    assert second.out == ""


def test_a_malformed_trigger_url_never_reaches_the_log(tmp_path, monkeypatch, capsys):
    # The log is world readable and the URL is a credential, so a bad file must
    # not be echoed back through the failure message.
    secret = "not-a-url-but-still-a-secret"
    url_file = tmp_path / "slack-trigger-url"
    url_file.write_text(secret)
    monkeypatch.setattr(agent_alerts, "TRIGGER_URL_FILE", url_file)
    monkeypatch.setattr(agent_alerts, "STATE_FILE", tmp_path / "state.json")
    monkeypatch.delenv("HERDR_SLACK_TRIGGER_URL", raising=False)

    monkeypatch.setattr(
        agent_alerts, "read_agent_list", lambda: listing(agent("working"))
    )
    agent_alerts.main()
    monkeypatch.setattr(agent_alerts, "read_agent_list", lambda: listing(agent("idle")))
    agent_alerts.main()

    written = capsys.readouterr()
    assert secret not in written.out + written.err
