augroup custom_templates
  autocmd!
  autocmd BufNewFile *.rb 0r ~/.vim/templates/skeleton.rb
  autocmd BufNewFile *.sh 0r ~/.vim/templates/skeleton.sh
augroup END
