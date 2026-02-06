-- git plugins

return {
  { 'sindrets/diffview.nvim', cmd = { 'DiffviewOpen', 'DiffviewFileHistory' } },

  -- handy git ui
  {
    'NeogitOrg/neogit',
    lazy = true,
    cmd = 'Neogit',
    keys = {
      { '<leader>gg', ':Neogit<cr>', desc = 'neo[g]it' },
    },
    config = function()
      require('neogit').setup {
        disable_commit_confirmation = true,
        integrations = {
          diffview = true,
        },
      }
    end,
  },

  {
    'lewis6991/gitsigns.nvim',
    enabled = true,
    event = 'VeryLazy', -- defer loading until after startup
    opts = {},
  },
  {
    'akinsho/git-conflict.nvim',
    version = '^2.1.0',
    event = 'VeryLazy', -- defer loading until after startup
    opts = {
      default_mappings = false,
      disable_diagnostics = true,
    },
    keys = {
      { '<leader>gco', ':GitConflictChooseOurs<cr>' },
      { '<leader>gct', ':GitConflictChooseTheirs<cr>' },
      { '<leader>gcb', ':GitConflictChooseBoth<cr>' },
      { '<leader>gc0', ':GitConflictChooseNone<cr>' },
      { ']x', ':GitConflictNextConflict<cr>' },
      { '[x', ':GitConflictPrevConflict<cr>' },
    },
  },
  {
    'f-person/git-blame.nvim',
    event = 'VeryLazy', -- defer loading until after startup
    opts = {
      enabled = false,
    },
    config = function(_, opts)
      require('gitblame').setup(opts)
      vim.g.gitblame_display_virtual_text = 1
    end,
  },

  { -- github PRs and the like with gh - cli
    'pwntester/octo.nvim',
    enabled = true,
    cmd = 'Octo',
    config = function()
      require('octo').setup()
      vim.keymap.set('n', '<leader>gpl', ':Octo pr list<cr>', { desc = 'octo [p]r list' })
      vim.keymap.set('n', '<leader>gpr', ':Octo review start<cr>', { desc = 'octo [r]eview' })
    end,
  },
}
