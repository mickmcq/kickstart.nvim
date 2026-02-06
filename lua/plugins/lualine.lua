return {
  {
    'nvim-lualine/lualine.nvim',
    enabled = true,
    event = 'VeryLazy', -- lazy load after startup
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      options = { theme = 'ayu_light' },
    },
  }
}
