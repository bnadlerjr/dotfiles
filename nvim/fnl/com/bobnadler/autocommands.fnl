(module com.bobnadler.autocommands
  {autoload {nvim aniseed.nvim}})

(nvim.ex.autocmd "BufRead,BufNewFile *.selmer set syntax=jinja")

(nvim.ex.autocmd "FileType make setlocal noexpandtab")

; Add spell checking and autowrap for Git commit messages
(nvim.ex.autocmd "Filetype gitcommit setlocal spell textwidth=72")

; Auto-clean fugitive buffers
(nvim.ex.autocmd "BufReadPost fugitive://* set bufhidden=delete")

; Word wrap with line breaks for text files
(nvim.ex.autocmd "BufRead,BufNewFile *.txt,*.md,*.markdown,*.rdoc set wrap linebreak nolist textwidth=79 wrapmargin=0")

; vim-lexical setup
(nvim.ex.autocmd "FileType gitcommit,markdown,md,txt,rdoc,html,erb,ruby,elixir,clojure,jinja call lexical#init()")
