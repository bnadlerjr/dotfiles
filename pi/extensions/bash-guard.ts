import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

/**
 * Guardrails against common destructive mistakes in trusted repositories.
 *
 * This is intentionally not a security boundary: allowed commands, project
 * scripts, and compiler hooks can execute arbitrary code with the user's
 * permissions.
 */

type BashRisk =
  | { action: "allow" }
  | { action: "block" | "confirm"; reason: string };

type RiskRule = {
  pattern: RegExp;
  reason: string;
};

// Keep each tool call to one simple shell command so a harmless first command
// cannot conceal a blocked second command. Operators in quoted arguments are
// conservatively rejected too.
const FORBIDDEN_SHELL_SYNTAX = /[\0\r\n;&|`<>]|\$\(/;

const BLOCK_RULES: readonly RiskRule[] = [
  {
    pattern: /^(?:\S*\/)?(?:sudo|doas|su)(?:\s|$)/,
    reason: "privilege escalation is not allowed",
  },
  {
    pattern: /^(?:\S*\/)?(?:shutdown|reboot|halt|poweroff)(?:\s|$)/,
    reason: "host power operations are not allowed",
  },
  {
    pattern:
      /^(?:\S*\/)?(?:mount|umount|mkfs(?:\.\S+)?|fdisk|parted|wipefs|cryptsetup)(?:\s|$)/,
    reason: "disk administration is not allowed",
  },
  {
    pattern:
      /^(?:env\s+)?MIX_ENV=(?:prod|production)\s+mix\s+ecto\.(?:drop|reset|rollback)(?:\s|$)/,
    reason: "destructive production database operations are not allowed",
  },
  {
    pattern:
      /^docker\s+run\b.*(?:--privileged\b|(?:-v|--volume)(?:=|\s+)\/(?:[:\s]|$)|--mount\b[^\n]*\bsource=\/)/,
    reason: "privileged containers and host root mounts are not allowed",
  },
];

const CONFIRM_RULES: readonly RiskRule[] = [
  {
    pattern:
      /^(?:\S*\/)?rm\b(?=[^\n]*(?:\s-(?:[A-Za-z]*r[A-Za-z]*f?|[A-Za-z]*f[A-Za-z]*r)|\s--recursive\b))[^\n]*$/,
    reason: "recursive file deletion",
  },
  {
    pattern: /^git\s+push(?:\s|$)/,
    reason: "pushing Git changes",
  },
  {
    pattern: /^git\s+reset\s+--hard(?:\s|$)/,
    reason: "discarding Git changes with reset --hard",
  },
  {
    pattern: /^git\s+clean(?:\s|$)/,
    reason: "deleting untracked Git files",
  },
  {
    pattern: /^git\s+branch\s+(?:-[A-Za-z]*D[A-Za-z]*|--delete\s+--force)(?:\s|$)/,
    reason: "force-deleting a Git branch",
  },
  {
    pattern: /^terraform\s+(?:apply|destroy|import|force-unlock)(?:\s|$)/,
    reason: "mutating Terraform-managed infrastructure",
  },
  {
    pattern: /^terraform\s+state\s+(?:mv|rm|push)(?:\s|$)/,
    reason: "mutating Terraform state",
  },
  {
    pattern:
      /^kubectl\s+(?:apply|create|delete|edit|patch|replace|scale|set|rollout|taint|label|annotate)(?:\s|$)/,
    reason: "mutating Kubernetes resources",
  },
  {
    pattern: /^helm\s+(?:install|upgrade|uninstall|rollback)(?:\s|$)/,
    reason: "mutating a Helm release",
  },
  {
    pattern:
      /^gh\s+(?:issue\s+(?:create|edit|close|reopen|comment|delete)|pr\s+(?:create|edit|close|reopen|comment|review|merge)|repo\s+(?:create|delete|rename|archive)|release\s+(?:create|edit|delete)|workflow\s+run)(?:\s|$)/,
    reason: "mutating GitHub state",
  },
  {
    pattern:
      /^jira\s+issue\s+(?:create|edit|delete|assign|clone|comment|link|move|transition)(?:\s|$)/,
    reason: "mutating Jira state",
  },
  {
    pattern: /^(?:(?:MIX_ENV=\S+)\s+)?mix\s+ecto\.(?:drop|reset)(?:\s|$)/,
    reason: "dropping or resetting a database",
  },
  {
    pattern: /^(?:npm\s+publish|mix\s+hex\.publish)(?:\s|$)/,
    reason: "publishing a package",
  },
  {
    pattern:
      /^docker\s+(?:rm|rmi|kill|stop|system\s+prune|volume\s+prune|container\s+prune|image\s+prune|builder\s+prune)(?:\s|$)/,
    reason: "deleting or stopping Docker resources",
  },
  {
    pattern: /^(?:\S*\/)?(?:kill|pkill|killall)(?:\s|$)/,
    reason: "terminating processes",
  },
];

export function classifyBashCommand(command: string): BashRisk {
  const trimmed = command.trim();
  if (!trimmed) return { action: "block", reason: "the command is empty" };

  if (FORBIDDEN_SHELL_SYNTAX.test(trimmed)) {
    return {
      action: "block",
      reason: "shell composition or redirection is not allowed",
    };
  }

  for (const rule of BLOCK_RULES) {
    if (rule.pattern.test(trimmed)) return { action: "block", reason: rule.reason };
  }

  for (const rule of CONFIRM_RULES) {
    if (rule.pattern.test(trimmed)) {
      return { action: "confirm", reason: rule.reason };
    }
  }

  return { action: "allow" };
}

function displayCommand(command: string): string {
  return JSON.stringify(command.slice(0, 240));
}

export default function bashGuardExtension(pi: ExtensionAPI): void {
  pi.on("before_agent_start", async (event) => ({
    systemPrompt:
      `${event.systemPrompt}\n\n` +
      "Bash guard: bash commands run on the host in a trusted repository. " +
      "Use one simple command per tool call; shell composition and redirection are not allowed. " +
      "High-impact operations may require user approval or be blocked. Do not try to bypass the guard.",
  }));

  pi.on("tool_call", async (event, ctx) => {
    if (event.toolName !== "bash") return undefined;

    const input = event.input as { command?: unknown } | undefined;
    const command =
      typeof input?.command === "string" ? input.command.trim() : "";
    const risk = classifyBashCommand(command);

    if (risk.action === "allow") return undefined;

    if (risk.action === "confirm") {
      if (ctx.hasUI) {
        const approved = await ctx.ui.confirm(
          "Bash guard: approval required",
          `${risk.reason}:\n\n${command}\n\nAllow this command?`,
        );
        if (approved) return undefined;
      }

      return {
        block: true,
        reason:
          `Bash guard: ${risk.reason} was not approved.\n` +
          `  Command: ${displayCommand(command)}`,
      };
    }

    return {
      block: true,
      reason:
        `Bash guard: ${risk.reason}. Run the operation manually if necessary.\n` +
        `  Command: ${displayCommand(command)}`,
    };
  });
}
