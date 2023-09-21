return {
  'lervag/vimtex',
  lazy = true,
  ft = { 'plaintex', 'tex' },
  config = function()
    local L = require('utils.lib')

    L.vim.g('vimtex_syntax_enabled', 0)
    L.vim.g('vimtex_compiler_method', 'tectonic')
    L.vim.g('vimtex_compiler_tectonic', {
      options = { '--keep-intermediates', '--keep-logs', '--synctex' }
    })

    L.vim.g('vimtex_toc_show_preable', 0)
    L.vim.g('vimtex_toc_config', {
      name = 'Table of Contents',
      indent_levels = 1,
      layer_status = { include = 0, label = 0 },
      show_help = 0,
      split_pos = 'vert rightbelow',
      split_width = 38,
      tocdepth = 1,
      todo_sorted = 0
    })

    L.vim.g('vimtex_quickfix_autoclose_after_keystrokes', 1)
    L.vim.g('vimtex_quickfix_ignore_filters', {
      '\\hbox (badness 10000)',
      'inputenc package ignored',
      'biblatex.*Using fall-back BibTeX(8) backend'
    })

    L.vim.g('vimtex_view_method', 'zathura')
    L.vim.g('vimtex_view_forward_search_on_start', 0)

    L.key.nnmap('<localleader>lt', '<CMD>VimtexTocToggle<CR>')
    L.key.nnmap('<localleader>lT', '<CMD>VimtexTocOpen<CR>')
  end
}
