" Required for Vundle
filetype off

let need_to_install_plugins=0
if empty(system("grep lazy_load ~/.vim/bundle/Vundle.vim/autoload/vundle.vim"))
    silent !mkdir -p ~/.vim/bundle
    silent !rm -rf ~/.vim/bundle/Vundle.vim
    silent !git clone https://github.com/gmarik/vundle ~/.vim/bundle/Vundle.vim
    let need_to_install_plugins=1
endif

set runtimepath+=~/.vim/bundle/Vundle.vim

call vundle#begin()

Plugin 'gmarik/Vundle.vim'                          " let Vundle manage Vundle, required

Plugin 'AndrewRadev/writable_search.vim'            " Grep for something, then write the original files directly through the search results
Plugin 'DataWraith/auto_mkdir'                      " Allows you to save files into directories that do not exist yet
Plugin 'Glench/Vim-Jinja2-Syntax'                   " Jinja2 syntax highlighting
Plugin 'JazzCore/ctrlp-cmatcher'                    " CtrlP C matching extension
Plugin 'MarcWeber/vim-addon-mw-utils'               " vim-snipmate dependency
Plugin 'altercation/vim-colors-solarized'           " Solarized color theme
Plugin 'bkad/CamelCaseMotion'                       " provide CamelCase motion through words
Plugin 'bling/vim-airline'                          " lean & mean status/tabline for vim that's light as air
Plugin 'digitaltoad/vim-jade'                       " Jade syntax highlighting
Plugin 'ervandew/supertab'                          " Perform all your vim insert mode completions with Tab
Plugin 'garbas/vim-snipmate'                        " handy code snippets
Plugin 'godlygeek/csapprox'                         " dependency for Solarized
Plugin 'guns/vim-clojure-static'                    " Clojure syntax highlighting and indentation
Plugin 'guns/vim-sexp'                              " Precision editing for s-expressions
Plugin 'jpalardy/vim-slime'                         " Send code from vim buffer to a REPL
Plugin 'juvenn/mustache.vim'                        " Mustache support
Plugin 'kana/vim-textobj-user'                      " dependency for rubyblock
Plugin 'kchmck/vim-coffee-script'                   " ugh... a necessary evil... for now
Plugin 'kien/ctrlp.vim'                             " Fuzzy file, buffer, mru, tag, etc finder
Plugin 'nelstrom/vim-textobj-rubyblock'             " custom text object for selecting Ruby blocks
Plugin 'rking/ag.vim'                               " plugin for the_silver_searcher
Plugin 'scrooloose/nerdcommenter'                   " quickly (un)comment lines
Plugin 'tomtom/tlib_vim'                            " vim-snipmate dependency
Plugin 'tpope/vim-bundler'                          " makes source navigation of bundled gems easier
Plugin 'tpope/vim-classpath'                        " Clojure JVM classpath
Plugin 'tpope/vim-cucumber'                         " provides syntax highlightling, indenting, and a filetype plugin
Plugin 'tpope/vim-dispatch'                         " Asynchronous build and test dispatcher
Plugin 'tpope/vim-fireplace'                        " Clojure nrepl support
Plugin 'tpope/vim-fugitive'                         " Git plugin
Plugin 'tpope/vim-haml'                             " HAML support
Plugin 'tpope/vim-leiningen'                        " static support for Leiningen
Plugin 'tpope/vim-projectionist'                    " project configuration
Plugin 'tpope/vim-ragtag'                           " Ghetto HTML / XML mappings
Plugin 'tpope/vim-rails'                            " Rails helpers
Plugin 'tpope/vim-rake'                             " makes Ruby project navigation easier for non-Rails projects
Plugin 'tpope/vim-repeat'                           " Enable repeating supported plugin maps with '.'
Plugin 'tpope/vim-sexp-mappings-for-regular-people' " vim-sexp mappings rely on meta key; these don't
Plugin 'tpope/vim-surround'                         " makes working w/ quotes, braces,etc. easier
Plugin 'vim-ruby/vim-ruby'                          " packaged w/ vim but this is latest and greatest

call vundle#end()

if 1 == need_to_install_plugins
    silent! PluginInstall
    q
endif
