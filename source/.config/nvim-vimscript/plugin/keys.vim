" commands
" command -nargs=1 name :command <args>

" remap leader
let mapleader = " "

" qol
nnoremap -- :w<Enter>
nnoremap <C-l> :noh<Enter>
nnoremap <leader>~ viw~
nnoremap <S-h> :call ToggleHiddenAll()<Enter>

" markdown code-block mappings
nnoremap <leader>" a``<Esc>
nnoremap <leader>' o```<Enter>```<Esc>kA

" html / css / js mappings
nnoremap <leader>br oborder: 1px solid red;<Esc>o<Esc>
nnoremap <leader>bg oborder: 1px solid green;<Esc>o<Esc>
nnoremap <leader>bb oborder: 1px solid blue;<Esc>o<Esc>

" fuzzy search
nnoremap         <A-f> :FZF -i --reverse --scroll-off=1 --no-info --no-color --prompt= ~<Enter>
nnoremap <leader><A-f> :FZF .

" create panes
nnoremap         <A-Enter> :vnew<Enter>:FZF -i --reverse --scroll-off=1 --no-info --no-color --prompt= ~<Enter>
nnoremap <leader><A-Enter>  :new<Enter>:FZF -i --reverse --scroll-off=1 --no-info --no-color --prompt= ~<Enter>

" change panes
nnoremap <A-h> <C-w>h
nnoremap <A-j> <C-w>j
nnoremap <A-k> <C-w>k
nnoremap <A-l> <C-w>l

" resize panes
" nnoremap <C-h> :4winc <<Enter>
" nnoremap <C-j> :4winc +<Enter>
" nnoremap <C-k> :4winc -<Enter>
" nnoremap <C-l> :4winc ><Enter>

nnoremap <A-.> <C-w>\|
nnoremap <A--> <C-w>_

" plugin maps
nmap ; gcc
nmap <leader>; gc

imap <A-e> <C-y>,<Esc>
nmap <A-e> <C-y>,<Esc>

nmap [[ <plug>Markdown_MoveToPreviousHeader
nmap ]] <plug>Markdown_MoveToNextHeader
nmap [h <plug>Markdown_MoveToPreviousSiblingHeader
nmap ]h <plug>Markdown_MoveToNextSiblingHeader
nmap ]u <plug>Markdown_MoveToParentHeader

nmap <C-p> <plug>MarkdownPreviewToggle
