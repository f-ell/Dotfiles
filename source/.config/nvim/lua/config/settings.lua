local F = require('config.functions')

-- General settings
F.setsV('syntax', 'on')
F.setsV('filetype', 'plugin indent on')
F.setNV('list')
	vim.opt.listchars = {
		eol = '¬',
		tab = '> ',
		trail = '~'
	}
F.setNV('nocompatible')

-- Encoding, spelling, clipboard, undo
F.setNV('encoding', 'utf-8')
F.setNV('spell')
F.setNV('spelllang', 'de_de,en_us,en_gb')

F.setNV('clipboard', 'unnamed')
F.setNV('confirm')
F.setNV('wildmenu')
F.setNV('undofile')
F.setNV('undodir', '~/.local/share/nvim/undo')

-- Key-chord timeouts
F.setNV('timeoutlen', '500')
F.setNV('ttimeoutlen', '0')

-- Look and behaviour
F.setNV('nowrap')
vim.cmd(":lua vim.g.signcolumn = 'yes:1'")
F.setNV('numberwidth', '3')
F.setNV('textwidth', '80')

F.setNV('mouse', 'a')
F.setNV('laststatus', '3')
F.setNV('scrolloff', '1')
F.setNV('tabstop', '2')
F.setNV('softtabstop', '2')
F.setNV('shiftwidth', '2')
F.setNV('expandtab')

-- Splits and numbering
F.setmV('splitbelow', 'splitright')
F.setmV('number', 'relativenumber')
F.setmV('ruler', 'cursorline')

F.setmV('nobackup', 'nowritebackup', 'noswapfile')
F.setmV('autochdir', 'autoread', 'autowrite')

-- Search behaviour
F.setmV('hlsearch', 'incsearch', 'ignorecase')


-- Disable builtin plugins
F.vimg('loaded_gzip', '0')
F.vimg('loaded_zipPlugin', '0')
F.vimg('loaded_tar', '0')
F.vimg('loaded_tarPlugin', '0')
F.vimg('loaded_2html_plugin', '0')
F.vimg('loaded_netrw', '0')
F.vimg('loaded_netrwPlugin', '0')
F.vimg('loaded_matchit', '0')
F.vimg('loaded_matchparen', '0')
F.vimg('loaded_spec', '0')
