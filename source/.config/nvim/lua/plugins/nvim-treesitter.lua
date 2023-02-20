return {
  'nvim-treesitter/nvim-treesitter',
  lazy    = true,
  event   = { 'BufNewFile', 'BufReadPost' },
  dependencies = {
    'JoosepAlviste/nvim-ts-context-commentstring',
    {
      'nvim-treesitter/nvim-treesitter-context',
      opts = {
        enable      = true,
        mode        = 'cursor',
        trim_scope  = 'outer',
        max_lines         = 4,
        min_window_height = 24
      }
    }
  },
  config  = function()
    require('nvim-treesitter.configs').setup({
      auto_install      = false,
      ensure_installed  = {},

      highlight = {
        enable  = true,
        additional_vim_regex_highlighting = false
      },

      context_commentstring = {
        enable          = true,
        enable_autocmd  = false,
      },
    })
  end
}
