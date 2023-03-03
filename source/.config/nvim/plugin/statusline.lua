local L     = require('utils.lib')
local v     = vim
local va    = v.api
local vf    = v.fn
local strf  = string.format
local hl_no = '%#SlNormal#'
local git_info = {}


-- auxiliary
-- INFO: this may match an incorrect location with nested links
local readlink = function()
  local buf = vf.expand('%:p:h')..'/'..vf.expand('%:t')
  local src

  -- file itself is a link
  src = v.loop.fs_readlink(buf)
  if src then return src end

  -- link in directory structure
  local dir = ''
  for subdir in buf:sub(2):gmatch('(.-)/') do
    dir = dir..'/'..subdir
    src = v.loop.fs_readlink(dir)
    if src then break end
  end
  if src then return src..buf:gsub(dir, '') end

  -- no link in directory structure
  return buf
end

local readlink_dir = function()
  return v.fs.dirname(readlink())
end


local is_tracked = function()
  local fh = L.io.popen({
    'git', '-C', v.fs.dirname(git_info.dir),
    'ls-files', '--error-unmatch', readlink() }, true, '')
  return L.io.read(fh) ~= '' and true or false
end

local is_vcs = function()
  local fh = L.io.popen({
    'git', '-C', readlink_dir(),
    'rev-parse', '--is-inside-work-tree' }, true, false)
  return L.io.read(fh) == 'true' and true or false
end

local git_dir = function()
  local dir = nil
  local cwd = readlink_dir()

  while cwd do
    local current = cwd..'/.git'
    local stat    = v.loop.fs_stat(current)
    if not stat then goto continue end

    -- INFO: potentially inefficient; loop doesn't break on .git *files*
    if stat.type == 'directory' then dir = current; break end

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

  local content = L.io.read(fh)
  local head = content:match('^ref: refs/heads/(.+)$')

  if not head then
    fh = L.io.popen({
      'git', '-C', readlink_dir(),
      'describe', '--tags', '--exact-match', '@' }, true, '')
    local tag = L.io.read(fh)
    head = tag ~= '' and 't:'..tag or content:sub(1, 8)
  end

  return strf(' %s %s%s', '%#Git#', head, hl_no)
end


local git_diff = function()
  local file = readlink()
  if not git_info.tracked or file:match('/$') then
    return ' %#neutral#untracked'
  end

  -- TODO: diff tmpfile to update without writing (e.g. InsertLeave)
  local fh = L.io.popen({
    'git', '-C', readlink_dir(),
    'diff', '-U0', '--no-color', file }, true, '')

  local add, cha, del = 0, 0, 0
  for ln in L.io.read(fh):gmatch('(.-)\r?\n') do
    if not v.startswith(ln, '@@') then goto continue end

    local caps = { ln:match('^@@ %-%d+,?(%d*) %+%d+,?(%d*) @@') }
    local old, new = caps[1], caps[2]

    if old == '' then old = '1' end
    if new == '' then new = '1' end
    if      old == '0' then add = add + new
    elseif  new == '0' then del = del + old
    else
      cha = cha + math.min(old, new)
      if      tonumber(new) > tonumber(old) then add = add + (new - old)
      elseif  tonumber(new) < tonumber(old) then del = del + (old - new) end
    end

    ::continue::
  end

  local hl_a = add == 0 and '%#neutral#' or '%#GitAdd#'
  local hl_c = cha == 0 and '%#neutral#' or '%#GitCha#'
  local hl_d = del == 0 and '%#neutral#' or '%#GitDel#'
  return hl_a..' +'..add..hl_c..' ~'..cha..hl_d..' -'..del
end


-- register autocommands
va.nvim_create_autocmd({ 'BufEnter', 'BufFilePost', 'FileChangedShellPost',
  'FocusGained', 'WinClosed' }, { callback = function()
    git_info.vcs = is_vcs()
    if not git_info.vcs then return end

    git_info.dir  = git_dir()
    git_info.tracked = is_tracked()
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
  local git   = git_info.vcs and git_info.head..git_info.diff or ''

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
