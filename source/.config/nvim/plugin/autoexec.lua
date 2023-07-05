local augroup = vim.api.nvim_create_augroup('autoexec', { clear = false })

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
  if vim.api.nvim_win_is_valid(autoexec.aewin) then
    vim.api.nvim_win_close(autoexec.aewin, true)
  end

  for k, v in pairs(clean_tbl) do
    autoexec[k] = v
  end
end


local has_win = function()
  for _, winnr in pairs(vim.api.nvim_list_wins()) do
    if autoexec.aebuf == vim.api.nvim_win_get_buf(winnr) then return true end
  end
  return false
end




local make_buf = function()
  autoexec.aebuf = vim.api.nvim_create_buf(false, true)
  if autoexec.aebuf == 0 then
    return vim.notify('autoexec: couldn\'t create buffer', 4)
  end

  vim.api.nvim_buf_set_name(autoexec.aebuf, autoexec._bufname)
end


local make_split = function()
  local cmd = autoexec.dir == 0 and 'sp' or 'vsp'
  vim.cmd(cmd..' | b'..autoexec.aebuf)
  autoexec.aewin = vim.api.nvim_get_current_win()
  vim.api.nvim_set_current_win(autoexec.ogwin)
end


local update_split = function()
  vim.ui.select({ 'hor (-)', 'ver (|)' }, { prompt = 'split type: ' }, function(_, i)
    if i == nil then return vim.notify('aborting...', 2) end
    autoexec.dir = i - 1
  end)
end


local update_cmd = function()
  vim.ui.input({ prompt = 'cmd: ',
    default = autoexec.cmd == nil and vim.fn.expand('%:p') or autoexec.cmd },
    function(str)
      if str == nil then return vim.notify('aborting...', 2) end
      if str == '' then autoexec.cmd = vim.fn.expand('%:p') end
      autoexec.cmd = str
  end)
end


local register_cmd = function()
  if autoexec.id then return end

  autoexec.id = vim.api.nvim_create_autocmd('BufWritePost', {
    group   = augroup,
    buffer  = autoexec.ogbuf,
    desc    = 'Update buffer contents with <command> output on save.',
    callback  = function()
      local set_data = function(_, data)
        if not data then return end
        vim.api.nvim_buf_set_option(autoexec.aebuf, 'modifiable', true)
        vim.api.nvim_buf_set_lines(autoexec.aebuf, -1, -1, true, data)
        vim.api.nvim_buf_set_option(autoexec.aebuf, 'modifiable', false)
      end

      vim.api.nvim_buf_set_option(autoexec.aebuf, 'modifiable', true)
      vim.api.nvim_buf_set_lines(autoexec.aebuf, 0, -1, false, {
        autoexec.cmd..' output:', '' })
      vim.api.nvim_buf_set_option(autoexec.aebuf, 'modifiable', false)

      vim.fn.jobstart(autoexec.cmd, {
        detach = false,
        stdout_buffered = true,
        on_stdout = set_data,
        on_stderr = set_data
      })
    end
  })
end


local register_del = function()
  vim.api.nvim_create_autocmd({ 'BufUnload', 'BufDelete', 'BufWipeout' }, {
    group = augroup,
    buffer = autoexec.aebuf,
    desc = 'Remove auto-update and reset context on :bd | :bw | unload.',
    callback = function()
      reset()
    end
  })
end




vim.api.nvim_create_user_command('AutoExec', function()
  autoexec.ogwin = vim.api.nvim_get_current_win()
  autoexec.ogbuf = vim.api.nvim_get_current_buf()
  autoexec.ogname = vim.api.nvim_buf_get_name(autoexec.ogbuf)

  if autoexec.aebuf == autoexec.ogbuf then
    return vim.notify('autoexec: can\'t attach to autoexec buffer', 2)
  end
  if autoexec.aebuf then reset() end

  vim.notify('attaching to buffer...', 2)

  if not autoexec.aebuf then make_buf() end

  update_split()
  if not has_win() then make_split() end

  update_cmd()
  register_cmd()
  register_del()

  vim.notify('attached', 2)
  vim.cmd('silent w')
end, { desc = 'Execute <command> whenever current buffer is written.' })


vim.api.nvim_create_user_command('AutoExecCmd', function()
  update_cmd()
  vim.cmd('silent w')
end, { desc = 'Update <command> without changing anything else.' })


vim.api.nvim_create_user_command('AutoExecDetach', function()
  vim.api.nvim_del_autocmd(autoexec.id)
  vim.api.nvim_buf_delete(autoexec.aebuf, { force = true })
  reset()
end, { desc = 'Clean up AutoExec and wipe AutoExec buffer.' })


vim.api.nvim_create_user_command('AutoExecShow', function()
  if not autoexec.aewin or has_win() then
    return vim.notify('autoexec: no autoexec buffer found', 3)
  end
  make_split()
end, { desc = 'Re-split AutoExec buffer if it exists and isn\'t visible.' })
