return {
  'terrortylor/nvim-comment',
  lazy = true,
  keys = { 'm', '<leader>m', },
  config = function()
    require('nvim_comment').setup({
      line_mapping              = 'm',
      operator_mapping          = '<leader>m',
      comment_chunk_text_object = 'ic',
      hook = function()
        require('ts_context_commentstring.internal').update_commentstring()
      end
    })
  end
}
