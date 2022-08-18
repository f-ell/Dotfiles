local F = require('utils.functions')


wipebuf = function()
  if vim.fn.tabpagenr('$') == 1 then
    vim.cmd('enew | bw #')
  else
    vim.cmd('bw')
  end
end

toggleterm = function()
  local bufname = 'term_buffer'
  local termheight = vim.api.nvim_win_get_height(0) / 4

  -- if focused -> close
  if string.find(vim.api.nvim_buf_get_name(0), bufname) then
    return vim.api.nvim_command('close')
  end

  local bufnr = vim.fn.bufnr(bufname)
  -- buffer doesn't exist -> create buf
    -- if vim.fn.bufexists('term_buffer') == 0 then
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


vim.g.mapleader = ' '

-- normal
F.nnmap('<leader>sk', ':source ~/.config/nvim/lua/utils/keymaps.lua<CR>')

F.nnmap('--', ':w<CR>')
F.nnmap('-w', ':lua wipebuf()<CR>')
F.nnmap('<C-l>', ':noh<CR>')
F.nnmap('<leader><CR>', ':lua toggleterm()<CR>')

F.nnmap('<leader>~', 'viw~')
F.nnmap('<leader>rcl', '"*y_:lua <C-r>*<CR>')


F.nnmap('<A-f>', ':FZF -i --reverse --scroll-off=1 --no-info --no-color --prompt=$ ~<CR>')

-- visual
F.vnmap('<Tab>',    '>gv')
F.vnmap('<S-Tab>',  '<gv')

-- command
F.cnmap('<C-h>', '<Left>')
F.cnmap('<C-k>', '<Up>')
F.cnmap('<C-j>', '<Down>')
F.cnmap('<C-l>', '<Right>')

-- terminal
F.tnmap('<C-d>', '<C-\\><C-n>')


-- html / css / js
F.nnmap('<leader>br', 'oborder: 1px solid red;<Esc>o<Esc>')
F.nnmap('<leader>bg', 'oborder: 1px solid green;<Esc>o<Esc>')
F.nnmap('<leader>bb', 'oborder: 1px solid blue;<Esc>o<Esc>')


-- tabs
F.nnmap('<leader>g0', ':tabfirst<CR>')
F.nnmap('<leader>g$', ':tablast<CR>')

F.nnmap('<leader>gh', ':tabmove-<CR>')
F.nnmap('<leader>gj', ':tabmove0<CR>')
F.nnmap('<leader>gl', ':tabmove+<CR>')
F.nnmap('<leader>gk', ':tabmove$<CR>')


-- splits
F.nmap('<A-CR>',          ':vnew<CR><A-f>')
F.nmap('<leader><A-CR>',  ':new<CR><A-f>')

F.nnmap('<A-h>', '<C-w>h')
F.nnmap('<A-j>', '<C-w>j')
F.nnmap('<A-k>', '<C-w>k')
F.nnmap('<A-l>', '<C-w>l')

-- F.nnmap('<C-h>', ':4winc <<CR>')
-- F.nnmap('<C-j>', ':4winc +<CR>')
-- F.nnmap('<C-k>', ':4winc -<CR>')
-- F.nnmap('<C-l>', ':4winc ><CR>')


-- plugins
  -- packer
    F.nnmap('<leader>ps', ':PackerStatus<CR>')
    F.nnmap('<leader>pc', ':PackerCompile<CR>')
    F.nnmap('<leader>py', ':PackerSync<CR>')

  -- colorizer
    F.nnmap('<leader>ct', ':ColorizerToggle<CR>')

  -- emmet
    F.inmap('<A-e>', '<C-y>,<Esc>')
    F.nnmap('<A-e>', '<C-y>,<Esc>')

  -- markdownpreview
    F.nnmap('<A-p>', '<plug>MarkdownPreviewToggle')

  -- nvim-tree
    F.nnmap('<leader>ntt', ':NvimTreeToggle<CR>')

  -- trouble
    F.nnmap('<leader>tt', ':TroubleToggle<CR>')

  -- vimtex
    F.nnmap('<leader>vcl',  ':VimtexClean<CR>')
    F.nnmap('<leader>vcp',  ':VimtexCompileSS<CR>')
    F.nnmap('<leader>vtoc', ':VimTexTocToggle<CR>')
    F.nnmap('<leader>vst',  ':VimtexStatus!<CR>')
    F.nnmap('<leader>vv',   ':VimtexView<CR>')
