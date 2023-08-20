local L = require('utils.lib')

local git_info = {
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

local is_tracked = function()
  local dir = git_info.dir.git:gsub('%.git$', '')
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
  if not git_info.is_tracked or file:match('/$') then
    return '%#GitZero# untracked'
  end

  -- TODO: diff tmpfile to update without writing (e.g. InsertLeave)
  local fh = L.io.popen({
    'git', '-C', readlink_dir(),
    'diff', '-U0', '--no-color', file }, true, '')

  local add, cha, del = 0, 0, 0
  for ln in L.io.read(fh):gmatch('(.-)\r?\n') do
    if not vim.startswith(ln, '@@') then goto continue end
    if vim.startswith(ln, '@@@')    then return '%#GitDel# unmerged' end

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

  local hl_a = add == 0 and '%#GitZero#' or '%#GitAdd#'
  local hl_c = cha == 0 and '%#GitZero#' or '%#GitCha#'
  local hl_d = del == 0 and '%#GitZero#' or '%#GitDel#'
  return hl_a..' +'..add..hl_c..' ~'..cha..hl_d..' -'..del
end

local git_head = function()
  local fh = io.open(git_info.dir.repo..'/HEAD', 'r')
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

  return string.format(' %s%s%s', '%#Git#', head, '%#SlNormal#')
end


-- components
local mode = function()
  local m = vim.api.nvim_get_mode().mode
  if m == '' then m = 'v' end
  m = m:sub(0, 1):upper()

  local colours = {
    '%#mode'..m..'#',
    '%#mode'..m..'x#'
  }

  return string.format('%s %s%s', colours[1], m, colours[2])
end

local buffer = function()
  local name = vim.fn.bufname()
  name = name == '' and '[null]' or string.gsub(name, '.*/', '')

  if name:len() > 24 then
    local ext = vim.fn.expand('%:e')
    local offset = 4 + (ext:len() > 0 and ext:len() + 1 or 0)

    local prefix = name:sub(0, 24 - (offset + 3))
    local suffix = name:sub(-offset)
    name = prefix..'...'..suffix
  end

  local hl = '%#SlBuf'
  if vim.bo.readonly then hl = hl..'Ro' end

  return string.format(
    '%%#SlBg#%s%s (%s) %s %s%s',
    vim.bo.modified and '*' or ' ', name, '%n',
    hl..'#', '',
    hl..'Inv'..(git_info.vcs and '' or 'x')..'#'
  )
end

local git = function()
  return git_info.vcs
    and '%#SlBg#'..git_info.head..git_info.diff..' %#SlGit# %#SlGitInv#'
    or ''
end

local bytecount = function()
  local count = vim.fn.line2byte(vim.fn.line('$'))
    + vim.fn.len(vim.fn.getline('$'))
  if count == -1 then count = 0 end
  return '%#SlByteInv#%#SlByte#﬘ %#SlBg# '..count..'B '
end

local searchcount = function()
  local search = vim.fn.searchcount()
  local cur = search.current;

  if search.exact_match == 0 then cur = 0 end
  if search.incomplete == 1 then return cur..'/?' end

  return '%#SlSearchInv#%#SlSearch# %#SlBg# '..cur..'/'..search.total..' '
end

local position = function()
  return '%#SlLocInv#%#SlLoc# %#SlBg# %l:%v '
end


-- register autocommands
vim.api.nvim_create_autocmd({
  'BufEnter', 'BufFilePost', 'FileChangedShellPost', 'FocusGained', 'WinClosed'
  }, { callback = function()
    git_info.vcs = is_vcs()
    if not git_info.vcs then return end

    git_info.dir.git, git_info.dir.repo = git_dir()
    git_info.is_tracked = is_tracked()
    git_info.head = git_head()
    git_info.diff = git_diff()
  end
})

vim.api.nvim_create_autocmd('BufWritePre', {
  nested = true,
  callback = function()
    if not git_info.vcs then return end
    git_info.head = git_head()
    if not vim.bo.modified then return end

    vim.api.nvim_create_autocmd('BufWritePost', {
      once = true,
      callback = function() git_info.diff = git_diff() end
    })
  end
})


-- statusline definition
local statusline = function()
  return table.concat({
    mode(),
    buffer(), '%#SlNormal#',
    git(),
    '%#SlNormal#%=%<',
    bytecount(),
    searchcount(),
    position()
  })
end


_G.statusline = statusline
L.vim.o('laststatus', 3)
L.vim.o('statusline', '%!v:lua.statusline()')
