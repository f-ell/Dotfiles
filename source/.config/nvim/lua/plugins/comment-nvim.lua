return {
  'numToStr/Comment.nvim',
  lazy  = true,
  event = 'FileType',
  config = function()
    require('Comment').setup({
      sticky    = true,
      padding   = true,
      mappings  = { basic = true, extra = false },
      toggler   = { line = 'm' },
      opleader  = { line = '<leader>m' }
    })
  end
}
