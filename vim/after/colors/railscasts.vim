" Vim color file

set background=dark

let g:colors_name = "railscasts"

" Color definitions
let bright_charcoal   = '#333435'
let bright_lime_green = '#a5c261'
let cappuccino        = '#bc9458'
let film_pro_orange   = '#da4939'
let hawkes_blue       = '#d0d0ff'
let hero              = '#cc7833'
let pitch_black       = '#2b2b2b'
let shakespeare       = '#6d9cbe'
let wan_white         = '#e6e1dc'

" Non-text settings
exe 'hi Cursor     guifg=' . wan_white
exe 'hi CursorLine guibg=' . bright_charcoal
exe 'hi LineNr     guifg=' . wan_white . ' guibg=' . pitch_black
exe 'hi Nontext    guifg=' . bright_charcoal
exe 'hi Normal     guifg=' . wan_white . ' guibg=' . pitch_black

" General syntax settings
exe 'hi Boolean    guifg=' . shakespeare
exe 'hi Comment    guifg=' . cappuccino        . ' gui=italic'
exe 'hi Constant   guifg=' . shakespeare
exe 'hi Define     guifg=' . hero
exe 'hi Error      guifg=' . bright_charcoal   . ' gui=bold'
exe 'hi Float      guifg=' . bright_lime_green
exe 'hi Identifier guifg=' . hawkes_blue
exe 'hi Keyword    guifg=' . hero              . ' gui=bold'
exe 'hi Number     guifg=' . bright_lime_green
exe 'hi PreProc    guifg=' . wan_white
exe 'hi Special    guifg=' . wan_white
exe 'hi Statement  guifg=' . film_pro_orange
exe 'hi String     guifg=' . bright_lime_green
exe 'hi Todo       guifg=' . bright_charcoal   . ' gui=bold'
exe 'hi Type       guifg=' . film_pro_orange
