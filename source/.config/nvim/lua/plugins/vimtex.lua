local F = require('utils.functions')

-- Preparation
F.g('vimtex_view_method',     'zathura')
F.g('vimtex_compiler_method', 'tectonic')

-- maps
F.nnmap('<leader>vcl',  ':VimtexClean<CR>')
F.nnmap('<leader>vcp',  ':VimtexCompileSS<CR>')
F.nnmap('<leader>vtoc', ':VimTexTocToggle<CR>')
F.nnmap('<leader>vst',  ':VimtexStatus!<CR>')
F.nnmap('<leader>vv',   ':VimtexView<CR>')
