return {
  'echasnovski/mini.align',
  lazy = true,
  event = 'VeryLazy',
  config = function()
    require('mini.align').setup({
      mappings = {
        start = '<leader>a',
        start_with_preview = '<leader>A'
      }
    })
  end
}
