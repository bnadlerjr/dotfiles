#!/bin/bash

# Finds all wiki pages that are linked to from other pages, but do not
# exist (i.e. finds "ghost" pages).
#
# The idea for this came from [this script][1].
#
# [1]: https://forum.obsidian.md/t/script-find-orphaned-links-linking-to-no-existing-note/6976
set -o errexit
set -o nounset
set -o pipefail
if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

VAULT_PATH="${HOME}/Dropbox/vimwiki"

find "${VAULT_PATH}" -iname '*.md' -exec basename {} \; | \
    sort -u | \
    sed "s/\.md//" | \
    tee "${VAULT_PATH}/notes_list.txt" > /dev/null

grep \
    --recursive \
    --only-matching \
    --ignore-case \
    --extended-regexp \
    --no-filename \
    -I \
    "\[\[([a-zA-Z0-9 ]*)\]\]" "${VAULT_PATH}" | \
    sort -u | \
    sed "s/\]]//" | sed 's/\[\[//' | \
    tee "${VAULT_PATH}/links_list.txt" > /dev/null

grep -Fxv -f "${VAULT_PATH}/notes_list.txt" "${VAULT_PATH}/links_list.txt"
