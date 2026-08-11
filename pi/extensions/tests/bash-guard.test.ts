import assert from "node:assert/strict";
import { describe, test } from "node:test";

import { classifyBashCommand } from "../bash-guard/policy.ts";

type Action = ReturnType<typeof classifyBashCommand>["action"];

function expectAction(command: string, expected: Action): void {
  assert.equal(classifyBashCommand(command).action, expected, command);
}

describe("simple shell syntax", () => {
  test("allows metacharacters that are inert inside arguments", () => {
    expectAction('rg "foo|bar" .', "allow");
    expectAction('python -c "print(1); print(2)"', "allow");
    expectAction('grep "a>b" file', "allow");
    expectAction("printf '%s|%s' a b", "allow");
    expectAction("echo \\|", "allow");
    expectAction("echo '$(date)'", "allow");
  });

  test("blocks composition, redirection, and command substitution", () => {
    for (const command of [
      "echo foo; echo bar",
      "echo foo && echo bar",
      "echo foo | cat",
      "echo foo > output",
      "cat < input",
      'echo "$(date)"',
      "echo `date`",
      "echo foo\necho bar",
      "echo \0",
    ]) {
      expectAction(command, "block");
    }
  });

  test("blocks empty input", () => {
    expectAction("", "block");
    expectAction("   ", "block");
  });
});

describe("hard blocks", () => {
  test("covers each prohibited operation family", () => {
    for (const command of [
      "sudo true",
      "/usr/bin/doas true",
      "su root",
      "shutdown now",
      "reboot",
      "mount /dev/x /mnt",
      "umount /mnt",
      "mkfs.ext4 /dev/x",
      "fdisk /dev/x",
      "parted /dev/x",
      "wipefs /dev/x",
      "cryptsetup erase volume",
      "MIX_ENV=prod mix ecto.drop",
      "MIX_ENV=production mix ecto.reset",
      "env MIX_ENV=prod mix ecto.rollback",
      "docker run --privileged image",
      "docker run -v /:/host image",
      "docker run --mount type=bind,source=/,dst=/host image",
      "docker run --mount type=bind,src=/,dst=/host image",
    ]) {
      expectAction(command, "block");
    }
  });

  test("does not mistake a subdirectory mount for host root", () => {
    expectAction("docker run -v /tmp:/tmp image", "allow");
    expectAction("docker run --mount type=bind,src=/tmp,dst=/tmp image", "allow");
  });
});

describe("approval gates", () => {
  test("covers each high-impact operation family", () => {
    for (const command of [
      "rm -rf tmp",
      "rm -fr tmp",
      "rm --recursive tmp",
      "git push origin main",
      "git reset --hard HEAD",
      "git clean -fd",
      "git branch -D old",
      "git branch --delete --force old",
      "terraform apply",
      "terraform destroy",
      "terraform import x y",
      "terraform force-unlock lock",
      "terraform state mv x y",
      "terraform state rm x",
      "terraform state push state.tfstate",
      "kubectl delete pod app",
      "helm upgrade app chart",
      "gh pr merge 123",
      "jira issue transition ABC-123 Done",
      "mix ecto.drop",
      "npm publish",
      "mix hex.publish",
      "docker system prune",
      "pkill server",
    ]) {
      expectAction(command, "confirm");
    }
  });
});

describe("invocation normalization", () => {
  test("recognizes paths, wrappers, assignments, and global options", () => {
    for (const command of [
      "/usr/bin/git push",
      "env git push",
      "command /usr/bin/git -C repo push",
      "CI=1 git push",
      "terraform -chdir=infra destroy",
      "kubectl --context prod delete pod app",
      "docker --context prod system prune",
      "npm --workspace package publish",
      "gh --repo org/repo pr merge 1",
    ]) {
      expectAction(command, "confirm");
    }
  });

  test("honors environment removal", () => {
    expectAction("MIX_ENV=prod env -u MIX_ENV mix ecto.drop", "confirm");
  });
});
