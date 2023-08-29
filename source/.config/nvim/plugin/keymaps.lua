local key = require('utils.lib').key

local wipe_buf = function()
  if #vim.api.nvim_list_tabpages() == 1 then
    vim.cmd('enew! | silent! bw #')
  else
    vim.cmd('bw')
  end
end

local terminal = function()
  local name = 'terminal'
  local termheight  = vim.api.nvim_win_get_height(0) / 4

  if string.find(vim.api.nvim_buf_get_name(0), name) then
    vim.api.nvim_command('close')
    return
  end

  local bufnr = vim.fn.bufnr(name)
  if bufnr == -1 then
    bufnr = vim.api.nvim_create_buf(false, false)
    if bufnr == 0 then
      vim.log('error spawning new terminal buffer', 4)
      return
    end
  else
    local winid = vim.fn.bufwinid(bufnr)
    if winid ~= -1 then
      vim.fn.win_gotoid(winid)
      return
    end
  end

  vim.api.nvim_command('bot sb'..bufnr..' | resize '..termheight)

  if vim.fn.bufname(bufnr) == '' then
    vim.fn.termopen('/bin/zsh')
    vim.api.nvim_command('0f | f '..name)
  end
end

-- misc
key.nnmap('<F12>', '<CMD>syntax sync fromstart<CR>')
key.nnmap('--', '<CMD>w<CR>')
key.nnmap('-d', '<CMD>bd<CR>')
key.nnmap('-w', function() wipe_buf() end)

key.nnmap('<leader>~', 'viw~')
key.nnmap('<leader>w', '<CMD>w !doas tee %<CR>')
key.nnmap('<leader>x', '<CMD>!chmod 744 %<CR>')
key.nnmap('<leader>%', '<CMD>so %<CR>')

key.tnmap('<C-d>', '<C-\\><C-n>')
key.nnmap('<leader><CR>', function() terminal() end)

key.nnmap('n', 'nzz')
key.nnmap('N', 'Nzz')
key.nnmap('<C-u>', '<C-u>zz')
key.nnmap('<C-d>', '<C-d>zz')
key.modemap({'n', 'v'}, '<leader>y', '"+y')
key.modemap({'n', 'v'}, '<leader>d', '"_d')

-- tabs
key.nnmap('<leader>t0', '<CMD>tabmove0<CR>')
key.nnmap('<leader>t$', '<CMD>tabmove$<CR>')
key.nnmap('<leader>tj', '<CMD>silent! tabmove-<CR>')
key.nnmap('<leader>tk', '<CMD>silent! tabmove+<CR>')

-- ex navigation
key.cnmap('<C-h>', '<Left>')
key.cnmap('<C-k>', '<Up>')
key.cnmap('<C-j>', '<Down>')
key.cnmap('<C-l>', '<Right>')

-- window navigation
key.nnmap('<A-h>', '<C-w>h')
key.nnmap('<A-j>', '<C-w>j')
key.nnmap('<A-k>', '<C-w>k')
key.nnmap('<A-l>', '<C-w>l')
