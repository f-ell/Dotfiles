require('nvim-treesitter.configs').setup({
  auto_install = false,
  ensure_installed = {
    'java', 'latex', 'lua', 'markdown', 'python',
  },
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = true
  }
})
