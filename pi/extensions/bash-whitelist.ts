import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

/**
 * Bash command prefixes mirrored from claude/settings.json.
 *
 * A prefix matches either the complete command or the prefix followed by
 * whitespace. Shell composition is rejected separately below.
 */
// Commands in this list must match in full. Keep environment-variable access
// here so callers cannot append the name of a secret variable.
const ALLOWED_EXACT_COMMANDS = [
  "printenv PI_MODEL",
  "printenv PI_SESSION_ID",
] as const;

const ALLOWED_PREFIXES = [
  // Elixir commands run explicitly in the test environment.
  "MIX_ENV=test mix compile",
  "MIX_ENV=test mix credo",
  "MIX_ENV=test mix dialyzer",
  "MIX_ENV=test mix ecto.create",
  "MIX_ENV=test mix ecto.drop",
  "MIX_ENV=test mix ecto.migrate",
  "MIX_ENV=test mix ecto.reset",
  "MIX_ENV=test mix ecto.rollback",
  "MIX_ENV=test mix format",
  "MIX_ENV=test mix help",
  "MIX_ENV=test mix hex.outdated",
  "MIX_ENV=test mix test",

  // General utilities.
  "cat",
  "docker logs",
  "docker ps",
  "du",
  "echo",
  "fd",
  "file",
  "grep",
  "head",
  "ls",
  "mkdir",
  "ps",
  "pwd",
  "rg",
  "sloc",
  "sort",
  "stat",
  "tail",
  "terraform plan",
  "terraform validate",
  "wc",
  "which",

  // GitHub CLI (read-only/status-oriented commands).
  "gh issue list",
  "gh issue status",
  "gh issue view",
  "gh pr checks",
  "gh pr diff",
  "gh pr list",
  "gh pr status",
  "gh pr view",
  "gh repo list",
  "gh repo view",
  "gh search",
  "gh status",

  // Git and git-machete.
  "git branch --show-current",
  "git config commit.template",
  "git diff",
  "git grep",
  "git log",
  "git ls-files",
  "git machete completion",
  "git machete diff",
  "git machete file",
  "git machete format",
  "git machete help",
  "git machete hooks",
  "git machete is-managed",
  "git machete list",
  "git machete log",
  "git machete show",
  "git machete status",
  "git machete version",
  "git rev-parse",
  "git show",
  "git status",
  "git worktree list",

  // Jira CLI.
  "jira board list",
  "jira epic list",
  "jira issue",
  "jira me",
  "jira open",
  "jira project list",
  "jira sprint list",

  // Elixir commands.
  "mix compile",
  "mix credo",
  "mix dialyzer",
  "mix ecto.create",
  "mix ecto.drop",
  "mix ecto.gen.migration",
  "mix ecto.migrate",
  "mix ecto.reset",
  "mix ecto.rollback",
  "mix format",
  "mix help",
  "mix hex.info",
  "mix hex.outdated",
  "mix lint",
  "mix sobelow",
  "mix test",
] as const;

// Keep each tool call to one simple shell command. This is intentionally
// conservative: operators inside quoted arguments are rejected too.
const FORBIDDEN_SHELL_SYNTAX = /[\0\r\n;&|`<>]|\$\(/;

export function isBashCommandAllowed(command: string): boolean {
  if (!command || FORBIDDEN_SHELL_SYNTAX.test(command)) return false;

  if (ALLOWED_EXACT_COMMANDS.some((allowed) => command === allowed))
    return true;

  return ALLOWED_PREFIXES.some(
    (prefix) =>
      command === prefix ||
      (command.startsWith(prefix) && /^\s/.test(command.slice(prefix.length))),
  );
}

function displayCommand(command: string): string {
  return JSON.stringify(command.slice(0, 160));
}

export default function bashWhitelistExtension(pi: ExtensionAPI): void {
  pi.on("before_agent_start", async (event) => ({
    systemPrompt:
      `${event.systemPrompt}\n\n` +
      "Bash whitelist: each bash tool call must contain one simple command. " +
      "Shell composition, including pipes, command chaining, and redirection, is not allowed. " +
      "Use separate or parallel tool calls, and prefer the read, grep, find, and ls tools for inspection.",
  }));

  pi.on("tool_call", async (event) => {
    if (event.toolName !== "bash") return undefined;

    const input = event.input as { command?: unknown } | undefined;
    const command =
      typeof input?.command === "string" ? input.command.trim() : "";

    if (isBashCommandAllowed(command)) return undefined;

    const reason = FORBIDDEN_SHELL_SYNTAX.test(command)
      ? "shell composition or redirection is not allowed"
      : "command is not in the allowlist";

    return {
      block: true,
      reason:
        `Bash whitelist: ${reason}.\n` +
        "Use separate tool calls or the read, grep, find, and ls tools; do not retry with sh -c.\n" +
        `  Command: ${displayCommand(command)}`,
    };
  });
}
