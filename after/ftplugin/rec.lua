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
--   level 0  `%rec:` descriptor blocks, which stay unfolded
--
-- This lives in after/ftplugin because ~/.config/nvim comes first in the
-- runtimepath: a plain ftplugin/rec.lua would be sourced *before* vim-rec's and
-- have its fold settings overwritten.

local function is_blank(line)
  return line:match '^%s*$' ~= nil
end

local function is_field(line)
  return line:match '^%a[%w_]*%s*:' ~= nil
end

-- `%rec:`, `%mandatory:` and friends describe a record set rather than belong
-- to a record, and are left unfolded so they stay visible
local function is_descriptor(line)
  return line:match '^%%' ~= nil
end

-- comments attach to whatever they follow rather than breaking a record apart,
-- and a `+` line continues the field above it
local function is_comment(line)
  return line:match '^#' ~= nil
end

local function is_continuation(line)
  return line:match '^%+' ~= nil
end

function _G.RecFoldExpr()
  local lnum = vim.v.lnum
  local line = vim.fn.getline(lnum)

  if is_blank(line) or is_descriptor(line) then
    return '0'
  end

  -- `+` continuations and comments stay at the level of the line above, which
  -- also keeps a continued descriptor field at level 0
  if not is_field(line) then
    return lnum == 1 and '0' or '='
  end

  -- a field opens a record when the line that owns the text above it is blank or
  -- a descriptor, otherwise it is one more field in the current record. comments
  -- and continuations aren't owners, so look past them.
  local prev = lnum - 1
  while prev >= 1 do
    local l = vim.fn.getline(prev)
    if not (is_comment(l) or is_continuation(l)) then
      break
    end
    prev = prev - 1
  end
  if prev < 1 then
    return '>1'
  end
  local prev_line = vim.fn.getline(prev)
  if is_blank(prev_line) or is_descriptor(prev_line) then
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
