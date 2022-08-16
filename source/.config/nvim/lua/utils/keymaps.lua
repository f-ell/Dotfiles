local F = require('utils.functions')


term = function()
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

-- QOL
-- n
F.nnmap('<leader>sk', ':source ~/.config/nvim/lua/utils/keymaps.lua<CR>')

F.nnmap('--', ':w<CR>')
F.nnmap('<leader>bw', ':bw<CR>')
F.nnmap('<C-l>', ':noh<CR>')


F.nnmap('<leader>~', 'viw~')
F.nnmap('<leader><CR>', ':lua term()<CR>')

F.nnmap('<A-f>', ':FZF -i --reverse --scroll-off=1 --no-info --no-color --prompt=$ ~<CR>')

-- v
F.vnmap('<Tab>', '>gv')
F.vnmap('<S-Tab>', '<gv')

-- c
F.cnmap('<C-h>', '<Left>')
F.cnmap('<C-k>', '<Up>')
F.cnmap('<C-j>', '<Down>')
F.cnmap('<C-l>', '<Right>')

-- t
F.tnmap('<C-d>', '<C-\\><C-n>')



-- PACKER
F.nnmap('<leader>ps', ':PackerStatus<CR>')
F.nnmap('<leader>pc', ':PackerCompile<CR>')
F.nnmap('<leader>py', ':PackerSync<CR>')


-- TABS
F.nnmap('<leader>h', ':tabnext-<CR>')
F.nnmap('<leader>j', ':tabfirst<CR>')
F.nnmap('<leader>l', ':tabnext+<CR>')
F.nnmap('<leader>k', ':tablast<CR>')

F.nnmap('<leader><C-h>', ':tabmove-<CR>')
F.nnmap('<leader><C-j>', ':tabmove0<CR>')
F.nnmap('<leader><C-l>', ':tabmove+<CR>')
F.nnmap('<leader><C-k>', ':tabmove$<CR>')


-- SPLITS
F.nmap('<A-CR>', ':vnew<CR><A-f>')
F.nmap('<leader><A-CR>', ':new<CR><A-f>')

F.nnmap('<A-h>', '<C-w>h')
F.nnmap('<A-j>', '<C-w>j')
F.nnmap('<A-k>', '<C-w>k')
F.nnmap('<A-l>', '<C-w>l')

-- map('n', '<C-h>', ':4winc <<CR>')
-- map('n', '<C-j>', ':4winc +<CR>')
-- map('n', '<C-k>', ':4winc -<CR>')
-- map('n', '<C-l>', ':4winc ><CR>')

-- F.map('n', '<A-.>', '<C-w>|') -- might need backslash-escape
-- F.map('n', '<A-->', '<C-w>_')


-- HTML / CSS / JS
F.nnmap('<leader>br', 'oborder: 1px solid red;<Esc>o<Esc>')
F.nnmap('<leader>bg', 'oborder: 1px solid green;<Esc>o<Esc>')
F.nnmap('<leader>bb', 'oborder: 1px solid blue;<Esc>o<Esc>')


-- Markdown
F.nnmap('<leader>"', 'a``<Esc>')
F.nnmap('<leader>\'', 'o```<CR>```<Esc>kA')


-- Plugins
  -- Colorizer
    F.nnmap('<leader>c', ':ColorizerToggle<CR>')
  -- Trouble
    F.nnmap('<leader>t', ':TroubleToggle<CR>')

  -- Nvim-Tree
    F.nnmap('<leader>e', ':NvimTreeToggle<CR>')

  -- Emmet
    F.inmap('<A-e>', '<C-y>,<Esc>')
    F.nnmap('<A-e>', '<C-y>,<Esc>')

  -- MarkdownPreview
    F.nnmap('<A-p>', '<plug>MarkdownPreviewToggle')
