set nocompatible

set encoding=utf-8
set spell spelllang=de_de,en_us,en_gb
" syn match latexCommand +\\w\+\s+ contains=@NoSpell
set ruler cursorline
set nowrap textwidth=80 " colorcolumn=+1
set splitbelow splitright

set nobackup nowritebackup noswapfile
set autochdir autoread autowrite " autoindent
set wildmenu
set number relativenumber numberwidth=4
set tabstop=2 expandtab
set scrolloff=1
set mouse=a
set confirm
set clipboard=unnamed
set timeoutlen=500 ttimeoutlen=0
set undofile undodir=~/.config/nvim/undo

syntax on
filetype plugin indent on

set hlsearch incsearch ignorecase

set list listchars=eol:¬,tab:>\ ,trail:~ " ,space:␣
