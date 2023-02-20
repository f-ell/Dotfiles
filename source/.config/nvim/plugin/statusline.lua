local L     = require('utils.lib')
local v     = vim
local va    = v.api
local vf    = v.fn
local strf  = string.format
local hl_no = '%#SlNormal#'
local git_info = {}


-- auxiliary
local readlink = function()
  local buf = vf.expand('%:p:h') .. '/' .. vf.expand('%:t')
  local src = v.loop.fs_readlink(buf)

  return src and src or buf
end

local readlink_dir = function()
  return v.fs.dirname(readlink())
end


local is_vcs = function()
  local fh = L.util.open({
    'git', '-C', readlink_dir(),
    'rev-parse', '--is-inside-work-tree' }, true, false)
  return L.util.read(fh) == 'true' and true or false
end

local git_dir = function()
  local dir = nil
  local cwd = readlink_dir()

  while cwd do
    local current = cwd .. '/.git'
    local stat    = v.loop.fs_stat(current)
    if not stat then goto continue end

    -- INFO: potentially inefficient
    -- loop doesn't break when encoutering .git *files* from submodules
    if stat.type == 'directory' then
      dir = current
      break
    end

    ::continue::
    cwd = cwd:match('^(.+)/.-$')
  end

  return dir
end




-- misc components
local mode = function()
  local m = va.nvim_get_mode().mode

  if      m == 'V'   then m = 'VL'
  elseif  m == ''  then m = 'VB' end

  return m:upper()
end


local mode_colour = function()
  local m = va.nvim_get_mode().mode

  if      m == 'V' or m == '' then m = 'v'
  elseif  m == 'nt'             then m = 'n' end

  local main  = strf('%s%s#', '%#mode', m:upper())
  local aux   = strf('%s%sx#', '%#mode', m:upper())
  return main, aux
end


local modified = function()
  return va.nvim_buf_get_option(0, 'modified') and ' ' or ''
end


local bufname = function()
  local hl_ro   = '%#SlRo#'
  local hl_rox  = '%#SlRox#'

  local buf = vf.bufname()
  if buf == '' then buf = '[null]'
  else              buf = string.gsub(buf, '.*/', '') end

  local str
  if va.nvim_buf_get_option(0, 'readonly') then
    str = strf('%s%s%s%s', hl_rox, hl_ro, buf, hl_rox)
  else
    str = buf
  end
  return str..' '
end


local bytecount = function()
  local count = vf.line2byte('$') + vf.len(vf.getline('$'))
  if count == -1 then count = 0 end
  return count..'B'
end


local searchcount = function()
  local s   = vf.searchcount({ maxcount = 0 })
  local cur = s.current; local tot = s.total; local cmp = s.incomplete

  if s.exact_match == 0 then cur = 0 end
  if cmp == 1           then return cur..'/?' end

  return cur..'/'..tot
end




-- git components
local git_head = function()
  local fh = io.open(git_info.dir..'/HEAD', 'r')
  if fh == nil then return '' end

  local content = L.util.read(fh)
  local head = content:match('^ref: refs/heads/(.+)$')

  if not head then
    fh = L.util.open({
      'git', '-C', readlink_dir(),
      'describe', '--tags', '--exact-match', '@' }, true, '')
    local tag = L.util.read(fh)
    head = tag ~= '' and 't:'..tag or content:sub(1, 8)
  end

  return strf(' %s %s%s', '%#Git#', head, hl_no)
end


local git_diff = function()
  local ustr = ' %#neutral#untracked'
  local file = readlink()
  if file:match('/$') then return ustr end

  local fh = L.util.open({
    'git', '-C', readlink_dir(),
    'diff', '--numstat', file }, true, '')
  local numstat = L.util.read(fh)

  if numstat == '' then
    fh = L.util.open({
      'git', '-C', readlink_dir(),
      'ls-files', '--error-unmatch', file }, true, '')
    if L.util.read(fh) == '' then return ustr end

    return ' %#neutral#+0 -0'
  end

  local add = string.match(numstat, '%d+')
  local del = string.match(numstat, '%d+', string.len(add) + 1)

  local hl_a = add == '0' and '%#neutral#' or '%#GitAdd#'
  local hl_d = del == '0' and '%#neutral#' or '%#GitDel#'

  return hl_a..' +'..add..hl_d..' -'..del
end


-- register autocommands
va.nvim_create_autocmd({ 'BufEnter', 'BufFilePost', 'FileChangedShellPost',
  'FocusGained' }, { callback = function()
    git_info.vcs = is_vcs()
    if not git_info.vcs then return end

    git_info.dir  = git_dir()
    git_info.head = git_head()
    git_info.diff = git_diff()
  end
})

va.nvim_create_autocmd('BufWritePre', {
  nested = true,
  callback = function()
    if not git_info.vcs then return end
    git_info.head = git_head()
    if not v.bo.modified then return end

    va.nvim_create_autocmd('BufWritePost', {
      once = true,
      callback = function() git_info.diff = git_diff() end
    })
  end
})




-- statusline definition
local statusline = function()
  local main, aux = mode_colour()
  local mode  = strf('%s%s%s%s%s', aux, main, mode(), aux, hl_no)
  local bufnr = strf('%s(%s)', hl_no, '%n')
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
