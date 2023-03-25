return {
  'folke/todo-comments.nvim',
  lazy = true,
  dependencies = 'nvim-lua/plenary.nvim',
  event = 'BufReadPost',
  config = function() require('todo-comments').setup() end
}
