" Override the system runtime/syntax/pandoc.vim (~125ms) with a no-op.
if exists('b:current_syntax')
  finish
endif
let b:current_syntax = 'pandoc'
