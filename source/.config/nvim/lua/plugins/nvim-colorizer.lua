local F = require('utils.functions')

require('colorizer').setup({'*'}, {
  RGB       = true;
  RRGGBB    = true;
  RRGGBBAA  = true;
  rgb_fn    = true;
  hsl_fn    = true;
  css       = true;
  css_fn    = true;
  mode = 'background'
})

vim.cmd('ColorizerToggle')


-- maps
F.nnmap('<leader>ct', ':ColorizerToggle<CR>')
