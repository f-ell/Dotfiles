if not pcall(require, 'lspconfig')
  or not pcall(require, 'nvim-lsp-installer') then
    return
end

require('nvim-lsp-installer').setup()
require('lsp.setup')
require('lsp.functions').setup()
