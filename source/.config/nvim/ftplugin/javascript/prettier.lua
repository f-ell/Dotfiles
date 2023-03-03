local L   = require('utils.lib')
local v   = vim
local va  = v.api
local vf  = v.fn


if vf.executable('prettier') ~= 1 then return end


local augroup = va.nvim_create_augroup('prettier', { clear = false })
local dir   = vf.stdpath('run')..'/nvim.user'
local file  = dir..'/nvim_prettier'..v.loop.os_getpid()


-- INFO: for more efficient writing (prettier makes it slow enough as is), this
-- is only run once. Deleting or making dir inaccessible while nvim is running
-- will break the autocommand.
L.fs.mktmpdir()




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

      local fh = L.io.popen({ 'prettier',
        '--cache-strategy', 'content', '--cache',
        '--parser', v.bo.filetype, file }, false, '')

      local lines = {}
      for ln in L.io.read_no_chop(fh):gmatch('(.-)\r?\n') do
        table.insert(lines, ln)
      end

      va.nvim_buf_set_lines(0, 0, -1, true, lines)
    end
  })
end




-- Register formatting autocommands on startup
if next(get_cmds()) == nil then
  va.nvim_create_autocmd('VimLeavePre', {
    group = augroup,
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
