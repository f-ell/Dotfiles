" ____   ____
" |   \  |  |______
" |    \ |  | ___  \
" |     \|  | |  \  |
" |  \   \  | |__/  |
" |  |\     | _____/
" |__| \____| | Author: Nico Pareigis
"          |__| NeoVim
"
" Note: This configuration is split into multiple files to keep different parts
" of the configuration easily digestible. This file only contains Vim-Plug im-
" ports and some general configuration.

" plugins
call plug#begin('~/.config/nvim/vim-plug/plugged')

Plug 'sheerun/vim-polyglot'
Plug 'tpope/vim-surround'
Plug 'preservim/nerdcommenter'
  let g:NERDSpaceDelims            = 1
  let g:NERDTrimTrailingWhitespace = 1
Plug 'mattn/emmet-vim'
Plug 'ap/vim-css-color'

Plug 'preservim/vim-markdown'
  let g:vim_markdown_no_default_keymappings     = 1
  let g:vim_markdown_no_extensions_in_markdown  = 1
  let g:vim_markdown_edit_url_in                = 'vsplit'
  let g:vim_markdown_toc_autofit                = 1
  let g:vim_markdown_folding_disabled           = 1
  let g:vim_markdown_folding_level              = 6
  let g:vim_markdown_new_list_item_indent       = 0
  let g:vim_markdown_emphasis_multiline         = 0
  let g:vim_markdown_strikethrough              = 1
  let g:vim_markdown_math                       = 1
  let g:vim_markdown_conceal_code_blocks        = 0
  let g:tex_conceal                             = ""
  let g:vim_markdown_frontmatter                = 1
  let g:vim_markdown_toml_frontmatter           = 1
  let g:vim_markdown_json_frontmatter           = 1
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install' }
  let g:mkdp_browser = 'qutebrowser'
Plug 'dhruvasagar/vim-table-mode'
  let g:table_mode_relign_map               = '<leader>tr'
  let g:table_mode_tableize_map             = '<leader>tt'
  let g:table_mode_delete_row_map           = '<leader>tdr'
  let g:table_mode_delete_column_map        = '<leader>tdc'
  let g:table_mode_insert_column_before_map = '<leader>tic'
  let g:table_mode_insert_column_after_map  = '<leader>tac'

Plug 'itchyny/lightline.vim'
Plug 'sainnhe/everforest'
Plug 'b4skyx/serenade'

call plug#end()

" other settings
let g:fzf_layout = {
    \ 'window': { 'width': 0.6, 'height': 0.4, 'yoffset': 0 }
    \ }

let s:hidden_all = 0
function! ToggleHiddenAll()
  if s:hidden_all == 0
    let s:hidden_all = 1
    set noshowmode
    set noruler
    set laststatus=0
    set noshowcmd
  else
    let s:hidden_all = 0
    set laststatus=2
    set showcmd
  endif
endfunction

