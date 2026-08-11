import { basename } from "node:path";

/**
 * Guardrails against common destructive mistakes in trusted repositories.
 *
 * This is intentionally not a security boundary: allowed commands, project
 * scripts, and compiler hooks can execute arbitrary code with the user's
 * permissions.
 */

export type BashRisk =
  | { action: "allow" }
  | { action: "block" | "confirm"; reason: string };

type RiskRule = {
  pattern: RegExp;
  reason: string;
};

// Keep each tool call to one simple shell command so a harmless first command
// cannot conceal a blocked second command. Shell operators are harmless in
// quoted arguments, although command substitution in double quotes is not.
function hasForbiddenShellSyntax(command: string): boolean {
  let quote: "single" | "double" | undefined;

  for (let index = 0; index < command.length; index += 1) {
    const character = command[index];

    if (character === "\0" || character === "\r" || character === "\n") {
      return true;
    }

    if (quote === "single") {
      if (character === "'") quote = undefined;
      continue;
    }

    if (character === "\\") {
      index += 1;
      continue;
    }

    if (character === "'") {
      if (quote === undefined) quote = "single";
      continue;
    }

    if (character === '"') {
      quote = quote === "double" ? undefined : "double";
      continue;
    }

    if (character === "`" || (character === "$" && command[index + 1] === "(")) {
      return true;
    }

    if (quote === undefined && ";&|<>".includes(character)) return true;
  }

  return false;
}

type ParsedCommand = {
  executable: string;
  args: string[];
  environment: Map<string, string>;
};

function tokenizeSimpleCommand(command: string): string[] {
  const words: string[] = [];
  let word = "";
  let quote: "single" | "double" | undefined;
  let wordStarted = false;

  for (let index = 0; index < command.length; index += 1) {
    const character = command[index];

    if (quote === "single") {
      if (character === "'") quote = undefined;
      else word += character;
      wordStarted = true;
      continue;
    }

    if (character === "\\") {
      wordStarted = true;
      if (index + 1 < command.length) word += command[++index];
      continue;
    }

    if (character === "'") {
      if (quote === undefined) quote = "single";
      else word += character;
      wordStarted = true;
      continue;
    }

    if (character === '"') {
      quote = quote === "double" ? undefined : "double";
      wordStarted = true;
      continue;
    }

    if (quote === undefined && /\s/.test(character)) {
      if (wordStarted) words.push(word);
      word = "";
      wordStarted = false;
      continue;
    }

    word += character;
    wordStarted = true;
  }

  if (wordStarted) words.push(word);
  return words;
}

function takeEnvironmentAssignment(
  word: string,
  environment: Map<string, string>,
): boolean {
  const match = /^([A-Za-z_][A-Za-z0-9_]*)=(.*)$/.exec(word);
  if (!match) return false;
  environment.set(match[1], match[2]);
  return true;
}

const GLOBAL_OPTIONS_WITH_VALUES: Readonly<Record<string, ReadonlySet<string>>> = {
  git: new Set(["-C", "-c", "--git-dir", "--work-tree", "--namespace"]),
  kubectl: new Set([
    "-n",
    "-s",
    "--namespace",
    "--context",
    "--kubeconfig",
    "--cluster",
    "--user",
    "--server",
    "--request-timeout",
    "--as",
    "--as-group",
    "--token",
    "--certificate-authority",
    "--client-certificate",
    "--client-key",
    "--cache-dir",
    "--tls-server-name",
    "--profile",
    "--profile-output",
    "--v",
    "--vmodule",
    "--log-flush-frequency",
  ]),
  docker: new Set(["-c", "-H", "-l", "--config", "--context", "--host", "--log-level"]),
  npm: new Set(["-w", "--workspace", "--prefix", "--userconfig", "--registry"]),
  gh: new Set(["-R", "--repo", "--hostname"]),
};

function stripGlobalOptions(executable: string, args: string[]): string[] {
  const optionsWithValues = GLOBAL_OPTIONS_WITH_VALUES[executable];
  if (!optionsWithValues && executable !== "terraform") return args;

  let index = 0;
  while (index < args.length && args[index].startsWith("-")) {
    const option = args[index];
    if (option === "--") return args.slice(index + 1);
    if (executable === "terraform" && option.startsWith("-chdir=")) {
      index += 1;
      continue;
    }

    const name = option.split("=", 1)[0];
    index += option.includes("=") || !optionsWithValues?.has(name) ? 1 : 2;
  }

  return args.slice(index);
}

function parseSimpleCommand(command: string): ParsedCommand {
  const words = tokenizeSimpleCommand(command);
  const environment = new Map<string, string>();
  let index = 0;

  while (index < words.length && takeEnvironmentAssignment(words[index], environment)) {
    index += 1;
  }

  while (index < words.length) {
    const wrapper = basename(words[index]);
    if (wrapper === "env") {
      index += 1;
      while (index < words.length) {
        const word = words[index];
        if (word === "--") {
          index += 1;
          break;
        }
        if (word === "-u" || word === "--unset") {
          const name = words[index + 1];
          if (name) environment.delete(name);
          index += 2;
          continue;
        }
        if (word.startsWith("--unset=")) {
          environment.delete(word.slice("--unset=".length));
          index += 1;
          continue;
        }
        if (word.startsWith("-") && !word.includes("=")) {
          index += 1;
          continue;
        }
        if (takeEnvironmentAssignment(word, environment)) {
          index += 1;
          continue;
        }
        break;
      }
      continue;
    }

    if (wrapper === "command") {
      index += 1;
      while (index < words.length && /^-(?:p|v|V|--)$/.test(words[index])) index += 1;
      continue;
    }

    break;
  }

  const executable = index < words.length ? basename(words[index]) : "";
  const args = stripGlobalOptions(executable, words.slice(index + 1));
  return { executable, args, environment };
}

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
      /^docker\s+run\b.*(?:--privileged\b|(?:-v|--volume)(?:=|\s+)\/(?:[:\s]|$)|--mount\b[^\n]*\b(?:source|src)=\/(?:,|\s|$))/,
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

  if (hasForbiddenShellSyntax(trimmed)) {
    return {
      action: "block",
      reason: "shell composition or redirection is not allowed",
    };
  }

  const parsed = parseSimpleCommand(trimmed);
  const normalized = [parsed.executable, ...parsed.args].join(" ");

  if (
    parsed.executable === "mix" &&
    /^(?:prod|production)$/.test(parsed.environment.get("MIX_ENV") ?? "") &&
    /^ecto\.(?:drop|reset|rollback)(?:\s|$)/.test(parsed.args.join(" "))
  ) {
    return {
      action: "block",
      reason: "destructive production database operations are not allowed",
    };
  }

  for (const rule of BLOCK_RULES) {
    if (rule.pattern.test(normalized)) return { action: "block", reason: rule.reason };
  }

  for (const rule of CONFIRM_RULES) {
    if (rule.pattern.test(normalized)) {
      return { action: "confirm", reason: rule.reason };
    }
  }

  return { action: "allow" };
}
