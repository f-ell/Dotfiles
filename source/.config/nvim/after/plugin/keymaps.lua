local F = require('utils.functions')


local wipe_buf = function()
  if vim.fn.tabpagenr('$') == 1 then  vim.cmd('enew | bw #')
  else                                vim.cmd('bw') end
end


local tab_bufs = function()
  -- loops over tabs - checks if any window holds target buffer in any tab
  local haswindow = function(target_bufnr)
    for i = 1, vim.fn.tabpagenr('$') do
      local tabbuflist = vim.fn.tabpagebuflist(i)
      for j = 1, #(tabbuflist) do
        if vim.fn.bufnr(tabbuflist[j]) == target_bufnr then return true end
      end
    end

    return false
  end

  -- loop over buffers - check if buffer should be split to new tab
  for _, v in pairs(vim.api.nvim_list_bufs()) do
    local bufname = vim.fn.bufname(v)

    if    vim.fn.buflisted(v) == 1
      -- and vim.fn.bufloaded(v) == 1
      and not haswindow(v)
      and bufname ~= '' then
      vim.cmd('tabe '..bufname)
    end
  end

  vim.cmd('tablast')
end


local terminal = function()
  local bufname     = 'term_buffer'
  local termheight  = vim.api.nvim_win_get_height(0) / 4

  -- if focused -> close
  if string.find(vim.api.nvim_buf_get_name(0), bufname) then
    return vim.api.nvim_command('close')
  end

  local bufnr = vim.fn.bufnr(bufname)
  -- buffer doesn't exist -> create buf
  if bufnr == -1 then
    bufnr = vim.api.nvim_create_buf(false, false)
    if bufnr == 0 then
      return print('Fatal error while spawing new terminal buffer!')
    end
  -- buffer exists ->
  else
    -- window exists? -> focus
    local winid = vim.fn.bufwinid(bufnr)
    if winid ~= -1 then return vim.fn.win_gotoid(winid) end
  end

  -- window doesn't exist? -> split
  vim.api.nvim_command('bot sb'..bufnr..' | resize '..termheight)

  -- window is empty -> open new terminal and rename
  if vim.fn.bufname(bufnr) == '' then
    vim.fn.termopen('/bin/zsh')
    vim.api.nvim_command('0f | f '..bufname)
  end
end




-- misc
F.nnmap('--', '<CMD>w<CR>')
F.nnmap('-d', '<CMD>bd<CR>')
F.nnmap('-w',         function() wipe_buf() end)
F.nnmap('<leader>tb', function() tab_bufs() end)

F.nnmap('<leader>~',  'viw~')
F.nnmap('<leader>w',  '<CMD>w !doas tee %<CR>')
F.nnmap('<leader>x',  '<CMD>!chmod 744 %<CR>')
F.nnmap('<leader>%%', '<CMD>so %<CR>')
F.nnmap('<leader>%k', '<CMD>so ~/.config/nvim/after/plugin/keymaps.lua<CR>')
F.nnmap('<leader>%s', '<CMD>so ~/.config/nvim/lua/plugins/luasnip.lua<CR>')

F.tnmap('<C-d>', '<C-\\><C-n>')
F.nnmap('<leader><CR>', function() terminal() end)

-- credits primeagen
F.nnmap('n', 'nzz')
F.nnmap('N', 'Nzz')
F.nnmap('<C-u>', '<C-u>zz')
F.nnmap('<C-d>', '<C-d>zz')
F.nnmap('<leader>y', '"+y')
F.vnmap('<leader>y', '"+y')
F.nnmap('<leader>d', '"_d')
F.vnmap('<leader>d', '"_d')

  -- tabs
F.nnmap('<leader>g0', '<CMD>tabfirst<CR>')
F.nnmap('<leader>g$', '<CMD>tablast<CR>')
F.nnmap('<leader>gh', '<CMD>silent! tabmove-<CR>')
F.nnmap('<leader>gj', '<CMD>tabmove0<CR>')
F.nnmap('<leader>gl', '<CMD>silent! tabmove+<CR>')
F.nnmap('<leader>gk', '<CMD>tabmove$<CR>')

-- ex-mode navigation
F.cnmap('<C-h>', '<Left>')
F.cnmap('<C-k>', '<Up>')
F.cnmap('<C-j>', '<Down>')
F.cnmap('<C-l>', '<Right>')

  -- windows
F.nnmap('<A-h>', '<C-w>h')
F.nnmap('<A-j>', '<C-w>j')
F.nnmap('<A-k>', '<C-w>k')
F.nnmap('<A-l>', '<C-w>l')

  -- html / css / js
F.nnmap('<leader>br', 'oborder<CMD> 1px solid red;<Esc>o<Esc>')
F.nnmap('<leader>bg', 'oborder<CMD> 1px solid green;<Esc>o<Esc>')
F.nnmap('<leader>bb', 'oborder<CMD> 1px solid blue;<Esc>o<Esc>')
