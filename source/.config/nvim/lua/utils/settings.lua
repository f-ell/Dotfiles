local v = require('utils.lib').vim

-- spelling
  -- using api functions results in horrendous performance hit
-- vim.opt['spell'] = true
-- vim.g['spelllang'] = 'de_de,en_us,en_gb'

-- miscellaneous
v.o('shell',      'dash')
v.o('cdhome',     true)
v.o('confirm',    true)
v.o('showmode',   false)
v.o('showcmd',    false)
v.o('showbreak',  '> ')
v.o('cmdheight',  1)
v.c('filetype plugin indent on')

v.o('list', true)
v.o('listchars', 'eol:¬,tab:| ,lead:.,trail:~,nbsp:+')

v.o('cursorline', true)
v.o('ignorecase', true)
v.o('smartcase',  true)
v.o('shortmess', 'asWFS')

v.o('wrap', false)
v.o('textwidth',  80)
v.o('numberwidth', 3)
v.o('signcolumn', 'yes')
v.o('number',         true)
v.o('relativenumber', true)
v.o('pumheight', 7)

v.o('clipboard', 'unnamed')
v.o('guicursor', 'n-v-c-sm:block,i-ci-ve:hor1-blinkon200-blinkoff150,r-cr-o:hor20')
v.o('scrolloff',  1)
v.o('mouse', 'a')

-- tab-settings
v.o('expandtab',  true)
v.o('tabstop',       2)
v.o('softtabstop',   2)
v.o('shiftwidth',    2)

-- timeouts
v.o('timeoutlen',  500)
v.o('ttimeoutlen',   0)

-- splits
v.o('splitbelow',  true)
v.o('splitright',  true)
v.o('equalalways', false)
v.o('ruler',       false)

-- buffer-behaviour
v.o('autochdir',   true)
v.o('updatecount', 0) -- supersedes L.o('swapfile', false)
v.o('undofile',    true)

-- transparency
v.o('pumblend', 0)
v.o('winblend', 0)
