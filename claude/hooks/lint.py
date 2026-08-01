#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.8"
# dependencies = []
# ///

"""Claude Code PostToolUse adapter for the lint-file CLI.

Translation only: a payload on stdin becomes one CLI invocation and the CLI's
exit code becomes this hook's exit code. Every linting decision lives in
bin/lint-file, which knows nothing about Claude Code.
"""

import json
import subprocess
import sys
from pathlib import Path

# Anchored on this file's own location — the dotfiles checkout — not on the repo
# whose files are being edited, which is almost always a different one. PATH
# would find it too, since ~/bin symlinks here, but only once that link farm is
# installed, and another lint-file earlier on PATH would win.
CLI = Path(__file__).resolve().parents[2] / "bin" / "lint-file"


WRITING_TOOLS = ("Write", "Edit", "MultiEdit")

# The only exit codes the CLI defines: 0 silence, 1 a linter could not be run,
# 2 findings. Claude Code reads 2 as "block the edit".
CLI_EXIT_CODES = (0, 1, 2)


def run_hook(payload):
    """Invoke the CLI for the edited file and return its exit code.

    A code outside the CLI's own set means it died rather than reported — 127
    from a shebang whose interpreter is missing, or a negative code from a
    signal — so it becomes 1 instead of reaching the shell as a status nobody
    defined. Forwarded, a signal's -9 arrives as 247.
    """
    if payload.get("tool_name", "") not in WRITING_TOOLS:
        return 0

    file_path = payload.get("tool_input", {}).get("file_path", "")
    if not file_path:
        return 0

    code = subprocess.run([str(CLI), file_path], check=False).returncode

    return code if code in CLI_EXIT_CODES else 1


def main():
    try:
        payload = json.load(sys.stdin)
        code = run_hook(payload)
    # A bug in this adapter must not surface as a bare traceback on every edit.
    except Exception as e:  # noqa: BLE001
        print(f"lint hook: {type(e).__name__}: {e}", file=sys.stderr)
        code = 1

    sys.exit(code)


if __name__ == "__main__":
    main()
