return {
  'folke/todo-comments.nvim',
  lazy = true,
  dependencies = 'nvim-lua/plenary.nvim',
  event = 'VeryLazy',
  config = function()
    require('todo-comments').setup({
      signs = false,
      highlight = { multiline = false }
    })
  end
}
