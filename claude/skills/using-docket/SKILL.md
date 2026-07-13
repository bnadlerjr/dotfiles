---
name: using-docket
description: |
  Operate docket.exs, Bob's personal work-item tracker CLI, on the user's
  behalf: create work items, move them through their state machine, list and
  show items, block/unblock, link items to Jira/Linear ticket keys, and report
  dwell-time and cycle-time stats.

  Use on explicit request about the docket or personal work items — "what's on
  my docket", "add a work item", "move #3 to doing", "why is #5 blocked",
  "block #2 waiting on review", "docket stats", "show item 7", "list my items",
  "link #3 to INS-451", "move INS-451 to review", "what ticket is #3 tied to".
  Usage only: running commands and interpreting output. Does NOT author or edit
  machine definitions (machines/*.mmd) or the docket.exs source.
---

# Using docket

Run and interpret `docket.exs`, a personal work-item tracker backed by an append-only event log and named state machines (FSMs). Each item belongs to one machine and occupies one state; moves are validated against the machine's transitions.

## Core Principles

### Invoke `docket.exs` directly

It is on the user's PATH (symlinked at `~/bin/docket.exs`). Call it as `docket.exs <command>`. Never run it via `elixir` or a repo-relative path.

### One command per action, then read the output

Every command prints human-readable output and exits 0 on success or 1 on failure. Run the command, then relay what happened. Don't inspect the event log or machine files to reconstruct state — the CLI is the interface.

### Relay docket's own errors verbatim

When a command exits non-zero, docket writes a self-explanatory message to stderr (illegal transitions list the allowed next states; an unknown machine lists the available ones). Surface that message rather than guessing or working around it. Do not retry with mutated arguments.

## Command Reference

| Command | Purpose |
|---------|---------|
| `new <title> [-m machine] [-s state] [--ref key]` | Create an item. Title is the remaining words joined with spaces. `-m` is required only when more than one machine exists; `-s` must be an initial (entry) state, else it defaults to the machine's first initial. `--ref` links a ticket key at creation. |
| `move <id> <state>` | Transition item `<id>` to `<state>`, validated against its machine. |
| `list [--all] [-m machine]` | List active items. Hides items in a terminal state unless `--all`; `-m` filters to one machine. Groups by machine when more than one is present. |
| `show <id>` | Item header plus full state history with timestamps. |
| `link <id> <ref>` | Tie the item to a Jira/Linear ticket key (e.g. `INS-451`). Re-linking replaces the previous key — that is also the only way to correct one; there is no unlink. |
| `block <id> <reason...>` | Flag item as blocked with a reason (reason is required). Blocked is orthogonal metadata, not a state. |
| `unblock <id>` | Clear the blocked flag. |
| `graph` | Registry of machines: name, state count, item count, file path. |
| `graph <name>` | Print the raw Mermaid source of one machine. |
| `stats` | Per-state average dwell time; adds cycle-time stats when a machine declares a `%% cycle: a --> b` directive. |

### Item ids and ticket keys

Every command that takes an `<id>` accepts either the item number (optional `#` prefix: `3` or `#3`) or a linked ticket key in any case (`INS-451`, `ins-451`). A key resolves to the item currently linked to it; when several items share the key, the sole non-terminal one wins, and if that is still ambiguous docket errors listing the candidate ids — retry with an explicit id.

### Reading `list` output

Each row is `#<id>  [<key>]  <state>  <N>d  <title>` with `  [BLOCKED: reason]` appended when flagged. The `<key>` column appears only when at least one listed item is linked, and is blank for unlinked items. `<N>d` is days in the current state. Rows are ordered by the machine's state order, then id. Empty result prints `nothing here`.

### Success output shapes

- `new` → `#<id> [<key> ][<machine>/<state>] <title>` (key present only with `--ref`)
- `move` → `#<id> <old> -> <new>  (<title>)`
- `link` → `#<id> linked <KEY>  (<title>)`
- `block` → `#<id> blocked: <reason>`; `unblock` → `#<id> unblocked`
- `show` → `#<id> [<key> ]<title>  (<machine>: <state>[, BLOCKED: <reason>])` then one `  <ts>  -> <state>` line per history entry

## Examples

Create an item (single machine configured, so `-m` is optional):

```bash
docket.exs new Wire up the export endpoint
# #4 [work/todo] Wire up the export endpoint
```

Create in a specific machine at a non-default entry state:

```bash
docket.exs new Draft the RFC -m writing -s outline
```

Move an item (both forms of id accepted):

```bash
docket.exs move 3 doing
docket.exs move '#3' doing
# #3 todo -> doing  (Wire up the export endpoint)
```

See what's active, or everything including finished items:

```bash
docket.exs list
docket.exs list --all -m work
```

Link an item to its tracker ticket — at creation, or later once the ticket exists:

```bash
docket.exs new Wire up the export endpoint --ref POPS-1912
# #4 POPS-1912 [work/todo] Wire up the export endpoint
docket.exs link 4 pops-1912
# #4 linked POPS-1912  (Wire up the export endpoint)
```

Address an item by its ticket key instead of its id:

```bash
docket.exs move POPS-1912 review
docket.exs show pops-1912
```

Inspect one item's history, and understand why it's blocked:

```bash
docket.exs show 5
docket.exs block 5 waiting on API keys from vendor
docket.exs unblock 5
```

Survey machines and read one's definition:

```bash
docket.exs graph
docket.exs graph work
```

Report timing:

```bash
docket.exs stats
```

## Error Semantics

- **Illegal transition** — docket prints the allowed next states from the current state. Report them; do not attempt a different target unless the user picks one.
- **Unknown machine / unknown state** — docket lists the valid machines or states. Relay the list.
- **`-s` not an entry point** — docket lists the machine's initial states; pick one of those or omit `-s`.
- **`no item #<id>`** — the id doesn't exist. Suggest `list` or `list --all` to find the right id.
- **`not a ticket key`** — the ref given to `link` or `--ref` doesn't look like `ABC-123`. Relay the message; do not invent a key.
- **`no item with ref <KEY>`** — nothing is linked to that key. Suggest `list --all` to find the item and link it.
- **`<KEY> matches several items`** — docket lists the candidate ids. Ask the user which item they mean (or infer from context) and retry with the explicit id.
- **Corrupt event log** — docket raises with the offending `events.jsonl` line number. Relay it; this is a data-integrity issue, not a usage mistake.

## Ticket Refs

Refs are bare Jira/Linear ticket keys (`INS-451`, `ENG-123`) — never URLs or free text. Docket stores the key and nothing else; it does not talk to any tracker.

When the user asks about the *ticket* behind an item — its tracker status, comments, assignee, description — take the key from docket output and defer to the `managing-jira` or `managing-linear` skill. Do not enrich docket output with tracker data unprompted: docket commands report docket state only, and the user initiates every crossing to the tracker.

## Out of Scope

This skill runs docket; it does not shape it.

- **No machine authoring.** Do not create or edit `machines/*.mmd`. If the user wants to add states, transitions, or a new workflow, say that's outside this skill and point them at the machine files under `$DOCKET_DIR/machines/`.
- **No source edits.** Do not modify `docket.exs` itself.

If a command fails with **"no machines"**, no `.mmd` definitions exist yet — docket's own error output prints a template. Creating that file is the user's call (or a separate task), not something to do implicitly to satisfy a tracking request.

## Data Location (context only)

State lives in `$DOCKET_DIR` — default `$XDG_DATA_HOME/docket`, falling back to `~/.local/share/docket`. It holds `events.jsonl` (append-only log) and `machines/*.mmd`. Use this only to explain errors or locate machine files for the user; the CLI, not these files, is how you read and change items.
