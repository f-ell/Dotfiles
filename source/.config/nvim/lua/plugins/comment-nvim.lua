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
      opleader  = { line = '<leader>m' },
      pre_hook  = require('ts_context_commentstring.integrations.comment_nvim')
        .create_pre_hook()
    })
  end
}
