local L     = require('utils.lib')
local strf  = string.format
local hl_no = '%#SlNormal#'

local git = {
  diff = '',
  dir = {
    git = '',
    repo = ''
  },
  head = '',
  is_tracked = false,
  vcs = false
}


-- auxiliary
-- WARN: this may match an incorrect location with nested links
local readlink = function()
  local buf = vim.fn.expand('%:p:h')..'/'..vim.fn.expand('%:t')

  -- file itself is a link
  local src = vim.loop.fs_readlink(buf)
  if src then return src end

  -- link in directory structure
  local dir = ''
  for subdir in buf:sub(2):gmatch('(.-)/') do
    dir = dir..'/'..subdir
    src = vim.loop.fs_readlink(dir)
    if src then return src..buf:gsub(dir, '') end
  end

  -- no link in directory structure
  return buf
end

local readlink_dir = function()
  return vim.fs.dirname(readlink())
end




-- misc components
local mode = function()
  local m = vim.api.nvim_get_mode().mode

  if      m == 'V'   then m = 'VL'
  elseif  m == ''  then m = 'VB' end

  return m:upper()
end


local mode_colour = function()
  local m = vim.api.nvim_get_mode().mode

  if      m == 'V' or m == '' then m = 'v'
  elseif  m == 'nt'             then m = 'n' end

  local main  = strf('%s%s#', '%#mode', m:upper())
  local aux   = strf('%s%sx#', '%#mode', m:upper())
  return main, aux
end


local modified = function()
  return vim.api.nvim_buf_get_option(0, 'modified') and ' ' or ''
end


local bufname = function()
  local hl_ro   = '%#SlRo#'
  local hl_rox  = '%#SlRoX#'

  local buf = vim.fn.bufname()
  if buf == '' then buf = '[null]'
  else              buf = string.gsub(buf, '.*/', '') end

  local str
  if vim.api.nvim_buf_get_option(0, 'readonly') then
    str = strf('%s%s%s%s', hl_rox, hl_ro, buf, hl_rox)
  else
    str = buf
  end
  return str..' '
end


local bytecount = function()
  local count = vim.fn.line2byte('$') + vim.fn.len(vim.fn.getline('$'))
  if count == -1 then count = 0 end
  return count..'B'
end


local searchcount = function()
  local s   = vim.fn.searchcount({ maxcount = 0 })
  local cur = s.current; local tot = s.total; local cmp = s.incomplete

  if s.exact_match == 0 then cur = 0 end
  if cmp == 1           then return cur..'/?' end

  return cur..'/'..tot
end




-- git components
local is_tracked = function()
  local dir = git.dir.git:gsub('%.git$', '')
  local fh = L.io.popen({
    'git', '-C', dir,
    'ls-files', '--error-unmatch', readlink():gsub('^'..dir, '') }, true, '')
  return L.io.read(fh) ~= ''
end


local is_vcs = function()
  local fh = L.io.popen({
    'git', '-C', readlink_dir(),
    'rev-parse', '--is-inside-work-tree' }, true, false)
  return L.io.read(fh) == 'true'
end


local git_dir = function()
  local git_dir, root_dir = '', ''
  local cwd = readlink_dir()

  while cwd do
    local path = cwd..'/.git'
    local stat = vim.loop.fs_stat(path)

    if stat then
      git_dir = path
      root_dir = path

      if stat.type == 'file' then
        local fh = io.open(path, 'r')
        if fh ~= nil then root_dir = L.io.read(fh):match('^gitdir: (.*)$') end
      end

      break
    end

    cwd = cwd:match('^(.+)/.-$')
  end

  return git_dir, root_dir
end


local git_diff = function()
  local file = readlink()
  if not git.is_tracked or file:match('/$') then
    return ' %#neutral#untracked'
  end

  -- TODO: diff tmpfile to update without writing (e.g. InsertLeave)
  local fh = L.io.popen({
    'git', '-C', readlink_dir(),
    'diff', '-U0', '--no-color', file }, true, '')

  local add, cha, del = 0, 0, 0
  for ln in L.io.read(fh):gmatch('(.-)\r?\n') do
    if not vim.startswith(ln, '@@') then goto continue end
    if vim.startswith(ln, '@@@')    then return ' %#GitDel#unmerged' end

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


local git_head = function()
  local fh = io.open(git.dir.repo..'/HEAD', 'r')
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




-- register autocommands
vim.api.nvim_create_autocmd({ 'BufEnter', 'BufFilePost', 'FileChangedShellPost',
  'FocusGained', 'WinClosed' }, { callback = function()
    git.vcs = is_vcs()
    if not git.vcs then return end

    git.dir.git, git.dir.repo = git_dir()
    git.is_tracked = is_tracked()
    git.head = git_head()
    git.diff = git_diff()
  end
})

vim.api.nvim_create_autocmd('BufWritePre', {
  nested = true,
  callback = function()
    if not git.vcs then return end
    git.head = git_head()
    if not vim.bo.modified then return end

    vim.api.nvim_create_autocmd('BufWritePost', {
      once = true,
      callback = function() git.diff = git_diff() end
    })
  end
})




-- statusline definition
local statusline = function()
  local main, aux = mode_colour()
  local mode  = strf('%s%s%s%s%s', aux, main, mode(), aux, hl_no)
  local bufnr = strf('%s(%s)', hl_no, '%n')
  local git   = git.vcs and git.head..git.diff or ''

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
