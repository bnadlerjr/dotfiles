#!/usr/bin/env bash
set -euo pipefail

readonly CLAUDE_DIR="${HOME}/.claude"
readonly WORKSPACE="/workspace"
readonly WORKSPACE_CLAUDE="${WORKSPACE}/claude"
readonly DEVCONTAINER_DIR="${WORKSPACE}/.devcontainer"

mkdir -p "${CLAUDE_DIR}/plans"

link() {
    local target="$1"
    local link_path="$2"
    ln -sfn "${target}" "${link_path}"
    echo "linked ${link_path} -> ${target}"
}

# Inherit the host gitconfig (identity, aliases, delta). The tracked file
# includes ~/.gitconfig.local, which the devcontainer mounts read-only from the
# host for any machine-specific overrides. Commit signing is then disabled by
# the container-only include below, since the host's signer (1Password
# op-ssh-sign) lives in macOS's Group Containers and isn't reachable here.
link "${WORKSPACE}/gitconfig"                   "${HOME}/.gitconfig"

cat > "${HOME}/.gitconfig.devcontainer" <<'EOF'
[commit]
    gpgsign = false
[tag]
    gpgsign = false
EOF

# Inherit the host bash setup (aliases, env, prompt). The tracked bashrc sources
# ~/dotfiles/bash/{env,config,aliases,git-prompt}, so ~/dotfiles is linked to the
# workspace to keep those paths resolving without rewriting the host file.
link "${WORKSPACE}"                             "${HOME}/dotfiles"
link "${WORKSPACE}/bashrc"                      "${HOME}/.bashrc"

link "${WORKSPACE_CLAUDE}/skills"               "${CLAUDE_DIR}/skills"
link "${WORKSPACE_CLAUDE}/commands"             "${CLAUDE_DIR}/commands"
link "${WORKSPACE_CLAUDE}/agents"               "${CLAUDE_DIR}/agents"
link "${WORKSPACE_CLAUDE}/hooks"                "${CLAUDE_DIR}/hooks"
link "${WORKSPACE_CLAUDE}/guidelines"           "${CLAUDE_DIR}/guidelines"
link "${WORKSPACE_CLAUDE}/CLAUDE-PERSONAL.md"   "${CLAUDE_DIR}/CLAUDE.md"

# Use the host settings.json as the user-level config — this brings the hooks
# block, model pin, and statusline along. Container-only overrides (deny list,
# defaultMode=auto) live in settings.local.json and are merged on top.
link "${WORKSPACE_CLAUDE}/settings.json"        "${CLAUDE_DIR}/settings.json"
link "${DEVCONTAINER_DIR}/settings.json"        "${CLAUDE_DIR}/settings.local.json"
