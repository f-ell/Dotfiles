local v   = vim
local va  = v.api
local vf  = v.fn
local uv  = v.loop

local attached = false
local bufnr   = va.nvim_get_current_buf()
local std     = vf.stdpath('config')
local conf    = vf.expand('%:p:h')
local data    = conf
local file    = vf.bufname()
local theme   = 'theme.css'
local suffix  = uv.os_getpid()..'-'..bufnr

if not vf.expand('%:t'):match('%.slides%.md$') then return end

local spawn = function(name, args)
  uv.spawn(name, { args = args, stdio = { nil, nil, nil } }, function(code, _)
    if code ~= 0 then return print('autorender: couldn\'t spawn process.') end
  end)
end

va.nvim_buf_create_user_command(0, 'AutoRenderStart', function(tbl)
  if attached then
    return v.notify('autorender: autorender already running.', 2)
  end
  attached = true

  if tbl.args ~= '' then
    conf, theme = v.fs.dirname(tbl.args), v.fs.basename(tbl.args)
  end

  -- TODO: connect pipe to stderr and append to messages
  spawn(std..'/ftplugin/markdown/marp_spawn.sh',
    { std, conf, data, file, theme, suffix })

  va.nvim_create_autocmd({ 'BufFilePre', 'BufUnload', 'VimLeavePre' }, {
    buffer = bufnr,
    once = true,
    callback = function()
      spawn(std..'/ftplugin/markdown/marp_kill.sh', { suffix })
    end
  })
end, { nargs = '?', complete = 'file', desc = 'Register BufWritePost autocommand to convert to PDF with docker and marp.' })


va.nvim_buf_create_user_command(0, 'AutoRenderStop', function()
  if not suffix then return v.notify('autorender: no process running.', 2) end
  attached = false
  spawn(std..'/ftplugin/markdown/marp_kill.sh', { suffix })
end, { desc = 'Delete autocommand registered by AutoRenderStart.' })
