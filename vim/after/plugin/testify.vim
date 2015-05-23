if exists('g:loaded_testify')
    finish
endif
let g:loaded_testify = 1

if !exists('g:testify_launcher')
    let g:testify_launcher = "!"
endif

if !exists('g:testify_runners')
    let g:testify_runners = {
                \ 'cucumber': './bin/cucumber ',
                \ 'ruby': ' ruby ',
                \ 'rspec': './bin/rspec ',
                \ 'python': ' nosetests -s ' }
endif

command! -nargs=0 TestifyRunFile call testify#RunFile()
command! -nargs=0 TestifyRunFocused call testify#RunFocused()
