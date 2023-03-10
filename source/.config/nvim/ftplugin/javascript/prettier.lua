local L   = require('utils.lib')
local v   = vim
local va  = v.api
local vf  = v.fn

if vf.executable(vf.stdpath('data')..'/mason/bin/prettierd') ~= 1 then return end

local augroup = va.nvim_create_augroup('prettierd', { clear = false })
local dir   = vf.stdpath('run')..'/nvim.user'
local file  = dir..'/nvim_prettier'..v.loop.os_getpid()


local get_cmds = function()
  return va.nvim_get_autocmds({ group = augroup })
end


local running = function()
  local cmds = vf.flatten(get_cmds())

  if next(cmds) == nil or #cmds == 1 and cmds[1].event == 'VimLeavePre' then
    return false
  end

  return true
end


local write_tmpfile = function(lines)
  local fh = assert(io.open(file, 'w+'), 'couldn\'t open '..file)
  assert(fh:write(table.concat(lines, '\n')), 'couldn\'t write to '..file)
  fh:close()
end


local attach = function()
  va.nvim_create_autocmd('BufWritePre', {
    group   = augroup,
    pattern = { '*.js', '*.[cm]js', '*.ts', '*.[jt]sx' },
    desc = 'Run buffer contents through prettier before writing to file.',
    callback = function()
      if not v.bo.modified then return end

      write_tmpfile(va.nvim_buf_get_lines(0, 0, -1, true))

      -- TODO: run process with uv.spawn to get pid and kill on VimLeavePre
      local fh = L.io.popen({ 'cat', file, '| prettierd', vf.expand('%'), '; echo $?' }, false, '')
      local lines = {}
      for ln in L.io.read_no_chop(fh):gmatch('(.-)\r?\n') do
        table.insert(lines, ln)
      end

      if (lines[#lines]) ~= '0' then
        return v.notify('prettier: prettierd returned non-zero exit code.', 3)
      end
      table.remove(lines, #lines)
      va.nvim_buf_set_lines(0, 0, -1, true, lines)
    end
  })
end




-- Register formatting autocommands on startup
if next(get_cmds()) == nil then
  va.nvim_create_autocmd('VimLeavePre', {
    group = augroup,
    once  = true,
    desc  = 'Remove temporary file.',
    callback = function()
      if not v.loop.fs_stat(file) then return end
      assert(os.remove(file), 'couldn\'t remove temporary file '..file)
    end
  })

  attach()
end


-- Create user command to toggle formatting
va.nvim_create_user_command('PrettierToggle', function()
  if running() then
    va.nvim_del_autocmd(get_cmds()[1].id)
    v.notify('prettier: formatting disabled.', 1)
  else
    attach()
    v.notify('prettier: formatting enabled.', 1)
  end
end, { desc = 'Toggle prettier formatting.' })
