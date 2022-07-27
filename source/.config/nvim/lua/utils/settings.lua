local F = require('utils.functions')

-- Encoding, spelling, clipboard, undo
-- F.g('encoding', 'utf-8')
F.o('spell')
F.g('spelllang', 'de_de,en_us,en_gb')

-- General settings
-- F.g('nocompatible')
F.g('shell', 'dash')
F.c('syntax on')
F.c('filetype plugin indent on')
F.o('list')
  vim.opt.listchars = {
    eol  = '¬',
    tab  = '| ',
    nbsp = '+',
    trail = '~'
  }

F.o('wrap', '!')
F.g('laststatus', '3')
F.g('textwidth', '80')
F.g('numberwidth', '3')
F.o('number')
F.o('relativenumber')
F.g('signcolumn', 'yes:1')

F.g('clipboard', 'unnamed')
F.g('mouse', 'a')
F.g('scrolloff', '1')
F.o('expandtab')
F.o('smarttab')
vim.bo.tabstop      = 2
vim.bo.softtabstop  = 2
vim.bo.shiftwidth   = 2

F.o('confirm')
-- F.o('wildmenu')

-- Key-chord timeouts
F.g('timeoutlen', '500')
F.g('ttimeoutlen', '0')

-- Splits and 
F.o('splitbelow')
F.o('splitright')
-- F.o('ruler')
F.o('cursorline')

F.o('autochdir')
-- F.o('autoread')
F.o('autowrite')
F.o('backup', '!')
F.o('writebackup', '!')
F.o('swapfile', '!')
F.o('undofile')
-- F.g('undodir', '~/.local/share/nvim/undo')

-- Search behaviour
-- F.o('hlsearch')
-- F.o('incsearch')
F.o('ignorecase')
