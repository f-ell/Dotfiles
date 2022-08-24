local attach_to_buffer = function(_in_bufnr, _out_bufnr, command)
  local in_bufnr  = tonumber(_in_bufnr)
  local out_bufnr = tonumber(_out_bufnr)
  local in_file   = vim.fn.bufname(in_bufnr)

  vim.api.nvim_create_autocmd('BufWritePost', {
    group     = vim.api.nvim_create_augroup('AutoExec', {clear = true}),
    pattern   = in_file,
    callback  = function()
      local append = function(_, data)
        if data then
          vim.api.nvim_buf_set_lines(out_bufnr, -1, -1, false, data)
        end
      end

      vim.api.nvim_buf_set_lines(out_bufnr, 0, -1, false,
        {in_file..' output:'})
      vim.api.nvim_buf_set_lines(out_bufnr, -1, -1, false, {''})

      vim.fn.jobstart(command, {
        stdout_buffered = true, -- get data linewise
        on_stdout = append,
        on_stderr = append
      })
    end
  })
end



vim.api.nvim_create_user_command('AutoExec', function()
  local exists = false
  print('Attaching to buffer...')

  local in_bufname  = vim.fn.bufname()
  local in_bufnr    = vim.fn.bufnr(in_bufname)
  local in_winid    = vim.fn.bufwinid(in_bufnr)
  local out_bufnr

  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.fn.bufname(bufnr) == 'AutoExec' then
      exists    = true
      out_bufnr = bufnr
    end
  end

  if not exists then
    out_bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(out_bufnr, 'AutoExec')

    local split_dir = vim.fn.input('[h]orizontal | [V]ertical: ')
          split_dir = split_dir:lower()

    local split_cmd = ' | b'..out_bufnr..' | exe win_gotoid('..in_winid..')'
    if split_dir == 'h' then  split_cmd = 'new'..split_cmd
    else                      split_cmd = 'vnew'..split_cmd end
    vim.api.nvim_command(split_cmd)
  end

  local command   = vim.split(vim.fn.input('command: '), ' ')

  attach_to_buffer(in_bufnr, out_bufnr, command)
  print(' \nAttached.')
  vim.api.nvim_command('silent w')
end, {})
