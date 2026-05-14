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
# host for any machine-specific overrides. Commit signing is disabled inside
# the container at the system level (see Dockerfile).
link "${WORKSPACE}/gitconfig"                   "${HOME}/.gitconfig"

link "${WORKSPACE_CLAUDE}/skills"               "${CLAUDE_DIR}/skills"
link "${WORKSPACE_CLAUDE}/commands"             "${CLAUDE_DIR}/commands"
link "${WORKSPACE_CLAUDE}/agents"               "${CLAUDE_DIR}/agents"
link "${WORKSPACE_CLAUDE}/guidelines"           "${CLAUDE_DIR}/guidelines"
link "${WORKSPACE_CLAUDE}/CLAUDE-PERSONAL.md"   "${CLAUDE_DIR}/CLAUDE.md"
link "${DEVCONTAINER_DIR}/settings.json"        "${CLAUDE_DIR}/settings.json"
