local F = require('utils.functions')

-- Spelling
  -- using api functions results in horrendous performance hit
-- vim.opt['spell'] = true
-- vim.g['spelllang'] = 'de_de,en_us,en_gb'

-- General settings
F.o('shell',   'dash')
F.o('showmode', false)
F.c('filetype plugin indent on')

F.o('list', true)
F.o('listchars', 'eol:¬,tab:| ,nbsp:+,trail:~')

F.o('wrap', false)
F.o('textwidth', 80)
F.o('numberwidth',  3)
F.o('number',          true)
F.o('relativenumber',  true)
F.o('pumheight', 8)

F.o('clipboard', 'unnamed')
F.o('guicursor', 'n-v-c-sm:block,i-ci-ve:block1-blinkon200-blinkoff150,r-cr-o:hor20')
F.o('mouse',     'a')
F.o('scrolloff',   1)

-- Tab settings
F.o('expandtab',  true)
F.o('tabstop',       2)
F.o('softtabstop',   2)
F.o('shiftwidth',    2)

F.o('confirm', true)

-- Key-chord timeouts
F.o('timeoutlen',  500)
F.o('ttimeoutlen',   0)

-- Splits and 
F.o('splitbelow',  true)
F.o('splitright',  true)
F.o('cursorline',  true)
F.o('ruler',       false)

F.o('autochdir',   true)
F.o('updatecount', 0) -- supersedes F.bset('swapfile', false)
F.o('undofile',    true)

-- Search behaviour
F.o('ignorecase', true)
