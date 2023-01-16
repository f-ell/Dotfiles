return {
  'glepnir/lspsaga.nvim',
  lazy    = true, -- required as dependency in lsp_bootstrap.lua
  config  = function()
    require('lspsaga').setup({
      ui = {
        border    = 'rounded',
        winblend  = 0,
        code_action = ' ',
        diagnostic  = ' '
      },
      symbol_in_winbar = { enable = false },
      preview = {
        lines_above = 0,
        lines_below = 8,
      },
      scroll_preview = {
        scroll_up   = '<C-k>',
        scroll_down = '<C-j>'
      },

      lightbulb = {
        enable            = true,
        enable_in_insert  = false,
        sign              = true,
        virtual_text      = false
      },
      code_action = { num_shortcut = true, quit = '<C-c>' },

      definition = { quit = '<C-c>' },

      diagnostic = {
        show_code_action = false,
        keys = { quit = '<C-c>' }
      },

      rename = {
        in_select = true,
        quit = '<C-c>'
      }
    })
  end
}
