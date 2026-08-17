-- Folding for GNU recutils files.
--
-- vim-rec's own ftplugin already sets foldmethod=expr and foldexpr=GetRecFold(),
-- which gives one fold per record (level 1) containing its fields (level 2) and
-- multiline continuations (level 3). This file only tunes how those folds behave
-- and how a closed fold is rendered.
--
-- This lives in after/ftplugin because ~/.config/nvim comes first in the
-- runtimepath: a plain ftplugin/rec.lua would be sourced *before* vim-rec's and
-- have its fold settings overwritten.

-- render a closed record as its first field plus a line count,
-- e.g. `name: Ada Lovelace  ⋯ 7 lines`
function _G.RecFoldText()
  local first = vim.fn.getline(vim.v.foldstart)
  local lines = vim.v.foldend - vim.v.foldstart + 1
  return string.format('%s  ⋯ %d lines', first, lines)
end

vim.opt_local.foldtext = 'v:lua.RecFoldText()'
vim.opt_local.foldenable = true

-- start with every record expanded; `zM` collapses them all, `zR` reopens
vim.opt_local.foldlevel = 99

vim.b.undo_ftplugin = (vim.b.undo_ftplugin or 'exe')
  .. ' | setlocal foldtext< foldenable< foldlevel<'
