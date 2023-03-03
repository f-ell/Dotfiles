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
    },
    'nvim-treesitter/nvim-treesitter-textobjects'
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

      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          include_surrounding_whitespace = true,
          keymaps = { -- queries located in textobjects.scm
            ['af'] = '@function.outer',
            ['if'] = '@function.inner',
            ['ac'] = '@conditional.outer',
            ['ic'] = '@conditional.inner',
            ['aC'] = '@class.outer',
            ['iC'] = '@class.inner'
          }
        }
      }
    })
  end
}
