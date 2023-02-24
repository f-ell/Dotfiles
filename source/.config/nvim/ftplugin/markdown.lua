local L   = require('utils.lib')
local v   = vim
local va  = v.api
local vf  = v.fn

local fh
local send = function(msg) v.notify('autorender: '..msg, 2) end
local early_exit = false

-- preliminary checks
if not vf.expand('%:t'):match('%.slides%.md$') then return end
if not vf.executable('docker') then
  send('docker not executable.')
  early_exit = true
end

fh = L.util.open({ 'pidof', 'dockerd' }, true, '')
if not L.util.read(fh):match('%d+') then
  send('dockerd not running.')
  early_exit = true
end

fh = L.util.open({ 'groups' }, true, '')
if not L.util.read(fh):match('docker') then
  send('user is not in docker group.')
  early_exit = true
end

if early_exit then return end




-- TODO: start container once here and only docker exec?
-- TODO: adjust timeout?
-- download docker image if necessary
local image = 'marpteam/marp-cli'

local stat = vf.wait(10000, function()
  fh = L.util.open({
    'docker', 'inspect', '--type=image', image}, true, '')
  if L.util.read(fh) == '' then
    fh = L.util.open({ 'docker', 'pull', '-q', image }, true, '')
    if L.util.read(fh) == '' then return false end
  end
  return true
end)

if stat <= 0 then return send('failed to download image.') end




-- register user commands
local uid, gid = v.loop.getuid(), v.loop.getgid()
local cid   = nil
local lock  = false
local running = false

va.nvim_buf_create_user_command(0, 'AutoRenderStart', function(tbl)
  if running then return send('autorender already running.') end
  running = true

  -- TODO: decide on theme.css location in data_dir or similar
  local css = tbl.args and tbl.args or 'THEME_FILE'
  local cwd   = vf.expand('%:p:h')
  local file  = vf.expand('%:p:t')

  cid = va.nvim_create_autocmd('BufWritePost', {
    callback = function()
      -- TODO: msg if conversion running?
      if lock or not v.o.modified then return end
      lock = true

      local jid = vf.jobstart({ 'docker', 'run', '--rm',
        '-e', 'MARP_USER='..uid..':'..gid, '-v', cwd..':'..'/home/marp/app',
        'marpteam/marp-cli', '--theme', css, '--pdf', file }, {
      on_exit = function() lock = false end, on_stderr = function() print('job fatal'); lock = false end })

      -- TODO: remove
      print(jid)

      if jid <= 0 then return v.notify('autorender: conversion failed, jobstart() fatal.') end

      vf.jobwait(jid)
      lock = false
    end
  })
end, { nargs = '?', complete = 'file', desc = 'Register BufWritePost autocommand to convert to PDF with docker and marp.' })

va.nvim_buf_create_user_command(0, 'AutoRenderStop', function()
  running = false
  if not cid then return send('no autocommand registered.') end

  va.nvim_del_autocmd(cid)
end, { desc = 'Delete autocommand registered by AutoRenderStart.' })
