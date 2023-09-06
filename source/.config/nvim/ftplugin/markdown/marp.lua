local cmd_id  = nil
local bufnr   = vim.api.nvim_get_current_buf()
local std     = vim.fn.stdpath('config')..'/ftplugin/markdown'
local suffix  = vim.loop.os_getpid()..'-'..bufnr

if not vim.fn.expand('%:t'):match('%.slides%.md$') then return end

-- TODO: connect pipe to stderr and append to messages
local spawn = function(name, args)
  vim.loop.spawn(name, { args = args, stdio = { nil, nil, nil } }, function(code, _)
    if code ~= 0 then return print('marp: couldn\'t spawn process.') end
  end)
end

local get_data_and_theme = function(tbl)
  local data, theme = nil, 'theme.css'
  if tbl.args ~= '' then
    data  = vim.fn.fnamemodify(vim.fs.dirname(tbl.args), ':p')
    theme = vim.fs.basename(tbl.args)
  else
    local cwd = vim.loop.cwd()
    if vim.loop.fs_stat(cwd..'/'..theme) then data = cwd
    else                                    data = std end
  end
  return data, theme
end

local marp_once = function(tbl)
  if cmd_id then return vim.notify('marp: marp already running.', 2) end
  local data, theme = get_data_and_theme(tbl)
  spawn(std..'/marp_spawn.sh', { 0, suffix, data, theme, vim.fn.bufname() })
end

local marp_stop = function()
  if not cmd_id then return vim.notify('marp: no process running.', 2) end
  spawn(std..'/marp_kill.sh', { suffix })

  vim.api.nvim_del_autocmd(cmd_id)
  vim.api.nvim_buf_del_user_command(0, 'MarpStop')
  cmd_id = nil
end

local marp_start = function(tbl)
  if cmd_id then return vim.notify('marp: marp already running.', 2) end
  local data, theme = get_data_and_theme(tbl)
  spawn(std..'/marp_spawn.sh', { 1, suffix, data, theme, vim.fn.bufname() })

  cmd_id = vim.api.nvim_create_autocmd({ 'BufFilePre', 'BufUnload', 'VimLeavePre' }, {
    buffer = bufnr,
    once = true,
    callback = function() spawn(std..'/marp_kill.sh', { suffix }) end
  })

  vim.api.nvim_buf_create_user_command(0, 'MarpStop', marp_stop,
    { desc = 'Delete MarpStart autocommand.' })
end

vim.api.nvim_buf_create_user_command(0, 'MarpOnce', marp_once,
  { nargs = '?', complete = 'file', desc = 'Markdown to PDF once.' })

vim.api.nvim_buf_create_user_command(0, 'MarpStart', marp_start,
  { nargs = '?', complete = 'file', desc = 'Markdown to PDF continuous.' })
