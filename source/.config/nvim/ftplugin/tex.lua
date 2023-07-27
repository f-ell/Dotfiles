vim.api.nvim_create_autocmd('BufWritePost', {
  buffer = vim.api.nvim_get_current_buf(),
  callback = function()
    -- NOTE: inefficient but requierd with delayed Vimtex load
    if vim.g.loaded_vimtex and vim.g.vimtex_compiler_method == 'tectonic' then
      vim.cmd('silent VimtexCompileSS');
    end
  end
})
