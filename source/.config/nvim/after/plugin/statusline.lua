local F     = require('utils.functions')
local v     = vim
local strf  = string.format
local hl_no = '%#SlNormal#'; local hl_it = '%#SlItalic#'


-- auxiliary functions
local open = function(tbl, err_null, ret_nil)
  if err_null then table.insert(tbl, '2>/dev/null') end

  local fh = io.popen(table.concat(tbl, ' '), 'r')
  if fh == nil then return ret_nil else return fh end
end

local read = function(fh)
  local ret = F.chop(fh:read('*a'))
  fh:close()
  return ret
end


local resolve_dir = function()
  local buf = v.fn.bufname()
  local res = v.loop.fs_readlink(buf)
  return v.fs.dirname(res ~= '' and res or buf)
end

local resolve_file = function()
  local buf   = v.fn.bufname()
  local res   = v.loop.fs_readlink(buf)
  return res ~= '' and res or buf
end


local is_vcs = function()
  local fh  = open({
    'git', '-C', resolve_dir(),
    'rev-parse', '--is-inside-work-tree' }, true, false)
  local vcs = read(fh)

  if vcs == 'true' then return true
  else                  return false end
end


-- main functions
local get_mode = function()
  local mode = v.api.nvim_get_mode().mode

  if      mode == 'V'   then mode = 'VL'
  elseif  mode == ''  then mode = 'VB' end

  return mode:upper()
end


local get_mode_colour = function()
  local mode = v.api.nvim_get_mode().mode

  if      mode == 'V' or mode == '' then mode = 'v'
  elseif  mode == 'nt'                then mode = 'n' end

  local main  = strf('%s%s#', '%#mode', mode:upper())
  local aux   = strf('%s%sx#', '%#mode', mode:upper())
  return main, aux
end


local git = function()
  if not is_vcs() then return '' end

  local fh; local head = ''; local dir = resolve_dir()

  fh    = open({ 'git', '-C', dir, 'branch', '--show-current' }, false, '')
  head  = read(fh)

  if head == '' then
    fh    = open({
      'git', '-C', dir,
      'describe', '--tags', '--exact-match', '@' }, true, '')
    head  = 'tag:'..read(fh)
  end

  if head == 'tag:' then
    fh    = open({ 'git', '-C', dir, 'rev-parse', '@' }, false, '')
    head  = string.sub(read(fh), 1, 7)
  end
  head = strf(' %s %s%s', '%#Git#', head, hl_no)

  return head
end


local diff = function()
  if not is_vcs() then return '' end

  local fh = open({
    'git', '-C', resolve_dir(),
    'diff', '--numstat', resolve_file() }, true, '')
  local numstat = read(fh)

  if numstat == '' then
    local ret = '+0 -0'

    fh = open({
      'git', '-C', resolve_dir(),
      'ls-files', '--error-unmatch', resolve_file() }, true, '')
    if read(fh) == '' then ret = 'untracked' end

    return ' %#neutral#'..ret
  end

  local add = string.match(numstat, '%d+')
  local del = string.match(numstat, '%d+', string.len(add) + 1)

  local hl_a = add == '0' and '%#neutral#' or '%#GitAdd#'
  local hl_d = del == '0' and '%#neutral#' or '%#GitDel#'

  return hl_a..' +'..add..hl_d..' -'..del
end


local modified = function()
  local modified = ''
  if v.api.nvim_buf_get_option(0, 'modified') then  modified = ' ' end
  return modified
end


local bufname = function()
  local bufname = v.fn.bufname()
  if bufname == '' then bufname = '[null]'
  else                  bufname = string.gsub(bufname, '.*/', '') end

  local hl      = false
  local hl_ro   = '%#SlRo#'
  local hl_rox  = '%#SlRox#'
  if v.api.nvim_buf_get_option(0, 'readonly') then hl = true end

  if hl then
    return strf('%s%s%s%s', hl_rox, hl_ro, bufname, hl_rox)
  else
    return bufname..' '
  end
end


local get_bufnr = function() return '%n' end


local bytecount = function()
  local count = v.fn.line2byte('$') + v.fn.len(v.fn.getline('$'))
  if count == -1 then count = 0 end
  return count..'B'
end


local searchcount = function()
  local s   = v.fn.searchcount({maxcount=0})
  local cur = s.current; local tot = s.total; local cmp = s.incomplete

  if s.exact_match == 0 then cur = 0 end
  if cmp == 1           then return cur..'/?' end

  return cur..'/'..tot
end


local position = function() return '%l:%v' end


local set_statusline = function()
  local main, aux = get_mode_colour()
  local mode  = strf('%s%s%s%s%s', aux, main, get_mode(), aux, hl_no)
  local bufnr = strf('%s(%s)', hl_no, get_bufnr())

  return table.concat({
    hl_no, ' ', mode, git(), diff(), hl_no,
    '%=',
    '    ', modified(), hl_it, bufname(), bufnr, '    ', '%<',
    '%=',
    bytecount(), '  ', searchcount(), '  ', position(), ' '
  })
end


_G.statusline = set_statusline
F.o('laststatus', 3)
F.o('statusline', '%!v:lua.statusline()')
