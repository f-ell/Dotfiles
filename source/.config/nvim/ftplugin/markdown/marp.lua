local v   = vim
local va  = v.api
local vf  = v.fn

local attached = false
local bufnr   = va.nvim_get_current_buf()
local std     = vf.stdpath('config')..'/ftplugin/markdown'
local data    = nil
local theme   = 'theme.css'
local suffix  = v.loop.os_getpid()..'-'..bufnr

if not vf.expand('%:t'):match('%.slides%.md$') then return end

local spawn = function(name, args)
  v.loop.spawn(name, { args = args, stdio = { nil, nil, nil } }, function(code, _)
    if code ~= 0 then
      attached = false
      return print('marp: couldn\'t spawn process.')
    end
  end)
end

va.nvim_buf_create_user_command(0, 'MarpStart', function(tbl)
  if attached then return v.notify('marp: marp already running.', 2) end
  attached = true

  if tbl.args == '' then
    if v.loop.fs_stat('./theme.css') then data = vf.expand('%:p:h')
    else                                  data = std end
  else
    data, theme = v.fs.dirname(tbl.args), v.fs.basename(tbl.args)
  end

  -- TODO: connect pipe to stderr and append to messages
  spawn(std..'/marp_spawn.sh', { suffix, data, theme, vf.bufname() })

  va.nvim_create_autocmd({ 'BufFilePre', 'BufUnload', 'VimLeavePre' }, {
    buffer = bufnr,
    once = true,
    callback = function()
      spawn(std..'/marp_kill.sh', { suffix })
    end
  })
end, { nargs = '?', complete = 'file', desc = 'Register BufWritePost autocommand to convert to PDF with docker and marp.' })


va.nvim_buf_create_user_command(0, 'MarpStop', function()
  if not attached then return v.notify('marp: no process running.', 2) end
  spawn(std..'/marp_kill.sh', { suffix })
  attached = false
end, { desc = 'Delete autocommand registered by MarpStart.' })
