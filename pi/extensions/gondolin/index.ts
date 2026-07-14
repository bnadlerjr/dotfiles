/**
 * Gondolin sandbox for pi
 *
 * Runs pi's built-in tools inside a local Gondolin micro-VM. Adapted from the
 * upstream example (earendil-works/pi, examples/extensions/gondolin). Main
 * departures:
 *
 *   - Guest paths mirror host paths exactly (no /workspace remapping), so a
 *     git worktree's `.git` file — an absolute `gitdir:` path into the main
 *     checkout — resolves natively inside the guest.
 *   - When the working directory is a git worktree, the main checkout is
 *     mounted alongside it (derived from `git rev-parse --git-common-dir`).
 *   - Repository-specific policy is loaded from an untracked local config;
 *     the extension itself contains no application or organization settings.
 *
 * Setup:
 *   cd ~/dotfiles/pi/extensions/gondolin
 *   npm install --ignore-scripts
 *
 * Usage:
 *   cd /path/to/project
 *   pi -e ~/dotfiles/pi/extensions/gondolin
 *
 * Requirements:
 *   - QEMU installed (for example, `brew install qemu` on macOS)
 *   - @earendil-works/gondolin declares node >= 23.6.0 but is not
 *     engine-strict; verified working under node 22.19
 */

import { execFileSync } from "node:child_process";
import crypto from "node:crypto";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";
import {
  createHttpHooks,
  getInfoFromSshExecRequest,
  RealFSProvider,
  type SshExecDecision,
  type SshExecRequest,
  VM,
} from "@earendil-works/gondolin";
import type {
  ExtensionAPI,
  ExtensionContext,
} from "@earendil-works/pi-coding-agent";
import {
  type BashOperations,
  createBashTool,
  createEditTool,
  createFindTool,
  createGrepTool,
  createLsTool,
  createReadTool,
  createWriteTool,
  DEFAULT_MAX_BYTES,
  type EditOperations,
  type FindOperations,
  formatSize,
  type GrepToolDetails,
  type GrepToolInput,
  type LsOperations,
  type ReadOperations,
  truncateHead,
  truncateLine,
  type WriteOperations,
} from "@earendil-works/pi-coding-agent";

const DEFAULT_GREP_LIMIT = 100;

const EXTENSION_DIR = path.dirname(fileURLToPath(import.meta.url));
const DEFAULT_CONFIG_PATH = path.join(EXTENSION_DIR, ".local", "config.json");
const BASE_GUEST_ENV: Record<string, string> = {
  HOME: "/root",
  SSL_CERT_FILE: "/run/gondolin/ca-certificates.crt",
  NODE_EXTRA_CA_CERTS: "/run/gondolin/ca-certificates.crt",
};

interface SshConfig {
  allowedHosts: string[];
  allowedGitOrganizations: string[];
  agentSocket: string;
  knownHostsFile?: string;
  denyPush?: boolean;
}

interface SeedFileConfig {
  source: string;
  destination: string;
}

interface BuildCacheConfig {
  enabled: boolean;
  seedFiles?: SeedFileConfig[];
}

interface GondolinProfile {
  name?: string;
  repositories: string[];
  imagePath?: string;
  allowedHttpHosts?: string[];
  ssh?: SshConfig;
  tcpHosts?: Record<string, string>;
  env?: Record<string, string>;
  buildCache?: BuildCacheConfig;
  memory?: string;
  cpus?: number;
  provisionCommands?: string[];
}

interface GondolinConfig {
  profiles: GondolinProfile[];
}

function expandLocalPath(value: string): string {
  if (value === "~") return os.homedir();
  if (value.startsWith("~/")) return path.join(os.homedir(), value.slice(2));
  return path.resolve(value);
}

function loadConfig(): GondolinConfig {
  const configPath = expandLocalPath(
    process.env.PI_GONDOLIN_CONFIG ?? DEFAULT_CONFIG_PATH,
  );
  if (!fs.existsSync(configPath)) return { profiles: [] };
  const parsed = JSON.parse(fs.readFileSync(configPath, "utf8")) as GondolinConfig;
  if (!Array.isArray(parsed.profiles)) {
    throw new Error(`${configPath}: expected a profiles array`);
  }
  return parsed;
}

function repositoryRoot(localCwd: string): string {
  const topLevel = gitRevParse(localCwd, "--show-toplevel") ?? localCwd;
  const commonDir = gitRevParse(localCwd, "--git-common-dir");
  if (commonDir && !isInsideHostPath(topLevel, commonDir)) {
    return path.basename(commonDir) === ".git"
      ? path.dirname(commonDir)
      : commonDir;
  }
  return topLevel;
}

function selectProfile(config: GondolinConfig, localCwd: string): GondolinProfile {
  const root = repositoryRoot(localCwd);
  const profile = config.profiles.find(({ repositories }) =>
    repositories.some((repository) => {
      if (repository.includes(path.sep) || path.isAbsolute(repository)) {
        return expandLocalPath(repository) === root;
      }
      return repository === path.basename(root);
    }),
  );
  return profile ?? { name: "default", repositories: [] };
}

function createSshExecPolicy(config: SshConfig) {
  return (request: SshExecRequest): SshExecDecision => {
    const info = getInfoFromSshExecRequest(request);
    if (!info) {
      return {
        allow: false,
        message: "only git smart-protocol commands are allowed",
      };
    }
    if (config.denyPush !== false && info.service === "git-receive-pack") {
      return { allow: false, message: "pushes from the sandbox are disabled" };
    }
    const allowed = config.allowedGitOrganizations.some((organization) =>
      info.repo.startsWith(`${organization}/`),
    );
    if (!allowed) {
      return {
        allow: false,
        message: "repository organization is not allowed by the local profile",
      };
    }
    return { allow: true };
  };
}

type TextToolResult<TDetails> = {
  content: Array<{ type: "text"; text: string }>;
  details: TDetails | undefined;
};

function stripAtPrefix(value: string): string {
  return value.startsWith("@") ? value.slice(1) : value;
}

function toPosix(value: string): string {
  return value.split(path.sep).join(path.posix.sep);
}

function isInsideHostPath(root: string, value: string): boolean {
  const relativePath = path.relative(root, value);
  return (
    relativePath === "" ||
    (!relativePath.startsWith("..") && !path.isAbsolute(relativePath))
  );
}

// Guest paths mirror host paths, so translation only normalizes and resolves
// relative paths against the working directory.
function toGuestPath(localCwd: string, inputPath: string): string {
  const trimmed = stripAtPrefix(inputPath.trim());
  if (!trimmed) return toPosix(localCwd);
  return path.posix.resolve(toPosix(localCwd), toPosix(trimmed));
}

function gitRevParse(localCwd: string, flag: string): string | undefined {
  try {
    const output = execFileSync("git", ["-C", localCwd, "rev-parse", flag], {
      encoding: "utf8",
      stdio: ["ignore", "pipe", "ignore"],
    }).trim();
    return output ? path.resolve(localCwd, output) : undefined;
  } catch {
    return undefined;
  }
}

// The checkout containing the working directory is mounted at its identical
// guest path (the toplevel, so a repo-subdir cwd still sees the `.git`
// entry). For a git worktree the main checkout is mounted too: the
// worktree's `.git` file holds an absolute `gitdir:` path into it, and git
// breaks without it. Guarding on the `.git` basename keeps a bare-repo
// worktree from mounting the bare repo's parent (sibling exposure).
function computeMounts(
  localCwd: string,
  profile: GondolinProfile,
): Record<string, RealFSProvider> {
  const topLevel = gitRevParse(localCwd, "--show-toplevel") ?? localCwd;
  const mounts: Record<string, RealFSProvider> = {
    [toPosix(topLevel)]: new RealFSProvider(topLevel),
  };
  const repoRoot = repositoryRoot(localCwd);
  if (repoRoot !== topLevel) {
    mounts[toPosix(repoRoot)] = new RealFSProvider(repoRoot);
  }
  if (!profile.buildCache?.enabled) return mounts;

  // Keep guest-generated artifacts separate from host artifacts and from
  // other repositories. Profiles opt into this mount and choose how tools use
  // it through their environment variables.
  const repoRootHash = crypto
    .createHash("sha256")
    .update(repoRoot)
    .digest("hex")
    .slice(0, 8);
  const cacheDir = path.join(
    os.homedir(),
    ".cache",
    "pi-gondolin",
    `${path.basename(repoRoot)}-${repoRootHash}`,
  );
  fs.mkdirSync(cacheDir, { recursive: true });
  mounts["/build-cache"] = new RealFSProvider(cacheDir);

  for (const seed of profile.buildCache.seedFiles ?? []) {
    const source = expandLocalPath(seed.source);
    const destination = path.resolve(cacheDir, seed.destination);
    if (!isInsideHostPath(cacheDir, destination)) {
      throw new Error(`build-cache seed escapes cache: ${seed.destination}`);
    }
    if (
      fs.existsSync(source) &&
      (!fs.existsSync(destination) ||
        fs.statSync(source).mtimeMs > fs.statSync(destination).mtimeMs)
    ) {
      fs.mkdirSync(path.dirname(destination), { recursive: true });
      fs.copyFileSync(source, destination);
    }
  }
  return mounts;
}

function createGondolinReadOps(vm: VM, localCwd: string): ReadOperations {
  return {
    readFile: async (filePath) =>
      vm.fs.readFile(toGuestPath(localCwd, filePath)),
    access: async (filePath) => {
      await vm.fs.access(toGuestPath(localCwd, filePath));
    },
    detectImageMimeType: async (filePath) => {
      const ext = path.posix
        .extname(toGuestPath(localCwd, filePath))
        .toLowerCase();
      if (ext === ".png") return "image/png";
      if (ext === ".jpg" || ext === ".jpeg") return "image/jpeg";
      if (ext === ".gif") return "image/gif";
      if (ext === ".webp") return "image/webp";
      return null;
    },
  };
}

function createGondolinWriteOps(vm: VM, localCwd: string): WriteOperations {
  return {
    writeFile: async (filePath, content) => {
      await vm.fs.writeFile(toGuestPath(localCwd, filePath), content, {
        encoding: "utf8",
      });
    },
    mkdir: async (dirPath) => {
      await vm.fs.mkdir(toGuestPath(localCwd, dirPath), { recursive: true });
    },
  };
}

function createGondolinEditOps(vm: VM, localCwd: string): EditOperations {
  const readOps = createGondolinReadOps(vm, localCwd);
  const writeOps = createGondolinWriteOps(vm, localCwd);
  return {
    readFile: readOps.readFile,
    writeFile: writeOps.writeFile,
    access: readOps.access,
  };
}

function createGondolinLsOps(vm: VM, localCwd: string): LsOperations {
  return {
    exists: async (filePath) => {
      try {
        await vm.fs.access(toGuestPath(localCwd, filePath));
        return true;
      } catch {
        return false;
      }
    },
    stat: async (filePath) => vm.fs.stat(toGuestPath(localCwd, filePath)),
    readdir: async (dirPath) => vm.fs.listDir(toGuestPath(localCwd, dirPath)),
  };
}

async function walkGuestFiles(
  vm: VM,
  root: string,
  visit: (guestPath: string, relativePath: string) => Promise<boolean>,
  signal?: AbortSignal,
): Promise<boolean> {
  if (signal?.aborted) throw new Error("Operation aborted");
  const stat = await vm.fs.stat(root, { signal });
  if (!stat.isDirectory()) return visit(root, path.posix.basename(root));

  const walkDirectory = async (
    dir: string,
    relativeDir: string,
  ): Promise<boolean> => {
    if (signal?.aborted) throw new Error("Operation aborted");
    const entries = await vm.fs.listDir(dir, { signal });
    for (const entry of entries) {
      if (entry === ".git" || entry === "node_modules") continue;
      const guestPath = path.posix.join(dir, entry);
      const relativePath = relativeDir
        ? path.posix.join(relativeDir, entry)
        : entry;
      let entryStat: Awaited<ReturnType<VM["fs"]["stat"]>>;
      try {
        entryStat = await vm.fs.stat(guestPath, { signal });
      } catch {
        continue;
      }
      if (entryStat.isDirectory()) {
        if (!(await walkDirectory(guestPath, relativePath))) return false;
      } else if (!(await visit(guestPath, relativePath))) {
        return false;
      }
    }
    return true;
  };

  return walkDirectory(root, "");
}

function matchesToolGlob(relativePath: string, pattern: string): boolean {
  const normalizedPattern = toPosix(pattern);
  if (normalizedPattern.includes("/")) {
    return (
      path.posix.matchesGlob(relativePath, normalizedPattern) ||
      path.posix.matchesGlob(relativePath, `**/${normalizedPattern}`)
    );
  }
  return path.posix.matchesGlob(
    path.posix.basename(relativePath),
    normalizedPattern,
  );
}

function createGondolinFindOps(vm: VM, localCwd: string): FindOperations {
  return {
    exists: async (filePath) => {
      try {
        await vm.fs.access(toGuestPath(localCwd, filePath));
        return true;
      } catch {
        return false;
      }
    },
    glob: async (pattern, cwd, options) => {
      const root = toGuestPath(localCwd, cwd);
      const results: string[] = [];
      await walkGuestFiles(vm, root, async (guestPath, relativePath) => {
        if (results.length >= options.limit) return false;
        if (matchesToolGlob(relativePath, pattern)) results.push(guestPath);
        return results.length < options.limit;
      });
      return results;
    },
  };
}

function createLineMatcher(
  pattern: string,
  literal: boolean | undefined,
  ignoreCase: boolean | undefined,
) {
  if (literal) {
    const needle = ignoreCase ? pattern.toLowerCase() : pattern;
    return (line: string) =>
      (ignoreCase ? line.toLowerCase() : line).includes(needle);
  }
  const regex = new RegExp(pattern, ignoreCase ? "i" : undefined);
  return (line: string) => regex.test(line);
}

function appendGrepBlock(params: {
  outputLines: string[];
  lines: string[];
  relativePath: string;
  lineIndex: number;
  contextLines: number;
}): boolean {
  let linesTruncated = false;
  const start =
    params.contextLines > 0
      ? Math.max(0, params.lineIndex - params.contextLines)
      : params.lineIndex;
  const end =
    params.contextLines > 0
      ? Math.min(
          params.lines.length - 1,
          params.lineIndex + params.contextLines,
        )
      : params.lineIndex;

  for (let index = start; index <= end; index++) {
    const rawLine = params.lines[index] ?? "";
    const { text, wasTruncated } = truncateLine(rawLine.replace(/\r/g, ""));
    if (wasTruncated) linesTruncated = true;
    const separator = index === params.lineIndex ? ":" : "-";
    params.outputLines.push(
      `${params.relativePath}${separator}${index + 1}${separator} ${text}`,
    );
  }
  return linesTruncated;
}

async function executeGondolinGrep(
  vm: VM,
  localCwd: string,
  params: GrepToolInput,
  signal?: AbortSignal,
): Promise<TextToolResult<GrepToolDetails>> {
  const root = toGuestPath(localCwd, params.path ?? ".");
  const rootStat = await vm.fs.stat(root, { signal });
  const rootIsDirectory = rootStat.isDirectory();
  const matcher = createLineMatcher(
    params.pattern,
    params.literal,
    params.ignoreCase,
  );
  const contextLines =
    params.context && params.context > 0 ? params.context : 0;
  const effectiveLimit = Math.max(1, params.limit ?? DEFAULT_GREP_LIMIT);
  const outputLines: string[] = [];
  const details: GrepToolDetails = {};
  let matchCount = 0;
  let matchLimitReached = false;
  let linesTruncated = false;

  await walkGuestFiles(
    vm,
    root,
    async (guestPath, relativePath) => {
      if (matchCount >= effectiveLimit) return false;
      if (params.glob && !matchesToolGlob(relativePath, params.glob))
        return true;
      let content: string;
      try {
        content = await vm.fs.readFile(guestPath, { encoding: "utf8", signal });
      } catch {
        return true;
      }
      const lines = content
        .replace(/\r\n/g, "\n")
        .replace(/\r/g, "\n")
        .split("\n");
      const displayPath = rootIsDirectory
        ? relativePath
        : path.posix.basename(guestPath);
      for (let index = 0; index < lines.length; index++) {
        if (signal?.aborted) throw new Error("Operation aborted");
        if (!matcher(lines[index] ?? "")) continue;
        matchCount++;
        if (
          appendGrepBlock({
            outputLines,
            lines,
            relativePath: displayPath,
            lineIndex: index,
            contextLines,
          })
        ) {
          linesTruncated = true;
        }
        if (matchCount >= effectiveLimit) {
          matchLimitReached = true;
          return false;
        }
      }
      return true;
    },
    signal,
  );

  if (matchCount === 0)
    return {
      content: [{ type: "text", text: "No matches found" }],
      details: undefined,
    };

  const rawOutput = outputLines.join("\n");
  const truncation = truncateHead(rawOutput, {
    maxLines: Number.MAX_SAFE_INTEGER,
  });
  const notices: string[] = [];
  let output = truncation.content;

  if (matchLimitReached) {
    details.matchLimitReached = effectiveLimit;
    notices.push(`${effectiveLimit} matches limit reached`);
  }
  if (linesTruncated) {
    details.linesTruncated = true;
    notices.push("long lines truncated");
  }
  if (truncation.truncated) {
    details.truncation = truncation;
    notices.push(`${formatSize(DEFAULT_MAX_BYTES)} limit reached`);
  }
  if (notices.length > 0) output += `\n\n[${notices.join(". ")}]`;

  return {
    content: [{ type: "text", text: output }],
    details: Object.keys(details).length > 0 ? details : undefined,
  };
}

function sanitizeEnv(
  env: NodeJS.ProcessEnv | undefined,
): Record<string, string> | undefined {
  if (!env) return undefined;
  const result: Record<string, string> = {};
  for (const [key, value] of Object.entries(env)) {
    if (typeof value === "string") result[key] = value;
  }
  return result;
}

function createGondolinBashOps(
  vm: VM,
  localCwd: string,
  shellPath: string,
  guestEnv: Record<string, string>,
): BashOperations {
  return {
    exec: async (command, cwd, { onData, signal, timeout, env }) => {
      if (signal?.aborted) throw new Error("aborted");
      const guestCwd = toGuestPath(localCwd, cwd);
      const controller = new AbortController();
      const onAbort = () => controller.abort();
      signal?.addEventListener("abort", onAbort, { once: true });

      let timedOut = false;
      const timer =
        timeout && timeout > 0
          ? setTimeout(() => {
              timedOut = true;
              controller.abort();
            }, timeout * 1000)
          : undefined;

      try {
        const proc = vm.exec([shellPath, "-lc", command], {
          cwd: guestCwd,
          env: { ...sanitizeEnv(env), ...guestEnv },
          signal: controller.signal,
          stdout: "pipe",
          stderr: "pipe",
        });
        for await (const chunk of proc.output()) onData(chunk.data);
        const result = await proc;
        return { exitCode: result.exitCode };
      } catch (error) {
        if (signal?.aborted) throw new Error("aborted");
        if (timedOut) throw new Error(`timeout:${timeout}`);
        throw error;
      } finally {
        if (timer) clearTimeout(timer);
        signal?.removeEventListener("abort", onAbort);
      }
    },
  };
}

export default function (pi: ExtensionAPI) {
  const localCwd = process.cwd();
  const profile = selectProfile(loadConfig(), localCwd);
  const mounts = computeMounts(localCwd, profile);
  const mountList = Object.keys(mounts).join(", ");
  const configuredImagePath = profile.imagePath
    ? expandLocalPath(profile.imagePath)
    : undefined;
  const imagePath =
    configuredImagePath &&
    fs.existsSync(path.join(configuredImagePath, "manifest.json"))
      ? configuredImagePath
      : undefined;
  const guestEnv: Record<string, string> = {
    ...BASE_GUEST_ENV,
    ...(profile.ssh
      ? {
          GIT_SSH_COMMAND:
            "ssh -o BatchMode=yes -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR",
        }
      : {}),
    ...profile.env,
  };
  const localRead = createReadTool(localCwd);
  const localWrite = createWriteTool(localCwd);
  const localEdit = createEditTool(localCwd);
  const localBash = createBashTool(localCwd);
  const localGrep = createGrepTool(localCwd);
  const localFind = createFindTool(localCwd);
  const localLs = createLsTool(localCwd);

  let vm: VM | undefined;
  let vmStarting: Promise<VM> | undefined;
  let shellPath = "/bin/sh";

  async function startVm(ctx?: ExtensionContext): Promise<VM> {
    ctx?.ui.setStatus(
      "gondolin",
      ctx.ui.theme.fg("accent", `Gondolin: starting ${localCwd}`),
    );
    const { httpHooks } = createHttpHooks({
      allowedHosts: profile.allowedHttpHosts ?? [],
    });
    const created = await VM.create({
      sessionLabel: `pi ${path.basename(localCwd)}`,
      sandbox: imagePath ? { imagePath } : undefined,
      vfs: { mounts },
      httpHooks,
      dns: { mode: "synthetic", syntheticHostMapping: "per-host" },
      ssh: profile.ssh
        ? {
            allowedHosts: profile.ssh.allowedHosts,
            agent: expandLocalPath(profile.ssh.agentSocket),
            knownHostsFile: profile.ssh.knownHostsFile
              ? expandLocalPath(profile.ssh.knownHostsFile)
              : path.join(EXTENSION_DIR, "github-known-hosts"),
            execPolicy: createSshExecPolicy(profile.ssh),
            upstreamReadyTimeoutMs: 60_000,
          }
        : undefined,
      tcp: profile.tcpHosts ? { hosts: profile.tcpHosts } : undefined,
      env: guestEnv,
      memory: profile.memory ?? "4G",
      cpus: profile.cpus ?? 2,
    });
    const bashProbe = await created.exec([
      "/bin/sh",
      "-lc",
      "command -v bash || true",
    ]);
    shellPath = bashProbe.stdout.trim() || "/bin/sh";
    // Host-owned mounts can trigger git's dubious-ownership check. Additional
    // toolchain provisioning belongs in the untracked local profile.
    const provisionCommands = [
      "if command -v git >/dev/null; then printf '[safe]\\n\\tdirectory = *\\n' >> /etc/gitconfig; fi",
      ...(profile.provisionCommands ?? []),
    ];
    const provision = await created.exec([
      "/bin/sh",
      "-lc",
      provisionCommands.join(" && "),
    ]);
    if (provision.exitCode !== 0) {
      ctx?.ui.notify(
        `Gondolin guest provisioning failed (exit ${provision.exitCode}); guest tools may misbehave.\n${provision.stderr}`.trim(),
        "warning",
      );
    }
    vm = created;
    ctx?.ui.setStatus(
      "gondolin",
      ctx.ui.theme.fg(
        "accent",
        `Gondolin: ${created.id.slice(0, 8)} (${profile.name ?? "local"}; ${localCwd})`,
      ),
    );
    ctx?.ui.notify(
      `Gondolin VM ready. Mounted at identical guest paths: ${mountList}.`,
      "info",
    );
    return created;
  }

  async function ensureVm(ctx?: ExtensionContext): Promise<VM> {
    if (vm) return vm;
    if (!vmStarting) {
      vmStarting = startVm(ctx).finally(() => {
        vmStarting = undefined;
      });
    }
    return vmStarting;
  }

  pi.on("session_start", async (_event, ctx) => {
    await ensureVm(ctx);
  });

  pi.on("session_shutdown", async (_event, ctx) => {
    const activeVm = vm;
    vm = undefined;
    vmStarting = undefined;
    if (!activeVm) return;
    ctx.ui.setStatus(
      "gondolin",
      ctx.ui.theme.fg("muted", "Gondolin: stopping"),
    );
    try {
      await activeVm.close();
    } finally {
      ctx.ui.setStatus("gondolin", undefined);
    }
  });

  pi.registerCommand("gondolin", {
    description: "Show Gondolin VM status",
    handler: async (_args, ctx) => {
      const activeVm = await ensureVm(ctx);
      ctx.ui.notify(
        [
          `Gondolin VM: ${activeVm.id}`,
          `Working directory: ${localCwd}`,
          `Profile: ${profile.name ?? "local"}`,
          `Mounts (identical guest paths): ${mountList}`,
          `Shell: ${shellPath}`,
        ].join("\n"),
        "info",
      );
    },
  });

  pi.registerTool({
    ...localRead,
    async execute(id, params, signal, onUpdate, ctx) {
      const activeVm = await ensureVm(ctx);
      const tool = createReadTool(localCwd, {
        operations: createGondolinReadOps(activeVm, localCwd),
      });
      return tool.execute(id, params, signal, onUpdate);
    },
  });

  pi.registerTool({
    ...localWrite,
    async execute(id, params, signal, onUpdate, ctx) {
      const activeVm = await ensureVm(ctx);
      const tool = createWriteTool(localCwd, {
        operations: createGondolinWriteOps(activeVm, localCwd),
      });
      return tool.execute(id, params, signal, onUpdate);
    },
  });

  pi.registerTool({
    ...localEdit,
    async execute(id, params, signal, onUpdate, ctx) {
      const activeVm = await ensureVm(ctx);
      const tool = createEditTool(localCwd, {
        operations: createGondolinEditOps(activeVm, localCwd),
      });
      return tool.execute(id, params, signal, onUpdate);
    },
  });

  pi.registerTool({
    ...localBash,
    async execute(id, params, signal, onUpdate, ctx) {
      const activeVm = await ensureVm(ctx);
      const tool = createBashTool(localCwd, {
        operations: createGondolinBashOps(
          activeVm,
          localCwd,
          shellPath,
          guestEnv,
        ),
      });
      return tool.execute(id, params, signal, onUpdate);
    },
  });

  pi.registerTool({
    ...localLs,
    async execute(id, params, signal, onUpdate, ctx) {
      const activeVm = await ensureVm(ctx);
      const tool = createLsTool(localCwd, {
        operations: createGondolinLsOps(activeVm, localCwd),
      });
      return tool.execute(id, params, signal, onUpdate);
    },
  });

  pi.registerTool({
    ...localFind,
    async execute(id, params, signal, onUpdate, ctx) {
      const activeVm = await ensureVm(ctx);
      const tool = createFindTool(localCwd, {
        operations: createGondolinFindOps(activeVm, localCwd),
      });
      return tool.execute(id, params, signal, onUpdate);
    },
  });

  pi.registerTool({
    ...localGrep,
    async execute(_id, params, signal, _onUpdate, ctx) {
      const activeVm = await ensureVm(ctx);
      return executeGondolinGrep(activeVm, localCwd, params, signal);
    },
  });

  pi.on("user_bash", async (_event, ctx) => {
    const activeVm = await ensureVm(ctx);
    return {
      operations: createGondolinBashOps(
        activeVm,
        localCwd,
        shellPath,
        guestEnv,
      ),
    };
  });

  pi.on("before_agent_start", async (event, ctx) => {
    await ensureVm(ctx);
    const note =
      `All tools run inside a Gondolin micro-VM sandbox. ` +
      `Host directories mounted read-write at identical guest paths: ${mountList}. ` +
      `The working directory is unchanged (${localCwd}). Network egress is restricted.`;
    return { systemPrompt: `${event.systemPrompt}\n\n${note}` };
  });
}
