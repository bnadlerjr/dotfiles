// Show context usage as tokens (for example, 100k/272k) instead of a percentage.
// @ts-nocheck

function call(target: any, name: string): any {
  try {
    return typeof target?.[name] === "function" ? target[name]() : undefined;
  } catch {
    return undefined;
  }
}

function compactTokens(value: number): string {
  if (!Number.isFinite(value) || value <= 0) return "0";
  if (value < 1_000) return String(Math.round(value));

  const scaled = value / 1_000;
  const digits = scaled < 10 && !Number.isInteger(scaled) ? 1 : 0;
  return `${scaled.toFixed(digits)}k`;
}

function contextUsage(ctx: any, footerData: any): { used: number; limit: number } {
  const usage =
    call(ctx, "getContextUsage") ??
    call(footerData, "getContextUsage") ??
    footerData?.contextUsage ??
    {};

  const used = Number(
    usage.tokens ??
      usage.usedTokens ??
      usage.contextTokens ??
      usage.inputTokens ??
      0,
  );
  const limit = Number(
    usage.contextWindow ??
      usage.limit ??
      usage.maxTokens ??
      ctx?.model?.contextWindow ??
      0,
  );

  return { used, limit };
}

function sessionCost(ctx: any, footerData: any): number {
  const direct =
    call(footerData, "getCost") ?? footerData?.cost ?? call(ctx, "getSessionCost");
  if (Number.isFinite(Number(direct))) return Number(direct);

  // Fall back to summing assistant-message costs on the active branch.
  const branch = call(ctx?.sessionManager, "getBranch") ?? [];
  return branch.reduce((total: number, entry: any) => {
    const cost = entry?.message?.usage?.cost?.total ?? entry?.usage?.cost?.total ?? 0;
    return total + (Number.isFinite(Number(cost)) ? Number(cost) : 0);
  }, 0);
}

function thinkingLevel(ctx: any, footerData: any): string | undefined {
  return (
    call(ctx, "getThinkingLevel") ??
    call(footerData, "getThinkingLevel") ??
    ctx?.thinkingLevel ??
    ctx?.agent?.thinkingLevel
  );
}

function fitLine(left: string, right: string, width: number): string {
  if (width <= 0) return "";
  if (!right) return left.slice(0, width);

  const spaces = width - left.length - right.length;
  if (spaces >= 1) return left + " ".repeat(spaces) + right;

  // Preserve the requested token counter when the terminal is narrow.
  const availableRight = Math.max(0, width - left.length - 1);
  return availableRight > 0
    ? `${left} ${right.slice(Math.max(0, right.length - availableRight))}`.slice(0, width)
    : left.slice(0, width);
}

export default function tokenFooter(pi: any) {
  pi.on("session_start", (_event: any, ctx: any) => {
    if (!ctx?.hasUI) return;

    ctx.ui.setFooter((_tui: any, _theme: any, footerData: any) => ({
      render(width: number): string[] {
        const { used, limit } = contextUsage(ctx, footerData);
        const cost = sessionCost(ctx, footerData);
        const provider = ctx?.model?.provider ?? "";
        const model = ctx?.model?.id ?? ctx?.model?.name ?? "";
        const level = thinkingLevel(ctx, footerData);

        const subscription = provider === "openai-codex" ? " (sub)" : "";
        const context = limit
          ? `${compactTokens(used)}/${compactTokens(limit)} (auto)`
          : `${compactTokens(used)} (auto)`;
        const left = `$${cost.toFixed(3)}${subscription} ${context}`;
        const right = `${provider ? `(${provider}) ` : ""}${model}${level ? ` • ${level}` : ""}`;

        return [fitLine(left, right, width)];
      },
      invalidate() {},
    }));
  });
}
