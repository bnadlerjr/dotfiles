#!/usr/bin/env -S uv run --quiet --script
# /// script
# requires-python = ">=3.8"
# dependencies = []
# ///

r"""Send a Slack alert if a herdr agent stays blocked, or if an agent stops.

Start this script from a timer (launchd). Do not start it from a herdr plugin
event. The script reads the status at each poll. It does not react to events.

A poll makes the threshold of five minutes possible at a low cost. An event
handler must continue to operate for the full five minutes. If the handler
stops before that time, the script loses the alert. No other process shows
the loss. A poll reads the status that is already on disk. If one poll does
not operate, the script loses one interval only.

A poll also prevents a second problem with the `blocked` status. That status
changes at each permission prompt. A handler that starts at each change needs
a time window to prevent too many messages. A poll examines the status of a
pane only after the threshold passes. Therefore the script ignores a prompt
that you answer at the keyboard.

Completion is different. Completion is the change from `working` to `idle`
between two polls. No detection rule gives herdr's `done` status for a Claude
pane. To find the change, the script must keep the status from the previous
poll. This is the reason that the state stays on disk between two runs.

Setup
-----

1. Install the timer. All the steps that follow need it. `update_symlinks.sh`
   makes a symlink from the plist in `herdr/launchd/` to
   ~/Library/LaunchAgents, and then reloads the launchd job. The job starts
   this script every 60 seconds. This applies to macOS only, and other
   operating systems do not do this step.

   No other procedure starts the job. Before this step, the script operates
   only when you start it at the keyboard. A new symlink is not enough,
   because launchd keeps the definition from the first bootstrap. This is the
   reason that `update_symlinks.sh` reloads the job.

2. Make the Slack workflow. In Workflow Builder, start a workflow "From a
   webhook". Give the workflow two Text variables: `headline` and `body`.
   `format_alert` gives these two keys.

   Add the step "Send a message to a person". Put your name in that step. Put
   the two values in the message with the button "Insert a variable".
   Workflow Builder does not replace text in a template. If you type
   `{headline}`, Workflow Builder keeps those characters.

   Publish the workflow. If you do not publish the workflow, the trigger
   refuses each request with `workflow_not_published`. Publish the workflow
   again after each change.

3. Keep the trigger URL that Slack gives you when you publish:

       op read "op://<vault-item>" \
           > ~/.config/herdr/slack-trigger-url
       chmod 600 ~/.config/herdr/slack-trigger-url

   Each person who has that URL can send messages to the DM. This repository
   is public. Therefore the URL stays out of it.
   `HERDR_SLACK_TRIGGER_URL` replaces the file for one run.

4. Examine the result before you use the script. If there is no URL, the
   script prints the payload and sends no message. Therefore a test run is
   safe:

       ./agent_alerts.py
"""

import json
import os
import subprocess
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path

SUBPROCESS_TIMEOUT_SECONDS = 10
HTTP_TIMEOUT_SECONDS = 10

# Keep this file out of the repository, because the trigger URL is a
# credential and this tree is public. Make the file with
# `op read ... > ~/.config/herdr/slack-trigger-url` and `chmod 600`.
TRIGGER_URL_FILE = Path.home() / ".config" / "herdr" / "slack-trigger-url"

STATE_FILE = (
    Path(os.environ.get("XDG_STATE_HOME") or Path.home() / ".local" / "state")
    / "herdr-agent-alerts"
    / "state.json"
)

# Workflow Builder shows a fixed template with a slot for each variable.
# Therefore this script makes the full message. The words and the emoji stay
# in a file that you can compare and test, and you do not have to change
# Slack again.
MARKS = {"blocked": "🔴", "finished": "✅"}
VERBS = {"blocked": "is blocked in", "finished": "finished in"}

# The text that worktrunk adds to the name of a repository directory when it
# puts the worktrees adjacent to that directory.
WORKTREE_SUFFIX = ".worktrees"

# The time that a pane must stay blocked before Slack gets a message. The
# time is long enough to prevent a message about a prompt that you answer at
# the keyboard.
BLOCKED_AFTER_SECONDS = 300.0

# The statuses that give information. `unknown` shows that detection failed,
# and a failure of detection gives no information about the agent. Therefore
# `unknown` is not in this list. herdr's `done` status is also not in this
# list, because no rule gives it. The module docstring gives the reason.
TRACKED_STATUSES = ("blocked", "working", "idle")

# The maximum age of the previous observation of a pane. An older observation
# does not allow a statement about the time between that observation and this
# one. The value is three intervals of the launchd job. Therefore one poll
# that does not operate is acceptable, and one cycle with a failure of
# detection is also acceptable. A full night is not acceptable.
OBSERVATION_STALE_AFTER_SECONDS = 180.0


def decide_alerts(agents, prior_state, now):
    """Give the agents to alert on, and the state for the next poll.

    `agents` is the result of `herdr agent list`. `prior_state` is the state
    from the previous call. Do not examine `prior_state`. Keep it, and give
    it to the next call.
    """
    alerts = []
    next_state = {}

    for entry in agents:
        # herdr is a separate tool with its own release channel, and thus its
        # reply can change. An entry with no status is not in
        # TRACKED_STATUSES, and it drops out below. A failure of detection
        # has the same result.
        status = entry.get("agent_status")
        pane_id = entry.get("pane_id")
        prior = prior_state.get(pane_id)

        if status not in TRACKED_STATUSES:
            # Detection failed in this cycle, and a failure is not new
            # information about the agent. The script keeps the previous
            # observation and its time. Therefore a short failure does not
            # end a period and does not allow a second alert. A long failure
            # makes the observation stale, in the same way as a sleep.
            if prior is not None:
                next_state[pane_id] = prior
            continue

        was = prior["status"] if prior else None

        if was != status:
            since, alerted = now, False
        else:
            since, alerted = prior["since"], prior["alerted"]

        kind = None
        if prior is not None and not alerted:
            # A pane that this poll finds for the first time gives no event.
            # It held its status for no time, and it has no previous status
            # that an agent can complete from.
            kind = alert_kind(was, status, now - since, now - prior["last_tracked"])
        if kind:
            alerted = True
            alerts.append((entry, kind))

        # Each pane goes in the state, also a pane with a status that causes
        # no alert. A pane that the state does not keep loses its `alerted`
        # flag, and a period that is complete can then send a second alert.
        next_state[pane_id] = {
            "status": status,
            "since": since,
            "alerted": alerted,
            "last_tracked": now,
        }

    return alerts, next_state


def alert_kind(was, status, held_for, since_last_tracked):
    """Give the name of the event for a pane, or None if there is no event."""
    if status == "blocked" and held_for >= BLOCKED_AFTER_SECONDS:
        # There is no test of the age here. A pane that is still blocked
        # stays blocked, whatever the time of the previous poll.
        return "blocked"

    if status != "idle" or was not in ("working", "blocked"):
        # Completion is the change to `idle`, and not the `idle` status. A
        # pane that was idle at the previous poll also stopped before that
        # poll. Therefore that pane is not new information.
        return None

    if since_last_tracked > OBSERVATION_STALE_AFTER_SECONDS:
        # The machine went to sleep, or herdr did not operate, or detection
        # failed for many cycles. The pane is idle now, but the script found
        # `working` many hours ago. That observation gives no information
        # about the time when the agent stopped.
        return None
    return "finished"


def format_alert(entry, kind):
    """Make the two Slack variables for one agent.

    This function uses `kind` and not the status of the pane, because a pane
    that completed shows `idle`. No data in the entry shows that the agent
    stopped.
    """
    name = (entry.get("agent") or "agent").replace("-", " ").replace("_", " ").title()

    # A pane id such as `wN:pY` is a handle, and not a number in a sequence.
    # Therefore it gives no information to a person who reads Slack. The id
    # is of use only in `herdr agent focus`. Therefore the message gives the
    # full command, which you can copy at the keyboard, and not the bare id.
    command = f"`herdr agent focus {entry['pane_id']}`"
    title = entry.get("terminal_title_stripped")

    return {
        "headline": f"{MARKS[kind]} {name} {VERBS[kind]} {repo_name(entry['cwd'])}",
        "body": f"{title}\n{command}" if title else command,
    }


def repo_name(cwd):
    """Give the name of the repository for a pane, also for a worktree.

    worktrunk puts a checkout in an adjacent `<repo>.worktrees/<branch>`
    directory. Therefore the last directory is the name of a branch. A name
    from the branch does not show which repository has the problem, and
    branch names are longer than repository names.
    """
    directory = Path(cwd)
    if directory.parent.name.endswith(WORKTREE_SUFFIX):
        return directory.parent.name[: -len(WORKTREE_SUFFIX)]
    return directory.name


def resolve_trigger_url(url_file):
    """Find the Slack trigger URL, or give None if there is no URL.

    launchd cannot answer a prompt from 1Password to unlock the vault.
    Therefore the script cannot read the URL with `op` at the time of the
    poll. A file with mode 600 is the only other method.
    """
    from_environment = os.environ.get("HERDR_SLACK_TRIGGER_URL")
    if from_environment:
        return from_environment

    try:
        return url_file.read_text().strip() or None
    except OSError:
        return None


def parse_agents(stdout):
    """Get the list of agents from a reply to `herdr agent list`.

    This function gives None if it cannot read the reply. A reply that the
    script cannot read is different from a session with no agents: a poll
    with no reply must keep the state, but a poll with no agents must clear
    the state.

    The list is in `result`. If you read the top level, each poll gives
    nothing and shows no explanation.
    """
    try:
        return json.loads(stdout)["result"]["agents"]
    except (json.JSONDecodeError, KeyError, TypeError):
        if stdout:
            print(f"Unreadable agent list: {stdout[:200]}", file=sys.stderr)
        return None


def load_state(state_file):
    """Read the state from the previous poll, or start with no state.

    This function does not examine the entries. `main` removes a state that
    it cannot read, and therefore this function does not test the shape of an
    entry.
    """
    try:
        state = json.loads(state_file.read_text())
    except (OSError, ValueError):
        # ValueError covers the syntax of the JSON. ValueError also covers
        # the characters of the file, as UnicodeDecodeError.
        return {}

    return state if isinstance(state, dict) else {}


def save_state(state_file, state):
    """Put the state on disk in one step that a stop cannot interrupt.

    A direct write makes the file empty before it puts the new data in the
    file. If the poller stops in that interval, the file keeps only a part of
    the data, and that file reads as no state. Each pane then loses its
    `alerted` flag, and the next poll sends each alert a second time. A write
    to a different file and a rename prevent this, because the rename either
    occurs or does not occur.

    There is no `fsync` here. Therefore a loss of power can still give a file
    with the new name and the old data. One poll makes the state again, and
    that risk needs no more code.
    """
    state_file.parent.mkdir(parents=True, exist_ok=True)
    payload = json.dumps(state)

    temporary = state_file.with_name(state_file.name + ".new")
    try:
        temporary.write_text(payload)
        os.replace(temporary, state_file)
    except OSError:
        temporary.unlink(missing_ok=True)
        raise


def read_agent_list():
    """Ask herdr for its agents, or give None if the script cannot ask."""
    try:
        completed = subprocess.run(
            ["herdr", "agent", "list"],
            capture_output=True,
            text=True,
            timeout=SUBPROCESS_TIMEOUT_SECONDS,
            check=False,
        )
    except (OSError, subprocess.SubprocessError):
        return None

    if completed.returncode != 0:
        return None
    return completed.stdout


def post_alert(url, payload):
    """Send one flat object to a Workflow Builder trigger with POST."""
    request = urllib.request.Request(
        url,
        data=json.dumps(payload).encode(),
        headers={"Content-Type": "application/json"},
    )
    # urlopen makes an HTTPError if the reply is not 2xx, and that error is
    # the only signal that the caller uses. Therefore this function gives no
    # value.
    with urllib.request.urlopen(request, timeout=HTTP_TIMEOUT_SECONDS):
        pass


def send_alerts(alerts, trigger_url):
    """Send a Slack message for each alert, or print it if there is no URL."""
    for entry, kind in alerts:
        try:
            payload = format_alert(entry, kind)
        except (KeyError, TypeError, AttributeError) as error:
            # herdr gave an entry with a field that is absent or of the wrong
            # type. One such entry must not stop the loop, because the panes
            # after it in the list also lose their alerts.
            print(
                f"Cannot make an alert for {entry.get('pane_id')}: {error}",
                file=sys.stderr,
            )
            continue

        if not trigger_url:
            # No URL is a usual condition and not an error. The script
            # operates in this condition before you make the URL file. You
            # also use this condition when you examine the script at the
            # keyboard.
            print(json.dumps(payload, ensure_ascii=False))
            continue
        try:
            post_alert(trigger_url, payload)
        except ValueError:
            # Request() makes a ValueError for a bad URL, and the message
            # contains the URL. That URL is a credential, and all users can
            # read this log. Therefore the message stays out of the log.
            print("Slack post failed: trigger URL is malformed", file=sys.stderr)
        except (urllib.error.URLError, OSError) as error:
            print(f"Slack post failed: {error}", file=sys.stderr)


def main():
    trigger_url = resolve_trigger_url(TRIGGER_URL_FILE)

    agents = parse_agents(read_agent_list())
    if agents is None:
        # A poll that herdr could not answer is not a session with no agents.
        # If the script saves the empty state, it removes the history of each
        # pane. The next good poll then sends a second alert for the same
        # period.
        return 0

    now = time.time()
    try:
        alerts, state = decide_alerts(agents, load_state(STATE_FILE), now)
    except (KeyError, TypeError):
        # The state on disk has a shape that this script cannot read, because
        # the script changed and the file did not change. The launchd job
        # starts the script from the repository. Therefore each edit becomes
        # live in less than a minute. The file from the previous shape stays
        # on disk.
        #
        # One poll makes the state again. Therefore the file has no value and
        # needs no migration. The log line has a different purpose: a poll
        # that removes the state at each cycle gives no output, and a script
        # that does not operate also gives no output. The line shows which
        # one occurred.
        print("Discarded state that this script cannot read", file=sys.stderr)
        alerts, state = decide_alerts(agents, {}, now)

    try:
        send_alerts(alerts, trigger_url)
    finally:
        # The state goes to disk, also when an error stops the send
        # operation. The alternative is a queue for a second attempt, and one
        # alert that the script loses for each failure is the better choice.
        save_state(STATE_FILE, state)
    return 0


if __name__ == "__main__":
    sys.exit(main())
