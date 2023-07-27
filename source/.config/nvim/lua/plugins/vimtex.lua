return {
  'lervag/vimtex',
  lazy = true,
  ft = { 'latex', 'plaintex', 'tex' },
  keys = {
    { '<leader>vl', '<CMD>VimtexClean<CR>' },
    { '<leader>vc', '<CMD>VimtexCompileSS<CR>' },
    { '<leader>vs', '<CMD>VimtexStatus!<CR>' },
    { '<leader>vv', '<CMD>VimtexView<CR>' }
  },
  config = function()
    local vim = require('utils.lib').vim
    vim.g('vimtex_view_method', 'zathura')
    vim.g('vimtex_compiler_method', 'tectonic')
  end
}
