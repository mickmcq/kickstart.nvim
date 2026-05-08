
return {
  { -- terminal
    'akinsho/toggleterm.nvim',
    cmd = { 'ToggleTerm', 'TermExec', 'ToggleTermToggleAll', 'ToggleTermSendCurrentLine', 'ToggleTermSendVisualLines', 'ToggleTermSendVisualSelection' },
    keys = { [[<c-\>]] },
    opts = {
      open_mapping = [[<c-\>]],
      direction = 'float',
    },
  },
}
