return {
  'folke/todo-comments.nvim',
  lazy = true,
  event = 'VimEnter',
  dependencies = 'nvim-lua/plenary.nvim',
  config = function() require('todo-comments').setup() end
}
