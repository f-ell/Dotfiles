local F = require('config.functions')

F.vimg('mapleader', ' ')

-- QOL
F.map('n', '--', ':w<Enter>')
F.map('n', ',,', '@@')
F.map('n', '<S-t>', ':TroubleToggle<Enter>')
F.map('n', '<C-l>', ':noh<Enter>')

F.map('n', '<leader>~', 'viw~')
F.map('n', '<A-f>', ':FZF -i --reverse --scroll-off=1 --no-info --no-color --prompt=$ ~<Enter>')

-- Markdown
F.map('n', '<leader>"', 'a``<Esc>')
F.map('n', '<leader>\'', 'o```<Enter>```<Esc>kA')

-- HTML / CSS / JS
F.map('n', '<leader>br', 'oborder: 1px solid red;<Esc>o<Esc>')
F.map('n', '<leader>bg', 'oborder: 1px solid green;<Esc>o<Esc>')
F.map('n', '<leader>bb', 'oborder: 1px solid blue;<Esc>o<Esc>')

-- SPLITS
F.map('n', '<A-Enter>', ':vnew<Enter><A-f>', { noremap = false })
F.map('n', '<leader><A-Enter>', ':new<Enter><A-f>', { noremap = false })

F.map('n', '<A-h>', '<C-w>h')
F.map('n', '<A-j>', '<C-w>j')
F.map('n', '<A-k>', '<C-w>k')
F.map('n', '<A-l>', '<C-w>l')

-- map('n', '<C-h>', ':4winc <<Enter>')
-- map('n', '<C-j>', ':4winc +<Enter>')
-- map('n', '<C-k>', ':4winc -<Enter>')
-- map('n', '<C-l>', ':4winc ><Enter>')

F.map('n', '<A-.>', '<C-w>|') -- might need backslash-escape
F.map('n', '<A-->', '<C-w>_')

-- Plugins
  -- Emmet
    F.map('i', '<A-e>', '<C-y>,<Esc>')
    F.map('n', '<A-e>', '<C-y>,<Esc>')
  -- MarkdownPreview
    F.map('n', '<C-p>', '<plug>MarkdownPreviewToggle')
