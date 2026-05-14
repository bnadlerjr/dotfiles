#!/usr/bin/env bash
set -euo pipefail

readonly CLAUDE_DIR="${HOME}/.claude"
readonly WORKSPACE_CLAUDE="/workspace/claude"
readonly DEVCONTAINER_DIR="/workspace/.devcontainer"

git config --global --add safe.directory /workspace

mkdir -p "${CLAUDE_DIR}/plans"

link() {
    local target="$1"
    local link_path="$2"
    ln -sfn "${target}" "${link_path}"
    echo "linked ${link_path} -> ${target}"
}

link "${WORKSPACE_CLAUDE}/skills"               "${CLAUDE_DIR}/skills"
link "${WORKSPACE_CLAUDE}/commands"             "${CLAUDE_DIR}/commands"
link "${WORKSPACE_CLAUDE}/agents"               "${CLAUDE_DIR}/agents"
link "${WORKSPACE_CLAUDE}/guidelines"           "${CLAUDE_DIR}/guidelines"
link "${WORKSPACE_CLAUDE}/CLAUDE-PERSONAL.md"   "${CLAUDE_DIR}/CLAUDE.md"
link "${DEVCONTAINER_DIR}/settings.json"        "${CLAUDE_DIR}/settings.json"
