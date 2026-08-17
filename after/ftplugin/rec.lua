-- Folding for GNU recutils files.
--
-- vim-rec's own ftplugin sets foldmethod=expr and foldexpr=GetRecFold(), but
-- that expression gives every field in a record the same level, so consecutive
-- fields merge into one fold and `zc` collapses the whole record. This file
-- replaces the expression with one that opens a fold per field, and tunes how
-- closed folds are rendered.
--
--   level 1  a record, starting at its first field
--   level 2  a single field whose value spans several lines
--   level 0  `%rec:` descriptor blocks, which stay unfolded
--
-- recutils writes a multi-line value two ways, and both fold: a `+` at the start
-- of the continuation line, or a `\` at the end of the line being continued.
--
-- A field with no continuation lines deliberately gets no fold of its own: a
-- one-line fold never renders closed (see 'foldminlines'), so it would only make
-- `zc` look dead on first press and make `zj`/`zk` stop on every field.
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

-- a trailing `\` pulls the following line into this one's value, whatever that
-- line looks like
local function continues_below(line)
  return line:match '\\%s*$' ~= nil
end

-- is `lnum` part of the value started on an earlier line?
local function is_continued_into(lnum)
  return lnum > 1 and continues_below(vim.fn.getline(lnum - 1))
end

-- does the field on `lnum` have continuation lines below it?
local function has_continuation(lnum)
  if continues_below(vim.fn.getline(lnum)) then
    return true
  end
  local last = vim.fn.line '$'
  local next_lnum = lnum + 1
  while next_lnum <= last and is_comment(vim.fn.getline(next_lnum)) do
    next_lnum = next_lnum + 1
  end
  return next_lnum <= last and is_continuation(vim.fn.getline(next_lnum))
end

function _G.RecFoldExpr()
  local lnum = vim.v.lnum
  local line = vim.fn.getline(lnum)

  if is_blank(line) then
    return '0'
  end

  -- a line pulled in by a trailing `\` belongs to the value above it even when
  -- it looks like a field or a descriptor of its own
  if is_continued_into(lnum) then
    return '='
  end

  if is_descriptor(line) then
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
    if not (is_comment(l) or is_continuation(l) or is_continued_into(prev)) then
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

  -- a later field in the record: worth its own fold only if it continues
  return has_continuation(lnum) and '>2' or '1'
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
