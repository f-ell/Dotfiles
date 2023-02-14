local v   = vim
local va  = v.api
local vf  = v.fn
local vu  = v.ui

local augroup = va.nvim_create_augroup('autoexec', { clear = false })

local clean_tbl = {
  ogname = nil,
  ogwin = nil,
  ogbuf = nil,
  aebuf = nil,
  aewin = nil,
  dir = 0, -- 0 -> hor, 1 -> ver
  cmd = nil,
  id  = nil
}
local autoexec = {
  _bufname  = 'AutoExec',
  ogname    = nil,
  ogwin = nil,
  ogbuf = nil,
  aebuf = nil,
  aewin = nil,
  dir = 0, -- 0 -> hor, 1 -> ver
  cmd = nil,
  id  = nil
}




local reset = function()
  if va.nvim_win_is_valid(autoexec.aewin) then
    va.nvim_win_close(autoexec.aewin, true)
  end

  for k, v in pairs(clean_tbl) do
    autoexec[k] = v
  end
end


local has_win = function()
  for _, winnr in pairs(va.nvim_list_wins()) do
    if autoexec.aebuf == va.nvim_win_get_buf(winnr) then return true end
  end
  return false
end




local make_buf = function()
  autoexec.aebuf = va.nvim_create_buf(false, true)
  if autoexec.aebuf == 0 then
    return v.notify('autoexec: couldn\'t create buffer', 4)
  end

  va.nvim_buf_set_name(autoexec.aebuf, autoexec._bufname)
end


local make_split = function()
  local cmd = autoexec.dir == 0 and 'sp' or 'vsp'
  v.cmd(cmd..' | b'..autoexec.aebuf)
  autoexec.aewin = va.nvim_get_current_win()
  va.nvim_set_current_win(autoexec.ogwin)
end


local update_split = function()
  vu.select({ 'hor (-)', 'ver (|)' }, { prompt = 'split type: ' }, function(_, i)
    if i == nil then return print('aborting...') end
    autoexec.dir = i - 1
  end)
end


local update_cmd = function()
  vu.input({ prompt = 'cmd: ',
    default = autoexec.cmd == nil and vf.expand('%:p') or autoexec.cmd },
    function(str)
      if str == nil then return print('aborting...') end
      if str == '' then autoexec.cmd = vf.expand('%:p') end
      autoexec.cmd = str
  end)
end


local register_cmd = function()
  if autoexec.id then return end

  autoexec.id = va.nvim_create_autocmd('BufWritePost', {
    group   = augroup,
    buffer  = autoexec.ogbuf,
    desc    = 'Update buffer contents with <command> output on save.',
    callback  = function()
      local set_data = function(_, data)
        if not data then return end
        va.nvim_buf_set_option(autoexec.aebuf, 'modifiable', true)
        va.nvim_buf_set_lines(autoexec.aebuf, -1, -1, true, data)
        va.nvim_buf_set_option(autoexec.aebuf, 'modifiable', false)
      end

      va.nvim_buf_set_option(autoexec.aebuf, 'modifiable', true)
      va.nvim_buf_set_lines(autoexec.aebuf, 0, -1, false, {
        autoexec.cmd..' output:', '' })
      va.nvim_buf_set_option(autoexec.aebuf, 'modifiable', false)

      vf.jobstart(autoexec.cmd, {
        detach = false,
        stdout_buffered = true,
        on_stdout = set_data,
        on_stderr = set_data
      })
    end
  })
end


local register_del = function()
  va.nvim_create_autocmd({ 'BufUnload', 'BufDelete', 'BufWipeout' }, {
    group   = augroup,
    buffer  = autoexec.aebuf,
    desc    = 'Remove auto-update and reset context on :bd | :bw | unload.',
    callback = function()
      reset()
    end
  })
end




va.nvim_create_user_command('AutoExec', function()
  autoexec.ogwin   = va.nvim_get_current_win()
  autoexec.ogbuf   = va.nvim_get_current_buf()
  autoexec.ogname  = va.nvim_buf_get_name(autoexec.ogbuf)

  if autoexec.aebuf == autoexec.ogbuf then
    return v.notify('autoexec: can\'t attach to AutoExec buffer', 2)
  end
  if autoexec.aebuf then reset() end

  print('attaching to buffer...')

  if not autoexec.aebuf then make_buf() end

  update_split()
  if not has_win() then make_split() end

  update_cmd()
  register_cmd()
  register_del()

  print(' \nattached successfully.')
  v.cmd('silent w')
end, { desc = 'Execute <command> whenever current buffer is written.' })


va.nvim_create_user_command('AutoExecCmd', function()
  update_cmd()
  v.cmd('silent w')
end, { desc = 'Update <command> without changing anything else.' })


va.nvim_create_user_command('AutoExecDetach', function()
  va.nvim_del_autocmd(autoexec.id)
  va.nvim_buf_delete(autoexec.aebuf, { force = true })
  reset()
end, { desc = 'Clean up AutoExec and wipe AutoExec buffer.' })
