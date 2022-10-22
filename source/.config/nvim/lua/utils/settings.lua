local F = require('utils.functions')

-- spelling
  -- using api functions results in horrendous performance hit
-- vim.opt['spell'] = true
-- vim.g['spelllang'] = 'de_de,en_us,en_gb'

-- miscellaneous
F.o('shell',    'dash')
F.o('cdhome',   true)
F.o('confirm',  true)
F.o('showmode', false)
F.o('cmdheight', 0)
F.c('filetype plugin indent on')

F.o('list', true)
F.o('listchars', 'eol:¬,tab:| ,lead:.,trail:~,nbsp:+')
-- F.o('completeopt', 'menu,preview,noinsert')

F.o('cursorline', true)
F.o('ignorecase', true)
F.o('smartcase',  true)

F.o('wrap', false)
F.o('textwidth',  80)
F.o('numberwidth', 3)
-- F.o('signcolumn', 'number')
F.o('signcolumn', 'yes')
F.o('number',         true)
F.o('relativenumber', true)
F.o('pumheight', 7)

F.o('clipboard', 'unnamed')
F.o('guicursor', 'n-v-c-sm:block,i-ci-ve:hor1-blinkon200-blinkoff150,r-cr-o:hor20')
F.o('scrolloff',  1)
F.o('mouse', 'a')

-- tab-settings
F.o('expandtab',  true)
F.o('tabstop',       2)
F.o('softtabstop',   2)
F.o('shiftwidth',    2)

-- timeouts
F.o('timeoutlen',  500)
F.o('ttimeoutlen',   0)

-- splits
F.o('splitbelow',  true)
F.o('splitright',  true)
F.o('equalalways', false)
F.o('ruler',       false)

-- buffer-behaviour
F.o('autochdir',   true)
F.o('updatecount', 0) -- supersedes F.o('swapfile', false)
F.o('undofile',    true)

-- transparency
F.o('pumblend', 8)
F.o('winblend', 8)
