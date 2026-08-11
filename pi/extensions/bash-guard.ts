import {
  isToolCallEventType,
  type ExtensionAPI,
} from "@earendil-works/pi-coding-agent";
import {
  classifyBashCommand,
  type BashRisk,
} from "./bash-guard/policy.ts";

function displayCommand(command: string): string {
  return JSON.stringify(command.slice(0, 240));
}

type DecisionOutcome = "approved" | "denied" | "unavailable" | "blocked";

export default function bashGuardExtension(pi: ExtensionAPI): void {
  const auditDecision = (
    command: string,
    risk: Exclude<BashRisk, { action: "allow" }>,
    outcome: DecisionOutcome,
  ): void => {
    pi.appendEntry("bash-guard-decision", {
      action: risk.action,
      outcome,
      reason: risk.reason,
      command: command.slice(0, 240),
    });
  };

  pi.on("before_agent_start", async (event) => ({
    systemPrompt:
      `${event.systemPrompt}\n\n` +
      "Bash guard: bash commands run on the host in a trusted repository. " +
      "Use one simple command per tool call; shell composition and redirection are not allowed. " +
      "High-impact operations may require user approval or be blocked. Do not try to bypass the guard.",
  }));

  pi.on("tool_call", async (event, ctx) => {
    if (!isToolCallEventType("bash", event)) return undefined;

    const command = event.input.command.trim();
    const risk = classifyBashCommand(command);

    if (risk.action === "allow") return undefined;

    if (risk.action === "confirm") {
      if (ctx.hasUI) {
        const approved = await ctx.ui.confirm(
          "Bash guard: approval required",
          `${risk.reason}:\n\n${command}\n\nAllow this command?`,
        );
        if (approved) {
          auditDecision(command, risk, "approved");
          return undefined;
        }
        auditDecision(command, risk, "denied");
      } else {
        auditDecision(command, risk, "unavailable");
      }

      return {
        block: true,
        reason:
          `Bash guard: ${risk.reason} was not approved.\n` +
          `  Command: ${displayCommand(command)}`,
      };
    }

    auditDecision(command, risk, "blocked");
    return {
      block: true,
      reason:
        `Bash guard: ${risk.reason}. Run the operation manually if necessary.\n` +
        `  Command: ${displayCommand(command)}`,
    };
  });
}
