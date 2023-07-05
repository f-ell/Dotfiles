local vim = require('utils.lib').vim

-- spelling
-- v.o('spell', true) -- horrendous performance hit
vim.o('spelllang', 'en_gb,de_de')

-- miscellaneous
vim.o('shell',      'dash')
vim.o('cdhome',     true)
vim.o('confirm',    true)
vim.o('showmode',   false)
vim.o('showcmd',    false)
vim.o('showbreak',  '> ')
vim.o('cmdheight',  1)
vim.c('filetype plugin indent on')

vim.o('list', true)
vim.o('listchars', 'eol:¬,tab:| ,lead:.,trail:~,nbsp:+')

vim.o('cursorline', true)
vim.o('ignorecase', true)
vim.o('smartcase',  true)
vim.o('shortmess', 'asWFS')

vim.o('wrap', false)
vim.o('textwidth',  80)
vim.o('signcolumn', 'yes')
vim.o('number',         true)
vim.o('relativenumber', true)
vim.o('pumheight', 7)

vim.o('clipboard', 'unnamed')
vim.o('guicursor', 'n-v-c-sm:block,i-ci-ve:hor1-blinkon200-blinkoff150,r-cr-o:hor20')
vim.o('scrolloff',  1)
vim.o('mouse', 'a')

-- tab-settings
vim.o('expandtab',  true)
vim.o('tabstop',       2)
vim.o('softtabstop',   2)
vim.o('shiftwidth',    2)

-- timeouts
vim.o('timeoutlen',  500)
vim.o('ttimeoutlen',   0)

-- splits
vim.o('splitbelow',  true)
vim.o('splitright',  true)
vim.o('equalalways', false)
vim.o('ruler',       false)

-- buffer-behaviour
vim.o('autochdir',   true)
vim.o('updatecount', 0)
vim.o('undofile',    true)

-- transparency
vim.o('pumblend', 0)
vim.o('winblend', 0)
