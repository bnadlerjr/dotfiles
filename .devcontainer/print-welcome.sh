#!/usr/bin/env bash
set -euo pipefail

cat <<'EOF'

Container ready. Next steps:

  1. Open a shell inside this container. From your host terminal:

       cd <path-to-dotfiles>     # the repo containing .devcontainer/
       devcontainer exec --workspace-folder . bash

     If the devcontainer CLI isn't installed yet:
       npm install -g @devcontainers/cli

  2. Authenticate Claude Code (one-time per container volume):
       claude /login

  3. Start an agent:
       claude

Auth tokens persist in the dotfiles-claude Docker volume across restarts.

Firewall is active. Outbound traffic is restricted to:
  GitHub, npm, PyPI, anthropic.com (api/console/claude.ai),
  statsig.com, astral.sh.
Add MCP hosts to .devcontainer/init-firewall.sh as you need them.
EOF
