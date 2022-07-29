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
  Plug 'itchyny/lightline.vim'
  Plug 'sainnhe/everforest'
  Plug 'b4skyx/serenade'

  Plug 'neovim/nvim-lspconfig'
  Plug 'sheerun/vim-polyglot'

  Plug 'ap/vim-css-color'
  Plug 'mattn/emmet-vim'
  Plug 'tpope/vim-surround'
  Plug 'terrortylor/nvim-comment'

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
    let g:tex_conceal                             = ''
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
call plug#end()


" lsp and other initialization

" vim.keymap.set('n', '<leader>vr', vim.lsp.buf.rename, {buffer = 0})
lua <<EOF
require('lspconfig').perlpls.setup{
  on_attach = function()
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, {buffer = 0})
    vim.keymap.set('n', '<leader>dj', vim.diagnostic.goto_next, {buffer = 0})
    vim.keymap.set('n', '<leader>dk', vim.diagnostic.goto_prev, {buffer = 0})
  end,
  }
require('nvim_comment').setup({
--   line_mapping = "<leader>cc",
--   operator_mapping = "<leader>c",
--   comment_chunk_text_object = "ic",
})
EOF


" other
let g:fzf_layout = { 'window': { 'width': 0.5, 'height': 0.4, 'relative': v:true, 'yoffset': 0.75 } }

let s:hidden_all = 0
function! ToggleHiddenAll()
  if s:hidden_all == 0
    let s:hidden_all = 1
    set noshowmode noshowcmd nocursorline noruler
    set laststatus=0
  else
    let s:hidden_all = 0
    set showmode showcmd cursorline ruler
    set laststatus=3
  endif
endfunction

