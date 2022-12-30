local F     = require('utils.functions')
local strf  = string.format
local hl_no = '%#SlNo#'; local hl_it = '%#SlIt#'; local hl_git = '%#SlGit#'


local get_mode = function()
  local mode = vim.api.nvim_get_mode().mode

  if      mode == 'V'   then mode = 'VL'
  elseif  mode == ''  then mode = 'VB' end

  return mode:upper()
end


local get_mode_colour = function()
  local mode = vim.api.nvim_get_mode().mode

  if      mode == 'V' or mode == '' then mode = 'v'
  elseif  mode == 'nt'                then mode = 'n' end

  local main  = strf('%s%s#', '%#mode', mode:upper())
  local aux   = strf('%s%sx#', '%#mode', mode:upper())
  return main, aux
end


local get_search_count = function()
  local s   = vim.fn.searchcount({maxcount=0})
  local cur = s.current; local tot = s.total; local cmp = s.incomplete

  if s.exact_match == 0 then cur = 0 end
  if cmp == 1           then return cur..'/?' end

  return cur..'/'..tot
end


local get_git = function()
  local fh; local head = ''

  fh        = io.popen('git rev-parse --is-inside-work-tree 2>/dev/null', 'r')
  local git = F.chop(fh:read('*a')); fh:close()

  if git == 'true' then
    fh    = io.popen('git branch --show-current', 'r')
    head  = F.chop(fh:read('*a')); fh:close()

    if head == '' then
      fh    = io.popen('git describe --tags @', 'r')
      head  = 'tag:'..F.chop(fh:read('*a')); fh:close()
    end

    if head == '' then
      fh    = io.popen('git rev-parse @', 'r')
      head  = fh:read('*a'); fh:close()
      head  = head:sub(1, 7)
    end
    head = strf(' %s %s%s', hl_git, head, hl_no)
  end

  return head
end


local get_bufname = function()
  local bufname = vim.fn.bufname()
  if bufname == '' then bufname = '[null]'
  else                  bufname = string.gsub(bufname, '.*/', '') end

  local hl      = false
  local hl_ro   = '%#SlRo#'
  local hl_rox  = '%#SlRox#'
  if vim.api.nvim_buf_get_option(0, 'readonly') then hl = true end

  if hl then
    return strf('%s%s%s%s', hl_rox, hl_ro, bufname, hl_rox)
  else
    return bufname..' '
  end
end


local get_bufnr = function() return '%n' end


local get_modified = function()
  local modified = ''
  if vim.api.nvim_buf_get_option(0, 'modified') then  modified = ' ' end
  return modified
end


local get_bytecount = function()
  local count = vim.fn.line2byte('$') + vim.fn.len(vim.fn.getline('$'))
  if count == -1 then count = 0 end
  return count..'B'
end


local get_position = function() return '%l:%v' end


local set_statusline = function()
  local main, aux = get_mode_colour(vim.api.nvim_get_mode().mode)
  local mode  = strf('%s%s%s%s%s', aux, main, get_mode(), aux, hl_no)
  local bufnr = strf('%s(%s)', hl_no, get_bufnr())

  return table.concat({
    hl_no, ' ', mode, '%<', get_git(), hl_no,
    '%=',
    get_modified(), hl_it, get_bufname(), bufnr,
    '%=',
    get_bytecount(), '  ', get_search_count(), '  ', get_position(), ' '
  })
end


_G.statusline = set_statusline
F.o('laststatus', 3)
F.o('statusline', '%!v:lua.statusline()')
