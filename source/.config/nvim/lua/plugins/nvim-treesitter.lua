return {
  'nvim-treesitter/nvim-treesitter',
  lazy    = true,
  event   = { 'BufReadPost', 'BufNewFile' },
  config  = function()
    require('nvim-treesitter.configs').setup({
      auto_install      = false,
      ensure_installed  = {},
      highlight = {
        enable  = true,
        additional_vim_regex_highlighting = true
      }
    })
  end
}
