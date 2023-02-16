local L     = require('utils.lib')
local v     = vim
local va    = v.api
local strf  = string.format
local hl_no = '%#SlNormal#'
local git_info = {}


-- auxiliary
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
  local fh = L.util.open({
    'git', '-C', resolve_dir(),
    'rev-parse', '--is-inside-work-tree' }, true, false)
  return L.util.read(fh) == 'true' and true or false
end




-- misc components
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


local modified = function()
  local modified = ''
  if v.api.nvim_buf_get_option(0, 'modified') then  modified = ' ' end
  return modified
end


local bufname = function()
  local hl_ro   = '%#SlRo#'
  local hl_rox  = '%#SlRox#'

  local bufname = v.fn.bufname()
  if bufname == '' then bufname = '[null]'
  else                  bufname = string.gsub(bufname, '.*/', '') end

  local str
  if v.api.nvim_buf_get_option(0, 'readonly') then
    str = strf('%s%s%s%s', hl_rox, hl_ro, bufname, hl_rox)
  else
    str = bufname
  end
  return str..' '
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




-- git components
local get_head = function()
  local get_obj_id = function(str)
    return str:match('^(%x+) ')
  end
  local get_obj_ref = function(str)
    local prefix = ''
    if str:match('refs/tags/') then prefix = 't:' end
    return prefix..str:gsub('^.*/', ''):gsub('%^{}', '')
  end

  local dir = resolve_dir()

  local fh = L.util.open({
    'git', '-C', dir,
    'show-ref', '--head', '--heads', '--tags', '--abbrev', '-d', }, false, '')

  local head_ln = fh:read('*l')

  local b, m = 0, 0
  for ln in fh:lines() do
    if get_obj_id(head_ln) == get_obj_id(ln) then
      m = m + 1
      if ln:match('refs/heads/') then b = b + 1 end
      head_ln = ln
    end
  end
  fh:close()

  if m == 0 then
    head_ln = get_obj_id(head_ln)
  elseif b > 1 or (m > b and b > 0) then
    fh = L.util.open({ 'git', '-C', dir, 'branch', '--show-current' }, true)
    head_ln = L.util.read(fh)
  else
    head_ln = get_obj_ref(head_ln)
  end

  return strf(' %s %s%s', '%#Git#', head_ln, hl_no)
end


local get_diff = function()
  local fh = L.util.open({
    'git', '-C', resolve_dir(),
    'diff', '--numstat', resolve_file() }, true, '')
  local numstat = L.util.read(fh)

  if numstat == '' then
    local ret = '+0 -0'

    fh = L.util.open({
      'git', '-C', resolve_dir(),
      'ls-files', '--error-unmatch', resolve_file() }, true, '')
    if L.util.read(fh) == '' then ret = 'untracked' end

    return ' %#neutral#'..ret
  end

  local add = string.match(numstat, '%d+')
  local del = string.match(numstat, '%d+', string.len(add) + 1)

  local hl_a = add == '0' and '%#neutral#' or '%#GitAdd#'
  local hl_d = del == '0' and '%#neutral#' or '%#GitDel#'

  return hl_a..' +'..add..hl_d..' -'..del
end


-- populate git information and register autocommands
git_info.vcs  = is_vcs()
if git_info.vcs then
  git_info.head = get_head()
  git_info.diff = get_diff()
end

va.nvim_create_autocmd({ 'BufEnter', 'FileChangedShellPost', 'FocusGained' }, {
  callback = function()
    git_info.vcs = is_vcs()
    if not git_info.vcs then return end

    git_info.head = get_head()
    git_info.diff = get_diff()
  end
})

va.nvim_create_autocmd('BufWritePre', {
  nested = true,
  callback = function()
    if not git_info.vcs then return end
    git_info.head = get_head()
    if not v.bo.modified then return end

    va.nvim_create_autocmd('BufWritePost', {
      once = true,
      callback = function() git_info.diff = get_diff() end
    })
  end
})




-- statusline definition
local statusline = function()
  local main, aux = get_mode_colour()
  local mode  = strf('%s%s%s%s%s', aux, main, get_mode(), aux, hl_no)
  local bufnr = strf('%s(%s)', hl_no, get_bufnr())
  local git   = git_info.vcs and git_info.head .. git_info.diff or ''

  return table.concat({
    hl_no, ' ', mode, git, hl_no,
    '%=',
    '    ', modified(), bufname(), bufnr, '    ', '%<',
    '%=',
    bytecount(), '  ', searchcount(), '  ', '%l:%v', ' '
  })
end


_G.statusline = statusline
L.vim.o('laststatus', 3)
L.vim.o('statusline', '%!v:lua.statusline()')
