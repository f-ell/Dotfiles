return {
  'nvim-tree/nvim-web-devicons',
  lazy = true,
  config = function()
    -- inspired by projekt0n/circles.nvim
    local nwd = require('nvim-web-devicons')
    nwd.setup({ default = true })
    for _, icon in pairs(nwd.get_icons()) do icon.icon = '' end
    nwd.set_default_icon('', '#859289')
  end
}
