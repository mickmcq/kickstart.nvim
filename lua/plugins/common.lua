return {
  -- common dependencies
  { 'nvim-lua/plenary.nvim' },
  {
    'folke/snacks.nvim',
    dev = false,
    priority = 1000,
    lazy = false,
    opts = {
      styles = {},
      bigfile = { notify = false },
      quickfile = { enabled = false }, -- disabled: triggers treesitter 'range' error on nvim 0.12
      picker = {
        ui_select = false, -- keep native vim.ui.select instead of the snacks picker
      },
      indent = {},
    },
  },
}
