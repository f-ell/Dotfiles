local F = require('utils.functions')

-- Spelling
  -- using api functions results in horrendous performance hit
-- vim.opt['spell'] = true
-- vim.g['spelllang'] = 'de_de,en_us,en_gb'

-- General settings
F.gset('shell',   'dash')
F.bset('syntax',  'on')
F.gset('showmode', false)
F.c('filetype plugin indent on')

F.wset('list', true)
F.gset('listchars', 'eol:¬,tab:| ,nbsp:+,trail:~')

F.wset('wrap', false)
F.bset('textwidth',   80)
F.wset('numberwidth',  3)
F.wset('number',          true)
F.wset('relativenumber',  true)
F.wset('signcolumn', 'yes:1')
F.gset('pumheight', 8)

F.gset('clipboard', 'unnamed')
F.gset('guicursor', 'n-v-c-sm:block,i-ci-ve:block1-blinkon200-blinkoff150,r-cr-o:hor20')
F.gset('mouse',     'a')
F.gset('scrolloff',   1)

-- Tab settings
F.bset('expandtab', true)
F.bset('tabstop',     2)
F.bset('softtabstop', 2)
F.bset('shiftwidth',  2)

F.gset('confirm', true)

-- Key-chord timeouts
F.gset('timeoutlen',  500)
F.gset('ttimeoutlen',   0)

-- Splits and 
F.gset('splitbelow',  true)
F.gset('splitright',  true)
F.wset('cursorline',  true)
F.gset('ruler',       false)

-- F.gset('autochdir')
-- F.gset('autowrite')
F.bset('swapfile', false)
F.bset('undofile', true)

-- Search behaviour
F.gset('ignorecase', true)
