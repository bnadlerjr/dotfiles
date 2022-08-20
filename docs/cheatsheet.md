# Cheatsheet

## Vim

#### vim-abolish
* `:Subvert` works like `%s` with curly brace support
* can coerce text: `crs` -> `snake_case`, `cr-` -> `dash-case`, etc.

#### vim-conflicted
* `g conflicted` -> open vim w/ conflicted files opened
* `dgu`          -> diffget from the upstream version
* `dgl`          -> diffget from the local version
* `]m`           -> resolve and move to next conflicted file

#### vim-lexical
* `zg` / `zug` -> mark / unmark word as good
* `zw` / `zuw` -> mark / unmark word as bad
* `<Leader>s`  -> suggest spellings
* `<Leader>t`  -> thesaurus

### Language Specific

#### Clojure
* Leiningen plugin  -> `:plugins [[cider/cider-nrepl "0.24.0"]]`
* `<LocalLeader>r`  -> `:Require`
* `<LocalLeader>R`  -> `:Require!`
* `<LocalLeader>ei` -> `Eval` inner
* `<LocalLeader>ee` -> `Eval`
* `<LocalLeader>et` -> `Eval` top
* `cp{motion}`      -> `Eval` motion
* `cqq`             -> prompt w/ form under cursor
* `<f` / `>f`       -> move form
* `<e` / `>e`       -> move element
* `<I` / `>I`       -> insert

#### vim-ruby-refactoring
* `<Leader>rap`  -> RAddParameter
* `<Leader>rcpc` -> RConvertPostConditional
* `<Leader>rel`  -> RExtractLet
* `<Leader>rec`  -> RExtractConstant
* `<Leader>relv` -> RExtractLocalVariable
* `<Leader>rit`  -> RInlineTemp
* `<Leader>rrlv` -> RRenameLocalVariable
* `<Leader>rriv` -> RRenameInstanceVariable
* `<Leader>rem`  -> RExtractMethod
