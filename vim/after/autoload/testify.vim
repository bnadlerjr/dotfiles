" Run a test file. If the current file is a test, save the filename in
" `t:testify_current_filename` and run it. Otherwise run the file currently
" stored in `t:testify_current_filename`.
function testify#RunFile()
    try
        call s:SetCurrentTestFilename()
        execute g:testify_launcher .
                    \ s:DetermineRunner() .
                    \ t:testify_current_filename
    endtry
endfunction

" Works the same as `testify#RunFile` except runs a specific test instead of
" the entire file.
function testify#RunFocused()
    try
        call s:SetCurrentTestFilename()
        execute g:testify_launcher .
                    \ s:DetermineRunner() .
                    \ t:testify_current_filename .
                    \ ":" . line(".")
    endtry
endfunction

function s:SetCurrentTestFilename()
    let filename = expand("%")
    if -1 != match(filename, '.feature\|\(_spec\|_test\).rb\|_test.py$')
        let t:testify_current_filename = filename
    elseif !exists("t:testify_current_filename")
        throw "No test file found."
    end
endfunction

function s:DetermineRunner()
    let runner = &filetype
    if 1 == has_key(g:testify_runners, runner)
        return g:testify_runners[runner]
    else
        throw "No test runner specified for " . runner
    end
endfunction
