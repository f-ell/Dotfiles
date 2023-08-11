return {
  'lervag/vimtex',
  lazy = true,
  ft = { 'latex', 'plaintex', 'tex' },
  keys = {
    { '<leader>vc', '<CMD>VimtexCompileSS<CR>' },
    { '<leader>vs', '<CMD>VimtexStatus!<CR>' },
    { '<leader>vt', '<CMD>VimtexTocToggle<CR>' },
    { '<leader>vv', '<CMD>VimtexView<CR>' }
  },
  config = function()
    local vim = require('utils.lib').vim
    vim.g('vimtex_view_method', 'zathura')
    vim.g('vimtex_compiler_method', 'tectonic')
    vim.g('vimtex_view_forward_search_on_start', 0)
    vim.g('vimtex_toc_show_preable', 0)
    vim.g('vimtex_toc_config', {
      name = 'Table of Contents',
      indent_levels = 1,
      layer_status = { include = 0 },
      show_help = 0,
      split_pos = 'vert rightbelow',
      split_width = 38
    })
  end
}
