local v   = vim
local va  = v.api
local vf  = v.fn

local cmd_id  = nil
local bufnr   = va.nvim_get_current_buf()
local std     = vf.stdpath('config')..'/ftplugin/markdown/'
local suffix  = v.loop.os_getpid()..'-'..bufnr

if not vf.expand('%:t'):match('%.slides%.md$') then return end

-- TODO: connect pipe to stderr and append to messages
local spawn = function(name, args)
  v.loop.spawn(name, { args = args, stdio = { nil, nil, nil } }, function(code, _)
    if code ~= 0 then return print('marp: couldn\'t spawn process.') end
  end)
end

local get_data_and_theme = function(tbl)
  local data, theme = nil, 'theme.css'
  if tbl.args ~= '' then
    data, theme = v.fs.dirname(tbl.args), v.fs.basename(tbl.args)
  else
    local cwd = v.loop.cwd()
    if v.loop.fs_stat(cwd..'/theme.css') then data = cwd
    else                                      data = std end
  end
  return data, theme
end

va.nvim_buf_create_user_command(0, 'MarpOnce', function(tbl)
  if cmd_id then return v.notify('marp: marp already running.', 2) end
  local data, theme = get_data_and_theme(tbl)
  spawn(std..'/marp_spawn.sh', { 0, suffix, data, theme, vf.bufname() })
end, { nargs = '?', complete = 'file', desc = 'Markdown to PDF once.' })

va.nvim_buf_create_user_command(0, 'MarpStart', function(tbl)
  if cmd_id then return v.notify('marp: marp already running.', 2) end
  local data, theme = get_data_and_theme(tbl)
  spawn(std..'/marp_spawn.sh', { 1, suffix, data, theme, vf.bufname() })

  cmd_id = va.nvim_create_autocmd({ 'BufFilePre', 'BufUnload', 'VimLeavePre' }, {
    buffer = bufnr,
    once = true,
    callback = function() spawn(std..'/marp_kill.sh', { suffix }) end
  })

  va.nvim_buf_create_user_command(0, 'MarpStop', function()
    if not cmd_id then return v.notify('marp: no process running.', 2) end
    spawn(std..'/marp_kill.sh', { suffix })

    va.nvim_del_autocmd(cmd_id)
    cmd_id = nil
  end, { desc = 'Delete MarpStart autocommand.' })
end, { nargs = '?', complete = 'file', desc = 'Markdown to PDF continuous.' })
