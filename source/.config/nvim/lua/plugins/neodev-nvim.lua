return {
  'folke/neodev.nvim',
  lazy = true,
  ft = 'lua',
  config = function()
    require('neodev').setup({
      library = {
        enabled = true,
        runtime = true,
        types = true,
        plugins = false,
      },
      setup_jsonls = true,
      lspconfig = false,
      pathStrict = true,
    })
  end
}
