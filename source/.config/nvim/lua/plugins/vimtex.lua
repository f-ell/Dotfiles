return {
  'lervag/vimtex',
  lazy = true,
  ft = { 'plaintex', 'tex' },
  config = function()
    local vim = require('utils.lib').vim

    vim.g('vimtex_compiler_method', 'tectonic')
    vim.g('vimtex_compiler_tectonic', {
      options = { '--keep-intermediates', '--keep-logs', '--synctex' }
    })

    vim.g('vimtex_toc_show_preable', 0)
    vim.g('vimtex_toc_config', {
      name = 'Table of Contents',
      indent_levels = 1,
      layer_status = { include = 0, label = 0 },
      show_help = 0,
      split_pos = 'vert rightbelow',
      split_width = 38
    })

    vim.g('vimtex_quickfix_autoclose_after_keystrokes', 1)
    vim.g('vimtex_quickfix_ignore_filters', {
      '\\hbox (badness 10000)',
      'inputenc package ignored',
      'biblatex.*Using fall-back BibTeX(8) backend'
    })

    vim.g('vimtex_view_method', 'zathura')
    vim.g('vimtex_view_forward_search_on_start', 0)
  end
}
