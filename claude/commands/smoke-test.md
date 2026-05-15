---
description: Smoke-test the dev container — identity, symlinks, tools, sudo, firewall, mounts
allowed-tools: Bash
---

# Smoke Test

Run a comprehensive smoke test of the Claude Code dev container. Verifies identity/env, `~/.claude` symlinks, installed tooling, sudo least-privilege, firewall allow + deny lists, workspace bind-mount writability, and persistent volumes. Produces per-check evidence followed by a PASS/FAIL summary table.

## Instructions

- Run every check in order. Do not stop on first failure — collect all evidence.
- For each check, show the **command** you ran and its **literal output** (stdout/stderr, truncated only if absurdly long).
- Mark each check **PASS**, **FAIL**, or **SKIP** with a one-line rationale.
- **Do not attempt to fix anything.** This command diagnoses; it does not remediate.
- Use `command -v` (not `which`) for tool detection — POSIX-portable.
- All firewall checks use `curl -4 --connect-timeout 2 --max-time 5` to force IPv4 (the ipset is IPv4-only) and bound per-address attempts. The PASS criterion for denied egress is exit != 0 within `--max-time`; record the elapsed time as informational only — multi-record hosts iterate through addresses and will legitimately take longer than single-record hosts even with REJECT.
- End with the summary table from the Report section. Nothing else after it.

## Workflow

### 1. Identity & environment

```bash
whoami                          # expect: dotfiles
id                              # expect: uid=dotfiles, group=dotfiles
echo "$DEVCONTAINER | $CLAUDE_CONFIG_DIR | $EDITOR"
                                # expect: true | /home/dotfiles/.claude | nvim
pwd && ls /workspace            # /workspace exists, contains .devcontainer/ and claude/
```

### 2. Symlinks into `~/.claude`

For each of: `skills`, `commands`, `agents`, `guidelines`, `CLAUDE.md`, `settings.json`:

```bash
readlink -f ~/.claude/<name>
```

PASS = each resolves under `/workspace` **and** the target exists (`test -e`).

### 3. Tooling availability

For each tool: `claude`, `git`, `gh`, `rg`, `fd`, `fzf`, `jq`, `bat`, `nvim`, `tmux`, `uv`, `delta`:

```bash
command -v <tool> && <tool> --version 2>&1 | head -1
```

Flag any tool that is missing or exits non-zero.

### 4. Sudo least-privilege

```bash
sudo -n -l                      # should list ONLY /usr/local/bin/init-firewall.sh as NOPASSWD
sudo -n true                    # MUST FAIL — no blanket NOPASSWD
sudo -n /usr/local/bin/init-firewall.sh --help 2>&1 | head -1
                                # should attempt the script (script-level error is fine; sudo-level error is not)
```

### 5. Firewall — allowed egress

For each host below, run:

```bash
curl -4 -sS --connect-timeout 2 --max-time 5 -o /dev/null -w "%{http_code} %{time_total}s\n" https://<host>/
```

Hosts: `api.anthropic.com`, `api.github.com`, `registry.npmjs.org`, `pypi.org`, `files.pythonhosted.org`, `astral.sh`, `statsig.com`.

- **PASS** = curl exits 0 with any HTTP code (200/401/403/404 all fine — we're testing reachability, not auth).
- **FAIL** = curl exits non-zero (connection refused, timeout, ICMP prohibited).

### 6. Firewall — denied egress

Same curl pattern. Hosts: `example.com`, `www.google.com`, `www.cloudflare.com`, `1.1.1.1`.

- **PASS** = curl exits non-zero within `--max-time` (any block: REJECT, DROP+timeout, or refused).
- **FAIL** = curl exits 0 (the request actually went through — firewall bypass).
- Record `%{time_total}` as informational. Hosts with many A records will take longer because curl iterates through addresses even when each is rejected fast.

### 7. Workspace bind mount writability

```bash
touch /workspace/.smoketest && stat -c '%U:%G %a' /workspace/.smoketest && rm /workspace/.smoketest
```

PASS = touch succeeds, owner is `dotfiles:dotfiles`, file removed cleanly.

### 8. Persistent volumes

```bash
mount | grep -E "/home/dotfiles/.claude|/commandhistory"
```

Both mounts must appear. Then confirm both are writable:

```bash
touch ~/.claude/.smoketest && rm ~/.claude/.smoketest
touch /commandhistory/.smoketest && rm /commandhistory/.smoketest
```

## Report

After all 8 checks, emit a single summary table:

| # | Check                          | Result | Notes                                  |
|---|--------------------------------|--------|----------------------------------------|
| 1 | Identity & environment         | PASS   | dotfiles@..., /workspace mounted       |
| 2 | `~/.claude` symlinks           | PASS   | all 6 resolve under /workspace         |
| 3 | Tooling availability           | PASS   | 12/12 tools present                    |
| 4 | Sudo least-privilege           | PASS   | only init-firewall.sh NOPASSWD         |
| 5 | Firewall — allowed egress      | PASS   | 7/7 hosts reachable                    |
| 6 | Firewall — denied egress       | PASS   | 4/4 hosts blocked (times vary)         |
| 7 | Workspace bind mount           | PASS   | writable as dotfiles:dotfiles          |
| 8 | Persistent volumes             | PASS   | both mounted and writable              |

Close with a single line: `Overall: PASS` or `Overall: FAIL (N checks failed)`.
