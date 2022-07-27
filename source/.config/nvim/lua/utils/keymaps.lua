local F = require('utils.functions')

F.g('mapleader', ' ')

-- QOL
F.nnmap('--', ':w<CR>')
F.nnmap('<C-l>', ':noh<CR>')
F.nnmap('<leader>~', 'viw~')

F.nnmap('<leader>t', ':TroubleToggle<CR>')
F.nnmap('<leader>e', ':NvimTreeToggle<CR>')
F.nnmap('<A-f>', ':FZF -i --reverse --scroll-off=1 --no-info --no-color --prompt=$ ~<CR>')


-- PACKER
F.nnmap('<leader>ps', ':PackerStatus<CR>')
F.nnmap('<leader>pc', ':PackerCompile<CR>')
F.nnmap('<leader>py', ':PackerSync<CR>')


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
  -- Emmet
    F.inmap('<A-e>', '<C-y>,<Esc>')
    F.nnmap('<A-e>', '<C-y>,<Esc>')
  -- MarkdownPreview
    F.nnmap('<A-p>', '<plug>MarkdownPreviewToggle')
