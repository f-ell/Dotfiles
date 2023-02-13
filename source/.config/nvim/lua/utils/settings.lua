local L = require('utils.lib')

-- spelling
  -- using api functions results in horrendous performance hit
-- vim.opt['spell'] = true
-- vim.g['spelllang'] = 'de_de,en_us,en_gb'

-- miscellaneous
L.o('shell',      'dash')
L.o('cdhome',     true)
L.o('confirm',    true)
L.o('showmode',   false)
L.o('showcmd',    false)
L.o('showbreak',  '> ')
L.o('cmdheight',  1)
L.c('filetype plugin indent on')

L.o('list', true)
L.o('listchars', 'eol:¬,tab:| ,lead:.,trail:~,nbsp:+')

L.o('cursorline', true)
L.o('ignorecase', true)
L.o('smartcase',  true)

L.o('wrap', false)
L.o('textwidth',  80)
L.o('numberwidth', 3)
L.o('signcolumn', 'yes')
L.o('number',         true)
L.o('relativenumber', true)
L.o('pumheight', 7)

L.o('clipboard', 'unnamed')
L.o('guicursor', 'n-v-c-sm:block,i-ci-ve:hor1-blinkon200-blinkoff150,r-cr-o:hor20')
L.o('scrolloff',  1)
L.o('mouse', 'a')

-- tab-settings
L.o('expandtab',  true)
L.o('tabstop',       2)
L.o('softtabstop',   2)
L.o('shiftwidth',    2)

-- timeouts
L.o('timeoutlen',  500)
L.o('ttimeoutlen',   0)

-- splits
L.o('splitbelow',  true)
L.o('splitright',  true)
L.o('equalalways', false)
L.o('ruler',       false)

-- buffer-behaviour
L.o('autochdir',   true)
L.o('updatecount', 0) -- supersedes L.o('swapfile', false)
L.o('undofile',    true)

-- transparency
L.o('pumblend', 0)
L.o('winblend', 0)
