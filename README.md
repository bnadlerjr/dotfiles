# Bob's Dotfiles
Dotfile setup based on Advanced Commandline screencast from PeepCode.

## Install
1. Clone to ~/dotfiles
2. Create symlinks to dotfiles by running `update_symlinks`
3. Install CtrlP C Matcher extension:

```bash
cd ~/.vim/bundle/ctrlp-cmatcher
./install.sh
```

4. Install LanguageClient-neovim

```bash
cd ~/.vim/bundle/LanguageClient-neovim
./install.sh
```

5. Install Elixir Language Server

```bash
$ mkdir -p ~/dev/elixir && cd ~/dev/elixir
$ git clone git@github.com:elixir-lsp/elixir-ls.git
$ cd elixir-ls && mkdir rel

# checkout the latest release
$ git checkout tags/v0.4.0

$ mix deps.get && mix compile

$ mix elixir_ls.release -o rel
```

6. Update Thesaurus for vim-lexical
```bash
./update_lexical.sh
```

## License
(The MIT License)

Copyright (c) 2009-2022 Bob Nadler, Jr.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
