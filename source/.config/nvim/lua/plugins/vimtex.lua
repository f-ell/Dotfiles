return {
  'lervag/vimtex',
  lazy    = true,
  ft      = { 'latex', 'plaintex', 'tex' },
  keys    = {
    { '<leader>vcl',  '<CMD>VimtexClean<CR>' },
    { '<leader>vcp',  '<CMD>VimtexCompileSS<CR>' },
    { '<leader>vtoc', '<CMD>VimtexTocToggle<CR>' },
    { '<leader>vst',  '<CMD>VimtexStatus!<CR>' },
    { '<leader>vv',   '<CMD>VimtexView<CR>' }
  },
  config  = function()
    local L = require('utils.lib')

    L.g('vimtex_view_method',     'zathura')
    L.g('vimtex_compiler_method', 'tectonic')
  end
}
