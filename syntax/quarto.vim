" Override the system runtime/syntax/quarto.vim (~140ms) with a no-op.
" Treesitter (via the markdown parser, registered for quarto in
" quarto-nvim's ftplugin) handles highlighting.
if exists('b:current_syntax')
  finish
endif
let b:current_syntax = 'quarto'
