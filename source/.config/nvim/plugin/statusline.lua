local L = require('utils.lib')

local git_info = {
  diff = nil,
  dir = {
    git = '',
    repo = ''
  },
  head = '',
  is_tracked = false,
  vcs = false
}

local lsp_severities = { 'Error', 'Warn', 'Info', 'Hint' }

---- auxiliary ----
-- WARN: may match an incorrect path with nested links
local readlink = function()
  local buf = vim.fn.expand('%:p:h')..'/'..vim.fn.expand('%:t')

  local src = vim.loop.fs_readlink(buf)
  if src then return src end

  -- link in directory structure
  local dir = ''
  for subdir in buf:sub(2):gmatch('(.-)/') do
    dir = dir..'/'..subdir
    src = vim.loop.fs_readlink(dir)
    if src then return src..buf:gsub(dir, '') end
  end

  return buf
end

local readlink_dir = function()
  return vim.fs.dirname(readlink())
end

local round = function(number, quotient)
  return vim.fn.round((number * 10)/ quotient) / 10
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
    return nil
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

  return { add = add, cha = cha, del = del }
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

  return head
end

---- components ----
local mode = function()
  local m = vim.api.nvim_get_mode().mode
  if m == '' then m = 'v' end
  m = m:sub(0, 1):upper()

  return table.concat({
    '%#mode'..m..'#', m, '%#Statusline#'
  })
end

local buffer = function()
  local name = vim.fn.bufname()
  name = name == ''
    and '[null]'
    or (name:match('([^/]-/?)$') or '_ERR')

  local maxlen = 24
  if name:len() > maxlen then
    local fillchars = '...'

    local i = name:find('%.')
    local ext = i and name:sub(i) or ''
    local offset = ext:len() > 0 and 2 + ext:len() or 4
    name = name:sub(0, maxlen - (offset + fillchars:len()))
      ..fillchars
      ..name:sub(-offset)
  end

  return table.concat({
    '%#Statusline#',
    vim.bo.modified and '+ ' or '- ',
    name,
    ' ',
    vim.bo.readonly and '%#StatuslineReadonly#' or '',
    '(%n)',
    '%#Statusline#'
  })
end

local git = function()
  if not git_info.vcs then return '' end

  local diff = ''
  if not git_info.is_tracked or git_info.diff == nil then
    diff = '%#GitZero#untracked'
  else
    local hl_a = '%#Git'..(git_info.diff.add == 0 and 'Zero' or 'Add')..'#'
    local hl_c = '%#Git'..(git_info.diff.cha == 0 and 'Zero' or 'Cha')..'#'
    local hl_d = '%#Git'..(git_info.diff.del == 0 and 'Zero' or 'Del')..'#'
    diff = table.concat({
      hl_a..'+'..git_info.diff.add,
      hl_c..'~'..git_info.diff.cha,
      hl_d..'-'..git_info.diff.del
    }, ' ')
  end

  return table.concat({
    '%#Git# '..git_info.head,
    ' ',
    diff,
    '%#Statusline#'
  })
end

local lsp = function()
  local lsp_signs = vim.fn.filter(vim.fn.sign_getdefined(), function(_, s)
    return vim.startswith(s.name, 'DiagnosticSign')
  end)

  local clients = vim.lsp.get_active_clients({ bufnr = 0 })
  if #clients == 0 then return '' end

  for i=1, #clients do
    clients[i] = clients[i].name
  end

  local diagnostics = vim.diagnostic.get(0)
  local counts = { 0, 0, 0, 0 }
  for i=1, #diagnostics do
    counts[diagnostics[i].severity] = counts[diagnostics[i].severity] + 1
  end

  local parts = {}
  if #diagnostics == 0 then goto skip_diagnostic end

  for i=1, #counts do
    if counts[i] == 0 then goto continue end

    local sign = vim.fn.filter(lsp_signs, function(_, s)
      return s.name == 'DiagnosticSign'..lsp_severities[i]
    end)[1]

    parts[#parts+1] = '%#'..sign.texthl..'#'..sign.text..counts[i]
    ::continue::
  end

  ::skip_diagnostic::
  return table.concat({
    '%#StatuslineLspinfo#',
    table.concat(clients, ', '),
    #diagnostics > 0 and ' '..table.concat(parts, ' ') or '',
    '%#Statusline#'
  })
end

local bytecount = function()
  local unit = 'B'
  local count = vim.fn.line2byte(vim.fn.line('$')) + vim.fn.getline('$'):len()
  if count == -1 then count = 0 end

  if count >= 1048576 then
    unit = 'MiB'
    count  = round(count, 1048576)
  elseif count >= 10240 then
    unit = 'KiB'
    count = round(count, 1024)
  end

  return table.concat({
    '%#StatuslineBytecount#﬘%#Statusline#',
    ' ',
    count..unit
  })
end

local searchcount = function()
  local search = vim.fn.searchcount({ maxcount = 98 })
  local cur = search.current;

  if search.exact_match == 0 then cur = 0 end
  if search.incomplete == 1 then search.total = '?' end

  return table.concat({
    '%#StatuslineSearch#%#Statusline#',
    ' ',
    cur..'/'..search.total
  })
end

local location = function()
  return table.concat({
    '%#StatuslineLocation#%#Statusline#',
    ' ',
    '%l:%v'
  })
end

---- definition ----
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

-- avoid unnecessary git calls
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

local statusline = function()
  return ' '..table.concat({
    mode(),
    buffer(),
    git(),
    '%=',
    lsp(),
    bytecount(),
    searchcount(),
    location()
  }, ' ')..'%< '
end

_G.statusline = statusline
L.vim.o('laststatus', 3)
L.vim.o('statusline', '%!v:lua.statusline()')
