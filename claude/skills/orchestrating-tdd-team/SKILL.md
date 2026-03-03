---
name: orchestrating-tdd-team
description: Orchestrates TDD teams with Agent Teams. Defines communication
  protocol, agent spawn configuration, and team-lead behavior. Use when
  creating or leading a TDD team with tester, engineer, and refactorer
  agents, or when someone mentions "TDD team", "agent team", or
  "orchestrate agents".
---

# Orchestrating TDD Teams

## Quick Start

Read this before spawning any agents. Four rules:

1. Spawn every agent with `mode: "acceptEdits"`
2. Include the Team Directory block in every agent prompt
3. Send one message per task assignment — never a "start" then details
4. After assigning work, stop — messages arrive automatically

## Team Roles

| Name | Phase | File Scope | Hands Off To |
|------|-------|------------|--------------|
| `team-lead` | Orchestration | Any (read-only) | `tester` |
| `tester` | RED | `test/` only | `engineer` |
| `engineer` | GREEN | `lib/` only | `refactorer` |
| `refactorer` | REFACTOR | `lib/` only | `tester` |

One cycle: tester → engineer → refactorer → tester (next task).

## Spawning Agents

ALWAYS set `mode: "acceptEdits"` so agents can write files and run tests
without blocking on user permission prompts.

Agent tool parameters for each member:

```
name: "tester"
subagent_type: "general-purpose"
mode: "acceptEdits"
team_name: "<your-team-name>"
```

```
name: "engineer"
subagent_type: "general-purpose"
mode: "acceptEdits"
team_name: "<your-team-name>"
```

```
name: "refactorer"
subagent_type: "general-purpose"
mode: "acceptEdits"
team_name: "<your-team-name>"
```

Without `mode: "acceptEdits"`, agents cannot write files or run
`mix test` / `npm test` without blocking on user approval.

## Agent Prompt Requirements

Include this EXACT block in every agent prompt, after the identity section.
Replace `<your-team-name>` with the actual team name.

```markdown
## Team Directory (use EXACT names in SendMessage)
- `team-lead` — orchestrator, assigns tasks
- `tester` — RED phase, writes failing tests
- `engineer` — GREEN phase, makes tests pass
- `refactorer` — REFACTOR phase, improves code quality

CRITICAL: Use these exact strings as the `recipient` in SendMessage.
Never use "orchestrator", "lead", "refacterer", or any variation.
```

Why: without this block agents infer names from context and guess wrong
(`refacterer`, `orchestrator`, `@engineer`), causing misrouted messages
and multi-hour stalls.

### Domain Skill References

Each agent prompt should include a "Before Starting" section that directs
the agent to read the domain-appropriate skill for its role:

| Role | Skill to Read | Purpose |
|------|--------------|---------|
| `tester` | Testing skill (e.g., `testing-elixir`) | Test philosophy, assertions, patterns |
| `engineer` | Language skill (e.g., `developing-elixir`) | Idioms, conventions, GREEN phase |
| `refactorer` | Refactoring skill (`refactoring-code`) | Smell catalog, safe refactoring mechanics |

Example for the tester prompt:

```markdown
## Before Starting (MANDATORY)
Read before your first edit:
- `~/.claude/skills/testing-elixir/SKILL.md`

Consult skill references on-demand when the task involves specific areas.
```

The domain skills vary by project stack. The orchestration rules in this
skill do not — they apply regardless of language.

## Task Assignment Protocol

Send ONE message per task assignment containing ALL of:

1. Task number and subject
2. Files to read for context
3. What the agent should produce
4. Who to message when done (use exact name from directory)

Example:

```
Task #2: Write failing test for `Investigation.close/1`
Read: lib/lakitu/investigation.ex (lines 40-65)
Produce: test in test/lakitu/investigation_test.exs asserting that
  close/1 sets status to :closed and records closed_at timestamp
When done: message `team-lead` with the test file path and failure output
```

Before sending an assignment:
- Check if the agent already sent you a completion message
- If so, acknowledge their work instead of re-assigning

Do NOT send a brief "start" followed by a detailed message.
Do NOT send the same assignment twice.

## While Agents Work

After assigning work, messages from agents arrive AUTOMATICALLY.

Do NOT:
- Poll or check on agent status
- Send "still waiting" messages
- Generate turns to narrate the wait
- Use Bash/Read to check agent output files

Instead:
- Prepare upcoming tasks (create in task list, draft descriptions)
- Review completed work from previous phases
- End your turn — the next agent message will wake you

Every polling turn re-consumes the full context window and produces
nothing. 25-34 wasted turns per session have been observed.

## Error Recovery

**Silent agent** (no response within 5 minutes):

1. Send a single status-check message to the agent
2. If still no response after the check, re-send the assignment

**Agent failure** (agent reports an error or crashes):

1. Document completed and remaining work in the task list
2. Re-spawn ONLY the failed agent with the same prompt
3. Assign the failed agent's pending task to the new instance
4. Do NOT restart the entire team for a single agent failure

**Session recovery** (resuming after a full session failure):

1. Read the task list to identify completed vs. remaining work
2. Create a new team with the same structure
3. Skip completed tasks — assign only remaining work
4. Note in agent prompts which files already exist from prior work

## TDD Cycle Flow

```
┌─────────┐     ┌──────────┐     ┌────────────┐
│ tester   │────▶│ engineer │────▶│ refactorer │
│ (RED)    │     │ (GREEN)  │     │ (REFACTOR) │
└─────────┘     └──────────┘     └────────────┘
     ▲                                  │
     └──────────────────────────────────┘
                 next task
```

Each task goes through one full cycle:

1. `tester` writes a failing test, confirms it fails, messages `engineer`
2. `engineer` writes minimal code to pass, confirms green, messages `refactorer`
3. `refactorer` improves code quality, keeps tests green, messages `tester`
4. `tester` applies any test-side suggestions from `refactorer`
5. Task marked completed via TaskUpdate; next task begins at step 1

The team-lead assigns work to `tester` to start each cycle and monitors
phase transitions through automatic message delivery.

## Guidelines

### Do

- Create all tasks in the task list before spawning agents
- Spawn all three agents in a single message (parallel Agent tool calls)
- Wait for agent messages — they arrive automatically
- Use TaskUpdate to track task status through phases
- Keep agent prompts focused: identity + team directory + role instructions
- Acknowledge agent completion messages before assigning new work

### Don't

- Spawn agents without `mode: "acceptEdits"`
- Omit the Team Directory block from any agent prompt
- Send multiple messages for one assignment
- Poll, narrate waiting, or generate idle turns
- Restart the entire team when one agent fails
- Assign work outside an agent's file scope (see Team Roles table)
- Use agent UUIDs — always use names (`tester`, `engineer`, `refactorer`)
