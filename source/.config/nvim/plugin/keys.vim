" commands
" command -nargs=1 name :command <args>

" remap leader
let mapleader = " "

" qol
nnoremap <Esc> :w<Enter>
nnoremap <C-l> :noh<Enter>
nnoremap <S-h> :call ToggleHiddenAll()<Return>
" markdown code-block mappings
nnoremap <leader>" a``<Esc>
nnoremap <leader>' o```<Return>```<Esc>kA

" fuzzy search
nnoremap         <A-f> :FZF ~<Enter>
nnoremap <leader><A-f> :FZF .

" new panes
nnoremap         <C-n> :vsp ~/.config/nvim/newpane<Enter>:FZF ~<Enter>
nnoremap <leader><C-n>  :sp ~/.config/nvim/newpane<Enter>:FZF ~<Enter>

" resize panes
nnoremap <C-j> <C-w>4<
nnoremap <C-k> <C-w>4>
nnoremap <leader>h <C-w>\|
nnoremap <leader>l <C-w>_
nnoremap <leader>n <C-w>=

" change panes
nnoremap <A-h> <C-w>h
nnoremap <A-j> <C-w>j
nnoremap <A-k> <C-w>k
nnoremap <A-l> <C-w>l

" plugin maps
map <S-m> <plug>NERDCommenterToggle
imap <A-e> <C-y>,<Esc>
nmap <A-e> <C-y>,<Esc>

nmap [[ <plug>Markdown_MoveToPreviousHeader
nmap ]] <plug>Markdown_MoveToNextHeader
nmap [h <plug>Markdown_MoveToPreviousSiblingHeader
nmap ]h <plug>Markdown_MoveToNextSiblingHeader
nmap ]u <plug>Markdown_MoveToParentHeader

nmap <C-p> <plug>MarkdownPreviewToggle
