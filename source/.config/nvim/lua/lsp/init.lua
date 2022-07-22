local ok1, lspconfig  = pcall(require, 'lspconfig')
local ok2, lspinstall = pcall(require, 'nvim-lsp-installer')
if not ok1 then
    return
end

lspinstall.setup()
require('lsp.setup')
require('lsp.functions').setup()

return
