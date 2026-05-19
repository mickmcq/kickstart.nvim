local api = vim.api
local ts = vim.treesitter

ts.language.register('markdown', 'quarto')
pcall(ts.start, 0, 'markdown')
vim.bo.syntax = 'ON'

vim.b.slime_cell_delimiter = '```'
vim.b['quarto_is_r_mode'] = nil
vim.b['reticulate_running'] = false

vim.bo.commentstring = '<!-- %s -->'
-- wrap text, but by word no character
-- indent the wrappped line
vim.wo.wrap = true
vim.wo.linebreak = true
vim.wo.breakindent = true
vim.wo.showbreak = '|'

-- don't run vim ftplugin on top
vim.api.nvim_buf_set_var(0, 'did_ftplugin', true)

-- continue bullet lists on Enter (deferred to avoid being overridden)
vim.bo.comments = 'b:-,b:+,b:*,b:1.'
vim.schedule(function()
  vim.bo.formatoptions = vim.bo.formatoptions .. 'ro'
end)

-- markdown vs. quarto hacks
local ns = vim.api.nvim_create_namespace 'QuartoHighlight'
vim.api.nvim_set_hl(ns, '@markup.strikethrough', { strikethrough = false })
vim.api.nvim_set_hl(ns, '@markup.doublestrikethrough', { strikethrough = true })
vim.api.nvim_win_set_hl_ns(0, ns)

-- vim.api.nvim_set_hl(0, '@markup.codecell', { bg = '#000055' })
vim.api.nvim_set_hl(0, '@markup.codecell', {
  link = 'CursorLine',
})

