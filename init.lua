-- NOTE: Throughout this config, some plugins are
-- disabled by default. This is because I don't use
-- them on a daily basis, but I still want to keep
-- them around as examples.
-- You can enable them by changing `enabled = false`
-- to `enabled = true` in the respective plugin spec.
-- Some of these also have the
-- PERF: (performance) comment, which
-- indicates that I found them to slow down the config.
-- (may be outdated with newer versions of the plugins,
-- check for yourself if you're interested in using them)

-- vim.treesitter.language.add('pandoc_markdown', { path = "/usr/local/lib/libtree-sitter-pandoc-markdown.so" })
-- vim.treesitter.language.add('pandoc_markdown_inline', { path = "/usr/local/lib/libtree-sitter-pandoc-markdown-inline.so" })
-- vim.treesitter.language.register('pandoc_markdown', { 'quarto', 'rmarkdown' })

-- Disable unused providers to skip startup probes
-- (re-enable python3 by setting to 1 and `pip install pynvim` if you start using molten-nvim)
vim.g.loaded_python3_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0

-- Disable built-in editorconfig support
vim.g.editorconfig = false

-- Add Mason's bin directory to PATH so LSP servers can be spawned before
-- mason.setup() runs (mason is now lazy-loaded; this avoids the chicken-and-egg).
vim.env.PATH = vim.fn.stdpath('data') .. '/mason/bin:' .. vim.env.PATH

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true
-- Show which line your cursor is on
vim.o.cursorline = true
-- Minimal number of screen lines to keep above and below the cursor.
vim.o.scrolloff = 5

vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.opt.foldlevel = 99
vim.api.nvim_set_keymap('n', '<C-t>', 'i<C-R>=strftime("%Y-%m-%d %H:%M:%S")<CR><Esc>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<C-t>', '<C-R>=strftime("%Y-%m-%d %H:%M:%S")<CR>', { noremap = true, silent = true })

require('config.global')
require('config.lazy')
require('config.autocommands')
require('config.redir')


-- NOTE: render-markdown and lualine setup moved to their plugin spec files for lazy loading


vim.cmd.colorscheme 'oscura'
vim.api.nvim_set_hl(0, 'TermCursor', { fg = '#A6E3A1', bg = '#A6E3A1' })
vim.api.nvim_set_hl(0, 'WinSeparator', { fg = 'dimgray', bg = '' })
vim.opt.guicursor = "n-v-c:block-Cursor,i-ci-ve:ver25,r-cr-o:hor20"
-- This makes the cursor swap the foreground and background colors of the character it is over
-- vim.api.nvim_set_hl(0, 'Cursor', { fg = '#A6E3A1', guibg = 'bla', reverse = true })


vim.keymap.set('n', 'j', 'gj', { noremap = true, silent = true, desc = 'Move down by display line' })
vim.keymap.set('n', 'k', 'gk', { noremap = true, silent = true, desc = 'Move up by display line' })
vim.api.nvim_set_hl(0, "quartoCodeOptions", { bold = true , underline = true})

-- make neovim reopen files at the last cursor position
vim.api.nvim_create_autocmd("BufReadPost", {
  pattern = "*",
  callback = function()
    local last_pos_line = vim.fn.line("'\"")
    local total_lines = vim.fn.line("$")
    if last_pos_line > 1 and last_pos_line <= total_lines then
      vim.cmd("normal! g'\"")
    end
  end,
})

vim.api.nvim_set_keymap("n", "L", "L", { noremap = true})
vim.api.nvim_set_keymap("n", "H", "H", { noremap = true})
vim.keymap.set('n', '<C-CR>', '<Plug>SlimeLineSend', { noremap = false })
vim.g.slime_target = "kitty"
vim.g.slime_bracketed_paste = 1
vim.g.slime_python_ipython = 0
vim.g.slime_paste_file = vim.fn.expand("$HOME/.slime_paste")

-- Your keybindings
vim.keymap.set('n', '<C-CR>', '<Plug>SlimeParagraphSend', { noremap = false })
vim.keymap.set('i', '<C-CR>', '<Esc><Plug>SlimeParagraphSendi', { noremap = false })
vim.keymap.set('x', '<C-CR>', '<Plug>SlimeRegionSend', { noremap = false })

-- insert notes in quarto presentations
vim.keymap.set('n', '<leader>n', 'O::: {.notes}<cr>:::<esc>O', {noremap = true})

-- toggle transparent background with <leader>t
local is_transparent = true
function ToggleTransparency()
    if is_transparent then
        vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })
        vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })
        vim.api.nvim_set_hl(0, "LineNr", { bg = "NONE" })
        -- Add other groups as needed (e.g., Pmenu, SignColumn)
    else
        -- Reload colorscheme or set default background
        vim.cmd("colorscheme " .. vim.g.colors_name)
    end
    is_transparent = not is_transparent
end

vim.api.nvim_create_user_command("ToggleTransparency", ToggleTransparency, {})
-- Map to a key, e.g., <leader>t
vim.keymap.set("n", "<leader>t", ":ToggleTransparency<CR>")

-- Use :R terminal-command instead of :! terminal-command
  vim.api.nvim_create_user_command('R', function(opts)
    vim.cmd('split | terminal ' .. opts.args)
    local bufnr = vim.api.nvim_get_current_buf()
    vim.api.nvim_create_autocmd('TermClose', {
      buffer = bufnr,
      once = true,
      callback = function()
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<CR>', ':bdelete!<CR>', { silent = true })
        print('Press Enter to close')
      end
    })
  end, { nargs = '+' })

-- Example function to toggle completion
local function toggle_completion()
  vim.b.completion = not vim.b.completion
  if not vim.b.completion then
    require("blink.cmp").hide() -- Hide the completion menu if disabled
  end
end

-- Set a keymap (e.g., <C-q> in insert and normal modes)
vim.keymap.set({ "i", "n" }, "<leader><C-b>", toggle_completion, { desc = "Toggle Completion" })

-- Enable mouse in all modes
vim.opt.mouse = 'a'

-- Show a 2-character wide column for folding indicators
vim.opt.foldcolumn = '2'

vim.opt.wrap = true       -- Enable soft wrap
vim.opt.linebreak = true  -- Wrap at word boundaries
vim.opt.textwidth = 0     -- Set to 0 to disable hard wrapping by default

-- vim-llama Toggle with <Leader>lt
vim.keymap.set('n', '<Leader>lt', ':LlamaToggle<CR>', { desc = 'Toggle Llama' })

