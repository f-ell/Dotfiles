local L = require('utils.lib')

L.vim.o('spell', true);

vim.api.nvim_create_autocmd('BufWritePre', {
  buffer = vim.api.nvim_get_current_buf(),
  callback = function()
    if not (
      vim.bo.modified
      and vim.g.loaded_vimtex
      and vim.g.vimtex_compiler_method == 'tectonic'
      ) then
      return
    end

    vim.api.nvim_create_autocmd('BufWritePost', {
      once = true,
      buffer = vim.api.nvim_get_current_buf(),
      callback = function() vim.cmd('silent VimtexCompileSS') end
    })
  end
})
