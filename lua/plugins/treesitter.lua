return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',
    cmd = { 'TSInstall', 'TSUpdate', 'TSUpdateSync', 'TSUninstall' },
    dependencies = {
      { 'nvim-treesitter/nvim-treesitter-textobjects', branch = 'main' },
    },
    config = function()
      require('nvim-treesitter').setup {}

      require('nvim-treesitter').install {
        'r',
        'python',
        'markdown',
        'markdown_inline',
        'julia',
        'bash',
        'yaml',
        'lua',
        'vim',
        'query',
        'vimdoc',
        'latex',
        'html',
        'css',
        'dot',
        'javascript',
        'mermaid',
        'norg',
        'typescript',
      }

      vim.api.nvim_create_autocmd('FileType', {
        callback = function(ev)
          local ft = vim.bo[ev.buf].filetype
          local lang = vim.treesitter.language.get_lang(ft) or ft
          if pcall(vim.treesitter.language.add, lang) then
            pcall(vim.treesitter.start, ev.buf, lang)
          end
        end,
      })

      require('nvim-treesitter-textobjects').setup {
        select = { lookahead = true },
        move = { set_jumps = true },
      }

      local select = require 'nvim-treesitter-textobjects.select'
      local move = require 'nvim-treesitter-textobjects.move'

      local function map_select(key, capture, desc)
        vim.keymap.set({ 'x', 'o' }, key, function()
          select.select_textobject(capture, 'textobjects')
        end, { desc = desc })
      end

      local function map_move(key, fn, capture, desc)
        vim.keymap.set({ 'n', 'x', 'o' }, key, function()
          fn(capture, 'textobjects')
        end, { desc = desc })
      end

      map_select('af', '@function.outer', 'select around function')
      map_select('if', '@function.inner', 'select inside function')
      map_select('ac', '@class.outer', 'select around class')
      map_select('ic', '@class.inner', 'select inside class')

      map_move(']m', move.goto_next_start, '@function.outer', 'next function start')
      map_move(']]', move.goto_next_start, '@class.inner', 'next class start')
      map_move(']M', move.goto_next_end, '@function.outer', 'next function end')
      map_move('][', move.goto_next_end, '@class.outer', 'next class end')
      map_move('[m', move.goto_previous_start, '@function.outer', 'prev function start')
      map_move('[[', move.goto_previous_start, '@class.inner', 'prev class start')
      map_move('[M', move.goto_previous_end, '@function.outer', 'prev function end')
      map_move('[]', move.goto_previous_end, '@class.outer', 'prev class end')
    end,
  },
}
