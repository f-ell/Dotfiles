return {
  'lervag/vimtex',
  lazy    = true,
  ft      = { 'latex', 'plaintex', 'tex' },
  keys    = {
    { '<leader>vcl',  ':VimtexClean<CR>' },
    { '<leader>vcp',  ':VimtexCompileSS<CR>' },
    { '<leader>vtoc', ':VimtexTocToggle<CR>' },
    { '<leader>vst',  ':VimtexStatus!<CR>' },
    { '<leader>vv',   ':VimtexView<CR>' }
  },
  config  = function()
    local F = require('utils.functions')

    F.g('vimtex_view_method',     'zathura')
    F.g('vimtex_compiler_method', 'tectonic')
  end
}
