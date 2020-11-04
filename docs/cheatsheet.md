# Cheatsheet

## Bash
Bash script template:
```bash
#!/bin/bash
set -euxo pipefail
```

## Vim

### General
* `<Leader>v` -> Edit `.vimrc` file

### Plugins

#### vim-abolish
* `:Subvert` works like `%s` with curly brace support
* can coerce text: `crs` -> `snake_case`, `cr-` -> `dash-case`, etc.


#### vim-grepper
* `<Leader>*` -> search for word under cursor
* `gs{motion}` -> search for text using motion

#### vim-lexical
* `zg` / `zug` -> mark / unmark word as good
* `zw` / `zuw` -> mark / unmark word as bad
* `<Leader>s` -> suggest spellings
* `<Leader>t` -> thesaurus

### Language Specific

#### Clojure
* Leiningen plugin -> `:plugins [[cider/cider-nrepl "0.24.0"]]`
* `<LocalLeader>r` -> `:Require`
* `<LocalLeader>R` -> `:Require!`
* `<LocalLeader>ei` -> `Eval` inner
* `<LocalLeader>ee` -> `Eval`
* `<LocalLeader>et` -> `Eval` top
* `cp{motion}` -> `Eval` motion
* `cqq` -> prompt w/ form under cursor
* `<f` / `>f` -> move form
* `<e` / `>e` -> move element
* `<I` / `>I` -> insert
