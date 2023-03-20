local key = require('utils.lib').key
local v   = vim


local wipe_buf = function()
  if #v.api.nvim_list_tabpages() == 1 then  v.cmd('enew! | silent! bw #')
  else                                      v.cmd('bw') end
end


local tab_bufs = function()
  -- loop over tabs - check if any window holds target buffer in any tab
  local haswindow = function(target_bufnr)
    for i = 1, v.fn.tabpagenr('$') do
      local tabbuflist = v.fn.tabpagebuflist(i)
      for j = 1, #(tabbuflist) do
        if v.fn.bufnr(tabbuflist[j]) == target_bufnr then return true end
      end
    end

    return false
  end

  -- loop over buffers - check if buffer should be split to new tab
  for _, b in pairs(v.api.nvim_list_bufs()) do
    local bufname = v.fn.bufname(b)

    if    v.fn.buflisted(b) == 1
      -- and v.fn.bufloaded(v) == 1
      and not haswindow(b)
      and bufname ~= '' then
      v.cmd('tabe '..bufname)
    end
  end

  v.cmd('tablast')
end


local terminal = function()
  local bufname     = 'terminal'
  local termheight  = v.api.nvim_win_get_height(0) / 4

  -- if focused -> close
  if string.find(v.api.nvim_buf_get_name(0), bufname) then
    return v.api.nvim_command('close')
  end

  local bufnr = v.fn.bufnr(bufname)
  -- buffer doesn't exist -> create buf
  if bufnr == -1 then
    bufnr = v.api.nvim_create_buf(false, false)
    if bufnr == 0 then
      return print('Fatal error while spawing new terminal buffer!')
    end
  -- buffer exists ->
  else
    -- window exists? -> focus
    local winid = v.fn.bufwinid(bufnr)
    if winid ~= -1 then return v.fn.win_gotoid(winid) end
  end

  -- window doesn't exist? -> split
  v.api.nvim_command('bot sb'..bufnr..' | resize '..termheight)

  -- window is empty -> open new terminal and rename
  if v.fn.bufname(bufnr) == '' then
    v.fn.termopen('/bin/zsh')
    v.api.nvim_command('0f | f '..bufname)
  end
end




-- misc
key.nnmap('<F12>', '<CMD>syntax sync fromstart<CR>')
key.nnmap('--', '<CMD>w<CR>')
key.nnmap('-d', '<CMD>bd<CR>')
key.nnmap('-w',           function() wipe_buf() end)
key.nnmap('<leader>tab',  function() tab_bufs() end)

key.nnmap('<leader>~', 'viw~')
key.nnmap('<leader>w', '<CMD>w !doas tee %<CR>')
key.nnmap('<leader>x', '<CMD>!chmod 744 %<CR>')
key.nnmap('<leader>%', '<CMD>so %<CR>')

key.tnmap('<C-d>', '<C-\\><C-n>')
key.nnmap('<leader><CR>', function() terminal() end)

-- credits primeagen
key.nnmap('n', 'nzz')
key.nnmap('N', 'Nzz')
key.nnmap('<C-u>', '<C-u>zz')
key.nnmap('<C-d>', '<C-d>zz')
key.nnmap('<leader>y', '"+y')
key.vnmap('<leader>y', '"+y')
key.nnmap('<leader>d', '"_d')
key.vnmap('<leader>d', '"_d')

  -- tabs
key.nnmap('<leader>g0', '<CMD>tabfirst<CR>')
key.nnmap('<leader>g$', '<CMD>tablast<CR>')
key.nnmap('<leader>gh', '<CMD>silent! tabmove-<CR>')
key.nnmap('<leader>gj', '<CMD>tabmove0<CR>')
key.nnmap('<leader>gl', '<CMD>silent! tabmove+<CR>')
key.nnmap('<leader>gk', '<CMD>tabmove$<CR>')

-- ex-mode navigation
key.cnmap('<C-h>', '<Left>')
key.cnmap('<C-k>', '<Up>')
key.cnmap('<C-j>', '<Down>')
key.cnmap('<C-l>', '<Right>')

  -- windows
key.nnmap('<A-h>', '<C-w>h')
key.nnmap('<A-j>', '<C-w>j')
key.nnmap('<A-k>', '<C-w>k')
key.nnmap('<A-l>', '<C-w>l')
