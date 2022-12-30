return {
  'norcalli/nvim-colorizer.lua',
  lazy    = true,
  event   = 'BufReadPost',
  keys    = { { '<leader>ct', '<CMD>ColorizerToggle<CR>' } },
  config  = function()
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
  end
}
