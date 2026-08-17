-- Folding for GNU recutils files.
--
-- vim-rec's own ftplugin sets foldmethod=expr and foldexpr=GetRecFold(), but
-- that expression gives every field in a record the same level, so consecutive
-- fields merge into one fold and `zc` collapses the whole record. This file
-- replaces the expression with one that opens a fold per field, and tunes how
-- closed folds are rendered.
--
--   level 1  a record, starting at its first field
--   level 2  a single field, plus any `+` continuation lines
--
-- This lives in after/ftplugin because ~/.config/nvim comes first in the
-- runtimepath: a plain ftplugin/rec.lua would be sourced *before* vim-rec's and
-- have its fold settings overwritten.

local function is_blank(line)
  return line:match '^%s*$' ~= nil
end

-- `%rec:` and friends are descriptors, `Title:` is an ordinary field; both
-- open a fold the same way
local function is_field(line)
  return line:match '^%%?%a[%w_]*%s*:' ~= nil
end

-- comments attach to whatever they follow rather than breaking a record apart
local function is_comment(line)
  return line:match '^#' ~= nil
end

function _G.RecFoldExpr()
  local lnum = vim.v.lnum
  local line = vim.fn.getline(lnum)

  if is_blank(line) then
    return '0'
  end

  -- `+` continuations and comments stay at the level of the line above
  if not is_field(line) then
    return lnum == 1 and '0' or '='
  end

  -- a field opens a record when the nearest preceding line that isn't a
  -- comment is blank, otherwise it is one more field within the current record
  local prev = lnum - 1
  while prev >= 1 and is_comment(vim.fn.getline(prev)) do
    prev = prev - 1
  end
  if prev < 1 or is_blank(vim.fn.getline(prev)) then
    return '>1'
  end
  return '>2'
end

-- render a closed fold as its first line plus a line count,
-- e.g. `Notes: see also  ⋯ 3 lines`
function _G.RecFoldText()
  local first = vim.fn.getline(vim.v.foldstart)
  local lines = vim.v.foldend - vim.v.foldstart + 1
  return string.format('%s  ⋯ %d line%s', first, lines, lines == 1 and '' or 's')
end

vim.opt_local.foldexpr = 'v:lua.RecFoldExpr()'
vim.opt_local.foldtext = 'v:lua.RecFoldText()'
vim.opt_local.foldenable = true

-- start with every record expanded; `zM` collapses them all, `zR` reopens
vim.opt_local.foldlevel = 99

vim.b.undo_ftplugin = (vim.b.undo_ftplugin or 'exe')
  .. ' | setlocal foldexpr< foldtext< foldenable< foldlevel<'
