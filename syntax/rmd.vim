" Override the system runtime/syntax/rmd.vim (~140ms) with a no-op.
" Treesitter handles highlighting via the markdown parser.
if exists('b:current_syntax')
  finish
endif
let b:current_syntax = 'rmd'
